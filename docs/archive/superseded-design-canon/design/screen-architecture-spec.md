> Superseded document.
>
> This file is preserved for historical context only.
> Active canon now lives in:
> - `docs/canon/design/Ambitions_Design_Constitution.md`
> - `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md`
> - `docs/canon/Ambitions_2_0_Roadmap.md`
> - `docs/canon/Ambitions_2_0_Batch_Plan.md`
>
> Do not use this file as implementation source of truth.

# Screen Architecture Spec

Historical/superseded note: This file is preserved pre-Batch-61 frontend transformation context. Active Ambitions 2.0 screen truth now lives in [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md) and [screen-contract-matrix.md](screen-contract-matrix.md). If this file references Insights, Profile, Habits, Captures, or older shell behavior as primary surfaces, treat those references as historical unless explicitly reaffirmed by the Design Constitution.

## Purpose

Define exact intended structure, emphasis, disclosure, and interaction posture for every major transformed frontend surface.

## Global Screen Rules

- Every major screen has one hero zone.
- Every major screen exposes one primary action cluster.
- The first screenful must answer "what matters here" without scrolling.
- Every top-level screen must resolve its dominant surface question before any secondary module competes for attention.
- Supporting modules must be ordered by decision value, not by data type.
- Trust must be visible but lightweight by default.
- Each major surface may expose one intent-sensitive primary action only.
- Cognitive Mode Lens weighting may reorder emphasis, but it must not multiply visible controls.

## Top-Level Surface Questions

- `Today`: What matters now?
- `Goals`: Where am I headed?
- `Plan`: How does this week hold together?
- `Insights`: What am I learning?
- `Profile / Trust`: How is my system configured?

These are canonical question anchors for top-level composition and disclosure order.

## Mobile Provenance

On mobile, provenance should be carried through:

- `Origin Chip`
- `Context Ribbon`
- `Return Stack Memory`

These patterns communicate source and continuity without falling back to desktop-style breadcrumb chains.

## Shared Layer Systems

### Continuity Ribbon

- optional, appears only when there is one continuity signal worth carrying across surfaces
- sits below the header rail or at the top of hero support content
- never stacks

### Intent-Sensitive Primary Action

- every major surface gets one primary action slot
- the visible verb may change based on user state
- the slot itself stays stable so the screen does not feel reconfigured

### Cognitive Mode Lens

- `Focus`: emphasizes immediate action and suppresses secondary modules
- `Triage`: emphasizes sorting, deciding, attaching, or choosing
- `Shape`: emphasizes planning, tradeoffs, and future structure
- `Reflect`: emphasizes proof, patterns, and quieter comparison

## Today

### Role

Daily command surface and product home base.

### Hero zone

`Living Hero Surface`

Must show, in this order:

1. dominant day truth
2. current best next move
3. state of the day: stable, tight, drifted, overloaded, recovering

### Supporting zones

1. `Continuity Ribbon`, when active
2. `Now block`
3. `Next block`
4. `Open time / room block`
5. `Momentum strip`
6. `Fixed commitments summary`
7. `Optional lower-priority supporting modules`

### Default density

- low density
- no more than three strong modules before the fold
- no stacked dashboard of equal cards

### Core actions

- complete
- start focus
- defer
- split
- reschedule
- protect later
- open goal detail
- open plan

### Intent-sensitive primary action

- stable day: `Start focus` or `Complete next`
- tight day: `Protect this block`
- drifted day: `Recover calmly`
- overloaded day: `Lighten today`
- no-plan day: `Build today`

### Disclosure levels

- first layer: now, next, room, best action
- second layer: fixed commitments, momentum, supporting context
- third layer: trust whisper, recovery detail, history of what changed

### Trust surfaces

- whisper chip on hero
- optional "why this" inline reveal
- full reasoning sheet only on demand

### Editing surfaces

- inline lightweight action chips for fast day changes
- sheet for reschedule and protect
- full-screen focus experience for start focus

### State variants

- stable day
- tight day
- drifted day
- overloaded day
- recovery day
- low-data day
- no-plan day

### Motion behavior

- hero updates animate like a truth replacement, not card reload
- completing work produces closure motion downward or inward
- defer and reschedule move items laterally or backward in time-oriented motion

### Cognitive weighting

- Focus: hero, now, next, and primary action dominate
- Triage: capture and unfinished decisions gain emphasis
- Shape: room and open-time treatment moves upward
- Reflect: momentum and what-changed summaries become more visible

### Novel systems used

- Living Hero Surface
- Recovery Bloom
- Time Aperture
- Trust Whisper
- Focus Screenlet entry
- Continuity Ribbon
- Intent-Sensitive Primary Action

## Goals

### Role

Direction board, not inventory list.

### Hero zone

Direction hero showing:

1. active ambition pressure
2. neglected or at-risk goal signal
3. visible direction posture for the week

### Supporting zones

