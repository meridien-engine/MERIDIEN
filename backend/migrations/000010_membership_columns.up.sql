BEGIN;

ALTER TABLE join_requests
  ADD COLUMN IF NOT EXISTS role        VARCHAR(20),
  ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES users(id),
  ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;

ALTER TABLE invitations
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','accepted','expired'));

COMMIT;
