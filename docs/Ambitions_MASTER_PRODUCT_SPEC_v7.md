# Ambitions — Master Product Spec v7

## Product Status
This version supersedes earlier roadmap assumptions from the point immediately after Phase 9.5.
It preserves current progress while updating the product structure based on recent real-device review.

---

## Product Name
**Ambitions**

## Product Thesis
A structured, intelligent personal execution system that converts long-term goals into realistic daily actions and helps the user consistently follow through.

## Core Promise
Given a goal at any timeframe, the system should break it down into the next realistic actions without overwhelming the user.

---

## Current Delivery Status

Completed:
- Phase 1 — Foundation
- Phase 2 — Data Models + Core Structure
- Phase 3 — Planning Brain v1
- Phase 4 — Time Capacity + Scheduling
- Phase 5 — Execution + Replanning
- Phase 6 — Adaptation Layer v1
- Phase 7 — Calendar + Notifications Integration
- Phase 8 — Product Completion

In Progress:
- Phase 9 — Hardening / Stabilization / Polish
- Phase 9.5 — Visual Hardening / Humanization / Product-Craft Pass

New Immediate Follow-up:
- Phase 9.6 — Interaction Corrections + Accessibility + Navigation Cleanup

Planned Next:
- Phase 10 — Navigation Architecture + Drill-Down Foundation
- Phase 11 — Profile + Settings Hub
- Phase 12 — Progress, History, and Reflection Surfaces
- Phase 13 — Interactive Today + Surplus Time Actions
- Phase 14 — Accounts + Sync Foundation
- Phase 15 — Smarter Personalization
- Phase 16 — Advanced Integrations + Controls

---

## Why the Roadmap Changed
Recent real-device review showed that the app is improving visually, but the product structure still does not feel fully intuitive or flagship-caliber in use.

The most important learnings:
- time presentation feels too mechanical
- button hierarchy and contrast are not yet credible
- page categorization is not strong enough
- too much information remains on primary pages instead of being drillable
- the product needs a dedicated Profile / Me hub before deeper settings and reflective features expand
- the Today experience needs to feel more alive, contextual, and opportunity-aware
- the product should remain calm on the surface and only become analytical inside explicitly chosen deeper surfaces

These issues are structural, not just decorative. The roadmap must therefore prioritize interaction architecture before later maturity expansion.

---

## Product Philosophy
1. Clarity over motivation
2. System over willpower
3. Calm interface, deep logic
4. Small daily actions compound
5. Primary screens should feel usable at a glance
6. Deep detail should be drillable, not dumped on the main page
7. The app must feel human-made and commercially credible
8. Analytics belong in reflective spaces, not everywhere

---

## Updated Top-Level Product Structure
The app now moves to a five-part top-level model.

### Top-Level Sections
- Today
- Goals
- Plan
- Insights
- Profile

### Section Roles
**Today**
- execution center
- what is active now
- what is next
- how much free time remains
- opportunity to start a useful new action when surplus time exists

**Goals**
- all goals index
- status by goal
- drill into milestones, progress, task history, and protected work

**Plan**
- review-oriented plan surface
- current day/week structure
- acceptance and adjustment flows
- scheduling and plan-specific edits

**Insights**
- explicitly analytical space
- trends, momentum, completion patterns, continuity, and reflection tools
- should be the only clearly analytical top-level section

**Profile**
- Me hub
- settings, preferences, account state, appearance, integrations, and personal control surfaces
- later houses profile-level continuity/history summaries and deeper reflective utilities where appropriate

---

## Locked Decisions

### 1) Navigation Architecture
The product will use a **full-screen page architecture with shallow top-level navigation and drill-down detail flows**.

Implications:
- major pages should feel complete on their own
- deeper functionality should live behind clear actionable rows, cards, or buttons
- fewer long stacked pages
- more “tap into the next level” navigation
- elegant back affordance on drill-down screens
- iOS-style swipe-from-left back behavior where platform patterns allow it

### 2) Scroll Budget
Primary top-level screens should remain tightly edited.

Rules:
- target no more than roughly **2x viewport height** on primary screens
- nonessential details must move into drill-down pages
- avoid burying critical actions below long content walls
- summary first, detail later

### 3) Time Formatting
Default time presentation is now **friendly 12-hour formatting**, not default 24-hour / military-style presentation.

Rules:
- use forms like `8:00 AM`, `8:15 AM`, `5:00 PM`
- compact forms may use `8:00a` / `5:00p` only if highly polished and consistent
- time should read modern, polished, and consumer-friendly
- 24-hour time may exist only as an optional preference later, not as the default product language

### 4) Button and Action Hierarchy
Buttons are a core trust surface and must feel product-grade.

Rules:
- strong primary action style
- restrained secondary action style
- clear quiet/tertiary text action style
- readable contrast in all states
- no white text on insufficiently filled surfaces
- spacing, radius, and weight must feel intentional
- top-level screens should make next actions obvious without looking busy

### 5) Information Architecture Tone
The app should feel calm by default and analytical only by choice.

