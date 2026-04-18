# Ambitions Surgical Execution Plan

## Goal
Create the most efficient path from the current native SwiftUI Ambitions app to a true personal operating system, minimizing duplicate work and Codex usage by building reusable foundations before surfaces.

## Current State
Ambitions already has:
- native SwiftUI app structure
- Goal Engine / plan-execution-learning foundation
- SwiftData persistence
- repository-backed services
- Today / Goals / Habits / Insights / Profile surfaces
- UI tests and CI

Main gaps:
- no first-class capture system end-to-end
- no full feasibility / recovery / time orchestration engine
- no App Intents / widget / Live Activity / share extension stack completed end-to-end
- no sync boundary finalized
- no life graph / long-range path modeling / household model / runtime separation

## Core Principle
Do not build surfaces until the engine they consume is stable.

That means:
- no share extension before capture model exists
- no widgets/live activities before a canonical Now State exists
- no calendar conflict UI before time orchestration model exists
- no multi-device sync before snapshot/export and conflict policy exist
- no dedicated device prototype before runtime separation and surface-role definitions exist

## Reframed Execution Structure
Instead of feature-first phases, use foundation bundles:
1. Build hygiene + repo truth
2. Domain foundation
3. Core intelligence
4. Time orchestration
5. External action infrastructure
6. Ambient surfaces
7. Sync + trust foundation
8. Life graph + path modeling
9. Learning engine
10. Shared life
11. Runtime separation
12. Device work

## Hard Dependency Rules

### Rule 1 — Canonical Action Pipeline first
All user/system actions should execute through one command path:
- in-app buttons
- notifications
- widget interactions
- Live Activity actions
- App Intents
- share flows

No surface-specific business logic.

### Rule 2 — Canonical “Now State” before ambient UI
Create a single derived model for:
- best next step
- today posture
- pressure level
- active focus session
- open capture urgency
- blockers / waiting-on

Widgets, notifications, controls, and Live Activities should all read from this.

### Rule 3 — App Intents infrastructure before interaction-heavy surface work
App Intents should define reusable actions/entities once, then power:
- Siri / Shortcuts / Spotlight
- widget interactivity
- Live Activity buttons
- controls
- Action button / lock-screen actions

### Rule 4 — Shared container before extensions
Before widgets/share extensions/Live Activities depend on shared data, add:
- App Groups entitlement
- shared container abstraction
- extension-safe storage adapter
- deep link routing and scene resolution

### Rule 5 — Snapshot/export schema before sync
Before choosing CloudKit or anything else, create:
- versioned snapshot schema
- import/export
- conflict policy
- sync capability interface

### Rule 6 — Life graph ontology before long-range path UX
Before Career Maps, astronaut planning, education ladders, etc., define:
- domains
- roles
- milestones
- dependencies
- path branches
- support/delegation types

### Rule 7 — Runtime separation before hardware prototype
A device prototype may be concepted earlier, but the first serious engineering prototype should wait until core runtime and context services are detached from the phone app shell.

## Revised Phase Order

### Phase 0 — Build hygiene and source-of-truth cleanup
Purpose:
- remove dead path ambiguity
- lock repo truth
- stabilize CI/dev workflow

Includes:
- docs cleanup
- remove TS/Expo legacy if no longer needed
- confirm XcodeGen-only workflow
- current-state capability matrix
- acceptance test baseline

Exit:
- one source of truth
- one build pipeline
- all future prompts scoped to native app only

### Phase 1 — Domain foundation
Purpose:
Build primitives reused everywhere.

Includes:
- stable IDs across goals/steps/captures/sessions
- domain event log
- Goal Memory event schema
- Execution Modes enum
- Narrative Momentum enum
- cause-of-drift enum
- confidence model
- canonical deep link and external route model
- canonical command/action protocol

Exit:
- every future feature can attach to shared domain models instead of inventing new ones

### Phase 2 — First-class capture core
Purpose:
Make capture a core system before external intake surfaces.

