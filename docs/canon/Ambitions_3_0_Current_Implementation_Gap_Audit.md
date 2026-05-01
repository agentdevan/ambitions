# Ambitions 3.0 — Current Implementation Gap Audit

Status: F00 completed audit baseline; F01-F03 Today foundation/detail work implemented
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)
Implementation plan: [Ambitions 3.0 Front-End Implementation Batch Plan](./Ambitions_3_0_Front_End_Implementation_Batch_Plan.md)
Last updated: 2026-04-30

---

## Executive Verdict

F00 is an audit-only batch. It did not implement app features, fix UI tests,
rename identifiers, change workflows, add dependencies, or claim FAANG handoff
readiness.

Current implementation is **PARTIAL** against Ambitions 3.0.

The repo has a strong native SwiftUI foundation, green local build, green unit
tests, implemented canonical top-level shell labels, meaningful domain models,
and several mature D/M/R-era foundations for Capture, Plan, You, receipts,
reviews, external surfaces, accessibility locks, and release evidence. The gap
is that Ambitions 3.0's signature front-end primitives are not yet fully
implemented as user-facing 3.0 surfaces. Today now renders an
`AmbitionsDayRailView` and F03 adds a Today-local Step Detail sheet from the
Reality Rail, but Step Session remains a legacy focus/routing seam; Action
Closure and Proof/Receipt
logic are strong in domain/tests but not yet a shared user-facing closure sheet
and receipt trail; Capture has Smart Attachment/Needs a Place foundations but
not the full Placement Resolver flow; Plan, Goals, and You are substantial but
still carry old internal seams and need F-series modernization.

FAANG handoff remains **PARTIAL** until at least these blockers are resolved:

- full UI smoke suite passes or every failure is modernized with canon-backed
  expectations
- legacy user-facing copy debt is eliminated from active surfaces/external
  surfaces
- legacy internal identifier debt is migrated or explicitly compatibility
  isolated
- Ambitions 3.0 Step Session, Action Closure, and Receipt/Proof surfaces have
  implementation, previews, tests, and honest evidence beyond the F01-F03 Today
  Reality Rail and Step Detail work
- release, accessibility, device, TestFlight, and App Store claims remain gated
  by the existing evidence rules

F04 should continue with **Step Session rename/migration and routing**, not with
broad shell replacement, global identifier migration, or release readiness
claims.

## Current Build/Test Status

Preflight:

- `git status --short`: clean before F00 run-state update
- `git branch --show-current`: `main`
- `git rev-parse HEAD`: `5282b23bd6ad62ad3b4870fe0694f492d5285250`
- `git log -1 --oneline`: `5282b23b Index Ambitions FAANG team operating system`

Task width gate:

- Task size: L
- Type: audit/docs-only
- Implementation: prohibited
- App code changes: prohibited
- Workflow changes: prohibited
- Runtime dependency changes: prohibited
- Primary allowed docs: this audit, F00 report, `BATCH_REGISTRY`,
  `CONTEXT_INDEX`, `.codex/reports/current-run-state.md`

Baseline validation on 2026-04-30:

| Command | Status | Evidence |
| --- | --- | --- |
| `scripts/validate-dev-tools.sh \|\| true` | PASS | Found Xcode 26.3, XcodeGen 2.45.4, ripgrep 15.1.0, git 2.53.0, gh 2.92.0, jq 1.8.1, xcbeautify 3.2.1, markdownlint-cli2 0.22.1, lychee 0.24.1. |
| `scripts/run-doc-qa.sh \|\| true` | PARTIAL/advisory | Stale guidance hits are historical/supporting; markdownlint reports 8,980 broad pre-existing style errors; lychee reports 571 total / 566 OK / 5 older local-link failures. Latest logs under `docs/audits/doc-qa/20260430-164517-*`. |
| `scripts/build-local.sh \|\| true` | PASS | `xcodegen generate`; build succeeded on `platform=iOS Simulator,name=iPhone 17`; latest log `output/logs/build-local-20260430-164517.log`. |
| `scripts/test-local.sh \|\| true` | PARTIAL | `AmbitionsTests` passed 744 tests. `AmbitionsUITests` ran 29 tests with 9 failures. Log `output/logs/test-local-20260430-160618.log`; xcresult at `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.04.30_16-06-21--0400.xcresult`. |

