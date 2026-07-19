# Ambitions 10/10 Architecture Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the current Ambitions source tree into a robust, modern, future-facing SwiftUI modular monolith whose runtime, module boundaries, dependency flow, tests, and proof all enforce the same architecture.

**Architecture:** Replace exact-path architecture law with a versioned, compiler-enforced architecture contract consumed by the XcodeGen app graph and root Swift package. The contract binds product invariants, logical module ownership, allowed dependency edges, public APIs, and migration/deletion proof; it does not constitutionalize every directory or leaf filename. Every meaningful life-state mutation must pass through one injected command executor, produce a durable event/projection/receipt lineage, and survive replay after process restart. SwiftUI feature targets render immutable projections and send intents; the app target is composition-only; storage and Apple-framework integrations remain adapters.

**Tech Stack:** Swift 6 strict concurrency with the installed Swift 6.3.3 compiler, SwiftUI Observation, XcodeGen, SwiftData and SQLite adapters, Swift Testing for unit/integration tests, XCTest/XCUIAutomation for UI and performance tests, Xcode 26.6, Instruments 26, OSLog/signposts, Python architecture guards.

## Global Constraints

- Work on `main` only unless the user explicitly requests otherwise.
- Keep `IPHONEOS_DEPLOYMENT_TARGET = 26.0` until product canon explicitly changes it.
- Build continuously with the installed Xcode 26.6 / Swift 6.3.3 toolchain. Xcode 27, Swift 6.4, and iOS 27-only APIs are outside this program because that toolchain is unavailable; they are future compatibility work, not an architecture-completion gate.
- Preserve XcodeGen; `project.yml` remains target-graph source truth.
- Preserve the architecture contract, not an immutable directory diagram. Logical module ownership, dependency direction, product boundaries, and compiler target membership are binding; internal folders may evolve when the same train updates canon, manifests, imports, audits, migration evidence, and deletion proof.
- Do not create a package or target split until a new linked ADR proves deletion/collapse is insufficient and specifies dependency graph, validation, and rollback.
- Do not add new `+02`, `+03`, or `+04` files, broad `Models.swift` files, or production Swift files above 600 lines.
- Until Task 8 installs the owner-approved canon amendment, new runtime authority remains under the currently binding `Core/LocalRuntimeOS/` owner. Task 8 reauthorizes the logical `Core/Runtime` module; migration then moves authority without leaving a parallel runtime.
- Persistent surfaces remain Today / Goals / Time / You; Capture remains a global composer; Motion remains Navigation behavior.
- The private life graph remains local and inspectable. R2 and Source Atlas remain public-reference-only.
- New source and repairs use test-first red/green cycles. Lexical or path tests may guard governance but may not prove runtime behavior.
- Each train must leave the app buildable, preserve user data, include rollback, and close no higher than its current evidence permits.
- Physical-device execution is foregone for this program by owner direction on 2026-07-09. Simulator evidence may satisfy this architecture program's automated gates, but it cannot prove physical-device behavior, manual VoiceOver quality, independent Visual Green, TestFlight readiness, App Store readiness, or Release Green.
- The owner approved Task 8's compiler-enforced module-boundary ADR direction on 2026-07-09. The ADR must still contain the measured dependency graph, validation, rollback, and proof ceilings required below.
- The owner approved the conventional modular-monolith direction on 2026-07-10: `App`, `Core`, `Data`, `Platform`, `Features`, `Navigation`, `DesignSystem`, `UI`, `Support`, `Extensions`, and `Tests` are the proposed initial physical organization, not permanent constitutional path law.
- Historical junk is deleted rather than renamed or archived. Retain compatibility source only while a current migration/runtime consumer and executable removal gate require it; Git history is the archive.

---

## Architecture contract gates

Task 8 installs one machine-readable `architecture-contract.json` plus an executable schema/audit. The contract must contain all eight gates below; generated run logs remain ignored and are never treated as durable canon.

1. **Product / IA to module ownership:** every active Linear canonical-spec capability maps to one logical owner, one target, and one implementation status. No product capability may gain two mutation, projection, presentation, or adapter authorities.
2. **Route and presentation contract:** every root, global flow, contextual flow, drilldown, sheet, extension entry, and deep link declares its typed route, presentation style, root-dock behavior, dismissal law, and owning feature. Today / Goals / Time / You remain the only persistent roots.
3. **Canonical object migration invariants:** Life Area, Goal, Goal Path, Step, Event, Reminder, Note, Saved-for-Later Draft, Proof, Attachment, Closure, Schedule Placement, Receipt, History Event, Source Reference, Recovery Segment, and Import/Diff Record preserve identity, provenance, lifecycle, relationships, recurrence, deletion/restore, command/event/projection/receipt lineage, and replay equality through moves and schema changes.
4. **Parent Feature coverage:** the thirteen Parent Feature candidates in the Linear canonical design spec map to bounded targets/trains and explicit `required`, `optional`, `aspirational`, `deprecated`, or `unsupported` status. They are coverage inventory, not automatic implementation or launch claims.
5. **Old-path and duplicate-authority deletion:** a target/path migration cannot close while the old owner still contains reachable product/runtime policy. Shims must be policy-free, named in the contract, and deleted by a declared train. Historical non-source junk is deleted, not relocated.
6. **Known-issue deduplication:** every discovered gap maps to an existing live issue/dedupe key or records why a new issue is required. Architecture work must not manufacture duplicate tracker authority.
7. **Authority conflict register:** current repo truth, the Linear canonical design spec, the owner-approved architecture contract, live source, and proof artifacts are compared explicitly. Product/object/IA law is preserved; stale source-path advice and obsolete proof assumptions are superseded in the same canon amendment.
8. **Proof-ceiling reconciliation:** simulator automation may satisfy this architecture program, but the physical-device waiver cannot prove device behavior, manual VoiceOver quality, independent Visual Green, TestFlight readiness, App Store readiness, or Release Green.

The executable audit fails closed when a gate is missing, an owner is duplicated, a forbidden edge exists, a stale owner remains reachable, a canonical object loses migration coverage, or a claim exceeds its evidence ceiling.

### Architecture contract mechanics

- **Stable logical IDs:** every module has a path-independent identifier such as `ambitions.domain`, `ambitions.runtime.api`, `ambitions.feature.today`, or `ambitions.navigation`. Paths and target names are versioned metadata; moves cannot manufacture a second logical module.
- **Monotonic CI ratchets:** forbidden-edge count, duplicate-owner count, unproven-mutation count, compatibility-shim count, nonconforming-filename count, public-API surface, and release-binary support/debug source count may only stay flat or improve within a migration train. Any regression requires a rejected build or an owner-approved contract version with evidence.
- **Per-module budgets:** each module declares allowed frameworks, allowed logical dependencies, public symbol allowlist, maximum dependency fan-out, and measured clean/incremental build contribution. `@testable import` cannot bypass production boundaries in integration or UI targets.
- **Support exclusion:** previews, fixtures, scenarios, debug menus, architecture probes, and test helpers must not enter the Release application or extension binary unless the contract explicitly classifies a production diagnostic with privacy and size proof.
- **Expiring shims:** every compatibility shim declares `logicalOwner`, `consumer`, `introducedBy`, `removalTask`, and `removalCondition`. The audit fails when the removal condition is satisfied but the shim remains, or when a shim contains product/runtime policy.

Task 8 makes the architecture-contract audit blocking in local quality gates and CI for every source, manifest, canon, or contract change. A flexible physical layout is acceptable only because these fitness functions remain mandatory.

## Proposed source layout, not constitutional law

This is the initial migration shape. It is a planning aid and package/source-membership proposal. The versioned architecture contract and compiler graph are authoritative; a later measured improvement may change these folders without a product-canon rewrite when ownership, dependency, public API, migration, deletion, and proof gates remain Green.

