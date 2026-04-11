# Ambitions — Master Product Spec

## Product Status
Active planning document. This is the single source of truth for the project and should be updated as decisions are locked.

---

## Product Name
**Ambitions**

## Product Thesis
A structured, intelligent personal execution system that converts long-term goals into realistic daily actions and helps the user consistently follow through.

## Product Category
Personal productivity / planning / life operating system

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

Planned Next:
- Phase 10 — Accounts + Sync Foundation

---

## Locked Decisions

### 1) Product Direction
The chosen project is **Ambitions**, the external-brain life operating system.

### 2) Product Model
**Hybrid model**
- Structured deterministic core system
- Optional intelligence layer on top
- Intelligence assists, but does not replace system logic

### 3) Planning Philosophy
- No improvisational building
- No vague feature creep
- Every major decision should be defined before implementation begins
- Codex prompts should follow a deliberate build sequence

### 4) Task Load Logic
**Flexible based on workload**
- The system should not use a fixed hard daily task cap
- It should calculate available time per day based on:
  - sleep assumption: 8 hours by default
  - getting ready time
  - commute / drive time
  - work schedule blocks
  - other blocked calendar commitments
- Tasks must include estimated duration
- Daily task generation should avoid overcrowding the day

### 5) Goal Input Style
**Both structured and natural language input**
- Structured entry for precision
- Natural language entry for convenience

### 6) System Tone
**Neutral with slight guidance**
- Primarily calm, minimal, Apple-like
- Subtle guidance is acceptable
- Not coach-like, aggressive, or guilt-inducing

### 7) Platform Strategy
**iPhone-first product design, but not Mac-dependent native execution on day one**

Implications:
- Primary product experience is designed for iPhone
- iPad support is included
- The product should feel like a real app, not a generic website
- Development should avoid requiring a Mac at the beginning
- Architecture should preserve a path to a native-feeling app experience and future App Store viability

### 8) Build Priority
**Craft-first**
- Product quality and maturity take priority over raw implementation speed
- Early phases must establish strong design, architecture, and interaction quality
- Development should favor refinement, consistency, and intentionality over fast but shallow output
- UI and UX must feel premium from the first meaningful build phases

---

## Product Philosophy
1. Clarity over motivation
2. Small daily actions compound
3. System over willpower
4. Calm interface, deep logic
5. Minimal UI, high usefulness
6. No productivity guilt
7. The user should always know what matters today

---

## Primary User Problem
The user has meaningful long-term goals, but struggles to consistently translate them into realistic, daily executable actions across multiple life domains.

## Desired Outcome
The app acts as an external brain that transforms goals into concrete plans and preserves momentum over time.

---

## Core Systems

### A. Goal Decomposition Engine
Input:
- yearly goals
- monthly goals
- weekly goals

Output:
- monthly milestones
- weekly plans
- daily tasks

Characteristics:
- deterministic first
- optionally refined by intelligence layer
- realistic, not aspirational fantasy planning

### B. Time Capacity Engine
Calculates actual available execution time per day using:
- sleep
- work blocks
- commute time
- morning prep time
- calendar events
- optional user-defined constraints

### C. Execution Engine
- daily task list
- completion tracking
- carry-forward logic
- rescheduling support
- task effort and time-awareness

### D. Intelligence Layer
- improves plans
- suggests adjustments
- helps when goals are vague or stalled
- should not create chaos or randomness

### E. Domain System
Supported domains include:
- fitness
- finance
- credit
- career
- skill building
- relationship
- personal

### F. Feedback and Adaptation
- track completion rate
- detect overload
- adjust future planning recommendations

---

## Product Scope Direction

### Strong V1 Candidates
- create goals
- goal hierarchy and timeframe structure
- automatic goal breakdown
- daily task generation
- task duration estimates
- Today view
- calendar-aware workload logic
- simple progress tracking
- basic guidance layer

### Avoid in V1
- social features
- gamification-heavy systems
- bloated dashboards
- advanced machine learning
- voice-first workflows
- excessive analytics
- too many settings

---

## UX Direction
Top-level product should remain tight and calm.

Likely top-level sections:
- Today
- Goals
- Plan
- Insights

Screen count should remain intentionally limited.

---

## Design Direction

