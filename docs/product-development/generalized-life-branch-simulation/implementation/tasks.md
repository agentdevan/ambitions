# Implementation Tasks

1. Canon/protocol contracts/fixtures/activation gate (REQ-001–007, 014–016).
2. Qualifier/consistent complete snapshot/branch simulation (REQ-001–002, 006).
3. Dependency/reversibility/completeness/security validation (REQ-002, 004–007).
4. Owner participant registry and opaque prepare tokens (REQ-003, 008–009, 012).
5. Proven shared atomic coordinator (REQ-008–010, 012).
6. Journaled saga/compensation/relaunch/reconciliation (REQ-009–012).
7. External intent-only handoff (REQ-005, 011–013).
8. Repository/migration/invalidation/delete/purge (REQ-012–013).
9. Accessible compare/confirm/progress/recovery UI and integration (all REQs).
10. Full phase-fault/REQ-001–REQ-016 verification; production gate must remain
    closed absent exact upstream/user evidence.

Run focused tests and inspect each task diff.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Versioned protocols/fault fixtures validate and signed activation gate remains closed absent exact evidence. |
| 2 | 1, portfolio/owner read contracts | Qualification rejects incomplete owners; snapshot is consistent, complete and revision-bound. |
| 3 | 2 | Graph/semantic checks prove dependency completeness, bounded resources and declared reversibility/compensation without model authority. |
| 4 | 1–3 | Each admitted owner implements the typed protocol and returns opaque branch/plan/revision/expiry-bound prepared tokens. |
| 5 | 4 | Atomic mode is selected only for one proven transaction domain and passes every phase-fault test without partial visibility. |
| 6 | 4 | Saga prepares first, commits topologically, compensates safely, persists unknowns and reconciles idempotently after relaunch. |
| 7 | 2–6 | External effects become non-executable draft inputs only and require the separate external-action owner. |
| 8 | 2–7 | Migration is lossless-or-inspection-only; invalidation/delete/purge preserve recovery truth and never mutate owners. |
| 9 | 1–8 | Compare/confirm/progress/recovery states are accessible and integration exposes no generic repository or write client. |
| 10 | 1–9 | REQ-001–REQ-016 matrix and exhaustive phase-fault, privacy/security, accessibility, performance/device evidence are complete; gate claim remains conformance-only. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 2, 9, 10 |
| REQ-002 | 1, 2, 3, 9, 10 |
| REQ-003 | 1, 4, 9, 10 |
| REQ-004 | 1, 3, 9, 10 |
| REQ-005 | 1, 7, 9, 10 |
| REQ-006 | 1, 2, 3, 9, 10 |
| REQ-007 | 1, 3, 9, 10 |
| REQ-008 | 4, 5, 9, 10 |
| REQ-009 | 4, 5, 6, 9, 10 |
| REQ-010 | 5, 6, 9, 10 |
| REQ-011 | 6, 7, 9, 10 |
| REQ-012 | 4, 5, 6, 8, 9, 10 |
| REQ-013 | 7, 8, 9, 10 |
| REQ-014 | 1, 9, 10 |
| REQ-015 | 1, 9, 10 |
| REQ-016 | 1, 9, 10 |
