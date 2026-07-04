# P2 Core Runtime Inventory

Status: Active P2 source/runtime proof inventory  
Scope: P2 Core Runtime Behavior trains only  
Owner posture: QA evidence log, not visual proof, release proof, or roadmap  
Baseline for P2A: `0c92b2d969ff7299c1583889100a26c9ed7562ad`  
P2A source-proof commit: `ac398ccdc175f65b70804dd47ae97803922d7a85`  
Final train commit: recorded in P2A closeout

This file records scoped source/runtime evidence for P2 trains. It does not upgrade Visual Green, Release Green, device readiness, accessibility readiness, notification delivery, account/R2 readiness, full goal pathing, Future Steps, Make Room, Add with conflict, Life Capital, Source Atlas app-side composition, reviews, or full automation controls.

## P2A Protected Seven-Day Placement Guard

### Mission

Ambitions must not silently move scheduled Step placement inside the next seven days. The P2A implementation is a source/runtime safety-contract guard for scheduled placement, not a full scheduling architecture, visual redesign, or approval UI.

### Contract Implemented

- Canonical owner: `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ProtectedStepPlacementPolicy.swift`.
- Command preflight hook: `Native/Ambitions/Core/LocalRuntimeOS/Commands/PolicyGuardedCommandExecutor.swift`.
- Test owner: `Native/AmbitionsTests/LocalRuntimeOS/TimeEngine/ProtectedStepPlacementPolicyTests.swift` and `Native/AmbitionsTests/LocalRuntimeOS/Commands/PolicyGuardedCommandExecutorTests.swift`.
- Deterministic decision states: `allowed`, `requires_explicit_approval`, `blocked_from_silent_movement`, and `pending_review`.
- Inputs evaluated: current time, original placement, proposed placement, protected seven-day window, trigger, explicit approval, automation policy maturity, context quality, and local-only boundary.
- Automatic movement inside the next seven days is blocked from silent application unless explicit approval is present.
- Automatic future movement outside the next seven days is allowed only when existing automation policy explicitly allows it and context is sufficient; otherwise it returns pending review.
- User-initiated movement inside the next seven days requires explicit action.
- Missed Step recovery `Move it` is treated as user-initiated and keeps non-shaming `What changed?` / `Still counts` impact language.
- Protected placement remains local-only and account-free; non-local placement attempts are blocked.

### Target Gates

- `automatic_adjustment_does_not_move_next_seven_days_silently`
- `automatic_future_adjustment_occurs_only_where_allowed`
- `automation_respects_protected_near_term_placement`
- `user_caused_adjustment_shows_impact_summary`
- `foundation_reminder_can_be_created_completed_and_rescheduled`
- `foundation_offline_core_runs_without_account`

### Status

- Source Green for scoped protected-placement policy and command preflight.
- Runtime Green for focused policy/executor behavior and affected P1 regressions.
- Interaction Green not claimed; no rendered approval/review UI was changed or proven.
- Ready for Visual Review not claimed; no screenshots were created.
- Visual Green not claimed.
- Release Green not claimed.

### Evidence

- `scripts/ambitions-xcode-test-focused.sh --batch P2A_PROTECTED_PLACEMENT --test AmbitionsTests/ProtectedStepPlacementPolicyTests --timeout 15m --kill-after 60s`: passed, 7 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch P2A_PROTECTED_PLACEMENT_EXECUTOR --test AmbitionsTests/PolicyGuardedCommandExecutorTests --timeout 15m --kill-after 60s`: passed, 5 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch P2A_P1_REGRESSION_TODAY --test AmbitionsTests/TodayCommandHandlerTests --timeout 15m --kill-after 60s`: passed, 9 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch P2A_P1_REGRESSION_RECURRENCE --test AmbitionsTests/RecurringStepLifecycleServiceTests --timeout 15m --kill-after 60s`: passed, 3 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch P2A_P1_REGRESSION_CAPTURE --test AmbitionsTests/CaptureServiceTests --timeout 15m --kill-after 60s`: passed, 20 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch P2A_P1_REGRESSION_TIME --test AmbitionsTests/P1DTimeFoundationTests --timeout 15m --kill-after 60s`: passed, 5 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch P2A_P1_REGRESSION_SEARCH --test AmbitionsTests/P1FLocalSearchFoundationTests --timeout 15m --kill-after 60s`: passed, 3 tests.

