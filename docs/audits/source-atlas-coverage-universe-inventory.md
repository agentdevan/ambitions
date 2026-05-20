# Source Atlas Coverage Universe Inventory

Status: Implementation prerequisite inventory  
Batch: AMB-SOURCE-ATLAS-COVERAGE-UNIVERSE-01  
Date: 2026-05-20  
Scope: Existing Source Atlas Factory, source-pack, validation, proof, fixture, and governance surfaces

## Authority Read First

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Inventory Result

The repo already contains Source Atlas Factory and source-pack owner seams. The Coverage Universe must extend those seams and must not reinstall Source Atlas, create a parallel source-pack authority, or treat generated artifacts as canon or proof.

## Relevant Artifacts

| Artifact | Classification | Notes |
|---|---|---|
| `Native/Ambitions/Domain/SourceAtlasPackModels.swift` | active implementation | Defines source-pack schema primitives, claim/freshness/review states, risk classes, validation issues, manifest models, source records, requirements, proof maps, projection recipes, and validator behavior. Safe to reuse as the native Source Atlas pack model authority. |
| `Native/Ambitions/Domain/SourceAtlasPackFactoryModels.swift` | active implementation | Existing Source Atlas Pack Factory Lite decoder/validator for JSON/YAML pack inputs. Coverage tooling must not duplicate this app-domain factory; it can generate derivative candidate inputs for later validation. |
| `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift` | active implementation | Freshness modeling exists in the app domain. Coverage scenarios should stress freshness boundaries without changing app runtime behavior in this batch. |
| `Native/Ambitions/Domain/SourceAtlasQueryEngineModels.swift` | active implementation | Query and selection models exist. Coverage fixtures may later feed this seam, but this batch should not claim runtime query proof from generated scenarios alone. |
| `Native/Ambitions/Domain/SourceAtlasStoreModels.swift` | active implementation | Local Source Atlas store models exist. Coverage promotion must preserve local-only/non-network boundaries. |
| `Native/Ambitions/Domain/SourceAtlasReviewModels.swift` | active implementation | Review-state concepts exist and should be preserved by candidate scoring and promotion receipts. |
| `Native/Ambitions/Domain/SourceAtlasClaimCandidateExtractorModels.swift` | active implementation | Claim candidate extraction exists. Coverage candidates should not be treated as extracted official claims. |
| `Native/Ambitions/Domain/SourceAtlasUserMiniPackBuilderModels.swift` | active implementation | User mini-pack boundary exists. Coverage Universe must not leak private/sensitive data into generated source packs. |
| `Native/Ambitions/Domain/SourceAtlasLocalImpactMatcherModels.swift` | active implementation | Local impact matching exists and should remain local/review-bound. |
| `Native/Ambitions/Domain/SourceAtlasURLSourceImporterModels.swift` | active implementation | URL importer models exist. Coverage tools must not perform network import. |
| `Native/Ambitions/Domain/SourceAtlasPlainTextImporterModels.swift` | active implementation | Plain text import models exist. Coverage tools can accept manually pasted ScenarioSpecs, but generated text remains derivative. |
| `Native/Ambitions/Domain/SourceAtlasPDFImportBoundaryModels.swift` | active implementation | PDF import boundary exists. Coverage Universe does not change PDF import behavior. |
| `Native/Ambitions/Domain/SourceAtlasPDFKitTextExtractionModels.swift` | active implementation | PDFKit extraction models exist. Not touched by this batch. |
| `Native/Ambitions/Domain/SourceAtlasImageScreenshotImporterModels.swift` | active implementation | Screenshot importer models exist. Not touched by this batch. |
| `Native/Ambitions/Domain/SourceAtlasVisionOCRFallbackModels.swift` | active implementation | OCR fallback models exist. Coverage scenarios may reference OCR-derived evidence as an edge case but cannot make proof claims. |
| `Native/Ambitions/Domain/SourceAtlasDocumentTypeClassifierModels.swift` | active implementation | Document classifier models exist. Coverage candidates should preserve review/freshness boundaries. |
| `Native/Ambitions/UI/SourceAtlasUIPrimitives.swift` | active implementation | UI primitives exist. This batch is tooling/docs/fixtures only and does not alter UI. |
| `Native/AmbitionsTests/Domain/SourceAtlas*Tests.swift` | active implementation | Focused Source Atlas test coverage exists across pack models, factory, query, import, store, freshness, review, and classifier seams. This batch adds deterministic tooling proof, not Swift runtime test proof. |
| `Native/AmbitionsTests/UI/SourceAtlasUIPrimitivesTests.swift` | active implementation | Source Atlas UI primitive tests exist. Not touched. |
| `tools/source-atlas/ambitions-pack-diff.py` | active implementation | Existing local pack diff tool. Safe to reuse conceptually; coverage dedupe/reporting should not replace it. |
| `tools/source-atlas/ambitions-pack-crypto.py` | active implementation | Existing pack hash/signature/revocation tooling. Coverage promotion receipts should include input hashes but must not imply signing/release proof. |
| `tools/source-atlas/ambitions-freshness-broker.py` | active implementation | Existing local freshness broker tooling. Coverage validation should keep freshness explicit. |
| `tools/source-atlas/ambitions-official-adapter-contract.py` | active implementation | Existing official-adapter contract. Coverage tools must not claim official adapter proof. |
| `tools/source-atlas/research-import/` | active implementation | Local-only research seed importer exists. Research seeds are inputs, not production packs. Coverage Universe should follow the same derivative-boundary posture. |
| `tools/source-atlas/tests/` | active implementation | Python tests exist for current Source Atlas tools. New coverage proof should add local deterministic command validation rather than depending on network services. |
| `tools/mcp/ambitions_source_atlas_mcp/` | active implementation | Optional local MCP scaffold exists. Coverage tooling must not add write-capable or network MCP behavior. |
| `scripts/ambitions-source-atlas-title-check.py` | active implementation | Existing Source Atlas title/canon checker. Safe to include in validation ladder. |
| `scripts/sa-pack-schema-validate.sh` | active implementation | Existing advisory pack schema validation entry. Coverage validator should be additive and not replace it. |
| `scripts/sa-pack-validate.sh` | active implementation | Existing advisory pack validation entry. Coverage validator should be additive. |
| `scripts/sa-pack-duplication-scan.sh` | active implementation | Existing no-sprawl/duplication advisory scan. Coverage dedupe should extend this concern for generated scenarios/candidates. |
| `scripts/sa-source-freshness-scan.sh` | active implementation | Existing freshness advisory scan. Coverage recipes should stress stale/unknown/conflict states. |
| `scripts/sa-source-container-coverage-scan.sh` | active implementation | Existing source-container coverage scan. Overlaps conceptually with Coverage Universe but does not provide the requested combinatorial scenario generator. |
| `scripts/sa-user-source-not-official-scan.sh` | active implementation | Existing officialness boundary scan. Coverage validation must preserve this boundary. |
| `scripts/sa-pack-revocation-rollback-scan.sh` | active implementation | Existing revocation/rollback scan. Coverage promotion receipts should be reversible. |
| `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md` | canonical/supporting | Active supporting Source Atlas composition model according to prior SA/SAP reports. Safe to reuse; subordinate to truth files. |
| `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md` | canonical/supporting | Existing gate matrix. Coverage Universe reports should not override it. |
| `docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md` | canonical/supporting | Existing Codex OS map for Source Atlas. Coverage runbook should link conceptually without changing train authority. |
| `docs/codex/SOURCE_ATLAS_PROJECTION_QA_FIXTURE_FAMILIES.md` | canonical/supporting | Existing fixture family guidance. Coverage promotion destinations should align with fixture-family thinking. |
| `docs/audits/sa01-source-atlas-canon-lock-report.md` | generated derivative/supporting | Prior audit report. Useful historical evidence, not current proof. |
| `docs/audits/sa02-source-atlas-gate-matrix-report.md` | generated derivative/supporting | Prior gate-matrix audit. Useful, not proof of new Coverage Universe. |
| `docs/audits/sa03-universal-source-binder-coverage-map-report.md` | generated derivative/supporting | Prior coverage map report. Overlapping conceptually; not a combinatorial scenario generator. |
| `docs/audits/sap01-composable-pack-architecture-lock-report.md` | generated derivative/supporting | Establishes no one-pack-per-goal posture. Coverage Universe must comply. |
| `docs/audits/sap03-pack-factory-composition-rules-report.md` | generated derivative/supporting | Confirms Pack Factory should produce reusable graph pieces, overlays, proof maps, recipes, and aliases rather than goal-specific pack sprawl. |
| `docs/audits/sap05-no-sprawl-no-duplicate-pack-gate-report.md` | generated derivative/supporting | Confirms no-sprawl/no-duplicate gates and physical advisory scripts. Coverage Universe must not mass-commit generated junk. |
| `docs/audits/source-atlas-research-seeds-v1-local-import-report.md` | generated derivative/supporting | Establishes research seed import posture. Generated materials are seed inputs, not proof. |
| `docs/audits/source-atlas-source-truth-and-integration-report.md` | generated derivative/supporting | Earlier integration report. Useful for routing; not current implementation proof. |
| `docs/codex/fixtures/ldi/` | generated derivative | Existing small LDI fixture material. Coverage fixture promotion should remain bounded and receipt-backed. |
| `docs/proof/amb-fe-be/moat-scenario-proof-98/` | proof artifact | Existing proof packet for moat scenarios. It proves only its own logged run, not this Coverage Universe batch. |
| `prompts/batches/SA*.md` | generated derivative/supporting | Source Atlas batch prompts exist. Useful for traceability, not active proof. |
| `.codex/skills/source-atlas-composition-architect/` | active implementation/supporting | Existing Source Atlas composition reviewer skill. Safe to reuse in review posture. |
| `.codex/skills/pack-duplication-reviewer/` | active implementation/supporting | Existing duplication reviewer skill. Coverage dedupe should align with this posture. |
| `.codex/skills/source-claim-graph-architect.md` | active implementation/supporting | Existing source-claim reviewer guidance. Coverage contradiction checks should align. |
| `.codex/DerivedData/` and `output/DerivedData*` | stale/generated derivative | Build artifacts, unsafe to use as source truth and unsafe to inventory as active Source Atlas implementation. |

