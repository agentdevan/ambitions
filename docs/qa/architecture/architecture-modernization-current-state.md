# Architecture Modernization Current State

**Evidence date:** 2026-07-20
**Baseline `main`:** `733a5feac8c81a1a09e6d9086da0948c02f9032d`
**Reconciliation source head:** `26a4eee7c98ba62fb92caaac564a58344295656f`
**Current program PR:** draft PR #45
**Canon:** revision `1`, content digest `76361a57b770ec79e15748e5c46d100ffa3068e7f3f67ef3d7ac27bbb7f1761a`
**Bounded pack:** `.codex/canon-packs/5e2c2ce9fab990e3cb019bb3f66e93dcc34c5d5e83f4a82002741ba46ddab8d6/codex-autonomous-repair-delegation-docs.json`
**Claim ceiling:** Source/governance claim only within the declared scope and current linked evidence.

This document reconciles the historical 2026-07-09 architecture plan with active canon and current repository evidence. It is an evidence projection, not product law, a task authorization, or an architecture-completion claim. It does not establish runtime Green, device or simulator proof, visual or accessibility approval, privacy/security approval, release readiness, or a 10/10 result.

## Evidence taxonomy

| Evidence class | Meaning in this reconciliation | Current posture |
| --- | --- | --- |
| **Source** | Current tracked source, configuration, tests, registries, and scripts at the source head. Source presence proves only the named structure or implementation fact. | Inspected for the facts recorded below. |
| **Build** | A build or test command tied to a revision, toolchain, destination, exit status, and retained result. | PR CI build-for-testing passed. Local timing samples are ancestor evidence from 2026-07-11 and are not current-HEAD proof. |
| **Runtime** | Executed behavior, restart, replay, failure-injection, persistence, and external-effect evidence at the claimed revision. | Current audit is Red; no current-HEAD local runtime run was performed for this reconciliation. |
| **Simulator** | Simulator execution tied to an OS/runtime, device profile, command, result, and revision. | Unverified on current HEAD. |
| **Visual** | Rendered-state comparison with current visual authority and the required independent review. | Unverified on current HEAD. |
| **Unverified** | Planned, source-present, historical, stale, inconsistent, not run, or otherwise insufficient for the broader claim. | Remains below Green until current claim-specific evidence exists. |

Compatibility, duplicate, stale, proof-only, preview, obsolete, and conflicting sub-classifications are audit triage. They help order review; they do not upgrade any registry row or historical task to canon-satisfied.

## Historical Tasks 1-19 reconciliation

The only statuses used below are `complete`, `partially complete`, `not started`, `superseded`, `obsolete`, `requires fresh proof`, and `requires canon amendment`.

