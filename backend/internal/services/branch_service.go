package services

import (
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
)

// BranchService handles branch business logic
type BranchService struct {
	branchRepo *repositories.BranchRepository
}

// NewBranchService creates a new branch service instance
func NewBranchService(branchRepo *repositories.BranchRepository) *BranchService {
	return &BranchService{branchRepo: branchRepo}
}

// CreateBranchRequest represents a branch creation request
type CreateBranchRequest struct {
	Name    string `json:"name" binding:"required"`
	Address string `json:"address"`
	City    string `json:"city"`
	Phone   string `json:"phone"`
}

// UpdateBranchRequest represents a branch update request
type UpdateBranchRequest struct {
	Name    *string `json:"name"`
	Address *string `json:"address"`
	City    *string `json:"city"`
	Phone   *string `json:"phone"`
	Status  *string `json:"status"`
}

// GrantAccessRequest represents a request to grant branch access to a user
type GrantAccessRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// List returns a paginated list of branches for a business
func (s *BranchService) List(businessID uuid.UUID, page, limit int) ([]models.Branch, int64, error) {
	return s.branchRepo.FindAll(businessID, page, limit)
}

// GetByID retrieves a branch by ID within a business
func (s *BranchService) GetByID(businessID, id uuid.UUID) (*models.Branch, error) {
	return s.branchRepo.FindByID(id, businessID)
}

// Create creates a new branch for a business
func (s *BranchService) Create(businessID uuid.UUID, req *CreateBranchRequest) (*models.Branch, error) {
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return nil, errors.New("branch name is required")
	}

	branch := &models.Branch{
		BusinessID: businessID,
		Name:       name,
		Address:    strings.TrimSpace(req.Address),
		City:       strings.TrimSpace(req.City),
		Phone:      strings.TrimSpace(req.Phone),
		Status:     "active",
	}

	if err := s.branchRepo.Create(branch); err != nil {
		return nil, errors.New("failed to create branch")
	}

	return branch, nil
}

// Update updates a branch's information
func (s *BranchService) Update(businessID, id uuid.UUID, req *UpdateBranchRequest) (*models.Branch, error) {
	branch, err := s.branchRepo.FindByID(id, businessID)
	if err != nil {
		return nil, err
	}

	if req.Name != nil {
		name := strings.TrimSpace(*req.Name)
		if name == "" {
			return nil, errors.New("branch name cannot be empty")
		}
		branch.Name = name
	}
	if req.Address != nil {
		branch.Address = strings.TrimSpace(*req.Address)
	}
	if req.City != nil {
		branch.City = strings.TrimSpace(*req.City)
	}
	if req.Phone != nil {
		branch.Phone = strings.TrimSpace(*req.Phone)
	}
	if req.Status != nil {
		branch.Status = *req.Status
	}

	if err := s.branchRepo.Update(branch); err != nil {
		return nil, errors.New("failed to update branch")
	}

	return branch, nil
}

// Delete soft deletes a branch; rejects deletion of the main branch
func (s *BranchService) Delete(businessID, id uuid.UUID) error {
	branch, err := s.branchRepo.FindByID(id, businessID)
	if err != nil {
		return err
	}
	if branch.IsMain {
		return errors.New("cannot delete the main branch")
	}
	return s.branchRepo.Delete(id, businessID)
}

// GrantAccess grants a user access to a branch
func (s *BranchService) GrantAccess(businessID, branchID uuid.UUID, req *GrantAccessRequest, grantedBy uuid.UUID) error {
	userID, err := uuid.Parse(req.UserID)
	if err != nil {
		return errors.New("invalid user_id")
	}

	// Verify branch belongs to this business
	ok, err := s.branchRepo.BranchBelongsToBusiness(branchID, businessID)
	if err != nil {
		return err
	}
	if !ok {
		return errors.New("branch not found")
	}

	access := &models.UserBranchAccess{
		UserID:    userID,
		BranchID:  branchID,
		GrantedBy: &grantedBy,
	}

	if err := s.branchRepo.GrantAccess(access); err != nil {
		if strings.Contains(err.Error(), "duplicate") || strings.Contains(err.Error(), "unique") {
			return errors.New("user already has access to this branch")
		}
		return errors.New("failed to grant access")
	}

	return nil
}

// RevokeAccess revokes a user's access to a branch
func (s *BranchService) RevokeAccess(businessID, branchID, userID uuid.UUID) error {
	// Verify branch belongs to this business
	ok, err := s.branchRepo.BranchBelongsToBusiness(branchID, businessID)
	if err != nil {
		return err
	}
	if !ok {
		return errors.New("branch not found")
	}

	return s.branchRepo.RevokeAccess(userID, branchID)
}

// ListAccess returns users with access to a branch
func (s *BranchService) ListAccess(businessID, branchID uuid.UUID) ([]models.UserBranchAccess, error) {
	// Verify branch belongs to this business
	ok, err := s.branchRepo.BranchBelongsToBusiness(branchID, businessID)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, errors.New("branch not found")
	}

	return s.branchRepo.ListAccess(branchID)
}
