<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B06 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04D-B06`

## Train ID and title
`TRAIN_04D` - Capture-to-Runtime Factoring & Future Proof Bridge

## Batch role in train
Batch 6 of 7 in TRAIN_04D

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`
- `TRAIN_04C`

## Downstream dependencies
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_08`

## Objective
Prove capture factoring across realistic inputs.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Scenario output must avoid sensitive logs, remain local, and prove no cloud/LLM dependency.

## Accessibility constraints
Accessibility is not proven by the gauntlet alone. Any surfaced scenario states must preserve VoiceOver-readable labels, Dynamic Type-safe copy, Reduce Motion-safe paths, and non-color-only status.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `capture_root` owns Capture parser/routing/SmartAttachment work under `Native/Ambitions/Features/Capture`, `Native/Ambitions/Services/CaptureService.swift`, and `Native/Ambitions/Services/SmartAttachmentService.swift`.
- Champion Merge Yellow: broad Capture runtime gauntlet remains unproven; do not claim full Capture runtime consolidation until that gate is Green or owner-accepted.

## Allowed files/directories
- Add at least 150 deterministic capture scenarios.
- Cover scheduled activities, proof events, facility/access facts, equipment facts, blockers, recovery/injury notes, social/support context, recurring commitments, ambiguous time, ambiguous goal relevance, no current goal but future useful context, high-risk/sensitive context, plan conflict, protected time conflict, user correction, paused/deleted context, and replay.
- Add scenario runner/reporting if needed under existing local test/report patterns.
- Add `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md` and deterministic scenario output.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no broad claim unless Green
- no App Store/privacy/accessibility overclaims

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect all prior T04D proof artifacts and test surfaces.
3. Build or extend deterministic scenario fixtures.
4. Add at least 150 scenarios across all required categories.
5. Emit scenario output and Red/Yellow/Green summary.
6. List failing scenarios explicitly.
7. Block broad claims unless all required assertions are Green.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04D-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B06 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md`
- Deterministic scenario output under `build/reports/capture-runtime-bridge/`
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
Green: gauntlet report exists; deterministic output exists; Red/Yellow/Green summary exists; every required assertion passes; no broad claim before Green.
Yellow: bounded failing scenario list with owner, reason, no-claim boundary, and gate.
Red: no deterministic gauntlet, silent mutation/use appears, weak match is forced, capture is lost, or cloud/LLM dependency is added.

## Rollback behavior
Rollback only files touched by IOS26-T04D-B06 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Gauntlet scenario count:
Gauntlet proof:
Failing scenarios:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04D-B06 - Capture runtime gauntlet

## Objective
Prove capture factoring across realistic inputs.

## Why this exists
Capture-to-runtime factoring is not credible from a few happy paths. Ambitions must prove at least 150 deterministic scenarios spanning scheduled activities, proof, context, ambiguity, sensitivity, correction, replay, protected time, future use, and no cloud/LLM dependency.

## Dependencies
IOS26-T04D-B01, IOS26-T04D-B02, IOS26-T04D-B03, IOS26-T04D-B04, IOS26-T04D-B05, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Captures/`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
- Runtime
- Goal compiler
- Recommendation engine
- Source Atlas runtime bridge
- Life Context
- Time
- Goals
- Today
- You
- Persistence
- Receipts
- Replay
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- Preview fixtures

## Exact changes allowed
- Add at least 150 deterministic capture scenarios.
- Cover scheduled activities, proof events, facility/access facts, equipment facts, blockers, recovery/injury notes, social/support context, recurring commitments, ambiguous time, ambiguous goal relevance, no current goal but future useful context, high-risk/sensitive context, plan conflict, protected time conflict, user correction, paused/deleted context, and replay.
- Add scenario runner/reporting if needed under existing local test/report patterns.
- Add `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md` and deterministic scenario output.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no broad claim unless Green
- no App Store/privacy/accessibility overclaims

## Additive Core Replacement Foundation Bridge
T04D-B06 must recognize that Capture is the entry point for replacing the five app job families through Ambitions-native objects. This is an additive requirement and must not break active T04D-B06 work.

Capture outputs to include:
- ScheduledBlockCandidate
- ReminderTriggerCandidate
- CommitmentCandidate
- StepCandidate
- GoalThreadCandidate
- ContextEntryCandidate
- CollectionCandidate
- ProofCandidate
- SourceRecordCandidate
- ReflectionCandidate
- HeldItemCandidate
- NeedsAPlace
- ReadyToPlace

Scenario categories to add:
- event/schedule capture
- reminder capture
- project/task capture
- note/reference capture
- proof capture
- relation capture
- template-worthy repeated capture
- protected-time capture
- recurring commitment capture
- sensitive context capture
- future-use context capture
- ambiguous capture
- correction capture
- replay capture

Additional Red conditions:
- Capture can only create inbox text.
- Capture cannot produce reviewable candidates for replacement foundation objects.
- Capture silently forces weak match.
- Capture schedules silently.
- Capture uses sensitive context silently.
- Capture cannot produce SourceRecord.

Downstream handoff:
- T04E contract harness consumes capture fixture categories.
- T04F consumes ScheduledBlockCandidate.
- T04G consumes ReminderTriggerCandidate.
- T04H consumes Commitment/Step/GoalThread candidates.
- T04I consumes ContextEntry/Collection/Template/Relation candidates.
- T04J consumes capture/search/command routing.
- T04K consumes SourceRecord and runtime adapter outputs.

## Required scenario assertions
- Every capture is preserved.
- Useful captures are factored or held for review.
- No weak match is forced.
- No scheduled item is silently committed.
- No sensitive fact is silently used.
- Every material decision has receipt.
- Replay is deterministic.
- Future context can be queried by later goals.
- No cloud/LLM dependency exists.

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect all prior T04D proof artifacts and test surfaces.
3. Build or extend deterministic scenario fixtures.
4. Add at least 150 scenarios across all required categories.
5. Emit scenario output and Red/Yellow/Green summary.
6. List failing scenarios explicitly.
7. Block broad claims unless all required assertions are Green.

## Tests to add/update
- Deterministic gauntlet has at least 150 scenarios.
- Scenario categories cover the full required list.
- Required assertions are enforced.
- Red/Yellow/Green summary exists.
- Failing scenarios are listed if any.
- No cloud/LLM dependency is introduced.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B06 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md`
- Deterministic scenario output under `build/reports/capture-runtime-bridge/`

## Accessibility requirements
Accessibility is not proven by the gauntlet alone. Any surfaced scenario states must preserve VoiceOver-readable labels, Dynamic Type-safe copy, Reduce Motion-safe paths, and non-color-only status.

## Privacy/local-first requirements
Scenario output must avoid sensitive logs, remain local, and prove no cloud/LLM dependency.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against the deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: gauntlet report exists; deterministic output exists; Red/Yellow/Green summary exists; every required assertion passes; no broad claim before Green.
Yellow: bounded failing scenario list with owner, reason, no-claim boundary, and gate.
Red: no deterministic gauntlet, silent mutation/use appears, weak match is forced, capture is lost, or cloud/LLM dependency is added.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B06 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Gauntlet scenario count:
Gauntlet proof:
Failing scenarios:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
