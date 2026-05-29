# SA01-SA32 Source Atlas Full Maturity Train

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active planned implementation train; blocked until selected by global order or explicit user approval.
Date: 2026-05-06
Train code: SA

## Required approval phrase

`Start Source Atlas Train`

The global full-stack order may also select SA batches when the user explicitly preauthorizes cross-train sequencing.

## Purpose

Implement Source Atlas as Ambitions’ signed, offline-first, claim-level world-source system with Universal Source Binder, Pack Factory, Claim Review, Freshness Broker, Composable Pack Graph, Goal Projection, and AOS/LDI integration.

Source Atlas exists so Ambitions can help users create trustworthy, personalized paths from life goals and external requirements without hallucinating, requiring a user-data server, breaking offline, duplicating one pack per goal, or overclaiming legal/career/education/professional certainty.

## Placement

Preferred placement:

1. HPS01-HPS12 Green or accepted Yellow with owners.
2. SAP01-SAP05 composition/projection lock.
3. SA01-SA32.
4. Deep AOS runtime batches.
5. LDI runtime batches.

If the live train has advanced, insert SAP/SA at the earliest safe point before any unimplemented AOS/LDI work that depends on real-world requirements, source packs, pack composition, user source import, freshness, claim review, goal projection, alternative pathing, or step generation.

## Train law

Source Atlas must strengthen trust without widening the visible app.

Forbidden:

- sixth tab
- Source Atlas surface
- source-pack marketplace
- public credential network
- official education/career database claim
- hosted AI backend
- user-data server
- direct live API dependency for core app behavior
- hidden claim mutation
- OCR-as-truth behavior
- legal/career/education/professional certainty
- internet-required core behavior
- one pack per individual goal phrase
- static same path for every user with same goal
- pro/elite path duplication of lower-level graph nodes
- packs generating final scheduled steps without AOS/LDI/Plan context

## SAP — Source Atlas Projection Lock Prephase

SAP batches must run before SA06 Pack Schema Implementation and before any real pack creation scales.

### SAP01 — Composable Pack Architecture Lock

Type: docs/architecture/gates.
Goal: Lock Source Atlas as composable domain/capability/overlay graph architecture, not one-pack-per-goal templates.
Allowed files: docs/codex, docs/canon, audit docs, Codex OS maps.
Acceptance: `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md` exists; no one-pack-per-goal, composable graph, highest-path reuse, and generated-step laws are explicit.
Hard Red: architecture treats individual goal strings as full source-pack owners.

### SAP02 — Goal Projection Object Model

Type: docs/schema planning.
Goal: Define GoalProjection, ProjectionProfile, PersonalPathInstance, ProjectionRecipe, StepCandidateSeed, AlternativePathSet, and OptionValueMap before runtime implementation.
Acceptance: SA schema work cannot begin until projection objects are referenced by train and gate matrix.
Hard Red: user goal maps directly to static pack/path without projection contract.

### SAP03 — Pack Factory Composition Rules

Type: docs/tooling contract.
Goal: Define how Pack Factory produces domain packs, capability graphs, overlays, proof maps, projection recipes, and aliases rather than isolated goal packs.
Acceptance: Pack Factory gates require composition contract, overlay dependency declaration, projection recipe validation, duplicate claim alias validation.
Hard Red: Pack Factory encourages duplicate claims/requirements across packs without stable aliases.

### SAP04 — Projection QA Fixtures

Type: docs/QA fixtures.
Goal: Add required fixture families for narrow skill goals, elite path reuse, alternative pathing, option value, official requirement overlays, and user-specific path variance.
Required scenarios:

- improve pickleball serve
- become pickleball pro
- learn pickleball
- make varsity football
- make it to the NFL
- improve football catching
- become football commentator
- become product manager
- become U.S. president
- get certification
- import school program page

Acceptance: SA fixture coverage cannot close without narrow skill slice, highest-path reuse, personalization, and alternative path tests.

### SAP05 — No-Sprawl / No-Duplicate Pack Gate

