package services

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
)

// SubmitJoinReq is the input for a user submitting a join request
type SubmitJoinReq struct {
	BusinessSlug string `json:"business_slug" binding:"required"`
	Message      string `json:"message"`
	Role         string `json:"role"`
}

// SendInvitationReq is the input for sending an invitation
type SendInvitationReq struct {
	Email string `json:"email" binding:"required,email"`
	Role  string `json:"role" binding:"required"`
}

// UpdateRoleReq is the input for updating a member's role
type UpdateRoleReq struct {
	Role string `json:"role" binding:"required"`
}

// MembershipService handles join requests, invitations, and member management
type MembershipService struct {
	joinReqRepo    *repositories.JoinRequestRepository
	invitationRepo *repositories.InvitationRepository
	businessRepo   *repositories.BusinessRepository
	userRepo       *repositories.UserRepository
}

// NewMembershipService creates a new MembershipService
func NewMembershipService(
	joinReqRepo *repositories.JoinRequestRepository,
	invitationRepo *repositories.InvitationRepository,
	businessRepo *repositories.BusinessRepository,
	userRepo *repositories.UserRepository,
) *MembershipService {
	return &MembershipService{
		joinReqRepo:    joinReqRepo,
		invitationRepo: invitationRepo,
		businessRepo:   businessRepo,
		userRepo:       userRepo,
	}
}

// ─── Business Lookup ─────────────────────────────────────────────────────────

// LookupBySlug returns public business info by slug
func (s *MembershipService) LookupBySlug(slug string) (*models.Business, error) {
	return s.businessRepo.FindBySlug(slug)
}

// ─── Join Request Methods ────────────────────────────────────────────────────

// SubmitJoinRequest lets a user request to join a business by slug
func (s *MembershipService) SubmitJoinRequest(userID uuid.UUID, req SubmitJoinReq) (*models.JoinRequest, error) {
	business, err := s.businessRepo.FindBySlug(req.BusinessSlug)
	if err != nil {
		return nil, errors.New("business not found")
	}

	// Reject if already an active member
	if _, err := s.businessRepo.GetMembership(userID, business.ID); err == nil {
		return nil, errors.New("you are already a member of this business")
	}

	// Reject if pending request already exists
	existing, err := s.joinReqRepo.FindPendingByUserAndBusiness(userID, business.ID)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, errors.New("you already have a pending join request for this business")
	}

	jr := &models.JoinRequest{
		UserID:     userID,
		BusinessID: business.ID,
		Status:     "pending",
		Message:    req.Message,
		Role:       req.Role,
	}
	if err := s.joinReqRepo.Create(jr); err != nil {
		return nil, errors.New("failed to submit join request")
	}
	return jr, nil
}

// ListMyJoinRequests returns all join requests submitted by the given user
func (s *MembershipService) ListMyJoinRequests(userID uuid.UUID) ([]models.JoinRequest, error) {
	return s.joinReqRepo.ListByUser(userID)
}

// ListJoinRequests returns all join requests for a business
func (s *MembershipService) ListJoinRequests(businessID uuid.UUID) ([]models.JoinRequest, error) {
	return s.joinReqRepo.ListByBusiness(businessID)
}

// ApproveJoinRequest approves a pending join request and creates the membership
func (s *MembershipService) ApproveJoinRequest(businessID, requestID, reviewerID uuid.UUID, role string) error {
	jr, err := s.joinReqRepo.FindByID(requestID)
	if err != nil {
		return errors.New("join request not found")
	}
	if jr.BusinessID != businessID {
		return errors.New("join request does not belong to this business")
	}
	if jr.Status != "pending" {
		return errors.New("join request is no longer pending")
	}

	// Use requested role if approver didn't specify one
	assignedRole := role
	if assignedRole == "" {
		assignedRole = jr.Role
	}
	if assignedRole == "" {
		assignedRole = "viewer"
	}

	membership := &models.UserBusinessMembership{
		UserID:     jr.UserID,
		BusinessID: jr.BusinessID,
		Role:       assignedRole,
		Status:     "active",
		InvitedBy:  &reviewerID,
	}
	if err := s.businessRepo.CreateMembership(membership); err != nil {
		return errors.New("failed to create membership")
	}

	now := time.Now()
	return s.joinReqRepo.UpdateStatus(requestID, "approved", assignedRole, reviewerID, now)
}

// RejectJoinRequest rejects a pending join request
func (s *MembershipService) RejectJoinRequest(businessID, requestID, reviewerID uuid.UUID) error {
	jr, err := s.joinReqRepo.FindByID(requestID)
	if err != nil {
		return errors.New("join request not found")
	}
	if jr.BusinessID != businessID {
		return errors.New("join request does not belong to this business")
	}
	if jr.Status != "pending" {
		return errors.New("join request is no longer pending")
	}

	now := time.Now()
	return s.joinReqRepo.UpdateStatus(requestID, "rejected", "", reviewerID, now)
}

