package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type Location struct {
	ID          uuid.UUID       `json:"id" gorm:"type:uuid;primaryKey"`
	BusinessID  uuid.UUID       `json:"business_id" gorm:"type:uuid;index"`
	City        string          `json:"city" gorm:"type:varchar(255);not null"`
	Zone        string          `json:"zone" gorm:"type:varchar(255)"`
	ShippingFee decimal.Decimal `json:"shipping_fee" gorm:"type:decimal(15,2);not null;default:0.00"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
	DeletedAt   gorm.DeletedAt  `json:"deleted_at" gorm:"index"`
}

func (Location) TableName() string {
	return "locations"
}
