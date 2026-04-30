# Ambitions Master Product and Visual System Spec v2

Status: Active canonical product and visual direction.

Adoption date: 2026-04-29

Latest integration date: 2026-04-30

This document supersedes conflicting active language around `Your best next move`, `next best move`, manual `Start Focus` sessions, guessed durations, free-time assumptions, vacation as free time, silent automatic reflow, stale overdue task behavior, punitive completion language, generic dashboard framing, and top-level screen duplication.

Historical documents may keep deprecated phrases only as clearly historical context. Future Codex prompts and implementation batches should treat this file as the active master direction for product behavior, visual system, IA, wording, and interaction intent unless a later explicit canon decision supersedes it.

---

## 1. Product Thesis

Ambitions is a premium iPhone-native life operating system that uses adaptive panels, timeline rails, grounded time context, receipts, proof, Step Sessions, and Action Closure to help people know where to start, take the right step, recover without shame, and trust what changed.

Ambitions should feel:

- Native.
- Expensive.
- Calm.
- Intelligent.
- Restrained.
- Deep.
- Trustworthy.
- Beautiful.
- Dynamic.
- Human.

Ambitions should feel like:

```text
70% Apple quiet luxury
20% OpenAI intelligence
10% executive command surface
```

Ambitions must not feel like:

- A task app.
- A habit tracker.
- A fake AI dashboard.
- A SaaS analytics product.
- An Android app.
- A web app squeezed into iOS.
- A calendar clone.
- A card pile.
- A guilt machine.
- A productivity dashboard.
- A project-management board.
- A notes/chat app.

The product should remain deep, not wide: a few native top-level surfaces, with meaningful drill-downs where depth belongs.

---

## 2. Locked Top-Level Shell

The top-level app structure is exactly:

```text
Today / Goals / Capture / Plan / You
```

No top-level `Insights`, `Profile`, `Tasks`, `Habits`, `Calendar`, `Settings`, `AI`, `Assistant`, or `Focus` tab is allowed.

Those concepts may exist only as drill-downs, panels, grouped rows, or system surfaces where canon explicitly allows them.

### Tab roles

- Today: `What matters now?` Daily Command Surface.
- Goals: `Where am I headed?` Ambition Portfolio.
- Capture: `What needs a place?` Intake/composer surface.
- Plan: `Does this hold together?` Believability and planning suite.
- You: `How is my system working for me?` Personal System Center.

### Canonical 12-screen reference board

The canonical product/marketing/architecture board remains exactly:

1. Today
2. Goals
3. Goal Detail
4. Capture
5. Plan
6. You
7. Trust Center
8. What Ambitions Knows
9. Reviews / Life OS Receipt
10. Appearance Studio
11. First Run
12. Recovery Flow

Additional screens are real product depth, but they are drill-downs/subflows, not replacements for the 12-screen reference board.

Examples of allowed drill-downs/subflows:

- Step Detail.
- Step Session.
- Path subview.
- Proof subview.
- Decisions / Risks subview.
- Needs a Place.
- Ready to Place.
- Grow into Goal.
- Schedule & Availability.
- Planning Defaults.
- Vacation / Away Time.
- Automation & Trust.
- Plan Day / Week / Month scopes.
- Month Life Shape view.

---

## 3. Global Navigation Philosophy

The app should feel native to iPhone. Users should understand the app because they understand iOS.

Use:

- Predictable tab bar behavior.
- Safe-area correctness.
- Standard tap targets.
- Native-feeling sheets.
- Grouped lists where appropriate.
- Familiar row/chevron behavior.
- Clear hierarchy.
- Deep drill-downs instead of extra top-level tabs.

Do not hide primary navigation or invent a web-dashboard shell.

Ambitions should borrow iOS interaction grammar, then layer Ambitions-specific adaptive system panels, timeline rails, plan health surfaces, proof rails, recovery panels, and context lenses on top.

---

## 4. Header Philosophy

Top-level tabs should not waste space with large visible title blocks by default.

The selected tab bar item provides location awareness. The top of each top-level screen should prioritize context, state, and action over repeating the tab name.

Avoid:

- Large thick headers.
- Huge visible `Today`, `Goals`, or `Plan` blocks.
- Empty vertical padding.
- Blocked-off top areas.
- Repeated screen names that do not add value.

Use:

- Compact contextual headers.
- Small context chips.
- Subtle action icons.
- Screen-specific state.
- Content starting high but safely.

### Accessibility exception

Even when large visible titles are reduced, preserve screen identity for navigation and accessibility.

SwiftUI implementations should still expose appropriate navigation titles, traits, and VoiceOver labels. For example, `.navigationTitle("Today")` may remain with `.navigationBarTitleDisplayMode(.inline)` or an equivalent custom accessibility implementation.

