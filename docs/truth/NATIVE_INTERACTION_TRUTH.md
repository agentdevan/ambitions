# NATIVE_INTERACTION_TRUTH.md

Status: Active product/design source of truth  
Scope: Native interaction laws, imported app-pattern translations, drilldown rules, surface behavior, UI reconstruction gates  
Applies to: Ambitions native iPhone app, report-repair trains, screenshot acceptance, future SwiftUI/UIKit implementation work  
Authority: Companion to `docs/truth/PRODUCT_DESIGN_TRUTH.md`. Where this file is stricter or more specific for UI reconstruction, this file wins for interaction, navigation, capture, time legibility, settings, empty states, and native Apple behavior.

---

## 0. Why this canon exists

The App Testing Report failure pattern is not merely visual quality. The app is exposing internal architecture instead of letting the user operate through clear native objects.

This canon folds the supplied atlas and app-reference analysis into Ambitions design truth. The references are not product targets. Ambitions must not become Reminders, Microsoft To Do, ChatGPT, Calendar, Settings, or a task/calendar/chat app. Those apps contribute interaction laws that Ambitions translates into its own object system.

Core law:

```text
Ambitions must make time, capture, drilldown, search, settings, completion, and navigation obvious before it asks the user to understand Ambitions-specific vocabulary.
```

A surface fails reconstruction if the user must decode internal nouns before understanding what to do.

---

## 1. Imported interaction laws

### 1.1 Time must be legible before it is intelligent

Apple Reminders and Calendar make time orientation easy before applying higher-level grouping or behavior. Ambitions must do the same before layering Private Life Runtime intelligence.

Ambitions translation:

- Today shows now, current available window, recommended step, next fixed point, protected boundary, urgent pressure, completed/closed loop, waiting/blocked, and later today.
- Time shows fixed points, open capacity, protected time, pressure, energy fit, recovery, future scheduled steps, and past-due pressure without becoming a calendar clone.
- The current-time marker must be live and device-derived or test-injected, never hardcoded.
- Calendar source data is a constraint layer, not the root visual model.

Hard red:

- Hardcoded time labels.
- Calendar block clone as the core Time visual.
- Free/busy language as the dominant Time model.
- Intelligence copy that appears before basic time orientation is clear.

### 1.2 Root navigation and drilldown navigation are different systems

Bottom navigation belongs only at the root level. Drilldowns must feel native iOS: back arrow, gesture back, focused full-screen object, no bottom nav clutter.

Root level:

```text
Contextual Shell Header
Surface object
Root navigation
```

Drilldown level:

```text
Back arrow / gesture
Focused full-screen object
No root nav
```

Capture level:

```text
Composer-first surface
Keyboard-aware
Expandable to full-screen
No tab bar fighting the keyboard
```

Hard red:

- Bottom/root nav visible in goal detail, step detail, day detail, appearance settings, privacy, receipts/history, or capture detail.
- Drilldowns that look like dashboard pages.
- Root shell chrome that persists when it damages keyboard, capture, or focused detail work.

### 1.3 Capture must be beautiful, obvious, and expandable

ChatGPT’s composer contributes interaction quality, not product identity. Capture should inherit premium composer behavior and Reminders-style rich quick-add controls, translated into Ambitions intake.

Quick Composer baseline:

```text
[ + ]  Capture what changed…                      [ mic ] [ send ]
```

Expandable controls:

- Camera
- Photos
- Files
- Scan Document
- Scan Text
- Voice
- Date
- Reminder
- Repeat
- Location
- Goal
- Flag / priority
- Details

Full Atmosphere Composer asks:

- What is this?
- Where should it go?
- When does it matter?
- Does it become a Goal, Step, Time boundary, note, proof, reminder, or held item?
- What should Ambitions protect?

Capture must not feel like:

- a floating generic add button;
- a debug route selector;
- a source/proof/receipt console;
- a small modal trapped between nav and keyboard;
- a task creation form copied from Reminders.

### 1.4 Settings becomes You

You is not a runtime manual. It is the native home for profile, command center, security, privacy, appearance, planning defaults, permissions, history, and personal system controls.

You top-level order:

1. Profile header
2. Personal system
3. Planning defaults
4. Sources & permissions
5. Privacy & security
6. Receipts & history
7. Appearance
8. Notifications
9. Export & share
10. Help
11. About

Hard red:

- Runtime jargon on top-level You.
- `runtime-backed`, `fixture-only`, `blocked-pending-model`, or equivalent implementation status in user-facing UI.
- Philosophy cards before controls.
- Long product explanations in settings rows.
- Social profile framing.

### 1.5 Ambitions uses living-object transitions, not page-open transitions

Apple Calendar’s strongest pattern is object continuity. Year -> month -> day does not feel like unrelated pages. Ambitions must use this principle across Time, Goals, and Today.

Time transition chain:

```text
Life range -> Year -> Month -> Week -> Day -> Now window -> Step fit
```

Goals transition chain:

```text
Life areas -> Goal constellation -> Active thread -> Step chain -> Recommended step -> Proof history
```

Today transition chain:

```text
Daily reality -> Current window -> Start Here token -> Step detail -> Closure/proof
```

Hard red:

- Detail routes that do not preserve origin.
- Opening a new screen where the same object should morph, zoom, unfold, or recompose.
- Motion used as decoration instead of continuity/state explanation.

### 1.6 Empty, low-data, and inactive states need grace

Reminders shows no-data states through collapse, dimming, and quiet organization. Ambitions must stop overexplaining emptiness.

Rules:

- Empty states are calm, short, and useful.
- Low-data states prioritize manual action.
- Inactive states collapse, dim, or reduce rather than showing warnings.
- Source-unavailable states do not panic the user.
- Empty Today does not become a system diagnostic.

Hard red:

- `Source unavailable` without user-useful next action.
- Long explanatory empty-state cards.
- Blank dashboard panels.
- “No standalone task is pulling on Today” or similar generic/productivity language.

### 1.7 Steps can have substeps, evidence, attachments, reminders, and repeats, but must not become tasks

Reminders and To Do prove these controls are useful. Ambitions must translate them into Step mechanics.

Ambitions Step mechanics:

```text
Goal
  -> Goal Thread
    -> Step
      -> Substeps
      -> Evidence
      -> Attachments
      -> Reminder
      -> Repeat
      -> Location
      -> Proof
      -> Closure
      -> Next recommended step
```

Hard red:

- Generic checklist-first Step detail.
- Task app metadata shown before fit, context, and goal/thread relationship.
- A Step that has controls but no time-fit, source, closure, or proof behavior.

---

## 2. Reference app translation table

| Source app | Useful pattern | Ambitions translation |
|---|---|---|
| Apple Reminders | Vertical Today ordered by due date | Today uses Reality Meridian ordered by now, recommended step, fixed time, protected window, future pressure |
| Apple Reminders | Scheduled future grouping | Time shows overdue, today, tomorrow, rest of week, rest of month, later months as clean pressure buckets |
| Apple Reminders | Inline add with date/reminder/repeat/location/tag/flag/attachments/scanning | Capture composer exposes Ambitions-native controls for time, reminder, repeat, location, goal, flag, scan, attachment, detail expansion |
| Apple Reminders | Urgent, completed, flagged | Today and Goals support urgent, completed/closed, pinned/protected/waiting sections |
| Apple Reminders | Graceful no-data collapse | Empty/low-data Ambitions states collapse quietly and offer one useful action |
| Microsoft To Do | Steps attached to tasks | Ambitions Steps support substeps under Goal Thread and proof/closure semantics |
| Microsoft To Do | Notes/files/grouping | Step/Goal detail support notes, files, grouped constellations, and proof attachments |
| Microsoft To Do | Themes | You -> Appearance Studio with restrained Ambitions theme variants |
| ChatGPT | Composer quality | Capture uses premium composer, attachment/mic controls, keyboard choreography, expand-to-fullscreen |
| ChatGPT | Settings organization | You becomes native profile/settings/control/security/appearance surface |
| Apple Calendar | Current-time marker | Today and Time use live now marker tied to device time/test injection |
| Apple Calendar | Day/month/year morphing | LifeShape Field and Constellation Atlas evolve between zoom levels instead of disconnected page opens |
| Apple Calendar | Today button | Time, Goals, and future views have contextual return-to-current-reality anchoring |

Hard rule: copy no product category. Translate interaction law only.

---

## 3. Shell interaction law

The Shell is the app-wide navigation and command grammar. It is not decorative chrome.

Shell absorbs:

- root navigation;
- drilldown back behavior;
- search;
- capture;
- view mode;
- Today/current-reality anchor;
- contextual actions;
- keyboard-aware composer behavior;
- root-vs-detail chrome reduction.

