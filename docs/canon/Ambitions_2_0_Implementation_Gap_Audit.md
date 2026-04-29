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

The app is not yet release-candidate locked. The D01-D26 Design Constitution delta/alignment layer is complete for planning purposes after D26 release-candidate validation, M01-M12 are complete for planning purposes through Cross-Surface Continuity, Mode Lens, Mature Invention Performance, and R01-R03 are complete for planning purposes through accessibility claims lock, performance/responsiveness evidence, and device-readiness/scenario-review evidence; the next implementation layer is R04 App Store, Privacy, Marketing, and Investor Demo Readiness. Life Areas, North Stars, and One-Step Goals now have foundation object/projection layers; Today has its D11 plan/One-Step preview alignment; Capture has its D12 Smart Attachment / Needs a Place alignment; Goals has D13 bounded portfolio consumption with accessible Map/List fallback and M10 qualitative portfolio maturity signals for scope, stuck work, proof, next-step clarity, and archive learning; Goal Detail has D14 Mission Control lane alignment with D20 plain visible labels and M07 Path Builder over the M05-M06 path intelligence seam; Plan has D15 believability, Rich Timeline, Weekly Plan Strip, local-first calendar evidence alignment, D20 state-language cleanup, and M11 recovery maturity signals for overloaded days, waiting/commitments, private/manual social load, confirmation boundaries, calendar write limits, and receipt/undo posture; Ritual language is aligned in D16; You has its D17 Personal System Center grouping with D20 plain visible labels; Trust Center has its D18 navigable, receipt-aware, privacy-safe alignment; What Ambitions Knows has its D19 bounded local memory center and M08 reviewable narrative memory/conservative pattern projection; Reviews now has M09 cadence/progress-receipt/planning-handoff maturity without top-level Insights or analytics-dashboard creep; the shell now has an M12 continuity ribbon and a code-backed continuity/performance report across Today, Capture, Goals, Plan, You, Reviews, external surfaces, and Goal Detail Path Builder; R02 adds a code-backed `ReleasePerformanceResponsivenessReport` over launch, navigation, Today, Goal Detail, Plan, receipts/history, memory/reviews, path/portfolio, and external snapshots without fake timing thresholds or real-device performance claims; R03 adds a code-backed `ReleaseDeviceQAReadinessReport` over physical-device, fresh-install, returning-user, denied-permission, data-volume, week-away, export/import, external-surface, and representative scenario readiness while keeping TestFlight gated on physical-device proof; D20 added Human Language Review guard coverage; D21 added internal Accessibility Nutrition evidence while keeping public claims locked; R01 adds a code-backed accessibility claims lock and You/Profile `Claims locked` copy without publishing Accessibility Nutrition Facts; D22-D25 aligned external-surface contracts, widgets, Live Activities, and App Intents / Shortcuts without production-readiness claims; D26 validated the alignment evidence without claiming final RC lock or App Store readiness; M01 added a code-backed scenario catalog, manual checklist, and blocker classification without claiming release readiness; M02 added portable snapshot manifests, selected categories, safe import summaries, warnings, and encoded fresh-store restore proof without claiming cloud sync or a finished export/import UI; M03 added partial-package reference warnings, malformed/legacy package safety proof, and no-lost-data merge preservation without claiming sync, real-device backup, or production-store migration proof; M04 added a code-backed external-surface verification checklist and regression proof without claiming device/platform readiness; M05 added a qualitative path intelligence projection contract; M06 added broad domain packs and explainable fork comparison without a Path tab, professional-advice claims, hidden scoring, persistence, export, or sync; M07 added Goal Detail Path Builder UI without broad path mutation/editing, automatic roadmap changes, semantic zoom dependency, real-device/manual UI proof, or rendered accessibility proof; M08 added reviewable narrative memory and conservative pattern signals without broad destructive deletion, global pause/forget preferences, cloud/account/sync memory, sensitive identity inference, confidence-score UI, or black-box recommendation copy; M10 added Goals portfolio maturity without fake numerical certainty, kanban structure, a full archive browser, path editing, or a Tasks tab; M11 added Plan recovery maturity without silent reflow, calendar writes, a promise-ledger UI, release-readiness claims, or a new top-level surface; M12 does not claim rendered external-platform verification, real-device performance measurements, TestFlight readiness, App Store readiness, or RC lock, R01 does not claim manual accessibility proof, R02 does not claim real-device performance proof, and R03 does not claim physical-device, TestFlight, App Store, or rendered external-platform proof.

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
| Plan-owned calendar action | `PlanScreen.handleCalendarAwarenessAction` calls Plan service only when the Plan card allows it; onboarding does not request calendar access; D15 adds local-first evidence labels for `From your calendar`, `Created in Ambitions`, and `Based on your plan`. | Valid foundation. |
| Rich panel primitives | `Sources/Components/RichPanelPrimitives.swift` defines panel kinds, semantic states, accessibility hooks. | Valid foundation, needs Constitution panel taxonomy expansion. |
| Accessibility Nutrition infrastructure | `Sources/Accessibility/AccessibilityNutrition.swift`, `Sources/Accessibility/AccessibilityClaimsLock.swift`, `AccessibilityNutritionChecklistTests.swift`. | Valid internal infrastructure; public claims remain locked until manual proof. |
| You trust/control foundation | `ProfileScreen.swift` user-facing title is `You`; Profile service builds Trust Center, memory controls, receipts, conservative status. | Valid foundation, not full Personal System Center. |
| Widgets / Live Activity scaffolding | `Native/AmbitionsWidgetExtension`, `ExternalSurfaceSnapshotBuilder.swift`, `NextStepLiveActivityService.swift`. | Valid scaffolding; not production-complete under the Constitution. |
| App Intents / Shortcuts scaffolding | `OpenAmbitionsDestinationIntent.swift`. | D25 aligns shortcut command names, privacy, confirmation, safe routing, and App Intent source handling; real-device Shortcuts/Siri visibility remains unclaimed. |
| Local notification foundation | `LocalNotificationFoundation.swift` defines categories, opt-in request, and next-step scheduling. | Valid foundation; needs frequency/privacy controls. |

