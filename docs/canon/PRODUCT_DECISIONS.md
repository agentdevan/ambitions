# Ambitions Product Decisions

Status: Active canon decision log for product-definition waves.

Purpose: Preserve explicit product decisions made after canon consolidation. This document records decisions that clarify ambiguity across product, design, onboarding, lifecycle, memory, trust, capture, plan/calendar, goals, and implementation acceptance.

## Decision Authority

This document records resolved product decisions. It does not replace:

- `MASTER_PRODUCT_SPEC.md` for product truth
- `docs/canon/design/Ambitions_Design_Constitution.md` for design/IA/UX authority
- `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership
- `docs/canon/DOMAIN_MODEL.md` for object model detail
- `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md` for lifecycle detail
- `docs/canon/TRUST_PRIVACY_MEMORY.md` for trust/memory/privacy detail
- `docs/canon/ONBOARDING_SPEC.md` for first-run flow detail
- `docs/canon/design/smart-attachment-spec.md` for Capture / Smart Attachment routing detail

When these decisions clarify an ambiguity, future docs and batch prompts should follow them unless a later explicit canon decision supersedes them.

---

# Wave 1 — Product Identity And Life Areas

Adoption date: 2026-04-27

## Resolved Decisions

- Ambitions is user-facing as a **life organization system**.
- Internally, Ambitions is a **personal life operating system / external brain** for goals, plans, tasks, memory, and recovery.
- The primary opening feeling is: `My life feels organized`.
- The immediate proof is: `I know what matters now` and `I know the next concrete step`.
- Life Areas are inferred/recommended and correctable, not mandatory friction.
- Default Life Areas:

```text
Career
Creative
Finance
Health
Home
Relationships
Education
Personal
Admin
```

- Users can rename default Life Areas while preserving an internal canonical type.
- `North Star` is deeper-view language; top-level/new-user copy may use `long-term ambition`.
- A Goal is a meaningful outcome that may need a plan.
- User-facing standalone action language is `Task`.
- Internal/design term for a standalone task is `One-Step Goal`.
- A Task can exist without a Goal, but Ambitions should suggest attaching or promoting when useful.

## Non-Negotiable Rules

System rule:

```text
Every item has a place.
```

Execution rules:

```text
Every goal has a next step.
Every plan must be believable.
```

Emotional rule:

```text
The user never feels punished for drifting.
```

Product-shape rule:

```text
The app stays deep, not wide.
```

---

# Wave 2 — Lifecycle And State Language

Adoption date: 2026-04-27

## Resolved Decisions

- Internal state: `Dropped`.
- User-facing label for dropped goals: `No Longer Relevant`.
- `Cancelled` and `Dropped` remain internally separate, but the UI can simplify at launch.
- Intentional goal ending action: `End Goal`, then ask the reason.
- Goal pause action: `Park Goal`.
- Pause state: `Parked`.
- Goal Weather is not directly manually overridden. The user corrects inputs that affect weather.
- Internal Plan states may use stronger language:

```text
Believable
Tight
Fragile
Broken
```

- User-facing Plan labels should be softer:

```text
Believable
Tight
Needs Protection
No Longer Holds
```

- Confirmation is required for destructive actions, external writes, and major deadline changes.
- Receipt + undo should be used for reversible local actions:

```text
Mark Done
Move task
Park task
Attach task to goal
Rename Life Area
Change display density
```

- Confirmation is required for:

```text
Delete memory
Calendar write
```

- Completed goals stay visibly emphasized for 30 days by default.
- Major completed goals may remain emphasized longer depending on importance.
- Product/design language: `Completion Archive`.
- Normal UI language: `Archive`.

---

# Wave 3 — Trust, Memory, And Receipts

Adoption date: 2026-04-27

## Resolved Decisions

- Low-risk memories may be auto-created with visibility.
- Sensitive or high-impact memories should be suggested for user confirmation first.

Confirmation required:

```text
Health-related preferences
Relationship/family details
Financial goals or constraints
Location patterns
Calendar-derived patterns
Sensitive Life Area details
```

Can auto-create with receipt/visibility:

```text
Display/density preferences
Recovery preferences
Repeated task routing
```

Contextual:

```text
Work/career goals
```

- Users can pause memory learning globally and by category.
- User can mark any Life Area sensitive.

Sensitive launch behavior:

```text
Hide details in notifications/widgets
Collapse details on Today
Use generic labels like Private item
```

Later/advanced sensitive behavior:

```text
Require Face ID to open
Exclude from export by default
Keep local-only
Hide from screenshots/previews
```

Undo duration depends on action type:

```text
Quick UI actions: 5-10 seconds
Route changes / attach / move: until screen exit or review tray dismissal
Rename/display changes: 30 seconds
Destructive/external writes: confirmation first, undo only if platform-safe
```

Trust Center:

- No numerical Trust Score at launch.
- Use qualitative status sections.
- Top status: `You are in control`.

Memory naming:

- User-facing section: `What Ambitions Knows`.
- Object/type name: `Memory`.

Delete all memory:

- Allowed from Trust Center.
- Requires confirmation.
- Offer export/reminder first where export exists.
- If export is not implemented, say so plainly.
- Does not delete goals/tasks/plans unless explicitly included separately.

---

# Wave 4 — Onboarding And First-Run Flow

Adoption date: 2026-04-27

## Resolved Decisions

- Onboarding should show a static premium product preview at launch.
- Animation can come later.
- The first onboarding prompt is:

```text
What do you want to organize?
```

- First object creation should show the receipt inside the destination.

Example receipt:

```text
Saved as Goal · Creative
Next: Shape the first milestone
Change
```

- Onboarding should not ask for display density up front.
- Default display setting: `Balanced + Comfortable`.
- Display density and panel size can be adjusted later in `You`.
- Life Area should be inferred when possible.
- Life Area should be asked only when Ambitions is uncertain.
- Life Area assignment must remain correctable from the receipt.
- Notifications should not be requested during onboarding.
- Notification permission should only be requested after the user sets a reminder or protected block.
- Calendar access should not be requested during onboarding.
- Calendar access should only be requested from Plan after the user asks for calendar-aware planning.

Default onboarding examples should cover:

```text
Career
Creative
Finance
Health
Home
Relationships / Family
```

- Baby/family examples can appear later when contextually relevant.
- If the user skips onboarding, land in Today with a strong empty state and a Capture action.
- First-run success metric:

```text
User creates any useful object.
```

## Implementation Implications

- Do not optimize onboarding around finishing every setup screen.
- Do not make first-run success depend on calendar, notifications, a full plan, or a full goal hierarchy.
- First value comes from one useful object, one visible destination, one clear receipt, and one next action.
- Onboarding must prove organization before asking for permissions or preferences.

---

# Wave 5 — Capture And Smart Attachment

Adoption date: 2026-04-27

## Resolved Decisions

- The main Capture input should feel like a `Quiet Command Sheet`.
- Capture should not feel like search, chat, a generic note app, or an inbox form.
- Primary Capture placeholder:

```text
What needs a place?
```

- Onboarding keeps its separate first prompt:

```text
What do you want to organize?
```

## Route Confidence Behavior

When Ambitions is unsure where a capture belongs, behavior depends on confidence:

```text
High confidence: route + receipt
Medium confidence: route + receipt + easy Change
Low confidence: ask 1 question or save to Needs a Place
```

Temporary holding area:

```text
Needs a Place
```

## Allowed Capture Routes

Launch/core routes:

```text
Task
Goal
Idea
Proof
Waiting
Plan
```

Later/advanced routes:

```text
Contextual Note
Reminder
Ritual
Archive
Decision
```

## Notes Policy

Resolved decision:

```text
No general Notes object at launch. Allow contextual notes attached to objects.
```

Implementation implication:

- Avoid turning Ambitions into a general notes app.
- Notes should be attached to goals, tasks, proof, reviews, decisions, plans, or other meaningful objects.
- A larger notes surface can be reconsidered later after core execution is mature.

## Capture Receipt Pattern

Successful capture receipts should use the `Saved as...` / `Attached as...` pattern.

Examples:

```text
Saved as Task · Today
Saved as Goal · Creative
Saved to Needs a Place
Attached as Proof · Music Goal
```

Rules:

- Receipt should show object type, destination, and route correction where safe.
- Avoid generic `Captured`, `Routed`, or `Added to Ambitions` as primary success copy.

## Task-To-Goal Promotion

Resolved decision:

```text
Capture should suggest task-to-goal promotion; user confirms before promotion.
```

Implementation implication:

- Do not auto-promote tasks into goals.
- When a task appears to have too much structure, Ambitions can suggest `Turn Into Goal`.
- Promotion creates a receipt and preserves the original capture context.

## Voice Input

Resolved decision:

```text
Use iOS dictation first. Native voice capture can come later.
```

Implementation implication:

- Do not build a separate voice system at launch.
- Do not claim voice capture beyond platform dictation until implemented.

## Highest Capture Rule

Resolved rule stack:

```text
Nothing gets lost.
Every capture gets a clear next route.
```

Implementation implication:

- Failed saves preserve text.
- Low-confidence captures have a safe place.
- Capture should be fast, but not at the cost of losing or misplacing user intent.

---

# Wave 6 — Plan, Calendar, And Believability

Adoption date: 2026-04-27

## Resolved Decisions

Plan's core job:

```text
Shape a believable day/week.
Build the daily schedule as part of making goals executable.
```

Implementation implication:

- Plan is not a calendar clone.
- Plan is not only a due-soon list.
- Plan should make goals executable by shaping a believable day/week and constructing a usable daily schedule.

## Plan Visual / IA Direction

Resolved decision:

```text
Plan-first with optional calendar awareness.
```

Rules:

- Plan should not look like a raw calendar first.
- Calendar views can support Plan, but they do not own Plan.
- A weekly calendar view can come later if it serves believability and execution.

## Plan Main Question

Resolved main question:

```text
Can this week actually hold?
```

Supporting daily question:

```text
What daily schedule makes this hold?
```

Implementation implication:

- Weekly believability is the main Plan question.
- Daily schedule construction is an important sub-job of Plan.
- Plan should show the truth when the week cannot hold.

## Calendar-Aware Meaning

Calendar-aware means:

```text
Read calendar events.
Suggest open windows.
Compare Ambitions plan against real commitments.
Write calendar events only after explicit user confirmation.
```

Rules:

- Calendar writes require confirmation every time.
- Calendar read permission should be requested from Plan after calendar-aware value is clear.
- Calendar-derived patterns require memory confirmation before becoming memory.

## First Calendar Permission CTA

Primary CTA:

```text
Make Plan calendar-aware
```

Supporting phrase:

```text
Find real open windows
```

Avoid as primary CTA:

```text
Sync Calendar
```

## Overload Behavior

When the week is overloaded, Plan should:

```text
Suggest a lighter plan.
Ask what to protect.
```

Rules:

- Do not only show a warning.
- Do not automatically move tasks.
- Do not pretend impossible weeks are fine.
- Recovery should stay non-shaming.

## Rituals / Routines

Resolved decision:

```text
Plan includes rituals/routines, but not as a standalone Habits tab.
```

Implementation implication:

- Rituals belong in Plan, Today, Goal Detail, and You/Reviews where useful.
- Do not recreate a standalone Habits tab.

## Believability Definition

Believable means:

```text
Enough time exists.
It fits energy and context.
The user has done similar before where evidence exists.
It does not conflict with real commitments.
No fake precision.
```

Rules:

- Believability should be evidence-aware and correction-friendly.
- It should avoid exact confidence theater.
- It should show why the plan holds or does not hold.

## Plan Must Never

Plan must never:

```text
Shame the user.
Silently reschedule.
Pretend impossible weeks are fine.
Become a raw calendar clone.
```

---

# Wave 7 — Goals And Goal Detail

Adoption date: 2026-04-27

## Resolved Decisions

Goals' core job:

```text
Help the user choose and protect direction.
```

Goals top screen should prioritize:

```text
One protected / most important goal.
Goal portfolio health.
```

Supporting content below:

```text
Goal list.
Life Areas.
Recent progress.
```

## Goals Surface Direction

Resolved direction:

```text
Top-level Goals should not look like a project management board.
```

Rules:

- Deep detail may use structured milestone/step views where useful.
- Top-level Goals should not become a task board, spreadsheet, KPI dashboard, or project management surface.
- Goals should protect direction before exposing management detail.

## Goal Detail Main Questions

Primary question:

```text
What is the next visible step?
```

Secondary question:

```text
Is this goal still believable?
```

Implementation implication:

- Goal Detail should lead with next action clarity.
- Believability/risk should be visible enough to avoid false confidence.
- Task lists, progress metrics, and history should support these questions, not replace them.

## Goal Weather Meaning

Goal Weather primarily communicates:

```text
Believability / risk / clarity.
```

Rules:

- Goal Weather is not a progress percentage.
- Goal Weather is not mood.
- Goal Weather is not motivation decoration.
- Goal Weather can include deadline pressure, but it is not deadline pressure only.

## Progress Percentages

Resolved decision:

```text
Only show progress percentages when measurable and honest.
```

Rules:

- Do not show fake precision.
- Do not make percentages the primary goal health signal.
- Prefer milestone/proof/next-step clarity when the goal is not honestly quantifiable.

## Proof Definition

Proof includes:

```text
Completed step.
Artifact created.
Decision made.
Feedback received.
Blocker resolved.
Reflection / review.
```

Rules:

- Proof is evidence of real progress.
- Proof is broader than task completion.
- Proof should support trust, Goal Weather, reviews, and archive learning.

## Manual Proof

Resolved decision:

```text
Users can manually add proof, but it should attach to a goal, milestone, or step.
```

Implementation implication:

- Manual proof should not float as a disconnected object.
- Proof attachment should create a receipt where meaningful.
- Proof should remain correctable if attached to the wrong object.

## Missing Next Step

When a goal has no next step, Ambitions should:

```text
Ask the user to choose one.
Suggest one.
```

Rules:

- Do not merely warn.
- Do not hide the goal from Today solely because the next step is missing.
- Help the user restore forward motion.

## Goals Must Never Become

Goals must never become:

```text
Project management board.
Spreadsheet.
KPI dashboard.
Motivation quote wall.
```

---

# Active Follow-Up Targets

These decisions should be reflected in:

- `DOMAIN_MODEL.md`
- `GOAL_PLAN_TASK_LIFECYCLE.md`
- `ONBOARDING_SPEC.md`
- `TRUST_PRIVACY_MEMORY.md`
- `EMPTY_ERROR_RECOVERY_STATES.md`
- `IMPLEMENTATION_ACCEPTANCE_GATES.md`
- `docs/canon/CAPTURE_SMART_ATTACHMENT.md`
- `docs/canon/PLAN_CALENDAR_BELIEVABILITY.md`
- `docs/canon/GOALS_GOAL_DETAIL.md`
- `docs/canon/design/smart-attachment-spec.md`
- future batch prompts involving onboarding, Life Areas, Capture routing, Today empty states, Goals, Goal Detail, Goal Weather, Proof, Plan, calendar-aware planning, believability, daily schedule, rituals, You, Trust Center, receipts, sensitive Life Areas, notifications/widgets, export/import, privacy controls, Smart Attachment, Needs a Place, or Capture input behavior.