### Remaining Gaps

- No rendered approval/review UI proof for protected placement.
- No accessibility proof for protected placement UI.
- No device/no-network proof.
- No notification delivery or tap-through proof.
- No full scheduling architecture centralization across every projection and legacy mutation path.
- No full automation settings model globally, per life area, or per goal.
- No Future Steps, full goal pathing, Make Room, Add with conflict, Life Capital, Source Atlas app-side composition, reviews, account/R2, Visual Green, or Release Green proof.

### Architecture Notes

- Final Architecture Tree inspected: yes.
- Current canonical owner touched after `AMB-1557`: `Core/LocalRuntimeOS/TimeEngine`.
- Test owner touched after `AMB-1557`: `Native/AmbitionsTests/LocalRuntimeOS/TimeEngine` and existing executor tests.
- `Features/` was not expanded.
- `SimpleStepLifecycleService.swift` was not edited during P2A and remained at 807 lines; `AMB-1557` later routed recurring occurrence generation through `RecurrenceEngine` while leaving repository mutation authority unchanged.
- Compatibility debt: command preflight covers schedule/placement commands with step placement metadata; broader scheduling/projection centralization remains a future TimeEngine repair train.

## P2B-A Central Apply-Path Consolidation Addendum

Date: 2026-06-25
Baseline SHA: `dc25c6bad15de86dac5ad5da36aa7e1862488002`
Current source baseline inspected: `6b24af43e0761415413565d930fba0198f11f503`
Phase status: Honest Yellow. Focused source/runtime validation passed for the rendered Time placement path and existing P2A command preflight, but the bundle stopped before P2B-B because the standard release-claim scan is Red on unrelated pre-existing component strings outside this phase diff.

### Scope

P2B-A routes the rendered Time placement apply path through the existing protected-placement policy before any Time/Today mutation is produced. It does not add rendered approval UI, full Make Room, Add with conflict, Future Steps, Life Capital, account/R2 behavior, Source Atlas app behavior, Visual Green, Release Green, or device readiness.

### Source Changed

- `Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ProtectedStepPlacementPolicy.swift`
- `Native/AmbitionsTests/Time/TimeFieldMutationCoordinatorTests.swift`

### Apply-Path Proof Added

- `TimeFieldMutationCoordinator.perform(.placeStep)` now creates placement metadata for the selected Time bucket, including proposed start/end, duration, trigger, and explicit approval state.
- `AMB-1557` routes the coordinator through `PlacementEngine`, which evaluates the command with `ProtectedTimeEngine`, `ProtectedStepPlacementPolicy`, `PriorityPlacementPolicy`, and conflict proposals before constructing `TimeMutation` or `RuntimeMutation`.
- Automatic Time placement inside the next seven days returns a protected-placement decision and does not mutate the Time surface.
- User-initiated Time placement without explicit approval returns `requires_explicit_approval` and does not mutate the Time surface.
- Normal rendered Time placement remains user-initiated and explicit by default, preserving the existing `Place Step` button behavior until P2B-B renders the review path.
- Explicit approval metadata now overrides the prior user-actor fallback, so a user-initiated protected placement with `explicitUserApproval=false` returns review-required instead of silently applying.

### Validation

