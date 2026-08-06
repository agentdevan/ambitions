# Implementation Tasks

Every unqualified basename resolves to its exact repository path in
`implementation/plan.md`. Run focused tests and inspect the diff after each
task. Regenerate the Xcode project after each task that changes Swift or
resources once `project.yml` includes the resource directory.

1. **Canon, schemas, and fixed semantic policy.** Update/resolve the named canon
   files; add five foundry schemas and the three config policies. Dependency:
   approved Design. Trace: `REQ-001`, `REQ-002`, `REQ-009` through `REQ-014`,
   `REQ-017`, `REQ-019`. Acceptance: every source/release/member/field/claim/
   identity/right/eligibility has a strict contract, exact release placeholders
   must be resolved before build, and unknown members fail closed. Tests:
   schema cases in `test_education_corpus_release.py` and canon compiler tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. **CIP 2020 and source-value semantics.** Implement models, CIP adapter, full
   hierarchy/crosswalk fixtures, and reported/imputed/derived/suppressed/not-
   applicable/missing/revised value semantics. Dependency: Task 1. Trace:
   `REQ-001` through `REQ-003`, `REQ-013`, `REQ-014`. Acceptance: the full
   baseline hierarchy is accounted; split/combined relations never become
   identity; a CIP record cannot become an offering/competency. Tests:
   `test_education_corpus_cip_2020.py` and model schema cases.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. **IPEDS and College Scorecard adapters.** Implement exact release/file/field
   allowlists and fixtures for identity, mixed component years, completions,
   admissions, cost/aid, outcome measures, field/credential level, imputation,
   revision, small cohorts, and suppression. Dependency: Tasks 1-2. Trace:
   `REQ-001`, `REQ-003` through `REQ-006`, `REQ-013`, `REQ-014`, `REQ-018`.
   Acceptance: every value retains source definition/clock/population/state;
   completions never create current offerings; suppressed values never render,
   compare, or rank. Tests: IPEDS and Scorecard foundry test files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. **DAPIP and explicit identity assertions.** Implement DAPIP adapter and
   identity resolver with exact institution/program/site/agency/scope/action/
   dates/disclaimer plus confirmed, ambiguous, conflicting, merger/closure,
   superseded, and unmapped fixtures. Dependency: Tasks 1-3. Trace: `REQ-001`,
   `REQ-007` through `REQ-009`, `REQ-013`, `REQ-014`. Acceptance: recognition
   never inherits across scope and claims cannot traverse ambiguous/conflicting
   links. Tests: DAPIP and identity foundry test files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. **Rights, access, and CTDL/CASE fail-closed reservations.** Implement the
   rights engine, adapter reservations, and fixtures for individual access,
   bulk approval, research agreement, content-rights absent, attribution,
   transformation/retention, withdrawal, excluded assets, and publisher
   changes. Dependency: Task 1. Trace: `REQ-010` through `REQ-013`, `REQ-015`,
   `REQ-016`. Acceptance: technical parse/conformance cannot enable content;
   failures isolate affected records; withdrawal produces the exact purge plan.
   Tests: `test_education_corpus_rights.py` and release tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. **Foundry validation, coverage, diff, and archive builder.** Implement the
   remaining foundry modules/CLI and deterministic signed `.saec` generation.
   Dependency: Tasks 2-5. Trace: `REQ-001` through `REQ-018`, `REQ-020`.
   Acceptance: reproducible bytes, exact denominators, explicit identity and
   source-family shards, release diff/invalidation, evaluation bindings, and no
   partial/rights-blocked/regressive promotion. Tests: all eight foundry files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. **Native models, decoder, identity, and semantic parity.** Implement native
   data models, decoder, identity resolver, and semantic validator. Dependency:
   Tasks 1-6. Trace: `REQ-001` through `REQ-014`, `REQ-018`, `REQ-019`.
   Acceptance: Swift/Python accept/reject identical golden archives and produce
   matching count, identity, processing, suppression, recognition, rights, and
   eligibility results. Tests: models/decoder/semantic/identity native tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