Rules:
- hide nonessential data from primary surfaces
- keep execution pages focused on usability and movement
- reserve heavy reflection and trend reading for Insights and selected drill-downs
- do not turn Today, Goals, or Plan into dashboards

### 6) Today Screen Direction
Today becomes a more engaging, opportunity-aware execution surface.

Required capabilities:
- show what is currently ongoing
- show what is next
- show available free time windows clearly
- offer a “start something useful” or “use this open block” action when surplus time exists
- feel alive without feeling noisy
- remain calm and low-pressure

Atmosphere:
- light “sunny day” emotional tone is acceptable
- tasteful environmental assets or accents may be used
- emojis may be used sparingly and intentionally where they improve warmth or clarity
- no emoji spam, no novelty clutter

### 7) Goals Surface Direction
Goals needs a stronger and more complete information model.

Required capabilities:
- dedicated all-goals list view
- clearer progress visibility
- stronger milestone drill-downs
- task history tied to a goal
- timeline-friendly history view
- easier inspection without turning the screen into a CRUD console

### 8) Profile / Me Hub
A dedicated Profile page is now required before deeper settings and reflective systems expand further.

Profile should include:
- account identity and sync state
- appearance
- schedule defaults
- integrations
- notifications
- planning preferences
- data/export/privacy pathways later as needed
- personal summary surfaces where they belong

Profile is the product’s control center, not a dumping ground.

### 9) Settings Architecture
Settings should be **grouped and drillable**.

Rules:
- each major setting area opens a dedicated screen
- only closely related controls should be grouped together on one page
- example: Appearance screen can include theme preset, light/dark selection, motion preference, and similar visual controls together
- avoid giant mixed setting walls
- every settings page should feel like a designed page, not a form dump

### 10) Theme Strategy
The app now requires a **paired light/dark theme system**.

Rules:
- current light themes should each have a dark counterpart with the same personality
- dark themes should preserve the calm aesthetic, not become neon or gamer-styled
- light/dark should feel curated, not merely inverted
- theme selection belongs under Appearance in Profile

### 11) Motion and Interaction Quality
The app should use **tasteful motion** as a quality signal.

Rules:
- subtle transitions
- pleasant state changes
- refined presses and surface changes
- no gratuitous flourish
- animation should clarify movement and improve perceived quality
- interaction quality should aim toward polished consumer-app expectations

### 12) Drill-Down First Detail Strategy
Additional details, secondary metrics, and advanced controls should live under drill-down pathways.

Examples:
- goal detail pages
- task history timeline pages
- appearance page
- schedule defaults page
- integrations page
- account page
- plan review pages

### 13) Primary Screen Composition Rule
Primary screens should present:
- the current answer
- the next action
- a short summary of why it matters

They should not attempt to teach the whole system at once.

---

## Design Direction (Updated)

### Overall Design Direction
**Calm premium consumer productivity with controlled warmth**

The aesthetic should remain:
- neutral-first
- soft and premium
- human-made
- editorial in restraint

But now it must also become:
- more interactive
- more readable in motion
- more confidently categorized
- less static and prototype-like

### Depth and Surface Rules
- use fewer generic stacked cards
- vary composition more intentionally
- keep top-level pages lighter and more breathable
- save dense structure for drill-down pages where the user asked for detail

### Typography Rules
- headline language should feel written, not generated
- support copy should be shorter and more useful
- metadata should be quiet
- time strings and labels should read like a polished consumer app

---

## Updated Screen Principles

### Today
Purpose:
- help the user act now
- make free time legible
- keep the day calm and alive

Should emphasize:
- ongoing blocks
- next best action
- free windows
- a tasteful opportunity prompt when time is available

Should de-emphasize:
- analytics
- excess metadata
- secondary system explanation

### Goals
Purpose:
- show the goal portfolio clearly
- make progress inspectable
- support deeper per-goal drill-downs

Should emphasize:
- all goals overview
- active goal status
- progress and history entry points

### Plan
Purpose:
- review and adjust the planned structure
- keep the editing surfaces deliberate and contained

Should emphasize:
- current plan shape
- clear actions to accept, refine, or inspect further

### Insights
Purpose:
- provide trend and reflection depth
- serve as the explicitly analytical zone

Should emphasize:
- meaningful history
- trends over time
- momentum, continuity, and behavior patterns

### Profile
Purpose:
- personal control center
- own settings and identity
- hold deeper personal configuration and reflection entry points

Should emphasize:
- drill-down rows
- grouped controls
- elegant settings navigation
- account/appearance/integration clarity

---

## Current Immediate Product Debt
These are now treated as active Phase 9.6 issues:
- default 24-hour time formatting on user-facing screens
- button contrast and hierarchy failures
- unreadable text on some pressable surfaces
- page categorization not yet strong enough
- insufficient drill-down structure
- primary pages still carrying too much secondary detail
- lack of Profile / Me destination
- inconsistent sense of “what happens next” across screens

---

## Revised Roadmap