- `scripts/ambitions-xcode-test-focused.sh --batch P2B_A_TIME_COORDINATOR_RERUN --test AmbitionsTests/TimeFieldMutationCoordinatorTests --timeout 15m --kill-after 60s` passed: 11 tests, 0 failures.
- Earlier `P2B_A_TIME_COORDINATOR` run failed once before the explicit-approval override was patched: `testP2BAUserTimePlacementInsideSevenDaysRequiresExplicitApprovalBeforeMutation`.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_A_P2A_POLICY --test AmbitionsTests/ProtectedStepPlacementPolicyTests --timeout 15m --kill-after 60s` passed: 7 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_A_P2A_EXECUTOR --test AmbitionsTests/PolicyGuardedCommandExecutorTests --timeout 15m --kill-after 60s` passed: 5 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_A_P1D_TIME --test AmbitionsTests/P1DTimeFoundationTests --timeout 15m --kill-after 60s` passed: 5 tests, 0 failures.
- `python3 scripts/product-experience-gate-index-check.py` passed: 99 gates validated.
- `python3 scripts/ambitions-skill-registry-check.py` passed.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` passed.
- `python3 scripts/ambitions-copy-contract-lint.py` passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py` passed.
- `python3 scripts/ambitions-architecture-inventory.py` passed: final-tree parity achieved.
- `git diff --check` passed.
- `bash scripts/release-claim-safety-scan.sh` failed on pre-existing strings in `Sources/Components/CoreReusableInteractionPrimitives+02-AmbitionCoreInteractionPrimitiveCatalog.swift` (`production ready`, `release ready`). That file was not touched by P2B-A.

### Gate Posture

- `automatic_adjustment_does_not_move_next_seven_days_silently`: remains Partial. P2B-A adds source/runtime apply-path consolidation evidence, but rendered approval UI, accessibility proof, and device/no-network proof remain missing.
- `automation_respects_protected_near_term_placement`: remains Partial. P2B-A adds Time coordinator preflight evidence, but rendered review UI, receipt persistence beyond scoped mutation proof, accessibility proof, and device/no-network proof remain missing.
- `user_caused_adjustment_shows_impact_summary`: remains Partial. P2B-A does not render the user-caused impact summary.

### Remaining Gaps

- No rendered protected placement approval/review UI yet.
- No approve/decline UI proof yet.
- No screenshot or visual proof.
- No accessibility proof for the approval UI.
- No device/no-network proof.
- Full standard validation is not Green because of the unrelated release-claim scan failure listed above.
- Broader scheduling centralization outside the scoped rendered Time coordinator and existing command preflight remains future P2 work.

### Architecture Notes

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Projection/Mutations`, `Core/Runtime`, and `Native/AmbitionsTests/Time`.
- Non-canonical owners touched: none.
- `Features/` was not expanded.
- No second protected-placement policy or executor was introduced.
- `SimpleStepLifecycleService.swift` was not touched by P2B-A.
- `SimpleStepLifecycleService.swift` line count remained 469.

## P2B-B Repair Rendered Protected Placement Approval Addendum

Date: 2026-06-25
Baseline SHA: `c2c0fc12814be75259ab172d407de0b0cea272d3`
Source/UI proof commit: `ba70e59be`
Phase status: Source Green, Runtime Green, Interaction Green scoped to the rendered Time protected-placement approval path, and Ready for Visual Review. Visual Green, Release Green, device readiness, and full accessibility conformance are not claimed.

### Scope

P2B-B repair routes the selected protected-placement Time service into the real rendered Time path and renders the approval UI through `TimeSurface -> TimeViewModel -> AppFeatureFactoryCapability.timeService`. It does not implement Make Room, Add with conflict, Future Steps, full goal pathing, Life Capital, Source Atlas app behavior, notification delivery, account/R2 behavior, visual redesign, or release/device validation.

### Root Cause Confirmed

The failed P2B-B attempt selected a protected-placement fixture service in `AppContainerFactory`, but `AppContainer` still constructed `AppRuntimeCapability` and `AppFeatureFactoryCapability` from `runtime.timeService`. `TimeSurface` loads through `featureFactory.timeService`, so the selected service never reached the rendered Time surface.

### Injection Path Repaired

- `AppContainer` now builds `AppRuntimeCapability` and `AppFeatureFactoryCapability` from the services passed into the container, including the selected `timeService`.
- `AppContainerFactory` can provide a DEBUG-only protected-placement Time service when `AMBITIONS_UI_PROTECTED_PLACEMENT_REVIEW=1`.
- `PreviewAppContainerFactory` uses the same protected-placement Time scenario when that DEBUG environment value is set.
- No second protected-placement policy, executor, Time service architecture, root surface, or fixture-only UI path was introduced.

### Source Changed

- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/Scenarios/SurfaceScenarios/TimeScenarios+Support.swift`
- `Native/Ambitions/Surfaces/Time/ProtectedPlacementReviewCard.swift`
- `Native/Ambitions/Surfaces/Time/ProtectedPlacementReviewState.swift`
- `Native/Ambitions/Surfaces/Time/TimeSurface.swift`
- `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`
- `Native/AmbitionsTests/Time/TimeProtectedPlacementReviewTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

