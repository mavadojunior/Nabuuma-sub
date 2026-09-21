# Nabuuma V3.15 Security Hardening Audit

**Status:** Production hardening complete (V3.15.3). Verification and RLS policy enforcement in progress.

**Production Instance:** `mzfkamgfvxypakfkjdfs` (PostgreSQL 17.6)

---

## Executive Summary

Nabuuma V3.15 implements a two-layer authorization boundary:
1. **Function grant layer:** SECURITY DEFINER/INVOKER and role-based EXECUTE permissions
2. **Row-level layer:** RLS policies enforce tenant isolation and data boundaries

All public SECURITY DEFINER exposure has been eliminated. Anonymous execution remains zero. The system now enforces a tightly scoped authenticated RPC surface with explicit authorization contracts.

---

## V3.15.2: Initial SECURITY DEFINER Audit

**Objective:** Remove unauthenticated and uncontrolled privileged function execution.

### Results

| Metric | Before | After |
|--------|--------|-------|
| Authenticated SECURITY DEFINER functions | 36 | 21 |
| Mutable search_path in SECURITY DEFINER | 9 | 0 |
| Anonymous SECURITY DEFINER execution | 0 | 0 ✓ |

### Functions Removed from Public Execution

**Trigger-only/Internal Functions:**
- Removed authenticated execution from functions designed for internal triggers only
- These functions contained no tenant context and could not safely execute as public RPCs

**Tenant-Mutation Functions (Caller-Supplied IDs):**
Revoked public execution from functions that could expose or mutate another tenant's data:
- `v19_fefo_batch_candidates` — batch candidate selection (tenant-aware filtering)
- `v20_verify_tenant_route` — routing verification (cross-tenant exposure risk)
- `execute_v19_stock_transfer` — stock transfer execution (financial mutation)
- `nos_append_audit` — audit log mutation (could bypass tenant boundary)
- `v33_record_signature` — cryptographic signature recording (financial integrity)
- `v34_consume_break_glass_authorization` — emergency access (privilege escalation risk)

**Direct Transaction Balance Verification:**
- Removed direct public execution of `v20_assert_transaction_balanced`
- Reason: Transaction balance is a privileged verification; callers must route through higher-level functions that enforce tenant context

### Hardening Applied

**Hash and Helper Functions:**
All previously flagged hash/helper functions now use explicit schema qualification:
```sql
SET search_path = '';
SELECT public.function_name(args);
```

This prevents unintended function shadowing and ensures only the explicitly qualified version executes.

**Authorization Helper Functions (Preserved):**
- `is_member(uuid)` — RLS helper: checks if user is member of organization
- `has_role(uuid, text)` — RLS helper: checks if user has specific role

These functions are preserved because:
1. Supabase documents SECURITY DEFINER authorization helpers as a standard RLS pattern
2. They are used by RLS policies themselves, not called directly by application code
3. They perform read-only authorization checks without data mutation
4. Removing them would break RLS policy evaluation

---

## V3.15.3: Authenticated SECURITY DEFINER Elimination

**Objective:** Convert remaining authenticated SECURITY DEFINER functions to SECURITY INVOKER or isolate privileged helpers.

### Results

| Metric | Before | After |
|--------|--------|-------|
| Authenticated SECURITY DEFINER functions | 21 | 0 ✓ |
| Anonymous SECURITY DEFINER execution | 0 | 0 ✓ |
| Public tables without RLS | 2 | 2 (hardened) |

### Converted Functions

All 21 remaining authenticated SECURITY DEFINER functions were reviewed:

**Converted to SECURITY INVOKER (14):**
- Functions with explicit tenant/role checks requiring caller identity
- No privilege escalation needed; caller context is sufficient
- Authorization now delegated to RLS policies and function-level checks

**Moved Out of Public Schema (7):**
- Privileged helper functions that should not be directly callable
- Moved to `_internal` or service-role-only schema
- Invoked only by orchestration functions that enforce authorization

**Preserved (0):**
- No authenticated SECURITY DEFINER functions remain in public schema

### RLS Enforcement on Public Tables

Two tables require RLS for proper data isolation:

#### `_nabuuma_deployment_bootstrap`
- **Purpose:** Deployment configuration and initialization
- **RLS Status:** Enabled + FORCE enabled
- **Access Policy:** Service-role only (no SELECT for authenticated/anon via Data API)
- **Rationale:** Bootstrap data is deployment-scoped; tenant isolation is enforced at deployment boundary, not row level

#### `stock_transfer_batch_lines`
- **Purpose:** Line items for stock transfer batches
- **RLS Status:** Enabled
- **Access Policy:** Authenticated users receive tenant-scoped SELECT only
- **Write Policy:** Writes remain trusted-executor controlled (service role or privileged function)
- **Rationale:** Read access can be row-scoped; writes require business logic validation

---

## Remaining Work: V3.15.6

**Objective:** Implement explicit rejection policies for intentional service-only tables.

### 13 Intentional RLS-Without-Policy Tables

These tables are intentionally configured with RLS enabled but no user-facing policies:
- They are accessed only by service-role functions or administrative operations
- They contain internal state or audit data not meant for tenant consumption

**Policy Pattern (to be applied):**
```sql
CREATE POLICY "reject_all" ON <table>
AS (permissive)
FOR ALL
TO (authenticated, anon)
USING (false)
WITH CHECK (false);
```

This explicitly documents the intent: "RLS is enabled; public access is intentionally rejected."

### Verification Strategy

**pgTAP Tests (V3.15.6):**
1. Confirm rejection policies exist on all 13 tables
2. Verify `SELECT` as authenticated role returns 0 rows
3. Verify `INSERT/UPDATE/DELETE` as authenticated role is blocked
4. Confirm service role can still access (if required by application logic)

**Execution Verification:**
- Migration result captured in GitHub Actions summary
- pgTAP test output uploaded as artifact
- Only marked deployed after artifact exists

---

## Authorization Model Summary

### Two-Layer Boundary

```
Layer 1: Function Grants
├─ SECURITY INVOKER: Caller identity used; authorization via RLS
├─ SECURITY DEFINER (RLS helpers only): No data access; authorization checks only
└─ Service-role functions: Trusted executors for privileged operations

Layer 2: Row-Level Security
├─ Public tables: RLS enforces tenant isolation
├─ Service-only tables: Explicit rejection policies
└─ Audit tables: Policy-free (no user access expected)
```

### Execution Path

**Authenticated User Request:**
```
Client → Public RPC (SECURITY INVOKER)
         → Function checks caller role via is_member() / has_role()
         → Queries tenant-scoped table (RLS applied)
         → Returns only caller's tenant data
```

**Privileged Operation:**
```
Application Server → Service-Role Function (SECURITY DEFINER)
                    → Performs cross-tenant operation (internal state)
                    → RLS bypassed (service role is administrator)
                    → Audit trail recorded
```

---

## Verification Checklist

- [x] V3.15.2: SECURITY DEFINER audit completed (36 → 21 functions)
- [x] V3.15.2: Mutable search_path hardened (9 → 0 functions)
- [x] V3.15.3: All authenticated SECURITY DEFINER eliminated (21 → 0)
- [x] V3.15.3: Public tables enforce RLS
- [ ] V3.15.6: Explicit rejection policies applied (13 tables)
- [ ] V3.15.6: pgTAP verification tests pass
- [ ] V3.15.6: Migration artifact uploaded to GitHub Actions

---

## References

- **Supabase Security Docs:** [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- **Supabase SECURITY DEFINER Pattern:** [Creating Authorization Policies](https://supabase.com/docs/guides/auth/row-level-security#using-security-definer-functions)
- **PostgreSQL SECURITY DEFINER:** [Function Security](https://www.postgresql.org/docs/current/sql-createfunction.html#SQL-CREATEFUNCTION-SECURITY)

---

## Deployment Notes

**PostgreSQL Version:** 17.6 (production-matched)

**Migration Framework:** Supabase CLI with pgTAP integration

**Rollback:** All migrations are reversible. Rejection policies can be dropped; SECURITY INVOKER conversions can be reverted to SECURITY DEFINER if needed.

**Audit Trail:** All changes logged via Supabase audit extensions and GitHub Actions workflow artifacts.
