<!-- markdownlint-disable MD013 MD060 -->

# RP-03 — Mutation, Trust, Receipt, and Undo

Audit base: `main` at `29872755f705f6bd8e276aeac86dcf376ac5f0d8` on 2026-07-22.

## Executive verdict

`PARTIALLY_SUPPORTED`. Ambitions has a real local authority transaction, durable `RuntimeCommitReceipt`, idempotent replay, bounded semantic events, and row-specific replay proof for selected Time, Today, Capture creation, Capture-to-Goal, and Time ritual operations. It does **not** have one production-proven mutation lifecycle across the product. The live `MeaningfulMutationRegistry` declares 121 mutation rows and 55 write paths, but marks broad Goals, Capture routing, external, repair, and generic runtime paths `unproven` [E03-01]. The runtime result vocabulary cannot represent scope-level partial settlement, uncertainty, recovery, or irreversibility [E03-02]. Therefore the shared visual trust grammar survives as a protected target, but a visual claim that all operations can reach Receipt, partial settlement, or Undo would overstate current capability.

Primary dispositions: `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `ARCHITECTURE_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED`, `RECONSTRUCTION_PLAN_ACTION_REQUIRED`.

## Scope and authority

This packet audits current mutation execution, truth-state distinctions, Receipts, Settlement Ledger feasibility, Undo, conflict, failure, and recovery. It compares live source and tests with Campaigns 03, 05, 06, 07, 08, 09, and 11. It does not approve a visual direction or infer behavior from a type alone.

Authority order used:

1. Live source and the source-owned `MeaningfulMutationRegistry`.
2. Current targeted tests as inspectable proof definitions; no new XCTest result was obtained.
3. Generated/canonical specifications as target contracts, not implementation proof.
4. Attached provisional visual records as protected intent only.

The targeted XCTest batch attempted by the audit coordinator failed before test execution with `FAILURE_CLASS=simulator_boot_failure` and `EXECUTED_TESTS=0`. It contributes no behavior evidence. Static source checks and test inspection remain the verification basis.

## Current mutation lifecycle

```text
AmbitionsCommand
  -> validate / compile
  -> append command journal
  -> build RuntimeTransaction
  -> detect bounded runtime conflict
  -> SQLite authority transaction
       [semantic event when required]
       + command event
       + RuntimeCommitReceipt
       + typed outbox intents
  -> projection / repository materialization
  -> command execution record + user-facing receipt projection
  -> replay existing receipt on duplicate/restart