### Rendered Approval Proof

- Focused UI test launched the app through the normal rendered Time path with `AMBITIONS_UI_PROTECTED_PLACEMENT_REVIEW=1`.
- The UI test opened Time, tapped the rendered LifeShape placement action, found `protected-placement-review`, and verified the Step, current placement, proposed placement, approve action, and keep action identifiers.
- The review copy remains plain and non-shaming:
  - `Review change`
  - `This moves a Step inside the next seven days. Ambitions will not move it without approval.`
  - `Move it`
  - `Keep as is`
- Screenshot artifacts were produced under `.codex/xcode-summaries/P2B_B_REPAIR_UI/20260625T123801Z-AmbitionsUITests-AmbitionsUITests-testAMB1168TimeLifeShapeMutationAndUndoScreens-83198-10459/extract/screenshots/`.

### Mutation and Keep Proof

- Source/runtime unit proof verifies protected placement does not mutate before approval.
- Tapping `Keep as is` clears the review, reports `Kept as is`, and leaves the Time state unchanged.
- Tapping `Move it` reruns the same Time mutation with explicit protected-placement approval, applies the placement, reports `Step moved`, and preserves existing undo behavior.
- The rendered UI test verified keep first, then reopened the review and approved the movement through the same Time path.

### Accessibility Proof

- The review card exposes `protected-placement-review`.
- Rows expose `protected-placement-review.step`, `protected-placement-review.current-placement`, and `protected-placement-review.proposed-placement`.
- Actions expose `protected-placement-review.move-it` and `protected-placement-review.keep-as-is`.
- Outcome exposes `protected-placement-review.outcome`.
- The card accessibility value includes the Step title, current placement, proposed placement, and approval reason in plain language.
- Public accessibility conformance, VoiceOver sweep, Dynamic Type sweep, Reduce Motion sweep, and device accessibility readiness are not claimed.

### Validation