1. `Active goals band`
2. `At-risk / crowded goals band`
3. `Recent movement band`
4. `Dormant or lower-priority goals disclosure`
5. `Continuity Ribbon`, when the app needs to carry live urgency from Today or Plan

### Module order

- hero
- active direction
- at-risk or crowded
- recent movement
- lower-priority disclosure

### Core actions

- open goal detail
- create goal
- refine strategy
- inspect pressure
- filter by ambition or posture

### Intent-sensitive primary action

- low ambiguity: `Open most urgent goal`
- high neglected-pressure state: `Recover this goal`
- strategy mismatch state: `Refine strategy`
- empty or low-goal state: `Create goal`

### Disclosure

- active goals visible by default
- archived, completed, and low-signal goals hidden behind disclosure

### Trust surfaces

- visible confidence / pace signal per card
- pressure scrubber access
- lightweight "why at risk" affordance

### Motion behavior

- card reordering should explain changing relevance
- opening a goal should preserve spatial continuity into Goal Detail

### Semantic Zoom

Goals supports four scales:

1. `Now`
2. `This week`
3. `This phase`
4. `Full path`

Rules:

- default scale is `This week`
- zoom control lives in hero support or header rail, never as a large segmented burden
- moving between scales should preserve the same goal objects and only change structural depth
- zooming out must compress detail rather than duplicate hierarchy labels

### Cognitive weighting

- Triage: active vs neglected sorting dominates
- Shape: phase and full-path structures dominate
- Reflect: recent movement and direction drift become more visible

### Novel systems used

- Living Hero Surface
- Horizon Ladder
- Pressure Scrubber
- Semantic Zoom for Goals
- Continuity Ribbon
- Intent-Sensitive Primary Action

## Goal Detail

### Role

Strategic chamber for one goal.

### Hero zone

Goal identity and current strategic posture:

1. goal title
2. ambition context
3. phase / pace / confidence summary
4. immediate movement truth

### Supporting zones

1. `Path Filmstrip`
2. `What matters next`
3. `Current phase / milestone composition`
4. `Recent movement`
5. `Path Preview Drawer` entry
6. `Trust and reasoning access`
7. `History and memory access`

### Default density

- medium density
- deeper than top-level screens but still editorial

### Core actions

- complete next step
- adjust plan
- teach / correct
- inspect reasoning
- open source audit
- open history / what changed

### Intent-sensitive primary action

- actionable goal: `Do next step`
- pressure mismatch: `Refine strategy`
- blocked goal: `Recover path`
- stale or unclear goal: `Clarify truth`

### Disclosure

- first layer: strategy and movement
- second layer: timeline, history, details
- third layer: audit, contradiction, freshness, assumptions

### Trust surfaces

- Trust Whisper summary inline
- reasoning sheet
- contradiction review
- source audit

### Motion behavior

- filmstrip movement should feel directional
- correction confirmations should feel precise and calming
- semantic zoom and path preview should preserve the active phase anchor

### Path Preview Drawer

- shallow future-path inspection surface
- reveals what comes after the current phase without leaving Goal Detail
- default state is collapsed
- expands from below the phase / movement region
- must not try to replace the full-path view

### Cognitive weighting

- Focus: next step and immediate movement dominate
- Shape: phase structure, path preview, and strategy composition dominate
- Reflect: recent movement, history, and trust explanations gain emphasis

### Novel systems used

- Path Filmstrip
- Trust Whisper
- Memory Lens
- Path Preview Drawer
- Object-Persistent Navigation
- Intent-Sensitive Primary Action

## Plan

### Role

Weekly shaping workspace.

### Hero zone

Week posture hero showing:

1. whether the week is believable
2. room vs overload
3. strongest tradeoff or pressure area

### Supporting zones

1. `Elastic Week View`
2. `Open windows and protected time`
3. `Week-shaping actions`
4. `Habits inside week structure`
5. `Captures entering the week`
6. `Weekly review access`
7. `Continuity Ribbon`, when a goal or week posture needs cross-surface carry-through

### Core actions

- patch week
- protect block
- lighten week
- move or reschedule
- inspect pressure
- open review

### Intent-sensitive primary action

- believable week: `Shape this week`
- overloaded week: `Lighten week`
- open window selected: `Use this room`
- carryover-heavy week: `Resolve carryover`

### Density

- medium density
- compress static time regions
- expand pressured regions

### Disclosure

- week summary and shape first
- detailed block editing second
- review detail and rationale third

### Trust surfaces

- visible explanation of why the week feels tight, light, or overloaded
- pressure scrubber
- calmer rationale under major changes

### Pressure Map

- pressure is shown through density, compression, tonal pressure cues, and constrained labels
- no dashboard heat map
- the map must let the user see:
  - where time is tight
  - where room remains
  - where feasibility is fragile

### Window Magnetism

