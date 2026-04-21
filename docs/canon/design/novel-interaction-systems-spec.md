# Novel Interaction Systems Spec

## Purpose

Turn the named frontend transformation inventions into explicit product systems with clear use, placement, and fallback rules.

Execution sequencing remains owned by `Ambitions_Frontend_Transformation_Execution_Classification.md`.
This file may reference execution tiers and owning batches for clarity, but it must not override that sequencing source.

## Status Legend

- `core`: required for the transformed product identity
- `secondary`: valuable and differentiated, but subordinate to core clarity
- `later-phase`: canonically approved but should land only in later frontend batches

The `status` label describes end-state product importance, not implementation order.

## Ownership Format

Each invention below includes:

- allowed surfaces
- fallback rule
- execution tier reference
- owning batch or batch band

## Living Hero Surface

- purpose: expose the dominant truth of the current surface
- value: immediate comprehension
- lives in: Today, Goals, Plan, Insights, Profile
- entry: default visible
- behavior: stable top-of-screen authored hero, not carousel
- motion: truth replacement and supporting module response
- fallback: compact summary panel when data is sparse
- execution tier: Early core
- owning batch or batch band: Batch 43 for first flagship implementation; reused across later surface batches
- status: core

## Contextual Global Compose

- purpose: unified creation and command entry
- value: fewer scattered entry points
- lives in: shell layer
- entry: persistent affordance above tab bar
- behavior: opens command hub for capture, goal, plan patch, recovery, focus, Memory Lens
- fallback: direct route buttons if shell affordance is unavailable on a platform
- execution tier: Early core
- owning batch or batch band: Batch 42
- status: core

## Shell-Aware Transitions

- purpose: preserve structure across navigation
- value: reduces disorientation
- lives in: tab changes, route pushes, external landings
- behavior: transitions express ownership and depth
- fallback: stable ownership and depth framing without matched motion
- execution tier: Early core
- owning batch or batch band: Batch 40 with reuse in later surface batches
- status: core

## Adaptive Header Rail

- purpose: give each surface a role-specific top bar without fragmenting shell identity
- allowed surfaces: all top-level tabs and major subroutes
- lives in: all top-level tabs and major subroutes
- behavior: execution, direction, shaping, reflection, or utility posture
- fallback: stable top bar with the same role semantics and reduced adaptation
- execution tier: Early core
- owning batch or batch band: Batch 40
- status: core

## Cognitive Mode Lens

- purpose: reweight content and action posture around how the user is thinking
- value: reduces density by making one mental posture dominant at a time
- lives in: shell-level weighting, header posture, primary action logic, supporting module order
- modes:
  - Focus
  - Triage
  - Shape
  - Reflect
- entry points:
  - implied by surface and state
  - explicit via Quiet Command Sheet only when useful
- cross-screen behavior:
  - Today defaults to Focus
  - Goals defaults to Triage
  - Plan defaults to Shape
  - Insights defaults to Reflect
  - Goal Detail may shift between Focus, Shape, and Reflect
- motion behavior: mode change reweights emphasis, not entire layout replacement
- fallback behavior: if lens-specific weighting is unavailable, preserve the default surface hierarchy
- anti-overcrowding rule: never show all mode choices as equal persistent chips on every top-level screen
- execution tier: Later core
- owning batch or batch band: Batches 46-59 after shell and flagship-surface stability
- status: core

## Continuity Ribbon

- purpose: carry one important continuity signal between major surfaces
- value: preserves mental state across navigation without requiring rereading
- lives in: Today, Goals, Plan, Insights, Goal Detail
- entry points:
  - appears automatically when one continuity signal materially changes decisions
- interaction behavior:
  - tap opens the owning context or deeper explanation
  - one secondary action max
- fallback behavior: compact hero-support meta line
- anti-overcrowding rule: never stack multiple ribbons
- execution tier: Later core
- owning batch or batch band: Batches 46-59 after stable shell hierarchy
- status: core

## Semantic Zoom for Goals

- purpose: let a user inspect one goal across multiple scales without hierarchy overload
- value: makes long-horizon ambition understandable on iPhone
- scales:
  - Now
  - This week
  - This phase
  - Full path
- lives in: Goals hero support, Goal Detail structural controls
- interaction behavior:
  - the same goal object persists while depth changes
  - default scale is `This week`
- motion behavior: structure compresses and expands around the active goal anchor
- fallback behavior: static phase summary plus full-path drill-down
- anti-overcrowding rule: keep the zoom control compact and near the active structural summary
- execution tier: Later core
- owning batch or batch band: Batch 45 with later Goal Detail deepening
- status: core

## Quiet Command Sheet

