# PLOS-011 Source Atlas Factory Runtime Map

Status: Green for AMB-647 read-only mapping scope; Yellow for production runtime wiring not yet proven
Linear issue: AMB-647
Parent issue: AMB-609
Label: PLOS-011
Date: 2026-06-12

## Scope

AMB-647 maps existing Source Atlas files, scripts, models, bridge code, tests, fixtures, docs, validation assets, and tooling into live/runtime, model-only, test-only, fixture-only, tooling, governance, stale, and false-positive categories. This is M01 proof and mapping only.

No app source, runtime feature, Source Atlas Factory production work, R2 distribution work, Step Elasticity work, CloudKit work, UIQL work, release work, or PLOS-M02+ work was performed.

## Existing-First Evidence

Commands and artifacts:

- `git status --short`
- `rg -n "SourceAtlas|source_atlas|source-atlas|PackFactory|StarterItem|StepCandidateSeed|RuntimeBridge|QueryEngine|IntentMatcher|Freshness|ProofMap|Receipt|Replay" Native Sources Native/AmbitionsTests scripts tools docs . --glob "*.swift" --glob "*.md" --glob "*.sh" --glob "*.py" --glob "*.json" --glob "*.yml" --glob "*.yaml" > artifacts/personal-life-os/validation/PLOS-011-source-atlas-search-log.txt`
- `find . -type f | rg -i "source.?atlas|sa-|source_atlas" > artifacts/personal-life-os/validation/PLOS-011-source-atlas-files.txt`
- `git ls-files | rg -i "source.?atlas|sa-|source_atlas|SAF" | sort > artifacts/personal-life-os/validation/PLOS-011-source-atlas-tracked-files.txt`
- `artifacts/personal-life-os/validation/PLOS-011-source-atlas-classification.tsv`

Inventory counts:

- Raw file inventory: 9,211 paths in `PLOS-011-source-atlas-files.txt`.
- Required search log: 19,429 matches in `PLOS-011-source-atlas-search-log.txt`.
- Tracked Source Atlas / Source Atlas-adjacent classification: 155 paths in `PLOS-011-source-atlas-classification.tsv`.

The raw file inventory intentionally includes generated, historical, artifact, and broad `sa-` matches. The classification table is the tracked-source control map for AMB-647 and prevents treating generated logs, UIQL safe-area artifacts, safety scripts, or cache files as Source Atlas production runtime.

## File Inventory Summary

The full path-by-path table is `artifacts/personal-life-os/validation/PLOS-011-source-atlas-classification.tsv` with columns:

`path`, `type`, `runtime_category`, `purpose`, `used_by`, `evidence`, `owner_phase`.

Category counts:

| Count | Runtime category |
|---:|---|
| 23 | test-only |
| 20 | script validator/advisory |
| 19 | compiled domain model; runtime eligibility unproven |
| 17 | standalone tooling/demo |
| 14 | governance/tooling skill |
| 13 | developer tooling |
| 12 | governance artifact |
| 11 | false-positive/non-Source-Atlas |
| 5 | tool test-only |
| 4 | false-positive/non-Source-Atlas script |
| 2 | runtime-model bridge; not proven wired to production app path |
| 2 | PLOS report artifact |
| 2 | supporting authority doc |
| 2 | research import tooling |
| 2 | stale tracked cache/test artifact |
| 1 | reviewer prompt |
| 1 | PLOS tooling helper |
| 1 | fixture-model only |
| 1 | UI primitive model/support; not proven live production surface |
| 1 | false-positive/non-Source-Atlas UIQL artifact |
| 1 | deterministic readiness validator |
| 1 | developer MCP docs only |

Representative live-source rows:

