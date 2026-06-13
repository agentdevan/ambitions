# Source Authority Internal State Machine

Status: Green for AMB-686 / PLOS-060 documentation/control-plane state-machine scope; Yellow for Swift runtime model implementation, validator automation, runtime eligibility computation, runtime pack consumption, production R2 promotion, privacy/legal approval, release readiness, accessibility proof, device proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-686 / PLOS-060
Parent issue: AMB-614 / PLOS-M06

## Boundary

This artifact defines the internal Source Authority state machine that later M06 children and runtime phases must consume before any Source Atlas pack, claim, seed, requirement, manifest, or R2 object can drive a recommendation or schedule install.

It does not implement Swift runtime behavior, compute runtime eligibility in the app, change app source, migrate schemas, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, or prove runtime pack consumption.

## Existing Source Ownership

AMB-686 extends existing owners rather than creating a parallel Source Atlas system:

- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/KnowledgeBoundaryModels.swift`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_PACK_SEED_FOUNDRY_PIPELINE.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_CONTRADICTION_FRESHNESS_SCAN.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RISK_JURISDICTION_CLASSIFICATION.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RELEASE_RECEIPT_REQUIREMENTS.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_NO_HARDCODED_STEPS_ENFORCEMENT.md`
- `artifacts/source-atlas-factory/r2/R2_STAGING_ACTIVATION_REPORT.md`
- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`

## SourceAuthorityState Enum Contract

The internal enum is named `SourceAuthorityState`. These cases are the only AMB-686 states:

| State | Runtime eligibility | User-facing compression owner | Required next route |
|---|---|---|---|
| `unknown` | `not_eligible` | AMB-687 | source-needed or review-needed |
| `source_needed` | `not_eligible` | AMB-687 | request/source-needed flow |
| `source_bound_draft` | `not_eligible` | AMB-687 | foundry review |
| `review_needed` | `not_eligible` | AMB-687 | editorial/risk/jurisdiction review |
| `reviewed_current` | `candidate` only | AMB-687 | compute eligibility from all evidence gates |
| `eligible_current` | `eligible` only when computed proof passes | AMB-687 | may feed later runtime only after M10 proves consumption |
| `stale` | `not_eligible` for current recommendations | AMB-687 | degraded/source-needed/review-needed |
| `stale_critical` | `blocked` | AMB-687 | block or professional-boundary |
| `source_changed` | `not_eligible` | AMB-687 | review-needed or supersession |
| `contradicted` | `blocked` | AMB-687 | contradiction review/quarantine |
| `revoked` | `blocked` | AMB-687 | revocation/quarantine/rollback |
| `incompatible` | `blocked` | AMB-687 | compatibility fallback/quarantine |
| `jurisdiction_needed` | `not_eligible` | AMB-687 | jurisdiction review |
| `high_risk_review_needed` | `blocked` | AMB-687 | high-risk review/professional-boundary |
| `quarantined` | `blocked` | AMB-687 | quarantine/rollback |
| `local_only_private` | `not_public_eligible` | AMB-687 | local-only user-owned lane |

`eligible_current` is not a string claim. It is a computed state produced only when `ComputedRuntimeEligibility` returns `eligible` from required evidence.

## ComputedRuntimeEligibility Linkage

The computed eligibility model is:

```text
ComputedRuntimeEligibility(
  state: eligible | not_eligible | blocked | not_public_eligible,
  authorityState: SourceAuthorityState,
  evidence: SourceAuthorityEvidence,
  blockingReasons: [SourceAuthorityBlockReason],
  noClaimBoundary: [String]
)
```

`eligible` requires all of:

- schema and manifest compatibility pass
- source binding and immutable hash binding pass
- freshness is current for the risk class
- no matching revocation
- no unresolved contradiction
- risk and jurisdiction metadata are present where required
- required review state is approved
- private-data leak check passes
- no-hardcoded-Step check passes
- release receipt is present
- rollback receipt or rollback target is present
- signature, hash, checksum, or pinned-integrity verification passes
- app compatibility is known

If any required input is missing, unverifiable, stale, revoked, contradicted, private-data contaminated, high-risk under-specified, incompatible, or manually asserted, the computed state is not `eligible`.

## Transition Table

| From | Event | To | Required evidence |
|---|---|---|---|
| `unknown` | source record appears without complete provenance | `source_needed` | source id or gap receipt |
| `source_needed` | source binding and hashes verified | `source_bound_draft` | source id, raw hash, normalized hash, import receipt |
| `source_bound_draft` | review required | `review_needed` | review queue record |
| `review_needed` | review approves and risk/jurisdiction complete | `reviewed_current` | reviewer id/receipt, risk class, jurisdiction envelope |
| `reviewed_current` | all computed eligibility gates pass | `eligible_current` | `ComputedRuntimeEligibility.state == eligible` |
| `reviewed_current` | freshness window ages out | `stale` | freshness manifest or local stale calculation |
| `stale` | high-risk or hard-expired material | `stale_critical` | freshness class and risk class |
| any non-terminal state | source hash, claim, manifest, or release receipt changes | `source_changed` | changed hash/manifest/release receipt |
| any non-terminal state | contradiction appears | `contradicted` | contradiction map entry |
| any state | revocation matches source/claim/pack/signer/manifest/path/hash | `revoked` | revocation manifest or emergency receipt |
| any state | app schema/version/signature compatibility fails | `incompatible` | compatibility manifest result |
| any state | jurisdiction is required but unresolved | `jurisdiction_needed` | applicability envelope or risk class |
| any state | high-risk review is required but absent | `high_risk_review_needed` | risk class and missing review |
| any state | private data, invalid pack, hash mismatch, unsupported schema, or unsafe merge detected | `quarantined` | validation issue or quarantine receipt |
| any public state | artifact is user-owned local/private only | `local_only_private` | local-only classification |
| `stale`, `source_changed`, `contradicted`, `revoked`, `incompatible`, `quarantined` | valid replacement and rollback target verified | `review_needed` | rollback/supersession receipt |

No transition may jump directly from `source_needed`, `source_bound_draft`, `review_needed`, `stale`, `source_changed`, `contradicted`, `revoked`, `incompatible`, `jurisdiction_needed`, `high_risk_review_needed`, `quarantined`, or `local_only_private` to `eligible_current` without computed proof.

## Routing Matrix

| Authority state | Runtime action | Trust-light route |
|---|---|---|
| `eligible_current` | candidate for later runtime consumption | normal source-backed path after M10 proof |
| `reviewed_current` | not yet eligible | review details, no current recommendation |
| `source_needed` | no recommendation from this source | source-needed |
| `review_needed` | no recommendation from this source | review-needed |
| `stale` | no current recommendation; degraded use only if future policy allows | source may need review |
| `stale_critical` | block | blocked until refreshed |
| `source_changed` | block current use | review source change |
| `contradicted` | block | source conflict |
| `revoked` | block and quarantine | source revoked |
| `incompatible` | block and fallback | cannot use this source yet |
| `jurisdiction_needed` | block for jurisdiction-sensitive use | needs local rules |
| `high_risk_review_needed` | block | needs review |
| `quarantined` | block | source blocked |
| `local_only_private` | local-only use only, never public/R2 | private to this device/account |

User-facing phrasing is owned by AMB-687. AMB-686 only defines the internal state-to-route contract and forbids debug/R2 jargon from becoming the user-facing label.

## Fixture Matrix

The machine-readable fixture matrix is `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.json`. It covers ready, stale, revoked, contradicted, jurisdiction-needed, review-needed, blocked, high-risk reviewed, high-risk unreviewed, incompatible, quarantined, source-needed, source-changed, and local-only-private cases.

## Red Conditions

- `runtime_eligible` is asserted manually rather than computed from evidence.
- Stale, revoked, contradicted, incompatible, unreviewed, high-risk under-specified, jurisdiction-needed, or quarantined material can drive Steps.
- User-facing states expose R2/debug/source-pack jargon instead of trust-light compression.
- Private user data, user goals, schedules, proof, receipts, local learning, raw private text, identifiers, secrets, or write tokens appear in R2/public Source Atlas material.
- A fixture/test/generated asset is treated as production runtime proof.

## Downstream Consumers

- AMB-687 / PLOS-061 compressed user-facing state model.
- AMB-688 / PLOS-062 source applicability envelope.
- AMB-689 / PLOS-063 routing rules.
- AMB-690 / PLOS-064 Source Settings drill-down model.
- AMB-691 / PLOS-065 validation gauntlet.
- AMB-617 / PLOS-M10 runtime consumption proof.
- AMB-635 / PLOS-M26 certification gauntlets.

## Non-Claims

This artifact does not implement Swift runtime behavior, compute runtime eligibility in the app, change app source, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, create production canaries, claim runtime pack consumption, claim production readiness, claim privacy/legal approval, claim release readiness, claim device/accessibility/performance proof, execute AMB-687, execute AMB-617/M10, or execute AMB-635/M26.
