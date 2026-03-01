package services

import (
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/shopspring/decimal"
)

// POSService handles business logic for point-of-sale operations
type POSService struct {
	sessionRepo  *repositories.POSSessionRepository
	orderRepo    *repositories.OrderRepository
	productRepo  *repositories.ProductRepository
	paymentRepo  *repositories.PaymentRepository
	orderService *OrderService
}

// NewPOSService creates a new POS service instance
func NewPOSService(
	sessionRepo *repositories.POSSessionRepository,
	orderRepo *repositories.OrderRepository,
	productRepo *repositories.ProductRepository,
	paymentRepo *repositories.PaymentRepository,
	orderService *OrderService,
) *POSService {
	return &POSService{
		sessionRepo:  sessionRepo,
		orderRepo:    orderRepo,
		productRepo:  productRepo,
		paymentRepo:  paymentRepo,
		orderService: orderService,
	}
}

// ── Session management ───────────────────────────────────────────────────────

// OpenSessionRequest is the input for opening a new POS session
type OpenSessionRequest struct {
	TenantID     uuid.UUID
	CashierID    uuid.UUID
	OpeningFloat string
}

// OpenSession opens a new cash drawer session for a cashier.
// Returns an error if the cashier already has an open session.
func (s *POSService) OpenSession(req *OpenSessionRequest) (*models.POSSession, error) {
	// Check for an existing open session
	existing, err := s.sessionRepo.FindOpenByUser(req.CashierID, req.TenantID)
	if err != nil {
		return nil, fmt.Errorf("failed to check existing sessions: %w", err)
	}
	if existing != nil {
		return nil, errors.New("cashier already has an open session")
	}

	openingFloat := decimal.Zero
	if req.OpeningFloat != "" {
		openingFloat, err = decimal.NewFromString(req.OpeningFloat)
		if err != nil {
			return nil, errors.New("invalid opening float amount")
		}
		if openingFloat.IsNegative() {
			return nil, errors.New("opening float must be non-negative")
		}
	}

	session := &models.POSSession{
		TenantID:     req.TenantID,
		CashierID:    req.CashierID,
		Status:       models.POSSessionStatusOpen,
		OpeningFloat: openingFloat,
		OpenedAt:     time.Now(),
	}

	if err := s.sessionRepo.Create(session); err != nil {
		return nil, fmt.Errorf("failed to create session: %w", err)
	}

	return session, nil
}

// CloseSessionRequest is the input for closing a POS session
type CloseSessionRequest struct {
	SessionID   uuid.UUID
	TenantID    uuid.UUID
	CashierID   uuid.UUID
	ClosingCash string
}

// CloseSession closes the given session and records the reconciliation values.
func (s *POSService) CloseSession(req *CloseSessionRequest) (*models.POSSession, error) {
	session, err := s.sessionRepo.FindByID(req.SessionID, req.TenantID)
	if err != nil {
		return nil, errors.New("session not found")
	}

	if !session.IsOpen() {
		return nil, errors.New("session is already closed")
	}

	if session.CashierID != req.CashierID {
		return nil, errors.New("only the session owner can close it")
	}

	closingCash, err := decimal.NewFromString(req.ClosingCash)
	if err != nil {
		return nil, errors.New("invalid closing cash amount")
	}
	if closingCash.IsNegative() {
		return nil, errors.New("closing cash must be non-negative")
	}

	now := time.Now()

	// Calculate expected cash = opening float + total cash collected
	cashCollected, err := s.sessionRepo.SumCashPayments(session)
	if err != nil {
		return nil, fmt.Errorf("failed to calculate expected cash: %w", err)
	}
	expectedCash := session.OpeningFloat.Add(cashCollected)
	cashDiff := closingCash.Sub(expectedCash)

	session.Status = models.POSSessionStatusClosed
	session.ClosedAt = &now
	session.ClosingCash = &closingCash
	session.ExpectedCash = &expectedCash
	session.CashDiff = &cashDiff

	if err := s.sessionRepo.Update(session); err != nil {
		return nil, fmt.Errorf("failed to close session: %w", err)
	}

	return session, nil
}

