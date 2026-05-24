<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B02 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04D-B02`

## Train ID and title
`TRAIN_04D` - Capture-to-Runtime Factoring & Future Proof Bridge

## Batch role in train
Batch 2 of 7 in TRAIN_04D

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
Scan existing goals and determine whether a capture should attach, suggest, or stay standalone.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Goal relevance scanning remains local-first. Sensitive context requires review before runtime use and must not appear in logs/external surfaces.

## Accessibility constraints
Goal relevance explanations and approval controls must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Allowed files/directories
- Add or connect `GoalRelevanceScan`.
- Compare extraction domain hints to existing goals.
- Use Source Atlas bridge from TRAIN_04C when available.
- Use Life Context from TRAIN_04A where relevant.
- Use PersonalizationFactorLedger from T04A-B06 where relevant.
- Rank high/medium/weak/rejected matches with reasons.
- Add correction learning where source evidence supports it.
- Add tests and `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no weak-match forced attachment
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect goal models, goal compiler inputs, Smart Attachment placement, Source Atlas bridge, and Life Context seams.
3. Define relevance scan contracts and confidence bands.
4. Rank high/medium/weak/rejected matches with explanations.
5. Require user review for attachment.
6. Save weak/no-match captures as standalone or future context candidates where useful.
7. Add correction scenarios that affect later ranking.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04D-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B02 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`
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
Green: high confidence suggestion works with approval; weak matches do not attach; no-match captures remain useful; explanations exist; correction affects future ranking.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: weak match is forced, goal attachment happens silently, or relevance is unexplainable.

## Rollback behavior
Rollback only files touched by IOS26-T04D-B02 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Goal relevance proof:
Forced-attachment block proof:
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
# IOS26-T04D-B02 - Goal relevance scanner

## Objective
Scan existing goals and determine whether a capture should attach, suggest, or stay standalone.

## Why this exists
Capture factoring is unsafe if it forces weak matches into goals. Ambitions must compare extracted meaning against local goal context, explain relevance, ask for user approval, and preserve unmatched captures as useful future context.

## Dependencies
IOS26-T04D-B01, TRAIN_03, TRAIN_04, TRAIN_04A, TRAIN_04B, TRAIN_04C, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Add or connect `GoalRelevanceScan`.
- Compare extraction domain hints to existing goals.
- Use Source Atlas bridge from TRAIN_04C when available.
- Use Life Context from TRAIN_04A where relevant.
- Use PersonalizationFactorLedger from T04A-B06 where relevant.
- Rank high/medium/weak/rejected matches with reasons.
- Add correction learning where source evidence supports it.
- Add tests and `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no weak-match forced attachment
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Required runtime objects
`GoalRelevanceScan` fields:
- captureID
- scannedGoalIDs
- highConfidenceMatches
- mediumConfidenceMatches
- weakMatches
- rejectedMatches
- relevanceReasons
- noMatchReason
- forcedAttachmentBlocked

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect goal models, goal compiler inputs, Smart Attachment placement, Source Atlas bridge, and Life Context seams.
3. Define relevance scan contracts and confidence bands.
4. Rank high/medium/weak/rejected matches with explanations.
5. Require user review for attachment.
6. Save weak/no-match captures as standalone or future context candidates where useful.
7. Add correction scenarios that affect later ranking.

## Tests to add/update
- High confidence capture can attach to a relevant goal after user approval.
- Medium confidence capture saves standalone and suggests attachment.
- Weak matches do not attach.
- No-match captures remain useful future context.
- Relevance scan produces explanation.
- User correction changes future relevance ranking.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B02 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`

## Accessibility requirements
Goal relevance explanations and approval controls must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Privacy/local-first requirements
Goal relevance scanning remains local-first. Sensitive context requires review before runtime use and must not appear in logs/external surfaces.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against the deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: high confidence suggestion works with approval; weak matches do not attach; no-match captures remain useful; explanations exist; correction affects future ranking.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: weak match is forced, goal attachment happens silently, or relevance is unexplainable.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B02 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Goal relevance proof:
Forced-attachment block proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
