# 🚀 MERIDIEN Backend - Quick Start

Three simple commands to get your server running:

## Step 1: Create Database
```bash
cd /media/muhammad/Work/Identity/BM/MERIDIEN/backend
./scripts/create-database.sh
```
*Enter your sudo password when prompted*

## Step 2: Run Migrations
```bash
./scripts/run-migrations.sh
```

## Step 3: Start Server
```bash
./scripts/start-server.sh
```

## Verify It Works
```bash
curl http://localhost:8080/health
```

Expected output:
```json
{
  "status": "healthy",
  "service": "MERIDIEN API",
  "time": "2024-12-24T..."
}
```

---

## Alternative: Run Without Scripts

If scripts fail, do it manually:

### Create Database
```bash
sudo -u postgres psql << EOF
CREATE DATABASE meridien_dev;
\c meridien_dev
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE USER muhammad WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE meridien_dev TO muhammad;
EOF
```

### Run Migrations
```bash
sudo -u postgres psql -d meridien_dev -f migrations/000001_init_schema.up.sql
```

### Start Server
```bash
go run cmd/server/main.go
```

---

## Next: Build Authentication

Once your server is running, we'll implement:
1. User registration endpoint
2. Login with JWT
3. Protected routes with middleware
4. Password reset

See `NEXT-STEPS.md` for the full roadmap!