### Design Direction
**Structured minimal with pure-minimal influence**
- Clean and calm overall presentation
- Strong information hierarchy without feeling busy
- Minimal chrome and restrained visual noise
- Must feel human-designed, premium, and intentional

### Color System
**Neutral-first with soft domain color support, plus theme management**
- Base experience should lean neutral and timeless
- Domain colors may be used subtly for guidance, not decoration
- App should include a theme manager with curated presets and customization
- Product should feel personal to the user, not generic

### Depth Style
**Soft depth**
- Gentle layering and separation
- Avoid heavy shadows and overly boxed UI
- Visual grouping should not rely on obvious dashboard-style cards unless necessary

### Typography Direction
**Clear hierarchy, calm tone**
- Strong readability and scanability
- No loud or overly assertive visual treatment
- Must not feel cheap, templated, or AI-generated
- Interface should guide quietly rather than shout at the user

---

## Today Screen Design (Locked)

### Overall Structure
**Hybrid model**
- Timeline-based structure for realism
- Tasks remain the primary focus
- Schedule context supports execution, not dominates it

### Overdue / Unfinished Task Visibility
**Controlled visibility**
- Unfinished tasks are visible but not aggressive
- No guilt-driven UI patterns
- System should surface carryover calmly and contextually

### Core Sections (Top to Bottom)
- Header (date + contextual capacity insight)
- Today’s Plan (time-blocked tasks with durations)
- Adaptive Guidance (subtle, minimal suggestions)
- Schedule Context (work, commute, fixed blocks)
- Progress + Rollover Awareness (calm reflection of completion state)

### UX Intent
- Feels like a calm, intelligent daily guide
- Emphasizes clarity and realism
- Avoids overwhelm and pressure

---

## Interaction Model (Locked)

### Task Interaction
**Hybrid interaction model**
- Quick inline actions (tap, swipe) for speed
- Optional deeper view for task details when needed
- Must prioritize low friction for daily use

### Task Completion Feedback
**Subtle feedback**
- Light animation or visual confirmation
- Reinforces progress without gamification
- Must feel satisfying but not distracting

### Task Start Behavior
**Optional focus mode**
- Default: tap to begin task
- Optional focus mode:
  - timer
  - reduced UI
  - distraction minimization

### Plan Control
**Fully editable plan**
- Users can:
  - move tasks
  - adjust time
  - reschedule
- System should observe and learn from these changes

### Replanning Trigger
**Suggestion-based replanning**
- System suggests adjustments when needed
- User must approve changes
- No aggressive or automatic reshuffling

---

## Integrations (Locked)

### Calendar Integration
**Semi-integrated (V1)**
- App reads calendar events
- Identifies busy vs free time
- Detects recurring commitments
- Can suggest time blocks for tasks
- User must confirm before writing anything to calendar

### Notifications
**Context-aware nudges (V1)**
- Reminders based on schedule and task timing
- Smart nudges using available free time
- Examples:
  - “You have 30 minutes free — good time for this”
  - “Start small: 10-min task first”
- Must remain calm, non-intrusive, and helpful

### V1 Integration Scope
- Calendar: Included
- Notifications: Included
- Health: Excluded (future phase)
- Finance: Excluded (future phase)

---

## Data Strategy (Locked)

### Storage Model
**Local-first with planned hybrid evolution**
- All core data stored locally on device in V1
- App must function fully offline
- Prioritize speed, reliability, and responsiveness
- Architecture must be designed to support future cloud sync without major refactor

### Sync Strategy (Future)
**Hybrid local + cloud (post-V1)**
- Local remains source of truth initially
- Cloud sync introduced later for multi-device continuity
- Conflict resolution and sync logic deferred to future phase

### Account System
**No account in initial V1 with future account path**
- No login required initially
- Zero onboarding friction
- Account system introduced later for sync and backup
- Data model must support user identity later without breaking structure

---

## Planning Model
**Assisted Replanning (Locked)**
- The system generates structured plans based on goals and available time
- When tasks are missed or schedules change, the system proposes adjustments
- The user reviews and approves changes
- The system does not automatically reshuffle everything without user awareness
- Plans remain stable but adaptable

---

## Breakdown Engine Decisions (Locked)

### Goal Structure
**Flexible hierarchy**
- Goals can be entered at any level
- The system should infer and generate missing layers
- The product should not force the user into rigid input sequencing

