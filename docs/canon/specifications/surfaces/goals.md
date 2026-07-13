+++
spec_id = "SURFACE-GOALS"
title = "Goals"
kind = "surface"
status = "normative"
owner_domain = "surface-goals"
canon_revision = 1
profile = "surface-v1"
owns_concepts = ["surface.goals.anti-patterns", "surface.goals.execution-stack", "surface.goals.first-viewport", "surface.goals.identity", "surface.goals.purpose", "surface.goals.screen-inventory", "surface.goals.visual-authority",
  "surface.goals.path-visual",
  "surface.goals.closure",
  "surface.goals.detail",
  "surface.goals.path-interaction",
  "surface.goals.reviews",
  "surface.goals.root-viewport",
  "surface.goal-detail.viewport",
]
inherits = [
  "CONST-IA-ROOT-001",
  "OBJECT-CANONICAL-GRAPH-001",
  "OBJECT-GOAL-LIFECYCLE-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Surfaces/Goals/",
  "Native/Ambitions/Core/Domain/",
  "Native/Ambitions/Core/LocalRuntimeOS/Planning/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Quality/",
]
+++

# Goals



## SPEC-SURFACE-GOALS-IDENTITY-001 — Life-area-first direction and path

- **Concept:** `surface.goals.identity`
- **Modality:** `MUST`
- **Scope:** Goals root and Goal depth
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-DIRECTION-001`
- **Supersedes:** none

Goals MUST organize direction through editable Life Areas and living Goal Paths, answering what the user is building, where they are on the path, and the next meaningful movement. It must preserve proof, recovery, Future Steps, schedule fit, and closure without exposing runtime architecture.

Goals MUST begin with editable Life Areas, MUST open into Life Area operating pages, and MUST expose each Goal as a living operating object with a horizontal Goal Path.

Goals SHOULD combine grouped Life Area sections, a visual overview, and drilldown lists and details.

## SPEC-SURFACE-GOALS-ANTI-PATTERNS-001 — No dashboard or project board drift

- **Concept:** `surface.goals.anti-patterns`
- **Modality:** `MUST NOT`
- **Scope:** Goals root, detail, and path presentation
- **Status:** `normative`
- **Verification:** `AUDIT-GOALS-ANTI-DRIFT-001`
- **Supersedes:** none

Goals MUST NOT become a metrics dashboard, project-management board, generic list of projects, Gantt chart, gamified quest, score, streak, badge, or productivity report. Quiet path health may inform an object; it cannot replace the Life Area, Goal, or path.

## SPEC-SURFACE-GOALS-SCREEN-INVENTORY-001 — Owned Goal experience

- **Concept:** `surface.goals.screen-inventory`
- **Modality:** `MUST`
- **Scope:** Goals root and owned drilldowns
- **Status:** `normative`
- **Verification:** `AUDIT-GOALS-ROUTES-001`
- **Supersedes:** none

Goals owns the Life Area index and detail, Goal creation/review/activation, Goal detail, full Goal Path, recovery packet, and Goal closure. Time owns calendar editing; Today owns the execution slice; Trust owns contextual receipts/source/privacy/history inspection; Capture owns global intake.

Goal detail MUST combine native task metadata with Ambitions direction, Proof, and current-Step layers.

The full Goal Path SHOULD use a horizontal, scrollable path timeline.

The horizontal Goal Path MUST snap to nodes, anchor on the current position by default, provide haptic selection feedback, support semantic node types, show selected-node detail, and provide a compact jump control for Start, Now, Next, and Finish.

When a goal reaches completion, Ambitions MUST show a first-class closure surface with final status, completed path, proof moments, recovery segments, remaining open items, schedule cleanup, final receipt, optional reflection, and next suggested direction.

Reviews MUST be both reflective and operational.

## SPEC-SURFACE-GOALS-FIRST-VIEWPORT-001 — Direction before metadata

- **Concept:** `surface.goals.first-viewport`
- **Modality:** `MUST`
- **Scope:** Goals root and Goal detail first viewport
- **Status:** `normative`
- **Verification:** `PROOF-GOALS-FIRST-VIEWPORT-001`
- **Supersedes:** none

Goals first-viewport behavior MUST be owned by the separate root, Goal-detail, and Goal-Path interaction contracts and MUST NOT collapse their independently verifiable states.

## SPEC-SURFACE-GOALS-PURPOSE-001 — Full path that adapts without forcing

- **Concept:** `surface.goals.purpose`
- **Modality:** `MUST`
- **Scope:** Path generation, activation, adaptation, recovery, and closure
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-PATH-LIFECYCLE-001`
- **Supersedes:** none

A Goal MUST carry an inspectable route from current reality to closure, including planned and completed Steps, Future Steps, proof, recovery, schedule changes, assumptions, and review points. Vague intent preserves a provisional shell and requests clarification. Material scheduling or path changes require preview and confirmation; no fake confident path or forced choice is allowed.

