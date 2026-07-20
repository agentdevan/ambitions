# Architecture Modernization Post-Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the smallest evidence-backed architecture gaps after the canon cutover without widening authority, inventing a fixed target tree, or claiming runtime or release readiness before current proof exists.

**Architecture:** Work proceeds from inventory truth to mutation authority, owner-bounded compatibility migrations, external-effect reconciliation, proof normalization, composition and navigation repair, one measured compiler-boundary candidate, and final evidence reconciliation. Every train begins with a new child intake and canon pack, uses RED → GREEN → REFACTOR, and remains independently reviewable and reversible.

**Tech Stack:** Swift 6.3.3, SwiftUI Observation, actor-isolated SwiftData, LocalRuntimeOS command/event/replay infrastructure, XCTest, Xcode 26.6 build 17F113, XcodeGen 2.45.4, and Python repository gates.

## Global Constraints

- Active authority is `docs/canon/`; this plan is guidance, not authority or task authorization.
- Baseline evidence is the 2026-07-20 reconciliation at source head `26a4eee7c98ba62fb92caaac564a58344295656f`.
- Applicable obligations are `CONST-PROOF-EVIDENCE-001`, `CONST-RUNTIME-MUTATION-001`, `CONSTITUTION`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, and `SYSTEM-PERSISTENCE-REPLAY`.
- Before each train, create a child intake for only that train and generate a fresh bounded pack with `python3 scripts/ambitions-canon.py pack`; no source edit is authorized by this document.
- Re-derive path scope, tests, gates, and claim ceiling from live canon and current source before the first edit; stop if either differs from this plan.
- Run `python3 scripts/ambitions-canon.py task start` before tracked edits and exact-diff `python3 scripts/ambitions-canon.py task finalize` before final review.
- Keep XcodeGen authoritative: edit `project.yml` when configuration changes, then regenerate; never hand-edit the generated Xcode project.
- Route every changed file through `python3 scripts/ambitions-changed-file-test-router.py`; run the union of its focused lanes and every broader trigger it reports.
- Runtime, persistence, navigation, topology, and proof-gate changes require an independent reviewer who did not author the train.
- No train may claim device, simulator, visual, accessibility, privacy/security, release, App Store, TestFlight, architecture completion, or 10/10 without separate current evidence and authority.
- This document is not an exact-tree law and must be re-derived whenever live evidence or canon changes.
- New compiler boundaries are candidate-driven and separate-PR by default; no target creation is implied or authorized here.

---

### Task 1: Normalize the Mutation Inventory Without Behavior Change

**Dominant objective:** Make the mutation registry and direct-write inventory a precise, fail-closed work queue by removing only source-proven obsolete rows, consolidating exact duplicates, and correcting classifications only when exact source and tests support the change.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, and `CONST-PROOF-EVIDENCE-001`; preserve exhaustive enumeration and prove that every removed or merged row maps to the same live mutation or to source that no longer exists.

**Files:**
Modify `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift` and `Native/AmbitionsTests/LocalRuntimeOS/Commands/MeaningfulMutationRegistryTests.swift`; modify `scripts/ambitions-runtime-direct-write-audit.py` only if the registry contract itself is wrong; inspect but do not regenerate `docs/qa/local-runtime-proof/current-local-runtime-proof.json`.

**Interfaces:**
- Consumes: current mutation descriptors in `MeaningfulMutationRegistry` and write-path findings from `ambitions-runtime-direct-write-audit.py`.
- Produces: one canonical registry row per live mutation identity, deterministic duplicate detection, and exact evidence links usable by later owner migrations.

**Scope and non-goals:** The LocalRuntimeOS registry and its tests are the sole source-edit scope. Do not alter mutation behavior, command execution, storage, feature code, generated proof, or any classification merely because a helper name looks durable.

**Current failing executable gate:** `python3 scripts/ambitions-runtime-direct-write-audit.py` is Red at the reconciled head; the combined inventory contains 154 unresolved/unproven rows.

