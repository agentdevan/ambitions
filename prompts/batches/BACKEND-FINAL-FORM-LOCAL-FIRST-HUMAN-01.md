<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-11898774, AMB28-same_source_file_targeted_by_multiple_active_batches-12077061, AMB28-same_source_file_targeted_by_multiple_active_batches-1300009, AMB28-same_source_file_targeted_by_multiple_active_batches-14217122, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-20949965, AMB28-same_source_file_targeted_by_multiple_active_batches-24962709, AMB28-same_source_file_targeted_by_multiple_active_batches-25147666, AMB28-same_source_file_targeted_by_multiple_active_batches-2563443, AMB28-same_source_file_targeted_by_multiple_active_batches-33594616, AMB28-same_source_file_targeted_by_multiple_active_batches-41370782, AMB28-same_source_file_targeted_by_multiple_active_batches-43735803 and 14 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01`

This prompt is intended to run through `scripts/ambitions-codex-train.sh` or `make batch`. Do not paste this directly into Codex unless the owner explicitly says: `bypass the Ambitions runner`.

# Executive Objective

Bring Ambitions' backend, implementation truth, validation posture, local-first proof, Source Atlas continuation state, and app-source craftsmanship to final-form senior iOS quality.

This is an all-in-one final-form repair and hardening batch. It must fix the known five backend gaps and expand beyond them into the adjacent backend, validation, CloudKit-readiness, repo-truth, and human-code-quality gates required for a best-in-class local-first native iPhone app.

This batch must not close Accepted Yellow for the core objective. It must run repair cycles until Green unless it hits an unrecoverable Hard Red.

When this batch is complete, Ambitions must be able to make this internal engineering claim truthfully:

> Ambitions has a best-in-class local-first SwiftData backend architecture, with senior-quality Swift source, deterministic repository and Unit of Work seams, migration/recovery/export/data-control proof, consistent source-of-truth state, and no prompt/batch/Codex residue in app runtime code.

This batch does not claim release readiness, App Store readiness, TestFlight readiness, physical-device validation, public accessibility conformance, privacy/legal approval, global train completion, CloudKit sync, or production user-data sync.

# Required End State

Green requires all of the following:

1. Stale queue/state/truth docs are repaired.
2. SA18 is recorded as complete / Accepted Yellow / do-not-rerun if it is the latest completed Source Atlas batch.
3. SA19 PDF Import Boundary is the next eligible normal Source Atlas handoff unless live source proves a newer completed state.
4. Compile/test blockers that prevented backend-focused proof are repaired.
5. Migration, backup, restore, export, import, delete, recovery, rollback, and data-control proof is hardened.
6. Derived read-model, index, and large-store/performance proof exists where the current app actually needs it.
7. SwiftData remains the primary local persistence engine.
8. `AmbitionsPersistenceStore` remains the single SwiftData container owner.
9. Runtime access to persistence remains behind repository and Unit of Work seams.
10. Schema ledger coverage matches active SwiftData models.
11. Local-only sync posture remains explicit and tested.
12. CloudKit readiness is documented as a future opt-in Apple-native path, not implemented.
13. No iCloud entitlement, CloudKit container, hidden cloud dependency, custom hosted backend, or external/cloud LLM is added.
14. App source and app tests pass a human-senior-code-quality gate.
15. App runtime source contains no prompt/batch/Codex/process residue.
16. All required validation passes with exact commands and exit codes recorded.
17. Final closeout report says `STATUS: GREEN` only with proof, or `STATUS: HARD RED` only when Green is impossible without violating safety, truth, or scope.

# Active Source Truth To Inspect First

Read all of these before editing:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
project.yml
Package.swift
.codex/state/active-batch.yml
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/AMB_REMAINING_BATCH_REFERENCE.json
docs/codex/AMB_REMAINING_BATCH_REFERENCE.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md
docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md
docs/audits/sa18-batch-closeout-report.md
docs/audits/pfc06-schema-persistence-source-truth-report.md
Native/Ambitions/App/AppContainerFactory.swift
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Persistence/SwiftDataRepositories.swift
Native/Ambitions/Persistence/PersistenceContracts.swift
Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift
Native/Ambitions/Persistence/PortableSnapshotContracts.swift
Native/Ambitions/Persistence/PortableSnapshotService.swift
Native/Ambitions/Persistence/SyncCapabilityContracts.swift
Native/Ambitions/Domain/SourceAtlasPlainTextImporterModels.swift
Native/AmbitionsTests/Persistence/
Native/AmbitionsTests/Domain/
Native/AmbitionsTests/Services/
Native/AmbitionsTests/Today/
Native/AmbitionsTests/Goals/
Native/AmbitionsTests/Plan/
Native/AmbitionsTests/App/
```

