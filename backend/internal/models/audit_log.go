package models

import (
	"time"

	"github.com/google/uuid"
)

// AuditLog records immutable actions for orders and finance
type AuditLog struct {
	ID        uuid.UUID  `gorm:"type:uuid;primary_key;default:uuid_generate_v4()" json:"id"`
	BusinessID uuid.UUID `gorm:"type:uuid;not null;index" json:"business_id"`
	UserID    *uuid.UUID `gorm:"type:uuid" json:"user_id,omitempty"`
	OrderID   *uuid.UUID `gorm:"type:uuid;index" json:"order_id,omitempty"`
	Action    string     `gorm:"type:varchar(50);not null" json:"action"`
	OldValue  JSONB      `gorm:"type:jsonb" json:"old_value,omitempty"`
	NewValue  JSONB      `gorm:"type:jsonb" json:"new_value,omitempty"`
	CreatedAt time.Time  `gorm:"not null;default:now()" json:"created_at"`
}

func (AuditLog) TableName() string { return "audit_logs" }
