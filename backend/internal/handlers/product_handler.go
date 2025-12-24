package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/middleware"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/services"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
	"github.com/shopspring/decimal"
)

// ProductHandler handles product HTTP requests
type ProductHandler struct {
	productService *services.ProductService
}

// NewProductHandler creates a new product handler instance
func NewProductHandler(productService *services.ProductService) *ProductHandler {
	return &ProductHandler{
		productService: productService,
	}
}

// CreateProductRequest represents the create product request body
type CreateProductRequest struct {
	CategoryID        *string `json:"category_id"`
	Name              string  `json:"name" binding:"required"`
	Description       string  `json:"description"`
	SKU               string  `json:"sku"`
	Barcode           string  `json:"barcode"`
	CostPrice         string  `json:"cost_price"`
	SellingPrice      string  `json:"selling_price" binding:"required"`
	DiscountPrice     *string `json:"discount_price"`
	StockQuantity     int     `json:"stock_quantity"`
	LowStockThreshold int     `json:"low_stock_threshold"`
	TrackInventory    bool    `json:"track_inventory"`
	Weight            *string `json:"weight"`
	WeightUnit        string  `json:"weight_unit"`
	Notes             string  `json:"notes"`
}

// UpdateProductRequest represents the update product request body
type UpdateProductRequest struct {
	CategoryID        *string `json:"category_id"`
	Name              *string `json:"name"`
	Description       *string `json:"description"`
	SKU               *string `json:"sku"`
	Barcode           *string `json:"barcode"`
	CostPrice         *string `json:"cost_price"`
	SellingPrice      *string `json:"selling_price"`
	DiscountPrice     *string `json:"discount_price"`
	StockQuantity     *int    `json:"stock_quantity"`
	LowStockThreshold *int    `json:"low_stock_threshold"`
	TrackInventory    *bool   `json:"track_inventory"`
	Status            *string `json:"status"`
	IsFeatured        *bool   `json:"is_featured"`
	Weight            *string `json:"weight"`
	WeightUnit        *string `json:"weight_unit"`
	Notes             *string `json:"notes"`
}

// Create handles product creation
func (h *ProductHandler) Create(c *gin.Context) {
	var req CreateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	// Parse category ID
	var categoryID *uuid.UUID
	if req.CategoryID != nil && *req.CategoryID != "" {
		catID, err := uuid.Parse(*req.CategoryID)
		if err != nil {
			utils.ErrorResponse(c, http.StatusBadRequest, "Invalid category ID")
			return
		}
		categoryID = &catID
	}

	// Parse prices
	costPrice, _ := decimal.NewFromString(req.CostPrice)
	sellingPrice, err := decimal.NewFromString(req.SellingPrice)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid selling price")
		return
	}

	var discountPrice *decimal.Decimal
	if req.DiscountPrice != nil {
		dp, err := decimal.NewFromString(*req.DiscountPrice)
		if err == nil {
			discountPrice = &dp
		}
	}

	var weight *decimal.Decimal
	if req.Weight != nil {
		w, err := decimal.NewFromString(*req.Weight)
		if err == nil {
			weight = &w
		}
	}

	serviceReq := &services.CreateProductRequest{
		TenantID:          tenantID,
		CategoryID:        categoryID,
		Name:              req.Name,
		Description:       req.Description,
		SKU:               req.SKU,
		Barcode:           req.Barcode,
		CostPrice:         costPrice,
		SellingPrice:      sellingPrice,
		DiscountPrice:     discountPrice,
		StockQuantity:     req.StockQuantity,
		LowStockThreshold: req.LowStockThreshold,
		TrackInventory:    req.TrackInventory,
		Weight:            weight,
		WeightUnit:        req.WeightUnit,
		Notes:             req.Notes,
	}

	product, err := h.productService.Create(serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusCreated, "Product created successfully", product)
}

