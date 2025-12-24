package services

import (
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/gosimple/slug"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/shopspring/decimal"
)

// ProductService handles product business logic
type ProductService struct {
	productRepo  *repositories.ProductRepository
	categoryRepo *repositories.CategoryRepository
}

// NewProductService creates a new product service instance
func NewProductService(productRepo *repositories.ProductRepository, categoryRepo *repositories.CategoryRepository) *ProductService {
	return &ProductService{
		productRepo:  productRepo,
		categoryRepo: categoryRepo,
	}
}

// CreateProductRequest represents a product creation request
type CreateProductRequest struct {
	TenantID          uuid.UUID
	CategoryID        *uuid.UUID
	Name              string
	Description       string
	SKU               string
	Barcode           string
	CostPrice         decimal.Decimal
	SellingPrice      decimal.Decimal
	DiscountPrice     *decimal.Decimal
	StockQuantity     int
	LowStockThreshold int
	TrackInventory    bool
	Weight            *decimal.Decimal
	WeightUnit        string
	Notes             string
}

// UpdateProductRequest represents a product update request
type UpdateProductRequest struct {
	CategoryID        *uuid.UUID
	Name              *string
	Description       *string
	SKU               *string
	Barcode           *string
	CostPrice         *decimal.Decimal
	SellingPrice      *decimal.Decimal
	DiscountPrice     *decimal.Decimal
	StockQuantity     *int
	LowStockThreshold *int
	TrackInventory    *bool
	Status            *string
	IsFeatured        *bool
	Weight            *decimal.Decimal
	WeightUnit        *string
	Notes             *string
}

// ListProductsRequest represents a request to list products
type ListProductsRequest struct {
	TenantID    uuid.UUID
	Search      string
	Status      string
	CategoryID  uuid.UUID
	LowStock    bool
	OutOfStock  bool
	IsFeatured  bool
	SortBy      string
	SortOrder   string
	Page        int
	PerPage     int
}

// Create creates a new product
func (s *ProductService) Create(req *CreateProductRequest) (*models.Product, error) {
	// Validate input
	if err := s.validateCreateRequest(req); err != nil {
		return nil, err
	}

	// Validate category if provided
	if req.CategoryID != nil {
		_, err := s.categoryRepo.FindByID(*req.CategoryID, req.TenantID)
		if err != nil {
			return nil, errors.New("invalid category")
		}
	}

	// Check if SKU already exists
	if req.SKU != "" {
		exists, err := s.productRepo.ExistsBySKU(req.SKU, req.TenantID)
		if err != nil {
			return nil, err
		}
		if exists {
			return nil, errors.New("product with this SKU already exists")
		}
	}

	// Check if barcode already exists
	if req.Barcode != "" {
		exists, err := s.productRepo.ExistsByBarcode(req.Barcode, req.TenantID)
		if err != nil {
			return nil, err
		}
		if exists {
			return nil, errors.New("product with this barcode already exists")
		}
	}

	// Generate slug from name
	productSlug := slug.Make(req.Name)

	// Create product
	product := &models.Product{
		TenantID:          req.TenantID,
		CategoryID:        req.CategoryID,
		Name:              strings.TrimSpace(req.Name),
		Slug:              productSlug,
		Description:       strings.TrimSpace(req.Description),
		SKU:               strings.TrimSpace(req.SKU),
		Barcode:           strings.TrimSpace(req.Barcode),
		CostPrice:         req.CostPrice,
		SellingPrice:      req.SellingPrice,
		DiscountPrice:     req.DiscountPrice,
		StockQuantity:     req.StockQuantity,
		LowStockThreshold: req.LowStockThreshold,
		TrackInventory:    req.TrackInventory,
		Status:            "active",
		Weight:            req.Weight,
		WeightUnit:        req.WeightUnit,
		Notes:             strings.TrimSpace(req.Notes),
	}

	// Save to database
	if err := s.productRepo.Create(product); err != nil {
		return nil, errors.New("failed to create product")
	}

	return product, nil
}

// GetByID retrieves a product by ID
func (s *ProductService) GetByID(id, tenantID uuid.UUID) (*models.Product, error) {
	return s.productRepo.FindByID(id, tenantID)
}

