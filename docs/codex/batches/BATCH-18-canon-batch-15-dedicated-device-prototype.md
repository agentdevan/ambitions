# Batch 18 — Canon Batch 15 / Dedicated Device Prototype

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Numbering Note

Batch 18 is the operational execution row in `docs/codex/BATCH_REGISTRY.md`. Canon Batch 15 is semantic roadmap context from the canonical batch plan and is not renumbered.

## Goal

Define and implement the narrowest viable dedicated-device prototype seam so Ambitions can validate a non-phone surface advantage without turning this batch into a hardware platform, a voice product rollout, or a second full client application.

The only supported thesis is a bedside ritual companion. This batch should prove that a useful non-phone glance and ritual surface can exist, that the current runtime can support it, and that the iPhone app remains the home for deep editing and complex workflows.

## In Scope

- audit and preserve the new runtime boundary, client context, external actions, ambient surfaces, ritual loops, and current iPhone app ownership
- define the minimum runtime-only dedicated-device prototype layer for one narrow thesis: bedside ritual companion
- add constrained client context for the bedside companion while keeping `.iphoneApp` default and fully capable
- derive a limited ritual, glance, and quick-action projection from existing runtime context, external snapshot truth, ritual cues, and command descriptors
- add device-safe runtime entry points limited to already-supported command semantics
- return deterministic fallback-to-phone behavior for deep editing and complex workflows through existing route-request/app-route adaptation
- add or refine shared runtime-facing contracts only where immediately useful and compatibility-safe
- add focused tests for dedicated-device client context, constrained runtime behavior, fallback routing, privacy-safe projection, and compatibility with current app/runtime flows

## Out Of Scope

- actual hardware integration
- new app targets, widget targets, hardware integration layers, production device UI shells, or transport protocols
- broad voice runtime rollout, speech input, audio sessions, or conversational interaction loops
- desktop or tablet rollout
- backend expansion
- auth/account systems
- major app redesign
- a second persistence stack
- a second external snapshot schema or second ambient-state model
- widened notification, widget, external action, or external snapshot payloads unless compile reality forces a tiny additive parity field
- speculative multimodal platform work beyond what current runtime seams can truthfully support
- replacing the iPhone app as the primary product client

## Dependency Rules

- do not skip ahead
- build on the existing runtime separation boundary, external action infrastructure, ambient surfaces, ritual system, and app-shell routing
- choose bedside ritual companion as the only supported prototype thesis
- do not add multiple prototype kinds, generic device-family abstractions, or speculative future surface matrices
- keep the device prototype constrained, glanceable, and ritual/quick-action oriented
- keep deep editing and complex planning on the iPhone app
- prefer additive compatibility-safe boundary work over disruptive rewrites

## Extra Constraints

- keep the seam runtime-only and projection-based
- derive `DedicatedDevicePrototypeRuntime` from existing runtime context, external snapshot truth, ritual cues, and current command infrastructure
- keep device-safe actions literal to command descriptors already present in the external snapshot/command layer
- return fallback-to-phone behavior instead of inventing local handling for actions requiring deeper editing, branching flows, or complex context gathering
- keep fallback app-owned through existing route-request/app-route adaptation
- keep prototype outputs privacy-safe and glance-safe; do not expose raw user-entered free text, long summaries, or sensitive capture content
- do not introduce voice runtime, speech input, audio session handling, or conversational interaction loops
- run full scheme validation unconditionally
- mark Batch 18 completed only if generation, build, targeted tests, full `AmbitionsTests`, and full scheme validation all pass

## Current Repo Notes

- Batch 17 completed a thin runtime separation boundary with `.iphoneApp` as the default runtime client context.
- `RuntimeContextSnapshot` already includes external snapshot truth, local-only sync/trust status, and runtime memory summary.
- `ExternalSurfaceSnapshot` and `ExternalSurfaceNowState` already carry privacy-safe ritual cues, glance posture, blocker counts, capture urgency, and supported command descriptors.
- `RuntimeActionCommandExecuting` already executes reusable command semantics, while app route adaptation remains owned by the current iPhone app shell.
- The existing widget, notification, and external action payloads are sufficient for this batch and should not be widened.

## Exit Criteria

- `.iphoneApp` remains the default and fully capable runtime client context
- bedside ritual companion is the only constrained non-phone prototype context
- dedicated-device projection derives from runtime context and external snapshot truth without adding a second snapshot schema
- projection exposes only glance-safe template keys, references, compact posture/state, ritual cues, command policy, and fallback route requests
- device-safe actions are limited to existing supported command descriptors
- goal detail, captures inbox, Today, drafts, plans, profile, and other deep-edit/complex workflows fall back deterministically to the phone
- runtime factory composes the prototype projection without creating another service graph
- focused tests cover context constraints, projection derivation, missing snapshot fallback, privacy safety, allowed command policy, fallback routing, and runtime compatibility
- generation, build, targeted tests, full `AmbitionsTests`, and full scheme validation all pass before status changes to completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsRuntimeBoundaryTests -only-testing:AmbitionsTests/DedicatedDevicePrototypeRuntimeTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Added `.bedsideRitualCompanion` as the only constrained non-phone prototype context while keeping `.iphoneApp` the default fully capable client context.
- Added `DedicatedDevicePrototypeRuntime` as a runtime-only projection derived from `RuntimeContextSnapshot`, `ExternalSurfaceGlanceState`, privacy-safe ritual cues, and existing external command descriptors.
- Kept outputs glance-safe by exposing template keys, compact posture/pressure/capture/blocker signals, references, command policy, and deterministic fallback route requests without raw user text, long summaries, capture content, or sensitive titles.
- Limited local device actions to already-supported `.complete` and `.snooze` command semantics when the external snapshot descriptor and target requirements allow them.
- Routed deep-edit and complex app-owned actions such as goal detail, Today, and captures inbox to deterministic fallback-to-phone route requests instead of adding local device handling.
- Composed the projection through `AmbitionsRuntimeFactory` without adding a new service graph, app target, widget target, hardware layer, voice/audio runtime, transport protocol, persistence stack, external snapshot schema, ambient-state model, or payload widening.
- Added focused runtime and boundary tests for constrained context, projection derivation, missing snapshot fallback, privacy safety, allowed command policy, fallback behavior, and compatibility with existing runtime/app flows.
- Validation passed on April 19, 2026:
  - `xcodegen generate`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsRuntimeBoundaryTests -only-testing:AmbitionsTests/DedicatedDevicePrototypeRuntimeTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

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
