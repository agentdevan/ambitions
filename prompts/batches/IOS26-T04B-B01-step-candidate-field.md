<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04B-B01`

## Train ID and title
`TRAIN_04B` - Step Optionality, Rejection Replanning & Simulation Proof

## Batch role in train
Batch 1 of 6 in TRAIN_04B

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
Replace single-step recommendation with a ranked candidate field.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Candidate generation must remain local-first and deterministic. Sensitive factors must not appear in logs or external surfaces.

## Accessibility constraints
Candidate field explanations must be representable as semantic summaries, not visual-only rank or pressure meaning. Dynamic Type and VoiceOver labels must preserve ranking reason, tradeoff, and approval requirement.

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
- Add domain/runtime requirements and source implementation for `StepCandidate`, `StepCandidateField`, `CandidateGenerationContext`, `CandidateScore`, `CandidateTradeoff`, `CandidateValidity`, `CandidateRankingTrace`, `CandidateRejectionRisk`, and `CandidateSource`.
- Add candidate generation for direct best, lighter, shorter, lower-energy, location-compatible, no-equipment, recovery-safe, admin/setup, learning/research, proof-gathering, prerequisite, maintenance, catch-up, substitution, parallel-path, and fallback steps.
- Add deterministic ranking traces using `PersonalizationFactorLedger`.
- Add focused tests, fixtures, and `build/reports/step-optionality/candidate-field.md`.

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
- no copy-only fake alternatives
- no demographic template branching
- no factorless recommendation

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect current goal compiler, recommendation, factor ledger, receipt, replay, persistence, and Today source.
3. Define candidate field models with estimated duration, energy required, access required, equipment/facility required, goal contribution, deadline contribution, future pressure impact, opportunity cost, ranking reason, rejection risk, timeline intact status, and approval requirement.
4. Generate multiple real candidates for the same goal without duplicating copy variants.
5. Rank candidates deterministically and emit a candidate ranking trace.
6. Add missing-context fallback behavior and proof.
7. Add tests and the candidate-field proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/step-optionality/candidate-field.md`
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
Green: multiple real candidates, deterministic ranking, factor-ledger proof, graceful missing context, and proof artifact exist.
Yellow: bounded gap with owner, reason, no-claim boundary, and post-batch gate.
Red: single-step-only recommendation engine, fake alternatives, opaque/factorless ranking, demographic branching, or sensitive log leakage.

## Rollback behavior
Rollback only files touched by IOS26-T04B-B01 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Candidate field proof:
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
# IOS26-T04B-B01 - Step candidate field

## Objective
Replace single-step recommendation with a ranked candidate field.

## Why this exists
Ambitions must not act like there is only one valid next step. The Private Life Runtime must generate multiple real step candidates for the same goal and deadline, rank them deterministically, expose tradeoffs, and degrade gracefully when context is missing.

## Dependencies
TRAIN_03, TRAIN_04, TRAIN_04A, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- `build/reports/life-context/`
- `build/reports/goal-intent-compiler/`

## Exact changes allowed
- Add domain/runtime requirements and source implementation for `StepCandidate`, `StepCandidateField`, `CandidateGenerationContext`, `CandidateScore`, `CandidateTradeoff`, `CandidateValidity`, `CandidateRankingTrace`, `CandidateRejectionRisk`, and `CandidateSource`.
- Add candidate generation for direct best, lighter, shorter, lower-energy, location-compatible, no-equipment, recovery-safe, admin/setup, learning/research, proof-gathering, prerequisite, maintenance, catch-up, substitution, parallel-path, and fallback steps.
- Add deterministic ranking traces using `PersonalizationFactorLedger`.
- Add focused tests, fixtures, and `build/reports/step-optionality/candidate-field.md`.

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
- no copy-only fake alternatives
- no demographic template branching
- no factorless recommendation

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect current goal compiler, recommendation, factor ledger, receipt, replay, persistence, and Today source.
3. Define candidate field models with estimated duration, energy required, access required, equipment/facility required, goal contribution, deadline contribution, future pressure impact, opportunity cost, ranking reason, rejection risk, timeline intact status, and approval requirement.
4. Generate multiple real candidates for the same goal without duplicating copy variants.
5. Rank candidates deterministically and emit a candidate ranking trace.
6. Add missing-context fallback behavior and proof.
7. Add tests and the candidate-field proof artifact.

## Tests to add/update
- Unit tests proving the same goal produces multiple real candidates.
- Unit tests proving candidates are not duplicate copy variants.
- Unit tests proving candidate ranking is deterministic.
- Unit tests proving candidates use `PersonalizationFactorLedger`.
- Unit tests proving missing context degrades gracefully.
- Replay tests proving candidate field reconstruction.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/step-optionality/candidate-field.md`

## Accessibility requirements
Candidate field explanations must be representable as semantic summaries, not visual-only rank or pressure meaning. Dynamic Type and VoiceOver labels must preserve ranking reason, tradeoff, and approval requirement.

## Privacy/local-first requirements
Candidate generation must remain local-first and deterministic. Sensitive factors must not appear in logs or external surfaces.

## iOS 26 API verification requirements
Any iOS 26 API use must be checked against source/project deployment target and recorded in the iOS 26 API ledger or proof artifact. Do not introduce an unverified API assumption.

## Green / Yellow / Red closeout rules
Green: multiple real candidates, deterministic ranking, factor-ledger proof, graceful missing context, and proof artifact exist.
Yellow: bounded gap with owner, reason, no-claim boundary, and post-batch gate.
Red: single-step-only recommendation engine, fake alternatives, opaque/factorless ranking, demographic branching, or sensitive log leakage.

## Rollback strategy
Rollback only files touched by IOS26-T04B-B01 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Candidate field proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
