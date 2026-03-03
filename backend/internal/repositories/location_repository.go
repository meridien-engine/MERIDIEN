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
	return businessTx(r.db, location.BusinessID, func(tx *gorm.DB) error {
		return tx.Create(location).Error
	})
}

// GetByID retrieves a location by ID for a tenant
func (r *LocationRepository) GetByID(businessID, locationID uuid.UUID) (*models.Location, error) {
	var location models.Location
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("business_id = ? AND id = ?", businessID, locationID).First(&location).Error
	})
	return &location, err
}

// List retrieves all locations for a tenant with pagination
func (r *LocationRepository) List(businessID uuid.UUID, page, pageSize int) ([]models.Location, int64, error) {
	var locations []models.Location
	var total int64
	offset := (page - 1) * pageSize

	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		if err := tx.Model(&models.Location{}).Where("business_id = ?", businessID).Count(&total).Error; err != nil {
			return err
		}
		return tx.Where("business_id = ?", businessID).
			Order("created_at DESC").
			Offset(offset).Limit(pageSize).
			Find(&locations).Error
	})
	if err != nil {
		return nil, 0, err
	}
	return locations, total, nil
}

// Update updates a location
func (r *LocationRepository) Update(businessID, locationID uuid.UUID, updates map[string]interface{}) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Model(&models.Location{}).
			Where("business_id = ? AND id = ?", businessID, locationID).
			Updates(updates).Error
	})
}

// Delete soft deletes a location
func (r *LocationRepository) Delete(businessID, locationID uuid.UUID) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("business_id = ? AND id = ?", businessID, locationID).Delete(&models.Location{}).Error
	})
}

// GetShippingFee retrieves shipping fee for a city
func (r *LocationRepository) GetShippingFee(businessID uuid.UUID, city string) (decimal.Decimal, error) {
	var location models.Location
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("business_id = ? AND city = ?", businessID, city).First(&location).Error
	})
	if err != nil {
		return decimal.NewFromInt(0), err
	}
	return location.ShippingFee, nil
}
