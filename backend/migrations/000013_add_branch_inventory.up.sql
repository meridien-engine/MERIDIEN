BEGIN;

CREATE TABLE IF NOT EXISTS branch_inventory (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id         UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id           UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id          UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  stock_quantity      INT NOT NULL DEFAULT 0,
  price_override      DECIMAL(15,2),
  low_stock_threshold INT NOT NULL DEFAULT 5,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(branch_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_branch_inv_business_id ON branch_inventory(business_id);
CREATE INDEX IF NOT EXISTS idx_branch_inv_branch_id   ON branch_inventory(branch_id);
CREATE INDEX IF NOT EXISTS idx_branch_inv_product_id  ON branch_inventory(product_id);

CREATE TRIGGER update_branch_inventory_updated_at
  BEFORE UPDATE ON branch_inventory
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE branch_inventory ENABLE ROW LEVEL SECURITY;
CREATE POLICY business_isolation ON branch_inventory
  USING (business_id = current_setting('app.current_business')::uuid);
ALTER TABLE branch_inventory FORCE ROW LEVEL SECURITY;

COMMIT;