```text
Native/
  Ambitions/
    App/
      Composition/
      Lifecycle/

    Core/
      Domain/
      ExternalSurfaceContracts/
      Runtime/
        API/
        Commands/
        Events/
        Transactions/
        State/
        Projections/
        Receipts/
        Replay/

    Data/
      Persistence/
      Search/
      Migration/
      Backup/

    Platform/
      Apple/
      Account/
      CloudKit/
      SourceAtlas/

    Features/
      Today/
      Goals/
      Time/
      You/
      Steps/
      CaptureComposer/
      Search/
      Trust/

    Navigation/
      Routes/
      Shell/
      Motion/

    DesignSystem/
    UI/
    Support/

  Extensions/
    Widget/
    Share/

  Tests/
    Unit/
    Integration/
    UI/
    Fixtures/
    Support/
```

Product IA does not follow filesystem nesting: only Today / Goals / Time / You are persistent roots; CaptureComposer and Search are global non-root flows; Trust is contextual; Motion is behavior; Steps is a shared canonical-object flow.

## 10/10 score contract

The program must not award points by prose or file presence. The final score is earned only when every gate in a row passes on the same commit.

| Dimension | Current working score | 10/10 exit contract |
| --- | ---: | --- |
| Overall architecture | 4/10 | Acyclic target graph; one mutation authority; Navigation is presentation/routing only; zero duplicate production owners; no architecture claim relies only on names or paths. |
| Runtime foundations | 4.5/10 | Every enumerated meaningful mutation produces durable command, semantic event, projection, receipt, and replay evidence; restart, duplicate, rollback, corruption, and outbox fault tests pass. |
| Compile-time modularity | 2/10 | Compiler-enforced Domain, Runtime API, Runtime Core, Data Adapter, Platform Adapter, Navigation, and feature boundaries; a feature edit does not rebuild the whole app graph; no target cycle. |
| Dependency discipline | 3/10 | No service locator in feature/UI code; no optional live environment dependencies; no default-created live runtime; no internal NotificationCenter routing; composition exists only in App bootstrap. |
| Proof/test integrity | 4/10 | Behavior claims are backed by executable state/output assertions; lexical tests are classified as governance-only; critical runtime tests use real stores and process-restart replay; required lanes have zero skips, retries, or expected failures. |

## Target dependency graph

Expand the existing root Swift package into focused targets whose source membership is declared by the architecture contract and manifests. `project.yml` continues to own the app, extension, scheme, and embedding graph; `Package.swift` owns reusable compile boundaries. Paths are an implementation detail; target identity, dependency direction, ownership, public API, and proof are the contract. Do not move source into decorative package folders that add no ownership or compile boundary.

```text
AmbitionsDomain
      ↑
AmbitionsRuntimeAPI
      ↑
AmbitionsRuntimeCore ← AmbitionsData
      ↑                    ↑
      └─────────── AmbitionsPlatformApple

AmbitionsExternalSurfaceContracts → AmbitionsDomain

AmbitionsFeatureToday ───────────┐
AmbitionsFeatureGoals ───────────┤
AmbitionsFeatureTime ────────────┤
AmbitionsFeatureYou ─────────────┤
AmbitionsFeatureSteps ───────────┼─→ AmbitionsNavigation → AmbitionsApp
AmbitionsFeatureCaptureComposer ─┤
AmbitionsFeatureSearch ──────────┤
AmbitionsFeatureTrust ───────────┘

AmbitionsDesignSystem → feature targets and Navigation only
```

Dependency rules:

```text
Domain imports Foundation only.
RuntimeAPI imports Domain.
RuntimeCore imports Domain + RuntimeAPI.
Data imports Domain + RuntimeAPI and implements storage ports.
PlatformApple imports Domain + RuntimeAPI and implements platform ports; it never owns canonical state.
ExternalSurfaceContracts imports Domain only and owns redacted cross-process DTOs.
Feature and Trust targets import Domain + RuntimeAPI + DesignSystem.
Feature targets never import Data, PlatformApple, App, or one another.
Navigation imports feature targets + RuntimeAPI + DesignSystem.
App imports and composes every target; no other target imports App.
```

## Program order

```text
Measure → make proof honest → establish one runtime seam → make commit event-first →
repair Time → repair all mutations → prove crash/replay → approve module ADR → extract targets →
remove service locator → install thin Navigation → modernize SwiftUI/Swift 6.3 → simulator proof → delete debt
```

---

### Task 1: Freeze the baseline and install the earned-score ledger

**Files:**
- Create: `docs/qa/architecture/architecture-10-scorecard.md`
- Create: `docs/qa/architecture/architecture-10-scorecard.json`
- Create: `docs/qa/architecture/current-module-graph.json`
- Modify: `docs/qa/KNOWN_ISSUES.md`
- Test: `scripts/ambitions-architecture-10-scorecard-check.py`

**Interfaces:**
- Consumes: current source inventory, `project.yml`, runtime proof output, strict quality gate output.
- Produces: a machine-readable baseline and a fail-closed scorer that later tasks update.

- [ ] **Step 1: Write scorer self-tests that reject prose-only Green**

```python
def test_dimension_requires_all_evidence():
    row = {"status": "green", "evidence": [], "requiredGates": ["runtime-restart"]}
    assert validate_dimension(row) == ["green dimension has no evidence", "missing gate runtime-restart"]
```

- [ ] **Step 2: Run the self-test and verify it fails because the scorer does not exist**

Run: `python3 scripts/ambitions-architecture-10-scorecard-check.py --self-test`

Expected: nonzero exit with the missing-script or missing-function error.

- [ ] **Step 3: Implement the scorer and capture the current baseline**

The JSON must record exact commit SHA, branch, source counts, target graph, validator results, five numeric working scores, evidence paths, blockers, and forbidden claims. A numeric score without all mandatory gates remains advisory and cannot produce Green.

- [ ] **Step 4: Run baseline validation**

Run:

```bash
python3 scripts/ambitions-architecture-10-scorecard-check.py --self-test
python3 scripts/ambitions-architecture-10-scorecard-check.py
python3 scripts/ambitions-remediation-governance-check.py --json
python3 scripts/ambitions-architecture-inventory.py --json
git diff --check
```

Expected: scorer self-test passes; scorecard check passes structurally while retaining current Yellow/Red scores.

- [ ] **Step 5: Commit the baseline**

```bash
git add docs/qa/architecture docs/qa/KNOWN_ISSUES.md scripts/ambitions-architecture-10-scorecard-check.py
git commit -m "docs(architecture): baseline earned 10 of 10 scorecard"
```

---

### Task 2: Replace path-based mutation proof with an exhaustive mutation registry

**Files:**
- Create: `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/Commands/MeaningfulMutationRegistryTests.swift`
- Modify: `scripts/ambitions-runtime-direct-write-audit.py`
- Modify: `scripts/ambitions-local-runtime-proof.py`
- Modify: `docs/audits/runtime-authority-map.md`
- Modify: `docs/adr/ADR-2026-07-02-source-atlas-scope-freeze.md`

**Interfaces:**
- Consumes: every user, system, adapter, and repair entry point that can change life state.
- Produces: `MeaningfulMutationDescriptor` entries with source, command kind, executor, durable stores, projection, receipt, replay, and proof tests.

```swift
struct MeaningfulMutationDescriptor: Sendable, Hashable {
    let id: String
    let sourcePath: String
    let commandKind: AmbitionsCommandKind
    let executorOwner: String
    let eventKind: String
    let projectionOwner: String
    let receiptOwner: String
    let replayTestID: String
}
```

- [ ] **Step 1: Write failing tests for known synthetic and unregistered paths**

The test must identify `TimeViewModel.performLifeShapeMutation`, `approveProtectedPlacementReview`, and `undoLastLifeShapeMutation` as unproven until they execute through the durable executor.

- [ ] **Step 2: Verify the tests fail against the current registry**

Run: `xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsUnitTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:AmbitionsTests/MeaningfulMutationRegistryTests test CODE_SIGNING_ALLOWED=NO`

Expected: failure listing the three Time mutation entry points.

- [ ] **Step 3: Make the Python audit semantic instead of directory-based**

