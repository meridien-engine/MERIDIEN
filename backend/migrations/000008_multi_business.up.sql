-- Migration 000008: Multi-business model
-- Replaces single-tenant model with multi-business: users exist independently,
-- belong to businesses via user_business_memberships, tenant_id → business_id.

BEGIN;

-- =========================================================
-- a) Drop old RLS policies on all tenant_id tables
-- =========================================================
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE column_name = 'tenant_id' AND table_schema = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON public.%I', r.table_name);
    EXECUTE format('ALTER TABLE public.%I NO FORCE ROW LEVEL SECURITY', r.table_name);
    EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY', r.table_name);
  END LOOP;
END;
$$;

-- =========================================================
-- b) Remove tenant_id from users; make email globally unique
-- =========================================================
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_tenant_id_email_key;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_tenant_id_fkey;
DROP INDEX IF EXISTS idx_users_tenant_id;
ALTER TABLE users DROP COLUMN IF EXISTS tenant_id;
ALTER TABLE users ADD CONSTRAINT users_email_key UNIQUE (email);

-- =========================================================
-- c) Rename tenants → businesses
-- =========================================================
ALTER TABLE tenants RENAME TO businesses;

-- Rename primary slug index (created in migration 001)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'tenants_slug_key') THEN
    ALTER INDEX tenants_slug_key RENAME TO businesses_slug_key;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tenants_slug') THEN
    ALTER INDEX idx_tenants_slug RENAME TO idx_businesses_slug;
  END IF;
END;
$$;

-- Rename trigger if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.triggers
    WHERE trigger_name = 'update_tenants_updated_at' AND event_object_table = 'businesses'
  ) THEN
    ALTER TRIGGER update_tenants_updated_at ON businesses RENAME TO update_businesses_updated_at;
  END IF;
END;
$$;

-- =========================================================
-- d) Add new columns to businesses; rename legacy columns
-- =========================================================
ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS owner_id       UUID REFERENCES users(id),
  ADD COLUMN IF NOT EXISTS category_id    UUID,
  ADD COLUMN IF NOT EXISTS business_type  VARCHAR(20) CHECK (business_type IN ('single_branch','multi_branch')),
  ADD COLUMN IF NOT EXISTS contact_phone  VARCHAR(50),
  ADD COLUMN IF NOT EXISTS contact_email  VARCHAR(255),
  ADD COLUMN IF NOT EXISTS logo_url       VARCHAR(500),
  ADD COLUMN IF NOT EXISTS plan           VARCHAR(50) NOT NULL DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS status         VARCHAR(20) NOT NULL DEFAULT 'active'
      CHECK (status IN ('active','suspended','trial'));

-- Rename legacy columns
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='businesses' AND column_name='subscription_plan') THEN
    ALTER TABLE businesses RENAME COLUMN subscription_plan TO _legacy_plan;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='businesses' AND column_name='subscription_status') THEN
    ALTER TABLE businesses RENAME COLUMN subscription_status TO _legacy_status;
  END IF;
END;
$$;

-- =========================================================
-- e) Create business_categories and seed 10 rows
-- =========================================================
CREATE TABLE IF NOT EXISTS business_categories (
  id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name    VARCHAR(255) NOT NULL,
  name_ar VARCHAR(255),
  slug    VARCHAR(255) NOT NULL UNIQUE
);

ALTER TABLE businesses
  ADD CONSTRAINT businesses_category_id_fkey
  FOREIGN KEY (category_id) REFERENCES business_categories(id);

INSERT INTO business_categories (name, name_ar, slug) VALUES
  ('Retail',          'تجزئة',           'retail'),
  ('Food & Beverage', 'طعام ومشروبات',   'food-beverage'),
  ('Fashion',         'أزياء',            'fashion'),
  ('Electronics',     'إلكترونيات',       'electronics'),
  ('Health & Beauty', 'صحة وجمال',        'health-beauty'),
  ('Home & Garden',   'منزل وحديقة',      'home-garden'),
  ('Automotive',      'سيارات',           'automotive'),
  ('Sports',          'رياضة',            'sports'),
  ('Education',       'تعليم',            'education'),
  ('Services',        'خدمات',            'services')
ON CONFLICT (slug) DO NOTHING;

-- =========================================================
-- f) Rename tenant_id → business_id in all scoped tables
-- =========================================================

-- customers
ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_tenant_id_fkey;
ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_tenant_id_email_key;
DROP INDEX IF EXISTS idx_customers_tenant_id;
ALTER TABLE customers RENAME COLUMN tenant_id TO business_id;
ALTER TABLE customers ADD CONSTRAINT customers_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_customers_business_id ON customers(business_id) WHERE deleted_at IS NULL;

-- products
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_tenant_id_fkey;
DROP INDEX IF EXISTS idx_products_tenant_id;
ALTER TABLE products RENAME COLUMN tenant_id TO business_id;
ALTER TABLE products ADD CONSTRAINT products_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_products_business_id ON products(business_id) WHERE deleted_at IS NULL;

-- categories
ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_tenant_id_fkey;
DROP INDEX IF EXISTS idx_categories_tenant_id;
ALTER TABLE categories RENAME COLUMN tenant_id TO business_id;
ALTER TABLE categories ADD CONSTRAINT categories_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_categories_business_id ON categories(business_id) WHERE deleted_at IS NULL;

