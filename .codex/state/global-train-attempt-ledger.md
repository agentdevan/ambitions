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
| Timestamp | Parent | Child | Attempt | Status | Proof Path | Next Action |
|---|---|---|---:|---|---|---|
| 2026-05-10T07:37:22Z | RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION | PK14 | 1 | yellow-unresolved | .codex/runs/PK14/20260510T073722Z/final-summary.md | Emit bounded repair; do not rerun from parent. |
| 2026-05-10T07:41:20Z | RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION | PK14 | 2 | red-unresolved | .codex/runs/PK14/20260510T074120Z/final-summary.md | Emit bounded repair; do not rerun from parent. |
| 2026-05-10T13:25:24Z | PK14-CONDUCTOR-REPAIR-01 | PK14 | 1 | green | .codex/runs/PK14/20260510T134429Z/final/03-review.final.md | PK14 consumed by clean top-level repair; do not rerun PK14. |
| 2026-05-10T14:58:52Z | RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION | PK15 | 2 | red-unresolved | .codex/runs/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION/20260510T145852Z/ | Parent conductor loop guard stopped nested PK15 churn; do not launch another nested child attempt. |
| 2026-05-10T15:12:22Z | top-level-runner | PK15 | 1 | finalization-required | .codex/runs/PK15/20260510T151222Z/final-summary.md | Run PK15-FINALIZE-01 to inspect existing diff/artifacts; do not rerun GPT-5.4-mini. |
| 2026-05-10T17:35:20Z | top-level-runner | PK15 | 1 | accepted-yellow | docs/audits/pk15-receipt-backend-report.md | PK15 focused receipt tests passed; one pre-existing external-surface expectation mismatch remains in `ExternalSurfaceVerificationChecklistTests` and is owned by QA / External Surface for follow-up. |
| 2026-05-10T18:28:20Z | top-level-runner | PK16 | 1 | green | docs/audits/pk16-trust-history-query-report.md | PK16 focused trust-history query tests passed; PK17 is next eligible. |
| 2026-05-11T14:00:21Z | GLOBAL-TRAIN-EXECUTE-FROM-PK17-TO-COMPLETE-01 | PK17 | 1 | green | docs/audits/pk17-batch-closeout-report.md | PK17 focused Today read-model tests passed; PK18 is next eligible. |
| 2026-05-12T04:11:51Z | GLOBAL-TRAIN-EXECUTE-FROM-PK17-TO-COMPLETE-01 | PK21 | 1 | green | docs/audits/pk21-batch-closeout-report.md | PK21 focused PlanFeatureServiceTests validation passed; PK22 is next eligible. |
| 2026-05-12T15:28:44Z | autonomous-train | PK28 | 1 | green | docs/audits/pk28-batch-closeout-report.md | PK28 focused command/policy tests passed and commit `1a5b758db2f08fcd06b59f3637ea38cd92b08854` was pushed; PK29 is next eligible. |
| 2026-05-12T16:25:00Z | fast-install-direct | PK29 | 1 | green | docs/audits/pk29-batch-closeout-report.md | PK29 focused entity-revision/tombstone tests passed and commit `cd5388c65ccceeeb3f8149e1ac792c60c0d63eb6` was pushed; PK30 is next eligible. |
| 2026-05-12T16:40:00Z | fast-install-direct | PK30 | 1 | green | docs/audits/pk30-batch-closeout-report.md | PK30 focused conflict-policy test passed and commit `3316296c5930341f4e9f1937e277826a419eaea7` was pushed; PK31 is next eligible. |
| 2026-05-12T16:52:00Z | fast-install-direct | PK31 | 1 | green | docs/audits/pk31-batch-closeout-report.md | PK31 focused portable snapshot test passed and commit `c3d2b246ab84caf031b2a48188eabbdc13c267cc` was pushed; PK32 is next eligible. |
| 2026-05-12T17:05:00Z | fast-install-direct | PK32 | 1 | green | docs/audits/pk32-batch-closeout-report.md | PK32 focused knowledge provider boundary test passed and commit `b618afe6f56980f7781d46f352455c92b809fc02` was pushed; PK33 is next eligible. |
| 2026-05-12T17:22:00Z | fast-install-direct | PK33 | 1 | green | docs/audits/pk33-batch-closeout-report.md | PK33 focused recommendation explanation model test passed; PK34 is next eligible. |
| 2026-05-12T17:36:00Z | fast-install-direct | PK34 | 1 | green | docs/audits/pk34-batch-closeout-report.md | PK34 focused runtime goal-intelligence service test passed; PK35 is next eligible. |
| 2026-05-12T17:50:00Z | fast-install-direct | PK35 | 1 | green | docs/audits/pk35-batch-closeout-report.md | PK35 focused large-store fixture generator test passed; PK36 is next eligible. |
| 2026-05-12T18:03:00Z | fast-install-direct | PK36 | 1 | green | docs/audits/pk36-batch-closeout-report.md | PK36 focused performance energy model test passed; PK37 is next eligible. |
| 2026-05-12T18:18:00Z | fast-install-direct | PK37 | 1 | green | docs/audits/pk37-batch-closeout-report.md | PK37 focused Today derived read-model cache test passed; PK38 is next eligible. |
| 2026-05-12T18:32:00Z | fast-install-direct | PK38 | 1 | green | docs/audits/pk38-batch-closeout-report.md | PK38 focused Domain package-boundary model test passed; PK39 is next eligible. |
| 2026-05-12T18:46:00Z | fast-install-direct | PK39 | 1 | green | docs/audits/pk39-batch-closeout-report.md | PK39 focused Storage package-boundary model test passed; PK40 is next eligible. |
| 2026-05-12T19:00:00Z | fast-install-direct | PK40 | 1 | green | docs/audits/pk40-batch-closeout-report.md | PK40 focused Runtime package-boundary model test passed; PK41 is next eligible. |
| 2026-05-12T19:14:00Z | fast-install-direct | PK41 | 1 | green | docs/audits/pk41-batch-closeout-report.md | PK41 focused Feature Engine package-boundary model test passed; SA07 is next eligible. |

