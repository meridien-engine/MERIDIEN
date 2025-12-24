-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    -- Category Information
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    UNIQUE(tenant_id, slug)
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,

    -- Basic Information
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100),
    barcode VARCHAR(100),

    -- Pricing
    cost_price DECIMAL(15,2) DEFAULT 0.00,
    selling_price DECIMAL(15,2) NOT NULL,
    discount_price DECIMAL(15,2),

    -- Inventory
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    low_stock_threshold INTEGER DEFAULT 10,
    track_inventory BOOLEAN NOT NULL DEFAULT true,

    -- Product Status
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    is_featured BOOLEAN DEFAULT false,

    -- Physical Properties
    weight DECIMAL(10,2),
    weight_unit VARCHAR(20) DEFAULT 'kg',

    -- Additional Information
    notes TEXT,
    custom_fields JSONB DEFAULT '{}',

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    UNIQUE(tenant_id, slug),
    UNIQUE(tenant_id, sku),
    UNIQUE(tenant_id, barcode)
);

-- Create indexes for categories
CREATE INDEX idx_categories_tenant_id ON categories(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_slug ON categories(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_parent_id ON categories(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_deleted_at ON categories(deleted_at);

-- Create indexes for products
CREATE INDEX idx_products_tenant_id ON products(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_category_id ON products(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_slug ON products(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_sku ON products(sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_barcode ON products(barcode) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_status ON products(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_stock_quantity ON products(stock_quantity) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_deleted_at ON products(deleted_at);

-- Full-text search index on products
CREATE INDEX idx_products_search ON products USING gin(
    to_tsvector('english',
        coalesce(name, '') || ' ' ||
        coalesce(description, '') || ' ' ||
        coalesce(sku, '') || ' ' ||
        coalesce(barcode, '')
    )
) WHERE deleted_at IS NULL;

-- Create triggers for updated_at
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample categories
INSERT INTO categories (tenant_id, name, slug, description)
VALUES
    (
        'bae1577c-1b95-4a0e-8eae-9a44654278b2',
        'Electronics',
        'electronics',
        'Electronic devices and accessories'
    ),
    (
        'bae1577c-1b95-4a0e-8eae-9a44654278b2',
        'Clothing',
        'clothing',
        'Apparel and fashion items'
    ),
    (
        'bae1577c-1b95-4a0e-8eae-9a44654278b2',
        'Food & Beverages',
        'food-beverages',
        'Food items and drinks'
    )
ON CONFLICT (tenant_id, slug) DO NOTHING;

-- Get category IDs for sample data
DO $$
DECLARE
    electronics_id UUID;
    clothing_id UUID;
BEGIN
    SELECT id INTO electronics_id FROM categories WHERE slug = 'electronics' AND tenant_id = 'bae1577c-1b95-4a0e-8eae-9a44654278b2' LIMIT 1;
    SELECT id INTO clothing_id FROM categories WHERE slug = 'clothing' AND tenant_id = 'bae1577c-1b95-4a0e-8eae-9a44654278b2' LIMIT 1;

    -- Insert sample products
    INSERT INTO products (tenant_id, category_id, name, slug, description, sku, barcode, cost_price, selling_price, stock_quantity, status)
    VALUES
        (
            'bae1577c-1b95-4a0e-8eae-9a44654278b2',
            electronics_id,
            'Wireless Mouse',
            'wireless-mouse',
            'Ergonomic wireless mouse with USB receiver',
            'MOUSE-001',
            '1234567890123',
            15.00,
            29.99,
            50,
            'active'
        ),
        (
            'bae1577c-1b95-4a0e-8eae-9a44654278b2',
            electronics_id,
            'USB Keyboard',
            'usb-keyboard',
            'Mechanical keyboard with backlight',
            'KEYB-001',
            '1234567890124',
            35.00,
            79.99,
            30,
            'active'
        ),
        (
            'bae1577c-1b95-4a0e-8eae-9a44654278b2',
            clothing_id,
            'Cotton T-Shirt',
            'cotton-tshirt',
            'Comfortable cotton t-shirt',
            'SHIRT-001',
            '1234567890125',
            8.00,
            19.99,
            100,
            'active'
        )
    ON CONFLICT (tenant_id, sku) DO NOTHING;
END $$;
