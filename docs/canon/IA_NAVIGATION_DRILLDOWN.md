# Ambitions IA, Navigation, And Drilldown

Status: Active canon consolidation layer.

Purpose: Consolidate top-level IA, navigation ownership, feature placement, drilldown behavior, breadcrumbs, grouped navigation lists, and anti-dashboard rules into one implementation-readable reference. This document reflects Wave 10 product decisions.

## Locked Top-Level Shell

The locked top-level tab structure is:

```text
Today / Goals / Capture / Plan / You
```

Rules:

- Keep the five-tab shell locked.
- Do not add more top-level tabs later without explicit canon change.
- Do not reintroduce top-level Insights, Habits, Tasks, Calendar, Life Areas, or Profile tabs.
- `You` is the canonical fifth tab; `Profile` is legacy compatibility terminology during migration only.

## Main Navigation Principle

Main principle:

```text
Fewer top-level surfaces, deeper drilldowns.
```

Rules:

- Ambitions should stay deep, not wide.
- New capabilities should prefer drilldowns, contextual placements, and shared systems over new tabs.
- The top level should remain visually calm and immediately understandable.
- Deep views must preserve orientation and avoid making the user feel lost.

## Feature Placement

Analytics:

```text
You -> Reviews / Patterns
```

Habits:

```text
Plan / Today / Goal Detail as rituals
```

Tasks:

```text
Today + Capture + Plan + contextual Goal Detail
```

Life Areas:

```text
Goals + You + contextual routing
```

Rules:

- Analytics should not become a top-level Insights tab.
- Habits should not become a standalone Habits tab; use rituals/routines where useful.
- Tasks should not become a top-level Tasks tab.
- Life Areas should not become a top-level Life Areas tab.
- Calendar should not become a top-level Calendar tab; Plan owns calendar-aware planning.

## Primary Homes And Contextual Appearances

Every object should have a clear primary home and may appear contextually elsewhere.

Examples:

| Object / capability | Primary home | Contextual appearances |
| --- | --- | --- |
| Best Next Action | Today | Plan, Goal Detail |
| Goal | Goals | Today, Plan, Reviews, You |
| Task | Today / Capture | Plan, Goal Detail, Reviews |
| Life Area | Goals / You | Capture routing, Reviews |
| Ritual | Plan | Today, Goal Detail, You/Reviews |
| Memory | You -> What Ambitions Knows | Trust Center, Reviews |
| Receipt | Trust layer / You | Capture, Plan, Goal Detail, Today |
| Analytics / Patterns | You -> Reviews / Patterns | Goal Detail, Plan, Today when actionable |
| Calendar-aware planning | Plan | Today when relevant |

Rules:

- Contextual appearance is not the same as duplicate ownership.
- Do not create duplicate homes for the same object.
- If an object appears in multiple places, one surface must remain the clear owner.

## Drilldown Behavior

Drilldowns are how Ambitions stays deep without adding tabs.

Good drilldowns:

- deepen context without widening the app
- preserve where the user came from
- reveal detail progressively
- keep the next useful action visible
- make object ownership clear

Poor drilldowns:

- hide everything in settings
- bury core actions
- create confusing parallel paths
- make the user lose their place
- turn every object into a dashboard

## Breadcrumbs And Orientation

Breadcrumb rule:

```text
Use breadcrumbs where depth can cause disorientation.
```

Rules:

- Breadcrumbs are not required on every shallow screen.
- Use them in deep goal, path, plan, review, trust, memory, archive, or object-management flows where the back stack alone may be unclear.
- Breadcrumbs should show meaningful hierarchy, not technical route names.
- Breadcrumbs should be compact and visually quiet.

Examples:

```text
Goals > Music Goal > Proof
Plan > This Week > Open Windows
You > Trust Center > What Ambitions Knows
```

## Grouped Navigation Lists

Grouped Navigation Lists should be used for:

```text
Settings
Trust
Memory
Reviews
Data controls
Deeper object menus
```

Official pattern:

```text
Grouped Navigation List
```

Visual descriptor:

```text
Settings-style grouped list
```

Rules:

- Use clear row labels and concise supporting descriptions.
- Rows may use chevrons for drilldown.
- Sections should be organized by user intent.
- Do not use grouped lists for everything.
- Do not let grouped lists become junk drawers.

## Dashboard Boundary

Ambitions should avoid dashboard-first IA.

Rules:

- Today is not an analytics dashboard.
- Goals is not a KPI dashboard.
- Plan is not a raw calendar dashboard.
- You is not a generic dashboard of everything.
- Reviews/Patterns may summarize behavior, but should lead to action or correction.

## IA Must Never

IA must never:

```text
Add top-level tabs casually.
Hide everything in settings.
Turn the app into dashboards.
Create duplicate homes for the same object.
```

Additional red flags:

- New feature appears in multiple places with no clear owner.
- Surface names drift from canonical tab names.
- `Profile` returns as user-facing naming.
- Deep views lack orientation despite multiple levels.
- A settings page becomes the only place to use an important product feature.

## QA Acceptance Criteria

IA/navigation is acceptable when:

- Top-level shell is Today / Goals / Capture / Plan / You.
- No new top-level tabs are introduced without canon change.
- Analytics live in You -> Reviews / Patterns.
- Habits live as rituals in Plan / Today / Goal Detail.
- Tasks live in Today + Capture + Plan + contextual Goal Detail.
- Life Areas live in Goals + You + contextual routing.
- Navigation follows fewer top-level surfaces, deeper drilldowns.
- Breadcrumbs appear where depth could cause disorientation.
- Grouped Navigation Lists are used for settings, trust, memory, reviews, data controls, and deeper object menus.
- IA does not add tabs casually, hide everything in settings, turn into dashboards, or create duplicate homes for the same object.

## Open Questions For Future Waves

- Which exact deep routes require breadcrumbs in v1?
- Should object detail screens use a consistent route header pattern?
- Should Capture have a command-sheet route from every tab?
- Should deep object menus use grouped navigation lists or rich action sheets?
- How should search/global command work without becoming the primary IA?
