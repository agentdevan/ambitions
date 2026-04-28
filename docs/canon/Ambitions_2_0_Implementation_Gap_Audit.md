# Ambitions 2.0 Implementation Gap Audit

Status: Active implementation audit.
Date: 2026-04-27.

This audit compares the current repo and native app against [design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md). It does not reopen, renumber, or erase completed historical batches. Completed batches remain completed for history; gaps created by the Design Constitution become future delta/alignment batches.

D02 evidence: [Ambitions_2_0_Object_Terminology.md](Ambitions_2_0_Object_Terminology.md) now locks shared object language before later feature batches consume those objects.

D08 evidence: `Native/Ambitions/Domain/NorthStarModels.swift` and `Native/Ambitions/Services/NorthStarProjector.swift` now provide the canonical North Star / Dormant Ambition model and deterministic local projection foundation under Life Areas. D13 adds bounded Goals-surface North Star rail consumption; full North Star detail remains future work.

D09 evidence: `Native/Ambitions/Domain/OneStepGoalModels.swift` and `Native/Ambitions/Services/OneStepGoalProjector.swift` now provide the canonical Task / One-Step Goal model and deterministic local projection foundation, including standalone Task vs contained Step semantics, privacy/accessibility projections, receipt-compatible promote/attach/demote metadata, Life Graph references, and Life Area count/reference hooks. D11 adds bounded Today consumption, D12 adds bounded Capture / Quiet Command Sheet routing, D13 adds controlled Goals portfolio consumption, and D14 preserves the Step/Task distinction inside Goal Detail. Full standalone detail UI and broader Plan integration remain future work.

D12 evidence: `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`, `Native/Ambitions/Features/Captures/CapturesViewModel.swift`, `Native/Ambitions/Features/Captures/CapturesScreen.swift`, and `Native/Ambitions/App/AppShellView.swift` now align Capture and the Quiet Command Sheet with Smart Attachment route previews, Needs a Place fallback, compact route choices, calm receipt copy, accessibility-safe route labels, and post-save Capture handoff. It does not add a top-level Tasks tab, chat interface, calendar behavior, or broad surface redesign.

D13 evidence: `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`, `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`, `Native/Ambitions/Features/Goals/GoalComponents.swift`, and `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift` now align Goals with Life Areas, North Stars, and One-Step Goals projections. Goals has a bounded Life Areas Map/List semantic zoom fallback, North Stars rail, controlled One-Step Goals panel, and D10 screen-contract snapshot coverage without adding a tab, North Star detail, Task detail, Path Builder, or unrelated surface redesign.

D14 evidence: `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`, `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`, `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`, and `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift` now align Goal Detail to the exact Mission Control lanes `Overview / Path / Steps / Proof / Decisions / Risks / Archive`. Goal Detail keeps contained work as Steps, preserves breadcrumb/object identity, proof, receipts, and next-step orientation, adds decisions/risks/archive projection cards, and validates the D10 Goal Detail screen contract without redesigning Goals overview, adding tabs, or building Path Builder.

## 1. Executive Summary

The repo has substantial native foundations: the five-tab shell, local-first SwiftUI app, Capture persistence, Command Pipeline, Event Ledger, Action Closure receipt models, Plan-owned calendar action boundary, rich panel primitives, Accessibility Nutrition infrastructure, Profile-backed You trust surface, local notification foundation, App Intents, widgets, and Live Activity scaffolding.

The app is not yet Constitution-complete. The biggest gaps are Plan timeline/calendar-trust alignment, Ritual language split, full You Personal System Center structure, Trust Center / What Ambitions Knows, systematic UX writing cleanup, external-surface contracts, and verified Accessibility Nutrition. Life Areas, North Stars, and One-Step Goals now have foundation object/projection layers; Today has its D11 plan/One-Step preview alignment; Capture has its D12 Smart Attachment / Needs a Place alignment; Goals has D13 bounded portfolio consumption with accessible Map/List fallback; and Goal Detail has D14 Mission Control lane alignment.

Several implemented surfaces are valid foundations but need alignment: Today, Capture, Goals, Goal Detail, Plan, You/Profile, external surfaces, notification controls, and shell/navigation behavior. The correct next move is not to reopen old batches; it is to add future alignment batches in dependency order.

## 2. Repo Areas Reviewed