- [ ] **Step 1: Start the bounded child**

  Record a child intake limited to the listed registry files, run `python3 scripts/ambitions-canon.py pack`, and run `python3 scripts/ambitions-canon.py task start` before editing.

- [ ] **Step 2: RED — encode exact stale and duplicate cases**

  Add table-driven tests in `MeaningfulMutationRegistryTests.swift` that fail for each proven obsolete row, duplicate identity, or unsupported upgraded classification. Run the focused registry test through the changed-file router and retain the failing case names and exit code.

- [ ] **Step 3: GREEN — make the minimum registry correction**

  Remove only rows whose referenced source is absent, merge only rows with identical owner, mutation identity, and source location, and reclassify only rows whose existing executable test proves the declared durability class.

- [ ] **Step 4: REFACTOR — enforce deterministic uniqueness**

  Centralize the row-identity assertion in the registry test without changing production behavior; rerun the focused tests and `python3 scripts/ambitions-runtime-direct-write-audit.py`.

- [ ] **Step 5: Route, review, and commit separately**

  Run the changed-file router, canon audit/build checks, skill conformance, authority sprawl, `git diff --check`, and an independent runtime-inventory review. Commit only this train after exact-diff finalization.

**Build/test expectation:** Registry tests and every router-selected app-unit lane pass; the direct-write blocker count may fall only by the number of source-proven stale or duplicate rows, with no new row omitted.

**Rollback:** Revert this train's single commit; do not manually reconstruct deleted rows or carry its lower count into later evidence.

**Maximum evidence claim:** Source-level mutation inventory normalization is complete for the reviewed rows; no mutation is newly proven durable and runtime remains Red unless separately established.

---

### Task 2: Repair Atomic Mutation Authority in the Committer and Today

**Dominant objective:** Replace pre-authority canonical mutation with one plan → authoritative commit → materialize lineage in `RuntimeCommandMutationCommitter` and the bounded Today flows.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, and `CONST-PROOF-EVIDENCE-001`; prove no canonical state becomes visible before authority and replay converges without duplicate effects.

**Files:**
Modify `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandMutationCommitter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeTransactionCommitPolicy.swift` as required by the lineage, and only Today owners selected under `Native/Ambitions/Surfaces/Today/`; test with `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift` and current durable action/receipt tests under `Native/AmbitionsTests/Today/`.

**Interfaces:**
- Consumes: `RuntimeCommandMutationCommitter`, `RuntimeTransactionCommitPolicy`, the event journal, and Today command plans.
- Produces: a single authoritative plan/commit/materialize result whose receipt and replay cursor identify the committed event lineage.

**Scope and non-goals:** Limit work to the committer and Today rows named by the fresh child intake. Do not migrate Capture, Goals, Time, You, external effects, or create a second transaction abstraction.

**Current failing executable gate:** `python3 scripts/ambitions-local-runtime-proof.py` and `python3 scripts/ambitions-runtime-direct-write-audit.py` are Red; live inspection identified pre-authority canonical mutation in the committer and Today.

- [ ] **Step 1: Start the bounded child and freeze row identities**

  Generate a fresh pack and authorization for the committer plus exact Today rows; record each registry identity before editing so no adjacent mutation is silently absorbed.

- [ ] **Step 2: RED — inject failure at every authority boundary**

  Extend `RuntimeAtomicCommitTests.swift` and the selected Today tests for crash/failure before journal write, after journal write before materialization, materialization retry, duplicate command identity, and replay after relaunch. Verify each new case fails for the pre-authority path.

- [ ] **Step 3: GREEN — establish one lineage**

  Change the committer and selected Today callers so they calculate a mutation plan without canonical writes, atomically commit authority, then materialize from the committed result. Preserve stable command/event identifiers across retries.

- [ ] **Step 4: REFACTOR — remove the bypass**

  Delete only the now-unreachable pre-authority branch, keep the narrow public interface, and prove ordinary replay does not reissue external work or apply the canonical mutation twice.

