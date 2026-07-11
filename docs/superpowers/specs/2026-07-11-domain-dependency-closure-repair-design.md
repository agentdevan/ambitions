# Ambitions Domain Dependency-Closure Repair Design

Status: Owner-approved design direction; written specification awaiting owner review
Date: 2026-07-11
Decision record: ADR-BUILD-003
Depends on: ADR-BUILD-002, Domain boundary census commits `7f51f3a7d` through `0a4643c3d`, and the blocked Task 3 compiler evidence
Scope: repair reverse dependencies that prevent `Core/Domain` from compiling independently, then resume the approved Domain module extraction
Claim status: Aspirational until implementation and current proof satisfy every scoped gate

## 1. Purpose

This repair exists to make the Domain edit-build-test loop materially faster without weakening code quality.

The blocked extraction proved that the current `Core/Domain` source set is not dependency-closed. Eleven Domain files produced 123 compiler errors because they reference twelve types currently declared in LocalRuntimeOS, Persistence, Today projection, or You projection.

The repair establishes the intended dependency direction:

```text
App / Surfaces / Trust / LocalRuntimeOS / Persistence
                         ↓
                 AmbitionsDomain
```

It must not create this graph:

```text
AmbitionsDomain → LocalRuntimeOS / Persistence / Surfaces
```

The result is successful only when focused Domain tests can compile and run without rebuilding application, surface, persistence, or runtime implementation source, while broader integration and Release gates still protect boundary behavior.

## 2. Current compiler evidence

The first exact 166-file `AmbitionsDomain` build found these unresolved declarations:

| Declaration | Current owner |
|---|---|
| `ActionReceiptSourceDomain` | `Core/LocalRuntimeOS/Inspection` |
| `ActionReceiptUndoAvailability` | `Core/LocalRuntimeOS/Inspection` |
| `AmbitionsCommand` | `Core/LocalRuntimeOS/Commands` |
| `AmbitionsCommandSource` | `Core/LocalRuntimeOS/Commands` |
| `EntityRevisionTombstoneEntityKind` | `Core/LocalRuntimeOS/Inspection` |
| `EventLedgerPrivacyClassification` | `Core/LocalRuntimeOS/Inspection` |
| `AFEPMeasurementEvidenceState` | `Core/Persistence` |
| `NowCommitmentKind` | `Surfaces/Today/Projection` |
| `NowContextLens` | `Surfaces/Today/Projection` |
| `NowGoalPressureKind` | `Surfaces/Today/Projection` |
| `NowPressureLevel` | `Surfaces/Today/Projection` |
| `YouMemoryFreshness` | `Surfaces/You/Projection` |

These are internal target failures, not public-access failures. Making declarations public cannot solve them.

The twelve declarations are the proven first closure set, not an assumption that the compiler cannot reveal additional reverse dependencies after repair. Every additional unresolved symbol must pass the same ownership classification before source changes continue.

## 3. Decision

Use semantic lift plus adapter relocation.

Three rules govern every repair:

1. A stable value used by Domain, runtime, persistence, and surfaces moves to its lowest truthful owner.
2. A runtime command, receipt implementation, projection input, or presentation adapter stays outside Domain; the misplaced adapter or whole misowned source moves to its canonical owner.
3. No alias, duplicate declaration, wrapper with identical authority, or reverse module dependency is allowed to make the compiler quiet.

This design does not preserve the number 166 as an architectural law. Exact canonical ownership outranks the original file count. The Domain boundary census, design, plan, graph truth, and benchmark documentation must use the corrected source set after repair.

## 4. Binding ownership decisions

### 4.1 Lift shared semantic values into Domain

The following raw-value contracts become Domain-owned because Domain models already persist or reason over their meaning and multiple upper layers consume them:

- `EventLedgerPrivacyClassification`
- `AFEPMeasurementEvidenceState`
- `NowCommitmentKind`
- `NowContextLens`
- `NowGoalPressureKind`
- `NowPressureLevel`

Their exact cases and raw values do not change.

The declarations move without presentation labels, colors, icons, view state, storage implementation, query execution, or runtime mutation policy. Today-specific extensions remain under `Surfaces/Today/Projection`. Persistence descriptors remain under `Core/Persistence`. Event-ledger storage and inspection behavior remain under `Core/LocalRuntimeOS`.

Prefer existing coherent Domain files over creating one file per enum. A touched file must retain one clear responsibility and remain below the hard line cap. Do not create a generic `SharedModels.swift`, `DomainModels.swift`, or new architecture bucket.

### 4.2 Keep runtime authority in LocalRuntimeOS

The following remain LocalRuntimeOS-owned:

- `AmbitionsCommand`
- `AmbitionsCommandSource`
- `ActionReceiptSourceDomain`
- `ActionReceiptUndoAvailability`
- `EntityRevisionTombstoneEntityKind`

Domain must not refer to these declarations after repair.

`Native/Ambitions/Core/Domain/ActionReceiptSourceDomain.swift` is a runtime adapter file: it maps command sources, command targets, and receipt source domains. Move and rename its implementation under the exact `Core/LocalRuntimeOS/Inspection` owner. Leave no shim in Domain.

