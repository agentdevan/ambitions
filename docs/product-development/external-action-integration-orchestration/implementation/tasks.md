# Implementation Tasks

1. Canon/adapter contracts/calendar/fake-provider fixtures (REQ-001–006, 015–017).
2. Intent/draft/payload/preflight/preview (REQ-002–004, 011, 017).
3. Separate action authorization and account/credential/OAuth fake harness
   (REQ-005–006, 012–015).
4. Adapter protocol/empty remote registry/Calendar editor adapter (REQ-001, 007,
   011, 016).
5. Protected outbox/idempotency/journal/execution (REQ-007–009, 012).
6. Result/reconciliation/owner notification/receipts (REQ-008–010, 012).
7. Disconnect/revoke/local purge and unknown recovery record (REQ-013–015).
8. Action Center/preview/progress/settings accessibility UI (REQ-004–005,
   008–009, 013–017).
9. Bootstrap/project permission generation and integration tests (all REQs).
10. Full verification/REQ-001–REQ-017 matrix; remote/high-consequence actions,
    external success/undo, deployment and release remain ceilings.

Run focused tests and inspect each task diff.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Schemas/fixtures parse, zero remote adapters are enabled and fake-provider faults are reproducible. |
| 2 | 1 | Draft/preflight/preview binds exact target, diff, risk, reversibility, source and unknowns without executable authority. |
| 3 | 2 | Connection permission and one-action authorization remain separate; credentials are Keychain-referenced and fake OAuth enforces PKCE/callback rules. |
| 4 | 1–3 | Adapter has no generic HTTP method; Calendar opens the system editor and treats dismissal/save as user/system outcomes, not claimed remote success. |
| 5 | 2–4 | Outbox is encrypted/minimal/idempotency-bound; crash/retry never silently duplicates and unknown outcome remains durable. |
| 6 | 5 | Result/reconciliation/receipts are provenance-bound; owner notification is non-mutating and requires owner revalidation. |
| 7 | 3, 5–6 | Disconnect/revoke/purge removes scoped local secrets/data while retaining only minimum unresolved recovery truth. |
| 8 | 2–7 | Preview/progress/unknown/recovery/settings states are complete, accessible and never hide external effect uncertainty. |
| 9 | 1–8 | Generated permission/bootstrap integration builds; network/command/provider-admission tests preserve zero-enabled-remote state. |
| 10 | 1–9 | REQ-001–REQ-017 matrix, threat/fault/privacy/security/accessibility/performance/device evidence are complete with no external-success claim. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 4, 9, 10 |
| REQ-002 | 1, 2, 9, 10 |
| REQ-003 | 1, 2, 9, 10 |
| REQ-004 | 1, 2, 8, 9, 10 |
| REQ-005 | 1, 3, 8, 9, 10 |
| REQ-006 | 1, 3, 9, 10 |
| REQ-007 | 4, 5, 9, 10 |
| REQ-008 | 5, 6, 8, 9, 10 |
| REQ-009 | 5, 6, 8, 9, 10 |
| REQ-010 | 6, 9, 10 |
| REQ-011 | 2, 4, 9, 10 |
| REQ-012 | 3, 5, 6, 9, 10 |
| REQ-013 | 1, 3, 7, 8, 9, 10 |
| REQ-014 | 3, 7, 9, 10 |
| REQ-015 | 1, 3, 7, 8, 9, 10 |
| REQ-016 | 1, 4, 8, 9, 10 |
| REQ-017 | 1, 2, 8, 9, 10 |
