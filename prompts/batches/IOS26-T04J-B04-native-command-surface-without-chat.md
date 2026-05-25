<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04J-B04 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04J-B04`

## Train ID and title
`TRAIN_04J` - Unified Capture Search Command and Obviousness

## Batch role in train
Batch 4 of 6 in TRAIN_04J

## Upstream dependencies
- `TRAIN_04F`
- `TRAIN_04G`
- `TRAIN_04H`
- `TRAIN_04I`

## Downstream dependencies
- `TRAIN_04K`

## Objective
Use assistant-like commands without chatbot UI.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
No cloud LLM, no hosted personal-data backend, no external analytics, no sensitive silent use, no sensitive logs, user-controlled source use, and local-first replay.

## Accessibility constraints
VoiceOver labels/order, Dynamic Type, Reduce Motion, Increase Contrast, non-color-only state, and minimum tap target expectations must be preserved for any surfaced state. Do not claim accessibility verification without current proof.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- Command/search/capture work must extend `capture_root`, `private_life_runtime`, `proof_receipt_replay`, and `you_root` as applicable; do not introduce chatbot, assistant, or parallel command intelligence owners.

## Allowed files/directories
- Add or update only the source, tests, fixtures, prompts, validators, and proof artifacts needed for this batch.
- Preserve `Today / Goals / Capture / Time / You` and Ambitions-native object language.
- Keep proof artifacts under `build/reports/life-command-search/`.

## Forbidden files/directories
- No sixth top-level tab.
- No Assistant, Dashboard, Calendar, Plan, Inbox, Review, or Profile top-level IA.
- No chat-first UI.
- No cloud LLM or hosted personal-data backend.
- No external analytics dependency.
- No silent schedule mutation, sensitive silent use, weak forced match, or unreceipted material mutation.
- No release, App Store, accessibility, privacy, or performance claim without current proof.

## Exact implementation steps
Use assistant-like commands without chatbot UI. Implement only the scoped local-first behavior after inspecting current source, then prove it with focused tests and proof artifacts.

## Validation commands
```bash
python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04J-B04
python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04J-B04
```
Inspect `Makefile` and `scripts/` for the current supported focused Xcode validation pattern before running app tests. Use existing repo validation commands only.

## Proof artifacts to write
- `build/reports/life-command-search/native-command-surface-without-chat.md`
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: Native command tests pass.
Yellow: bounded gap with owner, reason, no-claim boundary, validation posture, and post-batch gate.
Red: Command surface becomes chat-first or top-level Assistant UI.

## Rollback behavior
Revert only files touched by `IOS26-T04J-B04`. Preserve unrelated dirty work and generated artifacts outside this batch.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04J-B04 - Native command surface without chat

## Batch type
Implementation batch.

## Objective
Use assistant-like commands without chatbot UI.

## End-user job being replaced
Native command job.

## Replacement P0 contract
Command surface contract: native overlay/sheet, accessible, not top-level tab, maps commands to object actions, no assistant persona, no chat transcript.

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
Use assistant-like commands without chatbot UI. Implement only the scoped local-first behavior after inspecting current source, then prove it with focused tests and proof artifacts.

## Required tests
- Focused deterministic tests for the contract above.
- Scenario coverage sufficient for this batch's P0 gate.
- Claim-boundary scan proving no forbidden broad claim escaped.
- Regression tests for receipt/replay/privacy boundaries where behavior changes.

## Commands to run
```bash
python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04J-B04
python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04J-B04
```
Inspect `Makefile` and `scripts/` for the current supported focused Xcode validation pattern before running app tests. Use existing repo validation commands only.

## Required proof artifacts
- `build/reports/life-command-search/native-command-surface-without-chat.md`

## Accessibility requirements
VoiceOver labels/order, Dynamic Type, Reduce Motion, Increase Contrast, non-color-only state, and minimum tap target expectations must be preserved for any surfaced state. Do not claim accessibility verification without current proof.

## Privacy/local-first requirements
No cloud LLM, no hosted personal-data backend, no external analytics, no sensitive silent use, no sensitive logs, user-controlled source use, and local-first replay.

## Performance requirements
Record local latency, power, memory, and scaling expectations for this batch. Do not claim performance validation without measurements.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified locally and recorded in the proof artifact. If no new iOS 26 API is used, state that explicitly.

## Green / Yellow / Red closeout rules
Green: Native command tests pass.
Yellow: bounded gap with owner, reason, no-claim boundary, validation posture, and post-batch gate.
Red: Command surface becomes chat-first or top-level Assistant UI.

## Rollback strategy
Revert only files touched by `IOS26-T04J-B04`. Preserve unrelated dirty work and generated artifacts outside this batch.

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
----- END ORIGINAL PROMPT -----
