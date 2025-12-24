package services

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/models"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/repositories"
	"github.com/shopspring/decimal"
)

// OrderService handles business logic for orders
type OrderService struct {
	orderRepo    *repositories.OrderRepository
	customerRepo *repositories.CustomerRepository
	productRepo  *repositories.ProductRepository
	paymentRepo  *repositories.PaymentRepository
}

// NewOrderService creates a new order service instance
func NewOrderService(
	orderRepo *repositories.OrderRepository,
	customerRepo *repositories.CustomerRepository,
	productRepo *repositories.ProductRepository,
	paymentRepo *repositories.PaymentRepository,
) *OrderService {
	return &OrderService{
		orderRepo:    orderRepo,
		customerRepo: customerRepo,
		productRepo:  productRepo,
		paymentRepo:  paymentRepo,
	}
}

// CreateOrderRequest represents the request to create an order
type CreateOrderRequest struct {
	TenantID     uuid.UUID
	CustomerID   uuid.UUID
	Items        []OrderItemRequest
	TaxAmount    string
	DiscountAmount string
	ShippingAmount string
	ShippingAddress ShippingAddressRequest
	Notes        string
	InternalNotes string
}

// OrderItemRequest represents an item in the order request
type OrderItemRequest struct {
	ProductID      uuid.UUID
	Quantity       int
	DiscountAmount string
	TaxAmount      string
	Notes          string
}

// ShippingAddressRequest represents the shipping address
type ShippingAddressRequest struct {
	AddressLine1 string
	AddressLine2 string
	City         string
	State        string
	PostalCode   string
	Country      string
}

// UpdateOrderRequest represents the request to update an order
type UpdateOrderRequest struct {
	TaxAmount      *string
	DiscountAmount *string
	ShippingAmount *string
	ShippingAddress *ShippingAddressRequest
	Notes          *string
	InternalNotes  *string
}

// Create creates a new order
func (s *OrderService) Create(req *CreateOrderRequest) (*models.Order, error) {
	// Validate customer exists and is active
	customer, err := s.customerRepo.FindByID(req.CustomerID, req.TenantID)
	if err != nil {
		return nil, errors.New("customer not found")
	}

	if !customer.IsActive() {
		return nil, errors.New("customer is not active")
	}

	// Validate items
	if len(req.Items) == 0 {
		return nil, errors.New("order must have at least one item")
	}

	// Generate order number
	orderNumber, err := s.orderRepo.GenerateOrderNumber(req.TenantID)
	if err != nil {
		return nil, errors.New("failed to generate order number")
	}

	// Create order items and calculate subtotal
	orderItems := make([]models.OrderItem, 0, len(req.Items))
	subtotal := decimal.Zero

	for _, itemReq := range req.Items {
		// Validate product
		product, err := s.productRepo.FindByID(itemReq.ProductID, req.TenantID)
		if err != nil {
			return nil, errors.New("product not found: " + itemReq.ProductID.String())
		}

		if !product.IsActive() {
			return nil, errors.New("product is not active: " + product.Name)
		}

		// Check stock availability
		if product.TrackInventory && product.StockQuantity < itemReq.Quantity {
			return nil, errors.New("insufficient stock for product: " + product.Name)
		}

		// Validate quantity
		if itemReq.Quantity <= 0 {
			return nil, errors.New("quantity must be positive")
		}

		// Parse discount and tax for item
		itemDiscount := decimal.Zero
		if itemReq.DiscountAmount != "" {
			itemDiscount, err = decimal.NewFromString(itemReq.DiscountAmount)
			if err != nil {
				return nil, errors.New("invalid item discount amount")
			}
		}

		itemTax := decimal.Zero
		if itemReq.TaxAmount != "" {
			itemTax, err = decimal.NewFromString(itemReq.TaxAmount)
			if err != nil {
				return nil, errors.New("invalid item tax amount")
			}
		}

		// Create order item with product snapshot
		orderItem := models.OrderItem{
			ProductID:      &product.ID,
			ProductName:    product.Name,
			ProductSKU:     product.SKU,
			Quantity:       itemReq.Quantity,
			UnitPrice:      product.GetEffectivePrice(),
			DiscountAmount: itemDiscount,
			TaxAmount:      itemTax,
			Notes:          itemReq.Notes,
		}

		// Calculate line total
		orderItem.CalculateLineTotal()
		orderItems = append(orderItems, orderItem)

		// Add to subtotal (quantity × unit price - item discount)
		lineSubtotal := decimal.NewFromInt(int64(orderItem.Quantity)).
			Mul(orderItem.UnitPrice).
			Sub(itemDiscount)
		subtotal = subtotal.Add(lineSubtotal)
	}

	// Parse order-level amounts
	taxAmount := decimal.Zero
	if req.TaxAmount != "" {
		taxAmount, err = decimal.NewFromString(req.TaxAmount)
		if err != nil {
			return nil, errors.New("invalid tax amount")
		}
	}

	discountAmount := decimal.Zero
	if req.DiscountAmount != "" {
		discountAmount, err = decimal.NewFromString(req.DiscountAmount)
		if err != nil {
			return nil, errors.New("invalid discount amount")
		}
	}

	shippingAmount := decimal.Zero
	if req.ShippingAmount != "" {
		shippingAmount, err = decimal.NewFromString(req.ShippingAmount)
		if err != nil {
			return nil, errors.New("invalid shipping amount")
		}
	}

	// Create order
	order := &models.Order{
		TenantID:    req.TenantID,
		CustomerID:  req.CustomerID,
		OrderNumber: orderNumber,
		OrderDate:   time.Now(),
		Status:      models.OrderStatusDraft,
		PaymentStatus: models.PaymentStatusUnpaid,
		Subtotal:    subtotal,
		TaxAmount:   taxAmount,
		DiscountAmount: discountAmount,
		ShippingAmount: shippingAmount,
		ShippingAddressLine1: req.ShippingAddress.AddressLine1,
		ShippingAddressLine2: req.ShippingAddress.AddressLine2,
		ShippingCity:         req.ShippingAddress.City,
		ShippingState:        req.ShippingAddress.State,
		ShippingPostalCode:   req.ShippingAddress.PostalCode,
		ShippingCountry:      req.ShippingAddress.Country,
		Notes:         req.Notes,
		InternalNotes: req.InternalNotes,
		Items:         orderItems,
	}

	// Calculate total
	order.CalculateTotal()

	// Create order in database
	if err := s.orderRepo.Create(order); err != nil {
		return nil, errors.New("failed to create order")
	}

	// Reload with relationships
	createdOrder, err := s.orderRepo.FindByID(order.ID, req.TenantID)
	if err != nil {
		return nil, errors.New("failed to retrieve created order")
	}

	return createdOrder, nil
}

