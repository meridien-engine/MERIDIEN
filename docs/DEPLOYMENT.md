# MERIDIEN — Deployment Guide

> Last updated: March 2026
> Backend: Go 1.25 · Gin · GORM · PostgreSQL 15+ · Redis (optional)

---

## Table of Contents

1. [Production Readiness Status](#1-production-readiness-status)
2. [Prerequisites](#2-prerequisites)
3. [Environment Variables](#3-environment-variables)
4. [Known Issues to Fix Before Go-Live](#4-known-issues-to-fix-before-go-live)
5. [Database Setup & Migrations](#5-database-setup--migrations)
6. [Deployment Options](#6-deployment-options)
   - [Docker (Recommended)](#option-a-docker-recommended)
   - [Bare Metal / VPS](#option-b-bare-metal--vps)
   - [Managed Platforms](#option-c-managed-platforms)
7. [Reverse Proxy & TLS](#7-reverse-proxy--tls)
8. [Redis Setup](#8-redis-setup)
9. [Health Checks](#9-health-checks)
10. [Security Checklist](#10-security-checklist)
11. [Rollback Procedures](#11-rollback-procedures)
12. [Monitoring & Logging](#12-monitoring--logging)
13. [CI/CD Pipeline](#13-cicd-pipeline)
14. [Post-Deploy Verification](#14-post-deploy-verification)

---

## 1. Production Readiness Status

| Area | Status | Blocker? |
|------|--------|----------|
| Graceful shutdown | ✅ Implemented | — |
| JWT + token blacklist | ✅ Implemented | — |
| Row-Level Security (RLS) | ✅ Enabled | — |
| bcrypt password hashing | ✅ Cost 10 | — |
| Auth rate limiting | ✅ Redis-backed | — |
| Database migrations | ✅ 14 migrations | — |
| CORS configuration | ⚠️ Hardcoded to localhost | **Yes** |
| Structured logging | ⚠️ Uses `log` + emojis | No (but needed) |
| TLS / HTTPS | ⚠️ Not in code (needs reverse proxy) | **Yes** |
| DB SSL | ⚠️ Default is `disable` | **Yes** |
| Dockerfile | ❌ Not yet created | **Yes** |
| Test coverage | ⚠️ ~7% | No (but risky) |
| Request timeouts | ⚠️ Not set | No |
| Prometheus metrics | ❌ Not yet implemented | No |

**Must resolve items 3, 4, 5, 7 before accepting real traffic.**

---

## 2. Prerequisites

### Server Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 1 vCPU | 2 vCPU |
| RAM | 512 MB | 1 GB |
| Disk | 10 GB | 20 GB SSD |
| OS | Ubuntu 22.04+ | Ubuntu 24.04 LTS |

### Required Services

- **PostgreSQL 15+** — primary datastore (managed preferred: Neon, Supabase, RDS)
- **Redis 7+** — token blacklist + rate limiting (optional but strongly recommended)
- **Go 1.25+** — only needed for bare metal builds; not needed with Docker

### DNS

Point your domain at the server IP before running Caddy/Nginx TLS setup.

---

## 3. Environment Variables

Create `backend/configs/.env` (or inject as environment variables in your container / platform).

```env
# ── Application ───────────────────────────────────────────────────────────────
APP_NAME=MERIDIEN
APP_ENV=production          # development | production
APP_PORT=8080
APP_DEBUG=false             # true = verbose GORM logs; false in production

# ── Database ──────────────────────────────────────────────────────────────────
DB_HOST=your-db-host
DB_PORT=5432
DB_USER=meridien
DB_PASSWORD=CHANGE_ME_strong_password
DB_NAME=meridien
DB_SSLMODE=require          # MUST be "require" in production — never "disable"

# Alternatively, for managed providers (Neon, Supabase) use the full DSN
# The app builds the DSN from the individual fields above.

# ── JWT ───────────────────────────────────────────────────────────────────────
# Generate with: openssl rand -hex 64
JWT_SECRET=CHANGE_ME_at_least_64_chars_of_random_entropy
JWT_EXPIRATION_HOURS=24

# ── Redis (optional — app runs without it, but auth features degrade) ─────────
REDIS_HOST=your-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=CHANGE_ME_redis_password
REDIS_DB=0
```

> **Never commit `.env` to Git.** Use a secrets manager (Doppler, AWS Secrets Manager, Vault) or inject as environment variables through your platform.

### Generating a secure JWT secret

```bash
openssl rand -hex 64
```

The app will refuse to start with `APP_ENV=production` if `JWT_SECRET` is still set to the default value.

---

## 4. Known Issues to Fix Before Go-Live

These are code changes required before the backend is production-safe.

### 4.1 CORS — Hardcoded to localhost

**File:** `backend/internal/router/router.go`

The `AllowOriginFunc` currently allows only `http://localhost:*`. All requests from a real domain will be rejected.

**Fix:** Replace the hardcoded check with an environment variable:

```go
// In router.go — replace AllowOriginFunc
allowedOrigins := strings.Split(os.Getenv("ALLOWED_ORIGINS"), ",")

corsConfig := cors.Config{
    AllowOriginFunc: func(origin string) bool {
        for _, o := range allowedOrigins {
            if strings.TrimSpace(o) == origin {
                return true
            }
        }
        return false
    },
    // ... rest unchanged
}
```

Add to your `.env`:

```env
ALLOWED_ORIGINS=https://app.yourdomain.com,https://yourdomain.com
```

### 4.2 DB SSL must be enabled

Set `DB_SSLMODE=require` (already the default in `.env.example`). Confirm your PostgreSQL host has a valid SSL certificate.

### 4.3 Graceful shutdown timeout

**File:** `backend/cmd/server/main.go`

The server currently waits indefinitely for in-flight requests on shutdown. Add a 30-second timeout to avoid hanging deployments:

```go
// Replace the current shutdown block
srv := &http.Server{Addr: addr, Handler: r}
go func() {
    if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
        log.Fatalf("server error: %v", err)
    }
}()

quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
<-quit

ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()
srv.Shutdown(ctx)
```

---

## 5. Database Setup & Migrations

### 5.1 Create the database

```bash
psql -h $DB_HOST -U $DB_USER -c "CREATE DATABASE meridien;"
```

Or use your managed provider's UI.

### 5.2 Create the application user (recommended)

```sql
CREATE USER meridien_app WITH PASSWORD 'strong_password';
GRANT CONNECT ON DATABASE meridien TO meridien_app;
GRANT USAGE ON SCHEMA public TO meridien_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO meridien_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO meridien_app;
-- RLS requires SET on the configuration parameter
GRANT SET ON PARAMETER app.current_business TO meridien_app;
```

### 5.3 Run migrations

```bash
cd backend
./scripts/run-migrations.sh
```

The script tracks applied migrations in the `schema_migrations` table and skips already-applied ones. It is safe to run multiple times.

**Migration order (14 migrations):**

| # | Migration | Description |
|---|-----------|-------------|
| 001 | `init_schema` | Users, UUID extension |
| 002 | `create_customers` | Customer table |
| 003 | `create_products` | Products + categories |
| 004 | `create_orders` | Orders + order items + payments |
| 005 | `add_audit_couriers` | Couriers + audit log |
| 006 | `enable_rls` | Row-Level Security on all tables |
| 007 | `add_pos` | POS sessions, order_type, pos checkout |
| 008 | `multi_business` | `tenants→businesses`, memberships |
| 009 | `add_stores` | Stores table |
| 010 | `membership_columns` | Join requests + invitations |
| 011 | `add_branches` | Branches + user branch access |
| 012 | `fix_product_unique` | Unique constraint scoped to business |
| 013 | `add_branch_inventory` | Branch-level stock |
| 014 | `add_locations_deleted_at` | Soft delete on locations |

### 5.4 Verify migrations

```bash
psql -h $DB_HOST -U $DB_USER -d meridien \
  -c "SELECT version, applied_at FROM schema_migrations ORDER BY version;"
```

Expected: 14 rows.

### 5.5 Rolling back a migration

Each migration has a corresponding `.down.sql` file:

```bash
psql -h $DB_HOST -U $DB_USER -d meridien \
  -f backend/migrations/000014_add_locations_deleted_at.down.sql

# Remove from tracking table
psql -h $DB_HOST -U $DB_USER -d meridien \
  -c "DELETE FROM schema_migrations WHERE version = '000014';"
```

> ⚠️ Always take a database snapshot before running migrations or rollbacks in production.

---

## 6. Deployment Options

### Option A: Docker (Recommended)

> A Dockerfile does not yet exist and must be created. Below is the template to use.

**`backend/Dockerfile`:**

```dockerfile
# ── Build stage ───────────────────────────────────────────────────────────────
FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o meridien ./cmd/server

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM alpine:3.20

RUN addgroup -S meridien && adduser -S meridien -G meridien
WORKDIR /app

COPY --from=builder /app/meridien .
COPY --from=builder /app/migrations ./migrations

USER meridien
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1

ENTRYPOINT ["./meridien"]
```

**`docker-compose.yml` (local dev & staging):**

```yaml
version: '3.9'

services:
  app:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      APP_ENV: production
      APP_PORT: 8080
      DB_HOST: postgres
      DB_PORT: 5432
      DB_USER: meridien
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: meridien
      DB_SSLMODE: disable       # only disable inside a private Docker network
      JWT_SECRET: ${JWT_SECRET}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      ALLOWED_ORIGINS: ${ALLOWED_ORIGINS}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: meridien
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: meridien
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U meridien"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

**Build and run:**

```bash
# Build
docker build -t meridien-backend ./backend

# Run with compose
cp .env.example .env   # fill in values
docker compose up -d

# Run migrations inside the container
docker compose exec app sh -c "cd /app && ./scripts/run-migrations.sh"

# Check logs
docker compose logs -f app
```

---

### Option B: Bare Metal / VPS

1. **Build the binary on the server (or cross-compile locally):**

```bash
cd backend
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -ldflags="-s -w" -o meridien ./cmd/server
```

2. **Copy files to the server:**

```bash
scp meridien user@your-server:/opt/meridien/
scp -r migrations user@your-server:/opt/meridien/
scp -r scripts user@your-server:/opt/meridien/
```

3. **Create a systemd service** (`/etc/systemd/system/meridien.service`):

```ini
[Unit]
Description=MERIDIEN Backend API
After=network.target postgresql.service

[Service]
Type=simple
User=meridien
WorkingDirectory=/opt/meridien
ExecStart=/opt/meridien/meridien
Restart=always
RestartSec=5

# Environment — or use EnvironmentFile=/opt/meridien/.env
Environment=APP_ENV=production
Environment=APP_PORT=8080
Environment=DB_HOST=localhost
Environment=DB_NAME=meridien
Environment=DB_SSLMODE=require
# ... add remaining vars

[Install]
WantedBy=multi-user.target
```

4. **Enable and start:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable meridien
sudo systemctl start meridien
sudo systemctl status meridien
```

---

### Option C: Managed Platforms

| Platform | Notes |
|----------|-------|
| **Railway** | Connect GitHub repo, set env vars in dashboard, auto-deploys on push |
| **Render** | Web Service → Dockerfile, set env vars, free PostgreSQL available |
| **Fly.io** | `fly launch` from backend directory, `fly secrets set` for env vars |
| **Google Cloud Run** | Push Docker image to Artifact Registry, deploy as Cloud Run service |
| **AWS ECS / App Runner** | ECR for image, App Runner for zero-config container hosting |

For all managed platforms:
- Use a **managed PostgreSQL** (Neon, Supabase, or platform-native)
- Use a **managed Redis** (Upstash free tier works for start)
- Inject all env vars through the platform's secrets UI — never bake into the image

---

## 7. Reverse Proxy & TLS

The Go server listens on plain HTTP. TLS termination must be handled by a reverse proxy.

### Caddy (easiest — auto TLS)

```caddyfile
# /etc/caddy/Caddyfile
api.yourdomain.com {
    reverse_proxy localhost:8080
}
```

```bash
sudo apt install caddy
sudo systemctl enable --now caddy
```

Caddy automatically obtains and renews Let's Encrypt certificates.

### Nginx

```nginx
server {
    listen 443 ssl;
    server_name api.yourdomain.com;

    ssl_certificate     /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name api.yourdomain.com;
    return 301 https://$host$request_uri;
}
```

Get a certificate with Certbot:

```bash
sudo certbot --nginx -d api.yourdomain.com
```

---

## 8. Redis Setup

Redis is **optional** — the app runs without it, but these features will be disabled:

| Feature | Without Redis |
|---------|---------------|
| Token revocation on logout | Disabled (tokens remain valid until expiry) |
| Auth rate limiting | Disabled (unlimited auth attempts) |

### Minimum Redis configuration (`/etc/redis/redis.conf`):

```
requirepass your_redis_password
maxmemory 128mb
maxmemory-policy allkeys-lru
save ""                  # disable RDB persistence (cache only)
```

### Recommended: Use a managed Redis

- **Upstash** — free tier, 10k commands/day, works well for this use case
- **Redis Cloud** — free 30 MB tier
- **AWS ElastiCache** — production-grade

---

## 9. Health Checks

The server exposes a health endpoint:

```
GET /health
```

**Expected response (200 OK):**

```json
{
  "status": "ok",
  "service": "MERIDIEN"
}
```

Use this URL for:
- Load balancer health checks
- Docker `HEALTHCHECK`
- Kubernetes liveness/readiness probes
- Uptime monitoring (UptimeRobot, BetterUptime)

---

## 10. Security Checklist

Before going live, verify each item:

```
[ ] DB_SSLMODE=require (not disable)
[ ] JWT_SECRET is random, ≥64 characters (openssl rand -hex 64)
[ ] APP_DEBUG=false in production
[ ] CORS ALLOWED_ORIGINS set to your actual frontend domain only
[ ] .env file has permissions 600 (chmod 600 configs/.env)
[ ] No default passwords in use (DB, Redis)
[ ] TLS certificate active and auto-renewing
[ ] Redis has a password set
[ ] Server firewall: only ports 80, 443, 22 (SSH) open to public
[ ] PostgreSQL port 5432 NOT exposed to public internet
[ ] Redis port 6379 NOT exposed to public internet
[ ] APP_ENV=production set (enables JWT_SECRET validation)
[ ] Verified RLS is active: run the test in .github/workflows/ci-rls.yml
```

---

## 11. Rollback Procedures

### Application rollback

```bash
# With Docker — roll back to previous image tag
docker pull ghcr.io/your-org/meridien-backend:previous-tag
docker compose up -d --no-deps app

# With systemd — replace binary and restart
sudo systemctl stop meridien
cp /opt/meridien/meridien.backup /opt/meridien/meridien
sudo systemctl start meridien
```

### Database rollback

Always snapshot before migrating:

```bash
# Snapshot before migration
pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > backup_$(date +%Y%m%d_%H%M%S).sql

# Roll back one migration (example: 000014)
psql -h $DB_HOST -U $DB_USER -d $DB_NAME \
  -f backend/migrations/000014_add_locations_deleted_at.down.sql

psql -h $DB_HOST -U $DB_USER -d $DB_NAME \
  -c "DELETE FROM schema_migrations WHERE version = '000014';"
```

### Full restore from backup

```bash
psql -h $DB_HOST -U $DB_USER -c "DROP DATABASE meridien;"
psql -h $DB_HOST -U $DB_USER -c "CREATE DATABASE meridien;"
psql -h $DB_HOST -U $DB_USER -d meridien < backup_20260303_120000.sql
```

---

## 12. Monitoring & Logging

### Current logging state

The app uses Go's standard `log` package with emoji-prefixed messages. This is readable locally but **not parseable by log aggregators**. Before production:

- Replace `log` with a structured logger (`zap` or `logrus`)
- Output JSON in production: `{"level":"info","msg":"server started","port":"8080"}`
- Keep human-readable format in development

### Recommended logging stack (self-hosted)

```
App (stdout JSON) → Promtail → Loki → Grafana
```

### Recommended logging stack (managed)

| Service | Free tier | Notes |
|---------|-----------|-------|
| Axiom | 500MB/day | Excellent DX, easy setup |
| Logtail (BetterStack) | 1GB/month | Good for small apps |
| Datadog | 14-day trial | Full observability platform |

### Uptime monitoring

Use [UptimeRobot](https://uptimerobot.com) (free) to monitor `GET /health` every 5 minutes and alert on downtime.

---

## 13. CI/CD Pipeline

A basic RLS test workflow already exists at `.github/workflows/ci-rls.yml`.

### Recommended full pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Build & Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: meridien_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.25'
      - run: cd backend && go test ./...

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: |
          docker build -t ghcr.io/${{ github.repository }}/backend:${{ github.sha }} ./backend
          docker push ghcr.io/${{ github.repository }}/backend:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        run: |
          ssh ${{ secrets.DEPLOY_HOST }} \
            "docker pull ghcr.io/${{ github.repository }}/backend:${{ github.sha }} && \
             docker compose up -d --no-deps app"
```

**Secrets to add in GitHub repository settings:**

- `DEPLOY_HOST` — `user@your-server-ip`
- `DB_PASSWORD`
- `JWT_SECRET`
- `ALLOWED_ORIGINS`
- `REDIS_PASSWORD`

---

## 14. Post-Deploy Verification

Run these checks after every deployment:

```bash
BASE=https://api.yourdomain.com

# 1. Health check
curl -s $BASE/health | jq .
# Expected: {"status":"ok","service":"MERIDIEN"}

# 2. Register a test user
curl -s -X POST $BASE/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","last_name":"User","email":"test@example.com","password":"Test1234"}' \
  | jq .success

# 3. Login
TOKEN=$(curl -s -X POST $BASE/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234"}' \
  | jq -r '.token')
echo "Got token: ${TOKEN:0:20}..."

# 4. Get businesses (generic token)
curl -s -H "Authorization: Bearer $TOKEN" \
  $BASE/api/v1/auth/businesses | jq .

# 5. Verify CORS header
curl -s -I -H "Origin: https://app.yourdomain.com" \
  $BASE/health | grep -i access-control

# 6. Verify TLS
curl -sI https://api.yourdomain.com/health | head -1
# Expected: HTTP/2 200
```

---

## Quick Reference

```
Binary port:     8080 (set APP_PORT)
Health check:    GET /health
API prefix:      /api/v1
Migrations:      backend/scripts/run-migrations.sh
Config file:     backend/configs/.env
Migration files: backend/migrations/
Log format:      stdout (redirect to log aggregator)
```
