package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// POS session status constants
const (
	POSSessionStatusOpen   = "open"
	POSSessionStatusClosed = "closed"
)

// POSSession represents a cashier's cash drawer session
type POSSession struct {
	BaseModel
	BusinessID   uuid.UUID        `gorm:"type:uuid;not null;index" json:"business_id"`
	CashierID    uuid.UUID        `gorm:"type:uuid;not null;index" json:"cashier_id"`
	Status       string           `gorm:"type:varchar(20);not null;default:'open'" json:"status"`
	OpeningFloat decimal.Decimal  `gorm:"type:decimal(15,2);not null;default:0.00" json:"opening_float"`
	ClosingCash  *decimal.Decimal `gorm:"type:decimal(15,2)" json:"closing_cash,omitempty"`
	ExpectedCash *decimal.Decimal `gorm:"type:decimal(15,2)" json:"expected_cash,omitempty"`
	CashDiff     *decimal.Decimal `gorm:"column:cash_difference;type:decimal(15,2)" json:"cash_difference,omitempty"`
	OpenedAt     time.Time        `gorm:"not null;default:now()" json:"opened_at"`
	ClosedAt     *time.Time       `json:"closed_at,omitempty"`

	// Relationships
	Cashier *User `gorm:"foreignKey:CashierID" json:"cashier,omitempty"`
}

// TableName specifies the table name for POSSession
func (POSSession) TableName() string {
	return "pos_sessions"
}

// IsOpen returns true when the session is currently open
func (s *POSSession) IsOpen() bool {
	return s.Status == POSSessionStatusOpen
}
