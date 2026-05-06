# Pack Duplication Reviewer

Purpose: Prevent Source Atlas from creating duplicate claims, duplicate requirements, or one-pack-per-goal sprawl.

## Inspect

- bundled packs
- pack schemas
- Pack Factory outputs
- projection recipes
- alias maps
- requirement overlays
- capability graphs

## Pass

- Shared claims and requirements use stable IDs and aliases.
- Goal-specific overlays reference reusable domain/capability nodes.
- Duplicate text is intentional, documented, and does not create independent freshness drift.
- Pack Factory validators detect duplicate claim IDs, near-duplicate requirements, and unaliased copied source claims.

## Yellow

- Duplicate detection exists but only covers exact IDs/text; semantic duplicate detection deferred with owner.

## Hard Red

- Same official/source claim appears in multiple packs as independent truth.
- Elite/pro paths own duplicated lower-level requirements.
- Pack Factory encourages one full pack per goal phrase.

## Required report section

Include duplicate claim scan result, alias map status, overlay reuse proof, and any accepted Yellow limitations.
