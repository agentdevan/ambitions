# Global Train Attempt Ledger

## Purpose
Prevent recursive child-runner loops, repeated same-root retries, ambiguous continuation, and hidden child-batch state during the Ambitions global train.

This ledger is committed source-state. `.codex/runs/**` remains local run evidence and must not be committed.

## Current Active Attempt
- parent batch: GLOBAL-TRAIN-EXECUTE-FROM-PK17-TO-COMPLETE-01
- selected child batch: PK21
- child prompt: prompts/batches/PK21.md
- child run dir: .codex/runs/PK21/20260512T035041Z
- child attempt number: 1
- status: green
- started: 2026-05-12T03:50:41Z
- completed: 2026-05-12T04:11:51Z
- next action: PK22 SideEffectLedger Foundation
- retry allowed: false
- reason: PK21 extracted the Time projection seam while preserving Plan as the internal compatibility owner; focused PlanFeatureServiceTests validation passed and no forbidden-claim scan blockers were recorded.

## Latest Closed Attempt
- parent batch: GLOBAL-TRAIN-EXECUTE-FROM-PK17-TO-COMPLETE-01
- selected child batch: PK21
- child prompt: prompts/batches/PK21.md
- child run dir: .codex/runs/PK21/20260512T035041Z
- child attempt number: 1
- status: green
- started: 2026-05-12T03:50:41Z
- completed: 2026-05-12T04:11:51Z
- next action: PK22 SideEffectLedger Foundation
- retry allowed: false
- reason: PK21 extracted the Time projection seam while preserving Plan as the internal compatibility owner; focused PlanFeatureServiceTests validation passed and no forbidden-claim scan blockers were recorded.

## State Rules
- A batch cannot be launched if the ledger already has the same batch active with status `running`, `unknown-unresolved`, `yellow-unresolved`, `red-unresolved`, `repair-required`, `finalization-required`, or `blocked`.
- A batch cannot be launched a second time from the same parent pass.
- A failed or unresolved batch requires a separately named repair/finalization prompt before another normal attempt.
- `UNKNOWN` child status is not permission to start another attempt.
- `UNKNOWN` must be treated as `unknown-unresolved` unless artifact inspection proves otherwise.
- A build lock or active conflicting runner/Codex/Xcode process state must be treated as `red-unresolved` or `blocked`.
- Green and accepted Yellow may continue only after proof path, owner, reason, no-claim boundary, retirement condition, and resume path are recorded where applicable.

## Attempt History
*(Older entries have been archived. See Archive Links below.)*

| Timestamp | Parent | Child | Attempt | Status | Proof Path | Next Action |
|---|---|---|---:|---|---|---|
| 2026-05-18T14:47:34Z | Post-PK | EFC14 | 1 | green | commit: d9a4137aa338571afc768d4f6a8bc95ac6dd0b9d | EFC15 |
| 2026-05-18T15:08:20Z | Post-PK | EFC15 | 1 | green | commit: 1eaf414dba7064d9b7793753ed7231d6ceca3cff | EFC16 |
| 2026-05-18T15:33:33Z | Post-PK | EFC16 | 1 | green | commit: 5e5b69bee824829d1095444ca3d340ed8da0ba3b | EFC17 |
| 2026-05-18T15:52:05Z | Post-PK | EFC17 | 1 | green | commit: 73fa2dbd3188b92aab1f44bcd506f661d696c64b | EFC18 |

## Archive Links
- [2026-05-18 Ledger Archive](../archive/train-attempt-ledgers/2026-05-18-ledger-archive.md)

## Rotation Policy
**Important**: This ledger must remain bounded to prevent excessive token context burns. Do not allow it to grow unbounded. When the active history exceeds ~5-10 entries or the file size approaches ~30KB, rotate older entries into a dated markdown file under `.codex/archive/train-attempt-ledgers/` and leave a link in the Archive Links section.

## Unresolved Recovery/Failure Notes
*(None currently active)*
