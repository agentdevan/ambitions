# Signature Interface SwiftUI Architecture Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-85812687, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: SI01 architecture evidence; no app behavior implemented
Date: 2026-05-04
Owner batch: SI01 Signature Interface Canon To SwiftUI Architecture

## Purpose

This map translates PXOS experience intent into bounded SwiftUI owner families for the Signature Interface train. It is a planning artifact for SI02-SI18. It does not change production Swift, create routes, retire compatibility seams, add persistence, add dependencies, or claim SI/PXOS/Product Depth/AmbitionsOS implementation.

## Source Truth Read

- `docs/codex/batches/SI01_Signature_Interface_Canon_To_SwiftUI_Architecture_Prompt.md`
- `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md`
- `.codex/skills/signature-interface-creative-director.md`
- `.codex/review-boards/signature-interface-review-board.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/canon/PXOS_Visual_Interaction_System.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`

## Architecture Law

PXOS owns the intended experience. SI owns reusable native SwiftUI expression. ME protects file ownership. CS protects route/raw/external/import/export/persistence compatibility. PD composes SI primitives into drill-down depth after SI handoff. AOS may expose intelligence through SI only after source-truth, privacy, fallback, and trust gates.

The locked top-level surfaces remain `Today / Goals / Capture / Time / You`. SI must deepen these surfaces with rails, lanes, maps, composers, receipts, grouped navigation, and detail routes; it must not widen the product into new tabs, dashboards, inboxes, notes, habit modes, or AI wrapper surfaces.

## SwiftUI Owner Families

| SI family | Primary purpose | Likely SwiftUI owner area | Allowed future batches | Required gates |
| --- | --- | --- | --- | --- |
| Adaptive panels and actions | Shared material panels, action affordances, status density, module chrome | `Native/Ambitions/UI`, `Sources/`, `AppUI/Sources/` only when the active SI prompt names exact files | SI02 | SI creative direction, accessibility, Reduce Motion, file-size, preview |
| Shell and grouped navigation | Safe-area shell grammar, grouped rows, disclosure rows, top-level composition support | `Native/Ambitions/App`, `Native/Ambitions/Features/Profile`, shared UI only with CS proof | SI03, SI11, SI17 | IA/shell navigation, Profile/You compatibility, top-level composition |
| Today rail and hero | DayTimelineRail 2.0, Hero Step Panel, one clear Start here path | `Native/Ambitions/Features/Today` and shared primitives named by SI04/SI05 | SI04, SI05, SI17 | ME Today gates, accessibility, preview, anti-generic |
| Goals path and lanes | LifePath, Mission Control lanes, proof previews | `Native/Ambitions/Features/Goals` and shared primitives named by SI06/SI07 | SI06, SI07, SI17 | ME Goals gates, visual QA, accessibility |
| Plan life shape | Capacity, pressure, protected/free time, recovery/reflow objects | `Native/Ambitions/Features/Plan` and shared primitives named by SI08 | SI08, SI17 | ME Plan gates, Reduce Motion, cognitive load |
| Capture composer | Private intake atmosphere, placement reveal, route review | `Native/Ambitions/Features/Capture`, `Native/Ambitions/Domain` only when EB/CS owner proof allows | SI09 | Capture privacy, EB03 owner map, CS route/raw proof |
| Trust receipt layer | Proof, receipt, source, recovery, local-first trust UI | Shared UI plus owning surface feature files named by SI10 | SI10, SI17 | Privacy/trust/receipt, release-claim safety |
| Personal System Center | System profile header, trust summary, grouped controls | `Native/Ambitions/Features/Profile` for current internal owner while preserving visible `You` canon | SI11, SI17 | Profile/You compatibility, privacy/trust, accessibility |
| Motion and haptics | Meaningful state transitions, optional native haptic intent, Reduced Motion equivalents | Shared UI/interaction helpers only when exact owners are named | SI12 | Interaction/motion/haptics, Reduce Motion, performance |
| Empty/degraded states and symbols | Loading, empty, blocked, stale, source, proof, recovery status grammar | Shared UI and owning surface previews named by SI13/SI14 | SI13, SI14 | Copy/language, no color-only meaning, preview |
| Accessibility and preview QA | Adaptive interface pass, state matrix, previews, visual QA inventory | Tests/PreviewSupport/shared preview seams only when active batch owns them | SI15, SI16 | Accessibility, preview, validation evidence |

## Component State Matrix

