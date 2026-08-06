# Implementation Tasks

1. Canon and registered task contract (REQ-003–006, 010, 015).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Interpretation models/repository/correction flow (REQ-001–002, 008, 011,
   014, 016); exact statement and facets must remain separate.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Career/education/hobby providers and closed candidate bundle (REQ-003–009);
   no provider receives private context.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Identity/source/route/transfer/constraint/current validators (REQ-003–010,
   015); reject minted IDs and unsupported prose.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Private-runtime composition and semantic renderer (REQ-005–006, 010, 013);
   alias-only output and deterministic fallback.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. Proposal repository/coordinator/invalidation/purge (REQ-011, 013–015);
   stale async discard and deletion terminality.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. Comparison, inspection and correction UI (REQ-001, 004–011, 013, 016).
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
8. Adoption-input builder and owner revalidation integration (REQ-012); prove no
   command/client path from generation.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
9. Integration/resources/project generation (all requirements).
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
10. Run full verification (all requirements); source breadth, path generation,
    Goal mutation, hosted mode, deployment and release remain explicit ceilings.

Each task runs focused tests and diff inspection. Requirements not explicitly
listed on a task are covered by tasks 9–10; task 10 must produce a complete
REQ-001–REQ-016 evidence matrix.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Canon and versioned task schemas agree; golden fixtures parse; no command field exists. |
| 2 | 1 | Interpretation revisions preserve exact user text, explicit facets and correction history; stale writes are rejected. |
| 3 | 1–2 | Every provider returns only admitted public identities; private context is joined locally; sparse coverage is explicit. |
| 4 | 3 | Minted IDs, unsupported claims, false route/transfer semantics and stale current claims fail deterministically. |
| 5 | 3–4, private-runtime contract | Model input is alias-only, fallback remains usable, and rendered facts cannot exceed validated semantics. |
| 6 | 2–5 | Captured-revision mismatch discards output; retry/save/delete/purge are idempotent and deletion-terminal. |
| 7 | 6 | All evidence/unknown/correction states have ordered accessible projections and non-shaming recovery. |
| 8 | 6 | Adoption receives a non-authorized typed input, revalidates current evidence and exposes no generation-to-command path. |
| 9 | 1–8 | Bootstrap/resources compile from `project.yml`; integration tests prove boundary wiring and no private data enters public retrieval. |
| 10 | 1–9 | Every REQ has passing test evidence; build, privacy/security, accessibility, performance and device results retain their exact claim ceilings. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 2, 7, 9, 10 |
| REQ-002 | 2, 9, 10 |
| REQ-003 | 1, 3, 4, 9, 10 |
| REQ-004 | 1, 3, 4, 7, 9, 10 |
| REQ-005 | 1, 3, 4, 5, 7, 9, 10 |
| REQ-006 | 1, 3, 4, 5, 7, 9, 10 |
| REQ-007 | 3, 4, 7, 9, 10 |
| REQ-008 | 2, 3, 4, 7, 9, 10 |
| REQ-009 | 3, 4, 7, 9, 10 |
| REQ-010 | 1, 4, 5, 7, 9, 10 |
| REQ-011 | 2, 6, 7, 9, 10 |
| REQ-012 | 8, 9, 10 |
| REQ-013 | 5, 6, 7, 9, 10 |
| REQ-014 | 2, 6, 9, 10 |
| REQ-015 | 1, 4, 6, 9, 10 |
| REQ-016 | 2, 7, 9, 10 |
