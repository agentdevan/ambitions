<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B05 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04D-B05`

## Train ID and title
`TRAIN_04D` - Capture-to-Runtime Factoring & Future Proof Bridge

## Batch role in train
Batch 5 of 7 in TRAIN_04D

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
Make capture factoring receipt-backed, replayable, and correctable.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Receipts and replay remain local-first. Sensitive details require redaction in external surfaces and logs.

## Accessibility constraints
Receipts, replay, correction controls, and undo availability must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

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
- Add or connect `CaptureRuntimeReceipt`.
- Add receipt types: captureExtracted, captureNeedsClarification, captureMatchedGoal, captureWeakMatchRejected, captureSavedAsFutureContext, captureProposedForTime, captureAddedToTime, captureAttachedToGoal, captureSavedAsProof, captureRuntimeUsePaused, captureCorrectionApplied, captureReplayGenerated.
- Make replay reconstruct raw capture, extraction, ambiguity, relevance scan, proposed destinations, user decision, runtime use status, receipt, and future use.
- Add correction paths for wrong activity/time/goal, do not use for planning, save only as note, attach to different goal, and delete context.
- Add tests and `build/reports/capture-runtime-bridge/receipts-replay-corrections.md`.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no unredacted sensitive details in external surfaces
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect receipt, replay, correction, and privacy redaction seams.
3. Define capture runtime receipt contract and receipt event taxonomy.
4. Add deterministic replay trace reconstruction.
5. Add correction paths that update future routing.
6. Add privacy redaction for sensitive external surfaces.
7. Prove users can prevent future runtime use.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/capture-runtime-bridge/receipts-replay-corrections.md`
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
- `build/reports/frontend-object-purity/`
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
Green: receipts exist; replay is deterministic; corrections change future routing; user can prevent future use; sensitive details are redacted externally.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no receipt, no replay, no correction path, or sensitive details leak.

## Rollback behavior
Rollback only files touched by IOS26-T04D-B05 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Receipts proof:
Replay proof:
Correction proof:
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
# IOS26-T04D-B05 - Receipts, replay, corrections

## Objective
Make capture factoring receipt-backed, replayable, and correctable.

## Why this exists
Capture factoring changes what Ambitions may use later. Every material detection, proposal, attachment, future-use decision, pause, correction, and replay must be inspectable and reversible enough to preserve trust.

## Dependencies
IOS26-T04D-B01, IOS26-T04D-B02, IOS26-T04D-B03, IOS26-T04D-B04, TRAIN_10 receipt/replay assumptions, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Add or connect `CaptureRuntimeReceipt`.
- Add receipt types: captureExtracted, captureNeedsClarification, captureMatchedGoal, captureWeakMatchRejected, captureSavedAsFutureContext, captureProposedForTime, captureAddedToTime, captureAttachedToGoal, captureSavedAsProof, captureRuntimeUsePaused, captureCorrectionApplied, captureReplayGenerated.
- Make replay reconstruct raw capture, extraction, ambiguity, relevance scan, proposed destinations, user decision, runtime use status, receipt, and future use.
- Add correction paths for wrong activity/time/goal, do not use for planning, save only as note, attach to different goal, and delete context.
- Add tests and `build/reports/capture-runtime-bridge/receipts-replay-corrections.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no unredacted sensitive details in external surfaces
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Required runtime objects
`CaptureRuntimeReceipt` fields:
- whatWasCaptured
- whatWasDetected
- whereItWent
- whatItMayAffect
- whatWasNotUsed
- whyApprovalWasNeeded
- timestamp
- privacyRedactions
- undoAvailability

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect receipt, replay, correction, and privacy redaction seams.
3. Define capture runtime receipt contract and receipt event taxonomy.
4. Add deterministic replay trace reconstruction.
5. Add correction paths that update future routing.
6. Add privacy redaction for sensitive external surfaces.
7. Prove users can prevent future runtime use.

## Tests to add/update
- Required receipt events exist.
- Replay reconstructs raw capture, extraction, ambiguity, relevance, proposals, decisions, runtime-use status, receipt, and future use.
- Wrong activity correction changes future routing.
- Wrong time correction changes future routing.
- Wrong goal match correction changes future routing.
- Do not use this for planning prevents future planning use.
- Save only as note preserves capture without runtime use.
- Attach to different goal updates relevance memory.
- Delete context stops future use.
- Sensitive details are redacted in external surfaces.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/receipts-replay-corrections.md`

## Accessibility requirements
Receipts, replay, correction controls, and undo availability must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Privacy/local-first requirements
Receipts and replay remain local-first. Sensitive details require redaction in external surfaces and logs.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against the deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: receipts exist; replay is deterministic; corrections change future routing; user can prevent future use; sensitive details are redacted externally.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no receipt, no replay, no correction path, or sensitive details leak.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B05 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Receipts proof:
Replay proof:
Correction proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
