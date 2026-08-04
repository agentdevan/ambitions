# Implementation Tasks

1. **Canon and task bundle Foundry.** Add canon, contracts, config, linter,
   deterministic compiler and fixtures. Trace: REQ-001, 008–010, 015–017.
2. **Native task registry and mode policy.** Implement registry parity,
   availability and content-blind routing. Dependency: 1. Trace: REQ-001–003,
   013, 015, 017. Acceptance: unknown tuple unavailable; no silent escalation.
3. **Context and consent.** Implement owner field clients, capsule minimization,
   preview and scoped consent. Dependency: 2. Trace: REQ-004–006, 014, 018.
4. **Read-only tools.** Implement typed registry/gateway/budgets/revision checks.
   Dependency: 1–3. Trace: REQ-007, 016. Acceptance: no write/arbitrary graph.
5. **Envelope and deterministic validation.** Implement ordered validators and
   feature handoff. Dependency: 1–4. Trace: REQ-008–009, 012, 016.
6. **Adapters.** Implement deterministic fake and on-device adapter; compile PCC
   behind unavailable gates; keep hosted registry empty. Dependency: 2–5. Trace:
   REQ-002–003, 006, 008, 013, 017.
7. **Sessions, cancellation and repair.** Implement actor/event stream, bounded
   repair, stale-revision rejection and recovery. Dependency: 5–6. Trace:
   REQ-010, 013, 016.
8. **Receipts, change invalidation and purge.** Implement no-payload receipts,
   compatibility invalidation and scoped deletion. Dependency: 1–7. Trace:
   REQ-014–015.
9. **Disclosure and accessibility UI.** Implement context/mode/progress/result/
   failure/clear projections. Dependency: 3–8. Trace: REQ-004, 011, 013–014, 018.
10. **Resources and integration.** Generate/byte-review registry, update project
    and runtime bootstrap/boundaries. Dependency: 1–9. Trace: all requirements.
11. **Full verification.** Run `implementation/verification.md`. Dependency:
    1–10. Acceptance: all relevant lanes pass; PCC/provider/feature usefulness,
    canonical mutation, deployment and release remain N/A/insufficient.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Task bundles compile deterministically; schemas/prompts reject unregistered fields, commands, sensitive leakage and unsupported claims. |
| 2 | 1 | Registry/runtime tuples match Foundry bytes; unavailable capabilities fail closed and content-blind routing never silently escalates modes. |
| 3 | 2 | Capsules contain only registered minimal fields; preview/consent is purpose- and revision-bound; denied fields are absent, not guessed. |
| 4 | 1–3 | Tools are typed/read-only, revision-checked and budgeted; arbitrary graph/network/write access is structurally unavailable. |
| 5 | 1–4 | Untrusted output cannot cross the boundary until schema, ID, source, invariant, claim, privacy and security validators pass in order. |
| 6 | 2–5 | Fake/on-device modes obey the same contract; PCC remains gated and hosted-provider registry contains zero configured providers. |
| 7 | 5–6 | Sessions serialize revisions, cancellation is terminal, repair is bounded and stale/partial output cannot be accepted or resumed silently. |
| 8 | 1–7 | Receipts retain no payload/private text; compatibility changes invalidate exact work; clear/purge is scoped, idempotent and deletion-terminal. |
| 9 | 3–8 | Context/mode/progress/failure/correction/clear states are inspectable, skippable where allowed and fully accessible without privacy leakage. |
| 10 | 1–9 | Signed registry resources and generated project compile; runtime exposes only the typed read/result boundary and no command/external client. |
| 11 | 1–10 | REQ-001–REQ-018 matrix and deterministic, build, privacy/security, accessibility, performance, device/model evidence are complete with PCC/provider/usefulness ceilings. |

## Requirement traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 2, 10, 11 |
| REQ-002 | 2, 6, 11 |
| REQ-003 | 2, 6, 11 |
| REQ-004 | 3, 9, 11 |
| REQ-005 | 3, 11 |
| REQ-006 | 3, 6, 11 |
| REQ-007 | 4, 11 |
| REQ-008 | 1, 5, 6, 11 |
| REQ-009 | 1, 5, 11 |
| REQ-010 | 1, 7, 11 |
| REQ-011 | 9, 11 |
| REQ-012 | 5, 11 |
| REQ-013 | 2, 6, 7, 9, 11 |
| REQ-014 | 3, 8, 9, 11 |
| REQ-015 | 1, 2, 8, 11 |
| REQ-016 | 1, 4, 5, 7, 11 |
| REQ-017 | 1, 2, 6, 11 |
| REQ-018 | 3, 9, 11 |
