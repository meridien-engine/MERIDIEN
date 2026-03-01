package main

import (
	"database/sql"
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
)

func main() {
	var (
		dsn       string
		csvPath   string
		tenantStr string
	)

	// Default DSN uses Unix socket (peer auth) — works without a password on local dev
	flag.StringVar(&dsn, "dsn",
		"host=/var/run/postgresql user=muhammad dbname=meridien_dev sslmode=disable TimeZone=UTC",
		"PostgreSQL DSN")
	flag.StringVar(&csvPath, "csv", "", "Path to the Bosta CSV dataset")
	flag.StringVar(&tenantStr, "tenant", "", "Tenant ID (UUID) to import locations for")
	flag.Parse()

	if csvPath == "" || tenantStr == "" {
		log.Fatal("Usage: import_bosta -csv <path_to_csv> -tenant <tenant_uuid>")
	}

	tenantID, err := uuid.Parse(tenantStr)
	if err != nil {
		log.Fatalf("Invalid tenant UUID: %v", err)
	}

	// 1. Connect using standard database/sql with lib/pq (no GORM model mapping)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}
	log.Println("✅ Connected to local database")

	// 2. Open CSV File
	file, err := os.Open(csvPath)
	if err != nil {
		log.Fatalf("Failed to open CSV file: %v", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	reader.LazyQuotes = true
	reader.FieldsPerRecord = -1

	records, err := reader.ReadAll()
	if err != nil {
		log.Fatalf("Failed to read CSV: %v", err)
	}

	if len(records) < 2 {
		log.Fatal("CSV file has no data rows")
	}

	// 3. Process records — deduplicate city+zone pairs
	// Bosta CSV column mapping:
	//   Col 0  = Country Code
	//   Col 3  = Gov [EN]       → City
	//   Col 8  = Area [EN]      → Zone prefix
	//   Col 14 = District [EN]  → Zone suffix
	type row struct{ city, zone string }
	seen := make(map[string]bool)
	var rows []row

	for i, r := range records {
		if i == 0 {
			continue // Skip header
		}
		if len(r) < 15 {
			continue
		}
		if strings.TrimSpace(r[0]) != "EG" {
			continue
		}

		city := strings.TrimSpace(r[3])
		area := strings.TrimSpace(r[8])
		district := strings.TrimSpace(r[14])

		var zone string
		if area != "" && district != "" {
			zone = fmt.Sprintf("%s - %s", area, district)
		} else if area != "" {
			zone = area
		} else if district != "" {
			zone = district
		}

		if city == "" {
			continue
		}

		key := city + "|" + zone
		if seen[key] {
			continue
		}
		seen[key] = true
		rows = append(rows, row{city: city, zone: zone})
	}

	log.Printf("Parsed %d unique locations. Inserting...", len(rows))

	// 4. Insert in a single transaction with RLS context set
	tx, err := db.Begin()
	if err != nil {
		log.Fatalf("Failed to begin transaction: %v", err)
	}

	// Set RLS tenant context for the transaction
	if _, err := tx.Exec(fmt.Sprintf("SET LOCAL app.current_tenant = '%s'", tenantID.String())); err != nil {
		tx.Rollback()
		log.Fatalf("Failed to set tenant context: %v", err)
	}

	const batchSize = 500
	for start := 0; start < len(rows); start += batchSize {
		end := start + batchSize
		if end > len(rows) {
			end = len(rows)
		}
		batch := rows[start:end]

		// Build a multi-row INSERT
		var values []string
		var args []interface{}
		for j, r := range batch {
			base := j * 3
			values = append(values, fmt.Sprintf("($%d, $%d, $%d, 0.00)", base+1, base+2, base+3))
			args = append(args, uuid.New().String(), tenantID.String(), r.city)
			// zone appended separately via UPDATE below if needed
			_ = r.zone // handled in separate pass
		}

		// Simpler: individual inserts are fine for 2778 rows
		stmt, err := tx.Prepare(`INSERT INTO locations (id, tenant_id, city, zone, shipping_fee)
		                          VALUES ($1, $2, $3, $4, 0.00)`)
		if err != nil {
			tx.Rollback()
			log.Fatalf("Failed to prepare statement: %v", err)
		}

		for _, r := range batch {
			if _, err := stmt.Exec(uuid.New().String(), tenantID.String(), r.city, r.zone); err != nil {
				stmt.Close()
				tx.Rollback()
				log.Fatalf("Failed to insert row (%s / %s): %v", r.city, r.zone, err)
			}
		}
		stmt.Close()
		log.Printf("  Inserted rows %d–%d...", start+1, end)
	}

	if err := tx.Commit(); err != nil {
		log.Fatalf("Failed to commit transaction: %v", err)
	}

	log.Printf("✅ Successfully imported %d locations for tenant %s!", len(rows), tenantID.String())
}