```

The SQLite commit is atomic for its authority records [E03-03]. Projection materialization can fail after authority and be marked for recovery rather than converting committed truth into failure [E03-04]. This is a valid local transaction foundation, not proof that every feature mutation enters it. The registry itself labels the generic committer and coordinator unproven without row-specific lifecycle proof [E03-01].

## Current-state findings

### Proven floor versus generic promise

- Time placement and Time Undo are `durable`; Today has selected durable goal-step and Receipt paths; Capture creation materialization is `projectionOnly` behind committed authority; Capture-to-Goal handoff is `durable` [E03-01].
- Most Goals mutations, most Capture post-save/routing mutations, external integrations, repair operations, and the generic runtime entry points remain explicitly `unproven` [E03-01]. They cannot be elevated to `SUPPORTED` because the file or type exists.
- The authoritative commit persists a typed local receipt with event/projection cursors, rollback-plan identity, replay trace, affected object IDs, and checksum [E03-03]. The presence of a rollback-plan ID is not a generic rollback executor: the rollback model exposes a structural `isExecutable` predicate, while the registry supplies executable Undo proof only for bounded paths [E03-05].

### Current, proposed, and settled truth contract

| Truth layer | Capability status | Current contract | Evidence |
|---|---|---|---|
| Current authoritative local truth | `PARTIALLY_SUPPORTED` | SQLite authority is current truth for covered semantic commands; uncovered repository writes are not proven to share this boundary. | E03-01, E03-03 |
| Proposed truth / preview | `PARTIALLY_SUPPORTED` | Command validation includes confirmation and blocked outcomes, and some surfaces render proposal stages. There is no single proposal schema spanning all mutations. | E03-02, E03-10 |
| Editing | `PARTIALLY_SUPPORTED` | Feature-local editing states exist, but are not part of the runtime result model. | E03-02 |
| Saving / committing | `SUPPORTED` | The executor, journal, commit policy, and SQLite authority represent an actual commit boundary for covered commands. | E03-03, E03-04 |
| Pending / queued | `PARTIALLY_SUPPORTED` | Command and side-effect enums contain pending/queued states, but the action receipt factory collapses both to `draftedPrepared`; generic durable later settlement is not proven. | E03-02, E03-07 |
| Settled changed / unchanged | `PARTIALLY_SUPPORTED` | Success and no-op exist, with action receipt result states for selected operations. Coverage is not product-wide. | E03-02, E03-07 |
| Partial settlement | `ABSENT` | No scope-aware partial/deferred/uncertain settlement model was found; current command and side-effect states are whole-result states. | E03-02, E03-08 |
| Failed | `SUPPORTED` | Failed, blocked, unsupported, validation, permission, and failed-safely states exist, though several collapse at presentation. | E03-02, E03-07, E03-08 |
| Recovering / recovered | `PARTIALLY_SUPPORTED` | Post-authority materialization recovery metadata and recovery domain models exist; no shared lifecycle status binds them to every mutation. | E03-04, E03-11 |
| Irreversible | `ABSENT` | No shared irreversible outcome/status or scope model was found. | E03-02, E03-08 |
| Undo available | `PARTIALLY_SUPPORTED` | Time Undo is durable and replay-tested by registry evidence; generic Undo availability is representational and not a product-wide inverse-command proof. | E03-01, E03-05, E03-07 |

## State capability matrix

| Visual/runtime state | Capability status | Finding | Evidence |
|---|---|---|---|
| Current truth | `PARTIALLY_SUPPORTED` | Strong for covered authority events; mixed elsewhere. | E03-01, E03-03 |
| Proposed truth | `PARTIALLY_SUPPORTED` | Confirmation/preview contracts exist, not unified. | E03-02, E03-10 |
| Preview | `PARTIALLY_SUPPORTED` | Feature-local proposals exist; registry includes `previewOnly`, which is explicitly not production authority. | E03-01, E03-10 |
| Editing | `PARTIALLY_SUPPORTED` | UI-local, not a durable runtime state. | E03-02 |
| Saving | `SUPPORTED` | Executor and atomic commit can express in-flight work for covered operations. | E03-03, E03-04 |
| Pending | `PARTIALLY_SUPPORTED` | Named in command and side-effect models; generic persistence and later settlement are missing. | E03-02, E03-08 |
| Partial settlement | `ABSENT` | No per-scope outcome collection. | E03-02, E03-08 |
| Settled changed | `PARTIALLY_SUPPORTED` | Successful receipts carry affected objects for covered operations. | E03-03, E03-06 |
| Settled unchanged | `PARTIALLY_SUPPORTED` | `noOp` exists, but unchanged Receipt semantics are not uniformly proven. | E03-02, E03-07 |
| Deferred | `PARTIALLY_SUPPORTED` | `queued`/prepared-draft can signal deferral, but not a durable generic deferred scope. | E03-02, E03-07 |
| Failed | `SUPPORTED` | Whole-operation failure states exist. | E03-02, E03-08 |
| Still uncertain | `ABSENT` | No canonical runtime result status. | E03-02 |
| Recovering / recovered | `PARTIALLY_SUPPORTED` | Recovery is contextual and bounded, not a universal state transition. | E03-04, E03-11 |
| Irreversible | `ABSENT` | No runtime result representation. | E03-02 |
| Undo available | `PARTIALLY_SUPPORTED` | Durable for Time; otherwise availability labels exceed executable proof. | E03-01, E03-07 |

## Receipt capability and ownership matrix

| Receipt concern | Capability status | Owner / behavior | Evidence |
|---|---|---|---|
| Durable authority receipt | `SUPPORTED` | `EventStoreSQLite` stores `RuntimeCommitReceipt` inside `runtime_authority_commits`. | E03-03, E03-06 |
| Receipt replay by command identity | `SUPPORTED` | Existing authority receipt is returned for the same command ID. | E03-03 |
| Event/projection lineage | `SUPPORTED` | Receipt holds event cursor, projection cursors, affected IDs, replay trace, checksum. | E03-06 |
| User-visible Receipt history | `PARTIALLY_SUPPORTED` | `ReceiptProjection` and SwiftData Action Receipt history exist; proven coverage is bounded by the registry. | E03-01, E03-06 |
| Failed Receipt | `PARTIALLY_SUPPORTED` | Action receipt models can display failed-safely; failed commands do not establish a uniform durable failure Receipt contract. | E03-07 |
| Partial Receipt | `ABSENT` | No per-scope partial outcome schema was found. | E03-02, E03-08 |
| Privacy classification | `SUPPORTED` | Command execution records and events carry local-only/privacy fields. | E03-02, E03-03 |
| Retention/deletion policy | `UNKNOWN` | Storage exists, but this packet found no authoritative product-wide retention/deletion implementation for Receipts. | E03-06 |

## Settlement Ledger feasibility

The existing ingredients make a future Settlement Ledger technically plausible: a durable authority receipt, an action receipt projection, and a persistent side-effect ledger with claim/finalize semantics [E03-06, E03-08]. Current capability is `PLANNED_NOT_IMPLEMENTED`, not `SUPPORTED`:

| Required Ledger facet | Capability status | Evidence-based limit |
|---|---|---|
| Completed scopes | `PARTIALLY_SUPPORTED` | A receipt lists affected objects, but not independently completed scopes. |
| Failed scopes | `ABSENT` | Whole-result failure exists; scope failures do not. |
| Deferred scopes | `ABSENT` | Queue/prepared states are not scope members of one settlement. |
| Uncertain scopes | `ABSENT` | No status/schema. |
| Reversible scopes | `PARTIALLY_SUPPORTED` | Rollback-plan identity and bounded Time Undo exist; no scope-level reversibility. |
| Irreversible scopes | `ABSENT` | No status/schema. |
| Review-required scopes | `PARTIALLY_SUPPORTED` | Confirmation-required exists for whole operations and external effects, not a settlement scope collection. |

Architecture must decide whether the Settlement Ledger is a projection over `RuntimeCommitReceipt` plus side-effect records or a new canonical record. The audit does not choose.

## Undo and reversibility matrix

| Mutation family | Capability status | Finding | Evidence |
|---|---|---|---|
| Time life-shape placement | `SUPPORTED` | Registry declares durable Undo requiring original receipt and expected projection version; named tests cover duplicate and stale rejection. | E03-01, E03-09 |
| Selected Today actions | `PARTIALLY_SUPPORTED` | Durable action/receipt paths exist, but a product-wide inverse command is not established. | E03-01 |
| Capture creation | `PARTIALLY_SUPPORTED` | Durable creation authority exists; generic Capture undo/rollback is not registry-proven. | E03-01 |
| Capture-to-Goal handoff | `PARTIALLY_SUPPORTED` | Atomic/replay proof exists, but no user-facing inverse handoff contract is established. | E03-01, E03-09 |
| Goals mutations | `PLANNED_NOT_IMPLEMENTED` | Current registry rows are unproven. | E03-01 |
| External EventKit effect | `PARTIALLY_SUPPORTED` | Durable adapter identity/ledger exists, but registry marks the mutation path unproven and external reversal semantics are not established. | E03-01, E03-08 |
| Generic command | `UNKNOWN` | Rollback metadata/type presence does not prove an executable inverse. | E03-05 |

Undo must be visually withheld or explicitly unavailable unless the owning operation supplies executable proof. This is `TARGETED_VISUAL_REFINEMENT_REQUIRED`; showing universal Undo would be `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE`.

## Conflict versus failure matrix

| Condition | Capability status | Runtime distinction | Evidence |
|---|---|---|---|
| Validation failure | `SUPPORTED` | `failed` or `blocked` after validation. | E03-02, E03-04 |
| Confirmation prerequisite | `SUPPORTED` | `requiresConfirmation`. | E03-02, E03-04 |
| Duplicate command | `SUPPORTED` | Existing durable receipt is replayed by command ID. | E03-03 |
| Stale object/read overlap | `PARTIALLY_SUPPORTED` | Runtime detector checks stale read-set overlap against receipts held by the idempotency store. | E03-05 |
| Projection cursor regression | `PARTIALLY_SUPPORTED` | Runtime detector has a bounded cursor conflict. | E03-05 |
| External duplicate/reconciliation | `PARTIALLY_SUPPORTED` | Side-effect outbox can return `reconciliationRequired`; row-specific production proof is unproven. | E03-01, E03-08 |
| Source disagreement | `ABSENT` | No shared conflict outcome located. | E03-05 |
| Calendar domain conflict | `PLANNED_NOT_IMPLEMENTED` | Desired in visual/canon, but EventKit paths remain registry-unproven. | E03-01 |
| Identity conflict | `ABSENT` | No generic conflict type found beyond transaction overlap. | E03-05 |
| Sync failure | `PARTIALLY_SUPPORTED` | External/result failures exist, but no production-proven graph sync reconciliation. | E03-08 |

## Visual-assumption comparison

| Provisional assumption | Status | Disposition | Directions / campaigns |
|---|---|---|---|
| Shared distinction between current truth, proposal, commit, and settled result | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `RUNTIME_CAPABILITY_REQUIRED` | Campaigns 03, 05, 06, 07, 08, 09, 11; AVF-COHERENCE-S07-R00 |
| Durable Receipt after every meaningful mutation | `PARTIALLY_SUPPORTED` | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | AVF-CAPTURE-S07-R00, AVF-TIME-S07-R00, AVF-TODAY-S09-R00, AVF-SEARCH-D07-R00, AVF-YOU-D07-R01 |
| Multi-scope partial settlement | `ABSENT` | `RUNTIME_CAPABILITY_REQUIRED`, `ARCHITECTURE_DECISION_REQUIRED` | Campaigns 03, 05, 07, 09, 11; AVF-RECOVERY-S07-R00 |
| Undo offered where supported | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `IMPLEMENTATION_DETAIL_DEFERRED` | Campaigns 03, 05, 06, 07, 08, 09, 11 |
| Universal Undo affordance | `CONTRADICTED` | `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` | Same campaigns |
| Conflict visually distinct from failure | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `RUNTIME_CAPABILITY_REQUIRED` | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00 |
| Contextual recovery after post-authority materialization failure | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED` | Campaigns 09, 11 |

