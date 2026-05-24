<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B04 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04B-B04`

## Train ID and title
`TRAIN_04B` - Step Optionality, Rejection Replanning & Simulation Proof

## Batch role in train
Batch 4 of 6 in TRAIN_04B

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
Require approval for replacement steps and preserve learning.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Receipts and learning remain local-first. Sensitive rejection reasons must be redacted from logs and external surfaces.

## Accessibility constraints
Approval, receipt, and undo controls must remain reachable through VoiceOver and Dynamic Type. Confirmation cannot rely on haptics or color alone.

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
- Add approval requirements for material timeline/schedule/deadline changes.
- Add receipt types: `stepRejected`, `rejectionReasonSaved`, `alternateStepGenerated`, `alternateStepApproved`, `deadlinePressureChanged`, `timelineStillOnTrack`, `deadlineAtRisk`, `scopeReviewSuggested`, `rejectedCandidateSuppressed`, and `preferenceLearned`.
- Add replay support for the decision.
- Add undo where safe.
- Add tests, fixtures, and `build/reports/step-optionality/approval-receipts-learning.md`.

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
- no silent plan mutation
- no unapproved material deadline or schedule change

## Exact implementation steps
1. Re-read active truth files and confirm B01-B03 proof.
2. Inspect receipt, replay, persistence, recommendation, and Today source.
3. Add approval gate logic for material schedule/deadline changes.
4. Add receipt models, persistence, and replay reconstruction.
5. Feed approved alternative and reason into local learning.
6. Add undo where safe and proof that no silent mutation occurs.
7. Add proof artifact.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/step-optionality/approval-receipts-learning.md`
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
Green: approval gates, receipts, replay, safe undo, and local learning proof exist.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: silent mutation, missing receipt, unreplayable decision, unapproved material change, or sensitive log leakage.

## Rollback behavior
Rollback only files touched by IOS26-T04B-B04 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Approval/receipt proof:
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
# IOS26-T04B-B04 - Approval, receipts, and learning

## Objective
Require approval for replacement steps and preserve learning.

## Why this exists
Ambitions must never silently mutate a plan. The user can reject a step, choose an alternative, and approve material changes, while receipts preserve rejection, reason, replacement, timeline impact, suppression, and preference learning.

## Dependencies
IOS26-T04B-B01, IOS26-T04B-B02, IOS26-T04B-B03, TRAIN_10 readiness assumptions for downstream receipt/replay integration, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- Add approval requirements for material timeline/schedule/deadline changes.
- Add receipt types: `stepRejected`, `rejectionReasonSaved`, `alternateStepGenerated`, `alternateStepApproved`, `deadlinePressureChanged`, `timelineStillOnTrack`, `deadlineAtRisk`, `scopeReviewSuggested`, `rejectedCandidateSuppressed`, and `preferenceLearned`.
- Add replay support for the decision.
- Add undo where safe.
- Add tests, fixtures, and `build/reports/step-optionality/approval-receipts-learning.md`.

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
- no silent plan mutation
- no unapproved material deadline or schedule change

## Required flow
1. User taps "Not this" or "Show another."
2. Ambitions asks why.
3. Ambitions shows 3-5 alternatives.
4. Each alternative shows timeline impact.
5. User chooses one.
6. Material schedule/deadline changes require approval.
7. Receipt records rejection, reason, replacement, and deadline impact.
8. Runtime learns from the event.

## Implementation steps
1. Re-read active truth files and confirm B01-B03 proof.
2. Inspect receipt, replay, persistence, recommendation, and Today source.
3. Add approval gate logic for material schedule/deadline changes.
4. Add receipt models, persistence, and replay reconstruction.
5. Feed approved alternative and reason into local learning.
6. Add undo where safe and proof that no silent mutation occurs.
7. Add proof artifact.

## Tests to add/update
- No silent plan mutation.
- Approval required for material timeline changes.
- Receipt explains what changed and why.
- Replay reconstructs the decision.
- Undo exists where safe.
- Preference learning affects later ranking.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/step-optionality/approval-receipts-learning.md`

## Accessibility requirements
Approval, receipt, and undo controls must remain reachable through VoiceOver and Dynamic Type. Confirmation cannot rely on haptics or color alone.

## Privacy/local-first requirements
Receipts and learning remain local-first. Sensitive rejection reasons must be redacted from logs and external surfaces.

## iOS 26 API verification requirements
Any iOS 26 persistence, transaction, presentation, or accessibility API usage must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: approval gates, receipts, replay, safe undo, and local learning proof exist.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: silent mutation, missing receipt, unreplayable decision, unapproved material change, or sensitive log leakage.

## Rollback strategy
Rollback only files touched by IOS26-T04B-B04 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Approval/receipt proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
----- END ORIGINAL PROMPT -----
