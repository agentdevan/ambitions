# Ambitions — Master Product Spec vNext
**Status:** Full visual plan integrated; this file replaces the prior master spec as the canonical source for current shipping product truth.
**Purpose:** Preserve roadmap continuity, align completed work with the current state, and fold in the full flagship visual plan, dark-first theming system, premium interaction model, and updated phase roadmap.

---

## Ambitions 2.0 Post-Batch-60 Update

As of 2026-04-24, the active post-Batch-60 canon is the Ambitions 2.0 major transformation package under `docs/canon/Ambitions_2_0_*.md`. Those newly added files are the top-level source of truth for future Ambitions 2.0 work.

## Ambitions 2.0 Active Design Constitution

As of the design constitution reconciliation, [docs/canon/design/Ambitions_Design_Constitution.md](docs/canon/design/Ambitions_Design_Constitution.md) is the active design source of truth for IA, UX writing, object naming, screen contracts, visual/component contracts, interaction, trust, accessibility posture, and external-surface contracts. Shared object naming is further locked in [docs/canon/Ambitions_2_0_Object_Terminology.md](docs/canon/Ambitions_2_0_Object_Terminology.md).

Source-of-truth hierarchy:

1. [docs/canon/design/Ambitions_Design_Constitution.md](docs/canon/design/Ambitions_Design_Constitution.md)
2. [docs/canon/Ambitions_2_0_Master_Plan.md](docs/canon/Ambitions_2_0_Master_Plan.md)
3. [docs/canon/Ambitions_2_0_Product_Architecture.md](docs/canon/Ambitions_2_0_Product_Architecture.md)
4. [docs/canon/Ambitions_2_0_Visual_System.md](docs/canon/Ambitions_2_0_Visual_System.md)
5. [docs/canon/Ambitions_2_0_Object_Terminology.md](docs/canon/Ambitions_2_0_Object_Terminology.md)
6. Supporting design matrices/specs under [docs/canon/design](docs/canon/design)

Final product promise:

> Ambitions makes my life feel organized, and gives me the concrete steps to accomplish anything I set my mind to.

Expanded thesis:

> Ambitions exists to unlock people's lives by turning ambitions, goals, tasks, plans, and real-world constraints into clear next steps, believable plans, proof of progress, and calm recovery when life changes.

Active product language: Ambitions is an intelligent product, not an AI product. It should not sound like a chat-first AI wrapper.

Active shell: `Today / Goals / Capture / Plan / You`.

`You` is the Personal System Center. `Profile` may remain in compatibility code, but user-facing active canon uses `You`.

Task and Step are not interchangeable: `Task = standalone One-Step Goal`; `Step = action inside a Goal, Path, or Plan`. Tasks can be promoted into Goals, attached to Goals, turned into Rituals, or remain standalone without creating a top-level Tasks tab.

Life Areas and North Stars are active canon. Life Areas are visible inside Goals and You, not a sixth tab. North Stars are long-range dormant or identity-level ambitions under Life Areas.

Smart Attachment is the named Capture system for routing captures to Life Areas, Ambitions, Goals, Plans, Steps, Tasks, Proof, Decisions, Rituals, or Waiting items with editable receipts.

Panel Size and Display Density are active design controls: `Minimal / Balanced / Detailed` and `Compact / Comfortable / Large`, defaulting to `Balanced + Comfortable`.

The official categorized settings/depth pattern is `GroupedNavigationList` with Navigation Section, Navigation Row, Disclosure Navigation Row, Preference Row, Status Navigation Row, and Destructive Action Row.

Calendar permission remains Plan-owned. Calendar read is requested only after explicit Plan action, calendar write requires explicit confirmation, Plan works without calendar access, and onboarding must not request calendar permission.

Notifications are sparse by default, privacy-safe, and operational. Accessibility Nutrition remains unverified until audited; no user-facing accessibility claims should appear before verification evidence exists.

All phases and batches before Batch 61 are complete for planning purposes. Older phase language below is historical where it conflicts with the new Ambitions 2.0 canon.

"Ambitions is a personal life organization system."

Ambitions 2.0 is not merely a planner, habit tracker, goal app, calendar wrapper, analytics dashboard, or beautiful productivity app. The active canon directs the product toward a daily life operating loop with continuity, believability, proof, recovery, correction, trust, memory, focus, strategic pathing, and calmness.

Locked 2.0 direction:

- top-level tabs are Today, Goals, Capture, Plan, and You
- Insights is demoted from top-level navigation
- Habits is absorbed into Plan, rituals, Today execution, and Reviews/pattern reflection
- Life Areas and North Stars are first-class organization lenses inside Goals and You, not extra tabs
- Task means standalone One-Step Goal; Step means contained action inside a Goal, Path, or Plan
- Smart Attachment is the named Capture routing and correction system
- visual direction is "Calm shell, rich panels, meaningful visual state."
- execution direction is "Verify truth first, build shared systems once, then transform surfaces, then ship Apple-native external surfaces."
- Goal / Plan / Task visual canon is newly integrated as planned future work: Goal Lifecycle Rail, Goal Atlas, Proof Spine, Next Visible Step, Goal Weather, Decision Trail, Timeline View, Milestone Cards, Kanban-lite Task Lane, Weekly Plan Strip, and Completion Archive.
- Ambitions is not a task manager with goals attached. It is a visual life execution system where goals, plans, milestones, tasks, proof, decisions, weather, and archive learning stay connected by design.

