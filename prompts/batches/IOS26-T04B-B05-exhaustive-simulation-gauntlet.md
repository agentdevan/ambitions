<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B05 - Exhaustive simulation gauntlet

## Objective
Prove step optionality and simulation across many goals and contexts.

## Why this exists
The moat claim is only credible if optionality, rejection reasoning, deadline impact, receipts, and replay survive broad deterministic scenario coverage rather than a few handpicked examples.

## Dependencies
IOS26-T04B-B01, IOS26-T04B-B02, IOS26-T04B-B03, IOS26-T04B-B04, TRAIN_03, TRAIN_04, TRAIN_04A, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Runtime
- Recommendation engine
- Goal compiler
- Today
- Time
- Goals
- You
- Persistence
- Receipts
- Replay
- Services
- Sources/Theme
- Native/AmbitionsTests
- Native/AmbitionsUITests
- Preview fixtures
- `build/reports/step-optionality/`

## Exact changes allowed
- Add deterministic scenario fixtures and tests for the gauntlet.
- Add a report writer or test artifact path for `build/reports/step-optionality/simulation-gauntlet.md`.
- Add privacy-safe failure summaries and top failing scenario listings.
- Update only source, tests, previews, and proof artifacts required for this batch.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no opaque recommendation engine
- no "AI confidence" consumer language
- no hidden profiling
- no external analytics dependency
- no top-level IA changes
- no generic dashboard
- no sensitive context in logs
- no demographic-only branching
- no impossible timeline shown as fine

## Required gauntlet
- 25 goal archetypes
- 10 life context profiles
- 10 schedule realities
- 10 rejection reasons
- 5 deadline pressure levels
- 5 access/facility states
- 5 historical context states
- Minimum 500 deterministic scenario checks.

## Required goal archetypes
- make varsity football
- play college basketball
- release a song
- launch an app
- pay off debt
- lose weight
- build strength
- learn coding
- get a job
- move apartments
- start mountain biking
- prepare for exam
- build portfolio
- repair relationship habit
- clean/organize home system
- start business
- write book
- improve sleep
- recover from burnout
- train for race
- save money
- build social life
- learn instrument
- finish certification
- plan trip

## Required assertions
- every plan has multiple candidates
- every candidate has impact simulation
- every rejection changes ranking or records a no-op reason
- every material deadline impact is surfaced
- every accepted alternative has receipt
- no demographic-only branching
- no factorless recommendation
- no impossible timeline is shown as fine
- no sensitive context appears in logs
- replay is deterministic

## Implementation steps
1. Re-read active truth files and confirm B01-B04 proof.
2. Inspect test infrastructure, fixture generation, proof writer conventions, and privacy log guards.
3. Build deterministic scenario matrix coverage with at least 500 checks.
4. Add Red/Yellow/Green summary and top failing scenario listing.
5. Ensure no sensitive context appears in logs or reports.
6. Add proof artifact.

## Tests to add/update
- Minimum 500 deterministic scenario checks.
- Fixture tests for all required goal archetypes.
- Privacy log scan for sensitive context.
- Replay determinism tests.
- Red/Yellow/Green summary generation test.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04B-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B05 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/step-optionality/simulation-gauntlet.md`

## Accessibility requirements
Gauntlet fixtures must include accessibility-relevant states for Today optionality handoff where applicable. This batch does not prove public accessibility unless actual accessibility proof is produced.

## Privacy/local-first requirements
No sensitive context may appear in logs, proof reports, or external artifacts. All scenario generation must be local and deterministic.

## iOS 26 API verification requirements
Any iOS 26 API used by test/proof harnesses must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: `build/reports/step-optionality/simulation-gauntlet.md` exists with deterministic output, Red/Yellow/Green summary, at least 500 checks, and top failing scenarios if any.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no simulation gauntlet, non-deterministic replay, sensitive logs, impossible timelines shown as fine, or factorless recommendation.

## Rollback strategy
Rollback only files touched by IOS26-T04B-B05 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Simulation gauntlet proof:
Scenario count:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
