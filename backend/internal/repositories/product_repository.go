package repositories

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// ProductRepository handles database operations for products
type ProductRepository struct {
	db *gorm.DB
}

// NewProductRepository creates a new product repository instance
func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{db: db}
}

// Create creates a new product
func (r *ProductRepository) Create(product *models.Product) error {
	return r.db.Create(product).Error
}

// FindByID finds a product by ID within a specific tenant
func (r *ProductRepository) FindByID(id, tenantID uuid.UUID) (*models.Product, error) {
	var product models.Product
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("Category").
		First(&product).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product not found")
		}
		return nil, err
	}

	return &product, nil
}

// FindBySKU finds a product by SKU within a specific tenant
func (r *ProductRepository) FindBySKU(sku string, tenantID uuid.UUID) (*models.Product, error) {
	var product models.Product
	err := r.db.Where("sku = ? AND tenant_id = ?", sku, tenantID).
		Preload("Category").
		First(&product).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product not found")
		}
		return nil, err
	}

	return &product, nil
}

// Update updates a product's information
func (r *ProductRepository) Update(product *models.Product) error {
	return r.db.Save(product).Error
}

// Delete soft deletes a product
func (r *ProductRepository) Delete(id, tenantID uuid.UUID) error {
	result := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Delete(&models.Product{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("product not found")
	}

	return nil
}

// List returns products for a tenant with pagination and filters
func (r *ProductRepository) List(tenantID uuid.UUID, filters ProductListFilters) ([]models.Product, int64, error) {
	var products []models.Product
	var total int64

	query := r.db.Model(&models.Product{}).Where("tenant_id = ?", tenantID)

	// Apply filters
	if filters.Search != "" {
		searchPattern := "%" + filters.Search + "%"
		query = query.Where(
			"name ILIKE ? OR description ILIKE ? OR sku ILIKE ? OR barcode ILIKE ?",
			searchPattern, searchPattern, searchPattern, searchPattern,
		)
	}

	if filters.Status != "" {
		query = query.Where("status = ?", filters.Status)
	}

	if filters.CategoryID != uuid.Nil {
		query = query.Where("category_id = ?", filters.CategoryID)
	}

	if filters.LowStock {
		query = query.Where("stock_quantity <= low_stock_threshold AND stock_quantity > 0")
	}

	if filters.OutOfStock {
		query = query.Where("stock_quantity = 0")
	}

	if filters.IsFeatured {
		query = query.Where("is_featured = ?", true)
	}

	// Count total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Apply sorting
	sortField := "created_at"
	sortOrder := "DESC"
	if filters.SortBy != "" {
		sortField = filters.SortBy
	}
	if filters.SortOrder != "" {
		sortOrder = filters.SortOrder
	}
	query = query.Order(fmt.Sprintf("%s %s", sortField, sortOrder))

	// Apply pagination
	limit := 20
	offset := 0
	if filters.Limit > 0 {
		limit = filters.Limit
	}
	if filters.Offset >= 0 {
		offset = filters.Offset
	}

	// Preload category
	err := query.Preload("Category").Limit(limit).Offset(offset).Find(&products).Error
	if err != nil {
		return nil, 0, err
	}

	return products, total, nil
}

// UpdateStock updates product stock quantity
func (r *ProductRepository) UpdateStock(id, tenantID uuid.UUID, quantity int) error {
	return r.db.Model(&models.Product{}).
		Where("id = ? AND tenant_id = ?", id, tenantID).
		Update("stock_quantity", quantity).Error
}

// ExistsBySKU checks if a product with the given SKU exists in the tenant
func (r *ProductRepository) ExistsBySKU(sku string, tenantID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.Product{}).
		Where("sku = ? AND tenant_id = ?", sku, tenantID).
		Count(&count).Error
	return count > 0, err
}

// ExistsByBarcode checks if a product with the given barcode exists in the tenant
func (r *ProductRepository) ExistsByBarcode(barcode string, tenantID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.Product{}).
		Where("barcode = ? AND tenant_id = ?", barcode, tenantID).
		Count(&count).Error
	return count > 0, err
}

// ProductListFilters represents filters for listing products
type ProductListFilters struct {
	Search      string
	Status      string
	CategoryID  uuid.UUID
	LowStock    bool
	OutOfStock  bool
	IsFeatured  bool
	SortBy      string
	SortOrder   string
	Limit       int
	Offset      int
}