| Task and historical objective | Status | Current supporting files | Relevant commit/PR evidence | Active requirement IDs | Current implementation, test, or proof evidence | Remaining gap | Objective survives? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1. Freeze the baseline and install an earned-score ledger | `partially complete` | `docs/qa/architecture/architecture-10-scorecard.{md,json}`; `docs/qa/architecture/current-module-graph.json`; `scripts/ambitions-architecture-10-scorecard-check.py` | `456905ff0` installed the baseline; `1d4c0a202` made proof gates fail closed; both are ancestors of baseline `main`. | `CONST-PROOF-EVIDENCE-001`, `CONSTITUTION` | The ledger and checker exist, and the current module graph records the nine-node topology. The checker is currently Red because it still cites purged paths. | Re-derive the scorecard from active canon and current evidence; remove stale path dependencies without promoting numeric estimates to proof. | Yes: an evidence-backed, fail-closed architecture status projection survives. |
| 2. Replace path-based mutation proof with an exhaustive registry | `partially complete` | `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`; `Native/AmbitionsTests/LocalRuntimeOS/Commands/MeaningfulMutationRegistryTests.swift`; `scripts/ambitions-runtime-direct-write-audit.py`; `scripts/ambitions-local-runtime-proof.py` | `b302c730c`, `7a69dff61`, and `8cef42381` added and hardened the registry/audit lineage. | `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `CONST-PROOF-EVIDENCE-001` | The registry and write-path scan enumerate current candidates, but 154/165 combined rows remain unresolved or unproven. | Remove obsolete rows and duplicates, then upgrade only rows with exact source plus row-specific executable proof. | Yes: exhaustive, fail-closed mutation accounting survives. |
| 3. Define the narrow runtime client used by features | `requires fresh proof` | `Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift`; `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift`; `Native/Ambitions/App/AppContainerFactory.swift`; `Native/AmbitionsTests/LocalRuntimeOS/Boundary/RuntimeCommandClientTests.swift` | `208c58586` introduced the injected client; `0c7e32b2a` used it in the Time slice. | `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `CONST-PROOF-EVIDENCE-001` | The seam and focused tests are source-present. Current features still contain optional/default-live/global dependencies and direct app-container reach-through. | Re-run focused strict-concurrency/build tests at current HEAD and remove remaining bypassing construction paths in bounded owner slices. | Yes: narrow injected command/query clients survive; source presence alone does not prove app-wide adoption. |
| 4. Make the event journal authoritative and commit atomic | `partially complete` | `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandMutationCommitter.swift`; `RuntimeTransactionCommitPolicy.swift`; `EventJournal/RuntimeEventReplay.swift`; `Storage/EventStoreSQLiteAtomicCommit.swift`; atomic/replay tests | `0aa35134f`, `a79943292`, and `0a66c1f90` established and repaired the semantic event/replay spine. | `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY` | Event-first types, SQLite atomic support, and focused tests exist. Live inspection still finds pre-authority canonical mutation in `RuntimeCommandMutationCommitter` and Today flows. | Replace mutate-then-commit paths with one authoritative plan/commit/materialize lineage and prove every failure boundary. | Yes, unchanged in intent and still required. |
| 5. Repair the Time vertical slice end to end | `requires fresh proof` | `Native/Ambitions/Surfaces/Time/`; `Native/Ambitions/Projection/Mutations/`; `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+TimeCommands.swift`; `Native/AmbitionsTests/Time/`; `TimeCommandReplayTests.swift` | `0c7e32b2a` implemented the bounded Time lineage slice. | `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `CONST-PROOF-EVIDENCE-001` | Source and historical focused tests exist. Current registry still counts 16 unproven Time rows, and current-HEAD runtime/restart evidence was not run. | Reconcile Time rituals and Step lifecycle row by row, then rerun restart, duplicate, failure, replay, and focused UI behavior proof. | Yes: durable Time mutations survive; the former completion claim does not. |
| 6. Convert every remaining meaningful mutation by vertical slice | `partially complete` | `MeaningfulMutationRegistry.swift`; Today durable action/receipt tests; current Today, Goals, Capture, Time, You, adapter, and repair owners | `bcf68229a`, `972c197ef`, and `c2f878da9` advanced Today; earlier runtime/Time commits established reusable patterns. | `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY` | Seven descriptors are durable and two are projection-only. The exact remaining unproven domain totals are recorded below. | Execute separately reviewable owner slices; do not collapse 154 unresolved rows into one mega-diff or infer durability from a shared helper. | Yes, but only as bounded per-owner migration trains. |
| 7. Prove crash consistency, replay, migration, and external-write ordering | `partially complete` | `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`; `EventJournal/RuntimeDomainEventReplayTests.swift`; `ExternalWrites/`; `Repair/`; `docs/qa/local-runtime-proof/` | Runtime spine commits above provide focused ancestor evidence; checked-in proof artifact commit `348d7e478` predates later registry/proof changes. | `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `RUNTIME-MUTATION-SEQUENCE-001`, `CONST-PROOF-EVIDENCE-001` | Focused test files exist, but current LocalRuntimeProof is Red with 157 blockers and external-effect coverage is incomplete. | Normalize crash, replay, migration, corruption, and outbox evidence at one current SHA; regenerate the proof artifact only after Green. | Yes, fully; no current Green is implied. |
| 8. Approve fixed compiler-enforced boundaries through an ADR/exact tree | `superseded` | `docs/qa/architecture/current-module-graph.json`; `module-candidate-policy.json`; `domain-module-boundary.json`; `scripts/ambitions-module-candidate-gate.py`; active `docs/canon/` | `0b7925ee9`, `ba48e6301`, and `76f911bbf` installed and hardened candidate-driven policy after the original plan. | `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001` | The policy reports zero authorized future targets; the whole-domain candidate is rejected. | A fixed exact tree and amendment to old `docs/truth` cannot direct current work. Any owner/path change must pass active canon and fresh authorization. | The fixed tree does not survive. Flexible, evidence-backed ownership enforcement survives. |
| 9. Automatically extract Domain, RuntimeAPI, and external-contract leaf targets | `superseded` | `module-candidate-policy.json`; `domain-module-boundary.json`; `current-module-graph.json`; `Packages/AmbitionsDesignSystem/`; `Native/Ambitions/Core/Time/` | `004b7707a` and `648b0cfc9` are the two observed module pilots; `ad9615675` superseded whole-domain speed prerequisite. | `CONSTITUTION`, `CONST-RUNTIME-MUTATION-001`, `CONST-PROOF-EVIDENCE-001` | DesignSystem and the seven-file TimeFoundation pilot exist. No future target is authorized; whole-domain extraction failed/rejected. | Evaluate one dependency-closed, high-churn candidate with current compiler, graph, test, benchmark, and independent-review evidence. | Automatic named extraction does not survive; measured candidate evaluation does. |
| 10. Extract fixed RuntimeCore, Data, and Apple-platform targets | `superseded` | Active `Core/LocalRuntimeOS/` source owners; `current-module-graph.json`; `module-candidate-policy.json`; `scripts/ambitions-module-candidate-gate.py` | No authorized implementation commit exists for these named targets; candidate-policy commits are the current governance evidence. | `CONST-RUNTIME-MUTATION-001`, `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001` | Current topology contains no RuntimeCore, Data, or Platform target, and canon retains `Core/LocalRuntimeOS/` ownership. | Only a measured candidate that preserves canonical ownership may be proposed in its own PR. | Fixed targets do not survive; dependency separation survives only through measured candidates. |
| 11. Replace AppContainer service location with feature clients | `partially complete` | `Native/Ambitions/App/AppContainerFactory.swift`; `Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift`; feature roots; `Native/AmbitionsTests/App/AppContainerFactoryTests.swift` | `208c58586` introduced the main seam; later feature work adopted it selectively. | `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `CONST-PROOF-EVIDENCE-001` | Centralized construction is a current strength. Direct container reach-through, optional live dependencies, default live runtime construction, globals, and NotificationCenter routing remain. | Replace each remaining dependency with a narrow injected client/action and current focused tests, without moving authority into presentation. | Yes. |
| 12. Replace Stage with an exact `Navigation/` ownership move | `superseded` | `Native/Ambitions/Stage/`; `StageReducer.swift`; `StageStore.swift`; `Native/AmbitionsTests/App/StageThinnessOwnershipTests.swift`; active canon | `265ab2798` thinned Stage overlay ownership; later Stage/source commits are current supporting history. | `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001` | Typed Stage reducer/store structures and navigation tests exist, but navigation ownership remains split and direct state mutation/NotificationCenter routing remain. | Make navigation presentation-only while preserving Stage canonical ownership. A new `Navigation/` authority requires a canon amendment. | Presentation-only responsibility survives; the exact path move does not. |
| 13. Automatically extract feature, Trust, and Navigation targets | `superseded` | `current-module-graph.json`; `module-candidate-policy.json`; `project.yml`; current feature/Stage/Trust source | TimeFoundation `648b0cfc9` is an observed pilot, not permission for feature targets. | `CONSTITUTION`, `CONST-RUNTIME-MUTATION-001`, `CONST-PROOF-EVIDENCE-001` | No such feature or Navigation targets exist or are authorized. Current app target still owns 1,330 Swift files. | Prove one candidate's dependency closure and measured benefit through policy; keep cross-feature runtime authority canonical. | Automatic targets and generic `Features/` ownership do not survive; measured compiler isolation does. |
| 14. Standardize every filename and delete historical material | `superseded` | Active `docs/canon/`; `docs/canon/decisions/SUPERSESSION_LEDGER.toml`; current source/project consumers; historical plan retained at `docs/superpowers/plans/2026-07-09-architecture-10-of-10-modernization.md` | No bounded completion commit exists. Later canon cutover/purge work, not this task, governs supersession. | `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001` | Active canon owns supersession and source history remains available in Git. No current executable proof authorizes broad rename/deletion. | Any cleanup must be consumer-proven, individually authorized, and governed by active supersession law. | The automatic filename/deletion train does not survive. Narrow evidence-backed cleanup may be proposed separately. |
| 15. Adopt modern SwiftUI under the Swift 6.3.3 toolchain deliberately | `partially complete` | `.xcode-version`; `project.yml`; `Package.swift`; current `@Observable` feature models; concurrency/build tests | `cb15fd8e0` migrated the foundation to Swift 6; subsequent build/module commits retained strict settings. | `CONSTITUTION`, `CONST-PROOF-EVIDENCE-001` | Current source uses Swift 6 strict concurrency, Observation, and actor-isolated SwiftData patterns. The current toolchain facts are recorded below. | Current-HEAD build, availability, runtime, simulator, performance, and accessibility proof remains unrun here; modernization must remain evidence-driven. | Yes, as incremental platform maintenance, not a blanket rewrite. |
| 16. Harden an iOS 26 SwiftData observation mechanism | `obsolete` | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData*.swift`; `Projections/`; persistence/replay tests | `b616fa056` repaired a SwiftData startup warning, but no completed historical observation train proves this mechanism. | `SYSTEM-PERSISTENCE-ATOMIC-001`, `SYSTEM-PERSISTENCE-REPLAY`, `CONST-RUNTIME-MUTATION-001` | Actor-isolated SwiftData is present, but canon is substrate-independent and the originally prescribed observation mechanism is not the authority. | Prove atomic persistence, cursor/replay equivalence, migration, and duplicate suppression regardless of substrate; add substrate work only when a live defect requires it. | SwiftData-specific mechanism does not survive; persistence/replay correctness does. |
| 17. Rebuild the test portfolio around executable behavior | `not started` | Current `Native/AmbitionsTests/`, `Native/AmbitionsModuleTests/`, `Native/AmbitionsUITests/`; `project.yml`; `scripts/ambitions-changed-file-test-router.py` | No bounded implementation commit for the historical portfolio rebuild. | `CONST-PROOF-EVIDENCE-001`, `CONSTITUTION` | Current topology has 404 app-unit, 1 module-test, and 22 UI-test Swift files. No current classification artifact or completed portfolio migration exists. | Classify evidence tiers and improve touched tests in bounded work; do not use lexical tests as runtime proof. | Yes, but it must be incremental and tied to changed behavior. |
| 18. Establish accessibility, interaction, performance, and energy budgets | `not started` | Existing UI/accessibility/performance tests and historical evidence only; no requested budget artifacts exist | No bounded implementation commit for the historical budget program. | `CONST-PROOF-EVIDENCE-001`, `CONSTITUTION` | No current-HEAD simulator/device/visual/accessibility/performance matrix was run for this reconciliation. | Establish measurement and approval authority before numeric budgets; retain device and independent-review non-claims. | Yes as a separate evidence program, not as implied architecture proof. |
| 19. Run one final earned 10/10 gate and delete transitional authority | `superseded` | `architecture-10-scorecard.{md,json}`; current canon gates; runtime/proof scripts | No completion commit exists; current PR #45 is documentation-only and cannot close architecture. | `CONST-PROOF-EVIDENCE-001`, `CONSTITUTION` | Current scorecard, strict quality, direct-write, and LocalRuntimeProof gates are Red, and current-HEAD runtime/simulator/visual proof is absent. | Close dimensions independently with current evidence and retain explicit owners/blockers for every open obligation. | One artificial 10/10 label does not survive. Dimensioned, evidence-backed closure does. |