Live source/project/test evidence wins over stale docs, old reports, prompt text, model memory, and historical source-truth material.

# Facts To Preserve

- Active top-level IA is exactly `Today / Goals / Capture / Time / You`.
- Plan is not a top-level destination.
- Internal Plan/Profile/Captures compatibility seams may remain when safely justified.
- Core backend is local-first and SwiftData-backed.
- Core intelligence must remain deterministic, inspectable, privacy-safe, and local-first.
- External/cloud LLMs are not core architecture.
- No custom hosted personal-data backend is allowed.
- Current sync posture is local-only / unavailable.
- CloudKit is allowed only as future optional Apple-native sync after explicit readiness gates.
- SA18 Plain Text Importer exists on `main` and has an Accepted Yellow closeout.
- Correct next Source Atlas handoff is SA19 PDF Import Boundary unless live source proves otherwise.
- Completed batches must not be reactivated.
- Release, device, accessibility, performance, privacy/legal, App Store, and TestFlight claims require current proof.

# Operating Loop

Use this repair loop until Green:

1. Inspect current source truth.
2. Record baseline commit and dirty state.
3. Patch the smallest coherent set.
4. Validate.
5. Classify every failure as one of:
   - in-scope defect;
   - stale state;
   - compile blocker;
   - test-target blocker;
   - generated project issue;
   - environment/toolchain blocker;
   - forbidden-scope risk;
   - design/source-truth conflict;
   - human-code-quality failure.
6. Repair in-scope defects immediately.
7. Rerun validation.
8. Repeat until all required Green gates pass.
9. Stop only for unrecoverable Hard Red.

Do not stop after a single Red if a bounded repair is possible.

Do not close Accepted Yellow for this batch.

# Allowed Scope

## Phase 0 — Baseline And Proof Setup

Record baseline:

```bash
git status --short --branch
git rev-parse HEAD
```

Create and maintain:

```text
docs/audits/backend-final-form-local-first-human-01-report.md
docs/audits/backend-final-form-human-code-review.md
```

The closeout report must be updated as the batch progresses, not invented at the end.

## Phase 1 — Source State / Queue / Truth Repair

Repair stale state and queue mirrors.

Expected state unless live source proves a newer completed batch:

- SA18 Plain Text Importer: complete / Accepted Yellow / do-not-rerun.
- SA19 PDF Import Boundary: next eligible.
- Global train: not complete.
- Release: not ready.
- CloudKit sync: not implemented.
- Device/accessibility/performance/privacy/legal/App Store/TestFlight: not claimed.

Allowed files:

```text
.codex/state/active-batch.yml
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/AMB_REMAINING_BATCH_REFERENCE.json
docs/codex/AMB_REMAINING_BATCH_REFERENCE.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md
docs/codex/BATCH_REGISTRY.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/audits/backend-final-form-local-first-human-01-report.md
```

Repair stale implementation truth when it conflicts with source/project files. Example: if docs still say Swift 5.10 but `project.yml` says Swift 6.0, source/project truth wins and docs must be corrected.

Do not mark Accepted Yellow work Green without fresh validation proof.

## Phase 2 — Compile/Test Debt Repair

Repair blockers that prevent backend-focused proof from running.

Known blocker candidates from recent closeouts:

```text
Native/Ambitions/Features/Today/TodayReadModelProjector.swift
Native/Ambitions/Features/Goals/GoalsOverviewProjector.swift
Native/Ambitions/Services/LargeStoreFixtureGenerator.swift
Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift
Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift
Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift
Ambitions.xcodeproj / project.yml generated inclusion of new Source Atlas files
```

Repair rules:

- Fix root cause.
- Do not delete tests to pass.
- Do not skip assertions.
- Do not weaken domain guarantees.
- Do not add broad compatibility hacks.
- If a type lacks a property, either add the correct property at the owning model seam or repair the caller to use the current contract.
- If a test is actor-isolation invalid, make it Swift 6 correct.
- If protocol conformance is stale, update the fixture to the current protocol.
- If generated project inclusion is stale, regenerate from `project.yml`; do not hand-edit generated project files unless repo policy permits and source truth requires it.

## Phase 3 — SwiftData Backend Final-Form Hardening

Keep SwiftData. Do not replace it.

Audit and repair:

