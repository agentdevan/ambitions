# Implementation Tasks

Use exact paths from `implementation/plan.md`; run focused checks and inspect
each task diff before continuing.

1. **Canon, schemas, predicates and profiles.** Add/update exact canon; add five
   schemas/four configs. Trace: `REQ-001` through `REQ-007`, `REQ-010` through
   `REQ-018`. Acceptance: fixed families/predicates/metadata/use profiles/
   forbidden propagation are strict and unknowns fail closed.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. **CIP version and CIP–SOC adapters.** Implement all CIP migration actions and
   many-to-many relevance with fixtures. Dependency: 1. Trace: `REQ-001` through
   `REQ-009`, `REQ-012`, `REQ-017`. Acceptance: exact version actions and non-
   claims survive; no generic equivalence/qualification.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. **O*NET-SOC and gated O*NET–ESCO.** Implement exact O*NET–SOC granularity and
   ESCO predicate/QA/right gates. Dependency: 1. Trace: `REQ-001` through
   `REQ-007`, `REQ-010`, `REQ-012`, `REQ-017`. Acceptance: no sibling inheritance;
   ESCO stays unavailable until exact rights/releases pass; related lower-QA is
   restricted.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. **Alignments and candidates.** Implement CTDL/CASE publisher rows and
   Wikidata/lexical/model candidate review records. Dependency: 1. Trace:
   `REQ-003` through `REQ-006`, `REQ-009`, `REQ-010`, `REQ-018`. Acceptance:
   source/review states stay distinct; candidate confidence never enables use.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. **No-inference validation, conflicts and coverage.** Implement exact-edge
   profiles, chain/cycle/inverse/claim leakage rejection, conflicts/no-match,
   coverage/diff and deterministic archive. Dependency: 2-4. Trace: all
   requirements. Acceptance: no derived consumer edge; reproducible bytes and
   exact denominators/hard gates. Tests: all foundry files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. **Native models, decoder and semantic parity.** Implement public models,
   decoder/validator. Dependency: 1-5. Trace: `REQ-001` through `REQ-013`,
   `REQ-016` through `REQ-018`. Acceptance: Python/Swift parity for every edge,
   state, profile, conflict and rejection.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. **Snapshot, migration, coordinator and purge.** Implement lifecycle and
   legacy candidate-only migration. Dependency: 6. Trace: `REQ-010` through
   `REQ-015`, `REQ-017`, `REQ-018`. Acceptance: atomic snapshots/LKG/replay,
   honest legacy state and complete resumable purge.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
8. **Exact query and dependency invalidation.** Implement indices, one-edge
   query/read client, public dependency index/notifier. Dependency: 7. Trace:
   `REQ-002` through `REQ-009`, `REQ-012`, `REQ-014`, `REQ-018`. Acceptance: no
   inference/traversal/private data; exact impacts notify without mutation.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
9. **Trust and accessibility.** Implement four files and inspection integration.
   Dependency: 8. Trace: `REQ-003` through `REQ-009`, `REQ-012`, `REQ-014`,
   `REQ-016`, `REQ-017`. Acceptance: source versus product use and all limits/
   conflicts/chains are fully accessible.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
10. **Resources, registry, project generation.** Generate/byte-review bootstrap,
    update refresh/scheduler/project and regenerate Xcode. Dependency: 1-9.
    Trace: all requirements. Acceptance: fixed public IDs, offline/LKG and
    measured device budgets.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
11. **Complete verification.** Run `implementation/verification.md`. Dependency:
    1-10. Trace: all requirements. Acceptance: all applicable semantic, source,
    rights, privacy, bias/dignity, recovery, accessibility, performance, build,
    simulator/device lanes pass; current acceptance/user transfer/release remain
    explicit N/A/insufficient.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| `REQ-001` | 1, 2, 3, 5, 6, 10, 11 |
| `REQ-002` | 1, 2, 3, 5, 6, 8, 11 |
| `REQ-003` | 1, 2, 3, 4, 5, 6, 8, 9, 11 |
| `REQ-004` | 1, 2, 3, 4, 5, 6, 9, 11 |
| `REQ-005` | 1, 4, 5, 6, 9, 11 |
| `REQ-006` | 1, 2, 3, 4, 5, 6, 8, 9, 11 |
| `REQ-007` | 1, 5, 6, 8, 11 |
| `REQ-008` | 2, 5, 6, 8, 11 |
| `REQ-009` | 2, 4, 5, 6, 8, 9, 11 |
| `REQ-010` | 1, 3, 4, 5, 7, 11 |
| `REQ-011` | 1, 5, 6, 8, 11 |
| `REQ-012` | 1, 2, 3, 5, 7, 8, 9, 11 |
| `REQ-013` | 1, 5, 6, 7, 11 |
| `REQ-014` | 1, 5, 7, 8, 9, 11 |
| `REQ-015` | 1, 7, 11 |
| `REQ-016` | 1, 6, 9, 11 |
| `REQ-017` | 1, 2, 3, 5, 6, 7, 9, 11 |
| `REQ-018` | 1, 4, 5, 6, 7, 8, 10, 11 |
