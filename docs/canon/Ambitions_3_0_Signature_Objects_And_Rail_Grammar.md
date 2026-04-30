# Ambitions 3.0 — Signature Objects And Rail Grammar

Status: Active Ambitions 3.0 visual and IA canon contract  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Ambitions 3.0 should feel coherent because each top-level surface has one dominant signature object and the app shares a restrained visual grammar.

This contract prevents equal-weight card walls, duplicate dashboards, decorative rails, and generic app chrome.

---

## Signature Object Rule

Every top-level tab has exactly one dominant signature object.

A supporting panel may appear only if it clarifies, controls, or routes deeper from that signature object.

Top-level screens should never become equal-weight card stacks.

---

## Canonical Signature Objects By Tab

| Tab | Signature object | Primary question | Must not become |
|---|---|---|---|
| Today | `AmbitionsDayRailView` | What should I do now, what changed, and what counted? | Task list, calendar clone, dashboard, focus timer |
| Goals | `AmbitionPortfolioView` + Goal Detail `MissionControlView` | Where am I headed and what is next? | Project board, KPI dashboard, motivation wall |
| Capture | `CaptureComposer` | What needs a place? | Chat box, notes app, inbox graveyard |
| Plan | `PlanShapeView` with Day / Week / Month scopes | Does this hold together? | Raw calendar, schedule generator, due-date list |
| You | `PersonalSystemCenterView` | What does Ambitions know and how do I control it? | Junk drawer, social profile, analytics dashboard |

---

## Premium Density Cap

Top-level screens should avoid more than:

- 1 signature object
- 1 primary action zone
- 1 contextual status strip
- 1 supporting section
- 1 optional recovery/trust/proof prompt

Additional depth belongs in drill-downs.

---

## Rail / Node Visual Grammar

Rails represent connected progression, navigation, or proof.

Allowed rail types:

- Vertical execution rail: Today Day Rail
- Bottom navigation rail: Ambition Meridian
- Goal path rail: Goal Detail Path
- Proof rail: Goal Detail / Reviews
- Plan shape rail: Month / Life Shape only if it clarifies pressure/arcs

Node meanings:

- filled circle: active / selected
- hollow circle: upcoming / inactive
- diamond: closure / decision
- document/receipt mark: proof / receipt
- muted node: protected / waiting / unavailable
- aperture/star: Capture only

---

## Rail Overuse Rule

Do not use rails everywhere.

A rail is allowed only when it represents:

- sequence
- progression
- navigation
- proof over time
- relationship between states

Do not use rails as decoration.

---

## Day Rail / Meridian Relationship

The Ambition Meridian Shell and Ambitions Day Rail share visual grammar but never duplicate ownership.

- Meridian owns global navigation and lightweight global context.
- Day Rail owns Today execution, Now / Next / Later, closure, proof, and the recommended step.
- Meridian may reflect active step, closure needed, or receipt saved state.
- Meridian must not become a second Today rail, task list, status dashboard, or action-control strip.
- Day Rail must not become global navigation.

---

## Day Rail Above-the-Fold Ownership

On Today, the Day Rail owns the first meaningful viewport.

Allowed above or attached to the rail:

- Compact Today context header
- Day Rail hero recommended step
- Now / Next / Later rows
- one closure prompt when needed
- one proof summary when relevant

Not allowed above the rail:

- separate dashboard cards
- separate task lists
- separate focus panels
- separate plan-health panels
- analytics panels
- motivational quote cards

---

## Rail Density Failsafe

If a rail would render more than:

- 1 Start here card
- 3 Today rows
- 1 closure prompt
- 1 proof summary

then extra objects must route to Plan, Step Detail, Full Day, or Review rather than expanding Today.

---

## Meridian Navigation Safety Rule

The Meridian is allowed only if it remains as obvious as a native iOS tab bar.

It must pass:

- every destination reachable in one tap
- VoiceOver names every destination plainly
- selected state is obvious
- Capture is obvious without becoming a giant plus button
- the user can still understand there are five top-level destinations
- navigation is never hidden behind status context

---

## Meridian Rollout Rule

The first Meridian implementation should support feature-flag or debug fallback to the native tab bar until navigation, accessibility, and deep-link behavior are verified.

The Meridian may become default only after:

- top-level navigation UI tests pass
- VoiceOver traversal passes
- Dynamic Type remains usable
- deep routes preserve orientation
- no destination becomes less discoverable

---

## Accessibility Rules

Every rail-based component must provide a non-visual reading order.

Required:

- section label
- current item
- item state
- duration/source if shown
- connected goal/ambition if shown
- available action
- explanation route

Rail position and node shape must not be the only way to understand state.

---

## Acceptance Criteria

This contract is satisfied when:

- every top-level tab has one dominant signature object
- top-level screens avoid equal-weight card stacks
- rails are used only for meaningful sequence/progression/navigation/proof
- Day Rail and Meridian share grammar without duplicating ownership
- rail components remain accessible without visual interpretation
- signature objects preserve the five-tab shell and Golden Launch Loop
