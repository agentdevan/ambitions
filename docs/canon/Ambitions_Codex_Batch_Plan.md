# Ambitions Codex Batch Plan

## How to use this plan

Use **three layers of context**, not one giant prompt every time.

### Layer 1 — persistent repo context
Keep an `AGENTS.md` file in the repo root. Put in it:
- project mission
- source-of-truth directories
- build/test commands
- coding conventions
- what not to touch
- current execution rule: do not skip ahead, do not add future-facing UI before the required engine exists
- branch / commit / PR expectations

### Layer 2 — master roadmap context
Keep the following docs in the repo and reference them when needed:
- `MASTER_PRODUCT_SPEC.md`
- `Ambitions_OS_Master_Roadmap.md`
- `Ambitions_Surgical_Execution_Plan.md`
- this `Ambitions_Codex_Batch_Plan.md`

Do **not** paste all of them into every Codex task.

### Layer 3 — per-batch task prompt
For each Codex task, send only:
- the current batch goal
- the dependency rules
- exact files/folders in scope
- acceptance criteria
- explicit out-of-scope items
- required validation commands

That keeps prompts small and avoids wasting rate on re-explaining the whole product.

---

## Operating rules for Codex

1. **One batch at a time.** Never ask Codex to do Batch N+1 while Batch N is still unstable.
2. **Ask mode first for larger work.** Get an implementation plan before code changes.
3. **Code mode second.** Only after the plan matches the batch below.
4. **No cross-batch freelancing.** Codex must not opportunistically add later-phase features.
5. **Patch existing architecture.** Reuse service/repository/navigation patterns already in the repo.
6. **No UI for engines that do not exist yet.** Views should trail stable domain/service work.
7. **No new logic islands.** Shared logic must live in reusable services/domain modules.
8. **Tests are part of the batch.** A batch is not done without the required tests.
9. **Keep PRs reviewable.** Prefer 1 batch = 1 PR, occasionally split into 2 PRs when the batch has a foundation and a UI follow-up.
10. **Do not reprompt the entire product thesis each time.** Reference docs; only send the active slice.

---

## The correct execution order

### Batch 0 — Repo truth and guardrails
**Goal:** make the repo and docs tell the truth, remove stale runtime assumptions, and lock in native-only execution.

**Why first:** prevents all future tasks from inheriting stale assumptions.

**In scope**
- README cleanup
- docs index cleanup
- runtime truth alignment
- remove legacy TS/Expo/runtime artifacts if already approved
- verify XcodeGen + test pipeline is the source of truth

**Depends on:** nothing

**Enables:** every later batch

**Do not do yet**
- new product features
- engine work
- capture surfaces
- widgets/intents/sync

**Acceptance criteria**
- docs and Profile/runtime copy are truthful
- no stale legacy runtime references remain
- XcodeGen build/test path is documented and green

---

### Batch 1 — Domain foundation pass
**Goal:** stabilize the reusable domain primitives before new features expand.

**Build**
- audit and normalize shared domain models
- add version-safe event/history model where needed
- establish canonical IDs, timestamps, status/state enums
- create clear service boundaries for capture, planning, recovery, orchestration, sync

**Depends on:** Batch 0

**Enables:** capture, planning v2, recovery, sync

**Do not do yet**
- heavy UI changes
- App Intents
- widgets
- calendar reads
- sync backend

**Acceptance criteria**
- shared types are explicit and stable
- no feature service owns data it should not own
- service boundaries are clear enough for later extension work

---

### Batch 2 — First-class capture core
**Goal:** make capture a stable product pillar inside the app.

**Build**
- `CaptureSourceType` expansion
- capture repository/service finalization
- Captures inbox/tab
- capture states and transitions
- turn capture into goal / attach to goal
- routing to captures inbox

**Depends on:** Batch 1

**Enables:** share extension, App Intent capture, memory graph intake

**Do not do yet**
- share extension
- voice capture
- App Intent capture
- automated triage beyond minimal stable rules

**Acceptance criteria**
- captures are persisted and browsable
- captures can be triaged without hacks
- capture actions reuse app service patterns cleanly

---

### Batch 3 — Planning engine v2
**Goal:** strengthen the canonical “what should happen next?” logic before ambient surfaces exist.

**Build**
- confidence-labeled planning
- feasibility scoring
- pacing / effort posture rules
- fragility / pressure markers
- canonical next-step derivation rules
- richer planning outputs where needed

**Depends on:** Batch 1

**Enables:** recovery engine, notifications, widgets, time orchestration

**Do not do yet**
- widgets
- Live Activities
- interactive notifications
- aggressive learning systems

**Acceptance criteria**
- app can derive one stable, explainable next move
- planning outputs expose confidence and risk, not just action text

---

### Batch 4 — Recovery engine
**Goal:** make Ambitions adapt after missed, delayed, or blocked work.

**Build**
- `RescheduleEngine`
- smaller-step fallback logic
- waiting / dependency-aware states
- recovery mode transitions
- feedback-to-plan patching
- narrative momentum / execution mode scaffolding if low-risk

