# Architecture Modernization Post-Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the smallest evidence-backed architecture gaps after the canon cutover without widening authority, inventing a fixed target tree, or claiming runtime or release readiness before current proof exists.

**Architecture:** Work proceeds from inventory truth to mutation authority, owner-bounded compatibility migrations, external-effect reconciliation, proof normalization, composition and navigation repair, one measured compiler-boundary candidate, and final evidence reconciliation. Every source-changing child uses its own intake, fresh canon pack, RED → GREEN → REFACTOR loop, review, finalization, and reversible commit.

**Tech Stack:** Swift 6.3.3, SwiftUI Observation, actor-isolated SwiftData, LocalRuntimeOS command/event/replay infrastructure, XCTest, Xcode 26.6 build 17F113, XcodeGen 2.45.4, and Python repository gates.

## Global Constraints

- Active authority is `docs/canon/`; this plan is guidance, not authority, task authorization, owner approval, or finalization.
- Baseline evidence is the 2026-07-20 reconciliation at source head `26a4eee7c98ba62fb92caaac564a58344295656f`.
- Applicable obligations are `CONST-PROOF-EVIDENCE-001`, `CONST-RUNTIME-MUTATION-001`, `CONSTITUTION`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, and `SYSTEM-PERSISTENCE-REPLAY`.
- Before each source-changing child, admit only its listed paths, generate a fresh pack with `python3 scripts/ambitions-canon.py pack`, and obtain current authorization with `python3 scripts/ambitions-canon.py task start`.
- Revalidate each named cohort against live canon, registry rows, and current source. If a path moved, produce a corrected child plan and obtain fresh authority; do not substitute an unnamed path.
- Run exact-diff `python3 scripts/ambitions-canon.py task finalize` only after implementation, tests, and independent review for that child's final diff.
- Keep XcodeGen authoritative: edit `project.yml` when configuration changes, regenerate, and never hand-edit the generated Xcode project.
- Route concrete changed paths with repeated `--path` arguments to `python3 scripts/ambitions-changed-file-test-router.py --execute`; run every command and broader trigger it emits.
- Runtime, persistence, navigation, topology, and proof-gate changes require a reviewer who did not author the change.
- No train may claim device, simulator, visual, accessibility, privacy/security, release, App Store, TestFlight, architecture completion, or 10/10 without separate current evidence and authority.
- This document is not an exact-tree law, does not authorize later source edits, and must be re-derived whenever live evidence or canon changes.
- New compiler boundaries are candidate-driven and separate-PR by default; no target creation is implied or authorized here.

---

### Task 1: Normalize the Mutation Inventory Without Behavior Change

**Dominant objective:** Make the mutation registry and direct-write inventory a precise, fail-closed work queue by removing only source-proven obsolete rows, consolidating identical rows, and correcting classifications only when named executable tests support the change.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, and `CONST-PROOF-EVIDENCE-001`; every removed or merged row must map to absent source or the same owner, mutation identity, and source location.

**Child intake and exact scope:** Admit `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`, `Native/AmbitionsTests/LocalRuntimeOS/Commands/MeaningfulMutationRegistryTests.swift`, and `scripts/ambitions-runtime-direct-write-audit.py`. Do not regenerate `docs/qa/local-runtime-proof/current-local-runtime-proof.json`.

**Interfaces:** Consume `MeaningfulMutationRegistry` descriptors and audit findings; produce deterministic row identity, duplicate detection, and evidence links for Tasks 2–5.

**Direct RED/GREEN:** RED is `python3 scripts/ambitions-runtime-direct-write-audit.py` exiting nonzero with 154 unresolved/unproven combined rows. Task-local GREEN is all registry tests passing and the audit reporting an exact, explained delta; the overall audit may remain Red for genuine unproven rows.

**Focused commands:** `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-01 --scheme AmbitionsUnitTests --test MeaningfulMutationRegistryTests`; `python3 scripts/ambitions-runtime-direct-write-audit.py`; `python3 scripts/ambitions-changed-file-test-router.py --path Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift --path Native/AmbitionsTests/LocalRuntimeOS/Commands/MeaningfulMutationRegistryTests.swift --execute`.

**Scope and non-goals:** No command execution, feature, storage, proof-artifact, or product-behavior change. A shared helper or favorable name is not durability evidence.

- [ ] **Step 1: Start the child** — Create the bounded intake, fresh pack, and current authorization for the three admitted paths.
- [ ] **Step 2: RED** — Add table-driven cases for every proven obsolete row, duplicate identity, and unsupported upgraded class; retain failing case names and exit codes.
- [ ] **Step 3: GREEN** — Remove only source-absent rows, merge only identical identities, and reclassify only rows named by passing executable tests.
- [ ] **Step 4: REFACTOR** — Centralize deterministic row-identity assertions without changing production behavior.
- [ ] **Step 5: Verify** — Run all focused commands, canon checks, `git diff --check`, independent runtime-inventory review, exact-diff finalization, and a standalone commit.