- Product and canon docs: `MASTER_PRODUCT_SPEC.md`, `docs/canon/**/*.md`, `docs/canon/design/**/*.md`.
- Roadmap and planning docs: `docs/canon/Ambitions_2_0_Roadmap.md`, `docs/canon/Ambitions_2_0_Batch_Plan.md`, `docs/implementation-backlog.md`.
- Codex context docs: `docs/codex/CONTEXT_INDEX.md`, `docs/codex/BATCH_REGISTRY.md`, `docs/codex/MASTER_CODEX_SYSTEM.md`, `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md`.
- Native app shell and routing: `Native/Ambitions/App/`.
- Native domain/services/persistence: `Native/Ambitions/Domain/`, `Native/Ambitions/Services/`, `Native/Ambitions/Persistence/`.
- SwiftUI features: `Native/Ambitions/Features/Today`, `Captures`, `Goals`, `Plan`, `Profile`, `Onboarding`, `Habits`, `Insights`.
- Shared design system and accessibility: `Sources/Components`, `Sources/Accessibility`, `AppUI/Sources`.
- External surfaces: `Native/Ambitions/AppIntents`, `Native/Ambitions/Notifications`, `Native/Ambitions/ExternalSnapshots`, `Native/AmbitionsWidgetExtension`.
- Tests: `Native/AmbitionsTests`, `Native/AmbitionsUITests`.
- Project wiring: `project.yml`.

## 3. Implemented And Still Valid

| Area | Current evidence | Status |
| --- | --- | --- |
| Five-tab shell | `Native/Ambitions/App/AppTab.swift`, `AmbitionsRootView.swift` expose Today, Goals, Capture, Plan, You user-facing tabs. | Valid foundation. |
| Capture as a real tab | `AmbitionsRootView.captureNavigation()` opens `CapturesScreen(shellMode: .topLevelCapture)`. | Valid foundation. |
| Separate global command entry | Shell plus button presents `QuietCommandSheetView` through `ShellCommandRouter`. | Valid foundation, needs copy/behavior alignment. |
| Canonical goal detail routing | `AppNavigation.openGoalDetail` selects Goals and pushes one detail route. | Valid foundation. |
| Capture persistence/routing | `CaptureModels.swift`, `CaptureService.swift`, `CapturesViewModel.swift`, `CapturesScreen.swift`. | Valid foundation. |
| Command Pipeline | `AmbitionsCommandExecutor.swift`, command tests. | Valid foundation. |
| Action Closure receipt model | `ActionClosureReceiptModels.swift` includes results, undo/correction availability, explanation, source, safety. | Valid foundation, needs search/history UI. |
| Plan-owned calendar action | `PlanScreen.handleCalendarAwarenessAction` calls Plan service only when the Plan card allows it; onboarding does not request calendar access. | Valid foundation, needs full local-first evidence labeling pass. |
| Rich panel primitives | `Sources/Components/RichPanelPrimitives.swift` defines panel kinds, semantic states, accessibility hooks. | Valid foundation, needs Constitution panel taxonomy expansion. |
| Accessibility Nutrition infrastructure | `Sources/Accessibility/AccessibilityNutrition.swift`, `AccessibilityNutritionChecklistTests.swift`. | Valid internal infrastructure; verification remains unverified. |
| You trust/control foundation | `ProfileScreen.swift` user-facing title is `You`; Profile service builds Trust Center, memory controls, receipts, conservative status. | Valid foundation, not full Personal System Center. |
| Widgets / Live Activity scaffolding | `Native/AmbitionsWidgetExtension`, `ExternalSurfaceSnapshotBuilder.swift`, `NextStepLiveActivityService.swift`. | Valid scaffolding; not production-complete under the Constitution. |
| App Intents / Shortcuts scaffolding | `OpenAmbitionsDestinationIntent.swift`. | Valid scaffolding; needs receipt and privacy alignment. |
| Local notification foundation | `LocalNotificationFoundation.swift` defines categories, opt-in request, and next-step scheduling. | Valid foundation; needs frequency/privacy controls. |

## 4. Implemented But Needs Alignment