### Decomposition Method
**Hybrid decomposition**
- Structured templates provide stability and domain logic
- Intelligence refines the plan based on context, phrasing, domain, and user history
- The app should avoid fully unbounded AI planning

### Task Generation Philosophy
**Adaptive per-user generation**
- The system should not use a simplistic fixed task count rule
- It should learn how the user responds to task size, difficulty, frequency, and persistence
- If the user is failing to meet goals, the system should adapt the plan rather than merely repeating it
- The engine should explore alternative task sizes, pacing, sequencing, and completion strategies
- Goal achievement should be prioritized over rigid plan preservation

### Time Estimation Philosophy
**Intelligence-guided, learned over time**
- Initial task duration estimates should be generated by the system
- Over time, estimates should adapt based on the user's actual completion behavior
- Time estimation should become increasingly personalized

### Constraint Handling Philosophy
**Context-aware block interpretation**
- The engine should determine whether a time block is fully unavailable or partially usable
- Work blocks should be treated as non-plannable except for explicitly available windows such as lunch breaks
- Other blocks may be treated as hard or soft constraints depending on their nature

---

## User Adaptation Model (Locked)

The system will learn and adapt to the user across five core dimensions.

### 1) Capacity Profile
Represents how much time and usable energy the user actually has.
Includes:
- available free time per day
- high vs low capacity periods
- workday vs non-workday differences
- schedule consistency vs volatility

### 2) Completion Profile
Represents what the user reliably finishes.
Includes:
- completion rate by task duration
- completion rate by domain
- completion rate by time of day
- carryover frequency

### 3) Friction Profile
Represents what the user avoids or struggles to start.
Includes:
- repeatedly deferred tasks
- tasks exceeding optimal size
- avoided domains
- patterns of resistance

### 4) Momentum Profile
Represents how execution success or failure compounds throughout a day or week.
Includes:
- streak sensitivity
- impact of early wins vs early failures
- whether missed starts collapse execution
- dependence on structure

### 5) Strategy Profile
Represents which planning style produces the highest completion rate.
Examples:
- fewer larger tasks vs many smaller tasks
- front-loaded vs evenly distributed schedules
- batching vs alternating task types
- difficulty sequencing preferences

---

## Dynamic Strictness Model (Locked)

The system will not use a fixed strictness level. It will adapt over time based on user behavior.

### Phase 1 — Trust Building (Protective)
- Lower task volume
- Shorter task duration
- High completion bias
- Focus on early wins and consistency

### Phase 2 — Calibration (Adaptive)
- System observes user behavior patterns
- Adjusts task size, count, and pacing
- Begins increasing load where safe

### Phase 3 — Optimization (Balanced)
- Operates near user’s proven capacity
- Prioritizes efficient goal completion
- Maintains pressure within tolerable limits

### Phase 4 — Regression Handling (Protective fallback)
- Triggered by missed tasks, overload signals, or avoidance patterns
- Reduces task load and complexity
- Focuses on rebuilding momentum

### Core Principle
The system optimizes for the most executable plan in the current state, not the most aggressive or theoretically optimal plan.

---

## Breakdown Engine Rules (Locked)

### Task Granularity
**Mixed granularity**
- Tasks range approximately 5–45 minutes
- Mix of quick wins and deeper work
- Adjusted over time based on user completion behavior

### Daily Plan Structure
**Time-blocked scheduling**
- Tasks are assigned to specific time slots
- Must respect:
  - work schedule
  - commute
  - sleep
  - existing calendar events
- System should optimize placement based on user capacity patterns

### Failure Handling
**Adaptive recovery (split + substitute hybrid)**
- Missed tasks may:
  - be broken into smaller tasks
  - be replaced with alternative strategies
- System should not blindly carry tasks forward unchanged
- Goal completion is prioritized over plan rigidity

---

## Roadmap Extensions (Locked)

### Post-Baseline Expansion Philosophy
Ambitions does not stop at the Phase 9 hardening pass.

Phase 9 establishes a strong baseline release-quality build:
- polished
- stable
- coherent
- premium-feeling
- suitable as a product baseline

After that, the roadmap continues into deliberate maturity expansion phases rather than unstructured feature growth.

The product should continue evolving in a phased manner, with each phase scoped cleanly and aligned to the core product thesis:
- realistic execution
- calm guidance
- adaptive planning
- premium personal feel
- trustworthiness over novelty

---

