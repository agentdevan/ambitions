# Ambitions Product Experience Pack Repo Traceability Map

Status: Batch 1A/1B/1C/1D docs/planning artifact; no app implementation started
Date: 2026-05-04

## Purpose

This map connects the completed Product Experience Pack source truth to current
repo files discovered during Batch 0 reconnaissance. It is a planning and
handoff artifact only. It does not start Product Depth, resume the global train,
change app behavior, finalize candidate items, or claim implementation
readiness.

## Source Truth Used

- User-provided Product Experience Pack lock for Batch 1A.
- Batch 0 repo reconnaissance evidence.
- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- Current native SwiftUI files under `Native/Ambitions/`, `Sources/`, and
  `AppUI/Sources/`.

## Batch 1B Reconciliation Addendum

Batch 1B hardens three source-truth risk areas without editing app code,
navigation, design tokens, persistence, runtime, CI, tests, previews, or
fixtures.

### Accent Taxonomy / Default

Severity: Yellow.

Classification: naming/token migration conflict with product implications. The
Pack locks Appearance Studio under You, Gold as the default accent, launch
accents as Gold, Platinum, Rose, Cyan, Violet, emphasis-only accent behavior,
and no semantic-state recoloring. Current repo evidence shows
`AmbitionAccentFamily` cases `sage`, `blueGray`, `mutedGold`, `copper`, and
`sand`, with defaults resolving to `.sage` in theme, persistence, and You
editor state.

Affected files:

- `Sources/Theme/AmbitionTheme.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileViewModel.swift`
- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/Services/AppServices.swift`

Future treatment options:

- A. Rename/map existing accent tokens to the Pack taxonomy.
- B. Introduce compatibility mapping while preserving old internal values.
- C. Create a docs-only alias plan first.
- D. Stop for design-token implementation approval.

Recommendation: choose option C before implementation. Theme, persistence
defaults, and Appearance Studio files are approval-gated for edits because a
token/default change can affect saved preferences and shared UI semantics.

### MissionControlTimeSpine Order

Severity: Yellow.

Classification: partial alignment with unresolved order conflict. Mission
Control lane primitives exist, but current lane evidence is closer to Path,
Proof, Risks, Proof/Blockers/Next Step/Momentum, and related detail surfaces
than to the locked Pack order: Completed, Now, Friction, Next, Horizon.

Affected files:

- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Sources/Components/ShellChromePrimitives.swift`
- `docs/canon/PXOS_Goals_Mission_Control_Canon.md`
- `docs/audits/si07-mission-control-lane-components-report.md`

Future reconciliation model:

- Completed may be backed by proof/evidence, but proof itself remains evidence
  semantics rather than achievement language.
- Friction may include blockers, source review, assumptions, or recovery
  boundaries.
- Now and Next must remain distinct.
- Horizon must not become a roadmap, Gantt, or calendar clone.
- Evidence Ledger / Proof Spine should be preserved by meaning, not forced into
  chronology.

Recommendation: keep Goals/Mission Control source files approval-gated. The
best owner for formal mapping is Product Depth PD01 if the train is explicitly
started; until then, keep this as docs-only reconciliation evidence rather than
a primitive implementation batch.

### User-Facing Copy Boundary

Severity: Yellow.

Classification: internal compatibility vocabulary is allowed to remain when it
is not user-facing and preserves migration/history, but any user-facing surface
must obey Product Experience Pack copy rules.

Observed compatibility areas:

- `Native/Ambitions/App/AppTab.swift` preserves compatibility cases for older
  routes while active tabs remain Today, Goals, Capture, Plan, You.
- `Native/Ambitions/Features/Habits/**`, `Native/Ambitions/Features/Insights/**`,
  and `Native/Ambitions/Features/Profile/**` include legacy owner names that may
  be internal or route/history seams.
- Async/result states and domain scoring-style fields can include technical
  vocabulary that must not become Pack-facing copy without review.

Safe rule: internal cases, identifiers, file names, raw values, and migration
terms may remain if they are not exposed as user-facing copy and if
compatibility or history requires them. User-facing text must prefer Pack
language: Time, capacity, and defaults; Redaction rules / Preview safety /
Private details; Source may be stale; proof as evidence; receipts as
consequence and reversibility; privacy as user control.

Recommendation: run a docs-only copy-boundary scan before any app copy cleanup.
Do not rename internal compatibility cases or raw values in Batch 1B.

## Batch 1C Copy-Boundary Scan Addendum

