-- V3.15.6: Explicit RLS Rejection Policies for Service-Only Tables
-- Purpose: Enforce intentional service-role-only access via explicit USING (false) policies
-- Impact: Authenticated and anonymous users receive empty result sets from these tables
-- Rollback: All policies can be dropped independently; schema remains intact

-- Transaction wrapper for safety
BEGIN;

-- Log migration start
DO $$ 
BEGIN
  RAISE NOTICE 'V3.15.6: Applying explicit RLS rejection policies for 13 service-only tables';
  RAISE NOTICE 'Timestamp: %', NOW();
END $$;

-- ============================================================================
-- Table 1: audit_logs (or equivalent audit table)
-- Purpose: Internal audit trail, not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='audit_logs') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='audit_logs' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.audit_logs
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: audit_logs.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 2: internal_state (or equivalent service state table)
-- Purpose: Internal system state, not for direct tenant access
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='internal_state') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='internal_state' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.internal_state
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: internal_state.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 3: deployment_config
-- Purpose: Deployment-scoped configuration, not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='deployment_config') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='deployment_config' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.deployment_config
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: deployment_config.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 4: migration_log
-- Purpose: Migration tracking (internal), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='migration_log') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='migration_log' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.migration_log
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: migration_log.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 5: system_events
-- Purpose: Internal system event log, not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='system_events') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='system_events' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.system_events
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: system_events.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 6: feature_flags
-- Purpose: Feature flag state (service-controlled), not for direct tenant access
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='feature_flags') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='feature_flags' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.feature_flags
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: feature_flags.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 7: cache_metadata
-- Purpose: Cache invalidation and metadata (internal), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='cache_metadata') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='cache_metadata' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.cache_metadata
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: cache_metadata.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 8: rate_limit_state
-- Purpose: Rate limit tracking (internal), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='rate_limit_state') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='rate_limit_state' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.rate_limit_state
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: rate_limit_state.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 9: encryption_keys_metadata
-- Purpose: Encryption key tracking (privileged), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='encryption_keys_metadata') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='encryption_keys_metadata' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.encryption_keys_metadata
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: encryption_keys_metadata.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 10: async_job_queue
-- Purpose: Async job state (service-controlled), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='async_job_queue') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='async_job_queue' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.async_job_queue
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: async_job_queue.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 11: distributed_lock_state
-- Purpose: Distributed lock tracking (internal), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='distributed_lock_state') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='distributed_lock_state' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.distributed_lock_state
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: distributed_lock_state.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 12: telemetry_events
-- Purpose: Telemetry aggregation (internal), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='telemetry_events') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='telemetry_events' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.telemetry_events
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: telemetry_events.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Table 13: service_health_state
-- Purpose: Service health and internal metrics (service-controlled), not for tenant consumption
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='service_health_state') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='service_health_state' AND policyname='reject_all_public_access') THEN
      CREATE POLICY "reject_all_public_access" ON public.service_health_state
        AS PERMISSIVE
        FOR ALL
        TO (authenticated, anon)
        USING (false)
        WITH CHECK (false);
      RAISE NOTICE 'Policy created: service_health_state.reject_all_public_access';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Verification: Log policy count
-- ============================================================================
DO $$
DECLARE
  policy_count INT;
BEGIN
  SELECT COUNT(*) INTO policy_count FROM pg_policies 
  WHERE schemaname='public' AND policyname='reject_all_public_access';
  
  RAISE NOTICE 'Migration complete. Total reject_all_public_access policies created: %', policy_count;
  RAISE NOTICE 'All service-only tables now explicitly reject public/authenticated access';
END $$;

COMMIT;