**Build/test non-regression:** `MeaningfulMutationRegistryTests` and every concrete router command pass; blocker reduction equals the reviewed stale/duplicate rows and no live mutation disappears.

**Rollback:** Revert the standalone commit and discard its lower inventory count from downstream evidence.

**Maximum evidence claim:** Source-level inventory normalization is complete for the named rows; no mutation is newly durable and runtime remains Red unless separately established.

---

### Task 2: Repair Atomic Mutation Authority in the Committer and Today

**Dominant objective:** Replace pre-authority canonical mutation with one plan → authoritative commit → materialize lineage in the committer and the currently observed Today mutation seams.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, and `CONST-PROOF-EVIDENCE-001`; no canonical state becomes visible before authority and replay converges without duplicate effects.

**Child intake and exact source scope:** Admit `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandMutationCommitter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeTransactionCommitPolicy.swift`, `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Interaction/TodayCommandActionHandler.swift`, `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`, and `Native/Ambitions/Core/LocalRuntimeOS/Inspection/TodayReceiptCommandService.swift`.

**Exact tests:** Modify `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`, `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`, `Native/AmbitionsTests/Today/TodayClosureRuntimeTests.swift`, `Native/AmbitionsTests/Today/TodayDurableActionMutationIntegrationTests.swift`, `Native/AmbitionsTests/Today/TodayDurableReceiptMutationIntegrationTests.swift`, and `Native/AmbitionsTests/Today/TodayGoalStepActionAtomicityTests.swift`; create `Native/AmbitionsTests/Today/TodayAuthorityLineageFailureInjectionTests.swift`.

**Interfaces:** Consume `RuntimeCommandMutationCommitter`, `RuntimeTransactionCommitPolicy`, event journal, Today command handlers, and receipts; produce one committed event lineage with stable command/event identity and replay cursor.

**Direct RED/GREEN:** RED is `TodayAuthorityLineageFailureInjectionTests` showing visible canonical change on authority failure or double materialization after replay. GREEN is zero pre-authority visibility, one event/receipt/materialization for duplicates, and identical post-relaunch projection.

**Focused commands:** `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-02 --scheme AmbitionsUnitTests --test RuntimeAtomicCommitTests --test TodayAuthorityLineageFailureInjectionTests --test TodayGoalStepActionAtomicityTests --test TodayDurableActionMutationIntegrationTests --test TodayDurableReceiptMutationIntegrationTests`; `python3 scripts/ambitions-runtime-direct-write-audit.py`; `python3 scripts/ambitions-local-runtime-proof.py`.

**Scope and non-goals:** Do not migrate Capture, Goals, Time, You, or external effects and do not create a second transaction abstraction.

- [ ] **Step 1: Start the child** — Freeze the exact Today registry identities, then obtain the child intake, pack, and authorization for the listed files.
- [ ] **Step 2: RED** — Inject failure before journal write, after journal write before materialization, during materialization, on duplicate command identity, and on relaunch replay.
- [ ] **Step 3: GREEN** — Calculate without canonical writes, atomically commit authority, then materialize only from the committed result while retaining stable identifiers.
- [ ] **Step 4: REFACTOR** — Remove the now-unreachable pre-authority branch and keep one narrow committer interface.
- [ ] **Step 5: Verify** — Run focused tests, both runtime gates, a concrete changed-file router invocation for every modified path, canon checks, independent runtime/persistence review, finalization, and one commit.

**Build/test non-regression:** Focused tests and emitted broader build-for-testing commands pass; every injected failure leaves the exact expected durable and projected state.

**Rollback:** Revert the commit and its Today registry upgrades together.

**Maximum evidence claim:** The named Today paths use the tested lineage at the reviewed revision; no other domain or app-wide atomicity is proven.

---

### Task 3: Produce and Execute Five Owner-Bounded Compatibility Children

**Dominant objective:** Turn the current registry rows into five exact child plans, then migrate each owner independently through the Task 2 lineage without a mega-diff.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, and `CONST-PROOF-EVIDENCE-001`; each migrated row needs named failure, retry, restart, receipt, and replay evidence.

**Current cohorts and child-plan outputs:**