| Path | Type | Runtime category | Purpose | Used by | Evidence | Owner phase |
|---|---|---|---|---|---|---|
| `Native/Ambitions/Domain/SourceAtlasPackModels.swift` | Swift source | compiled domain model; runtime eligibility unproven | Pack/source/claim/requirement/proof/path/projection schema and validator | Tests and dependent domain/runtime models | Defines `SourceAtlasPack`, `SourceAtlasPackManifest`, `SourceAtlasPackValidator`, runtime boundary fields, source state and validation issues | M01/M04/M05/M06/M12 |
| `Native/Ambitions/Domain/SourceAtlasPackFactoryModels.swift` | Swift source | compiled domain model; runtime eligibility unproven | Lite JSON/YAML pack decoder and validator wrapper | Tests and dependent models | Defines `SourceAtlasPackFactoryLite`, decode, make, and validate flows | M04/M05 |
| `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift` | Swift source | compiled domain model; runtime eligibility unproven | Goal intent to pack selection model and deterministic matcher | Tests and query engine | Defines `SourceAtlasIntentMatcher`, `SourceAtlasPackSelection`, `canDriveRuntime` | M07/M12 |
| `Native/Ambitions/Domain/SourceAtlasQueryEngineModels.swift` | Swift source | compiled domain model; runtime eligibility unproven | Pack query and fallback/source-needed response model | Tests and intent matcher | Defines `SourceAtlasQueryEngine`, fallback reasons, source-needed details, current-use gates | M06/M07 |
| `Native/Ambitions/Domain/SourceAtlasStoreModels.swift` | Swift source | compiled domain model; runtime eligibility unproven | Payload load, hash check, quarantine, and offline fallback store model | Tests and query fallback models | Defines `SourceAtlasStore`, SHA256 check, quarantine reasons, `SourceAtlasStoreLoadResult` | M04/M06/M23 |
| `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift` | Swift source | runtime-model bridge; not proven wired to production app path | Expands Source Atlas paths and seeds into Step candidate fields and traces | Runtime tests and bridge replay | Defines `SourceAtlasStepCandidateFieldBridge.expand(...)` and trace rebuilding | M12/M13/M14 |
| `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift` | Swift source | runtime-model bridge; not proven wired to production app path | Creates replay snapshots and receipts for Source Atlas to Step bridge | Runtime tests | Defines `SourceAtlasRuntimeBridgeReplay`, bridge receipts, fallback candidate | M17/M26 |
| `Native/Ambitions/Features/You/YouScreen.swift` | Swift source | live app UI projection for Source Atlas knowledge, not factory bridge runtime | Displays profile Source Atlas knowledge rows in You | You surface | `YouSourceAtlasKnowledgeSurface` is rendered from `profileProjection.sourceAtlasKnowledge` | M01/M17 |
| `Native/Ambitions/Features/You/YouFeatureService.swift` | Swift source | live app projection service, not factory bridge runtime | Builds Source Atlas knowledge rows for You | You surface | `makeSourceAtlasKnowledgeState(...)` and row builders compile profile/projection state | M01/M17 |
| `Native/Ambitions/Domain/SourceAtlasCoverageRuntimeFixtureModels.swift` | Swift source | fixture-model only | Runtime fixture schema/validator with value-model-only boundary | Tests/coverage fixtures | `runtimeBoundary` returns `.valueModelOnly`; validator blocks proof-alone claims | M01/M26 |
| `scripts/sa-pack-validate.sh` | Shell script | script validator/advisory | Pack resource validation wrapper | Manual/Goal Mode validation | Warns when `Resources/SourceAtlas` is missing | M04/M05/M26 |
| `tools/source-atlas/coverage.py` | Python tool | developer tooling | Coverage universe generator for source-pack stubs, fixtures, and reports | Manual/local tooling | Declares generated fixtures are proof inputs, not proof alone | M26 |
| `tools/source-atlas/lakehouse-workbench/*` | Python/demo tooling | standalone tooling/demo | Lakehouse workbench and R2 staging command generation | Developer/manual only | Not app runtime; R2 references are staging/public-reference tooling | M04/M05/M26 |
| `tools/source-atlas/tests/__pycache__/*.pyc` | Bytecode cache | stale tracked cache/test artifact | Tracked generated cache files | none | Not source/runtime; cleanup candidate | M01 stale map/M26 |

## Subsystem Map