- `scripts/ambitions-xcode-test-focused.sh --batch P2B_B_REPAIR_REVIEW_UNIT --test AmbitionsTests/TimeProtectedPlacementReviewTests --timeout 15m --kill-after 60s` passed: 4 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_B_REPAIR_UI --test AmbitionsUITests/AmbitionsUITests/testAMB1168TimeLifeShapeMutationAndUndoScreenshotProof --timeout 20m --kill-after 60s` passed: 1 test, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_B_REPAIR_COORDINATOR --test AmbitionsTests/TimeFieldMutationCoordinatorTests --timeout 15m --kill-after 60s` passed: 11 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_B_REPAIR_POLICY --test AmbitionsTests/ProtectedStepPlacementPolicyTests --timeout 15m --kill-after 60s` passed: 7 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_B_REPAIR_EXECUTOR --test AmbitionsTests/PolicyGuardedCommandExecutorTests --timeout 15m --kill-after 60s` passed: 5 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2B_B_REPAIR_P1D_TIME --test AmbitionsTests/P1DTimeFoundationTests --timeout 15m --kill-after 60s` passed: 5 tests, 0 failures.
- `python3 scripts/product-experience-gate-index-check.py` passed: 99 gates validated.
- `python3 scripts/ambitions-skill-registry-check.py` passed.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` passed.
- `python3 scripts/ambitions-copy-contract-lint.py` passed.
- `bash scripts/release-claim-safety-scan.sh` passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py $(git diff --name-only HEAD --)` passed before the docs addendum.
- `python3 scripts/ambitions-architecture-inventory.py --json` passed with `green: true`.
- `git diff --check` passed.

### Gate Posture

- `automatic_adjustment_does_not_move_next_seven_days_silently`: remains Partial. P2B-B repair adds rendered approval, approval mutation, keep/decline, accessibility identifier, and screenshot evidence; device/no-network proof and broader scheduling centralization remain missing.
- `automation_respects_protected_near_term_placement`: remains Partial. P2B-B repair adds rendered review proof, but full automation settings, receipt persistence beyond the scoped visible mutation/undo path, and device/no-network proof remain missing.
- No scenario gate Markdown/YAML status was upgraded by this repair.

### Remaining Gaps

- No Visual Green or Release Green claim.
- No physical-device validation.
- No network-disabled/no-account device workflow proof.
- No full VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, or High Contrast sweep.
- No full scheduling architecture centralization beyond the scoped rendered Time path and existing command preflight.
- No persistent approval receipt beyond the scoped visible mutation and existing undo proof.

### Architecture Notes

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `App`, `Surfaces/Time`, `Scenarios/SurfaceScenarios`, `Native/AmbitionsTests/Time`, and `Native/AmbitionsUITests`.
- Non-canonical owners touched: none.
- `Features/` was not expanded.
- No compatibility shims were added.
- `SimpleStepLifecycleService.swift` was not touched by P2B-B repair.
- `SimpleStepLifecycleService.swift` line count remained 469.

## P2C-A Priority Runtime Model + Placement Policy Addendum

Date: 2026-06-25
Baseline SHA: `3514e0ec030611789aa476cf56bad7eb8b67ba4a`
Phase status: Source Green and Runtime Green scoped to the deterministic local priority placement policy. Interaction Green, Visual Green, Release Green, device readiness, and full accessibility conformance are not claimed.

### Scope

P2C-A adds a small canonical runtime policy for placement priority. It supports exactly `Low`, `Normal`, and `High`, represents user override state where scoped, keeps low-context placement conservative, and confirms priority cannot bypass the protected seven-day placement guard. It does not render priority controls, persist a final priority setting, implement Make Room, Add with conflict, Future Steps, full goal pathing, Life Capital, Source Atlas app behavior, account/R2 behavior, visual redesign, or release/device validation.

### Source Changed

- `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/PriorityPlacementPolicy.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/TimeEngine/PriorityPlacementPolicyTests.swift`

### Runtime Proof

- `PlacementPriority` exposes only `Low`, `Normal`, and `High`.
- `Critical`, `Must Fit`, rank, score, and urgency-score language are rejected as user-facing priority values.
- `PriorityPlacementInput` can be created from local command priority hints or explicit metadata override.
- `PriorityPlacementDecision` preserves user override state, local-only posture, protected-placement decision kind, and explicit approval requirement.
- High priority inside the protected seven-day window still requires explicit approval and cannot bypass protected approval.
- Low-context priority returns `pending_review` with degraded facts instead of a confidence or optimization claim.
- Low priority may return a defer/review suggestion, but it does not implement or invoke Make Room.
- Non-local placement priority attempts return pending review and remain account-free.

### Validation

- `scripts/ambitions-xcode-test-focused.sh --batch P2C_A_PRIORITY_POLICY --test AmbitionsTests/PriorityPlacementPolicyTests --timeout 15m --kill-after 60s` passed: 8 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_A_PROTECTED_POLICY --test AmbitionsTests/ProtectedStepPlacementPolicyTests --timeout 15m --kill-after 60s` passed: 7 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_A_POLICY_EXECUTOR --test AmbitionsTests/PolicyGuardedCommandExecutorTests --timeout 15m --kill-after 60s` passed: 5 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_A_TIME_MUTATION --test AmbitionsTests/TimeFieldMutationCoordinatorTests --timeout 15m --kill-after 60s` passed: 11 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_A_TIME_REVIEW --test AmbitionsTests/TimeProtectedPlacementReviewTests --timeout 15m --kill-after 60s` passed: 4 tests, 0 failures.
- `python3 scripts/product-experience-gate-index-check.py` passed: 99 gates validated.
- `python3 scripts/ambitions-skill-registry-check.py` passed.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` passed.
- `python3 scripts/ambitions-copy-contract-lint.py` passed.
- `bash scripts/release-claim-safety-scan.sh` passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py` passed.
- `python3 scripts/ambitions-architecture-inventory.py` passed: final-tree parity achieved.
- `git diff --check` passed.

### Gate Posture

- `priority_supports_low_normal_high`: remains Partial. P2C-A adds scoped runtime model and test proof; rendered UI/accessibility proof remains P2C-B.
- `priority_can_be_overridden_by_user`: moves from Unknown to Partial. P2C-A represents user override in the runtime decision; rendered edit control and persistence/relaunch proof remain missing.
- `priority_does_not_include_must_fit_as_goal_type`: moves from Unknown to Partial. P2C-A rejects `Must Fit` as a priority value and the vocabulary drift scan passed; broader goal-type audit remains future proof.
- `priority_can_be_inferred`: remains Partial. P2C-A can derive scoped priority context from existing command hints, but does not claim broad inference.
- `make_room_is_action_not_priority`: remains Missing. P2C-A does not implement Make Room.

### Remaining Gaps

- No rendered priority controls or review copy yet.
- No user-visible priority accessibility proof.
- No screenshot or visual proof.
- No physical-device validation.
- No no-account/no-network device workflow proof.
- No persistence/relaunch proof for final user priority override.
- No Future Steps, full goal pathing, Make Room, Add with conflict, Life Capital, Source Atlas app-side composition, Visual Green, or Release Green proof.

### Architecture Notes

- Final Architecture Tree inspected: yes.
- Current canonical owner after `AMB-1557`: `Core/LocalRuntimeOS/TimeEngine`.
- Current test owner after `AMB-1557`: `Native/AmbitionsTests/LocalRuntimeOS/TimeEngine`.
- Non-canonical owners touched: none.
- `Features/` was not expanded.
- No parallel Step, Time, Priority, Capacity, Conflict, or persistence model was introduced.
- No compatibility shims were added.
- `SimpleStepLifecycleService.swift` was not touched by P2C-A.
- `SimpleStepLifecycleService.swift` line count remained 469.

## AMB-1557 LocalRuntimeOS TimeEngine Addendum

Date: 2026-06-30
Phase status: Source Green and Runtime Green scoped to the local temporal backend foundation. Interaction Green, Visual Green, Release Green, physical-device readiness, and full app-wide TimeEngine adoption are not claimed.

### Scope

`AMB-1557` installs `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/` as the canonical owner for local temporal graph, protected placement, priority placement, recurrence, conflict, placement, recovery-window, and local calendar-store behavior. EventKit remains outside this owner as an adapter/side-effect boundary.

### Source Changed

- `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/`
- `Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift`
- `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService+Recurring.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/TimeEngine/`

### Runtime Proof

- `TimeFieldMutationCoordinator.perform(.placeStep)` evaluates placement commands through `PlacementEngine` before producing Time or runtime mutations.
- `PlacementEngine` routes local-only placement through protected-time, priority, constraint, conflict, and runtime-spine trace semantics.
- `RecurrenceEngine` owns local recurrence date generation used by recurring step scheduling.
- `LifeCalendarStore` provides durable local calendar block storage and object-state projection records without making EventKit authoritative.
- The old `Core/Runtime` protected-placement and priority-placement policy owners and matching old runtime test owners were removed.

### Remaining Gaps

- Not every Time/scheduling/recovery/recurrence path consumes `TimeEngine` yet.
- EventKit outbox and external reconciliation are not fully enforced across every external calendar path.
- TimeProjection is not yet fully rebuilt from the event journal for every Time mutation.
- Rendered review UI, accessibility proof, no-network device proof, Visual Green, and Release Green are not claimed.

## P2C-B Rendered Priority Controls / Review Copy Addendum

Date: 2026-06-25
Baseline SHA: `99ec82c9fb2824516a69725de65b56f9187c4d97`
Phase status: Honest Yellow. Source and runtime unit validation passed for scoped rendered priority controls in the existing Time protected-placement review path. Full Interaction Green is not claimed because the focused UI screenshot test repeatedly failed after reaching the priority control and screenshot point on XCUITest tap/hittability/action outcome behavior.

### Scope

P2C-B exposes `Priority` in the existing protected placement review card under Time. It keeps priority values to `Low`, `Normal`, and `High`, lets the pending review priority be changed locally, and keeps protected seven-day movement behind explicit approval even when priority is changed to High. It does not create a new surface, dashboard, score, rank, Critical value, Must Fit value, Make Room flow, Add with conflict flow, Future Steps, full goal pathing, Life Capital, account/R2 behavior, Source Atlas app behavior, visual redesign, or release/device validation.

### Source Changed

- `Native/Ambitions/Surfaces/Time/ProtectedPlacementReviewCard.swift`
- `Native/Ambitions/Surfaces/Time/ProtectedPlacementReviewState.swift`
- `Native/Ambitions/Surfaces/Time/TimeSurface.swift`
- `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`
- `Native/AmbitionsTests/Time/TimeProtectedPlacementReviewTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

