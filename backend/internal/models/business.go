package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Business represents a business/organisation using the system (replaces Tenant)
type Business struct {
	BaseModel
	Name         string     `gorm:"type:varchar(255);not null" json:"name"`
	Slug         string     `gorm:"type:varchar(255);not null;uniqueIndex" json:"slug"`
	OwnerID      *uuid.UUID `gorm:"type:uuid" json:"owner_id,omitempty"`
	CategoryID   *uuid.UUID `gorm:"type:uuid" json:"category_id,omitempty"`
	BusinessType string     `gorm:"type:varchar(20)" json:"business_type,omitempty"`
	ContactPhone string     `gorm:"type:varchar(50)" json:"contact_phone,omitempty"`
	ContactEmail string     `gorm:"type:varchar(255)" json:"contact_email,omitempty"`
	LogoURL      string     `gorm:"type:varchar(500)" json:"logo_url,omitempty"`
	Plan         string     `gorm:"type:varchar(50);not null;default:'free'" json:"plan"`
	Status       string     `gorm:"type:varchar(20);not null;default:'active'" json:"status"`

	// Relationships
	Category *BusinessCategory       `gorm:"foreignKey:CategoryID" json:"category,omitempty"`
	Members  []UserBusinessMembership `gorm:"foreignKey:BusinessID" json:"members,omitempty"`
}

// TableName specifies the table name for Business
func (Business) TableName() string {
	return "businesses"
}

// BeforeCreate hook for Business
func (b *Business) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	if b.Plan == "" {
		b.Plan = "free"
	}
	if b.Status == "" {
		b.Status = "active"
	}
	return nil
}

// BusinessCategory represents a category for a business
type BusinessCategory struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	Name   string    `gorm:"type:varchar(255);not null" json:"name"`
	NameAr string    `gorm:"type:varchar(255)" json:"name_ar,omitempty"`
	Slug   string    `gorm:"type:varchar(255);not null;uniqueIndex" json:"slug"`
}

// TableName for BusinessCategory
func (BusinessCategory) TableName() string {
	return "business_categories"
}

// UserBusinessMembership links a user to a business with a role
type UserBusinessMembership struct {
	BaseModel
	UserID     uuid.UUID  `gorm:"type:uuid;not null;index" json:"user_id"`
	BusinessID uuid.UUID  `gorm:"type:uuid;not null;index" json:"business_id"`
	Role       string     `gorm:"type:varchar(20);not null;default:'owner'" json:"role"`
	Status     string     `gorm:"type:varchar(20);not null;default:'active'" json:"status"`
	InvitedBy  *uuid.UUID `gorm:"type:uuid" json:"invited_by,omitempty"`

	// Relationships
	User     *User     `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// TableName for UserBusinessMembership
func (UserBusinessMembership) TableName() string {
	return "user_business_memberships"
}

// BeforeCreate hook for UserBusinessMembership
func (m *UserBusinessMembership) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	if m.Role == "" {
		m.Role = "owner"
	}
	if m.Status == "" {
		m.Status = "active"
	}
	return nil
}

// JoinRequest represents a user's request to join a business (Phase 2)
type JoinRequest struct {
	BaseModel
	UserID     uuid.UUID  `gorm:"type:uuid;not null;index" json:"user_id"`
	BusinessID uuid.UUID  `gorm:"type:uuid;not null;index" json:"business_id"`
	Status     string     `gorm:"type:varchar(20);not null;default:'pending'" json:"status"`
	Message    string     `gorm:"type:text" json:"message,omitempty"`
	Role       string     `gorm:"type:varchar(20)" json:"role,omitempty"`
	ReviewedBy *uuid.UUID `gorm:"type:uuid" json:"reviewed_by,omitempty"`
	ReviewedAt *time.Time `json:"reviewed_at,omitempty"`

	// Relationships
	User     *User     `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// TableName for JoinRequest
func (JoinRequest) TableName() string {
	return "join_requests"
}

// Invitation represents an invitation to join a business (Phase 2)
type Invitation struct {
	BaseModel
	BusinessID uuid.UUID  `gorm:"type:uuid;not null;index" json:"business_id"`
	Email      string     `gorm:"type:varchar(255);not null" json:"email"`
	Role       string     `gorm:"type:varchar(20);not null;default:'viewer'" json:"role"`
	Token      string     `gorm:"type:varchar(255);not null;uniqueIndex" json:"token"`
	InvitedBy  *uuid.UUID `gorm:"type:uuid" json:"invited_by,omitempty"`
	Status     string     `gorm:"type:varchar(20);not null;default:'pending'" json:"status"`
	ExpiresAt  *time.Time `json:"expires_at,omitempty"`
	AcceptedAt *time.Time `json:"accepted_at,omitempty"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// TableName for Invitation
func (Invitation) TableName() string {
	return "invitations"
}
