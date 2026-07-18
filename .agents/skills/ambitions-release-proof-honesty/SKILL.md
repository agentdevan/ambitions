---
name: ambitions-release-proof-honesty
description: Keep Ambitions validation and readiness language within current evidence ceilings.
---

# Ambitions proof-ceiling adapter

This is a non-authoritative procedural adapter. It cannot manufacture proof,
approve release, authorize work or merge, or upgrade a missing check.

Registry entry: `docs/canon/references/skill-dependencies.json`
Allowed purpose: keep validation and readiness claims within current evidence
ceilings.
Canonical requirement IDs: `CONST-PROOF-EVIDENCE-001`,
`CANON-DESTRUCTIVE-SUPERSESSION-001`.

Procedure:

1. Generate the bounded pack and list the exact proof obligations and claim ceiling.
2. Separate verified, failed, not run, blocked, and human/device follow-up.
3. Bind claims only to current commands, exit codes, artifacts, and approvals.
4. Remove broader readiness language when the required evidence is absent.
5. Report supported claims, explicit non-claims, next proof, and rollback.

Use the exact dependency paths and SHA-256 values in the registry; stale bytes
fail `skill-conformance --check`.
