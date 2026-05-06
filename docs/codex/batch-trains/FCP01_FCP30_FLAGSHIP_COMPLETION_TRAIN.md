# FCP01-FCP30 Flagship Completion Train
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth; queued implementation train after Product Depth closeout unless explicitly inserted by user approval.
Date: 2026-05-05
Train code: FCP

## Required User Approval Phrase

`Start Flagship Completion Train`

No other phrase starts FCP implementation. Creating this train, referencing it, updating global order, or adding source truth does not start production Swift implementation.

## Purpose

FCP turns the Ambitions 10/10 Flagship Completion Plan into sequenced, gated implementation. It upgrades every major primitive, component, surface, object, state, motion, trust, proof, accessibility, and QA layer to the 10/10 flagship bar without widening Ambitions beyond Today / Goals / Capture / Plan / You.

## Train Type

Product-object implementation / signature interface upgrade / cross-surface maturity / accessibility and trust closure.

## Source Truth Stack

1. `README.md`
2. `AGENTS.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_Product_Experience_OS_Index.md`
5. `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
6. `docs/canon/Ambitions_Signature_Interface_System.md`
7. `docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md`
8. `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
9. `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
10. `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
11. `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
12. `docs/codex/BATCH_REGISTRY.md`
13. `docs/codex/CONTEXT_INDEX.md`
14. `.codex/reports/current-run-state.md`
15. `.codex/reports/current-batch-train-state.md`

## Relationship To Existing Trains

- Product Depth remains active through PD15 Green in current run-state evidence.
- PD16-PD18 remain queued Product Depth continuation before broad FCP
  implementation unless the global full-stack order selects a stricter
  prerequisite first.
- FCP docs/planning foundation may proceed under the global full-stack approval.
  FCP production Swift implementation still requires the selected batch to
  authorize implementation and prove file boundaries.
- FCP does not retire CS seams, alter route/raw values, add dependencies, change persistence/schema, or claim release readiness by itself.
- FCP may compose SI, DAV, EB, PD, ME, and CS evidence only where source truth and owner files allow it.

## Global Stop Conditions

Stop on any hard Red:

- new top-level tab
- top-level dashboard/grid/card-stack structure
- calendar clone
- inbox/feed/notes-app drift
- habit/streak/trophy drift
- AI chatbot wrapper
- user-facing confidence score
- unsupported AI/LDI/runtime claim
- unsupported privacy/legal/export/delete claim
- unsupported release/App Store/TestFlight/platform claim
- public accessibility claim without evidence
- hidden mutation or silent plan change
- route/raw-value/persistence/schema compatibility break
- dependency/workflow/signing/entitlement change without explicit approval
- weak implementation validation
- missing focused tests for implementation
- file-size Red without extraction plan
- source-truth conflict

## Common Required Skills

Use relevant `.codex/skills/*` where present:

- `xctest-builder.md`
- `batch-registry-reconciler.md`
- `copy-guard-runner.md`
- `faang-handoff-auditor.md`
- `voiceover-label-auditor.md`
- `screenshot-readiness-reviewer.md`
- `meridian-shell-builder.md`
- `goal-ux-designer.md`
- `plan-ux-designer.md`
- `day-shape-builder.md`
- `trust-ux-designer.md`
- `personalization-source-label-auditor.md`
- `full-regression-escalation-skill.md`
- `flake-classifier.md`

## Common Validation

Every implementation batch must run or explicitly document inability to run:

- `git status --short`
- `git diff --check`
- `xcodegen generate` if project generation may be affected
- focused `xcodebuild` tests for changed owner files
- `scripts/build-local.sh`
- product drift scan
- copy/release-claim scan
- accessibility and Reduce Motion advisory scan
- file-size/diff-size review
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Docs-only batches must verify no production Swift, route/raw-value, persistence/schema, workflow, dependency, signing, entitlement, generated project, CI/config, or app behavior changed.

## Batch Order

### FCP01 — Flagship Completion Source Truth Lock

Type: Docs/planning.
Owner: Cross-surface.
Depends on: user authorization; Product Depth state inspected.
Goal: Lock FCP source truth and make the 10/10 object standard discoverable.
Allowed files: FCP docs, registry/context/run-state pointers.
Required output: source-truth report.
Stop if: any production Swift or app behavior changes.
Status: Complete Green on 2026-05-05 as docs-only source-truth lock.
Evidence: `docs/audits/fcp01-flagship-completion-source-truth-lock-report.md`.

### FCP02 — Object Vocabulary And Anatomy Lock

Type: Docs/planning.
Owner: Cross-surface design system.
Depends on: FCP01.
Goal: Lock Surface, Rail, Spine, Thread, Edge, Fold, Drawer, Pocket, Field, Receipt, Proof, Closure, Lens, Resolver, Center as implementation vocabulary.
Required output: anatomy table and object acceptance rules.
Stop if: vocabulary introduces new top-level destinations.
Status: Complete Green on 2026-05-05 as docs-only vocabulary/anatomy lock.
Evidence: `docs/audits/fcp02-object-vocabulary-anatomy-lock-report.md`.

### FCP03 — Ownership / File Boundary / Dependency Map

Type: Docs/planning.
Owner: Architecture / maintainability.
Depends on: FCP02.
Goal: Map all 25 objects to likely files, tests, previews, dependencies, and risk owners.
Required output: boundary map update.
Stop if: route/raw/persistence/schema changes are authorized without explicit owner proof.
Status: Complete Green on 2026-05-05 as docs-only ownership/file-boundary/dependency map.
Evidence: `docs/audits/fcp03-ownership-file-boundary-dependency-map-report.md`.

### FCP04 — Preview Fixture And QA Matrix Expansion

Type: Mixed docs/test-fixture planning; no production UI.
Owner: PreviewSupport / QA.
Depends on: FCP03.
Goal: Expand preview scenario requirements for normal/loading/empty/private/stale/blocked/recovery/overloaded/reduced-motion/Dynamic Type states.
Stop if: preview work changes production behavior.
Status: Complete Green on 2026-05-05 as docs-only preview/QA matrix expansion.
Evidence: `docs/audits/fcp04-preview-fixture-qa-matrix-expansion-report.md`.

### FCP05 — Start Here Surface

Status: Complete Green on 2026-05-05 as Today-owned Start Here Surface
implementation. It replaces the Hero Step card posture with typed Context Edge,
Time Fit Proof, Goal Thread, source-quality, because-line, primary/secondary
actions, and FCP06 Receipt Drawer seam evidence.
Evidence: `docs/audits/fcp05-start-here-surface-report.md`.

Type: Implementation.
Owner: Today.
Depends on: FCP01-FCP04; SI05; SI10; PD02/PD03/PD04 evidence.
Goal: Replace Hero Step card posture with StartHereSurface.
Likely files: TodayDayRailPanels, DayRailViewState, TodayExecutionProjector, DayRailProjection, Today tests, PreviewTodayScenarios.
Required primitives: StartHereSurface, ContextEdge, TimeFitProof, GoalThread, ReceiptDrawer seam.
Acceptance: not a generic card; explains why now, source, time fit, goal thread, privacy, receipt.

### FCP06 — Receipt Drawer / Trust Layer

Status: Complete Green on 2026-05-05 as shared Receipt Drawer and Source Fold
foundation. Start Here attachment is deferred to FCP05 under the newer global
order because FCP05 was not complete when FCP06 ran.

Type: Implementation.
Owner: Shared Trust.
Depends on: FCP01-FCP04; SI10; DAV09; EB17/EB18 where relevant. The older
FCP05 dependency applies to Start Here attachment, not the shared trust
foundation.
Goal: Create reusable ReceiptDrawer and SourceFold; attach to Start Here first.
Likely files: TrustReceiptLayerPrimitives, DynamicAdaptiveVisualPrimitives, Today integration, tests/previews.
Acceptance: every receipt answers what happened, why, source, freshness, privacy, change, undo/correction/review.
Evidence: `docs/audits/fcp06-receipt-drawer-trust-layer-report.md`.

### FCP07 — Reality Rail Continuity

Type: Implementation.
Owner: Today.
Depends on: FCP05-FCP06; SI04; PD02-PD04.
Goal: Make Start Here, Now/Next/Later, closure, proof, and pressure one continuous Reality Rail object.
Acceptance: no agenda clone; closure knots and proof markers are integrated.
Evidence: `docs/audits/fcp07-reality-rail-continuity-report.md`.

### FCP13A — Action Closure Diamond

Type: Implementation.
Owner: Today / Action Closure.
Depends on: FCP05-FCP07; PD04; FCP06.
Goal: Upgrade the existing Today closure sheet into a closure / decision
Diamond that explains Outcome, Consequence, Proof, and Recovery before any
confirmation.
Acceptance: no hidden mutation; no proof-as-achievement; no feed posture;
accessibility, Dynamic Type, and Reduce Motion equivalents are present.
Status: Complete Green on 2026-05-05 as Today-owned Action Closure Diamond
implementation.
Evidence: `docs/audits/fcp13a-action-closure-diamond-report.md`.

### FCP08 — Ambition Meridian Shell

Type: Implementation.
Owner: Shell / navigation.
Depends on: FCP04; SI03; SI17.
Goal: Create familiar native shell with proprietary meridian chrome and receipt overlay zone.
Acceptance: no hidden nav; five tabs preserved; compact contextual header is accessible.
Status: Complete Green on 2026-05-05 as default Meridian shell presentation
with native rollback and focused shell proof.
Evidence: `docs/audits/fcp08-ambition-meridian-shell-report.md`.

### FCP09 — Motion / Haptics / Reduced Motion Proof

Type: Implementation.
Owner: Shared design system.
Depends on: FCP05-FCP08; SI12; DAV10.
Goal: Object-specific motion/haptic policies for Start Here, Rail, Drawer, Fold, Spine, Closure, LifeShape, Capture.
Acceptance: no motion-only meaning; every motion has reduced-motion equivalent.
Status: Complete Green on 2026-05-05 as shared object-motion policy evidence
for Start Here, Reality Rail, Receipt Drawer, Source Fold,
MissionControlTimeSpine, Action Closure Diamond, LifeShape Map, and Capture
Atmosphere Composer.
Evidence: `docs/audits/fcp09-motion-haptics-reduced-motion-proof-report.md`.

### FCP10 — MissionControlTimeSpine

Type: Implementation.
Owner: Goals.
Depends on: FCP06; PD05-PD08; SI07; DAV06.
Goal: Replace Mission Control grid as primary object with MissionControlTimeSpine.
Acceptance: Completed / Now / Friction / Next / Horizon preserved; no dashboard grid.

### FCP11 — LifePath Thread

Type: Implementation.
Owner: Goals.
Depends on: FCP10; SI06; PD06-PD08.
Goal: Replace path-card feel with LifePathThread, proof beads, risk pinch, alternate branch fold.
Acceptance: private path redaction; non-color state meaning; accessible path order.

### FCP12 — Proof Spine / Evidence Ledger

Type: Implementation.
Owner: Goals / Trust.
Depends on: FCP06, FCP10, FCP11, PD07.
Goal: Create shared ProofSpine used by Today, Goals, Plan, and You as later integration allows.
Acceptance: proof has source/freshness/privacy/correction/stale behavior.

### FCP13B — Goal Alternate Path / Decision History Polish

Type: Implementation.
Owner: Goals.
Depends on: FCP11-FCP12; PD08.
Goal: Upgrade alternate routes and decision history into native folds/spine branches, not cards/lists.
Acceptance: no automated reroute; no PM dashboard.

### FCP14 — LifeShape Contour Map

Status: Complete Green on 2026-05-06 as bounded Plan LifeShape Contour Map
implementation evidence.
Type: Implementation.
Owner: Plan.
Depends on: PD14; SI08; DAV05.
Goal: Replace bar/card LifeShape expression with contour/pocket/field map.
Acceptance: no calendar grid, no bar chart as primary object, protected pockets and pressure fields visible.

### FCP15 — Reflow Decision Fold

Status: Complete Green on 2026-05-06 as bounded Plan Reflow Decision Fold
implementation evidence.
Type: Implementation.
Owner: Plan.
Depends on: FCP14; PD12.
Goal: Before/after Decision Fold for reflow changes.
Acceptance: accept/edit/decline; no silent rearrangement; protected-time proof visible.

### FCP16 — Pressure Field / Recovery Loop

Type: Implementation.
Owner: Plan / Today.
Depends on: FCP14-FCP15; PD13; PD04.
Goal: Shared pressure and recovery object language.
Acceptance: no shame copy; overloaded day produces smaller safe next step and receipt.
Status: Complete Green on 2026-05-06 as bounded Plan / Today implementation.
It added shared Pressure Field / Recovery Loop object language to Plan's
pressure review and Today's recovery bloom, kept the smaller safe next step
first for overloaded Today, and preserved no shame copy, no silent mutation,
Calendar write, route/raw-value, persistence/schema, sync/cloud, release,
legal/privacy, public accessibility, AOS runtime, or LDI runtime claims.
Evidence: `docs/audits/fcp16-pressure-field-recovery-loop-report.md`.

### FCP17 — Schedule / Availability / Defaults Center

Type: Implementation.
Owner: You / Plan.
Depends on: PD16 preferred; EB21/EB22 boundaries.
Goal: Create AvailabilityCenter from Schedule, Planning Defaults, Automation Trust, Vacation/Away, Durations.
Acceptance: hard context wins; open time not auto-filled; Guided default; vacation not free time unless marked.
Status: Complete Green on 2026-05-05 as a bounded You-owned Availability Center
implementation. It added typed Availability Center state, a Schedule &
Availability detail card, and focused Profile tests without route/raw-value,
persistence/schema, permission-request, calendar-write, sync/account, release,
legal/privacy, or public accessibility claims.
Evidence: `docs/audits/fcp17-schedule-availability-defaults-center-report.md`.

### FCP18 — Capture Placement Shelf

Status: Complete Green on 2026-05-06 as bounded Capture Placement Shelf
implementation evidence.
Type: Implementation.
Owner: Capture.
Depends on: FCP06; PD09; SI09; DAV04.
Goal: Upgrade route reveal into Placement Shelf.
Acceptance: text-first composer; destination/consequence/privacy/source/correction visible; no inbox.

### FCP19 — Placement Resolver / Correction Fold

Status: Complete Green on 2026-05-06 as bounded Placement Resolver /
Correction Fold implementation evidence.
Type: Implementation.
Owner: Capture.
Depends on: FCP18; PD10.
Goal: Resolver Fold with correction receipts.
Acceptance: no hidden learning; no model confidence; correction choices preserve user control.

### FCP20 — Grow Into Goal Seed Incubator

Status: Complete Green on 2026-05-06 as bounded Goal Seed Incubator
implementation evidence.
Type: Implementation.
Owner: Capture / Goals.
Depends on: FCP18-FCP19; PD11.
Goal: Upgrade grow-into-goal into Goal Seed Incubator.
Acceptance: explicit promotion confirmation; no automatic goal creation.

### FCP21 — Voice / Motor Capture Accessibility

Status: Complete Green on 2026-05-06 as bounded Capture composer
input-alternatives implementation evidence.
Type: Implementation.
Owner: Capture / Accessibility.
Depends on: FCP18-FCP20; EB29/EB30 evidence.
Goal: Make Capture accessible for voice/motor alternatives while preserving honest unsupported states.
Acceptance: mic unavailable state honest if not connected; motor alternatives documented and tested.

### FCP22 — Personal System Center Refactor

Status: Complete Green on 2026-05-05 as bounded You root Personal System
Center implementation evidence.
Type: Implementation.
Owner: You.
Depends on: PD15-PD16 preferred; SI11; DAV07; ME06.
Goal: Refactor You from settings/card pile into PersonalSystemCenter.
Acceptance: root has one primary system center; Planning Setup and Trust controls are prominent.

### FCP23 — Memory Lens / External Brain Visual Layer

Status: Complete Green on 2026-05-05 as bounded You-owned Memory Lens
implementation evidence.
Type: Implementation.
Owner: You / Memory.
Depends on: FCP22; EB08-EB12, EB33, EB37, EB38 evidence.
Goal: Memory Lens with source age, correction, privacy shutter, why-remembered fold.
Acceptance: no creepy omniscient copy; no unsupported durable sync/export/delete claim.

### FCP24 — Appearance Studio

Status: Complete Green on 2026-05-05 as bounded You-owned Appearance Studio
object-preview implementation evidence.
Type: Implementation.
Owner: You / Design system.
Depends on: FCP22.
Goal: Appearance Studio with real object previews for Start Here, Rail, LifeShape, Receipt Drawer.
Acceptance: no theme shop; no behavior/personality claim.

### FCP25 — Loading / Empty / Degraded State Objectization

Type: Implementation.
Owner: Shared.
Depends on: FCP05, FCP10, FCP14, FCP18, FCP22; SI13.
Goal: Object-specific honest states.
Acceptance: no generic error; no fake progress; every major object has state matrix.

### FCP26 — Iconography / Status Grammar Hardening

Type: Implementation.
Owner: Shared.
Depends on: FCP25; SI14.
Goal: Complete status glyph/shape/copy/non-color meaning grammar.
Acceptance: no color-only status; no arbitrary symbol drift.

### FCP27 — Cross-Surface Proof / Review Mesh

Type: Implementation.
Owner: Cross-surface.
Depends on: PD17, FCP06, FCP12, FCP15, FCP19, FCP22.
Goal: ContinuityReceiptMesh connects Capture, Today, Goals, Plan, and You.
Acceptance: no activity feed dump; review paths are consistent and privacy-safe.

### FCP28 — Full App 10/10 Audit

Type: Audit / repair-planning; no broad implementation unless scoped repair is explicitly permitted.
Owner: Cross-surface.
Depends on: FCP01-FCP27.
Goal: Deep review every remaining screen, route, state, copy, trust path, accessibility path, preview, and test.
Acceptance: no area remains below 10/10 without a named Yellow owner and repair batch.

### FCP29 — Human Visual / Accessibility / Device Proof Packet

Type: Proof packet / QA.
Owner: QA / accessibility / design.
Depends on: FCP28.
Goal: Prepare human visual, device, VoiceOver, Dynamic Type, Reduce Motion, screenshots, haptic, performance proof packet.
Acceptance: claims remain unmade until proof exists.

### FCP30 — Flagship Completion Handoff

Type: Docs/handoff.
Owner: Cross-surface.
Depends on: FCP29.
Goal: Close train, record unresolved Yellows, rollback path, and next-lane readiness.
Acceptance: no unresolved Red; implementation truth matches evidence.

## Completion Rule

FCP completes only when FCP30 is Green or accepted Yellow with no hard Red, every object has implementation proof or explicit Yellow owner, and release/platform/accessibility/privacy claims remain evidence-bound.