8. **Snapshot store, migration, coordinator, and recovery.** Implement store,
   migration, coordinator, invalidation planner, reset, and purge on the public
   cache. Dependency: Task 7. Trace: `REQ-011`, `REQ-013` through `REQ-016`,
   `REQ-018`, `REQ-020`. Acceptance: immutable reads, atomic promotion, LKG,
   idempotent crash replay, corrupt-index rebuild, exact legacy supersession,
   and complete resumable rights purge. Tests: store, migration, coordinator,
   and invalidation/purge files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
9. **Local query and read-only consumer boundary.** Implement query index/actor,
   read client, runtime projection boundary, and bootstrap composition without
   a command/rank/model client. Dependency: Task 8. Trace: `REQ-002` through
   `REQ-009`, `REQ-012` through `REQ-017`, `REQ-019`. Acceptance: local search,
   paging, inspection, and same-definition comparison are deterministic and
   snapshot-bound; no private input, network, feedback, ranking, mutation, or
   external-action path exists. Tests: query/privacy boundary tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
10. **Inspection and accessibility.** Implement four Trust files and update the
    exact source inspection and You entry files. Dependency: Task 9. Trace:
    `REQ-002` through `REQ-010`, `REQ-013` through `REQ-017`. Acceptance: every
    source/value/identity/recognition/failure state and recovery is accessible,
    comprehensible, and free of ranking/prediction/endorsement overclaim. Tests:
    inspection, accessibility, and UI files.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
11. **Bundled bootstrap, refresh registry, and project generation.** Generate
    and byte-review bootstrap JSON/archive; update fixed refresh entries,
    lifecycle scheduler, `project.yml`, and generated project. Dependency:
    Tasks 1-10. Trace: `REQ-001` through `REQ-020`. Acceptance: clean install
    works offline; all remote IDs are fixed public release IDs; no user/location
    partition exists; resource/archive/storage budgets are measured against
    approved evidence. Tests: decoder/store/coordinator/privacy/resource-bundle
    integration.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
12. **Portfolio evaluation and complete verification.** Run every ordinary and
    adversarial fixture plus all commands/evidence lanes in
    `implementation/verification.md`. Dependency: Tasks 1-11. Trace: all
    `REQ-001` through `REQ-020`. Acceptance: applicable source, rights,
    identity, privacy/security, failure, migration, accessibility, performance,
    build, simulator, and physical-device lanes are green; recommendation,
    current offerings, CTDL/CASE unapproved content, direct-user usefulness,
    merge, deployment, and release remain explicit N/A or insufficient.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| `REQ-001` | 1, 2, 3, 4, 6, 7, 11, 12 |
| `REQ-002` | 1, 2, 6, 7, 9, 10, 11, 12 |
| `REQ-003` | 2, 3, 6, 7, 9, 12 |
| `REQ-004` | 3, 6, 7, 9, 10, 12 |
| `REQ-005` | 3, 6, 7, 9, 10, 12 |
| `REQ-006` | 3, 6, 7, 9, 10, 12 |
| `REQ-007` | 4, 6, 7, 9, 10, 12 |
| `REQ-008` | 4, 6, 7, 9, 10, 12 |
| `REQ-009` | 1, 4, 6, 7, 9, 10, 12 |
| `REQ-010` | 1, 5, 6, 7, 10, 12 |
| `REQ-011` | 1, 5, 6, 8, 12 |
| `REQ-012` | 1, 5, 6, 7, 9, 12 |
| `REQ-013` | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12 |
| `REQ-014` | 1, 2, 3, 4, 6, 7, 8, 9, 10, 12 |
| `REQ-015` | 5, 6, 8, 12 |
| `REQ-016` | 5, 8, 9, 12 |
| `REQ-017` | 1, 9, 10, 12 |
| `REQ-018` | 3, 6, 7, 8, 11, 12 |
| `REQ-019` | 1, 7, 9, 11, 12 |
| `REQ-020` | 6, 8, 11, 12 |
