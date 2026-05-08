# 12 — Screen Composition Constitution

Status: active canon, docs-only.

Purpose:

- enforce one dominant primary object per top-level surface
- prevent stacked-card, dashboard, generic module, and feed drift
- define attention budgets, silhouettes, layout laws, and visual hierarchy gates
- make Ambitions feel premium, native, obvious, useful, and unforgettable

## Core Composition Law

Every top-level screen follows this attention budget at rest:

```text
Primary object: 70-80%
Context/chrome: 10-15%
Secondary proof/control: 5-10%
Everything else: drill-down
```

If a top-level surface requires more than three visible modules at rest, the composition is not flagship yet.

## Dominant Surface Silhouettes

| Surface | Dominant silhouette | What must not happen |
| --- | --- | --- |
| Today | Vertical meridian | task list / disconnected hero card |
| Goals | Atlas field | dashboard / KPI portfolio / endless modules |
| Capture | Open field + composer | notes feed / inbox / chatbot |
| Time | Capacity field | calendar grid / schedule dashboard |
| You | Grouped system profile | social profile / admin console |

A screen must remain recognizably Ambitions with labels removed. If text removal leaves a generic app shell, the visual object is not strong enough.

## Top-Level Surface Laws

1. One living object dominates each top-level surface.
2. One primary action appears when action is expected.
3. One accent system appears at rest.
4. One active proof/receipt may appear at rest.
5. One trust explanation may be open at a time.
6. Three visible modules max at rest.
7. Zero red badges.
8. Zero count badges.
9. Zero score widgets.
10. Zero decorative stars.
11. Zero generic dashboard tiles.
12. Zero stacked-card top-level compositions.

## Screen-Specific Composition

### Today

Question: What should I do now?

Composition:

- Reality Meridian owns the day shape.
- Start Here Surface emerges from the active Meridian state.
- Trust Seam explains Why this? when requested.
- Receipt Surface proves closure/reflow/action changes.
- Later/deep detail is summarized until intent.

Hard Red:

- Today looks like a task list.
- Start Here reads as a detached card.
- Today leads with many modules.
- Overdue/failed/shame language appears.

### Goals

Question: What is my life pointed at?

Composition:

- Constellation Atlas owns the overview.
- Life areas are visible without system ranking.
- Orbital Lens opens focused area detail.
- Mission Control stays inside Goal Detail.
- Goal thread to Today is visible only when useful.

Hard Red:

- Goals becomes KPI dashboard, ranked life score, habit ring surface, astrology map, or endless portfolio modules.

### Capture

Question: Where do I put this thought?

Composition:

- Atmosphere Composer owns the screen.
- Open atmospheric space reduces pressure.
- Composer is bottom-oriented and keyboard-native.
- Route reveal appears only after input/capture.
- Needs a Place is valid and safe.

Hard Red:

- Capture becomes notes feed, inbox, chat, category board, or plus-tab app.

### Time

Question: What can my life actually hold?

Composition:

- LifeShape Field owns capacity reality.
- Shape Time is the screen identity.
- Open time, goal time, protected time, and pressure are visible without calendar-clone behavior.
- Review pressure and Shape week are primary actions.
- Calendar appears only as source or detail.

Hard Red:

- Time becomes calendar clone, agenda, analytics dashboard, red-warning surface, or silent scheduler.

### You

Question: How does Ambitions work for me?

Composition:

- User System Profile owns the surface.
- Screen title is Your System.
- iOS Settings-like grouped navigation is intentional.
- Trust & Automation, Privacy, Receipts & History, Planning Setup, and Defaults are findable.
- Celestial ornament is minimal.

Hard Red:

- You becomes social profile, admin console, account hub, AI settings wall, or search-first settings clone.

## Spatial System

Default rules:

- 20pt screen edge default.
- 8/12/16/24/32 spacing rhythm.
- 44pt minimum tappable target.
- 48pt preferred primary action target.
- Primary action should be thumb-zone aware.
- Safe-area chrome must not feel cramped.
- Home indicator area needs breathing room.
- Object detail sheets use native detents and clear dismissal.

Surface scroll rules:

- Today scrolls only if Later or deep detail expands.
- Goals must not become an endless module scroll.
- Capture should barely scroll, if at all.
- Time scrolls only when review/detail expands.
- You may scroll because grouped navigation requires it.

Keyboard rules:

- Capture composer stays visible with keyboard.
- Composer and tab bar must not collide.
- Route reveal does not push input out of reach.
- Large Dynamic Type must preserve capture flow.

## Visual Hierarchy Rules

Every screen declares:

1. primary layer
2. secondary layer
3. tertiary layer
4. hidden/drill-down layer

Hierarchy laws:

- primary object must dominate at rest
- only one primary CTA
- secondary actions use quiet controls
- tertiary data moves to drill-downs or Trust Seam
- use size before color
- use position before decoration
- use motion only to explain relationships
- active state must be legible without glow
- red is reserved for destructive or system-critical errors only

## Emotional Hierarchy

Ambitions should reduce burden, not create urgency theater.

Priority:

```text
Safety/trust > recovery > current action > time pressure > goal thread > ambient beauty
```

Tone laws:

- pressure is not danger
- protected is not blocked
- waiting is not failure
- still counts is not consolation
- recovery is not punishment
- manual mode is not lesser
- no calendar access is not broken
- empty state is not failure
- source unavailable is not blame
- user drift is expected

## Composition QA Tests

### Blur Test

A blurred screenshot should still reveal the primary object silhouette.

### Five-Second Test

A user should explain the screen purpose in five seconds.

### Three-Second Identity Test

A reviewer should not identify the screen as task app, calendar, notes, dashboard, habit tracker, chatbot, SaaS admin, astrology, sci-fi HUD, or generic SwiftUI.

### One-Tap Test

When action is expected, the primary action must be visible immediately.

### Tired-User Test

A tired user should feel less burdened after opening the screen.

### Founder Test

If the founder cannot explain why an object exists or where it sits in the hierarchy, the surface is Yellow or Red.

### Ruthless Removal Test

If removing an element improves clarity and does not remove essential state, source, trust, or action, remove it.

## Drill-Down Discipline

Move these out of top-level rest states:

- analytics
- long history
- receipt archive
- full calendar detail
- dense goal lanes
- capture queues
- automation details
- privacy controls
- long explanations
- secondary reviews

Allowed top-level content must directly support the primary object, current state, primary action, trust/proof, or essential recovery.

## Required Composition Proof

Green visual/composition claims require screenshot or rendered preview evidence for:

- default state
- empty state
- active state
- recovery state
- large Dynamic Type
- Reduce Motion where motion affects relationship/state
- no-calendar/manual mode where relevant
- source-unavailable mode where relevant

Without proof, status is Yellow.