- purpose: premium quick-action surface for capture, open, recover, explain, correct, reschedule, and focus
- value: concentrates high-value actions without turning the app into a tool palette
- lives in: shell overlay, opened from Contextual Global Compose
- interaction behavior:
  - opens into one readable action surface
  - may include search/open path, but never as a developer palette
- motion behavior: calm upward reveal from shell
- fallback behavior: direct global compose hub with reduced option count
- anti-overcrowding rule: keep one primary interaction path visible at a time
- execution tier: Early core
- owning batch or batch band: Batch 42
- status: core

## Object-Persistent Navigation

- purpose: preserve identity continuity for the same object across surfaces
- value: reduces cognitive reset between Today, Goals, Goal Detail, Plan, Captures, and review
- lives in: navigation and motion grammar
- applies to:
  - goals
  - phases
  - blocks
  - captures
  - review objects
- interaction behavior: destination retains stable title, signal posture, and structural anchor
- fallback behavior: stable identity framing without matched motion
- execution tier: Early core
- owning batch or batch band: Batch 40 with reuse across later batches
- status: core

## Path Preview Drawer

- purpose: shallow preview of what comes next on a goal's path
- value: gives future visibility without forcing full-path inspection
- lives in: Goal Detail
- interaction behavior:
  - collapsed by default
  - expands below current strategy / phase context
- motion behavior: shallow downward or outward reveal from current path region
- fallback behavior: compact upcoming-phase summary
- anti-overcrowding rule: drawer must not compete with the next-step region for first-layer attention
- execution tier: Advanced later core
- owning batch or batch band: Batch 48
- status: secondary

## Time Aperture

- purpose: inspect room and time pressure without calendar overload
- allowed surfaces: Today and Plan
- lives in: Today and Plan
- behavior: compact expandable time view
- fallback: textual room summary when data is limited
- execution tier: Later core
- owning batch or batch band: Batch 44 and later Plan work
- status: core, phase-gated to Today II and Plan work

## Recovery Bloom

- purpose: convert drift into calm recovery
- lives in: Today first, then other recovery entry points
- behavior: offers smallest safe next move, lighter version, reschedule, protect later, accept reality
- motion: soft bloom open, not alert dialog
- fallback: inline recovery card
- execution tier: Later core
- owning batch or batch band: Batch 44 first, then reused in later recovery contexts
- status: core

### Deepened recovery rules

- prior structure remains visible but visually deprioritized
- the safer path appears before deeper explanation
- explanation remains progressive
- the UI should feel like it is reorganizing reality, not flagging a broken plan

## Trust Whisper

- purpose: first-layer trust without debug-console feel
- allowed surfaces: Today, Goal Detail, Plan, Profile
- lives in: Today, Goal Detail, Plan, Profile
- behavior: compact hint plus optional reveal
- fallback: supporting meta line when space is tight
- execution tier: Early core
- owning batch or batch band: First flagship implementation in Batches 43-45, then reused later
- status: core

## Pressure Map

- purpose: show pressure, density, feasibility, and compression without dashboard clutter
- value: makes week and goal pressure legible without charts-first composition
- lives in: Plan, Goals, and supporting Today or review contexts
- interaction behavior:
  - visible by default as calm shaped density
  - deeper inspect via scrub or tap
- fallback behavior: compact pressure summary line
- anti-overcrowding rule: no analytics heatmap language
- execution tier: Later core
- owning batch or batch band: Batches 49-50
- status: core

## Pressure Scrubber

- purpose: let users inspect pressure changes interactively
- allowed surfaces: Goals and Plan
- lives in: Goals and Plan
- behavior: scrub time or pressure dimension and update visuals immediately
- fallback: static pressure summary if interaction is not supported
- execution tier: Later core
- owning batch or batch band: Batches 49-50
- status: core

## Path Filmstrip

- purpose: make goal progress feel directional and lived
- allowed surfaces: Goal Detail
- lives in: Goal Detail
- behavior: shows phase and milestone movement through a visual rail
- fallback: stacked milestone summary
- execution tier: Later core
- owning batch or batch band: Batch 47
- status: core

## Elastic Week View

- purpose: shape a week without dense static-grid energy
- allowed surfaces: Plan
- lives in: Plan
- behavior: expands pressure regions and compresses low-signal regions
- fallback: calmer timeline-list hybrid
- execution tier: Later core
- owning batch or batch band: Batch 49
- status: core

## Strategy Composer

- purpose: premium goal setup and strategy shaping
- allowed surfaces: goal creation and major plan refinement
- lives in: goal creation and major plan refinement
- behavior: full-screen authored flow, not form dump
- fallback: simplified goal setup with the same language rules
- execution tier: Later core
- owning batch or batch band: Batch 46
- status: core

## Memory Lens

