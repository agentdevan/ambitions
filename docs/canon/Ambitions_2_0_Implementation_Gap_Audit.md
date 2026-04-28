# Ambitions 2.0 Implementation Gap Audit

Status: Active implementation audit.
Date: 2026-04-27.

This audit compares the current repo and native app against [design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md). It does not reopen, renumber, or erase completed historical batches. Completed batches remain completed for history; gaps created by the Design Constitution become future delta/alignment batches.

D02 evidence: [Ambitions_2_0_Object_Terminology.md](Ambitions_2_0_Object_Terminology.md) now locks shared object language before later feature batches consume those objects.

## 1. Executive Summary

The repo has substantial native foundations: the five-tab shell, local-first SwiftUI app, Capture persistence, Command Pipeline, Event Ledger, Action Closure receipt models, Plan-owned calendar action boundary, rich panel primitives, Accessibility Nutrition infrastructure, Profile-backed You trust surface, local notification foundation, App Intents, widgets, and Live Activity scaffolding.

The app is not yet Constitution-complete. The biggest gaps are first-class Life Areas / North Stars, Tasks as standalone One-Step Goals, Smart Attachment as a named routing/receipt/correction system, GroupedNavigationList, Panel Size + Display Density, searchable receipt history, Today Plan Layer, full You Personal System Center structure, What Ambitions Knows, semantic zoom, and verified Accessibility Nutrition.

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
| Goals | Has Goal Lifecycle Rail, Goal Weather, Goal Atlas preview, archive summary, active cards. Life Areas, North Stars rail, One-Step Goals section, and semantic zoom are not first-class. | Goals / Life Areas / North Stars transformation. |
| Goal Detail | Has Mission Control, breadcrumb, timeline, Proof Rail, receipts, tactics/tasks lens. Constitution lanes are not exactly `Overview / Path / Steps / Proof / Decisions / Risks / Archive`; Tasks/Steps wording needs alignment. | Goal Detail Mission Control lanes alignment. |
| Plan | Has Plan Treaty, capacity, lifecycle rail, timeline strip, believability, calendar boundary, recovery/reflow. It still exposes a `Habits` toolbar route and needs Rich Timeline Widget/Ritual language alignment. | Plan believability + timeline widget and Ritual split alignment. |
| You | Profile-backed You has Trust Center, memory controls, receipts, reviews, appearance, integrations, notification permission; it is not yet the categorized Personal System Center using GroupedNavigationList. | You Personal System Center alignment. |
| Trust / memory | Trust Center and memory controls exist, but `What Ambitions Knows` is not a named full surface and editable/deletable/recoverable memory contracts are incomplete. | Trust Center / What Ambitions Knows batches. |
| Receipts | Receipt domain and You audit card exist; searchable receipt history and privacy-safe display rules are not implemented as a cross-surface product surface. | Receipt search/history batch. |
| Accessibility | Infrastructure and labels exist, but Dynamic Type/VoiceOver/Reduce Motion/target-size verification across screen/panel combinations is not complete. | Accessibility Nutrition verification. |
| External surfaces | Widgets, Live Activity, notifications, and App Intents exist; Constitution privacy, snapshot, receipt, confirmation, and verification contracts are not complete. | External surfaces and platform validation batches. |

## 5. Planned But Not Implemented

- Life Areas Overview / Life Areas Atlas.
- North Stars / dormant Ambitions as first-class objects and surfaces.
- One-Step Goals as standalone Tasks with promotion/demotion/attachment behavior.
- Smart Attachment named system with confidence behavior, editable receipts, correction, and learning.
- GroupedNavigationList and official row types.
- Panel Size: Compact / Comfortable / Large.
- Display Density: Minimal / Balanced / Detailed.
- Screen Contract Matrix implementation pass.
- Component Contract Matrix implementation pass.
- UX Writing / State Language Matrix implementation pass.
- Full Trust Center and What Ambitions Knows.
- Searchable receipt history.
- Semantic Zoom with accessibility and performance fallbacks.
- Notification frequency/privacy controls.
- Widget/Live Activity/App Intent contract alignment and platform verification.
- User-facing Accessibility Nutrition facts after verification evidence.

## 6. Missing Entirely