// ─── Invitation Methods ──────────────────────────────────────────────────────

// SendInvitation creates an invitation for an email address to join a business
func (s *MembershipService) SendInvitation(businessID, inviterID uuid.UUID, req SendInvitationReq) (*models.Invitation, error) {
	// Prevent duplicate active invitations for the same email+business
	existing, err := s.invitationRepo.FindPendingByEmailAndBusiness(req.Email, businessID)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, errors.New("a pending invitation already exists for this email")
	}

	// Generate a cryptographically random 32-byte hex token
	tokenBytes := make([]byte, 32)
	if _, err := rand.Read(tokenBytes); err != nil {
		return nil, errors.New("failed to generate invitation token")
	}
	token := hex.EncodeToString(tokenBytes)

	expiresAt := time.Now().Add(7 * 24 * time.Hour)
	inv := &models.Invitation{
		BusinessID: businessID,
		Email:      req.Email,
		Role:       req.Role,
		Token:      token,
		InvitedBy:  &inviterID,
		Status:     "pending",
		ExpiresAt:  &expiresAt,
	}
	if err := s.invitationRepo.Create(inv); err != nil {
		return nil, errors.New("failed to create invitation")
	}
	return inv, nil
}

// ListInvitations returns all invitations for a business
func (s *MembershipService) ListInvitations(businessID uuid.UUID) ([]models.Invitation, error) {
	return s.invitationRepo.FindByBusiness(businessID)
}

// ValidateInvitationToken validates a token and returns the invitation if valid
func (s *MembershipService) ValidateInvitationToken(token string) (*models.Invitation, error) {
	inv, err := s.invitationRepo.FindByToken(token)
	if err != nil {
		return nil, errors.New("invitation not found")
	}
	if inv.Status != "pending" {
		return nil, errors.New("invitation is no longer valid")
	}
	if inv.ExpiresAt != nil && time.Now().After(*inv.ExpiresAt) {
		return nil, errors.New("invitation has expired")
	}
	return inv, nil
}

// AcceptInvitation accepts an invitation and creates the membership
func (s *MembershipService) AcceptInvitation(token string, userID uuid.UUID) (*models.UserBusinessMembership, error) {
	inv, err := s.ValidateInvitationToken(token)
	if err != nil {
		return nil, err
	}

	// Check not already a member
	if _, err := s.businessRepo.GetMembership(userID, inv.BusinessID); err == nil {
		return nil, errors.New("you are already a member of this business")
	}

	membership := &models.UserBusinessMembership{
		UserID:     userID,
		BusinessID: inv.BusinessID,
		Role:       inv.Role,
		Status:     "active",
		InvitedBy:  inv.InvitedBy,
	}
	if err := s.businessRepo.CreateMembership(membership); err != nil {
		return nil, errors.New("failed to create membership")
	}

	now := time.Now()
	if err := s.invitationRepo.UpdateStatus(inv.ID, "accepted", &now); err != nil {
		return nil, errors.New("failed to update invitation status")
	}

	return membership, nil
}

// ─── Member Management Methods ───────────────────────────────────────────────

// GetMembers returns all active members of a business
func (s *MembershipService) GetMembers(businessID uuid.UUID) ([]models.UserBusinessMembership, error) {
	var members []models.UserBusinessMembership
	err := s.businessRepo.DB().
		Preload("User").
		Where("business_id = ? AND status = ? AND deleted_at IS NULL", businessID, "active").
		Find(&members).Error
	return members, err
}

// UpdateMemberRole updates the role of a member (owner role is immutable)
func (s *MembershipService) UpdateMemberRole(businessID, targetUserID uuid.UUID, newRole string) error {
	membership, err := s.businessRepo.GetMembership(targetUserID, businessID)
	if err != nil {
		return errors.New("member not found")
	}
	if membership.Role == "owner" {
		return errors.New("cannot change the role of an owner")
	}
	membership.Role = newRole
	return s.businessRepo.DB().Save(membership).Error
}

// RemoveMember soft-deletes a membership (owner cannot be removed)
func (s *MembershipService) RemoveMember(businessID, targetUserID uuid.UUID) error {
	membership, err := s.businessRepo.GetMembership(targetUserID, businessID)
	if err != nil {
		return errors.New("member not found")
	}
	if membership.Role == "owner" {
		return errors.New("cannot remove the owner of a business")
	}
	return s.businessRepo.DB().Delete(membership).Error
}
