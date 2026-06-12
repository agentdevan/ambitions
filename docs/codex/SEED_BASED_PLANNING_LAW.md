# Seed-Based Planning Law

Status: Active PLOS M00 governance law
Issue: AMB-639 / PLOS-003
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none

This law defines Source Atlas seed-based planning for PLOS execution. It does not implement seed generation, change Source Atlas models, add pack payloads, alter R2 distribution, implement source freshness, or rename existing Source Atlas types.

## Core Law

Source Atlas stores reusable seeds, not finished hardcoded Steps.

A seed is reusable source/pathing structure that can be composed with the user's local life context, source authority, path state, deadline physics, reflow constraints, and Step Quality Firewall. A Step is the runtime-composed result for a specific user, moment, capacity, proof state, and source envelope.

Production packs must not use exact-user hardcoded finished Steps as the main unit. The only exception is an explicitly user mini-pack/local-only value model that is not source truth, not public pack truth, and not share authority.

## Existing Model Anchors

AMB-639 inspected current source before installing this law. Existing seams include:

- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
  - `SourceAtlasStarterItem`
  - `SourceAtlasRequirement`
  - `SourceAtlasProofMap`
  - `SourceAtlasProjectionRecipe`
  - `SourceAtlasCompositionContract`
  - `SourceAtlasRuntimeBoundary`
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`
  - `SourceAtlasStepCandidateSeedTrace`
  - `SourceAtlasStepExpansionCandidateTrace`
  - `SourceAtlasStepExpansionRejectedSeedTrace`
  - `SourceAtlasStepExpansionTrace`
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift`
  - node, requirement, proof, starter, milestone, and fallback seed traces
  - source record IDs, source claim IDs, freshness warnings, sensitive context redactions
  - compiled Step fallback that is non-executable when safe source-backed expansion is unavailable
- `Native/Ambitions/Domain/SourceAtlasUserMiniPackBuilderModels.swift`
  - user mini-pack local-only/value-model boundary
  - user-provided claims that are not official source truth
- `Native/AmbitionsTests/**/SourceAtlas*.swift`
  - existing pack, store, bridge, coverage, and offline fallback coverage

These seams are source anchors. AMB-639 does not change or validate runtime output.

## Seed Types

PLOS seed taxonomy includes:

| Seed type | Purpose | Source authority expectation |
|---|---|---|
| starter seeds | Low-risk first action when full path authority is incomplete. | Must be labeled as starter guidance, not full source-backed pathing. |
| capability seeds | Reusable capability building blocks. | Must retain source, claim, requirement, and freshness links. |
| proof seeds | Evidence or receipt requirements needed before, during, or after execution. | Must bind to proof requirements and privacy class. |
| requirement seeds | Required conditions, documents, equipment, rules, or constraints. | Must carry requirement source state and review/freshness state. |
| prerequisite seeds | Before-you-start dependencies. | Must block or sequence Steps when missing. |
| recovery seeds | Safe recovery routes after interruption, failure, or changed reality. | Must avoid shame and preserve proof/reflow receipts. |
| replacement seeds | Alternative path candidates when a Step or path no longer fits. | Must preserve source authority and reason for replacement. |
| elasticity seeds | Shrink, extend, defer, split, merge, or re-scope behavior. | Must respect source, risk, and deadline envelopes. |
| path overlay seeds | Reusable overlays for role, path, requirement, proof, or projection variants. | Must identify dependency packs and overlay IDs. |
| momentum-tail seeds | Small follow-through actions that keep continuity after completion. | Must be optional and not become streak/score pressure. |
| jurisdiction seeds | Jurisdiction, age, eligibility, school, legal, travel, certification, or rule-specific constraints. | Must block authoritative pathing when jurisdiction is unknown. |
| deadline-protection seeds | Actions or reflows that protect a date or deadline. | Must be tied to deadline physics and source authority. |
| resource-light seeds | Lower-capacity alternatives when time, energy, money, access, or attention is constrained. | Must not erase proof or safety requirements. |
| location-compatible seeds | Location, access, mobility, or environment-compatible variants. | Must preserve privacy and local context boundaries. |
| split/merge seeds | Decompose or combine Steps when scale changes. | Must keep receipts and source traceability. |

Seed types may map to existing model strings or future typed models. This law does not require a rename or schema migration.