- [ ] **Step 5: Route and independently review**

  Run focused transaction and Today tests, both Red gates, the changed-file router union, canon checks, and independent runtime/persistence review before exact-diff finalization and a standalone commit.

**Build/test expectation:** All selected atomic and Today tests pass, router-selected build-for-testing does not regress, and failure injection leaves no pre-authority canonical state at every tested boundary.

**Rollback:** Revert the standalone commit and restore the pre-train registry classifications; never retain new durable labels if the authority repair is reverted.

**Maximum evidence claim:** The named committer and Today rows use the tested authoritative lineage at the reviewed revision; no other domain or app-wide atomicity is proven.

---

### Task 3: Migrate Compatibility Paths in Five Owner-Bounded Subtrains

**Dominant objective:** Replace remaining compatibility mutations with the authoritative command lineage without combining independent owners into a mega-diff.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, and `CONST-PROOF-EVIDENCE-001`; every migrated row needs exact failure, retry, restart, and replay evidence.

**Files and subtrain order:**
3A is the Today remainder under `Native/Ambitions/Surfaces/Today/` with `Native/AmbitionsTests/Today/`; 3B is Capture under `Native/Ambitions/Surfaces/Capture/` with `Native/AmbitionsTests/Capture/`; 3C is Goals under `Native/Ambitions/Surfaces/Goals/` with `Native/AmbitionsTests/Goals/`; 3D is Time rituals/step lifecycle in `Native/Ambitions/Surfaces/Time/`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+TimeCommands.swift`, and current Time tests; 3E is You preferences/onboarding/startup under `Native/Ambitions/Surfaces/You/` with matching app/startup tests. Each may update `MeaningfulMutationRegistry.swift` only for proven rows.

**Interfaces:**
- Consumes: the Task 2 authoritative committer, `RuntimeCommandClient`, domain command executor entry points, and stable command identifiers.
- Produces: owner-local command plans and receipts with no feature-side canonical write before the authoritative commit.

**Scope and non-goals:** One live owner is one reviewable subtrain, pack, finalization, and commit. Do not share a diff across 3A–3E, move UI ownership, redesign features, or upgrade rows outside the selected owner.

**Current failing executable gate:** `python3 scripts/ambitions-runtime-direct-write-audit.py` is Red; the reconciled unproven totals include Today 7, Capture 31, Goals 18, Time 16, and You 9.

- [ ] **Step 1: Start subtrain 3A with exact rows and fresh authority**

  Create a Today-only intake and pack, select only currently live remainder rows, and repeat the following RED → GREEN → REFACTOR cycle before proceeding to 3B.

- [ ] **Step 2: RED — prove the selected owner's failure boundaries**

  Add focused tests for pre-write failure, post-write/pre-materialize failure, duplicate identity, relaunch replay, and receipt equivalence; retain the expected failures against the compatibility path.

- [ ] **Step 3: GREEN — route the owner through the authoritative client**

  Replace only the selected direct mutation with `RuntimeCommandClient`/executor planning and the Task 2 committer lineage; preserve feature-visible behavior and stable identifiers.

- [ ] **Step 4: REFACTOR — delete the selected compatibility path**

  Remove the obsolete branch, update only its exact registry rows, run the owner-focused tests, direct-write audit, LocalRuntimeProof audit, and changed-file router union.

- [ ] **Step 5: Review, finalize, and commit the owner independently**

  Obtain independent runtime/persistence review, finalize the exact diff, and commit before starting the next owner. Repeat Steps 1–5 for 3B Capture, 3C Goals, 3D Time, and 3E You with separate packs and commits.

**Build/test expectation:** Each owner subtrain passes its focused tests and router-selected broader lanes before the next begins; existing app-unit build-for-testing must not regress and blocker reductions must equal exact proven rows.

**Rollback:** Revert only the failing owner's commit and restore only its registry rows; completed earlier owners remain independently revertible and reviewable.

**Maximum evidence claim:** Only the named rows in each committed owner subtrain are proven migrated; the remaining inventory and app-wide runtime posture keep their prior status.

---

### Task 4: Reconcile External Ingestion and Effects

**Dominant objective:** Make Share and App Intent intake durably acknowledge or remove input only after command success, then prove EventKit, notification, widget, and other external-effect ordering.

**Requirements and proof obligations:** `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `CONST-RUNTIME-MUTATION-001`, and `CONST-PROOF-EVIDENCE-001`; external work must be durable, deduplicated, replay-safe, and offline-safe.

