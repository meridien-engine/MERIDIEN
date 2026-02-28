package repositories

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// UserRepository handles database operations for users
type UserRepository struct {
	db *gorm.DB
}

// NewUserRepository creates a new user repository instance
func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create creates a new user in the database
func (r *UserRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

// FindByID finds a user by ID within a specific tenant
func (r *UserRepository) FindByID(id, tenantID uuid.UUID) (*models.User, error) {
	var user models.User
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("Tenant").
		First(&user).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	return &user, nil
}

// FindByEmail finds a user by email within a specific tenant
func (r *UserRepository) FindByEmail(email string, tenantID uuid.UUID) (*models.User, error) {
	var user models.User
	err := r.db.Where("email = ? AND tenant_id = ?", email, tenantID).
		Preload("Tenant").
		First(&user).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	return &user, nil
}

// Update updates a user's information
func (r *UserRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

// Delete soft deletes a user
func (r *UserRepository) Delete(id, tenantID uuid.UUID) error {
	result := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Delete(&models.User{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("user not found")
	}

	return nil
}

// UpdateLastLogin updates the user's last login timestamp
func (r *UserRepository) UpdateLastLogin(id, tenantID uuid.UUID) error {
	now := time.Now()
	return r.db.Model(&models.User{}).
		Where("id = ? AND tenant_id = ?", id, tenantID).
		Update("last_login_at", &now).Error
}

// List returns all users for a tenant with pagination
func (r *UserRepository) List(tenantID uuid.UUID, limit, offset int) ([]models.User, int64, error) {
	var users []models.User
	var total int64

	// Count total
	if err := r.db.Model(&models.User{}).
		Where("tenant_id = ?", tenantID).
		Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := r.db.Where("tenant_id = ?", tenantID).
		Limit(limit).
		Offset(offset).
		Order("created_at DESC").
		Find(&users).Error

	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// CountByTenant returns the number of users for a tenant
func (r *UserRepository) CountByTenant(tenantID uuid.UUID) (int64, error) {
	var count int64
	err := r.db.Model(&models.User{}).
		Where("tenant_id = ?", tenantID).
		Count(&count).Error
	return count, err
}

// ExistsByEmail checks if a user with the given email exists in the tenant
func (r *UserRepository) ExistsByEmail(email string, tenantID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.User{}).
		Where("email = ? AND tenant_id = ?", email, tenantID).
		Count(&count).Error
	return count > 0, err
}

// FindAllByEmail finds all users with the given email across tenants
func (r *UserRepository) FindAllByEmail(email string) ([]models.User, error) {
	var users []models.User
	err := r.db.Where("email = ?", email).
		Preload("Tenant").
		Find(&users).Error
	if err != nil {
		return nil, err
	}
	return users, nil
}
