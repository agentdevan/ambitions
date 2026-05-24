<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B02 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04B-B02`

## Train ID and title
`TRAIN_04B` - Step Optionality, Rejection Replanning & Simulation Proof

## Batch role in train
Batch 2 of 6 in TRAIN_04B

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
Let users reject recommended steps and teach the runtime why.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Rejection reasons, especially emotional readiness, safety, injury, transportation, and blockers, must remain local and privacy-safe. Do not log sensitive reason text.

## Accessibility constraints
The reason sheet must preserve VoiceOver order, readable labels, large content sizes, and non-color-only state. Custom reason entry must remain reachable and dismissible.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Allowed files/directories
- Add rejection reason models and persistence.
- Add compact reason sheet behavior for "Not this".
- Add candidate suppression from immediate resurfacing unless context changes.
- Add ranking influence from rejection reasons.
- Add lower-learning-quality receipt behavior when reason is skipped.
- Add focused tests, fixtures, and `build/reports/step-optionality/rejection-loop.md`.

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
- no shame language
- no rejected candidate immediate resurfacing without context change

## Exact implementation steps
1. Re-read active truth files and confirm dependency proof from B01.
2. Inspect candidate, recommendation, receipt, persistence, replay, and Today flow source.
3. Add local rejection reason domain and persistence behavior.
4. Implement "Not this" reason capture with optional skip and lower learning quality.
5. Suppress rejected candidate from immediate resurfacing unless context changes.
6. Feed rejection reason into future candidate ranking.
7. Add rejection receipt and deterministic replay proof.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/step-optionality/rejection-loop.md`
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
Green: rejected candidate suppression, reason persistence, ranking effect, receipt, future recommendation effect, and privacy proof exist.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: rejection treated as failure, sensitive logs, immediate resurfacing without context change, or no ranking effect/no-op receipt.

## Rollback behavior
Rollback only files touched by IOS26-T04B-B02 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Rejection loop proof:
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
# IOS26-T04B-B02 - Rejection reasoning loop

## Objective
Let users reject recommended steps and teach the runtime why.

## Why this exists
Rejecting a Recommended step is not failure. Ambitions must support "Not this", ask "Why not this?", suppress the rejected candidate from immediate resurfacing unless context changes, and use the reason to alter future ranking while keeping sensitive reasons local.

## Dependencies
IOS26-T04B-B01, TRAIN_03, TRAIN_04, TRAIN_04A, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Today
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
- `build/reports/step-optionality/candidate-field.md`

## Exact changes allowed
- Add rejection reason models and persistence.
- Add compact reason sheet behavior for "Not this".
- Add candidate suppression from immediate resurfacing unless context changes.
- Add ranking influence from rejection reasons.
- Add lower-learning-quality receipt behavior when reason is skipped.
- Add focused tests, fixtures, and `build/reports/step-optionality/rejection-loop.md`.

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
- no shame language
- no rejected candidate immediate resurfacing without context change

## Required rejection reasons
- too long
- too hard
- too easy
- too much energy
- wrong location
- no equipment
- no transportation
- not enough time
- emotionally not ready
- blocked by someone else
- already did similar
- not useful
- unsafe / injury concern
- boring / low motivation
- prefer different path
- custom reason

## Implementation steps
1. Re-read active truth files and confirm dependency proof from B01.
2. Inspect candidate, recommendation, receipt, persistence, replay, and Today flow source.
3. Add local rejection reason domain and persistence behavior.
4. Implement "Not this" reason capture with optional skip and lower learning quality.
5. Suppress rejected candidate from immediate resurfacing unless context changes.
6. Feed rejection reason into future candidate ranking.
7. Add rejection receipt and deterministic replay proof.

## Tests to add/update
- Rejected step is excluded from immediate next options.
- Reason changes candidate ranking.
- Reason persists locally.
- Rejection receipt exists.
- Future recommendations reflect the reason.
- Sensitive reasons are absent from logs and external surfaces.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/step-optionality/rejection-loop.md`

## Accessibility requirements
The reason sheet must preserve VoiceOver order, readable labels, large content sizes, and non-color-only state. Custom reason entry must remain reachable and dismissible.

## Privacy/local-first requirements
Rejection reasons, especially emotional readiness, safety, injury, transportation, and blockers, must remain local and privacy-safe. Do not log sensitive reason text.

## iOS 26 API verification requirements
Any iOS 26 sheet, presentation, accessibility, or persistence API usage must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: rejected candidate suppression, reason persistence, ranking effect, receipt, future recommendation effect, and privacy proof exist.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: rejection treated as failure, sensitive logs, immediate resurfacing without context change, or no ranking effect/no-op receipt.

## Rollback strategy
Rollback only files touched by IOS26-T04B-B02 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Rejection loop proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
