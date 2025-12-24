package services

import (
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
	"github.com/shopspring/decimal"
)

// CustomerService handles customer business logic
type CustomerService struct {
	customerRepo *repositories.CustomerRepository
}

// NewCustomerService creates a new customer service instance
func NewCustomerService(customerRepo *repositories.CustomerRepository) *CustomerService {
	return &CustomerService{
		customerRepo: customerRepo,
	}
}

// CreateCustomerRequest represents a customer creation request
type CreateCustomerRequest struct {
	TenantID     uuid.UUID `json:"tenant_id"`
	FirstName    string    `json:"first_name"`
	LastName     string    `json:"last_name"`
	Email        string    `json:"email"`
	Phone        string    `json:"phone"`
	AddressLine1 string    `json:"address_line1"`
	AddressLine2 string    `json:"address_line2"`
	City         string    `json:"city"`
	State        string    `json:"state"`
	PostalCode   string    `json:"postal_code"`
	Country      string    `json:"country"`
	CompanyName  string    `json:"company_name"`
	TaxID        string    `json:"tax_id"`
	CustomerType string    `json:"customer_type"`
	Notes        string    `json:"notes"`
}

// UpdateCustomerRequest represents a customer update request
type UpdateCustomerRequest struct {
	FirstName    *string `json:"first_name"`
	LastName     *string `json:"last_name"`
	Email        *string `json:"email"`
	Phone        *string `json:"phone"`
	AddressLine1 *string `json:"address_line1"`
	AddressLine2 *string `json:"address_line2"`
	City         *string `json:"city"`
	State        *string `json:"state"`
	PostalCode   *string `json:"postal_code"`
	Country      *string `json:"country"`
	CompanyName  *string `json:"company_name"`
	TaxID        *string `json:"tax_id"`
	CustomerType *string `json:"customer_type"`
	Status       *string `json:"status"`
	Notes        *string `json:"notes"`
}

// ListCustomersRequest represents a request to list customers
type ListCustomersRequest struct {
	TenantID     uuid.UUID
	Search       string
	Status       string
	CustomerType string
	SortBy       string
	SortOrder    string
	Page         int
	PerPage      int
}

// Create creates a new customer
func (s *CustomerService) Create(req *CreateCustomerRequest) (*models.Customer, error) {
	// Validate input
	if err := s.validateCreateRequest(req); err != nil {
		return nil, err
	}

	// Check if email already exists (if provided)
	if req.Email != "" {
		exists, err := s.customerRepo.ExistsByEmail(req.Email, req.TenantID)
		if err != nil {
			return nil, err
		}
		if exists {
			return nil, errors.New("customer with this email already exists")
		}
	}

	// Create customer
	customer := &models.Customer{
		TenantID:     req.TenantID,
		FirstName:    strings.TrimSpace(req.FirstName),
		LastName:     strings.TrimSpace(req.LastName),
		Email:        strings.ToLower(strings.TrimSpace(req.Email)),
		Phone:        strings.TrimSpace(req.Phone),
		AddressLine1: strings.TrimSpace(req.AddressLine1),
		AddressLine2: strings.TrimSpace(req.AddressLine2),
		City:         strings.TrimSpace(req.City),
		State:        strings.TrimSpace(req.State),
		PostalCode:   strings.TrimSpace(req.PostalCode),
		Country:      strings.TrimSpace(req.Country),
		CompanyName:  strings.TrimSpace(req.CompanyName),
		TaxID:        strings.TrimSpace(req.TaxID),
		CustomerType: req.CustomerType,
		Status:       "active",
		Notes:        strings.TrimSpace(req.Notes),
		CreditLimit:  decimal.NewFromInt(0),
		CurrentBalance: decimal.NewFromInt(0),
	}

	// Save to database
	if err := s.customerRepo.Create(customer); err != nil {
		return nil, errors.New("failed to create customer")
	}

	return customer, nil
}

// GetByID retrieves a customer by ID
func (s *CustomerService) GetByID(id, tenantID uuid.UUID) (*models.Customer, error) {
	customer, err := s.customerRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, err
	}
	return customer, nil
}