| Requirement | Current repo truth | Missing work |
| --- | --- | --- |
| Task = standalone One-Step Goal | Existing code mostly uses `Step` inside goals/plans and capture route labels. | First-class Task/One-Step Goal model, detail surface, promotion/demotion/attachment, tests. |
| Life Area first-class object | `LifeGraphContext` has domains/assignments, but not Constitution Life Areas Overview/Atlas. | Life Area object model and surfaces. |
| North Star detail | No first-class North Star model/detail surface found. | Dormant ambition/North Star model, detail, and rails. |
| GroupedNavigationList component | `ListChevronRow` exists, but no `GroupedNavigationList` component/row taxonomy found. | Shared component and usage pass. |
| Panel size/density controls | No source references found for `Panel Size` or `Display Density`. | Preferences, tokens, rendering behavior, tests. |
| What Ambitions Knows | Memory Lens and Profile memory controls exist, but no named surface matching the Constitution. | You-owned memory center. |
| Receipt search | Receipt model exists; no searchable receipt history surface found. | Search/index/display/redaction. |
| Focus Support setting | No source reference found for `Focus Support`. | Accessibility/You preference and behavior contract. |
| Semantic Zoom | Goal Atlas preview exists; no accessible semantic zoom implementation found. | Zoom model, list fallback, performance guardrails. |

## 7. Conflicts With Active Canon

| Conflict | Evidence | Required handling |
| --- | --- | --- |
| `Habits` user-facing route remains visible in Plan toolbar | `PlanScreen.swift` button label `Habits`; `AppTab.habits` compatibility route. | Rename/absorb toward Rituals in Ritual split batch while preserving route compatibility if needed. |
| `Insights` and `Profile` compatibility code remains | `AppTab.swift`, `AppNavigation.swift`, `Features/Insights`, `Features/Profile`. | Accept internal compatibility only; future alignment should avoid user-facing top-level Profile/Insights. |
| Capture wording uses `Needs a route` rather than `Needs a Place` | `CapturesScreen.groupedCaptures`. | UX writing/Capture alignment. |
| Widget foundation still carries historical families such as habit/insight/profile | `AppUI/Sources/WidgetFoundation.swift`. | External surface contract alignment; avoid active top-level meaning. |
| App Intents expose `Command`, `Memory Lens`, `Captures inbox` | `OpenAmbitionsDestinationIntent.swift`. | Align with Quiet Command Sheet, What Ambitions Knows, and Capture naming in App Intents batch. |
| Goal Detail lens says `Tasks` for goal-contained items | `GoalsFeatureModels.swift`. | Clarify contained Steps vs standalone One-Step Goals. |

## 8. Surface-By-Surface Gap Matrix

| Surface | Implemented and valid | Constitution gap | Recommended batch |
| --- | --- | --- | --- |
| Today | Hero, Save the Day, support/deep dive, drift states. | Today Plan Layer, relevant One-Step Goals, full planned day, explicit open-window evidence. | Today 2.0 Design Constitution Alignment. |
| Goals | Direction hero, lifecycle rail, Goal Weather, archive, Atlas preview. | Life Areas, North Stars rail, One-Step Goals section, Semantic Zoom. | Goals / Life Areas / North Stars transformation. |
| Goal Detail | Mission Control, breadcrumb, timeline, Proof Rail, receipts. | Exact lanes, Step/Task distinction, Archive lane, Decision Trail consistency. | Goal Detail Mission Control Lanes Alignment. |
| Capture | Fast input, routing actions, recent captures, attach to goal. | Needs a Place, Smart Attachment, editable Smart Attachment receipts, 1-3 clarification choices. | Capture + Quiet Command Sheet; Smart Attachment. |
| Plan | Believability, Plan Treaty, timeline strip, calendar boundary, recovery/reflow. | Rich Timeline Widget, Ritual language, local-first calendar labels, Plan-owned permission proof. | Plan Believability + Timeline Widget; Ritual split. |
| You | Profile-backed You, Trust Center card, memory controls, reviews, appearance, integrations. | Personal System Center categories, GroupedNavigationList, What Ambitions Knows, full privacy/export/import controls. | You Personal System Center; Trust Center; What Ambitions Knows. |
| Life Areas Overview | Goal Atlas preview only. | Full Life Areas Overview / Atlas absent. | Life Areas Overview / Atlas. |
| North Star Detail | Not found. | Full surface absent. | North Stars / Dormant Ambitions. |
| Task / One-Step Goal Detail | Not found. | Full object/detail absent. | One-Step Goals Object Model. |
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
| Life Areas Panel | Not found as named component. | Implement with Life Areas Atlas. |
| One-Step Goals Panel | Not found as named component. | Implement with One-Step Goals. |
| GroupedNavigationList | Not found. | New shared component required. |
| Navigation Rows | `ListChevronRow` exists. | Official row taxonomy missing. |
| Receipt Panels | Receipts cards exist in Goal Detail/You. | Search/history/redaction contract missing. |
| Weekly Plan Strip | Plan timeline strip exists. | Needs Rich Timeline Widget/Constitution naming alignment. |
| Timeline Widget | Timeline strip/cards exist. | Needs official widget contract. |
| Goal Lifecycle Rail | Goals and Plan lifecycle rails exist. | Needs Life Areas/North Stars/semantic zoom integration. |
| Proof Rail | Goal Detail Proof Rail exists. | Needs proof/receipt/search maturity. |
| North Stars Rail | Not found. | New component. |
| Continuity Ribbon | External continuity model exists. | Named UI component not found. |
| Quiet Command Sheet | Shell sheet exists. | Smart Attachment receipt/clarification behavior missing. |
| Smart Attachment Receipt | Not found. | New component/contract. |