| Child plan | Current source cohort | Existing focused tests | Concrete baseline command |
| --- | --- | --- | --- |
| `docs/superpowers/plans/2026-07-20-architecture-modernization-today-remainder.md` | `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Interaction/TodayCommandActionHandler.swift`, `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Inspection/TodayReceiptCommandService.swift` | Existing `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`, `Native/AmbitionsTests/Today/TodayClosureRuntimeTests.swift`, `Native/AmbitionsTests/Today/TodayServiceProjectionTests.swift`; new `Native/AmbitionsTests/Today/TodayRemainderAuthorityLineageTests.swift` | `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-03A --scheme AmbitionsUnitTests --test TodayCommandHandlerTests --test TodayClosureRuntimeTests --test TodayServiceProjectionTests --test TodayRemainderAuthorityLineageTests` |
| `docs/superpowers/plans/2026-07-20-architecture-modernization-capture.md` | `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/DefaultCaptureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/DefaultCaptureServiceRouting.swift` | Existing `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/CaptureRouting/CaptureRoutingTests.swift`, `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`; new `Native/AmbitionsTests/Capture/CaptureAuthorityLineageTests.swift` | `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-03B --scheme AmbitionsUnitTests --test CaptureViewModelTests --test CaptureRoutingTests --test CaptureServiceTests --test CaptureAuthorityLineageTests` |
| `docs/superpowers/plans/2026-07-20-architecture-modernization-goals.md` | `Native/Ambitions/Surfaces/Goals/CreateGoalViewModel.swift`, `Native/Ambitions/Surfaces/Goals/GoalsViewModels.swift`, `Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureService+10-performMutation.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalTeachingSignalService.swift` | Existing `Native/AmbitionsTests/Goals/CreateGoalViewModelTests.swift`, `Native/AmbitionsTests/Goals/GoalCreationServiceTests.swift`, `Native/AmbitionsTests/Goals/GoalDetailExplainabilityActionTests.swift`, `Native/AmbitionsTests/Services/GoalTeachingSignalServiceTests.swift`; new `Native/AmbitionsTests/Goals/GoalsAuthorityLineageTests.swift` | `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-03C --scheme AmbitionsUnitTests --test CreateGoalViewModelTests --test GoalCreationServiceTests --test GoalDetailExplainabilityActionTests --test GoalTeachingSignalServiceTests --test GoalsAuthorityLineageTests` |
| `docs/superpowers/plans/2026-07-20-architecture-modernization-time-lifecycle.md` | `Native/Ambitions/Surfaces/Time/TimeRitualsViewModel.swift`, `Native/Ambitions/Surfaces/Time/Projection/TimeRitualsMutationHelpers.swift`, `Native/Ambitions/Surfaces/Time/Projection/TimeRitualsProjectionService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/SimpleStepLifecycleService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/SimpleStepLifecycleService+Recurring.swift` | Existing `Native/AmbitionsTests/Time/TimeRitualsProjectionServiceTests.swift`, `Native/AmbitionsTests/Runtime/RecurringStepLifecycleServiceTests.swift`, `Native/AmbitionsTests/Time/TimeDurableMutationIntegrationTests.swift`; new `Native/AmbitionsTests/Time/TimeLifecycleAuthorityLineageTests.swift` | `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-03D --scheme AmbitionsUnitTests --test TimeRitualsProjectionServiceTests --test RecurringStepLifecycleServiceTests --test TimeDurableMutationIntegrationTests --test TimeLifecycleAuthorityLineageTests` |
| `docs/superpowers/plans/2026-07-20-architecture-modernization-you-startup.md` | `Native/Ambitions/Surfaces/You/YouViewModel.swift`, `Native/Ambitions/Surfaces/You/Projection/YouFeatureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/State/YouPreferencesCommandService.swift`, `Native/Ambitions/App/Bootstrap/SystemSurfaceBootstrap.swift` | Existing `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/State/ObjectStateTests.swift`, `Native/AmbitionsTests/App/OnboardingAndDegradedStateTests.swift`; new `Native/AmbitionsTests/You/YouStartupAuthorityLineageTests.swift` | `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-03E --scheme AmbitionsUnitTests --test YouFeatureServiceTests --test ObjectStateTests --test OnboardingAndDegradedStateTests --test YouStartupAuthorityLineageTests` |

**Interfaces:** Each child consumes the Task 2 committer, `RuntimeCommandClient`, domain executor, and stable command identities; it produces owner-local plans/receipts with no feature-side canonical write before commit.

**Direct RED/GREEN:** RED is `python3 scripts/ambitions-runtime-direct-write-audit.py` naming the child's registry rows as unproven, plus a new owner test that fails at a named authority/replay boundary. GREEN is that exact test matrix passing and only its named registry rows upgraded; unrelated blockers remain Red.