For detail, use [docs/canon/Ambitions_2_0_Master_Plan.md](docs/canon/Ambitions_2_0_Master_Plan.md), [docs/canon/Ambitions_2_0_Product_Architecture.md](docs/canon/Ambitions_2_0_Product_Architecture.md), [docs/canon/Ambitions_2_0_Systems_Architecture.md](docs/canon/Ambitions_2_0_Systems_Architecture.md), [docs/canon/Ambitions_2_0_Visual_System.md](docs/canon/Ambitions_2_0_Visual_System.md), [docs/canon/Ambitions_2_0_Roadmap.md](docs/canon/Ambitions_2_0_Roadmap.md), and [docs/canon/Ambitions_2_0_Batch_Plan.md](docs/canon/Ambitions_2_0_Batch_Plan.md).

### Goal / Plan / Task visual systems

The active 2.0 canon defines this hierarchy:

- Goal = direction.
- Plan = believable path.
- Milestone = meaningful checkpoint.
- Task = standalone One-Step Goal.
- Step = contained action inside a Goal, Path, or Plan.
- Proof = evidence of real progress.
- Decision = reason the path changed.
- Weather = readable health signal.
- Archive = memory and learning.

The product should visually prioritize current goal direction, Next Visible Step, current plan window, proof of momentum, risk/blocker clarity, timeline context, and archive/learning.

Every active goal should show one Next Visible Step. Goal Weather is the user-facing visual language for goal health. Proof Spine is the vertical Goal Detail expression of Proof Rail. Goal Atlas is the visual portfolio/map layer that later expands into Path Builder. Plan Treaty changes should create Decision Trail notes when scope changes. Completion Archive must preserve completed, cancelled, dropped, parked, merged, and transformed goals as learning artifacts, not trash.

This section records product canon only. It does not claim these surfaces are implemented before their owning batches.

---

## 1. Product thesis

Ambitions is a calm, premium, iPhone-first personal execution system for individuals.

It is not a generic to-do app, not a project manager, not a corporate productivity dashboard, not a habit toy, and not a chat-first AI wrapper.

Ambitions should help a person do five things better than anything else on mobile:

1. understand what matters now
2. understand whether their goals are realistically achievable
3. break meaningful goals into believable work
4. recover from drift without shame
5. feel clear, real progress over time

The product should feel like a personal execution OS that reduces noise, lowers overwhelm, and makes meaningful progress feel obvious.

---

## 2. Product standard

The target standard is not “good indie productivity app.”

The target standard is:

- flagship consumer product quality
- FANG-level interaction maturity
- premium iPhone-native feel
- award-level clarity and restraint
- App Store Editors’ Choice caliber usefulness and polish
- Apple Design Award caliber thoughtfulness, accessibility, and craft

That means every major surface must feel:

- beautiful
- obvious
- low-friction
- emotionally safe
- fast to understand
- trustworthy
- intentionally composed

Beauty alone is not enough. Ambitions must earn habit by reducing cognitive load and increasing confidence.

---

## 3. Primary user

The primary user is an ambitious individual trying to make real progress in real life, often under inconsistent energy, inconsistent focus, and real schedule pressure.

A critical sub-user is the person with ADHD or ADHD-like execution struggles.

This means the product must be optimized for:

- overwhelm reduction
- clarity under stress
- fewer decisions
- shorter interaction loops
- obvious recovery paths
- visible progress
- realistic planning instead of fantasy planning
- compassionate language with adult tone

Ambitions should never make the user feel like they are managing the app. The app should manage complexity for the user.

---

## 4. Core product promises

### 4.1 Goal decomposition promise

A user should be able to enter any meaningful goal and a deadline in plain language.

Examples:

- Release 3 songs by August 1
- Lose 20 pounds by September 30
- Pay off $5,000 of debt by December 1
- Get a data analyst job in 6 months
- Launch my app this summer

The app must then:

- interpret the goal
- detect the likely work shape
- generate milestone structure
- generate actionable tasks
- estimate the total workload
- connect the plan to available time and real execution behavior

### 4.2 Feasibility promise

The app must compare the goal against:

- free time from now until the deadline
- fixed commitments
- believable weekly capacity
- learned execution behavior
- pace mode

Then it must tell the truth:

- this is possible
- this is possible but tight
- this is not realistically possible under current conditions

If it is not realistically possible, it must offer:

- revised deadline suggestion
- lighter scope suggestion
- pacing tradeoff options

### 4.3 Pacing promise

Every goal setup must support three pacing modes:

- Conservative
- Balanced
- Aggressive

Each mode must affect:

- weekly hours
- task or session count
- task sizing
- risk level
- deadline confidence
- adaptation behavior

These pacing models must continue updating throughout the life of the goal based on the user’s learned habits.

### 4.4 Progress promise

The user must feel meaningful progress.

Progress should not be reduced to:

- streaks
- badges
- generic percent circles
- completion theater

Progress must feel like:

- on pace
- slightly off pace
- reset needed
- recovered
- no longer realistic without changes
- new suggested target date
- clear movement toward something meaningful

### 4.5 Recovery promise

When plans drift, the app must help the user recover without shame.

It must make it easy to:

- reduce today
- reschedule
- split work
- reconsider scope
- change pace
- accept a new timeline

The tone must be honest, calm, and adult.

---

## 5. Core experience principles

These principles are the product’s operating laws.