## Legacy Language Scan Classification

Command:

```bash
rg -n --hidden --glob '!/.git/**' \
  'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' \
  . || true
```

Result: 858 hits.

Classification:

| Class | Count | Evidence examples | F00 classification |
| --- | ---: | --- | --- |
| Allowed migration/copy-guard references | ~120 | `docs/canon/Ambitions_3_0_Content_QA_And_Copy_Guard.md`, `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`, `.codex/validation/copy-qa-pack.md` | Allowed; these docs define forbidden terms and replacements. |
| Archived/historical/supporting references | ~430 | 2.0/v2 docs, old batch prompts, `MASTER_PRODUCT_SPEC.md`, prior audit scan files | Allowed as history unless reused as active prompt truth. |
| Compatibility test/reference | ~80 | tests for no `AI confidence`, `Profile` tab absence, safe failure states | Allowed where the test protects migration or copy guard. |
| Active doc debt | ~40 | old canon/supporting docs that still contain deprecated wording outside explicit guard context | Cleanup batch recommended, but not F00. |
| User-facing UI debt | 3+ confirmed | `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift:76`, `:89` use `.overdue`; `Native/Ambitions/UI/LaunchGateView.swift:45` says `Launch failed`; Capture failure title at `Native/Ambitions/Features/Captures/CapturesViewModel.swift:279` | F15/F16 copy and external-surface cleanup. |
| Accessibility label debt | Low but real | `Sources/Accessibility/AccessibilityNutrition.swift:61`, `:69` discuss failed/missed states as audit language | Mostly allowed checklist language; verify future labels do not leak shame copy. |
| App Intent / widget / external-surface debt | Confirmed | Live Activity and snapshot state use `overdue`, external `focus` variant copy | F15, after F01-F06 clarify new Step Session naming. |
| Internal code identifier debt | High | `startFocus`, `bestNextMove`, `activeFocus`, `Profile`, `Insights`, `Habits`, `capturesInbox` | Do not rename in F00; migrate in F15 after compatibility plan. |
| False positives | Many | `failed` as engineering/test status; `missed` in recovery research; `productivity score` in forbidden-copy lists | Keep as guard/history. |

Recommended cleanup batch: F15 for internal identifiers and active external
copy, with F16 for UI test expectation modernization. Do not start this before
F01-F06 establish the replacement Reality Rail / Step / Closure contracts.

## Internal Identifier Migration Classification

Command:

```bash
rg -n --hidden --glob '!/.git/**' \
  'startFocus|TodayFocus|activeFocus|bestNextMove|capturesInbox|Insights|Profile|Habits' \
  Native Sources AppUI docs .github project.yml || true
```

Result: 3,443 hits.

Classification:

| Class | Evidence | Classification |
| --- | --- | --- |
| Safe temporary compatibility seam | `Native/Ambitions/App/AppTab.swift:7-13`, `:18-28`, `:35-44`; `Native/Ambitions/App/AppNavigation.swift:83-89`, `:150-169` | Keep until migration plan. Legacy raw values normalize to canonical destinations. |
| Must rename in F01-F06 | `Native/Ambitions/Features/Today/TodayFeatureModels.swift:49-50`; `Native/Ambitions/Domain/AmbitionsCommandModels.swift:13`; `Native/Ambitions/Features/Today/TodayExecutionViewState.swift:25`, `:163`, `:1099` | Replace Today action/session names after F01-F04 define Day Rail and Step Session models. |
| Must rename in F15 legacy migration | `Native/Ambitions/Domain/ProfileModels.swift`; `Native/Ambitions/Features/Profile/*`; `Native/Ambitions/Features/Insights/*`; `Native/Ambitions/Features/Habits/*`; AppUI `ProfileSummary*`/`FocusNow*` widgets | Wide migration; requires compatibility map and focused regression. |
| Persisted/deep-link compatibility risk | `AppTab` raw values, `PlanRouteTarget.capturesInbox`, `InsightsRouteTarget`, share extension `.capturesInbox`, external snapshots `activeFocus` | Must not be renamed casually; use adapters/deprecated aliases. |
| User-facing leak | `Native/AmbitionsShareExtension/ShareIntakeView.swift:47` says `Review in Captures`; widget `FocusNow*` family names can leak if surfaced | F15 external surface/copy pass. |
| Test expectation debt | `Native/AmbitionsUITests/AmbitionsUITests.swift:142`, `:158`, `:171`, `:325`, `:334`, `:343`; many `ProfileFeatureServiceTests` names | F16 modernizes names after product migration. |
| Docs-only migration reference | `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md:127-133`; migration plans and review checklists | Allowed. |
| False positive / generated artifact | `docs/audits/all-local-files.txt`, old generated DerivedData listings | Ignore or clean generated audit inventories later if desired. |