| Subsystem | Existing artifacts | Runtime category | Proof and caveat | Owner phase |
|---|---|---|---|---|
| Pack models | `SourceAtlasPackModels.swift` | Compiled domain model | Contains pack kinds, sources, claims, requirements, starter items, proof map, projections, freshness/risk/disclosure/runtime boundary/composition fields, and validator. Compiling is not proof of production pack loading. | M04/M05/M06 |
| Pack factory / decoder / validator | `SourceAtlasPackFactoryModels.swift` | Compiled domain model | Supports JSON/YAML decode and validation through `SourceAtlasPackFactoryLite`; usage found in tests, not in production app runtime path. | M04/M05 |
| Source records | `SourceAtlasPackModels.swift`, `SourceAtlasSourceContainerModels.swift` | Compiled domain model | Source states, provenance, extraction/failure states, and source containers exist. Production ingestion and trust gates remain unproven. | M04/M06 |
| Claims | `SourceAtlasPackModels.swift`, `SourceAtlasClaimCandidateExtractorModels.swift` | Compiled domain model | Claim states and candidate extraction exist with source/freshness/risk/review state shaping. Not proof of shipped Source Atlas claim ingestion. | M05/M06/M18 |
| Requirements | `SourceAtlasPackModels.swift`, `SourceAtlasQueryEngineModels.swift` | Compiled domain model | Requirement source/freshness/review/risk gates feed query fallback logic. Production requirement store remains unproven. | M06/M09 |
| Freshness | `SourceAtlasFreshnessBrokerModels.swift`, `tools/source-atlas/ambitions-freshness-broker.py`, `scripts/sa-source-freshness-scan.sh` | Model plus tooling | Manifest/update receipt concepts exist; no live freshness service or remote distribution proof. | M06/M23/M26 |
| Risk/review | `SourceAtlasReviewModels.swift`, `HIGH_RISK_DOMAIN_SAFETY_LAW.md`, `scripts/sa-high-risk-claim-scan.sh` | Model/governance/tooling | Review and high-risk laws exist; runtime high-risk enforcement is future. | M18/M26 |
| Store/cache/quarantine | `SourceAtlasStoreModels.swift` | Compiled domain model | Hash, schema, revocation/contradiction, and validation quarantine logic exists. No bundled/cached production resource path was proven. | M04/M06/M23 |
| Intent matcher | `SourceAtlasIntentMatchModels.swift` | Compiled domain model | Deterministic matcher selects packs and records can-drive-runtime state. Only test usage proven. | M07/M12 |
| Query engine | `SourceAtlasQueryEngineModels.swift` | Compiled domain model | Selects current-use-capable query results or source-needed fallback. Only test/model usage proven. | M06/M07 |
| Mini-pack builder | `SourceAtlasUserMiniPackBuilderModels.swift` | Compiled domain model | User mini-pack builder exists as local value model. It is not source truth or production pack distribution proof. | M05/M22 |
| Importers | URL, PDF, PDFKit, plain text, image/screenshot, OCR fallback, document classifier models | Compiled domain models | Import boundary models exist. Production importer UI/storage/resource wiring was not proven. | M05/M06 |
| Coverage fixtures | `SourceAtlasCoverageRuntimeFixtureModels.swift`, `tools/source-atlas/coverage.py`, runtime gauntlet tests | Fixture/test/tooling | Fixture models and generation tooling exist. They are deterministic proof inputs, not product proof by themselves. | M26 |
| Capability path composer | `SourceAtlasPackModels.swift` composition/path types, `SourceAtlasCapabilityPathCompositionModelsTests.swift` | Model/test coverage | Path composition model exists and tests cover path composition. Production path installer is not proven. | M12/M13 |
| Step candidate bridge | `SourceAtlasStepCandidateFieldBridge.swift` | Runtime-model bridge, not production-wired | Bridge can expand paths into Step candidate fields and source traces. No active app caller was proven in AMB-647. | M13/M14 |
| Runtime replay | `SourceAtlasRuntimeBridgeReplay.swift`, replay tests | Runtime-model bridge, not production-wired | Replay snapshot and receipt model exists. No live inspection route was proven. | M17/M26 |
| Receipts | `SourceAtlasBridgeReceiptReplayModels.swift`, bridge replay | Compiled domain/runtime model | Receipt kinds, summaries, correction input, recommendation summary exist. Live receipt persistence/inspection route remains future. | M17/M26 |
| UI primitives | `SourceAtlasUIPrimitives.swift`, UI tests | UI support, not proven live | UI primitive tests exist; You has a live Source Atlas knowledge projection, but factory bridge UI is not production-proven. | M17 |
| Validation scripts | `scripts/sa-*.sh`, `source-atlas-readiness-validate.py`, SAF scripts | Advisory/deterministic tooling | Validators and advisory scans exist. Some still reference absent/stale roots and must not be treated as runtime proof. | M01/M26 |
| Research import tools | `tools/source-atlas/research-import/*` | Research tooling | Imports research seeds into `Resources/SourceAtlas/ResearchSeeds`; that root is not proven present as production app resource in AMB-647. | M04/M05 |
| R2/distribution | `tools/source-atlas/lakehouse-workbench/*`, SAF R2 boundary docs | Tooling/governance only | R2 references are staging/public-reference tooling and boundary docs. No R2 production distribution was implemented or claimed. | M04/M26 |