// Update updates a customer's information
func (s *CustomerService) Update(id, tenantID uuid.UUID, req *UpdateCustomerRequest) (*models.Customer, error) {
	// Get existing customer
	customer, err := s.customerRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, err
	}

	// Update fields if provided
	if req.FirstName != nil {
		if err := utils.ValidateName(*req.FirstName, "first name"); err != nil {
			return nil, err
		}
		customer.FirstName = strings.TrimSpace(*req.FirstName)
	}

	if req.LastName != nil {
		if err := utils.ValidateName(*req.LastName, "last name"); err != nil {
			return nil, err
		}
		customer.LastName = strings.TrimSpace(*req.LastName)
	}

	if req.Email != nil {
		email := strings.ToLower(strings.TrimSpace(*req.Email))
		if email != "" {
			if err := utils.ValidateEmail(email); err != nil {
				return nil, err
			}
			// Check if email already exists for another customer
			if email != customer.Email {
				exists, err := s.customerRepo.ExistsByEmail(email, tenantID)
				if err != nil {
					return nil, err
				}
				if exists {
					return nil, errors.New("customer with this email already exists")
				}
			}
		}
		customer.Email = email
	}

	if req.Phone != nil {
		customer.Phone = strings.TrimSpace(*req.Phone)
	}

	if req.AddressLine1 != nil {
		customer.AddressLine1 = strings.TrimSpace(*req.AddressLine1)
	}

	if req.AddressLine2 != nil {
		customer.AddressLine2 = strings.TrimSpace(*req.AddressLine2)
	}

	if req.City != nil {
		customer.City = strings.TrimSpace(*req.City)
	}

	if req.State != nil {
		customer.State = strings.TrimSpace(*req.State)
	}

	if req.PostalCode != nil {
		customer.PostalCode = strings.TrimSpace(*req.PostalCode)
	}

	if req.Country != nil {
		customer.Country = strings.TrimSpace(*req.Country)
	}

	if req.CompanyName != nil {
		customer.CompanyName = strings.TrimSpace(*req.CompanyName)
	}

	if req.TaxID != nil {
		customer.TaxID = strings.TrimSpace(*req.TaxID)
	}

	if req.CustomerType != nil {
		if err := s.validateCustomerType(*req.CustomerType); err != nil {
			return nil, err
		}
		customer.CustomerType = *req.CustomerType
	}

	if req.Status != nil {
		if err := s.validateStatus(*req.Status); err != nil {
			return nil, err
		}
		customer.Status = *req.Status
	}

	if req.Notes != nil {
		customer.Notes = strings.TrimSpace(*req.Notes)
	}

	// Save updates
	if err := s.customerRepo.Update(customer); err != nil {
		return nil, errors.New("failed to update customer")
	}

	return customer, nil
}

// Delete soft deletes a customer
func (s *CustomerService) Delete(id, tenantID uuid.UUID) error {
	return s.customerRepo.Delete(id, tenantID)
}

// List returns a paginated list of customers
func (s *CustomerService) List(req *ListCustomersRequest) ([]models.Customer, int64, error) {
	// Calculate offset
	page := req.Page
	if page < 1 {
		page = 1
	}
	perPage := req.PerPage
	if perPage < 1 {
		perPage = 20
	}
	if perPage > 100 {
		perPage = 100
	}
	offset := (page - 1) * perPage

	// Build filters
	filters := repositories.ListFilters{
		Search:       req.Search,
		Status:       req.Status,
		CustomerType: req.CustomerType,
		SortBy:       req.SortBy,
		SortOrder:    req.SortOrder,
		Limit:        perPage,
		Offset:       offset,
	}

	return s.customerRepo.List(req.TenantID, filters)
}

// validateCreateRequest validates the creation request
func (s *CustomerService) validateCreateRequest(req *CreateCustomerRequest) error {
	if req.TenantID == uuid.Nil {
		return errors.New("tenant ID is required")
	}

	if err := utils.ValidateName(req.FirstName, "first name"); err != nil {
		return err
	}

	if err := utils.ValidateName(req.LastName, "last name"); err != nil {
		return err
	}

	if req.Email != "" {
		if err := utils.ValidateEmail(req.Email); err != nil {
			return err
		}
	}

	// Default customer type if not provided
	if req.CustomerType == "" {
		req.CustomerType = "individual"
	}

	if err := s.validateCustomerType(req.CustomerType); err != nil {
		return err
	}

	return nil
}

// validateCustomerType validates customer type
func (s *CustomerService) validateCustomerType(customerType string) error {
	validTypes := map[string]bool{
		"individual": true,
		"business":   true,
	}

	if !validTypes[customerType] {
		return errors.New("invalid customer type. Must be 'individual' or 'business'")
	}

	return nil
}

// validateStatus validates customer status
func (s *CustomerService) validateStatus(status string) error {
	validStatuses := map[string]bool{
		"active":   true,
		"inactive": true,
		"blocked":  true,
	}

	if !validStatuses[status] {
		return errors.New("invalid status. Must be 'active', 'inactive', or 'blocked'")
	}

	return nil
}
