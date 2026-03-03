DROP INDEX IF EXISTS idx_locations_deleted_at;

ALTER TABLE locations DROP COLUMN IF EXISTS deleted_at;
