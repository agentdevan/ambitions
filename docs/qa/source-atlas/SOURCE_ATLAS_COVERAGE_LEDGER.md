# Source Atlas Coverage Ledger

Status: Yellow
Generated: 2026-06-27
Input commit: b26cbaf53
Owner posture: Retained coverage/proof roll-up, not product canon, production coverage proof, R2 readiness proof, privacy/legal approval, release proof, or known-issue closure.

This ledger rolls up the current Source Atlas registry, product-experience scenario gates, native source states, claim/provenance/freshness posture, validation commands, R2 readiness gates, and known-issue routing. It must stay conservative: source-present, locally validated, or generated coverage artifacts do not prove production freshness, app-side R2 behavior, entitlement gating, privacy/legal approval, device behavior, accessibility conformance, or release readiness.

## Non-Claims

- does not claim stable-channel R2 production freshness
- does not claim Source Atlas packs are production-ready
- does not claim app-side R2 fetch/cache/entitlement gating is validated
- does not claim R2 privacy boundary is release-validated
- does not claim account readiness, TestFlight readiness, App Store readiness, device proof, or accessibility conformance
- does not close known issues

## Roll-Up

| Layer | Current live coverage | Status ceiling | Primary evidence |
| --- | --- | --- | --- |
| Registry | 8 sources, 6 adapter lanes, 2 pathway seeds, 8 claims, 7 requirements | Source/tooling coverage only | `tools/source-atlas/foundry/registry.py` |
| Scenarios | 6 Source-related product gates; 17 M09 golden scenarios x 8 source-state variants | Scenario/contract coverage only | `docs/qa/product-experience-scenario-gates.yaml`, `tools/source-atlas/fixtures/m09/golden-benchmark-matrix.json` |
| Source states | current, unavailable, stale, stale-critical, conflicted, revoked, unsupported, review-required | Local repair-routing proof only | `tools/source-atlas/foundry/m09_validation.py`, `tools/source-atlas/fixtures/m09/source-state-repair-fixtures.json` |
| Claims, provenance, freshness | 8 seed claims; freshness values: selection_cycle_watch, stable_law_watch | Seed/source-record proof only | `tools/source-atlas/foundry/registry.py`, `tools/source-atlas/foundry/contracts/*` |
| Native source | 54 SourceAtlas source files and 32 SourceAtlas test files | Source/test presence; no release proof | `Native/Ambitions/**/SourceAtlas*.swift`, `Native/AmbitionsTests/**/SourceAtlas*.swift` |
| Validation | 17 available M09 commands, 1 unavailable command, 14 areas | Local validation matrix proof only | `docs/qa/source-atlas/2026-06-26-m09-validation-command-matrix.json` |
| R2 readiness | 5 contracts; production operations proof status Green for `source-atlas/v1/validation/amb-1429` | Green only for validation-prefix operations proof; Yellow for app/runtime/release readiness | `tools/source-atlas/foundry/contracts`, `docs/qa/source-atlas/production-r2-operations-proof.md` |
| Known issues | 7 routed; 7 keep-open recommendations | Routing only; no closure | `tools/source-atlas/foundry/m09_validation.py` |

## Coverage Tooling Audit

| Tooling area | Observed | Ledger finding |
| --- | --- | --- |
| Coverage command wrappers | 10 wrappers: `tools/source-atlas/coverage-candidates.py`, `tools/source-atlas/coverage-dedupe.py`, `tools/source-atlas/coverage-expand.py`, `tools/source-atlas/coverage-ledger.py`, `tools/source-atlas/coverage-mutate.py`, `tools/source-atlas/coverage-promote.py`, `tools/source-atlas/coverage-report.py`, `tools/source-atlas/coverage-score.py`, `tools/source-atlas/coverage-validate.py`, `tools/source-atlas/coverage.py` | Wrappers are present and route through `tools/source-atlas/coverage.py`. |
| Coverage Universe config/report roots | Missing: `source-atlas/coverage`, `source-atlas/schemas`, `source-atlas/reports` | Yellow while required config/schema/report roots are absent; do not claim full Coverage Universe reproducibility. |
| Coverage fixtures and receipts | 25 fixture JSON files; 131 generated receipt JSON files | Deterministic proof inputs only; not runtime or release proof. |
| Foundry contracts and boundary fixtures | 5 contracts; fixture counts {"boundary_invalid": 10, "boundary_valid": 5, "r2_invalid": 3, "r2_valid": 1}; 8 R2 operation fixtures | Local schema/boundary proof surface exists; stable-channel freshness and app-side R2 remain unproven. |

## Source-Related Scenario Gates

| Gate | Group | Current status |
| --- | --- | --- |
| `source_atlas_invisible_by_default` | Source Atlas | Partial |
| `source_atlas_does_not_upload_private_user_context` | Source Atlas | Partial |
| `source_atlas_pack_not_browsed_as_marketplace` | Source Atlas | Partial |
| `source_atlas_enriches_path_when_relevant` | Source Atlas | Partial |
| `source_inspection_available_when_user_asks_why` | Source Atlas | Partial |
| `source_freshness_change_can_trigger_review_state` | Source Atlas | Partial |

