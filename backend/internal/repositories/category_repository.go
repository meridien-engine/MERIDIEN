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
	return r.db.Create(category).Error
}

// FindByID finds a category by ID within a specific tenant
func (r *CategoryRepository) FindByID(id, tenantID uuid.UUID) (*models.Category, error) {
	var category models.Category
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("Parent").
		Preload("Children").
		First(&category).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("category not found")
		}
		return nil, err
	}

	return &category, nil
}

// FindBySlug finds a category by slug within a specific tenant
func (r *CategoryRepository) FindBySlug(slug string, tenantID uuid.UUID) (*models.Category, error) {
	var category models.Category
	err := r.db.Where("slug = ? AND tenant_id = ?", slug, tenantID).
		Preload("Parent").
		Preload("Children").
		First(&category).Error

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
	return r.db.Save(category).Error
}

// Delete soft deletes a category
func (r *CategoryRepository) Delete(id, tenantID uuid.UUID) error {
	result := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Delete(&models.Category{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("category not found")
	}

	return nil
}

// List returns all categories for a tenant
func (r *CategoryRepository) List(tenantID uuid.UUID) ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Where("tenant_id = ?", tenantID).
		Preload("Parent").
		Preload("Children").
		Order("name ASC").
		Find(&categories).Error

	if err != nil {
		return nil, err
	}

	return categories, nil
}

// ListRootCategories returns all root categories (no parent) for a tenant
func (r *CategoryRepository) ListRootCategories(tenantID uuid.UUID) ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Where("tenant_id = ? AND parent_id IS NULL", tenantID).
		Preload("Children").
		Order("name ASC").
		Find(&categories).Error

	if err != nil {
		return nil, err
	}

	return categories, nil
}

// ExistsBySlug checks if a category with the given slug exists in the tenant
func (r *CategoryRepository) ExistsBySlug(slug string, tenantID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.Category{}).
		Where("slug = ? AND tenant_id = ?", slug, tenantID).
		Count(&count).Error
	return count > 0, err
}
