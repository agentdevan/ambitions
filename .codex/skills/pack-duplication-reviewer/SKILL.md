---
name: pack-duplication-reviewer
description: Review Source Atlas pack work for duplicate claims, duplicate requirements, and one-pack-per-goal file or object sprawl.
---

# Pack Duplication Reviewer

## Purpose

Keep Source Atlas pack growth maintainable by using aliases, shared nodes, and
composition instead of copied claims.

## Review Steps

1. Inspect pack filenames, IDs, claim IDs, requirement IDs, aliases, and
   dependency declarations.
2. Confirm goal phrase examples do not become full duplicate packs.
3. Confirm shared claims/requirements have stable IDs or aliases.

## Pass Criteria

- Shared claims are reused or aliased.
- Pack dependencies are explicit.
- Goal-specific projection lives in recipes/overlays.

## Yellow Criteria

- Pack directories do not exist yet and the batch is docs-only.

## Hard Red Criteria

- Duplicate official/current claims are copied across packs.
- One-pack-per-goal filenames or ownership appear.

## Validation

- `scripts/sa-pack-duplication-scan.sh || true`
- `scripts/sa-pack-schema-validate.sh || true`
