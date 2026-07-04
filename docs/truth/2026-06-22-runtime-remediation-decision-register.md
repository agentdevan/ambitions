# 2026-06-22 Runtime Remediation Decision Register

**Status:** Canonical decision register for the 2026-06-22 runtime QA remediation.  
**Owner posture:** Permanent product, architecture, implementation, QA, and proof truth for this remediation run.  
**Evidence path:** `docs/qa/evidence/2026-06-22-device-review/`.

This file is the comprehensive decision register from the runtime remediation planning. It is permanent product / architecture / implementation truth for this remediation run.

---

## 1. Codex operating model

Codex must not be given vague issues like “fix Capture” or “make Goals better.”

Codex receives:

1. Global Remediation Law first.
2. One execution-bundle dossier at a time.
3. QA leaves as acceptance criteria, not as design prompts.

Codex may decide:

- exact low-level Swift implementation mechanics
- local refactors needed to make the scoped train compile
- test structure when equivalent proof is preserved

Codex may not decide:

- product behavior
- visual direction
- IA
- copy density
- route behavior
- fake-state policy
- proof standards
- what “fixed” means

Parent train = architecture / product decision layer.

Execution bundle = what Codex implements.

QA leaves = acceptance criteria / proof checklist.

Execution-bundle order:

1. Theme / Design System Tokens
2. Shell / Stage OS
3. Capture Routing + Composer
4. Goals Root / Detail Rebuild
5. Today Reality Window / Action Gating
6. Search Find / Act / Inspect
7. Time Native Life Calendar
8. You Settings / Appearance / Privacy
9. Final Proof / Accessibility / Release Gate
10. Register Sync / Control Closeout

Runtime honesty:

- Runtime app paths must be real.
- No fake success.
- No fake placement.
- No dead mic.
- No fake proof.
- No fake “step placed.”
- No placeholder route that pretends to work.
- If unavailable: build the real path, hide it, disable it honestly, or show an honest unavailable state.

Status ceiling:

- No validation = Red
- Source/test only = Source Green / Runtime Yellow max
- Simulator-only visual proof = Visual Yellow max
- Device screenshot/video + tests + docs update = Candidate Runtime/Visual Green
- Owner acceptance = Done

---

## 2. Task / Step / Goal / Thought law

Ambitions is not avoiding tasks.

Ambitions must be capable of being the best task app as a contained feature.

But tasks/free-floating steps are not the whole product, not the brand frame, and not the root IA.

Runtime objects:

- Goal = durable direction
- Step = actionable unit
- Free-floating Step = valid when no goal currently fits
- Thought = valid modular capture destination
- Life Area = default or custom organizing domain
- Capture = global intake + resolver + creation flow for all of the above

Free-floating steps have equal validity to goal-linked steps in Today and Time.

Conflicts should be resolved during Capture, pathing, Time Fit, or Goal Detail, not by demoting free steps.

---

## 3. Theme / Design System decisions

Theme architecture:

- Full design-system package layer.
- Do not scatter color extensions or hard-coded styles.
- Build semantic color tokens, material tokens, spacing tokens, typography tokens, motion tokens, haptic semantics, and semantic glyph registry.
- Light and Dark must come from one semantic token model.

Light Mode:

- Native Apple luminous graphite-on-mist.
- Mist, pearl, pale graphite, restrained celestial warmth, high contrast.
- No washed-out grey.
- No generic white utility UI.

Dark Mode:

- Rebuild Dark and Light from one semantic model.
- Do not patch Light around dark-mode assumptions.

Foundation proof:

- screenshot matrix
- token audit
- safe-area audit
- Dynamic Type
- Light/Dark/System live-switch proof
- route proof that navigation, Capture access, and Search access still work

---

## 4. Shell / Stage OS decisions

Shell = Stage OS.

Shell owns:

- navigation
- route depth
- global gestures
- Capture/Search access
- safe-area behavior
- motion
- haptics
- accessibility actions
- semantic glyphs

Bottom navigation:

- four separate floating icon-only buttons
- structurally coordinated by an invisible rail
- active state = accent-colored icon only
- no visible labels by default
- no rings
- no underline
- no glow
- no badge
- no capsule
- no dock border

