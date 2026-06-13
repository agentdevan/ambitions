# Source Authority User-Facing State Model

Status: Green for AMB-687 / PLOS-061 documentation/control-plane compressed-state contract; Yellow for Swift runtime model implementation, UI implementation, screenshot review, accessibility proof, validator automation, runtime eligibility computation, runtime pack consumption, production R2 promotion, privacy/legal approval, release readiness, device proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-687 / PLOS-061
Parent issue: AMB-614 / PLOS-M06

## Boundary

This artifact defines the compressed user-facing state model for Source Authority. It maps the AMB-686 `SourceAuthorityState` internal state machine into a small set of trust-light states that can appear in future top-level UI, receipt strips, and Source Settings drill-downs.

It does not implement Swift runtime behavior, edit UI, change app source, compute runtime eligibility in the app, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, or prove runtime pack consumption.

## Existing Source Ownership

AMB-687 extends existing owners rather than creating a parallel UI or source-authority system:

- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.json`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Components/LoadingDegradedStatePrimitives.swift`
- `Native/Ambitions/Features/You/YouRootSurface.swift`

## Compression Contract

The future Swift/domain model name is `SourceAuthorityUserState`. It compresses AMB-686 internal states into seven user-facing states:

| User-facing state | Top-level label | Allowed top-level meaning | Drill-down route |
|---|---|---|---|
| `ready` | Ready | Source authority is current enough for the scoped action, subject to future computed eligibility proof. | Show source, freshness, review, receipt, risk, jurisdiction, and rollback path. |
| `needs_source` | Needs source | Ambitions does not have enough source backing for this path. | Open the missing source or coverage gap. |
| `needs_review` | Needs review | A source, jurisdiction, risk, freshness, or review condition must be checked before planning or sharing. | Open Source Settings review details. |
| `older_source` | Older source | Source authority is stale or may be stale; current use is not Green. | Open freshness, expiration, and replacement details. |
| `source_changed` | Source changed | A source or claim changed since last safe use. | Open changed-source trace and review path. |
| `cannot_use` | Cannot use this | Source authority is blocked, revoked, contradicted, incompatible, high-risk unreviewed, or quarantined. | Open blocker reason and safe fallback. |
| `local_only` | Local only | This material is user-owned/private and cannot become public Source Atlas authority. | Open local privacy and receipt boundary. |

Top-level UI may use a shorter label only if the accessible name preserves the state and the drill-down remains one intentional step away.

## Internal State Mapping

| AMB-686 `SourceAuthorityState` | User state | Top-level action posture | Runtime eligibility posture |
|---|---|---|---|
| `unknown` | `needs_source` | do not recommend from this source | `not_eligible` |
| `source_needed` | `needs_source` | ask for source or coverage | `not_eligible` |
| `source_bound_draft` | `needs_review` | review before use | `not_eligible` |
| `review_needed` | `needs_review` | review before use | `not_eligible` |
| `reviewed_current` | `needs_review` | compute before use | `candidate_only` |
| `eligible_current` | `ready` | can be considered by future runtime only after computed proof | `eligible_when_computed` |
| `stale` | `older_source` | no current recommendation | `not_eligible` |
| `stale_critical` | `cannot_use` | block | `blocked` |
| `source_changed` | `source_changed` | review changed source | `not_eligible` |
| `contradicted` | `cannot_use` | block | `blocked` |
| `revoked` | `cannot_use` | block and quarantine | `blocked` |
| `incompatible` | `cannot_use` | block and fallback | `blocked` |
| `jurisdiction_needed` | `needs_review` | resolve local rules | `not_eligible` |
| `high_risk_review_needed` | `cannot_use` | block until review | `blocked` |
| `quarantined` | `cannot_use` | block and quarantine | `blocked` |
| `local_only_private` | `local_only` | keep local/private | `not_public_eligible` |

`ready` is not a synonym for `runtime_eligible`. It may be shown only when the underlying computed state is `eligible_current` and future runtime code has exact evidence. In AMB-687 scope, `ready` is a contract label, not runtime proof.

## Trust-Light Copy Rules

Allowed top-level copy:

- Ready
- Needs source
- Needs review
- Older source
- Source changed
- Cannot use this
- Local only

Allowed secondary lines:

- "Open Source Settings"
- "Open source details"
- "Review before planning"
- "Fresh source needed"
- "This stays local"
- "Ambitions will not act on this source"

Forbidden top-level copy:

- raw enum values such as `eligible_current`, `stale_critical`, `high_risk_review_needed`, or `local_only_private`
- R2, bucket, manifest, compatibility manifest, hash, checksum, signer, canary, staging, production, or source-pack jargon
- confidence scores, AI badges, "always current", "approved", "privacy approved", "safe", or release-readiness wording without exact proof
- generic error text such as "Unavailable" when the state is blocked, revoked, contradicted, or needs review

## Disclosure Layers

| Layer | Required behavior |
|---|---|
| Top-level decision line | Use only the compressed label and one short human reason when needed. |
| Trust strip | May show compressed source state, freshness, receipt, and privacy boundary using existing trust receipt primitives. |
| Drill-down | Must expose the internal state, source, freshness, review, risk, jurisdiction, receipt, rollback, and blocker details without becoming the default UI. |
| Source Settings | Future AMB-690 must use this model for the Source Settings drill-down and may add deeper grouping, not new top-level states. |
| Accessibility | Accessible names must include state, action posture, and review path; color and glyphs cannot be the only state carriers. |

## Fixture Matrix

The machine-readable fixture matrix is `artifacts/source-atlas-factory/SOURCE_AUTHORITY_USER_FACING_STATE_MODEL.json`. It covers ready, needs-source, needs-review, older-source, source-changed, cannot-use, local-only, high-risk reviewed, high-risk unreviewed, stale, revoked, contradicted, jurisdiction-needed, incompatible, quarantined, and reviewed-but-not-computed cases.

## Red Conditions

- User-facing source states expose raw internal enum, R2, manifest, hash, canary, staging, production, or debug jargon.
- `ready` is displayed when computed runtime eligibility is missing, stale, revoked, contradicted, incompatible, high-risk under-specified, jurisdiction-needed, review-needed, quarantined, local-only-private, or manually asserted.
- Stale, revoked, contradicted, incompatible, review-needed, jurisdiction-needed, high-risk-review-needed, quarantined, or local-only-private states can drive Steps.
- A Source Settings drill-down hides blocked, revoked, contradicted, high-risk, jurisdiction, privacy, receipt, or rollback state.
- Private user data, user goals, schedules, proof, receipts, local learning, raw private text, identifiers, secrets, or write tokens appear in R2/public Source Atlas material.

## Downstream Consumers

- AMB-688 / PLOS-062 source applicability envelope.
- AMB-689 / PLOS-063 non-ready routing rules.
- AMB-690 / PLOS-064 Source Settings drill-down model.
- AMB-691 / PLOS-065 validation gauntlet.
- AMB-624 / PLOS-M17 trust-light UI and deep drill-down.
- AMB-617 / PLOS-M10 runtime consumption proof.
- AMB-635 / PLOS-M26 certification gauntlets.

## Non-Claims

This artifact does not implement Swift runtime behavior, UI, accessibility semantics, screenshots, Source Settings screens, runtime eligibility computation in the app, validator/scanner automation, schema migration, pack publication, Cloudflare/R2 provisioning, live R2 writes, runtime pack consumption, production promotion, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, accessibility proof, measured performance proof, security certification, AMB-688 execution, AMB-617/M10 runtime consumption, AMB-624/M17 UI implementation, AMB-635/M26 production certification, or AMB-614 parent completion.
