---
name: ambitions-architecture-tree-enforcement
description: Use before Ambitions source creation, movement, refactors, or reviews to enforce the exact architecture tree from PRODUCT_DESIGN_TRUTH.md with no equivalent folders, no legacy Features ownership, no Motion/Capture root destinations, and no backend/runtime authority outside Core/LocalRuntimeOS.
---

# Ambitions Architecture Tree Enforcement

## Skill digest
- Use when: source creation, movement, refactor, architecture review, or touched `Features/` compatibility is in scope.
- Do not use as: product canon, source proof, or a reason to invent equivalent paths.
- Required first read: `docs/truth/CODEX_START_HERE.md`.
- Owns: exact Final Architecture Tree enforcement and non-equivalent owner checks.
- Does not own: product canon, implementation completeness, release proof, or migration approval beyond the scoped train.
- Hard red: new product logic under non-canonical owners, new backend/runtime authority outside `Core/LocalRuntimeOS/`, Motion/Capture root destinations, or "equivalent" folder/path interpretation.
- Required output: Final Architecture Tree inspected, canonical owners touched, non-canonical owners touched, shims left behind, architecture debt, next repair train.

This skill is operating support only. The binding architecture tree lives in `docs/truth/PRODUCT_DESIGN_TRUTH.md` under `Final Architecture Tree`.

`docs/truth/*`, live source, tests, current logs, current proof artifacts, and current user or issue instructions win over this skill.

This skill exists to stop architecture drift, convenience folders, old feature ownership, and "equivalent" interpretations.

Architecture simplification posture:

```text
law over lore
deep runtime, boring UI
delete before naming
proof automation outranks prose
```

Prefer stable laws and canonical owners over new terminology. Do not add new broad architecture nouns, folders, suffix splits, engines, kernels, managers, coordinators, services, systems, runtimes, ledgers, scenes, lenses, or OS labels unless the scoped train deletes, collapses, or replaces duplicate authority or active truth explicitly approves the new owner with a proof gate. Deep runtime is allowed under the canonical LocalRuntimeOS law; user-facing UI must remain plain and object-led. Proof artifacts, scripts, logs, and accepted evidence set the claim ceiling.

## Hard Rule

The final architecture tree is binding path ownership, not a suggestion.

Do not use these escape hatches:

- "equivalent"
- "roughly equivalent"
- "same concept under Features"
- "keep it where it already is"
- "temporary feature-owned implementation"
- "compatibility location"
- "parallel implementation"
- "close enough for now"

If product canon says an object belongs under `App/`, `Stage/`, `Core/`, `Core/LocalRuntimeOS/`, `Projection/`, `Language/`, `Trust/`, `Interaction/`, `Rendering/`, `DesignSystem/`, `Surfaces/`, `Composer/`, `Scenarios/`, `Diagnostics/`, or `Quality/`, then new or moved implementation must use that exact owner.

## Required Read Order

Before creating, moving, reviewing, or refactoring source, read:

1. `docs/truth/CODEX_START_HERE.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. the `Final Architecture Tree` section in full
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `AGENTS.md`
7. relevant live source, tests, `project.yml`, scripts, and current logs

Also read `docs/truth/PRODUCT_EXPERIENCE_CANON.md` when architecture work touches Life Capital, full pathing, Future Steps, proof/progress transfer, Source Atlas, onboarding, reviews, automation, Capture, Time, Goals, Today, You, or Trust.

If the current repo does not match the final tree, the mismatch is architecture debt. It is not permission to add new work to the wrong owner.

## Canonical Ownership Enforcement

Persistent root surfaces are exactly:

```text
Today / Goals / Time / You
```

Global composer:

```text
Capture
```

Cross-surface behavior layer:

```text
Motion
```

Inspectable trust layer:

```text
Proof / Source / Privacy / History / Receipts
```

Required ownership rules:

- App launch, environment, dependencies, feature flags, and stage host belong under `App/`.
- Root shell, surfaces, overlays, routing, chrome, safe areas, focus, reducers, effects, transitions, and motion behavior belong under `Stage/`.
- Motion belongs under `Stage/Motion/` only. Motion is not a root surface, not `Surfaces/Motion/`, not a tab, not a destination.
- Domain models, time primitives, and permissions belong under `Core/`.
- New backend/runtime authority belongs under `Core/LocalRuntimeOS/` and must preserve the `Command -> Event -> Projection -> Receipt -> Replay` target law.
- Existing `Core/Runtime/`, `Core/Persistence/`, and `Projection/Commands/` source is implementation scaffolding and migration debt when touched. Do not add new runtime policy, persistence substrate authority, command authority, event authority, projection materialization authority, side-effect authority, privacy egress authority, sync authority, migration authority, or diagnostics authority there.
- Runtime-to-UI translation belongs under `Projection/`; prefer feature-local projection over new central `Projection/SurfaceLenses` authority when canon allows.
- User-facing vocabulary, copy policy, forbidden terms, and copy budget belong under `Language/`.
- Proof, Source, Privacy, History, Receipts, and trust disclosure behavior belong under `Trust/`.
- Gestures, keyboard policy, direct manipulation, and haptics belong under `Interaction/`.
- Canvas renderers and semantic mirrors belong under `Rendering/`.
- Tokens, native settings primitives, object-stage primitives, and product objects belong under `DesignSystem/`.
- Root product surfaces belong under `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, and `Surfaces/You` only.
- Capture belongs under `Composer/Capture/`, not `Surfaces/Capture/`, not root navigation, not a feature tab.
- Scenarios belong under `Scenarios/`.
- Diagnostics belong under `Diagnostics/`.
- Audit harnesses and quality gates belong under `Quality/`.

## Features Directory Law

`Features/` is not a canonical owner for new Ambitions architecture.

- Do not create new product implementation under `Features/`.
- Do not keep touched implementation under `Features/` because it already exists there.
- Do not add new runtime, projection, surface, composer, motion, trust, rendering, design-system, or quality ownership under `Features/`.
- Existing `Features/` code is legacy compatibility until migrated.
- Any train touching a `Features/` implementation must move ownership toward the final architecture tree or close Yellow with an explicit architecture-debt note and a named next repair train.

A short-lived compatibility shim is allowed only when required to preserve compilation during migration. The shim must:

- contain no product policy
- contain no new runtime authority
- contain no new projection authority
- contain no new trust authority
- route to the canonical owner
- be named or documented as a shim
- have a removal target in the closeout

## Forbidden Drift

Stop and repair before closeout if the train creates or expands:

- new `+02` or `+03` split files
- new broad `Models.swift` files
- file-size or suffix-split churn that preserves duplicate authority instead of deleting or collapsing it
- `RootTab` as root architecture
- `TabView` as the product model
- `Surfaces/Motion/`
- `Surfaces/Capture/`
- `Projection/SurfaceLenses/MotionLens.swift`
- `Projection/StageScenes/MotionStageScene.swift`
- root Motion navigation
- root Capture navigation
- fifth persistent surface
- generic dashboard surface
- feature-owned runtime policy
- Core/Runtime-owned new backend/runtime policy
- Core/Persistence-owned new backend substrate policy
- Projection/Commands-owned new command spine policy
- meaningful runtime mutations that bypass `Command -> Event -> Projection -> Receipt -> Replay`
- feature-owned projection policy
- feature-owned trust policy
- feature-owned motion policy
- new Source Atlas scope before public-reference/no-private-life-graph boundary proof exists
- custom Stage, UIKit, or rendering machinery where SwiftUI-native implementation can satisfy product law
- source paths that are "equivalent" to the final tree but not the final tree

## Migration Rule

When source already exists outside the final tree:

1. Identify the canonical owner from `PRODUCT_DESIGN_TRUTH.md`.
2. Move the source to the exact owner when feasible within the train.
3. Update imports, XcodeGen/project ownership, tests, previews, and scripts.
4. Leave only a minimal shim if required for compatibility.
5. Record the shim and removal target in closeout.
6. Do not call the train Green if new product logic remains in a non-canonical owner.

## Closeout Required

Every train using this skill must report:

- `Final Architecture Tree` section inspected: yes/no
- canonical owners touched
- non-canonical owners touched
- files moved or created
- old/non-canonical paths removed
- compatibility shims left behind, if any
- architecture debt
- next repair train if debt remains
- confirmation that no "equivalent" folder/path interpretation was used
- proof artifacts, validation commands, and not-run checks that set the closeout ceiling
