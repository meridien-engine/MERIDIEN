package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Branch represents a physical branch of a business
type Branch struct {
	BaseModel
	BusinessID uuid.UUID `gorm:"type:uuid;not null;index" json:"business_id"`
	Name       string    `gorm:"type:varchar(255);not null" json:"name"`
	Address    string    `gorm:"type:text" json:"address,omitempty"`
	City       string    `gorm:"type:varchar(255)" json:"city,omitempty"`
	Phone      string    `gorm:"type:varchar(50)" json:"phone,omitempty"`
	IsMain     bool      `gorm:"not null;default:false" json:"is_main"`
	Status     string    `gorm:"type:varchar(20);not null;default:'active'" json:"status"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"-"`
}

// TableName specifies the table for Branch
func (Branch) TableName() string {
	return "branches"
}

// BeforeCreate sets defaults for Branch
func (b *Branch) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	if b.Status == "" {
		b.Status = "active"
	}
	return nil
}

// UserBranchAccess links a user to a branch they can access
type UserBranchAccess struct {
	ID        uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	UserID    uuid.UUID  `gorm:"type:uuid;not null;index" json:"user_id"`
	BranchID  uuid.UUID  `gorm:"type:uuid;not null;index" json:"branch_id"`
	GrantedBy *uuid.UUID `gorm:"type:uuid" json:"granted_by,omitempty"`
	CreatedAt time.Time  `json:"created_at"`

	// Relationships
	User   *User   `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Branch *Branch `gorm:"foreignKey:BranchID" json:"-"`
}

// TableName for UserBranchAccess
func (UserBranchAccess) TableName() string {
	return "user_branch_access"
}