Every future SI primitive must either implement or explicitly classify these states: normal, selected, focused, loading, empty, disabled, error/degraded, privacy-sensitive, reduced-motion, Dynamic Type, stale source, partial source, offline/local-only, blocked, waiting, needs review, recovery, overwhelming day, setup needed, denied source, and no data yet.

If a state is impossible for a primitive, the batch report must say why and name the nearest equivalent proof.

## Surface Composition Contracts

| Surface | Primary SI object | Detail belongs behind | Red drift |
| --- | --- | --- | --- |
| Today | DayTimelineRail + HeroStepPanel | Step Detail, Step Session, recovery, closure, proof/source detail | Generic task list, dense surface, shame recovery |
| Goals | LifePath + MissionControlLane | Goal Detail, Mission Control lanes, proof/history, alternate paths | KPI wall, project-management board, equal-card grid |
| Capture | CaptureAtmosphereComposer | Routing review, placement correction, grow-into-goal, source detail | Inbox clone, notes app, fake AI composer |
| Plan | LifeShapeMap | Day/week shape, reflow, pressure review, Life Shape detail | Calendar clone, capacity spreadsheet, analytics surface |
| You | Personal System Center + grouped navigation | Trust review, memory/data controls, setup defaults, receipts/history | Generic settings dump, profile vanity page, hidden trust controls |

## Motion And Tactility Contract

Motion must orient, confirm, or reduce uncertainty. It must not decorate state. Each future motion primitive must name source state, destination state, user purpose, Reduce Motion equivalent, VoiceOver behavior, Dynamic Type consideration, performance risk, and validation proof.

Haptic intent may be defined only as subtle, native, optional reinforcement for user-initiated confirmations, disclosures, receipts, closure, warnings, or rollback. SI01 implements no haptics.

## Evidence Requirements For SI02-SI18

Each UI-changing SI batch must record exact owner files, before/after Swift line counts, component state matrix, invented-but-native rubric scores, preview fixture names or screenshot limits, accessibility/Reduce Motion/Dynamic Type/VoiceOver/tap-target/non-color evidence, visual QA and anti-generic scan results, compatibility non-change proof where relevant, rollback path, and release-claim non-claims.

Docs-only SI batches may use source-truth and audit evidence instead of previews, screenshots, or builds, but must not imply UI was implemented.

## Invented-But-Native Baseline

| Category | Score | Evidence |
| --- | --- | --- |
| Originality | 4 | Names Ambitions-specific rails, lanes, maps, composers, receipts, and system center owners. |
| Native iPhone believability | 4 | Uses native SwiftUI, grouped navigation, safe-area shell, SF Symbol preference, and optional system haptics. |
| Usefulness | 4 | Maps every primitive family to surface purpose and later batch owner. |
| Restraint | 5 | No app behavior, no new tabs, no broad implementation, no asset/dependency changes. |
| Accessibility | 4 | Defines state matrix and evidence requirements for later UI batches. |
| Emotional tone | 4 | Preserves calm, premium, recovery-aware product identity without gimmicks. |
| System coherence | 5 | Aligns PXOS, SI, ME, CS, PD, AOS, and REC responsibilities. |
| Maintainability | 4 | Requires named owner files, line counts, previews, rollback, and file-size gates. |

Average: 4.25. Result: Green for docs architecture scope, with Yellow proof gaps owned by later UI implementation batches.

## Yellow Ledger

| Yellow | Why not Red | Owner |
| --- | --- | --- |
| No rendered screenshots or human visual approval | SI01 is architecture-only and changes no UI. | First UI-changing SI batch that can produce preview/screenshot evidence. |
| No physical-device, VoiceOver-human, Instruments, or battery proof | SI01 makes no runtime or release claim. | SI15/SI16 and release/operator proof lanes. |
| Exact Swift owner files for later primitives remain implementation-time decisions | SI01 names owner families; later prompts must name exact files before edits. | SI02-SI18 active batch reports. |

## Rollback

Revert the SI01 commit to remove this architecture map, audit report, and train-state advance. No production Swift, route/raw value, persistence/schema, dependency, workflow, signing, asset catalog, or app behavior rollback is required for SI01.

## Non-Claims

SI01 does not claim SI complete, PXOS implemented, Product Depth implemented, AmbitionsOS implemented, App Store readiness, TestFlight readiness, production readiness, physical-device proof, public accessibility proof, signed archive proof, legal/privacy signoff, human visual approval, screenshot proof, or final release decision.

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
