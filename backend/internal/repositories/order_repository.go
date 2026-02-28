package repositories

import (
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// OrderRepository handles database operations for orders
type OrderRepository struct {
	db *gorm.DB
}

// NewOrderRepository creates a new order repository instance
func NewOrderRepository(db *gorm.DB) *OrderRepository {
	return &OrderRepository{db: db}
}

// OrderListFilters contains filter parameters for listing orders
type OrderListFilters struct {
	CustomerID    uuid.UUID
	Status        string
	PaymentStatus string
	FromDate      time.Time
	ToDate        time.Time
	Search        string
	SortBy        string
	SortOrder     string
	Limit         int
	Offset        int
}

// Create creates a new order with items
func (r *OrderRepository) Create(order *models.Order) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// Set tenant for this transaction at LOCAL scope so it applies to this tx only
		if order.TenantID != uuid.Nil {
			if err := tx.Exec("SET LOCAL app.current_tenant = ?", order.TenantID).Error; err != nil {
				return err
			}
		}

		// Create the order
		if err := tx.Create(order).Error; err != nil {
			return err
		}
		return nil
	})
}

// FindByID finds an order by ID with all relationships
func (r *OrderRepository) FindByID(id uuid.UUID, tenantID uuid.UUID) (*models.Order, error) {
	var order models.Order
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("Customer").
		Preload("Items").
		Preload("Items.Product").
		Preload("Payments").
		First(&order).Error

	if err != nil {
		return nil, err
	}

	return &order, nil
}

// FindByOrderNumber finds an order by order number
func (r *OrderRepository) FindByOrderNumber(orderNumber string, tenantID uuid.UUID) (*models.Order, error) {
	var order models.Order
	err := r.db.Where("order_number = ? AND tenant_id = ?", orderNumber, tenantID).
		Preload("Customer").
		Preload("Items").
		Preload("Payments").
		First(&order).Error

	if err != nil {
		return nil, err
	}

	return &order, nil
}

// List returns a paginated list of orders with filters
func (r *OrderRepository) List(tenantID uuid.UUID, filters OrderListFilters) ([]models.Order, int64, error) {
	var orders []models.Order
	var total int64

	query := r.db.Model(&models.Order{}).Where("tenant_id = ?", tenantID)

	// Apply filters
	if filters.CustomerID != uuid.Nil {
		query = query.Where("customer_id = ?", filters.CustomerID)
	}

	if filters.Status != "" {
		query = query.Where("status = ?", filters.Status)
	}

	if filters.PaymentStatus != "" {
		query = query.Where("payment_status = ?", filters.PaymentStatus)
	}

	if !filters.FromDate.IsZero() {
		query = query.Where("order_date >= ?", filters.FromDate)
	}

	if !filters.ToDate.IsZero() {
		query = query.Where("order_date <= ?", filters.ToDate)
	}

	if filters.Search != "" {
		searchPattern := "%" + filters.Search + "%"
		query = query.Where("order_number ILIKE ?", searchPattern)
	}

	// Count total matching records
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Apply sorting
	sortBy := filters.SortBy
	if sortBy == "" {
		sortBy = "order_date"
	}

	sortOrder := filters.SortOrder
	if sortOrder == "" {
		sortOrder = "desc"
	}

	query = query.Order(sortBy + " " + sortOrder)

	// Apply pagination
	if filters.Limit > 0 {
		query = query.Limit(filters.Limit)
	}

	if filters.Offset > 0 {
		query = query.Offset(filters.Offset)
	}

	// Execute query with preloading
	err := query.
		Preload("Customer").
		Preload("Items").
		Preload("Payments").
		Find(&orders).Error

	if err != nil {
		return nil, 0, err
	}

	return orders, total, nil
}

// Update updates an order
func (r *OrderRepository) Update(order *models.Order) error {
	// Use optimistic locking: only update when version matches, then increment version
	return r.db.Transaction(func(tx *gorm.DB) error {
		if order.TenantID != uuid.Nil {
			if err := tx.Exec("SET LOCAL app.current_tenant = ?", order.TenantID).Error; err != nil {
				return err
			}
		}

		// store current version and increment
		prevVersion := order.Version
		order.Version = prevVersion + 1

		res := tx.Model(&models.Order{}).
			Where("id = ? AND tenant_id = ? AND version = ?", order.ID, order.TenantID, prevVersion).
			Select("*").
			Updates(order)

		if res.Error != nil {
			return res.Error
		}

		if res.RowsAffected == 0 {
			return errors.New("optimistic locking failure")
		}

		return nil
	})
}