**Focused commands:** Run the applicable table command, `python3 scripts/ambitions-runtime-direct-write-audit.py`, and `python3 scripts/ambitions-local-runtime-proof.py`. Each evidence/design operation writes repeated literal `--path` arguments for every source and test path in its table row into the fixed-path child plan before that plan can request authorization.

**Scope and non-goals:** The parent operation is evidence/design work. Each child plan must name registry IDs, full source paths, test method names, RED reason, GREEN result, and literal router command before any source authorization. Never combine two table rows in one pack, diff, review, or commit.

- [ ] **Step 1: Produce 03A** — Revalidate Today rows and write the complete Today child plan; stop if any owner or test path differs.
- [ ] **Step 2: Execute 03A independently** — Obtain its pack/authorization, run TDD, independent review, finalization, and commit.
- [ ] **Step 3: Repeat in order** — Produce and execute 03B Capture, 03C Goals, 03D Time, and 03E You with separate authorization and commits.
- [ ] **Step 4: REFACTOR per child** — Delete only that owner's obsolete compatibility branch after replay evidence passes.
- [ ] **Step 5: Verify parent result** — Run all table commands and both runtime gates; reconcile exact blocker deltas after every child.

**Build/test non-regression:** Each child passes its concrete focused and changed-file commands before the next starts; blocker reductions equal exact proven rows.

**Rollback:** Revert only the failing owner's commit and its registry changes; earlier owner commits remain independently reversible.

**Maximum evidence claim:** Only registry rows named in each completed child are migrated; all other rows retain their prior status.

---

### Task 4: Reconcile External Ingestion and Effects in Three Children

**Dominant objective:** Acknowledge Share/App Intent input only after command success, then prove durable, idempotent EventKit/notification/widget/external effects.

**Requirements and proof obligations:** `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `CONST-RUNTIME-MUTATION-001`, and `CONST-PROOF-EVIDENCE-001`; prove crash-before-write, crash-after-write-before-ack, duplicate, timeout, offline relaunch, and ordinary replay non-reissue.

**Exact children:** 04A Share owns `Native/AmbitionsShareExtension/ShareIntakeView.swift`, `Native/AmbitionsShareExtension/ShareViewController.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ShareExtensionIntake.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalCreationImportService.swift`, `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`, and new `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/ExternalIngestionAcknowledgementTests.swift`; 04B App Intent owns `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift`, `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`, `Native/AmbitionsTests/App/AppIntentCommandRoutingInventoryTests.swift`, and new `Native/AmbitionsTests/App/AppIntentAcknowledgementReplayTests.swift`; 04C effects owns `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/NotificationOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalReconciliation.swift`, `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/ExternalWritesTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/SideEffectLedgerRepositoryTests.swift`, `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`, `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`, and new `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/ExternalEffectReplayTests.swift`.

**Interfaces:** Consume durable command receipts, stable ingestion IDs, side-effect intent records, and replay cursors; produce acknowledgement/removal after success and idempotent effect completion keyed by durable intent identity.

**Direct RED/GREEN:** RED is new `ExternalIngestionAcknowledgementTests` or `ExternalWritesTests` proving premature acknowledgement or duplicate dispatch in one of the six required scenarios. GREEN is retained intake until success, one durable completion identity, and zero ordinary-replay reissue in all six cases.

**Focused commands:** 04A: `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-04A --scheme AmbitionsUnitTests --test ExternalCreationImportServiceTests --test ExternalIngestionAcknowledgementTests`; 04B: `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-04B --scheme AmbitionsUnitTests --test AppIntentRoutingTests --test AppIntentCommandRoutingInventoryTests --test AppIntentAcknowledgementReplayTests`; 04C: `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-04C --scheme AmbitionsUnitTests --test ExternalWritesTests --test SideEffectLedgerRepositoryTests --test EventKitIntegrationServiceTests --test LocalNotificationFoundationTests --test ExternalEffectReplayTests`.

**Scope and non-goals:** Use `docs/superpowers/plans/2026-07-20-architecture-modernization-external-share.md`, `docs/superpowers/plans/2026-07-20-architecture-modernization-external-app-intent.md`, and `docs/superpowers/plans/2026-07-20-architecture-modernization-external-effects.md`. Each receives a separate intake, pack, authorization, review, finalization, and commit. Do not place external APIs inside the local atomic transaction or claim third-party delivery.

- [ ] **Step 1: RED** — Create the exact new acknowledgement test and six-case failure matrix before changing source.
- [ ] **Step 2: GREEN** — Commit local authority, dispatch through the narrow adapter, persist completion, then acknowledge/remove intake.
- [ ] **Step 3: REFACTOR** — Remove feature-side retry flags only after the durable intent owns retries.
- [ ] **Step 4: Verify each child** — Run its focused command, both runtime gates, literal changed-path router command, canon checks, and independent runtime/persistence review.
- [ ] **Step 5: Commit separately** — Complete 04A, then 04B, then 04C without shared diffs.

**Build/test non-regression:** All six failure/replay cases pass per child, existing feature tests pass, and ordinary replay emits no duplicate external call.

**Rollback:** Revert one child and its registry classifications; do not retain completion fixtures written by an incompatible schema.

**Maximum evidence claim:** Ordering and replay are proven only for each completed child; device delivery and other adapters remain unproven.

---

### Task 5: Normalize Crash, Replay, Migration, Corruption, and Proof Gates

**Dominant objective:** Repair stale/circular checks, run current executable evidence at one revision, and regenerate LocalRuntimeProof only after every required input is Green.

**Requirements and proof obligations:** `CONST-PROOF-EVIDENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `RUNTIME-MUTATION-SEQUENCE-001`, and `CONST-RUNTIME-MUTATION-001`; proof producers never consume their own prior Green artifact.