**Depends on:** Batch 3

**Enables:** ambient next-step surfaces, schedule-aware orchestration

**Do not do yet**
- calendar conflict reading
- widgets/Live Activities
- household/shared planning

**Acceptance criteria**
- delay/skip/stuck actions produce deterministic plan updates
- repeated drift results in calmer, smaller, believable next actions

---

### Batch 5 — Time orchestration foundation (write paths)
**Goal:** connect Ambitions to time carefully, without overreaching permissions too early.

**Build**
- EventKit service boundary
- add-to-calendar
- add-reminder
- create-only time actions where possible
- permission strings and authorization plumbing

**Depends on:** Batch 3

**Enables:** appointment prep, time blocking, conflict-aware planning

**Do not do yet**
- full availability scanning
- conflict forecasting
- day-pressure analytics

**Acceptance criteria**
- a selected step can become a calendar event/reminder
- EventKit is behind mocks and service protocols

---

### Batch 6 — Time orchestration intelligence (read paths)
**Goal:** make plans reality-aware using real schedule context.

**Build**
- calendar read/full access path if approved
- conflict detection
- available-window search
- day pressure / week pressure derivation
- protected block suggestions

**Depends on:** Batch 5, Batch 4

**Enables:** believable scheduling, pressure-aware next-step logic

**Do not do yet**
- widgets/Live Activities unless the derived outputs are stable
- sync

**Acceptance criteria**
- system can reject or warn on impossible time suggestions
- plan selection can factor in real schedule pressure

---

### Batch 7 — External action infrastructure
**Goal:** build one command system reused by app, intents, widgets, notifications, and activities.

**Build**
- App Intent strategy
- intent-safe command execution layer
- app dependency wiring for extensions/intents
- canonical deep-link / route mapping
- canonical “Now State” snapshot model

**Depends on:** Batch 2, Batch 3, Batch 4

**Enables:** widgets, Live Activities, interactive notifications, controls, share extension follow-ups

**Do not do yet**
- full widget polish
- share extension UI
- device runtime

**Acceptance criteria**
- one reusable action pipeline exists
- one reusable snapshot exists for ambient surfaces

---

### Batch 8 — Ambient surfaces bundle
**Goal:** expose stable state outside the app without creating new business logic.

**Build as one grouped framework bundle**
- App Groups / shared container
- widget extension
- glanceable shared views
- Live Activity layouts
- interactive widget/activity actions via App Intents
- notification categories/actions if not already present

**Depends on:** Batch 7, Batch 3, Batch 4

**Enables:** ambient Ambitions behavior all day

**Do not do yet**
- overdesigned visual variants
- experimental controls if not clearly valuable
- household/shared surfaces

**Acceptance criteria**
- all ambient surfaces read from the same canonical snapshot/action layer
- no surface-specific business logic exists

---

### Batch 9 — Ritual OS
**Goal:** own repeat usage loops once the ambient and recovery layers are real.

**Build**
- morning setup
- midday restart
- evening close
- weekly reset
- monthly review scaffolding
- narrative posture summaries

**Depends on:** Batch 4, Batch 6, Batch 8

**Enables:** retention and deeper personal operating behavior

**Do not do yet**
- advanced life graph or household features

**Acceptance criteria**
- rituals are powered by existing engines, not hard-coded flows
- each ritual produces useful state changes or review outputs

---

### Batch 10 — Sync/trust foundation
**Goal:** make memory portable and multi-device safe before choosing a forever backend.

**Build**
- versioned snapshot/export format
- import path
- `SyncCapability` boundary
- local-only default
- conflict policy
- migration hooks

**Depends on:** Batch 1

**Enables:** CloudKit adapter, future non-Apple runtime, dedicated device

**Do not do yet**
- backend-specific assumptions spread through app code
- device engineering

**Acceptance criteria**
- all core user state can round-trip through export/import
- sync remains optional and isolated behind an adapter boundary

---

### Batch 11 — Apple-first sync adapter (optional but efficient)
**Goal:** get practical cross-device value without collapsing the architecture into one provider.

**Build**
- CloudKit/iCloud-backed sync adapter if chosen
- background sync hooks
- device trust UI
- sync status reporting

**Depends on:** Batch 10

**Enables:** real multi-device Ambitions on Apple platforms

**Do not do yet**
- assume CloudKit is the final forever solution for all devices

**Acceptance criteria**
- sync can be swapped or disabled without breaking core app behavior

---

### Batch 12 — Life graph foundation
**Goal:** model the person’s life structure, not just goals/tasks.

**Build**
- life domains
- roles
- long-range path objects
- milestone/dependency structures
- domain-specific metadata

**Depends on:** Batch 10

**Enables:** career maps, education planning, household support, deeper intelligence

**Do not do yet**
- fancy AI narration on top of weak structures

**Acceptance criteria**
- nontrivial multi-year goals can be represented structurally

