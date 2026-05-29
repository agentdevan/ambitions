# FCP13A Action Closure Diamond Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete Green on 2026-05-05
Train: FCP Flagship Completion
Owner: Today / Action Closure
Type: Implementation

## Purpose

Upgrade the existing Today Action Closure sheet from a plain outcome chooser
into the Action Closure Diamond object selected by the global full-stack order.

The Diamond is a closure / decision object. It must help the user choose an
honest outcome, preview the consequence, preserve proof semantics, and keep
recovery visible without silently changing Today, Plan, Goals, persistence, or
routes.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_3_0_Action_Closure_Sheet_Spec.md`
- `docs/canon/PXOS_Action_Closure_Recovery_Canon.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`

## Allowed Files

- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `docs/codex/batches/FCP13A_Action_Closure_Diamond_Prompt.md`
- `docs/audits/fcp13a-action-closure-diamond-report.md`
- global order, registry, context, and run-state docs needed to record batch truth

## Forbidden Files

- route/raw-value/navigation files unless a hard blocker is found
- persistence/schema/sync/auth/network/AI/LDI runtime files
- CI/config/project/source-truth dependency files beyond `xcodegen generate`
- production Swift outside the named Today Action Closure owner files

## Acceptance

- Action Closure Diamond is a real Today-owned state/UI object, not just a
  renamed sheet.
- Diamond explains Outcome, Consequence, Proof, and Recovery.
- Proof remains evidence only; receipt remains consequence; no user-facing
  confidence, score, shame, or silent automation copy is introduced.
- Accessibility labels expose the Diamond meaning and each facet.
- Dynamic Type has a list equivalent.
- Reduce Motion has a static equivalent.
- No persistence, route, Plan mutation, calendar write, AI runtime, release,
  legal/privacy, or public accessibility claim is added.

## Validation

- `xcodegen generate`
- focused `TodayViewModelTests`
- `scripts/build-local.sh`
- CQS advisory scans
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