## Critical contradictions

1. **Receipt presence versus Receipt coverage.** The runtime has durable receipts, while the registry explicitly keeps many meaningful mutations unproven. A shared Receipt visual cannot imply universal coverage [E03-01, E03-03].
2. **Rollback metadata versus executable Undo.** Receipt and rollback types carry identifiers, but only bounded Time Undo is registry-proven [E03-01, E03-05].
3. **Pending labels versus later settlement.** Pending/queued exist, yet collapse to `draftedPrepared` in Action Receipt presentation and have no generic durable settlement queue [E03-02, E03-07].
4. **Settlement Ledger visual versus state vocabulary.** Required partial, uncertain, irreversible, and per-scope outcomes are absent [E03-02, E03-08].
5. **Generic transaction architecture versus row proof.** The committer/coordinator exist, but their registry rows remain `unproven`; architecture presence cannot certify feature behavior [E03-01].

## Required decisions

| Authority | Decision required |
|---|---|
| Devan | Whether the protected visual program may keep partial settlement explicitly provisional, or whether affected journeys must omit it until runtime support exists. |
| Architecture | Define canonical Settlement Ledger ownership and its relationship to `RuntimeCommitReceipt`, Action Receipt history, and external side-effect records. |
| Architecture | Define one product-wide truth-state algebra or approve bounded per-domain state models with explicit visual capability negotiation. |
| Runtime | Add or reject typed scope outcomes for completed, failed, deferred, uncertain, reversible, irreversible, and review-required scopes. |
| Runtime | Establish executable inverse-command/compensating-command contracts and persistence duration for each Undo-capable mutation. |
| UX Blueprint | Specify how unavailable Undo, partial outcomes, post-authority materialization recovery, and no-op receipts are disclosed without false success. |
| Reconstruction planning | Sequence migration of unproven direct/repository mutation rows to proven owner authority and remove duplicate write authority only after parity proof. |