**Files:**
Modify exact Share/App Intent owners selected from `Native/Ambitions/`, exact adapters selected from `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/`, and notification/EventKit clients only when named by intake; test under `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/`; update `MeaningfulMutationRegistry.swift` only for exact proven rows.

**Interfaces:**
- Consumes: durable command receipts, stable ingestion identifiers, external-write intent records, and replay cursors.
- Produces: acknowledgement/removal after command success and idempotent external-effect dispatch keyed by the durable intent identity.

**Scope and non-goals:** Start with Share/App Intent acknowledgement, then review EventKit, notifications, widgets, and remaining adapters as separately reviewable children. Do not place external APIs inside the atomic local store transaction or claim network delivery.

**Current failing executable gate:** `python3 scripts/ambitions-local-runtime-proof.py` is Red and external-effect coverage is incomplete; the registry retains unproven App Intents, notifications, widgets/extensions, and external-adapter rows.

- [ ] **Step 1: Authorize one ingestion or effect child**

  Generate a fresh pack naming one live owner, its adapter, exact tests, and exact registry rows; never combine all external surfaces in one diff.

- [ ] **Step 2: RED — encode the complete failure matrix**

  Add executable cases for crash-before-write, crash-after-write-before-ack, duplicate delivery, timeout, offline relaunch, and ordinary replay non-reissue. Verify the current path fails the relevant case before implementation.

- [ ] **Step 3: GREEN — persist intent and acknowledge after success**

  Give ingestion and effect records stable identities, commit local authority first, dispatch through the narrow adapter, persist completion, and remove or acknowledge intake only after the command receipt succeeds.

- [ ] **Step 4: REFACTOR — unify idempotency at the adapter seam**

  Remove duplicate feature-side retry flags only after tests prove the durable intent owns retry state; retain cancellation and timeout semantics.

- [ ] **Step 5: Route, review, and repeat by live owner**

  Run external-write tests, focused ingestion tests, both runtime gates, router-selected lanes, and independent runtime/persistence review; finalize and commit one owner before authorizing the next.

**Build/test expectation:** The six required failure/replay cases pass for each owner, existing focused feature behavior passes, and ordinary replay issues no duplicate external call.

**Rollback:** Revert one owner commit and restore its prior acknowledgement plus registry state; do not preserve completion markers written by an incompatible schema in test fixtures.

**Maximum evidence claim:** Durable ordering and replay behavior are proven only for the reviewed external owner under tested failures; third-party delivery, device behavior, and all other adapters remain unproven.

---

### Task 5: Normalize Crash, Replay, Migration, Corruption, and Proof Gates

**Dominant objective:** Repair stale or circular proof checks, run current executable evidence at one revision, and regenerate LocalRuntimeProof only after every required check is Green.

