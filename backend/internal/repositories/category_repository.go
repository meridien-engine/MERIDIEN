package repositories

import (
	"errors"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// CategoryRepository handles database operations for categories
type CategoryRepository struct {
	db *gorm.DB
}

// NewCategoryRepository creates a new category repository instance
func NewCategoryRepository(db *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: db}
}

// Create creates a new category
func (r *CategoryRepository) Create(category *models.Category) error {
	return businessTx(r.db, category.BusinessID, func(tx *gorm.DB) error {
		return tx.Create(category).Error
	})
}

// FindByID finds a category by ID within a specific tenant
func (r *CategoryRepository) FindByID(id, businessID uuid.UUID) (*models.Category, error) {
	var category models.Category
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("id = ? AND business_id = ?", id, businessID).
			Preload("Parent").Preload("Children").First(&category).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("category not found")
		}
		return nil, err
	}
	return &category, nil
}

// FindBySlug finds a category by slug within a specific tenant
func (r *CategoryRepository) FindBySlug(slug string, businessID uuid.UUID) (*models.Category, error) {
	var category models.Category
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("slug = ? AND business_id = ?", slug, businessID).
			Preload("Parent").Preload("Children").First(&category).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("category not found")
		}
		return nil, err
	}
	return &category, nil
}

// Update updates a category's information
func (r *CategoryRepository) Update(category *models.Category) error {
	return businessTx(r.db, category.BusinessID, func(tx *gorm.DB) error {
		return tx.Save(category).Error
	})
}

// Delete soft deletes a category
func (r *CategoryRepository) Delete(id, businessID uuid.UUID) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		result := tx.Where("id = ? AND business_id = ?", id, businessID).Delete(&models.Category{})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return errors.New("category not found")
		}
		return nil
	})
}

// List returns all categories for a tenant
func (r *CategoryRepository) List(businessID uuid.UUID) ([]models.Category, error) {
	var categories []models.Category
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("business_id = ?", businessID).
			Preload("Parent").Preload("Children").
			Order("name ASC").
			Find(&categories).Error
	})
	return categories, err
}

// ListRootCategories returns all root categories (no parent) for a tenant
func (r *CategoryRepository) ListRootCategories(businessID uuid.UUID) ([]models.Category, error) {
	var categories []models.Category
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("business_id = ? AND parent_id IS NULL", businessID).
			Preload("Children").
			Order("name ASC").
			Find(&categories).Error
	})
	return categories, err
}

// ExistsBySlug checks if a category with the given slug exists in the tenant
func (r *CategoryRepository) ExistsBySlug(slug string, businessID uuid.UUID) (bool, error) {
	var count int64
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Model(&models.Category{}).
			Where("slug = ? AND business_id = ?", slug, businessID).
			Count(&count).Error
	})
	return count > 0, err
}
