package repositories

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// StoreRepository handles database operations for stores
type StoreRepository struct {
	db *gorm.DB
}

// NewStoreRepository creates a new store repository instance
func NewStoreRepository(db *gorm.DB) *StoreRepository {
	return &StoreRepository{db: db}
}

// Create creates a new store
func (r *StoreRepository) Create(store *models.Store) error {
	return businessTx(r.db, store.BusinessID, func(tx *gorm.DB) error {
		return tx.Create(store).Error
	})
}

// FindByID finds a store by ID within a specific business
func (r *StoreRepository) FindByID(id, businessID uuid.UUID) (*models.Store, error) {
	var store models.Store
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("id = ? AND business_id = ?", id, businessID).First(&store).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("store not found")
		}
		return nil, err
	}
	return &store, nil
}

// Update updates a store's information
func (r *StoreRepository) Update(store *models.Store) error {
	return businessTx(r.db, store.BusinessID, func(tx *gorm.DB) error {
		return tx.Save(store).Error
	})
}

// Delete soft deletes a store
func (r *StoreRepository) Delete(id, businessID uuid.UUID) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		result := tx.Where("id = ? AND business_id = ?", id, businessID).Delete(&models.Store{})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return errors.New("store not found")
		}
		return nil
	})
}

// FindAll returns stores for a business with pagination and optional search
func (r *StoreRepository) FindAll(businessID uuid.UUID, page, limit int, search string) ([]models.Store, int64, error) {
	var stores []models.Store
	var total int64

	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	offset := (page - 1) * limit

	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		query := tx.Model(&models.Store{}).Where("business_id = ?", businessID)

		if search != "" {
			searchPattern := "%" + search + "%"
			query = query.Where(
				"name ILIKE ? OR city ILIKE ? OR phone ILIKE ?",
				searchPattern, searchPattern, searchPattern,
			)
		}

		if err := query.Count(&total).Error; err != nil {
			return err
		}

		return query.
			Order(fmt.Sprintf("%s %s", "created_at", "DESC")).
			Limit(limit).
			Offset(offset).
			Find(&stores).Error
	})
	if err != nil {
		return nil, 0, err
	}
	return stores, total, nil
}
