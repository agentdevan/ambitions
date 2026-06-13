# Source Authority Non-Ready Routing

Status: Green for AMB-689 / PLOS-063 documentation/control-plane non-ready routing contract; Yellow for Swift runtime model implementation, validator automation, runtime eligibility computation, runtime pack consumption, UI implementation, production R2 promotion, privacy/legal approval, release readiness, accessibility proof, device proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-689 / PLOS-063
Parent issue: AMB-614 / PLOS-M06

## Boundary

This artifact defines the routing rules for Source Authority states that cannot currently drive a Recommended step, schedule install, or share projection. It consumes AMB-686 internal state, AMB-687 compressed user-facing state, and AMB-688 applicability-envelope evidence.

It does not implement Swift runtime behavior, compute runtime eligibility in the app, change app source, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, implement UI, or prove runtime pack consumption.

## Existing Source Ownership

AMB-689 extends existing owners rather than creating a parallel routing system:

- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_USER_FACING_STATE_MODEL.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_APPLICABILITY_ENVELOPE.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_CONTRADICTION_FRESHNESS_SCAN.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RISK_JURISDICTION_CLASSIFICATION.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RELEASE_RECEIPT_REQUIREMENTS.md`
- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md`

## Routing Contract

The future domain contract name is `SourceAuthorityNonReadyRoute`. Every non-ready Source Authority state must resolve to one route, one user-facing compressed state, one blocked runtime action posture, and one recovery path.

| Route id | Internal state inputs | Computed state | User state | Runtime action posture | Required next route |
|---|---|---|---|---|---|
| `source_needed` | `unknown`, `source_needed` | `not_eligible` | `needs_source` | no Recommended step, schedule install, or share projection from this source | request public source, coverage gap, or unsupported-source receipt |
| `review_required` | `source_bound_draft`, `review_needed`, `reviewed_current` without computed proof | `not_eligible` or `candidate` | `needs_review` | no runtime action until review and computed evidence pass | open review details |
| `jurisdiction_needed` | `jurisdiction_needed` | `not_eligible` | `needs_review` | no jurisdiction-sensitive runtime action | resolve local/institution/program rules |
| `stale_source` | `stale` | `not_eligible` | `older_source` | no current recommendation; local degraded display only if future policy proves safe | refresh source or review replacement |
| `source_changed` | `source_changed` | `not_eligible` | `source_changed` | block current source-backed action until change is reviewed | changed-source review and supersession |
| `revoked_source` | `revoked` | `blocked` | `cannot_use` | block and quarantine; never drive Steps | revocation, rollback, or safe fallback |
| `contradiction_review` | `contradicted` | `blocked` | `cannot_use` | block current use | contradiction review and source comparison |
| `compatibility_fallback` | `incompatible` | `blocked` | `cannot_use` | block remote/current use | compatibility fallback or last-known-good review |
| `hard_blocked` | `stale_critical`, `high_risk_review_needed`, `quarantined` | `blocked` | `cannot_use` | block all source-backed runtime action | high-risk review, quarantine, professional boundary, or rollback |
| `local_only` | `local_only_private` | `not_public_eligible` | `local_only` | never public/R2/share eligible; no public source-backed action | keep local, redact, or user-owned local lane |

## Blocking Precedence

When multiple conditions are present, the route must choose the most restrictive safe route:

1. Private data leak, secret, write token, or local-only private material -> `local_only` or `hard_blocked`.
2. Revocation match -> `revoked_source`.
3. Quarantine trigger, unsupported schema, hash mismatch, or invalid pack -> `hard_blocked`.
4. Unresolved contradiction -> `contradiction_review`.
5. Incompatible app/schema/signature/manifest -> `compatibility_fallback`.
6. High-risk unreviewed, stale-critical, crisis/safety, or professional-boundary gap -> `hard_blocked`.
7. Jurisdiction unresolved where applicability varies -> `jurisdiction_needed`.
8. Source changed or supersession needed -> `source_changed`.
9. Stale but not hard-expired -> `stale_source`.
10. Review missing or reviewed-current without computed proof -> `review_required`.
11. Missing source or unsupported source coverage -> `source_needed`.

No lower-priority route may soften a higher-priority block.

## Recovery Rules

