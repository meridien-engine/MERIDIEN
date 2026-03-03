-- Rollback migration 000008: restore single-tenant model

BEGIN;

-- Drop new tables
DROP TABLE IF EXISTS invitations CASCADE;
DROP TABLE IF EXISTS join_requests CASCADE;
DROP TABLE IF EXISTS user_business_memberships CASCADE;

-- Drop RLS on business_id tables
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE column_name = 'business_id'
      AND table_schema = 'public'
      AND table_name NOT IN ('businesses', 'business_categories')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS business_isolation ON public.%I', r.table_name);
    EXECUTE format('ALTER TABLE public.%I NO FORCE ROW LEVEL SECURITY', r.table_name);
    EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY', r.table_name);
  END LOOP;
END;
$$;

-- Rename business_id → tenant_id in scoped tables
ALTER TABLE locations  DROP CONSTRAINT IF EXISTS locations_business_id_fkey;
DROP INDEX IF EXISTS idx_locations_business_id;
ALTER TABLE locations  RENAME COLUMN business_id TO tenant_id;

ALTER TABLE couriers   DROP CONSTRAINT IF EXISTS couriers_business_id_fkey;
DROP INDEX IF EXISTS idx_couriers_business_id;
ALTER TABLE couriers   RENAME COLUMN business_id TO tenant_id;

ALTER TABLE payments   DROP CONSTRAINT IF EXISTS payments_business_id_fkey;
DROP INDEX IF EXISTS idx_payments_business_id;
ALTER TABLE payments   RENAME COLUMN business_id TO tenant_id;

ALTER TABLE pos_sessions DROP CONSTRAINT IF EXISTS pos_sessions_business_id_fkey;
DROP INDEX IF EXISTS idx_pos_sessions_business_id;
ALTER TABLE pos_sessions RENAME COLUMN business_id TO tenant_id;

ALTER TABLE orders     DROP CONSTRAINT IF EXISTS orders_business_id_fkey;
DROP INDEX IF EXISTS idx_orders_business_id;
ALTER TABLE orders     RENAME COLUMN business_id TO tenant_id;

ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_business_id_fkey;
DROP INDEX IF EXISTS idx_categories_business_id;
ALTER TABLE categories RENAME COLUMN business_id TO tenant_id;

ALTER TABLE products   DROP CONSTRAINT IF EXISTS products_business_id_fkey;
DROP INDEX IF EXISTS idx_products_business_id;
ALTER TABLE products   RENAME COLUMN business_id TO tenant_id;

ALTER TABLE customers  DROP CONSTRAINT IF EXISTS customers_business_id_fkey;
DROP INDEX IF EXISTS idx_customers_business_id;
ALTER TABLE customers  RENAME COLUMN business_id TO tenant_id;

-- Drop business_categories FK from businesses first
ALTER TABLE businesses DROP CONSTRAINT IF EXISTS businesses_category_id_fkey;
DROP TABLE IF EXISTS business_categories;

-- Remove new columns from businesses
ALTER TABLE businesses
  DROP COLUMN IF EXISTS owner_id,
  DROP COLUMN IF EXISTS category_id,
  DROP COLUMN IF EXISTS business_type,
  DROP COLUMN IF EXISTS contact_phone,
  DROP COLUMN IF EXISTS contact_email,
  DROP COLUMN IF EXISTS logo_url,
  DROP COLUMN IF EXISTS plan,
  DROP COLUMN IF EXISTS status;

-- Rename legacy columns back
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='businesses' AND column_name='_legacy_plan') THEN
    ALTER TABLE businesses RENAME COLUMN _legacy_plan TO subscription_plan;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='businesses' AND column_name='_legacy_status') THEN
    ALTER TABLE businesses RENAME COLUMN _legacy_status TO subscription_status;
  END IF;
END;
$$;

-- Rename businesses → tenants
ALTER TABLE businesses RENAME TO tenants;

-- Restore tenant_id in users
ALTER TABLE users ADD COLUMN IF NOT EXISTS tenant_id UUID;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_key;

-- Re-enable old RLS
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE column_name = 'tenant_id' AND table_schema = 'public'
      AND table_name != 'users'
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', r.table_name);
    EXECUTE format(
      'CREATE POLICY tenant_isolation ON public.%I USING (tenant_id = current_setting(''app.current_tenant'')::uuid)',
      r.table_name
    );
    EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', r.table_name);
  END LOOP;
END;
$$;

COMMIT;