1. **Reality before aspiration** — reflect real time, real energy, and real behavior.
2. **One recommended step** — show one clear next step before anything else.
3. **Hide what can wait** — not everything deserves equal visibility at all times.
4. **Reduce shame, increase truth** — never punish normal inconsistency.
5. **Progress must feel visible** — movement should feel real, not administrative.
6. **Planning must feel lighter than thinking alone** — planning in the app must reduce mental load.
7. **Visible intelligence, hidden complexity** — the product should feel smart without acting like a chatbot.
8. **Premium means restraint** — fewer, stronger surfaces; better hierarchy; better motion; better language.
9. **Every return should reduce ambiguity** — opening the app should make life feel clearer, not busier.
10. **ADHD-safe by default** — the product must be resilient to overwhelm, interruption, and inconsistent energy.
11. **Obvious first, clever second** — do not sacrifice comprehension for novelty.
12. **Visual over verbal** — hierarchy, spacing, time treatment, iconography, and progress visuals should do more work than explanatory copy.
13. **Habit through relief, not manipulation** — increase return behavior by making re-entry easy and next steps clear, not through pressure.

---

## 6. Product architecture

Ambitions should resolve downward like this:

**Life Area → Ambition / North Star → Goal → Path → Plan → Milestone → Step → Proof → Receipt / Review**

And upward like this:

**Today → Proof → Plan believability → Goal pace → Ambition / North Star direction → Life Area**

This is what makes the product feel like an operating system rather than a task app.

`Task` is a standalone One-Step Goal. `Step` is an action contained by a larger Goal, Path, or Plan. A Task can be promoted into a Goal, attached to an existing Goal, become a Ritual, or remain standalone with category, time, reminder, location, priority, proof, history, and review value. A top-level Tasks tab is not part of Ambitions canon.

---

## 7. Information architecture and top-level surfaces

### 7.1 Main tabs

The primary information architecture is:

1. Today
2. Goals
3. Capture
4. Plan
5. You

The tab bar must be polished, simple, and strong enough to support daily repeated use.

### 7.1A Top-level surface question doctrine

Each top-level surface must answer one dominant question:

- `Today`: What matters now?
- `Goals`: Where am I headed?
- `Capture`: What needs a place?
- `Plan`: Does this hold together?
- `You`: How is my system working for me?

This is product doctrine, not sample copy.
Each surface may contain supporting modules, but its first screenful must resolve its dominant question before the user scrolls.

### 7.1B Mobile provenance doctrine

On mobile, Ambitions should not rely on classic desktop-style breadcrumbs as the main provenance pattern.

Use:

- `Origin Chip`
- `Context Ribbon`
- `Return Stack Memory`

These are calm provenance signals.
They explain source and continuity without turning the product into navigation chrome.

### 7.2 Today

Today is the execution center. It must answer immediately:

- what matters now
- what is next
- what is fixed
- what is flexible
- what room is left
- how to recover if the day drifted

### 7.3 Goals

Goals must not be a disconnected list. They must show:

- what is active
- what is represented in the week
- what is stale or crowded
- whether pace is believable
- confidence to deadline

### 7.4 Capture

Capture is the intake and routing surface. It must show:

- fast input
- Needs a Place
- suggested routes
- recent captures
- Smart Attachment
- editable receipts

Quick Capture is a separate global action that opens the Quiet Command Sheet. The Capture tab opens the full Capture surface.

### 7.5 Plan

Plan is the weekly shaping surface. It must show:

- fixed commitments
- available capacity
- protected focus windows
- carryover pressure
- whether the week is believable
- how the week serves active goals
- rituals and recurring execution structures
- calendar-aware mode only after explicit Plan action

### 7.6 You

You is the Personal System Center. It must show:

- profile card
- personal system status
- light analytics summary
- next review / trust signal
- categorized Grouped Navigation Lists
- What Ambitions Knows
- Reviews
- Trust Center
- Privacy
- Sync / Export
- Integrations
- Appearance
- Notifications
- Accessibility
- Settings

### 7.7 Contextual Insights

Insights is not a top-level tab. Insights is contextual intelligence at the decision point.

Insight placement:

- Today: contextual insight tied to today's action
- Goals: goal health, path explanation, and proof
- Goal Detail: Why This / Why Changed / Decision Trail
- Plan: believability, pressure, and calendar evidence
- You: Reviews, memory, personal analytics, and trust

### 7.8 Activity History / Timeline drill-down

Activity History is a supporting drill-down surface, not a top-level tab.

It must show:

- what happened
- how the day actually unfolded
- what was completed, skipped, moved, or changed
- how behavior patterns are forming over time

This surface exists to make the system feel alive and trustworthy rather than static.

### 7.9 Supporting-route truth

The transformed frontend may redesign shell behavior, but these route-ownership rules remain the canonical design direction unless a later canon update explicitly replaces them:

- `Capture` is a singular first-class top-level product surface.
- `Habits` is absorbed into Plan, rituals, Today execution, and Reviews/pattern reflection rather than treated as a standalone top-level product area.
- `Weekly Review` is a supporting route owned by planning and review flows, not a top-level shell destination.
- `Monthly Review` is a supporting reflection route, not a top-level shell destination.
- `Memory Lens` is a shell-level recall utility surface, not a tab.
- `Trust Center` is a You-owned utility and trust surface, not a separate top-level destination.

### 7.10 Cognitive posture truth

The transformed frontend uses four product-level cognitive postures that reweight content without turning the shell into a mode-heavy power-user system:

- `Focus`
- `Triage`
- `Shape`
- `Reflect`

These are not top-level destinations.
They are a cognitive lens that changes emphasis, primary action posture, and disclosure depth across existing surfaces.

Default posture by top-level surface:

- `Today`: Focus
- `Goals`: Triage or Shape depending on whether the user is inspecting or composing direction
- `Plan`: Shape
- `You`: Reflect or Utility depending on whether the user is reviewing or configuring trust

