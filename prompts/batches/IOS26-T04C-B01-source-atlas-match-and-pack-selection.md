<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B01 - Source Atlas match and pack selection

## Objective
Map raw user goal intent to Source Atlas packs safely.

## Why this exists
Source Atlas cannot be product behavior unless raw goal intent can match to source/freshness/risk-gated packs that are safe to drive runtime output. Ambitions must clarify ambiguous matches and reject unsupported, stale, disputed, or high-risk packs unless user review is required first.

## Dependencies
TRAIN_03, TRAIN_04, TRAIN_04A, TRAIN_04B, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Capture promotion
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
- Add or connect requirements for `SourceAtlasIntentMatch` and `SourceAtlasPackSelection`.
- Parse and normalize raw goal text.
- Match goal intent to domain packs, specific domain packs, skill slices, and role overlays.
- Enforce schema, source, freshness, review, and risk gates.
- Preserve rejected pack reasons and compact clarification requests.
- Add tests and `build/reports/source-atlas-runtime-bridge/match-and-pack-selection.md`.

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
- no unsupported pack driving runtime output

## Required runtime objects
`SourceAtlasIntentMatch` fields:
- rawGoalText
- normalizedGoalIntent
- matchedDomainIDs
- matchedSpecificDomainIDs
- matchedSkillSliceIDs
- matchedRoleIDs
- confidenceBand
- missingClarifications
- sourceAtlasPackIDs
- rejectedPackIDs
- matchTrace

`SourceAtlasPackSelection` fields:
- selectedPackIDs
- rejectedPackIDs
- rejectionReasons
- sourceState
- freshnessState
- riskState
- reviewState
- canDriveRuntime
- requiredUserReview

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect Source Atlas pack, freshness, risk, review, and store source.
3. Define intent match and pack selection contracts.
4. Enforce source/freshness/risk/review gates before runtime use.
5. Preserve rejected pack reasons in trace.
6. Add compact clarification behavior for ambiguous goals.
7. Add proof scenarios and proof artifact.

## Tests to add/update
- "Make varsity football" maps to sport/football/high-school pathway packs where available.
- "Release 3 songs by August" maps to creative/music/release packs where available.
- "Pay off $5,000 debt" maps to financial goal context and blocks high-risk advice unless review-safe.
- Unknown goal degrades to generic goal scaffold with missing-source warning.
- Stale pack is rejected or marked Needs Review.
- No unsupported pack drives runtime output.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04C-B01 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B01 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/source-atlas-runtime-bridge/match-and-pack-selection.md`

## Accessibility requirements
Clarification prompts and review-needed states must be VoiceOver-readable, Dynamic Type-safe, and not color-only.

## Privacy/local-first requirements
Raw goal text, rejected packs, and risk traces remain local-first. Sensitive goal context must not appear in logs or external surfaces.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: source/freshness/risk/review gates enforced, rejected packs visible in trace, ambiguity clarifies, and unsupported packs do not drive runtime output.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: stale/high-risk/unsupported packs silently drive recommendations or fake certainty appears.

## Rollback strategy
Rollback only files touched by IOS26-T04C-B01 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Intent match proof:
Pack selection proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
