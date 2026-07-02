# Ambitions Agent Contract

Status: Active repo front-door guidance  
Audience: Codex, ChatGPT, GitHub agents, and any AI contributor touching this repository  
Last major canon refresh: 2026-06-16  
Purpose: Route agents to active truth, prevent stale-canon work, preserve proof honesty, and keep Ambitions on a premium local-first native iPhone product path.

This file is not implementation proof, validation proof, release proof, product completeness proof, or a roadmap. It is the standing operating contract for agents.

If this file conflicts with `docs/truth/*`, the truth files win.

---

## 1. Non-negotiable Ambitions identity

Ambitions is a premium native iPhone-first, local-first Personal Life OS. It organizes life, shapes time, grounds goals in daily reality, adapts when reality changes, and helps the user make meaningful progress through calm, personalized, inspectable, non-shaming support.

The supreme product mission truth is `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`: Ambitions is a private Personal Life OS for contextual life orchestration. Its primary function is to convert messy life intent into contextual goal paths, scheduled next actions, adaptive schedule reflow, recovery moves, proof-backed progress, and user learning, locally and inspectably.

Short product thesis:

```text
Ambitions helps life make sense, then helps the user start what fits.
```

The active product moat is the Private Life Runtime: a local, inspectable, user-controlled life graph that turns intent into reality-fit action, then preserves what changed over time.

Agents must optimize for native iPhone quality, local-first core behavior, offline core value with no account, optional Ambitions Account identity and entitlement support when scoped, R2/Source Atlas as public/reference/freshness infrastructure only, deterministic inspectable intelligence, proof-backed claims, premium SwiftUI polish, accessibility, privacy, and clean repo authority hierarchy.

---

## 2. Current active product canon

Top-level persistent surfaces are exactly:

```text
Today / Goals / Time / You
```

Global composer/action layer:

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

Primary objects:

- Today -> Reality Meridian / Start Here
- Goals -> Constellation Atlas
- Time -> LifeShape Field
- You -> User System Profile
- Global Capture -> Atmosphere Composer / Open Field
- Motion behavior -> Stage/Motion proof, recovery, re-entry, completion, blockage, time-shift, undo, and protected-boundary state changes

Motion is not a tab. Motion is not a destination. Motion is not current product root IA.

Motion belongs under `Stage/Motion` as product behavior, not as analytics surface, activity feed, XP system, score, streak, productivity report, social timeline, or dashboard.

`Capture` is the global composer/action layer, not a tab, inbox, notes feed, plus-tab utility, chatbot, generic intake dashboard, category grid, or persistent floating button.

`Plan`, `Profile`, `Captures`, `Pulse`, `Motion tab`, and `Capture tab` are historical or compatibility context only unless active truth explicitly scopes a migration.

Locked user-facing language:

- Use `Start here` for the flagship Today decision object.
- Use `Recommended step`, not `Recommended next move`.
- Use `Step`, not generic task/move language.
- Use `Start now` when launching execution.
- Use `Open step` when opening detail.
- Use `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo` for closure/control states.
- Avoid shame, fake urgency, streak pressure, score pressure, AI branding, and productivity-guilt framing.

---

## 3. Apple Platform Source Atlas