**Requirements and proof obligations:** `CONST-PROOF-EVIDENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `RUNTIME-MUTATION-SEQUENCE-001`, and `CONST-RUNTIME-MUTATION-001`; proof producers may consume source and executed results, never their own prior Green artifact.

**Files:**
Modify `scripts/ambitions-local-runtime-proof.py` and only stale runtime gate dependencies identified by executable failure under `scripts/`; test `RuntimeAtomicCommitTests.swift`, `RuntimeDomainEventReplayTests.swift`, and exact migration/repair/corruption suites under `Native/AmbitionsTests/LocalRuntimeOS/`; regenerate `docs/qa/local-runtime-proof/current-local-runtime-proof.json` only after Green.

**Interfaces:**
- Consumes: current test results, mutation registry output, direct-write audit output, migration/corruption evidence, revision, toolchain, and destination metadata.
- Produces: a non-circular LocalRuntimeProof artifact bound to the exact source SHA and executable result set.

**Scope and non-goals:** Repair only failing proof dependencies demonstrated at current HEAD. Do not hand-edit Green status, suppress blockers, accept ancestor output, or regenerate while any required check is Red.

**Current failing executable gate:** `python3 scripts/ambitions-local-runtime-proof.py` reports Red with 20 checks, 17 pass, 3 fail, and 157 blockers; the checked-in July 4 Green artifact is stale.

- [ ] **Step 1: Start the proof-normalization child**

  Generate a pack naming the proof script, exact failing dependencies, exact executable suites, and the generated artifact; record current SHA and toolchain before edits.

- [ ] **Step 2: RED — prove stale and circular inputs fail closed**

  Add or extend script tests so an ancestor artifact, missing command result, mismatched SHA, circular self-consumption, and failed migration/corruption lane each force Red.

- [ ] **Step 3: GREEN — bind gates to current executable inputs**

  Replace purged paths and circular artifact reads with current source, command exit codes, structured results, revision, toolchain, and destination metadata; preserve all blockers until their evidence passes.

- [ ] **Step 4: REFACTOR — execute the current proof matrix once**

  Run atomic, replay, restart, migration, corruption, duplicate, direct-write, and registry lanes at one revision. Regenerate `current-local-runtime-proof.json` only if the gate independently computes Green.

- [ ] **Step 5: Independently review proof provenance**

  Have a non-author verify every artifact input and claim ceiling, run canon checks plus the changed-file router, finalize the exact diff, and commit proof normalization separately.

**Build/test expectation:** All proof-script tests and required runtime suites pass at one SHA; generation is deterministic and a missing or stale input returns nonzero rather than retaining Green.

**Rollback:** Revert script and generated artifact together; restore the prior artifact only as explicitly stale historical evidence, never as current Green.

**Maximum evidence claim:** LocalRuntimeProof is current and Green only for its enumerated checks at the bound revision; it does not prove simulator, device, visual, accessibility, security, or release readiness.

---

### Task 6: Repair Composition Boundaries

**Dominant objective:** Remove feature-level raw container reach-through, optional live dependencies, default live runtime construction, globals, and NotificationCenter product routing through narrow injected clients and typed actions.

**Requirements and proof obligations:** `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `CONSTITUTION`, and `CONST-PROOF-EVIDENCE-001`; preserve centralized construction while proving no replacement creates a second runtime authority.

**Files:**
Modify `Native/Ambitions/App/AppContainerFactory.swift`, `RuntimeCommandClient.swift`, `AmbitionsRuntimeServices.swift`, and one exact owner under `Native/Ambitions/Surfaces/`; test `Native/AmbitionsTests/App/AppContainerFactoryTests.swift` and `Native/AmbitionsTests/LocalRuntimeOS/Boundary/RuntimeCommandClientTests.swift`.

**Interfaces:**
- Consumes: `RuntimeCommandClient`, `AmbitionsRuntimeServices`, and `AppContainerFactory` composition roots.
- Produces: non-optional feature dependencies and typed injected actions/events whose live implementations are constructed only at the app root.

**Scope and non-goals:** Migrate one reach-through/global/routing owner per child. Do not move canonical state into view models, introduce a service locator, rewrite unrelated views, or combine navigation ownership with composition work.

**Current failing executable gate:** `python3 scripts/ambitions-architecture-10-scorecard-check.py` is Red at the reconciled head; source inspection records direct container reach-through, optional/default-live/global dependencies, and NotificationCenter routing.

- [ ] **Step 1: Select and authorize one composition bypass**

  Use source plus tests to name one exact owner, dependency, factory construction point, and focused test files in a fresh child intake and pack.

