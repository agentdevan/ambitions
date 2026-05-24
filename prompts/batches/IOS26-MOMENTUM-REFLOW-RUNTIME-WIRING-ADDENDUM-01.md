<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01`

## Train ID and title
`NON_MANIFEST_IOS26_PROMPT` - Non-manifest IOS26 support prompt

## Batch role in train
Supporting prompt outside manifest batch matrix

## Upstream dependencies
- none

## Downstream dependencies
- none recorded

## Objective
Apply the Momentum Reflow / Step Time Reallocation addendum to the current IOS26 Core Life Operations Foundation installation.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Preserve local-first deterministic behavior. Do not introduce external personal-data, cloud LLM, analytics, tracking, backend SDK, or paid service dependencies.

## Accessibility constraints
Preserve VoiceOver semantics, Dynamic Type, Reduce Motion, Increase Contrast, and 44 pt minimum touch-target expectations where UI is touched. Do not claim accessibility verification without proof.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.

## Allowed files/directories
- Scope is limited to the original prompt intent and the active owner files identified after truth/source inspection.

## Forbidden files/directories
- No cloud dependency.
- No LLM dependency.
- No analytics/tracking SDK.
- No top-level IA changes.
- No release/accessibility/performance/privacy claims without proof.

## Exact implementation steps
1. Re-read active truth files.
2. Inspect only the allowed source and proof areas.
3. Implement the smallest patch that satisfies this sealed work order.
4. Write the required proof artifact.
5. Run validation and report proof honestly.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01 TEST=AmbitionsTests
```

## Proof artifacts to write
- `build/reports/ios26-flagship/<batch-id>.md`


## Green / Yellow / Red gates
Green: sealed objective, validation, and proof artifact pass. Yellow: bounded gap with owner, reason, no-claim boundary, and follow-up gate. Red: missing prompt, boundary violation, failed validation without accepted Yellow, or forbidden dependency/claim.

## Rollback behavior
Rollback only files touched by this batch and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
Status:
Files changed:
Validation run:
Validation not run:
Proof artifacts:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Rollback:

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