| Area | Gap | Required delta |
| --- | --- | --- |
| Shell IA | Internal compatibility names still include `captures`, `profile`, `insights`, and `habits`; current-tab tap once/twice behavior was not found. | Shell IA / tab alignment delta. |
| Navigation stacks | Major tabs use `NavigationStack`, but Today/Capture stack preservation and tab retap behavior are not explicit. | Shell/navigation behavior pass. |
| Quiet Command Sheet | Exists, but user-facing copy centers on `Command`, not the Quiet Command Sheet / Smart Attachment contract. | Capture + Quiet Command Sheet alignment. |
| Capture | Uses `Needs a route`, `Plan seed`, `Seed`, `Attach`; does not consistently use `Needs a Place` or Smart Attachment receipts. | Capture + Smart Attachment batches. |
| Today | Has Hero Decision Panel, Save the Day, support panels, and drift handling, but no explicit Today Plan Layer, One-Step Goals panel, or full planned-day matrix. | Today 2.0 Design Constitution Alignment. |
| Goals | Has Goal Lifecycle Rail, Goal Weather, Goal Atlas preview, archive summary, active cards, and D13 Life Areas / North Stars / One-Step Goals portfolio panels with Map/List fallback. | Later maturity work can deepen Path Builder and long-range portfolio behavior after D14-D26. |
| Goal Detail | Has exact Mission Control lanes `Overview / Path / Steps / Proof / Decisions / Risks / Archive`, breadcrumb/object identity, timeline, Proof Rail, decisions, risks, archive learning, receipts, and Step-safe contained action language. | Later maturity work can deepen Path Builder, review/search, and archive learning after D15-D26. |
| Plan | Has Plan Treaty, capacity, lifecycle rail, timeline strip, believability, calendar boundary, recovery/reflow. It still exposes a `Habits` toolbar route and needs Rich Timeline Widget/Ritual language alignment. | Plan believability + timeline widget and Ritual split alignment. |
| You | Profile-backed You has Trust Center, memory controls, receipts, reviews, appearance, integrations, notification permission; it is not yet the categorized Personal System Center using GroupedNavigationList. | You Personal System Center alignment. |
| Trust / memory | Trust Center and memory controls exist, but `What Ambitions Knows` is not a named full surface and editable/deletable/recoverable memory contracts are incomplete. | Trust Center / What Ambitions Knows batches. |
| Receipts | Receipt domain and You audit card exist; searchable receipt history and privacy-safe display rules are not implemented as a cross-surface product surface. | Receipt search/history batch. |
| Accessibility | Infrastructure and labels exist, but Dynamic Type/VoiceOver/Reduce Motion/target-size verification across screen/panel combinations is not complete. | Accessibility Nutrition verification. |
| External surfaces | Widgets, Live Activity, notifications, and App Intents exist; Constitution privacy, snapshot, receipt, confirmation, and verification contracts are not complete. | External surfaces and platform validation batches. |

## 5. Planned But Not Implemented

- Full Life Areas Overview / Life Areas Atlas detail transformation beyond bounded Goals portfolio consumption.
- North Stars / dormant Ambitions detail surfaces beyond the D13 Goals rail.
- One-Step Goals detail surfaces and cross-surface behavior beyond the D09 model/projection foundation, D11 Today preview, D12 Capture routing, and D13 Goals panel.
- Smart Attachment full surface adoption with editable receipts, correction, and learning beyond the D06 foundation.
- Broad GroupedNavigationList adoption across You/Trust/Goal Detail beyond the D03 component foundation.
- Broad Panel Size and Display Density adoption across active surfaces beyond the D04 design-system foundation.
- ScreenContractRegistry snapshot adoption inside D12-D19 surface tests beyond the D10/D11 contract gates.
- Component Contract Matrix implementation pass.
- UX Writing / State Language Matrix implementation pass.
- Full Trust Center and What Ambitions Knows.
- Searchable receipt history.
- Broader semantic zoom maturity and performance verification beyond the D13 Goals Map/List fallback.
- Notification frequency/privacy controls.
- Widget/Live Activity/App Intent contract alignment and platform verification.
- User-facing Accessibility Nutrition facts after verification evidence.

## 6. Missing Entirely