// Delete soft deletes an order
func (r *OrderRepository) Delete(id uuid.UUID, tenantID uuid.UUID) error {
	return r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Delete(&models.Order{}).Error
}

// GenerateOrderNumber generates a unique order number for the tenant
func (r *OrderRepository) GenerateOrderNumber(tenantID uuid.UUID) (string, error) {
	// Format: ORD-YYYYMMDD-XXXX
	today := time.Now().Format("20060102")
	prefix := "ORD-" + today + "-"

	// Find the last order number for today
	var lastOrder models.Order
	err := r.db.Where("tenant_id = ? AND order_number LIKE ?", tenantID, prefix+"%").
		Order("order_number DESC").
		First(&lastOrder).Error

	sequence := 1
	if err == nil {
		// Extract sequence from last order number
		// ORD-20251224-0001 -> 0001
		if len(lastOrder.OrderNumber) >= 4 {
			lastSequence := lastOrder.OrderNumber[len(lastOrder.OrderNumber)-4:]
			var seqNum int
			if _, err := fmt.Sscanf(lastSequence, "%04d", &seqNum); err == nil {
				sequence = seqNum + 1
			}
		}
	} else if err != gorm.ErrRecordNotFound {
		return "", err
	}

	orderNumber := fmt.Sprintf("%s%04d", prefix, sequence)
	return orderNumber, nil
}

// UpdateStatus updates the order status
func (r *OrderRepository) UpdateStatus(id uuid.UUID, tenantID uuid.UUID, status string) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if tenantID != uuid.Nil {
			if err := tx.Exec("SET LOCAL app.current_tenant = ?", tenantID).Error; err != nil {
				return err
			}
		}

		res := tx.Model(&models.Order{}).
			Where("id = ? AND tenant_id = ?", id, tenantID).
			Update("status", status)

		return res.Error
	})
}

// UpdatePaymentStatus updates the payment status and paid amount
func (r *OrderRepository) UpdatePaymentStatus(id uuid.UUID, tenantID uuid.UUID, paymentStatus string, paidAmount string) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if tenantID != uuid.Nil {
			if err := tx.Exec("SET LOCAL app.current_tenant = ?", tenantID).Error; err != nil {
				return err
			}
		}

		res := tx.Model(&models.Order{}).
			Where("id = ? AND tenant_id = ?", id, tenantID).
			Updates(map[string]interface{}{
				"payment_status": paymentStatus,
				"paid_amount":    paidAmount,
			})

		return res.Error
	})
}

// CountByTenant returns the total number of orders for a tenant
func (r *OrderRepository) CountByTenant(tenantID uuid.UUID) (int64, error) {
	var count int64
	err := r.db.Model(&models.Order{}).
		Where("tenant_id = ?", tenantID).
		Count(&count).Error
	return count, err
}

// CountByStatus returns the count of orders by status for a tenant
func (r *OrderRepository) CountByStatus(tenantID uuid.UUID, status string) (int64, error) {
	var count int64
	err := r.db.Model(&models.Order{}).
		Where("tenant_id = ? AND status = ?", tenantID, status).
		Count(&count).Error
	return count, err
}

// GetTotalSales returns total sales amount for a tenant within a date range
func (r *OrderRepository) GetTotalSales(tenantID uuid.UUID, fromDate, toDate time.Time) (string, error) {
	var total struct {
		Sum string
	}

	query := r.db.Model(&models.Order{}).
		Select("COALESCE(SUM(total_amount), 0) as sum").
		Where("tenant_id = ? AND status NOT IN (?)", tenantID, []string{models.OrderStatusDraft, models.OrderStatusCancelled})

	if !fromDate.IsZero() {
		query = query.Where("order_date >= ?", fromDate)
	}

	if !toDate.IsZero() {
		query = query.Where("order_date <= ?", toDate)
	}

	err := query.Scan(&total).Error
	if err != nil {
		return "0", err
	}

	return total.Sum, nil
}