## 4. Implemented But Needs Alignment

| Area | Gap | Required delta |
| --- | --- | --- |
| Shell IA | Internal compatibility names still include `captures`, `profile`, `insights`, and `habits`; current-tab tap once/twice behavior was not found. | Shell IA / tab alignment delta. |
| Navigation stacks | Major tabs use `NavigationStack`, but Today/Capture stack preservation and tab retap behavior are not explicit. | Shell/navigation behavior pass. |
| Quiet Command Sheet | Exists, but user-facing copy centers on `Command`, not the Quiet Command Sheet / Smart Attachment contract. | Capture + Quiet Command Sheet alignment. |
| Capture | Uses `Needs a Place`, suggested routes, Plan idea language, attach/change route affordances, and local receipts. | Later maturity can deepen correction and receipt review flows. |
| Today | Has Hero Decision Panel, Save the Day, support panels, and drift handling, but no explicit Today Plan Layer, One-Step Goals panel, or full planned-day matrix. | Today 2.0 Design Constitution Alignment. |
| Goals | Has Goal Lifecycle Rail, Goal Weather, Goal Atlas preview, archive summary, active cards, D13 Life Areas / North Stars / One-Step Goals portfolio panels with Map/List fallback, and M10 qualitative portfolio maturity signals for scope, stuck work, proof, next-step clarity, and archive learning. | Later maturity can deepen full archive browsing, confirmed path editing, and release/manual proof after M11-M12/R-gates. |
| Goal Detail | Has exact Mission Control lanes `Overview / Path / Steps / Proof / Decisions / Risks / Archive`, breadcrumb/object identity, timeline, Proof Rail, decisions, risks, archive learning, receipts, Step-safe contained action language, and M07 Path Builder with phases, dependencies, fork prompts, proof checks, Today/Plan handoff copy, accessible list fallback, and a compact performance budget. | Later maturity work can deepen review/search, archive learning, and confirmed path-editing behavior after M08-M12. |
| Plan | Has Plan Treaty, capacity, lifecycle rail, Rich Timeline source labels, Weekly Plan Strip naming, believability, calendar boundary, recovery/reflow, D10 Plan screen-contract snapshot coverage, and Ritual support-loop language while preserving compatibility routes internally. | Later maturity work can deepen planning/recovery after D17-D26. |
| You | Profile-backed You now has a D17 Personal System Center map using GroupedNavigationList categories for Profile, Personalization, Memory / What Ambitions Knows, Reviews, Analytics, Trust & Explanations, Privacy, Sync / Export, Integrations, Appearance, Notifications, Accessibility, and Settings. D19 deepens What Ambitions Knows without turning You into a settings dump or adding tabs, D20 keeps the visible heading plain, D21 records internal accessibility evidence without publishing claims, D22 adds the shared external-surface contract foundation, D23 aligns widgets to that contract, D24 aligns Live Activities to the same privacy/stale/deep-link boundaries, and D25 aligns App Intents / Shortcuts naming plus confirmation posture. M01 now proves the core surfaces through a scenario QA catalog and manual checklist. M02 proves the portable export/import service contract without claiming a finished You UI. M03 proves service-level partial/corrupt/legacy/no-lost-data safety on that seam without claiming sync or real-device backup proof. M04 verifies existing external-surface continuity/stale/private/failure contracts while keeping device/platform readiness unclaimed. M05 adds a qualitative path intelligence projection layer over existing Goals/Goal Detail/Plan seams. M06 adds broad domain packs and explainable fork comparison over that seam. M07 adds the Goal Detail-owned Path Builder UI over that seam. M08 adds reviewable narrative memory and conservative pattern signals inside What Ambitions Knows. M09 matures Reviews with cadence summaries, progress receipt lines, and confirmation-safe planning handoffs. | M11 should deepen Plan/recovery without turning You or Reviews into dashboards. |
| Trust / memory | Trust Center now has D18 GroupedNavigationList sections for status/boundaries, receipts/corrections/explanations, and privacy/future capabilities plus privacy-safe receipt summaries. D19 adds a named What Ambitions Knows local memory center with source/freshness/use labels, privacy-safe groups, accessibility labels/values/hints, and explicit safe-vs-blocked controls. M08 adds reviewable narrative memory and conservative pattern signals sourced only from explicit local evidence, with sensitive-detail posture and safe-vs-blocked correction/delete/pause status. | Later maturity can deepen real edit/delete/pause/export/import flows after confirmation and undo boundaries exist. |
| Receipts | Receipt domain and You audit card exist; searchable receipt history and privacy-safe display rules are not implemented as a cross-surface product surface. | Receipt search/history batch. |
| Accessibility | Infrastructure and labels exist, but Dynamic Type/VoiceOver/Reduce Motion/target-size verification across screen/panel combinations is not complete. | Accessibility Nutrition verification. |
| External surfaces | Widgets, Live Activity, notifications, and App Intents exist; D22 adds a shared contract registry, privacy snapshot policy, safe stale/unavailable labels, command/receipt/confirmation requirements, and fallback-route rules. D23 aligns widget projection/rendering to those rules while keeping rendered gallery/device verification unclaimed; D24 aligns ActivityKit content state and widget rendering to safe privacy labels, bounded windows, stale/unavailable labels, fallback links, and concise accessibility summaries while keeping real-device/rendered lifecycle verification unclaimed; D25 aligns App Intents / Shortcuts to canon commands, safe routes, local capture receipt copy, and confirmation for Mark Done / Save the Day before mutation. M04 adds a code-backed verification checklist tying notifications, widgets, Live Activities, App Intents, Shortcuts, and the shared snapshot container back to D22 contracts and manual platform evidence requirements. R03 adds a release-readiness report that keeps these platform checks device-required. | Simulator/unit/source proof is current; real-device notification delivery, rendered widget gallery, ActivityKit lifecycle, Shortcuts/Siri invocation, and installed-device app-group I/O remain unclaimed until device proof exists. |

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
| `Habits` compatibility route remains internally | `AppTab.habits`, `PlanRouteTarget.habits`, and related service identifiers remain for saved-data/deep-link compatibility while user-facing copy presents Rituals. | Preserve compatibility-only internals; do not restore a top-level Habits tab. |
| `Insights` and `Profile` compatibility code remains | `AppTab.swift`, `AppNavigation.swift`, `Features/Insights`, `Features/Profile`. | Accept internal compatibility only; future alignment should avoid user-facing top-level Profile/Insights. |
| Capture wording uses `Needs a route` rather than `Needs a Place` | `CapturesScreen.groupedCaptures`. | UX writing/Capture alignment. |
| Widget foundation still carries historical families such as habit/insight/profile | `AppUI/Sources/WidgetFoundation.swift`. | External surface contract alignment; avoid active top-level meaning. |
| App Intents expose `Command`, `Memory Lens`, `Captures inbox` | `OpenAmbitionsDestinationIntent.swift`. | D25 aligns naming to Quiet Command Sheet, What Ambitions Knows, Capture, Start Next Step, Mark Done, Save the Day, and Open Plan. |
| Goal Detail lens keeps an internal compatibility case named `tasks` | `GoalsFeatureModels.swift` displays that lens as `Steps`. | Preserve compatibility-only internals while keeping user-facing contained actions as Steps. |

