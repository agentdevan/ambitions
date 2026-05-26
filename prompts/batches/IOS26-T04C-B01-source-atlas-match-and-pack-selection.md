<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04C-B01`

## Train ID and title
`TRAIN_04C` - Source Atlas -> Runtime Compiler Bridge

## Batch role in train
Batch 1 of 6 in TRAIN_04C

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
Map raw user goal intent to Source Atlas packs safely.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Raw goal text, rejected packs, and risk traces remain local-first. Sensitive goal context must not appear in logs or external surfaces.

## Accessibility constraints
Clarification prompts and review-needed states must be VoiceOver-readable, Dynamic Type-safe, and not color-only.

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
- Add or connect requirements for `SourceAtlasIntentMatch` and `SourceAtlasPackSelection`.
- Parse and normalize raw goal text.
- Match goal intent to domain packs, specific domain packs, skill slices, and role overlays.
- Enforce schema, source, freshness, review, and risk gates.
- Preserve rejected pack reasons and compact clarification requests.
- Add tests and `build/reports/source-atlas-runtime-bridge/match-and-pack-selection.md`.

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
- no unsupported pack driving runtime output

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect Source Atlas pack, freshness, risk, review, and store source.
3. Define intent match and pack selection contracts.
4. Enforce source/freshness/risk/review gates before runtime use.
5. Preserve rejected pack reasons in trace.
6. Add compact clarification behavior for ambiguous goals.
7. Add proof scenarios and proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04C-B01 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B01 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/source-atlas-runtime-bridge/match-and-pack-selection.md`
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
Green: source/freshness/risk/review gates enforced, rejected packs visible in trace, ambiguity clarifies, and unsupported packs do not drive runtime output.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: stale/high-risk/unsupported packs silently drive recommendations or fake certainty appears.

## Rollback behavior
Rollback only files touched by IOS26-T04C-B01 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