Recommended migration batch: F15, after F01-F14 establish the new target names
and after compatibility/deep-link risks are isolated.

## UI Test Failure Map

Latest full UI result: 29 UI tests run, 9 failed.

| Test | Line | Surface | Failure | Classification | Likely owner |
| --- | ---: | --- | --- | --- | --- |
| `testDemoPlanPressureScrubberUpdatesSelectedDayAndActionLane` | `Native/AmbitionsUITests/AmbitionsUITests.swift:570` | Plan | `XCTAssertTrue failed`; log shows repeated search for plan elements | outdated test expectation / accessibility identifier drift | F16; may also need F10-F12 Plan proof |
| `testForcedOnboardingCaptureFirstPathOpensQuickCapture` | `:59` | Onboarding / Capture | expected `No hidden analytics` before quick capture field | outdated onboarding copy expectation / fixture drift | F16; no F00 product fix |
| `testGoalDetailTrustAndMemoryDisclosureStayBelowStrategicLayer` | `:509` | Goal Detail / You trust disclosure | expected trust/memory disclosure below strategic layer | real implementation gap or outdated deep-scroll expectation | F13/F14 then F16 |
| `testPreviewBootstrapCanCreateGoalFromEmptyState` | `:88` | Goals create flow | expected `goals.creation-message` | likely async/fixture drift or create-flow UI expectation | F16 after F13 |
| `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry` | `:444` | Today reentry | expected focus/recovery reentry state | outdated test expectation plus real Step Session gap | F01-F04, F16 |
| `testShellOwnedCreateGoalFlowWorksFromCommandSheet` | `:277` | Shell command / goal composer | expected compose outcome | navigation or fixture drift | F16; possible shell routing check |
| `testTodayCanHandOffToGoalDetail` | `:489` | Today to Goal Detail | expected Today goal detail button | real implementation gap or identifier drift | F03/F13, F16 |
| `testTodayCanHandOffToPlan` | `:533` | Today to Plan | expected `today.action.openPlan.none` / `Open Plan`; failed after repeated scroll attempts | real implementation gap or outdated selector | F01-F02, F16 |
| `testTodayStartFocusCanOpenBoundedFocusScreenlet` | `:480` | Today focus/Step Session | expected bounded focus screenlet after `Start now` | real implementation gap and legacy naming | F04, F16 |

Do not delete, quarantine, or fix these tests in F00. They are the main live
evidence that handoff remains PARTIAL.

## Surface-by-Surface Implementation Audit

