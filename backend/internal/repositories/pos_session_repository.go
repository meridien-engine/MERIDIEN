package repositories

import (
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

// POSSessionRepository handles database operations for POS sessions
type POSSessionRepository struct {
	db *gorm.DB
}

// NewPOSSessionRepository creates a new POS session repository instance
func NewPOSSessionRepository(db *gorm.DB) *POSSessionRepository {
	return &POSSessionRepository{db: db}
}

// POSSessionFilters contains filter parameters for listing POS sessions
type POSSessionFilters struct {
	Status    string
	CashierID uuid.UUID
	SortBy    string
	SortOrder string
	Limit     int
	Offset    int
}

// Create persists a new POS session
func (r *POSSessionRepository) Create(s *models.POSSession) error {
	return tenantTx(r.db, s.TenantID, func(tx *gorm.DB) error {
		return tx.Create(s).Error
	})
}

// FindByID retrieves a session by ID within a tenant
func (r *POSSessionRepository) FindByID(id, tenantID uuid.UUID) (*models.POSSession, error) {
	var session models.POSSession
	err := tenantTx(r.db, tenantID, func(tx *gorm.DB) error {
		return tx.Where("id = ? AND tenant_id = ?", id, tenantID).
			Preload("Cashier").
			First(&session).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("session not found")
		}
		return nil, err
	}
	return &session, nil
}

// FindOpenByUser retrieves the currently open session for a cashier
func (r *POSSessionRepository) FindOpenByUser(cashierID, tenantID uuid.UUID) (*models.POSSession, error) {
	var session models.POSSession
	err := tenantTx(r.db, tenantID, func(tx *gorm.DB) error {
		return tx.Where("cashier_id = ? AND tenant_id = ? AND status = ?",
			cashierID, tenantID, models.POSSessionStatusOpen).
			Preload("Cashier").
			First(&session).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil // no open session is a valid state
		}
		return nil, err
	}
	return &session, nil
}

// Update saves changes to an existing session
func (r *POSSessionRepository) Update(s *models.POSSession) error {
	return tenantTx(r.db, s.TenantID, func(tx *gorm.DB) error {
		return tx.Save(s).Error
	})
}

// List returns paginated sessions for a tenant
func (r *POSSessionRepository) List(tenantID uuid.UUID, filters POSSessionFilters) ([]models.POSSession, int64, error) {
	var sessions []models.POSSession
	var total int64

	err := tenantTx(r.db, tenantID, func(tx *gorm.DB) error {
		query := tx.Model(&models.POSSession{}).Where("tenant_id = ?", tenantID)

		if filters.Status != "" {
			query = query.Where("status = ?", filters.Status)
		}
		if filters.CashierID != uuid.Nil {
			query = query.Where("cashier_id = ?", filters.CashierID)
		}

		if err := query.Count(&total).Error; err != nil {
			return err
		}

		sortField := "opened_at"
		sortOrder := "DESC"
		if filters.SortBy != "" {
			sortField = filters.SortBy
		}
		if filters.SortOrder != "" {
			sortOrder = filters.SortOrder
		}
		query = query.Order(fmt.Sprintf("%s %s", sortField, sortOrder))

		limit := 20
		offset := 0
		if filters.Limit > 0 {
			limit = filters.Limit
		}
		if filters.Offset >= 0 {
			offset = filters.Offset
		}

		return query.Preload("Cashier").Limit(limit).Offset(offset).Find(&sessions).Error
	})
	if err != nil {
		return nil, 0, err
	}
	return sessions, total, nil
}

// SumCashPayments returns the total cash collected during this session window
func (r *POSSessionRepository) SumCashPayments(session *models.POSSession) (decimal.Decimal, error) {
	var total decimal.Decimal

	closedAt := time.Now()
	if session.ClosedAt != nil {
		closedAt = *session.ClosedAt
	}

	err := r.db.Transaction(func(tx *gorm.DB) error {
		sql := fmt.Sprintf("SET LOCAL app.current_tenant = '%s'", session.TenantID.String())
		if err := tx.Exec(sql).Error; err != nil {
			return err
		}
		return tx.Raw(`
			SELECT COALESCE(SUM(p.amount), 0)
			FROM payments p
			WHERE p.tenant_id = ?
			  AND p.payment_method = 'cash'
			  AND p.deleted_at IS NULL
			  AND p.created_at >= ?
			  AND p.created_at <= ?`,
			session.TenantID, session.OpenedAt, closedAt).
			Scan(&total).Error
	})
	if err != nil {
		return decimal.Zero, fmt.Errorf("failed to sum cash payments: %w", err)
	}
	return total, nil
}
