<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
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
