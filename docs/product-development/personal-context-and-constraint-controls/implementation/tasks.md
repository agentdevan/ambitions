# Implementation Tasks

1. Canon and typed fact/grant contracts (REQ-001–006, 014–017).
2. Protected repository/events/migration (REQ-001–006, 013–015).
3. Unit/timezone resolver and precedence/conflict engine (REQ-002, 008, 014).
4. Capability-scoped ephemeral read clients (REQ-005–009, 015).
5. Task-local override and influence receipts (REQ-010–011, 015–016).
6. Dependency impact/mutation/archive/reset/purge (REQ-012–013).
7. Context library and progressive capture UI (REQ-003, 005–006, 010–013, 016).
8. Disabled suggestion-policy seam and conformance harness (REQ-004, 017).
9. Bootstrap/project integration and cross-consumer contract tests (all REQs).
10. Full verification with REQ-001–REQ-017 matrix; imports, suggestion defaults,
    usefulness, external processing, deployment and release remain claim ceilings.

Run focused checks and inspect each task diff before continuing.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Typed values, explicit unknown states and separate purpose grants compile with no inference/enumeration API. |
| 2 | 1 | Immutable events round-trip; admissible legacy values migrate without mining behavior; journaled purge is deletion-terminal. |
| 3 | 1–2 | Precedence/conflict, units, recurrence, calendar and timezone behavior pass deterministic locale/DST matrices. |
| 4 | 2–3 | Registered consumers receive only purpose/category-minimal expiring views and cannot enumerate or write facts. |
| 5 | 4 | Task-local overrides do not alter the registry; influence receipts retain opaque reason/effect evidence without sensitive values. |
| 6 | 2, 5 | Impact previews are exact; disable/archive/reset/delete notify owners without mutating them; purge removes every scoped copy. |
| 7 | 2–6 | Capture remains skippable and all fact/conflict/influence/lifecycle states are accessible, localized and non-shaming. |
| 8 | 1, 4 | Suggestion client is structurally disabled; conformance proves no implicit fact/influence activation. |
| 9 | 1–8 | Typed boundary/bootstrap integration builds; all initial consumers pass no-enumeration, stale-view and no-write contract tests. |
| 10 | 1–9 | REQ-001–REQ-017 evidence and migration, privacy/security, accessibility, performance, device and user-study gates are recorded without overclaiming. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 2, 9, 10 |
| REQ-002 | 1, 2, 3, 9, 10 |
| REQ-003 | 1, 7, 9, 10 |
| REQ-004 | 1, 8, 9, 10 |
| REQ-005 | 1, 4, 7, 9, 10 |
| REQ-006 | 1, 7, 9, 10 |
| REQ-007 | 4, 9, 10 |
| REQ-008 | 3, 4, 9, 10 |
| REQ-009 | 4, 9, 10 |
| REQ-010 | 5, 7, 9, 10 |
| REQ-011 | 5, 7, 9, 10 |
| REQ-012 | 6, 7, 9, 10 |
| REQ-013 | 2, 6, 9, 10 |
| REQ-014 | 1, 2, 3, 9, 10 |
| REQ-015 | 1, 2, 4, 5, 9, 10 |
| REQ-016 | 1, 5, 7, 9, 10 |
| REQ-017 | 1, 8, 9, 10 |
