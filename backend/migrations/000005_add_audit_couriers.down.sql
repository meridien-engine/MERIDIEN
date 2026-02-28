-- Rollback migration added in 000005

ALTER TABLE orders
  DROP COLUMN IF EXISTS total_order_amount,
  DROP COLUMN IF EXISTS shipping_fee_cost,
  DROP COLUMN IF EXISTS charge_shipping_on_cancel,
  DROP COLUMN IF EXISTS version;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS couriers;
DROP TABLE IF EXISTS locations;