- purpose: fast recall of what changed, what was learned, and why a surface looks this way
- allowed surfaces: shell-level utility plus Goal Detail integrations
- lives in: shell-level utility plus Goal Detail integrations
- behavior: search and recall surface, not audit log
- fallback: targeted history drill-downs
- execution tier: Later core
- owning batch or batch band: Batch 56, with earlier command foundations in Batch 42
- status: core

## Horizon Ladder

- purpose: show ambition-to-today structure clearly
- allowed surfaces: Goals, Goal Detail, Strategy Composer
- lives in: Goals, Goal Detail, Strategy Composer
- behavior: scalable hierarchical representation
- fallback: compact structural summary
- execution tier: Later core
- owning batch or batch band: Batch 45 with later deepening in Goal Detail and Strategy Composer
- status: core

## Focus Screenlet

- purpose: compact focus mode for app and ambient surfaces
- allowed surfaces: in-app focus, widgets, Live Activities, Watch later
- lives in: in-app focus, widgets, Live Activities, Watch later
- behavior: minimal controls, high clarity
- fallback: simple focus card
- execution tier: Later core
- owning batch or batch band: later Today and external-surface work
- status: core

## Appearance Studio

- purpose: curated personalization without theme-playground drift
- allowed surfaces: Profile
- lives in: Profile
- behavior: preview dark, light, system, accent families, tone posture
- fallback: simpler appearance settings with same curated rules
- execution tier: Later core
- owning batch or batch band: Batch 52
- status: core

## Review Constellation

- purpose: replace analytics-heavy review composition with clustered behavioral proof
- value: makes reflection feel editorial and humane
- lives in: Insights, Weekly Review, Monthly Review
- interaction behavior:
  - clustered groups expand into proof and related context
  - supports compare and drill-down without BI-panel density
- motion behavior: clusters expand from the selected proof center
- fallback behavior: compact grouped reflection cards
- anti-overcrowding rule: compact charts support the constellation; they do not become the main composition
- execution tier: Later core
- owning batch or batch band: Batch 51 with review reuse later
- status: core

## Window Magnetism

- purpose: let open-time windows visually attract suitable work
- value: makes planning feel intelligent without becoming playful or gimmicky
- lives in: Plan
- interaction behavior:
  - suitable work suggestions dock toward viable windows
  - user can accept, inspect, or ignore
- motion behavior: subtle settling into available room
- fallback behavior: textual or chip-level "fits here" suggestion
- anti-overcrowding rule: attraction should feel suggestive, not animated spectacle
- execution tier: Advanced later core
- owning batch or batch band: Batch 50
- status: secondary

## Living Capture

- purpose: treat captures as latent thought objects with meaningful maturity states
- value: makes capture feel alive and lower-friction than inbox triage alone
- lives in: capture routes, Plan integration, goal-promotion flows
- states:
  - raw
  - warming
  - attached
  - activated
  - parked
- interaction behavior:
  - state changes are visible and understandable
  - promotion into goal or plan preserves object identity
- fallback behavior: simpler capture-state labeling without richer motion
- execution tier: Later core
- owning batch or batch band: capture and Plan ecosystem work in Batches 50 and 56
- status: core

## Intent-Sensitive Primary Action

- purpose: keep one strong action visible while adapting to the user's real state
- value: avoids multiplying controls while keeping the right action obvious
- lives in: Today, Goals, Goal Detail, Plan, Insights, Profile, Captures, Habits
- interaction behavior:
  - one stable primary-action slot
  - visible action label adapts to state
- fallback behavior: surface-default primary action
- anti-overcrowding rule: never show multiple "primary" buttons competing in the same zone
- execution tier: Early core
- owning batch or batch band: first flagship implementation in Batches 43-45, then reused later
- status: core

## Split-Pane Thinking on iPhone

- purpose: preserve context while inspecting a selected planning or path object
- value: reduces route thrash in narrow cases
- lives in:
  - Plan
  - Goal Detail
  - Weekly Review
- interaction behavior:
  - one dominant pane, one contextual pane
  - contextual pane collapses cleanly
- fallback behavior: push or sheet presentation
- anti-overcrowding rule: never use as a default phone shell layout
- execution tier: Advanced later core
- owning batch or batch band: Batch 50, with narrow Goal Detail use only after mature later-core surfaces exist
- status: later-phase

## Sync Pulse

- purpose: calm cross-device trust indication
- allowed surfaces: Profile and future device handoff points
- lives in: Profile and future device handoff points
- behavior: one-line trust posture plus deeper center
- fallback: trust meta row
- execution tier: Later core
- owning batch or batch band: Batch 52 with cross-device continuation in Batches 57-58
- status: core, but implementation-gated to later trust and cross-device work