Labels may appear only in:

- first-run teaching
- long press
- accessibility

Capture/Search:

- no persistent Capture button
- no persistent Search button
- Capture access: long press empty Stage, optional advanced edge gesture after onboarding if conflict-free, App Shortcut, keyboard command, VoiceOver custom action, first-run teaching.
- Search access: pull-down from Stage, keyboard command, App Shortcut, VoiceOver custom action, first-run teaching.

Gesture priority:

1. system gestures
2. accessibility
3. active control gestures
4. route gestures
5. shell gestures

Dock visible only on root surfaces.

Dock hidden in drilldowns and global flows.

Capture hides dock.

Search hides dock.

Goal Detail hides dock.

Area Detail hides dock.

Time Fit hides dock.

Safe area:

- Stage background full-bleeds.
- Interactive chrome respects true status/gesture safe zones.
- No artificial shelves.
- No status bar collision.

Motion:

- restrained material continuity
- Stage morphs communicate route depth
- Reduce Motion alternate path required

Haptics:

- tab switch
- capture open
- search open
- commit receipt
- invalid action
- protection set
- must respect system/user haptics settings

Semantic glyph registry:

- app-wide semantic glyph registry using SF Symbols now
- custom Ambitions glyphs later

---

## 5. Capture Routing + Composer decisions

Capture architecture:

- typed Capture routing
- Capture is a flow engine
- entry points pass typed context and skip known steps
- broad first-class intents, controlled by typed routes

Required intents:

- free
- goal seed
- step seed
- proof
- time protect
- note/thought
- constraint/fixed point
- attachment/context capture

No `Task` language.

Presentation:

- full-screen Stage takeover
- not sheet
- not tab
- not floating card

Root composer:

- field-first atmospheric canvas
- no placeholder text
- spatial cursor
- iconography
- ambient input affordances
- one-time gesture teaching
- no route categories while typing

Voice:

- no custom mic/transcription system now
- system keyboard dictation only
- visible microphone affordance must invoke native keyboard dictation through text input path if supported, or be absent
- no dead mic icon

Attachments:

- real local capture attachments
- attachment role depends on destination: proof, reference, source, context

Flow:

Composer -> optional context/depth collection -> Proposal -> Commit/Receipt

Contextual Goals `+` example:

Tap + inside Work life area:

- opens global Capture full-screen Stage takeover
- intent = Goal
- lifeArea = Work
- skips destination picker
- starts at goal-direction capture
- collects richer context
- proposal/confirmation
- creates real goal thread
- returns to Goals Work area

Goal seed collects:

- direction
- why
- life area
- constraints/current reality
- first possible step
- timing/pathing context

One-step goal:

- Proposal suggests Step with option to make Goal.
- This solves one-step goal/task behavior without user-facing `Task`.

Unresolved destination:

- user can create new goal
- create custom life area
- create thought
- create free-floating step
- create held capture item
- do not force one of four rigid categories
- do not use junk drawer framing

Receipt:

- ambient proof stitch
- destination
- change destination
- undo
- inspect

Resolver explanation:

- hidden behind glyph by default
- user touches glyph
- inline field reveals explanation

Persistence proof:

- create capture
- reload/reopen store
- object still exists
- route/inspect object still works

---

## 6. Goals Root Atlas decisions

Goals root = broad customizable Life Area Atlas.

Life areas are the root object.

Goals, steps, thoughts, proof, receipts, settings, and history live inside area drilldowns.

Goals root is not:

- goal list
- constellation gimmick
- dashboard
- report card
- diagnostic console

Primary job:

- show where life is currently pulling
- show broad life areas
- surface active direction without turning into a list

Default life areas:

- Work
- Body
- Home
- People
- Self
- Future

Each can be:

- renamed
- hidden
- reordered
- assigned icon
- customized

Life area form:

- simple
- modern
- elegant
- can behave as tappable region / refined tile / collapsible atlas zone
- must not become generic cards

Empty default areas:

- visible even when empty
- quiet region
- icon/name
- minimal create affordance
- no fake example content
- no empty grey card

Area drilldown owns depth:

- goals
- free-floating steps
- thoughts
- proof
- receipts
- sources/context
- area settings
- accomplished goals/history

Held capture area:

- valid modular holding area
- not Inbox
- not junk drawer
- where unresolved captures wait for shape

Life areas are never done.

Goals can be accomplished. Life areas cannot.

Today relationship:

- if a goal/step is planned for Today, area/thread gets minimal focus highlight/lift
- no visible `Feeds Today` copy

Time relationship:

- not on root
- Time links appear inside area drilldown

Search:

- global Search handles Goals search
- no Goals-specific search field

Tap:

- life area opens full-screen area detail
- goal thread may inline preview only if elegant; otherwise direct full-screen Goal Detail on iPhone

Custom area creation:

- root quick-create
- Capture Proposal create-new-area

Area customization:

- long press quick rename/hide/reorder
- area detail for deeper customization

Icons:

- SF Symbols through mapping layer now
- custom glyphs later

No root percentages.

Movement/proof/accomplished state only.

Metrics live in inspection/detail.

---

## 7. Goal Detail / Path Timeline decisions

Goal Detail combines:

- goal profile
- goal path operation surface
- historical journal

Central object:

- horizontal/scrubbable path field
- anchored nodes
- past proof/history left
- current step center
- future path right

Default focus: current step.

If no current step exists, focus on choosing next step.

Node types:

- Proof
- Step
- Decision
- Recovery
- Pause
- Accomplished

Past proof editing:

- append correction
- do not overwrite original proof
- original receipt remains inspectable

Late proof:

- can attach to historical node
- may reflow entire goal path

Future path editing:

- move
- replace
- pause
- delete
- split
- locally/deterministically regenerate/propose future path
- preserve history

Deleting future step:

- offer Remove or Mark skipped depending on history/proof

Deleting goal:

- hard delete only if no proof/history
- archive/accomplish otherwise

Modifying direction:

- creates direction revision event
- large changes offer “make this a new goal”

Accomplished:

- goal becomes Accomplished
- proof/history preserved
- optional next direction prompt
- share/create output option
- no gamified celebration

Today:

- Today pulls best fit from goal path
- detail can nominate/protect candidate
- Today decides based on capacity/time reality

Time:

- Goal Detail can place real steps and inspect time pressure/capacity
- no fake Place Step

Capture:

All additions route through contextual Capture:

- add proof
- add step
- add thought
- revise direction
- attach context

Actions:

- add proof
- add step
- pause
- resume
- recover
- revise direction
- archive/accomplish
- change area
- split goal
- merge goal
- convert loose steps
- delete
- modify
- share/create output

Recovery:

- reduces path pressure
- creates smaller next step
- asks Today to stop pulling temporarily if needed
- not failure

Paused:

- remains visible
- stops generating Today candidates
- keeps proof/history
- can resume

Proof:

- proof stitches attached to path nodes
- receipt drawer shows full trail

Thoughts:

- can attach to path node, future step, goal root, or goal thought pool
- can grow into steps/goals

Copy:

- more copy than root is allowed only to explain decisions/consequences

---

## 8. Today / Reality Window decisions

Today root = visually rich, actionable Reality Window.

Today root is not:

- generic planner
- task list
- dashboard
- timeline clone
- CTA stack

Valid Start Here:

- day-context mode + token-in-window
- day reality remains visible
- actionable step is placed inside viable current window

No valid step:

- Recovery state
- protects capacity instead of shaming user

Root actions:

- state-gated action cluster
- no fixed CTA row
- no dead actions

Primary action:

- token itself is the action
- tap/operate token
- accessibility action can say “Begin”

Closure:

- appears only after step has been started or is proof-eligible

Remove generic `Capture what changed`.

If current step is active/proof-eligible, show proof/closure affordance as state-specific glyph.

Shape Time:

- focused Time Fit flow scoped to current step/window
- no routing to Time root

Protect Window:

- scoped Protect Window flow now
- direct manipulation later
- creates real protected time state or honest unavailable state

