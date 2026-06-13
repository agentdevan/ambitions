# Source Authority Applicability Envelope

Status: Green for AMB-688 / PLOS-062 documentation/control-plane applicability-envelope contract; Yellow for Swift runtime model implementation, validator automation, runtime eligibility computation, runtime pack consumption, UI implementation, production R2 promotion, privacy/legal approval, release readiness, accessibility proof, device proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-688 / PLOS-062
Parent issue: AMB-614 / PLOS-M06

## Boundary

This artifact defines the `SourceApplicabilityEnvelope` contract that Source Authority must consume before any Source Atlas source, claim, requirement, seed, pack, manifest, or future R2 object can be considered for runtime eligibility.

It does not implement Swift runtime behavior, compute runtime eligibility in the app, change app source, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, implement UI, or prove runtime pack consumption.

## Existing Source Ownership

AMB-688 extends existing owners rather than creating a parallel Source Atlas system:

- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_USER_FACING_STATE_MODEL.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RISK_JURISDICTION_CLASSIFICATION.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RELEASE_RECEIPT_REQUIREMENTS.md`
- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md`

## SourceApplicabilityEnvelope Model

`SourceApplicabilityEnvelope` is the structured input boundary for `ComputedRuntimeEligibility`. It must be computed from evidence, not written as a free-form eligibility claim.

Required fields:

| Field group | Required fields | Red stop |
|---|---|---|
| Identity | `envelope_id`, `schema_version`, `owning_issue`, `artifact_family`, `artifact_ids`, `source_authority_state`, `user_state` | Missing AMB issue, missing artifact id, or PLOS label-only owner. |
| Source binding | `source_ids`, `claim_ids`, `requirement_ids`, `source_hashes`, `normalized_source_hashes`, `pack_payload_hashes`, `manifest_hashes` | Missing source binding, hash mismatch, mutable alias only, or private/local material treated as public source truth. |
| Temporal | `effective_at`, `observed_at`, `reviewed_at`, `stale_after`, `hard_expires_at`, `freshness_window_id`, `offline_grace_until` | Missing dates for runtime-affecting source, stale source claimed current, or hard-expired source allowed. |
| Jurisdiction | `jurisdiction_scope`, `jurisdiction_values`, `age_school_context`, `institution_context`, `professional_context`, `travel_context` | Jurisdiction-sensitive material marked globally applicable or unresolved jurisdiction allowed. |
| Risk and review | `risk_class`, `review_requirement`, `review_state`, `review_receipt_id`, `professional_boundary`, `high_risk_overlay` | High-risk, unknown-risk, or jurisdiction-sensitive material lacks approved review. |
| Manifest controls | `compatibility_manifest_id`, `freshness_manifest_id`, `revocation_manifest_id`, `rollback_manifest_id`, `release_receipt_id`, `signature_or_integrity_state` | Missing compatibility, freshness, revocation, rollback, release receipt, or integrity evidence. |
| Privacy boundary | `privacy_class`, `public_reference_allowed`, `local_only`, `share_allowed`, `r2_public_allowed`, `private_data_scan_status` | Private user data, secrets, identifiers, or local-only material allowed into R2/public Source Atlas. |
| Allowed actions | `recommended_step_allowed`, `schedule_install_allowed`, `share_projection_allowed`, `source_settings_display_allowed`, `local_personalization_allowed` | Runtime action allowed while eligibility is blocked, not eligible, stale, revoked, contradicted, review-needed, jurisdiction-needed, or local-only-private. |
| Blocking reasons | `blocking_reasons`, `required_next_route`, `no_claim_boundary` | Empty blocking reasons for non-eligible state or missing no-claim boundary. |

## Eligibility Linkage

`ComputedRuntimeEligibility` consumes the envelope and returns one of:

- `eligible`
- `candidate`
- `not_eligible`
- `blocked`
- `not_public_eligible`

The envelope may produce `candidate` only when all source, temporal, jurisdiction, risk/review, manifest, release, privacy, and compatibility fields are present but future runtime owners still need implementation proof.