```text
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Persistence/SwiftDataRepositories.swift
Native/Ambitions/Persistence/PersistenceContracts.swift
Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift
Native/Ambitions/Persistence/PortableSnapshotContracts.swift
Native/Ambitions/Persistence/PortableSnapshotService.swift
Native/Ambitions/Persistence/SyncCapabilityContracts.swift
Native/Ambitions/App/AppContainerFactory.swift
```

Requirements:

- SwiftData schema list and schema ledger must match.
- Every active `@Model` record must be represented in schema ledger tests.
- Store ownership must remain isolated.
- Repository contracts must remain the feature-facing boundary.
- Unit of Work must remain the write boundary for multi-entity commits where relevant.
- `resetAllData()` must stay technical full-store reset and must not be represented as user-facing delete-all-memory unless a separate safe UX/data-control path exists.
- Encoded snapshots must have compatibility/degradation tests.
- Unknown persisted enum values must degrade safely.
- Every destructive or external-effect-like command must be receipt/side-effect/data-control aware.
- No CloudKit, server, hosted backend, external LLM dependency, or telemetry dependency may be introduced.

## Phase 4 — Migration / Backup / Restore / Export / Import / Delete / Recovery

Make this area final-form.

Repair or add tests/source for:

- schema version ledger coverage;
- migration plan scaffold;
- pre-migration backup;
- staged import dry run;
- restore rollback;
- portable export;
- portable import;
- malformed package handling;
- unsupported schema handling;
- merge/replace behavior;
- conflict report;
- delete/forget/export data-control command boundaries;
- no silent destructive mutation;
- no cloud/account assumption;
- no release/legal/privacy overclaim.

Expected test areas:

```text
Native/AmbitionsTests/Persistence/StorageSchemaVersionLedgerTests.swift
Native/AmbitionsTests/Persistence/StorageMigrationPlanScaffoldTests.swift
Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift
Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift
Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift
Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift
Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift
Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift
Native/AmbitionsTests/Domain/AmbitionsCommandModelsTests.swift
Native/AmbitionsTests/Domain/SafeAutomationPolicyModelsTests.swift
Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift
Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift
```

## Phase 5 — Derived Read-Model / Index / Performance Proof

Audit query/projector/read-model hot spots.

Inspect at minimum:

```text
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Plan/
Native/Ambitions/Persistence/SwiftDataRepositories.swift
Native/AmbitionsTests/Today/TodayDerivedReadModelCacheTests.swift
Native/AmbitionsTests/Goals/
Native/AmbitionsTests/Plan/
```

Requirements:

- Do not add premature cache complexity.
- Add derived read-model/index support only with a clear performance or projection-stability reason.
- Existing derived cache tests must compile and pass.
- Large-store fixture proof must pass or be repaired.
- Performance budget docs/tests must reflect real source behavior.
- No fake performance claim without measurement or deterministic fixture proof.
- If profiling cannot run in this environment, limit claims and add deterministic large-store tests.

## Phase 6 — Source Atlas Continuation Readiness

Do not rerun SA18.

Verify:

- SA18 source exists.
- SA18 closeout exists.
- SA18 is not reactivated.
- SA19 is next.
- SA19 prompt is runner-compatible.
- SA19 inherits source/freshness/privacy/EFC/no-claim obligations.
- Source Atlas focused tests compile past prior unrelated blockers.

If executing SA19 is safe within this batch and all Green conditions remain achievable, run SA19 as a separately identifiable canonical batch step inside this run, preserving its own closeout report and queue update.

If SA19 is not executed, create a clean handoff proving the backend is now ready for SA19.

## Phase 7 — CloudKit Readiness Gate, No Implementation

Create a final-form Apple-native sync decision gate.

Allowed files:

```text
docs/architecture/
docs/canon/
docs/audits/backend-final-form-local-first-human-01-report.md
Native/Ambitions/Persistence/SyncCapabilityContracts.swift
Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift
scripts/
```

Required record, preferably:

```text
docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md
```

Requirements:

- CloudKit is not implemented in this batch.
- No iCloud entitlement is added.
- No CloudKit container is configured.
- No user data syncs across devices.
- Local-only remains default and fully functional.
- Future CloudKit must be opt-in Apple-native sync, not a hidden backend.
- Future CloudKit prerequisites must include:
  - entitlement/container setup;
  - SwiftData/CloudKit model compatibility review;
  - optional account/iCloud state UX;
  - offline-first behavior;
  - conflict/tombstone strategy;
  - migration/backup/restore proof;
  - export-before-sync posture;
  - privacy copy;
  - device/iCloud proof;
  - rollback plan;
  - no hidden server dependency;
  - no external LLM/cloud intelligence dependency.

