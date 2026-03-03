package repositories

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// InvitationRepository handles database operations for invitations
type InvitationRepository struct {
	db *gorm.DB
}

// NewInvitationRepository creates a new invitation repository instance
func NewInvitationRepository(db *gorm.DB) *InvitationRepository {
	return &InvitationRepository{db: db}
}

// Create saves a new invitation
func (r *InvitationRepository) Create(inv *models.Invitation) error {
	return r.db.Create(inv).Error
}

// FindByToken looks up an invitation by its unique token (no auth filter — public lookup)
func (r *InvitationRepository) FindByToken(token string) (*models.Invitation, error) {
	var inv models.Invitation
	err := r.db.Preload("Business").Where("token = ?", token).First(&inv).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("invitation not found")
		}
		return nil, err
	}
	return &inv, nil
}

// FindByBusiness returns all invitations for a business, newest first
func (r *InvitationRepository) FindByBusiness(businessID uuid.UUID) ([]models.Invitation, error) {
	var invitations []models.Invitation
	err := r.db.Where("business_id = ?", businessID).
		Order("created_at DESC").
		Find(&invitations).Error
	return invitations, err
}

// FindPendingByEmailAndBusiness returns an active pending invitation for the given email+business pair
func (r *InvitationRepository) FindPendingByEmailAndBusiness(email string, businessID uuid.UUID) (*models.Invitation, error) {
	var inv models.Invitation
	err := r.db.Where("email = ? AND business_id = ? AND status = ?", email, businessID, "pending").
		First(&inv).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &inv, nil
}

// UpdateStatus sets the status and, optionally, accepted_at on an invitation
func (r *InvitationRepository) UpdateStatus(id uuid.UUID, status string, acceptedAt *time.Time) error {
	updates := map[string]any{
		"status": status,
	}
	if acceptedAt != nil {
		updates["accepted_at"] = acceptedAt
	}
	return r.db.Model(&models.Invitation{}).Where("id = ?", id).Updates(updates).Error
}
