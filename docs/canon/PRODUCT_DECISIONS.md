# Ambitions Product Decisions

Status: Active canon decision log for product-definition waves.

Purpose: Preserve explicit product decisions made after canon consolidation. Focused docs under `docs/canon/` carry implementation-readable detail. This file records the resolved decision ledger.

## Decision Authority

This document records resolved product decisions. It does not replace:

- `MASTER_PRODUCT_SPEC.md` for product truth.
- `docs/canon/design/Ambitions_Design_Constitution.md` for design/IA/UX authority.
- `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership.
- `docs/canon/DOMAIN_MODEL.md` for object model detail.
- focused consolidation docs under `docs/canon/` for implementation-readable detail.

When these decisions clarify ambiguity, future docs and batch prompts should follow them unless a later explicit canon decision supersedes them.

---

# Wave 1 — Product Identity And Life Areas

Adoption date: 2026-04-27

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

Non-negotiable rules:

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

- Internal state: `Dropped`.
- User-facing label for dropped goals: `No Longer Relevant`.
- `Cancelled` and `Dropped` remain internally separate, but launch UI can simplify.
- Intentional goal ending action: `End Goal`, then ask reason.
- Goal pause action: `Park Goal`; state: `Parked`.
- Goal Weather is corrected through inputs, not direct manual override.
- Internal Plan states: Believable, Tight, Fragile, Broken.
- User-facing Plan labels: Believable, Tight, Needs Protection, No Longer Holds.
- Confirmation required for destructive actions, external writes, and major deadline changes.
- Receipt + undo preferred for reversible local actions such as Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density.
- Confirmation required for Delete memory and Calendar write.
- Completed goals stay visibly emphasized for 30 days by default; major goals may remain emphasized longer.
- Product/design language: `Completion Archive`; normal UI language: `Archive`.

---

# Wave 3 — Trust, Memory, And Receipts

Adoption date: 2026-04-27

- Low-risk memories may be auto-created with visibility.
- Sensitive/high-impact memories should be suggested for confirmation first.
- Confirmation required for health-related preferences, relationship/family details, financial goals/constraints, location patterns, calendar-derived patterns, and sensitive Life Area details.
- Display/density preferences, recovery preferences, and repeated task routing can auto-create with receipt/visibility.
- Users can pause memory learning globally and by category.
- User can mark any Life Area sensitive.
- Sensitive launch behavior: hide details in notifications/widgets, collapse details on Today, use generic labels like `Private item`.
- Advanced sensitive behavior later: Face ID, export exclusion, local-only enforcement, screenshot hiding.
- No numerical Trust Score at launch; use qualitative status sections.
- Trust Center top status: `You are in control`.
- User-facing memory section: `What Ambitions Knows`.
- Object/type name: `Memory`.
- Delete all memory is allowed from Trust Center, requires confirmation, offers export/reminder first where export exists, and does not delete goals/tasks/plans unless explicitly included separately.

---

# Wave 4 — Onboarding And First-Run Flow

Adoption date: 2026-04-27

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

- Capture input feel: `Quiet Command Sheet`.
- Capture should not feel like search, chat, generic notes, or inbox form.
- Capture placeholder: `What needs a place?`
- Onboarding prompt remains: `What do you want to organize?`
- Confidence behavior: high = route + receipt; medium = route + receipt + easy Change; low = ask 1 question or save to Needs a Place.
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

- You core job: `Personal system center`.
- You contains settings, trust, memory, reviews, and personalization.
- You may show analytics only as Reviews/Patterns, not dashboard analytics.
- Reviews primarily turn what happened into what should happen next.
- Main You top status: `You are in control`.
- Settings should use the official pattern: `Grouped Navigation List`.
- Visual descriptor: `Settings-style grouped list`.
- Canonical naming should move fully to `You`; `Profile` is legacy compatibility terminology during migration only.
- Export/import belongs in You when implemented, surfaced through Trust Center / Data controls.
- Appearance Studio belongs in You.
- You must never become a junk drawer, analytics dashboard, generic settings page, or social profile.

---

# Wave 10 — IA, Navigation, And Drilldown

Adoption date: 2026-04-27

- Locked top-level tabs: Today / Goals / Capture / Plan / You.
- Keep locked five-tab shell; do not add more top-level tabs later without explicit canon change.
- Analytics: You -> Reviews / Patterns.
- Habits: Plan / Today / Goal Detail as rituals.
- Tasks: Today + Capture + Plan + contextual Goal Detail.
- Life Areas: Goals + You + contextual routing.
- Main navigation principle: fewer top-level surfaces, deeper drilldowns.
- Breadcrumbs: use where depth can cause disorientation.
- Grouped Navigation Lists: settings, trust, memory, reviews, data controls, deeper object menus.
- IA must never add top-level tabs casually, hide everything in settings, turn the app into dashboards, or create duplicate homes for the same object.

---

# Wave 11 — Intelligence, Automation, And Suggestions

Adoption date: 2026-04-27

- Ambitions intelligence should primarily explain, suggest, and prepare.
- Do not expose AI/model language in normal UI.
- Suggestions should feel like calm options.
- Ambitions should only auto-change plans/goals after user confirmation when important.
- Suggestions must include Why this, evidence or assumption, user control, and dismiss/change option.
- Confidence is qualitative only in normal UI; numeric/debug confidence only in debug/internal contexts.
- Smart means predictive, personalized, explainable, correctable, with explainable/correctable first.
- Safe local reversible actions are allowed; external actions require confirmation.
- Safe automation boundary: confirm before important changes; safe local reversible actions allowed.
- Intelligence must never hide uncertainty, pretend certainty, shame the user, or make external changes silently.

---

# Wave 12 — Visual System, Components, And Motion

Adoption date: 2026-04-27

- Visual system feel: `Premium calm OS`.
- Top-level screens should avoid equal-weight card walls, dense dashboards, long paragraphs, and too many exposed controls.
- Rich panels should be used for meaningful state, hierarchy, and context.
- Motion should be subtle and meaningful.
- Motion should communicate where things went, what changed, and state transitions.
- Celebratory effects should be rare, for meaningful completions.
- Component priority: build reusable components and tokens.
- Light and dark mode both matter, with dark preferred if needed.
- Visual design must never reduce readability, create fake depth, use decoration without meaning, or hide primary action.
- Visual north star: `Calm intelligent life OS`.

---

# Wave 13 — Accessibility And Focus Support

Adoption date: 2026-04-27

- Accessibility means core product quality.
- ADHD support user-facing name: `Focus Support`.
- Focus Support should primarily reduce decisions and protect next action clarity.
- Avoid card overload, shame language, unclear next action, and dense dashboards for attention/executive-function challenges.
- Dynamic Type is a core requirement.
- VoiceOver is a core requirement.
- Color must never be the only meaning carrier.
- Reduce Motion must preserve meaning.
- Focus Support must never infantilize, remove depth, label the user, or turn the app into training wheels.
- Accessibility north star: `Anyone can understand what matters next`.

---

# Wave 14 — External Surfaces, Notifications, Widgets, And Live Activities

Adoption date: 2026-04-27

- External surfaces should primarily surface the right next thing safely.
- Notification frequency: sparse by default; user controls later.
- Notification tone: calm and operational.
- Sensitive/private details in notifications/widgets collapse as `Private item` at launch.
- Widgets show Best Next Action / Today slice.
- Live Activities show active focus/protected block or time-sensitive plan slice.
- App Intents / Shortcuts should support capture.
- Safe local actions with receipts are allowed from external surfaces; external writes require app confirmation.
- External surfaces must never expose private details, spam user, show fake urgency, or replace core app context.
- External-surface north star: `Calm continuity`.

---

# Wave 15 — Data, Local-First, Sync, And Export

Adoption date: 2026-04-27

- Default data posture: local-first.
- No account required at launch.
- No launch sync; sync later only after trust/export is strong.
- Export should exist before cloud sync.
- Export should include user-selectable categories.
- Delete-all-memory affects memory only.
- Data controls live under You -> Trust Center / Data controls.
- Do not show sync/export claims before implemented.
- Export failure should explain data remains safe, offer retry, and offer review export option.
- Data trust north star: user understands what is stored, remembered, exported, and deleted.

---

# Wave 16 — Monetization, Pricing, And Business Model

Adoption date: 2026-04-27

- Business model feel: `Premium life OS`.
- No ads.
- Free tier: useful but limited.
- Free tier should prove that one meaningful goal can become organized.
- Paid should unlock deep planning, reviews, memory, personalization, and advanced external surfaces.
- Export should not feel hostage.
- Trust, privacy, and data controls should not be paywalled.
- No manipulative monetization.
- Pricing posture: premium but accessible.
- Paid value must never depend on locking user data, shame, artificial friction, or manipulative urgency.
- Monetization north star: user feels Ambitions is worth paying for because it genuinely improves execution.

---

# Wave 17 — Launch Scope, MVP, And Quality Bar

Adoption date: 2026-04-27

- Launch should prove Ambitions can organize one meaningful goal into a believable execution system.
- Launch should not include every canon idea.
- Launch quality bar: stable, understandable, useful, and trustworthy.
- Fewer complete loops are better than more partial features.
- Do not ship fake AI, broken sync claims, unclear data controls, or dead-end flows.
- Advanced canon may remain planned.
- Launch acceptance requires core loop, empty states, error states, accessibility, and privacy truth.
- MVP must never mean ugly, untrustworthy, incomplete core loop, or confusing.
- Delay sync, advanced memory, widgets / Live Activities, and native AI-style suggestions if not excellent.
- Launch north star: prove Ambitions can make a meaningful goal feel organized, believable, and actionable.

---

# Wave 18 — Roadmap, Batch Governance, And No-Drift Execution

Adoption date: 2026-04-27

- Roadmap should optimize for completing coherent product loops.
- Batches may introduce new canon only when explicitly labeled as a canon proposal.
- When a batch conflicts with canon, pause and resolve conflict.
- Batch completion requires acceptance gates pass and docs/status updated.
- Roadmap order should prioritize dependencies.
- Future roadmap docs should distinguish shipped, planned, and deferred.
- Codex prompts should always include relevant canon docs, acceptance gates, no-drift rules, and validation command expectations.
- Batch execution must never add tabs casually, rename canon casually, implement fake capability, or skip validation/status updates.
- Unresolved questions become canon proposals or decision log entries.
- Roadmap governance north star: no drift from the product Ambitions is becoming.

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
- `docs/canon/MONETIZATION_PRICING_BUSINESS_MODEL.md`
- `docs/canon/LAUNCH_SCOPE_MVP_QUALITY_BAR.md`
- `docs/canon/ROADMAP_BATCH_GOVERNANCE.md`
- future batch prompts involving roadmap governance, batch execution, no-drift rules, canon proposals, acceptance gates, validation, shipped/planned/deferred status, launch scope, MVP, quality bar, onboarding, IA, navigation, drilldown, breadcrumbs, tabs, Life Areas, Capture routing, Today, Now State, empty states, recovery, best next action, Goals, Goal Detail, Goal Weather, Proof, Plan, calendar-aware planning, believability, daily schedule, rituals, You, Profile migration, Settings, Reviews, Trust Center, Appearance Studio, intelligence, suggestions, automation, visual system, components, motion, accessibility, Focus Support, external surfaces, notifications, widgets, Live Activities, App Intents, Shortcuts, data controls, local-first behavior, sync, export/import, monetization, pricing, free tier, paid tier, receipts, sensitive Life Areas, privacy controls, Smart Attachment, Needs a Place, or Capture input behavior.
