# Ambitions Product Decisions

Status: Active canon decision log for product-definition waves.

Purpose: Preserve explicit product decisions made after canon consolidation. This document records decisions that clarify ambiguity across product, design, onboarding, lifecycle, memory, trust, capture, plan/calendar, goals, today/now state, You/profile/settings/reviews, and implementation acceptance.

## Decision Authority

This document records resolved product decisions. It does not replace:

- `MASTER_PRODUCT_SPEC.md` for product truth.
- `docs/canon/design/Ambitions_Design_Constitution.md` for design/IA/UX authority.
- `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership.
- `docs/canon/DOMAIN_MODEL.md` for object model detail.
- `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md` for lifecycle detail.
- focused consolidation docs under `docs/canon/` for implementation-readable detail.

When these decisions clarify ambiguity, future docs and batch prompts should follow them unless a later explicit canon decision supersedes them.

---

# Wave 1 — Product Identity And Life Areas

Adoption date: 2026-04-27

## Resolved Decisions

- User-facing category: `Life organization system`.
- Internal ambition: `Personal life operating system / external brain`.
- Primary opening feeling: `My life feels organized`.
- Immediate proof: `I know what matters now` and `I know the next concrete step`.
- Life Areas are inferred/recommended and correctable, not mandatory friction.
- Default Life Areas: Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin.
- Users can rename default Life Areas while preserving internal canonical type.
- `North Star` is deeper-view language; top-level/new-user copy may use `long-term ambition`.
- Goal = meaningful outcome that may need a plan.
- User-facing standalone action language: `Task`.
- Internal/design term for standalone task: `One-Step Goal`.
- A Task can exist without a Goal, but Ambitions should suggest attaching/promoting when useful.

## Non-Negotiable Rules

```text
Every item has a place.
Every goal has a next step.
Every plan must be believable.
The user never feels punished for drifting.
The app stays deep, not wide.
```

---

# Wave 2 — Lifecycle And State Language

Adoption date: 2026-04-27

## Resolved Decisions

- Internal state: `Dropped`.
- User-facing label for dropped goals: `No Longer Relevant`.
- `Cancelled` and `Dropped` remain internally separate, but launch UI can simplify.
- Intentional goal ending action: `End Goal`, then ask reason.
- Goal pause action: `Park Goal`; state: `Parked`.
- Goal Weather is corrected through inputs, not direct manual override.
- Internal Plan states: Believable, Tight, Fragile, Broken.
- User-facing Plan labels: Believable, Tight, Needs Protection, No Longer Holds.
- Confirmation required for destructive actions, external writes, and major deadline changes.
- Receipt + undo preferred for Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, Change display density.
- Confirmation required for Delete memory and Calendar write.
- Completed goals stay visibly emphasized for 30 days by default; major goals may remain emphasized longer.
- Product/design language: `Completion Archive`.
- Normal UI language: `Archive`.

---

# Wave 3 — Trust, Memory, And Receipts

Adoption date: 2026-04-27

## Resolved Decisions

- Low-risk memories may be auto-created with visibility.
- Sensitive/high-impact memories should be suggested for confirmation first.
- Confirmation required for health-related preferences, relationship/family details, financial goals/constraints, location patterns, calendar-derived patterns, and sensitive Life Area details.
- Display/density preferences, recovery preferences, and repeated task routing can auto-create with receipt/visibility.
- Work/career goals are contextual.
- Users can pause memory learning globally and by category.
- User can mark any Life Area sensitive.
- Sensitive launch behavior: hide details in notifications/widgets, collapse details on Today, use generic labels like `Private item`.
- Advanced sensitive behavior later: Face ID, export exclusion, local-only enforcement, screenshot hiding.
- Undo duration depends on action type:
  - Quick UI actions: 5-10 seconds.
  - Route changes / attach / move: until screen exit or review tray dismissal.
  - Rename/display changes: 30 seconds.
  - Destructive/external writes: confirmation first, undo only if platform-safe.
- No numerical Trust Score at launch; use qualitative status sections.
- Trust Center top status: `You are in control`.
- User-facing memory section: `What Ambitions Knows`.
- Object/type name: `Memory`.
- Delete all memory is allowed from Trust Center, requires confirmation, offers export/reminder first where export exists, and does not delete goals/tasks/plans unless explicitly included separately.

---

# Wave 4 — Onboarding And First-Run Flow

Adoption date: 2026-04-27

## Resolved Decisions

- Static premium product preview at launch; animation can come later.
- First onboarding prompt: `What do you want to organize?`
- First object creation shows receipt inside the destination.
- Do not ask for display density during onboarding.
- Default display setting: `Balanced + Comfortable`.
- Display density/panel size can be adjusted later in You.
- Life Area is inferred when possible and asked only when Ambitions is uncertain.
- Life Area assignment remains correctable from the receipt.
- Notifications are requested only after reminder/protected-block value.
- Calendar access is requested only from Plan after calendar-aware planning action.
- Default examples cover Career, Creative, Finance, Health, Home, Relationships / Family.
- Baby/family examples can appear later when contextually relevant.
- If onboarding is skipped, land in Today with strong empty state and Capture action.
- First-run success metric: user creates any useful object.

---

# Wave 5 — Capture And Smart Attachment

Adoption date: 2026-04-27

## Resolved Decisions

- Capture input feel: `Quiet Command Sheet`.
- Capture should not feel like search, chat, generic notes, or inbox form.
- Capture placeholder: `What needs a place?`
- Onboarding prompt remains: `What do you want to organize?`
- Confidence behavior:
  - High confidence: route + receipt.
  - Medium confidence: route + receipt + easy Change.
  - Low confidence: ask 1 question or save to Needs a Place.
- Temporary holding area: `Needs a Place`.
- Launch/core capture routes: Task, Goal, Idea, Proof, Waiting, Plan.
- Later/advanced routes: Contextual Note, Reminder, Ritual, Archive, Decision.
- No general Notes object at launch; contextual notes only, attached to meaningful objects.
- Successful capture receipts use `Saved as...` / `Attached as...` pattern.
- Task-to-goal promotion is suggested and user-confirmed, not automatic.
- Voice input uses iOS dictation first; native voice capture can come later.
- Highest rules: `Nothing gets lost` and `Every capture gets a clear next route`.

---

# Wave 6 — Plan, Calendar, And Believability

Adoption date: 2026-04-27

## Resolved Decisions

- Plan core job: shape a believable day/week and build the daily schedule as part of making goals executable.
- Plan direction: plan-first with optional calendar awareness.
- Plan main question: `Can this week actually hold?`
- Supporting daily question: `What daily schedule makes this hold?`
- Calendar-aware means: read calendar events, suggest open windows, compare Ambitions plan against real commitments, and write calendar events only after explicit confirmation.
- Calendar writes are never automatic and require confirmation every time.
- First calendar CTA: `Make Plan calendar-aware`; supporting phrase: `Find real open windows`.
- Overload behavior: suggest a lighter plan and ask what to protect.
- Rituals/routines belong in Plan but not as a standalone Habits tab.
- Believable means enough time exists, it fits energy/context, user has done similar before where evidence exists, it does not conflict with real commitments, and no fake precision is used.
- Plan must never shame, silently reschedule, pretend impossible weeks are fine, or become a raw calendar clone.

---

# Wave 7 — Goals And Goal Detail

Adoption date: 2026-04-27

## Resolved Decisions

- Goals core job: help the user choose and protect direction.
- Goals top screen priority: one protected / most important goal and goal portfolio health.
- Supporting content: goal list, Life Areas, recent progress.
- Top-level Goals should not look like a project management board; deep detail may use structured milestone/step views.
- Goal Detail primary question: `What is the next visible step?`
- Goal Detail secondary question: `Is this goal still believable?`
- Goal Weather communicates believability / risk / clarity.
- Progress percentages appear only when measurable and honest.
- Proof includes completed step, artifact created, decision made, feedback received, blocker resolved, and reflection/review.
- Manual proof is allowed but should attach to a goal, milestone, or step.
- When a goal has no next step, Ambitions should ask the user to choose one and suggest one.
- Goals must never become a project management board, spreadsheet, KPI dashboard, or motivation quote wall.

---

# Wave 8 — Today And Now State

Adoption date: 2026-04-27

## Resolved Decisions

- Today core job: help the user know what matters now.
- Today prioritizes one best next action first.
- Full daily schedule appears below the main next action.
- When the day breaks, Today should offer recovery and ask what to protect.
- Main recovery action: `Save the Day`.
- Today includes rituals/routines only if relevant now.
- Sensitive/private items collapse as `Private item` at launch.
- Empty Today: Capture Something is primary; goal suggestion is secondary.
- Now State means best current execution context.
- Now State is not only current task, time of day, user mood, or calendar status.
- Today must never become a task dump, calendar clone, analytics dashboard, or motivation quote wall.

---

# Wave 9 — You, Profile, Settings, And Reviews

Adoption date: 2026-04-27

## Resolved Decisions

- You core job: `Personal system center`.
- You contains settings, trust, memory, reviews, and personalization.
- You may show analytics only as Reviews/Patterns, not dashboard analytics.
- Reviews primarily turn what happened into what should happen next.
- Main You top status: `You are in control`.
- Settings should use the official pattern: `Grouped Navigation List`.
- Visual descriptor: `Settings-style grouped list`.
- Naming direction: canonical naming should move fully to `You`; `Profile` should be treated as legacy compatibility terminology during migration only.
- Export/import belongs in You when implemented, surfaced through Trust Center / Data controls.
- Appearance Studio belongs in You.
- You must never become a junk drawer, analytics dashboard, generic settings page, or social profile.

## Implementation Implications

- New user-facing copy should say `You`, not `Profile`.
- New docs should use `You` as canonical surface language.
- Existing code paths named `Profile` should be migrated deliberately to `You` where safe.
- Temporary compatibility shims may remain during migration only when needed to avoid breaking the app.
- Product, design, and future batch prompts should avoid introducing new `Profile` terminology except to reference legacy code.

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
- `docs/canon/TODAY_NOW_STATE.md`
- `docs/canon/YOU_PROFILE_REVIEWS.md`
- `docs/canon/design/smart-attachment-spec.md`
- future batch prompts involving onboarding, Life Areas, Capture routing, Today, Now State, empty states, recovery, best next action, Goals, Goal Detail, Goal Weather, Proof, Plan, calendar-aware planning, believability, daily schedule, rituals, You, Profile migration, Settings, Reviews, Trust Center, Appearance Studio, receipts, sensitive Life Areas, notifications/widgets, export/import, privacy controls, Smart Attachment, Needs a Place, or Capture input behavior.