| Surface | Canon requirement | Current implementation evidence | Tests/previews | Status | Risk | Handoff impact | Next batch |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Today / Reality Rail / Day Rail | Day Rail is the Today signature object; `Start here`; Now/Next/Later rows; row tap to Step Detail; `Start now` to Step Session. | `TodayScreen.swift` renders `AmbitionsDayRailView` first in loaded Today, with `Start here`, `Start now`, Now/Next/Later rows, source/context/duration labels, and reserved closure/proof slots. `TodayFeatureModels.swift:49-50` still has `.startFocus`. | `TodayViewModelTests` passed; focused Today shell/fresh-goal tests passed; full UI smoke still known failing. | partial / legacy naming | Step Session remains F04; full UI smoke still needs modernization. | P0 blocker. | F04/F16 |
| Step Detail | Row tap opens lightweight inspection surface with why/readiness/duration/source/adjust controls. | F03 added `DayRailStepDetailState`, `TodayStepDetailSheet`, and Reality Rail hero/row taps that open Today-local detail with duration/source/context labels, recommendation bullets, and privacy-safe redaction. | Focused `TodayViewModelTests` prove detail state, copy, private redaction, reserved `Start now`, and closure/proof reservation. | implemented / Today-local | UI smoke still needs focused modernization; Step Session remains separate. | Reduced but not handoff-ready. | F16 follow-up as needed |
| Step Session | Step-first execution drill-down, not timer-first or focus-first; supports Complete, Still Counts, Pause, Adjust. | Focus screenlet exists: `TodayFeatureModels.swift:397`, `TodayPanels.swift:1577`; route still `.startFocus` and `TodayEntryContext.focus`. | `testTodayStartFocusCanOpenBoundedFocusScreenlet` failed at `:480`; unit focus tests pass. | partial / legacy naming | Execution remains bounded focus screenlet, not 3.0 Step Session. | P0 blocker. | F04 |
| Action Closure | Shared closure sheet with Completed, Still Counts, Rescheduled, Not needed, Blocked, Waiting, Needs Recovery, Needs Review. | Domain receipt grammar exists: `ActionClosureReceiptModels.swift:5-21`, `:110-128`, `:184-191`; no shared UI sheet verified. | `ActionClosureReceiptModelsTests` passed 15 tests. | partial | Closure is not yet a shared user-facing surface. | P0 blocker. | F05 |
| Proof / Receipts / Reviews | Proof/receipt ledger must show toast, peek, trail/search/export levels; Reviews summarize evidence. | Receipt domain and projection exist; Reviews projection in `ReviewsV1Projector.swift`; You renders review/receipt sections in `ProfileScreen.swift:1033-1149`. | Receipt and Profile/Reviews tests pass; no shared receipt UI smoke proof. | partial | User may not recover what changed outside You detail sheets. | P1 blocker. | F06 |
| Capture / Placement Resolver | Composer-first `What needs a place?`; Suggested Place / Needs Decision / Needs a Place / Saved as object; placement receipt. | `CapturesScreen.swift:101`, `:442-453`, `:502-574`; Smart Attachment models at `SmartAttachmentModels.swift:90-146`; service at `SmartAttachmentService.swift:13-162`; ViewModel preview/receipt at `CapturesViewModel.swift:13-34`, `:316-377`. | Capture/SmartAttachment tests pass; UI quick capture passes, onboarding capture path fails at `:59`. | partial | Foundation exists, full Placement Resolver UX missing. | P1. | F07-F09 |
| Plan Life Suite | Day/Week/Month/Life planning suite, not calendar clone; no silent calendar writes. | `PlanFeatureModels.swift` has week pressure, calendar, recovery, lifecycle rail; `PlanFeatureServiceTests.swift:187-198`, `:352-365`, `:370-395`, `:412-435` prove denied/manual/suggestion-only behavior. | 25 Plan unit tests pass; Plan UI smoke failure at `:570`. | partial / outdated test | Strong service foundation; user-facing suite still panel-heavy and UI test unstable. | P1. | F10-F12 |
| Goals / Goal Mission Control | Portfolio home and Goal Detail lane-based Mission Control: overview/path/steps/proof/decisions/risks/archive. | Goals/Goal Detail files exist; UI tests expect decisions/risks/archive/path/tactics; Goal Detail trust disclosure UI failure at `:509`. | Goals unit tests pass; Goal Detail UI smoke partly passes, one trust disclosure failure. | partial | Goal Detail has many lanes but 3.0 mission-control proof is incomplete. | P1. | F13 |
| You / Trust / Memory | You as control center; What Ambitions Knows with source/freshness/safe controls; local-first trust. | User-facing root exists at `ProfileScreen.swift:184-231`; detail names include `What Ambitions Knows` and `Trust Center` at `:158-165`; memory source/freshness rows at `:760-845`, `:851-1002`; models at `ProfileModels.swift:161-242`. | Profile service tests pass 16 tests; You UI smoke tests pass. | implemented user-facing / legacy internal naming | Internal `Profile` seam remains migration debt. | P2/P1 for migration. | F14-F15 |
| Ambitions Operating Shell / Meridian | Preserve Today/Goals/Capture/Plan/You; Meridian waits or is feature-flagged. | `AppTab.swift:3-13`, `:35-44` preserves canonical visible labels with compatibility raw values. `AppShellView.swift:51-63` continuity messages. | Shell UI test passes canonical five tabs. | implemented shell baseline / Meridian missing | Do not replace shell before content loop stabilizes. | F17 only after F01-F16. | F17 |
| App Intents / Widgets / External Surfaces | Privacy-safe projection; no unsupported platform readiness; no legacy copy leaks. | `project.yml:43-71`, App Intent files, external snapshots; `ExternalSurfaceSnapshotBuilder.swift:65-66`, `:150-156` still use `bestNextStep`/`activeFocus`/Focus copy. Widget Live Activity has `.overdue`. | External unit tests pass; no rendered widget/device proof. | partial / external debt | Platform claims remain blocked; copy/identifier debt. | F15 plus release gates. | F15/R gates |
| Product language / copy | No AI theater, fake scores, shame copy, or legacy tab names in visible UI. | Copy guard exists; visible app mostly uses `Start now`, `What needs a place?`, `You`; active debt in external/capture failure states. | Copy tests pass; scans show 858 hits. | partial | Debt can leak through external surfaces and tests. | P1. | F15 |
| Accessibility | Dynamic Type/VoiceOver/Reduce Motion evidence; no public claim without manual proof. | `AccessibilityNutrition.swift`; `AccessibilityClaimsLock`; You copy says claims locked. | 10 accessibility checklist tests pass; no manual proof. | partial | Source evidence only, no public/accessibility readiness claim. | P1 release gate. | F16/R gates |
| Privacy / Trust projection | Local-first, confirmation-gated, no silent calendar changes. | Plan, You, receipts, external snapshot tests pass; `ProfileFeatureServiceTests` assert no sync/accessibility overclaims. | Unit evidence strong. | implemented foundation / manual proof missing | Release claims still gated. | P1 release gate. | F14/R gates |
| Tests / previews / fixtures | Tests protect user promises and must modernize after canon changes. | 744 unit tests pass; 9 UI tests fail; previews exist for Today/Capture/Plan/Goals/You. | `scripts/test-local.sh` PARTIAL. | partial / blocked | Main handoff blocker. | P0 blocker. | F16 |