## Live Runtime Participation

Green source facts:

- Source Atlas domain and runtime bridge Swift files are part of tracked app source under `Native/Ambitions`.
- `SourceAtlasStepCandidateFieldBridge` and `SourceAtlasRuntimeBridgeReplay` contain runtime-shaped bridge/replay logic.
- You has live UI projection code for Source Atlas knowledge via `YouSourceAtlasKnowledgeSurface` and `YouFeatureService.makeSourceAtlasKnowledgeState(...)`.

Yellow boundaries:

- AMB-647 did not prove the Source Atlas Factory bridge is invoked by the active Today recommendation runtime.
- AMB-647 did not prove bundled/cached Source Atlas pack resources exist in a production resource path.
- AMB-647 did not prove R2 distribution, pack download, release receipt, revocation refresh, or CloudKit/local sync behavior.
- Model compilation, runtime-shaped structs, and tests are not product runtime proof.

Runtime classification:

| Class | Paths / subsystems | Verdict |
|---|---|---|
| Live app UI projection | `YouScreen.swift`, `YouFeatureService.swift`, `YouModels.swift` Source Atlas knowledge state | Live You display/projection only; not Source Atlas Factory bridge completion |
| Runtime-model bridge | `SourceAtlasStepCandidateFieldBridge.swift`, `SourceAtlasRuntimeBridgeReplay.swift` | Bridge/replay code exists; no active production caller proven |
| Compiled model-only | Most `Native/Ambitions/Domain/SourceAtlas*.swift` | Valid source models, not runtime completion |
| Tests-only | `Native/AmbitionsTests/**SourceAtlas*.swift`, `tools/source-atlas/tests/*` | Validation coverage only |
| Fixture-only | `SourceAtlasCoverageRuntimeFixtureModels.swift`, generated coverage fixture tooling | Proof input only, not product proof |
| Tooling-only | `tools/source-atlas/**`, `scripts/sa-*.sh`, SAF skill scripts | Developer/Goal Mode support only |
| Governance/doc-only | SAF artifacts, Source Atlas laws, reviewer prompts | Authority and closeout support only |
| Stale/cleanup candidates | tracked `__pycache__/*.pyc`, scripts referencing absent roots | Not runtime; cleanup or root-alignment follow-up |
| False positives | `shell-safe-area`, `SafeAutomation`, `Safety`, `claim_safety` matches | Not Source Atlas Factory artifacts |

## Source Atlas To Step Bridge Map

Existing model chain:

1. Goal intent enters `SourceAtlasIntentMatcher.evaluate(rawGoalText:)`.
2. Intent matcher normalizes the goal text, applies deterministic rules, queries `SourceAtlasQueryEngine`, and produces `SourceAtlasIntentMatch` plus `SourceAtlasPackSelection`.
3. Pack selection records selected/rejected packs, source state, freshness state, risk state, review state, `canDriveRuntime`, and `requiredUserReview`.
4. Query engine can select current-use-capable requirements or fallback to source-needed details.
5. Capability/path composition types in `SourceAtlasPackModels.swift` and `PersonalPathComposition` feed `SourceAtlasStepCandidateFieldBridge.expand(...)`.
6. Bridge expands selected paths, requirements, starter seeds, and plan skeleton milestones into `StepCandidateField` candidates and `SourceAtlasStepExpansionTrace`.
7. Runtime replay creates `SourceAtlasRuntimeBridgeReplay`, `SourceAtlasBridgeReceipt` entries, and a selected recommendation summary.
8. Future Today handoff, runtime persistence, replay detail route, release receipts, and source-refresh feedback loops remain phase-owned and unproven.

Gap status:

- Goal intent to pack selection: model/test present, production invocation unproven.
- Pack selection to query/source gates: model/test present, production store/resource root unproven.
- Path composition to Step candidate expansion: bridge/test present, active app caller unproven.
- Candidate ranking/Today handoff: bridge constructs `StepCandidateField`, but live Today recommendation integration remains future proof.
- Replay/receipt: model/test present, live inspection/persistence route unproven.