## Mutation inventory

Current inventory totals are exact for the source head:

- 115 mutation descriptors: 7 durable, 2 projection-only, 1 preview-only, 105 unproven.
- 50 write paths: 1 preview-only, 49 unproven.
- 165 combined rows: 7 durable, 2 projection-only, 0 adapter, 2 preview-only, 154 unresolved/unproven.

The 154 unresolved/unproven rows break down by current domain triage as follows:

| Domain | Unproven total |
| --- | ---: |
| Today | 7 |
| Goals | 18 |
| Capture | 31 |
| Time | 16 |
| You | 9 |
| Notifications | 4 |
| App Intents | 4 |
| Widgets/extensions | 8 |
| External adapters | 13 |
| Repair/migration | 13 |
| Runtime internals | 25 |
| Other | 6 |

These domain totals are an execution-order aid, not proof that all rows in a domain share one owner, defect, or valid bulk fix.

## Persistence and LocalRuntimeProof

The live audit posture is **Red**: 20 checks, 17 pass, 3 fail, and 157 blockers. The checked-in `docs/qa/local-runtime-proof/current-local-runtime-proof.json` says Green but was generated July 4. It predates the July 10 mutation-registry work and the July 18 proof-script changes, so it is stale and is not valid evidence for current HEAD.

Active obligations remain `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, `SYSTEM-PERSISTENCE-ATOMIC-001`, and `SYSTEM-PERSISTENCE-REPLAY`. Current source and tests show a real event/replay foundation, but the open mutation rows, pre-authority writes, incomplete failure/replay coverage, and stale proof projection prevent a broader runtime claim.

## Current compile topology

- Nine graph nodes.
- App source root: 1,337 Swift files.
- `Ambitions` target: 1,330 Swift files.
- `AmbitionsTimeFoundation`: 7 Swift files.
- `AmbitionsDesignSystem`: 109 Swift files.
- `AmbitionsWidgetUI`: 7 Swift files.
- Tests: 404 app-unit, 1 module-test, and 22 UI-test Swift files.
- 11 multiply compiled production paths and 17 extra inclusions.
- No authorized future target.
- The whole-domain candidate is rejected.
- The 45/166 lexical separability result is triage-only, not compiler-boundary proof.
- The Domain corpus has 609 outside consumers.
- No extraction or deletion is authorized by this reconciliation.

`docs/qa/architecture/current-module-graph.json`, `domain-module-boundary.json`, and `module-candidate-policy.json` are the current topology projections. New compiler boundaries must remain candidate-driven, measured, and separately authorized.

## Composition and navigation

Current strengths are centralized construction in `AppContainerFactory`, Swift 6 strict concurrency, growing Observation adoption, and actor-isolated SwiftData access. These are source-level strengths, not app-wide runtime proof.

Current gaps are optional or default-live dependencies, global dependencies, direct feature reach-through to the app container, split navigation ownership, direct Stage mutations outside one reducer transition, and internal product routing through `NotificationCenter`. Composition repair must inject narrow values/actions without creating a second runtime authority. Navigation repair must preserve Stage canonical ownership and keep routing presentation-only unless canon is amended.

## Build and test evidence freshness

The retained 2026-07-11 ancestor evidence records:

| Lane | Historical result |
| --- | ---: |
| Project startup | 4s median / 6s worst |
| Module build-for-testing | 4s / 7s |
| Module test-without-building | 6s / 7s |
| Leaf edit | 9s / 9s |
| App-unit build-for-testing | 6s / 18s |
| Hosted focused test | 22s / 25s |
| Module test | 14s / 25s |
| Cache-invalidated build | 439s |
| Immediate repeat | 8s |
| Later focused test | 23s |

All values are ancestor evidence from 2026-07-11; current HEAD is unverified. The 439-second sample has inconsistent cold/warm labeling and must not be compared as a trustworthy cold-build cohort until the metadata is normalized.

The current checked-in toolchain declarations and active host tools are:

- `.xcode-version`: 26.3.
- Active Xcode: 26.6, build `17F113`.
- Swift compiler: 6.3.3.
- Swift package tools version: 6.2.
- XcodeGen: 2.45.4.

## Current gate posture

| Gate/evidence | Current result | Claim boundary |
| --- | --- | --- |
| Canon audit | Green | Canon structure only. |
| Canon build check | Green | Generated canon parity only. |
| Skill conformance | Green | Adapter bytes/dependencies only. |
| Authority sprawl | Green | Authority-location audit only. |
| Canon conflicts | Green | No open canonical conflict in the current report. |
| Canon traceability | Green with 1,045 posture gaps | Traceability command execution succeeded; gaps remain evidence work, not implementation proof. |
| Architecture inventory | Green | Current source inventory shape only. |
| Architecture scorecard current check | Red | It references stale purged paths and cannot establish a current score. |
| Strict quality gate | Red | Full strict quality claim unavailable. |
| Runtime direct-write audit | Red | Meaningful mutation compliance unavailable. |
| LocalRuntimeProof | Red | 17/20 checks pass; 157 blockers remain. |
| Current-HEAD local build/runtime/simulator/visual | Not run | No claim in these dimensions. |
| PR CI build-for-testing | Passed | Build-for-testing only; it does not prove runtime behavior or release readiness. |

## Smallest successor queue and blockers

The smallest useful queue is: normalize the mutation inventory; repair atomic authority in `RuntimeCommandMutationCommitter` and Today; migrate remaining compatibility paths in separate owner slices; reconcile external intake/effects; normalize crash/replay/migration/corruption proof; repair composition and navigation responsibility; evaluate at most one compiler-boundary candidate at a time; then re-derive the closeout projection.

The immediate blockers are the 154 unresolved/unproven mutation rows, pre-authority writes, incomplete durable acknowledgement and external-effect proof, stale/circular proof gates, composition/navigation bypasses, zero authorized future targets, and absent current-HEAD runtime/simulator/visual evidence. The executable sequence, exact scopes, tests, rollback, and claim ceilings are defined separately in `docs/superpowers/plans/2026-07-20-architecture-modernization-post-cutover.md`.
