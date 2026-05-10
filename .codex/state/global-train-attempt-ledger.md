# Global Train Attempt Ledger

## Purpose
Prevent recursive child-runner loops, repeated same-root retries, ambiguous continuation, and hidden child-batch state during the Ambitions global train.

This ledger is committed source-state. `.codex/runs/**` remains local run evidence and must not be committed.

## Current Active Attempt
- parent batch: RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION
- selected child batch: PK16
- child prompt: prompts/batches/PK16.md
- child run dir: .codex/runs/PK16/20260510T175745Z
- child attempt number: 1
- status: green
- started: 2026-05-10T17:57:45Z
- completed: 2026-05-10T18:28:20Z
- next action: `make global-train-until-complete`
- retry allowed: false
- reason: PK16 completed after GPT-5.5 review repaired the proof-reference presence filter and focused trust-history repository validation passed.

## State Rules
- A batch cannot be launched if the ledger already has the same batch active with status `running`, `unknown-unresolved`, `yellow-unresolved`, `red-unresolved`, `repair-required`, `finalization-required`, or `blocked`.
- A batch cannot be launched a second time from the same parent pass.
- A failed or unresolved batch requires a separately named repair/finalization prompt before another normal attempt.
- `UNKNOWN` child status is not permission to start another attempt.
- `UNKNOWN` must be treated as `unknown-unresolved` unless artifact inspection proves otherwise.
- A build lock or active conflicting runner/Codex/Xcode process state must be treated as `red-unresolved` or `blocked`.
- Green and accepted Yellow may continue only after proof path, owner, reason, no-claim boundary, retirement condition, and resume path are recorded where applicable.

## Attempt History
| Timestamp | Parent | Child | Attempt | Status | Proof Path | Next Action |
|---|---|---|---:|---|---|---|
| 2026-05-10T07:37:22Z | RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION | PK14 | 1 | yellow-unresolved | .codex/runs/PK14/20260510T073722Z/final-summary.md | Emit bounded repair; do not rerun from parent. |
| 2026-05-10T07:41:20Z | RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION | PK14 | 2 | red-unresolved | .codex/runs/PK14/20260510T074120Z/final-summary.md | Emit bounded repair; do not rerun from parent. |
| 2026-05-10T13:25:24Z | PK14-CONDUCTOR-REPAIR-01 | PK14 | 1 | green | .codex/runs/PK14/20260510T134429Z/final/03-review.final.md | PK14 consumed by clean top-level repair; do not rerun PK14. |
| 2026-05-10T14:58:52Z | RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION | PK15 | 2 | red-unresolved | .codex/runs/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION/20260510T145852Z/ | Parent conductor loop guard stopped nested PK15 churn; do not launch another nested child attempt. |
| 2026-05-10T15:12:22Z | top-level-runner | PK15 | 1 | finalization-required | .codex/runs/PK15/20260510T151222Z/final-summary.md | Run PK15-FINALIZE-01 to inspect existing diff/artifacts; do not rerun Spark. |
| 2026-05-10T17:35:20Z | top-level-runner | PK15 | 1 | accepted-yellow | docs/audits/pk15-receipt-backend-report.md | PK15 focused receipt tests passed; one pre-existing external-surface expectation mismatch remains in `ExternalSurfaceVerificationChecklistTests` and is owned by QA / External Surface for follow-up. |
| 2026-05-10T18:28:20Z | top-level-runner | PK16 | 1 | green | docs/audits/pk16-trust-history-query-report.md | PK16 focused trust-history query tests passed; PK17 is next eligible. |