## Missing But Required For This Batch

- `source-atlas/coverage/dimensions.yaml`
- `source-atlas/coverage/recipes.yaml`
- `source-atlas/coverage/edge-case-classes.yaml`
- `source-atlas/coverage/mutation-rules.yaml`
- `source-atlas/coverage/quality-scoring.yaml`
- `source-atlas/coverage/promotion-policy.yaml`
- `source-atlas/coverage/scale-presets.yaml`
- ScenarioSpec, CandidateSourcePack, coverage report, and generation receipt schemas under `source-atlas/schemas/`
- Deterministic coverage expander, validator, scorer, dedupe, mutation, promotion, and report commands under `tools/source-atlas/`
- Bounded generated proof run with manifests/receipts and small promoted fixtures only
- Coverage matrix, heatmap, gap report, runbook, and final audit report

## Unsafe To Scale Without New Gates

- Generating one source pack per goal phrase.
- Committing thousands of generated ScenarioSpecs or candidate packs.
- Treating generated-only evidence as proof.
- Using stale or generated source context confidently.
- Promoting private/sensitive candidate material without privacy/local-only boundary fields.
- Allowing generated artifacts to imply app runtime behavior, official source approval, release proof, accessibility proof, or legal/privacy signoff.
- Adding API-key, network, hosted-model, or app-runtime dependency paths.

## Safe To Reuse

- Existing Source Atlas native domain vocabulary and validation posture.
- Existing `tools/source-atlas/` namespace.
- Existing advisory scan posture for no-sprawl, no-claim, freshness, and duplication.
- Existing local-only research seed posture.
- Existing proof-boundary language from truth files and Source Atlas reports.
- Existing small fixture/report pattern under `docs/audits/`, `docs/codex/fixtures/`, and `docs/proof/`.

## Implementation Boundary

This inventory authorizes an additive Coverage Universe layer only. It does not authorize app runtime behavior changes, new cloud services, hosted LLM dependencies, official source pack claims, release claims, or broad Source Atlas Factory replacement.
