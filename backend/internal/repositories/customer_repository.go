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
	return r.db.Create(customer).Error
}

// FindByID finds a customer by ID within a specific tenant
func (r *CustomerRepository) FindByID(id, tenantID uuid.UUID) (*models.Customer, error) {
	var customer models.Customer
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		First(&customer).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("customer not found")
		}
		return nil, err
	}

	return &customer, nil
}

// FindByEmail finds a customer by email within a specific tenant
func (r *CustomerRepository) FindByEmail(email string, tenantID uuid.UUID) (*models.Customer, error) {
	var customer models.Customer
	err := r.db.Where("email = ? AND tenant_id = ?", email, tenantID).
		First(&customer).Error

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
	return r.db.Save(customer).Error
}

// Delete soft deletes a customer
func (r *CustomerRepository) Delete(id, tenantID uuid.UUID) error {
	result := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Delete(&models.Customer{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("customer not found")
	}

	return nil
}

// List returns customers for a tenant with pagination and filters
func (r *CustomerRepository) List(tenantID uuid.UUID, filters ListFilters) ([]models.Customer, int64, error) {
	var customers []models.Customer
	var total int64

	query := r.db.Model(&models.Customer{}).Where("tenant_id = ?", tenantID)

	// Apply filters
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

	// Count total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Apply sorting
	sortField := "created_at"
	sortOrder := "DESC"
	if filters.SortBy != "" {
		sortField = filters.SortBy
	}
	if filters.SortOrder != "" {
		sortOrder = filters.SortOrder
	}
	query = query.Order(fmt.Sprintf("%s %s", sortField, sortOrder))

	// Apply pagination
	limit := 20
	offset := 0
	if filters.Limit > 0 {
		limit = filters.Limit
	}
	if filters.Offset >= 0 {
		offset = filters.Offset
	}

	err := query.Limit(limit).Offset(offset).Find(&customers).Error
	if err != nil {
		return nil, 0, err
	}

	return customers, total, nil
}

// CountByTenant returns the number of customers for a tenant
func (r *CustomerRepository) CountByTenant(tenantID uuid.UUID) (int64, error) {
	var count int64
	err := r.db.Model(&models.Customer{}).
		Where("tenant_id = ?", tenantID).
		Count(&count).Error
	return count, err
}

// ExistsByEmail checks if a customer with the given email exists in the tenant
func (r *CustomerRepository) ExistsByEmail(email string, tenantID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&models.Customer{}).
		Where("email = ? AND tenant_id = ?", email, tenantID).
		Count(&count).Error
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
