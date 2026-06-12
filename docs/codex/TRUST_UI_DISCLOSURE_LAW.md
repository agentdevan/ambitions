# Trust UI Disclosure Law

Status: Active PLOS M00 governance law
Issue: AMB-642 / PLOS-006
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none
UI implementation proof: none

This law defines how future PLOS UI can remain quiet while still being inspectable and trustworthy. It does not redesign UI, add SwiftUI surfaces, change app copy, add screenshots, or prove accessibility.

## Core Law

Trust-light UI means Ambitions shows the minimum useful explanation at the moment of decision and keeps deeper source, context, constraint, receipt, and fallback detail one intentional step away.

Trust-light does not mean opaque. It also does not mean a dashboard, admin panel, debug panel, source dump, or paragraph-heavy explanation layer.

Every future PLOS UI that claims runtime reasoning Green must satisfy both sides:

- top-level state stays short, calm, and action-oriented
- deeper trust state is inspectable through a clear drill-down, receipt, breadcrumb, or fallback path

If the user cannot understand why a recommendation exists, where it came from, what changed, what can fail, or how to review the trace, the UI is not Green. If the explanation overwhelms the top-level surface with internal machinery, the UI is also not Green.

## Existing Authority Anchors

AMB-642 inspected current docs and source before installing this law. Existing anchors include:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  - active product canon already requires one-primary-object discipline, progressive disclosure, calm trust, receipt/source/freshness paths, Dynamic Type, VoiceOver, Reduce Motion, Increase Contrast, and no dashboard/card-stack/chatbot posture.
- `docs/codex/ui-quality-firewall.md`
  - UI Red conditions already include dashboard anatomy, generic cards, missing source/trust/receipt, missing accessibility semantics, clipped text, unreadable geometry, and false Green.
- `docs/codex/ambitions_ui_review_checklist.md`
  - reviewer checks already require active source path, primary object/action, compact source/trust/receipt, Dynamic Type, Reduce Motion, Increase Contrast, banned-language checks, and honest status.
- `docs/codex/ambitions_no_card_replacement_taxonomy.md`
  - replacement taxonomy already blocks panel piles, metric grids, generic task rows, chat transcript panels, and calendar-copy cards while allowing subordinate chips/strips/traces.
- `docs/codex/ambitions_primitive_invention_registry.md`
  - existing promoted primitives include source trust strip, proof relationship trace family, quiet reflow family, and accessibility fallback contract concepts.
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
  - existing primitive vocabulary already covers source freshness, privacy labels, why/change/undo/correction/review labels, and accessibility summaries.
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
  - existing primitive vocabulary already supports adaptive density and accessibility fallback concepts.
- `Sources/Components/QuietReflowPrimitiveFamily.swift`
  - existing primitive vocabulary already supports quiet reflow, consequence, review, and receipt framing.
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
  - Source Atlas states must be compressed for user-facing surfaces while preserving source authority.
- `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md`
  - material consequence cannot be hidden by quiet presentation.

These anchors are existing-first context only. They do not prove UI implementation.

## Disclosure Layers

Future PLOS UI must choose the smallest layer that preserves trust:

| Layer | Purpose | Allowed content | Forbidden content |
|---|---|---|---|
| Decision line | Let the user act without decoding internals. | Short recommendation reason, current constraint, one action. | Paragraphs, source dumps, debug state, confidence theater. |
| Trust strip | Show why the recommendation is safe enough to consider. | Source state, freshness state, receipt status, risk state, review-needed state. | Unlabeled glyphs, unexplained scores, ornamental AI badges. |
| Consequence line | Show material human impact. | Deadline, protected time, proof, recovery, source, or affected-goal consequence. | Productivity scores, guilt framing, hidden material risk. |
| Receipt preview | Show what will be recorded if the user acts. | What changes, affected objects, rollback/failure state. | Mutating state without receipt, pretending receipt exists before proof. |
| Drill-down trace | Let the user inspect source, context, constraints, fallback, and replay. | Source, context, constraints, receipt, fallback, privacy, rollback, proof path. | Dashboard/admin/debug anatomy as the default UI. |
| Blocker state | Explain why action cannot proceed. | Human blocker phrase, safe next review path, source/failure boundary. | Silent failure, generic error, impossible path presented as viable. |

