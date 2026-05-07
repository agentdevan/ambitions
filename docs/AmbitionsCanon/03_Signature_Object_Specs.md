# 03 — Signature Object Specs

Status: locked direction, pre-visual-validation, docs-only.

Purpose:

- Reality Meridian
- Start Here Surface
- Atmosphere Composer
- LifeShape Field
- Constellation Atlas
- Orbital Lens
- User System Profile

Every object requires purpose, anatomy, data model direction, state model, interaction model, accessibility behavior, motion behavior, preview fixtures, acceptance criteria, and Hard Reds.

This document does not implement app behavior.

---

## 1. Source-Truth Priority

1. Ambitions Design System
2. Canon Index / 10-10 Maturity Gate
3. Product Canon
4. Continuity Layer & Chrome
5. Signature Object Specs
6. Trust / Privacy / Automation
7. Accessibility / Motion / Performance
8. QA / Preview / Visual Drift
9. Native Shell / Tokens / Materials
10. Implementation / Codex / Repo Integration
11. Visual references
12. Existing repo convenience

---

## 2. Signature Object Thesis

Signature Objects are the Ambitions-native product inventions.

They are not generic components. They are first-class product objects with purpose, state, interaction, trust, accessibility, motion, and preview requirements.

Primitives provide consistency. Signature Objects are the product.

A top-level screen is mature only when its primary Signature Object is dominant, useful, accessible, and unmistakably Ambitions-specific.

No Signature Object may proceed to implementation from visual mock alone.

---

## 3. Universal Signature Object Requirements

Every Signature Object must define:

1. purpose
2. user job
3. canon role
4. anatomy
5. data model
6. state model
7. interaction model
8. motion model
9. accessibility behavior
10. empty state
11. loading state
12. error/recovery state
13. trust/receipt behavior where relevant
14. preview fixtures
15. anti-patterns
16. acceptance criteria
17. Hard Red failures

---

## 4. Product Object Acceptance Matrix

| Object | Must prove | Hard Red failure |
| --- | --- | --- |
| Reality Meridian | Now / Next / Later feel inhabited, not listed | generic task list or calendar timeline |
| Start Here Surface | one primary action emerges from active Meridian node | detached card / Begin Focus / AI prompt |
| Constellation Atlas | equal-weight life areas with user order/pin/hide/rename | KPI dashboard, ranked life score, astrology |
| Orbital Lens | selected area focus preserves wider life context | isolated goal dashboard |
| Atmosphere Composer | quiet composer-first capture with route reveal after input | notes feed, inbox, chatbot, category board |
| LifeShape Field | open time, goal time, protected time, pressure are legible | calendar clone or analytics dashboard |
| User System Profile | native settings-like control of planning, trust, privacy | social profile, admin console, hidden trust |

---

## 5. Reality Meridian

### Purpose

Reality Meridian is Today’s flagship object. It turns the current day into an inhabitable execution surface.

It shows what fits now, what comes next, what remains later, and what still counts.

It must not become a task list, calendar timeline, dashboard, habit tracker, or productivity score surface.

### User Job

The user should be able to answer:

- What matters now?
- What can fit now?
- What comes next?
- What remains later?
- What changed?
- What still counts?
- Why is this recommended?

### Relationship to Start Here

Reality Meridian is the primary object. Start Here is the action surface that emerges from the active Meridian node.

Start Here may not be a detached card stack. It is physically, visually, semantically, and accessibly connected to the active Now / Next / Later state.

### Anatomy

Required:

1. Meridian trace
2. Now node
3. Next node
4. Later region
5. active step anchor
6. Start Here action surface
7. closure state affordance
8. Trust Seam connection
9. receipt/proof mark
10. Quiet Reflow prompt region when needed

Optional:

- protected block marker
- pressure hint
- goal thread trace
- capacity readout

Forbidden:

- full task list
- overdue section
- stacked productivity cards
- KPI tiles
- generic timeline rows
- motivational widget

### Data Model Direction

```swift
struct RealityMeridianModel {
    var date: Date
    var now: MeridianMoment
    var next: MeridianMoment?
    var later: [MeridianMoment]
    var recommendedStep: StepRecommendation?
    var openCapacity: TimeInterval?
    var protectedBlocks: [ProtectedBlock]
    var pressureState: PressureState?
    var receipts: [ReceiptReference]
    var reflowPrompt: ReflowPrompt?
}
```

### Required States

- empty day
- no schedule connected
- manual plan available
- now open
- active step live
- next soon
- pressure soon
- protected time active
- missed but recoverable
- still counts
- blocked
- waiting
- receipt available
- trust open
- reflow suggested
- error / source unavailable