// Update updates a product's information
func (s *ProductService) Update(id, tenantID uuid.UUID, req *UpdateProductRequest) (*models.Product, error) {
	// Get existing product
	product, err := s.productRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, err
	}

	// Update fields if provided
	if req.CategoryID != nil {
		if *req.CategoryID != uuid.Nil {
			_, err := s.categoryRepo.FindByID(*req.CategoryID, tenantID)
			if err != nil {
				return nil, errors.New("invalid category")
			}
		}
		product.CategoryID = req.CategoryID
	}

	if req.Name != nil {
		name := strings.TrimSpace(*req.Name)
		if name == "" {
			return nil, errors.New("product name cannot be empty")
		}
		product.Name = name
		product.Slug = slug.Make(name)
	}

	if req.Description != nil {
		product.Description = strings.TrimSpace(*req.Description)
	}

	if req.SKU != nil {
		sku := strings.TrimSpace(*req.SKU)
		if sku != product.SKU && sku != "" {
			exists, err := s.productRepo.ExistsBySKU(sku, tenantID)
			if err != nil {
				return nil, err
			}
			if exists {
				return nil, errors.New("product with this SKU already exists")
			}
		}
		product.SKU = sku
	}

	if req.Barcode != nil {
		barcode := strings.TrimSpace(*req.Barcode)
		if barcode != product.Barcode && barcode != "" {
			exists, err := s.productRepo.ExistsByBarcode(barcode, tenantID)
			if err != nil {
				return nil, err
			}
			if exists {
				return nil, errors.New("product with this barcode already exists")
			}
		}
		product.Barcode = barcode
	}

	if req.CostPrice != nil {
		product.CostPrice = *req.CostPrice
	}

	if req.SellingPrice != nil {
		if req.SellingPrice.LessThanOrEqual(decimal.Zero) {
			return nil, errors.New("selling price must be greater than zero")
		}
		product.SellingPrice = *req.SellingPrice
	}

	if req.DiscountPrice != nil {
		product.DiscountPrice = req.DiscountPrice
	}

	if req.StockQuantity != nil {
		if *req.StockQuantity < 0 {
			return nil, errors.New("stock quantity cannot be negative")
		}
		product.StockQuantity = *req.StockQuantity
	}

	if req.LowStockThreshold != nil {
		product.LowStockThreshold = *req.LowStockThreshold
	}

	if req.TrackInventory != nil {
		product.TrackInventory = *req.TrackInventory
	}

	if req.Status != nil {
		if err := s.validateStatus(*req.Status); err != nil {
			return nil, err
		}
		product.Status = *req.Status
	}

	if req.IsFeatured != nil {
		product.IsFeatured = *req.IsFeatured
	}

	if req.Weight != nil {
		product.Weight = req.Weight
	}

	if req.WeightUnit != nil {
		product.WeightUnit = *req.WeightUnit
	}

	if req.Notes != nil {
		product.Notes = strings.TrimSpace(*req.Notes)
	}

	// Save updates
	if err := s.productRepo.Update(product); err != nil {
		return nil, errors.New("failed to update product")
	}

	return product, nil
}

// Delete soft deletes a product
func (s *ProductService) Delete(id, tenantID uuid.UUID) error {
	return s.productRepo.Delete(id, tenantID)
}

// List returns a paginated list of products
func (s *ProductService) List(req *ListProductsRequest) ([]models.Product, int64, error) {
	// Calculate offset
	page := req.Page
	if page < 1 {
		page = 1
	}
	perPage := req.PerPage
	if perPage < 1 {
		perPage = 20
	}
	if perPage > 100 {
		perPage = 100
	}
	offset := (page - 1) * perPage

	// Build filters
	filters := repositories.ProductListFilters{
		Search:     req.Search,
		Status:     req.Status,
		CategoryID: req.CategoryID,
		LowStock:   req.LowStock,
		OutOfStock: req.OutOfStock,
		IsFeatured: req.IsFeatured,
		SortBy:     req.SortBy,
		SortOrder:  req.SortOrder,
		Limit:      perPage,
		Offset:     offset,
	}

	return s.productRepo.List(req.TenantID, filters)
}

// UpdateStock updates product stock quantity
func (s *ProductService) UpdateStock(id, tenantID uuid.UUID, quantity int) error {
	if quantity < 0 {
		return errors.New("stock quantity cannot be negative")
	}
	return s.productRepo.UpdateStock(id, tenantID, quantity)
}

// validateCreateRequest validates the creation request
func (s *ProductService) validateCreateRequest(req *CreateProductRequest) error {
	if req.TenantID == uuid.Nil {
		return errors.New("tenant ID is required")
	}

	name := strings.TrimSpace(req.Name)
	if name == "" {
		return errors.New("product name is required")
	}

	if req.SellingPrice.LessThanOrEqual(decimal.Zero) {
		return errors.New("selling price must be greater than zero")
	}

	if req.StockQuantity < 0 {
		return errors.New("stock quantity cannot be negative")
	}

	return nil
}

// validateStatus validates product status
func (s *ProductService) validateStatus(status string) error {
	validStatuses := map[string]bool{
		"active":       true,
		"inactive":     true,
		"discontinued": true,
	}

	if !validStatuses[status] {
		return errors.New("invalid status. Must be 'active', 'inactive', or 'discontinued'")
	}

	return nil
}