Root shell must expose:

- contextual surface header;
- search scoped to the current object;
- capture entry embedded in the shell/composer system;
- floating root nav only for Today / Goals / Time / Motion / You.

Drilldown shell must expose:

- top-left back affordance;
- gesture back;
- focused title/object context;
- no bottom/root nav.

Time-specific shell affordance:

- top-right mode switcher: Field / Day / Week / Month / List.

Hard red:

- persistent dashboard frame behavior;
- global floating plus as primary Capture;
- bottom nav visible in drilldowns;
- keyboard fighting tab bar;
- static header title with no context/action value.

---

## 4. Surface-specific interaction canon

### 4.1 Today / Reality Meridian

Default mode remains Start Here, not a task board.

Today visible layers:

- Now
- Recommended step
- Current available window
- Next fixed point
- Protected boundary
- Urgent pressure
- Completed / closed loop
- Waiting / blocked
- Later today

Today modes:

| Mode | Purpose |
|---|---|
| Start Here | One recommended step and why it fits |
| Meridian | Scrollable day reality with now marker |
| List | Dense chronological steps/events view |
| Completed | Closed steps and proof stitches |
| Urgent | Time-sensitive or consequence-heavy items |
| Protected | Boundaries Ambitions should not violate |

Calendar event block translation:

```text
Calendar: 9:00-10:00 Meeting
Ambitions: 9:00-10:00 unavailable / fixed point
           10:10-10:40 usable light window
           Recommended step fits here
           Recovery needed before next hard edge
```

Hard red:

- Today as task list;
- static now marker;
- hardcoded time;
- CTA stack as first viewport;
- debug/source language before user action.

Primary files:

- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/Features/Today/TodayRealityMeridianFlagshipAdapter.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`
- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`

### 4.2 Capture / Atmosphere Composer

Capture has two forms:

1. Quick Composer for simple intake.
2. Full Atmosphere Composer for complex intent.

Quick Composer must be premium, native, obvious, keyboard-aware, and expandable.

Full Atmosphere Composer resolves:

- Step
- Goal
- Time boundary
- Note
- Proof
- Reminder
- Held item

Hard red:

- generic floating add button;
- tiny modal under keyboard;
- debug route selector;
- receipt/proof/source console;
- task-form clone.

Primary files:

- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift`
- `Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`
- `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`

### 4.3 Time / LifeShape Field

Time borrows Calendar orientation, not Calendar visual blocks.

LifeShape levels:

```text
Life range
Year
Month
Week
Day
Now window
Step fit
```

Time shows:

| Layer | Meaning |
|---|---|
| Fixed points | Calendar events, appointments, deadlines |
| Open capacity | Usable time windows |
| Protected time | Do-not-touch recovery/boundary windows |
| Pressure | Deadlines, urgency, compression |
| Energy fit | Whether a step matches available capacity |
| Recovery | Required buffer before more work |
| Future scheduled steps | What Ambitions placed/recommends |
| Past due | Items that still matter after window loss |

Required modes:

- Field
- Day
- Week
- Month
- List

Hard red:

- calendar clone;
- event-block visual as primary model;
- source/proof/receipt columns on first viewport;
- vertical text wrapping;
- top-level Reflow preview.

Primary files:

- `Native/Ambitions/Features/Time/TimeScreen.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/Ambitions/Features/Time/TimeLifeSuiteState.swift`
- `Native/Ambitions/Features/Time/TimeReflowDecisionState.swift`
- `Native/Ambitions/Features/Time/TimeFeatureModels.swift`
- `Native/Ambitions/Features/Time/WeeklyReviewScreen.swift`

### 4.4 Goals / Constellation Atlas

Goals can borrow grouping and substep utility, but not task-app structure.

Goals exposes:

- Life areas
- Active goals
- Current thread
- Recommended step feeding Today
- Upcoming step chain
- Proof history
- Blocked/waiting steps
- Completed milestones
- Pinned/urgent goals

Task-app translation:

```text
To Do task with steps
-> Ambitions Goal
  -> Thread
    -> Step
      -> Substeps
      -> Proof
      -> Closure
      -> Next recommended step