// GetByID retrieves an order by ID
func (s *OrderService) GetByID(id uuid.UUID, tenantID uuid.UUID) (*models.Order, error) {
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}
	return order, nil
}

// List retrieves a list of orders with filters
func (s *OrderService) List(tenantID uuid.UUID, filters repositories.OrderListFilters) ([]models.Order, int64, error) {
	return s.orderRepo.List(tenantID, filters)
}

// Update updates an order
func (s *OrderService) Update(id uuid.UUID, tenantID uuid.UUID, req *UpdateOrderRequest) (*models.Order, error) {
	// Get existing order
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}

	// Check if order can be edited
	if !order.CanEdit() {
		return nil, errors.New("order cannot be edited in current status")
	}

	// Update fields if provided
	if req.TaxAmount != nil {
		taxAmount, err := decimal.NewFromString(*req.TaxAmount)
		if err != nil {
			return nil, errors.New("invalid tax amount")
		}
		order.TaxAmount = taxAmount
	}

	if req.DiscountAmount != nil {
		discountAmount, err := decimal.NewFromString(*req.DiscountAmount)
		if err != nil {
			return nil, errors.New("invalid discount amount")
		}
		order.DiscountAmount = discountAmount
	}

	if req.ShippingAmount != nil {
		shippingAmount, err := decimal.NewFromString(*req.ShippingAmount)
		if err != nil {
			return nil, errors.New("invalid shipping amount")
		}
		order.ShippingAmount = shippingAmount
	}

	if req.ShippingAddress != nil {
		order.ShippingAddressLine1 = req.ShippingAddress.AddressLine1
		order.ShippingAddressLine2 = req.ShippingAddress.AddressLine2
		order.ShippingCity = req.ShippingAddress.City
		order.ShippingState = req.ShippingAddress.State
		order.ShippingPostalCode = req.ShippingAddress.PostalCode
		order.ShippingCountry = req.ShippingAddress.Country
	}

	if req.Notes != nil {
		order.Notes = *req.Notes
	}

	if req.InternalNotes != nil {
		order.InternalNotes = *req.InternalNotes
	}

	// Recalculate total
	order.CalculateTotal()

	// Save order
	if err := s.orderRepo.Update(order); err != nil {
		return nil, errors.New("failed to update order")
	}

	return order, nil
}

// Delete soft deletes an order
func (s *OrderService) Delete(id uuid.UUID, tenantID uuid.UUID) error {
	// Get order
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return errors.New("order not found")
	}

	// Only allow deleting draft orders
	if !order.IsDraft() {
		return errors.New("only draft orders can be deleted")
	}

	return s.orderRepo.Delete(id, tenantID)
}