**Child intake and exact scope:** Admit `scripts/ambitions-local-runtime-proof.py`, new `scripts/tests/test_ambitions_local_runtime_proof.py`, `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/EventJournal/RuntimeDomainEventReplayTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/Repair/DryRunMigrationTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/Repair/MigrationPlannerTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/Repair/RestoreRollbackTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/Repair/StoreInvariantCheckerTests.swift`, and—only after computed Green—`docs/qa/local-runtime-proof/current-local-runtime-proof.json`.

**Interfaces:** Consume current command results, registry/direct-write output, revision, toolchain, destination, migration, rollback, and corruption evidence; produce a deterministic non-circular artifact bound to those inputs.

**Direct RED/GREEN:** RED is `python3 scripts/ambitions-local-runtime-proof.py` reporting 17/20 checks and 157 blockers, or unit tests accepting a stale SHA, missing result, or circular artifact. GREEN is all required inputs passing at one SHA and deterministic regeneration; any missing input exits nonzero.

**Focused commands:** `python3 -m unittest scripts.tests.test_ambitions_local_runtime_proof`; `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-05 --scheme AmbitionsUnitTests --test RuntimeAtomicCommitTests --test RuntimeDomainEventReplayTests --test DryRunMigrationTests --test MigrationPlannerTests --test RestoreRollbackTests --test StoreInvariantCheckerTests`; `python3 scripts/ambitions-local-runtime-proof.py`.

**Scope and non-goals:** Repair only failures reproduced by these commands. Do not hand-edit Green, suppress blockers, accept ancestor output, or regenerate while a required input is Red.

- [ ] **Step 1: Start the child** — Bind intake/pack/authorization to the listed script, tests, and conditional generated artifact.
- [ ] **Step 2: RED** — Prove ancestor SHA, missing result, circular self-consumption, migration failure, rollback failure, and corruption failure each force Red.
- [ ] **Step 3: GREEN** — Bind proof to structured current results, SHA, toolchain, and destination while preserving every unresolved blocker.
- [ ] **Step 4: REFACTOR** — Normalize input ordering and run the complete matrix once at one revision.
- [ ] **Step 5: Verify** — Regenerate only after computed Green; run concrete router paths, canon checks, and independent provenance review before finalization and commit.

**Build/test non-regression:** Script and XCTest suites pass at one SHA; generation is deterministic and stale/missing inputs return nonzero.

**Rollback:** Revert script and generated artifact together; label the restored artifact stale.

**Maximum evidence claim:** LocalRuntimeProof is Green only for enumerated checks at the bound revision; no simulator, device, visual, accessibility, security, or release claim follows.

---

### Task 6: Repair the Four Observed Composition Bypasses

**Dominant objective:** Replace the observed raw container, optional runtime, and NotificationCenter dependencies with narrow injected clients/actions constructed at the app root.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `CONSTITUTION`, and `CONST-PROOF-EVIDENCE-001`; replacement seams must not create a second runtime authority.

**Exact children:** 06A owns `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`, `Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift`, `Native/Ambitions/App/AppContainerFactory.swift`, `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`, and `Native/AmbitionsTests/App/GlobalComposerHardeningTests.swift`; 06B owns `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift`, `Native/AmbitionsTests/LocalRuntimeOS/Boundary/RuntimeCommandClientTests.swift`, and `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`; 06C owns `Native/Ambitions/Surfaces/You/YouScreen+04-YouLifeContextSurface.swift` and new `Native/AmbitionsTests/You/YouLifeContextRoutingTests.swift`.

**Interfaces:** Consume `RuntimeCommandClient`, `AmbitionsRuntimeServices`, typed shell/navigation actions, and `AppContainerFactory`; produce non-optional injected values whose live forms are constructed only at the app root.

