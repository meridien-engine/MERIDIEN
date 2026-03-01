DROP TABLE IF EXISTS pos_sessions;
ALTER TABLE orders
    DROP COLUMN IF EXISTS order_type,
    DROP COLUMN IF EXISTS customer_name,
    ALTER COLUMN customer_id SET NOT NULL;
