package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

type ReportHandler struct {
	reportService *services.ReportService
}

func NewReportHandler(reportService *services.ReportService) *ReportHandler {
	return &ReportHandler{
		reportService: reportService,
	}
}

// GetCourierReconciliation returns cash reconciliation report for all couriers
// Shows delivered vs collected amounts per courier
func (h *ReportHandler) GetCourierReconciliation(c *gin.Context) {
	// Get tenant ID from context (set by middleware)
	businessIDVal, exists := c.Get("business_id")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "business_id not found in context")
		return
	}

	businessID, ok := businessIDVal.(uuid.UUID)
	if !ok {
		utils.ErrorResponse(c, http.StatusUnauthorized, "invalid business_id format")
		return
	}

	// Get reconciliation report
	reconciliation, err := h.reportService.GetCourierReconciliation(businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "failed to get courier reconciliation")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Courier reconciliation report retrieved successfully", reconciliation)
}
