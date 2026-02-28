package repositories

import (
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

type CourierRepository struct {
	db *gorm.DB
}

func NewCourierRepository(db *gorm.DB) *CourierRepository {
	return &CourierRepository{db: db}
}

// GetReconciliationReport returns cash reconciliation for all couriers
// Shows delivered vs collected amounts per courier for a tenant
func (r *CourierRepository) GetReconciliationReport(tenantID uuid.UUID) ([]models.CourierReconciliation, error) {
	var results []models.CourierReconciliation

	// Query: Per courier, sum of amounts for delivered orders minus sum for collected orders
	err := r.db.
		Table("couriers c").
		Select(`
			c.id as courier_id,
			c.name as courier_name,
			COALESCE(SUM(CASE WHEN o.status = ? THEN o.total_order_amount ELSE 0 END), 0) as delivered_amount,
			COALESCE(SUM(CASE WHEN o.status = ? THEN o.total_order_amount ELSE 0 END), 0) as collected_amount,
			COALESCE(SUM(CASE WHEN o.status = ? THEN o.total_order_amount ELSE 0 END), 0) -
			COALESCE(SUM(CASE WHEN o.status = ? THEN o.total_order_amount ELSE 0 END), 0) as pending_amount
		`, models.OrderStatusDelivered, models.OrderStatusCollected, models.OrderStatusDelivered, models.OrderStatusCollected).
		Joins("LEFT JOIN orders o ON c.id = o.courier_id AND o.tenant_id = c.tenant_id AND o.deleted_at IS NULL").
		Where("c.tenant_id = ?", tenantID).
		Where("c.deleted_at IS NULL").
		Group("c.id, c.name").
		Order("c.created_at DESC").
		Scan(&results).
		Error

	return results, err
}