Mode shifts must remain obvious, calm, and low-ceremony.
They should feel like the app is reweighting relevance, not like the user is entering a different operating mode that needs setup.

---

## 8. ADHD-first product requirements

These are required product behaviors.

- Every major screen must communicate its main point in under a few seconds.
- The user should rarely face more than one major decision at a time.
- Unclosed work should quickly convert into a safer next step.
- Common actions should complete in a few taps.
- The app must tell the truth when a goal, day, or week is unrealistic.
- The product should make movement feel concrete, especially when the final result is still far away.
- The user should not need to interpret ambiguous surfaces under stress.

---

## 9. Forward platform and continuity doctrine

The future planning direction should stay organized around a small set of platform pillars rather than a loose bag of branded features.

### 9.1 Platform pillars

- `Path Intelligence Layer`
  - `Readiness Gates`
  - `Path Draft + Evidence Pack`
  - `Decision-Swing Clarifications`
  - `Influence Cards`
- `State Continuity Mesh`
  - `Now State Lease`
  - `Continuity Receipts`
  - `Sync Health Strip`
  - `semantic conflict language`
- `Reality Model`
  - `Availability Seasons`
  - `Life Transition Modes`
  - `Stability Pass`
  - `Arrival Triggers`
- `Execution Resilience Stack`
  - `Equivalent Progress Sets`
  - `Recovery Cascade`
- `Context Vault + Signal Policy`

### 9.2 Cross-cutting programs

- `Progressive Intelligence Onboarding`
  - `60-Second Starting State`
- `Reflection OS`
  - `Quiet Gaps`
  - `Truth Mirror`

### 9.3 Named planning subsystems

These names remain valid when they materially govern execution or future-batch planning:

- `Degraded-State Orchestrator`
- `Recommendation Object Model`
- `Surface Contract Matrix`

These constructs should stay explicit in canon and planning, but they should still resolve into calm product behavior rather than feature-label clutter.
The product must reduce paragraph UI and keep reading burden low.
Returning after a missed day or week must feel simple and non-threatening.

---

## 10. Visual and interaction doctrine

### 10.1 Core mandate

Rebuild Ambitions so it feels like a real flagship iPhone product, not a productivity template.

The UI should feel:

- premium
- obvious
- modern
- calm
- minimal
- habit-forming
- actionable
- warm, but not soft or vague

This is not:

- a generic to-do app
- a dashboard-heavy productivity tool
- a gamified habit app
- a corporate workflow system

The visual target is a product worthy of comparison to the best modern consumer software design language from Apple, OpenAI, Meta, and Google:

- clear hierarchy
- excellent spacing
- low friction
- beautiful restraint
- high visual intelligence
- instant comprehension
- designed for repeated daily use

### 10.2 Product behavior the UI must reinforce

The UI should always communicate:

1. I know what matters right now.
2. I know what to do next.
3. I can use my free time intelligently.
4. I can see progress without reading a lot.
5. The app helps me keep momentum.
6. Returning to the app feels rewarding and easy.

Every screen should support action, not just information.

### 10.3 Design philosophy

#### Obvious first, clever second

Do not design for novelty. Do not hide important actions behind abstraction. Do not make the UI artsy at the cost of usability.

The user should understand each screen within one to two seconds.

#### Visual over verbal

Reduce text. Replace explanation with:

- hierarchy
- spacing
- iconography
- card grouping
- time treatment
- progress visuals
- micro feedback

Avoid paragraph UI, labels stacked on labels, and over-described sections.

#### Premium through restraint

Premium should come from:

- confident whitespace
- refined typography
- precise spacing
- soft depth
- tasteful color restraint
- smooth grouping
- subtle motion cues
- strong component consistency

Not from:

- excessive gradients
- glowing neon
- flashy glassmorphism everywhere
- noisy shadows
- decorative clutter

#### Habit-forming without childish gamification

The app should encourage repeat use through:

- momentum visibility
- intelligent next actions
- satisfying completion feedback
- compact streak cues
- progress continuity
- clear daily return value

Do not use:

- childish badges everywhere
- cartoon visuals
- over-the-top celebration screens
- fake dopamine spam

#### TikTok-era usability

The app should feel designed for users who expect:

- instant clarity
- fast scanning
- bold focal points
- low reading burden
- fluid navigation
- visual punch without clutter

That means:

- stronger top-level hierarchy
- clearer hero section per screen
- fewer competing cards
- more obvious interaction targets
- cleaner tab bar behavior
- concise labels
- bolder primary action framing

### 10.3.1 Canonical design-truth set

The detailed future frontend design truth lives under `docs/canon/design/`.

Those files define:

- shell IA and route ownership
- exact screen architecture
- shared design-system rules
- motion and microinteraction grammar
- trust and correction UX
- copy and state language
- external surface behavior
- cross-device surface roles
- signature interaction systems

Use the new Ambitions 2.0 canon files when planning or implementing active Batch 61+ work. The detailed frontend files remain historical design context where not superseded.
They deepen this master spec; they do not change the current active batch by themselves.

### 10.3.2 Additional signature systems

The future transformed frontend should treat the following as named product systems, not vague design inspiration:

- Cognitive Mode Lens
- Continuity Ribbon
- Semantic Zoom for Goals
- Quiet Command Sheet
- Object-Persistent Navigation
- Path Preview Drawer
- Pressure Map
- Review Constellation
- Window Magnetism
- Living Capture
- Intent-Sensitive Primary Action

These systems must stay:

- calm
- obvious
- low-density by default
- progressively disclosed
- consumer-native rather than tool-like