## 8. Surface-By-Surface Gap Matrix

| Surface | Implemented and valid | Constitution gap | Recommended batch |
| --- | --- | --- | --- |
| Today | Hero, Save the Day, support/deep dive, drift states. | Today Plan Layer, relevant One-Step Goals, full planned day, explicit open-window evidence. | Today 2.0 Design Constitution Alignment. |
| Goals | Direction hero, lifecycle rail, Goal Weather, archive, Atlas preview, Life Areas panel, North Stars rail, One-Step Goals panel, Map/List fallback, M05 qualitative path intelligence projection contract, M06 broad domain-pack/fork-comparison support, and M10 qualitative portfolio maturity signals. | Later maturity work can add full archive browsing, confirmed path editing, and performance evidence. | Portfolio/path maturity. |
| Goal Detail | Mission Control, breadcrumb, timeline, Proof Rail, decisions, risks, archive, receipts, exact `Overview / Path / Steps / Proof / Decisions / Risks / Archive` lanes, M05 source/freshness/proof/fallback path projection support, and M06 explainable fork-comparison support owned by Goal Detail prompts. | Later maturity can add Path Builder UI, review/search, and archive learning. | Portfolio/path maturity. |
| Capture | Fast input, routing actions, recent captures, attach to goal. | Needs a Place, Smart Attachment, editable Smart Attachment receipts, 1-3 clarification choices. | Capture + Quiet Command Sheet; Smart Attachment. |
| Plan | Believability, Plan Treaty, Rich Timeline Widget/source labels, Weekly Plan Strip naming, calendar boundary, recovery/reflow, Plan-owned permission proof, and Ritual support-loop language. | Later maturity work can deepen planning/recovery and cross-surface continuity. | Plan/recovery maturity. |
| You | Profile-backed You, D17 Personal System Center categories, D18 navigable Trust Center sections, D19 What Ambitions Knows memory center, privacy-safe trust receipt summaries, memory controls, reviews, appearance, integrations, and M02 service-level portable export/import proof. | Full user-facing export/import controls and deeper memory maturity remain future work. | Export/import UI, data safety, and memory maturity. |
| Life Areas Overview | Foundation Life Area object/projection layer, Goal Atlas preview hooks, and D13 Goals portfolio panel exist. | Dedicated detail/deeper transformation remains future maturity work. | Portfolio/path maturity. |
| North Star Detail | Foundation North Star object/projection layer and D13 Goals rail exist. | Full detail surface absent. | Portfolio/path maturity. |
| Task / One-Step Goal Detail | Model/projection foundation exists; D11 Today can surface compact standalone One-Step Goals, D12 can route/save from Capture, D13 can show controlled Goals portfolio items, and D14 keeps contained Goal Detail work as Steps without creating a Tasks tab. | Full standalone detail and broader Plan panel UI remain future surface work. | Plan alignment / maturity. |
| Review | Reviews v1 is You-owned. | Needs receipt/search/memory maturity and Constitution copy pass. | Reviews/receipt maturity. |
| Trust Center | Present as a You-owned card with D18 GroupedNavigationList sections for boundaries, receipts/corrections/explanations, privacy/future capability truth, and recent receipt summaries. | Later maturity can deepen receipt search/history and platform readiness evidence. | Receipt/search maturity; external-surface verification. |
| What Ambitions Knows | D19 named local memory center exists with source/freshness/use labels, privacy-safe groups, accessibility labels/values/hints, and safe-vs-blocked controls. | Full edit/delete/pause/recovery flows remain future-owned until confirmation and undo boundaries exist. | Memory maturity. |
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
| Weekly Plan Strip | D15 names and exposes the Plan week view as Weekly Plan Strip. | Future maturity can deepen interactions after Ritual split and UX writing. |
| Timeline Widget | D15 aligns the Rich Timeline with local source labels: `Based on your plan`, `Created in Ambitions`, and `From your calendar` where calendar-derived mode is active. | Future maturity can deepen long-range/path timeline behavior. |
| Goal Lifecycle Rail | Goals and Plan lifecycle rails exist. | Needs Life Areas/North Stars/semantic zoom integration. |
| Proof Rail | Goal Detail Proof Rail exists. | Needs proof/receipt/search maturity. |
| North Stars Rail | D13 adds a bounded Goals North Stars rail over the D08 projection. | Full North Star detail remains future maturity work. |
| Continuity Ribbon | External continuity model exists. | Named UI component not found. |
| Quiet Command Sheet | Shell sheet exists with quick-capture handoff, suggested route copy, and changeable receipt language. | Deeper clarification behavior remains later maturity work. |
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
| Trust Center | D18 Profile-backed Trust Center card has dedicated GroupedNavigationList sections, receipt summaries, and local-first/unavailable-state truth. | Later maturity can deepen receipt search/history and platform readiness evidence. |
| What Ambitions Knows | D19 named local memory center exists with source/freshness/use labels and safe-vs-blocked controls. | Full edit/delete/pause/recovery flows remain future-owned until confirmation and undo boundaries exist. |
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
| App Intents / Shortcuts | Open destination and Capture intents exist with D25 command descriptors, canon names, privacy language, safe routes, App Intent source routing, in-app confirmation posture for mutation-capable commands, M04 checklist evidence requirements, and R03 release-readiness gating. | Real Shortcuts/Siri/device verification remains unclaimed until physical-device proof exists. |
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
| D15 | Plan Believability + Timeline Widget Alignment | Completed alignment: Plan now asks `Does this hold together?`, validates a D10 Plan screen-contract snapshot, labels Rich Timeline and calendar evidence, names Weekly Plan Strip, and preserves Plan-owned calendar permission/write boundaries. |
| D16 | Ritual Split Alignment | Completed alignment: remaining user-facing standalone habit posture now presents as Rituals across Plan support loops, the Plan-owned Rituals route, Goal mode/clarification copy, and You defaults while preserving internal compatibility identifiers. |
| D17 | You Personal System Center Alignment | Completed: added categorized You structure and GroupedNavigationList map without a settings dump or new tabs. |
| D18 | Trust Center Alignment | Completed: Trust Center is navigable, privacy-safe, receipt-aware, and conservative about sync/export/account/accessibility/platform claims. |
| D19 | What Ambitions Knows | Completed: visible You-owned local memory center with source/freshness/use labels, privacy-safe memory grouping, accessibility labels/values/hints, and safe-vs-blocked controls without claiming cloud memory, sync, account systems, or destructive deletion. |
| D20 | UX Writing Cleanup | Completed: active visible copy, previews, screen contracts, command/receipt summaries, and focused guard tests now prefer Human Language Review/state-language terms while internal compatibility identifiers remain where needed. |
| D21 | Accessibility Nutrition Verification | Completed: internal screen/component evidence records now cover the active matrix with source/design/test/manual-proof anchors while public claims remain unverified. |
| D22 | External Surfaces Contract Alignment | Completed: shared external-surface contract registry, privacy snapshot defaults, safe fallback routes, and command/receipt/confirmation boundaries now exist with tests. |
| D23 | Widgets Alignment | Completed: widgets now render from a shared D22-backed projection with privacy summaries, stale/unavailable states, safe fallback routes, accessibility labels, and focused tests. |
| D24 | Live Activities Alignment | Completed: ActivityKit content state and rendering now carry privacy summaries, stale/unavailable labels, bounded end times, safe fallback routes, accessibility summaries, and focused tests. |
| D25 | App Intents / Shortcuts Alignment | Completed: shortcut command descriptors now cover Capture, Start Next Step, Mark Done, Save the Day, and Open Plan with privacy language, safe routes, receipt posture, and confirmation for mutation-capable commands. |
| D26 | Release Candidate Validation | Completed: validated aligned surfaces, claims posture, simulator build/test evidence, and docs/status truth before M01; final RC lock, App Store readiness, real-device QA, public accessibility claims, and platform-surface verification remain future R/M gates. |

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
17. You Personal System Center Alignment. Completed.
18. Trust Center Alignment. Completed.
19. What Ambitions Knows. Completed.
20. UX Writing Cleanup. Completed.
21. Accessibility Nutrition Verification. Completed.
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