### Rendered Priority Proof

- The protected placement review card now renders a `Priority` segmented control with `Low`, `Normal`, and `High`.
- The review card exposes `protected-placement-review.priority`.
- The review card accessibility value includes the selected priority and available priority choices.
- The review card includes the priority review note: priority can help Ambitions choose what to review first, but the move still needs approval when protected placement requires approval.
- `TimeViewModel.updateProtectedPlacementPriority(_:)` updates only the pending review state and does not mutate Time placement.
- Changing priority to High keeps `requiresExplicitApproval == true` and `canBypassProtectedApproval == false`.

### Validation

- `scripts/ambitions-xcode-test-focused.sh --batch P2C_B_TIME_REVIEW --test AmbitionsTests/TimeProtectedPlacementReviewTests --timeout 15m --kill-after 60s` passed: 5 tests, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_B_UI --test AmbitionsUITests/AmbitionsUITests/testAMB1168TimeLifeShapeMutationAndUndoScreenshotProof --timeout 20m --kill-after 60s` failed after proving the priority control and capturing the review screenshot; later failure: `time.life-shape-field.layer.protected` not hittable.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_B_UI_RERUN --test AmbitionsUITests/AmbitionsUITests/testAMB1168TimeLifeShapeMutationAndUndoScreenshotProof --timeout 20m --kill-after 60s` failed after proving the priority control and capturing the review screenshot; later failure: `protected-placement-review.keep-as-is` not hittable.
- `scripts/ambitions-xcode-test-focused.sh --batch P2C_B_UI_FINAL --test AmbitionsUITests/AmbitionsUITests/testAMB1168TimeLifeShapeMutationAndUndoScreenshotProof --timeout 20m --kill-after 60s` failed after proving the priority control and capturing the review screenshot; later failure: review outcome did not appear after coordinate fallback tap.