### 10.4 Overall look

Use a plain, clean background behind device renders and in presentation materials so the actual UI is obvious.

Inside the app, use a dark-mode-first design system that feels:

- blended
- warm
- premium
- slightly atmospheric
- highly readable

Dark mode should not feel gamer, neon, cyberpunk, or fintech.

### 10.5 Color and theming architecture

#### Base palette direction

Base tones should come from:

- charcoal
- deep warm gray
- espresso black
- soft graphite

Curated accent families may include:

- muted gold
- warm sand
- stone
- subtle sage
- soft blue-gray
- deep copper
- soft cream in light mode

Avoid:

- bright blue as primary identity
- loud green success overload
- overly saturated gradients
- harsh white-on-black contrast everywhere
- rainbow UI

#### Mode structure

Dark mode is the default design environment.

It should feel:

- calm
- deep
- slightly warm
- blended
- premium

Light mode is not an afterthought.

It should feel:

- soft
- airy
- warm-neutral
- not stark white
- equally premium

#### Theme architecture

Themes are not simple accent swaps.

Each theme should define:

1. background tone
2. surface tone
3. accent color
4. text contrast tuning
5. subtle mood

Themes must never change:

- layout
- spacing
- hierarchy
- component structure

Themes may change:

- color system
- tone
- subtle emphasis

#### Personalization rules

Personalization should feel engineered, not skinned.

Appearance controls should support:

- Mode: Dark / Light / System
- Accent selection from a curated palette
- live preview of theme choice

### 10.6 Surface behavior

Cards and containers should feel:

- softly lifted
- subtly blended into the background
- rounded, but not bubble-like
- tactile and modern

Use:

- restrained shadows
- faint borders
- tonal separation
- slight material layering

Avoid:

- hard boxes
- thick outlines
- flat wireframe feel
- excessive blur

### 10.7 Typography

Typography should be one of the most premium parts of the product.

Use type with:

- strong contrast between headline, section label, body, and meta text
- clear size hierarchy
- compact supporting copy
- minimal uppercase usage
- clean number treatment for time and progress

Text should feel concise, intentional, and never noisy.

### 10.8 Premium button system

Only three core button tiers should exist.

#### Primary / Hero button

Used for:

- Start or Resume
- Complete
- Confirm meaningful decisions
- Best Next Action

Design characteristics:

- roughly 44–52pt height
- slightly more rounded than cards
- subtle depth
- accent color used here
- strong contrast
- minimal text

Only one true primary button should exist per section.

#### Secondary button

Used for:

- Reschedule
- Adjust
- Skip
- plan edits
- support actions

Design characteristics:

- same shape language as primary
- lower contrast
- no heavy fill or only subtle fill
- optional tinted accent at low opacity

#### Tertiary / inline action

Used for:

- links
- small actions
- low-emphasis adjustments

Design characteristics:

- text-only or very light chip
- no heavy container
- slightly brighter than body text

#### Button motion

Every button should have:

- subtle press compression
- release snap-back
- optional micro highlight shift
- optional soft haptic feedback on supported platforms

### 10.9 Component guidance

Cards should be soft, tactile, elegant, scanable, and vertically breathable.

Rows should be concise, tap-clear, and strong in left-to-right hierarchy.

Progress elements should prefer segmented or linear treatments. Rings should only appear when they improve glanceability.

Chips and tags should stay compact and quiet.

Icons should be clean, modern, easy to parse, and consistent in weight.

The tab bar should feel App Store quality.

### 10.10 Interaction rules

Every screen needs one clear primary behavior.

Top-level screens should be glanceable. Detail views should be deeper but still elegant.

Use subtle reward through motion and closure for task completion, milestone progress, plan approval, and daily closure.

The app should always support re-entry by surfacing:

- what changed
- what is next
- what can fit into available time
- how momentum is going
- where the user is slipping

### 10.11 Screen-by-screen direction

#### Today

This is the most important screen in the app.

It should feel like:

- a calm execution center
- a daily operating system
- the app’s habit-forming home base

Required structure:

- top framing or greeting
- hero **Now** section
- compact **Next** section
- distinct **Free Time / Open Window** section
- **Best Next Action** recommendation
- optional compact momentum strip

Avoid long task lists, calendar overload, dense schedule views at the top, and equally weighted card stacks.

#### Goals and Goal Detail

This area should make long-term ambition feel tangible and active.

Each goal card should show:

- title
- progress state
- milestone or phase
- momentum or health
- drill-down affordance

Goal Detail should show:

- title and positioning
- milestone stack or phase breakdown
- progress visualization
- recent movement
- next meaningful sub-step
- timeline or execution history
- refine-plan affordance

Avoid spreadsheet feeling, KPI-heavy dashboards, cluttered subtask trees, and excessive explanatory text.

#### Plan

This screen should communicate that Ambitions is intelligently helping structure the user’s life.

Primary content should include:

- week or day scope toggle
- compact date treatment
- clean timeline/list hybrid
- open windows
- protected focus sessions
- obvious edit/review affordances

Avoid enterprise planning tables, tiny tap targets, and dense week grids.

#### Insights

This should make reflection feel useful, not analytical for its own sake.

Use a strong hero summary, compact charts, streak patterns, segmented timelines, and tasteful micro visualizations.

Avoid stock-chart energy, fintech visual language, giant legends, and BI-panel density.

#### Profile

This should be the calm utility layer.

It should provide access to:

- appearance
- habits and defaults
- notifications
- integrations
- billing and account
- system preferences

Use clean grouped rows, an elegant header, and subtle personalization.

