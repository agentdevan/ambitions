# Implementation Tasks

Every source basename below resolves to the exact repository-relative path in
`implementation/plan.md`. After a task adds Swift files, regenerate the project
with `xcodegen generate` before its focused tests. Each task ends with those
tests green and a review of the task diff before the next task starts.

1. **Canon, schema, and fixture contract.** Add the new canon owner and narrow
   cross-specification handoffs; add the JSON schema, README, and complete
   `EVAL-FUTURE-ASTRONAUT-PIVOT-001` synthetic fixture. Dependency: none.
   Trace: `REQ-001` through `REQ-008`, `REQ-010`, `REQ-011`, `REQ-013`,
   `REQ-017`. Acceptance: every fixture has stable identity, exact claim and
   dependency requirements, data class, coverage, expected evidence,
   limitations, hard invariants, and no private or fabricated production data.
   Tests: `test_schema_and_reports.py` schema/fixture cases and canon compiler
   tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. **Domain models, decoding, and registry.** Implement the four model files,
   manifest loader, and registry. Dependency: Task 1. Trace: `REQ-001` through
   `REQ-004`, `REQ-013`, `REQ-017`. Acceptance: strict versioned round trips,
   normalized values, unique IDs, exact evidence types, explicit applicability,
   legal states, and no aggregate score. Tests:
   `IntelligenceEvaluationModelsTests.swift` and
   `IntelligenceEvaluationRegistryTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. **Protected evaluation store and deletion.** Implement store schema, store,
   and deletion service beneath the active runtime generation. Dependency: Task
   2. Trace: `REQ-003`, `REQ-008`, `REQ-009`, `REQ-012`, `REQ-017`, `REQ-018`.
   Acceptance: atomic/idempotent batches, immutable history, protected private
   artifacts, backup/sync/export exclusion, index rebuild, disk-full recovery,
   unsupported-schema failure, resumable deletion, and no derived influence.
   Tests: `IntelligenceEvaluationStoreTests.swift`,
   `IntelligenceEvaluationDeletionTests.swift`, and privacy storage cases.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. **Runner and evidence methods.** Implement the actor runner, deterministic
   method registration, bounded execution, injected clock/seed, cancellation,
   partial runs, and adjudication-pending evidence. Dependency: Tasks 2-3.
   Trace: `REQ-002`, `REQ-003`, `REQ-006`, `REQ-011`, `REQ-013`, `REQ-017`.
   Acceptance: immutable dependency snapshots, stable ordering, no empty/skip/
   partial pass, captured non-deterministic evidence, and truthful recovery.
   Tests: `IntelligenceEvaluationRunnerTests.swift` plus source/model/failure
   matrices.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. **Hard invariants and verdict derivation.** Implement the invariant evaluator
   and verdict engine. Dependency: Task 4. Trace: `REQ-004` through `REQ-011`,
   `REQ-013`, `REQ-014`, `REQ-016`, `REQ-017`. Acceptance: every named hard
   failure forces `needs_revision`; missing mandatory evidence yields
   `insufficient_evidence`; supported evidence cannot satisfy another type; and
   a model cannot self/sole-approve protected claims. Tests:
   `IntelligenceEvaluationInvariantEvaluatorTests.swift` and
   `IntelligenceEvaluationVerdictEngineTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. **Invalidation and read-only handoffs.** Implement the invalidation planner,
   runtime read client, reverse dependency index, immutable supersession, and
   non-authoritative change-impact DTO. Dependency: Tasks 3-5. Trace:
   `REQ-007`, `REQ-009`, `REQ-012`, `REQ-017`, `REQ-018`. Acceptance: dependency
   and deletion changes invalidate exactly affected evidence, history remains,
   reruns receive new identities, and no handoff imports command/approval
   authority. Tests: `IntelligenceEvaluationInvalidationTests.swift` and
   compile-time mutation-negative client tests.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. **Redacted inspection and accessibility.** Implement the four Trust files and
   development/review route. Dependency: Task 6. Trace: `REQ-003`, `REQ-008`,
   `REQ-015`, `REQ-017`, `REQ-018`. Acceptance: exact bindings, evidence,
   disagreement, limitations, coverage, and invalidation are inspectable with
   redaction; no dashboard/score/root is added; all visible states and controls
   work under the accessibility matrix. Tests:
   `IntelligenceEvaluationInspectionTests.swift`,
   `IntelligenceEvaluationAccessibilityTests.swift`, and
   `IntelligenceEvaluationInspectionUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
8. **CLI, reports, and cross-decoder conformance.** Implement the Python CLI and
   report formatter. Dependency: Tasks 1-6. Trace: `REQ-001` through `REQ-004`,
   `REQ-008`, `REQ-012`, `REQ-017`, `REQ-018`. Acceptance: Swift and Python
   accept/reject the same golden manifests; reports are deterministic,
   claim-bound, coverage-complete, redacted, and machine-readable; the CLI never
   reads a private app store by default. Tests: all
   `test_schema_and_reports.py` cases and Swift golden-decoder cases.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
9. **End-to-end fixture and integration ceiling.** Compose the owner in
   `RuntimeBootstrap.swift`, wire Source Atlas/Planning/Scheduling/Trust and
   non-production external-operation test seams, and run the astronaut pivot
   case. Dependency: Tasks 1-8. Trace: all `REQ-001` through `REQ-018`.
   Acceptance: the case proves proposal/typed-owner boundaries, correction,
   localized replanning, pivot preservation, privacy canaries, failure states,
   deletion, and invalidation without live-store mutation; model, production
   source, production provider, direct-user, and release claims remain
   insufficient/N/A. Tests: `FutureAstronautPivotEvaluationTests.swift` and
   `IntelligenceEvaluationPrivacyTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
10. **Project generation and complete verification.** Confirm `project.yml`
    remains unchanged because its recursive source declarations cover every new
    Swift/test path, regenerate `Ambitions.xcodeproj`, run every command and
    manual evidence lane in `implementation/verification.md`, and record exact
    counts and claim ceilings. Dependency: Tasks 1-9. Trace: all requirements. Acceptance: canon,
    schema/CLI, focused tests, full tests, build, static boundaries, lint,
    secrets, privacy/security, performance, accessibility, simulator, and
    physical-device evidence are green; any unavailable lane remains explicitly
    unproven rather than silently waived. If a target/resource change makes a
    `project.yml` edit necessary, return to the plan before editing it.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Requirement-to-task traceability

| Requirement | Owning tasks |
|---|---|
| `REQ-001` | 1, 2, 8, 9, 10 |
| `REQ-002` | 1, 2, 4, 9, 10 |
| `REQ-003` | 1, 2, 3, 4, 7, 8, 9, 10 |
| `REQ-004` | 1, 2, 5, 8, 9, 10 |
| `REQ-005` | 1, 5, 9, 10 |
| `REQ-006` | 1, 4, 5, 9, 10 |
| `REQ-007` | 1, 5, 6, 9, 10 |
| `REQ-008` | 1, 3, 5, 7, 8, 9, 10 |
| `REQ-009` | 3, 5, 6, 9, 10 |
| `REQ-010` | 1, 5, 9, 10 |
| `REQ-011` | 1, 4, 5, 9, 10 |
| `REQ-012` | 3, 6, 8, 9, 10 |
| `REQ-013` | 1, 2, 4, 5, 9, 10 |
| `REQ-014` | 5, 9, 10 |
| `REQ-015` | 7, 9, 10 |
| `REQ-016` | 5, 9, 10 |
| `REQ-017` | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 |
| `REQ-018` | 3, 6, 7, 8, 9, 10 |
