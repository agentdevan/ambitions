# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Update import/source/You canon and add the two ProfileImport Domain files.
   Dependency: none for claims; Capability foundation for relationships. Trace:
   Design summary/model, REQ-001 through REQ-005. Acceptance: archive session,
   staged blob, row, user-provided claim, source lineage, duplicate decision,
   lifecycle, and cleanup state are typed without credential/Capability truth.
   Test: `Native/AmbitionsTests/Domain/ProfileArchiveImportModelsTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Implement `ProfileArchiveTableParser.swift` and
   `ProfileArchiveStagingService.swift`. Dependency: Task 1. Trace: intake and
   privacy, REQ-001 through REQ-004, REQ-011, REQ-013. Acceptance: file picker,
   scoped access, size/type/encoding/schema/cell bounds, formula/control-character
   neutralization, deterministic rows, encrypted staging, and cleanup fail closed.
   Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Repair/ProfileArchiveTableParserSecurityTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Attachments/ProfileArchiveStagingServiceTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Implement `ProfileArchiveImportStore.swift` and
   `ProfileArchiveImportMigration.swift`. Dependency: Tasks 1-2. Trace:
   persistence/recovery, REQ-006, REQ-010 through REQ-015. Acceptance: empty
   migration, revision CAS, session expiry, interruption resume, corrupt/unknown
   quarantine, raw-byte deletion, backup exclusion, and replay-equivalent accepted
   claims. Test: `Native/AmbitionsTests/LocalRuntimeOS/State/ProfileArchiveImportStoreTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Implement `ProfileClaimImportCommandService.swift`. Dependency: Tasks 1-3.
   Trace: row review/mutation, REQ-004 through REQ-010, REQ-012. Acceptance:
   accept/edit/skip/reject/duplicate decisions are per-row and idempotent;
   relationship is separately confirmed; no row auto-creates Capability, Goal,
   Proof, credential, or external write. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/ProfileClaimImportCommandServiceTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Implement `ProfileClaimInspectionProjection.swift`,
   `ProfileArchiveImportView.swift`, and `ProfileClaimReviewView.swift`.
   Dependency: Tasks 1-4. Trace: flows/accessibility, REQ-001 through REQ-015.
   Acceptance: preview counts/errors, row source, edits, duplicates, exact result,
   cleanup, deletion, nonvisual table navigation, Dynamic Type, and focus recovery.
   Test: `Native/AmbitionsUITests/ProfileArchiveImportUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
6. Add malicious/corrupt/large archive fixtures, update canon, regenerate project,
   and run verification. Dependency: Tasks 1-5. Trace: all REQ-001 through
   REQ-015. Acceptance: all requirements pass with no raw archive persistence or
   provider network path. Tests: run `implementation/verification.md` in full.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
