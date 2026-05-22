<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B04 - Future proof context storage

## Objective
Make unmatched captures valuable for future goals and runtime planning.

## Why this exists
If a capture does not match a current goal, Ambitions should still preserve useful context for future runtime use while making that context visible, reviewable, editable, pausable, and deletable.

## Dependencies
IOS26-T04D-B01, IOS26-T04D-B02, IOS26-T04D-B03, TRAIN_04A, TRAIN_04C, TRAIN_09 inspection assumptions, TRAIN_11 persistence assumptions, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Add or connect `FutureProofContextCandidate`.
- Classify future use for no-match or standalone captures.
- Store activity history, facility/access, equipment/access, blocker, opportunity, recovery, recurring commitment, life context, historical context, and goal seed candidates.
- Expose review controls through You -> What Ambitions Knows where available.
- Mark freshness, source, sensitivity, runtime-use status, and deletion support.
- Add tests and `build/reports/capture-runtime-bridge/future-proof-context-storage.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no sensitive runtime use without review
- no silent goal attachment
- no silent schedule mutation
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Required runtime objects
`CaptureRuntimeFactoringCandidate` fields:
- captureID
- candidateType: step / scheduledActivity / proof / lifeContext / historicalContext / facilityAccess / equipmentAccess / blocker / opportunity / recovery / recurringCommitment / goalSeed / decideLater
- suggestedDestination
- runtimeUseAllowed
- requiresApproval
- sourceFreshness
- sensitivity
- reason
- rejectedReason optional

`FutureProofContextCandidate` fields:
- captureID
- contextCategory
- potentialFutureUses
- sourceLabel
- freshness
- reviewNeeded
- runtimeUseAllowed
- visibleInYou
- deletionSupported

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect Life Context, You inspection controls, persistence, and runtime query seams.
3. Define future context candidate and factoring candidate contracts.
4. Classify unmatched useful captures without forcing current goal attachment.
5. Require review before sensitive runtime use.
6. Ensure paused/deleted context stops affecting runtime.
7. Add query tests showing later goals can use allowed context.

## Tests to add/update
- Pickleball becomes activity history / fitness/social context.
- YMCA open court becomes facility access.
- Mountain bike trail closed becomes local opportunity/access constraint.
- Ankle hurt becomes health/recovery constraint requiring review.
- Worked late again becomes schedule drift / capacity signal.
- Guitar lesson weekly becomes recurring commitment / skill context.
- Unmatched useful captures do not disappear.
- Future goals can query stored context.
- Sensitive context is review-gated.
- Paused/deleted context stops affecting runtime.
- Context is visible in You.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B04 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/future-proof-context-storage.md`

## Accessibility requirements
Context visibility and controls in You must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Privacy/local-first requirements
Future context remains local-first. Sensitive context requires review before runtime use and must support pause/delete/edit controls.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against the deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: unmatched useful captures persist; future goals can query allowed context; sensitive context is review-gated; pause/delete stops runtime use; context is visible in You.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: unmatched useful captures disappear, sensitive context is used silently, or stored context is not queryable later.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B04 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Future context proof:
You visibility proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
