# Ambitions Product Decisions

Status: Active canon decision log for product-definition waves.

Purpose: Preserve explicit product decisions made after canon consolidation. This document records decisions that clarify ambiguity across product, design, onboarding, lifecycle, memory, trust, capture, plan/calendar, goals, today/now state, You/profile/settings/reviews, IA/navigation, intelligence/automation, visual system/components/motion, accessibility/focus support, external surfaces/notifications/widgets/live activities, data/local-first/sync/export, and implementation acceptance.

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

# Wave 10 — IA, Navigation, And Drilldown

Adoption date: 2026-04-27

## Resolved Decisions

Locked top-level tab structure:

```text
Today / Goals / Capture / Plan / You
```

Top-level tab policy:

```text
Keep locked five-tab shell.
Do not add more top-level tabs later without explicit canon change.
```

Feature placement:

```text
Analytics: You -> Reviews / Patterns
Habits: Plan / Today / Goal Detail as rituals
Tasks: Today + Capture + Plan + contextual Goal Detail
Life Areas: Goals + You + contextual routing
```

Main navigation principle:

```text
Fewer top-level surfaces, deeper drilldowns.
```

Breadcrumbs:

```text
Use breadcrumbs where depth can cause disorientation.
```

Grouped Navigation Lists should be used for:

```text
Settings
Trust
Memory
Reviews
Data controls
Deeper object menus
```

IA must never:

```text
Add top-level tabs casually.
Hide everything in settings.
Turn the app into dashboards.
Create duplicate homes for the same object.
```

## Implementation Implications

- Do not reintroduce top-level Insights, Habits, Tasks, Calendar, Life Areas, or Profile tabs.
- `You` replaces user-facing `Profile` as the canonical fifth tab.
- Drilldowns should support depth without widening the app.
- Every object should have a clear primary home and contextual appearances elsewhere.
- Navigation should preserve orientation, especially in deep goal/plan/trust/review flows.

---

# Wave 11 — Intelligence, Automation, And Suggestions

Adoption date: 2026-04-27

## Resolved Decisions

Ambitions intelligence should primarily:

```text
Explain, suggest, and prepare.
```

User-facing AI/model language policy:

```text
Do not expose AI/model language in normal UI.
```

Suggestions should feel like:

```text
Calm options.
```

Plan/goal changes:

```text
Ambitions should only auto-change plans/goals after user confirmation.
```

Suggestion requirements:

```text
Why this.
Evidence or assumption.
User control.
Dismiss/change option.
```

Confidence display:

```text
Qualitative only in normal UI.
Numeric/debug confidence only in debug/internal contexts.
```

Smart means:

```text
Predictive.
Personalized.
Explainable.
Correctable.
Explainable/correctable first.
```

Acting without user input:

```text
Safe local reversible actions are allowed.
External actions require confirmation.
```

Safe automation boundary:

```text
Confirm before important changes.
Safe local reversible actions allowed.
```

Intelligence must never:

```text
Hide uncertainty.
Pretend certainty.
Shame the user.
Make external changes silently.
```

## Implementation Implications

- Ambitions should not be chat-first.
- Suggestions must preserve user control.
- Important changes require confirmation.
- External actions require confirmation.
- Reversible local actions may use receipt + undo where safe.
- Suggestions should expose why they appear and how to dismiss/change them.
- Intelligence should be useful without fake certainty or scoring the user.

---

# Wave 12 — Visual System, Components, And Motion

Adoption date: 2026-04-27

## Resolved Decisions

Visual system feel:

```text
Premium calm OS.
```

Top-level screens should avoid:

```text
Equal-weight card walls.
Dense dashboards.
Long paragraphs.
Too many exposed controls.
```

Rich panels should be used for:

```text
Meaningful state, hierarchy, and context.
```

Motion should be:

```text
Subtle and meaningful.
```

Motion should communicate:

```text
Where things went.
What changed.
State transitions.
```

Celebratory effects:

```text
Rarely, for meaningful completions.
```

Component priority:

```text
Build reusable components and tokens.
```

Theme support:

```text
Light and dark mode both matter, with dark preferred if needed.
```

Visual design must never:

```text
Reduce readability.
Create fake depth.
Use decoration without meaning.
Hide primary action.
```

Visual north star:

```text
Calm intelligent life OS.
```

## Implementation Implications

- Visual beauty must support comprehension, trust, and action.
- Top-level screens should have clear hierarchy and one dominant purpose.
- Reusable components/tokens should be preferred over one-off beautiful screens.
- Motion should clarify routing, state changes, and action closure; it should not become ambience or personality theater.
- Reduce Motion must preserve equivalent clarity.
- Celebration should be reserved for meaningful completions, not ordinary task churn.

---

# Wave 13 — Accessibility And Focus Support

Adoption date: 2026-04-27

## Resolved Decisions

Accessibility means:

```text
Core product quality.
```

ADHD support user-facing name:

```text
Focus Support.
```