## Unsupported assumptions

- A Receipt can be promised for every meaningful operation: `PARTIALLY_SUPPORTED`; keep provisional or condition on proven owner coverage.
- A single operation can currently expose a scope-by-scope Settlement Ledger: `ABSENT`; requires architecture/runtime implementation before visual use.
- Pending work will settle later and notify the user: `UNKNOWN`; no generic proof.
- Undo is available wherever an Action Receipt label says so: `CONTRADICTED`; availability labels are not executable inverse proof.
- All conflicts can be distinguished from failure: `ABSENT` outside bounded transaction and external reconciliation cases.
- A rollback-plan identifier means rollback is executable: `CONTRADICTED`; withhold this implication.

## Reconstruction implications

- Convert the registry’s unproven meaningful mutation rows one owner at a time; preserve semantic event, atomic commit, projection, receipt, restart, and replay proof.
- Introduce proof gates for Receipt visibility, Undo visibility, and partial-settlement visibility so the UI cannot infer capability from enum/type presence.
- Reconcile Action Receipt state collapse (`pending`/`queued` to `draftedPrepared`) with the protected visual distinctions.
- Keep side-effect reconciliation separate from local authoritative commit; model compensation instead of assuming external rollback.
- Add focused crash/restart tests for each newly claimed path. The present simulator failure means this audit did not refresh executable test evidence.