VoiceOver users should still understand which screen they are on.

---

## 5. Language Rules

### Deprecated user-facing language

Do not use in normal UI:

- `Your best next move`
- `next best move`
- `Start Focus`
- `Focus session`
- `Productivity score`
- `AI confidence`
- `Optimization rating`
- `Overdue`
- `Failed`
- `Behind`
- `Missed`
- `Incomplete`

### Preferred user-facing language

Use calm, direct, human language:

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
- `Private`
- `Saved`

Use `step` for an action the user should take.

Avoid `move` as a noun for a user action. The internal closure/system state `Moved` may remain where it means a scheduled occurrence was rescheduled; the preferred user-facing label is usually `Rescheduled`.

### Hero language

The Today hero uses `Start here`, not `Your best next move`.

The action is a `Recommended step`, not a `next best move`.

Primary CTAs are:

- `Start now`
- `Open step`
- `Continue`
- `Review`

Secondary CTA is usually:

- `Adjust plan`

Optional explanation affordance:

- `Why this?`

---

## 6. Layout Density Rules

Ambitions should be spacious, but no space should be wasted.

Space is valid when it improves clarity, calm, tap comfort, visual grouping, breathing room, or decision-making.

Space is wasteful when it creates dead header zones, giant decorative cards, unnecessary gaps, hidden useful content, or forced scrolling.

### Top-level scroll depth

- Today: may extend roughly up to two iPhone screens when useful.
- Goals: may extend roughly up to two iPhone screens when useful.
- Capture: composer-driven; should not require normal scrolling under normal text sizes.
- Plan: may extend because it can be a fuller planning suite, but must preserve its believability/recovery purpose.
- You: lenient because grouped system sections require depth.
- Drill-downs: can be deeper when justified.

Capture is the major exception: it should feel immediate, with the bottom composer as the main action.

---

## 7. Visual Style

Base feel:

- Dark-mode-first.
- Warm graphite.
- Premium material.
- Restrained glow.
- Quiet depth.
- Crisp text.
- Clear hierarchy.
- Soft rounded surfaces.
- Subtle separators.

Avoid:

- Neon overload.
- Cartoonish color.
- Overly bright gradients.
- Generic SaaS blues.
- Tiny unreadable labels.
- Fake glass everywhere.
- Heavy shadows.
- Dense dashboard blocks.
- Equal-weight card walls.

Color communicates state, source, priority, action, risk, trust, proof, or recovery. Color is not decoration.

Semantic color guidance:

- Amber: priority, protected time, selected state, primary action, active step.
- Teal: progress, proof, clear state.
- Purple: memory, personalization, reflection.
- Red/orange: true risk, blocker, recovery only.
- Graphite/gray: structure, secondary information, inactive states.
- Blue: limited; avoid generic link-blue dominance.

The premium version of Ambitions should feel dimensional, not colorful for its own sake.

### Starfield signature

A restrained dark-sky/starfield visual signature is allowed only for:

- Capture.
- First Run.

Rules:

- Very low contrast.
- No bright stars behind text.
- No galaxy overload.
- No childish space theme.
- Works with Reduce Motion.
- Feels premium and quiet.

Do not apply the starfield across the entire app.

---

## 8. Adaptive System Panels

Ambitions should be built from reusable, data-driven SwiftUI components.

Official concept:

```text
Adaptive System Panels
```

Definition:

Reusable, data-driven SwiftUI components that summarize goals, plans, proof, memory, recovery, time context, and user state.

Primary component families:

1. Step / decision panels.
2. Timeline rails.
3. Progress panels.
4. Proof panels.
5. Plan health panels.
6. Capture composer.
7. Grouped navigation lists.
8. Memory panels.
9. Recovery panels.
10. Appearance controls.
11. Receipt trails.
12. Time context chips.
13. Availability panels.
14. Reflow panels.
15. Trust / automation controls.

Canonical component names include:

- `AppBackground`
- `SurfacePanel`
- `CompactContextHeader`
- `HeroStepPanel`
- `DayTimelineRail`
- `TimelineRailRow`
- `TimelineRailMarker`
- `StepDetailPanel`
- `StepSessionView`
- `TimeContextLens`
- `TimeContextBadge`
- `DurationBadge`
- `DurationSourceLabel`
- `PlanHealthPanel`
- `CalendarStrip`
- `CalendarDayPill`
- `PlanDayDetailPanel`
- `FreeTimePanel`
- `AvailabilityWindowPanel`
- `ScheduleStrip`
- `EvidenceSourceChip`
- `ScheduleSourceLabel`
- `GoalPathRail`
- `ProofRail`
- `CaptureComposer`
- `GroupedNavigationSection`
- `AmbitionsNavigationRow`
- `UserSystemProfilePanel`
- `StatusChip`
- `RigidityChip`
- `ReadinessChip`
- `ContextRequirementChip`
- `RecoveryPanel`
- `ReceiptTrail`
- `ClosureCheckInPanel`
- `ActionClosureSheet`
- `ReflowOpportunityPanel`
- `ReflowPromptSheet`
- `AutomationLevelControl`
- `PlanBehaviorSettings`
- `ScheduleInputPanel`
- `VacationAvailabilityControl`