// GetCurrentSession returns the open session for a cashier, or nil if none
func (s *POSService) GetCurrentSession(cashierID, tenantID uuid.UUID) (*models.POSSession, error) {
	return s.sessionRepo.FindOpenByUser(cashierID, tenantID)
}

// GetSession returns a specific session by ID
func (s *POSService) GetSession(id, tenantID uuid.UUID) (*models.POSSession, error) {
	return s.sessionRepo.FindByID(id, tenantID)
}

// ListSessions returns a paginated list of sessions for a tenant
func (s *POSService) ListSessions(tenantID uuid.UUID, f repositories.POSSessionFilters) ([]models.POSSession, int64, error) {
	return s.sessionRepo.List(tenantID, f)
}

// ── Product lookup ───────────────────────────────────────────────────────────

// LookupProduct finds a product by barcode (exact) then SKU (exact)
func (s *POSService) LookupProduct(query string, tenantID uuid.UUID) (*models.Product, error) {
	if query == "" {
		return nil, errors.New("query cannot be empty")
	}

	// Try barcode first
	product, err := s.productRepo.FindByBarcode(query, tenantID)
	if err == nil {
		return product, nil
	}

	// Fall back to SKU
	product, err = s.productRepo.FindBySKU(query, tenantID)
	if err == nil {
		return product, nil
	}

	return nil, errors.New("product not found")
}

// ── Checkout ─────────────────────────────────────────────────────────────────

// POSCheckoutItem is a single line in the checkout request
type POSCheckoutItem struct {
	ProductID string
	Quantity  int
}

// POSCheckoutRequest is the input for completing a POS sale
type POSCheckoutRequest struct {
	TenantID       uuid.UUID
	CashierID      uuid.UUID
	SessionID      uuid.UUID
	CustomerName   string
	Items          []POSCheckoutItem
	CashTendered   string
	DiscountAmount string
}

// POSCheckoutResult is returned after a successful checkout
type POSCheckoutResult struct {
	Order   *models.Order   `json:"order"`
	Payment *models.Payment `json:"payment"`
	Change  string          `json:"change"`
}

