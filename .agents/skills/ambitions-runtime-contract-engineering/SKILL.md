---
name: ambitions-runtime-contract-engineering
description: Use when implementing, reviewing, testing, or repairing Ambitions Private Life Runtime behavior contracts, including goal creation, full goal path, scheduling, future steps, plan adjustment, conflict resolution, life capital, proof, progress transfer, onboarding, review, Source Atlas, runtime mutations, receipts, undo, degraded/offline states, and scenario gates.
---

# Ambitions Runtime Contract Engineering

## Skill digest

Turn active product/runtime contracts into inspectable Swift implementation, scenarios, tests, and proof boundaries. This skill does not define canon, release proof, or product truth; it routes runtime work to the truth files and prevents vague "AI behavior" from replacing deterministic local contract engineering.

## Required starting point

Before using this skill, read `docs/truth/CODEX_START_HERE.md`.

For any runtime contract work, also read the smallest required subset:

- `docs/truth/PRODUCT_EXPERIENCE_CANON.md` for behavior contracts and scenario gates.
- `docs/truth/PRODUCT_MOAT_TRUTH.md` for Private Life Runtime moat and local-first boundaries.
- `docs/truth/PRODUCT_DESIGN_TRUTH.md` for surface/composer/motion/trust architecture.
- `docs/truth/IMPLEMENTATION_TRUTH.md` and `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` for current implementation/proof status.
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` when Apple APIs, SwiftUI, SwiftData, permissions, App Intents, notifications, widgets, or platform primitives are touched.

Load `ambitions-source-truth-authority`, `ambitions-architecture-tree-enforcement`, and `ambitions-ios-quality-gate` when the change touches source or Apple-platform behavior. Load `ambitions-release-proof-honesty` before any proof/readiness wording.

## Contract workflow

1. Name the contract: goal creation, full goal path, scheduling, future step, plan adjustment, conflict resolution, life capital, proof, progress transfer, onboarding, review, Source Atlas, or a truth-file-named scenario.
2. Quote or cite the truth-file authority in your notes, then implement only the scoped contract slice.
3. Map the contract to canonical owners: `Core/Runtime`, `Projection/Commands`, `Projection/Mutations`, `Trust`, `Scenarios`, `Surfaces`, `Composer/Capture`, `Stage/Motion`, or another exact Final Architecture Tree owner.
4. Define deterministic inputs, state transition, mutation receipt, undo/recovery behavior, proof ledger event, accessibility announcement, offline/degraded behavior, and privacy boundary.
5. Add or update scenario/test coverage at the lowest useful level: pure runtime tests first, projection/command tests next, UI/runtime proof only when user-facing behavior changes.
6. Close with non-claims: no release proof, device proof, public accessibility proof, or privacy/legal signoff unless separately evidenced.

## Engineering bar

- Runtime behavior must be local-first, inspectable, deterministic where feasible, and explainable through proof/receipt/history surfaces.
- Do not implement a generic chatbot, activity feed, productivity score, streak system, cloud AI dependency, or backend profile path as a runtime contract.
- Do not place new runtime authority under `Features/`. If touching legacy `Features/`, move toward the canonical owner or record explicit Yellow debt with a named repair train.
- Every mutation that changes user-visible life state needs a receipt/undo/proof story or a deliberate, documented reason it does not.

## Closeout shape

Include:

- Contract name and truth-file authority.
- Canonical owners touched.
- State/mutation/proof/undo/degraded behavior implemented.
- Tests/scenarios run or not run, with exact commands.
- Remaining Yellow contract debt and next repair train, if any.
- Explicit non-claims.
