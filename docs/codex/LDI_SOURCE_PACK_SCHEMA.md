# LDI Source Pack Schema

<!-- markdownlint-disable MD013 -->

Status: Protocol description only. No runtime dependency or JSON Schema package is added.

## Source Claim Shape

Required fields: `claim_id`, `claim_type`, `value`, `unit`, `jurisdiction`, `authority_level`, `source_refs`, `source_state`, `freshness_policy`, `last_verified`, `effective_date`, `source_conflict_state`, `claim_quality_state`.

Optional fields: `expires_at`, `superseded_by`, `professional_boundary`.

## Pack Manifest Shape

Required fields: `pack_id`, `version`, `schema_version`, `checksum`, `provenance`, `source_state`, `quality_state`, `freshness_policy`, `source_refs`, `review_state`, `rollback_version`, `deprecation_state`, `conflict_state`, `stale_state`, `contains_executable_logic`.

`contains_executable_logic` must be false.

## Pack Quality States

`draft`, `generated`, `schema-valid`, `source-attached`, `reviewed`, `official-source-backed`, `stale`, `deprecated`, `withdrawn`, `professional-review-required`, `conflict`, `unsafe-to-use`, `local-only`.

## Source Operation Manifest

Non-personal manifests may publish latest manifest, changed claim IDs, pack versions, signed diffs, source freshness state, generic update metadata, public/static assets, and checksums. They must not include user data.