## Maturity Expansion Roadmap

### Phase 10 — Accounts + Sync Foundation
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
- sync must not make the app feel slower or more fragile
- identity and sync should feel calm and low-friction
- architecture should avoid a major refactor of core engines

### Phase 11 — Richer Goal Management + Plan Review
Goal:
Give users deeper, safer control over generated plans and ongoing goal evolution.

Scope:
- richer goal editing
- safer regeneration of milestones and tasks
- stronger plan review / acceptance flows
- improved domain templates
- clearer control over generated structure
- better ongoing goal detail and continuity surfaces

Rules:
- avoid CRUD-heavy UX
- preserve calm, elegant product feel
- user control should increase without making the app feel manual or bureaucratic

### Phase 12 — Insights + History
Goal:
Provide meaningful retrospective value without turning Ambitions into a dashboard product.

Scope:
- execution history
- progress trends
- domain progress visibility
- meaningful review surfaces
- momentum / continuity insights
- calm reflection tools
- historical plan and execution context

Rules:
- no gamified score obsession
- no bloated analytics dashboards
- insights should be useful, calm, and behaviorally meaningful

### Phase 13 — Smarter Personalization
Goal:
Improve personalization from longer behavioral history while staying explainable and trustworthy.

Scope:
- longer-horizon adaptation
- stronger duration refinement
- deeper strategy personalization
- richer domain-specific behavioral tuning
- improved task-size and timing recommendations
- more nuanced momentum/friction understanding

Rules:
- remain deterministic-first unless a future explicit ML phase is planned
- avoid opaque “AI coach” behavior
- preserve explainability and user trust

### Phase 14 — Advanced Integrations + Controls
Goal:
Expand real-world control and personalization without cluttering the app.

Scope:
- more nuanced calendar handling
- broader notification controls
- richer integration preferences
- deeper theme personalization
- more advanced scheduling controls
- optional future calendar-write pathways if intentionally chosen later

Rules:
- preserve low-noise product behavior
- do not create settings sprawl
- integrations should remain conservative, useful, and optional

---

## App Store Readiness Roadmap (Locked Future Milestone)

### App Store Readiness Phase
App Store readiness is an explicit roadmap target.

The product is being built toward eventual iOS App Store submission, but this phase should occur only after the core product baseline and key maturity phases are sufficiently established.

This phase must not be rushed.

Goal:
Prepare Ambitions for Apple App Store submission in a deliberate, compliant, release-quality manner.

Scope:
- Apple packaging and signing workflow
- bundle identifiers and iOS distribution setup
- App Store Connect setup
- privacy policy
- App Privacy disclosures
- permission copy audit
- submission metadata
- screenshots and asset preparation
- app icon and launch asset finalization
- TestFlight preparation
- App Review risk audit
- final iPhone/iPad device QA
- release-candidate validation

Requirements:
- the app must be stable
- permission handling must be graceful
- no misleading claims
- privacy posture must be explicit and accurate
- no obviously unfinished surfaces
- onboarding and first-run experience must be polished
- calendar and notifications permission paths must be non-disruptive
- app copy and metadata must remain calm, trustworthy, and realistic

Important:
App Store readiness is a distinct milestone, not an afterthought and not an automatic result of product completion.

The sequence should be:
1. core product build
2. hardening and baseline polish
3. maturity expansion as needed
4. App Store readiness phase
5. TestFlight / submission preparation
6. App Store submission

---

## Product Planning Rule Extension
No roadmap expansion should be treated as ad hoc feature growth.

All future work beyond Phase 9 should be added to the master plan as named phases with:
- clear scope
- explicit constraints
- product rationale
- architecture implications
- defined non-goals

---

## Non-Negotiables
- The app must feel human-made and intentional
- The daily plan must be realistic
- Tasks must respect available time
- The product must reduce cognitive load, not increase it
- Intelligence must remain controlled and useful
- The design must feel mature and commercially credible

---

## Open Questions
These are unresolved and should be locked as future work is defined:
- exact post-Phase-9 expansion sequencing after accounts/sync
- long-term sync conflict resolution strategy
- richer history model structure
- future analytics/privacy posture after accounts
- eventual App Store packaging workflow on available hardware
- whether future calendar write support should ever be included

---

## Build Planning Rule
No implementation prompt should be written until the related product decision is explicitly defined in this document.
