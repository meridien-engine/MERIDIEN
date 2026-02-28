package services

import (
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/shopspring/decimal"
)

type LocationService struct {
	locationRepo *repositories.LocationRepository
}

func NewLocationService(locationRepo *repositories.LocationRepository) *LocationService {
	return &LocationService{
		locationRepo: locationRepo,
	}
}

// CreateLocation creates a new location for a tenant
func (s *LocationService) CreateLocation(tenantID uuid.UUID, city, zone string, shippingFee decimal.Decimal) (*models.Location, error) {
	location := &models.Location{
		ID:          uuid.New(),
		TenantID:    tenantID,
		City:        city,
		Zone:        zone,
		ShippingFee: shippingFee,
	}

	if err := s.locationRepo.Create(location); err != nil {
		return nil, err
	}

	return location, nil
}

// GetLocation retrieves a location by ID
func (s *LocationService) GetLocation(tenantID, locationID uuid.UUID) (*models.Location, error) {
	return s.locationRepo.GetByID(tenantID, locationID)
}

// ListLocations lists all locations for a tenant
func (s *LocationService) ListLocations(tenantID uuid.UUID, page, pageSize int) ([]models.Location, int64, error) {
	if page < 1 {
		page = 1
	}

	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	return s.locationRepo.List(tenantID, page, pageSize)
}

// UpdateLocation updates a location
func (s *LocationService) UpdateLocation(tenantID, locationID uuid.UUID, updates map[string]interface{}) error {
	return s.locationRepo.Update(tenantID, locationID, updates)
}

// DeleteLocation deletes a location
func (s *LocationService) DeleteLocation(tenantID, locationID uuid.UUID) error {
	return s.locationRepo.Delete(tenantID, locationID)
}

// GetShippingFeeForCity retrieves shipping fee for a city
func (s *LocationService) GetShippingFeeForCity(tenantID uuid.UUID, city string) (decimal.Decimal, error) {
	return s.locationRepo.GetShippingFee(tenantID, city)
}
