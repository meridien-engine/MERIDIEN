BEGIN;

-- Drop the old constraints (named with tenant_id from before the rename)
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_tenant_id_sku_key;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_tenant_id_barcode_key;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_tenant_id_slug_key;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_business_id_sku_key;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_business_id_barcode_key;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_business_id_slug_key;

-- Partial unique indexes: only enforce uniqueness for non-empty values on active rows
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_business_sku
  ON products(business_id, sku)
  WHERE sku IS NOT NULL AND sku != '' AND deleted_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_products_business_barcode
  ON products(business_id, barcode)
  WHERE barcode IS NOT NULL AND barcode != '' AND deleted_at IS NULL;

-- Slug must always be unique per business (it's always set)
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_business_slug
  ON products(business_id, slug)
  WHERE deleted_at IS NULL;

COMMIT;
