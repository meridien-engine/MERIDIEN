package repositories

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// BranchRepository handles database operations for branches
type BranchRepository struct {
	db *gorm.DB
}

// NewBranchRepository creates a new branch repository instance
func NewBranchRepository(db *gorm.DB) *BranchRepository {
	return &BranchRepository{db: db}
}

// Create creates a new branch using businessTx for RLS compliance
func (r *BranchRepository) Create(branch *models.Branch) error {
	return businessTx(r.db, branch.BusinessID, func(tx *gorm.DB) error {
		return tx.Create(branch).Error
	})
}

// FindByID finds a branch by ID within a specific business
func (r *BranchRepository) FindByID(id, businessID uuid.UUID) (*models.Branch, error) {
	var branch models.Branch
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("id = ? AND business_id = ?", id, businessID).First(&branch).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("branch not found")
		}
		return nil, err
	}
	return &branch, nil
}

// Update updates a branch's information
func (r *BranchRepository) Update(branch *models.Branch) error {
	return businessTx(r.db, branch.BusinessID, func(tx *gorm.DB) error {
		return tx.Save(branch).Error
	})
}

// Delete soft deletes a branch
func (r *BranchRepository) Delete(id, businessID uuid.UUID) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		result := tx.Where("id = ? AND business_id = ?", id, businessID).Delete(&models.Branch{})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return errors.New("branch not found")
		}
		return nil
	})
}

// FindAll returns branches for a business with pagination
func (r *BranchRepository) FindAll(businessID uuid.UUID, page, limit int) ([]models.Branch, int64, error) {
	var branches []models.Branch
	var total int64

	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	offset := (page - 1) * limit

	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		query := tx.Model(&models.Branch{}).Where("business_id = ?", businessID)

		if err := query.Count(&total).Error; err != nil {
			return err
		}

		return query.
			Order(fmt.Sprintf("%s %s", "is_main", "DESC")).
			Order("created_at ASC").
			Limit(limit).
			Offset(offset).
			Find(&branches).Error
	})
	if err != nil {
		return nil, 0, err
	}
	return branches, total, nil
}

// GrantAccess grants a user access to a branch
func (r *BranchRepository) GrantAccess(access *models.UserBranchAccess) error {
	// No RLS on user_branch_access; use plain db
	return r.db.Create(access).Error
}

// RevokeAccess revokes a user's access to a branch
func (r *BranchRepository) RevokeAccess(userID, branchID uuid.UUID) error {
	result := r.db.Where("user_id = ? AND branch_id = ?", userID, branchID).
		Delete(&models.UserBranchAccess{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("access record not found")
	}
	return nil
}

// ListAccess returns all users with access to a branch
func (r *BranchRepository) ListAccess(branchID uuid.UUID) ([]models.UserBranchAccess, error) {
	var records []models.UserBranchAccess
	err := r.db.Where("branch_id = ?", branchID).
		Preload("User").
		Find(&records).Error
	return records, err
}

// BranchBelongsToBusiness checks that a branch belongs to the given business
func (r *BranchRepository) BranchBelongsToBusiness(branchID, businessID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.Branch{}).
		Where("id = ? AND business_id = ? AND deleted_at IS NULL", branchID, businessID).
		Count(&count).Error
	return count > 0, err
}
