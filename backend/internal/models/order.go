package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

// Order represents a sales order in the system
type Order struct {
	BaseModel
	TenantID   uuid.UUID `gorm:"type:uuid;not null;index" json:"tenant_id"`
	CustomerID uuid.UUID `gorm:"type:uuid;not null;index" json:"customer_id"`

	// Order Identification
	OrderNumber string    `gorm:"type:varchar(50);not null" json:"order_number"`
	OrderDate   time.Time `gorm:"not null;index" json:"order_date"`

	// Order Status
	Status        string `gorm:"type:varchar(50);not null;default:'draft';index" json:"status"`
	PaymentStatus string `gorm:"type:varchar(50);not null;default:'unpaid';index" json:"payment_status"`

	// Financial Information
	Subtotal       decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"subtotal"`
	TaxAmount      decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"tax_amount"`
	DiscountAmount decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"discount_amount"`
	ShippingAmount decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"shipping_amount"`
	TotalAmount    decimal.Decimal `gorm:"type:decimal(15,2);not null" json:"total_amount"`
	PaidAmount     decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"paid_amount"`
	// Logistics / reconciliation fields
	TotalOrderAmount       decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"total_order_amount"`
	ShippingFeeCost        decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"shipping_fee_cost"`
	ChargeShippingOnCancel bool            `gorm:"not null;default:false" json:"charge_shipping_on_cancel"`

	// Optimistic locking
	Version int64 `gorm:"not null;default:1" json:"version"`

	// Shipping Information
	ShippingAddressLine1 string `gorm:"type:varchar(255)" json:"shipping_address_line1,omitempty"`
	ShippingAddressLine2 string `gorm:"type:varchar(255)" json:"shipping_address_line2,omitempty"`
	ShippingCity         string `gorm:"type:varchar(100)" json:"shipping_city,omitempty"`
	ShippingState        string `gorm:"type:varchar(100)" json:"shipping_state,omitempty"`
	ShippingPostalCode   string `gorm:"type:varchar(20)" json:"shipping_postal_code,omitempty"`
	ShippingCountry      string `gorm:"type:varchar(100)" json:"shipping_country,omitempty"`

	// Additional Information
	Notes         string `gorm:"type:text" json:"notes,omitempty"`
	InternalNotes string `gorm:"type:text" json:"internal_notes,omitempty"`
	CustomFields  JSONB  `gorm:"type:jsonb;default:'{}'" json:"custom_fields,omitempty"`

	// Relationships
	Tenant   *Tenant     `gorm:"foreignKey:TenantID" json:"tenant,omitempty"`
	Customer *Customer   `gorm:"foreignKey:CustomerID" json:"customer,omitempty"`
	Items    []OrderItem `gorm:"foreignKey:OrderID" json:"items,omitempty"`
	Payments []Payment   `gorm:"foreignKey:OrderID" json:"payments,omitempty"`
}

// OrderItem represents a line item in an order
type OrderItem struct {
	ID        uuid.UUID  `gorm:"type:uuid;primary_key;default:uuid_generate_v4()" json:"id"`
	OrderID   uuid.UUID  `gorm:"type:uuid;not null;index" json:"order_id"`
	ProductID *uuid.UUID `gorm:"type:uuid" json:"product_id,omitempty"`

	// Product Snapshot (preserved even if product changes/deleted)
	ProductName string `gorm:"type:varchar(255);not null" json:"product_name"`
	ProductSKU  string `gorm:"type:varchar(100)" json:"product_sku,omitempty"`

	// Quantity and Pricing
	Quantity       int             `gorm:"not null" json:"quantity"`
	UnitPrice      decimal.Decimal `gorm:"type:decimal(15,2);not null" json:"unit_price"`
	DiscountAmount decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"discount_amount"`
	TaxAmount      decimal.Decimal `gorm:"type:decimal(15,2);not null;default:0.00" json:"tax_amount"`
	LineTotal      decimal.Decimal `gorm:"type:decimal(15,2);not null" json:"line_total"`

	// Additional Information
	Notes string `gorm:"type:text" json:"notes,omitempty"`

	// Timestamps
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relationships
	Order   *Order   `gorm:"foreignKey:OrderID" json:"order,omitempty"`
	Product *Product `gorm:"foreignKey:ProductID" json:"product,omitempty"`
}

// Payment represents a payment made against an order
type Payment struct {
	BaseModel
	TenantID uuid.UUID `gorm:"type:uuid;not null;index" json:"tenant_id"`
	OrderID  uuid.UUID `gorm:"type:uuid;not null;index" json:"order_id"`

	// Payment Information
	PaymentDate   time.Time       `gorm:"not null;index" json:"payment_date"`
	PaymentMethod string          `gorm:"type:varchar(50);not null;index" json:"payment_method"`
	Amount        decimal.Decimal `gorm:"type:decimal(15,2);not null" json:"amount"`

	// Transaction Details
	TransactionReference string `gorm:"type:varchar(255)" json:"transaction_reference,omitempty"`
	Status               string `gorm:"type:varchar(50);not null;default:'completed'" json:"status"`

	// Additional Information
	Notes string `gorm:"type:text" json:"notes,omitempty"`

	// Relationships
	Tenant *Tenant `gorm:"foreignKey:TenantID" json:"tenant,omitempty"`
	Order  *Order  `gorm:"foreignKey:OrderID" json:"order,omitempty"`
}

