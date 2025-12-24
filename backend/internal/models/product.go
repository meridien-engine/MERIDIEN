package models

import (
	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

// Product represents a product in the inventory
type Product struct {
	BaseModel
	TenantID   uuid.UUID  `gorm:"type:uuid;not null;index" json:"tenant_id"`
	CategoryID *uuid.UUID `gorm:"type:uuid" json:"category_id,omitempty"`

	// Basic Information
	Name        string `gorm:"type:varchar(255);not null" json:"name"`
	Slug        string `gorm:"type:varchar(255);not null" json:"slug"`
	Description string `gorm:"type:text" json:"description,omitempty"`
	SKU         string `gorm:"type:varchar(100)" json:"sku,omitempty"`
	Barcode     string `gorm:"type:varchar(100)" json:"barcode,omitempty"`

	// Pricing
	CostPrice     decimal.Decimal `gorm:"type:decimal(15,2);default:0.00" json:"cost_price"`
	SellingPrice  decimal.Decimal `gorm:"type:decimal(15,2);not null" json:"selling_price"`
	DiscountPrice *decimal.Decimal `gorm:"type:decimal(15,2)" json:"discount_price,omitempty"`

	// Inventory
	StockQuantity     int  `gorm:"not null;default:0" json:"stock_quantity"`
	LowStockThreshold int  `gorm:"default:10" json:"low_stock_threshold"`
	TrackInventory    bool `gorm:"not null;default:true" json:"track_inventory"`

	// Product Status
	Status     string `gorm:"type:varchar(50);not null;default:'active';index" json:"status"`
	IsFeatured bool   `gorm:"default:false" json:"is_featured"`

	// Physical Properties
	Weight     *decimal.Decimal `gorm:"type:decimal(10,2)" json:"weight,omitempty"`
	WeightUnit string          `gorm:"type:varchar(20);default:'kg'" json:"weight_unit,omitempty"`

	// Additional Information
	Notes        string `gorm:"type:text" json:"notes,omitempty"`
	CustomFields JSONB  `gorm:"type:jsonb;default:'{}'" json:"custom_fields,omitempty"`

	// Relationships
	Tenant   *Tenant   `gorm:"foreignKey:TenantID" json:"tenant,omitempty"`
	Category *Category `gorm:"foreignKey:CategoryID" json:"category,omitempty"`
}

// TableName specifies the table name for Product
func (Product) TableName() string {
	return "products"
}

// BeforeCreate hook to set defaults
func (p *Product) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}

	if p.Status == "" {
		p.Status = "active"
	}

	if p.WeightUnit == "" {
		p.WeightUnit = "kg"
	}

	if p.CustomFields == nil {
		p.CustomFields = make(JSONB)
	}

	return nil
}

// IsActive checks if product is active
func (p *Product) IsActive() bool {
	return p.Status == "active"
}

// IsInStock checks if product is in stock
func (p *Product) IsInStock() bool {
	return p.StockQuantity > 0
}

// IsLowStock checks if product stock is low
func (p *Product) IsLowStock() bool {
	return p.StockQuantity <= p.LowStockThreshold && p.StockQuantity > 0
}

// GetEffectivePrice returns the selling price or discount price if available
func (p *Product) GetEffectivePrice() decimal.Decimal {
	if p.DiscountPrice != nil && p.DiscountPrice.GreaterThan(decimal.Zero) {
		return *p.DiscountPrice
	}
	return p.SellingPrice
}

// GetProfitMargin calculates the profit margin percentage
func (p *Product) GetProfitMargin() decimal.Decimal {
	if p.CostPrice.IsZero() {
		return decimal.Zero
	}

	profit := p.GetEffectivePrice().Sub(p.CostPrice)
	margin := profit.Div(p.CostPrice).Mul(decimal.NewFromInt(100))

	return margin.Round(2)
}
