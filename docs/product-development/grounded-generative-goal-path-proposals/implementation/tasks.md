# Implementation Tasks

1. Canon/task contracts and NASA/sparse fixtures (REQ-002–008, 015–017).
2. Evidence graph/adapters/semantic classifier (REQ-001–004, 006–008).
3. Alias task and private runtime composer (REQ-005, 007, 013, 015).
4. Ordered validation/security pipeline (REQ-002–008, 015–016).
5. Proposal repository/coordinator/progressive projection (REQ-007, 009,
   013–014, 017).
6. Semantic delta/invalidation preserving completion (REQ-008, 012–014).
7. Comparison and activation handoffs with no mutation (REQ-010–011).
8. Review/delta/accessibility UI (REQ-006–009, 012–013, 017).
9. Integration/resources/project regeneration if required (all requirements).
10. Full verification and REQ-001–REQ-017 evidence matrix; keep unsupported
    corpora, canonical adoption, scheduling, device breadth and release ceilings.

Run focused tests and inspect each task diff before proceeding.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design and approved destination input contract | Canon, schemas and NASA/sparse fixtures parse with no canonical-object, placement or command output fields. |
| 2 | 1 | Graph construction is deterministic, typed, source-bound and preserves private unknowns without inferring satisfaction. |
| 3 | 2, private-runtime contract | Composer accepts only graph aliases/registered generic slots and deterministic/manual fallback remains available. |
| 4 | 2–3 | Invalid aliases, facts, graph logic, source authority, private claims and prohibited copy are rejected within resource budgets. |
| 5 | 2–4 | Revision capture, cancellation, retry, partial projection and lifecycle replay discard stale work and never auto-activate. |
| 6 | 5 | Semantic deltas explain retained/moved/conditional/added/unsupported nodes and preserve completed/history state. |
| 7 | 5–6 | Comparison names differences without a winner; activation input is non-authorized and owner-revalidated. |
| 8 | 5–7 | Overview/detail/delta/correction flows expose complete ordered and accessible meanings at supported sizes. |
| 9 | 1–8 | Boundary/bootstrap/resource integration builds from generated project state and mutation spies remain clean. |
| 10 | 1–9 | REQ-001–REQ-017 matrix, focused/full tests and privacy, security, accessibility, performance and device evidence are complete with exact ceilings. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 2, 9, 10 |
| REQ-002 | 1, 2, 4, 9, 10 |
| REQ-003 | 1, 2, 4, 9, 10 |
| REQ-004 | 1, 2, 4, 9, 10 |
| REQ-005 | 1, 3, 9, 10 |
| REQ-006 | 1, 2, 8, 9, 10 |
| REQ-007 | 1, 2, 3, 4, 5, 9, 10 |
| REQ-008 | 1, 2, 4, 5, 6, 9, 10 |
| REQ-009 | 5, 8, 9, 10 |
| REQ-010 | 7, 9, 10 |
| REQ-011 | 7, 9, 10 |
| REQ-012 | 6, 8, 9, 10 |
| REQ-013 | 3, 5, 6, 8, 9, 10 |
| REQ-014 | 5, 6, 9, 10 |
| REQ-015 | 1, 3, 4, 9, 10 |
| REQ-016 | 1, 4, 9, 10 |
| REQ-017 | 1, 5, 8, 9, 10 |
