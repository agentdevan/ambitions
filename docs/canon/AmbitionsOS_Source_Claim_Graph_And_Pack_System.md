# AmbitionsOS Source Claim Graph And Pack System

<!-- markdownlint-disable MD013 -->

Status: Future source truth. No source pack runtime, signed manifest runtime, hosted source service, or official requirement verification is claimed.

## Source Claim Graph

Plans depend on claim IDs, not hardcoded prose. Each source-backed claim must support: `claim_id`, `claim_type`, `value`, `unit`, `jurisdiction`, `authority_level`, `source_refs`, `source_state`, `freshness_policy`, `last_verified`, `effective_date`, optional `expires_at`, optional `superseded_by`, optional `professional_boundary`, `source_conflict_state`, and `claim_quality_state`.

## Pack Taxonomy

Archetype packs, domain packs, jurisdiction packs, regulated packs, professional-boundary packs, unsafe redirect packs, North Star packs, source-stale packs, impossible-timeline packs, crisis-support packs, privacy-sensitive packs, and unsupported-domain exploration packs.

## Pack Quality States

`draft`, `generated`, `schema-valid`, `source-attached`, `reviewed`, `official-source-backed`, `stale`, `deprecated`, `withdrawn`, `professional-review-required`, `conflict`, `unsafe-to-use`, `local-only`.

ChatGPT/agent-generated packs may be drafts only until source, schema, and review evidence exists.

## Pack Supply Chain Security

Every pack must support `pack_id`, semantic version, schema version, signed checksum, provenance, source refs, review state, rollback version, deprecation state, conflict state, stale state, no executable logic, safe import validation, corruption handling, tamper detection, signature verification, pack diff integrity, and pack manifest integrity.

Do not allow arbitrary untrusted pack execution.

## Freshness Broker And Source Operations

The smallest Ambitions-owned non-personal server surface may own only latest manifest, changed claim IDs, pack versions, pack diffs, source freshness state, generic source-update notification metadata, source-check cache, public/static pack assets, and signed manifests.

The server must not own user dreams, user goals, user plans, user receipts, user memory, user schedule, user identity, user analytics, user source dependency index, or hosted planning by default.

App manifest checks are required on app launch, before regulated goal activation, before source-sensitive commitment activation, before scheduled commitment mutation, when opening source-stale plans, during periodic review, and after generic source-update push if delivered. Push notifications are hints, not source truth.

## Pack Size Principles

Do not store large copied source documents in packs. Store source URL/reference, title, authority level, jurisdiction, last verified, freshness policy, atomic claim IDs, values, effective dates, expiration dates, source state, conflict state, user-facing citation metadata, and professional boundary flag.

Simple pack target: 5-25 KB. Normal domain pack target: 25-100 KB. Complex regulated pack target: 100-500 KB. Huge jurisdiction/legal pack: split into smaller packs.

Initial target is 100 excellent packs before thousands, then 500-1,000, then 5,000+ only with signed manifests, dedupe, validation, and optional download support.