- [ ] **Step 2: RED — make implicit live construction observable**

  Add focused tests that omit the dependency or install a recording client and fail when the feature constructs a live runtime, reaches through the container, reads a global, or posts product routing through NotificationCenter.

- [ ] **Step 3: GREEN — inject the narrow dependency**

  Add the smallest typed query, command, or action interface to the existing boundary, construct its live value in `AppContainerFactory`, and require the feature to receive it explicitly.

- [ ] **Step 4: REFACTOR — remove the bypass**

  Delete the selected optional/default/global/NotificationCenter path, keep previews supplied with explicit inert fixtures, and ensure only the app root constructs live implementations.

- [ ] **Step 5: Route and independently review**

  Run factory and boundary tests, selected feature tests, architecture check, direct-write audit, changed-file router union, and independent runtime/composition review before a standalone commit; repeat with a new child for the next owner.

**Build/test expectation:** Focused dependency tests pass, preview/test construction stays explicit, router-selected build-for-testing passes, and no new container reach-through or global live constructor appears.

**Rollback:** Revert the one-owner commit, including its factory wiring and tests; do not leave an unused public client interface behind.

**Maximum evidence claim:** The reviewed feature owner uses explicit narrow composition; app-wide dependency cleanup and runtime behavior outside the focused tests remain unproven.

---

### Task 7: Repair Navigation Responsibility Without Moving Authority

**Dominant objective:** Preserve Stage canonical ownership while making navigation presentation-only and routing all transitions through one typed reducer/action boundary.

**Requirements and proof obligations:** `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001`, and where a transition triggers commands, `CONST-RUNTIME-MUTATION-001` plus `RUNTIME-MUTATION-SEQUENCE-001`; prove presentation cannot mutate canonical domain state directly.

**Files:**
Modify exact owners under `Native/Ambitions/Stage/`, including `StageReducer.swift` and `StageStore.swift`, plus one proven direct-mutation/NotificationCenter caller at a time; test `Native/AmbitionsTests/App/StageThinnessOwnershipTests.swift`.

**Interfaces:**
- Consumes: typed Stage actions and current `StageReducer` transitions.
- Produces: presentation-only navigation intents reduced by Stage, with command work delegated through injected runtime actions rather than navigation state.

**Scope and non-goals:** Keep `Native/Ambitions/Stage/` as canonical owner. Do not create a `Navigation/` authority, move domain state into routes, alter deep-link behavior without a failing test, or amend canon inside this train.

**Current failing executable gate:** `python3 scripts/ambitions-architecture-10-scorecard-check.py` is Red; current source evidence records split navigation ownership, direct Stage mutations, and NotificationCenter routing.

- [ ] **Step 1: Authorize one direct transition bypass**

  Generate a fresh pack naming the exact caller, Stage action/reducer/store files, focused test, and any runtime action boundary touched.

- [ ] **Step 2: RED — prove the bypass violates one reducer transition**

  Extend `StageThinnessOwnershipTests.swift` and the caller's focused test so direct Stage mutation or NotificationCenter routing fails while a typed Stage action remains observable.

- [ ] **Step 3: GREEN — route through the typed action**

  Add the minimum Stage action and deterministic reducer transition, inject it into the caller, and delegate any domain mutation to the existing runtime command boundary.

- [ ] **Step 4: REFACTOR — remove duplicate route ownership**

  Delete the selected direct mutation/notification observer, preserve deep-link and restoration semantics, and keep navigation models free of canonical domain storage.

- [ ] **Step 5: Route and independently review**

  Run Stage ownership tests, caller tests, architecture and direct-write audits, router-selected broader lanes, and independent navigation/runtime review before a standalone commit.

**Build/test expectation:** The selected transition passes reducer, restoration, and caller tests; no new `Navigation/` target/path authority exists and build-for-testing does not regress.

**Rollback:** Revert the single transition commit and restore the exact prior route; do not leave duplicate notification and typed-action routes enabled together.