| Requirement | Current repo truth | Missing work |
| --- | --- | --- |
| Task = standalone One-Step Goal | Canonical Task / One-Step Goal model and projection foundation exists; D11 adds a bounded Today preview for standalone capture-derived Tasks; D12 adds bounded Capture/Quiet Command receipt routing; D13 adds bounded Goals portfolio consumption; D14 keeps Goal Detail contained actions as Steps; existing `Step` remains contained inside goals/plans. | Full standalone detail surfaces and broader cross-surface promotion/attachment workflows remain future work. |
| Life Area first-class object | Canonical Life Area object/projection foundation exists, with D13 Goals portfolio panel consumption and Map/List fallback. | Full detail transformation remains future maturity work. |
| North Star detail | Canonical North Star / Dormant Ambition object and projection foundation exists; D13 adds bounded Goals rail consumption. | Full North Star detail remains future maturity work. |
| GroupedNavigationList component | `ListChevronRow` exists, but no `GroupedNavigationList` component/row taxonomy found. | Shared component and usage pass. |
| Panel size/density controls | No source references found for `Panel Size` or `Display Density`. | Preferences, tokens, rendering behavior, tests. |
| What Ambitions Knows | Memory Lens and Profile memory controls exist, but no named surface matching the Constitution. | You-owned memory center. |
| Receipt search | Receipt model exists; no searchable receipt history surface found. | Search/index/display/redaction. |
| Focus Support setting | No source reference found for `Focus Support`. | Accessibility/You preference and behavior contract. |
| Semantic Zoom | D13 adds a bounded Goals Life Areas Map/List presentation with accessibility labels and list fallback. | Broader semantic zoom maturity and performance guardrails remain future verification work. |

## 7. Conflicts With Active Canon

| Conflict | Evidence | Required handling |
| --- | --- | --- |
| `Habits` user-facing route remains visible in Plan toolbar | `PlanScreen.swift` button label `Habits`; `AppTab.habits` compatibility route. | Rename/absorb toward Rituals in Ritual split batch while preserving route compatibility if needed. |
| `Insights` and `Profile` compatibility code remains | `AppTab.swift`, `AppNavigation.swift`, `Features/Insights`, `Features/Profile`. | Accept internal compatibility only; future alignment should avoid user-facing top-level Profile/Insights. |
| Capture wording uses `Needs a route` rather than `Needs a Place` | `CapturesScreen.groupedCaptures`. | UX writing/Capture alignment. |
| Widget foundation still carries historical families such as habit/insight/profile | `AppUI/Sources/WidgetFoundation.swift`. | External surface contract alignment; avoid active top-level meaning. |
| App Intents expose `Command`, `Memory Lens`, `Captures inbox` | `OpenAmbitionsDestinationIntent.swift`. | Align with Quiet Command Sheet, What Ambitions Knows, and Capture naming in App Intents batch. |
| Goal Detail lens keeps an internal compatibility case named `tasks` | `GoalsFeatureModels.swift` displays that lens as `Steps`. | Preserve compatibility-only internals while keeping user-facing contained actions as Steps. |

## 8. Surface-By-Surface Gap Matrix