- open windows can visually attract suitable work suggestions
- attraction is expressed through proximity, suggestion docking, and soft emphasis
- never use playful snapping or game-like magnet effects
- if the engine lacks confidence, the window stays neutral rather than making a weak suggestion

### Split-pane thinking

- allowed only when shaping a selected block or open-time window while keeping the week visible
- secondary pane must remain compact and collapsible

### Motion behavior

- week compression and expansion must convey room and pressure
- moved items animate with time semantics, not list semantics
- object persistence should make the same block feel continuous between Plan, Today, and review

### Cognitive weighting

- Shape: week posture, pressure map, and shaping actions dominate
- Triage: captures and unresolved blocks move upward
- Reflect: carryover and review summaries gain emphasis

### Novel systems used

- Elastic Week View
- Pressure Scrubber
- Pressure Map
- Window Magnetism
- Continuity Ribbon
- Intent-Sensitive Primary Action

## Captures

### Role

Fast intake and triage route that feels absorbed into the operating system.

### Structure

1. triage hero or compact summary
2. continuity ribbon if a capture is actively changing another surface
3. active capture queue
4. promoted / attached recents
5. deferred seed vault disclosure

### Living Capture states

- `raw`
- `warming`
- `attached`
- `activated`
- `parked`

Rules:

- raw: newly captured, minimal interpretation
- warming: gaining shape or awaiting a likely destination
- attached: linked to an existing goal or week context
- activated: now part of active execution or shaping
- parked: intentionally held without pressure

### Core actions

- turn into goal
- attach to goal
- schedule into week
- archive
- keep as seed

### Intent-sensitive primary action

- raw capture: `Triage this`
- warming capture: `Give this a home`
- attached capture: `Open linked context`
- activated capture: `Use now`
- parked capture: `Revisit later`

### Trust posture

- source and freshness visible but not dominant

### Cognitive weighting

- Triage is the default lens
- Shape becomes active when promoting into Plan or Goal creation

### Novel systems used

- Living Capture
- Quiet Command Sheet
- Intent-Sensitive Primary Action

## Habits

### Role

Support structure for week shape and momentum, not a separate streak game.

### Structure

1. current week relevance summary
2. active habits
3. lighter / optional habits disclosure
4. habit history entry

### Core actions

- mark done
- protect in week
- reduce or pause
- inspect pattern

### Intent-sensitive primary action

- active day: `Do now`
- overfull week: `Protect or lighten`
- reflective context: `Inspect pattern`

## Insights

### Role

Narrative reflection layer.

### Hero zone

One editorial reflection summary:

1. momentum truth
2. drift or stability truth
3. strongest trend worth noticing

### Supporting zones

1. `Review Constellation`
2. `Activity history entry`
3. `Review summaries`
4. `Compare period interactions`
5. `Compact chart support only where it clarifies`

### Density

- low-to-medium
- no BI-panel clutter

### Core actions

- inspect period
- open history
- compare time ranges
- open related goal or plan state

### Intent-sensitive primary action

- recent drift: `Review what changed`
- stable progress: `See proof`
- reflection gap: `Compare periods`

### Novel systems used

- Living Hero Surface
- Review Constellation
- Continuity Ribbon
- Intent-Sensitive Primary Action

## Profile

### Role

Calm utility layer and trust center.

### Hero zone

Identity, appearance, and trust summary:

1. appearance state
2. sync or local-first trust state
3. notification / integration health

### Supporting zones

1. `Appearance Studio`
2. `Trust Center`
3. `Defaults and behaviors`
4. `Notifications and integrations`
5. `Account and billing`

### Core actions

- change theme
- inspect trust state
- manage notifications
- inspect integrations

### Intent-sensitive primary action

- trust warning: `Review trust status`
- appearance interest: `Customize appearance`
- notification issue: `Fix notifications`

### Novel systems used

- Appearance Studio
- Sync Pulse

## Weekly Review

### Role

Structured weekly closure and next-week shaping entry.

### Structure

1. week summary hero
2. completed vs carried forward
3. friction and overload reflection
4. next-week posture setup
5. optional split-pane carry-forward view when shaping next week

## Monthly Review

### Role

Longer-horizon reflection and strategy reset.

### Structure

1. month narrative summary
2. goal pace and direction
3. recurring blockers and wins
4. next-month posture
5. constellation view of clustered proof

## Activity History

### Role

Behavioral proof and trustworthy timeline.

### Structure

1. period filter
2. vertically ordered events
3. event chips and annotations
4. drill-down entry into related goal, plan, or correction

### Object continuity rule

- history objects must visibly connect back to their owning goal, plan block, capture, or correction context

## State Behavior Rules

### Empty states

- must still communicate the surface role
- must offer one next step
- must never feel like placeholder UI

### Loading states

- preserve structure and hierarchy
- avoid spinner-only full-screen emptiness unless blocking

### Error states

- state what failed
- state what still exists locally if relevant
- offer retry or safe fallback

### Re-entry states

- highlight what changed since last use
- highlight the one safest next move