Type: Codex OS/gate integration.
Goal: Install reviewer skills/scripts and source-order hooks so Codex rejects one-pack-per-goal sprawl, pack duplication, and static path output.
Acceptance: Source Atlas Codex OS map references composition/projection reviewers and scripts; later SA batches invoke them.
Hard Red: SA implementation proceeds without ownership of composition/projection gates.

## Phase 0 — Source Truth And Codex OS

### SA01 — Source Atlas Canon Lock

Type: docs/canon.
Goal: Lock Source Atlas thesis, boundaries, supported source types, source states, freshness states, risk classes, UI law, completion standard, and composition/projection inheritance.
Allowed files: docs/canon, docs/codex, audit docs.
Acceptance: `docs/canon/Ambitions_Source_Atlas.md` exists and forbids Source Atlas surface, official overclaim, hosted AI/user-data server, hidden mutation, internet dependency, and one-pack-per-goal sprawl.

### SA02 — Source Atlas Gate Matrix

Type: docs/gates.
Goal: Add hard gates for source container coverage, PDFKit extraction, OCR review-required, URL snapshots, user-provided-is-not-official, high-risk source review, offline fallback, pack validation, revocation/rollback, private document protection, rendered source-state proof, composable pack graph, goal projection, skill slicing, highest-path reuse, generated-step boundaries, and option value.
Acceptance: `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md` exists and Source Atlas-dependent work cannot close Green without invoked or owned gates.

### SA03 — Universal Source Binder Coverage Map

Type: docs/coverage.
Goal: Define full support for URL, PDF, screenshot/image, copied text, local file, official pack, user mini-pack, and document categories rulebook/school page/job posting/certification handbook.
Acceptance: every supported type has import, extraction, failure, privacy, review, and rendered-proof requirements.

### SA04 — Source Atlas Codex OS Upgrade

Type: Codex OS docs/scripts/skills.
Goal: Add Source Atlas reviewer skills, advisory scripts, composition/projection reviewers, report requirements, stop conditions, and CQS/FVQ invocation triggers.
Acceptance: skill/script map exists and later batches must create or invoke physical skills/scripts before closing relevant implementation work.

### SA05 — Source Atlas Global Order And Integration Lock

Type: docs/global-order integration.
Goal: Insert or overlay Source Atlas after HPS and before deep AOS/LDI; update integration maps.
Acceptance: global order overlay and AOS/LDI/FCP/PFC/HPS integration map exist.

## Phase 1 — Core Data Model

### SA06 — Pack Schema Implementation

Type: Swift domain model + fixtures.
Goal: Implement SourceAtlasPack, manifest, source record, claim, requirement, starter item, proof map, freshness policy, risk policy, disclosure copy, fixture types, and composition/projection primitives from SAP.
Acceptance: typed Codable models, sample pack decode tests, invalid schema tests, composition schema tests, no production network behavior.

### SA07 — Claim State Machine

Type: Swift domain model/tests.
Goal: Implement official, semiOfficial, expert, community, maintainerCurated, userProvided, userConfirmed, imported, inferred, ocrDerived, stale, staleCritical, sourceChanged, disputed, revoked, unsupported, private, unknown states.
Acceptance: state transitions tested; user-provided/OCR cannot become official without explicit validated source bridge.

### SA08 — Requirement Graph Implementation

Type: Swift domain model/tests.
Goal: Implement hard/soft/prerequisite/equipment/skill/proof/deadline/blocker/accelerator/review-required requirement nodes and edges, plus RequirementOverlay composition.
Acceptance: requirement graph can attach source/freshness/risk states and cannot mark source-free official requirements.

### SA09 — Proof Map Implementation

Type: Swift domain model/tests.
Goal: Map requirements/capability nodes to proof candidates, proof strength, proof privacy, correction/revocation hooks, and Evidence Ledger bridge.
Acceptance: proof is user-owned evidence, not score; proof-to-requirement mapping is source/claim-bound.

### SA10 — Freshness And Risk Model Implementation

Type: Swift domain model/tests.
Goal: Implement freshness states, review intervals, high-risk stale blocking, and risk classes.
Acceptance: staleCritical high-risk claims cannot drive recommendations as current.

## Phase 1.5 — Composition And Projection Runtime

### SA10A — Capability Graph / Level Ladder Implementation