-- orders
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_tenant_id_fkey;
DROP INDEX IF EXISTS idx_orders_tenant_id;
ALTER TABLE orders RENAME COLUMN tenant_id TO business_id;
ALTER TABLE orders ADD CONSTRAINT orders_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_orders_business_id ON orders(business_id) WHERE deleted_at IS NULL;

-- payments
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_tenant_id_fkey;
DROP INDEX IF EXISTS idx_payments_tenant_id;
ALTER TABLE payments RENAME COLUMN tenant_id TO business_id;
ALTER TABLE payments ADD CONSTRAINT payments_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_payments_business_id ON payments(business_id) WHERE deleted_at IS NULL;

-- pos_sessions
ALTER TABLE pos_sessions DROP CONSTRAINT IF EXISTS pos_sessions_tenant_id_fkey;
DROP INDEX IF EXISTS idx_pos_sessions_tenant_id;
ALTER TABLE pos_sessions RENAME COLUMN tenant_id TO business_id;
ALTER TABLE pos_sessions ADD CONSTRAINT pos_sessions_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_pos_sessions_business_id ON pos_sessions(business_id) WHERE deleted_at IS NULL;

-- couriers
ALTER TABLE couriers DROP CONSTRAINT IF EXISTS couriers_tenant_id_fkey;
DROP INDEX IF EXISTS idx_couriers_tenant_id;
ALTER TABLE couriers RENAME COLUMN tenant_id TO business_id;
ALTER TABLE couriers ADD CONSTRAINT couriers_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_couriers_business_id ON couriers(business_id);

-- locations
ALTER TABLE locations DROP CONSTRAINT IF EXISTS locations_tenant_id_fkey;
DROP INDEX IF EXISTS idx_locations_tenant_id;
ALTER TABLE locations RENAME COLUMN tenant_id TO business_id;
ALTER TABLE locations ADD CONSTRAINT locations_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_locations_business_id ON locations(business_id);

-- audit_logs (optional — only rename if the column exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'audit_logs' AND column_name = 'tenant_id'
  ) THEN
    ALTER TABLE audit_logs DROP CONSTRAINT IF EXISTS audit_logs_tenant_id_fkey;
    DROP INDEX IF EXISTS idx_audit_logs_tenant_id;
    ALTER TABLE audit_logs RENAME COLUMN tenant_id TO business_id;
    ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_business_id_fkey
      FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
    CREATE INDEX IF NOT EXISTS idx_audit_logs_business_id ON audit_logs(business_id);
  END IF;
END;
$$;

-- =========================================================
-- g) Create user_business_memberships
-- =========================================================
CREATE TABLE IF NOT EXISTS user_business_memberships (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  role        VARCHAR(20) NOT NULL DEFAULT 'owner'
              CHECK (role IN ('owner','admin','manager','cashier','viewer')),
  status      VARCHAR(20) NOT NULL DEFAULT 'active'
              CHECK (status IN ('active','inactive','invited')),
  invited_by  UUID REFERENCES users(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ,
  UNIQUE(user_id, business_id)
);

CREATE INDEX IF NOT EXISTS idx_ubm_user_id     ON user_business_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_ubm_business_id ON user_business_memberships(business_id);

CREATE OR REPLACE TRIGGER update_ubm_updated_at
  BEFORE UPDATE ON user_business_memberships
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =========================================================
-- h) Migrate existing users into memberships (CROSS JOIN safe:
--    only one business exists in a fresh install)
-- =========================================================
INSERT INTO user_business_memberships
  (id, user_id, business_id, role, status, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  u.id,
  b.id,
  CASE WHEN u.role IN ('owner','admin','manager','cashier','viewer') THEN u.role ELSE 'owner' END,
  'active',
  NOW(),
  NOW()
FROM users u
CROSS JOIN businesses b
WHERE u.deleted_at IS NULL AND b.deleted_at IS NULL
ON CONFLICT (user_id, business_id) DO NOTHING;

-- Set owner_id on businesses to first owner-role member
UPDATE businesses b
SET owner_id = (
  SELECT m.user_id
  FROM user_business_memberships m
  WHERE m.business_id = b.id AND m.role = 'owner'
  ORDER BY m.created_at
  LIMIT 1
)
WHERE b.owner_id IS NULL;

-- =========================================================
-- i) Create join_requests and invitations (schema only)
-- =========================================================
CREATE TABLE IF NOT EXISTS join_requests (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  status      VARCHAR(20) NOT NULL DEFAULT 'pending'
              CHECK (status IN ('pending','approved','rejected')),
  message     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS invitations (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  email       VARCHAR(255) NOT NULL,
  role        VARCHAR(20) NOT NULL DEFAULT 'viewer'
              CHECK (role IN ('owner','admin','manager','cashier','viewer')),
  token       VARCHAR(255) NOT NULL UNIQUE,
  invited_by  UUID REFERENCES users(id),
  expires_at  TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ
);

-- =========================================================
-- j) Re-enable RLS with business_id
-- =========================================================
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE column_name = 'business_id'
      AND table_schema = 'public'
      AND table_name NOT IN (
        'user_business_memberships', 'businesses', 'invitations', 'join_requests'
      )
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', r.table_name);
    EXECUTE format(
      $policy$
      CREATE POLICY business_isolation ON public.%I
        USING (business_id = current_setting('app.current_business')::uuid)
      $policy$,
      r.table_name
    );
    EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', r.table_name);
  END LOOP;
END;
$$;

COMMIT;
