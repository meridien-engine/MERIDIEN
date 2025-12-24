-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    -- Basic Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),

    -- Address Information
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),

    -- Business Information
    company_name VARCHAR(255),
    tax_id VARCHAR(100),

    -- Customer Status
    customer_type VARCHAR(50) NOT NULL DEFAULT 'individual',
    status VARCHAR(50) NOT NULL DEFAULT 'active',

    -- Financial Information
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    current_balance DECIMAL(15,2) DEFAULT 0.00,

    -- Additional Information
    notes TEXT,
    custom_fields JSONB DEFAULT '{}',

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    UNIQUE(tenant_id, email)
);

-- Create indexes
CREATE INDEX idx_customers_tenant_id ON customers(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_email ON customers(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_phone ON customers(phone) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_status ON customers(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_customer_type ON customers(customer_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_deleted_at ON customers(deleted_at);

-- Full-text search index on customer names
CREATE INDEX idx_customers_search ON customers USING gin(
    to_tsvector('english',
        coalesce(first_name, '') || ' ' ||
        coalesce(last_name, '') || ' ' ||
        coalesce(company_name, '') || ' ' ||
        coalesce(email, '')
    )
) WHERE deleted_at IS NULL;

-- Create trigger for updated_at
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create sample customers for demo tenant
INSERT INTO customers (tenant_id, first_name, last_name, email, phone, customer_type, status)
VALUES
    (
        'bae1577c-1b95-4a0e-8eae-9a44654278b2',
        'John',
        'Smith',
        'john.smith@example.com',
        '+1-555-0101',
        'individual',
        'active'
    ),
    (
        'bae1577c-1b95-4a0e-8eae-9a44654278b2',
        'Sarah',
        'Johnson',
        'sarah.j@example.com',
        '+1-555-0102',
        'individual',
        'active'
    ),
    (
        'bae1577c-1b95-4a0e-8eae-9a44654278b2',
        'Michael',
        'Williams',
        'michael.w@business.com',
        '+1-555-0103',
        'business',
        'active'
    )
ON CONFLICT (tenant_id, email) DO NOTHING;
