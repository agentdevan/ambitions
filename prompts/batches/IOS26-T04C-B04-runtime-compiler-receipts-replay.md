<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B04 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04C-B04`

## Train ID and title
`TRAIN_04C` - Source Atlas -> Runtime Compiler Bridge

## Batch role in train
Batch 4 of 6 in TRAIN_04C

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`

## Downstream dependencies
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_10`

## Objective
Make the bridge receipt-backed and replayable.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Receipts and replay traces remain local-first. Sensitive source/context data must be redacted from logs, widgets, share extension, App Intents, and external snapshots.

## Accessibility constraints
Receipt and replay summaries must remain readable with VoiceOver and Dynamic Type where surfaced.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Allowed files/directories
- Add bridge receipt requirements and replay trace requirements.
- Add user correction influence for future pack/path/candidate ranking.
- Redact sensitive data where needed.
- Add tests and `build/reports/source-atlas-runtime-bridge/receipts-replay.md`.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no unsupported professional advice
- no hidden expert system claims
- no source pack overclaim
- no stale source use without review
- no demographic templates
- no top-level IA changes
- no external analytics dependency
- no sensitive data in logs
- no unreplayable recommendation behavior

## Exact implementation steps
1. Re-read active truth files and confirm B01-B03 proof.
2. Inspect receipt, replay, recommendation, persistence, and source atlas trace source.
3. Add receipt models for bridge events.
4. Add deterministic replay reconstruction for raw intent, packs, paths, candidates, selected recommendation, factor ledger, and simulation.
5. Make user corrections affect future output.
6. Add sensitive data redaction checks.
7. Add proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/source-atlas-runtime-bridge/receipts-replay.md`
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
Green: deterministic replay passes, receipts include source/freshness/risk status, corrections alter future output, and sensitive data is redacted.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no bridge receipts, no deterministic replay, unredacted sensitive data, or corrections do not affect output.

## Rollback behavior
Rollback only files touched by IOS26-T04C-B04 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Receipt proof:
Replay proof:
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
# IOS26-T04C-B04 - Runtime compiler receipts and replay

## Objective
Make the bridge receipt-backed and replayable.

## Why this exists
Source Atlas-driven recommendations must be inspectable after the fact. Replay must reconstruct raw intent, selected and rejected packs, selected and rejected paths, step candidates, selected Start Here recommendation, factor ledger, and simulation result.

## Dependencies
IOS26-T04C-B01, IOS26-T04C-B02, IOS26-T04C-B03, TRAIN_04B, TRAIN_10, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackFactoryModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- Runtime
- Recommendation engine
- Goal compiler
- Today
- Goals
- Time
- You
- Persistence
- Receipts
- Replay
- Services
- Native/AmbitionsTests
- Native/AmbitionsUITests
- Preview fixtures
- `tools/source-atlas/`
- `docs/codex/SOURCE_ATLAS_*.md`

## Exact changes allowed
- Add bridge receipt requirements and replay trace requirements.
- Add user correction influence for future pack/path/candidate ranking.
- Redact sensitive data where needed.
- Add tests and `build/reports/source-atlas-runtime-bridge/receipts-replay.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no unsupported professional advice
- no hidden expert system claims
- no source pack overclaim
- no stale source use without review
- no demographic templates
- no top-level IA changes
- no external analytics dependency
- no sensitive data in logs
- no unreplayable recommendation behavior

## Required receipts
- sourceAtlasIntentMatched
- sourceAtlasPackSelected
- sourceAtlasPackRejected
- sourceAtlasPathComposed
- sourceAtlasPathRejected
- sourceAtlasStepCandidatesExpanded
- sourceAtlasUnsupportedGoalFallback
- sourceAtlasFreshnessBlocked
- sourceAtlasUserCorrectionApplied
- sourceAtlasReplayGenerated

## Implementation steps
1. Re-read active truth files and confirm B01-B03 proof.
2. Inspect receipt, replay, recommendation, persistence, and source atlas trace source.
3. Add receipt models for bridge events.
4. Add deterministic replay reconstruction for raw intent, packs, paths, candidates, selected recommendation, factor ledger, and simulation.
5. Make user corrections affect future output.
6. Add sensitive data redaction checks.
7. Add proof artifact.

## Tests to add/update
- Deterministic replay passes.
- Receipts include source/freshness/risk status.
- Corrections alter future output.
- Sensitive data is redacted where needed.
- Unsupported fallback receipts reconstruct correctly.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/source-atlas-runtime-bridge/receipts-replay.md`

## Accessibility requirements
Receipt and replay summaries must remain readable with VoiceOver and Dynamic Type where surfaced.

## Privacy/local-first requirements
Receipts and replay traces remain local-first. Sensitive source/context data must be redacted from logs, widgets, share extension, App Intents, and external snapshots.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: deterministic replay passes, receipts include source/freshness/risk status, corrections alter future output, and sensitive data is redacted.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no bridge receipts, no deterministic replay, unredacted sensitive data, or corrections do not affect output.

## Rollback strategy
Rollback only files touched by IOS26-T04C-B04 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Receipt proof:
Replay proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
