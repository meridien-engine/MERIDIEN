-- Add audit_logs, couriers, locations and order fields for logistics features

ALTER TABLE orders
  ADD COLUMN total_order_amount numeric(15,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN shipping_fee_cost numeric(15,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN charge_shipping_on_cancel boolean NOT NULL DEFAULT false,
  ADD COLUMN version bigint NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id uuid NOT NULL,
  user_id uuid,
  order_id uuid,
  action varchar(50) NOT NULL,
  old_value jsonb,
  new_value jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS couriers (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id uuid NOT NULL,
  name varchar(255) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS locations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id uuid NOT NULL,
  city varchar(255) NOT NULL,
  zone varchar(255),
  shipping_fee numeric(15,2) NOT NULL DEFAULT 0.00,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