#### Activity History / timeline drill-down

Use:

- vertically scrollable timeline
- elegant timestamps
- event chips or states
- completion markers
- annotations or reflection snippets
- optional filtering

Avoid dense audit-log appearance, excessive metadata, and enterprise status language.

---

## 11. Language standard

The product language must be:

- calm
- clear
- respectful
- adult
- low-ego
- emotionally safe

Use language like:

- “Still possible, but tighter than before.”
- “This week may need a lighter version to hold.”
- “The current deadline is unlikely to hold at this pace.”
- “A later target would be more believable.”
- “One meaningful block still fits.”

Avoid language like:

- “Crush your goals”
- “You’re on fire”
- “Streak in danger”
- “You failed to complete”
- “Stale catch-up wall”

---

## 12. Current state and completion alignment

As of the current roadmap state:

- foundational systems already exist
- the app already has onboarding, planning, review, rituals, and weekly shaping foundations
- the product is beyond prototype-shell stage
- the remaining work is about turning breadth into coherence, intelligence, premium clarity, and release-grade quality

The current alignment of phase completion is:

- **Phase 18** remains completed and should continue to be treated as the shipped weekly review and next-week shaping milestone
- **Phase 18.1** remains the in-progress hardening and navigation correction pass
- **Phase 20.1** remains a completed or already-landed Plan deepening pass and should be preserved as existing truth rather than re-proposed as new greenfield work

Implication:

- future work should deepen, unify, and harden
- future work should not restart working systems from scratch
- the new visual plan is a premium alignment and restructuring pass over existing foundations, not a conceptual reset

---

## 13. Roadmap continuity rules

The existing roadmap continuity must be preserved.

- older completed phases are not renumbered
- the current completed and in-progress states remain valid
- new work should continue numerically from the current state
- completed work should not be re-proposed as future greenfield work
- this master spec supersedes older planning language where there is conflict

---

## 14. Phase roadmap going forward

The roadmap can take as many phases as necessary. The correct priority is not shortest roadmap. The correct priority is strongest product.

### Phase 18 — Completed
**Weekly review and next-week shaping**

Already landed and established:

- weekly review state
- next-week shaping state
- weekly carryover review
- weekly reminder model
- scheduling impact from weekly shaping
- initial Insights / Profile / Plan integration

### Phase 18.1 — Completed / historical hardening pass
**Weekly hardening + navigation correction**

Required outcome:

- weekly review reminder is fully controllable from UI
- Plan “Next week” row routes to the correct weekly review and shaping experience
- Profile top-level planning summary preserves unfinished-work handling visibility
- Insights hero progress logic is driven by the current weekly digest rather than stale summary math
- runtime validation limitations are documented clearly while better non-web validation paths are exercised

### Phase 18.2 — Flagship visual system foundation
**Design tokens, surfaces, typography, buttons, motion, and theme architecture**

Must accomplish:

- dark-mode-first authored visual system
- light mode that feels equally premium rather than fallback
- curated accent families usable across both modes
- theme architecture based on background, surface, accent, contrast, and mood
- spacing system tightening
- type scale and hierarchy rules
- canonical card, row, chip, progress, and tab-bar styling
- premium three-tier button system
- component motion standards

Acceptance criteria:

- shared visual tokens exist and are used across top-level surfaces
- dark and light modes both pass premium-quality review
- accent choices do not cheapen the product
- core components no longer look generic or template-driven

### Phase 18.3 — Completed / historical app shell, navigation, and hierarchy correction
**Five-tab shell alignment + hero-first screen structure**

Historical note: this pre-Batch-61 phase is superseded by the Ambitions 2.0 shell and Design Constitution. The active top-level shell is `Today / Goals / Capture / Plan / You`; Insights is contextual and Profile is user-facing `You`.

Must accomplish:

- historical five-tab IA formerly targeted Today / Goals / Plan / Insights / Profile; active canon supersedes this with Today / Goals / Capture / Plan / You
- premium tab-bar treatment and active-state clarity
- stronger header behavior and section hierarchy
- one-main-action-per-view enforcement at top-level surfaces
- cleaner route logic for drill-down screens
- stronger summary-to-detail layering
- better safe-area handling, spacing, and breathing room
- Cognitive Mode Lens weighting rules across shell destinations
- Quiet Command Sheet and Continuity Ribbon shell integration
- object-persistent transitions for the same goal, block, or capture across surfaces

Acceptance criteria:

- tab shell feels flagship quality
- top-level screens have a clear hero section
- competing elements are materially reduced
- primary behaviors are obvious on each top-level screen

### Phase 18.4 — Today execution center overhaul
**Today becomes the flagship habit-forming home base**

Must accomplish:

- hero **Now** section
- compact **Next** section
- distinct **Free Time / Open Window** section
- intelligent **Best Next Action** section
- compact daily momentum treatment
- stronger fixed vs flexible distinction
- obvious completion, reschedule, skip, and recovery actions
- re-entry treatment for drifted days
- Intent-Sensitive Primary Action tuned to day posture
- Continuity Ribbon carrying the one most important active continuity signal
- Recovery Bloom as a first-class visual and interaction state

Acceptance criteria:

- Today is clearly the strongest surface in the product
- hero hierarchy is obvious on first glance
- action density is lower while usefulness is higher
- long task list feeling is removed

### Phase 18.5 — Goals and Goal Detail overhaul
**Long-term ambition becomes tangible, visible, and premium**

Must accomplish:

- premium goal cards with strong scanability
- clear active vs stalled vs completed treatment
- stronger milestone or phase visuals
- visible goal health and pace state
- upgraded Goal Detail composition
- recent movement and next meaningful sub-step treatment
- stronger distinction between strategy and tactics
- Semantic Zoom for Goals across now, week, phase, and full-path scales
- Path Preview Drawer for shallow future-path inspection
- Goal-level object persistence between Today, Goals, Goal Detail, Plan, and review

Acceptance criteria:

- goals overview is easy to scan
- Goal Detail has stronger hierarchy than the current state
- progress feels meaningful without KPI clutter
- the screen no longer reads like a productivity template

### Phase 18.6 — Plan workspace UX overhaul
**Premium week-shaping experience on top of existing planning foundations**

Must accomplish:

- cleaner day/week scope treatment
- timeline/list hybrid that is legible on phone
- clearer fixed vs flexible block treatment
- stronger open-window visibility
- better protected-focus visuals
- obvious edit/review affordances
- calmer explanation of why blocks exist
- clearer weekly tradeoff framing
- improved visual communication of whether the week is believable
- Pressure Map and Window Magnetism behaviors for open-time opportunity and week compression
- limited split-pane thinking on iPhone only where planning clarity materially improves

Acceptance criteria:

- Plan is easier to scan and adjust than the current state
- dense calendar energy is reduced
- weekly shaping feels calmer and more credible
- the screen supports existing planning logic without restarting it

### Phase 18.7 — Insights, history, and review coherence layer
**Reflection surfaces become one elegant system**

Must accomplish:

- stronger Insights hero treatment
- better composition of supporting modules
- coherent visual language for momentum, consistency, drift, and progress trend
- activity history timeline drill-down
- less duplication between summary insights and review-oriented surfaces
- better use of compact charts and micro visualizations
- lower text burden across reflection surfaces
- Review Constellation for clustered behavioral proof instead of analytics-heavy dashboard composition

Acceptance criteria:

- Insights is scanable and visually strong
- history view feels like behavioral proof, not an audit log
- reflection surfaces are encouraging without being soft or vague

### Phase 18.8 — Profile, appearance, and personalization system
**Calm utility layer + premium theming controls**

Must accomplish:

- elegant Profile composition
- grouped settings with stronger hierarchy
- appearance settings for Dark / Light / System
- curated accent selection UI
- live preview of theme choices where practical
- better notification/defaults surfaces
- stronger sync, integration, and account-status framing

Acceptance criteria:

- Profile no longer feels like a generic settings clone
- appearance settings feel intentional and polished
- system and trust controls are easier to understand

### Phase 18.9 — Calm completion, momentum, and re-entry foundation
**Retention mechanics integrated into the flagship shell**

Must accomplish:

- subtle completion feedback
- continuity cards or equivalent momentum cues
- lightweight daily closure
- “keep moving” or “one step from milestone” treatments where appropriate
- better same-day re-entry after interruption
- better next-day re-entry after drift
- low-pressure resurfacing of unfinished but still relevant work

Acceptance criteria:

- missed time no longer creates a dead-end feeling
- completion feedback feels polished
- momentum is visible without turning childish

### Phase 19 — Monthly Review + Strategy Layer

Must accomplish:

- monthly review state and storage model
- monthly strategy summary
- month-level pattern reads
- month-level pace truth across active goals
- month-level drift, overload, and carryover pattern detection
- recommended month posture for the next cycle

Acceptance criteria:

- monthly review feels connected to weekly review, not bolted on
- month summaries are readable, honest, and calm
- the visual language of review remains consistent

### Phase 20 — Plan modeling deepening
**Believability logic and shaping intelligence**

Must accomplish:

- more credible weekly capacity modeling
- stronger focus-window protection logic
- clearer carryover pressure logic
- stronger “this week is believable / too full / needs a lighter shape” logic
- better task placement controls
- stronger tradeoff modeling between fixed obligations and meaningful work

Acceptance criteria:

- weekly truth feels materially stronger
- pressure and capacity are understandable and trustworthy
- the surface visibly supports goal pacing and deadline realism

### Phase 20.1 — Completed / existing deepening pass

This phase state remains part of the truth source if already landed on main. Future Plan work should deepen rather than restart it.

### Phase 21 — Goal Intelligence Engine + Today execution integration
**The core moat phase**

Must accomplish:

- plain-language goal intake
- goal type and work-pattern inference
- milestone and task scaffold generation
- feasibility evaluation against free time, fixed commitments, weekly capacity, learned behavior, and selected pace mode
- revised deadline suggestion when needed
- Conservative / Balanced / Aggressive pace modes
- a premium goal strategy composer
- Today awareness of goal pace pressure and deadline pressure

Acceptance criteria:

- goal setup reliably generates milestone and task scaffolds
- feasibility is clearly surfaced
- revised deadline suggestions exist when needed
- pace mode selection is obvious and meaningful
- Today clearly reflects pace and deadline pressure

### Phase 22 — Ambition layer above Goals + progress model
**Direction above execution**

Must accomplish:

- first-class Ambition model above Goal
- goals grouped under ambitions
- ambition-level meaning and direction context
- better pace and confidence expression at the goal level
- explicit representation of whether active ambitions are actually being served by the calendar and plan
- progress that connects daily progress, weekly progress, goal pace, deadline realism, and ambition direction

Acceptance criteria:

- users can see bigger direction above goals
- goals feel more meaningful and grounded
- progress feels more alive than completion counts
- ambitions help determine planning and review importance

### Phase 23 — Explainable recommendations + review intelligence
**Trust through reasoning clarity**

Must accomplish:

- stronger recommendation explainability
- review logic that can answer “can I still make this?”
- clearer rationale for task-now recommendations
- clearer rationale for lighter weeks, revised deadlines, carryover posture, and recovery paths
- human-language explanations based on time left, room in the week, goal pace pressure, consistency pattern, preferred task size, and energy fit

Acceptance criteria:

- recommendations feel understandable and grounded
- review intelligence feels like one system rather than scattered logic
- explainability improves trust without cluttering the UI

### Phase 24 — Calm retention, reminders, and longitudinal re-entry
**Healthy habit formation over time**

Must accomplish:

- better reminder timing
- better multi-day re-entry
- better multi-week re-entry
- smarter regain-context surfaces
- continuity logic that survives missed time
- progress language that motivates without manipulating

Acceptance criteria:

- re-entry after drift is dramatically easier
- reminders are useful and low-pressure
- the app feels habit-forming through relief and momentum, not guilt

### Phase 25 — Auth, sync, trust, and cross-device hardening
**Reliability across devices and over time**

Must accomplish:

- better local-only vs connected-account clarity
- stronger pending-changes visibility
- better reconnect and retry behavior
- better conflict and stale-state handling
- clearer trust language around sync and safety
- fewer silent failure modes
- clearer integration health surfaces

Acceptance criteria:

- cross-device trust is materially stronger
- sync state is understandable
- silent failure risk is lower
- account and sync surfaces feel mature

### Phase 26 — Flagship polish, accessibility, performance, and product coherence
**Finish-quality phase**

Must accomplish:

- tighter spacing and hierarchy system-wide
- better canvas/card balance
- more consistent motion and state changes
- strong Dynamic Type behavior
- VoiceOver sanity on major flows
- contrast quality
- reduced-motion respect where appropriate
- faster perceived load on major screens
- smoother transitions and scroll performance
- better empty, loading, error, and first-return states

Acceptance criteria:

- hierarchy is consistently strong across all major surfaces
- the app looks and feels flagship-grade
- accessibility is no longer a later item
- the product feels authored, not assembled

### Phase 27 — Release-candidate hardening and App Store readiness
**Launch readiness, not just product completeness**

Must accomplish:

- real iPhone validation
- offline and relaunch behavior testing
- reminder and calendar flow testing
- sync recovery path testing
- successful native builds
- install / relaunch / persistence checks
- store assets and screenshots
- App Store description and positioning
- privacy policy, App Privacy disclosures, support path, and any required terms
- analytics, crash reporting, beta workflow, and post-launch triage workflow

Acceptance criteria:

- the product is functionally launch-ready
- the store package is credible
- legal and trust basics are covered
- operational support exists for real users

---

## 15. What the finished product must be able to do

By the end of the roadmap, Ambitions is not complete unless all of these are true:

1. a user can enter a meaningful goal and deadline in plain language
2. the app can generate believable milestones and tasks
3. the app can estimate whether the deadline is realistic
4. the app can suggest a revised deadline when necessary
5. the user can choose conservative, balanced, or aggressive pacing
6. the system keeps adapting pacing based on learned behavior
7. Today reflects the reality of active goal pressure
8. Plan reflects whether the week is believable
9. Review tells the truth across day, week, month, and direction
10. the product feels obvious, beautiful, and calm enough for repeated use under stress
11. the app is cross-device trustworthy
12. dark mode and light mode both feel premium and intentional
13. theming and appearance controls feel curated rather than cosmetic
14. the product is genuinely launch-ready, not just feature-complete

If any of those are missing, the product is still incomplete.

---

## 16. Non-goals and anti-patterns

Ambitions must aggressively avoid:

- generic dashboard homepages
- enterprise project-management vibes
- chat-first AI interfaces
- visible technical scoring systems
- bloated analytics
- shame-based overdue framing
- streak bait
- gamification gimmicks
- dense phone kanban boards
- decorative premium effects without product value
- too many parallel views that duplicate each other
- forcing the user to manually architect everything
- neon or noisy dark mode
- theme systems that feel bolted on
- UI-kit buttons and generic template cards
- decorative clutter that weakens clarity

---

## 17. Success definition

Ambitions succeeds when a user feels:

- clearer
- calmer
- more realistic
- more capable
- less guilty
- more connected to meaningful progress

It wins when the product can honestly say:

- give me your goal and your deadline
- I’ll tell you if it’s believable
- I’ll help you shape the work
- I’ll adapt the plan as life changes
- I’ll help you keep moving without turning your life into admin

That is the product.

---

## 18. Canonical planning rule

From this point forward, Codex phase planning should treat this document as the canonical source of truth for the current shipping product.
For platform vision, execution order, batch packaging, and active work status, follow [docs/codex/CONTEXT_INDEX.md](docs/codex/CONTEXT_INDEX.md).
For active Ambitions 2.0 Batch 61+ design truth, use [docs/canon/Ambitions_2_0_Visual_System.md](docs/canon/Ambitions_2_0_Visual_System.md) together with the new Ambitions 2.0 canon package. The older frontend design docs remain historical context where not superseded.

When there is conflict between:

- older future-phase planning text
- stale assumptions about what Ambitions still needs
- generic strategy suggestions
- earlier, lighter visual guidance that is now superseded by the full flagship visual plan

this document should win for current shipping product truth.
For future platform scope or implementation sequencing, the canonical roadmap and execution docs in `docs/canon/` win.

All future Codex prompts should be generated against:

- the real repo state on `main`
- the actual completed phases
- the in-progress phase state
- this master product spec
- the canonical planning docs under `docs/canon/`
- the active queue in `docs/codex/BATCH_REGISTRY.md`
