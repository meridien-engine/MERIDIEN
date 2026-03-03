package repositories

import (
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// businessTx executes fn inside a transaction with SET LOCAL app.current_business
// so PostgreSQL RLS policies are satisfied. Use this for every query that
// touches a business-scoped table.
//
// Note: SET LOCAL does not support prepared statement parameters ($1 syntax),
// so the UUID is inlined directly. UUIDs are hex+hyphens only — no injection risk.
func businessTx(db *gorm.DB, businessID uuid.UUID, fn func(tx *gorm.DB) error) error {
	return db.Transaction(func(tx *gorm.DB) error {
		sql := fmt.Sprintf("SET LOCAL app.current_business = '%s'", businessID.String())
		if err := tx.Exec(sql).Error; err != nil {
			return err
		}
		return fn(tx)
	})
}

// tenantTx is an alias for businessTx kept for any remaining call sites.
// Deprecated: use businessTx.
func tenantTx(db *gorm.DB, businessID uuid.UUID, fn func(tx *gorm.DB) error) error {
	return businessTx(db, businessID, fn)
}
