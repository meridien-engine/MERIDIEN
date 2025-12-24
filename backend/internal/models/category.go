package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Category represents a product category
type Category struct {
	BaseModel
	TenantID uuid.UUID `gorm:"type:uuid;not null;index" json:"tenant_id"`

	// Category Information
	Name        string     `gorm:"type:varchar(255);not null" json:"name"`
	Slug        string     `gorm:"type:varchar(255);not null" json:"slug"`
	Description string     `gorm:"type:text" json:"description,omitempty"`
	ParentID    *uuid.UUID `gorm:"type:uuid" json:"parent_id,omitempty"`

	// Relationships
	Tenant   *Tenant     `gorm:"foreignKey:TenantID" json:"tenant,omitempty"`
	Parent   *Category   `gorm:"foreignKey:ParentID" json:"parent,omitempty"`
	Children []Category  `gorm:"foreignKey:ParentID" json:"children,omitempty"`
	Products []Product   `gorm:"foreignKey:CategoryID" json:"products,omitempty"`
}

// TableName specifies the table name for Category
func (Category) TableName() string {
	return "categories"
}

// BeforeCreate hook to set defaults
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return nil
}

// IsRootCategory checks if this is a root category (no parent)
func (c *Category) IsRootCategory() bool {
	return c.ParentID == nil
}
