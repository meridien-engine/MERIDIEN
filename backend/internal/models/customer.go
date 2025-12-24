package models

import (
	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

// Customer represents a customer in the system
type Customer struct {
	BaseModel
	TenantID uuid.UUID `gorm:"type:uuid;not null;index" json:"tenant_id"`

	// Basic Information
	FirstName string `gorm:"type:varchar(100);not null" json:"first_name"`
	LastName  string `gorm:"type:varchar(100);not null" json:"last_name"`
	Email     string `gorm:"type:varchar(255)" json:"email,omitempty"`
	Phone     string `gorm:"type:varchar(50)" json:"phone,omitempty"`

	// Address Information
	AddressLine1 string `gorm:"type:varchar(255)" json:"address_line1,omitempty"`
	AddressLine2 string `gorm:"type:varchar(255)" json:"address_line2,omitempty"`
	City         string `gorm:"type:varchar(100)" json:"city,omitempty"`
	State        string `gorm:"type:varchar(100)" json:"state,omitempty"`
	PostalCode   string `gorm:"type:varchar(20)" json:"postal_code,omitempty"`
	Country      string `gorm:"type:varchar(100)" json:"country,omitempty"`

	// Business Information
	CompanyName string `gorm:"type:varchar(255)" json:"company_name,omitempty"`
	TaxID       string `gorm:"type:varchar(100)" json:"tax_id,omitempty"`

	// Customer Status
	CustomerType string `gorm:"type:varchar(50);not null;default:'individual';index" json:"customer_type"`
	Status       string `gorm:"type:varchar(50);not null;default:'active';index" json:"status"`

	// Financial Information
	CreditLimit    decimal.Decimal `gorm:"type:decimal(15,2);default:0.00" json:"credit_limit"`
	CurrentBalance decimal.Decimal `gorm:"type:decimal(15,2);default:0.00" json:"current_balance"`

	// Additional Information
	Notes        string `gorm:"type:text" json:"notes,omitempty"`
	CustomFields JSONB  `gorm:"type:jsonb;default:'{}'" json:"custom_fields,omitempty"`

	// Relationships
	Tenant *Tenant `gorm:"foreignKey:TenantID" json:"tenant,omitempty"`
}

// TableName specifies the table name for Customer
func (Customer) TableName() string {
	return "customers"
}

// BeforeCreate hook to set defaults
func (c *Customer) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}

	if c.CustomerType == "" {
		c.CustomerType = "individual"
	}

	if c.Status == "" {
		c.Status = "active"
	}

	if c.CustomFields == nil {
		c.CustomFields = make(JSONB)
	}

	return nil
}

// FullName returns the customer's full name
func (c *Customer) FullName() string {
	return c.FirstName + " " + c.LastName
}

// IsActive checks if customer is active
func (c *Customer) IsActive() bool {
	return c.Status == "active"
}

// IsBusiness checks if customer is a business
func (c *Customer) IsBusiness() bool {
	return c.CustomerType == "business"
}

// GetDisplayName returns company name for businesses, full name for individuals
func (c *Customer) GetDisplayName() string {
	if c.IsBusiness() && c.CompanyName != "" {
		return c.CompanyName
	}
	return c.FullName()
}
