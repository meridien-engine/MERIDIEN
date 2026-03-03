package services

import (
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
)

// StoreService handles store business logic
type StoreService struct {
	storeRepo *repositories.StoreRepository
}

// NewStoreService creates a new store service instance
func NewStoreService(storeRepo *repositories.StoreRepository) *StoreService {
	return &StoreService{storeRepo: storeRepo}
}

// CreateStoreRequest represents a store creation request
type CreateStoreRequest struct {
	Name     string `json:"name" binding:"required"`
	Address  string `json:"address"`
	City     string `json:"city"`
	Phone    string `json:"phone"`
	IsActive *bool  `json:"is_active"`
}

// UpdateStoreRequest represents a store update request
type UpdateStoreRequest struct {
	Name     *string `json:"name"`
	Address  *string `json:"address"`
	City     *string `json:"city"`
	Phone    *string `json:"phone"`
	IsActive *bool   `json:"is_active"`
}

// List returns a paginated list of stores for a business
func (s *StoreService) List(businessID uuid.UUID, page, limit int, search string) ([]models.Store, int64, error) {
	return s.storeRepo.FindAll(businessID, page, limit, search)
}

// GetByID retrieves a store by ID within a business
func (s *StoreService) GetByID(businessID, id uuid.UUID) (*models.Store, error) {
	return s.storeRepo.FindByID(id, businessID)
}

// Create creates a new store for a business
func (s *StoreService) Create(businessID uuid.UUID, req *CreateStoreRequest) (*models.Store, error) {
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return nil, errors.New("store name is required")
	}

	isActive := true
	if req.IsActive != nil {
		isActive = *req.IsActive
	}

	store := &models.Store{
		BusinessID: businessID,
		Name:       name,
		Address:    strings.TrimSpace(req.Address),
		City:       strings.TrimSpace(req.City),
		Phone:      strings.TrimSpace(req.Phone),
		IsActive:   isActive,
	}

	if err := s.storeRepo.Create(store); err != nil {
		return nil, errors.New("failed to create store")
	}

	return store, nil
}

// Update updates a store's information
func (s *StoreService) Update(businessID, id uuid.UUID, req *UpdateStoreRequest) (*models.Store, error) {
	store, err := s.storeRepo.FindByID(id, businessID)
	if err != nil {
		return nil, err
	}

	if req.Name != nil {
		name := strings.TrimSpace(*req.Name)
		if name == "" {
			return nil, errors.New("store name cannot be empty")
		}
		store.Name = name
	}

	if req.Address != nil {
		store.Address = strings.TrimSpace(*req.Address)
	}

	if req.City != nil {
		store.City = strings.TrimSpace(*req.City)
	}

	if req.Phone != nil {
		store.Phone = strings.TrimSpace(*req.Phone)
	}

	if req.IsActive != nil {
		store.IsActive = *req.IsActive
	}

	if err := s.storeRepo.Update(store); err != nil {
		return nil, errors.New("failed to update store")
	}

	return store, nil
}

// Delete soft deletes a store
func (s *StoreService) Delete(businessID, id uuid.UUID) error {
	return s.storeRepo.Delete(id, businessID)
}