Type: Swift domain model/tests.
Goal: Implement DomainPack, SpecificDomainPack, CapabilityGraph, CapabilityNode, CapabilityEdge, LevelLadder, RoleOverlay, PathOverlay.
Acceptance: narrow skill slice and highest-path reuse fixtures pass.

### SA10B — Goal Projection Engine Contract

Type: Swift runtime contract/tests.
Goal: Implement GoalProjection, ProjectionProfile, ProjectionRecipe, PersonalPathInstance, StepCandidateSeed, AlternativePathSet, OptionValueMap.
Acceptance: user goals produce projections rather than static paths; different users can receive different PersonalPathInstances from the same source graph.

### SA10C — Projection Fixtures And No-Sprawl Validation

Type: tests/tools.
Goal: Add fixtures for pickleball skill slice/pro path, football varsity/NFL/commentator paths, U.S. president strict source overlay, job posting example-only path, and school program strict review.
Acceptance: no one-pack-per-goal scan, pack duplication scan, and projection fixture scan pass or create accepted Yellow with owner.

## Phase 2 — Runtime

### SA11 — Source Atlas Store

Type: Swift runtime/tests.
Goal: Load bundled/cached packs, validate schema/hash metadata, quarantine invalid packs, provide last-known-good fallback.
Acceptance: no internet required; missing/corrupt packs fail into source-needed/stale fallback.

### SA12 — Source Atlas Query Engine

Type: Swift runtime/tests.
Goal: Query packs by goal/domain/claim/requirement/source state and return ranked source candidates without fake confidence.
Acceptance: query results expose source/freshness/uncertainty and fallback state.

### SA13 — Source Needed Mode

Type: Swift runtime/UI seam/tests.
Goal: Add first-class source-needed result when exact/current pack is unavailable.
Acceptance: app can help from starter/meta guidance while blocking official/current claims.

### SA14 — Local Impact Matcher

Type: Swift runtime/tests.
Goal: Join public changed claim IDs to local goals privately.
Acceptance: no user data leaves device; source-impact receipts can be generated locally.

### SA15 — Offline Fallback Runtime

Type: Swift runtime/tests.
Goal: Ensure no internet, unreachable manifest, needs review download, stale cache, and missing pack states degrade safely.
Acceptance: no blank failure or crash; source/freshness copy is honest.

## Phase 3 — Universal Source Binder

### SA16 — Source Container Model

Type: Swift domain model/tests.
Goal: Implement unified SourceContainer types for URL, PDF, image, plain text, local file, official pack, and user mini-pack.
Acceptance: every container carries privacy, source, extraction, review, and failure state.

### SA17 — URL Source Importer

Type: Swift importer/tests.
Goal: Support pasted/share URLs, content-type detection, redirects/canonical URL, source hash, extraction quality, and failure fallback.
Acceptance: URL import never labels source official by default and never mutates without review.

### SA18 — Plain Text Importer

Type: Swift importer/tests.
Goal: Normalize copied/pasted text, classify source category, produce review-required candidates.
Acceptance: copied text is user-provided/unknown source unless linked to validated source.

### SA19 — PDF Import Boundary

Type: Swift importer/UI seam/tests.
Goal: Support local/PDF URL route, locked/corrupt/huge/partial/no-text/private states before extraction.
Acceptance: PDF failures are readable and safe; private PDFs are protected.

### SA20 — PDFKit Text Extraction

Type: Swift importer/tests.
Goal: Extract embedded PDF text with page locators and source hash.
Acceptance: page-aware text blocks, partial extraction handling, review-required claim candidates.

### SA21 — Vision OCR Fallback

Type: Swift importer/tests.
Goal: OCR scanned PDF pages and screenshots/images using Vision route.
Acceptance: OCR-derived output is always review-required and cannot become official/current silently.

### SA22 — Image / Screenshot Importer

Type: Swift importer/tests.
Goal: Support image/screenshot import, OCR quality labels, manual correction, private state.
Acceptance: screenshot claims are user-provided/OCR-derived and review-required.

### SA23 — Document Type Classifier

Type: Swift deterministic classifier/tests.
Goal: Classify rulebook, school program page, job posting, certification handbook, official page, generic text, legal/civic/professional source.
Acceptance: categories drive risk/review rules but do not imply official truth.