// ConfirmOrder confirms an order (pending → confirmed)
func (s *OrderService) ConfirmOrder(id uuid.UUID, tenantID uuid.UUID) (*models.Order, error) {
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}

	// Validate status transition
	if !order.IsPending() && !order.IsDraft() {
		return nil, errors.New("only pending or draft orders can be confirmed")
	}

	// Re-check stock availability
	for _, item := range order.Items {
		if item.ProductID != nil {
			product, err := s.productRepo.FindByID(*item.ProductID, tenantID)
			if err != nil {
				continue // Product might be deleted, skip check
			}

			if product.TrackInventory && product.StockQuantity < item.Quantity {
				return nil, errors.New("insufficient stock for product: " + item.ProductName)
			}
		}
	}

	// Update status
	order.Status = models.OrderStatusConfirmed
	if err := s.orderRepo.Update(order); err != nil {
		return nil, errors.New("failed to confirm order")
	}

	return order, nil
}

// ShipOrder marks an order as shipped (processing → shipped)
func (s *OrderService) ShipOrder(id uuid.UUID, tenantID uuid.UUID) (*models.Order, error) {
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}

	// Validate status transition
	if order.Status != models.OrderStatusProcessing && order.Status != models.OrderStatusConfirmed {
		return nil, errors.New("only processing or confirmed orders can be shipped")
	}

	// Deduct inventory
	for _, item := range order.Items {
		if item.ProductID != nil {
			product, err := s.productRepo.FindByID(*item.ProductID, tenantID)
			if err != nil {
				continue // Product deleted, skip
			}

			if product.TrackInventory {
				product.StockQuantity -= item.Quantity
				if err := s.productRepo.Update(product); err != nil {
					return nil, errors.New("failed to update inventory")
				}
			}
		}
	}

	// Update status
	order.Status = models.OrderStatusShipped
	if err := s.orderRepo.Update(order); err != nil {
		return nil, errors.New("failed to ship order")
	}

	return order, nil
}

// DeliverOrder marks an order as delivered (shipped → delivered)
func (s *OrderService) DeliverOrder(id uuid.UUID, tenantID uuid.UUID) (*models.Order, error) {
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}

	// Validate status transition
	if !order.IsShipped() {
		return nil, errors.New("only shipped orders can be marked as delivered")
	}

	// Update status
	order.Status = models.OrderStatusDelivered
	if err := s.orderRepo.Update(order); err != nil {
		return nil, errors.New("failed to deliver order")
	}

	return order, nil
}

// CancelOrder cancels an order
func (s *OrderService) CancelOrder(id uuid.UUID, tenantID uuid.UUID) (*models.Order, error) {
	order, err := s.orderRepo.FindByID(id, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}

	// Check if order can be cancelled
	if !order.CanCancel() {
		return nil, errors.New("order cannot be cancelled in current status")
	}

	// Update status
	order.Status = models.OrderStatusCancelled
	if err := s.orderRepo.Update(order); err != nil {
		return nil, errors.New("failed to cancel order")
	}

	return order, nil
}

// RecordPayment records a payment for an order
func (s *OrderService) RecordPayment(orderID uuid.UUID, tenantID uuid.UUID, paymentMethod string, amount string, transactionRef, notes string) (*models.Payment, error) {
	// Get order
	order, err := s.orderRepo.FindByID(orderID, tenantID)
	if err != nil {
		return nil, errors.New("order not found")
	}

	// Parse amount
	paymentAmount, err := decimal.NewFromString(amount)
	if err != nil {
		return nil, errors.New("invalid payment amount")
	}

	if paymentAmount.LessThanOrEqual(decimal.Zero) {
		return nil, errors.New("payment amount must be positive")
	}

	// Check if payment would exceed order total
	newPaidAmount := order.PaidAmount.Add(paymentAmount)
	if newPaidAmount.GreaterThan(order.TotalAmount) {
		return nil, errors.New("payment amount exceeds order balance")
	}

	// Create payment
	payment := &models.Payment{
		TenantID:             tenantID,
		OrderID:              orderID,
		PaymentDate:          time.Now(),
		PaymentMethod:        paymentMethod,
		Amount:               paymentAmount,
		TransactionReference: transactionRef,
		Status:               "completed",
		Notes:                notes,
	}

	if err := s.paymentRepo.Create(payment); err != nil {
		return nil, errors.New("failed to record payment")
	}

	// Update order paid amount and payment status
	order.PaidAmount = newPaidAmount
	order.UpdatePaymentStatus()

	if err := s.orderRepo.Update(order); err != nil {
		return nil, errors.New("failed to update order payment status")
	}

	return payment, nil
}

// GetOrderPayments retrieves all payments for an order
func (s *OrderService) GetOrderPayments(orderID uuid.UUID, tenantID uuid.UUID) ([]models.Payment, error) {
	return s.paymentRepo.ListByOrder(orderID, tenantID)
}