Move the `AmbitionsCommand` conversion extensions currently appended to `SafeAutomationProposedAction.swift` into `Core/LocalRuntimeOS/Commands`. The pure proposed-action values and evaluator remain Domain-owned only if they compile using Domain contracts alone.

`ExecutionResilienceInput` currently stores `[AmbitionsCommand]` and combines runtime events, Today projection state, and recovery projection inputs. It is not a pure Domain input. Move the runtime projection input/assembly authority to `Core/LocalRuntimeOS/Projections` or replace the command field with the smallest Domain-neutral evidence representation proven by its consumers. Do not expose `AmbitionsCommand` from Domain.

Receipt and tombstone types remain runtime-owned. Any Domain file that needs their implementation state must either move to LocalRuntimeOS or depend on a smaller Domain-owned semantic value with distinct authority. Do not clone the receipt enums into Domain.

The following ownership repairs are binding because the live source is runtime policy, receipt, replay, or projection authority rather than pure Domain state:

- move `SafeAutomationPolicyModels.swift` and the evaluator/command-conversion authority in `SafeAutomationProposedAction.swift` to `Core/LocalRuntimeOS/Commands`; use focused `SafeAutomationPolicyContracts.swift`, `SafeAutomationPolicyEvaluator.swift`, and `SafeAutomationCommandAdapter.swift` responsibilities rather than preserving a broad Models file;
- move `AmbitionGraphLineageModels.swift` to `Core/LocalRuntimeOS/Inspection` and rename it `EntityRevisionTombstoneLineage.swift`, because its lifecycle and view types are tombstone inspection contracts;
- move `ExecutionResilienceModels.swift` to `Core/LocalRuntimeOS/Projections` and rename it `ExecutionResilienceProjection.swift`; it is assembled by Today and evaluated by the Private Life Runtime projector;
- move `CaptureRuntimeReceipt.swift`, `CaptureRuntimeReceiptKind.swift`, `SmartAttachmentCaptureRuntimeReceiptBuilder.swift`, and `SmartAttachmentCaptureRuntimeReplayTrace.swift` to `Core/LocalRuntimeOS/Inspection` with focused receipt names;
- move `SmartAttachmentCaptureRuntimeDetectedSummary.swift` and command/receipt-dependent blocks from `SmartAttachmentActionLabel.swift` to `Core/LocalRuntimeOS/CaptureRouting`; retain only pure attachment semantics under Domain.

These moves leave no compatibility shim in Domain. Consumers update to the canonical source owner through target membership and imports; no duplicate declaration remains.

### 4.3 Keep presentation vocabulary in surfaces

`YouMemoryFreshness` remains under `Surfaces/You/Projection` because it owns user-facing labels and visual state.

Move the `searchFreshness` adapters currently attached to `Capture`, `GoalFeedbackEvent`, and `Goal` out of Domain and into You projection. Domain objects retain their canonical lifecycle/state values; You maps those values to presentation freshness.

Today presentation extensions for the lifted `Now*` values remain in Today projection. Only the raw semantic enums move downward.

## 5. File and naming posture

This train may move or rename files only when the entire file is misowned. It may move an extension block when the base file also contains valid Domain authority.

Expected source actions:

- remove `Core/Domain/ActionReceiptSourceDomain.swift` after moving its runtime mappings to a plainly named LocalRuntimeOS inspection file;
- remove command-conversion extensions from `Core/Domain/SafeAutomationProposedAction.swift` and place them under LocalRuntimeOS commands;
- move You-facing search-freshness extensions from their Domain files into a focused You projection file;
- relocate `ExecutionResilienceModels.swift` to LocalRuntimeOS projections as `ExecutionResilienceProjection.swift`;
- relocate `AmbitionGraphLineageModels.swift` to LocalRuntimeOS inspection as `EntityRevisionTombstoneLineage.swift`;
- relocate and rename safe-automation policy/evaluator/adapter source under LocalRuntimeOS commands;
- relocate capture runtime receipt construction and replay to LocalRuntimeOS inspection, and relocate runtime detection/routing adapters to LocalRuntimeOS capture routing;
- move shared raw-value declarations without duplicating them;
- update tests, target membership, path audits, and truth documents to the final paths.

No new numbered suffix file is allowed. Existing touched `+03` or `+04` debt may not be expanded. No new `Models.swift` bucket is allowed.

## 6. Compatibility and behavior preservation

Before moving any Codable or raw-value declaration, executable tests must capture:

- every case and exact raw value;
- JSON encoding and decoding round trips;
- legacy/default decode behavior where present;
- Hashable and CaseIterable ordering assumptions where consumers rely on them;
- persistence mapping fallbacks;
- replay, snapshot, and receipt compatibility;
- surface mapping output for Today and You adapters.

Declaration movement must not change serialized type payloads, schema-version constants, stored raw values, command behavior, receipt behavior, runtime mutation policy, accessibility copy, or visible UI.

No data migration is expected because Swift source ownership changes do not alter stored raw values. If a focused test shows encoded-shape drift, stop and redesign that move rather than adding an unplanned migration.

