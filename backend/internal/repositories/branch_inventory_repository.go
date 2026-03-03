package repositories

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// BranchInventoryRepository handles database operations for branch_inventory
type BranchInventoryRepository struct {
	db *gorm.DB
}

// NewBranchInventoryRepository creates a new branch inventory repository
func NewBranchInventoryRepository(db *gorm.DB) *BranchInventoryRepository {
	return &BranchInventoryRepository{db: db}
}

// Create inserts a new branch inventory row
func (r *BranchInventoryRepository) Create(inv *models.BranchInventory) error {
	return businessTx(r.db, inv.BusinessID, func(tx *gorm.DB) error {
		return tx.Create(inv).Error
	})
}

// FindByBranchAndProduct retrieves a specific inventory row
func (r *BranchInventoryRepository) FindByBranchAndProduct(branchID, productID, businessID uuid.UUID) (*models.BranchInventory, error) {
	var inv models.BranchInventory
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.
			Preload("Product").
			Where("branch_id = ? AND product_id = ?", branchID, productID).
			First(&inv).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("inventory record not found")
		}
		return nil, err
	}
	return &inv, nil
}

// FindByID retrieves a branch inventory row by its primary key
func (r *BranchInventoryRepository) FindByID(id, businessID uuid.UUID) (*models.BranchInventory, error) {
	var inv models.BranchInventory
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.
			Preload("Product").
			Where("id = ? AND business_id = ?", id, businessID).
			First(&inv).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("inventory record not found")
		}
		return nil, err
	}
	return &inv, nil
}

// Update saves changes to an existing inventory row
func (r *BranchInventoryRepository) Update(inv *models.BranchInventory) error {
	return businessTx(r.db, inv.BusinessID, func(tx *gorm.DB) error {
		return tx.Save(inv).Error
	})
}

// Delete hard-deletes the inventory row (deactivation uses Update with is_active=false)
func (r *BranchInventoryRepository) Delete(branchID, productID, businessID uuid.UUID) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		result := tx.
			Where("branch_id = ? AND product_id = ? AND business_id = ?", branchID, productID, businessID).
			Delete(&models.BranchInventory{})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return errors.New("inventory record not found")
		}
		return nil
	})
}

// FindByBranch returns all inventory rows for a branch with product preloaded
func (r *BranchInventoryRepository) FindByBranch(branchID, businessID uuid.UUID, page, limit int) ([]models.BranchInventory, int64, error) {
	var items []models.BranchInventory
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
		query := tx.Model(&models.BranchInventory{}).
			Where("branch_id = ? AND business_id = ?", branchID, businessID)

		if err := query.Count(&total).Error; err != nil {
			return err
		}

		return query.
			Preload("Product").
			Order(fmt.Sprintf("is_active DESC, created_at %s", "ASC")).
			Limit(limit).
			Offset(offset).
			Find(&items).Error
	})
	if err != nil {
		return nil, 0, err
	}
	return items, total, nil
}

// LookupForPOS finds an active inventory row by product barcode or SKU within a branch
func (r *BranchInventoryRepository) LookupForPOS(query string, businessID, branchID uuid.UUID) (*models.BranchInventory, error) {
	var inv models.BranchInventory
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.
			Preload("Product").
			Joins("JOIN products ON products.id = branch_inventory.product_id AND products.deleted_at IS NULL").
			Where("branch_inventory.branch_id = ? AND branch_inventory.is_active = true", branchID).
			Where("products.barcode = ? OR products.sku = ?", query, query).
			First(&inv).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product not found in branch inventory")
		}
		return nil, err
	}
	return &inv, nil
}
