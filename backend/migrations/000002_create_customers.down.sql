-- Drop trigger
DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;

-- Drop indexes
DROP INDEX IF EXISTS idx_customers_search;
DROP INDEX IF EXISTS idx_customers_deleted_at;
DROP INDEX IF EXISTS idx_customers_customer_type;
DROP INDEX IF EXISTS idx_customers_status;
DROP INDEX IF EXISTS idx_customers_phone;
DROP INDEX IF EXISTS idx_customers_email;
DROP INDEX IF EXISTS idx_customers_tenant_id;

-- Drop table
DROP TABLE IF EXISTS customers;