Top-level UI should normally use the decision line plus at most one compact trust/consequence line. Detailed source and replay state belongs in drill-down unless severity requires immediate confirmation, warning, blocking, or impossible-state visibility.

## User-Facing State Compression

Internal source/runtime states can be rich. Top-level user-facing states must be compressed without lying:

| Internal state family | Top-level expression | Drill-down requirement |
|---|---|---|
| source current | Source is current. | Show source, freshness, and receipt path when opened. |
| source stale/review needed | Needs review. | Explain stale/review cause before action Green. |
| source revoked/contradicted | Cannot proceed as-is. | Show source conflict, fallback, and safe review path. |
| consequence silent/inform | Safe or low-impact. | Receipt or trace available when opened. |
| consequence confirm/warn/block/impossible | Needs choice, warning, block, or scope change. | Must show consequence phrase before mutation. |
| schedule/reflow preview | This changes the plan. | Show before/after, affected goals, protected time, and receipt. |
| proof/receipt pending | Receipt will be created. | Show what will be recorded and rollback/failure state. |
| privacy/share boundary | Stays local or share-limited. | Show what leaves device only when sharing/export is in scope. |

Compression cannot erase source truth, safety state, privacy boundary, receipt requirement, or material consequence.

## Glyph And Breadcrumb Rules

Glyphs, chips, and compact strips are allowed only when they improve scanability without hiding meaning.

Green requires:

- glyphs have accessible names and a visible or adjacent meaning path
- color is not the only state carrier
- VoiceOver exposes source, receipt, risk, and action meaning in a useful order
- breadcrumbs identify where deeper trust detail lives
- drill-down can return the user to the original decision without losing context
- blocked or impossible states have a clear review or fallback route

Red conditions:

- unlabeled icons as the only trust indicator
- decorative AI badges standing in for source or proof
- hidden receipt/failure state
- drill-down that opens a dashboard of unrelated metrics
- source trace that exposes private data outside the current privacy boundary

## No False Calm

Quiet UI cannot hide material state. The following must never be suppressed by a trust-light surface:

- source revoked or contradicted
- high-risk review required
- protected time broken
- material displacement of another active goal
- schedule install failure
- deadline impossible
- unsafe state
- action that requires user confirmation before mutation

The surface can remain calm. It cannot become misleading.

## Green Enforcement

Any future PLOS issue that claims trust-light UI, runtime reasoning disclosure, source/receipt/replay disclosure, drill-down trace, breadcrumb, compact trust strip, or quiet reflow UI Green must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of active UI/source/receipt/accessibility ownership
- a named disclosure layer for each UI claim
- explicit top-level versus drill-down boundary
- source, receipt, consequence, fallback, privacy, and rollback handling when in scope
- visual evaluation of screenshots for UI claims
- Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, safe-area, tap-target, and legibility checks for UI claims
- no release, accessibility certification, privacy/legal approval, or performance claim without matching proof

Yellow is allowed when this law is installed but future UI implementation, screenshot review, accessibility proof, or runtime drill-down proof remains owned by later phases. Red is required for opaque recommendation UI, dashboard/admin/debug default anatomy, hidden material consequences, unlabeled glyph-only state, source/receipt overclaim, PLOS label Linear access, or phase-order violation.

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
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md`
- `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`

Future phase owners:

- AMB-624 / PLOS-M17 must use this law before Trust-light UI and deep drill-down Green.
- AMB-622 / PLOS-M15 and AMB-623 / PLOS-M16 must use this law for schedule/reflow UI claims.
- AMB-625 / PLOS-M18 must use this law when high-risk review state has UI visibility.

## Non-Claims

AMB-642 does not claim:

- UI implementation
- SwiftUI source change
- runtime feature implementation
- trust strip implementation
- drill-down implementation
- screenshot proof
- accessibility verification
- privacy/legal approval
- release, TestFlight, or App Store readiness
- PLOS-M00 completion
- PLOS-M01 or later execution
