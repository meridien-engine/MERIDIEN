-- 1. Add order_type and customer_name to existing orders table
ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS order_type    VARCHAR(20) NOT NULL DEFAULT 'online',
    ADD COLUMN IF NOT EXISTS customer_name VARCHAR(255),
    ALTER COLUMN customer_id DROP NOT NULL;

-- 2. Create pos_sessions table
CREATE TABLE IF NOT EXISTS pos_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    cashier_id      UUID NOT NULL REFERENCES users(id),
    status          VARCHAR(20) NOT NULL DEFAULT 'open',
    opening_float   DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    closing_cash    DECIMAL(15,2),
    expected_cash   DECIMAL(15,2),
    cash_difference DECIMAL(15,2),
    opened_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at       TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    CONSTRAINT chk_pos_status CHECK (status IN ('open', 'closed'))
);

CREATE INDEX idx_pos_sessions_tenant_id  ON pos_sessions(tenant_id)  WHERE deleted_at IS NULL;
CREATE INDEX idx_pos_sessions_cashier_id ON pos_sessions(cashier_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pos_sessions_status     ON pos_sessions(status)     WHERE deleted_at IS NULL;

CREATE OR REPLACE TRIGGER update_pos_sessions_updated_at
    BEFORE UPDATE ON pos_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE pos_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON pos_sessions
    USING (tenant_id = current_setting('app.current_tenant')::uuid);
ALTER TABLE pos_sessions FORCE ROW LEVEL SECURITY;