## Runtime Composition

Runtime-composed Steps require these inputs:

- user context
- source authority
- path state
- deadline physics
- reflow constraints
- Step Quality Firewall

Composition must also preserve:

- selected path and path overlays
- source record IDs
- source claim IDs
- requirement IDs
- proof requirement IDs
- starter item IDs when used
- freshness warnings
- sensitive context redactions
- local-only/private boundary
- replay or receipt references when behavior changes

The same seed can yield different Step results for different users or different moments because composition uses local life context. That variation is the Personal Life OS value. It must be inspectable and receipt-backed, not hidden mutation.

## Hardcoded Step Prohibition

No production pack should contain exact-user hardcoded finished Steps unless all of the following are true:

- it is explicitly a user mini-pack or local-only value model
- it is not public source truth
- it is not official-current authority
- it is not eligible for public sharing by default
- it cannot be reused as another user's source-backed Step
- it preserves correction, rejection, deletion, and review boundaries
- it carries local-only/private context boundaries

Forbidden production pack patterns:

- one pack per exact private goal
- finished Steps with private schedule, profile, proof, or receipt data
- finished Steps pretending to be source truth
- universal scheduled Steps detached from user context and source envelope
- hardcoded recommendations that bypass Step Quality Firewall
- hardcoded unsafe, legal, medical, financial, age-sensitive, or jurisdiction-sensitive instructions

Allowed source pack pattern:

- reusable seed plus source/proof/requirement/envelope metadata
- runtime composition creates the final Step locally for the user
- receipts explain why the Step exists and which seed/source constraints affected it

## Integration Points

Seed-based planning binds these PLOS laws and later phases:

- Any Goal Solution Loop: coverage demand records missing reusable seed types, not private finished Steps.
- Source Atlas Authority: seeds cannot drive current runtime behavior without eligible source state and applicability envelope.
- Step Quality Firewall: generated candidates must be rejected or degraded when generic, source-weak, unsafe, inaccessible, or uninspectable.
- Step Elasticity: elasticity seeds define shrink, extend, defer, split, merge, and replacement behavior without silent mutation.
- Life Consequence Reflow: replacement and recovery seeds must account for cross-goal consequences.
- High-Risk Safety: jurisdiction and risk seeds cannot be bypassed by starter guidance.
- Sharing: share projections can reference public-safe seeds and source summaries, not private user-composed Steps by default.

## Green Enforcement

Any future PLOS issue that claims seed coverage, source-backed pathing, reusable pack behavior, Generated Step quality, Step elasticity, coverage demand, replacement, recovery, or sharing eligibility must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first Source Atlas inspection
- explicit seed type or seed gap classification
- proof that source authority and applicability envelope remain attached through composition
- proof that final Steps are composed locally from user context and runtime constraints when runtime behavior is claimed
- explicit Step Quality Firewall relationship for generated candidates
- no exact-user hardcoded finished Steps in production packs
- clear user mini-pack/local-only exception boundaries
- no runtime implementation claim without source and validation proof

Yellow is allowed when the law/report is correct but future seed schema, pack proof, source authority proof, or runtime implementation proof remains owned. Red is required for treating Source Atlas as a hardcoded Step store, allowing finished hardcoded Steps as the main pack unit, conflating user mini-pack personalization with source truth, bypassing source-needed/review/stale/revoked states, PLOS label Linear access, or phase-order violation.

## Cross-Links

Primary authority:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `AGENTS.md`

PLOS law authority:

- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`

Source Atlas support authority:

- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `artifacts/source-atlas-factory/SAF_GOAL.md`
- `artifacts/source-atlas-factory/SAF-run-state.md`
- `.agents/skills/source-atlas-factory/SKILL.md`
- `scripts/sa-*.sh`
- `tools/source-atlas/**`

Proof for this law installation:

- `artifacts/personal-life-os/reports/PLOS-003-source-atlas-seed-laws-report.md`

## Non-Claims

This file does not prove:

- seed generation implementation
- Source Atlas runtime implementation
- source freshness implementation
- pack creation or production pack readiness
- R2 distribution readiness
- Step Quality Firewall implementation
- app source behavior
- source migration completion
- release readiness
- TestFlight or App Store readiness
- accessibility verification
- privacy or legal approval
- performance validation
- device validation
- owner approval