| Route id | User-facing action | Runtime recovery condition | Receipt required |
|---|---|---|---|
| `source_needed` | Open source gap | source binding, hashes, provenance, and import receipt appear | source gap or import receipt |
| `review_required` | Open review details | review approved and computed evidence complete | review receipt |
| `jurisdiction_needed` | Review local rules | jurisdiction envelope resolved for the user/action context | jurisdiction review receipt |
| `stale_source` | Refresh source | freshness manifest, observed date, and stale window become current | freshness receipt |
| `source_changed` | Review source change | changed hash/claim/manifest is reviewed or superseded | supersession or change receipt |
| `revoked_source` | Use safe fallback | rollback target or replacement source is verified and not revoked | revocation plus rollback receipt |
| `contradiction_review` | Review conflict | contradiction map is resolved or source is blocked | contradiction decision receipt |
| `compatibility_fallback` | Use compatible fallback | compatibility manifest passes for the active app/schema | compatibility receipt |
| `hard_blocked` | Cannot use this | quarantine/high-risk/professional-boundary block is resolved by owning future phase | block resolution receipt |
| `local_only` | Keep local | public path remains blocked; local-only use requires user-owned local policy proof | local privacy receipt |

## Runtime Action Matrix

| Route id | Recommended step | Schedule install | Share projection | Source Settings display | Local personalization |
|---|---|---|---|---|---|
| `source_needed` | no | no | no | allowed | local-only if safe and source-free |
| `review_required` | no | no | no | allowed | local-only if safe |
| `jurisdiction_needed` | no | no | no | allowed | no jurisdiction-sensitive action |
| `stale_source` | no | no | no | allowed | local-only degraded display if future policy proves safe |
| `source_changed` | no | no | no | allowed | no source-backed action until review |
| `revoked_source` | no | no | no | allowed with revocation/rollback detail | no |
| `contradiction_review` | no | no | no | allowed with conflict detail | no |
| `compatibility_fallback` | no | no | no | allowed with fallback detail | no source-backed remote action |
| `hard_blocked` | no | no | no | allowed with blocker detail | no unless future safe fallback proves it |
| `local_only` | no public/source-backed action | no public/source-backed action | no | allowed with privacy boundary | user-owned local only if safe |

## Trust-Light User Routing

Top-level copy must use AMB-687 compressed labels only: Ready, Needs source, Needs review, Older source, Source changed, Cannot use this, or Local only. AMB-689 permits route explanations only inside a future Source Settings or receipt drill-down.

Forbidden top-level copy includes raw enum values, `R2`, bucket, manifest, compatibility manifest, hash, checksum, signer, canary, staging, production, source pack, runtime eligible, always current, privacy approved, safe, AI-approved, or any release-readiness wording.

## Fixture Matrix

The machine-readable fixture matrix is `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.json`. It covers source-needed, review-required, reviewed-but-not-computed, jurisdiction-needed, stale, source-changed, revoked, contradicted, incompatible, hard-expired, high-risk-unreviewed, quarantined, local-only-private, private-data-leak, missing rollback, and missing release receipt cases.

## Red Conditions

- `runtime_eligible` or `ready` is manually asserted instead of computed from evidence.
- Stale, revoked, contradicted, incompatible, review-needed, jurisdiction-needed, source-needed, high-risk-under-reviewed, local-only-private, private-data-contaminated, or quarantined material can drive Recommended steps.
- Source-needed becomes a dead end without a source gap, import, coverage-demand, unsupported-source, or user-facing next route.
- User-facing routing exposes R2/debug/source-pack jargon instead of AMB-687 compressed labels.
- A lower-priority route softens revocation, contradiction, quarantine, private-data, high-risk, or compatibility blocks.
- Private user data, secrets, identifiers, raw private text, goals, schedules, proof, receipts, local learning, support bundles, diagnostics, or write tokens appear in public Source Atlas/R2 material.
- Fixture/test/generated/preview assets are treated as production runtime proof.

## Downstream Consumers

- AMB-690 / PLOS-064 Source Settings drill-down model.
- AMB-691 / PLOS-065 Source Authority validation gauntlet.
- AMB-617 / PLOS-M10 runtime consumption proof.
- AMB-627 / PLOS-M09 Step Quality Firewall.
- AMB-625 / PLOS-M18 high-risk safety, legality, and jurisdiction.
- AMB-635 / PLOS-M26 certification gauntlets.

## Non-Claims

This artifact does not implement Swift runtime behavior, compute runtime eligibility in the app, change app source, migrate schemas, create validators/scanners, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, implement UI, claim runtime pack consumption, claim production readiness, claim privacy/legal approval, claim release readiness, claim TestFlight readiness, claim App Store readiness, claim device/accessibility/performance proof, execute AMB-690, execute AMB-617/M10, execute AMB-627/M09, execute AMB-625/M18, execute AMB-635/M26, or close AMB-614/PLOS-M06.