Existing equivalent components may remain as compatibility adapters where they already exist.

---

## 9. Dynamic State Model

The app should not hardcode static screens.

Screens are composed from:

- State models.
- Rules.
- User data.
- Receipts.
- Goals.
- Plans.
- Calendar evidence.
- Proof.
- Memory.
- Closure history.
- Schedule and availability inputs.

Example Today composition:

```text
TodayView
├─ CompactContextHeader
├─ TimeContextLens
├─ HeroStepPanel(model: heroStep)
├─ ClosureCheckInPanel(model: closureCheckIn?)
├─ ReflowOpportunityPanel(model: reflow?)
├─ DayTimelineRail(model: todayRail)
├─ RecoveryInsightPanel(model: recovery?)
└─ AvailabilityWindowPanel(model: availability?)
```

Panels should appear only when they earn their space.

Every panel should answer at least one:

- What matters?
- What changed?
- What should I do?
- Why is this here?
- Can I trust it?
- Where do I go next?

---

## 10. Locked Product Rules

### 10.1 Focus is not a CTA

`Focus` should not be treated as a manually started mode on Today.

Focus, work, school, free time, recovery, and protected time appear as context states inside the Time Context Lens.

Preferred CTAs are `Start now`, `Open step`, `Adjust plan`, `Review options`, and `Why this?`.

Examples of context labels:

- `Work · 2h left`
- `School · until 2:30`
- `Free time · 45m open`
- `Protected time · 1h`
- `Vacation · unavailable`
- `Recovery · light day`
- `Creative · good window`

### 10.2 Context must be automated but grounded

Ambitions may use user-provided schedules, calendar events, protected blocks, commute/transition buffers, plan blocks, and recurring commitments.

The UI should lightly name the source where useful:

- `Based on your work schedule`
- `From your calendar`
- `Protected by your plan`
- `You marked this unavailable`
- `Open time after school`

Ambitions should feel intelligent, but not mysterious.

### 10.3 Free time has a strict definition

Free time is what remains only after excluding hard context:

- Work.
- School.
- Vacation / away.
- Calendar events.
- Commute / buffers.
- Protected blocks.
- Reserved commitments.
- Configured sleep / recovery.
- Configured family / household anchors.

Vacation is not free time by default.

Vacation / away time can be `Unavailable`, `Away`, `Out of routine`, `Protected`, `Travel`, or `Recovery` unless the user explicitly marks windows as `Available`, `Flexible`, `Open`, or usable for planning.

### 10.4 Durations must be grounded

Ambitions must never present a guessed duration as fact.

Every duration shown in the UI must be:

- User-set.
- User-accepted.
- Clearly suggested.
- Historically grounded.
- Actual.
- Unset.

Examples:

- `30 min planned`
- `Suggested: 15–20 min`
- `Usually 10–30 min`
- `Duration not set`
- `Completed in 12 min`

### 10.5 Early completion creates optional reflow, not silent rearrangement

If the user completes a step earlier than planned, Ambitions should show a quiet adaptive prompt instead of silently rearranging the day.

Example:

```text
You finished 18 min early.
Use this open time?
```

Options may include:

- `Suggest a step`
- `Reflow my day`
- `Protect this time`
- `Keep plan as is`

Reflow must be user-trusted, receipt-backed, reversible, and bounded by rigidity rules.

---

## 11. Time Context Hierarchy

Recommendations flow through this order:

1. Hard Context.
2. Availability Context.
3. Cognitive Context.
4. Recommendation Layer.

### 11.1 Hard Context

Hard Context defines when the user is not freely available.

Examples:

- Work.
- School.
- Vacation / away.
- Calendar events.
- Commute.
- Setup time.
- Transition buffers.
- Protected blocks.
- Sleep / recovery blocks.
- Family / household anchors.
- Appointments.
- Fixed commitments.

Hard Context should not be overwritten by recommendations.

### 11.2 Availability Context

Availability Context is derived after Hard Context is removed.

Examples:

- Free time.
- Open window.
- Flexible time.
- Protected free time.
- Unavailable.
- Low-control time.
- Available if needed.
- Open but do not fill.

Free time does not automatically mean Ambitions should fill the time.