**Maximum evidence claim:** The reviewed transition is presentation-only under Stage ownership; broader navigation consistency, simulator behavior, and visual correctness remain unproven.

---

### Task 8: Evaluate One Measured Compiler-Boundary Candidate

**Dominant objective:** Evaluate one dependency-closed cohort—prefer the duplicated external-surface contracts if still live—through current candidate policy before any target creation.

**Requirements and proof obligations:** `CONSTITUTION` and `CONST-PROOF-EVIDENCE-001`; demonstrate dependency closure, ownership compatibility, compile duplication reduction, focused test viability, and measured build impact without weakening LocalRuntimeOS authority.

**Files:**
Modify evaluation data only in `docs/qa/architecture/current-module-graph.json`, `module-candidate-policy.json` when its live schema requires it, and `domain-module-boundary.json`; inspect `project.yml`, `Packages/AmbitionsDesignSystem/`, `Native/Ambitions/Core/Time/`, and selected cohort paths; run `scripts/ambitions-module-candidate-gate.py`.

**Interfaces:**
- Consumes: current module graph, candidate-policy schema, source-consumer graph, compile-inclusion graph, focused tests, and baseline timing metadata.
- Produces: one accepted or rejected candidate record with exact cohort paths, consumers, ownership result, measurement protocol, results, blockers, and rollback decision.

**Scope and non-goals:** This train evaluates one cohort in one PR. Do not create a target, edit `project.yml`, move/delete source, select generic `Features/`, or infer approval from the 45/166 lexical separability triage.

**Current failing executable gate:** `python3 scripts/ambitions-module-candidate-gate.py` currently authorizes zero future targets and rejects the whole-domain candidate; 11 production paths are multiply compiled with 17 extra inclusions.

- [ ] **Step 1: Authorize an evaluation-only child**

  Generate a fresh pack naming the exact cohort and the three QA data files. If duplicated external-surface contracts are no longer dependency-closed, record that rejection and stop rather than substituting an unreviewed cohort.

- [ ] **Step 2: RED — run policy on current evidence**

  Refresh the current graph inputs without changing targets, run `python3 scripts/ambitions-module-candidate-gate.py`, and retain the exact rejection reasons for dependency closure, ownership, consumers, tests, or measurements.

- [ ] **Step 3: GREEN — complete evidence, not implementation**

  Add only missing measured facts: exact paths, compile inclusions, outside consumers, focused tests, clean baseline, repeated candidate build samples, and independent ownership review. A valid rejection is Green for this evaluation train.

- [ ] **Step 4: REFACTOR — make the decision reproducible**

  Normalize candidate data ordering and metadata, rerun the gate from a clean checkout state, and confirm the same accept/reject result without editing project configuration.

- [ ] **Step 5: Independently review and close the candidate PR**

  Obtain topology and ownership review, run canon checks, architecture inventory, changed-file routing, and exact-diff finalization. If accepted, create a separate future PR and fresh authorization for target work.

**Build/test expectation:** Existing targets and tests remain byte-for-byte configured; measurements identify compiler, revision, cache state, command, repetitions, and variance, and the candidate gate result is reproducible.

**Rollback:** Revert only the evaluation-data commit; no target or source move exists to unwind.

**Maximum evidence claim:** One candidate is measured and accepted or rejected by current policy; acceptance is not authorization to create a target and rejection is not a whole-app topology conclusion.

---

### Task 9: Reconcile Architecture Closeout Evidence

**Dominant objective:** Re-derive current scorecards and the whole-program obligation map from live canon, current source, current executable evidence, and independent review without collapsing dimensions into an artificial score.