### Interaction Model

Primary actions:

- Start now
- Open step
- Adjust plan
- Why this?
- Still counts
- Move this
- Shorten
- Waiting
- Blocked

Rules:

- primary action must be visible when a recommendation exists
- Why this? routes through Trust Seam
- closure states must be calm and reversible where appropriate
- reflow preview must show the affected object, not an abstract warning
- Later is summarized by default and expands only on intent

Forbidden copy:

- Begin Focus
- next best move
- best next move
- overdue
- failed
- productivity dropped
- streak broken

### Motion

Allowed:

- active node soft breathing only when genuinely live
- trace draw when relationship becomes visible
- Start Here emerges from active node
- Trust Seam opens from proof mark
- Reflow preview animates only affected node/segment

Reduced Motion:

- no breathing
- no line drawing dependency
- Start Here appears through native transition/fade
- reflow uses before/after state
- active state is text + static marker

### Accessibility

VoiceOver example:

```text
Today. Now has 30 minutes open. Recommended step: Draft proposal outline, 25 minutes, connected to Career. Next: meeting at 2:00. Later: one protected block remains. One receipt available.
```

Required:

- Now / Next / Later exposed as structured groups
- recommended step includes duration and source
- active node has selected/current semantics
- closure actions are accessible actions
- receipt mark has accessible label and target
- pressure/protected states do not rely on color
- Start Here is announced as emerging from current recommendation

Hard Red:

- user must interpret visual meridian to understand day
- active state is glow-only
- receipt is visual-only
- closure actions are hidden from VoiceOver

### Preview Fixtures

- TodayEmptyManual
- TodayNowOpenCapacity
- TodayRecommendedStepReady
- TodayActiveStepLive
- TodayNextSoon
- TodayProtectedBlockActive
- TodayPressureSoon
- TodayMissedStillCounts
- TodayBlocked
- TodayWaiting
- TodayNeedsRecovery
- TodayReceiptPlanAdjusted
- TodayTrustWhyThisOpen
- TodayCalendarDeniedManualFallback
- TodayLargeText
- TodayReduceMotion

### Acceptance Criteria

Reality Meridian passes only if Today feels live without feeling busy, Now / Next / Later are understandable visually and nonvisually, Start Here emerges from active node, source path exists, shame language is absent, receipts are inspectable, and the object could only belong to Ambitions.

---

## 6. Start Here Surface

### Purpose

Start Here is Today’s action surface. It converts the Reality Meridian’s active node into the next useful user action.

Start Here is not a card, widget, focus panel, motivational module, or productivity prompt. It is the action expression of the current Meridian state.

### Ownership

Reality Meridian owns the current day structure. Start Here owns recommendation presentation, primary CTA, immediate alternatives, source access through Why this?, closure/recovery affordances, and action receipt handoff.

Trust Seam owns explanation depth. Quiet Reflow owns mismatch adjustment. Receipt Surface owns proof after action.

### Anatomy

Required:

1. active-node anchor
2. recommendation label
3. step title
4. duration or effort indication when available
5. primary action
6. one quiet secondary action max
7. Why this? control
8. closure/recovery entry when needed
9. receipt/proof handoff after action

Forbidden:

- detached generic card
- multiple competing CTAs
- focus-session branding
- motivational quote
- productivity score
- AI assistant label
- dense metadata stack

### Approved Copy

- Start here
- Recommended step
- Start now
- Open step
- Adjust plan
- Why this?
- Still counts
- Move this
- Shorten
- Waiting
- Blocked

Forbidden:

- Begin Focus
- best next move
- next best move
- AI recommends
- optimize your day
- crush your goals
- overdue
- failed

### Required States

- no recommendation
- recommendation ready
- active step live
- source available
- source uncertain
- user declined recommendation
- action started
- action completed
- still counts
- moved
- shortened
- waiting
- blocked
- needs recovery
- receipt available

### Interaction

Primary CTA rules:

- If a step can begin now: Start now.
- If a step requires detail first: Open step.
- If the plan no longer fits: Adjust plan.
- If the step was partially done: Still counts.

Secondary action rules:

- max one visible secondary action by default
- additional actions route through Quiet Reflow or detail
- Why this? always routes through Trust Seam

### Accessibility

VoiceOver example:

```text
Start Here. Recommended step: Draft proposal outline, 25 minutes. Source: Career goal and 30 minutes open now. Button: Start now. More information available: Why this?
```

### Motion

Start Here may emerge from active Meridian node. Reduced Motion uses static origin indicator, native/fade presentation, and preserved text relationship.

