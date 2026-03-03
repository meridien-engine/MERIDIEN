package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
)

// MembershipHandler handles join requests, invitations, and member management
type MembershipHandler struct {
	membershipService *services.MembershipService
}

// NewMembershipHandler creates a new MembershipHandler
func NewMembershipHandler(membershipService *services.MembershipService) *MembershipHandler {
	return &MembershipHandler{membershipService: membershipService}
}

// ─── Business Lookup ─────────────────────────────────────────────────────────

// LookupBusiness returns public info about a business by slug
// GET /api/v1/businesses/slug/:slug
func (h *MembershipHandler) LookupBusiness(c *gin.Context) {
	slug := c.Param("slug")
	if slug == "" {
		utils.ErrorResponse(c, http.StatusBadRequest, "Slug is required")
		return
	}

	business, err := h.membershipService.LookupBySlug(slug)
	if err != nil {
		utils.NotFoundResponse(c, "Business not found")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Business found", business)
}

// ─── Join Request Endpoints ───────────────────────────────────────────────────

// SubmitJoinRequest lets an authenticated user submit a join request by business slug
// POST /api/v1/join-requests
func (h *MembershipHandler) SubmitJoinRequest(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	var req services.SubmitJoinReq
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	jr, err := h.membershipService.SubmitJoinRequest(userID, req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Join request submitted", jr)
}

// ListMyJoinRequests returns all join requests submitted by the authenticated user
// GET /api/v1/join-requests
func (h *MembershipHandler) ListMyJoinRequests(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	requests, err := h.membershipService.ListMyJoinRequests(userID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve join requests")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Join requests retrieved", requests)
}

// ListBusinessJoinRequests returns all join requests for a business
// GET /api/v1/businesses/:id/join-requests
func (h *MembershipHandler) ListBusinessJoinRequests(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}

	requests, err := h.membershipService.ListJoinRequests(businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve join requests")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Join requests retrieved", requests)
}

// approveRejectRequest is the shared request body for approve/reject
type approveRejectRequest struct {
	Role string `json:"role"`
}

// ApproveJoinRequest approves a pending join request
// POST /api/v1/businesses/:id/join-requests/:reqId/approve
func (h *MembershipHandler) ApproveJoinRequest(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}
	reviewerID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	reqIDStr := c.Param("reqId")
	reqID, err := uuid.Parse(reqIDStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request ID")
		return
	}

	var body approveRejectRequest
	_ = c.ShouldBindJSON(&body) // role is optional

	if err := h.membershipService.ApproveJoinRequest(businessID, reqID, reviewerID, body.Role); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Join request approved", nil)
}

// RejectJoinRequest rejects a pending join request
// POST /api/v1/businesses/:id/join-requests/:reqId/reject
func (h *MembershipHandler) RejectJoinRequest(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}
	reviewerID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	reqIDStr := c.Param("reqId")
	reqID, err := uuid.Parse(reqIDStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request ID")
		return
	}

	if err := h.membershipService.RejectJoinRequest(businessID, reqID, reviewerID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Join request rejected", nil)
}

// ─── Invitation Endpoints ─────────────────────────────────────────────────────

// SendInvitation sends an email invitation to join a business
// POST /api/v1/businesses/:id/invitations
func (h *MembershipHandler) SendInvitation(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}
	inviterID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	var req services.SendInvitationReq
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	inv, err := h.membershipService.SendInvitation(businessID, inviterID, req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Invitation sent", inv)
}

// ListInvitations returns all invitations for a business
// GET /api/v1/businesses/:id/invitations
func (h *MembershipHandler) ListInvitations(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}

	invitations, err := h.membershipService.ListInvitations(businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve invitations")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Invitations retrieved", invitations)
}

// ValidateInvitation validates an invitation token without accepting it
// GET /api/v1/invitations/:token
func (h *MembershipHandler) ValidateInvitation(c *gin.Context) {
	token := c.Param("token")
	inv, err := h.membershipService.ValidateInvitationToken(token)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Invitation is valid", inv)
}

// AcceptInvitation accepts an invitation and creates the membership
// POST /api/v1/invitations/:token/accept
func (h *MembershipHandler) AcceptInvitation(c *gin.Context) {
	userID, err := middleware.GetUserID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	token := c.Param("token")
	membership, err := h.membershipService.AcceptInvitation(token, userID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Invitation accepted", membership)
}

// ─── Member Management Endpoints ──────────────────────────────────────────────

// GetMembers returns all active members of a business
// GET /api/v1/businesses/:id/members
func (h *MembershipHandler) GetMembers(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}

	members, err := h.membershipService.GetMembers(businessID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve members")
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Members retrieved", members)
}

// updateRoleRequest is the request body for updating a member's role
type updateRoleRequest struct {
	Role string `json:"role" binding:"required"`
}

// UpdateMemberRole changes the role of a member
// PATCH /api/v1/businesses/:id/members/:userId
func (h *MembershipHandler) UpdateMemberRole(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}

	targetIDStr := c.Param("userId")
	targetID, err := uuid.Parse(targetIDStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid user ID")
		return
	}

	var req updateRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Role is required")
		return
	}

	if err := h.membershipService.UpdateMemberRole(businessID, targetID, req.Role); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Member role updated", nil)
}

// RemoveMember removes a member from a business
// DELETE /api/v1/businesses/:id/members/:userId
func (h *MembershipHandler) RemoveMember(c *gin.Context) {
	businessID, err := parseBusinessID(c)
	if err != nil {
		return
	}

	targetIDStr := c.Param("userId")
	targetID, err := uuid.Parse(targetIDStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid user ID")
		return
	}

	if err := h.membershipService.RemoveMember(businessID, targetID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Member removed", nil)
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

// parseBusinessID parses and returns the :id path parameter as a UUID.
// On error it writes the response and returns a non-nil error.
func parseBusinessID(c *gin.Context) (uuid.UUID, error) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid business ID")
		c.Abort()
	}
	return id, err
}