**Direct RED/GREEN:** Run `test -z "$(rg -n '@Environment\(\\\.appContainer\)|RuntimeCommandClient\? = nil|NotificationCenter\.default' Native/Ambitions/App/AppShellActivatedCaptureSeam.swift Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift Native/Ambitions/Surfaces/Today/TodayViewModel.swift Native/Ambitions/Surfaces/You/YouScreen+04-YouLifeContextSurface.swift)"`. RED is exit 1 with hits in all four current files; GREEN is exit 0 with no hit in those files plus passing injected-client tests.

**Focused commands:** 06A: `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-06A --scheme AmbitionsUnitTests --test AppContainerFactoryTests --test GlobalComposerHardeningTests`; 06B: `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-06B --scheme AmbitionsUnitTests --test RuntimeCommandClientTests --test TodayCommandHandlerTests`; 06C: `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-06C --scheme AmbitionsUnitTests --test YouLifeContextRoutingTests`.

**Scope and non-goals:** Use `docs/superpowers/plans/2026-07-20-architecture-modernization-composition-container.md`, `docs/superpowers/plans/2026-07-20-architecture-modernization-composition-today-runtime.md`, and `docs/superpowers/plans/2026-07-20-architecture-modernization-composition-you-routing.md`. Do not move canonical state into views, create a service locator, or combine navigation ownership changes.

- [ ] **Step 1: RED** — Run the source audit and add recording-client tests that expose each implicit dependency.
- [ ] **Step 2: GREEN** — Add the smallest typed interface, construct it in `AppContainerFactory`, and require explicit injection.
- [ ] **Step 3: REFACTOR** — Delete the admitted bypass and give previews explicit inert fixtures.
- [ ] **Step 4: Verify per child** — Run the source audit, child focused command, literal router command, canon checks, and independent runtime/composition review.
- [ ] **Step 5: Commit separately** — Finish 06A, 06B, and 06C with separate packs, finalizations, and commits.

**Build/test non-regression:** The direct audit exits 0 only after all three children, focused tests pass, and emitted build-for-testing commands pass.

**Rollback:** Revert the affected child including factory wiring and tests; remove any unused public interface introduced by that child.

**Maximum evidence claim:** The four named bypasses are removed; app-wide composition and runtime behavior outside these files remain unproven.

---

### Task 7: Repair the Observed Navigation Responsibility Bypasses

**Dominant objective:** Preserve Stage canonical ownership while replacing direct Stage property writes and NotificationCenter product routing with typed reducer actions.

**Requirements and proof obligations:** `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001`, and for command-triggering transitions `CONST-RUNTIME-MUTATION-001` plus `RUNTIME-MUTATION-SEQUENCE-001`; presentation cannot mutate canonical domain state.

**Child intake and exact scope:** Admit `Native/Ambitions/Stage/AmbitionsStage.swift`, `Native/Ambitions/Stage/StageReducer.swift`, `Native/Ambitions/Stage/StageStore.swift`, `Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift`, `Native/AmbitionsTests/App/StageThinnessOwnershipTests.swift`, `Native/AmbitionsTests/App/StageMotionRoutingTests.swift`, and `Native/AmbitionsTests/App/AppShellNavigationTests.swift`.

**Interfaces:** Consume typed Stage actions and reducer transitions; produce presentation-only intents reduced by Stage, with domain mutation delegated through injected runtime actions.

**Direct RED/GREEN:** Run `test -z "$(rg -n 'navigation\.(activeOverlay|continuityReceipt)[[:space:]]*=|NotificationCenter\.default' Native/Ambitions/Stage/AmbitionsStage.swift Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift)"`. RED is exit 1 for current direct writes and notification routing; GREEN is exit 0 plus passing reducer, motion, restoration, and shell-navigation tests.

**Focused commands:** `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-07 --scheme AmbitionsUnitTests --test StageThinnessOwnershipTests --test StageMotionRoutingTests --test AppShellNavigationTests`; `python3 scripts/ambitions-changed-file-test-router.py --path Native/Ambitions/Stage/AmbitionsStage.swift --path Native/Ambitions/Stage/StageReducer.swift --path Native/Ambitions/Stage/StageStore.swift --path Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift --execute`.

**Scope and non-goals:** Keep `Native/Ambitions/Stage/` canonical. Do not create a `Navigation/` authority, store domain state in routes, or change deep-link/restoration behavior without a failing test.

