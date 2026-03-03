BEGIN;

CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  address TEXT,
  city VARCHAR(255),
  phone VARCHAR(50),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_stores_business_id ON stores(business_id) WHERE deleted_at IS NULL;

CREATE TRIGGER update_stores_updated_at
  BEFORE UPDATE ON stores
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

CREATE POLICY business_isolation ON stores
  USING (business_id = current_setting('app.current_business')::uuid);

ALTER TABLE stores FORCE ROW LEVEL SECURITY;

COMMIT;
