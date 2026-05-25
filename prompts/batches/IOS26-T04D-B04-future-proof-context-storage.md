<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B04 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04D-B04`

## Train ID and title
`TRAIN_04D` - Capture-to-Runtime Factoring & Future Proof Bridge

## Batch role in train
Batch 4 of 7 in TRAIN_04D

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
Make unmatched captures valuable for future goals and runtime planning.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Future context remains local-first. Sensitive context requires review before runtime use and must support pause/delete/edit controls.

## Accessibility constraints
Context visibility and controls in You must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

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
- Add or connect `FutureProofContextCandidate`.
- Classify future use for no-match or standalone captures.
- Store activity history, facility/access, equipment/access, blocker, opportunity, recovery, recurring commitment, life context, historical context, and goal seed candidates.
- Expose review controls through You -> What Ambitions Knows where available.
- Mark freshness, source, sensitivity, runtime-use status, and deletion support.
- Add tests and `build/reports/capture-runtime-bridge/future-proof-context-storage.md`.

## Forbidden files/directories
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

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect Life Context, You inspection controls, persistence, and runtime query seams.
3. Define future context candidate and factoring candidate contracts.
4. Classify unmatched useful captures without forcing current goal attachment.
5. Require review before sensitive runtime use.
6. Ensure paused/deleted context stops affecting runtime.
7. Add query tests showing later goals can use allowed context.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04D-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B04 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/capture-runtime-bridge/future-proof-context-storage.md`
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
Green: unmatched useful captures persist; future goals can query allowed context; sensitive context is review-gated; pause/delete stops runtime use; context is visible in You.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: unmatched useful captures disappear, sensitive context is used silently, or stored context is not queryable later.

## Rollback behavior
Rollback only files touched by IOS26-T04D-B04 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