- [ ] **Step 1: RED** — Retain the direct-audit result and add reducer tests for overlay, continuity-receipt, and motion-current-action transitions.
- [ ] **Step 2: GREEN** — Add minimum typed actions and deterministic reducer transitions; inject the motion action sink.
- [ ] **Step 3: REFACTOR** — Delete property assignment and notification routes while preserving deep-link/restoration semantics.
- [ ] **Step 4: Verify** — Run direct audit, focused and router commands, direct-write audit, canon checks, and independent navigation/runtime review.
- [ ] **Step 5: Finish** — Finalize the exact diff and commit this navigation child alone.

**Build/test non-regression:** Direct audit exits 0, all three focused suites and emitted broader builds pass, and no `Navigation/` target/path appears.

**Rollback:** Revert the navigation commit; never leave both notification and typed-action routes active.

**Maximum evidence claim:** The named transitions are presentation-only under Stage; broader navigation, simulator behavior, and visual correctness remain unproven.

---

### Task 8: Evaluate the Eleven-File External-Surface Compiler Candidate

**Dominant objective:** Evaluate the current duplicated external-surface cohort through candidate policy before any target creation.

**Requirements and proof obligations:** `CONSTITUTION` and `CONST-PROOF-EVIDENCE-001`; prove dependency closure, ownership compatibility, duplicate reduction, focused-test viability, and measured build impact without weakening LocalRuntimeOS ownership.

**Exact operation scope:** Update only `docs/qa/architecture/current-module-graph.json`, `docs/qa/architecture/module-candidate-policy.json`, and `docs/qa/architecture/domain-module-boundary.json`. Evaluate the 11 current `duplicateCompilationRisks` paths under `Native/Ambitions/Projection/ExternalSnapshots/`: `ExternalSurfaceSnapshotContracts.swift`, `ExternalSurfaceContractModels.swift`, `ExternalWidgetProjection.swift`, `SharedExternalSnapshotStore.swift`, `ExternalSurfaceActionPayloads.swift`, `ExternalObjectReopeningProjector.swift`, `ExternalSurfaceGlanceState.swift`, `ExternalSurfaceControlContracts.swift`, `ExternalSurfaceScopeAllowlist.swift`, `NextStepActivityAttributes.swift`, and `ExternalCreationContracts.swift`.

**Interfaces:** Consume graph/policy schemas, compile inclusions, outside consumers, focused tests, and timing metadata; produce one reproducible accepted or rejected candidate record.

**Initial condition and exits:** `python3 -c 'import json; d=json.load(open("docs/qa/architecture/current-module-graph.json")); assert d["duplicateCompilationRiskCount"] == 11'` confirms the current duplicate-membership finding. Acceptable exit A is evidence-backed rejection with no topology change. Acceptable exit B is measured policy acceptance followed by a new separately authorized extraction plan/PR; this operation never creates the target.

**Focused commands:** `bash scripts/ambitions-xcode-test-focused.sh --batch ARCH-MOD-08 --scheme AmbitionsUnitTests --test ExternalSurfaceSnapshotBoundaryTests --test ExternalSurfaceActionPayloadTests --test ExternalSurfaceControlContractsTests --test ExternalWidgetProjectionTests --test AppGroupSnapshotWriterInventoryTests`; `python3 scripts/ambitions-module-candidate-gate.py --policy docs/qa/architecture/module-candidate-policy.json --root . --json`; `python3 scripts/ambitions-changed-file-test-router.py --path docs/qa/architecture/current-module-graph.json --path docs/qa/architecture/module-candidate-policy.json --path docs/qa/architecture/domain-module-boundary.json --execute`.

**Scope and non-goals:** Evaluation only in one PR. Do not edit `project.yml`, create a target, move/delete source, evaluate generic `Features/`, or treat 45/166 lexical separability as compiler proof.

- [ ] **Step 1: Start the evidence child** — Obtain a fresh pack and authorization for the three QA files and the fixed 11-file read-only cohort.
- [ ] **Step 2: RED evidence gap** — Record missing dependency, ownership, test, or measurement fields; do not call candidate rejection a failure.
- [ ] **Step 3: GREEN operation** — Add exact consumers, compile inclusions, clean baseline, repeated build samples, variance, and independent ownership review.
- [ ] **Step 4: REFACTOR** — Normalize ordering/metadata and reproduce the policy result from a clean checkout without configuration edits.
- [ ] **Step 5: Choose an allowed exit** — Commit evidence-backed rejection, or commit acceptance evidence and create `docs/superpowers/plans/2026-07-20-architecture-modernization-external-surface-extraction.md` under separate future authorization.

**Build/test non-regression:** Current targets stay configured identically; test and measurement results record revision, compiler, cache state, command, repetitions, and variance.

**Rollback:** Revert the evaluation-data commit; no target or source move exists to unwind.

