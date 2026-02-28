-- Revert RLS enablement and drop tenant policies on tenant-scoped tables
BEGIN;

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT table_name
    FROM information_schema.columns
    WHERE column_name = 'tenant_id' AND table_schema = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON public.%I', r.table_name);
    EXECUTE format('ALTER TABLE public.%I NO FORCE ROW LEVEL SECURITY', r.table_name);
    EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY', r.table_name);
  END LOOP;
END;
$$;

COMMIT;
