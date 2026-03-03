BEGIN;
DROP INDEX IF EXISTS idx_products_business_sku;
DROP INDEX IF EXISTS idx_products_business_barcode;
DROP INDEX IF EXISTS idx_products_business_slug;
COMMIT;