### 11.3 Cognitive Context

Cognitive Context describes what type of work fits the available window.

Examples:

- Deep work.
- Creative.
- Admin.
- Light.
- Recovery-friendly.
- Errands.
- Social.
- Planning.
- Review.
- Household.

This should be optional and gentle, not heavy mood tracking.

### 11.4 Recommendation Layer

Only after evaluating Hard Context, Availability Context, and Cognitive Context should Ambitions recommend a step.

Recommendations should account for:

- Available time.
- Duration source.
- Step priority.
- Goal importance.
- Due date.
- Dependencies.
- Location.
- Device/tool requirements.
- Cognitive fit.
- Recovery state.
- User preferences.
- Proof opportunity.

Ambitions never fills open time just because it exists.

---

## 12. Real-Life Issue Coverage

Ambitions must handle these product realities before claiming mature planning intelligence.

### 12.1 Split-shift and irregular schedules

Support multiple schedule blocks per day, irregular weekly schedules, one-off overrides, floating work blocks, and today-only adjustments.

### 12.2 On-call or low-control work

Work context can be `Deep Work`, `Standard Work`, `Low-Control Work`, `On Call`, `Meeting-heavy`, or `Admin-friendly`.

Ambitions should not recommend high-focus steps during low-control time unless the user allows it.

### 12.3 Commute, setup, and transition time

Support before-event buffers, after-event buffers, commute, setup, decompression, meal buffer, and pickup/dropoff buffer.

### 12.4 Family, partner, childcare, pet, and household obligations

Support recurring personal anchors such as Family, Partner, Childcare, Pet care, Household, Meal, Evening routine, Morning routine, and Personal commitment.

These are protected/reserved context, not free time.

### 12.5 Variable-duration steps

Support `No duration set`, `User-set duration`, `Suggested duration`, `Accepted suggested duration`, `Historical range`, and `Actual duration`.

### 12.6 Hard commitments vs flexible steps

Every scheduled occurrence should have a rigidity level:

- Fixed.
- Anchored.
- Protected.
- Flexible.
- Optional.
- Waiting.
- Someday.

Reflow may only adjust flexible/optional items unless the user explicitly approves.

### 12.7 Dependencies and readiness

Steps need readiness states:

- Ready.
- Waiting on person.
- Waiting on time.
- Waiting on place.
- Waiting on tool.
- Blocked.
- Needs Review.

Today should recommend only steps that are actually doable.

### 12.8 Location and tool constraints

Steps may include requirements for location, device, tool, internet, quiet, people, or energy type.

### 12.9 Energy and cognitive fit

Recommendations should respect lightweight cognitive labels such as Deep work, Creative, Admin, Light, Recovery-friendly, Errands, Social, Planning, and Review.

### 12.10 Over-automation and trust loss

Automation must be permissioned and receipt-backed.

Automation levels:

- `Manual`: Ambitions suggests; user decides.
- `Guided`: Ambitions proposes and asks before meaningful changes. Default.
- `Adaptive`: Ambitions can adjust flexible items within user-defined rules and always creates receipts/undo.

---

## 13. Action Closure System

Ambitions should not treat step completion as simple `complete / incomplete`.

It uses Action Closure.

Core rule:

- Ambitions does not auto-complete a step when time passes.
- Ambitions does not mark a step as failed because the user forgot to open the app.
- A scheduled step eventually needs a closure outcome.

### Model distinction

- `Step`: the actual action inside a goal, plan, or path.
- `Step Occurrence`: that step scheduled for a specific day/time/context.
- `Action Closure`: what happened to that occurrence.
- `Closure Receipt`: the record of what changed.

### Closure outcomes

Supported closure outcomes:

- Completed.
- Still Counts.
- Moved / Rescheduled.
- Skipped Intentionally.
- Not Needed.
- Blocked.
- Waiting.
- Needs Recovery.
- Needs Review.

User-facing state mapping:

- Active -> `Now`.
- Planned -> `Next` / `Later`.
- Awaiting Closure -> `Needs a quick check`.
- Partially completed -> `Still Counts`.
- Rescheduled -> `Rescheduled`.
- Could not happen -> `Needs Recovery`.
- Dependency exists -> `Waiting`.
- No longer relevant -> `Not Needed`.
- Requires user decision -> `Needs Review`.

Avoid emotionally punishing language unless a specific later canon requires otherwise.

### Prior unclosed steps

Today must not become a graveyard of old steps.

Prior unclosed steps appear as soft closure prompts, not stale Today rail items.

Examples:

- `Yesterday has 2 loose ends · Review`
- `One step needs a quick check · Close the loop`

A bottom sheet is allowed only when an unresolved item directly affects today’s plan or current recommendation.

### Still Counts visibility