| Surface | Implemented and valid | Constitution gap | Recommended batch |
| --- | --- | --- | --- |
| Today | Hero, Save the Day, support/deep dive, drift states. | Today Plan Layer, relevant One-Step Goals, full planned day, explicit open-window evidence. | Today 2.0 Design Constitution Alignment. |
| Goals | Direction hero, lifecycle rail, Goal Weather, archive, Atlas preview, Life Areas panel, North Stars rail, One-Step Goals panel, and Map/List fallback. | Later maturity work can deepen Path Builder, long-range portfolio behavior, and performance evidence. | Portfolio/path maturity. |
| Goal Detail | Mission Control, breadcrumb, timeline, Proof Rail, decisions, risks, archive, receipts, and exact `Overview / Path / Steps / Proof / Decisions / Risks / Archive` lanes. | Later maturity can deepen Path Builder, review/search, and archive learning. | Portfolio/path maturity. |
| Capture | Fast input, routing actions, recent captures, attach to goal. | Needs a Place, Smart Attachment, editable Smart Attachment receipts, 1-3 clarification choices. | Capture + Quiet Command Sheet; Smart Attachment. |
| Plan | Believability, Plan Treaty, timeline strip, calendar boundary, recovery/reflow. | Rich Timeline Widget, Ritual language, local-first calendar labels, Plan-owned permission proof. | Plan Believability + Timeline Widget; Ritual split. |
| You | Profile-backed You, Trust Center card, memory controls, reviews, appearance, integrations. | Personal System Center categories, GroupedNavigationList, What Ambitions Knows, full privacy/export/import controls. | You Personal System Center; Trust Center; What Ambitions Knows. |
| Life Areas Overview | Foundation Life Area object/projection layer, Goal Atlas preview hooks, and D13 Goals portfolio panel exist. | Dedicated detail/deeper transformation remains future maturity work. | Portfolio/path maturity. |
| North Star Detail | Foundation North Star object/projection layer and D13 Goals rail exist. | Full detail surface absent. | Portfolio/path maturity. |
| Task / One-Step Goal Detail | Model/projection foundation exists; D11 Today can surface compact standalone One-Step Goals, D12 can route/save from Capture, D13 can show controlled Goals portfolio items, and D14 keeps contained Goal Detail work as Steps without creating a Tasks tab. | Full standalone detail and broader Plan panel UI remain future surface work. | Plan alignment / maturity. |
| Review | Reviews v1 is You-owned. | Needs receipt/search/memory maturity and Constitution copy pass. | Reviews/receipt maturity. |
| Trust Center | Present as Profile/You card. | Needs dedicated navigation and GroupedNavigationList structure. | Trust Center Alignment. |
| What Ambitions Knows | Memory Lens and memory controls exist. | Named center absent. | What Ambitions Knows. |
| Archive | Goal archive summary exists. | Cross-object archive and receipt learning not complete. | Receipt/Archive maturity. |

## 9. Component-By-Component Gap Matrix

| Component | Current status | Gap |
| --- | --- | --- |
| Panel system | Rich panel primitives exist. | Constitution panel jobs/types incomplete; density/size absent. |
| Hero Decision Panel | Used in Today/rich panels. | Needs contract verification across screens. |
| Today Plan Panel | Not found as named component. | Implement in Today alignment. |
| Life Areas Panel | D13 adds a Goals Life Areas panel with Map/List presentation. | Future detail/maturity surfaces can reuse the projection. |
| One-Step Goals Panel | D13 adds a controlled Goals One-Step Goals panel; D11 has bounded Today preview consumption. | Full detail/workflow remains future Goal Detail/Plan work. |
| GroupedNavigationList | Not found. | New shared component required. |
| Navigation Rows | `ListChevronRow` exists. | Official row taxonomy missing. |
| Receipt Panels | Receipts cards exist in Goal Detail/You. | Search/history/redaction contract missing. |
| Weekly Plan Strip | Plan timeline strip exists. | Needs Rich Timeline Widget/Constitution naming alignment. |
| Timeline Widget | Timeline strip/cards exist. | Needs official widget contract. |
| Goal Lifecycle Rail | Goals and Plan lifecycle rails exist. | Needs Life Areas/North Stars/semantic zoom integration. |
| Proof Rail | Goal Detail Proof Rail exists. | Needs proof/receipt/search maturity. |
| North Stars Rail | D13 adds a bounded Goals North Stars rail over the D08 projection. | Full North Star detail remains future maturity work. |
| Continuity Ribbon | External continuity model exists. | Named UI component not found. |
| Quiet Command Sheet | Shell sheet exists. | Smart Attachment receipt/clarification behavior missing. |
| Smart Attachment Receipt | Not found. | New component/contract. |

## 10. Object-Model Gap Matrix

| Object | Current implementation | Constitution status |
| --- | --- | --- |
| Life Area | Canonical Life Area object/projection foundation exists with D13 Goals panel consumption. | Needs deeper detail/maturity surfaces later. |
| Ambition / North Star | Canonical North Star / Dormant Ambition object/projection foundation exists under Life Areas with D13 Goals rail consumption. | Needs full detail surface later. |
| Goal | Implemented. | Valid foundation. |
| Path | Path/life graph foundations exist. | Needs Constitution-facing path surfaces later. |
| Plan | Implemented as Plan 2.0 surface/foundation. | Needs timeline/ritual alignment. |
| Milestone | Goal plan sections/stages exist. | Needs visual milestone contract verification. |
| Step | Implemented inside goal/plan structures. | Must be reserved for contained actions. |
| Task | First-class standalone One-Step Goal model/projection foundation exists with D11 Today, D12 Capture, and D13 Goals bounded consumption. | Needs full detail surfaces and broader workflow integration. |
| Proof | Evidence/proof graph and Proof Rail exist. | Needs cross-surface maturity. |
| Receipt | Model and surface snippets exist. | Needs searchable history/privacy display. |
| Review | Reviews v1 exists. | Needs maturity and memory/receipt connection. |
| Archive | Goal archive states/summary exist. | Needs cross-object archive learning. |