Goals SHOULD show direction, goal paths, Life Capital relevance, proof, milestones, and progress.

Onboarding progress SHOULD show as a percentage.

## SPEC-SURFACE-GOALS-VISUAL-AUTHORITY-001 — Approved Goals package, separate implementation proof

- **Concept:** `surface.goals.visual-authority`
- **Modality:** `MUST`
- **Scope:** Goals and Goal Path visual authority
- **Status:** `normative`
- **Verification:** `PROOF-GOALS-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual mapping MUST use stable external IDs and distinguish approved design target from implementation proof. Owner-approved VSP-03 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:177:93` is the Goals visual target. Candidate naming does not weaken the durable owner approval, and approval does not prove SwiftUI parity, accessibility, device behavior, runtime behavior, Visual Green, or release status.

The horizontal Goal Path MUST communicate meaning through restrained shape, weight, material, micro-symbol, and line treatment.

## SPEC-SURFACE-GOALS-PATH-VISUAL-001 — Goal Path visual contract

- **Concept:** `surface.goals.path-visual`
- **Modality:** `MUST`
- **Scope:** Goal Path presentation
- **Status:** `normative`
- **Verification:** `REVIEW-GOAL-PATH-VISUAL-001`
- **Supersedes:** none

Goal Path presentation MUST keep current route and next Step legible at rest and reveal chronology, Proof, recovery, schedule change, and adaptation on drilldown.

## SPEC-SURFACE-GOALS-CLOSURE-001 — Goal closure presentation

- **Concept:** `surface.goals.closure`
- **Modality:** `MUST`
- **Scope:** Goals closure controls
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-CLOSURE-001`
- **Supersedes:** none

Goals MUST present explicit closure outcomes, consequence preview, Proof requirement or status, rollback, and History without collapsing them into completion.

## SPEC-SURFACE-GOALS-DETAIL-001 — Goals detail

- **Concept:** `surface.goals.detail`
- **Modality:** `MUST`
- **Scope:** Life Area and Goal detail
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-DETAIL-001`
- **Supersedes:** none

Goals detail MUST present the selected object, current direction, active relationships, next meaningful Step, Proof or recovery state, path health, and contextual actions.

## SPEC-SURFACE-GOALS-PATH-INTERACTION-001 — Goal Path interaction