## Validation Matrix

| Validation surface | Valid | Count / status | Evidence |
| --- | --- | --- | --- |
| Command matrix | True | 18 commands across 14 areas | `docs/qa/source-atlas/2026-06-26-m09-validation-command-matrix.json` |
| Golden benchmarks | True | 17 scenarios, 136 expanded source-state cases | `tools/source-atlas/fixtures/m09/golden-benchmark-matrix.json` |
| Source-state repair | True | 7 fixtures; states conflicted, review-required, revoked, stale, stale-critical, unavailable, unsupported | `tools/source-atlas/fixtures/m09/source-state-repair-fixtures.json` |

Unavailable validation entries are explicit non-claims:
- `m09.production.r2.upload`: Production R2 upload is explicitly out of scope for M09 and must not be run or claimed.

## R2 Readiness Map

| R2 / freshness capability | Current coverage | Claim ceiling |
| --- | --- | --- |
| Object layout | `tools/source-atlas/foundry/contracts/r2-object-layout.json` | Contract shape only |
| Release manifest | `tools/source-atlas/foundry/contracts/release-manifest-schema.json` | Schema shape only |
| Freshness manifest | `tools/source-atlas/foundry/contracts/freshness-manifest-schema.json` | Schema shape only |
| Revocation | `tools/source-atlas/foundry/contracts/revocation-manifest-schema.json` | Schema shape only |
| Last known good | `tools/source-atlas/foundry/contracts/last-known-good-schema.json` | Schema shape only |
| Promotion gate | `source-atlas-foundry.py promotion-gate` | Dry-run only |
| Production R2 operations proof | `docs/qa/source-atlas/production-r2-operations-proof.md`; 8 of 9 operations Green/Passed; 14 readback checksums matched | Source Atlas Production R2 Operations Proof only |
| M09 production R2 upload | `m09.production.r2.upload` is not_available | Not run in M09; superseded only by the separate AMB-1429 operations-proof scope |
| App-side fetch/cache/entitlement/privacy proof | No release proof in this ledger | Unproven |

## Known Issue Routing

| Issue | Route status | Covered by | Closure |
| --- | --- | --- | --- |
| `AMB-ISSUE-2001` | proof_gap_routed | commandMatrix, sourceStateRepair | keep open |
| `AMB-ISSUE-2004` | proof_gap_routed | commandMatrix | keep open |
| `AMB-ISSUE-2005` | proof_gap_routed | commandMatrix | keep open |
| `AMB-ISSUE-2007` | proof_gap_routed | commandMatrix, sourceStateRepair | keep open |
| `AMB-ISSUE-2010` | proof_gap_routed | commandMatrix, sourceStateRepair | keep open |
| `AMB-ISSUE-2011` | proof_gap_routed | commandMatrix, sourceStateRepair | keep open |
| `AMB-ISSUE-2012` | proof_gap_routed | commandMatrix, goldenBenchmarks, sourceStateRepair | keep open |

## Native Source Ownership Snapshot

| Canonical owner | SourceAtlas file count |
| --- | --- |
| Core/Domain | 39 |
| Core/Persistence | 4 |
| Core/Runtime | 7 |
| Projection | 3 |
| DesignSystem | 1 |
| Tests | 32 |

Sample native source evidence:

- `Native/Ambitions/Core/Domain/SourceAtlasBridgeReceiptReplayModels.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasClaimCandidateExtractorModels+02-SourceAtlasClaimCandidateExtractor+02-extract.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasClaimCandidateExtractorModels+02-SourceAtlasClaimCandidateExtractor+03-provenanceState.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasClaimCandidateExtractorModels+02-SourceAtlasClaimCandidateExtractor+04-locatorHint.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasClaimCandidateExtractorModels+02-SourceAtlasClaimCandidateExtractor.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasClaimCandidateExtractorModels.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasCoverageRuntimeFixtureModels.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasDocumentTypeClassifierModels.swift`

Sample native test evidence:

- `Native/AmbitionsTests/Domain/SourceAtlasCapabilityPathCompositionModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasClaimCandidateExtractorModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasDocumentTypeClassifierModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasFoundryM02ContractModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasImageScreenshotImporterModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasIntentMatchModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasLocalImpactMatcherModelsTests.swift`

## Next Repair Gates

- Restore or intentionally replace the missing Coverage Universe config/schema/report roots before claiming reproducible Coverage Universe coverage.
- Keep M09 production R2 upload unavailable until a scoped promotion gate run is approved and current proof is produced.
- Add app-side request-shape, fetch/cache, entitlement, quarantine/revocation, last-known-good, offline fallback, and privacy-boundary proof before any R2 readiness claim.
- Keep known issues open until their owning implementation or release proof exists outside this routing ledger.

## Rollback

Revert `tools/source-atlas/coverage-ledger.py` and `docs/qa/source-atlas/SOURCE_ATLAS_COVERAGE_LEDGER.md`. No source, runtime behavior, R2 object, account flow, or Xcode project setting is changed by this ledger.