## Primitive-by-Primitive Implementation Audit

| Primitive | Owner doc | Current code owner path | Status | Tests/previews | Major gap | Next batch | Risk if ignored |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1. Reality Rail | `Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md` | `Native/Ambitions/Features/Today` | partial | Today unit tests pass; Today UI failures | No proven `AmbitionsDayRailView` signature object | F01-F02 | Ambitions lacks its core first-screen identity. |
| 2. Action Closure Engine | `Ambitions_3_0_Action_Closure_Sheet_Spec.md` | `Native/Ambitions/Domain/ActionClosureReceiptModels.swift` | partial | Domain tests pass | Shared closure sheet missing | F05 | Closure stays fragmented. |
| 3. Proof & Receipt Ledger | `Ambitions_3_0_Proof_Receipts_And_Reviews_Contract.md` | `ActionClosureReceiptModels`, `ReviewsV1Projector`, `ProfileScreen` | partial | Receipt/Profile tests pass | Receipt peek/trail/search UI not fully proven | F06 | Trust is hard to inspect. |
| 4. Capture → Placement Resolver | `Ambitions_3_0_Placement_Resolver_Spec.md` | `CapturesScreen`, `CapturesViewModel`, `SmartAttachmentService` | partial | Capture/unit tests pass | Full placement decision flow missing | F07-F09 | Capture becomes inbox-like. |
| 5. Step Execution System | `Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md` | Today focus screenlet/action routing | partial/missing | UI focus test fails | Step Detail/Session not first-class | F03-F04 | Product remains planning-heavy. |
| 6. Plan Life Suite | `Ambitions_3_0_Plan_Life_Suite_Endgame.md` | `Native/Ambitions/Features/Plan` | partial | Plan unit tests pass; Plan UI failure | Day/Week/Life suite needs 3.0 surface consolidation | F10-F12 | Plan reads as stacked panels. |
| 7. Trust & Memory Control Plane | `Ambitions_3_0_Personalization_Consent_Model.md` | `Native/Ambitions/Features/Profile`, `ProfileModels` | implemented foundation / legacy naming | Profile tests pass | Internal Profile naming and broad controls pending | F14-F15 | Trust work stays hard to maintain. |
| 8. Goal Mission Control | `Ambitions_3_0_Primitive_Architecture.md` | `Native/Ambitions/Features/Goals` | partial | Goals tests pass; one Goal Detail UI failure | 3.0 Mission Control proof incomplete | F13 | Goals can feel like board/list. |
| 9. Recommendation Ledger | `Ambitions_3_0_Recommendation_Contract.md` | `RecommendationExplanationModels`, Today/Goal services | partial | Recommendation tests pass | Legacy `bestNextMove` identifiers and user route gaps | F03/F15 | Explainability drifts into old naming. |
| 10. First Useful Object Onboarding | `Ambitions_3_0_First_60_Seconds_Spec.md` | `ProgressiveIntelligenceOnboarding`, UI tests | partial | one onboarding UI failure | Capture-first expectation drift | F16 | First-run smoke remains unreliable. |
| 11. Review OS | `Ambitions_3_0_Proof_Receipts_And_Reviews_Contract.md` | `ReviewsV1Projector`, You/Profile | partial/implemented foundation | Reviews/Profile tests pass | You-owned reviews exist; 3.0 Review OS surface not standalone proof | F14/F16 | Review truth hard to validate visually. |
| 12. Accessibility / ADHD Control Layer | `Ambitions_3_0_Accessibility_Conformance_Plan.md` | `Sources/Accessibility`, tests, design tokens | partial | checklist tests pass | Manual/rendered proof missing | F16/R gates | Cannot claim accessibility readiness. |
| 13. Rail / Node Visual Grammar | `Ambitions_3_0_Signature_Objects_And_Rail_Grammar.md` | `Sources/Components`, Today panels | partial | design-system tests pass | Day Rail visual grammar not integrated | F02 | UI stays generic/panel-heavy. |
| 14. Ambitions Operating Shell | `Ambitions_3_0_Ambitions_Operating_Shell.md` | `AppShellView`, `AppTab`, navigation | implemented baseline / Meridian missing | shell UI tests pass | Meridian custom shell not implemented and should wait | F17 | Premature shell redesign risks nav loss. |
| 15. External Surface Projection | external surface docs/D22-D25 | `ExternalSnapshots`, widget/share/App Intents | partial | external tests pass | rendered/device proof and copy debt | F15/R gates | Platform/release claims blocked. |
| 16. Release / Market Proof System | release gates docs | release reports/support files | partial evidence system | R tests pass | human/device/accessibility/signed archive proof missing | R/human gates | No release/App Store readiness claim. |

