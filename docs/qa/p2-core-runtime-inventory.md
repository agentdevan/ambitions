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

- Canonical owner: `Native/Ambitions/Core/Runtime/ProtectedStepPlacementPolicy.swift`.
- Command preflight hook: `Native/Ambitions/Core/Runtime/PolicyGuardedCommandExecutor.swift`.
- Test owner: `Native/AmbitionsTests/Runtime/ProtectedStepPlacementPolicyTests.swift` and `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift`.
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
- Canonical owner touched: `Core/Runtime`.
- Test owner touched: `Native/AmbitionsTests/Runtime` and existing executor tests.
- `Features/` was not expanded.
- `SimpleStepLifecycleService.swift` was not edited and remains at 807 lines.
- Compatibility debt: command preflight covers schedule/placement commands with step placement metadata; broader scheduling/projection centralization remains a future P2 repair train.

## P2B-A Central Apply-Path Consolidation Addendum

Date: 2026-06-25
Baseline SHA: `dc25c6bad15de86dac5ad5da36aa7e1862488002`
Current source baseline inspected: `6b24af43e0761415413565d930fba0198f11f503`
Phase status: focused validation passed; broader apply-path consolidation remains scoped to the rendered Time placement path and existing P2A command preflight.

### Scope

P2B-A routes the rendered Time placement apply path through the existing protected-placement policy before any Time/Today mutation is produced. It does not add rendered approval UI, full Make Room, Add with conflict, Future Steps, Life Capital, account/R2 behavior, Source Atlas app behavior, Visual Green, Release Green, or device readiness.

### Source Changed

- `Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift`
- `Native/Ambitions/Core/Runtime/ProtectedStepPlacementPolicy.swift`
- `Native/AmbitionsTests/Time/TimeFieldMutationCoordinatorTests.swift`

### Apply-Path Proof Added

- `TimeFieldMutationCoordinator.perform(.placeStep)` now creates placement metadata for the selected Time bucket, including proposed start/end, duration, trigger, and explicit approval state.
- The coordinator evaluates the command with `ProtectedStepPlacementPolicy` before constructing `TimeMutation` or `RuntimeMutation`.
- Automatic Time placement inside the next seven days returns a protected-placement decision and does not mutate the Time surface.
- User-initiated Time placement without explicit approval returns `requires_explicit_approval` and does not mutate the Time surface.
- Normal rendered Time placement remains user-initiated and explicit by default, preserving the existing `Place Step` button behavior until P2B-B renders the review path.
- Explicit approval metadata now overrides the prior user-actor fallback, so a user-initiated protected placement with `explicitUserApproval=false` returns review-required instead of silently applying.

### Validation

- `scripts/ambitions-xcode-test-focused.sh --batch P2B_A_TIME_COORDINATOR_RERUN --test AmbitionsTests/TimeFieldMutationCoordinatorTests --timeout 15m --kill-after 60s` passed: 11 tests, 0 failures.
- Earlier `P2B_A_TIME_COORDINATOR` run failed once before the explicit-approval override was patched: `testP2BAUserTimePlacementInsideSevenDaysRequiresExplicitApprovalBeforeMutation`.

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
- Broader scheduling centralization outside the scoped rendered Time coordinator and existing command preflight remains future P2 work.

### Architecture Notes

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Projection/Mutations`, `Core/Runtime`, and `Native/AmbitionsTests/Time`.
- Non-canonical owners touched: none.
- `Features/` was not expanded.
- No second protected-placement policy or executor was introduced.
- `SimpleStepLifecycleService.swift` was not touched by P2B-A.