`Still Counts` appears in closure sheets, recovery flows, relevant prompts, and Step Detail when applicable. It should not appear everywhere completion appears.

---

## 14. Today Screen

Purpose: `What matters now?`

Today is the Daily Command Surface.

Required components:

- `CompactContextHeader`
- `TimeContextLens`
- `HeroStepPanel`
- `DayTimelineRail`
- `ClosureCheckInPanel` when needed
- `ReflowOpportunityPanel` when useful
- `RecoveryInsightPanel` when needed
- `AvailabilityWindowPanel` when useful
- visible tab bar

### Visual structure

```text
Safe area
Compact contextual header
HeroStepPanel
Optional closure/reflow prompt
Now / Next / Later DayTimelineRail
Optional availability/recovery panel
Tab bar
```

### Hero Step Panel

User-facing title: `Start here`.

The panel answers:

- Where should I start?
- Why this step?
- Does it fit my current context?
- How much time is really available?
- What can I do instead?

Required anatomy:

1. `Start here`
2. Recommended step title
3. Why now explanation
4. Current context label
5. Duration label with source
6. Day progress or time remaining
7. Primary CTA
8. Secondary CTA
9. Optional `Why this?`

Example:

```text
Start here
Reply to client feedback
Fits your current Work block and is ready.
Work · 45m left
45m planned
Day 42% complete
[Start now] [Adjust plan]
Why this?
```

### Adaptive hero sizing

The Hero Step Panel is adaptive:

- Compact on normal days.
- Standard when explanation/context/action is useful.
- Expanded only when explanation, recovery, closure, setup, or conflict resolution is needed.

Normal days should not show a giant hero.

### Day Timeline Rail

The Day Timeline Rail is a signature visual and navigation spine.

Locked structure:

- `Now`
- `Next`
- `Later Today`

Visual requirements:

- Left-side vertical rail.
- Small connected dots.
- Thin line.
- Active/current dot strongest.
- Completed/closed items muted but visible where relevant.
- Rows look and behave tappably.

Interaction:

- Tap row -> lightweight Step Detail.
- `Start now` from Step Detail -> Step Session.
- Quick action -> Complete when appropriate.
- More actions -> Action Closure Sheet.

The rail may support premium collapse/expand behavior tied to scroll/state, but it must remain readable, accessible, and scannable.

Duration labels in the rail must be grounded, for example `30 min planned`, `Suggested: 15 min`, `Usually 10–30 min`, or `Duration not set`.

---

## 15. Step Detail and Step Session

### Step Detail

Tapping a Today rail row opens lightweight Step Detail first.

Step Detail should show:

- Step title.
- Goal/context.
- Why it is here.
- Duration source.
- Readiness.
- Dependencies.
- Proof/notes if available.
- Closure actions.
- `Start now` / `Open step`.

### Step Session

Step Session is the real execution drill-down launched from `Start now` or `Open step`.

Do not call it Focus Session.

Step Session may show:

- Current step.
- Context state.
- Why it matters.
- Planned/suggested/user-set duration.
- Optional timer.
- Notes/proof capture.
- Complete.
- Still Counts.
- Pause.
- Adjust.

Timer rule: timer is optional/secondary, not timer-first by default.

---

## 16. Goals Screen

Purpose: `Where am I headed?`

Goals is the Ambition Portfolio, not a task board.

Required content:

- Life Areas / portfolio structure.
- Active Goals.
- North Stars preview.
- Goal Weather / qualitative maturity states.
- Proof/momentum summary.
- Next visible step.
- Drill-down affordances.
- Visible tab bar.

Goal rows should be compact, premium, and tappable.

Goal row anatomy:

- Goal name.
- Life Area.
- Next step.
- State chip.
- Proof marker.
- Chevron.

Use qualitative states such as `Active`, `Clear`, `Needs Review`, `Gaining Momentum`, `Waiting`, `Protected`, and `Recovering`.

Avoid fake scores and project-management board density.

---

## 17. Goal Detail

Purpose: `What is the state of this goal, and what happens next?`

Goal Detail is one destination with lane-based Mission Control.

Required lanes:

- Overview.
- Path.
- Steps.
- Proof.
- Decisions.
- Risks.
- Archive.

Goal Detail owns depth. Each lane may open deeper subviews.

Examples:

- Path -> Path Builder / GoalPathRail detail.
- Proof -> Proof rail / evidence detail.
- Decisions -> open decisions / decision history.
- Risks -> blockers / assumptions / recovery options.
- Steps -> Step list / Step Detail / Step Session entry.
- Archive -> completed steps / receipts.

GoalPathRail should feel like a luxury transit map, not a childish game board.

Do not split Goal Detail into multiple top-level destinations.

---