## 10. Object-Model Gap Matrix

| Object | Current implementation | Constitution status |
| --- | --- | --- |
| Life Area | Life graph domain/context exists. | Needs first-class Life Area model and surface. |
| Ambition / North Star | Long-range/path concepts exist. | North Star not first-class. |
| Goal | Implemented. | Valid foundation. |
| Path | Path/life graph foundations exist. | Needs Constitution-facing path surfaces later. |
| Plan | Implemented as Plan 2.0 surface/foundation. | Needs timeline/ritual alignment. |
| Milestone | Goal plan sections/stages exist. | Needs visual milestone contract verification. |
| Step | Implemented inside goal/plan structures. | Must be reserved for contained actions. |
| Task | Not first-class as standalone One-Step Goal. | Major missing object model. |
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
| D07 | Life Areas Overview / Atlas Object Model | Completed foundation: Life Areas are now a canonical object/projection layer and visible organization lens, not a tab. Full surface transformation remains D13. |
| D08 | North Stars / Dormant Ambitions Object Model | Add dormant ambition semantics and detail surfaces. |
| D09 | One-Step Goals Object Model | Add Task as standalone One-Step Goal and promotion/demotion/attachment rules. |
| D10 | Screen Contract Matrix Implementation Pass | Wire the screen matrix into implementation acceptance criteria before surface deltas. |
| D11 | Today 2.0 Design Constitution Alignment | Add Today Plan Layer, One-Step Goals surfacing, planned-day view, and Constitution copy. |
| D12 | Capture + Quiet Command Sheet Alignment | Align Capture with Needs a Place and make global command sheet feel like the Quiet Command Sheet. |
| D13 | Goals / Life Areas / North Stars Transformation and Semantic Zoom | Add Life Areas, North Stars, One-Step Goals section, and accessible semantic zoom. |
| D14 | Goal Detail Mission Control Lanes Alignment | Align lanes, Step/Task naming, decisions, risks, archive. |
| D15 | Plan Believability + Timeline Widget Alignment | Align timeline widget, open windows, local-first labels. |
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
14. Goal Detail Mission Control Lanes Alignment.
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
  - Result: found only `Drifted` in Today source; no source hits for GroupedNavigationList, Panel Size, Display Density, North Star, One-Step, Needs a Place, AI Confidence, AI Explanation, ADHD Mode, or Focus Support.
- Targeted `sed` reads over shell, navigation, Today, Capture, Goals, Goal Detail, Plan, Profile/You, onboarding, App Intents, notifications, external snapshots, widget extension, shared components, accessibility, roadmap, batch plan, backlog, context, and registry files.
  - Result: evidence captured in this audit.

No build or test suite was run because this was a docs/audit/sequencing batch with no app source changes.