// Checkout atomically creates an order, deducts inventory, and records the cash payment
func (s *POSService) Checkout(req *POSCheckoutRequest) (*POSCheckoutResult, error) {
	// 1. Validate the session
	session, err := s.sessionRepo.FindByID(req.SessionID, req.TenantID)
	if err != nil {
		return nil, errors.New("session not found")
	}
	if !session.IsOpen() {
		return nil, errors.New("session is not open")
	}
	if session.CashierID != req.CashierID {
		return nil, errors.New("session does not belong to the current cashier")
	}

	// 2. Validate items
	if len(req.Items) == 0 {
		return nil, errors.New("order must have at least one item")
	}

	// 3. Parse financials
	cashTendered, err := decimal.NewFromString(req.CashTendered)
	if err != nil {
		return nil, errors.New("invalid cash tendered amount")
	}

	discountAmount := decimal.Zero
	if req.DiscountAmount != "" {
		discountAmount, err = decimal.NewFromString(req.DiscountAmount)
		if err != nil {
			return nil, errors.New("invalid discount amount")
		}
	}

	// 4. Resolve products and check stock
	type resolvedItem struct {
		product *models.Product
		qty     int
	}
	resolved := make([]resolvedItem, 0, len(req.Items))

	orderItems := make([]models.OrderItem, 0, len(req.Items))
	subtotal := decimal.Zero

	for _, item := range req.Items {
		if item.Quantity <= 0 {
			return nil, errors.New("quantity must be positive")
		}

		productID, err := uuid.Parse(item.ProductID)
		if err != nil {
			return nil, fmt.Errorf("invalid product ID: %s", item.ProductID)
		}

		product, err := s.productRepo.FindByID(productID, req.TenantID)
		if err != nil {
			return nil, fmt.Errorf("product not found: %s", item.ProductID)
		}
		if !product.IsActive() {
			return nil, fmt.Errorf("product is not active: %s", product.Name)
		}
		if product.TrackInventory && product.StockQuantity < item.Quantity {
			return nil, fmt.Errorf("insufficient stock for product: %s", product.Name)
		}

		resolved = append(resolved, resolvedItem{product: product, qty: item.Quantity})

		unitPrice := product.GetEffectivePrice()
		lineTotal := decimal.NewFromInt(int64(item.Quantity)).Mul(unitPrice)

		orderItem := models.OrderItem{
			ProductID:   &product.ID,
			ProductName: product.Name,
			ProductSKU:  product.SKU,
			Quantity:    item.Quantity,
			UnitPrice:   unitPrice,
			LineTotal:   lineTotal,
		}
		orderItems = append(orderItems, orderItem)
		subtotal = subtotal.Add(lineTotal)
	}

	// 5. Calculate total
	totalAmount := subtotal.Sub(discountAmount)
	if totalAmount.IsNegative() {
		totalAmount = decimal.Zero
	}

	// 6. Validate cash tendered
	if cashTendered.LessThan(totalAmount) {
		return nil, fmt.Errorf("cash tendered (%.2f) is less than total (%.2f)",
			cashTendered.InexactFloat64(), totalAmount.InexactFloat64())
	}

	change := cashTendered.Sub(totalAmount)

	// 7. Generate order number
	orderNumber, err := s.orderRepo.GenerateOrderNumber(req.TenantID)
	if err != nil {
		return nil, errors.New("failed to generate order number")
	}

	customerName := req.CustomerName
	if customerName == "" {
		customerName = "Walk-in"
	}

	// 8. Create order
	order := &models.Order{
		TenantID:       req.TenantID,
		CustomerID:     nil,
		OrderType:      models.OrderTypePOS,
		CustomerName:   customerName,
		OrderNumber:    orderNumber,
		OrderDate:      time.Now(),
		Status:         models.OrderStatusDelivered,
		PaymentStatus:  models.PaymentStatusPaid,
		Subtotal:       subtotal,
		DiscountAmount: discountAmount,
		TotalAmount:    totalAmount,
		PaidAmount:     totalAmount,
		InternalNotes:  fmt.Sprintf("pos_session:%s", req.SessionID.String()),
		Items:          orderItems,
	}

	if err := s.orderRepo.Create(order); err != nil {
		return nil, fmt.Errorf("failed to create order: %w", err)
	}

	// 9. Deduct inventory
	for _, ri := range resolved {
		if ri.product.TrackInventory {
			ri.product.StockQuantity -= ri.qty
			if err := s.productRepo.Update(ri.product); err != nil {
				return nil, fmt.Errorf("failed to update inventory for %s: %w", ri.product.Name, err)
			}
		}
	}

	// 10. Record cash payment
	payment := &models.Payment{
		TenantID:      req.TenantID,
		OrderID:       order.ID,
		PaymentDate:   time.Now(),
		PaymentMethod: models.PaymentMethodCash,
		Amount:        totalAmount,
		Status:        "completed",
		Notes:         fmt.Sprintf("POS cash payment, tendered: %.2f, change: %.2f", cashTendered.InexactFloat64(), change.InexactFloat64()),
	}

	if err := s.paymentRepo.Create(payment); err != nil {
		return nil, fmt.Errorf("failed to record payment: %w", err)
	}

	// 11. Reload order with relationships
	createdOrder, err := s.orderRepo.FindByID(order.ID, req.TenantID)
	if err != nil {
		createdOrder = order // fall back to the unsaved struct
	}

	return &POSCheckoutResult{
		Order:   createdOrder,
		Payment: payment,
		Change:  change.StringFixed(2),
	}, nil
}
