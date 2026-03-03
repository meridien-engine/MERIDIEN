BEGIN;

CREATE TABLE IF NOT EXISTS branches (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name        VARCHAR(255) NOT NULL,
  address     TEXT,
  city        VARCHAR(255),
  phone       VARCHAR(50),
  is_main     BOOLEAN NOT NULL DEFAULT false,
  status      VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_branches_business_id ON branches(business_id) WHERE deleted_at IS NULL;

CREATE TRIGGER update_branches_updated_at
  BEFORE UPDATE ON branches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
CREATE POLICY business_isolation ON branches
  USING (business_id = current_setting('app.current_business')::uuid);
ALTER TABLE branches FORCE ROW LEVEL SECURITY;

-- user_branch_access: no RLS (controlled via JOIN with branches)
CREATE TABLE IF NOT EXISTS user_branch_access (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  branch_id  UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  granted_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, branch_id)
);

CREATE INDEX IF NOT EXISTS idx_uba_branch_id ON user_branch_access(branch_id);
CREATE INDEX IF NOT EXISTS idx_uba_user_id   ON user_branch_access(user_id);

COMMIT;
