package repositories

import (
	"errors"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// BusinessRepository handles database operations for businesses
type BusinessRepository struct {
	db *gorm.DB
}

// NewBusinessRepository creates a new business repository instance
func NewBusinessRepository(db *gorm.DB) *BusinessRepository {
	return &BusinessRepository{db: db}
}

// Create creates a new business
func (r *BusinessRepository) Create(business *models.Business) error {
	return r.db.Create(business).Error
}

// FindByID finds a business by ID
func (r *BusinessRepository) FindByID(id uuid.UUID) (*models.Business, error) {
	var business models.Business
	err := r.db.Where("id = ?", id).First(&business).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("business not found")
		}
		return nil, err
	}
	return &business, nil
}

// FindBySlug finds a business by slug
func (r *BusinessRepository) FindBySlug(slug string) (*models.Business, error) {
	var business models.Business
	err := r.db.Where("slug = ?", slug).First(&business).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("business not found")
		}
		return nil, err
	}
	return &business, nil
}

// Update updates a business's information
func (r *BusinessRepository) Update(business *models.Business) error {
	return r.db.Save(business).Error
}

// ExistsBySlug checks if a business with the given slug exists
func (r *BusinessRepository) ExistsBySlug(slug string) (bool, error) {
	var count int64
	err := r.db.Model(&models.Business{}).
		Where("slug = ?", slug).
		Count(&count).Error
	return count > 0, err
}

// GetCategories returns all business categories
func (r *BusinessRepository) GetCategories() ([]*models.BusinessCategory, error) {
	var categories []*models.BusinessCategory
	err := r.db.Order("name ASC").Find(&categories).Error
	return categories, err
}

// GetUserBusinesses returns all businesses a user is a member of
func (r *BusinessRepository) GetUserBusinesses(userID uuid.UUID) ([]*models.Business, error) {
	var businesses []*models.Business
	err := r.db.
		Joins("JOIN user_business_memberships ubm ON ubm.business_id = businesses.id").
		Where("ubm.user_id = ? AND ubm.deleted_at IS NULL AND ubm.status = ?", userID, "active").
		Where("businesses.deleted_at IS NULL").
		Find(&businesses).Error
	return businesses, err
}

// GetMembership returns the membership record for a user in a business
func (r *BusinessRepository) GetMembership(userID, businessID uuid.UUID) (*models.UserBusinessMembership, error) {
	var membership models.UserBusinessMembership
	err := r.db.Where("user_id = ? AND business_id = ? AND deleted_at IS NULL", userID, businessID).
		First(&membership).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("membership not found")
		}
		return nil, err
	}
	return &membership, nil
}

// CreateMembership creates a new user-business membership
func (r *BusinessRepository) CreateMembership(m *models.UserBusinessMembership) error {
	return r.db.Create(m).Error
}

// DB exposes the underlying gorm.DB for operations not covered by specific methods
func (r *BusinessRepository) DB() *gorm.DB {
	return r.db
}