**Maximum evidence claim:** This 11-file cohort is measured and accepted or rejected; acceptance is not target authorization and rejection is not a whole-app topology conclusion.

---

### Task 9: Reconcile Architecture Closeout Evidence

**Dominant objective:** Re-derive scorecards and the requirement/owner/blocker map from active canon, current source, executable evidence, and independent review without an artificial aggregate score.

**Requirements and proof obligations:** All six global IDs; every status names current evidence, owner, blocker, unblock condition, and proof ceiling.

**Child intake and exact scope:** Admit `docs/qa/architecture/architecture-10-scorecard.md`, `docs/qa/architecture/architecture-10-scorecard.json`, `docs/qa/architecture/current-module-graph.json`, `scripts/ambitions-architecture-10-scorecard-check.py`, new `scripts/tests/test_ambitions_architecture_10_scorecard_check.py`, and `docs/qa/architecture/architecture-modernization-current-state.md` only when current evidence changes it.

**Interfaces:** Consume canon traceability, architecture inventory, mutation/direct-write results, LocalRuntimeProof, candidate decision, changed-scope validation, build/test artifacts, and review findings; produce a deterministic dimensioned scorecard and obligation map.

**Direct RED/GREEN:** RED is the scorecard checker citing purged paths or tests accepting ancestor evidence, missing owner/blocker/unblock fields, unsupported Green, missing proof taxonomy, or 10/10. GREEN is deterministic derivation at one SHA even when evidence dimensions remain Red/Yellow/Unverified.

**Focused commands:** `python3 -m unittest scripts.tests.test_ambitions_architecture_10_scorecard_check`; `python3 scripts/ambitions-architecture-10-scorecard-check.py --self-test`; `python3 scripts/ambitions-architecture-10-scorecard-check.py --scorecard docs/qa/architecture/architecture-10-scorecard.json`; `python3 scripts/ambitions-architecture-inventory.py --json`; all four canon checks and `git diff --check`.

**Binding completion rule:** Begin closeout only when every retained Task 1–8 train is implemented or explicitly blocked by a named owner-only decision or external dependency. Every blocked row must include the exact requirement ID, named owner/dependency, current evidence path/result, and objective unblock condition; “deferred,” “later,” or scheduling preference is not a blocker.

**Scope and non-goals:** Repair stale derivation and reconcile current evidence. Do not force Green, average unlike dimensions, delete history, claim release readiness, or label the program 10/10.

- [ ] **Step 1: Start at the final program head** — Verify the binding completion rule, then generate the closeout intake, pack, and authorization.
- [ ] **Step 2: RED** — Add tests for purged paths, ancestor-as-current evidence, incomplete blocker rows, unsupported Green, missing taxonomy, and aggregate 10/10.
- [ ] **Step 3: GREEN** — Use active canon/current results, preserve every unproven dimension, and map every remaining requirement to owner/dependency, evidence, and unblock condition.
- [ ] **Step 4: REFACTOR** — Run canon audit/build/skill/authority/conflict/traceability, architecture inventory/scorecard, strict quality, direct-write, LocalRuntimeProof, candidate gate, concrete router commands, and current build/test lanes.
- [ ] **Step 5: Review and finish** — Give an independent reviewer the final diff, commands, artifact SHAs, unresolved map, and claim ceiling; correct findings before finalization and commit.

**Build/test non-regression:** Derivation checks are deterministic; every lane records command, SHA, toolchain/destination when applicable, exit code, and retained result.

**Rollback:** Revert scorecard, graph, checker, tests, and reconciliation together; retain prior projections only with stale/ancestor labels.

**Maximum evidence claim:** The program is reconciled at the named revision with dimensioned status, owners, blockers, and current evidence; completion, 10/10, runtime Green, device/simulator, visual/accessibility, privacy/security, and release claims remain unavailable unless independently proven.

---

## Program Order and Stop Conditions

- [ ] Complete Task 1 before using inventory totals in later child plans.
- [ ] Complete Task 2 before compatibility children depend on its committer lineage.
- [ ] Complete Tasks 3 and 4 in their listed child order with separate packs and commits.
- [ ] Complete Task 5 only after required runtime children are integrated at one revision.
- [ ] Complete Tasks 6 and 7 as separate children; neither may create canonical authority.
- [ ] Complete Task 8 as evidence-only; any target implementation requires its own plan, authorization, and PR.
- [ ] Complete Task 9 last and enforce its binding implemented-or-named-blocker rule.

Stop when canon, pack, source ownership, a direct gate, or independent review contradicts scope. Replace the child plan and authority rather than widening a diff. Local tests do not waive authorization, and source review does not upgrade absent runtime, simulator, visual, accessibility, security, or release evidence.