## Tests/Previews/Fixtures Gap Map

- Unit tests: currently strong; latest `AmbitionsTests` passed 744 tests.
- UI tests: current main blocker; 9 of 29 fail in the latest full run.
- Previews: Today/Capture/Plan/Goals/You preview support exists, but F01-F06
  must add/update deterministic previews for Day Rail, Step Detail, Step
  Session, Action Closure, and Receipt Peek.
- Fixtures: many D/M/R-era fixture names still encode older batch/user flows.
  F16 should modernize UI test metadata and fixture naming after F01-F15.
- Do not delete tests. Classify, modernize, or replace only with owner-doc
  evidence.

## Accessibility/Privacy/Trust Gap Map

- Accessibility source/test evidence exists, but manual VoiceOver, Dynamic
  Type, Reduce Motion, contrast, motor/tap-target, real-device, and external
  rendered proof are not verified.
- Privacy/trust foundations are relatively strong: local-only sync capability,
  no silent calendar writes, confirmation-gated broad mutation, privacy-safe
  external snapshots, and You-owned memory controls all have unit evidence.
- Public accessibility, TestFlight, App Store, device, and release readiness
  claims remain blocked.
- F01-F06 must keep all new step/closure/proof copy non-shaming, privacy-safe,
  and accessible without color-only meaning or gesture-only navigation.

## FAANG Handoff Blockers

