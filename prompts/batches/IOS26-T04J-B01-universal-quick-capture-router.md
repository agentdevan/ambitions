<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04J-B01 - Universal quick capture router

## Batch type
Implementation batch.

## Objective
Capture anything without deciding old app category.

## End-user job being replaced
Unified capture-anything job.

## Replacement P0 contract
Unified capture contract: route to ScheduledBlock, ReminderTrigger, Commitment, Step, GoalThread, ContextEntry, Proof, SourceRecord, Reflection, Held, Needs a Place, Ready to Place; ambiguity review; no cloud LLM; no silent mutation.

## Why this exists
This batch advances the replacement floor without copying old app UI. It keeps Ambitions-native objects, local receipts, proof, replay, and user-controlled source use as the implementation standard.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. Required prior proof must be inspected before claiming Green. Manifest status is installation state, not execution proof.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
Native/Ambitions/Features/Capture; search/command/action surfaces; Today/Goals/Time/You; Native/AmbitionsTests; Native/AmbitionsUITests; build/reports/life-command-search/.
Inspect these paths before inventing new paths, and record any missing or renamed source area in the final report.

## Exact changes allowed
- Add or update only the source, tests, fixtures, prompts, validators, and proof artifacts needed for this batch.
- Preserve `Today / Goals / Capture / Time / You` and Ambitions-native object language.
- Keep proof artifacts under `build/reports/life-command-search/`.

## Exact changes forbidden
- No sixth top-level tab.
- No Assistant, Dashboard, Calendar, Plan, Inbox, Review, or Profile top-level IA.
- No chat-first UI.
- No cloud LLM or hosted personal-data backend.
- No external analytics dependency.
- No silent schedule mutation, sensitive silent use, weak forced match, or unreceipted material mutation.
- No release, App Store, accessibility, privacy, or performance claim without current proof.

## Required implementation behavior
Capture anything without deciding old app category. Implement only the scoped local-first behavior after inspecting current source, then prove it with focused tests and proof artifacts.

## Required tests
- Focused deterministic tests for the contract above.
- Scenario coverage sufficient for this batch's P0 gate.
- Claim-boundary scan proving no forbidden broad claim escaped.
- Regression tests for receipt/replay/privacy boundaries where behavior changes.

## Commands to run
```bash
python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04J-B01
python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04J-B01
```
Inspect `Makefile` and `scripts/` for the current supported focused Xcode validation pattern before running app tests. Use existing repo validation commands only.

## Required proof artifacts
- `build/reports/life-command-search/universal-quick-capture-router.md`

## Accessibility requirements
VoiceOver labels/order, Dynamic Type, Reduce Motion, Increase Contrast, non-color-only state, and minimum tap target expectations must be preserved for any surfaced state. Do not claim accessibility verification without current proof.

## Privacy/local-first requirements
No cloud LLM, no hosted personal-data backend, no external analytics, no sensitive silent use, no sensitive logs, user-controlled source use, and local-first replay.

## Performance requirements
Record local latency, power, memory, and scaling expectations for this batch. Do not claim performance validation without measurements.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified locally and recorded in the proof artifact. If no new iOS 26 API is used, state that explicitly.

## Green / Yellow / Red closeout rules
Green: Router candidates pass.
Yellow: bounded gap with owner, reason, no-claim boundary, validation posture, and post-batch gate.
Red: Capture silently mutates or requires cloud LLM.

## Rollback strategy
Revert only files touched by `IOS26-T04J-B01`. Preserve unrelated dirty work and generated artifacts outside this batch.

## Final report format
```text
Status: Green / Yellow / Red
Files changed:
End-user job:
Replacement app floor:
P0 contract status:
Implementation behavior:
Tests run:
Validation not run:
Proof artifacts:
Accessibility status:
Privacy/local-first status:
Performance status:
Claims allowed:
Claims forbidden:
Yellow items:
Red items:
Next batch:
```
