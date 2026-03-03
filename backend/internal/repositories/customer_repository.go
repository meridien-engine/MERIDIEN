package repositories

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"gorm.io/gorm"
)

// CustomerRepository handles database operations for customers
type CustomerRepository struct {
	db *gorm.DB
}

// NewCustomerRepository creates a new customer repository instance
func NewCustomerRepository(db *gorm.DB) *CustomerRepository {
	return &CustomerRepository{db: db}
}

// Create creates a new customer
func (r *CustomerRepository) Create(customer *models.Customer) error {
	return businessTx(r.db, customer.BusinessID, func(tx *gorm.DB) error {
		return tx.Create(customer).Error
	})
}

// FindByID finds a customer by ID within a specific business
func (r *CustomerRepository) FindByID(id, businessID uuid.UUID) (*models.Customer, error) {
	var customer models.Customer
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("id = ? AND business_id = ?", id, businessID).First(&customer).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("customer not found")
		}
		return nil, err
	}
	return &customer, nil
}

// FindByEmail finds a customer by email within a specific business
func (r *CustomerRepository) FindByEmail(email string, businessID uuid.UUID) (*models.Customer, error) {
	var customer models.Customer
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Where("email = ? AND business_id = ?", email, businessID).First(&customer).Error
	})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("customer not found")
		}
		return nil, err
	}
	return &customer, nil
}

// Update updates a customer's information
func (r *CustomerRepository) Update(customer *models.Customer) error {
	return businessTx(r.db, customer.BusinessID, func(tx *gorm.DB) error {
		return tx.Save(customer).Error
	})
}

// Delete soft deletes a customer
func (r *CustomerRepository) Delete(id, businessID uuid.UUID) error {
	return businessTx(r.db, businessID, func(tx *gorm.DB) error {
		result := tx.Where("id = ? AND business_id = ?", id, businessID).Delete(&models.Customer{})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return errors.New("customer not found")
		}
		return nil
	})
}

// List returns customers for a business with pagination and filters
func (r *CustomerRepository) List(businessID uuid.UUID, filters ListFilters) ([]models.Customer, int64, error) {
	var customers []models.Customer
	var total int64

	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		query := tx.Model(&models.Customer{}).Where("business_id = ?", businessID)

		if filters.Search != "" {
			searchPattern := "%" + filters.Search + "%"
			query = query.Where(
				"first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR company_name ILIKE ?",
				searchPattern, searchPattern, searchPattern, searchPattern,
			)
		}
		if filters.Status != "" {
			query = query.Where("status = ?", filters.Status)
		}
		if filters.CustomerType != "" {
			query = query.Where("customer_type = ?", filters.CustomerType)
		}

		if err := query.Count(&total).Error; err != nil {
			return err
		}

		sortField := "created_at"
		sortOrder := "DESC"
		if filters.SortBy != "" {
			sortField = filters.SortBy
		}
		if filters.SortOrder != "" {
			sortOrder = filters.SortOrder
		}
		query = query.Order(fmt.Sprintf("%s %s", sortField, sortOrder))

		limit := 20
		offset := 0
		if filters.Limit > 0 {
			limit = filters.Limit
		}
		if filters.Offset >= 0 {
			offset = filters.Offset
		}

		return query.Limit(limit).Offset(offset).Find(&customers).Error
	})
	if err != nil {
		return nil, 0, err
	}
	return customers, total, nil
}

// ExistsByEmail checks if a customer with the given email exists in the business
func (r *CustomerRepository) ExistsByEmail(email string, businessID uuid.UUID) (bool, error) {
	var count int64
	err := businessTx(r.db, businessID, func(tx *gorm.DB) error {
		return tx.Model(&models.Customer{}).
			Where("email = ? AND business_id = ?", email, businessID).
			Count(&count).Error
	})
	return count > 0, err
}

// ListFilters represents filters for listing customers
type ListFilters struct {
	Search       string
	Status       string
	CustomerType string
	SortBy       string
	SortOrder    string
	Limit        int
	Offset       int
}
