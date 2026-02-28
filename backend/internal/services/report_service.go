package services

import (
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
)

type ReportService struct {
	courierRepo *repositories.CourierRepository
}

func NewReportService(courierRepo *repositories.CourierRepository) *ReportService {
	return &ReportService{
		courierRepo: courierRepo,
	}
}

// GetCourierReconciliation returns cash reconciliation data for all couriers
// Shows how much money is stuck with each courier waiting to be collected
func (s *ReportService) GetCourierReconciliation(tenantID uuid.UUID) ([]models.CourierReconciliation, error) {
	return s.courierRepo.GetReconciliationReport(tenantID)
}
