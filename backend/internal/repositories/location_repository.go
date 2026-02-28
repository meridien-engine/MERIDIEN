package repositories

import (
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type LocationRepository struct {
	db *gorm.DB
}

func NewLocationRepository(db *gorm.DB) *LocationRepository {
	return &LocationRepository{db: db}
}

// Create creates a new location
func (r *LocationRepository) Create(location *models.Location) error {
	return r.db.Create(location).Error
}

// GetByID retrieves a location by ID for a tenant
func (r *LocationRepository) GetByID(tenantID, locationID uuid.UUID) (*models.Location, error) {
	var location models.Location
	err := r.db.
		Where("tenant_id = ? AND id = ?", tenantID, locationID).
		First(&location).Error
	return &location, err
}

// List retrieves all locations for a tenant with pagination
func (r *LocationRepository) List(tenantID uuid.UUID, page, pageSize int) ([]models.Location, int64, error) {
	var locations []models.Location
	var total int64

	offset := (page - 1) * pageSize

	err := r.db.
		Where("tenant_id = ?", tenantID).
		Order("created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&locations).Error

	if err != nil {
		return nil, 0, err
	}

	r.db.
		Model(&models.Location{}).
		Where("tenant_id = ?", tenantID).
		Count(&total)

	return locations, total, nil
}

// Update updates a location
func (r *LocationRepository) Update(tenantID, locationID uuid.UUID, updates map[string]interface{}) error {
	return r.db.
		Model(&models.Location{}).
		Where("tenant_id = ? AND id = ?", tenantID, locationID).
		Updates(updates).Error
}

// Delete soft deletes a location
func (r *LocationRepository) Delete(tenantID, locationID uuid.UUID) error {
	return r.db.
		Where("tenant_id = ? AND id = ?", tenantID, locationID).
		Delete(&models.Location{}).Error
}

// GetShippingFee retrieves shipping fee for a city
func (r *LocationRepository) GetShippingFee(tenantID uuid.UUID, city string) (decimal.Decimal, error) {
	var location models.Location
	err := r.db.
		Where("tenant_id = ? AND city = ?", tenantID, city).
		First(&location).Error

	if err != nil {
		return decimal.NewFromInt(0), err
	}

	return location.ShippingFee, nil
}