Review Context:

- no visible button
- inspection glyph / long press on Start Here opens why-this/why-now/source/capacity/constraints

Why this fits:

- small semantic glyphs
- tap expands/drills explanation

Next fixed point:

- meridian/window anchor glyph with accessible label

Protected time:

- boundary shading + protection glyph

Remove Start Here/Meridian toggle entirely.

Delete root rail copy like `No source change yet` and `All from work context`.

Delete nonsemantic icons.

Replace visible `Live now` text with subtle live/current-node behavior.

No goal candidates:

- calm held-capture / recovery-adjacent state
- no big CTA

Too little time:

- offer smaller step, recovery, later placement, or focused Time Fit when real

Low capacity:

- offer recovery or smaller step from same source if possible

Free-floating steps:

- equal validity to goal-linked steps
- Today chooses by fit

Thoughts:

- surface only when they can become action or need placement

Proof after closure:

- proof stitch on token/window/meridian
- detail reveals receipt

Copy:

- almost none on root
- step title, tiny state labels, accessible labels
- tap/expand/drilldown explains

---

## 9. Search / Find / Act / Inspect decisions

Search = unified Find / Act / Inspect surface.

Not:

- chatbot
- shallow sheet
- generic text search

Invocation:

- global gesture
- keyboard command
- App Shortcut
- VoiceOver action
- first-run teaching
- no persistent button

Presentation:

- full-screen Stage takeover with soft origin context

Query:

- command field with optional tokens

Result families:

- goals
- steps
- thoughts
- proof
- receipts
- life areas
- captures
- time windows
- settings/actions/system areas

Row anatomy:

- object glyph
- title
- source/area
- state
- one valid action
- optional inspect glyph

Copy:

- icon-first labels
- one short human line only where needed
- no `Inspectable route`
- no internal routing labels
- no source freshness on primary rows

Scope:

- global with origin-biased ranking

Empty:

- minimal empty plus one contextual action
- create capture from query / widen scope / create thought

Tap:

- default tap opens
- secondary gesture/action exposes valid operations

Allowed actions:

- open
- place
- protect
- add proof
- convert thought
- move capture
- resume
- pause

Mutations:

- state-gated
- receipt-backed

Index:

- local deterministic SearchIndex first
- Spotlight later
- no cloud/LLM query path

Ranking:

- text
- origin context
- current day relevance
- object state
- user correction feedback

Capture:

- Search passes query into Capture with prefilled input/context
- Search does not create objects directly

Goals/Time/proof:

- precise navigation
- mutations happen in operation surfaces or Capture/Time Fit
- proof is searchable but user-facing

---

## 10. Time / Native Life Calendar decisions

Time = Ambitions’ native Life Calendar.

As obvious as Apple Calendar.

As rich as Weather.

As intelligent as the Private Life Runtime.

Time is not avoiding calendar behavior.

It is a first-class, calendar-grade time surface with Ambitions-native capacity, protection, placement, proof, recovery, and goal-path intelligence.

Primary job:

- first-class native calendar + capacity operation surface

Root object:

- Calendar-grade LifeShape Calendar Field
- Day/week/month/year/list are real calendar orientations with Ambitions overlays

First view:

- current day calendar field around now
- native access to week/month/year/list

Now:

- native now seam/line
- rich but obvious
- related to next fixed point and current open window

Fixed points:

- calendar-native event anchors
- semantic glyphs
- tap detail
- no unexplained dots

Open capacity:

- visible open windows in calendar field
- subtle capacity quality

Lenses:

- Open Capacity
- Protected Time
- Pressure
- Recovery
- Goal Load
- Transition

Root can default to composite view.

Place Step:

- only for real Step object
- focused placement flow
- no real step = no Place Step
- no real window = honest unavailable/recovery/shape options

Real Step object:

- title
- estimated size/duration
- source
- state
- goal-linked or free-floating

Free-floating steps:

- equal placement rights
- inspection shows linked/free-floating status

Thoughts:

- convert through Capture/Proposal
- Time may show unresolved thought pressure only in inspection or held-capture context

Protect Window:

- calendar-native selection/protection flow

Protected time object:

- start/end
- reason
- strength
- recurrence
- source
- conflict behavior
- actively affects placement

Conflicts:

- local deterministic proposal with alternatives
- no silent auto-resolve

Today:

- Today and Time share same placement/protection model

Goals:

- Goals owns path direction
- Time tests feasibility and places real steps in real windows

Capture:

- creates fixed points, protected windows, step candidates, constraints, and time notes through typed routes

Proof:

- proof residue on calendar windows
- receipt detail in drilldown

Orientations:

- day/week/month/year/list real
- day/week/list operational first
- month/year can start summary-focused but must be real

List:

- calendar-grade agenda + operational queue
- fixed points, open windows, protected boundaries, placed steps, conflicts, unresolved placements
- accessibility-first equivalent to visual field

Copy:

- sparse native labels
- tap-to-explain
- no root native Life Calendar marketing copy

Header:

- no root `TIME - native Life Calendar`
- internal name allowed only in inspection/help

Light Mode:

- semantic token rendering
- misted graphite calendar field
- no grey-on-grey

---

## 11. You / Settings / Appearance / Privacy decisions

You = Apple iOS Settings structure + ChatGPT iOS settings clarity/compactness + Ambitions material, privacy, local-first, proof, and life-system cohesion.

Surface job:

- native Settings/Profile control surface backed by local system profile state
- not dashboard
- not product manifesto
- not diagnostic console

Visual style:

- Apple Settings grouping
- ChatGPT-style compact clarity
- Ambitions materials
- no table dividers
- no bottom glow artifact
- no status dashboard

Root hierarchy:

- small profile/local-status capsule at top
- grouped settings:
  - Appearance
  - Capture
  - Life Areas
  - Privacy
  - Local Data
  - Sources
  - Receipts
  - Accessibility
  - About

Row anatomy:

- SF Symbol / Ambitions glyph
- title
- optional short secondary state only if useful
- chevron or native control
- no paragraphs on root

Appearance:

- System / Light / Dark
- live propagation
- preview tiles allowed if real tokens
- no close/reopen requirement

Capture settings:

- input behavior
- keyboard dictation behavior
- attachment defaults
- gesture teaching reset
- permission state

Life Areas:

- manage defaults/custom areas in You
- Goals/Capture also expose contextual creation

Privacy:

- local-only status
- permissions
- data boundaries
- export/delete
- source access
- no marketing copy

Local Data:

- export
- erase
- backup/sync status if applicable
- local store status
- migration state
- diagnostics deeper

Sources:

- add/remove/disable/inspect
- freshness/status only in detail

Receipts:

- searchable proof ledger by goal, step, capture, time, date, surface

Accessibility:

- Dynamic Type
- Reduce Motion
- Increase Contrast
- haptics
- icon labels
- VoiceOver actions
- proof preview

About:

- version
- build
- local-first note
- privacy/legal
- diagnostics export
- no manifesto

Every visible row opens real detail or honest unavailable state.

No dead settings.

---

## 12. Evidence control plane decisions

Mutable tracker state, issue IDs, project health labels, and train-specific blocker relationships are not truth law. Keep them in active tracker or QA/remediation artifacts when needed. This truth register retains only the durable proof law:

- no Runtime Green without current runtime proof
- no Visual Green without current rendered proof and required independent review
- no Release Green without current release evidence and required approvals
- no historical evidence may prove a fresh fix
- no proof artifact may close a defect if the artifact reveals the defect still exists

Evidence:

- repo stores evidence README, screenshot index, manifest
- historical evidence does not prove a fix
- fresh proof required for repaired builds

Evidence path:

`docs/qa/evidence/2026-06-22-device-review/`

Known tradeoffs:

- No persistent Capture/Search buttons increases discoverability burden; mitigated by first-run teaching, progressive hints, gesture map, VoiceOver, keyboard/App Shortcuts.
- Large binary evidence may live outside the repo; the repo should retain only stable indexes or manifests when they remain current and useful.
- Time is calendar-grade.
- Ambitions can contain task-app capability without being framed as a task app.