Remove the rule that automatically labels every `Core/LocalRuntimeOS/` marker as `canonical command`. Require a registry row for every write-capable production path and machine-detect missing semantic entry points from current source. Parse multiline Swift registry rows with a fail-closed tokenizer/parser; malformed rows, unknown statuses, missing classifications, and parser losses are findings. An executable lineage proof ID is required only for a positive `durable`, `projectionOnly`, or `adapter` claim. Registry/governance tests may prove an `unproven` classification exists, but they must not be presented as durability, receipt, projection, or replay proof.

- [ ] **Step 4: Register all current entry points with explicit status and rationale without upgrading their status**

Rows may be `durable`, `projectionOnly`, `adapter`, `previewOnly`, or `unproven`, but every row must state its classification explicitly. Positive statuses require row-specific executable lineage evidence. Otherwise classify the row `unproven`, leave unknown lineage fields empty/optional rather than filling them with generic placeholders, and record a specific reason. Unproven rows keep LocalRuntimeProof Red.

The registry inventories three existing public-reference Source Atlas cache write paths without changing Source Atlas behavior. Add an inventory-only allowlist entry for `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift` to `ADR-2026-07-02-source-atlas-scope-freeze.md`; this allowlist does not authorize new packs, network behavior, private context, R2 production scope, or private-life-graph egress.

- [ ] **Step 5: Run the registry and proof gates**

Run:

```bash
python3 scripts/ambitions-runtime-direct-write-audit.py --self-test
python3 scripts/ambitions-runtime-direct-write-audit.py --json
python3 scripts/ambitions-local-runtime-proof.py --json --audit-only
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/ambitions-remediation-governance-check.py --base 1d4c0a202068ef78f46a1af61688e723a7df564a --json
git diff --check
```

Expected: tooling, Source Atlas public-reference boundary audit, and changed-range remediation governance are structurally Green; runtime proof remains Red for every genuinely unproven mutation.

- [ ] **Step 6: Commit honest mutation inventory**

```bash
git add Native/Ambitions/Core/LocalRuntimeOS/Commands Native/AmbitionsTests/LocalRuntimeOS/Commands scripts docs/audits/runtime-authority-map.md docs/adr/ADR-2026-07-02-source-atlas-scope-freeze.md
git commit -m "test(runtime): require executable mutation lineage"
```

---

### Task 3: Define the narrow runtime client used by features

**Files:**
- Create: `Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/Boundary/RuntimeCommandClientTests.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift`
- Modify: `Native/Ambitions/App/AppContainerFactory.swift`

**Interfaces:**
- Consumes: existing `CommandExecuting` and projection query services.
- Produces: a closure-based, Sendable client with no storage or platform implementation exposure.

```swift
struct RuntimeCommandClient: Sendable {
    var execute: @Sendable (
        _ command: AmbitionsCommand,
        _ context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult

    var projection: @Sendable (
        _ request: RuntimeProjectionRequest
    ) async throws -> RuntimeProjectionSnapshot
}

enum RuntimeRouteIntent: Sendable, Equatable {
    case openGoal(id: String)
    case openCapture(id: String)
    case openReceipt(id: String)
    case returnToToday
}
```

- [ ] **Step 1: Write a failing test proving feature clients cannot construct live defaults**

The test must compile a supplied fake client and verify duplicate command IDs return the same receipt ID. Do not allow `RuntimeCommandClient.live` outside app composition.

- [ ] **Step 2: Add the client and one composition adapter around `AmbitionsCommandExecutor`**

The adapter belongs in `AppContainerFactory`; feature targets receive only the client value.

Remove presentation types such as `ShellOverlayState` from runtime boundaries. Runtime results may emit `RuntimeRouteIntent`; Stage translates that route-neutral value into presentation state at the composition boundary.

- [ ] **Step 3: Remove production default construction from command/runtime types**

Move in-memory defaults to `PreviewSupport` or test factories. Production initializers require journals, event stores, projection stores, idempotency stores, and receipt repositories explicitly.

- [ ] **Step 4: Validate strict concurrency and the focused client tests**

Run the focused test, `xcodegen generate`, and a no-sign simulator build. Expected: no new `Sendable` escape hatch and no `nonisolated(unsafe)` addition.

- [ ] **Step 5: Commit the runtime seam**

```bash
git add Native/Ambitions/Core/LocalRuntimeOS/Boundary Native/Ambitions/App/AppContainerFactory.swift Native/AmbitionsTests/LocalRuntimeOS/Boundary
git commit -m "refactor(runtime): expose one injected command client"
```

---

### Task 4: Make the event journal authoritative and the commit atomic

**Files:**
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandMutationCommitter.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeTransactionCommitPolicy.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEvent.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventReplay.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeIdempotencyStore.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionMaterializer.swift`
- Create: `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeDomainEvent.swift`
- Create: `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeDomainEventCodec.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/EventJournal/RuntimeDomainEventReplayTests.swift`

**Interfaces:**
- Consumes: validated command plus a pure transition proposal.
- Produces: one atomic commit containing durable idempotency claim, semantic events, projection cursor, receipt, rollback metadata, and outbox intents.

```swift
struct RuntimeTransitionProposal: Sendable {
    let events: [RuntimeDomainEvent]
    let receiptDraft: RuntimeReceiptDraft
    let outboxIntents: [RuntimeOutboxIntent]
}

protocol RuntimeAtomicStore: Sendable {
    func commit(
        command: CommandEnvelope,
        proposal: RuntimeTransitionProposal
    ) async throws -> RuntimeCommitReceipt
}
```

- [ ] **Step 1: Write a failing mutate-then-log regression test**

Execute Quick Capture with an injected event-append or projection failure. Assert that no capture exists after the returned failure. The current implementation must fail this test because `captureService.createCapture` runs before `persistExecution`.

- [ ] **Step 2: Write failing durable-idempotency concurrency tests**

Execute one command ID concurrently 100 times, reconstruct the runtime, execute it again, and require one transition plus the same final receipt for every caller.

- [ ] **Step 3: Define versioned semantic domain events**

Start with events required by Capture and Time, such as `captureCreated`, `stepPlaced`, `timeWindowProtected`, `timeWindowCorrected`, and `mutationUndone`. Payloads contain enough state to reconstruct canonical objects; `commandExecution` remains diagnostic metadata, not the mutation authority.

- [ ] **Step 4: Implement atomic claim and authoritative commit**

Replace the in-memory-only idempotency dictionary with a durable uniqueness constraint. One SQLite authority transaction claims the command, appends domain events, persists the receipt and outbox intents, and marks the command committed. A failed authority transaction exposes no acknowledged mutation. Projection/object/search stores are derived: update them in the transaction only when they share the same authority database; otherwise record a durable cursor and recover through deterministic catch-up. Never report a committed event as blocked merely because a derived projection needs recovery.

- [ ] **Step 5: Make repositories projections or transaction participants**

Feature services must stop mutating private state before the authoritative transaction. Object stores may be rebuilt materializations or participate inside the same atomic store transaction; they cannot be an earlier independent commit.

- [ ] **Step 6: Add codecs and upcaster fixtures**

Every event has a stable type ID and schema version. Decode the oldest fixture, upcast to the current event, and reject/quarantine unknown future schemas without deleting the journal.

- [ ] **Step 7: Prove empty-store reconstruction**

Delete object, projection, and search stores; replay only semantic events; require identical canonical and read-model checksums.

- [ ] **Step 8: Commit the event-first spine**

```bash
git add Native/Ambitions/Core/LocalRuntimeOS/Commands Native/Ambitions/Core/LocalRuntimeOS/EventJournal Native/Ambitions/Core/LocalRuntimeOS/Transactions Native/Ambitions/Core/LocalRuntimeOS/Projections Native/AmbitionsTests/LocalRuntimeOS
git commit -m "refactor(runtime): make semantic event commit authoritative"
```

---

### Task 5: Repair the Time vertical slice end to end

**Files:**
- Modify: `Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift`
- Modify: `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`
- Modify: `Native/Ambitions/Surfaces/Time/TimeSurface.swift`
- Create: `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+TimeCommands.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor.swift`
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeCalendarStore.swift`
- Test: `Native/AmbitionsTests/Time/TimeDurableMutationIntegrationTests.swift`
- Test: `Native/AmbitionsTests/LocalRuntimeOS/Commands/TimeCommandReplayTests.swift`

