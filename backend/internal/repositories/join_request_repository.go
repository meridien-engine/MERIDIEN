package repositories

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// JoinRequestRepository handles database operations for join requests
type JoinRequestRepository struct {
	db *gorm.DB
}

// NewJoinRequestRepository creates a new join request repository instance
func NewJoinRequestRepository(db *gorm.DB) *JoinRequestRepository {
	return &JoinRequestRepository{db: db}
}

// Create saves a new join request
func (r *JoinRequestRepository) Create(jr *models.JoinRequest) error {
	return r.db.Create(jr).Error
}

// FindByID finds a join request by ID
func (r *JoinRequestRepository) FindByID(id uuid.UUID) (*models.JoinRequest, error) {
	var jr models.JoinRequest
	err := r.db.Preload("User").Where("id = ?", id).First(&jr).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("join request not found")
		}
		return nil, err
	}
	return &jr, nil
}

// FindPendingByUserAndBusiness returns an active pending request for the given user+business pair
func (r *JoinRequestRepository) FindPendingByUserAndBusiness(userID, businessID uuid.UUID) (*models.JoinRequest, error) {
	var jr models.JoinRequest
	err := r.db.Where("user_id = ? AND business_id = ? AND status = ?", userID, businessID, "pending").
		First(&jr).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &jr, nil
}

// ListByBusiness returns all join requests for a business, newest first
func (r *JoinRequestRepository) ListByBusiness(businessID uuid.UUID) ([]models.JoinRequest, error) {
	var requests []models.JoinRequest
	err := r.db.Preload("User").
		Where("business_id = ?", businessID).
		Order("created_at DESC").
		Find(&requests).Error
	return requests, err
}

// ListByUser returns all join requests submitted by a user
func (r *JoinRequestRepository) ListByUser(userID uuid.UUID) ([]models.JoinRequest, error) {
	var requests []models.JoinRequest
	err := r.db.Preload("Business").
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&requests).Error
	return requests, err
}

// UpdateStatus sets the status, role, reviewer, and reviewed_at on a request
func (r *JoinRequestRepository) UpdateStatus(id uuid.UUID, status, role string, reviewedBy uuid.UUID, reviewedAt time.Time) error {
	updates := map[string]any{
		"status":      status,
		"reviewed_by": reviewedBy,
		"reviewed_at": reviewedAt,
	}
	if role != "" {
		updates["role"] = role
	}
	return r.db.Model(&models.JoinRequest{}).Where("id = ?", id).Updates(updates).Error
}