The envelope may produce `eligible` only when a future runtime implementation proves all evidence gates and the active phase owns runtime consumption. AMB-688 never marks a pack runtime-consumable.

## Applicability Rules

| Condition | Required envelope result | User state | Route |
|---|---|---|---|
| Source binding missing | `not_eligible` | `needs_source` | source-needed |
| Review missing | `not_eligible` | `needs_review` | review-needed |
| Jurisdiction unresolved | `not_eligible` | `needs_review` | jurisdiction-needed |
| Freshness stale | `not_eligible` | `older_source` | source-needed or review-needed |
| Hard expired or stale-critical | `blocked` | `cannot_use` | blocked until refreshed |
| Source changed | `not_eligible` | `source_changed` | review source change |
| Contradicted | `blocked` | `cannot_use` | contradiction review |
| Revoked | `blocked` | `cannot_use` | revoke, quarantine, or rollback |
| Incompatible | `blocked` | `cannot_use` | compatibility fallback |
| High-risk unreviewed | `blocked` | `cannot_use` | high-risk review or professional boundary |
| Private/local-only | `not_public_eligible` | `local_only` | local-only |
| All evidence gates present but runtime not implemented | `candidate` | `needs_review` | future runtime proof |
| All evidence gates pass in future owning runtime phase | `eligible` | `ready` | future runtime consumption only |

## Runtime Action Matrix

| Computed state | Recommended step | Schedule install | Share projection | Source Settings display | Local personalization |
|---|---|---|---|---|---|
| `eligible` | allowed only after future runtime proof | allowed only after future runtime proof | allowed only if privacy/share boundary passes | allowed | allowed when local privacy passes |
| `candidate` | no | no | no | allowed | local-only if safe |
| `not_eligible` | no | no | no | allowed | local-only if safe |
| `blocked` | no | no | no | allowed with blocker detail | no unless future safe fallback proves it |
| `not_public_eligible` | no public/source-backed action | no public/source-backed action | no | allowed with privacy boundary | local-only if user-owned and safe |

## Fixture Matrix

The machine-readable fixture matrix is `artifacts/source-atlas-factory/SOURCE_AUTHORITY_APPLICABILITY_ENVELOPE.json`. It covers ready candidate, missing source, review-needed, jurisdiction-needed, stale, hard-expired, source-changed, contradicted, revoked, incompatible, high-risk reviewed, high-risk unreviewed, local-only-private, private-data leak, missing rollback, missing release receipt, and unsupported schema cases.

## Red Conditions

- `runtime_eligible` is manually asserted instead of computed from envelope evidence.
- Stale, revoked, contradicted, incompatible, review-needed, jurisdiction-needed, high-risk-under-reviewed, local-only-private, private-data-contaminated, or rollback-missing material can drive Steps.
- Jurisdiction-sensitive recommendations are treated as globally applicable.
- High-risk material lacks risk, jurisdiction, review, source authority, professional-boundary, or freshness metadata.
- Envelope fields contain private user data, private source-needed text, goals, schedules, proof, receipts, local learning, identifiers, secrets, write tokens, support bundles, diagnostics, or raw private text.
- Fixture/test/generated/preview assets are treated as production runtime proof.

## Downstream Consumers

- AMB-689 / PLOS-063 routing rules.
- AMB-690 / PLOS-064 Source Settings drill-down model.
- AMB-691 / PLOS-065 validation gauntlet.
- AMB-617 / PLOS-M10 runtime consumption proof.
- AMB-627 / PLOS-M09 Step Quality Firewall.
- AMB-625 / PLOS-M18 high-risk safety, legality, and jurisdiction.
- AMB-635 / PLOS-M26 certification gauntlets.

## Non-Claims

This artifact does not implement Swift runtime behavior, compute runtime eligibility in the app, change app source, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, implement UI, claim runtime pack consumption, claim production readiness, claim privacy/legal approval, claim release readiness, claim TestFlight readiness, claim App Store readiness, claim device/accessibility/performance proof, execute AMB-689, execute AMB-617/M10, execute AMB-627/M09, execute AMB-625/M18, execute AMB-635/M26, or close AMB-614/PLOS-M06.