Before changing SwiftUI, UIKit interop, SwiftData, App Intents, WidgetKit, Live Activities, notifications, BackgroundTasks, LocalAuthentication, privacy, permissions, accessibility, HIG-aligned visual behavior, shell chrome, keyboard behavior, or iOS design-system primitives, read:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`

`PRODUCT_DESIGN_TRUTH.md` is product canon. The Apple Platform Source Atlas is an iOS implementation source map. If they conflict, product canon wins. If a specific Apple API is used, verify iOS 26 availability or provide an availability-gated fallback.

## 4. Account, R2, Source Atlas, and network law

Ambitions supports custom Ambitions Accounts at launch.

Launch authentication providers:

```text
Sign in with Apple
Google Sign-In
```

The app must remain fully usable without an account.

No account means: 100% offline core app, no hosted Ambitions account, no personal backend, no network dependency for core value, bundled/local reference packs only, and local goals, captures, closures, proof, preferences, and personalization.

Ambitions Account means optional identity, entitlement, R2 freshness/reference-pack access, account recovery/support, future paid identity layer, and future approved network features.

The Ambitions Account must not store the private life graph unless a future canon explicitly approves a user-owned sync architecture.

R2 is first-class infrastructure for Source Atlas freshness/reference packs. R2 is not a user-data backend and must never receive goals, captures, calendar data, schedule assumptions, life areas, receipts, proof, closure history, personalization data, behavior patterns, inferred priorities, private user context, or the private life graph.

Hosted AI services, external/cloud LLMs, cloud model APIs, and server-side profiling are excluded from core architecture.

---

## 5. Active authority hierarchy

Start every non-trivial repo task from the truth files.

Mandatory read order:

1. `docs/truth/README.md`
2. `docs/truth/CODEX_START_HERE.md` (routing/digest only; substantive truth files still win)
3. `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
4. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
5. `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
6. `docs/truth/PRODUCT_MOAT_TRUTH.md`
7. `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
8. `docs/truth/IMPLEMENTATION_TRUTH.md`
9. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
10. `docs/truth/RELEASE_TRUTH.md`
11. `docs/truth/CODEX_PROCESS_TRUTH.md`
12. `docs/truth/HISTORICAL_POLICY.md` (repo retention and stale-file deletion)
13. `AGENTS.md`
14. `README.md`
15. `docs/README.md`
16. `project.yml`
17. `Package.swift`
18. relevant source, tests, retained scripts, build docs, and current local logs
19. `.agents/skills/README.md` skill registry
20. relevant retained `.agents/skills/*/SKILL.md` files only after truth files and registry routing
21. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`


Historical material is not retained in-repo unless it is current, canon-aligned, and materially useful for App Store readiness. It must not override active truth.

---

## 6. Repo behavior rules

- Work on `main` only unless the user explicitly requests a branch or PR.
- Preserve XcodeGen.
- Edit `project.yml` and regenerate locally; do not treat checked-in `.xcodeproj` as source truth.

## 7. Strict Architecture Tree Enforcement

Before creating, moving, refactoring, or reviewing Ambitions source, agents must load and follow:

* `.agents/skills/README.md` for skill routing and retained-skill status
* `.agents/skills/ambitions-source-truth-authority/SKILL.md`
* `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
* `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
* `.agents/skills/ambitions-release-proof-honesty/SKILL.md` when validation, readiness, TestFlight, App Store, privacy/legal, accessibility, performance, CI, account, R2, or release claims are involved
* `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md` when implementing, reviewing, testing, or repairing Private Life Runtime behavior contracts, runtime mutations, receipts, undo/recovery, proof-ledger behavior, or runtime scenario gates

The `Final Architecture Tree` in `docs/truth/PRODUCT_DESIGN_TRUTH.md` is binding path ownership, not an approximate target.

Agents must not use:

* “equivalent”
* “roughly equivalent”
* “same concept under Features”
* “keep it where it already is”
* “temporary feature-owned implementation”
* “compatibility location”
* “parallel implementation”
* “close enough for now”

If product canon says an object belongs under `App/`, `Stage/`, `Core/`, `Projection/`, `Language/`, `Trust/`, `Interaction/`, `Rendering/`, `DesignSystem/`, `Surfaces/`, `Composer/`, `Scenarios/`, `Diagnostics/`, or `Quality/`, new or moved implementation must use that exact owner.

New backend/runtime authority belongs under `Core/LocalRuntimeOS/`. Existing `Core/Runtime/`, `Core/Persistence/`, and `Projection/Commands/` source is implementation scaffolding and migration debt when touched. The runtime mutation law is:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Do not add new command, transaction, event, projection, side-effect, storage-substrate, privacy, sync, migration, repair, or diagnostics authority outside `Core/LocalRuntimeOS/` unless a scoped issue explicitly closes Yellow with a named repair train.

`Features/` is not a canonical owner for new Ambitions architecture. Existing `Features/` code is legacy compatibility only. Any train touching `Features/` implementation must move ownership toward the final architecture tree or close Yellow with explicit architecture debt and a named repair train.

Motion belongs under `Stage/Motion/` only. Motion must not become a root surface, tab, destination, activity feed, analytics surface, score, streak, XP layer, or dashboard.

Capture belongs under `Composer/Capture/` only. Capture must not become `Surfaces/Capture/`, a tab, inbox, notes feed, generic plus surface, chatbot, or persistent root destination.

A compatibility shim is allowed only when needed to preserve compilation during migration. A shim must contain no product policy, runtime authority, projection authority, trust authority, or motion authority. It must route to the canonical owner and include a removal target in closeout.

Every source train closeout must include:

* `Final Architecture Tree` inspected: yes/no
* canonical owners touched
* files moved or created
* old/non-canonical paths removed
* compatibility shims left behind, if any
* why any Yellow architecture debt remains
* next repair train if debt remains
* confirmation that no “equivalent” folder/path interpretation was used
