package services

import (
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/shopspring/decimal"
)

// BranchInventoryService handles business logic for branch inventory
type BranchInventoryService struct {
	invRepo     *repositories.BranchInventoryRepository
	branchRepo  *repositories.BranchRepository
	productRepo *repositories.ProductRepository
}

// NewBranchInventoryService creates a new branch inventory service
func NewBranchInventoryService(
	invRepo *repositories.BranchInventoryRepository,
	branchRepo *repositories.BranchRepository,
	productRepo *repositories.ProductRepository,
) *BranchInventoryService {
	return &BranchInventoryService{
		invRepo:     invRepo,
		branchRepo:  branchRepo,
		productRepo: productRepo,
	}
}

// ── Request types ─────────────────────────────────────────────────────────────

// ActivateProductRequest is the input for adding a product to a branch
type ActivateProductRequest struct {
	StockQuantity     int    `json:"stock_quantity"`
	PriceOverride     string `json:"price_override"`
	LowStockThreshold *int   `json:"low_stock_threshold"`
}

// UpdateInventoryRequest is the input for updating a branch inventory row
type UpdateInventoryRequest struct {
	IsActive          *bool  `json:"is_active"`
	StockQuantity     *int   `json:"stock_quantity"`
	PriceOverride     string `json:"price_override"`
	LowStockThreshold *int   `json:"low_stock_threshold"`
}

// ── Methods ───────────────────────────────────────────────────────────────────

// ActivateProduct adds a product to a branch's inventory
func (s *BranchInventoryService) ActivateProduct(businessID, branchID, productID uuid.UUID, req *ActivateProductRequest) (*models.BranchInventory, error) {
	// Verify branch belongs to this business
	belongs, err := s.branchRepo.BranchBelongsToBusiness(branchID, businessID)
	if err != nil {
		return nil, errors.New("failed to verify branch")
	}
	if !belongs {
		return nil, errors.New("branch not found")
	}

	// Verify product belongs to this business
	_, err = s.productRepo.FindByID(productID, businessID)
	if err != nil {
		return nil, errors.New("product not found")
	}

	inv := &models.BranchInventory{
		BusinessID:        businessID,
		BranchID:          branchID,
		ProductID:         productID,
		IsActive:          true,
		StockQuantity:     req.StockQuantity,
		LowStockThreshold: 5,
	}

	if req.LowStockThreshold != nil {
		inv.LowStockThreshold = *req.LowStockThreshold
	}

	if po := strings.TrimSpace(req.PriceOverride); po != "" {
		d, err := decimal.NewFromString(po)
		if err != nil {
			return nil, errors.New("invalid price_override value")
		}
		inv.PriceOverride = &d
	}

	if err := s.invRepo.Create(inv); err != nil {
		if strings.Contains(err.Error(), "duplicate") || strings.Contains(err.Error(), "unique") {
			return nil, errors.New("product is already activated at this branch")
		}
		return nil, errors.New("failed to activate product")
	}

	// Preload product for response
	result, err := s.invRepo.FindByBranchAndProduct(branchID, productID, businessID)
	if err != nil {
		return inv, nil
	}
	return result, nil
}

// UpdateInventory updates stock, price override, or active state
func (s *BranchInventoryService) UpdateInventory(businessID, branchID, productID uuid.UUID, req *UpdateInventoryRequest) (*models.BranchInventory, error) {
	inv, err := s.invRepo.FindByBranchAndProduct(branchID, productID, businessID)
	if err != nil {
		return nil, errors.New("inventory record not found")
	}

	if req.IsActive != nil {
		inv.IsActive = *req.IsActive
	}
	if req.StockQuantity != nil {
		inv.StockQuantity = *req.StockQuantity
	}
	if req.LowStockThreshold != nil {
		inv.LowStockThreshold = *req.LowStockThreshold
	}
	if po := strings.TrimSpace(req.PriceOverride); po != "" {
		d, err := decimal.NewFromString(po)
		if err != nil {
			return nil, errors.New("invalid price_override value")
		}
		inv.PriceOverride = &d
	} else if req.PriceOverride == "" && req.IsActive != nil {
		// If price_override explicitly sent as empty string, clear it
		inv.PriceOverride = nil
	}

	if err := s.invRepo.Update(inv); err != nil {
		return nil, errors.New("failed to update inventory")
	}

	return inv, nil
}

// DeactivateProduct removes a product from a branch's inventory
func (s *BranchInventoryService) DeactivateProduct(businessID, branchID, productID uuid.UUID) error {
	// Verify branch belongs to business first
	belongs, err := s.branchRepo.BranchBelongsToBusiness(branchID, businessID)
	if err != nil {
		return errors.New("failed to verify branch")
	}
	if !belongs {
		return errors.New("branch not found")
	}

	return s.invRepo.Delete(branchID, productID, businessID)
}

// ListByBranch returns paginated inventory for a branch
func (s *BranchInventoryService) ListByBranch(businessID, branchID uuid.UUID, page, limit int) ([]models.BranchInventory, int64, error) {
	belongs, err := s.branchRepo.BranchBelongsToBusiness(branchID, businessID)
	if err != nil {
		return nil, 0, errors.New("failed to verify branch")
	}
	if !belongs {
		return nil, 0, errors.New("branch not found")
	}

	return s.invRepo.FindByBranch(branchID, businessID, page, limit)
}

// LookupForPOS finds an active inventory item by barcode or SKU within a branch
func (s *BranchInventoryService) LookupForPOS(query string, businessID, branchID uuid.UUID) (*models.BranchInventory, error) {
	if query == "" {
		return nil, errors.New("query cannot be empty")
	}
	return s.invRepo.LookupForPOS(query, businessID, branchID)
}
