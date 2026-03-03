package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

// BranchInventory tracks stock and activation state of a product at a specific branch.
// No soft-delete: deactivate via is_active=false; remove by deleting the row.
type BranchInventory struct {
	ID                uuid.UUID        `gorm:"type:uuid;primary_key;default:uuid_generate_v4()" json:"id"`
	BusinessID        uuid.UUID        `gorm:"type:uuid;not null;index"                         json:"business_id"`
	BranchID          uuid.UUID        `gorm:"type:uuid;not null;index"                         json:"branch_id"`
	ProductID         uuid.UUID        `gorm:"type:uuid;not null;index"                         json:"product_id"`
	IsActive          bool             `gorm:"not null;default:true"                            json:"is_active"`
	StockQuantity     int              `gorm:"not null;default:0"                               json:"stock_quantity"`
	PriceOverride     *decimal.Decimal `gorm:"type:decimal(15,2)"                               json:"price_override,omitempty"`
	LowStockThreshold int              `gorm:"not null;default:5"                               json:"low_stock_threshold"`
	CreatedAt         time.Time        `json:"created_at"`
	UpdatedAt         time.Time        `json:"updated_at"`

	// Preloaded relationships
	Product *Product `gorm:"foreignKey:ProductID" json:"product,omitempty"`
	Branch  *Branch  `gorm:"foreignKey:BranchID"  json:"-"`
}

// TableName specifies the table for BranchInventory
func (BranchInventory) TableName() string {
	return "branch_inventory"
}

// BeforeCreate sets a UUID if not already set
func (b *BranchInventory) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	return nil
}

// IsLowStock returns true when stock is at or below the threshold
func (b *BranchInventory) IsLowStock() bool {
	return b.StockQuantity <= b.LowStockThreshold
}