## Validation Asset Map

Existing validation assets found:

- Swift tests under `Native/AmbitionsTests/Domain/SourceAtlas*.swift`.
- Swift runtime tests under `Native/AmbitionsTests/Runtime/SourceAtlas*.swift`.
- UI primitive test under `Native/AmbitionsTests/UI/SourceAtlasUIPrimitivesTests.swift`.
- Python tool tests under `tools/source-atlas/tests/*`.
- Advisory shell scans under `scripts/sa-*.sh`.
- Deterministic readiness validator `scripts/codex/source-atlas-readiness-validate.py`.
- SAF wrappers under `.agents/skills/source-atlas-factory/scripts/*`.
- PLOS helper `.agents/skills/plos-runtime-master-build/scripts/plos-source-atlas-scan.sh`.

Known validation caveats:

- Some `scripts/sa-*.sh` still reference `Resources/SourceAtlas` or `Sources/Ambitions/SourceAtlas`; those roots were not proven as active production source roots in AMB-647.
- `tools/source-atlas/tests/__pycache__/*.pyc` are tracked generated cache artifacts and should not be treated as source or runtime proof.
- Coverage fixtures and gauntlets are useful proof inputs, not Green product/runtime proof by themselves.

## Missing Production Runtime Pieces

| Gap | Status | Owner phase |
|---|---|---|
| Production Source Atlas pack resource root and loading path | Not proven | M04/M05/M06 |
| R2 public-reference distribution, manifest, release receipt, rollback | Not implemented/proven | M04/M26 |
| Source freshness broker wired to runtime update/revocation flow | Not proven | M06/M23 |
| Source Atlas goal intent invocation from active goal creation or Today recommendation path | Not proven | M07/M10/M12 |
| Pack selection to Multi-Path Lattice / Step Graph Compiler handoff | Not proven | M12/M13 |
| Step candidate bridge production caller and Today handoff | Not proven | M13/M14 |
| Replay/receipt persistence and trust-light inspection route | Not proven | M17/M26 |
| High-risk jurisdiction/professional-boundary runtime gates | Not proven | M18 |
| Production-vs-fixture/test/script classification across all M01 surfaces | Partially mapped here; dedicated owner remains | AMB-651 / PLOS-015 |

## Red/Yellow/Green Verdict

Green:

- Existing Source Atlas artifacts were inspected and classified without adding a duplicate system.
- Live vs model-only vs test/fixture/tooling boundaries are explicit.
- Source Atlas to Step bridge model chain is mapped with no runtime completion overclaim.
- Stale roots, false positives, and tracked cache artifacts are called out.

Yellow:

- Source Atlas Factory production runtime participation remains unproven.
- Some advisory validators reference absent or unverified roots and need future root alignment.
- Full production-vs-fixture/test/script classification is owned by AMB-651 / PLOS-015.

Red blockers:

- None for AMB-647 mapping scope.

## PLOS Child Closeout

PLOS child closeout
Linear issue: AMB-647
Parent issue: AMB-609
Green/Yellow/Red status: Green for AMB-647 read-only Source Atlas runtime map; Yellow for production runtime wiring, pack resources, R2 distribution, live Today handoff, and full fixture/test/script classification not claimed.
Pushed to main: pending at report creation
Push hash: pending at report creation
App source changed: no
Runtime features implemented: no
PLOS-M00 executed: no
Linear identifiers used: AMB issue identifiers only
Validation run: required Source Atlas find inventory; required Source Atlas rg search log; tracked file classification; git diff --check; python3 scripts/codex/source-atlas-readiness-validate.py --self-test; python3 scripts/codex/source-atlas-readiness-validate.py; scripts/codex/program-preflight.sh plos; scripts/codex/program-phase-gate.sh plos M01; python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-011-source-atlas-factory-runtime-map.md
Red blockers: none for AMB-647 mapping scope
Yellow limits: production runtime wiring, pack resources, R2 distribution, live Today handoff, screenshot/accessibility/performance/release/privacy/legal proof, and full AMB-651 production-vs-fixture classification are not claimed
Owner approval claimed: no
Release/TestFlight/App Store readiness claimed: no
Next recommended action: after AMB-647 commit, push, and Linear closeout, continue to AMB-648 / PLOS-012 only