### Phase 9.6 — Interaction Corrections + Accessibility + Navigation Cleanup
Goal:
Close the most obvious trust-breaking product issues before broader expansion continues.

Scope:
- switch user-facing time formatting to polished 12-hour display by default
- repair button hierarchy, contrast, spacing, and fill treatment
- fix unreadable pressable text states
- reduce category confusion on existing screens
- tighten primary-screen action clarity
- confirm 9.5 visual hardening across device QA

Rules:
- this phase is corrective, not expansive
- it should remove obvious “prototype” signals
- accessibility and readability take priority over decoration

### Phase 10 — Navigation Architecture + Drill-Down Foundation
Goal:
Rebuild the product flow so primary pages stay concise and deeper detail becomes intentionally navigable.

Scope:
- top-level IA refinement
- drill-down page pattern system
- iOS-consistent back affordances
- swipe-back support where appropriate
- page-to-page navigation clarity
- scroll-budget enforcement on primary pages
- move secondary information into deeper views

Rules:
- fewer long pages
- more decisive information hierarchy
- full-screen page flows over content dumping

### Phase 11 — Profile + Settings Hub
Goal:
Introduce the dedicated Profile / Me destination and give settings a real home.

Scope:
- new Profile top-level page
- grouped settings index
- dedicated drill-down pages for settings areas
- schedule defaults page
- notifications page
- integrations page
- planning preferences page
- appearance page foundation

Rules:
- Profile should feel elegant, not administrative
- settings should be drillable and calm
- grouped controls only where they logically belong together

### Phase 12 — Progress, History, and Reflection Surfaces
Goal:
Add robust progress understanding and task/goal history without infecting the entire app with analytics.

Scope:
- goal progress system
- all-goals drill-down improvement
- task history timeline view
- per-goal history context
- reflection entry points from Profile and Insights
- continuity and progress visibility

Rules:
- analytical depth belongs here, not everywhere
- history should be useful and drillable
- reflection should feel valuable, not punitive

### Phase 13 — Interactive Today + Surplus Time Actions
Goal:
Make Today feel alive, opportunity-aware, and genuinely helpful in the moment.

Scope:
- ongoing-now treatment
- clearer free-time visualization
- surplus time suggestions
- “start something useful” actions from open blocks
- tasteful atmospheric assets
- subtle emotional warmth
- carefully chosen motion and occasional tasteful icon/emoji support

Rules:
- keep calmness intact
- avoid novelty bloat
- improve engagement without creating noise

### Phase 14 — Accounts + Sync Foundation
Goal:
Introduce the account system and cloud-sync foundation without breaking the app’s local-first strengths.

Scope:
- account creation and sign-in
- authenticated user identity model
- local-first to hybrid sync architecture
- cross-device continuity
- sync-safe data model evolution
- conflict-handling baseline
- backup and restore direction

Rules:
- local responsiveness must remain strong
- sync must not make the app feel fragile
- identity should feel low-friction and trustworthy

### Phase 15 — Smarter Personalization
Goal:
Improve personalization from longer behavioral history while staying explainable and trustworthy.

Scope:
- longer-horizon adaptation
- stronger duration refinement
- deeper strategy personalization
- richer domain-specific tuning
- improved task-size and timing recommendations

Rules:
- remain deterministic-first
- avoid opaque AI-coach behavior
- preserve explainability and user trust

### Phase 16 — Advanced Integrations + Controls
Goal:
Expand real-world control and personal customization without cluttering the app.

Scope:
- broader integration preferences
- deeper notification controls
- richer appearance customization
- more advanced scheduling controls
- optional future calendar-write pathways if intentionally chosen later

Rules:
- avoid settings sprawl
- preserve low-noise product behavior
- keep optionality high and default complexity low

---

## Non-Negotiables (Updated)
- The app must feel human-made and intentional
- The daily plan must be realistic
- Tasks must respect available time
- Primary screens must stay calm and comprehensible
- Nonessential detail must be drillable
- Default time formatting must feel polished and consumer-friendly
- Buttons and actions must be readable and trustworthy
- Analytics must stay contained to reflective spaces
- Profile / Me must exist before the control architecture expands further
- The design must feel mature and commercially credible

---

## Non-Goals
- no novelty-heavy emoji usage
- no constant illustration clutter
- no enterprise settings walls
- no generic dashboard sprawl across all screens
- no over-animated UI
- no dark mode that breaks the calm brand language

---

## Build Planning Rule (Updated)
No implementation prompt should be written for later expansion phases until:
1. Phase 9.6 issues are resolved
2. the navigation and drill-down model is explicitly defined
3. Profile / Settings architecture is locked
4. the relationship between Goals, Insights, and Profile history surfaces is clear

---

## Recommended Immediate Sequence
1. finish Phase 9.6 corrective work
2. implement Phase 10 navigation / drill-down foundation
3. build Phase 11 Profile + Settings Hub
4. then proceed into Phase 12 progress/history/reflection expansion

This sequence is now the preferred path forward.