### SA24 — Claim Candidate Extractor

Type: Swift deterministic extractor/tests.
Goal: Extract candidate requirements, deadlines, equipment, prerequisites, proof, unknowns, and warnings.
Acceptance: candidates are review-required and include source locators where possible.

### SA25 — Source Review Sheet / Claim Review Drawer

Type: SwiftUI/UI tests/FVQ.
Goal: Implement confirm/edit/reject/private/needs official review/do-not-use/delete flow.
Acceptance: no hidden mutation; rendered proof for all key source states.

### SA26 — User Mini-Pack Builder

Type: Swift runtime/tests.
Goal: Build local private mini-pack from confirmed user claims.
Acceptance: local-only, deletable, correctable, rejectable, private-state aware.

## Phase 4 — Pack Factory And Freshness

### SA27 — Pack Factory Lite

Type: tools/source-atlas scripts/schemas/tests.
Goal: Build and validate packs from JSON/YAML, including composable domain/capability/overlay/projection recipe packs.
Acceptance: pack schema validation, composition validation, fixtures, no-claim scan hooks, sample packs.

### SA28 — Pack Diff / Changed Claim Tooling

Type: tools/source-atlas.
Goal: Generate changed claim IDs, changelog, impacted requirements, and stale/revoked/disputed flags.
Acceptance: diff output can feed future freshness manifest.

### SA29 — Hash / Signature / Revocation Tooling

Type: Swift/runtime + tools contract/tests.
Goal: SHA-256 validation now, signature/revocation/rollback path.
Acceptance: invalid/revoked/corrupt packs are quarantined and old pack remains safe.

### SA30 — Freshness Broker Manifest Contract

Type: docs/tools/runtime seam/tests.
Goal: Define atlas manifest, pack index, changed claim IDs, hashes, signatures, revocation list, rollback pointers, and local update receipt.
Acceptance: public non-personal; no user-data server; app works when unreachable.

### SA31 — Official Source Adapter Contracts

Type: tools/docs/contracts.
Goal: Define official page/PDF and API adapter contracts for Data.gov catalog, O*NET, BLS, Census, USAJOBS, FEC, USAspending, and future sources.
Acceptance: adapters are factory inputs, not app runtime dependencies; no API key in app bundle.

## Phase 5 — UI, QA, And Integration

### SA32 — Source Atlas UI Primitives / QA / Handoff

Type: SwiftUI + tests + FVQ + docs.
Goal: Add SourceBadge, FreshnessBadge, SourceNeededFold, RequirementSourceFold, ClaimReviewDrawer, SourceBinderReviewSheet, PackUpdateReceipt, PrivateSourceShield, OCRReviewNotice, SourceImpactReceipt, ProjectionReceiptFold, SkillSliceIndicator, AlternativePathReceipt, OptionValueFold; close QA/handoff.
Acceptance: rendered proof covers source-backed, source-needed, user-provided, stale, source-changed, disputed, revoked, private source, OCR low-confidence, partial PDF extraction, review-needed, no internet, high-risk strict-review, projection receipt, skill slice, alternative path, still-counts option value, Dynamic Type-adjacent, and reduced-motion equivalent states.

## Common validation

Every SA/SAP batch must run or document inability to run:

- `git status --short`
- `git diff --check`
- relevant unit/UI/focused tests
- `scripts/sa-source-container-coverage-scan.sh || true`
- `scripts/sa-pack-schema-validate.sh || true`
- `scripts/sa-no-claim-scan.sh || true`
- `scripts/sa-offline-fallback-scan.sh || true`
- `scripts/sa-composition-projection-scan.sh || true`
- `scripts/sa-pack-duplication-scan.sh || true`
- `scripts/sa-projection-fixture-coverage-scan.sh || true`
- relevant CQS/FVQ scripts

## Closeout

SA is complete only when all source containers and document categories are either fully supported or explicitly removed from scope, no Source Atlas-dependent AOS/LDI path can hallucinate official requirements, every goal is compiled through composable graph/projection rules rather than one-off goal packs, and all source/freshness/projection states have tests and rendered proof where visible.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
