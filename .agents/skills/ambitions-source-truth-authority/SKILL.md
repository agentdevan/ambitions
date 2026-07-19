---
name: ambitions-source-truth-authority
description: Route Ambitions repo edits and reviews to current canon, live source, and evidence ceilings.
---

# Ambitions source and truth routing adapter

This is a non-authoritative procedural adapter. It cannot define product law,
authorize work or merge, waive a gate, or prove implementation or readiness.

Registry entry: `docs/canon/references/skill-dependencies.json`
Allowed purpose: route source and review work to current canon, source evidence,
and proof boundaries.
Canonical requirement IDs: `AUTHORITY-MISSION-001`,
`CONST-PROOF-EVIDENCE-001`.

Procedure:

1. Open `docs/canon/generated/CODEX_START_HERE.md` and generate the bounded pack.
2. Read only the canonical dependencies and requirement IDs routed by the pack.
3. Inspect live source, tests, the current diff, and current proof before claims.
4. Classify unsupported claims at the narrower evidence-bounded status.
5. Report canon inputs, live evidence, conflicts, validation, non-claims, and rollback.

Use the exact dependency paths and SHA-256 values in the registry; stale bytes
fail `skill-conformance --check`.
