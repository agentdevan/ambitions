# Momentum Reflow Runtime Wiring

Status: Yellow - addendum installed as docs/prompts/control-plane only; runtime implementation and tests are not proven.

Files changed:
- `docs/codex/IOS26_CORE_REPLACEMENT_P0_CONTRACTS.md`
- `docs/codex/IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE.md`
- `docs/codex/IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES.md`
- `prompts/trains/ios26-flagship/TRAIN_04F_TIME_OPERATIONS_CALENDAR_REPLACEMENT.md`
- `prompts/trains/ios26-flagship/TRAIN_04H_PROJECT_STEP_OPERATIONS_TODOIST_THINGS_REPLACEMENT.md`
- `prompts/trains/ios26-flagship/TRAIN_04J_UNIFIED_CAPTURE_SEARCH_COMMAND_OBVIOUSNESS.md`
- `prompts/trains/ios26-flagship/TRAIN_04K_PRIVATE_LIFE_RUNTIME_INTEGRATION_FOUNDATION.md`
- `prompts/batches/IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md`
- `prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md`
- `prompts/batches/IOS26-T04H-B06-project-step-closure-proof-replay.md`
- `prompts/batches/IOS26-T04H-B07-todoist-things-replacement-gauntlet.md`
- `prompts/batches/IOS26-T04J-B02-object-action-engine.md`
- `prompts/batches/IOS26-T04J-B06-command-search-obviousness-gauntlet.md`
- `prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md`
- `prompts/batches/IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md`
- `prompts/batches/IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md`
- `prompts/batches/IOS26-T04K-B07-foundation-and-moat-closeout.md`
- `prompts/batches/IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01.md`
- `build/reports/private-life-runtime-integration/momentum-reflow-runtime-wiring.md`

Momentum Reflow objects:
- Contract definitions added for MomentumReflowCandidate, MomentumReflowDecision, StepReallocationEvent, and PersonalRuntimeLearningSignal.

Time wiring:
- T04F train and batch prompts now require user-approved reassignment, protected-time review, conflict/pressure recalculation, displaced Step pressure display, and receipt-linked schedule impact.

Step/Goal wiring:
- T04H train and batch prompts now require explicit original Step disposition, explicit destination Step continuation, both GoalThread state updates, proof opportunity transfer, coherent displaced Step state, and no stale carryover.

Receipt wiring:
- The P0 contract and T04F/T04H/T04K prompts require receipt creation that links original Step, destination Step, scheduled block, approved duration, disposition, deadline policy, pressure impact, proof impact, and schedule impact.

Replay wiring:
- The P0 contract and T04K prompts require replay traces and deterministic replay of recommendation impact unless source state changed.

Source ledger wiring:
- T04K source-adapter prompt now requires StepReallocationEvent to feed runtime source adapters with timeContext, momentumContext, pressureImpact, and proofImpact.

Runtime learning signal:
- T04K train and batch prompts require PersonalRuntimeLearningSignal with signalType `momentum_reflow`, future ranking impact, bounded confidence state, and disable/reset/delete controls.

You / What Ambitions knows wiring:
- T04K personal operating model prompt now requires the learned momentum signal to be inspectable in You / What Ambitions knows and export/delete/reset-controlled.

Tests:
- Contract fixture catalog added at `docs/codex/IOS26_MOMENTUM_REFLOW_CONTRACT_FIXTURES.md` for scenarios A through F.
- Fixture requirements were wired into T04F, T04H, T04J, and T04K prompts.
- No Swift/XCTest implementation was added in this addendum install.
- No current test logs prove Momentum Reflow runtime behavior.

Proof artifact:
- This file is the required addendum install proof artifact.
- It is not implementation proof.

Claims allowed:
- Momentum Reflow runtime wiring requirements are installed in docs/prompts/control-plane material.
- Future implementation batches have contract fixtures and prompt requirements for Time, Step/Goal, object actions, runtime learning, You inspection, reset/delete, receipt, replay, and future ranking impact.

Claims forbidden:
- Momentum Reflow is implemented.
- Momentum Reflow affects current future recommendation ranking.
- Momentum Reflow is currently inspectable/resettable in the app.
- Momentum Reflow XCTest coverage exists.
- Time, Step/Goal, receipt, replay, source ledger, runtime learning, You, export/delete, accessibility, performance, privacy approval, release readiness, TestFlight readiness, or App Store readiness is proven by this addendum.

Yellow/Red items:
- Yellow: docs/prompts/control-plane addendum is installed, but runtime source, app UI, Swift tests, and current validation logs are not present for this behavior.
- Hard Red for future closeout: do not close Green unless Momentum Reflow affects future Private Life Runtime recommendation ranking and is inspectable/resettable.