---

### Batch 13 — Path systems
**Goal:** make long-horizon plans first-class.

**Build**
- career maps
- education/certification paths
- alternative branches
- contingency path logic
- support/delegation planning hooks

**Depends on:** Batch 12, Batch 3

**Enables:** “astronaut path” class experiences

**Do not do yet**
- hardware-specific experiences

**Acceptance criteria**
- the app can represent and guide a long, branching life trajectory

---

### Batch 14 — Learning and anticipation
**Goal:** make Ambitions feel intensely personal and historically informed.

**Build**
- Goal Memory
- energy pattern learning
- focus-window learning
- procrastination / drift trigger detection
- recommendation ranking by success likelihood
- “why now?” explanation system

**Depends on:** Batch 3, Batch 4, Batch 6, Batch 12

**Enables:** true external-brain behavior

**Do not do yet**
- black-box behavior the user cannot understand

**Acceptance criteria**
- recommendations are traceable to observed history and explicit user structure

---

### Batch 15 — Shared life / household intelligence
**Goal:** expand from solo operating system to supported shared-life planning.

**Build**
- support goals
- delegated work objects
- partner/shared coordination primitives
- household logistics surfaces

**Depends on:** Batch 12, Batch 14

**Enables:** family and relationship-scale planning

**Do not do yet**
- enterprise/team product drift

**Acceptance criteria**
- shared-life features still feel personal, calm, and consumer-native

---

### Batch 16 — Runtime separation
**Goal:** separate Ambitions intelligence from the iPhone shell.

**Build**
- platform runtime boundaries
- memory service
- context service
- orchestration service
- client/surface abstraction

**Depends on:** Batch 10, Batch 12, Batch 14

**Enables:** dedicated device prototyping

**Do not do yet**
- general consumer hardware launch work

**Acceptance criteria**
- iPhone app is one client of the Ambitions system, not the whole system

---

### Batch 17 — Dedicated device prototype
**Goal:** test the smallest viable non-phone Ambitions surface.

**Build**
- one narrow device thesis only
- likely desk/home/bedside companion first
- voice + glance + ritual interactions
- deliberately constrained capability set

**Depends on:** Batch 16

**Acceptance criteria**
- prototype validates a new surface advantage, not just novelty

---

## Shared framework bundles

These should be prompted as grouped work because they reuse the same technical foundation.

### Bundle 1 — SwiftData + domain services
Use for:
- capture core
- recovery engine
- Goal Memory
- event log/history
- sync snapshot
- life graph

### Bundle 2 — EventKit
Use for:
- add-to-calendar
- reminders
- conflict detection
- available windows
- pressure derivation

### Bundle 3 — App Intents
Use for:
- command execution bridge
- quick capture
- start focus
- open goal / open captures
- widget actions
- Live Activity actions

### Bundle 4 — WidgetKit + ActivityKit + shared glance UI
Use for:
- widgets
- Live Activities
- shared compact UI views
- ambient snapshot rendering

### Bundle 5 — App Groups/shared container
Use for:
- widget/share-extension data access
- extension-safe snapshots
- local cross-process state sharing

### Bundle 6 — Sync
Use for:
- export/import
- sync boundary
- CloudKit adapter if chosen
- conflict policy

---

## The exact answer to “whole plan or paced?”

### Do **not** send the whole plan in every Codex prompt.
That wastes context and rate, and encourages Codex to skip ahead.

### Do keep the whole plan available in-repo.
That preserves direction and lets Codex reference it when needed.

### Do send work at the pace of the batches.
That is the safest and most efficient path.

Recommended workflow:
1. Keep the full roadmap docs in the repo.
2. Keep `AGENTS.md` updated.
3. For each batch, first ask Codex to review the codebase and produce a plan **only for that batch**.
4. Compare the plan to this document.
5. Then issue the code task for that batch only.
6. Review/test/merge before starting the next batch.

---

## Batch prompt template

```text
You are working in the Ambitions repo.

Follow the repo's AGENTS.md and the current roadmap docs, but only implement the active batch below. Do not skip ahead. Do not opportunistically add later-phase features. Reuse existing architecture patterns.

ACTIVE BATCH: [name]

BATCH GOAL:
[one paragraph]

IN SCOPE:
- [item]
- [item]
- [item]

OUT OF SCOPE:
- [item]
- [item]
- [item]

DEPENDENCY RULES:
- Use existing repository/service/navigation patterns.
- Do not add UI that depends on engines not yet implemented.
- Shared business logic must live in reusable domain/services, not in surfaces.

FILES / AREAS TO TOUCH:
- [paths]

REQUIRED VALIDATION:
- xcodegen generate
- [build/test commands]

DELIVERABLES:
- implementation
- tests
- concise change summary

First, inspect the codebase and provide a brief implementation plan for this batch only. Do not code until the plan is complete.
```

---

## What you should ask me to do next

Ask for the **Batch 0 prompt** first, then proceed one batch at a time.
