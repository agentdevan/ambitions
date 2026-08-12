# UFP implementation plan

## Program boundary

The program is **Ambitions Unified Maximum Polish Frontend Program**. Its sole
operational ledger is
`/Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json`.
This repository packet is durable lifecycle governance and must not create or
mirror a `PROGRAM.json`.

Production source is entirely legacy until UFP-6 begins after complete UFP-5
fixture-frontend owner approval. Native Foundry is a deterministic fixture/
render/proof environment. No production target imports it, and no Foundry
fixture, screenshot, host test, or visual score is production runtime, device,
accessibility, or release proof.

## Milestones and order

| Milestone | Purpose | Entry | Exit / blocked-by rule |
| --- | --- | --- | --- |
| UFP-0 | Consolidate authority, lifecycle, ledger, workflow, component controls, canonical-source boundary, and zero-legacy contract. | This approved packet. | Ledger has exact UFP-0…UFP-8 controls and no shadow ledger exists. |
| UFP-1 | Finish primary directions: Today R04 D-129 retained, Time next. | UFP-0. | Component-cycle evidence and owner decisions exist; this is not complete-frontend approval. |
| UFP-2 | Complete the 47-screen/system-surface fixture coverage matrix. | UFP-1. | Typical/dense/very-dense, Light/Dark, keyboard, localization, RTL, accessibility, failure, and restoration states are covered where applicable. |
| UFP-3 | Derive and owner-approve the unified design system and cross-root grammar. | UFP-2. | Grammar is earned from shared semantics/state/accessibility/lifecycle, not speculative abstraction. |
| UFP-4 | Exhaustively disposition components and establish canonical Contracts/Foundation/UI source. | UFP-3. | Every component is `promote`, `rebuild`, `fixture-only`, `historical`, or `delete`; canonical source graph is clean. |
| UFP-5 | Complete and owner-approve the entire fixture-driven frontend. | UFP-4. | Source-identical canonical UI renders full coverage through synthetic adapters and `approvals.frontend_design` is true. Production wiring is otherwise blocked. |
| UFP-6 | Runtime-integrate and reconstruct all production vertical slices, starting Today. | UFP-5 frontend-complete gate and independent runtime-integration approval. | All roots/global journeys use real local-runtime adapters with no duplicate authority. |
| UFP-7 | Atomic production cutover and delete all legacy; verify zero legacy. | UFP-6 plus cutover/legacy-deletion approvals. | No legacy frontend source, component, target, asset, dependency, wrapper, route, preview, UI test, flag, or live reference remains. |
| UFP-8 | Physical-device, accessibility, performance, privacy, localization, migration, and release closure. | UFP-7 zero-legacy proof. | Final device/release evidence and explicit release approval are recorded. |

UFP-5 `frontend_design` approval is the non-negotiable production-wiring
boundary. UFP-6 runtime proof does not imply cutover/deletion. UFP-7 deletion
does not imply physical-device or release closure. UFP-8 never deletes the
retained component-sourcing research directory or historical evidence.

## Affected components and interfaces

| Area | Current boundary | Planned end state |
| --- | --- | --- |
| Contracts | `Packages/AmbitionsPresentation/Sources/AmbitionsPresentationContracts/FlagshipContracts.swift` | Canonical Contracts module: Sendable/Codable routes, fixtures, projection/intent/receipt/recovery/restoration vocabulary. |
| Foundation | `Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipFoundation/FlagshipSemanticTokens.swift` | Canonical Foundation module: semantic tokens, native styling, state/motion/accessibility roles; no UI dependency. |
| UI | `Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI/FlagshipShell.swift` | Canonical UI module: root and journey composition, projection/intent adapters, no direct persistence mutation. |
| Foundry | `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/` and `Native/AmbitionsNativeFoundryHost/` | Fixture/render/proof only; no production imports or final component authority. |
| Legacy frontend | `Native/Ambitions/DesignSystem`, `Stage`, `Rendering`, `Surfaces`, `Composer`, related assets/wrappers/targets discovered by UFP-0 | Entirely removed at UFP-7 after UFP-6 replacement proof and final-byte parity/rollback evidence. |

## Data, persistence, and migration approach

Contracts only describes presentation-side stable values. Local runtime remains
the source of projections, typed intents, idempotency, revisions, Receipts,
undo, recovery, and replay. UI does not introduce a second store, mutation
path, or restoration owner. Any Contract schema change has a version bump,
fixture migration, backward-read/replay test, and rollback path. Pure visual
components have no persistence/migration work; their plan must state that fact
explicitly rather than silently omit it.

## Rollout and deletion approach

UFP-6 starts with Today and extends the proven pattern through every route
family. UFP-7 makes one atomic cutover and deletes only entries with replacement
parity, rollback exit condition, and a no-live-reference search. App/extension/
preview targets, packages, assets, resource catalog entries, wrappers, test
support, flags, routes, and build settings are deletion classes—not merely
Swift files. UFP-8 closes physical-device and release evidence.

## Implementation order constraints

1. Do not promote an existing component based on visual similarity.
2. Do not start production wiring before UFP-5 complete-fixture-frontend owner approval.
3. Do not broaden a component API before its UFP-4 disposition and module owner
   are recorded.
4. Do not delete legacy before UFP-6 runtime integration, approvals, and UFP-7 live replacement parity and rollback proof.
5. Do not call Simulator/Foundry evidence device or release proof.
