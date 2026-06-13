# Source Authority Validation Gauntlet

Status: Green for AMB-691 / PLOS-065 documentation/control-plane validation-gauntlet contract; Yellow for Swift runtime model implementation, validator/scanner automation, executable test harness, runtime eligibility computation, runtime pack consumption, UI implementation, production R2 promotion, privacy/legal approval, release readiness, accessibility proof, device proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-691 / PLOS-065
Parent issue: AMB-614 / PLOS-M06

## Boundary

This artifact defines the Source Authority validation gauntlet that future implementation and certification phases must satisfy before any Source Atlas source, claim, seed, pack, or requirement can drive a Recommended step, schedule install, share projection, recap, or other runtime action.

It does not implement Swift runtime behavior, create executable validators, change app source, migrate schemas, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, implement UI, or prove runtime pack consumption.

## Existing Source Ownership

AMB-691 validates across the completed M06 contracts:

- `SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.md`
- `SOURCE_AUTHORITY_USER_FACING_STATE_MODEL.md`
- `SOURCE_AUTHORITY_APPLICABILITY_ENVELOPE.md`
- `SOURCE_AUTHORITY_NON_READY_ROUTING.md`
- `SOURCE_AUTHORITY_SOURCE_SETTINGS_DRILL_DOWN.md`
- `SOURCE_ATLAS_RISK_JURISDICTION_CLASSIFICATION.md`
- `SOURCE_ATLAS_RELEASE_RECEIPT_REQUIREMENTS.md`
- `SOURCE_ATLAS_NO_HARDCODED_STEPS_ENFORCEMENT.md`
- `R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`

## Gauntlet Contract

The future validator contract name is `SourceAuthorityValidationGauntlet`. It is a fail-closed sequence:

1. Identity and AMB binding: every artifact, source, route, and receipt has an AMB-bound owner and source id.
2. Source binding: source ids, claim ids, hashes, provenance, and import receipts exist.
3. Schema and compatibility: schema version, app compatibility, and manifest compatibility pass.
4. Integrity: signature, hash, checksum, or pinned-integrity verification passes.
5. Freshness and revocation: freshness current or routed stale; no matching revocation.
6. Contradiction: no unresolved contradiction, disputed claim, source-change, or unsafe merge.
7. Applicability: jurisdiction, effective date, expiration, risk, and review envelope is complete.
8. Risk and review: high-risk, unknown-risk, professional-boundary, minor/student, legal/civic, financial, health/medical, and crisis/safety states are reviewed or blocked.
9. Privacy boundary: no private user data, local-only material, secrets, identifiers, raw private text, diagnostics, support bundles, receipts, goals, schedules, proof, or write tokens in public Source Atlas/R2 material.
10. Release and rollback: release receipt, rollback target, supersession path, and last-known-good fallback exist where required.
11. Hardcoded-Step safety: no public pack carries finished exact-user Steps, exact schedules, private profile context, or source-free recommendations.
12. User-facing compression: raw internal/R2/debug jargon is not surfaced as top-level user state.
13. Non-ready routing: source-needed, review-needed, stale, source-changed, revoked, contradicted, incompatible, jurisdiction-needed, high-risk-review-needed, quarantined, and local-only states route correctly.
14. Source Settings drill-down: review-needed, blocked, contradiction, revocation, risk, jurisdiction, freshness, receipt, rollback, and privacy details remain inspectable.
15. Runtime action gate: Recommended step, schedule install, and share projection are denied unless future computed runtime eligibility proves all gates.

Any failed gate returns `blocked`, `not_eligible`, or `not_public_eligible`. Manual `runtime_eligible` is invalid.

## Required Future Outputs

| Output | Required fields | Current AMB-691 status |
|---|---|---|
| `SourceAuthorityValidationResult` | `result`, `failed_gate_ids`, `computed_runtime_eligibility`, `route`, `user_state`, `receipt_ids`, `no_claim_boundary` | Contract only |
| `SourceAuthorityValidationFixture` | `fixture_id`, `inputs`, `expected_state`, `expected_route`, `expected_user_state`, `expected_runtime_actions` | Contract fixtures in JSON |
| `SourceAuthorityValidationReceipt` | `validator_version`, `artifact_hashes`, `run_at`, `owner_issue`, `passed`, `failed_gate_ids` | Future-owned |
| `SourceAuthorityReplayFingerprint` | `source_state_hash`, `envelope_hash`, `route_hash`, `receipt_hash`, `fixture_hash` | Future-owned |

## Fixture Matrix

The machine-readable fixture matrix is `artifacts/source-atlas-factory/SOURCE_AUTHORITY_VALIDATION_GAUNTLET.json`. It covers ready, source-needed, review-needed, reviewed-but-not-computed, stale, stale-critical, source-changed, revoked, contradicted, jurisdiction-needed, high-risk-reviewed, high-risk-unreviewed, incompatible, quarantined, private-data-leak, local-only-private, missing rollback, missing release receipt, unsupported schema, manual runtime-eligible assertion, and debug-jargon leakage.

## Red Conditions

- Runtime eligibility is manually asserted or stored as an unverified string.
- Stale, revoked, contradicted, incompatible, source-needed, review-needed, jurisdiction-needed, high-risk-under-reviewed, local-only-private, private-data-contaminated, quarantined, missing-rollback, missing-release-receipt, unsupported-schema, or debug-jargon states can drive Steps.
- The gauntlet cannot validate blocked/review-needed routing.
- Compressed user-facing state maps expose R2/debug/source-pack jargon.
- Source Settings hides contradiction, review-needed, revoked, high-risk, jurisdiction, privacy, receipt, or rollback state.
- Private user data or secrets appear in public Source Atlas/R2 artifacts, logs, support bundles, diagnostics, Linear comments, or validation reports.
- Fixture/test/generated/preview assets are treated as production runtime proof.

## Downstream Consumers

- AMB-617 / PLOS-M10 runtime consumption proof.
- AMB-627 / PLOS-M09 Step Quality Firewall.
- AMB-624 / PLOS-M17 trust-light UI and deep drill-down.
- AMB-625 / PLOS-M18 high-risk safety, legality, and jurisdiction.
- AMB-635 / PLOS-M26 certification gauntlets.

## Non-Claims

This artifact does not implement Swift runtime behavior, validators/scanners, executable tests, replay fingerprinting, runtime eligibility computation in the app, runtime pack consumption, UI, screenshots, accessibility semantics, schema migration, pack publication, Cloudflare/R2 provisioning, live R2 writes, production promotion, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, accessibility proof, measured performance proof, security certification, AMB-617/M10 runtime consumption, AMB-624/M17 UI implementation, AMB-635/M26 production certification, or AMB-614 parent completion.