## 18. Capture Screen

Purpose: `What needs a place?`

Capture is composer-driven and should not feel like chat.

First-use behavior:

- Ultra-minimal first.
- Reveal routes after input.
- Do not show a heavy routing dashboard before the user types or speaks.

Locked composer:

- Bottom anchored.
- Text field at bottom.
- Mic inside text field.
- Add button on the right.
- Safe-area correct.
- No chat UI.
- No normal scrolling under normal text sizes.

Capture flow:

1. Type or speak the thought.
2. Ambitions suggests where it belongs.
3. User confirms or changes.
4. Receipt is shown.

Core routes:

- Task / One-Step Goal.
- Goal.
- Proof.
- Waiting.
- Decision.
- Needs a Place.

Secondary Capture flows are real but not top-level:

- `Needs a Place`.
- `Ready to Place`.
- `Grow into Goal`.
- `Recent`.
- `Build Goal`.

Do not make top-level Capture feel like email, notes, or a triage dashboard.

If a captured item implies time, Ambitions may ask softly whether to add a duration, use a suggested duration, or leave duration unset. It must not invent a duration silently.

Capture and First Run may use the restrained starfield treatment.

---

## 19. Plan Screen

Purpose: `Does this hold together?`

Plan is a fuller planning suite, but it must preserve Ambitions’ believability and recovery purpose.

Plan is not a generic calendar clone.

It answers:

- What is scheduled?
- What is truly open?
- What is protected?
- What is flexible?
- What changed?
- What can be adjusted safely?

Required components:

- Compact contextual header.
- Calendar strip / calendar day selector.
- Compact scope chip.
- Plan Health Panel.
- Selected day detail.
- Schedule strip.
- Availability / free/open/protected time.
- Evidence labels.
- Recovery action.
- Reflow opportunity.
- Visible tab bar.

### Scope chip

Plan uses a compact scope chip for:

- Day.
- Week.
- Month.

Default behavior is contextual:

- Active day -> Day.
- Planning/review window -> Week.
- Long-range planning -> Month / Life Shape.

### Month = Life Shape

Month view is not a generic calendar grid.

It emphasizes:

- Life areas.
- Pressure weeks.
- Protected time.
- Goal milestones.
- Vacation / away.
- Major commitments.
- Review markers.
- Open weeks.

Month answers: `What shape is my life taking?`

### Evidence labels

Plan must use source labels such as:

- `From your calendar`
- `Created in Ambitions`
- `Based on your plan`
- `From you`
- `Protected by you`
- `Suggested by Ambitions`

### Plan Health Panel

Plan Health should summarize capacity, pressure, open windows, protected time, and recovery state using qualitative labels like `Clear`, `Tight`, `Protected`, `Needs Review`, `Recovering`, and `Low-control`.

---

## 20. You Screen

Purpose: `How is my system working for me?`

You is the Personal System Center.

It is not a profile page, card feed, or junk drawer.

Required structure:

- UserSystemProfilePanel.
- Grouped navigation sections.
- Visible tab bar.

UserSystemProfilePanel is inspired by iOS Settings account panels but Ambitions-native.

It should include:

- User name / identity.
- Small avatar or Ambitions glyph.
- Short system subtitle.
- System state/value.
- Right chevron.
- Premium rounded surface.
- Restrained color.

Recommended grouped structure:

```text
Me
- Profile
- Personalization
- Appearance

Planning Setup
- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust

Memory and Trust
- What Ambitions Knows
- Trust Center
- Receipts & History
- Corrections

Reviews and Progress
- Reviews
- Proof
- Archive / Completed

System Edges
- Notifications
- Integrations
- Widgets / Live Activities / Shortcuts
- Export / Import

Accessibility and Support
- Accessibility
- Help / Support
- About
```

Planning Setup must be high because it powers the Time Context Hierarchy.

### Automation default

Default automation level is `Guided`.

Guided means Ambitions suggests and prepares changes, but asks before meaningful plan changes.

Automation levels:

- Manual.
- Guided.
- Adaptive.

### Vacation / Away

Vacation supports default behavior plus per-vacation override.

Default options may include:

- Unavailable.
- Protected.
- Partly available.
- Flexible.
- Ask each time.

Vacation does not become free time unless explicitly marked available.

---

## 21. Trust Center

Purpose: `Can I trust what Ambitions changed or used?`

Trust Center should feel warm and plain, not compliance-heavy.

Required content:

- Trust summary.
- Recent receipts.
- Explanations.
- Corrections.
- Privacy status.
- Safe vs blocked controls.
- Plain language.

Use calm labels such as `Clear`, `Private`, `Saved`, `Not Required`, `Blocked`, and `Needs Review`.

Avoid compliance/legal/AI-console language.