// TableName specifies the table name for Order
func (Order) TableName() string {
	return "orders"
}

// TableName specifies the table name for OrderItem
func (OrderItem) TableName() string {
	return "order_items"
}

// TableName specifies the table name for Payment
func (Payment) TableName() string {
	return "payments"
}

// BeforeCreate hook for Order
func (o *Order) BeforeCreate(tx *gorm.DB) error {
	if o.ID == uuid.Nil {
		o.ID = uuid.New()
	}

	if o.OrderDate.IsZero() {
		o.OrderDate = time.Now()
	}

	if o.Status == "" {
		o.Status = "draft"
	}

	if o.PaymentStatus == "" {
		o.PaymentStatus = "unpaid"
	}

	if o.CustomFields == nil {
		o.CustomFields = make(JSONB)
	}

	return nil
}

// BeforeCreate hook for OrderItem
func (oi *OrderItem) BeforeCreate(tx *gorm.DB) error {
	if oi.ID == uuid.Nil {
		oi.ID = uuid.New()
	}
	return nil
}

// BeforeCreate hook for Payment
func (p *Payment) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}

	if p.PaymentDate.IsZero() {
		p.PaymentDate = time.Now()
	}

	if p.Status == "" {
		p.Status = "completed"
	}

	return nil
}

// Order Status Constants
const (
	OrderStatusDraft      = "draft"
	OrderStatusPending    = "pending"
	OrderStatusConfirmed  = "confirmed"
	OrderStatusProcessing = "processing"
	OrderStatusShipped    = "shipped"
	OrderStatusDelivered  = "delivered"
	OrderStatusCollected  = "collected"
	OrderStatusCancelled  = "cancelled"
)

// Payment Status Constants
const (
	PaymentStatusUnpaid   = "unpaid"
	PaymentStatusPartial  = "partial"
	PaymentStatusPaid     = "paid"
	PaymentStatusRefunded = "refunded"
	PaymentStatusOverdue  = "overdue"
)

// Payment Method Constants
const (
	PaymentMethodCash         = "cash"
	PaymentMethodCard         = "card"
	PaymentMethodBankTransfer = "bank_transfer"
	PaymentMethodCheck        = "check"
	PaymentMethodOther        = "other"
)

// Order Helper Methods

// IsDraft checks if order is in draft status
func (o *Order) IsDraft() bool {
	return o.Status == OrderStatusDraft
}

// IsPending checks if order is in pending status
func (o *Order) IsPending() bool {
	return o.Status == OrderStatusPending
}

// IsConfirmed checks if order is confirmed
func (o *Order) IsConfirmed() bool {
	return o.Status == OrderStatusConfirmed
}

// IsProcessing checks if order is in processing state
func (o *Order) IsProcessing() bool {
	return o.Status == OrderStatusProcessing
}

// IsShipped checks if order has been shipped
func (o *Order) IsShipped() bool {
	return o.Status == OrderStatusShipped
}

// IsDelivered checks if order has been delivered
func (o *Order) IsDelivered() bool {
	return o.Status == OrderStatusDelivered
}

// IsCancelled checks if order is cancelled
func (o *Order) IsCancelled() bool {
	return o.Status == OrderStatusCancelled
}

// CanEdit checks if order can be edited (only draft/pending)
func (o *Order) CanEdit() bool {
	return o.IsDraft() || o.IsPending()
}

// CanCancel checks if order can be cancelled (not shipped or delivered)
func (o *Order) CanCancel() bool {
	return !o.IsShipped() && !o.IsDelivered() && !o.IsCancelled()
}

// IsPaid checks if order is fully paid
func (o *Order) IsPaid() bool {
	return o.PaymentStatus == PaymentStatusPaid
}

// IsUnpaid checks if order has no payments
func (o *Order) IsUnpaid() bool {
	return o.PaymentStatus == PaymentStatusUnpaid
}

// HasPartialPayment checks if order is partially paid
func (o *Order) HasPartialPayment() bool {
	return o.PaymentStatus == PaymentStatusPartial
}

// GetBalanceAmount returns the remaining balance to be paid
func (o *Order) GetBalanceAmount() decimal.Decimal {
	return o.TotalAmount.Sub(o.PaidAmount)
}

// UpdatePaymentStatus updates the payment status based on paid amount
func (o *Order) UpdatePaymentStatus() {
	if o.PaidAmount.IsZero() {
		o.PaymentStatus = PaymentStatusUnpaid
	} else if o.PaidAmount.GreaterThanOrEqual(o.TotalAmount) {
		o.PaymentStatus = PaymentStatusPaid
	} else {
		o.PaymentStatus = PaymentStatusPartial
	}
}

// CalculateTotal calculates the total amount from components
func (o *Order) CalculateTotal() {
	// Total = Subtotal + Tax + Shipping - Discount
	o.TotalAmount = o.Subtotal.
		Add(o.TaxAmount).
		Add(o.ShippingAmount).
		Sub(o.DiscountAmount)
}

// OrderItem Helper Methods

// CalculateLineTotal calculates the line total from components
func (oi *OrderItem) CalculateLineTotal() {
	// Line Total = (Quantity × Unit Price) - Discount + Tax
	itemTotal := decimal.NewFromInt(int64(oi.Quantity)).Mul(oi.UnitPrice)
	oi.LineTotal = itemTotal.Sub(oi.DiscountAmount).Add(oi.TaxAmount)
}
