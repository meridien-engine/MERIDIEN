package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type Courier struct {
	ID        uuid.UUID      `json:"id" gorm:"type:uuid;primaryKey"`
	BusinessID uuid.UUID      `json:"business_id" gorm:"type:uuid;index"`
	Name      string         `json:"name" gorm:"type:varchar(255);not null"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`
}

type CourierReconciliation struct {
	CourierID       uuid.UUID       `json:"courier_id"`
	CourierName     string          `json:"courier_name"`
	DeliveredAmount decimal.Decimal `json:"delivered_amount"`
	CollectedAmount decimal.Decimal `json:"collected_amount"`
	PendingAmount   decimal.Decimal `json:"pending_amount"` // delivered - collected
}

func (Courier) TableName() string {
	return "couriers"
}