**Interfaces:**
- Consumes: `RuntimeCommandClient`, Time command kinds, scheduling store, projection store.
- Produces: durable place/protect/correct/undo results whose receipt and projection can be reloaded after restart.

```swift
// TimeSurfaceState is a broad presentation projection whose nested graph does not
// define structural equality. Do not invent partial or reflection-based equality
// for this command result; durable equality is proven through receipt identity,
// projection version/checksum, replay, and the focused persistence tests below.
struct TimeFeatureMutationResult: Sendable {
    let projection: TimeSurfaceState
    let receiptID: String
    let projectionVersion: Int64
    let canUndo: Bool
}
```

- [ ] **Step 1: Write a restart test that fails with the current synthetic path**

Arrange a temporary on-disk command journal, SQLite event store, projection store, and schedule store. Execute `placeStepInTime`, destroy the runtime, reconstruct it, and require the same Time projection and receipt lineage.

- [ ] **Step 2: Write duplicate and failure-injection tests**

Require duplicate command IDs to be idempotent. Require journal failure, event append failure, projection failure, and receipt failure to produce no visible success and no external write.

- [ ] **Step 3: Implement Time command execution through the existing executor**

Handle `.placeStepInTime`, `.protectTimeWindow`, and `.correctTimeWindow`. The mutation closure changes canonical scheduling state only inside `RuntimeCommandMutationCommitter`.

- [ ] **Step 4: Make projection reload authoritative**

After execution, `TimeViewModel` reloads the committed Time projection. It must never apply `result.updatedTimeState` from a synthetic coordinator.

- [ ] **Step 5: Implement Undo as a command**

Undo carries the original receipt ID and expected projection version. A stale or already-undone receipt returns a typed rejection receipt.

- [ ] **Step 6: Delete the synthetic runtime path and false receipt copy**

Remove default `PrivateLifeRuntime()` construction, in-memory previous-state undo, and any claim that a receipt exists before the durable receipt query succeeds.

- [ ] **Step 7: Run focused runtime, Time, restart, and UI interaction tests**

Expected: all focused tests pass with zero skips; the mutation registry upgrades the exact Time rows to durable.

- [ ] **Step 8: Commit the repaired vertical slice**

```bash
git add Native/Ambitions/Projection/Mutations Native/Ambitions/Surfaces/Time Native/Ambitions/Core/LocalRuntimeOS/Commands Native/Ambitions/Core/LocalRuntimeOS/Scheduling Native/AmbitionsTests/Time Native/AmbitionsTests/LocalRuntimeOS/Commands
git commit -m "fix(time): persist mutations through runtime lineage"
```

---

### Task 6: Convert every remaining meaningful mutation one vertical slice at a time