Add or repair tests proving current runtime still returns local-only/unavailable.

## Phase 8 — Human Senior FAANG Code Quality Gate

Create and run a code-quality gate focused on app source and tests.

Add if missing:

```text
scripts/ambitions-human-code-quality-gate.py
```

The gate must scan:

```text
Native/Ambitions
Native/AmbitionsTests
Native/AmbitionsWidgetExtension
Native/AmbitionsShareExtension
Sources
AppUI/Sources
```

It must flag:

- process residue in app source:
  - `Codex`
  - `batch`
  - `prompt`
  - `runner`
  - `closeout`
  - `Accepted Yellow`
  - `Green closeout`
  - `Phase 01`
  - `Phase 02`
  - `Phase 03`
  - `Phase 04`
- stale user-facing `Plan` where Time is required;
- stale user-facing `Profile` where You/User System Profile is required;
- TODO/FIXME/HACK without owner or tracked follow-up;
- generated-looking comments;
- suspiciously broad generic names;
- overlarge files above defined thresholds;
- direct SwiftData usage outside persistence boundary;
- forbidden backend/provider terms in app runtime:
  - `Supabase`
  - `Firebase`
  - `Postgres`
  - `OpenAI`
  - `ChatGPT`
  - `LLM`
  - `analytics`
  - `telemetry`
  - `CloudKit`
  - `CKContainer`
  - `NSUbiquitous`

The gate must distinguish app source from docs. Docs may mention process terms. App runtime source must not look prompt-built.

Repair high-signal findings. Do not churn low-signal style issues.

Create/update:

```text
docs/audits/backend-final-form-human-code-review.md
```

This report must include:

- top app-source risks found;
- repairs made;
- remaining accepted internal compatibility seams;
- file-size/module-boundary findings;
- naming findings;
- test quality findings;
- final verdict: pass/fail.

The final verdict must be Pass for this batch to close Green.

## Phase 9 — Architecture / Module / File-Size Review

Run or create a module-boundary/file-size review.

Requirements:

- No direct persistence leakage outside allowed boundaries.
- No new giant God file.
- Existing overlarge files either:
  - are safely extracted in this batch; or
  - receive explicit owner, reason, extraction sequence, and tests.
- Do not destabilize visible UI for aesthetic extraction.
- Keep app source human-readable.

Suggested thresholds:

- warning over 500 lines;
- strong warning over 800 lines;
- fail over 1200 lines unless explicitly justified and not touched.

## Phase 10 — Final Proof And No-Claim Closeout

Update:

```text
docs/audits/backend-final-form-local-first-human-01-report.md
```

The report must include:

- final status;
- starting commit SHA;
- ending commit SHA if committed;
- files inspected;
- files changed;
- issues fixed;
- validation commands and exit codes;
- exact tests run;
- source/state consistency result;
- SwiftData/backend verdict;
- migration/recovery/export/data-control verdict;
- derived read-model/performance verdict;
- CloudKit readiness verdict;
- human-code-quality verdict;
- remaining internal compatibility seams;
- claims not made;
- rollback plan;
- next eligible global batch.

# Forbidden Scope

- Do not replace SwiftData.
- Do not add Realm, GRDB, raw SQLite, manual Core Data stack replacement, Supabase, Firebase, Postgres, or hosted backend.
- Do not enable CloudKit.
- Do not add iCloud entitlements.
- Do not add CloudKit container config.
- Do not add external/cloud LLM runtime.
- Do not add OpenAI/API dependency.
- Do not add analytics, telemetry, crash SDK, or user-data server.
- Do not change top-level IA.
- Do not restore Plan as a user-facing top-level tab.
- Do not broad-rename Plan/Profile compatibility seams without migration proof.
- Do not delete tests to pass.
- Do not weaken tests to pass.
- Do not hide compile errors.
- Do not fake build/test/device/accessibility/performance/privacy/legal/release proof.
- Do not mark Yellow work Green without fresh proof.
- Do not claim CloudKit sync works.
- Do not claim global train completion.
- Do not claim App Store/TestFlight readiness.
- Do not claim physical-device validation.
- Do not claim public accessibility conformance.
- Do not make code more mechanical, generic, or prompt-shaped.

# Validation Expectations

Run these at minimum:

```bash
git status --short --branch
git rev-parse HEAD
git diff --check
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
make batch-self-check
make prompt-audit
python3 scripts/ambitions-source-atlas-title-check.py --strict
```

Run human-code gate:

```bash
python3 scripts/ambitions-human-code-quality-gate.py
```

Run source/process scans:

```bash
rg -n "Codex|batch|prompt|runner|closeout|Accepted Yellow|Green closeout|Phase 0[1-4]" Native/Ambitions Native/AmbitionsTests Native/AmbitionsWidgetExtension Native/AmbitionsShareExtension Sources AppUI/Sources || true
rg -n "CloudKit|CKContainer|NSUbiquitous|iCloud" Native/Ambitions Native/AmbitionsWidgetExtension Native/AmbitionsShareExtension project.yml Package.swift || true
rg -n "Supabase|Firebase|Postgres|OpenAI|ChatGPT|LLM|analytics|telemetry" Native/Ambitions Native/AmbitionsWidgetExtension Native/AmbitionsShareExtension Sources AppUI/Sources Package.swift project.yml || true
rg -n "import SwiftData" Native/Ambitions Native/AmbitionsTests || true
```

Interpret hits. App runtime hits require repair or explicit allowed-boundary justification.

Run focused backend tests. Use exact current names if these names drift:

```bash
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/PersistenceRepositoryTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/EventLedgerRepositoryTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/StorageSchemaVersionLedgerTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/StorageMigrationPlanScaffoldTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/PreMigrationBackupTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/PortableRestoreRollbackTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/PortableSnapshotServiceTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/SyncCapabilityTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/AmbitionsCommandModelsTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/SafeAutomationPolicyModelsTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/PolicyGuardedCommandExecutorTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/AmbitionsCommandExecutorTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/TodayDerivedReadModelCacheTests
```

Run Source Atlas focused tests sufficient to prove SA18/SA19 readiness:

```bash
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/SourceAtlasPlainTextImporterModelsTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/SourceAtlasURLSourceImporterModelsTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 --lane focused-test --test AmbitionsTests/SourceAtlasSourceContainerModelsTests
```

If exact tests do not exist, discover current equivalents and document substitutions.

If any required validation fails, repair and rerun.

# Visual Proof Expectations If UI Changes

No UI changes are expected.

If any visible UI source changes occur:

- capture simulator screenshots for affected surfaces;
- record exact command;
- record simulator/device;
- record commit SHA;
- record screenshot path;
- verify top-level IA remains `Today / Goals / Capture / Time / You`;
- verify no user-facing Plan/Profile regression;
- verify accessibility labels are not degraded;
- verify Dynamic Type/Reduce Motion impact;
- do not claim final visual QA unless rendered proof exists.

# Hard Red Stop Conditions

Stop only if unrecoverable after bounded repair attempts:

- data-loss risk without rollback;
- schema mutation without migration/backup/restore proof;
- CloudKit/iCloud sync enabled by accident;
- custom hosted backend added;
- external/cloud LLM added to core runtime;
- top-level IA changed;
- user-facing Plan restored as top-level tab;
- test deletion/weakening is required to pass;
- source cannot build because of an external toolchain failure that cannot be repaired in repo;
- required validation cannot run in any available path and no honest Green proof is possible;
- batch would require broad unsafe rename or destructive reset;
- code quality would become more prompt/batch-generated-looking.

If Hard Red occurs, report exact cause, files touched, rollback, and why no further safe repair is possible.

# Rollback Expectations

Before edits:

```bash
git status --short --branch
git rev-parse HEAD
```

For every phase, document path-limited rollback.

Do not use hard reset unless explicitly authorized.

Examples:

```bash
git restore -- <touched tracked paths>
rm -f <new files created by this batch>
```

Never discard unrelated user work or `.codex/runs` artifacts without explicit cleanup scope.

# Required Closeout Artifacts

Create or update:

```text
docs/audits/backend-final-form-local-first-human-01-report.md
docs/audits/backend-final-form-human-code-review.md
```

Optional if useful:

```text
docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md
scripts/ambitions-human-code-quality-gate.py
```

# Required Final Status Language

The final report must say one of:

```text
STATUS: GREEN
```

or:

```text
STATUS: HARD RED
```

Do not close this batch as Accepted Yellow.

Green means all required proof passed.

Hard Red means Green was impossible without violating safety, truth, or scope.

# Runner Command

```bash
scripts/ambitions-codex-train.sh BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md
```

or:

```bash
make batch BATCH=BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01 PROMPT=prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