### Acceptance Criteria

Start Here passes only if it is visibly connected to the active node, presents one primary next action, exposes Why this?, avoids shame and productivity-pressure language, does not look like a detached card stack, supports large Dynamic Type, and preserves the active-node relationship under Reduced Motion.

Hard Red:

- Start Here becomes a generic card.
- Start Here contains chatbot/AI framing.
- Start Here hides source or recovery path.
- Start Here uses Begin Focus.

---

## 7. Atmosphere Composer

### Purpose

Atmosphere Composer is Capture’s primary object. It gives the user a quiet, native, low-pressure place to capture anything without turning Capture into a notes feed, inbox, chatbot, category picker, or task board.

### Canon Role

Capture is the quiet intake surface.

Required screen elements:

- Capture header / Context Crown
- open Celestial Field
- Capture anything hero phrase
- short subtitle
- bottom composer
- plus action inside composer context
- mic inside field/composer context
- Continuity Dock

### Anatomy

Required:

1. open atmospheric field
2. concise hero phrase
3. bottom composer field
4. text input
5. plus action within composer
6. mic action within composer or equivalent native position
7. post-capture route reveal
8. Trust Seam only after classification or automation

Forbidden:

- notes list
- inbox
- chat transcript
- category grid by default
- task board
- assistant prompt wall
- top-level plus tab

### Required States

- empty quiet field
- typing
- dictating
- captured locally
- classifying
- high-confidence route reveal
- low-confidence Needs a Place
- Ready to Place
- Grow into Goal
- source/automation explanation available
- error saving capture

### Route Reveal Rules

High confidence: show immediate route choices, limited and calm, with Trust Seam explanation available.

Low confidence: receipt-first confirmation labeled Needs a Place; do not overfit or pretend certainty.

Approved route labels:

- Needs a Place
- Ready to Place
- Grow into Goal

### Keyboard Behavior

Required:

- keyboard rise is native
- composer stays visible
- atmosphere compresses calmly
- no layout jump
- no hidden primary input
- dictation/mic state remains understandable

### Accessibility

VoiceOver example:

```text
Capture anything. Text field. Add a thought, task, plan, or idea. Button: dictate. Button: add.
```

After capture:

```text
Captured. Needs a Place. You can place it later, grow it into a goal, or review suggested routes.
```

### Motion

Allowed: composer rise with keyboard, atmosphere compression around input, route trace after capture, Trust Seam opening after classification.

Forbidden: particle celebration, chatbot typing animation, dramatic zoom, category cards flying in, animated AI classification theatre.

Reduced Motion: native keyboard, no route trace dependency, Trust Seam uses disclosure transition.

### Preview Fixtures

- CaptureEmptyQuietField
- CaptureTypingKeyboardVisible
- CaptureDictating
- CaptureCapturedLocal
- CaptureClassifying
- CaptureHighConfidenceRoutes
- CaptureNeedsAPlace
- CaptureReadyToPlace
- CaptureGrowIntoGoal
- CaptureSaveError
- CaptureTrustClassificationOpen
- CaptureLargeTextKeyboard
- CaptureReduceMotion

### Acceptance Criteria

Atmosphere Composer passes only if Capture feels quiet enough for thought to arrive, composer is primary, route reveal appears only after input/capture, classification preserves trust and uncertainty, keyboard feels native, and VoiceOver can complete the capture flow.

Hard Red:

- Capture tab icon is plus
- Capture shows default notes feed
- Capture leads with AI chat
- route classification is overconfident
- keyboard covers composer

---

## 8. LifeShape Field

### Purpose

LifeShape Field is Plan’s primary object. It helps the user understand and shape open time, goal time, protected time, pressure, and planning horizon without becoming a calendar clone.

Plan should feel like the user shapes the week like a living field, not a grid of appointments.

### Anatomy

Required:

1. scope control: Day / Week / Month
2. LifeShape Field visual field
3. open time expression
4. goal time expression
5. protected time expression
6. pressure expression
7. shaping action
8. review pressure action when needed
9. Trust Seam connection for source/explanation
10. Quiet Reflow preview region

Forbidden:

- calendar clone as primary surface
- KPI dashboard
- stacked metric cards
- heatmap-first design
- business analytics charts
- productivity score
- red warning system

### Required States

- week default
- day pressure
- month shaping
- open capacity available
- low capacity
- protected time active
- pressure Friday / pressure day
- schedule source unavailable
- calendar permission not granted
- manual-only planning
- reflow preview
- plan adjusted receipt
- source conflict
- empty plan
- loading capacity
- error reading schedule

