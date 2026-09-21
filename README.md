# Nabuuma Hospitality Control Centre

## Mission

Nabuuma V3.5 is the operational command centre for the Nabuuma hospitality ecosystem.

It connects hospitality operations, procurement, inventory, suppliers, logistics, training, quality control, cross-border commerce, fiscalization, financial settlement, and cryptographic evidence into one controlled operational system.

The system is designed to turn hospitality activity into traceable, auditable, and economically accountable operations.

## Engineering Objective

Build and maintain a production-grade hospitality operating system.

Every implementation must prioritize:

1. Correctness
2. Data integrity
3. Tenant isolation
4. Transactional atomicity
5. Security
6. Auditability
7. Deterministic financial calculations
8. Operational usability
9. Maintainability
10. Verifiable deployment

Do not implement features merely to increase surface area.

Every feature must solve a defined operational problem.

---

## Core Architecture

The platform is built around several connected control domains.

### Hospitality Operations

- Recipes
- Products
- Ingredients
- Production
- Events
- Demand
- Training
- Quality control

### Supply Network

- Suppliers
- Procurement
- Purchase orders
- Dispatch
- Delivery
- Proof of delivery
- Inventory movement
- Replenishment

### Financial Control

- Invoices
- Accounts
- Double-entry ledger
- Escrow
- Settlement
- Reconciliation
- Tax
- Fiscalization

### Cross-Border Operations

- Customs
- HS classification
- Manifests
- Cross-border dispatch
- Customs evidence
- Delivery gates

### Cryptographic Trust

- Provenance
- Signing workflows
- Oracle evidence
- Immutable records
- Ledger continuity
- Break-glass authorization
- Forensic recovery

---

## Non-Negotiable Engineering Rules

### Financial Precision

Never use floating-point arithmetic for money.

Use integer minor units or explicitly defined PostgreSQL "NUMERIC" precision where the financial specification requires it.

Never silently round financial values.

Every monetary transformation must have an explicit precision and rounding rule.

### Atomicity

Operations that change multiple related financial, inventory, settlement, dispatch, or escrow records must execute atomically.

A failed operation must roll back the entire transaction.

Never leave partially completed business transactions.

### Tenant Isolation

Every tenant-scoped operation must enforce tenant boundaries at the database layer.

Never rely exclusively on frontend filtering.

Never expose another tenant's records through:

- API routes
- server actions
- database queries
- views
- RPC functions
- analytics
- exports
- search

### Database Security

All exposed tables must have appropriate Row Level Security.

Do not disable RLS to make an implementation easier.

Do not expose service-role credentials to browser code.

Security-definer functions must have an explicitly controlled "search_path".

Never grant anonymous users privileges that allow unauthorized mutation of operational or financial data.

### Immutable Records

Records representing financial history, provenance, audit evidence, ledger history, or cryptographic evidence must not be casually updated or deleted.

Use append-only patterns where immutability is part of the domain model.

### Exact Units

Inventory and recipe quantities must preserve their declared units.

Do not silently convert units unless the conversion is explicitly defined and authorized.

---

## Current Technology

The application uses:

- Next.js
- React
- TypeScript
- Supabase
- PostgreSQL
- Supabase SSR authentication
- GitHub-based source control

The database is the authoritative source for transactional state.

Application code must not duplicate authoritative business rules that belong in PostgreSQL.

---

## Repository Structure

```
app/
  Application routes, pages and API routes

lib/
  Domain logic, database access and operational services

supabase/
  Database schema
  Migrations
  Security policies
  Database functions
  Tests

public/
  Static assets

.github/
  Repository automation
  CI/CD
  CODEOWNERS

middleware.ts
  Request/session boundary

package.json
  Runtime dependencies and scripts

.env.example
  Required environment configuration
```

---

## Database Versioning

The database evolves through versioned migrations.

The current Nabuuma architecture includes:

- V1.3, V1.7, V1.8, V1.9
- V2.0, V2.1, V2.2, V2.3, V2.4, V2.5, V2.6, V2.7, V2.8, V2.9
- V3.0, V3.1, V3.2, V3.3, V3.4, V3.5, V3.6, V3.7, V3.8, V3.9, V3.10, V3.11

Never rewrite historical migrations that have already been deployed.

Create a new migration for changes to an existing production schema.

---

## Application Development Rules

Before changing an existing domain:

1. Inspect the current implementation.
2. Inspect its database schema.
3. Inspect related migrations.
4. Inspect existing tests.
5. Identify security boundaries.
6. Identify transaction boundaries.
7. Identify dependencies.
8. Implement the smallest complete change.
9. Test the change.
10. Verify that existing functionality remains intact.

Do not replace working architecture merely because another implementation looks simpler.

---

## AI Engineering Rules

AI agents working in this repository must behave as engineering agents, not content generators.

Before modifying code:

- understand the existing architecture;
- search for existing implementations;
- reuse established patterns;
- preserve security boundaries;
- preserve database invariants;
- avoid duplicate functionality;
- avoid speculative abstractions.

Never create:

- TODO implementations
- fake APIs
- mock production services
- placeholder business logic
- incomplete transaction paths
- hard-coded credentials
- fake financial values
- silently ignored errors

If a requirement cannot safely be implemented, stop at the boundary and report the exact blocking dependency.

Do not hide an incomplete implementation behind a successful-looking UI.

---

## Testing Requirements

Every material change should be verified at the appropriate layer.

### TypeScript

```bash
npm run typecheck
```

### Lint

```bash
npm run lint
```

### Production Build

```bash
npm run build
```

### Database

Run the relevant PostgreSQL/pgTAP tests.

### Security

Verify:

- RLS
- authorization
- tenant isolation
- privilege boundaries
- service-role restrictions

### Financial Changes

Verify:

- debit/credit conservation
- integer precision
- transaction rollback
- duplicate prevention
- reconciliation
- immutable history

---

## Deployment Discipline

Never claim a change was deployed unless the deployment actually succeeded.

Never claim a test passed unless it was executed.

Never claim GitHub was modified unless the resulting commit exists.

Never claim Supabase was modified unless the migration or operation was successfully executed.

Report failures explicitly.

---

## Environment Variables

Secrets must never be committed.

Use ".env.example" for variable names and descriptions.

Never place:

- service-role keys
- database passwords
- private signing keys
- KMS secrets
- API credentials

inside source-controlled files.

---

## Git Workflow

Use the "main" branch as the canonical production branch unless repository policy explicitly states otherwise.

Changes should be:

1. Focused
2. Reviewable
3. Tested
4. Clearly committed
5. Traceable to an operational requirement

Commit messages should describe the actual engineering change.

Do not create meaningless commits.

---

## Change Priority

When multiple changes compete for attention, prioritize:

1. Security
2. Data integrity
3. Financial correctness
4. Transaction safety
5. Tenant isolation
6. Operational reliability
7. Testing
8. Performance
9. User experience
10. Visual refinement

A visually impressive interface with an unsafe transactional core is not considered production-ready.

---

## System Philosophy

Hospitality Control Centre is not merely a dashboard.

It is a control system.

The application should make it possible to answer:

- What happened?
- Who authorized it?
- Which tenant owned it?
- Which supplier or customer was involved?
- Which physical goods moved?
- Which evidence proves the movement?
- What financial event resulted?
- Was the transaction reconciled?
- Can the historical record be trusted?

Every major workflow should move toward those answers.

---

## Definition of Done

A feature is not complete because its UI renders.

A production feature is complete only when:

- the data model is correct;
- authorization is enforced;
- tenant boundaries are enforced;
- transactions are atomic;
- business rules are deterministic;
- errors are handled;
- relevant tests pass;
- production builds succeed;
- audit requirements are satisfied;
- documentation reflects the implementation.

Do not mark incomplete work as complete.
