# CS06 Internal Failed Taxonomy Dry-Run Red Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-03

Result: STOPPED ON RED

Global order number: 045

Active batch: CS06 Internal Failed Taxonomy Retirement

Dry-run decision: Execution allowed: NO

## Reason

CS06 is currently written as a broad retirement batch for the internal `.failed`
taxonomy. Source discovery shows the seam is not a narrow delete/rename target.
It spans command execution status, external action command failure states,
async UI state, safe-automation receipt semantics, copy/accessibility language,
tests, support checklists, logs, and historical docs.

Proceeding directly would risk changing raw/internal status values, weakening
failure-forensics behavior, blurring safe-failure semantics, or turning a copy
cleanup into a behavior/schema migration without a replacement map.

## Source-Backed Seam Evidence

Representative live seam hits:

- `Native/Ambitions/Domain/AmbitionsCommandModels.swift` owns command execution status values.
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift` emits `.failed` execution results and `eventLedgerEmission = "failed"`.
- `Native/Ambitions/Services/ExternalActionCommandService.swift` owns external command failure status.
- `Native/Ambitions/UI/AsyncViewState.swift` owns `case failed(String)` for internal UI state.
- `Native/Ambitions/Domain/SafeAutomationPolicyModels.swift` owns `failedSafely` and `safeFailure` receipt semantics.
- `Native/Ambitions/Domain/SmartAttachmentModels.swift` owns `failed_safely` and `unavailable_failed` confidence/result states.
- `Sources/Accessibility/AccessibilityNutrition.swift` and support/checklist files contain failure terminology in audit/checklist contexts.
- Existing docs explicitly distinguish internal failure taxonomy from humane user-facing copy.

## Red Classification

CS06 triggers Red because:

- seam owner is too broad for the current prompt;
- raw/internal status values may be compatibility surfaces;
- safe-failure receipt semantics must not be collapsed into generic copy cleanup;
- external action results and command execution tests require a focused proof plan;
- accessibility/copy language needs an inventory before any rename;
- no rollback/replacement map exists for the full `.failed` taxonomy.

## Required Repair Shape

Repair CS06 before execution by splitting it internally without changing the
formal 113-batch count:

- CS06A: failed/failure taxonomy compatibility map, copy/accessibility ledger,
  raw/internal value ledger, and safe-failure semantics map only.
- CS06B: focused compatibility proof for command execution, external action
  results, async UI state, safe-automation receipts, and copy/a11y guardrails.
- CS06C: narrow retirement only if CS06A and CS06B prove a specific value or
  phrase is safe to retire.

## Validation

Dry-run inspection commands:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
sed -n '1,240p' docs/codex/batches/CS06_Internal_Failed_Taxonomy_Retirement_Prompt.md
rg -n "\\.failed|failed|failure|Failed|Failure" Native Sources AppUI docs/canon docs/audits docs/codex .codex --glob '!docs/audits/doc-qa/**' --glob '!output/**' | head -300
rg -n "enum .*failed|case failed|failed\\s*=|rawValue.*failed|CodingKeys|status" Native/Ambitions Native/AmbitionsTests Sources AppUI -g '*.swift'
rg -n "CS06|failed taxonomy|Internal Failed|failed" docs/audits/cs01-compatibility-seam-registry-and-risk-map-report.md docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md .codex/reports/current-run-state.md .codex/reports/current-batch-train-state.md
```

Post-CS05B drift checks before CS06 dry-run:

- `git status --short`: clean
- `git diff --check`: PASS
- `scripts/batch-train-gate-check.sh || true`: GREEN_HINT working tree clean

Stop-report validation before commit:

- `git diff --check`: PASS
- CS06 state grep: PASS; registry, context, global order, train state, and this report all record `Execution allowed: NO`.
- Release-claim scan: PASS WITH YELLOW; hits are forbidden-claim lists, scan commands, historical logs, and explicit non-claims.
- `scripts/run-doc-qa.sh || true`: PASS WITH YELLOW; existing stale-guidance, deprecated-language, and markdownlint advisory backlog remains; lychee passed 647 links with 0 errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW before commit with expected dirty-tree hint only.

## Non-Claims

This report does not claim CS06 is implemented, repaired, or complete. It does
not claim any `.failed`, `failedSafely`, `safeFailure`, or user-facing failure
language was retired. It does not claim release readiness, physical-device
proof, App Store readiness, TestFlight readiness, public accessibility
conformance, AmbitionsOS implementation, Signature Interface implementation, or
Product Depth implementation.

## Next Recommended Path

Use a CS06 Red repair prompt that mirrors the CS02-CS05 staging pattern:

`Repair CS06 Failed Taxonomy Compatibility Seam And Resume Global Train`
