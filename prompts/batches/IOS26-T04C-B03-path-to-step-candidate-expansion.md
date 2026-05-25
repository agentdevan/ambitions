<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B03 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04C-B03`

## Train ID and title
`TRAIN_04C` - Source Atlas -> Runtime Compiler Bridge

## Batch role in train
Batch 3 of 6 in TRAIN_04C

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
Expand Source Atlas path composition into Step Candidate Field.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Candidate provenance stays local-first and sensitive context is redacted from logs and external surfaces.

## Accessibility constraints
Candidate provenance and simulation must remain readable and not visual-only where surfaced.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns runtime compiler integration.
- `proof_receipt_replay` owns receipt/replay traces for Source Atlas runtime bridges.
- `you_root` owns inspection surfaces for what Ambitions knows.

## Allowed files/directories
- Add or connect `SourceAtlasStepExpansionTrace`.
- Convert path nodes, requirements, proof needs, and starter seeds into step candidates.
- Generate TRAIN_04B candidate types where supported.
- Preserve candidate -> path -> pack/source provenance.
- Score candidates with `PersonalizationFactorLedger`.
- Simulate impact using TRAIN_04B deadline simulation.
- Add tests and `build/reports/source-atlas-runtime-bridge/path-step-candidate-expansion.md`.

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
- no duplicate copy-only alternatives

## Exact implementation steps
1. Re-read active truth files and confirm B01/B02 proof.
2. Inspect TRAIN_04B candidate field and simulation contracts.
3. Map path composition into candidate seeds and expanded candidates.
4. Preserve source provenance and freshness warnings.
5. Apply factor ledger scoring and deadline simulation.
6. Add safe generic scaffold behavior for unknown/unsupported goals.
7. Add proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/source-atlas-runtime-bridge/path-step-candidate-expansion.md`
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
Green: candidates derive from Source Atlas path composition, include provenance/ranking/simulation, avoid copy-only alternatives, and unsupported goals use safe scaffold with receipt.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no provenance, fake alternatives, unsupported source overclaim, or disconnected candidate field.

## Rollback behavior
Rollback only files touched by IOS26-T04C-B03 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Step expansion proof:
Candidate provenance proof:
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
# IOS26-T04C-B03 - Path to step candidate expansion

## Objective
Expand Source Atlas path composition into Step Candidate Field.

## Why this exists
Source Atlas path composition must become action. This batch connects path nodes, requirements, proof needs, and starter seeds into multiple step candidates with provenance, factor-ledger scoring, deadline simulation, and safe actionable copy.

## Dependencies
IOS26-T04C-B01, IOS26-T04C-B02, TRAIN_04B, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Add or connect `SourceAtlasStepExpansionTrace`.
- Convert path nodes, requirements, proof needs, and starter seeds into step candidates.
- Generate TRAIN_04B candidate types where supported.
- Preserve candidate -> path -> pack/source provenance.
- Score candidates with `PersonalizationFactorLedger`.
- Simulate impact using TRAIN_04B deadline simulation.
- Add tests and `build/reports/source-atlas-runtime-bridge/path-step-candidate-expansion.md`.

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
- no duplicate copy-only alternatives

## Required candidate outputs
- direct best step
- prerequisite step
- setup step
- proof-gathering step
- learning/research step
- practice step
- facility-based step
- no-equipment fallback
- shorter/lighter alternative
- catch-up step
- recovery-safe step
- deadline-protecting step

## Required runtime object
`SourceAtlasStepExpansionTrace` fields: sourceStepCandidateSeeds, expandedCandidates, rejectedSeeds, expansionRules, personalizationFactorsUsed, freshnessWarnings, sensitiveContextRedactions.

## Implementation steps
1. Re-read active truth files and confirm B01/B02 proof.
2. Inspect TRAIN_04B candidate field and simulation contracts.
3. Map path composition into candidate seeds and expanded candidates.
4. Preserve source provenance and freshness warnings.
5. Apply factor ledger scoring and deadline simulation.
6. Add safe generic scaffold behavior for unknown/unsupported goals.
7. Add proof artifact.

## Tests to add/update
- Candidate field comes from Source Atlas path composition.
- No duplicate copy-only alternatives.
- Each candidate has provenance, ranking trace, and simulation.
- Unknown/unsupported goals produce safe generic scaffold with missing-source receipt.
- Candidate copy is actionable, specific, and user-safe.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B03 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/source-atlas-runtime-bridge/path-step-candidate-expansion.md`

## Accessibility requirements
Candidate provenance and simulation must remain readable and not visual-only where surfaced.

## Privacy/local-first requirements
Candidate provenance stays local-first and sensitive context is redacted from logs and external surfaces.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: candidates derive from Source Atlas path composition, include provenance/ranking/simulation, avoid copy-only alternatives, and unsupported goals use safe scaffold with receipt.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: no provenance, fake alternatives, unsupported source overclaim, or disconnected candidate field.

## Rollback strategy
Rollback only files touched by IOS26-T04C-B03 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Step expansion proof:
Candidate provenance proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