Focus Support should primarily:

```text
Reduce decisions and protect next action clarity.
```

Ambitions should avoid for users with attention/executive-function challenges:

```text
Card overload.
Shame language.
Unclear next action.
Dense dashboards.
```

Dynamic Type:

```text
Core requirement.
```

VoiceOver:

```text
Core requirement.
```

Color-only meaning:

```text
Never use color as the only meaning carrier.
```

Reduce Motion:

```text
Preserve meaning.
```

Focus Support must never:

```text
Infantilize.
Remove depth.
Label the user.
Turn the app into training wheels.
```

Accessibility north star:

```text
Anyone can understand what matters next.
```

## Implementation Implications

- Accessibility is not a late compliance pass.
- Focus Support should improve clarity while preserving depth.
- The app should not expose `ADHD Mode` or label the user.
- Dynamic Type and VoiceOver must be considered in core UI, not only settings.
- Visual/motion systems must preserve state meaning without relying only on color or animation.
- Focus Support should reduce decision load, not remove important capability.

---

# Wave 14 — External Surfaces, Notifications, Widgets, And Live Activities

Adoption date: 2026-04-27

## Resolved Decisions

External surfaces should primarily:

```text
Surface the right next thing safely.
```

Notification frequency:

```text
Sparse by default.
User controls later.
```

Notification tone:

```text
Calm and operational.
```

Sensitive/private details in notifications/widgets:

```text
Collapse as Private item at launch.
```

Widgets should show:

```text
Best next action / Today slice.
```

Live Activities should show:

```text
Active focus/protected block or time-sensitive plan slice.
```

App Intents / Shortcuts:

```text
Should support capture.
```

External-surface data changes:

```text
Safe local actions with receipts are allowed.
External writes require app confirmation.
```

External surfaces must never:

```text
Expose private details.
Spam user.
Show fake urgency.
Replace core app context.
```

External-surface north star:

```text
Calm continuity.
```

## Implementation Implications

- External surfaces should support continuity, not engagement loops.
- Notifications should be rare, useful, and operational.
- Widgets should not become dashboards.
- Live Activities should be reserved for active protected/focus blocks or time-sensitive plan slices.
- Capture through App Intents/Shortcuts should preserve routing, receipts, and privacy boundaries.
- Sensitive Life Area details should not appear directly on external surfaces at launch.
- External surfaces can support safe local actions where receipts exist; important or external writes require app confirmation.

---

# Wave 15 — Data, Local-First, Sync, And Export

Adoption date: 2026-04-27

## Resolved Decisions

Default data posture:

```text
Local-first.
```

Launch account requirement:

```text
No account required at launch.
```

Sync posture:

```text
No launch sync.
Sync later only after trust/export is strong.
```

Export before cloud sync:

```text
Export should exist before cloud sync.
```

Export should include:

```text
User-selectable categories.
```

Delete-all-memory affects:

```text
Memory only.
```

Data controls live under:

```text
You -> Trust Center / Data controls.
```

Sync/export claims before implementation:

```text
Do not show sync/export claims before implemented.
```

Export failure should:

```text
Explain data remains safe.
Offer retry.
Offer review export option.
```

Data trust north star:

```text
User understands what is stored, remembered, exported, and deleted.
```

## Implementation Implications

- First-run value must not depend on account, backend, cloud, or sync.
- Local-first should be treated as a trust posture and product constraint, not merely an implementation detail.
- Export/import surfaces should be truthful and only appear as available when implemented.
- Delete-all-memory must not delete goals, tasks, plans, or other app data unless the user separately chooses a broader destructive action.
- Data controls belong in You through Trust Center / Data controls, not a separate tab.
- Sync should not launch until trust, export, recovery, failure states, and user comprehension are strong enough.

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
- `docs/canon/IA_NAVIGATION_DRILLDOWN.md`
- `docs/canon/INTELLIGENCE_AUTOMATION_SUGGESTIONS.md`
- `docs/canon/VISUAL_SYSTEM_COMPONENTS_MOTION.md`
- `docs/canon/ACCESSIBILITY_FOCUS_SUPPORT.md`
- `docs/canon/EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/design/smart-attachment-spec.md`
- future batch prompts involving onboarding, IA, navigation, drilldown, breadcrumbs, tabs, Life Areas, Capture routing, Today, Now State, empty states, recovery, best next action, Goals, Goal Detail, Goal Weather, Proof, Plan, calendar-aware planning, believability, daily schedule, rituals, You, Profile migration, Settings, Reviews, Trust Center, Appearance Studio, intelligence, suggestions, automation, visual system, components, motion, accessibility, Focus Support, Dynamic Type, VoiceOver, Reduce Motion, external surfaces, notifications, widgets, Live Activities, App Intents, Shortcuts, data controls, local-first behavior, sync, export/import, delete-all-memory, receipts, sensitive Life Areas, privacy controls, Smart Attachment, Needs a Place, or Capture input behavior.