---

## 22. What Ambitions Knows

Purpose: `What does the system remember, where did it come from, and what can I change?`

This is a Memory Library, not an AI data console.

Required content:

- Memory groups first.
- Source.
- Freshness.
- What this affects.
- Review / Update / Pause / Forget controls where safe.
- Private/sensitive handling.

Preferred groups:

- Goals & Plans.
- Preferences.
- Schedule Patterns.
- Proof & Receipts.
- People / Context.
- Sensitive Items.

Do not show a giant raw memory list first.

---

## 23. Reviews / Life OS Receipt

Purpose: `What changed, what counted, what carries forward?`

This is a receipt of reality, not an analytics dashboard.

Required content:

- Weekly/recovery review.
- What changed.
- What counted.
- Proof highlights.
- Decisions made.
- Carry-forward items.
- Receipt trail.

Ideal language:

- `This week still counted.`
- `You protected music twice.`
- `One plan changed. Nothing was lost.`
- `Two items carry forward.`

Do not turn this into an Insights tab or performance-report surface.

---

## 24. Appearance Studio

Purpose: `How should Ambitions look and feel?`

Appearance Studio should feel like a premium iOS settings screen, not a cheap theme editor.

Required content:

- Preview card.
- System / Light / Dark mode.
- Accent choices.
- Density control.
- Panel size control.

Options:

- Mode: System, Light, Dark.
- Accent: Amber, Teal, Purple, Graphite.
- Density: Comfortable, Balanced, Compact.
- Panel size: Standard, Spacious.

The row from You should be `Appearance`. Inside the detail screen, `Appearance Studio` is acceptable.

---

## 25. First Run

Purpose: start without setup burden.

Primary prompt:

```text
Start with one real thing.
```

First Run should not force setup.

It may optionally prompt Schedule & Availability because schedule data improves Today, Plan, and recommendation trust, but this should be non-blocking and the row remains persistent under You.

The first moment of value should remain capturing something real.

First Run may share the restrained starfield treatment with Capture.

---

## 26. Recovery Flow

Purpose: save the day when the plan breaks.

Recovery tone:

- Calm.
- Direct.
- Lightly supportive.

Not sentimental. Not cold. Not punitive.

Use:

```text
The day changed. The goal does not have to disappear.
```

Required sections:

- What changed.
- What stays protected.
- Steps to reschedule.
- Still Counts.
- Save the Day.
- Receipt / Undo.

Use `Steps to reschedule`, not `What can move`, where the UI is referring to user actions.

Still Counts should appear here when relevant.

---

## 27. Receipts and Trust Visibility

Receipts are essential to trust, but they should not become noisy.

Default behavior:

- Subtle toast or inline receipt confirmation.
- Full receipt detail available by tap/drill-down.

Examples:

- `Saved · receipt created`
- `Plan adjusted · undo available`
- `Step closed · Still Counts`
- `Rescheduled · receipt saved`

Full receipt detail lives in Trust Center, Receipts & History, Life OS Receipt, and linked detail screens.

A receipt records:

- What changed.
- When it changed.
- Why it changed.
- What source informed it.
- Whether undo/review is available.

---

## 28. Interaction Rules

Everything that visually appears as a row, rail item, or panel affordance should have predictable tap behavior.

Examples:

- Today rail row -> Step Detail.
- Step Detail `Start now` -> Step Session.
- Goal row -> Goal Detail.
- Calendar day -> selected day detail.
- You row -> drill-down.
- Memory group -> memory detail.
- Receipt row -> receipt detail.
- Proof item -> proof detail.

Use bottom sheets for closure decisions, quick edits, reschedule/recover actions, and route confirmation.

Use full-screen drill-downs for Goal Detail, Trust Center, What Ambitions Knows, Appearance, Reviews, Memory Detail, Receipt Detail, Schedule & Availability, Planning Defaults, Vacation / Away Time, and Automation & Trust.

Long press is optional later and must not be required for core behavior.

---

## 29. Tab Bar Rules

The tab bar is persistent on top-level screens.

It should be:

- Visible.
- Premium.
- Safe-area correct.
- Clear in selected state.
- Not hidden by content.
- Not overly bright.
- Not oversized.

Selected state can use subtle glow, accent tint, stronger icon, or pill/background treatment.

The tab bar provides top-level location awareness, reducing the need for huge screen titles.

---

## 30. Safe Area and Device Rules

The app must respect:

- Dynamic Island.
- Status bar.
- Home indicator.
- Tab bar.
- Keyboard.
- Bottom composer.

No content should sit under the Dynamic Island, hide behind the tab bar, clip near the home indicator, overlap the keyboard, or bleed under headers.

Capture especially must use a safe bottom inset or equivalent for `CaptureComposer`.

