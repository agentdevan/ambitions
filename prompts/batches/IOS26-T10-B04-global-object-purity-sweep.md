<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T10-B04 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T10-B04`

## Train ID and title
`TRAIN_10` - Proof, receipts, closure, recovery, replay

## Batch role in train
Batch 4 of 4 in TRAIN_10

## Upstream dependencies
- `TRAIN_03_through_TRAIN_09`
- `TRAIN_04A`
- `TRAIN_04B`
- `TRAIN_04C`
- `TRAIN_04D_for_receipts_replay`
- `TRAIN_04K`
- `TRAIN_04L`

## Downstream dependencies
- `TRAIN_12`

## Objective
Run the final global object-purity sweep after T10 so Ambitions cannot proceed into durability/accessibility/performance/release trains while active top-level UI still uses generic card/list/dashboard/feed/chat/calendar architecture.

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
- `proof_receipt_replay` owns Proof / Receipt / ReplayTrace across `Native/Ambitions/Domain`, `Native/Ambitions/Services`, and `Native/Ambitions/Runtime`.
- Accepted Yellow: proof_receipt_replay remains in accepted Yellow status. No-claim boundary: no parallel Proof/Receipt/ReplayTrace owner may be introduced. Follow-up gate: resolve adjacent Smart Attachment drift before broad proof closure. Affected canonical owner: proof_receipt_replay.

## Allowed files/directories
- Scope is limited to the original prompt intent and the active owner files identified after truth/source inspection.

## Forbidden files/directories
- No cloud dependency.
- No LLM dependency.
- No analytics/tracking SDK.
- No top-level IA changes.
- No release/accessibility/performance/privacy claims without proof.

## Exact implementation steps
1. Run `scripts/ios26-anti-card-check.py` in every surface mode plus global mode.
2. Inspect failures.
3. Repair active card architecture, card naming, card accessibility IDs, equal panel stacks, and root dashboard/list/feed/chat/calendar clone patterns.
4. Verify object roots remain installed:
   - Today / Reality Meridian
   - Time / LifeShape Field
   - Goals / Constellation Atlas
   - Capture / Atmosphere Composer
   - You / User System Profile
   - Proof / Receipt / Closure / Recovery
5. Verify preview matrices exist.
6. Verify tests and accessibility labels exist.
7. Produce final Green/Yellow/Red object frontend report.
8. Provide screenshot proof or manual screenshot checklist if automation is unavailable.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T10-B04 TEST=AmbitionsTests
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
# IOS26-T10-B04 — Global Object Purity Sweep

## Batch ID
`IOS26-T10-B04`

## Train ID and title
`TRAIN_10` — Proof, receipts, closure, recovery, replay

## Batch type
Implementation / validation closeout batch.

## Objective
Run the final global object-purity sweep after T10 so Ambitions cannot proceed into durability/accessibility/performance/release trains while active top-level UI still uses generic card/list/dashboard/feed/chat/calendar architecture.

## Required authorities to inspect first
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/codex/frontend/AMB_OBJECT_FRONTEND_IMPLEMENTATION_SPEC.md`
- `docs/codex/frontend/IOS26_OBJECT_FRONTEND_BATCH_INSERTION_PLAN.md`
- `docs/codex/frontend/IOS26_ANTI_CARD_VALIDATOR_SPEC.md`
- `docs/codex/frontend/OBJECT_FRONTEND_GREEN_YELLOW_RED_RUBRIC.md`
- all active source areas for Today, Time, Goals, Capture, You, shell, proof/receipt

## Scope
Allowed:
- targeted source repairs in shell and top-level surfaces
- validator fixes
- preview/test fixes
- accessibility identifier/label fixes
- proof artifacts under `build/reports/frontend-object-purity/`

Forbidden:
- no broad redesign outside object spec
- no new top-level tab
- no card compatibility wrappers in active rendered UI
- no dashboard/feed/chat/calendar clone root
- no release/App Store/device/performance/accessibility overclaims

## Required implementation behavior
1. Run `scripts/ios26-anti-card-check.py` in every surface mode plus global mode.
2. Inspect failures.
3. Repair active card architecture, card naming, card accessibility IDs, equal panel stacks, and root dashboard/list/feed/chat/calendar clone patterns.
4. Verify object roots remain installed:
   - Today / Reality Meridian
   - Time / LifeShape Field
   - Goals / Constellation Atlas
   - Capture / Atmosphere Composer
   - You / User System Profile
   - Proof / Receipt / Closure / Recovery
5. Verify preview matrices exist.
6. Verify tests and accessibility labels exist.
7. Produce final Green/Yellow/Red object frontend report.
8. Provide screenshot proof or manual screenshot checklist if automation is unavailable.

## Required validation commands
```bash
python3 scripts/ios26-anti-card-check.py --surface shell --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface today --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface time --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface goals --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface capture --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface you --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface proof --batch IOS26-T10-B04
python3 scripts/ios26-anti-card-check.py --surface global --batch IOS26-T10-B04
```

Then run the current supported focused build/test/previews validation from repo scripts.

## Proof artifacts
Write:

```text
build/reports/frontend-object-purity/IOS26-T10-B04-global-object-purity-sweep.md
build/reports/frontend-object-purity/IOS26-T10-B04-anti-card.md
build/reports/frontend-object-purity/IOS26-T10-B04-anti-card.json
build/reports/frontend-object-purity/IOS26-T10-B04-screenshot-checklist.md
```

## Green
- every validator mode passes
- no active Card architecture remains in top-level UI
- no dashboard/feed/chat/list/calendar-clone root remains
- object roots present and visible
- preview matrix present for every object surface
- accessibility labels present
- screenshot/manual proof present
- no active card compatibility wrappers

## Yellow
Allowed only after repair cycle, with exact file list, owner, no-claim boundary, and follow-up gate. Yellow may not claim global object-purity completion.

## Red
- any active top-level surface remains card/list/dashboard/feed/chat/calendar root
- object root missing
- validator absent or failing without accepted boundary
- active card compatibility wrapper remains rendered
- accessibility path broken
- silent material mutation/unreceipted change detected

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
Surface status table:
Anti-card status:
Screenshot/manual proof:
Accessibility status:
Reduce Motion status:
Yellow items:
Red items:
Downstream gates:
Rollback:
Next batch:
```
----- END ORIGINAL PROMPT -----
