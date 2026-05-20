# AMB_MOAT_OS_IMPLEMENTATION_MAP

## Scope

This document is the master moat map for installer phase 24+ consolidation.

## Moat entries

### Category moat: Personal Life OS
- **Definition:** A private life runtime-first system, not a generic productivity app, task manager, calendar clone, habit tracker, dashboard, or chatbot.
- **Why defensible:** Core promise ties to daily reality, mission integrity, and inspectable evidence.
- **Owner:** Product design + Codex governance docs.
- **Downstream batches:** `AMB-CATEGORY-PERSONAL-LIFE-OS-CANON-01`
- **Proof states:** Yellow if claims are pending; Green only with runtime and release evidence.
- **Canonical IA:** `Today / Goals / Capture / Time / You`, with `Plan` as a compatibility seam only.

### Runtime moat: Private Life Runtime
- **Definition:** Local deterministic decision core.
- **User-visible value:** Relevant recommendations with continuity and replay.
- **Owner:** `Native/Ambitions/Domain` + runtime docs.
- **Downstream batches:** `AMB-RUNTIME-PRIVATE-LIFE-RUNTIME-L0L1-02`
- **Required contracts:** `StartHereDecisionPacket`, `RealityMeridianProjection`, `RuntimeDecisionIR`, `CandidateRankingLedger`, `ConstraintFirewall`, `RuntimeCritic`, `DecisionReplayContract`
- **Runtime artifacts:** `RuntimeUnavailableState`, `RealityLedger`, `IntelligenceEventLedger`

### Intelligence moat
- **Definition:** Deterministic candidate competition + critic + replay.
- **Owner:** runtime + closure runtime teams.
- **Downstream batches:** `AMB-INTELLIGENCE-DETERMINISTIC-CANDIDATE-COMPETITION-04`, `AMB-INTELLIGENCE-CLOSURE-LEARNING-LOCAL-MEMORY-05`
- **State states:** warm-start, source freshness invalidation, blocked-goal unstick path, runtime unavailable, stale source, recovery review.
- **Validation:** projection and runtime validators plus fixture completeness, replay identity, and not-chosen reason coverage.

### Proof moat
- **Definition:** Every recommendation is explainable and replayable.
- **Owner:** proof receipt authorship and Codex review lanes.
- **Downstream batches:** `AMB-PROOF-RECEIPTS-FRESHNESS-WHY-NOT-CHOSEN-06`
- **Required projections:** `NotChosenReasonsProjection`, `TrustReceiptProjection`, `ProofTrailProjection`

### Visual moat
- **Definition:** Personal Reality Instrument projects stateful truth, not task dashboards.
- **Owner:** visual canonical implementation lane.
- **Downstream batches:** `AMB-VISUAL-PERSONAL-REALITY-INSTRUMENT-FOUNDATION-07`, `AMB-VISUAL-FLAGSHIP-SURFACES-TODAY-GOALS-CAPTURE-TIME-YOU-08`
- **Required objects:** Reality Meridian, LifeShape Field, Constellation Atlas, Atmosphere Composer.

### Trust moat
- **Definition:** Local-first, privacy-honest, no required backend dependencies.
- **Owner:** trust+privacy lane.
- **Downstream batches:** `AMB-TRUST-LOCAL-FIRST-PRIVACY-HONESTY-USER-CONTROLS-09`
- **Proof checks:** offline, delete/reset, export, redaction states.

### Continuity moat
- **Definition:** Apple-native sync continuity with conflict and restore truth.
- **Owner:** continuity lane.
- **Downstream batches:** `AMB-CONTINUITY-APPLE-NATIVE-CONFLICT-RESTORE-PROOF-10`
- **Hard boundaries:** no claim of sync/restore without conflict/degraded state proof.

### Accessibility moat
- **Definition:** Dense runtime intelligence has semantic equivalents.
- **Owner:** accessibility lane.
- **Downstream batches:** `AMB-ACCESSIBILITY-SEMANTIC-EQUIVALENTS-DENSE-RUNTIME-11`

### Codex moat
- **Definition:** validator and batch governance to prevent drift and false Green.
- **Owner:** Codex lane.
- **Downstream batches:** `AMB-CODEX-BATCH-TRAINS-VALIDATORS-HARD-RED-ROLLBACK-12`
- **Commands:** `scripts/ambitions_validate_*.py`, `make validate-ambitions-os`.

### Release moat
- **Definition:** release and screenshot claims bound to proof.
- **Owner:** release lane.
- **Downstream batches:** `AMB-RELEASE-CLAIM-REGISTRY-PROOF-SCREENSHOT-CANDIDATE-13`

### Integrated polish / no false green moat
- **Definition:** freeze pass that blocks unsupported maturity claims.
- **Downstream batches:** `AMB-MARKET-DEFINING-INTEGRATED-POLISH-14`, `AMB-OS-INTEGRATED-FREEZE-NO-FALSE-GREEN-15`

## Required enhancement integration points

- instant Today projection cache
- runtime warm-start
- precomputed Start Here candidates
- deterministic candidate ranking ledger
- constraint firewall before ranking
- runtime critic with explicit rejection reasons
- decision replay identity and source snapshot binding
- incremental projection invalidation
- app-open source freshness refresh
- offline command queue
- state restoration snapshot
- Reality Signature
- decision replay identity
- not-chosen reasons
- closure outcome attribution
- recovery-first selection
- local memory controls
- cross-surface consistency checks
- evidence fields for all surface snapshots

Each enhancement is assigned to one or more moats in this map and must inherit the same contract and validator ownership.

## Hard Red stop conditions

- claim of release or false proof states.
- duplicate batch IDs.
- prompt header missing or malformed.
- missing required contracts or missing owners.
- active IA drift to old top-level structures.
- decision packets without a non-selected reason code and privacy-safe reason text.

## Rollback expectation

- Revert changed docs files in the scope lists.
- Re-run authority and validator suites before reattempt.