```

Hard red:

- generic goals dashboard;
- ranked life score;
- empty life-area boxes;
- raw source/proof/receipt metadata in first viewport;
- checklist-first goal detail.

Primary files:

- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- Goal detail files

### 4.5 Motion / Motion Current

Motion answers:

```text
What changed?
Where can I re-enter?
What needs recovery?
What proof tells me this movement is real?
```

Hard red:

- analytics dashboard;
- static proof/recovery/re-entry ledgers;
- debug continuity dock;
- activity feed;
- XP/progress score/streak.

Primary files:

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- Motion projector/state files
- proof/recovery primitive files

### 4.6 You / User System Profile

You is native profile/settings/control/security/appearance. It should feel closer to iOS Settings than to an internal runtime document.

Top-level You structure:

1. Profile header
2. Personal system
3. Planning defaults
4. Sources & permissions
5. Privacy & security
6. Receipts & history
7. Appearance
8. Notifications
9. Export & share
10. Help
11. About

Hard red:

- runtime manual;
- implementation status words;
- product philosophy cards above controls;
- verbose trust/source/proof text on top level;
- social profile framing.

Primary files:

- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Domain/YouModels.swift`
- `Native/Ambitions/Domain/YouPlanningDefaultsModels.swift`
- `Native/Ambitions/Features/You/YouAvailabilityCenterCard.swift`
- `Native/Ambitions/Features/You/YouPlanningDefaultsSectionCard.swift`
- `Native/Ambitions/Features/You/YouTrustHistoryCenterCard.swift`
- `Native/Ambitions/Features/You/YouCrossSurfaceProofReviewCard.swift`
- `Native/Ambitions/Features/You/YouViewModel.swift`

---

## 5. Search canon

Search is global but scoped by default.

| Surface | Search finds |
|---|---|
| Today | Steps, closures, scheduled items, proof from today |
| Goals | Goals, threads, milestones, substeps, proof |
| Capture | Recent captures, unplaced captures, attachments |
| Time | Dates, windows, scheduled steps, fixed points |
| You | Settings, permissions, history, receipts, appearance controls |

Rules:

- Search is a shell affordance, not a default top-level search bar.
- Search opens over the current object first.
- Global expansion is optional.
- Search must not become a diagnostic “what Ambitions knows” page by default.

---

## 6. Closure canon

Basic closure must be fast:

```text
Done
Still counts
Move it
Blocked
Not needed
```

Advanced closure is progressive:

```text
Add proof
Add note
Recover
Reschedule
Change goal
Review later
```

Rules:

- Step identity remains visible.
- Closure is not a taxonomy exam.
- Completion can attach proof, note, file, photo, reminder, repeat, and next step.
- Closure must visibly mutate Today.

---

## 7. Appearance canon

Appearance Studio may support restrained variants:

- Graphite
- Deep Navy
- Low Light
- Warm Ember
- Celestial Minimal
- High Contrast

Rules:

- Custom photos are future-cautious and must not break the premium identity.
- Visual personalization cannot destroy contrast, hierarchy, or native feel.
- Ambitions must not become a theme playground.

---

## 8. Living-object transition canon

Same object evolves. Avoid disconnected route stacks.

Required transition behaviors:

- Time zooms between Life range / Year / Month / Week / Day / Now / Step fit.
- Goals zooms between Life areas / Constellation / Active thread / Step chain / Proof history.
- Today moves between Day reality / Current window / Start Here / Step detail / Closure proof.
- Drilldown preserves origin and return path.
- Reduce Motion gets equivalent static state/relationship labels.

---

## 9. UI reconstruction batch implications

Every report-repair batch must state which native interaction law it satisfies.

Required mapping:

| Batch area | Required canon application |
|---|---|
| Shell | root-vs-drilldown law, no bottom nav in detail, contextual header |
| Today | live time legibility, Reality Meridian, graceful empty state |
| Capture | composer quality, keyboard choreography, expand-to-fullscreen |
| Time | LifeShape zoom levels, live now marker, future buckets, no calendar clone |
| Goals | Constellation Atlas, substeps as Step mechanics, no generic task list |
| Motion | Motion Current as re-entry/recovery/proof object, not analytics |
| You | native Settings/Profile hierarchy, not runtime manual |
| Shared components | object-stage surfaces, non-card primitives, accessibility gates |
| Screenshot proof | fail-closed visual evidence after UI-affecting changes |

---

## 10. Final design gate

Every surface must pass this question:

```text
Could a user understand what this screen does before reading Ambitions-specific vocabulary?
```

If no, the screen is still too internal.

Implementation must repair toward native object operation before adding more Ambitions vocabulary, proof language, or runtime explanation.
