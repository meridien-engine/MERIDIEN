package integration

import (
	"database/sql"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

func TestRLS_Enforcement(t *testing.T) {
	dsn := os.Getenv("MERIDIEN_DB_DSN")
	if dsn == "" {
		dsn = "user=postgres dbname=meridien_dev sslmode=disable"
	}

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		t.Skipf("skipping integration test; cannot reach DB using DSN '%s': %v\nSet MERIDIEN_DB_DSN to a writable test database (e.g. 'user=postgres dbname=meridien_dev sslmode=disable')", dsn, err)
	}

	tx, err := db.Begin()
	if err != nil {
		t.Fatalf("begin tx: %v", err)
	}
	defer tx.Rollback()

	tenantA := "11111111-1111-1111-1111-111111111111"
	tenantB := "22222222-2222-2222-2222-222222222222"

	// create tenants
	if _, err := tx.Exec("INSERT INTO tenants (id, name, slug, created_at) VALUES ($1, $2, $3, now()) ON CONFLICT (id) DO NOTHING", tenantA, "Tenant A", "tenant-a"); err != nil {
		t.Fatalf("insert tenantA: %v", err)
	}
	if _, err := tx.Exec("INSERT INTO tenants (id, name, slug, created_at) VALUES ($1, $2, $3, now()) ON CONFLICT (id) DO NOTHING", tenantB, "Tenant B", "tenant-b"); err != nil {
		t.Fatalf("insert tenantB: %v", err)
	}

	// insert one order per tenant
	if _, err := tx.Exec("INSERT INTO orders (id, tenant_id, status, total_order_amount, created_at) VALUES (gen_random_uuid(), $1, 'draft', 100, now())", tenantA); err != nil {
		t.Fatalf("insert order A: %v", err)
	}
	if _, err := tx.Exec("INSERT INTO orders (id, tenant_id, status, total_order_amount, created_at) VALUES (gen_random_uuid(), $1, 'draft', 200, now())", tenantB); err != nil {
		t.Fatalf("insert order B: %v", err)
	}

	// Query without setting app.current_tenant: expect an error (policy uses current_setting(... )::uuid)
	var cnt int
	err = tx.QueryRow("SELECT count(*) FROM orders WHERE tenant_id = $1", tenantA).Scan(&cnt)
	if err == nil {
		t.Fatalf("expected error when app.current_tenant is not set, got nil and count=%d", cnt)
	}

	// Set local tenant A and expect to see only tenant A's order
	if _, err := tx.Exec("SET LOCAL app.current_tenant = $1", tenantA); err != nil {
		t.Fatalf("set local tenant A: %v", err)
	}
	if err := tx.QueryRow("SELECT count(*) FROM orders WHERE tenant_id = $1", tenantA).Scan(&cnt); err != nil {
		t.Fatalf("query tenant A after set: %v", err)
	}
	if cnt != 1 {
		t.Fatalf("expected 1 row for tenant A, got %d", cnt)
	}

	// Switch to tenant B and expect to see only tenant B's order
	if _, err := tx.Exec("SET LOCAL app.current_tenant = $1", tenantB); err != nil {
		t.Fatalf("set local tenant B: %v", err)
	}
	if err := tx.QueryRow("SELECT count(*) FROM orders WHERE tenant_id = $1", tenantB).Scan(&cnt); err != nil {
		t.Fatalf("query tenant B after set: %v", err)
	}
	if cnt != 1 {
		t.Fatalf("expected 1 row for tenant B, got %d", cnt)
	}
}
