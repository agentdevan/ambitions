<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B05 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04B-B05`

## Train ID and title
`TRAIN_04B` - Step Optionality, Rejection Replanning & Simulation Proof

## Batch role in train
Batch 5 of 6 in TRAIN_04B

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`

## Downstream dependencies
- `TRAIN_04C`
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_10`

## Objective
Prove step optionality and simulation across many goals and contexts.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
No sensitive context may appear in logs, proof reports, or external artifacts. All scenario generation must be local and deterministic.

## Accessibility constraints
Gauntlet fixtures must include accessibility-relevant states for Today optionality handoff where applicable. This batch does not prove public accessibility unless actual accessibility proof is produced.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns step candidate generation, rejection learning, and simulation loops.
- `today_root` may present optionality in Today only by extending `Native/Ambitions/Features/Today`, not by creating a detached Start Here/Today owner.

## Allowed files/directories
- Add deterministic scenario fixtures and tests for the gauntlet.
- Add a report writer or test artifact path for `build/reports/step-optionality/simulation-gauntlet.md`.
- Add privacy-safe failure summaries and top failing scenario listings.
- Update only source, tests, previews, and proof artifacts required for this batch.

## Forbidden files/directories
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

## Exact implementation steps
1. Re-read active truth files and confirm B01-B04 proof.
2. Inspect test infrastructure, fixture generation, proof writer conventions, and privacy log guards.
3. Build deterministic scenario matrix coverage with at least 500 checks.
4. Add Red/Yellow/Green summary and top failing scenario listing.
5. Ensure no sensitive context appears in logs or reports.
6. Add proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04B-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B05 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/step-optionality/simulation-gauntlet.md`
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
Green: `build/reports/step-optionality/simulation-gauntlet.md` exists with deterministic output, Red/Yellow/Green summary, at least 500 checks, and top failing scenarios if any.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no simulation gauntlet, non-deterministic replay, sensitive logs, impossible timelines shown as fine, or factorless recommendation.

## Rollback behavior
Rollback only files touched by IOS26-T04B-B05 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
