# Source Authority Source Settings Drill-Down Model

Status: Green for AMB-690 / PLOS-064 documentation/control-plane Source Settings drill-down contract; Yellow for Swift runtime model implementation, UI implementation, screenshot review, accessibility proof, validator automation, runtime eligibility computation, runtime pack consumption, production R2 promotion, privacy/legal approval, release readiness, device proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-690 / PLOS-064
Parent issue: AMB-614 / PLOS-M06

## Boundary

This artifact defines the future Source Settings drill-down model for Source Authority inspection and trust review. It specifies what a future UI/domain layer must expose one intentional step below top-level trust-light source state.

It does not implement Swift runtime behavior, change app source, implement UI, create screenshots, prove accessibility, compute runtime eligibility in the app, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, or prove runtime pack consumption.

## Existing Source Ownership

AMB-690 extends existing owners rather than creating a parallel settings surface:

- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_USER_FACING_STATE_MODEL.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_APPLICABILITY_ENVELOPE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`

## SourceSettingsDrillDown Model

The future domain/UI contract name is `SourceSettingsDrillDown`. It consumes:

- `SourceAuthorityState`
- `SourceAuthorityUserState`
- `SourceApplicabilityEnvelope`
- `SourceAuthorityNonReadyRoute`
- `ComputedRuntimeEligibility`
- source, freshness, review, risk, jurisdiction, release, rollback, contradiction, revocation, compatibility, privacy, and receipt evidence

Required fields:

| Field group | Required fields | Red stop |
|---|---|---|
| Identity | `drill_down_id`, `owning_issue`, `source_ids`, `claim_ids`, `pack_ids`, `state_snapshot_id` | Missing AMB issue, missing source/claim identity, or PLOS label-only owner. |
| Summary | `user_state`, `top_level_label`, `short_reason`, `primary_action` | Raw enum/R2/debug jargon or false Ready state. |
| Authority | `authority_state`, `computed_runtime_eligibility`, `non_ready_route`, `blocking_reasons` | Hidden review-needed/contradicted/revoked/blocked state. |
| Source trace | `source_title`, `source_type`, `source_date`, `source_hash_reference`, `source_binding_receipt_id` | Private user text or mutable alias treated as public source truth. |
| Freshness | `observed_at`, `stale_after`, `hard_expires_at`, `freshness_manifest_id`, `revocation_manifest_id` | Stale/revoked source shown as current. |
| Review | `review_requirement`, `review_state`, `review_receipt_id`, `review_reason` | Required review hidden or collapsed to a warning. |
| Risk and jurisdiction | `risk_class`, `jurisdiction_scope`, `jurisdiction_values`, `professional_boundary`, `high_risk_overlay` | Jurisdiction-sensitive or high-risk material treated as global/ordinary. |
| Release and rollback | `release_receipt_id`, `rollback_manifest_id`, `supersession_receipt_id`, `last_known_good_id` | Missing rollback or release evidence hidden from detail. |
| Privacy | `privacy_class`, `public_reference_allowed`, `local_only`, `share_allowed`, `r2_public_allowed`, `private_data_scan_status` | Private/local material made public/shareable. |
| Accessibility | `accessible_name`, `accessible_summary`, `focus_order`, `state_not_color_only` | Color/glyph-only state or missing VoiceOver meaning. |

## Disclosure Structure

Source Settings uses progressive disclosure, not a dashboard. A future surface should group the drill-down into these sections:

| Section | Purpose | Required content | Forbidden content |
|---|---|---|---|
| Source state | Explain the compressed label. | Ready, Needs source, Needs review, Older source, Source changed, Cannot use this, or Local only plus one short reason. | Raw enum, confidence score, AI badge, R2/debug jargon. |
| Why this matters | Explain action impact. | Whether a Recommended step, schedule install, or share projection is blocked or future-eligible. | False runtime eligibility claim. |
| Source trace | Show provenance. | Source id/title/type/date, source binding receipt, hash reference label, source gap if missing. | Raw private user content, secrets, write tokens, support logs. |
| Review and risk | Show review needs. | Review state, risk class, jurisdiction scope, professional boundary, high-risk overlay. | Disclaimer-only high-risk handling. |
| Freshness and changes | Show time reality. | Observed date, stale date, hard expiration, revocation, source-changed, contradiction, supersession state. | Stale/revoked source shown as current. |
| Receipt and fallback | Show recovery path. | Required receipt, rollback target, last-known-good, safe fallback or blocked route. | Mutating or claiming fallback without receipt. |
| Privacy boundary | Show what stays local. | Local-only/public reference/share allowed status and private-data scan state. | Public/R2 eligibility for private/local material. |

## State-To-Drill-Down Matrix

| User state | Required drill-down emphasis | Primary action |
|---|---|---|
| `ready` | computed evidence, freshness, receipt, privacy boundary, and rollback | Open source details |
| `needs_source` | missing source, source gap, coverage-demand, unsupported-source route | Add or review source |
| `needs_review` | review requirement, jurisdiction, risk, candidate-without-computation, route reason | Review source |
| `older_source` | observed date, stale date, hard expiration, replacement path | Refresh source |
| `source_changed` | changed source trace, supersession, before/after hash references | Review change |
| `cannot_use` | blocker, revocation/contradiction/quarantine/high-risk/incompatible reason, fallback | Use safe fallback |
| `local_only` | local privacy boundary and no public/R2/share eligibility | Keep local |

`ready` remains a future runtime proof label. AMB-690 does not make any source runtime-eligible.

## Accessibility Contract

Future UI that implements this model must provide:

- accessible name that includes source state and primary action
- accessible summary that includes blocked/review/freshness/privacy meaning
- deterministic focus order from summary to reason to recovery path
- non-color-only state indicators
- Dynamic Type wrapping and no clipped state labels
- Reduce Motion and Reduce Transparency-safe presentation
- Increase Contrast-safe state differentiation

AMB-690 defines these requirements only. It does not claim accessibility verification.

## Fixture Matrix

The machine-readable fixture matrix is `artifacts/source-atlas-factory/SOURCE_AUTHORITY_SOURCE_SETTINGS_DRILL_DOWN.json`. It covers ready, needs-source, needs-review, jurisdiction-needed, older-source, source-changed, revoked, contradicted, incompatible, high-risk-unreviewed, quarantined, local-only-private, private-data-leak, missing rollback, missing release receipt, and reviewed-but-not-computed cases.

## Red Conditions

- Source Settings hides contradiction, review-needed, jurisdiction-needed, revoked, stale-critical, high-risk-review-needed, quarantined, incompatible, or local-only/private state.
- Top-level or detail copy exposes R2, bucket, manifest, hash, canary, staging, production, source-pack, debug, or raw enum jargon.
- The drill-down displays `Ready` or runtime-eligible meaning without computed proof.
- Private user data, raw private text, goals, schedules, proof, receipts, identifiers, support bundles, diagnostics, secrets, or write tokens appear in public Source Atlas/R2 material.
- UI implementation claims are made without screenshot and accessibility proof.

## Downstream Consumers

- AMB-691 / PLOS-065 Source Authority validation gauntlet.
- AMB-624 / PLOS-M17 trust-light UI and deep drill-down.
- AMB-617 / PLOS-M10 runtime consumption proof.
- AMB-627 / PLOS-M09 Step Quality Firewall.
- AMB-625 / PLOS-M18 high-risk safety, legality, and jurisdiction.
- AMB-635 / PLOS-M26 certification gauntlets.

## Non-Claims

This artifact does not implement Swift runtime behavior, UI, screenshots, accessibility semantics, Source Settings screens, runtime eligibility computation in the app, validator/scanner automation, schema migration, pack publication, Cloudflare/R2 provisioning, live R2 writes, runtime pack consumption, production promotion, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, accessibility proof, measured performance proof, security certification, AMB-691 execution, AMB-617/M10 runtime consumption, AMB-624/M17 UI implementation, AMB-635/M26 production certification, or AMB-614 parent completion.
