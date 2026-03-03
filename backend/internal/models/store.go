package models

import "github.com/google/uuid"

// Store represents a physical branch location of a business
type Store struct {
	BaseModel
	BusinessID uuid.UUID `gorm:"not null;index" json:"business_id"`
	Name       string    `gorm:"not null" json:"name"`
	Address    string    `json:"address"`
	City       string    `json:"city"`
	Phone      string    `json:"phone"`
	IsActive   bool      `gorm:"default:true" json:"is_active"`
	Business   *Business `gorm:"foreignKey:BusinessID" json:"-"`
}
