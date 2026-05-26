<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B05 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04C-B05`

## Train ID and title
`TRAIN_04C` - Source Atlas -> Runtime Compiler Bridge

## Batch role in train
Batch 5 of 6 in TRAIN_04C

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
Prove broad goal/path/plan/step composition coverage.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
No sensitive context may appear in logs, reports, or external artifacts. Scenario generation and replay must remain local and deterministic.

## Accessibility constraints
Coverage fixtures must include inspection handoff states where relevant. This batch does not prove public accessibility unless actual accessibility proof is produced.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns runtime compiler integration.
- `proof_receipt_replay` owns receipt/replay traces for Source Atlas runtime bridges.
- `you_root` owns inspection surfaces for what Ambitions knows.

## Allowed files/directories
- Add deterministic bridge scenario fixtures and tests.
- Add report generation for `build/reports/source-atlas-runtime-bridge/coverage-gauntlet.md`.
- Add Red/Yellow/Green summary and failing scenario list when any.
- Update only source, tests, previews, and proof artifacts required for this batch.

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
- no impossible timeline presented as fine

## Exact implementation steps
1. Re-read active truth files and confirm B01-B04 proof.
2. Inspect test/proof artifact conventions and privacy log guards.
3. Build deterministic scenario matrix with at least 1,000 checks.
4. Cover required goal families, contexts, schedules, access states, historical states, and risk classes.
5. Record deterministic scenario output, Red/Yellow/Green summary, and failing scenarios.
6. Add proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04C-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B05 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/source-atlas-runtime-bridge/coverage-gauntlet.md`
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
Green: coverage gauntlet exists with deterministic output, Red/Yellow/Green summary, failing scenario list if any, and no broad claim unless Green.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no gauntlet, non-deterministic replay, sensitive logs, high-risk overclaim, one-pack template behavior, or impossible timelines shown as fine.

## Rollback behavior
Rollback only files touched by IOS26-T04C-B05 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