### Screenshot Evidence

- `.codex/xcode-summaries/P2C_B_UI_FINAL/20260625T175016Z-AmbitionsUITests-AmbitionsUITests-testAMB1168TimeLifeShapeMutationAndUndoScreens-67292-1356/extract/screenshots/amb-1168-time-protected-placement-review_0_80D40484-9267-4060-9CAF-CD7362FC78E9.png`
- Screenshot evidence is Ready for Visual Review only. Visual Green is not claimed.

### Gate Posture

- `priority_supports_low_normal_high`: remains Partial. P2C-B adds rendered control and screenshot evidence, but full UI interaction pass and broader accessibility sweep remain missing.
- `priority_can_be_overridden_by_user`: remains Partial. P2C-B adds local pending-review priority change proof; persistence/relaunch proof and full rendered interaction pass remain missing.
- `priority_does_not_include_must_fit_as_goal_type`: remains Partial. P2C-B does not add a Must Fit value.
- No scenario gate Markdown/YAML status was upgraded by P2C-B.

### Stop Reason

The bundle stops after P2C-B because more than two attempts hit the same XCUITest interaction root around hittability/action completion in the rendered protected review path. P2D-A, P2D-B, P2E-A, P2E-B, and P2F were not implemented in this run.

### Remaining Gaps

- Full P2C-B UI interaction pass remains missing.
- No Visual Green or Release Green claim.
- No physical-device validation.
- No network-disabled/no-account device workflow proof.
- No full VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, or High Contrast sweep.
- No persistence/relaunch proof for user priority override.
- Capacity fit, This does not fit yet, Make Room, Add with conflict, Future Steps, full goal pathing, Life Capital, Source Atlas app-side composition, account/R2, and P2F closeout remain future work.

### Architecture Notes

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Surfaces/Time`, `Native/AmbitionsTests/Time`, and `Native/AmbitionsUITests`.
- Non-canonical owners touched: none.
- `Features/` was not expanded.
- No parallel Step, Time, Priority, Capacity, Conflict, or persistence model was introduced.
- No compatibility shims were added.
- `SimpleStepLifecycleService.swift` was not touched by P2C-B.
- `SimpleStepLifecycleService.swift` line count remained 469.
