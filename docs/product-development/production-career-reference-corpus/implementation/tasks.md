# Implementation Tasks

Every unqualified basename resolves to its exact repository path in
`implementation/plan.md`. Run the task's focused tests and inspect its diff
before continuing. Regenerate the Xcode project after each task that changes
Swift or resources once `project.yml` includes the resource directory.

1. **Canon, schemas, and fixed source policy.** Add/update the named canon files,
   four foundry schemas, two config files, bootstrap manifest contract, and
   normative O*NET file/eligibility matrix. Dependency: approved Design. Trace:
   `REQ-001`, `REQ-003`, `REQ-005`, `REQ-008`, `REQ-009`, `REQ-012`, `REQ-019`.
   Acceptance: every source/release/member/claim family/right/eligibility has a
   strict schema and unknown members fail closed. Tests: schema cases in
   `test_career_corpus_release.py` and canon compiler tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. **O*NET 30.3 adapter and rights.** Implement source manifest, O*NET adapter,
   rights policy, and fixtures for ordinary software developer, regulated RN,
   competitive astronaut-adjacent identities, title-only, aggregate, `all
   other`, military, missing, malformed, private-canary, external-member, and
   rights-blocked cases. Dependency: Task 1. Trace: `REQ-001` through `REQ-004`,
   `REQ-007`, `REQ-008`, `REQ-013`, `REQ-015`. Acceptance: all 1,016 identities
   and every normative file are accounted; values/scales round-trip; restricted
   categories cannot widen eligibility. Tests:
   `test_career_corpus_onet_30_3.py` and `test_career_corpus_rights.py`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. **BLS source adapters.** Implement SOC, OOH/EP, OEWS, and ORS adapters plus
   fixtures for separate clocks, geography/population, point/range/SE,
   suppression/footnotes, preliminary/final, missing, stale, conflict, and
   source correction. Dependency: Task 1. Trace: `REQ-001`, `REQ-005` through
   `REQ-008`, `REQ-010`, `REQ-012`. Acceptance: source families cannot overwrite
   one another; every statistical value retains method and limitation; typical
   preparation never becomes a gate. Tests:
   `test_career_corpus_bls_overlays.py` and rights cases.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. **Foundry validation, coverage, diff, and release builder.** Implement the
   remaining foundry modules/CLI and signed deterministic archive generation.
   Dependency: Tasks 2-3. Trace: `REQ-001` through `REQ-013`, `REQ-018` through
   `REQ-020`. Acceptance: reproducible bytes, 23 SOC shards plus metadata/
   identity, exact coverage denominators, release diff/invalidation, hard-gate
   evaluation bindings, and no promotion of partial/rights-blocked/regressive
   output. Tests: all five career foundry test files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. **Native models, decoder, and semantic parity.** Implement identity,
   descriptor, statistical, rights, coverage, manifest models, decoder, and
   semantic validator. Dependency: Tasks 1-4. Trace: `REQ-001` through `REQ-008`,
   `REQ-012`, `REQ-013`, `REQ-015`, `REQ-019`. Acceptance: Swift and Python
   accept/reject identical golden manifests and produce matching identity,
   coverage, scale, statistical, rights, and eligibility accounting. Tests:
   `CareerCorpusModelsTests.swift`, `CareerCorpusArtifactDecoderTests.swift`, and
   `CareerCorpusSemanticValidatorTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. **Snapshot store, migration, coordinator, and recovery.** Implement the store,
   migration, coordinator, invalidation planner, and rights purge service on the
   existing public cache boundary. Dependency: Task 5. Trace: `REQ-009` through
   `REQ-012`, `REQ-016`, `REQ-018`. Acceptance: immutable snapshot reads,
   atomic promotion, last-known-good, idempotent resume, corrupt-index rebuild,
   legacy-pack supersession without reinterpretation, and complete resumable
   purge. Tests: store, migration, coordinator, and invalidation/purge test files.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. **Local query and read-only consumer boundary.** Implement query index/actor,
   read client, runtime projection boundary, and bootstrap composition without a
   command client. Dependency: Task 6. Trace: `REQ-002` through `REQ-007`,
   `REQ-009`, `REQ-012` through `REQ-016`. Acceptance: local search/paging and
   exact claim queries are deterministic and snapshot-bound; no private input,
   network, feedback, recommendation, or mutation path exists. Tests:
   `CareerCorpusQueryTests.swift` and privacy boundary tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
8. **Inspection and accessibility.** Implement the four Trust files, extend
   source inspection and the existing You entry without a new root. Dependency:
   Task 7. Trace: `REQ-002` through `REQ-008`, `REQ-010`, `REQ-012`, `REQ-015`
   through `REQ-017`. Acceptance: every source/statistical/failure state and its
   recovery is comprehensible with full assistive/accessibility behavior and no
   score/fit/gate overclaim. Tests: inspection, accessibility, and UI test files.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
9. **Bundled base, refresh registry, and project generation.** Generate and
   byte-review the bootstrap JSON and `.sacp`, update fixed refresh entries,
   lifecycle scheduler, `project.yml`, and generated project. Dependency: Tasks
   1-8. Trace: `REQ-001` through `REQ-012`, `REQ-016`, `REQ-018`, `REQ-019`.
   Acceptance: clean install and upgrade expose all O*NET identities offline;
   BLS requests use fixed public IDs; no user/location-derived request exists;
   bundle/archive sizes are measured and within approved measured budgets.
   Tests: decoder/store/coordinator/privacy and resource-bundle integration.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
10. **Portfolio evaluation and complete verification.** Run ordinary,
    regulated, competitive, title-only, aggregate, sparse, suppressed,
    preliminary, stale, conflict, rights-blocked, offline, rollback, and purge
    cases plus every command/evidence lane in `implementation/verification.md`.
    Dependency: Tasks 1-9. Trace: all `REQ-001` through `REQ-020`. Acceptance:
    every applicable source, rights, coverage, privacy/security, regression,
    accessibility, performance, build, simulator, and physical-device lane is
    green; recommendation/model/ESCO/current-opportunity/direct-user/release
    evidence remains explicitly N/A or insufficient.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| `REQ-001` | 1, 2, 3, 4, 5, 9, 10 |
| `REQ-002` | 2, 4, 5, 7, 8, 9, 10 |
| `REQ-003` | 1, 2, 4, 5, 7, 8, 9, 10 |
| `REQ-004` | 2, 4, 5, 7, 8, 9, 10 |
| `REQ-005` | 1, 3, 4, 5, 7, 8, 9, 10 |
| `REQ-006` | 3, 4, 5, 7, 8, 9, 10 |
| `REQ-007` | 2, 3, 4, 5, 7, 8, 9, 10 |
| `REQ-008` | 1, 2, 3, 4, 5, 8, 9, 10 |
| `REQ-009` | 1, 4, 6, 7, 9, 10 |
| `REQ-010` | 3, 4, 6, 8, 9, 10 |
| `REQ-011` | 4, 6, 9, 10 |
| `REQ-012` | 1, 3, 4, 5, 6, 7, 8, 9, 10 |
| `REQ-013` | 2, 4, 5, 7, 10 |
| `REQ-014` | 7, 10 |
| `REQ-015` | 2, 5, 7, 8, 10 |
| `REQ-016` | 6, 7, 8, 9, 10 |
| `REQ-017` | 8, 10 |
| `REQ-018` | 1, 4, 6, 9, 10 |
| `REQ-019` | 1, 4, 5, 9, 10 |
| `REQ-020` | 4, 10 |
