# Implementation Tasks

Use the exact paths in `implementation/plan.md`; inspect each task diff and run
its focused tests before continuing.

1. **Canon, schemas and source admission.** Add exact canon, six schemas and
   source/claim/purpose/rights/freshness configs. Trace: REQ-001–005, 013, 015–016.
   Acceptance: every unknown policy fails closed; synthetic is the only default.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. **Synthetic adapter and temporal semantics.** Implement all value/absence,
   interval/timezone/expiry/conflict/source-change fixtures. Dependency: 1.
   Trace: REQ-002–004, 007–008. Acceptance: deterministic source-native bytes.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. **Foundry release, rights and coverage.** Implement build/verify/diff,
   admission gates, coverage and withdrawal. Dependency: 1–2. Trace: REQ-001–004,
   007–008, 011, 013. Acceptance: repeat builds match; prohibited source fails.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. **Native models and parity.** Implement value types, decoder and semantic
   validator. Dependency: 1–3. Trace: REQ-001–004, 007–008, 011. Acceptance:
   Python/Swift parity for every fixture.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. **Snapshot lifecycle and migration.** Implement immutable store, migration,
   coordinator, journal, rollback/reset/purge. Dependency: 4. Trace: REQ-007–008,
   010–012. Acceptance: atomic readers, candidate-only legacy, resumable purge.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. **Exact query and ephemeral local filter.** Implement index/actor/evaluator/
   read client without private persistence or remote query. Dependency: 5.
   Trace: REQ-004–006, 008, 012. Acceptance: deterministic reason codes and
   stale-result discard; source bytes unchanged.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. **Expiry and dependency invalidation.** Implement expiration, exact diff and
   notifier. Dependency: 5–6. Trace: REQ-003, 007–008, 011–012. Acceptance: only
   exact public bindings notify; consumers are never mutated.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
8. **Trust, safe links and accessibility.** Implement inspection, local actions,
   allowlisted link builder and accessibility. Dependency: 6–7. Trace: REQ-009–010,
   014, 016. Acceptance: all states/limits are textual; no external write.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
9. **Resources and integration.** Generate/byte-review conformance artifact,
   add refresh target, bootstrap and regenerate project. Dependency: 1–8. Trace:
   all requirements. Acceptance: offline/LKG and fixed-target refresh work.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
10. **Complete verification.** Run `implementation/verification.md`. Dependency:
    1–9. Acceptance: all applicable lanes pass; real-source, transaction,
    personal eligibility, deployment and release claims remain N/A/insufficient.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| REQ-001 | 1, 3, 4, 9, 10 |
| REQ-002 | 1–4, 10 |
| REQ-003 | 1–4, 7, 10 |
| REQ-004 | 1–4, 6, 10 |
| REQ-005 | 1, 6, 9, 10 |
| REQ-006 | 6, 10 |
| REQ-007 | 2–5, 7, 10 |
| REQ-008 | 2–7, 9, 10 |
| REQ-009 | 8, 10 |
| REQ-010 | 5, 8, 10 |
| REQ-011 | 3, 5, 7, 10 |
| REQ-012 | 5–7, 10 |
| REQ-013 | 1, 3, 10 |
| REQ-014 | 8, 10 |
| REQ-015 | 1, 10 |
| REQ-016 | 1, 8, 10 |
