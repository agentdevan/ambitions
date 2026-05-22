<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
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