// GetByID retrieves a product by ID
func (h *ProductHandler) GetByID(c *gin.Context) {
	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
		return
	}

	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	product, err := h.productService.GetByID(productID, tenantID)
	if err != nil {
		utils.NotFoundResponse(c, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Product retrieved successfully", product)
}

// Update updates a product
func (h *ProductHandler) Update(c *gin.Context) {
	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
		return
	}

	var req UpdateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	serviceReq := &services.UpdateProductRequest{
		Name:              req.Name,
		Description:       req.Description,
		SKU:               req.SKU,
		Barcode:           req.Barcode,
		StockQuantity:     req.StockQuantity,
		LowStockThreshold: req.LowStockThreshold,
		TrackInventory:    req.TrackInventory,
		Status:            req.Status,
		IsFeatured:        req.IsFeatured,
		WeightUnit:        req.WeightUnit,
		Notes:             req.Notes,
	}

	// Parse category ID
	if req.CategoryID != nil {
		if *req.CategoryID == "" {
			nilUUID := uuid.Nil
			serviceReq.CategoryID = &nilUUID
		} else {
			catID, err := uuid.Parse(*req.CategoryID)
			if err != nil {
				utils.ErrorResponse(c, http.StatusBadRequest, "Invalid category ID")
				return
			}
			serviceReq.CategoryID = &catID
		}
	}

	// Parse prices
	if req.CostPrice != nil {
		cp, err := decimal.NewFromString(*req.CostPrice)
		if err != nil {
			utils.ErrorResponse(c, http.StatusBadRequest, "Invalid cost price")
			return
		}
		serviceReq.CostPrice = &cp
	}

	if req.SellingPrice != nil {
		sp, err := decimal.NewFromString(*req.SellingPrice)
		if err != nil {
			utils.ErrorResponse(c, http.StatusBadRequest, "Invalid selling price")
			return
		}
		serviceReq.SellingPrice = &sp
	}

	if req.DiscountPrice != nil {
		dp, err := decimal.NewFromString(*req.DiscountPrice)
		if err != nil {
			utils.ErrorResponse(c, http.StatusBadRequest, "Invalid discount price")
			return
		}
		serviceReq.DiscountPrice = &dp
	}

	if req.Weight != nil {
		w, err := decimal.NewFromString(*req.Weight)
		if err != nil {
			utils.ErrorResponse(c, http.StatusBadRequest, "Invalid weight")
			return
		}
		serviceReq.Weight = &w
	}

	product, err := h.productService.Update(productID, tenantID, serviceReq)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Product updated successfully", product)
}

// Delete deletes a product
func (h *ProductHandler) Delete(c *gin.Context) {
	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid product ID")
		return
	}

	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	if err := h.productService.Delete(productID, tenantID); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.SuccessResponse(c, http.StatusOK, "Product deleted successfully", nil)
}

// List retrieves a paginated list of products
func (h *ProductHandler) List(c *gin.Context) {
	tenantID, err := middleware.GetTenantID(c)
	if err != nil {
		utils.UnauthorizedResponse(c, "Tenant not found")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	search := c.Query("search")
	status := c.Query("status")
	lowStock := c.Query("low_stock") == "true"
	outOfStock := c.Query("out_of_stock") == "true"
	isFeatured := c.Query("is_featured") == "true"
	sortBy := c.DefaultQuery("sort_by", "created_at")
	sortOrder := c.DefaultQuery("sort_order", "DESC")

	var categoryID uuid.UUID
	if catID := c.Query("category_id"); catID != "" {
		categoryID, _ = uuid.Parse(catID)
	}

	req := &services.ListProductsRequest{
		TenantID:   tenantID,
		Search:     search,
		Status:     status,
		CategoryID: categoryID,
		LowStock:   lowStock,
		OutOfStock: outOfStock,
		IsFeatured: isFeatured,
		SortBy:     sortBy,
		SortOrder:  sortOrder,
		Page:       page,
		PerPage:    perPage,
	}

	products, total, err := h.productService.List(req)
	if err != nil {
		utils.InternalErrorResponse(c, "Failed to retrieve products")
		return
	}

	utils.PaginatedSuccessResponse(c, products, total, page, perPage)
}
