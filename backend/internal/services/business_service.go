package services

import (
	"errors"
	"log"
	"regexp"
	"strings"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
)

// BusinessService handles business management logic
type BusinessService struct {
	businessRepo *repositories.BusinessRepository
	branchRepo   *repositories.BranchRepository
}

// NewBusinessService creates a new business service instance
func NewBusinessService(businessRepo *repositories.BusinessRepository, branchRepo *repositories.BranchRepository) *BusinessService {
	return &BusinessService{businessRepo: businessRepo, branchRepo: branchRepo}
}

// CreateBusinessRequest represents a business creation request
type CreateBusinessRequest struct {
	Name         string `json:"name"`
	Slug         string `json:"slug"`
	BusinessType string `json:"business_type"`
	CategoryID   string `json:"category_id"`
	ContactPhone string `json:"contact_phone"`
	ContactEmail string `json:"contact_email"`
}

// slugRegex validates URL-safe slugs
var slugRegex = regexp.MustCompile(`^[a-z0-9][a-z0-9-]*[a-z0-9]$`)

// CreateBusiness creates a new business and adds the creator as owner
func (s *BusinessService) CreateBusiness(userID uuid.UUID, req *CreateBusinessRequest) (*models.Business, error) {
	// Validate name
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return nil, errors.New("business name is required")
	}

	// Auto-generate slug if not provided
	slug := strings.ToLower(strings.TrimSpace(req.Slug))
	if slug == "" {
		slug = generateSlug(name)
	}

	// Validate slug format
	if len(slug) < 2 || !slugRegex.MatchString(slug) {
		return nil, errors.New("slug must be at least 2 characters, lowercase alphanumeric and hyphens only")
	}

	// Check slug uniqueness
	exists, err := s.businessRepo.ExistsBySlug(slug)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("a business with this slug already exists")
	}

	// Validate business type
	if req.BusinessType != "" && req.BusinessType != "single_branch" && req.BusinessType != "multi_branch" {
		return nil, errors.New("business_type must be 'single_branch' or 'multi_branch'")
	}

	// Parse category ID
	var catID *uuid.UUID
	if req.CategoryID != "" {
		parsed, err := uuid.Parse(req.CategoryID)
		if err != nil {
			return nil, errors.New("invalid category_id")
		}
		catID = &parsed
	}

	business := &models.Business{
		Name:         name,
		Slug:         slug,
		OwnerID:      &userID,
		CategoryID:   catID,
		BusinessType: req.BusinessType,
		ContactPhone: strings.TrimSpace(req.ContactPhone),
		ContactEmail: strings.ToLower(strings.TrimSpace(req.ContactEmail)),
		Plan:         "free",
		Status:       "active",
	}

	if err := s.businessRepo.Create(business); err != nil {
		return nil, errors.New("failed to create business")
	}

	// Auto-create the main branch for every new business
	mainBranch := &models.Branch{
		BusinessID: business.ID,
		Name:       "Main Branch",
		IsMain:     true,
		Status:     "active",
	}
	if err := s.branchRepo.Create(mainBranch); err != nil {
		log.Printf("warning: auto-create main branch failed for business %s: %v", business.ID, err)
	}

	// Add creator as owner member
	membership := &models.UserBusinessMembership{
		UserID:     userID,
		BusinessID: business.ID,
		Role:       "owner",
		Status:     "active",
	}
	if err := s.businessRepo.CreateMembership(membership); err != nil {
		return nil, errors.New("failed to create owner membership")
	}

	return business, nil
}

// GetCategories returns all business categories
func (s *BusinessService) GetCategories() ([]*models.BusinessCategory, error) {
	return s.businessRepo.GetCategories()
}

// GetByID returns a business by ID
func (s *BusinessService) GetByID(id uuid.UUID) (*models.Business, error) {
	return s.businessRepo.FindByID(id)
}

// generateSlug converts a name to a URL-safe slug
func generateSlug(name string) string {
	s := strings.ToLower(name)
	// Replace spaces and special chars with hyphens
	re := regexp.MustCompile(`[^a-z0-9]+`)
	s = re.ReplaceAllString(s, "-")
	// Trim leading/trailing hyphens
	s = strings.Trim(s, "-")
	if s == "" {
		s = "business"
	}
	return s
}
