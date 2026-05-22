<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
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