Includes:
- Captures tab/inbox
- capture repository/service
- capture source types
- triage states
- turn-into-goal / attach-to-goal
- seed vault / revisit logic
- capture tests

Do NOT include yet:
- share extension
- App Intents capture
- voice capture

Exit:
- capture model is stable enough that later surfaces can target it safely

### Phase 3 — Planning engine v2
Purpose:
Strengthen the brain before adding OS-level surfaces.

Includes:
- feasibility engine
- deadline realism
- free-time-aware planning (internal model only)
- confidence-labeled recommendations
- fragility scoring
- capacity debt detection

Exit:
- the system can tell whether a plan is believable

### Phase 4 — Recovery engine
Purpose:
Build Ambitions’ defining behavior.

Includes:
- reschedule engine
- smaller-step generator
- waiting/dependency states
- cause-of-drift classification
- Goal Memory writebacks
- recovery-aware recommendation ranking

Exit:
- after delay/skip/stuck, the system produces a stable safer next move

### Phase 5 — Time orchestration foundation
Purpose:
Model time before showing time-heavy surfaces.

Includes:
- internal schedule/block model
- protected block model
- day-pressure and week-pressure computation
- calendar abstraction layer
- reminders abstraction layer
- “believability calendar” logic

Split implementation:
- 5A add-to-calendar/reminders (write-only where possible)
- 5B availability + conflict detection (full access)

Exit:
- the app understands room, pressure, and collision risk

### Phase 6 — External action infrastructure
Purpose:
Build the reusable outside-the-app action layer once.

Includes:
- AppEntity models
- AppIntent base infrastructure
- AppDependency/AppDependencyManager wiring
- shared deep link resolution
- action execution bridge
- app group/shared container abstraction
- snapshot readers for extensions

Do NOT build final widgets yet.

Exit:
- one reusable system can power Shortcuts, Spotlight, widgets, controls, and Live Activities

### Phase 7 — Ambient surfaces batch
Purpose:
Build all system surfaces off the same action and Now State foundations.

Includes:
- notifications
- widgets
- Live Activities
- controls if valuable
- lock-screen relevance
- focus session surface

Sequence inside phase:
- 7A notification foundation
- 7B widget extension + glance views
- 7C Live Activity in same widget extension
- 7D interactive widgets/controls where justified

Exit:
- ambient surfaces reuse shared models and action pipeline
- no surface has custom business logic

### Phase 8 — Ritual OS
Purpose:
Wrap the engines into repeat daily/weekly behaviors.

Includes:
- morning setup
- midday restart
- evening close
- weekly reset
- monthly course correction
- day/week thesis generation

Exit:
- return loops are coherent and engine-backed, not screen-backed

### Phase 9 — Sync and trust foundation
Purpose:
Prepare multi-device durability without overcommitting too early.

Includes:
- versioned snapshot schema
- import/export
- conflict policy
- SyncCapability abstraction
- LocalOnlySync default
- backend selection interface

Recommended decision:
- if near-term scope is Apple-only: CloudKit via SwiftData is fastest
- if endgame includes non-Apple dedicated hardware: do not let CloudKit become the only truth layer

Exit:
- sync can be added without rewriting the app model

### Phase 10 — Life graph foundation
Purpose:
Move from project planning to life structure.

Includes:
- domains
- roles
- obligations
- long-range milestones
- dependencies
- branch paths
- support/delegation objects

Exit:
- long-range paths can be modeled without ad hoc feature code

### Phase 11 — Path systems
Purpose:
Ship the compelling life-planning layer.

Includes:
- Career Maps
- education paths
- credential ladders
- application windows
- alternative branches
- milestone dependency visualizations

Exit:
- goals like “be an astronaut” can become structured trajectories

### Phase 12 — Learning and anticipation
Purpose:
Make Ambitions truly personalized.

Includes:
- energy-fit learning
- focus-window learning
- recommendation ranking by historical fit
- contradiction engine
- underrepresented-goal detection
- counterfactual planning
- “why now?” explanations

Exit:
- recommendations feel historically earned