---

## 31. Accessibility and ADHD Support

Accessibility is product quality.

Requirements:

- Comfortable tap targets.
- Clear focus order.
- VoiceOver labels.
- Dynamic Type resilience.
- No color-only meaning.
- Adequate contrast.
- No clipped text.
- No tiny status pills.
- Reduced Motion support.

ADHD-specific principles:

- One obvious next action.
- Minimal shame language.
- Low reading burden.
- Visual structure.
- Clear hierarchy.
- Calm recovery.
- No cluttered dashboards.
- No overwhelming setup.

The app should support depth without requiring the user to hold the whole system in their head.

---

## 32. Animation and Motion Rules

Motion should feel premium and useful.

Use motion for:

- Selected day transition.
- Timeline state update.
- Panel expansion/collapse.
- Bottom sheet presentation.
- Closure confirmation.
- Receipt saved feedback.
- Plan reflow explanation.

Avoid:

- Bouncy playful animation.
- Excessive glow pulses.
- Constant movement.
- Gamified confetti.

Motion should be subtle, fast, native, and confidence-building.

---

## 33. Screen-Specific Anti-Patterns

Today must avoid dashboard clutter, too many cards, old tasks taking over, and shameful overdue lists.

Goals must avoid task-board feel, too many colorful goal cards, fake scores, and KPI framing.

Goal Detail must avoid showing every lane at once, dense walls of modules, and burying the next step.

Capture must avoid chat UI, giant assistant areas, scroll-heavy intake, generic note routes, and a top text field when the bottom composer is intended.

Plan must avoid becoming a calendar clone, silently automating, hiding evidence labels, or becoming a scheduling SaaS dashboard.

You must avoid becoming a card feed, generic settings dump, analytics dashboard, or social profile.

Trust must avoid enterprise compliance language, scary data language, and legalistic tone.

Memory must avoid AI jargon, raw data dumps, and huge ungrouped memory lists.

Reviews must avoid analytics dashboards and performance-report vibes.

Recovery must avoid punitive tone, failure language, and overwhelming repair flow.

---

## 34. Acceptance Criteria

The design system is successful when:

- Today uses `Start here`, not deprecated best-move language.
- Today CTAs are `Start now` or `Open step`, not `Start Focus`.
- Focus/work/school/free time appear as context states, not manually started modes.
- Time Context Lens updates from grounded schedule inputs.
- Vacation / away is not treated as free time unless explicitly marked available.
- Free time is calculated only after hard context, commitments, buffers, protected blocks, and calendar events are excluded.
- Durations are user-set, user-accepted, clearly suggested, historically grounded, actual, or unset.
- Guessed durations are never presented as fact.
- Early completion creates a respectful reflow prompt, not silent rearrangement.
- Today rail is beautiful, connected, clickable, and useful.
- Tap Today rail row -> Step Detail; Start -> Step Session.
- Step Session has optional/secondary timer, not timer-first pressure.
- Plan supports Day / Week / Month scope while preserving believability/recovery purpose.
- Month is Life Shape, not a generic calendar grid.
- Capture is fast, bottom-composer-driven, ultra-minimal first, and reveals routes after input.
- Capture and First Run may use a restrained starfield visual signature.
- You has UserSystemProfilePanel and a high Planning Setup section.
- Goal Detail is one lane-based Mission Control destination with deeper subviews.
- Action Closure prevents stale/shameful step handling.
- Trust and receipts make changes understandable without becoming noisy.
- The app feels expensive, not colorful.
- The app feels native to iPhone, not web or Android.
- Every screen belongs to the same system.

---

## 35. Implementation Truth

This spec is canonical product/design direction. Code implementation must remain evidence-based.

Do not claim a surface, model, receipt path, preview, accessibility behavior, device behavior, TestFlight readiness, App Store readiness, or RC lock is implemented unless the current repo proves it.

When implementing, prefer this order:

1. Documentation/source-of-truth alignment.
2. Visual tokens and reusable AmbitionsUI components.
3. Compact contextual header system.
4. Time Context / Schedule & Availability foundations.
5. Action Closure / Step Occurrence foundations where not already complete.
6. Today Hero Step Panel + DayTimelineRail + Step Detail + Step Session.
7. Plan Day / Week / Month suite with Life Shape and evidence labels.
8. You UserSystemProfilePanel + Planning Setup.
9. Capture composer + restrained starfield + secondary flows.
10. Goals / Goal Detail lane depth.
11. Trust / Memory / Reviews / Appearance / First Run / Recovery alignment.
12. Previews, fixtures, tests, and validation evidence.

Do not implement one-off mockup screens. The correct implementation path is:

```text
tokens -> components -> data models -> screens -> previews/tests
```