### Data Model Direction

```swift
struct LifeShapeFieldModel {
    var horizon: PlanningHorizon
    var openTime: [CapacityBlock]
    var goalTime: [GoalTimeBlock]
    var protectedTime: [ProtectedBlock]
    var pressure: [PressurePoint]
    var sourceState: PlanningSourceState
    var reflowPreview: ReflowPreview?
    var receipts: [ReceiptReference]
}
```

### Interaction

Primary actions:

- Shape week
- Review pressure
- Adjust plan
- Protect this block
- Move this
- Shorten
- Open time
- Goal time

Shaping changes preview before apply unless user has approved defaults. Meaningful change leaves receipt.

### Accessibility

VoiceOver example:

```text
Plan. This week. 6 hours open, 3 hours goal time, 2 protected blocks. Pressure is highest Friday afternoon. Button: Review pressure. Button: Shape week.
```

Rules:

- pressure cannot be color-only
- protected time must be announced as protected, not blocked
- field visuals require list/summary equivalents
- reflow preview must announce before/after impact

### Motion

Allowed: LifeShape morph, pressure expansion from touched point, protected block emphasis, reflow preview affecting only changed region.

Reduced Motion: no morph dependency; before/after textual summary; static field update.

### Preview Fixtures

- PlanWeekDefault
- PlanDayPressure
- PlanMonthShaping
- PlanOpenCapacity
- PlanLowCapacity
- PlanProtectedBlocks
- PlanPressureFriday
- PlanCalendarDeniedManual
- PlanSourceConflict
- PlanReflowPreview
- PlanReceiptAdjusted
- PlanLargeText
- PlanReduceMotion

### Acceptance Criteria

LifeShape Field passes only if Plan avoids calendar clone, open/goal/protected/pressure are understandable, Week default is useful, Day/Month appear adaptively, reflow preview is clear, source/permission states are inspectable, and accessibility summary preserves meaning.

Hard Red:

- primary Plan UI is calendar grid
- metrics become dashboard tiles
- pressure is red alert behavior
- protected time reads as failure/blockage
- reflow changes schedule silently

---

## 9. Constellation Atlas

### Purpose

Constellation Atlas is Goals’ primary object. It shows life areas as an equal-weight atlas that the user can inspect, reorder, pin, hide, rename, and evolve.

Goals must not become a KPI dashboard, habit-ring surface, ranked life score, astrology visual, or performance category system.

### Default Life Areas

- Music
- Fitness
- Money
- Relationships
- Career
- Health
- Learning
- Home
- Creative
- Personal Growth

Rules:

- user can reorder
- user can pin
- user can hide
- user can rename
- system never ranks life areas by default
- no area visually dominates unless user selected or pinned it

### Anatomy

Required:

1. atlas field
2. life-area constellation points
3. selected area state
4. pinned area treatment
5. user order / arrangement logic
6. Orbital Lens entry
7. goal-thread trace when relevant
8. Trust Seam connection for recommended step/source

Forbidden:

- KPI dashboard
- progress rings as primary language
- habit streaks
- life score
- ranked categories
- astrology aesthetic
- decorative star map with no data meaning
- business analytics chart

### Required States

- no goals yet
- default life areas
- reordered areas
- pinned area
- hidden area
- selected area
- active goal thread
- recommended step feeding Today
- no active thread
- source unavailable
- loading goals
- error loading goals

### Interaction

Primary actions:

- Select area
- Open area
- Pin area
- Reorder areas
- Hide area
- Rename area
- Open goal thread

Selection expands into Orbital Lens. Pinning is user control, not system ranking. Recommended Today step must connect back through Trust Seam or thread trace.

### Accessibility

VoiceOver example:

```text
Goals. Life areas. Music, pinned. Fitness. Money. Relationships. Career. Health. Learning. Home. Creative. Personal Growth. Music has one active goal thread feeding Today.
```

### Motion

Allowed: selected constellation focus, Orbital Lens expansion from selected area, meaningful thread trace, calm reorder movement.

Reduced Motion: static focus, native push/inline expansion, text + static trace.

### Preview Fixtures

- GoalsDefaultLifeAreas
- GoalsNoGoalsYet
- GoalsPinnedArea
- GoalsReorderedAreas
- GoalsHiddenArea
- GoalsSelectedArea
- GoalsOrbitalLensOpen
- GoalsThreadFeedingToday
- GoalsSourceUnavailable
- GoalsLargeText
- GoalsReduceMotion

### Acceptance Criteria