1. Full UI smoke suite fails 9 tests.
2. Step Session is still represented by legacy focus naming/screenlet seams.
3. Shared Action Closure Sheet is missing.
4. Receipt/proof trail is not yet visible enough beyond domain/You surfaces.
5. Capture Placement Resolver flow is partial.
6. Plan/Goals/You have strong foundations but not full 3.0 surface proof.
7. Legacy internal identifiers remain widespread.
8. External-surface copy/identifier debt remains.
9. Accessibility/device/platform/release gates remain unverified by human or
    device evidence.

## Next Build Sequence From F00 Evidence

| Batch | Width | Purpose | Primitive | Likely files | Forbidden files | Tests likely touched | Validation | Dependencies | Risk | Acceptance | Stop conditions |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F01 — Reality Rail / Day Rail foundation | M | Add model/view-state foundation for Day Rail without visual rewrite. | Reality Rail | Today models/services/tests, preview fixtures | `.github/workflows/**`, dependencies, broad shell rewrite | Today unit tests, new Day Rail model tests | `xcodegen generate`; focused Today tests; build | F00 | model churn | DayRail state includes now/next/later, duration/source, closure/proof slots | requires UI rewrite or identifier migration |
| F02 — Reality Rail visual states and copy guard | M/L | Make Day Rail visible and copy-safe. | Reality Rail / Rail grammar | Today screen/panels/new Day Rail view/previews | Step Session full implementation, shell Meridian | Today UI smoke, copy guard | build; focused Today UI; doc QA | F01 | visual regressions | Day Rail owns first viewport; old hero hidden/gated | tab shell risk |
| F03 — Step Detail and recommendation explanation | M | Add row-tap Step Detail. | Step Execution / Recommendation Ledger | Today routing, Goal/Step detail seam, explanation models | Step Session, Action Closure | Today/Goal Detail tests | focused unit/UI | F01-F02 | route ambiguity | row tap opens detail; `Start now` remains separate | needs persistence migration |
| F04 — Step Session rename/migration and routing | M/L | Replace focus-first execution with Step Session. | Step Execution | Today action enums/routes/session view/tests | global Profile/Insights rename | Today tests, UI focus test | focused Today tests; build | F03 | compatibility naming | visible copy says Step Session/Start now, no `Start Focus` | breaking deep links/intents |
| F05 — Action Closure / Still Counts | M/L | Shared closure sheet and outcome model wiring. | Action Closure | Action receipt models if needed, shared UI, Today/Goal/Plan hooks | broad receipt history/export | closure tests, Today/Goal focused | focused closure tests; build | F04 | duplicate closure grammar | Still Counts and recovery outcomes create receipts | silent mutation |
| F06 — Proof & Receipt Ledger | M | Receipt peek/trail tied to proof. | Proof & Receipt Ledger | receipt UI, You/Trust hooks, Today rail proof slot | export/import redesign | receipt/profile tests | focused tests; build | F05 | trust overclaim | toast/peek/trail distinctions visible | release/accessibility claim temptation |
| F07 — Capture Composer cleanup | M | Calm composer and route preview cleanup. | Capture | Captures screen/viewmodel/tests | Placement backend rewrite | Capture tests/UI | focused Capture tests | F06 optional | inbox drift | composer remains dominant and copy-safe | new dependency |
| F08 — Placement Resolver | M/L | Suggested Place/Needs Decision/Needs a Place flow. | Placement Resolver | SmartAttachment/Capture UI/tests | goal engine rewrite | SmartAttachment/Capture tests | focused tests; build | F07 | fake precision | route suggestions are correctable and local | unsafe auto-place |
| F09 — Capture-to-Goal / Grow into Goal | M | Promote capture into goal safely. | Placement Resolver / Goal Mission | Capture, Goals create seam | persistence migration without plan | Capture/Goals tests | focused tests; build | F08 | data linkage | grow into goal creates receipt and route | destructive conversion |
| F10 — Plan Life Suite foundation | M | Model Day/Week/Life scopes. | Plan Life Suite | Plan models/service/tests | calendar write expansion | Plan tests | focused Plan tests | F01-F09 | scope creep | scope separation represented | calendar clone |
| F11 — Day Shape / Week Shape | M/L | Render shape views and update tests. | Plan Life Suite | Plan screen/previews/UI tests | Meridian shell | Plan UI/tests | focused UI/build | F10 | dense UI | day/week shape visible and scan-friendly | hidden gesture-only nav |
| F12 — Reflow / Recovery / Decisions | M | Modernize recovery decision surfaces. | Plan Life Suite / Action Closure | Plan recovery, receipts | automatic rescheduling | Plan/recovery tests | focused tests | F10-F11 | silent automation | suggestions only, receipts visible | calendar mutation |
| F13 — Goals / Goal Mission Control | L | Align Goals/Goal Detail to mission-control lanes. | Goal Mission Control | Goals screen/detail/service/tests | new top-level Path/Tasks tab | Goals UI/unit | focused tests/build | F03/F06 | project-board drift | lanes visible with next step/reason | scope becomes full redesign |
| F14 — You / Trust / What Ambitions Knows | M | Finish 3.0 You trust controls. | Trust & Memory | Profile/You screen/service/tests | internal rename sweep | Profile tests/UI | focused tests/build | F06/F13 | generic settings drift | You remains control center with source/freshness | destructive memory controls |
| F15 — Legacy identifier migration | L | Rename/compat-isolate legacy identifiers. | Cross-cutting | Today/Profile/Insights/Habits/AppTab/external | `.github/workflows/**`, dependencies | broad unit/UI | full build/test | F01-F14 | deep-link/persisted risk | compatibility adapters, no visible leak | unknown migration risk |
| F16 — UI test modernization | L | Modernize UI tests to 3.0 contracts. | QA | `Native/AmbitionsUITests`, fixtures, docs | app feature implementation | UI suite | focused then full UI | F01-F15 | deleting real coverage | failures classified and resolved | product bug found |
| F17 — Ambitions Operating Shell / Meridian feature-flagged | L | Introduce Meridian safely after content loop. | Shell | AppShell/UI/tests | replacing tab access without fallback | shell UI tests | full build/UI | F16 | navigation loss | feature-flag/fallback, five tabs reachable | usability uncertainty |

