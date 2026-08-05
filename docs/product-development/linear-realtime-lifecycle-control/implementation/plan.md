# Implementation Plan

## Components and interfaces

Create `tools/linear-control/` as an isolated TypeScript package with a pure
core, Node CLI, Linear/GitHub adapters, Cloudflare Worker, D1 migrations, and
tests. Public interfaces and commands are those defined in approved Design.

## Data flow and persistence

Repository raw bytes and GitHub evidence compile into a desired-state manifest.
Linear GraphQL reads normalize into `CurrentWorkspace`. The planner produces a
stable mutation list. Worker ingress validates signatures and queues bounded
events. A single queue consumer records a run, applies idempotent mutations,
verifies them, snapshots exceptions/metrics, and updates D1 mappings/receipts.

## Migrations and compatibility

Start with an additive D1 schema for deliveries, runs, mappings, receipts,
exceptions, and metric snapshots. SQL migrations are ordered and repeat-safe
through Wrangler's migration ledger. Manifest and delivery envelopes carry
schema versions; unknown future versions fail closed. No app database or
product-data migration is involved.

## Repository and canon impact

No product canon file changes. Add the lifecycle initiative, controller package,
and controller lanes to Code Quality. Add a deploy/event workflow only after
local tests and dry-run validation pass. Do not reuse or modify Source Atlas
runtime authority.

## Rollout order

1. Land lifecycle documents and pure compiler/policy tests.
2. Add adapters, CLI, Worker, D1 migration, Queue/DLQ config, and integration
   tests; generate Wrangler binding types.
3. Add Code Quality and authenticated GitHub event delivery.
4. Provision D1, primary queue, DLQ, Worker secrets, migrations, and deploy.
5. Install the lifecycle Project and exact Documents/Plan tasks in Linear.
6. Run two consecutive read-only full checks; repair parser/API defects.
7. Apply baseline reconciliation and verify a second zero-drift read.
8. Enable webhook ingress, scheduled reconciliation, cycles, views/templates,
   proof gating, metrics, and autonomous repair.

## Rollback and stop conditions

`MUTATIONS_ENABLED=false` stops writes while retaining ingress/check/ledger.
Worker versions support rollback; D1 migrations are additive. A signature,
schema, authority-commit, referential-safety, exact-hash, or required API
capability failure stops the affected mutation and creates one exception. No
failure authorizes archive/cancel as a substitute for deletion.