Constellation Atlas passes only if life areas feel like an atlas, user order/pin/hide/rename is clear, surrounding areas remain respected, constellation visuals have product meaning, accessibility exposes full structure, and the object avoids astrology/KPI/habit drift.

Hard Red:

- system ranks life areas by default
- habit rings dominate
- decorative constellations have no meaning
- Goals becomes dashboard
- nonvisual user cannot understand area relationships

---

## 10. Orbital Lens

### Purpose

Orbital Lens is the focused inspection surface for a selected life area inside Goals. It helps the user inspect goals, goal threads, relevant steps, and Today connections without losing context of the wider Constellation Atlas.

### Anatomy

Required:

1. selected life-area title
2. selected-area orbit/focus field
3. active goal threads
4. recommended step connection if present
5. source/Trust Seam entry
6. surrounding-area context or route back
7. primary action appropriate to area state

Forbidden:

- isolated dashboard detail
- progress-score panel
- motivational coaching card
- generic list of goals as whole surface

### Required States

- selected area empty
- one active goal thread
- multiple goal threads
- goal thread feeding Today
- archived/completed goal
- no recommendation
- source uncertain
- loading
- error

### Interaction

Primary actions:

- Open thread
- Add goal thread
- Connect to Today
- Why this?
- Back to Atlas

### Accessibility

VoiceOver example:

```text
Music selected. Two active goal threads. One thread has a recommended step for Today: Practice bridge section, 20 minutes. Button: Open thread. Button: Why this?
```

### Acceptance Criteria

Orbital Lens passes only if it emerges from selected atlas area, preserves wider life context, connects goal threads to Today when relevant, avoids KPI/list dominance, and has complete nonvisual behavior.

Hard Red:

- Orbital Lens becomes generic goal-detail dashboard
- progress score dominates
- selected area relationship is visual-only

---

## 11. User System Profile

### Purpose

User System Profile is You’s primary object. It gives the user practical, native-feeling control over planning setup, preferences, privacy, automation, and trust.

You is intentionally the most iOS Settings-like top-level surface.

### Locked Structure

Planning Setup:

- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust

Account & Preferences:

- Notifications
- Capture Preferences
- Focus & Session Defaults
- Privacy

Support / System:

- Help
- About Ambitions

### Anatomy

Required:

1. practical profile/system header
2. grouped navigation
3. current automation posture summary
4. privacy/source control path
5. planning setup path
6. native disclosure rows
7. Trust Seam route when arriving from adaptive behavior

Forbidden:

- social avatar/profile emphasis
- family section by default
- search field by default
- AI coach controls
- dashboard metrics
- gamified progress identity

### Automation & Trust Requirements

Automation & Trust must expose:

- current automation level
- source permissions
- calendar permission state
- recommendation behavior
- receipt history
- approved defaults when available
- undo/revert explanation
- privacy controls

### Required States

- default user profile
- manual automation
- suggest automation
- preview reflow automation
- calendar denied
- calendar granted
- calendar stale/error
- receipt archive
- privacy controls
- large text
- increase contrast

### Accessibility

You should follow native grouped navigation semantics. VoiceOver must announce group headers, row names, summaries, permission state, automation level, and destructive/privacy-sensitive controls clearly.

### Preview Fixtures

- YouDefault
- YouManualAutomation
- YouSuggestAutomation
- YouPreviewReflowAutomation
- YouCalendarDenied
- YouCalendarGranted
- YouReceiptArchive
- YouPrivacyControls
- YouLargeText
- YouIncreaseContrast

### Acceptance Criteria

User System Profile passes only if it feels like premium iOS settings, exposes trust/automation clearly, avoids social/profile/dashboard drift, gives users control over adaptive behavior, and supports object-local Trust Seam routes into global controls.

Hard Red:

- You becomes social profile
- automation controls are hidden
- privacy settings are vague
- trust history is inaccessible
- search/admin-console behavior dominates

---

## 12. Signature Object Hard Reds

Stop and repair if any are true:

1. Today becomes task list, calendar timeline, or focus widget.
2. Start Here becomes detached generic card.
3. Capture becomes notes feed, inbox, chatbot, category board, or plus-tab app.
4. Plan becomes calendar clone, heatmap, or analytics dashboard.
5. Goals becomes KPI dashboard, habit ring system, astrology, or ranked life score.
6. You becomes social profile, family hub, or admin console.
7. Any primary object requires visual-only interpretation.
8. Any adaptive object lacks source/explanation/control.
9. Any object lacks empty/loading/error/recovery state.
10. Any object uses shame/productivity-pressure copy.
11. Any object violates native iPhone behavior to appear more visually novel.
12. Any object cannot produce preview fixtures for major states.