## Evidence appendix

| ID | Claim and capability status | Source, symbol, stable lines | Authority / currency | Verification and result | Confidence / remaining uncertainty | Directions |
|---|---|---|---|---|---|---|
| E03-01 | Mutation coverage is bounded: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`, `MeaningfulMutationStatus`, `MeaningfulMutationRegistry.descriptors`, lines 3-23, 38-85, 151-206, 290-323, 352-403, 452-521. | Current source-owned proof registry at audit SHA; stronger than plans and type presence. | `python3 scripts/ambitions-runtime-direct-write-audit.py --json` returned `status=green`, 121 mutation rows, 55 direct-write markers, 50 unproven production write-path rows, zero missing registered entry points. | High. Registry proof labels are source assertions tied to named tests; this audit did not execute those tests. | All RP-03 directions. |
| E03-02 | Runtime result vocabulary lacks partial/uncertain/recovering/irreversible: `ABSENT`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandResult.swift`, `AmbitionsCommandExecutionStatus`, lines 5-14; execution result lines 16-40. | Current production source. | `rg -n -i "partial settlement\|settled partial\|partially settled\|uncertain scope\|irreversible scope\|review-required scope\|deferred scope" Native/Ambitions Native/AmbitionsTests` returned no matches. | High for shared named states; a domain-local synonym could exist outside searched terms. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E03-03 | SQLite authority transaction and replayable receipt: `SUPPORTED` for covered commands. | `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLiteAtomicCommit.swift`, `commitAuthority`, lines 69-145; authority schema/receipt persistence lines 245-307. | Current production source, authoritative store implementation. | Source inspection confirmed one SQLite transaction inserts semantic event, command event, receipt, and outbox intents; duplicate command returns existing receipt. | High for implementation structure; fresh execution blocked by simulator. | All RP-03 directions. |
| E03-04 | Commit/materialization recovery is bounded: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandMutationCommitter.swift`, `commit` and `persist`, lines 78-166. | Current production source. | Source inspection found command journal preparation, transaction commit, materialization, receipt enrichment, and `needs_recovery` metadata on record materialization error. | High for code path; row coverage constrained by E03-01. | AVF-CAPTURE-S07-R00, AVF-RECOVERY-S07-R00. |
| E03-05 | Conflict and rollback are narrow: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeConflictDetector.swift`, lines 3-114; `RuntimeTransactionCoordinator.swift`, lines 117-155; `RuntimeIdempotencyStore.swift`, lines 29-60; `RuntimeRollbackPlan.swift`, lines 5-63. | Current production source. | Source inspection found duplicate/stale/cursor conflicts against `committedReceipts` and only a structural rollback `isExecutable` predicate. | Medium-high. SQLite receipt reload into the conflict set and generic rollback execution were not established. | AVF-RECOVERY-S07-R00, AVF-COHERENCE-S07-R00. |
| E03-06 | Durable receipt lineage exists: `SUPPORTED` for covered authority commits. | `Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeCommitReceipt.swift`, `RuntimeCommitReceipt`, lines 5-82; `Native/Ambitions/Core/LocalRuntimeOS/Projections/ReceiptProjection.swift`, lines 3-38. | Current source and derived projection. | Source inspection confirmed cursor, rollback, replay, affected-ID, checksum fields and a receipt-event projection. | High for schema; user discovery breadth remains bounded. | All RP-03 directions. |
| E03-07 | Action receipt states/Undo labels are representational and lossy: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Inspection/ActionClosureReceiptModels.swift`, lines 5-50; `ActionReceiptCommandResultFactory.swift`, lines 53-81, 137-172. | Current production presentation/inspection source. | Source inspection found pending/queued collapse to `draftedPrepared`, failure collapse, and Undo labels including `availableLocal` and `notSupportedYet`. | High. Executable inverse behavior requires row proof, not these labels. | AVF-TODAY-S09-R00, AVF-SEARCH-D07-R00, AVF-YOU-D07-R01. |
| E03-08 | External side-effect settlement is narrow and not a multi-scope ledger: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift`, `SideEffectClaim` and `SideEffectResultState`, lines 44-63, claim/finalize lines 190-324; `SideEffectLedgerModels.swift`, lines 18-29. | Current production adapter source; registry labels EventKit/external rows unproven. | Source inspection found claimed/terminal/reconciliation-required and whole-result success/failure/permission/confirmation states. | High for model; low for device/external behavior because tests did not execute. | AVF-TIME-S07-R00, AVF-RECOVERY-S07-R00. |
| E03-09 | Named restart/replay tests exist but were not refreshed: `UNKNOWN` as current execution result. | `Native/AmbitionsTests/LocalRuntimeOS/Commands/TimeCommandReplayTests.swift`, tests lines 5 and 54; `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`, tests lines 5-264; `Native/AmbitionsTests/LocalRuntimeOS/Commands/CaptureGoalHandoffOwnerWriteTests.swift`, tests lines 5-270. | Current test source; not runtime evidence in this run. | `rg -n "func test" ...` enumerated the named proofs. Coordinator XCTest batch: simulator boot failure, zero executed. | High that tests exist; `UNKNOWN` for pass/fail at audit SHA. | AVF-TIME-S07-R00, AVF-CAPTURE-S07-R00. |
| E03-10 | Proposal/confirmation UI exists but is feature-local: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Composer/Capture/CaptureProposalStage.swift`, `CaptureProposalStage`, lines 4-35, 69-121, 142-170. | Current UI source; behavior not executed. | Source inspection found explicit Accept, Change destination, Cancel, and “without saving” semantics. | Medium-high; visual/runtime behavior not captured. | AVF-CAPTURE-S07-R00. |
| E03-11 | Shared recovery vocabulary exists as a domain contract, not a universal mutation machine: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/Domain/RecoveryState.swift`, `RecoveryState`, lines 3-43. | Current source contract. | Source inspection compared state type to command results; no product-wide binding was found. | Medium. Other local recovery models exist, but no unifying runtime transition was established. | AVF-RECOVERY-S07-R00. |

## Contradiction and unsupported-claim review

- Every `SUPPORTED` claim above is bounded to a named store or registry-proven operation.
- Generated/canonical requirements are not cited as runtime proof.
- Test names are recorded as source evidence only because zero tests executed.
- No fixture, preview, enum, or rollback identifier is treated as usable behavior.
- No revised visual direction is selected.
