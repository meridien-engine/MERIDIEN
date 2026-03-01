package repositories

import (
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// tenantTx executes fn inside a transaction with SET LOCAL app.current_tenant
// so PostgreSQL RLS policies are satisfied. Use this for every query that
// touches a tenant-scoped table.
//
// Note: SET LOCAL does not support prepared statement parameters ($1 syntax),
// so the UUID is inlined directly. UUIDs are hex+hyphens only — no injection risk.
func tenantTx(db *gorm.DB, tenantID uuid.UUID, fn func(tx *gorm.DB) error) error {
	return db.Transaction(func(tx *gorm.DB) error {
		sql := fmt.Sprintf("SET LOCAL app.current_tenant = '%s'", tenantID.String())
		if err := tx.Exec(sql).Error; err != nil {
			return err
		}
		return fn(tx)
	})
}
