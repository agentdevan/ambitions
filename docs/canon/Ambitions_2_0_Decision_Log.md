# Ambitions 2.0 Decision Log

Adoption date: 2026-04-24

## Locked Decisions

- Batch 60 is treated as complete for planning purposes per current user instruction. It was a release-candidate polish batch. Existing repo docs did not independently prove Batch 60 before this canon update, so this is recorded as a planning-source decision rather than an implementation claim.
- Ambitions 2.0 is the active post-Batch-60 canon program.
- The final product promise is: "Ambitions makes my life feel organized, and gives me the concrete steps to accomplish anything I set my mind to."
- The expanded thesis is: "Ambitions exists to unlock people's lives by turning ambitions, goals, tasks, plans, and real-world constraints into clear next steps, believable plans, proof of progress, and calm recovery when life changes."
- The Design Constitution at `docs/canon/design/Ambitions_Design_Constitution.md` is the active design source of truth for IA, UX writing, component naming, interaction, trust, accessibility, and external-surface contracts.
- Ambitions 2.0 is not merely a planner, habit tracker, goal app, calendar wrapper, analytics dashboard, or beautiful productivity app.
- The visual sentence is: "Calm shell, rich panels, meaningful visual state."
- The execution sentence is: "Verify truth first, build shared systems once, then transform surfaces, then ship Apple-native external surfaces."
- Insights is demoted now from top-level navigation.
- Habits is absorbed now into Plan, rituals, Today execution, and Reviews/pattern reflection.
- The top-level shell is Today / Goals / Capture / Plan / You.
- `Capture` is singular.
- `You` is the Personal System Center; `Profile` remains compatibility language only where current code requires it.
- Life Areas are visible organization lenses inside Goals and You; they are not a sixth tab.
- North Stars are long-range dormant or identity-level ambitions under Life Areas.
- `Task = standalone One-Step Goal`; `Step = action inside a Goal, Path, or Plan`.
- There is no top-level Tasks tab.
- Smart Attachment is the named Capture routing/correction system.
- Panel Size and Display Density are active design controls with default `Balanced + Comfortable`.
- `GroupedNavigationList` is the official categorized settings/depth pattern and is not primary execution UI.
- The visual direction is rich widget-like panels, not plain text cards.
- Calendar read/write is included.
- Plan works without calendar permission and requests permission only from explicit Plan actions.
- Calendar-derived insight data is local-first and explained.
- Apple-first sync is included.
- Export/import remains required as a trust fallback.
- Full long-range paths are included.
- Life Graph v1 is included in Ambitions 2.0 scope.
- Action Closure with undo where safely supported is included in Ambitions 2.0 scope.
- Reality Reflow is the shared safe mutation/recovery direction; no silent rescheduling.
- A dedicated global shell/chrome/header/tab visual alignment batch is included after Today 2.0 and before remaining major surface redesigns.
- Widgets and Live Activities are included only after Canonical Now State and Command Pipeline stability.
- Accessibility Nutrition is required.
- Dedicated device runtime is an architecture guardrail only.

## Deferred Scope

- HealthKit.
- Food/calorie sync.
- Household/shared life.
- Non-phone hardware prototype.
