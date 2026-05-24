<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01

## Objective
Apply the Momentum Reflow / Step Time Reallocation addendum to the current IOS26 Core Life Operations Foundation installation.

## Product requirement
A user must be able to move planned time from one Step to another active or recently active Step when real-life momentum makes that better. Ambitions must preserve the displaced goal, update the continued goal, record a receipt, replay the decision, create a local runtime learning signal, adapt future recommendations, expose the signal in You / What Ambitions knows, and let the user reset/delete/disable it.

## Required docs/prompts
- Add Momentum Reflow / Step Time Reallocation P0 Contract to `docs/codex/IOS26_CORE_REPLACEMENT_P0_CONTRACTS.md`.
- Add MomentumReflowCandidate, MomentumReflowDecision, StepReallocationEvent, and PersonalRuntimeLearningSignal definitions to `docs/codex/IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE.md`.
- Add Time / LifeShape Field requirements to TRAIN_04F.
- Add Commitment/Step/GoalThread requirements to TRAIN_04H.
- Add object-action requirements to TRAIN_04J.
- Add runtime learning-source requirements to TRAIN_04K.
- Add contract fixtures for scenarios A through F.
- Add required proof artifact `build/reports/private-life-runtime-integration/momentum-reflow-runtime-wiring.md`.

## Required fixture scenarios
- Scenario A: Workout planned at 6 PM. Music Step recently active. User reallocates workout time to music. Fitness goal remains active. Music Step gains proof opportunity. Future Start Here considers creative momentum preference.
- Scenario B: Workout deadline is high pressure. User attempts to reallocate. Ambitions allows it only after showing deadline impact.
- Scenario C: Original Step is protected/health-related/sensitive. Ambitions requires review and does not infer medical advice.
- Scenario D: User resets learned momentum preference. Future recommendations stop using that signal.
- Scenario E: Replay after relaunch restores same reflow receipt and recommendation impact.
- Scenario F: Export/delete removes learning signal and related source according to user choice.

## Hard Red
Do not close Green unless Momentum Reflow affects future Private Life Runtime recommendation ranking and is inspectable/resettable.

## No-claim boundary
This addendum install does not prove runtime implementation, tests, app UI behavior, recommendation ranking behavior, accessibility, privacy approval, performance, release readiness, TestFlight readiness, or App Store readiness.
