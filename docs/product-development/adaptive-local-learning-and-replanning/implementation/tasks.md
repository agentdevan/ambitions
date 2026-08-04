# Implementation Tasks

1. Canon/policy contracts/golden histories (REQ-001–004, 011, 014–017).
2. Owner adapters and private observation ledger (REQ-001, 005, 013–015).
3. Deterministic hypothesis/counterevidence/rebuild (REQ-002–004, 010–011).
4. Candidate review and command-only influence activation (REQ-003–007, 012,
   017).
5. Consumer capability views/use receipts (REQ-005–006, 010, 014).
6. Scoped correction/contradiction/expiry/reset (REQ-007, 010–013).
7. Dependency impact and non-mutating owner replan assembly (REQ-008–010).
8. Learning/replan controls and accessibility UI (REQ-006–007, 009–012, 017).
9. Migration/purge/security/resources/bootstrap (REQ-013–015; all integration).
10. Full verification and REQ-001–REQ-017 matrix; auto-active patterns,
    longitudinal benefit, canonical mutation, deployment/release remain ceilings.

Run focused checks and inspect each task diff.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design | Versioned policies/golden histories validate and contain only allowlisted categories, reasons, effects and expiry rules. |
| 2 | 1 | Adapters admit only named owner events, copy no private object bodies and deduplicate stable event IDs. |
| 3 | 1–2 | Incremental and rebuild results are deterministic; counterevidence/expiry work; output is candidate-only. |
| 4 | 3 | Only explicit preview/confirm commands activate influence; Not now/Not this/correction scopes are replay-safe. |
| 5 | 4 | Registered consumers receive minimal read-only views; use receipts expose no raw evidence and cannot mutate learning. |
| 6 | 3–5 | Corrections, contradictions, expiry, disable/reset/archive/delete rebuild exact affected state without Capability decay. |
| 7 | 5–6 | Impact is dependency-exact and every replan remains a non-authorized owner simulation/delta. |
| 8 | 4–7 | Controls, evidence/counterevidence, influence explanations and replans are complete, calm and accessible. |
| 9 | 1–8 | Migration/bootstrap/resources build; purge is deletion-terminal; network/private-content/command canaries remain clean. |
| 10 | 1–9 | REQ-001–REQ-017 matrix and privacy/security, accessibility, performance, device and longitudinal/user evidence are complete with conformance ceilings. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 2, 9, 10 |
| REQ-002 | 1, 3, 9, 10 |
| REQ-003 | 1, 3, 4, 9, 10 |
| REQ-004 | 1, 3, 4, 9, 10 |
| REQ-005 | 2, 5, 9, 10 |
| REQ-006 | 4, 5, 8, 9, 10 |
| REQ-007 | 4, 6, 8, 9, 10 |
| REQ-008 | 7, 9, 10 |
| REQ-009 | 7, 8, 9, 10 |
| REQ-010 | 3, 5, 6, 7, 9, 10 |
| REQ-011 | 1, 3, 6, 9, 10 |
| REQ-012 | 4, 6, 8, 9, 10 |
| REQ-013 | 2, 6, 9, 10 |
| REQ-014 | 1, 2, 5, 9, 10 |
| REQ-015 | 1, 2, 9, 10 |
| REQ-016 | 1, 9, 10 |
| REQ-017 | 1, 4, 8, 9, 10 |