Batch 1C ran a docs-only risky-copy scan and created
`docs/audits/ambitions-product-experience-pack-batch-1c-copy-boundary-scan.md`.
The scan confirms that legacy or risky terms are broad enough that remediation
must be staged and evidence-bound rather than performed as a bulk rename.

Summary:

- User-facing risk clusters: Habit/Ritual preview copy, Insights/History
  metrics and labels, Goal confidence/explainability labels, external snapshot
  urgency/mode labels, ScreenContract forbidden-copy lists, and privacy/source
  language that can drift into detection or certification tone.
- Internal compatibility/domain allowed clusters: `AppTab` compatibility cases,
  route fallbacks, async `.failed` states, receipt `failedSafely` raw values,
  domain confidence/score models, stale source states, goal modes, and legacy
  import/portable snapshot contracts.
- Historical/source-truth allowed clusters: canon forbidden lists, audit logs,
  train prompts, release claim ledgers, and validation scripts that mention
  risky terms as negative examples or technical pass/fail vocabulary.
- Test/fixture/preview risk clusters: `Native/Ambitions/PreviewSupport/**`,
  `Sources/Previews/**`, and `Native/AmbitionsTests/**` contain strings that
  may be visible in previews, screenshots, accessibility evidence, or asserted
  product contracts.

Safe rule: internal compatibility words are not automatically user-facing copy
debt. They may remain when preserving history, migration, routing
compatibility, raw values, or technical state. Future implementation must keep
those words out of visible labels, VoiceOver labels, receipts, headers,
buttons, tab labels, empty states, onboarding copy, and external snapshot copy
unless the source truth explicitly permits the wording.

Recommended treatment: Stage future copy work through inventory, fixture/preview
correction, visible UI copy correction, accessibility label correction,
receipt/source/privacy copy correction, and regression scans. Do not edit source
copy without explicit scope, owner files, focused tests, and copy-scan evidence.

## Batch 1D Source-Truth Packet And Readiness Gate Addendum

Batch 1D created:

- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/audits/ambitions-product-experience-pack-batch-1d-readiness-gate-report.md`

The source-truth packet assembles locked identity, objects, visual-board
caveats, accessibility requirements, copy guardrails, anti-generic guardrails,
Candidate/caveat register, repo handoff evidence, conflicts, and future stop
conditions. The readiness gate rates Product Depth PD01 as Stop until the exact
approval phrase is given, Batch 1E final file-boundary approval as Green/Yellow,
narrow implementation planning as Yellow/Stop, and broad app implementation as
Red.

## Top-Level Surface Mapping

| Surface | Locked primary object | Current repo files | Apparent alignment | Apparent conflict | Caveat | Implementation risk | Future treatment | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today | Reality Rail | `Native/Ambitions/Features/Today/TodayScreen.swift`, `TodayPanels.swift`, `TodayDayRailSignaturePrimitives.swift`, `TodayHeroStepSignaturePrimitives.swift`, `DayRailStepDetailState.swift`, `TodayActionClosureSheet.swift`, `TodayExecutionProjector.swift` | Current context index says Reality Rail, Start here, Start now, Now/Next/Later, Step Detail, Action Closure, proof slots, and privacy-safe projection exist. | Step Session depth is not proven as a complete primary execution environment in Batch 0. | Step Session timer must stay secondary. | High if a later batch turns Today into a dense task dashboard or upgrades Step Session without PD gates. | PD02/PD03-style depth only after Product Depth approval. | Inspect-only now; future implementation candidate after PD01. |
| Goals | LifePath View | `Native/Ambitions/Features/Goals/GoalsScreen.swift`, `GoalLifePathSignaturePrimitives.swift`, `GoalMissionControlLanePrimitives.swift`, `GoalComponents.swift`, `GoalDetailScreen.swift`, `GoalsFeatureService.swift` | SI06/SI07 evidence says LifePath and Mission Control lane primitives exist and are composed in Goals. | Product Experience Pack locks `MissionControlTimeSpine` order as Completed, Now, Friction, Next, Horizon; current repo evidence appears closer to lane/grid concepts such as Path, Proof, Risks, Proof/Blockers/Next Step/Momentum, and Horizon Ladder. | Generated visual-board copy is non-binding unless repeated in source truth. | High if Mission Control is edited before order/source ownership is reconciled. | Keep as PD01 mapping input if Product Depth starts; otherwise docs-only reconciliation evidence. | Inspect-only now; approval-gated future implementation candidate. |
| Capture | Text-first Capture Atmosphere Composer | `Native/Ambitions/Features/Captures/CapturesScreen.swift`, `CaptureAtmosphereComposer.swift`, `CaptureDraftRoutePreviewCard.swift`, `CapturesViewModel.swift`, `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`, `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift` | Current composer is text-first, has "What needs a place?", and reveals route/placement only after input. Voice affordance exists but is not connected. | PD10 prompt name still uses legacy confidence-loop wording in planning surfaces; future copy must avoid exposing model-certainty language. | Placement appears only after content exists. Candidate items must not be silently upgraded. | Medium if placement review becomes inbox-like or voice/add becomes primary. | PD09/PD10 depth with privacy/copy gates. | Inspect-only now; future implementation candidate after PD01. |
| Plan | LifeShape Map | `Native/Ambitions/Features/Plan/PlanScreen.swift`, `PlanLifeShapeTimeCapacityMap.swift`, `PlanLifeSuiteCard.swift`, `PlanLifeSuiteState.swift`, `PlanReflowDecisionCard.swift`, `PlanReflowDecisionState.swift`, `PlanFeatureService.swift` | SI08 evidence says a Plan-owned LifeShape Time Capacity Map exists with pressure reveal and no calendar grid. | Month LifeShape Lens has the highest calendar-clone risk and is not resolved by this map. | Day, Week, and Month are capacity lenses, not calendar modes. | High if Plan depth adds calendar-mode UI or silent rearrangement. | Narrow Plan LifeShape docs reconciliation before PD14 implementation. | Inspect-only now; future docs reconciliation candidate. |
| You | Personal System Center | `Native/Ambitions/Features/Profile/ProfileScreen.swift`, `ProfileRootSurface.swift`, `ProfileFeatureService.swift`, `ProfileViewModel.swift`, `Sources/Components/PersonalSystemCenterPrimitives.swift` | You is user-facing label for Profile-owned code. Personal System Center, Trust Center, What Ambitions Knows, receipts, privacy, and Appearance Studio are represented under You/Profile. | Appearance accent taxonomy conflicts with Pack: current code uses `sage`, `blueGray`, `mutedGold`, `copper`, `sand`; Pack locks Gold, Platinum, Rose, Cyan, Violet with Gold default. | You / Privacy / Memory / Receipts are copy-density guarded. | High if trust/privacy surfaces become dense settings or unsupported privacy/admin claims. | Docs-only alias plan before any token/default edit. | Inspect-only now; approval-gated future implementation candidate. |

## Primitive Mapping

| Primitive | Owner | Current repo files | Status | Caveat or candidate status | Future implementation risk | Recommended future batch type |
| --- | --- | --- | --- | --- | --- | --- |
| Ambition Meridian Shell | App shell | `Native/Ambitions/App/AppMeridianShell.swift`, `AppShellPresentationMode.swift`, `AmbitionsRootView.swift`, `AppShellView.swift`, `Sources/Components/ShellChromePrimitives.swift` | Partial/aligned | Meridian exists but native fallback remains the default shell mode. | Shell/routing edits are high-risk and approval-gated. | Docs-only shell boundary map unless explicitly scoped. |
| Reality Rail | Today | `TodayDayRailSignaturePrimitives.swift`, `DayRailViewState.swift`, `TodayDayRailPanels.swift`, `TodayScreen.swift` | Aligned | Current context claims F01/F02 Reality Rail evidence. | Can drift into task-list UI. | Product Depth Today planning before implementation. |
| Hero Step Panel | Today | `TodayHeroStepSignaturePrimitives.swift`, `TodayPanels.swift`, `TodayScreen.swift` | Aligned | SI05 evidence exists. | Primary-action hierarchy can be diluted by too many controls. | PD02/PD03 implementation only after PD01. |
| Step Detail | Today | `DayRailStepDetailState.swift`, `TodayScreen.swift`, `TodayPanels.swift`, `TodayViewModel.swift` | Partial/aligned | F03 says Today-local sheet exists; Product Depth asks for deeper drill-down. | Can become card expansion instead of true detail. | PD02 implementation after Product Depth approval. |
| Step Session | Today | `TodayScreen.swift`, `TodayViewModel.swift`, `TodayActionClosureSheet.swift`, F04 audit evidence | Partial/unknown | Step Session depth is not proven as the primary execution environment by Batch 0. Timer must stay secondary. | High if timer dominates or creates pressure. | PD03 after PD02 Green. |
| Action Closure Diamond | Today / Recovery | `TodayActionClosureSheet.swift`, `TodayActionClosureSheetState.swift`, `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, `Sources/Components/TrustReceiptLayerPrimitives.swift` | Partial | Current closure exists; "Diamond" naming is Pack-level visual/object language, not proven as a current repo object. | Outcome UI can imply achievement instead of evidence/consequence. | PD04 docs-to-implementation after Today depth. |
| Trust Receipt Caption | Shared / You / Today | `Sources/Components/TrustReceiptLayerPrimitives.swift`, `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, `ProfileFeatureService.swift` | Partial/aligned | SI10 evidence exists; caption-specific Pack object needs source-backed mapping. | Receipts must stay consequence, not notification. | Trust/proof docs reconciliation or PD15. |
| LifePath View | Goals | `GoalLifePathSignaturePrimitives.swift`, `GoalsScreen.swift`, `GoalsFeatureService.swift` | Aligned | SI06 evidence exists. | Goal path can become decorative without source/proof detail. | PD05/PD06 after Mission Control reconciliation. |
| MissionControlTimeSpine | Goals | `GoalMissionControlLanePrimitives.swift`, `GoalComponents.swift`, `GoalDetailScreen.swift`, `GoalsFeatureService.swift`, `Sources/Components/ShellChromePrimitives.swift` | Partial/conflict | Pack locks Completed, Now, Friction, Next, Horizon; current repo uses lane/grid language that needs reconciliation. | High risk of implementing the wrong order. | PD01 mapping input after Product Depth approval; no source edit before then. |
| Evidence Ledger / Proof Spine | Domain / Today / Goals / You | `ActionReceiptProofLedgerModels.swift`, `ProofResourceGraphModels.swift`, `TodayProofReceiptLedgerState.swift`, `ProfileFeatureService.swift`, `PortableSnapshotService.swift` | Partial/aligned | Proof is evidence, not achievement. | Persistence/proof edits are approval-gated. | PD07/PD17 only after trust/proof gates. |
| Capture Atmosphere Composer | Capture | `CaptureAtmosphereComposer.swift`, `CapturesScreen.swift`, `CaptureDraftRoutePreviewCard.swift` | Aligned | Text-first rule currently appears preserved. | Voice/add/attachment can become primary by accident. | PD09/PD10 after PD01. |
| Placement Resolver | Capture / Domain | `SmartAttachmentPlacementPreview.swift`, `SmartAttachmentModels.swift`, `SmartAttachmentService.swift`, `SmartAttachmentCaptureAdapter.swift`, `CaptureDraftRoutePreviewCard.swift` | Partial/aligned | Placement must appear only after content exists. | Candidate items must not be silently upgraded. | PD09 docs/implementation with privacy gates. |
| LifeShape Map | Plan | `PlanLifeShapeTimeCapacityMap.swift`, `PlanLifeSuiteState.swift`, `PlanLifeSuiteCard.swift`, `PlanFeatureService.swift` | Aligned with caveat | Month lens calendar-clone risk remains. | High if Day/Week/Month become calendar modes. | Narrow Plan LifeShape docs reconciliation before PD14. |
| Reflow Decision | Plan | `PlanReflowDecisionCard.swift`, `PlanReflowDecisionState.swift`, `PlanFeatureService.swift`, `PlanViewModel.swift` | Partial/aligned | Reflow must be user-owned and non-silent. | Runtime/source-truth edits may trigger AOS gates. | PD12 after Plan gates. |
| Personal System Center | You/Profile | `ProfileRootSurface.swift`, `ProfileScreen.swift`, `ProfileFeatureService.swift`, `Sources/Components/PersonalSystemCenterPrimitives.swift` | Aligned | You label is user-facing; Profile remains internal compatibility owner. | Copy density and privacy overclaim risk. | PD15/PD16 after You trust boundary review. |
| Appearance Studio | You/Profile / Theme | `ProfileScreen.swift`, `ProfileFeatureService.swift`, `ProfileViewModel.swift`, `Sources/Theme/AmbitionTheme.swift`, `Native/Ambitions/Persistence/PersistenceContracts.swift` | Conflict/partial | Location under You aligns; accent taxonomy/default conflict with Pack. | Token edits affect shared UI and persistence defaults. | Narrow docs-only accent-system reconciliation. |
| Proof / Source / Privacy / Receipt Marks | Shared UI / Domain / You | `TrustReceiptLayerPrimitives.swift`, `LoadingDegradedStatePrimitives.swift`, `IconographyStatusPrimitives.swift`, `AccessibilityAdaptiveInterfacePrimitives.swift`, `ProfileFeatureService.swift` | Partial/aligned | Source states are freshness, conflict, and review boundaries, not AI certification. | Copy can drift into certification or surveillance language. | Copy/trust boundary docs batch before implementation. |

## Conflict Map

| Conflict | Severity | Affected source truth | Affected repo files | Implementation impact | User decision needed | Recommended future resolution |
| --- | --- | --- | --- | --- | --- | --- |
| Accent system conflict | Yellow | Appearance Studio Addendum; Pack accent rules | `Sources/Theme/AmbitionTheme.swift`, `Native/Ambitions/Persistence/PersistenceContracts.swift`, `ProfileScreen.swift`, `ProfileFeatureService.swift`, `ProfileViewModel.swift` | Do not edit tokens until naming/default persistence implications are mapped. This is a naming/token migration conflict with product implications. | Yes, before token/default changes. | Create a docs-only alias plan first; mark design token files approval-gated. |
| MissionControlTimeSpine order conflict / unknown | Yellow | Product Object Spec Export; Pack MissionControlTimeSpine rule | `GoalMissionControlLanePrimitives.swift`, `GoalComponents.swift`, `GoalDetailScreen.swift`, `GoalsFeatureService.swift`, `Sources/Components/ShellChromePrimitives.swift` | Do not implement Mission Control depth until order and owner are reconciled. Current repo is partial alignment with unresolved order conflict. | Yes, if current lane model should be replaced. | Use as PD01 mapping input if Product Depth starts; otherwise keep docs-only. |
| Compatibility vocabulary risk | Yellow | Product Language System; Pack forbidden-copy rules | `AppTab.swift`, `AppNavigation.swift`, `Habits*`, `Insights*`, `Profile*`, async/result/domain files, previews, fixtures, tests, source/privacy/receipt labels | Preserve internal seams; do not expose legacy or certainty-oriented language in new UI. | No for preservation; yes for retirement or user-facing copy changes. | Use Batch 1C registry as future copy-remediation boundary. |
| Step Session depth unknown | Yellow | Today Pack object rules; PD03 manifest | `TodayScreen.swift`, `TodayViewModel.swift`, `TodayActionClosureSheet.swift` | Do not claim Step Session is complete Product Depth. | Yes before PD03 starts. | Let PD02/PD03 sequence decide after `Start Product Depth Train`. |
| Month LifeShape calendar-clone risk | Yellow | Plan LifeShape-first rule; caveats | `PlanLifeShapeTimeCapacityMap.swift`, `PlanLifeSuiteState.swift`, `PlanFeatureService.swift` | Do not add Month UI until capacity-lens contract is explicit. | Yes if Month lens is redesigned. | Narrow Plan LifeShape docs reconciliation or PD14 planning gate. |
| Validation command uncertainty | Yellow | Codex OS validation rules | `scripts/run-doc-qa.sh`, `scripts/batch-train-gate-check.sh`, `docs/native-build-and-release.md`, `.github/workflows/ios-validate.yml` | Docs-only validation can use doc QA and gate hints; lint/format command remains non-canonical. | No. | Record commands found; avoid inventing lint/format commands. |
| Product Depth approval gate | Stop | PD train manifest; global order | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`, `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md` | Product Depth cannot start from this batch. | Yes: exact phrase required. | User must say `Start Product Depth Train` to begin PD01. |
| Global train approval gate | Stop | Global continuation protocol | `GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`, current run/train state | No global continuation authorized. | Yes. | Stay stopped after Batch 1A. |

## Current Product Decisions Preserved

- Ambitions remains a premium native iPhone life operating system.
- Top-level tabs remain Today, Goals, Capture, Plan, You.
- Capture remains text-first.
- Plan remains LifeShape-first.
- You remains trust/control-first.
- Appearance Studio remains under You/Profile.
- Proof, receipts, source state, privacy, accessibility, and Reduced Motion
  requirements remain guarded and un-overclaimed.
- Product Depth remains queued/blocked and not started.

## Recommended Next Action

Recommended: run Batch 1E docs-only final file-boundary approval and
implementation-planning gate. It should preserve the Batch 1D source-truth
packet, avoid app code, and prepare only the next user decision. Do not start
Product Depth unless the user says the exact approval phrase from the Product
Depth manifest.
