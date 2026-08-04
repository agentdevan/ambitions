# Implementation Tasks

Unqualified basenames resolve to exact paths in `implementation/plan.md`. Run
focused checks and inspect the diff after every task. Regenerate Xcode state
after Swift/resource tasks once `project.yml` includes the resource directory.

1. **Canon, strict schemas, and fixed policy.** Update the four exact existing
   canon owners and add five schemas/four configs. Apply conditional canon only
   when its upstream owner exists. Dependency: approved Design. Trace:
   `REQ-001` through `REQ-005`, `REQ-010`, `REQ-012` through `REQ-018`.
   Acceptance: exact source/entity/editorial/right/cultural/eligibility
   contracts exist; unknown fields and arbitrary entities fail closed. Tests:
   release schema and canon compiler tests.
2. **Fixed Wikidata identity acquisition.** Implement source lock and bounded
   structured extraction for QID/revision, labels/aliases, direct reviewed
   statements, ranks/references, redirect/merge/deprecate/delete/revert, and
   exclusion of wiki prose/media/transitive neighbors. Dependency: Task 1.
   Trace: `REQ-001` through `REQ-003`, `REQ-010`, `REQ-011`. Acceptance:
   repeatable locked bytes; arbitrary query/entity and inherited eligibility
   fail. Tests: `test_possibility_catalog_wikidata.py`.
3. **Editorial eligibility and risk.** Implement signed review decisions,
   non-exclusive facets, minimum claim set, risk/purpose gating, dignity-safe
   language, expiry/carry-forward/supersession. Fixtures cover multi-facet,
   ambiguous, low-risk, tool/safety/provider/account/protected-context, harmful
   label, missing/expired/widened review. Dependency: Tasks 1-2. Trace:
   `REQ-002`, `REQ-004` through `REQ-006`, `REQ-009`, `REQ-013`.
   Acceptance: only complete low-risk creative/knowledge records become
   recommendation-discovery eligible. Tests: editorial tests.
4. **Starter materials, rights, and cultural/ethical state.** Implement exact
   Smithsonian record/media and Library item/set/advisory records, attribution,
   separate metadata/media rights, trademark/privacy/publicity, cultural block,
   correction/withdrawal and purge plan. Dependency: Task 1. Trace: `REQ-007`,
   `REQ-011` through `REQ-015`. Acceptance: portal/metadata rights never widen
   assets; withdrawal isolates only affected content and produces complete
   deletion. Tests: materials and rights/cultural files.
5. **NPS and AmeriCorps overlays.** Implement independent fixed source/release
   records with federal recreation and civic-statistical semantics. Dependency:
   Task 1. Trace: `REQ-006`, `REQ-008`, `REQ-011`, `REQ-013`. Acceptance: NPS
   cannot complete activity safety; AmeriCorps cannot create opportunity,
   placement, community rank, or normative participation. Tests: overlay file.
6. **Foundry validation, coverage, diff, and archive.** Implement remaining
   foundry modules/CLI and deterministic signed `.sapc` shards. Dependency:
   Tasks 2-5. Trace: all `REQ-001` through `REQ-018`. Acceptance: exact source/
   editorial/rights/cultural/risk/eligibility counts, explicit change impact,
   hard evaluation gates, and reproducible bytes. Tests: all seven foundry
   files.
7. **Native models, decoder, and semantic parity.** Implement native public
   types, archive decoder, and validator. Dependency: Tasks 1-6. Trace:
   `REQ-001` through `REQ-014`, `REQ-017`, `REQ-018`. Acceptance: Python/Swift
   accept/reject identical fixtures and match state/coverage/eligibility. Tests:
   native models, decoder, semantic validator.
8. **Snapshot lifecycle, migration, and purge.** Implement store, migration,
   coordinator, invalidation, reset, and purge. Dependency: Task 7. Trace:
   `REQ-011` through `REQ-015`, `REQ-017`, `REQ-018`. Acceptance: immutable
   leases, atomic promotion, LKG, replay, legacy overlay-only migration, and
   immediate/resumable complete purge. Tests: store/migration/coordinator/purge.
9. **Local query/read-only boundary.** Implement index/actor/read client and
   runtime projection injection. Dependency: Task 8. Trace: `REQ-001` through
   `REQ-010`, `REQ-013`, `REQ-016`, `REQ-018`. Acceptance: deterministic local
   label/facet paging with no transitive expansion, popularity, private input,
   history, feedback, recommendation, mutation, model, or external action.
   Tests: query/privacy files.
10. **Inspection and accessibility.** Implement four Trust files and exact
    You/inspection updates. Dependency: Task 9. Trace: `REQ-001` through
    `REQ-009`, `REQ-011` through `REQ-017`. Acceptance: source versus editorial,
    every state/limit and recovery are accessible without personal/dignity/
    safety overclaim. Tests: inspection/accessibility/UI files.
11. **Bootstrap, refresh registry, and project generation.** Generate and byte-
    review bootstrap/archive, update fixed refresh entries, scheduler,
    `project.yml`, and generated project. Dependency: Tasks 1-10. Trace: all
    requirements. Acceptance: offline clean install; fixed public artifact IDs;
    no user-derived shards; measured resource budgets. Tests: resource and
    lifecycle integration.
12. **Optional upstream hobby-consumer binding.** If exact approved v1 files
    exist, replace the synthetic-only projection at its boundary while keeping
    session privacy/ephemerality; otherwise record this task pending without
    creating that owner. Dependency: Tasks 9-11 and upstream v1. Trace:
    `REQ-005`, `REQ-006`, `REQ-009`, `REQ-010`, `REQ-018`. Acceptance: only
    recommendation-discovery records pass; no consumer data returns.
13. **Complete verification.** Run all commands/evidence in
    `implementation/verification.md`. Dependency: Tasks 1-11 and Task 12 when
    applicable. Trace: all requirements. Acceptance: all applicable source,
    editorial, rights/cultural, privacy, dignity/safety, recovery, migration,
    accessibility, performance, build, simulator, and device lanes pass; other
    claim areas remain explicit N/A/insufficient.

## Requirement-to-task traceability

| Requirement | Tasks |
|---|---|
| `REQ-001` | 1, 2, 6, 7, 9, 10, 11, 13 |
| `REQ-002` | 1, 2, 3, 6, 7, 9, 10, 13 |
| `REQ-003` | 1, 2, 6, 7, 9, 13 |
| `REQ-004` | 1, 3, 6, 7, 10, 13 |
| `REQ-005` | 1, 3, 6, 7, 9, 12, 13 |
| `REQ-006` | 1, 3, 5, 6, 7, 9, 12, 13 |
| `REQ-007` | 4, 6, 7, 10, 13 |
| `REQ-008` | 5, 6, 7, 10, 13 |
| `REQ-009` | 3, 6, 7, 9, 10, 12, 13 |
| `REQ-010` | 1, 2, 6, 7, 9, 12, 13 |
| `REQ-011` | 2, 4, 5, 6, 8, 10, 13 |
| `REQ-012` | 1, 4, 6, 8, 10, 13 |
| `REQ-013` | 1, 3, 4, 5, 6, 7, 8, 9, 13 |
| `REQ-014` | 1, 6, 7, 8, 13 |
| `REQ-015` | 4, 8, 13 |
| `REQ-016` | 1, 9, 10, 13 |
| `REQ-017` | 1, 6, 7, 8, 10, 13 |
| `REQ-018` | 1, 6, 7, 8, 9, 11, 12, 13 |