## 7. Compiler-closure loop

The repair uses the compiler as a sequential ownership oracle:

1. capture compatibility tests;
2. apply one ownership family at a time;
3. build the exact Domain target candidate;
4. classify newly exposed unresolved declarations;
5. repair only declarations that satisfy this design's ownership rules;
6. stop if a required repair would add a Domain-to-runtime/surface/persistence edge, duplicate authority, or broaden product behavior;
7. repeat until Domain compiles with Foundation and CryptoKit only.

Compiler errors authorize investigation, not automatic movement.

## 8. Test-speed architecture

The repair preserves three proof lanes:

```text
Domain edit
  → AmbitionsDomain build
  → AmbitionsModuleTests focused Domain suite

Boundary edit
  → AmbitionsUnitTests focused integration suite

Milestone
  → application build-for-testing
  → Release build
```

The fast lane is valuable only when it excludes LocalRuntimeOS, Persistence, Surfaces, SwiftUI, and application composition from compilation.

Required performance proof after extraction resumes:

- three warm Domain module build samples;
- three warm Domain module test samples;
- three warm Domain leaf edit-through-proof samples;
- three warm GoalEngine edit-through-proof samples;
- comparison with the Build Architecture pilot baselines and the thresholds already approved in ADR-BUILD-002.

A material throughput regression blocks the next decomposition phase even when correctness tests pass.

## 9. Validation

The repair train must prove:

- compatibility tests fail before each ownership move when the new owner is absent or mapping is incomplete;
- focused tests pass after each move;
- `Core/Domain` imports only Foundation and CryptoKit;
- Domain source contains no reference to LocalRuntimeOS command, receipt implementation, persistence implementation, Today presentation, or You presentation types;
- source-disposition and boundary manifests match the corrected source set;
- no production file has duplicate target membership;
- XcodeGen graph has zero cycles;
- application Debug build-for-testing passes;
- affected integration tests pass;
- Release build with signing disabled passes;
- remediation governance, constitution, canon, truth-path, and diff gates run with exact results;
- independent review has no Critical or Important findings.

No physical-device, Xcode 27, visual, accessibility, privacy/legal, CI, TestFlight, App Store, or release-readiness proof is required or claimed by this structural train.

## 10. Execution sequence

### Slice 1 — Compatibility lock

- Add raw-value, Codable, persistence fallback, replay/snapshot, and Today/You mapping tests for the proven twelve-declaration set.
- Capture current behavior before moving declarations.

### Slice 2 — Semantic value lift

- Move the six shared semantic values to Domain-owned source.
- Keep upper-layer behavior in its existing owner.
- Prove serialization and focused integration behavior.

### Slice 3 — Runtime adapter relocation

- Move command/receipt mappings and command-to-safe-automation conversion to LocalRuntimeOS.
- Repair `ExecutionResilienceInput` ownership without exposing `AmbitionsCommand` from Domain.
- Move any receipt/tombstone-dependent authority that is not pure Domain.

### Slice 4 — Surface adapter relocation

- Move You freshness adapters to You projection.
- Keep Today presentation extensions above the Domain enums.
- Prove no visible or accessibility-copy change.

### Slice 5 — Closure and extraction resume

- Regenerate the Domain census and disposition evidence.
- Compile the corrected Domain source set independently.
- Independently review ownership and dependency closure.
- Update ADR-BUILD-002 assumptions and resume Domain extraction Task 3 from its missing-module RED checkpoint.

## 11. Failure handling

- If a proposed Domain-owned value contains UI, storage, runtime mutation, or receipt implementation behavior, split behavior from value before moving it.
- If a runtime file is consumed directly by surfaces, preserve the downward dependency through LocalRuntimeOS or a Domain contract; do not move runtime authority into a surface.
- If moving a declaration changes Codable shape or persistence fallback, revert that move and redesign the contract.
- If new compiler failures reveal materially broader coupling, keep the extraction Blocked and return to design review rather than silently widening the train.
- If the corrected Domain boundary is materially smaller, update canon and evidence to the enhanced tree; do not preserve the number 166 for historical parity.

## 12. Proof ceiling

Design and repair approval do not prove:

- any declaration has moved safely;
- Domain is dependency-closed;
- `AmbitionsDomain` builds;
- module or integration tests pass;
- serialization, replay, or persistence compatibility;
- improved test speed;
- Runtime decomposition readiness;
- release readiness.

The train remains Partial or Blocked until current executable evidence proves the scoped repair and the resumed extraction gates.

## 13. Design acceptance

Owner-approved direction:

- optimize for faster focused testing without weakening broader proof;
- lift only stable shared semantic values into Domain;
- keep runtime commands, receipts, tombstones, and adapters in LocalRuntimeOS;
- keep user-facing freshness and Today presentation behavior in surfaces;
- allow exact canonical source ownership to improve the original 166-file reference boundary;
- preserve raw values, Codable shape, replay, persistence fallbacks, behavior, and UI output;
- resume the approved Domain extraction only after compiler dependency closure is independently Green.