## 11. UX-Writing Gap Matrix

| Requirement | Current status | Gap |
| --- | --- | --- |
| Calm/adult/non-shaming | Mostly present. | Needs systematic matrix pass. |
| No AI-wrapper language | No `AI Confidence` / `AI Explanation` found in source scan. | Keep guarded. |
| `Needs a Place` | Not found in source scan. | Replace Capture routing language where active. |
| `Saved as [object] - [area] - [route]` | Not found as active receipt pattern. | Add with Smart Attachment receipts. |
| `Why This`, `Why Now`, `Why Changed`, `What This Uses` | Not consistently found in source scan. | Explanation label cleanup. |
| `Update This` | Not found in source scan. | Correction copy cleanup. |
| `Save the Day` | Implemented in Today/Plan. | Add Save the Week where needed. |
| `Park / Not Today` | Not explicit as paired label. | Reality Reflow/Today cleanup. |
| `Drifted` | Present in Today posture. | Valid, verify state copy. |
| `Focus Support` | Not found. | Accessibility/You setting needed. |

## 12. Accessibility Gap Matrix

| Requirement | Current evidence | Status |
| --- | --- | --- |
| Dynamic Type | SwiftUI text styles and checklist exist. | Unverified across all screens. |
| VoiceOver | Many labels/identifiers and checklist exist. | Unverified reading order/values/hints. |
| Reduce Motion | Several surfaces use `accessibilityReduceMotion`. | Needs systematic variants and proof. |
| No color-only meaning | Icons/text/status pills common. | Needs verification. |
| Tap target size | Button styles and rows exist. | Needs verification. |
| Gesture alternatives | Some visible actions exist. | Swipe/drag/long-press alternatives need audit. |
| Focus not obscured | No full verification evidence found. | Unverified. |
| Focus Support | Not found as setting. | Missing. |
| Panel Size / Display Density | Not found. | Missing foundation. |
| Accessibility Nutrition status | Internal default is Unverified. | Correct; do not publish user-facing claims yet. |

## 13. Trust / Privacy Gap Matrix

| Requirement | Current evidence | Gap |
| --- | --- | --- |
| Trust Center | Profile-backed You card exists. | Needs dedicated center/navigation contract. |
| What Ambitions Knows | Memory controls and Memory Lens exist. | Named editable/deletable/correctable memory surface absent. |
| Editable memory | Correction/teaching foundations exist. | Full memory editing/deletion/recovery not implemented. |
| Searchable receipts | Receipt model/card exists. | Search/history absent. |
| Privacy-safe receipts | Receipt safety fields exist. | Redacted display rules need implementation. |
| Local-first calendar-derived insight | Reality/Plan foundation exists. | Needs labels and minimum-derived-data verification. |
| Plan-owned calendar permission | Present in Plan. | Needs regression test/UX proof and no onboarding drift. |
| Export/import trust fallback | Portable snapshot foundations exist. | Disaster drill remains future. |
| External data labels | Some trust copy exists. | `From your calendar`, `Created in Ambitions`, `Based on your plan` need systematic use. |

## 14. External-Surface Gap Matrix

| Surface | Current implementation | Constitution status |
| --- | --- | --- |
| Widgets | `AmbitionsWidgetExtension` and shared snapshots exist. | Requires contract alignment and platform verification. |
| Live Activities | ActivityKit widget and service exist. | Requires Now State/Command Pipeline stability verification and privacy default pass. |
| App Intents / Shortcuts | Open destination and Capture intents exist. | Requires receipt, confirmation, privacy, and naming alignment. |
| Notifications | Local next-step notification exists. | Needs frequency/privacy controls, sparse styles, sensitive-detail defaults. |
| Focus Filters | Not found. | Future only. |
| Share Extension | Present in repo paths/project history, not fully audited in this pass. | Do not mark complete without separate validation. |

## 15. Recommended New Batches

