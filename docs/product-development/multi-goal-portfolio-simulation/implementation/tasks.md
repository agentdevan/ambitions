# Implementation Tasks

1. Canon/contracts/fixtures/signed activation gate (REQ-003–006, 014–016).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Explicit-selection snapshot and owner consistency barrier (REQ-001–002, 012).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Heterogeneous resource ledger/double-count validator (REQ-003, 007, 009).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Scenario assumptions/deterministic engine/stable validation (REQ-004–007).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Sensitivity and explanation (REQ-006, 008–010, 015).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. Private repository/invalidation/migration/purge (REQ-012–013).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. Command-free owner bundles/Life Branch escalation (REQ-011).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
8. Conformance and production-gated accessible UI (REQ-009, 014–016).
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
9. Integration/resources/project regeneration if required (all REQs).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
10. Full verification/REQ-001–REQ-016 matrix; production remains unavailable
    until exact gate evidence passes, regardless of unit/build success.

Run focused checks and inspect each task diff.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Schemas/fixtures validate and the signed gate defaults closed unless exact evidence IDs satisfy policy. |
| 2 | 1, typed Goal/Path/Context/Capability/current projections | Only explicitly selected Goals enter one consistent captured-revision snapshot; stale owners fail closed. |
| 3 | 2 | Time, money, place, equipment, context, opportunity, people and capability remain distinct; shared amounts cannot double-count. |
| 4 | 2–3 | Scenario ordering/results are deterministic, assumption-bound and contain no probability, winner or cross-dimension arithmetic. |
| 5 | 4 | One-field sensitivity produces exact semantic diffs and every consequence has an inspectable reason/source/unknown binding. |
| 6 | 2–5 | Invalidation is narrow; archive/delete/purge are replay-safe and cannot affect canonical owner state. |
| 7 | 5–6 | Owner bundles and Life Branch escalation contain only typed non-authorized draft inputs and current expected revisions. |
| 8 | 1–7 | Conformance UI is fully accessible; production entry remains unavailable while the evidence gate is closed. |
| 9 | 1–8 | Read-only boundary/bootstrap/resource integration builds with zero command clients. |
| 10 | 1–9 | REQ-001–REQ-016 matrix, fault/performance/device/accessibility/privacy/security checks and exact gate/user evidence are recorded without production overclaim. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 2, 9, 10 |
| REQ-002 | 2, 9, 10 |
| REQ-003 | 1, 3, 9, 10 |
| REQ-004 | 1, 4, 9, 10 |
| REQ-005 | 1, 4, 9, 10 |
| REQ-006 | 1, 4, 5, 9, 10 |
| REQ-007 | 3, 4, 9, 10 |
| REQ-008 | 5, 9, 10 |
| REQ-009 | 3, 5, 8, 9, 10 |
| REQ-010 | 5, 9, 10 |
| REQ-011 | 7, 9, 10 |
| REQ-012 | 2, 6, 9, 10 |
| REQ-013 | 6, 9, 10 |
| REQ-014 | 1, 8, 9, 10 |
| REQ-015 | 1, 5, 8, 9, 10 |
| REQ-016 | 1, 8, 9, 10 |