## Recommended Next Codex Prompt: F04 Step Session

````markdown
You are Codex 5.5 on Mac acting as the Ambitions FAANG-level product engineering organization.

Run F04 — Step Session rename/migration and routing.

This is a Today-only implementation batch focused on replacing focus-first
execution naming/routing with Step Session behavior after F03 Step Detail.

Do not rewrite the whole Today UI.
Do not implement Action Closure Sheet yet.
Do not implement Proof / Receipt Ledger yet.
Do not implement Plan Life Suite.
Do not change shell architecture.
Do not rename global Profile/Insights/Habits identifiers.
Do not touch `.github/workflows/`.
Do not add dependencies.
Do not claim FAANG handoff readiness.

Primary goal:

- Make `Start now` launch a bounded Today Step Session rather than legacy
  focus-first behavior.
- Preserve F03 Step Detail as the inspection/explanation surface.
- Keep Action Closure, Still Counts, Proof, and Receipt behavior reserved for
  F05-F06 unless a compile-safe placeholder is already present.
- Remove visible `Start Focus` / `Focus Session` copy from active Today paths
  touched by F04, while compatibility-isolating internal identifiers if a full
  migration would exceed the task width.

Expected task width:

- Size: M/L
- Type: Today execution routing implementation
- Primitive: Step Execution
- Surface: Today
- App code changes: Today model/routing/UI/test/preview seams only
- Workflow/dependency changes: prohibited
- Release readiness claims: prohibited

Read the standard Ambitions 3.0 source-truth docs, the Day Rail build spec,
F03 report, `docs/codex/BATCH_REGISTRY.md`, `docs/codex/CONTEXT_INDEX.md`,
and the Today implementation files under `Native/Ambitions/Features/Today`.

Validation should include focused Today tests, touched-path copy guard,
`scripts/build-local.sh`, and `git diff --check`.

Do not claim FAANG handoff readiness. It remains PARTIAL until F01-F16 evidence
and the full UI smoke gate pass.
````

## Batch Train Architecture Hardening Update

F03.5 is now inserted before F04 because `TodayExecutionViewState.swift` exceeds the 1000-line architecture threshold after F01-F03. F13.5 and F16.5 are conditional checkpoint batches for Goals/You/Trust and whole-app SwiftUI state-contract risk. These batches preserve behavior and do not mark new product features implemented.