## Post-PK State Advancement — 2026-05-12T19:24:59Z

- completed batch: SA07
- status: accepted_yellow
- commit: 30d5edb67342e2613db37481cce39140f97ef226
- next batch: SA08
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-12T20:09:17Z

- completed batch: SA08
- status: accepted_yellow
- commit: 47f6c4cb6189f7e6be1b1ccaf15c63f17fbc0e12
- next batch: SA09
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-12T20:44:21Z

- completed batch: SA09
- status: accepted_yellow
- commit: a2d3e6c74fdb40ea2da584bf3a6f92f04c6b151a
- next batch: SA10
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-12T21:30:33Z

- completed batch: SA10
- status: accepted_yellow
- commit: 0824729d9260deb6ed654efdda7b6901b43933af
- next batch: SA10A
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-12T22:02:29Z

- completed batch: SA10A
- status: accepted_yellow
- commit: bb54d9a5630e075396607f14903c048edf612ea0
- next batch: SA10B
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-12T22:35:43Z

- completed batch: SA10B
- status: accepted_yellow
- commit: 4b2770dcc761931d89da50ebe133d0925ecb2b08
- next batch: SA10C
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-12T23:04:10Z

- completed batch: SA10C
- status: accepted_yellow
- commit: e71836f251bfa1422045c2b6e598bc3777996668
- next batch: SA11
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-13T03:26:54Z

- completed batch: SA11
- status: accepted_yellow
- commit: 6faac9cc298f095d69dc4bc2d743ac09552d60b0
- next batch: SA12
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-13T04:20:37Z

- completed batch: SA12
- status: accepted_yellow
- commit: b22b9761976d78522b9cb69fa9693b0f11583069
- next batch: SA13
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-13T04:43:52Z

- completed batch: SA13
- status: accepted_yellow
- commit: 756e681b2877f05ecf9a80bc2519a16cbc4810af
- next batch: SA14
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-13T05:16:04Z

- completed batch: SA14
- status: accepted_yellow
- commit: 441a09f9d0f54eb02beec603fceef95b30e777ff
- next batch: SA15
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-13T05:52:20Z

- completed batch: SA15
- status: accepted_yellow
- commit: d4a1029a4cd5403ab78e10ded863de4abbbc20a3
- next batch: SA16
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-13T06:26:42Z

- completed batch: SA16
- status: accepted_yellow
- commit: 8a9237e40aaba9add82d09e70d9272aa79117bfe
- next batch: SA17
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T02:47:40Z

- completed batch: SA20
- status: green
- commit: 76c8bc4191b8cdfe0910336c8908d01a0b4a4aa3
- next batch: SA21
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T03:17:34Z

- completed batch: SA21
- status: green
- commit: b4a536be04d7605678417b85387f1749fcc21e71
- next batch: SA22
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T03:36:36Z

- completed batch: SA22
- status: accepted_yellow
- commit: b5861a3e1
- next batch: SA23
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T03:48:38Z

- completed batch: SA23
- status: accepted_yellow
- commit: b5ff63d6fb1de37728b51bfda37cc3710b9d2ee2
- next batch: SA24
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T04:00:40Z

- completed batch: SA24
- status: accepted_yellow
- commit: a904b2f815c7eb3168c827606102ab0b4436f39d
- next batch: SA25
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T04:19:40Z

- completed batch: SA25
- status: green
- commit: 85b41434c44e2b30bfbc257a8de85edab8349711
- next batch: SA26
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T04:49:27Z

- completed batch: SA26
- status: green
- commit: 6dff2f3e7
- next batch: SA27
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T05:21:15Z

- completed batch: SA27
- status: green
- commit: 32360ce5e63f47600be4dda5f914c0c89cb7f129
- next batch: SA28
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T22:49:23Z

- completed batch: SA28
- status: green
- commit: 7b4575f58ac4c107da17aa0092c5a4e38c292a3b
- next batch: SA29
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T22:50:59Z

- completed batch: SA29
- status: green
- commit: 8f2acb1f5c449aec3fee8bd2941f6e06f2c7c2fd
- next batch: SA30
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T22:52:11Z

- completed batch: SA30
- status: green
- commit: 477827fc1174b5809b509ec43dffed2646ed7506
- next batch: SA31
- mode: deterministic state advancement helper

## Post-PK State Advancement — 2026-05-15T22:53:14Z

- completed batch: SA31
- status: green
- commit: 45019ac78fb1efa7e93299c0b20e3dabc8178256
- next batch: SA32
- mode: deterministic state advancement helper
