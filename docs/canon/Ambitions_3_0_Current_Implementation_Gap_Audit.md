# Ambitions 3.0 — Current Implementation Gap Audit

Status: Active Ambitions 3.0 audit baseline  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Implementation plan: [Ambitions 3.0 Front-End Implementation Batch Plan](./Ambitions_3_0_Front_End_Implementation_Batch_Plan.md)  
Last updated: 2026-04-30

---

## Purpose

This audit records the highest-impact known gaps between the current SwiftUI implementation and Ambitions 3.0 canon.

This is an evidence-gated planning document. It does not claim a complete code audit.

---

## Evidence Boundary

Initial evidence from repository search shows current implementation files and terms that must be reconciled before Ambitions 3.0 implementation can be considered coherent.

Evidence paths found:

- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Domain/AmbitionsCommandModels.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsCommandModelsTests.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Sources/Components/AmbitionsV2CanonicalComponents.swift`
- `Sources/Components/RichPanelPrimitives.swift`
- `docs/canon/Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md`
- `docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md`

This document should be expanded during F00 with exact line-level evidence and current rendered behavior.

---

## Severity Labels

- P0: blocks the Golden Launch Loop or creates major canon conflict
- P1: high-impact flagship UX/design/architecture gap
- P2: important polish, trust, accessibility, or maintainability gap
- P3: later improvement

---

# Known Gaps

## G01 — Today does not yet prove the 3.0 Day Rail loop

Severity: P0  
Likely batch: F01 / F02

Current implementation evidence:

- Today implementation exists in `TodayScreen.swift`, `TodayPanels.swift`, `TodayExecutionViewState.swift`, and related tests.
- 3.0 canon requires `AmbitionsDayRailView` as Today signature object.

3.0 target:

- `AmbitionsDayRailView` owns Today first meaningful viewport.
- `Start here` appears inside `DayRailHeroStepCard`.
- Now / Next / Later rows are tappable.
- Row tap opens Step Detail.
- Only `Start now` opens Step Session.
- Closure and proof are attached to the rail.

Risk:

Without this, Ambitions does not yet clearly answer what matters now, what changed, and what counted.

---

## G02 — Old focus/action terminology remains in app code

Severity: P0  
Likely batch: F01 / F04 / copy-guard pass

Current implementation evidence:

- Search found `startFocus` in `TodayScreen.swift`, `TodayFeatureModels.swift`, `AmbitionsCommandModels.swift`, App Intent routing tests, Today tests, and command model tests.

3.0 target:

- User-facing UI must not say `Start Focus` or `Focus Session`.
- Step Session is the execution drill-down.
- Focus/work/school/free time are context states, not primary actions.

Risk:

Old naming can leak into visible copy, tests, previews, intents, and future Codex prompts.

---

## G03 — HeroDecisionPanel / old hero grammar conflicts with Day Rail signature object

Severity: P0  
Likely batch: F02

Current implementation evidence:

- Search found `HeroDecisionPanel` in `TodayPanels.swift`, `AmbitionsV2CanonicalComponents.swift`, `RichPanelPrimitives.swift`, and v2 reconciler skill docs.

3.0 target:

- Hero Step Panel is resolved into `DayRailHeroStepCard`.
- Do not render a separate Hero Step Panel above the Day Rail by default.

Risk:

A separate hero plus rail creates a stacked premium-card layout and violates the 3.0 signature object rule.

---

## G04 — Step Detail is not yet verified as a first-class route

Severity: P0  
Likely batch: F03

Current implementation evidence:

- Requires F00 inspection.

3.0 target:

- Rail row tap opens lightweight Step Detail first.
- Step Detail explains what, why, readiness, duration, source, and controls.
- `Start now` opens Step Session.

Risk:

Without Step Detail, the Day Rail either opens execution too aggressively or becomes a static list.

---

## G05 — Step Session is not yet verified as a real execution drill-down

Severity: P0  
Likely batch: F04

Current implementation evidence:

- Requires F00 inspection.

3.0 target:

- Step-first, not timer-first.
- Shows current step, why it matters, context state, duration source, notes/proof capture, Complete, Still Counts, Pause, Adjust.

Risk:

Without Step Session, Ambitions remains a planning interface instead of an execution system.

---

## G06 — Action Closure Sheet needs shared implementation

Severity: P0  
Likely batch: F05

Current implementation evidence:

- Action Closure receipt/domain concepts exist in repo history, but shared closure sheet implementation requires audit.

3.0 target:

- One shared `ActionClosureSheet` grammar.
- Outcomes: Completed, Still Counts, Rescheduled, Not needed, Blocked, Waiting, Needs Recovery, Needs Review.
- Closure creates receipt.

Risk:

Without shared closure, old work becomes either stale debt or inconsistent surface-specific behavior.

---

## G07 — Receipt/proof presentation needs recoverable trail beyond toast

Severity: P1  
Likely batch: F06 / F16

Current implementation evidence:

- Requires F00 inspection of receipt models, toasts, trays, and You/Trust routes.

3.0 target:

- Receipt toast, peek, trail, search, export levels are distinct.
- Proof is evidence, not celebration or streak.

Risk:

Trust model exists but user may not understand what changed or where to find proof later.

---

## G08 — Capture needs 3.0 Placement Resolver flow

Severity: P0  
Likely batch: F07 / F08 / F09

Current implementation evidence:

- Requires F00 inspection of Capture screen and current route actions.

3.0 target:

- Composer-driven first-use.
- Post-input states: Suggested Place, Needs a Decision, Needs a Place, Saved as object.
- Placement preview and placement receipt.
- Sensitive/high-impact capture privacy checks.

Risk:

Without placement, Capture can become notes/inbox/task entry instead of the first step in the Golden Launch Loop.

---

## G09 — Plan needs Day / Week / Month scope separation

Severity: P1  
Likely batch: F10 / F11 / F12

Current implementation evidence:

- Requires F00 inspection of `PlanScreen.swift` and Plan feature files.

3.0 target:

- Day: what the day holds.
- Week: can the week actually hold?
- Month / Life Shape: life areas, pressure weeks, milestones, protected time.
- No raw calendar clone.

Risk:

Plan can become a panel stack or calendar clone instead of a believability suite.

---

## G10 — Goals needs Portfolio and Mission Control refinement

Severity: P1  
Likely batch: F13 / F14

Current implementation evidence:

- Requires F00 inspection of Goals and Goal Detail feature files.

3.0 target:

- Goals home acts as Ambition Portfolio.
- Goal Detail is lane-based Mission Control: Overview, Path, Steps, Proof, Decisions, Risks, Archive.
- Every active goal has next visible step or a reason.

Risk:

Goals can drift into project-board/KPI/dashboard behavior.

---

## G11 — You needs Personal System Center treatment

Severity: P1  
Likely batch: F15 / F16

Current implementation evidence:

- Requires F00 inspection of You/Profile files.

3.0 target:

- User-facing `You`, not `Profile`.
- Top status: `You are in control`.
- Planning Setup high: Schedule & Availability, Planning Defaults, Vacation / Away Time, Automation & Trust.
- Memory and receipts actionable.

Risk:

You can feel like generic settings instead of the user's control center.

---

## G12 — Ambition Meridian should wait until routing safety is verified

Severity: P1  
Likely batch: F17

Current implementation evidence:

- Meridian child spec exists.
- Requires root shell / tab routing audit before implementation.

3.0 target:

- Meridian is feature-flagged or fallback-safe initially.
- It preserves one-tap access to Today, Goals, Capture, Plan, You.
- No navigation discoverability loss.

Risk:

A beautiful custom shell can harm usability if it replaces the native tab bar before the content loop is stable.

---

## G13 — Copy guard is needed before UI invention work expands

Severity: P1  
Likely batch: cross-cutting with F01-F06

Current implementation evidence:

- Search found old focus/action terms in code and tests.

3.0 target:

- visible UI avoids deprecated terms.
- future tests/previews avoid old language unless deliberately testing compatibility.

Risk:

Canon can drift back through tests, app intents, accessibility labels, previews, and prompt output.

---

# Recommended F00 Audit Expansion

F00 should inspect and cite exact paths for:

- Today view hierarchy
- Today action enum and routing
- command/app intent action names
- visible copy constants
- accessibility labels
- preview fixtures
- UI tests
- Capture post-input behavior
- Plan scope structure
- Goals and Goal Detail routing
- You/Profile naming
- receipt/proof models and UI
- root app shell / TabView / navigation stacks

---

# Recommended First Implementation Order

1. F00 — Complete exact current implementation audit.
2. F01 — Day Rail model foundation.
3. F02 — Day Rail visual implementation.
4. F03 — Step Detail.
5. F04 — Step Session.
6. F05 — Action Closure Sheet.
7. F06 — Receipt Peek / Proof Saved.
8. F07-F09 — Capture and Placement.
9. F10-F12 — Plan scopes.
10. F13-F16 — Goals and You.
11. F17 — Meridian Shell feature-flagged.

---

## Acceptance Criteria For This Audit

This audit is acceptable when it remains honest about evidence limits and gives implementation a prioritized path.

This audit must be expanded before major front-end code changes if exact file/line-level gap proof is required.
