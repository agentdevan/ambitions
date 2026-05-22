<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B05 - Source Atlas coverage gauntlet

## Objective
Prove broad goal/path/plan/step composition coverage.

## Why this exists
Broad Source Atlas bridge claims are unsafe without deterministic coverage across many goal families, life contexts, schedules, access states, historical states, and risk classes.

## Dependencies
IOS26-T04C-B01, IOS26-T04C-B02, IOS26-T04C-B03, IOS26-T04C-B04, TRAIN_04A, TRAIN_04B, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Add deterministic bridge scenario fixtures and tests.
- Add report generation for `build/reports/source-atlas-runtime-bridge/coverage-gauntlet.md`.
- Add Red/Yellow/Green summary and failing scenario list when any.
- Update only source, tests, previews, and proof artifacts required for this batch.

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
- no impossible timeline presented as fine

## Required gauntlet
- At least 100 distinct goal intents.
- At least 20 life context profiles.
- At least 10 schedule realities.
- At least 10 facility/access states.
- At least 10 historical context states.
- At least 5 risk classes.
- Minimum 1,000 deterministic bridge checks.

## Required goal families
- sports performance
- creative release
- music production
- app launch
- coding skill
- job search
- education/test prep
- debt payoff
- saving money
- fitness
- strength
- weight loss
- sleep
- home organization
- relationship repair habit
- relocation/move
- travel planning
- social life
- certification
- business launch
- writing/book
- portfolio building
- mountain biking/outdoor skill
- mental recovery / burnout-safe planning
- instrument learning

## Required assertions
- known goals map to source packs or safe scaffold.
- no one-pack-per-goal template path.
- every current recommendation has source/freshness/risk gate result.
- every composed path has requirements and candidate steps.
- every selected candidate has factor ledger and simulation.
- unsupported goals are clearly labeled.
- high-risk domains do not overclaim.
- replay is deterministic.
- sensitive context is not logged.
- no impossible timeline is presented as fine.

## Implementation steps
1. Re-read active truth files and confirm B01-B04 proof.
2. Inspect test/proof artifact conventions and privacy log guards.
3. Build deterministic scenario matrix with at least 1,000 checks.
4. Cover required goal families, contexts, schedules, access states, historical states, and risk classes.
5. Record deterministic scenario output, Red/Yellow/Green summary, and failing scenarios.
6. Add proof artifact.

## Tests to add/update
- Minimum 1,000 deterministic bridge checks.
- Goal family fixture coverage.
- Source/freshness/risk gate assertion coverage.
- Candidate provenance/factor ledger/simulation assertions.
- Sensitive log redaction checks.
- Replay determinism checks.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04C-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B05 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/source-atlas-runtime-bridge/coverage-gauntlet.md`

## Accessibility requirements
Coverage fixtures must include inspection handoff states where relevant. This batch does not prove public accessibility unless actual accessibility proof is produced.

## Privacy/local-first requirements
No sensitive context may appear in logs, reports, or external artifacts. Scenario generation and replay must remain local and deterministic.

## iOS 26 API verification requirements
Any iOS 26 API used by test/proof harnesses must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: coverage gauntlet exists with deterministic output, Red/Yellow/Green summary, failing scenario list if any, and no broad claim unless Green.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no gauntlet, non-deterministic replay, sensitive logs, high-risk overclaim, one-pack template behavior, or impossible timelines shown as fine.

## Rollback strategy
Rollback only files touched by IOS26-T04C-B05 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Coverage gauntlet proof:
Scenario count:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
