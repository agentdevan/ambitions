---
name: ambitions-architecture-tree-enforcement
description: Check canonical source-owner paths before Ambitions source creation, movement, refactor, or review.
---

# Ambitions architecture-owner adapter

This is a non-authoritative procedural adapter. Canon owns architecture law;
this file cannot create an alternate tree, authorize work, or prove source or
runtime completion.

Registry entry: `docs/canon/references/skill-dependencies.json`
Allowed purpose: enforce canonical source-owner paths without defining product
law.
Canonical requirement IDs: `ENFORCEMENT-ARCHITECTURE-OWNERSHIP-001`,
`CONST-RUNTIME-MUTATION-001`.

Procedure:

1. Generate the bounded pack and resolve the exact canonical owner requirements.
2. Compare the requested paths with live source, project configuration, and tests.
3. Stop on an unowned or competing authority; do not invent an equivalent path.
4. Record owners touched, moves/removals, shims, remaining debt, validation, and rollback.

Use the exact dependency paths and SHA-256 values in the registry; stale bytes
fail `skill-conformance --check`.
