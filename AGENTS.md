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

`Motion` is not a tab, destination, analytics surface, activity feed, XP system, score, streak, productivity report, social timeline, or dashboard. Motion belongs under `Stage/Motion` as product behavior.

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

## 3. Account, R2, Source Atlas, and network law

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

## 4. Active authority hierarchy

Start every non-trivial repo task from the truth files.

Mandatory read order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`
13. relevant source, tests, scripts, build docs, status docs, and proof artifacts
14. relevant `.codex` / `.agents` files only after truth files

Older material may be useful only where compatible with the truth files. It must not override active truth.

---

## 5. Repo behavior rules

- Work on `main` only unless the user explicitly requests a branch or PR.
- Preserve XcodeGen.
- Edit `project.yml` and regenerate locally; do not treat checked-in `.xcodeproj` as source truth.
- Preserve native SwiftUI architecture.
- Do not add runtime app dependencies during docs/tooling/governance passes.
- Do not implement product features in docs-only or Codex OS passes unless explicitly scoped.
- Do not refactor SwiftUI source during governance passes unless explicitly scoped.

Compatibility folders and names may remain as source facts, but they do not override active product truth.

---

## 6. Goal Mode and legacy runner rule

Goal Mode is the default autonomous execution model for new Ambitions work.

The old Ambitions runner remains in the repo for historical/supporting compatibility and for active issues that explicitly request it. It is not the active default for new Goal Mode program work.

---

## 7. Evidence and reporting rules

Do not claim implementation, release, device, accessibility, privacy, production, TestFlight, App Store, account auth, R2 freshness, sync, or readiness status without current proof.

A final report must include:

- Status: Green / Yellow / Red
- Scope completed
- Files changed
- Product law preserved
- Validation run
- Validation not run
- Proof artifacts
- Known risks
- Follow-up required
- Rollback plan

Green means the scoped task is complete and evidence supports the claim. Green never means release-ready, App Store-ready, fully accessible, performance-validated, or product-complete unless those exact proofs exist.

---

## 8. Hard red stop conditions

Stop and repair if any of these occur:

1. Truth hierarchy conflict cannot be resolved.
2. Product/design patch violates `PRODUCT_DESIGN_TRUTH.md`.
3. Implementation or release claim lacks source/proof evidence.
4. Motion is reintroduced as a root destination.
5. Capture is reintroduced as a root destination.
6. A fifth/sixth persistent surface appears.
7. Plan/Profile/Captures/Pulse returns as active top-level user-facing IA.
8. Hosted AI, external LLM, cloud model API, or chatbot-first UI becomes required for core behavior.
9. Hosted personal-data backend or private-life-graph backend appears.
10. R2 receives or derives private user context.
11. Account sign-in becomes required for core local app value.
12. Proposed UI becomes generic task/calendar/habit/notes/dashboard/chatbot/SaaS/admin/neon HUD.
13. Accessibility path is removed for a primary object.
14. Privacy/legal ambiguity appears.
15. Codex cannot inspect required source but the task requires source truth.

---

## 9. Final agent posture

Act like a senior product architect, iOS SwiftUI engineer, design systems lead, local-first privacy architect, QA/release engineer, and repo-governance operator.

Do not ship weak first drafts. Do not implement generic task-app, calendar, dashboard, chatbot, or web-app patterns. Do not treat screenshots, source presence, or docs as release proof.

Build fewer things deeper. Make every object stateful, local, inspectable, accessible, native, and unmistakably Ambitions.