- **Concept:** `surface.goals.path-interaction`
- **Modality:** `MUST`
- **Scope:** Goal Path at rest and drilldown
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-PATH-INTERACTION-001`
- **Supersedes:** none

Goal Path MUST be useful at rest through current route and next Step, while drilldown reveals chronology, Proof, recovery, schedule change, and adaptation.

## SPEC-SURFACE-GOALS-REVIEWS-001 — Goals reviews

- **Concept:** `surface.goals.reviews`
- **Modality:** `MUST`
- **Scope:** Goal review states
- **Status:** `normative`
- **Verification:** `SCENARIO-GOALS-REVIEWS-001`
- **Supersedes:** none

Goals reviews MUST present due context, affected Goal and path state, recommended user-controlled choices, consequences, deferral, rollback, and History.

## SPEC-SURFACE-GOALS-ROOT-VIEWPORT-001 — Goals root viewport

- **Concept:** `surface.goals.root-viewport`
- **Modality:** `MUST`
- **Scope:** Goals root first viewport
- **Status:** `normative`
- **Verification:** `PROOF-GOALS-ROOT-VIEWPORT-001`
- **Supersedes:** none

The Goals root first viewport MUST foreground editable Life Areas, current direction, meaningful Goal movement, next Step, Proof or recovery state, and quiet path health.

## SPEC-SURFACE-GOAL-DETAIL-VIEWPORT-001 — Goal detail viewport

- **Concept:** `surface.goal-detail.viewport`
- **Modality:** `MUST`
- **Scope:** Goal detail first viewport
- **Status:** `normative`
- **Verification:** `PROOF-GOAL-DETAIL-VIEWPORT-001`
- **Supersedes:** none

Goal detail first viewport MUST foreground Goal identity and status, current route, next Step, Proof requirement or status, schedule fit, and a compact path preview.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Goals answers what the user is building, the living path, current position, next meaningful movement, and what proof or recovery still matters.

<!-- canon-section: entry-exit -->
Entry is root selection, Search, Today/Time context, Capture activation, restoration, or deep link. Exit uses root switch, Time handoff, Today handoff, contextual Trust inspection, or native back while preserving selected Life Area, Goal, path node, and focus.

<!-- canon-section: routes-presentation -->
The root is a native Life Area index. Life Area, Goal, path, generated-route review, recovery, and closure use native depth or a focused review presentation. Path selection never creates a parallel root.

<!-- canon-section: displayed-objects -->
Life Areas, Goals, Steps, Future Steps, path nodes, Proof Moments, schedule/adaptive changes, recovery segments, and closure moments are projections of canonical identity. Shape, label, order, and line treatment carry meaning without color alone.

<!-- canon-section: resting-states -->
Required states include empty direction, draft, ready to activate, active, paused, completed, archived, ended, needs attention, recovering, waiting, blocked, populated, dense, and selected-path-node states.

<!-- canon-section: loading-transitional -->
Transition records capture phase, retained Goal/path snapshot, progress, cancellation, and restoration target.
Clarification, route generation, simulation, activation, path adjustment, proof transfer, recovery, closure, and restoration preserve accepted state and expose progress/cancellation where work is not immediate.

<!-- canon-section: empty-degraded -->
Empty Goals invites creation or Capture without fabricated examples. Missing reference context, offline operation, path-generation uncertainty, schedule conflict, partial simulation, or local-store degradation preserves the Goal/draft and offers clarification, retry, manual editing, export, or safe unresolved state.

<!-- canon-section: commands-actions -->
Create, clarify, review, activate, edit, pause, resume, schedule, add proof, recover, close, archive, end, Trash, restore, and inspect route through canonical commands. Horizontal path interaction has ordered node list, jump controls, and explicit actions.

<!-- canon-section: durable-effects -->
Activation, path mutation, schedule placement, proof, recovery, closure, archive, Trash, and restore produce canonical events, projections, receipts, and replay-safe state. Progress transfer preserves context without false completion.

<!-- canon-section: failure-rollback -->
Generation failure keeps original intent and a provisional Goal shell. Material preview rejection leaves state unchanged. Partial schedule failure keeps accepted Goal/path state with visible conflict and recovery. Undo or rollback restores prior path/placement while retaining audit history.

<!-- canon-section: offline -->
Life Areas, Goals, local pathing at available capability, edits, proof, closure, recovery, receipts, history, and replay remain usable without account or network. Missing Source Atlas context cannot trigger private upload or block manual/local planning.

<!-- canon-section: privacy-data-classification -->
Goal intent, path, proof, resources, constraints, schedule fit, Life Capital links, and learning are private local graph data. Minimum-necessary redacted metadata may cross an explicitly approved export/sync boundary; Account and R2 never own the private graph.

<!-- canon-section: accessibility-reading-order -->
The semantic sequence is direction, lifecycle, next movement, proof, schedule fit, path position, and object actions.
VoiceOver orders Life Areas and Goal detail by direction, state, next movement, proof, schedule fit, then path. Goal Path provides an ordered node list with current position, state, rationale, actions, Start/Now/Next/Finish jumps, and filters without requiring horizontal spatial interpretation.

<!-- canon-section: dynamic-type -->
Life Area and Goal content reflows into one-column object-led layouts. Path switches to ordered semantic list where necessary; no node label, action, proof requirement, or consequence is lost.

<!-- canon-section: reduce-motion -->
Path travel, node transforms, activation, recovery, and closure use restrained crossfades or immediate updates while retaining selection, announcements, focus, and continuity semantics.

<!-- canon-section: reduce-transparency -->
Materials become opaque semantic surfaces with equivalent path hierarchy, connection treatment, selection, contrast, and state encoding.

<!-- canon-section: copy-state-language -->
Primary vocabulary presents personal direction and action in calm object terms.
Use plain Goal, Path, Step, Future Step, Proof, Still counts, Waiting, Blocked, Review, and Undo language. Do not expose graph/runtime taxonomy, shame, quest terms, points, levels, AI claims, or productivity scoring.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:177:93` supplies approved Goals design authority. Source rendering, semantic behavior, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/Goals/` owns presentation; `Core/Domain/`, `Core/LocalRuntimeOS/Planning/`, `PrivateLifeRuntimeKernel/`, `Scheduling/`, and `Inspection/` own canonical behavior; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover Life Area organization, path generation/clarification, material confirmation, activation, Future Steps, conflict, priority override, proof transfer, recovery, closure, archive/Trash/restore, replay, offline, Goal Path semantic list/actions, Dynamic Type, reduced effects, focus, and non-color encoding.

<!-- canon-section: proof -->
Required proof includes path and lifecycle scenario logs, receipts/replay, screenshot matrices for root/detail/path/recovery/closure, VoiceOver scripts, semantic parity, current visual mapping and independent acceptance, exact commands/exits, known gaps, and rollback. Canon text is not that proof.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Goals root, path materialization, selection, and semantic-node lookup MUST remain bounded, cancellable, and deterministically paged; perform no interaction-path network gating or synchronous disk I/O; use no polling or unbounded background loop; and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative Life Area/Goal/path data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.

## SPEC-SURFACE-GOALS-EXECUTION-STACK-001 — Goal execution stack

- **Concept:** `surface.goals.execution-stack`
- **Modality:** `MUST`
- **Scope:** Goal execution stack
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-SURFACE-GOALS-EXECUTION-STACK-001`
- **Supersedes:** none

Goal detail MUST expose current, next scheduled, and unscheduled upcoming Steps, Substep groups, Proof, schedule and recovery state, and actions to inspect, schedule, complete, or revise work linked to the Goal Path.
