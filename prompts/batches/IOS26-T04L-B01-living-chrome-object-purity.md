<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04L-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04L-B01`

## Train ID and title
`TRAIN_04L` - Object Frontend Living Chrome Foundation

## Batch role in train
Batch 1 of 1 in TRAIN_04L

## Upstream dependencies
- `TRAIN_02`
- `TRAIN_04J`
- `TRAIN_04K`

## Downstream dependencies
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_08`
- `TRAIN_09`
- `TRAIN_10`

## Objective
Install the object frontend implementation authority, add the anti-card validator, and make Living Chrome/global command shell object-pure before final object surfaces begin.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Preserve local-first deterministic behavior. Do not introduce external personal-data, cloud LLM, analytics, tracking, backend SDK, or paid service dependencies.

## Accessibility constraints
Preserve VoiceOver semantics, Dynamic Type, Reduce Motion, Increase Contrast, and 44 pt minimum touch-target expectations where UI is touched. Do not claim accessibility verification without proof.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.

## Allowed files/directories
- Scope is limited to the original prompt intent and the active owner files identified after truth/source inspection.

## Forbidden files/directories
- No cloud dependency.
- No LLM dependency.
- No analytics/tracking SDK.
- No top-level IA changes.
- No release/accessibility/performance/privacy claims without proof.

## Exact implementation steps
1. Add frontend object spec docs if not present.
2. Add `scripts/ios26-anti-card-check.py`.
3. Add validator tests or fixtures.
4. Rework global shell/Living Chrome so it is almost invisible by default, OS-like when needed, and surface-specific where appropriate.
5. Replace generic global add/plus dominance with contextual object-action behavior.
6. Ensure command surface is not chat, search-engine, Raycast clone, or dashboard.
7. Ensure shell receipts appear only for material actions as calm continuity.
8. Run shell/global validator modes.
9. Write proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04L-B01 TEST=AmbitionsTests
```

## Proof artifacts to write
- `build/reports/ios26-flagship/<batch-id>.md`
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
Green: sealed objective, validation, and proof artifact pass. Yellow: bounded gap with owner, reason, no-claim boundary, and follow-up gate. Red: missing prompt, boundary violation, failed validation without accepted Yellow, or forbidden dependency/claim.

## Rollback behavior
Rollback only files touched by this batch and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
Status:
Files changed:
Validation run:
Validation not run:
Proof artifacts:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Rollback:

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04L-B01 — Living Chrome Object Purity

## Batch ID
`IOS26-T04L-B01`

## Train ID and title
`TRAIN_04L` — Object Frontend Living Chrome Foundation

## Batch type
Implementation batch.

## Objective
Install the object frontend implementation authority, add the anti-card validator, and make Living Chrome/global command shell object-pure before final object surfaces begin.

## Required authorities to inspect first
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/frontend/AMB_OBJECT_FRONTEND_IMPLEMENTATION_SPEC.md`
- `docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md`
- `docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `AppShellScaffold` source
- command router / shell overlay source
- active AmbitionsDesignSystem source

## Scope
Allowed:
- docs/codex/frontend files
- `scripts/ios26-anti-card-check.py`
- validator tests/fixtures
- Living Chrome / shell SwiftUI source
- command surface source
- shell receipts/continuity source
- shell previews/tests
- proof artifacts under `build/reports/frontend-object-purity/`

Forbidden:
- no new top-level tab
- no chat-first UI
- no dashboard shell
- no generic global plus dominance
- no broad design-system rewrite
- no release/App Store/accessibility/performance overclaims

## Required implementation behavior
1. Add frontend object spec docs if not present.
2. Add `scripts/ios26-anti-card-check.py`.
3. Add validator tests or fixtures.
4. Rework global shell/Living Chrome so it is almost invisible by default, OS-like when needed, and surface-specific where appropriate.
5. Replace generic global add/plus dominance with contextual object-action behavior.
6. Ensure command surface is not chat, search-engine, Raycast clone, or dashboard.
7. Ensure shell receipts appear only for material actions as calm continuity.
8. Run shell/global validator modes.
9. Write proof artifact.

## Validation commands
Use supported repo commands only. At minimum:

```bash
python3 scripts/ios26-anti-card-check.py --surface shell --batch IOS26-T04L-B01
python3 scripts/ios26-anti-card-check.py --surface global --batch IOS26-T04L-B01
python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04L-B01
```

Then inspect `Makefile` and `scripts/` for the current focused Xcode validation command and run the narrowest relevant app/test validation.

## Proof artifacts
Write:

```text
build/reports/frontend-object-purity/IOS26-T04L-B01-living-chrome-object-purity.md
build/reports/frontend-object-purity/IOS26-T04L-B01-anti-card.md
build/reports/frontend-object-purity/IOS26-T04L-B01-anti-card.json
```

## Green
- object frontend docs installed
- anti-card validator installed
- shell/global validator modes pass
- shell no longer depends on generic card architecture
- command surface is native/contextual, not chat/search/dashboard
- shell tests/previews updated where touched
- accessibility labels preserved
- proof written

## Yellow
Allowed only with exact file list, owner, no-claim boundary, follow-up gate, and repair-cycle evidence.

## Red
- shell remains global card/dashboard/plus-first composition
- command surface becomes chat or assistant UI
- validator missing
- active Card architecture remains in shell
- accessibility path broken
- broad design-system rewrite without scoped need

## Final report required fields
```text
Status: Green / Yellow / Red
Batch:
Train:
Files changed by category:
Source changes:
Design-system changes:
Tests/previews:
Validators:
Proof artifacts:
Commands run:
Commands not run:
Object root evidence:
Anti-card status:
Shell command status:
Accessibility status:
Privacy/local-first status:
Yellow items:
Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