**Requirements and proof obligations:** `CONST-PROOF-EVIDENCE-001`, `CONSTITUTION`, `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, and `SYSTEM-PERSISTENCE-REPLAY`; every status must identify current evidence, owner, blocker, and proof ceiling.

**Files:**
Modify `docs/qa/architecture/architecture-10-scorecard.md`, `architecture-10-scorecard.json`, `current-module-graph.json`, and `scripts/ambitions-architecture-10-scorecard-check.py`; update `architecture-modernization-current-state.md` only if current evidence changes it.

**Interfaces:**
- Consumes: canon traceability, authority checks, architecture inventory, mutation/direct-write results, LocalRuntimeProof, module-candidate decisions, changed-scope validation, build/test artifacts, and independent review findings.
- Produces: a deterministic dimensioned scorecard plus one requirement/owner/blocker map with explicit Source, Build, Runtime, Simulator, Visual, and Unverified evidence classes.

**Scope and non-goals:** Repair stale purged-path derivation and reconcile current evidence only. Do not force Green, average unlike proof dimensions, delete historical plans, claim release readiness, or label the program 10/10.

**Current failing executable gate:** `python3 scripts/ambitions-architecture-10-scorecard-check.py` is Red because current derivation still references stale purged paths; strict quality, direct-write, and LocalRuntimeProof are also Red at the reconciliation head.

- [ ] **Step 1: Start the closeout child at the final program head**

  After Tasks 1–8 are merged or explicitly deferred, generate a fresh pack naming exact scorecard files, derivation script, current evidence inputs, and the changed-scope validation union.

- [ ] **Step 2: RED — assert active-canon and current-evidence derivation**

  Add checker cases that fail on purged authority paths, ancestor evidence presented as current, missing owner/blocker fields, unsupported Green, missing proof taxonomy, or any aggregate 10/10 claim.

- [ ] **Step 3: GREEN — re-derive every dimension**

  Replace stale inputs with active canon and current executable results, preserve Red/Yellow/Unverified wherever evidence is incomplete, and map every remaining requirement to an exact owner and blocker.

- [ ] **Step 4: REFACTOR — run the changed-scope validation union**

  Run canon audit/build/skill/authority/conflict/traceability gates, architecture inventory and scorecard checks, strict quality, direct-write audit, LocalRuntimeProof, module candidate gate, changed-file router union, and current build/test lanes required by touched scope.

- [ ] **Step 5: Obtain independent whole-program review**

  Give the reviewer the final diff, all current command results, artifact SHAs, unresolved map, and claim ceiling. Correct every unsupported claim before exact-diff finalization and the closeout commit.

**Build/test expectation:** The scorecard check is deterministic and Green as a derivation check even when individual dimensions remain Red; every executed lane records command, revision, toolchain/destination where applicable, exit code, and retained result.

**Rollback:** Revert scorecard, graph, checker, and reconciliation changes together; retain prior projections only with their original stale/ancestor labels.

**Maximum evidence claim:** The architecture program is reconciled at the named revision with dimension-specific status, owners, blockers, and current evidence. Architecture completion, 10/10, runtime Green, simulator/device proof, visual/accessibility approval, privacy/security approval, and release readiness remain unavailable unless each is independently proven.

---

## Program Execution Order and Stop Conditions

- [ ] Complete Task 1 before using registry totals to authorize later owner migrations.
- [ ] Complete Task 2 before any compatibility subtrain depends on the authoritative committer.
- [ ] Complete Task 3 owner subtrains separately; a blocked owner does not authorize widening another owner.
- [ ] Complete Task 4 only after its selected domain command path is authoritative.
- [ ] Complete Task 5 after required runtime implementations are merged, because proof regeneration must observe the final executable lineage.
- [ ] Execute Tasks 6 and 7 as separate one-owner commits; neither may create new canonical authority.
- [ ] Execute Task 8 as evaluation-only and use a separate PR for any accepted implementation.
- [ ] Execute Task 9 last against the actual final head and unresolved queue.

Stop immediately when canon, the generated pack, live source ownership, a failing gate, or independent review contradicts the planned scope. Replace the child intake and pack rather than widening a diff. A successful local test never waives authorization, and an accepted source review never upgrades absent runtime, simulator, visual, accessibility, security, or release evidence.