These are future delta/alignment batches. They do not replace the existing Batch 61-120 history and should not be marked complete until implementation evidence exists.

| Delta | Batch name | Purpose |
| --- | --- | --- |
| D01 | Shell IA / Tab Alignment Delta | Preserve five tabs, add current-tab tap behavior, clean active copy/naming, keep compatibility internal. |
| D02 | Shared Object Terminology Cleanup | Align Task/Step, Life Area, North Star, Ritual, Receipt, Review, and Archive naming before surfaces consume them; canonical terminology doc now exists. |
| D03 | GroupedNavigationList Component | Implement shared grouped list and row taxonomy. |
| D04 | Panel Size + Display Density | Add Compact/Comfortable/Large and Minimal/Balanced/Detailed foundations. |
| D05 | Receipt / Action Closure Search and Privacy Contract | Add searchable receipt history, privacy redaction, and display rules. |
| D06 | Smart Attachment Foundation | Implement named routing/confidence/clarification/receipt/correction behavior. |
| D07 | Life Areas Overview / Atlas Object Model | Completed foundation: Life Areas are now a canonical object/projection layer and visible organization lens, not a tab. D13 adds bounded Goals portfolio consumption; deeper detail/maturity work remains future. |
| D08 | North Stars / Dormant Ambitions Object Model | Completed foundation: North Stars / Dormant Ambitions are now canonical objects under Life Areas with deterministic local projection, privacy/accessibility fields, relationship hooks, and shaping metadata. Full detail/rail surfaces remain D13. |
| D09 | One-Step Goals Object Model | Completed foundation: Task is now a standalone One-Step Goal model/projection with promotion/attachment/demotion receipt metadata, privacy/accessibility fields, Life Graph references, and Life Area hooks. D11 adds bounded Today preview consumption, D12 adds Capture routing, D13 adds Goals portfolio consumption, and D14 preserves contained Goal Detail actions as Steps; full standalone detail/workflow integration remains future work. |
| D10 | Screen Contract Matrix Implementation Pass | Completed contract gate: `ScreenContractRegistry` and `ScreenContractValidator` now cover screen-matrix rows, canonical five-tab IA, D03-D09 dependencies, density/size, accessibility/privacy, forbidden old IA/copy detection, external-surface contract status, and D11-D19 handoff ownership. Surface transformations remain owned by D11-D19. |
| D11 | Today 2.0 Design Constitution Alignment | Completed alignment: Today now has a compact Today Plan Layer, source/open-window labels, D09-backed One-Step Goals preview consumption, visible move/park/mark-done affordances, and D10 contract snapshot coverage without calendar prompts, new tabs, or unrelated surface redesign. |
| D12 | Capture + Quiet Command Sheet Alignment | Completed alignment: Capture and the Quiet Command Sheet now use Smart Attachment-backed route previews/receipts, Needs a Place hold behavior, compact route choices, and post-save Capture handoff without chat UI, new tabs, calendar behavior, or broad surface redesign. |
| D13 | Goals / Life Areas / North Stars Transformation and Semantic Zoom | Completed alignment: Goals now consumes Life Areas, North Stars, and One-Step Goals projections with bounded portfolio panels, accessible Map/List fallback, North Stars rail, One-Step Goals panel, and D10 contract snapshot coverage without adding tabs or detail workflows. |
| D14 | Goal Detail Mission Control Lanes Alignment | Completed alignment: Goal Detail now uses exact Mission Control lanes, Step-safe contained action language, decisions/risks/archive projection cards, proof/receipt continuity, and D10 contract snapshot coverage without Goals overview redesign or Path Builder. |
| D15 | Plan Believability + Timeline Widget Alignment | Next: align timeline widget, open windows, local-first labels. |
| D16 | Ritual Split Alignment | Replace standalone habit posture with Rituals across Plan/Today/You. |
| D17 | You Personal System Center Alignment | Build categorized You structure without a settings dump. |
| D18 | Trust Center Alignment | Make Trust Center navigable, privacy-safe, and receipt-aware. |
| D19 | What Ambitions Knows | Build visible/editable/correctable memory center. |
| D20 | UX Writing Cleanup | Apply state-language matrix across surfaces. |
| D21 | Accessibility Nutrition Verification | Verify screen/component matrices before claims. |
| D22 | External Surfaces Contract Alignment | Align snapshots/actions/privacy/deep links before platform-specific deltas. |
| D23 | Widgets Alignment | Align widgets after Now State stability with lightweight snapshots. |
| D24 | Live Activities Alignment | Align Live Activities after Now State and Command Pipeline stability. |
| D25 | App Intents / Shortcuts Alignment | Align intents/Shortcuts with receipts, confirmation, and privacy. |
| D26 | Release Candidate Validation | Validate aligned surfaces, claims, performance, and docs before RC lock. |

