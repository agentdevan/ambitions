<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
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
