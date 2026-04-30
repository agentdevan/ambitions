# Ambitions Master Product and Visual System Spec v2

Status: Active canonical product and visual direction.

Adoption date: 2026-04-29

This document supersedes conflicting active language around `Your best next move`, `next best move`, manual `Start Focus` sessions, guessed durations, free-time assumptions, vacation as free time, silent automatic reflow, stale overdue task behavior, and punitive completion language. Historical documents may keep those phrases only as clearly historical context.

## Product Thesis

Ambitions is a premium iPhone-native life operating system that uses adaptive panels, timeline rails, grounded time context, receipts, proof, and action closure to help people know where to start, take the right step, recover without shame, and trust what changed.

Ambitions should feel native, expensive, calm, intelligent, restrained, deep, trustworthy, beautiful, dynamic, and human. It must not feel like a task app, habit tracker, fake AI dashboard, SaaS analytics product, Android app, web app squeezed into iOS, calendar clone, card pile, or guilt machine.

## Locked Shell

The top-level app structure is exactly:

```text
Today / Goals / Capture / Plan / You
```

No top-level `Insights`, `Profile`, `Tasks`, `Habits`, `Calendar`, `Settings`, `AI`, or `Assistant` tab is allowed. Those concepts may exist only as drill-downs, panels, grouped rows, or system surfaces.

Tab roles:

- Today: `What matters now?` Daily decision surface.
- Goals: `Where am I headed?` Ambition portfolio.
- Capture: `What needs a place?` Intake/composer surface.
- Plan: `Does this hold together?` Believability and recovery surface.
- You: `How is my system working for me?` Personal system center.

## Language Rules

Deprecated user-facing language:

- `Your best next move`
- `next best move`
- `Start Focus`
- `Focus session`
- `Productivity score`
- `AI confidence`
- `Overdue`
- `Failed`
- `Behind`
- `Missed`

Preferred user-facing language:

- `Start here`
- `Recommended step`
- `Start now`
- `Open step`
- `Adjust plan`
- `Why this?`
- `Close the loop`
- `Needs a quick check`
- `Still Counts`
- `Rescheduled`
- `Waiting`
- `Needs Review`
- `Needs Recovery`
- `Protected`
- `Clear`
- `Tight`
- `Ready`

Use `step` for an action the user should take. Avoid `move` as a noun for a user action. The internal closure/system state `Moved` may remain where it means a scheduled occurrence was rescheduled; the preferred user-facing label is `Rescheduled`.

## Locked Product Rules

Focus is not a Today CTA. Focus, work, school, free time, recovery, and protected time appear as context states inside the Time Context Lens. Preferred CTAs are `Start now`, `Open step`, `Adjust plan`, `Review options`, and `Why this?`.

Context must be automated but grounded. Ambitions may use user-provided schedules, calendar events, protected blocks, commute/transition buffers, plan blocks, and recurring commitments, and the UI should lightly name the source.

Free time is what remains only after excluding hard context: work, school, vacation/away, calendar events, commute/buffers, protected blocks, reserved commitments, configured sleep/recovery, and configured family/household anchors. Vacation is not free time by default.

Durations must be grounded as user-set, user-accepted, suggested, historical, actual, or unset. Guessed durations must never be presented as fact.

Early completion creates an optional reflow prompt, not silent rearrangement. Reflow must be user-trusted, receipt-backed, and reversible.

## Canonical Decisions

Schedule & Availability lives under `You -> Planning Behavior` and can also appear as a non-blocking contextual prompt where schedule data would improve Today, Plan, Hero Step recommendations, or first-run trust.

Automation levels are `Manual`, `Guided`, and `Adaptive`; the default is `Guided`. Guided means Ambitions proposes and asks before changing meaningful parts of the day.

Vacation and away setup requires a per-vacation availability behavior: `Unavailable`, `Protected`, `Flexible`, or `Open`. Vacation remains unavailable by default, and the user can make a selected behavior the future default.

Cognitive fit supports both inferred and user-selected paths using lightweight labels: `Deep work`, `Creative`, `Admin`, `Light`, `Recovery-friendly`, `Errands`, `Social`, `Planning`, `Review`, and `Household`.

Action Closure receipts must be visible in Today, Trust Center, and Goal Detail. Today shows lightweight check-ins or relevant receipts; Trust Center shows receipt history, explanations, privacy, corrections, and undo/review where available; Goal Detail shows goal-related receipts in Proof, Decisions, Archive, or Receipt Trail areas.

## Time Context Hierarchy

Recommendations flow through this order:

1. Hard Context: work, school, vacation/away, calendar events, commute, setup, transition buffers, protected blocks, sleep/recovery, family/household anchors, appointments, and fixed commitments.
2. Availability Context: free time, open windows, flexible time, protected free time, unavailable, low-control time, available if needed, and open but do not fill.
3. Cognitive Context: the type of work that fits the available window.
4. Recommendation Layer: only after the first three layers should Ambitions recommend a step.

Ambitions never fills open time just because it exists.

## Canonical Component Families

The canonical product component direction is Adaptive System Panels: reusable, data-driven SwiftUI components that summarize goals, plans, proof, memory, recovery, time context, and user state.

Primary families include step/decision panels, timeline rails, progress panels, proof panels, plan health panels, capture composer, grouped navigation lists, memory panels, recovery panels, appearance controls, receipt trails, time context chips, availability panels, reflow panels, and trust/automation controls.

Canonical component names include `AppBackground`, `SurfacePanel`, `CompactContextHeader`, `HeroStepPanel`, `DayTimelineRail`, `TimeContextLens`, `DurationBadge`, `PlanHealthPanel`, `AvailabilityWindowPanel`, `EvidenceSourceChip`, `GoalPathRail`, `ProofRail`, `CaptureComposer`, `GroupedNavigationSection`, `AmbitionsNavigationRow`, `UserSystemProfilePanel`, `ReceiptTrail`, `ClosureCheckInPanel`, `ActionClosureSheet`, `ReflowOpportunityPanel`, `AutomationLevelControl`, `PlanBehaviorSettings`, `ScheduleInputPanel`, and `VacationAvailabilityControl`. Existing equivalent components may remain as compatibility adapters where they already exist.

## Screen Direction

Today must lead with compact context and `Start here`, not a huge title or Focus-session framing. It owns Time Context Lens, Hero Step Panel, Day Timeline Rail, closure check-ins, reflow opportunities, availability, and recovery.

Plan is the believability and recovery surface, not a calendar clone. It distinguishes scheduled items, hard context, availability windows, protected time, capacity, pressure, readiness, evidence labels, and recovery options.

You is the Personal System Center, not a profile card feed. It starts with a User System Profile Panel, then grouped sections for Me, Memory and Trust, Reviews and Progress, Planning Behavior, System Edges, and Accessibility and Support.

Capture stays bottom-composer-driven and is not chat UI. It intakes, suggests a route, asks for confirmation or change, and creates a receipt. It does not invent durations silently.

Goals is an Ambition Portfolio, not a task board. Goal Detail owns depth through Overview, Path, Steps, Proof, Decisions, Risks, and Archive lanes, with receipt trails where relevant.

Trust Center, What Ambitions Knows, Reviews, Appearance Studio, and Recovery Flow must stay warm, plain, grouped, receipt-backed, and non-punitive.

## Implementation Truth

This spec is canonical product/design direction. Code implementation must remain evidence-based: do not claim a surface, model, receipt path, preview, accessibility behavior, device behavior, TestFlight readiness, App Store readiness, or RC lock is implemented unless the current repo proves it.