## 16. Dependency Order

1. Shell IA / Tab Alignment Delta.
2. Shared object terminology cleanup for Task vs Step, Life Area, North Star, Ritual, Receipt.
3. GroupedNavigationList Component.
4. Panel Size + Display Density.
5. Receipt / Action Closure search and privacy contract.
6. Smart Attachment Foundation.
7. Life Areas Overview / Atlas object model.
8. North Stars / Dormant Ambitions object model.
9. One-Step Goals Object Model.
10. Screen Contract Matrix implementation pass.
11. Today 2.0 Design Constitution Alignment.
12. Capture + Quiet Command Sheet Alignment.
13. Goals / Life Areas / North Stars transformation and Semantic Zoom.
14. Goal Detail Mission Control Lanes Alignment (completed).
15. Plan Believability + Timeline Widget Alignment.
16. Ritual Split Alignment.
17. You Personal System Center Alignment.
18. Trust Center Alignment.
19. What Ambitions Knows.
20. UX Writing Cleanup.
21. Accessibility Nutrition Verification.
22. External Surfaces Contract Alignment.
23. Widgets Alignment.
24. Live Activities Alignment.
25. App Intents / Shortcuts Alignment.
26. Release Candidate Validation.

## 17. Items That Must Not Be Implemented Yet

- Do not create a top-level Tasks tab.
- Do not reintroduce Insights, Profile, or Habits as top-level tabs.
- Do not make Capture tab behave like a floating action button.
- Do not request calendar or notification permission during onboarding.
- Do not ship user-facing accessibility claims before verification evidence.
- Do not claim widgets, Live Activities, App Intents, Shortcuts, or notifications are production-complete before platform validation.
- Do not implement sync, cloud memory, account systems, destructive memory deletion, or silent calendar writes as part of these alignment batches.
- Do not build semantic zoom before accessible list fallback and performance limits are defined.
- Do not build Smart Attachment without receipts and correction.

## 18. Validation Commands Run

- `find Native/Ambitions -maxdepth 3 -type f \( -name '*.swift' -o -name '*.plist' \) | sort`
  - Result: reviewed native app file structure.
- `find Native -maxdepth 4 -type d | sort`
  - Result: reviewed app, test, widget, share extension, and support directories.
- `rg -n "Insights|Profile|Habits|Tasks|Task|Step|AI|calendar|permission|accessibility|widgets|Live Activities|App Intents" Native/Ambitions AppUI Sources Tests project.yml`
  - Result: produced useful output but exited with an error because `Tests` does not exist at repo root.
- `rg -n "GroupedNavigationList|Navigation Row|Panel Size|Display Density|NorthStar|North Star|Life Area|Life Areas|One-Step|OneStep|Needs a Place|Why This|Why Now|Why Changed|What This Uses|Update This|Save the Week|Park / Not Today|Drifted|AI Confidence|AI Explanation|ADHD Mode|Focus Support" Native/Ambitions AppUI Sources Native/AmbitionsTests Native/AmbitionsUITests project.yml`
  - Result at audit time: found only `Drifted` in Today source; no source hits for GroupedNavigationList, Panel Size, Display Density, North Star, One-Step, Needs a Place, AI Confidence, AI Explanation, ADHD Mode, or Focus Support. Later D08/D09 work added North Star and One-Step Goal model/projection source hits without changing the remaining gap classifications.
- Targeted `sed` reads over shell, navigation, Today, Capture, Goals, Goal Detail, Plan, Profile/You, onboarding, App Intents, notifications, external snapshots, widget extension, shared components, accessibility, roadmap, batch plan, backlog, context, and registry files.
  - Result: evidence captured in this audit.

No build or test suite was run because this was a docs/audit/sequencing batch with no app source changes.
