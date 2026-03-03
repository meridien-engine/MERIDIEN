ALTER TABLE locations ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_locations_deleted_at ON locations (deleted_at);
