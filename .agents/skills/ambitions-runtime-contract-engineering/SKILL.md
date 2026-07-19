---
name: ambitions-runtime-contract-engineering
description: Route scoped Ambitions runtime contracts to canonical mutation, test, receipt, replay, and rollback requirements.
---

# Ambitions runtime-contract adapter

This is a non-authoritative procedural adapter. It cannot define runtime law,
create authority, authorize work or merge, or prove product/runtime completion.

Registry entry: `docs/canon/references/skill-dependencies.json`
Allowed purpose: route scoped runtime-contract implementation through canonical
mutation and proof law.
Canonical requirement IDs: `CONST-RUNTIME-MUTATION-001`,
`LAW-RUNTIME-DURABLE-SUCCESS-001`.

Procedure:

1. Generate the bounded pack and name the exact runtime requirements and owners.
2. Define deterministic input, accepted/rejected effects, receipt, replay,
   idempotency, rollback/recovery, degraded behavior, and privacy boundary.
3. Add the smallest focused test first and observe the required failure.
4. Implement only the authorized contract and run the routed focused checks.
5. Report owners, tests, proof, unsupported claims, remaining debt, and rollback.

Use the exact dependency paths and SHA-256 values in the registry; stale bytes
fail `skill-conformance --check`.
