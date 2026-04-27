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

# External Surface Spec

Historical/superseded note: This file is preserved pre-Batch-61 frontend transformation context. Active Ambitions 2.0 external-surface truth now lives in [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md) and [external-surfaces-contract.md](external-surfaces-contract.md). If this file conflicts with the active constitution, the constitution wins.

## Purpose

Define explicit future design truth for widgets, Live Activities, notifications, App Intents and shortcuts posture, share extension, and lock-screen or glance surfaces.

External surfaces consume the continuity, sync-trust, handoff, return, and degraded-sync contract in [../Ambitions_State_Continuity_Mesh.md](../Ambitions_State_Continuity_Mesh.md).

## Shared Rules

- external surfaces inherit the same truth model as the main app
- external surfaces inherit State Continuity Mesh semantics and must not create separate continuity or sync-trust models
- they must feel useful at glance depth
- they must not invent parallel business logic
- every external action must land in a canonical in-app route

## Widgets

### Families

- small: one truth, one action
- medium: hero truth plus one supporting row
- large: hero truth plus supporting context and two actions max

### Content priorities

- Today next move
- focus state
- week pressure
- goal momentum

### Actions

- open canonical route
- start focus
- complete quick action if intent-safe

## Live Activities

### Role

Ambient focus and active execution continuity.

### Content

- focus target
- remaining time or block posture
- pause / complete / return actions where allowed

### Tone

- compact
- calm
- not gamified

## Notifications

### Types

- recovery prompt
- focus reminder
- review prompt
- trust or stale-context notice only when meaningful

### Content rules

- one clear action
- one clear reason
- no nagging copy

## App Intents and App Shortcuts

### Posture

- feel like fast entry into the Ambitions OS
- expose high-value actions only

### Core shortcuts

- quick capture
- start focus
- open today
- open week
- quick recovery
- open goal

## Share Extension

### Role

Fast intake from outside the app.

### Behavior

- capture content
- allow fast classification
- route into canonical capture or goal creation flow

### Rules

- no standalone share-only logic island
- preserve source context visibly

## Lock Screen and Glance Surfaces

- prioritize confirmation, next move, and trust posture
- never overfill with dense detail
- continuity with shell landing is mandatory