**Files:**
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`
- Modify: feature services and command handlers under their existing canonical owners.
- Test: one `*DurableMutationIntegrationTests.swift` file per surface or adapter.

**Interfaces:**
- Consumes: RuntimeCommandClient and the proven Time pattern.
- Produces: zero `unproven` meaningful-mutation registry rows.

- [ ] **Step 1: Execute slices in this order**

```text
Today closure/recovery
Goals create/edit/path/clarification/archive
Capture create/promote/attach/correct
You preferences/learning/privacy/delete/export
Notifications and App Intents
Share extension intake
EventKit and widget outboxes
Repair/migration operators
```

- [ ] **Step 2: For each slice, write red restart/idempotency/failure tests first**

Each test must assert persisted state, event lineage, projection version, receipt identity, replay equality, and absence of side effects before local commit.

- [ ] **Step 3: Route the slice through the executor and delete alternate authority**

Do not retain an in-memory compatibility path. A short-lived shim may translate old input into a command but may not mutate.

- [ ] **Step 4: Run the complete mutation registry after every slice**

Expected: the unproven count decreases monotonically and no previously durable row regresses.

- [ ] **Step 5: Commit each slice separately**

Use these bounded commits and attach each proof artifact: `fix(today): route closure and recovery through runtime`, `fix(goals): route goal mutations through runtime`, `fix(capture): route capture mutations through runtime`, `fix(you): route preference and privacy mutations through runtime`, and `fix(adapters): route external actions through runtime`.

---

### Task 7: Prove crash consistency, replay, migration, and external-write ordering

**Files:**
- Create: `Native/AmbitionsTests/LocalRuntimeOS/RuntimeCrashConsistencyTests.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/RuntimeReplayEquivalenceTests.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/RuntimeMigrationRollbackTests.swift`
- Create: `Native/AmbitionsTests/LocalRuntimeOS/ExternalWriteOrderingTests.swift`
- Modify: existing transaction, event, projection, receipt, outbox, backup, and repair owners only where tests reveal defects.

**Interfaces:**
- Consumes: complete mutation registry.
- Produces: fault-injection matrix for every durable step.

- [ ] **Step 1: Add deterministic failpoints**

```swift
enum RuntimeCommitFailpoint: Sendable, CaseIterable {
    case afterCommandAppend
    case afterCanonicalMutation
    case afterEventAppend
    case afterProjectionMaterialization
    case beforeReceiptPersistence
    case beforeExternalOutboxLease
}
```

- [ ] **Step 2: Parameterize crash tests across all failpoints**

Use Swift Testing parameterized tests. After reconstruction, require either a fully committed result or a recoverable/rejected result; never partial user-visible success.

- [ ] **Step 3: Prove replay equality from an empty projection store**

Delete projections, replay events, and compare canonical checksums and user-facing read models.

- [ ] **Step 4: Replace full-journal projection rebuilds with cursor-based catch-up**

Every projector persists its event cursor/checksum, consumes only later events during normal operation, detects gaps, and can discard/rebuild from zero. Prove incremental output equals a clean full replay and that a crash after event commit but before projection save catches up automatically.

- [ ] **Step 5: Complete the transactional outbox worker**

Persist outbox intent with the authoritative event/receipt transaction. Use a worker actor with durable lease, retry/backoff, idempotency key, reconciliation, and terminal failure receipt. Remove swallowed result persistence. Prove crash-before-write, crash-after-write-before-result, permission denial, duplicate delivery, cancellation, and transient failure.

- [ ] **Step 6: Prove schema migration dry run, backup, rollback, and quarantine**

Test the oldest supported store fixture and the current schema. Corrupt one event and require quarantine without destroying the remaining graph.

- [ ] **Step 7: Prove local commit precedes EventKit, notification, widget, App Intent, and share effects**

External adapters receive only committed receipt evidence. Cancellation or process death leaves a retryable outbox row.

- [ ] **Step 8: Commit runtime resilience proof**

```bash
git add Native/AmbitionsTests/LocalRuntimeOS Native/Ambitions/Core/LocalRuntimeOS
git commit -m "test(runtime): prove crash replay and outbox consistency"
```

---

### Task 8: Approve compiler-enforced module boundaries through a new ADR

**Files:**
- Create: `docs/adr/ADR-2026-07-09-compiler-enforced-module-boundaries.md`
- Create: `docs/qa/architecture/architecture-contract.schema.json`
- Create: `docs/qa/architecture/architecture-contract.json`
- Create: `docs/qa/architecture/public-api-allowlist.json`
- Create: `scripts/ambitions-architecture-contract-audit.py`
- Modify: `scripts/ambitions-quality-gate.py`
- Modify: `scripts/ci/ambitions-pr-review-local.sh`
- Modify: `.github/workflows/ambitions-pr-review.yml`
- Modify: `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- Modify: `docs/truth/IMPLEMENTATION_TRUTH.md`
- Modify: `docs/truth/CODEX_PROCESS_TRUTH.md`
- Modify: `AGENTS.md`
- Modify: `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- Modify: `docs/adr/ADR-2026-07-05-active-package-boundary.md`

**Interfaces:**
- Consumes: observed dependency edges after mutation-path repair, the Linear canonical product/IA/object-model spec, current repo truth, live source, proof ceilings, and the owner-approved conventional modular-monolith direction.
- Produces: versioned logical module ownership, allowed imports, public API, product/IA ownership, route/presentation law, canonical-object migration invariants, Parent Feature coverage, deletion/shim state, issue deduplication, conflict resolution, proof ceilings, extraction order, build-time baselines, and rollback. It does not produce immutable leaf-path law.

- [ ] **Step 1: Generate the actual file/type dependency graph**

Do not infer dependencies from folders. Use compiler index data or SourceKit output and record cycles.

- [ ] **Step 2: Write a failing architecture-contract audit**

Before the contract exists, add fixtures that fail for each of the eight architecture contract gates and five contract mechanics. The audit must also reject feature-to-feature imports, feature-to-adapter imports, RuntimeCore-to-feature imports, App imports outside composition, duplicate logical owners, unstable logical IDs, ratchet regressions, unapproved framework/public-API growth, Release membership for support/debug sources, reachable stale authorities, expired or unregistered shims, missing canonical-object migration coverage, and proof claims above their evidence ceiling. Wire the audit into `ambitions-quality-gate.py`, the local PR-review wrapper, and the PR workflow in the same task.

- [ ] **Step 3: Write the owner-approved ADR**

Owner approval for compiler-enforced boundaries was provided on 2026-07-09; the conventional modular-monolith direction and removal of immutable exact-tree law were approved on 2026-07-10. The ADR must explain why the single app target is insufficient, why paths and names alone cannot enforce architecture, why the logical contract and compiler graph outrank a frozen directory diagram, how `project.yml` remains app-graph truth, how `Package.swift` enforces reusable boundaries, and how each target can be rolled back independently.

- [ ] **Step 4: Install the canon amendment and operating-contract update**

Replace Article 22's exact-tree constitution with a versioned architecture-contract constitution. Update `AGENTS.md`, implementation/process truth, and the retained architecture skill in the same commit so no active instruction continues to require `Stage`, `Surfaces`, `Composer`, `Core/LocalRuntimeOS`, or other old paths after their logical owners move. Preserve product laws: Today / Goals / Time / You only, CaptureComposer and Search global/non-root, Trust contextual, Motion behavior, local-first private graph, and public-reference-only R2/Source Atlas.

- [ ] **Step 5: Record clean and incremental build baselines**

Run `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -showBuildTimingSummary build CODE_SIGNING_ALLOWED=NO` three times for clean and representative Today/Time edits. Store median and p95 duration, compiled-file set, and binary size; do not set arbitrary absolute time thresholds before measuring the host.

The ADR sets relative gates: no extraction may regress clean-build p95 by more than 5%; final hot incremental feature edits must be at most 50% of baseline; binary size may not grow more than 2% without explained functionality.

- [ ] **Step 6: Commit ADR, contract, canon amendment, and guard before changing targets**

```bash
git add docs/adr docs/qa/architecture docs/truth AGENTS.md .agents/skills/ambitions-architecture-tree-enforcement/SKILL.md scripts/ambitions-architecture-contract-audit.py scripts/ambitions-quality-gate.py scripts/ci/ambitions-pr-review-local.sh .github/workflows/ambitions-pr-review.yml
git commit -m "docs(architecture): approve compiler enforced boundaries"
```

---

### Task 9: Extract Domain, RuntimeAPI, and external-contract leaf targets first

**Files:**
- Modify: `Package.swift`
- Modify: `project.yml`
- Modify: source access control under `Native/Ambitions/Core/Domain/`
- Move: runtime contracts from `Native/Ambitions/Core/LocalRuntimeOS/Boundary/` and `Commands/` into the `AmbitionsRuntimeAPI` target's declared source membership, initially proposed under `Native/Ambitions/Core/Runtime/API/`
- Move: redacted contracts from `Native/Ambitions/Projection/ExternalSnapshots/` into the `AmbitionsExternalSurfaceContracts` target, initially proposed under `Native/Ambitions/Core/ExternalSurfaceContracts/`
- Modify/move: `Native/AmbitionsWidgetExtension/` and `Native/AmbitionsShareExtension/` toward `Native/Extensions/Widget/` and `Native/Extensions/Share/`
- Create: `Native/AmbitionsTests/Architecture/ModuleImportBoundaryTests.swift`

**Interfaces:**
- Produces: `AmbitionsDomain`, `AmbitionsRuntimeAPI`, and `AmbitionsExternalSurfaceContracts` modules.
- Consumes: Foundation only for Domain; Domain for RuntimeAPI and ExternalSurfaceContracts.

- [ ] **Step 1: Add targets with explicit source lists**

Avoid globbing the entire `Core` tree. Start with the smallest value objects and command/query contracts needed by Time.

- [ ] **Step 2: Compile the new targets before moving consumers**

Expected: no SwiftUI, SwiftData, EventKit, UserNotifications, WidgetKit, AppIntents, or app-module import in Domain or RuntimeAPI.

- [ ] **Step 3: Move access control deliberately**

Expose only types required across the boundary. Do not make every declaration `public`. Prefer public immutable value types and internal implementations.

Generate symbol graphs for every new module and compare them with `docs/qa/architecture/public-api-allowlist.json`. New public symbols require a dependency rationale. Concrete repositories and adapters remain non-public.

- [ ] **Step 4: Move Time to the new APIs, then Today, Goals, Capture, and You**

Build after each consumer. Revert the individual consumer if it requires a circular edge.

- [ ] **Step 5: Replace widget/share source-file cherry-picking with ExternalSurfaceContracts**

The extensions import one redacted DTO module. No production source file is compiled into more than one target.

- [ ] **Step 6: Validate module graph and build timing**

Expected: no cycles; representative feature edit rebuilds fewer targets than baseline.

- [ ] **Step 7: Commit leaf modules**

```bash
git add Package.swift project.yml Native/Ambitions/Core Native/Ambitions/Projection/ExternalSnapshots Native/AmbitionsWidgetExtension Native/AmbitionsShareExtension Native/AmbitionsTests/Architecture
git commit -m "refactor(architecture): extract domain and runtime api targets"
```

---

### Task 10: Extract RuntimeCore, Data, and Apple-platform targets

**Files:**
- Modify: `Package.swift`
- Modify: `project.yml`
- Move: runtime policy from `Native/Ambitions/Core/LocalRuntimeOS/` into the `AmbitionsRuntimeCore` target, initially proposed under `Native/Ambitions/Core/Runtime/`
- Move: storage/search/migration/backup implementations into the `AmbitionsData` target, initially proposed under `Native/Ambitions/Data/`
- Move: Apple/account/CloudKit/Source Atlas adapters into platform targets, initially proposed under `Native/Ambitions/Platform/`
- Modify: `Native/Ambitions/App/AppContainerFactory.swift`
- Test: module-specific tests selected from `Native/AmbitionsTests/LocalRuntimeOS/`

**Interfaces:**
- Produces: `AmbitionsRuntimeCore`, `AmbitionsData`, and `AmbitionsPlatformApple`.
- Consumes: approved `AmbitionsRuntimeAPI` ports.

- [ ] **Step 1: Extract AmbitionsRuntimeCore without Apple UI frameworks**

RuntimeCore may use Foundation, CryptoKit, and OSLog where justified. It must not import SwiftUI, SwiftData, SQLite implementation modules, Apple adapters, or feature modules.

- [ ] **Step 2: Extract data implementations behind AmbitionsRuntimeAPI ports**

SwiftData, SQLite, FTS, file, blob, backup, and migration implementations live in AmbitionsData. RuntimeCore receives ports through initialization.

- [ ] **Step 3: Extract Apple and external adapters**

EventKit, UserNotifications, ActivityKit, WidgetKit bridges, App Intents bridges, share intake, account, CloudKit, and Source Atlas transport live in platform targets. They cannot mutate canonical state.

- [ ] **Step 4: Make AppContainerFactory the only live composition root**

No target except App knows concrete storage and platform adapter types simultaneously.

- [ ] **Step 5: Run module-specific runtime and adapter tests plus full build**

Expected: module audit Green; all external-write ordering tests Green; no new unsafe concurrency exception.

- [ ] **Step 6: Commit engine and adapter extraction**

```bash
git add Package.swift project.yml Native/Ambitions/Core Native/Ambitions/App/AppContainerFactory.swift Native/AmbitionsTests
git commit -m "refactor(architecture): enforce runtime adapter boundaries"
```

---

### Task 11: Replace AppContainer service location with feature clients

**Files:**
- Modify: `Native/Ambitions/App/AppContainer.swift`
- Modify: `Native/Ambitions/App/AppEnvironment.swift`
- Modify: `Native/Ambitions/App/AppCapabilities.swift`
- Modify: feature roots under `Native/Ambitions/Surfaces/*/*Surface.swift`
- Modify: `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`
- Test: `Native/AmbitionsTests/App/AppDependencyBoundaryTests.swift`

**Interfaces:**
- Consumes: RuntimeCommandClient and feature-specific query clients.
- Produces: one dependency value per feature root; child views receive values or actions explicitly.

- [ ] **Step 1: Write tests forbidding raw container access below App and Navigation roots**

Reject `@Environment(\.appContainer)`, raw service properties, and direct accesses such as `container.todayService`, `container.captureService`, or `container.runtime` in feature/UI source.

- [ ] **Step 2: Introduce feature dependencies**

```swift
struct TimeFeatureDependencies: Sendable {
    let clock: any AmbitionsClock
    let runtime: RuntimeCommandClient
    let loadProjection: @Sendable () async throws -> TimeSurfaceState
}
```

- [ ] **Step 3: Inject dependencies at feature roots**

Views below the root receive immutable state and action closures. Do not install the entire app container in the environment.

- [ ] **Step 4: Delete duplicated raw services and capability wrappers**

Retain only composition-owned session, Navigation dependencies, feature dependencies, and platform lifecycle hooks.

- [ ] **Step 5: Remove `nonisolated(unsafe)` environment defaults**

Environment defaults must be safe inert preview values or required values at the feature root. Missing live dependencies must fail during composition tests, not at user interaction time.

- [ ] **Step 6: Commit dependency repair**

```bash
git add Native/Ambitions/App Native/Ambitions/Surfaces Native/Ambitions/Composer Native/AmbitionsTests/App
git commit -m "refactor(app): replace service locator with feature clients"
```

---

### Task 12: Replace Stage with thin typed Navigation

**Files:**
- Modify: `Native/Ambitions/Stage/AmbitionsStage.swift`
- Modify: `Native/Ambitions/Stage/StageStore.swift`
- Modify: `Native/Ambitions/Stage/StageReducer.swift`
- Modify: `Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift`
- Create/move: the resulting typed routes, shell, and Motion behavior into the `AmbitionsNavigation` target, initially proposed under `Native/Ambitions/Navigation/`
- Modify: `Native/Ambitions/Surfaces/You/YouScreen+04-YouLifeContextSurface.swift`
- Test: `Native/AmbitionsTests/Stage/StageDependencyBoundaryTests.swift`
- Test: `Native/AmbitionsTests/Stage/StageRoutingTests.swift`

**Interfaces:**
- Consumes: typed feature destinations and feature outcomes.
- Produces: deterministic navigation state and overlay presentation only.

- [ ] **Step 1: Write tests that reject product mutation and direct services in Navigation**

Navigation may select routes, present overlays, and translate a completed feature outcome into navigation. It may not attach captures, recover product transitions, write copy policy, or call repositories/services.

- [ ] **Step 2: Replace internal NotificationCenter routing with typed navigation actions**

Motion sends `StageAction` through the Stage store. NotificationCenter remains only for genuine system notifications or extension handoff.

Make Stage state private and dispatch-only. Remove public setters and any method that dispatches and then mutates state directly; every transition must be represented by one reducer action and testable reduction.

- [ ] **Step 3: Move goal-creation and capture-binding orchestration into the Goals/CaptureComposer feature boundary**

Return a typed outcome such as `GoalCreationOutcome` to Navigation; Navigation only navigates.

- [ ] **Step 4: Migrate AmbitionsStage behavior into responsibility-named Navigation components**

Keep the main Stage view under 250 lines and each extracted component under 300 lines. Each component receives explicit values/actions.

- [ ] **Step 5: Run navigation reducer, route, overlay, Reduce Motion, and Dynamic Type tests**

Expected: no internal NotificationCenter route, no direct product service call in Navigation, and no reachable production authority left under the old Stage owner.

- [ ] **Step 6: Commit thin Navigation**

```bash
git add Native/Ambitions/Stage Native/Ambitions/Navigation Native/Ambitions/Features/You Native/AmbitionsTests/Navigation
git commit -m "refactor(navigation): replace stage with typed routing"
```

---

### Task 13: Extract feature, Trust, and Navigation targets without vertical silos

**Files:**
- Modify: `Package.swift`
- Modify: `project.yml`
- Modify/move: Today, Goals, Time, You, Steps, CaptureComposer, Search, and Trust source imports/access control.
- Create: feature-specific test targets in `project.yml`.
- Test: `scripts/ambitions-architecture-contract-audit.py`

**Interfaces:**
- Produces: eight feature targets and one Navigation target.
- Consumes: Domain, RuntimeAPI, DesignSystem only.

- [ ] **Step 1: Extract Time first as the proven reference slice**

Time owns presentation state, projections, views, accessibility, and feature client contracts. It does not own persistence or runtime mutation policy.

- [ ] **Step 2: Extract Goals, Steps, CaptureComposer, Search, Today, You, and Trust in measured dependency order**

Where features currently call one another, replace the edge with a RuntimeAPI command/query or a typed Navigation destination. Do not create a SharedFeatures dumping ground.

- [ ] **Step 3: Extract Navigation after all feature roots compile independently**

Navigation imports feature modules; feature modules never import Navigation.

- [ ] **Step 4: Add one compile-negative boundary fixture per forbidden edge**

The architecture-contract audit must fail if a feature imports App, Data, PlatformApple, Navigation, or another feature.

- [ ] **Step 5: Measure clean and incremental build improvement**

Required result: representative single-feature changes rebuild only their feature, Navigation/App dependents, and tests; record median improvement against Task 7 baseline.

- [ ] **Step 6: Commit each feature extraction separately**

Commit each extraction explicitly: `refactor(time): enforce compile-time boundary`, `refactor(goals): enforce compile-time boundary`, `refactor(steps): enforce compile-time boundary`, `refactor(capture): enforce compile-time boundary`, `refactor(search): enforce compile-time boundary`, `refactor(today): enforce compile-time boundary`, `refactor(you): enforce compile-time boundary`, `refactor(trust): enforce compile-time boundary`, and `refactor(navigation): enforce compile-time boundary`.

---

### Task 14: Standardize every human-authored filename and delete historical junk

**Files:**
- Consume then delete: `docs/audits/2026-07-05-amb-1818-file-size-cleanup-queue.md`
- Modify/delete: nonconforming production, test, support, script, configuration, and active-document filenames.
- Delete: stale prompts, trains, plans, logs, screenshots, proof packets, generated state, obsolete audits, stale skills, dead scripts/workflows, and compatibility source with no current executable consumer.
- Modify: `scripts/ambitions-remediation-governance-check.py`
- Create: `scripts/ambitions-filename-contract-audit.py`

**Interfaces:**
- Consumes: compiler-enforced modules, which reveal true component boundaries.
- Produces: focused files named by responsibility, a zero-debt filename audit, and no retained historical-junk tree.

- [ ] **Step 1: Inventory every tracked human-authored filename and consumer**

Classify Swift, tests, scripts, configuration, active documentation, resources, fixtures, generated/vendor inputs, and historical junk. Generated/vendor names are allowlisted only when the generator or upstream contract owns them. A file with no current build, test, release, legal/privacy, migration, or governance consumer is delete-worthy.

- [ ] **Step 2: For each family, choose one of three outcomes**

```text
merge tiny fragments into the owning type;
extract a real independent collaborator with a narrow interface;
delete duplicate or unused authority.
```

- [ ] **Step 3: Enforce the filename contract**

Swift files use UpperCamelCase and match the primary declaration; semantic extensions use `PrimaryType+Responsibility.swift`; scripts and ordinary docs use lowercase kebab-case; active canon keeps its approved prominent names. Delete all numbered suffix files, sequence labels, broad `*Models.swift`, `Helpers`, `Utils`, `Common`, and ambiguous noun-only buckets unless a narrow contract and executable consumer justify the name.

- [ ] **Step 4: Reduce architecture-noun count through deletion, not renaming**

Every retained Engine, Kernel, Coordinator, Runtime, Ledger, System, or Manager must have one owner, one public purpose, and executable tests.

- [ ] **Step 5: Delete historical junk and expired compatibility**

Do not move stale material into `Archive`, `Historical`, `Legacy`, or a new docs tree. Preserve only current migration decoders/fixtures with executable consumers and declared removal conditions. Git history is the archive.

- [ ] **Step 6: Split oversized tests by behavior and shared fixtures**

No production or support Swift file may exceed 600 lines at final closeout.

- [ ] **Step 7: Commit one dependency-safe family per cleanup train**

Use a concrete owner/family message for each train, beginning with `refactor(today): standardize projection ownership`, `refactor(time): standardize mutation ownership`, and `chore(repo): delete historical control-plane junk`. Regenerate XcodeGen and run the owning target's tests after every family; never perform an unvalidated filesystem-wide rename.

---

### Task 15: Adopt modern SwiftUI under the Swift 6.3.3 toolchain deliberately

**Files:**
- Modify: `project.yml`
- Modify: `Package.swift`
- Modify: feature models and roots only where compiler diagnostics or profiling justify change.
- Create: `docs/qa/platform/xcode-26-swift-6-3-compatibility-matrix.md`
- Test: `Native/AmbitionsTests/Architecture/ConcurrencyBoundaryTests.swift`

**Interfaces:**
- Consumes: modular feature clients and typed Navigation.
- Produces: one blocking Xcode 26.6 / iOS 26 lane with strict concurrency and availability enforcement.

- [ ] **Step 1: Pin and prove the available toolchain lane before changing compiler settings**

Run build, unit/integration tests, UI smoke, concurrency diagnostics, and availability scan with Xcode 26.6 / Swift 6.3.3. Keep the iOS 26 matrix blocking. Record exact Xcode build, Swift compiler, simulator runtime, and destination metadata. Do not add a placeholder Xcode 27 lane or weaken the available stable lane for an unavailable toolchain.

- [ ] **Step 2: Enforce Swift 6 language mode with the installed Swift 6.3.3 compiler**

Keep `SWIFT_VERSION = 6.0` and `SWIFT_STRICT_CONCURRENCY = complete`; the language-mode setting must not be confused with the installed compiler version. Enable `SWIFT_STRICT_MEMORY_SAFETY` warnings where supported by Xcode 26.6 and drive unacknowledged unsafe uses to zero before making the warning fatal.

- [ ] **Step 3: Use Observation with main-actor feature models**

Feature models are `@MainActor @Observable`; immutable domain/runtime values remain Sendable and non-main-actor. Store owned async tasks and cancel them, or use `.task(id:)`; do not launch ignored throwing tasks.

- [ ] **Step 4: Preserve compiler-owned `@State` optimization**

Do not rewrite correct state code simply to mention the new API. Verify model initialization counts with tests and Instruments.

- [ ] **Step 5: Adopt `ContentBuilder` only where it reduces builder complexity**

Measure type-check and incremental compile time before and after. Preserve iOS 26 behavior because the builder improvement is compiler-driven/back-deployable.

- [ ] **Step 6: Enforce the iOS 26 API boundary**

Do not introduce iOS 27-only SwiftUI APIs while Xcode 27 is unavailable. Prefer iOS 26-native APIs with equivalent action and accessibility semantics. Any future iOS 27 adoption requires a separate toolchain-available train with availability wrappers and tested iOS 26 fallbacks.

- [ ] **Step 7: Commit compiler/platform modernization separately from product behavior**

```bash
git add project.yml Package.swift docs/qa/platform Native/Ambitions Native/AmbitionsTests/Architecture
git commit -m "build(ios): enforce xcode 26 swift 6.3 lane"
```

---

### Task 16: Harden iOS 26 SwiftData observation without weakening runtime authority

**Files:**
- Modify: `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift`
- Modify: projection observation adapters under `Core/LocalRuntimeOS/Projections/`.
- Create: `Native/AmbitionsTests/LocalRuntimeOS/Storage/SwiftDataObservationCompatibilityTests.swift`

**Interfaces:**
- Consumes: committed projections and SwiftData transaction history.
- Produces: a deterministic iOS 26 persistent-history observation path with restart-safe token persistence and duplicate suppression.

- [ ] **Step 1: Write parity tests for live and restart-reconstructed iOS 26 observation paths**

Both paths must emit the same projection invalidation token after a committed runtime transaction and nothing after a rejected command.

- [ ] **Step 2: Implement observers inside AmbitionsData only**

Persistent-history observers trigger read-model refresh. They never become canonical events and never authorize mutation.

- [ ] **Step 3: Verify transaction-token persistence and duplicate suppression**

Restart the adapter and require incremental processing from the last token.

- [ ] **Step 4: Commit the availability-gated adapter**

```bash
git add Native/Ambitions/Core/LocalRuntimeOS/Storage Native/Ambitions/Core/LocalRuntimeOS/Projections Native/AmbitionsTests/LocalRuntimeOS/Storage
git commit -m "feat(storage): harden ios 26 observation adapter"
```

---

### Task 17: Rebuild the test portfolio around executable behavior

**Files:**
- Create: `docs/qa/testing/test-portfolio-classification.json`
- Create: `scripts/ambitions-test-proof-classification.py`
- Modify: tests under `Native/AmbitionsTests/` incrementally.
- Modify: `project.yml` test targets and schemes.

**Interfaces:**
- Consumes: all existing tests.
- Produces: tagged Swift Testing unit/integration suites, XCTest UI/performance suites, and governance-only lexical suites.

- [ ] **Step 1: Classify every test**

```text
unit-behavior
runtime-integration
storage-integration
contract
UI-interaction
accessibility
performance
governance-lexical
```

Lexical tests cannot satisfy behavior, runtime, accessibility, visual, or release gates.

Record the current baseline explicitly: 425 Swift test files, approximately 120,000 test LOC, 38 test files above 600 lines, more than 100 unit-test files that read source files, and only one Swift Testing file. Recompute rather than copying these numbers at execution time.

Every required test belongs to exactly one named test plan and proof tier. Every result records commit SHA, branch, Xcode, OS, destination, command, exit status, executed/failed/skipped counts, and `.xcresult` or report path.

- [ ] **Step 2: Migrate new and touched unit/integration tests to Swift Testing**

Use parameterized tests, traits, tags, `#expect`, and `#require`. Keep XCTest for XCUIAutomation and APIs not yet supported by Swift Testing.

- [ ] **Step 3: Replace source-string assertions with behavior assertions**

For each touched lexical test, either retain it under governance classification or replace it with compiled API/output behavior. Never delete a guard without an equivalent or stronger gate.

- [ ] **Step 4: Split every test file above 600 lines**

Shared fixtures are immutable Sendable builders. Avoid global mutable fixtures and blind sleeps.

- [ ] **Step 5: Enforce test determinism**

Required lanes allow zero `XCTSkip`, `XCTExpectFailure`, retry-only success, arbitrary sleep, shared persistent state, or unordered clock/network dependencies.

Required UI lanes also allow zero coordinate-tap fallback and zero broad scroll-hunting helper. Reach screens through deterministic routes, fixtures, accessibility identifiers, and explicit loaded-state barriers.

- [ ] **Step 6: Add test-shard schemes by module and proof type**

Every shard emits `.xcresult`, JSON summary, duration, failures, skips, and commit SHA.

- [ ] **Step 7: Commit test portfolio reform in bounded module batches**

Use concrete module batches, beginning with `test(time): replace lexical proof with behavior`, `test(runtime): replace lexical proof with behavior`, and `test(stage): replace lexical proof with behavior`.

---

### Task 18: Establish accessibility, interaction, performance, and energy budgets

**Files:**
- Create: `docs/qa/performance/architecture-performance-budgets.json`
- Create: `docs/qa/visual/flagship-screenshot-matrix.json`
- Create: `Native/AmbitionsTests/Performance/RuntimePerformanceTests.swift`
- Create: `Native/AmbitionsUITests/Accessibility/FlagshipAccessibilityTests.swift`
- Create: `Native/AmbitionsUITests/Visual/FlagshipScreenshotMatrixTests.swift`
- Create: `scripts/ambitions-performance-budget-check.py`
- Modify: source only in response to measured regressions.

**Interfaces:**
- Consumes: final modular SwiftUI architecture.
- Produces: device/simulator performance and accessibility artifacts tied to commit SHA.

- [ ] **Step 1: Measure before setting thresholds**

Capture launch, first Today projection, command commit, projection rebuild, search, Time scrolling, memory, storage, and energy baselines on named simulator classes covering constrained/small, mainstream, and Pro viewport profiles.

Replace the current in-memory `DispatchTime` smoke with Release-configuration `XCTApplicationLaunchMetric`, `XCTHitchMetric`, CPU, memory, storage, clock, and `XCTOSSignpostMetric` measurements against production-equivalent stores.

- [ ] **Step 2: Set percentile budgets from evidence**

Budgets include p50/p95 duration, main-thread blocking, peak memory, disk growth, replay throughput, hitch count, and SwiftUI long-update count.

- [ ] **Step 3: Profile with SwiftUI, Swift Concurrency, Time Profiler, Hangs/Hitches, and System Trace instruments**

Use Instruments 26 for stable proof and record the exact Xcode, Instruments, simulator runtime, destination, and commit SHA.

- [ ] **Step 4: Prove accessibility matrices**

Run `performAccessibilityAudit` on Today, Goals, Time, You, Capture, Search, Closure, and Inspection across success, empty, error, degraded, and post-mutation states. Test VoiceOver order/actions/focus restoration, Dynamic Type through accessibility sizes, Reduce Motion, Reduce Transparency, Increase Contrast, Differentiate Without Color, RTL, keyboard focus, safe areas, minimum hit targets, and iOS 26 navigation/presentation behavior. Automated simulator audits do not replace manual physical-device VoiceOver traversal; that remains an explicit non-claim.

- [ ] **Step 5: Build a deterministic screenshot matrix**

Cover all roots, global overlays, key mutations, small/mainstream/Pro simulator viewports, iOS 26, light/dark, default/accessibility text, contrast, transparency, and reduced motion. Store actual, expected, perceptual diff, SHA, Xcode, OS, locale, and simulator metadata. Baseline changes require a written visual rationale and independent review; absence of that review keeps Visual Green unavailable without blocking architecture-score completion.

- [ ] **Step 6: Fail CI on statistically meaningful regression**

Use repeated measurements and tolerance bands. Do not fail on a single noisy sample and do not average away a consistent p95 regression.

- [ ] **Step 7: Record the physical-device waiver and simulator proof ceiling**

Run the widest deterministic simulator matrix available for constrained/small, mainstream, and Pro profiles. Cover keyboard, notifications, App Intents, widgets, App Groups, EventKit permission states that Simulator can represent, offline/no-account behavior, accessibility, and performance. Record physical-device behavior, locked-device behavior, real notification delivery, real App Group/extension behavior, manual VoiceOver traversal, independent Visual Green, TestFlight readiness, App Store readiness, and Release Green as not proven. Physical-device proof is explicitly foregone for this architecture program and is not an architecture-score gate.

- [ ] **Step 8: Commit budgets and evidence harness**

```bash
git add docs/qa/performance docs/qa/visual Native/AmbitionsTests/Performance Native/AmbitionsUITests/Accessibility Native/AmbitionsUITests/Visual scripts/ambitions-performance-budget-check.py
git commit -m "test(quality): enforce performance and accessibility budgets"
```

---

### Task 19: Run the final earned 10/10 gate and delete transitional authority

**Files:**
- Modify: `docs/qa/architecture/architecture-10-scorecard.md`
- Modify: `docs/qa/architecture/architecture-10-scorecard.json`
- Modify: `docs/qa/KNOWN_ISSUES.md`
- Delete: all completed compatibility shims, stale lexical proof artifacts, and obsolete duplicated owners.

**Interfaces:**
- Consumes: every prior task and current evidence on one final SHA.
- Produces: earned dimension scores and explicit remaining non-claims.

- [ ] **Step 1: Require zero architecture blockers**

```text
zero unproven meaningful mutations
zero target cycles
zero forbidden imports
zero missing architecture-contract gates
zero duplicated logical owners
zero unstable logical module IDs
zero architecture-ratchet regressions
zero unapproved public-API or framework edges
zero support/debug source in Release products
zero reachable stale owner authority
zero unregistered or expired compatibility shims
zero canonical-object migration gaps
zero unresolved authority conflicts
zero raw AppContainer access in features
zero internal NotificationCenter routes
zero nonconforming human-authored filenames
zero retained historical junk
zero production/support Swift files above 600 lines
zero required-test skips/retries/expected failures
zero failed runtime, quality, accessibility, or performance gates
```

- [ ] **Step 2: Run the complete validation matrix on the same SHA**

```bash
xcodegen generate
python3 scripts/ambitions-architecture-10-scorecard-check.py
python3 scripts/ambitions-architecture-contract-audit.py
python3 scripts/ambitions-filename-contract-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py --json
python3 scripts/ambitions-local-runtime-proof.py --json
python3 scripts/ambitions-remediation-governance-check.py --json
python3 scripts/ambitions-quality-gate.py --max-per-gate 120
python3 scripts/ambitions-performance-budget-check.py
bash scripts/build-local.sh
git diff --check
```

Run all module unit/integration shards, flagship simulator UI/accessibility suites, and replay/migration/fault suites required by the scorecard. Attach `.xcresult`, logs, Instruments 26 traces, simulator metadata, and the explicit physical-device/release non-claim record.

- [ ] **Step 3: Re-run after deleting shims**

No 10/10 score is allowed while a compatibility shim retains product, runtime, projection, trust, or motion authority.

- [ ] **Step 4: Award each score independently**

A failing dimension remains at its earned score and names the exact blocker. Do not average five dimensions into a misleading overall 10.

- [ ] **Step 5: Commit final evidence and reconcile tracker only after proof**

```bash
git add docs/qa/architecture docs/qa/KNOWN_ISSUES.md
git commit -m "docs(architecture): record earned modernization score"
```

## Rollback strategy

- Each task is independently revertible and must not require reverting a later unrelated task.
- Runtime migrations create a pre-migration backup and dry-run receipt before store changes.
- Target extractions retain source paths, so rollback edits `project.yml`, imports, and access control without moving private data.
- Future Xcode 27, Swift 6.4, and iOS 27 compatibility work remains outside this program until that toolchain is available; the iOS 26 implementation remains authoritative and must not contain placeholder future-API code.
- A train that cannot preserve persistent-store compatibility stops before merge and remains Red.

## Program completion rule

The modernization program is complete only when all five dimensions independently satisfy their 10/10 exit contracts on one current commit. A green architecture inventory, successful build, large test count, or passing lexical audit is insufficient by itself.
