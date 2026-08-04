# Implementation Tasks

1. Canon/contracts/artifact/provenance/release fixtures (REQ-001, 003–006, 017).
2. Pinned trust metadata/rotation/attack verifier (REQ-002, 016).
3. Domain semantic validator registry/receipts (REQ-003, 005, 009).
4. Compatibility graph/environment detector and evaluation gate (REQ-004, 006,
   008, 012, 017).
5. Change classifier/dependency impact/no-mutation notifier (REQ-005, 010–011).
6. Quarantine/content/attestation/generation stores and reader leases (REQ-001,
   007, 012–015).
7. Promotion/LKG/safe rollback/environment fallback (REQ-007–008, 012, 015).
8. Revocation/withdrawal/purge/incident recovery (REQ-002, 009, 015–016).
9. Trust inspection/change notes/accessibility/resources/project integration
   (REQ-011, 014, 017–018; all integration).
10. Full verification and REQ-001–REQ-018 evidence/security review; rollout/
    model/corpus task claims remain exact and no release/deployment is implied.

Run focused checks and inspect each task diff.

## Dependency and acceptance matrix

| Task | Depends on | Acceptance criteria |
|---|---|---|
| 1 | Approved Design and existing Foundry contracts | Deterministic manifests/provenance/releases reproduce and state the exact evidence level without replacing domain builders. |
| 2 | 1 | Root rotation requires sequential threshold checks; expiry/version/hash/length/role attacks fail closed with pinned authority. |
| 3 | 1–2 | Every domain validator is registered/versioned and emits semantic receipts separate from signature/provenance trust. |
| 4 | 1–3, evaluation contracts | Exact compatibility tuple and signed evaluation IDs gate activation; unevaluated OS/model changes disable or use an already approved fallback. |
| 5 | 3–4 | Diffs/impact are claim- and dependency-exact; private references remain opaque and notifications cannot mutate owners. |
| 6 | 2–5 | Quarantine/content/attestation/generation stores are immutable and content-addressed; leases prevent unsafe deletion; journals replay idempotently. |
| 7 | 4–6 | Promotion is atomic; rollback is a newly validated activation; unsafe LKG/downgrade and incompatible fallback are rejected. |
| 8 | 2–7 | Signed revocation/withdrawal disables exact unsafe purposes; purge/recovery preserve shared-reference and tombstone rules. |
| 9 | 1–8 | Trust/change/degraded views are accessible; bundled resources regenerate from `project.yml`; no dynamic code or private command boundary appears. |
| 10 | 1–9 | REQ-001–REQ-018 matrix and reproducibility, trust-attack, semantic, compatibility, privacy/security, accessibility, performance/device evidence are complete with exact release ceilings. |

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 6, 9, 10 |
| REQ-002 | 2, 8, 9, 10 |
| REQ-003 | 1, 3, 9, 10 |
| REQ-004 | 1, 4, 9, 10 |
| REQ-005 | 1, 3, 5, 9, 10 |
| REQ-006 | 1, 4, 9, 10 |
| REQ-007 | 6, 7, 9, 10 |
| REQ-008 | 4, 7, 9, 10 |
| REQ-009 | 3, 8, 9, 10 |
| REQ-010 | 5, 9, 10 |
| REQ-011 | 5, 9, 10 |
| REQ-012 | 4, 6, 7, 9, 10 |
| REQ-013 | 6, 9, 10 |
| REQ-014 | 6, 9, 10 |
| REQ-015 | 6, 7, 8, 9, 10 |
| REQ-016 | 2, 8, 9, 10 |
| REQ-017 | 1, 4, 9, 10 |
| REQ-018 | 9, 10 |
