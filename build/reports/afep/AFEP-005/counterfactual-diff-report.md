# AFEP-005 Counterfactual Diff Report

Batch: AFEP-005
Branch: main
Commit: 56aeac85e211fb4075bd01e951ca98a5c043f8b2
Generated at: 2026-06-01T06:17:57Z

## Scope

Planning and recommendation counterfactual records added alongside the existing owner seams.

## What Changed

- Added deterministic recommendation reason graph types with explicit source, receipt, replay trace, runtime snapshot, and local fit references.
- Added recommendation counterfactual diff records with local-only export/privacy hooks.
- Added planning counterfactual diff records for selected-step versus alternative-step comparisons.
- Added tests that prove ordering, identifier normalization, export safety, and no opaque AI-confidence framing.

## Phase 03 Review Repair

- Restored visible-copy banned-framing checks in the new recommendation graph path.
- Repaired planning rank delta direction so selected-vs-alternative diffs report a positive selected-ahead distance.
- Reran wrapper build, focused tests, post guard, and diff hygiene after repair.

## Phase 04 Repair

- Repaired missing Bool returns in the recommendation reason graph and trust seam visible-copy guardrail getters.
- Reran wrapper build, focused recommendation explanation tests, focused planning domain tests, broader AmbitionsTests wrapper lane, post guard, and diff hygiene after repair.

## Phase 05 Final-Gate Repair

- Repaired an orphan-edge defect by including the uncertainty node in the returned recommendation reason graph.
- Added regression coverage that every reason-graph edge endpoint resolves to a returned node and that the uncertainty node is present.
- Reran the focused recommendation explanation wrapper lane and diff hygiene after the final-gate repair.

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

## Diff Behavior

- Source IDs, receipt IDs, replay trace IDs, runtime snapshot references, and local fit labels are normalized and sorted.
- Node, edge, and diff identifiers are stable and deterministic.
- Reason-graph edge endpoints resolve to returned graph nodes, including the uncertainty node.
- Export hooks remain redaction-aware and local-first.
- Visible copy guardrails reject confidence theater and assistant framing.

## Known Yellow Items

- Broader `AmbitionsTests` wrapper lane is Yellow/failed outside the AFEP-005 repair boundary; focused AFEP explanation/planning lanes passed.
- AFEP-005 control-plane support includes the runner prompt and concept-lock allowlist entry for the locked concepts touched by this batch.

## Rollback Notes

- Roll back the source changes with:

```bash
git restore -- Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/Ambitions/Domain/Planning/PlanningEvaluation.swift Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift
```

## Non-Claims

- No release, device, accessibility, privacy, or performance proof is claimed here.
- No cloud AI, backend account, analytics, or hosted inference dependency was added.
- No claim is made about full planner coverage beyond the exact focused lanes above.
