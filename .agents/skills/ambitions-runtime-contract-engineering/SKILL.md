---
name: ambitions-runtime-contract-engineering
description: Use when implementing, reviewing, testing, or repairing Ambitions Private Life Runtime behavior contracts, including goal creation, full goal path, scheduling, future steps, plan adjustment, conflict resolution, life capital, proof, progress transfer, onboarding, review, Source Atlas, runtime mutations, receipts, undo, degraded/offline states, and scenario gates.
---

# Ambitions Runtime Contract Engineering

## Skill digest

Turn active product/runtime contracts into inspectable Swift implementation, scenarios, tests, and proof boundaries. This skill does not define canon, release proof, or product truth; it routes runtime work to the truth files and prevents vague "AI behavior", architecture lore, or prose-only proof from replacing deterministic local contract engineering.

## Required starting point

Before using this skill, read `docs/truth/CODEX_START_HERE.md`.

For any runtime contract work, also read the smallest required subset:

- `docs/truth/PRODUCT_EXPERIENCE_CANON.md` for behavior contracts and scenario gates.
- `docs/truth/PRODUCT_MOAT_TRUTH.md` for Private Life Runtime moat and local-first boundaries.
- `docs/truth/PRODUCT_DESIGN_TRUTH.md` for surface/composer/motion/trust architecture.
- `docs/truth/IMPLEMENTATION_TRUTH.md` and `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` for current implementation/proof status.
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` when Apple APIs, SwiftUI, SwiftData, permissions, App Intents, notifications, widgets, or platform primitives are touched.

Load `ambitions-source-truth-authority`, `ambitions-architecture-tree-enforcement`, and `ambitions-ios-quality-gate` when the change touches source or Apple-platform behavior. Load `ambitions-release-proof-honesty` before any proof/readiness wording.

## LocalRuntimeOS law

New meaningful Private Life Runtime mutations must be designed against:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

As of Linear `AMB-1544`, `Core/LocalRuntimeOS/` is the target backend/runtime owner. Existing `Core/Runtime/`, `Core/Persistence/`, and `Projection/Commands/` source may be scaffolding to migrate or reuse, but it is not the final authority for new command, transaction, event, projection, side-effect, privacy, sync, migration, repair, or diagnostics work.

Do not add new runtime nouns, suffix-split files, broad model files, Source Atlas scope, or projection authority to make a contract sound complete. Delete, collapse, or replace duplicate authority first, keep Source Atlas public-reference-only with ADR allowlist plus no-private-life-graph boundary proof, and prefer feature-local projection when canon allows.

Accepted Yellow is forbidden for incomplete required runtime scope. If the issue requires command routing, event/replay behavior, receipt/rejection behavior, side-effect outbox enforcement, direct-write removal, migration proof, projection safety, deletion/quarantine, or executable tests, documentation or classification is not closure. Keep the issue `In Progress`, move it to `Needs Repair`, or wait for `Ready For Review` proof.

## Contract workflow

1. Name the contract: goal creation, full goal path, scheduling, future step, plan adjustment, conflict resolution, life capital, proof, progress transfer, onboarding, review, Source Atlas, or a truth-file-named scenario.
2. Quote or cite the truth-file authority in your notes, then implement only the scoped contract slice.
3. Map the contract to canonical owners: `Core/LocalRuntimeOS/CommandSpine`, `Core/LocalRuntimeOS/TransactionKernel`, `Core/LocalRuntimeOS/EventJournal`, `Core/LocalRuntimeOS/ProjectionEngine`, `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`, `Core/LocalRuntimeOS/PlanningEngine`, `Core/LocalRuntimeOS/TimeEngine`, `Core/LocalRuntimeOS/CaptureRouteGraph`, `Core/LocalRuntimeOS/TrustSystem`, `Core/LocalRuntimeOS/SearchRecall`, `Core/LocalRuntimeOS/SideEffectSystem`, `Core/LocalRuntimeOS/SourceAtlas`, `Core/LocalRuntimeOS/PrivacySecurity`, `Core/LocalRuntimeOS/Storage`, `Core/LocalRuntimeOS/MigrationRepair`, `Core/LocalRuntimeOS/Diagnostics`, `Projection/Mutations`, `Trust`, `Scenarios`, `Surfaces`, `Composer/Capture`, `Stage/Motion`, or another exact Final Architecture Tree owner.
4. Define deterministic inputs, state transition, mutation receipt, undo/recovery behavior, proof ledger event, accessibility announcement, offline/degraded behavior, and privacy boundary.
5. Keep Stage/UI work SwiftUI-native and thin when a runtime contract reaches UI; custom Stage/UIKit/rendering machinery needs product-law and Apple-source justification.
6. Add or update scenario/test coverage at the lowest useful level: pure runtime tests first, projection/command tests next, UI/runtime proof only when user-facing behavior changes.
7. Close with proof artifacts and non-claims: no release proof, device proof, public accessibility proof, Source Atlas/R2 readiness, or privacy/legal signoff unless separately evidenced.

## Engineering bar

- Runtime behavior must be local-first, inspectable, deterministic where feasible, and explainable through proof/receipt/history surfaces.
- Do not implement a generic chatbot, activity feed, productivity score, streak system, cloud AI dependency, or backend profile path as a runtime contract.
- Do not place new runtime authority under `Features/`, `Core/Runtime/`, `Core/Persistence/`, or `Projection/Commands/`. If touching legacy/scaffolded owners, move toward `Core/LocalRuntimeOS/` or record explicit Yellow debt with a named repair train.
- Do not create new `+02`, `+03`, or `+04` split files, broad `Models.swift` files, production Swift files above the hard line cap, or architecture nouns without deleting/collapsing duplicate authority in the same scoped train.
- Every mutation that changes user-visible life state needs command validation, event or ledger append semantics, projection/materialization consequences, a receipt/undo/proof story, replay/idempotency behavior, and a deliberate documented exception if any part is out of scope.
- Do not close required runtime remediation as Accepted Yellow while any required source change, deletion/quarantine, receipt behavior, migration proof, projection safety, or executable test remains incomplete.

## Closeout shape

Include:

- Contract name and truth-file authority.
- Canonical owners touched.
- State/mutation/proof/undo/degraded behavior implemented.
- Tests/scenarios run or not run, with exact commands.
- Remaining Yellow contract debt and next repair train, if any.
- Explicit non-claims.