### Phase 13 — Shared life / household
Purpose:
Add humane personal collaboration after solo truth is mature.

Includes:
- shared goals
- delegated work
- partner/home planning
- household logistics
- permission model for shared memory

Exit:
- collaboration feels personal, not workplace-like

### Phase 14 — Runtime separation
Purpose:
Detach Ambitions from the phone shell.

Includes:
- runtime services layer
- context service
- memory service
- capture service
- orchestration service
- voice runtime boundary
- local cache + remote intelligence boundary

Exit:
- the phone app is one client of Ambitions, not the whole product

### Phase 15 — Device concept and engineering prototype
Purpose:
Only now build the dedicated surface.

Includes:
- surface role validation
- narrow use-case device thesis
- ritual/glance/voice interactions
- secure session model
- fallback to phone for deep edit

Exit:
- clear reason the device exists
- clear reason it is not just a worse phone

## Framework Reuse Map

### Bundle A — SwiftData + domain services
Use for:
- capture core
- Goal Memory
- event log
- planning engine
- recovery engine
- sync snapshot/export
- life graph

Group these prompts together because they all change:
- models
- repositories
- services
- tests

### Bundle B — EventKit
Use for:
- add to calendar
- reminders
- conflict detection
- pressure scoring from real calendar data

Split permissions work:
- write-only event creation first
- full calendar access only when reading conflicts is needed

### Bundle C — App Intents
Use for:
- capture shortcuts
- focus controls
- open specific goals/plans
- widget interactivity
- Live Activity buttons
- controls / Action button

This should be built once and reused everywhere.

### Bundle D — WidgetKit + ActivityKit + SwiftUI glance views
Use for:
- widgets
- Live Activities
- controls
- glanceable shared views

Build these together because:
- they share extension targets
- they share glanceable design constraints
- Live Activities live in a widget extension

### Bundle E — App Groups + extension-safe storage
Use for:
- widget data
- share extension capture
- extension runtime access
- shared snapshots

### Bundle F — CloudKit / sync layer
Use for:
- multi-device sync
- conflict resolution
- durable personal brain layer

Build only after snapshot/export and sync interface exist.

## Codex Efficiency Rules

1. Every prompt should target one bundle, not one flashy feature.
2. Every prompt should name reusable artifacts first.
3. Every prompt should forbid surface-specific duplicate logic.
4. Every prompt should specify exact files/modules touched.
5. Every prompt should require tests before UI polish.
6. Every extension/surface prompt should consume existing services, never create hidden logic islands.
7. Never build notifications/widgets/controls against unstable recommendation models.
8. Never start sync implementation until snapshot/export passes round-trip tests.
9. Never start dedicated-device coding until runtime separation exists.

## Best Codex Batching Strategy

### Batch 1 — Cleanup and foundation
- Phase 0
- Phase 1
- Phase 2

### Batch 2 — Intelligence core
- Phase 3
- Phase 4
- Phase 5

### Batch 3 — External action platform
- Phase 6
- Phase 7
- Phase 8

### Batch 4 — Trust and scale
- Phase 9
- Phase 10
- Phase 11

### Batch 5 — Platform separation
- Phase 12
- Phase 13
- Phase 14
- Phase 15

## What I would change from the prior roadmap
- Move full ambient surface work later, after the recommendation/time engines are stronger.
- Split time orchestration into write-only creation first, conflict-reading second.
- Build App Intents infrastructure before final interactive widgets/controls.
- Treat sync as a boundary-first problem, not a backend-first problem.
- Move serious device engineering after runtime separation.

## Final Recommendation
The most efficient path is:
- clean repo truth
- stabilize domain primitives
- make capture real
- make planning truthful
- make recovery excellent
- make time orchestration real
- build reusable external action infrastructure
- then light up ambient surfaces
- then sync
- then life graph and learning
- then shared life
- then runtime separation
- then hardware

That order minimizes rework, keeps Codex prompts modular, and ensures every surface is powered by a mature engine instead of pushing unfinished logic upward into UI and extensions.
