# AFEP-005 Golden Explanation Pack

Batch: AFEP-005
Branch: main
Commit: 56aeac85e211fb4075bd01e951ca98a5c043f8b2
Generated at: 2026-06-01T06:17:57Z

## Scope

Deterministic recommendation explanation and counterfactual graph owner updates in:

- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Domain/Planning/PlanningEvaluation.swift`
- `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift`

## Phase 03 Review Repair

- Restored recommendation visible-copy guardrails for banned recommendation/dashboard framing without introducing those phrases as active source literals.
- Normalized planning rank deltas so the selected step reports a positive distance ahead of the alternative rank.
- Reran the wrapper build and focused test evidence after repair.

## Phase 04 Repair

- Repaired the two visible-copy guardrail computed properties so they return their deterministic `contains` result.
- Reran the wrapper build, focused recommendation explanation tests, focused planning domain tests, broader AmbitionsTests wrapper lane, post guard, and diff hygiene after repair.

## Phase 05 Final-Gate Repair

- Repaired the recommendation reason graph so the uncertainty node is included in the returned node set.
- Added regression coverage that every reason-graph edge endpoint resolves to a returned node and that the uncertainty node is present.
- Reran the focused recommendation explanation wrapper lane and diff hygiene after the final-gate repair.

## What This Pack Proves

- Recommendation trace explanations can build deterministic reason graphs with stable node, edge, and diff ordering.
- The new graph and diff records preserve source IDs, receipt IDs, replay trace IDs, runtime snapshot references, and local fit labels.
- Export and privacy hooks remain local-first and redaction-aware.
- The new test coverage avoids opaque AI framing, percentage claims, and "best next move" language.

## Validation Evidence

| Command | State | Notes |
| --- | --- | --- |
| `python3 scripts/ambitions-champion-coverage-check.py` | PASS | Reported `STATUS: GREEN`. |
| `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-005 --prompt prompts/batches/AFEP-005.md` | PASS | Reported `Status: GREEN`. |
| `xcodegen generate` | PASS | Regenerated `Ambitions.xcodeproj`. |
| `make xcode-build-for-testing BATCH=AFEP-005` | PASS after repair | First Phase 04 run failed on missing Bool returns in visible-copy guardrail getters; rerun passed. |
| `make xcode-focused-test BATCH=AFEP-005 TEST=AmbitionsTests/Domain/RecommendationExplanationModelsTests` | PASS | Wrapper validation passed after Phase 04 repair. |
| `make xcode-focused-test BATCH=AFEP-005 TEST=AmbitionsTests/Domain/RecommendationExplanationModelsTests` | PASS | Wrapper validation passed after Phase 05 final-gate repair. |
| `make xcode-focused-test BATCH=AFEP-005 TEST=AmbitionsTests/Domain/PlanningDomainModelsTests` | PASS | Wrapper validation passed after Phase 04 repair. |
| `make xcode-focused-test BATCH=AFEP-005 TEST=AmbitionsTests` | FAIL | Broader lane failed outside the AFEP-005 touched suites: `AmbitionsCommandExecutorTests`, `ReminderNaturalLanguageCaptureParserTests`, `StorageSchemaVersionLedgerTests`, plus a restart/timeout marker near `YouFeatureServiceTests`. |
| `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-005 --prompt prompts/batches/AFEP-005.md --changed-from 56aeac85e211fb4075bd01e951ca98a5c043f8b2` | PASS | Reported `Status: GREEN`. |
| `git diff --check` | PASS | No whitespace or patch-format issues. |

Latest wrapper summaries:

- `.codex/xcode-summaries/AFEP-005/20260601T060224Z/build-for-testing-summary.json` — Phase 04 build-for-testing failed before repair.
- `.codex/xcode-summaries/AFEP-005/20260601T060325Z/build-for-testing-summary.json` — build-for-testing passed after Phase 04 repair.
- `.codex/xcode-summaries/AFEP-005/20260601T060430Z/focused-test-summary.json` — RecommendationExplanationModelsTests focused lane passed after Phase 04 repair.
- `.codex/xcode-summaries/AFEP-005/20260601T060509Z/focused-test-summary.json` — PlanningDomainModelsTests focused lane passed after Phase 04 repair.
- `.codex/xcode-summaries/AFEP-005/20260601T060744Z/focused-test-summary.json` — broader AmbitionsTests lane failed outside the AFEP-005 focused suites.
- `.codex/xcode-summaries/AFEP-005/20260601T061704Z/focused-test-summary.json` — RecommendationExplanationModelsTests focused lane passed after Phase 05 final-gate repair.

## Golden Cases

- Recommendation trace graph ordering is stable after normalization.
- Recommendation trace graph edges reference returned nodes, including the uncertainty node.
- Replay trace IDs and runtime snapshot references round-trip through the graph model.
- Visible copy stays free of confidence theater and generic assistant framing.
- Planning counterfactual diffs remain deterministic and inspectable.

## Known Yellow Items

- Broader `AmbitionsTests` wrapper lane is Yellow/failed outside the AFEP-005 repair boundary; focused AFEP explanation/planning lanes passed.
- AFEP-005 control-plane support includes the runner prompt and concept-lock allowlist entry for the locked concepts touched by this batch.
- No device, accessibility, privacy, performance, CI, TestFlight, or App Store proof was claimed.

## Rollback Notes

- Roll back the source changes with:

```bash
git restore -- Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/Ambitions/Domain/Planning/PlanningEvaluation.swift Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift
```

## Non-Claims

- This pack does not claim release readiness.
- This pack does not claim device or simulator UI proof beyond the wrapper test lanes above.
- This pack does not claim accessibility, privacy, or performance proof.
- This pack does not claim any cloud, backend, analytics, or AI dependency.
