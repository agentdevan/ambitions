# Ambitions — Master Product Spec vNext
**Status:** Updated master spec replacing the prior future-phase planning doc  
**Purpose:** This is the canonical product spec for Codex phase planning going forward. It folds in the current planning source, preserves roadmap continuity, and closes the gaps around goal intelligence, feasibility, adaptive pacing, ADHD-first usability, flagship visual quality, and release readiness.

---

## 1. Product thesis

Ambitions is a calm, premium, iPhone-first personal execution system for individuals.

It is not a generic to-do app, not a project manager, not a corporate productivity dashboard, and not a chat-first AI wrapper.

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

Beauty alone is not enough.
Ambitions must earn habit by reducing cognitive load and increasing confidence.

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

Ambitions should never make the user feel like they are managing the app.
The app should manage complexity for the user.

---

## 4. Core product promises

Ambitions must be able to do all of the following:

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
Every goal setup must support 3 pacing modes:
- Conservative
- Balanced
- Aggressive

Each mode must affect:
- weekly hours
- task/session count
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

1. **Reality before aspiration**  
   The product must reflect real time, real energy, and real behavior.

2. **One best next move**  
   The app should show one clear next step before anything else.

3. **Hide what can wait**  
   Not everything deserves equal visibility at all times.

4. **Reduce shame, increase truth**  
   The app must never punish normal inconsistency.

5. **Progress must feel visible**  
   The user should feel movement, not just administrative completion.

6. **Planning must feel lighter than thinking alone**  
   If planning in the app is more mentally expensive than planning in the user’s head, the product is failing.

7. **Visible intelligence, hidden complexity**  
   The app should feel smart, but not expose raw model mechanics or become a chatbot.

8. **Premium means restraint**  
   Fewer, stronger surfaces. Better hierarchy. Better motion. Better language.

9. **Every return should reduce ambiguity**  
   Opening the app should make life feel clearer, not busier.

10. **ADHD-safe by default**  
   The app must be resilient to overwhelm, interruption, and inconsistent energy.

---

## 6. Product architecture

Ambitions should resolve downward like this:

**Ambition → Goal → Milestone → Task → Time Block → Today**

And upward like this:

**Today → Progress → Goal pace → Ambition direction**

This is what makes the product feel like an operating system rather than a task app.

---

## 7. Core surfaces

### 7.1 Today
Today is the execution center.
It must answer immediately:
- what matters now
- what is next
- what is fixed
- what is flexible
- what room is left
- how to recover if the day drifted

### 7.2 Goals
Goals must not be a disconnected list.
They must show:
- what is active
- what is represented in the week
- what is stale or crowded
- whether pace is believable
- confidence to deadline

### 7.3 Plan
Plan is the weekly shaping surface.
It must show:
- fixed commitments
- available capacity
- protected focus windows
- carryover pressure
- whether the week is believable
- how the week serves active goals

### 7.4 Review / Insights
This is the truth layer.
It must show:
- what held
- what drifted
- why drift happened
- whether goals are still on pace
- how adaptation is changing the plan
- whether the month is serving the user’s bigger direction

### 7.5 Profile
Profile is for controls and trust only.
It must not hold core workflow.
It should contain:
- reminder controls
- planning defaults
- account / sync state
- integrations health
- trust and data surfaces

---

## 8. ADHD-first product requirements

These are not optional niceties.
They are required product behaviors.

### 8.1 First-glance clarity
Every major screen must communicate its main point in under a few seconds.

### 8.2 Low decision density
The user should rarely face more than one major decision at a time.

### 8.3 Recovery over punishment
Missed work should quickly convert into a safer next step.

### 8.4 Short loops
Common actions should complete in a few taps.

### 8.5 Calm honesty
The app must tell the truth when a goal, day, or week is unrealistic.

### 8.6 Progress feeling
The product should make movement feel concrete, especially when the final result is still far away.

### 8.7 Obvious affordances
The user should not need to interpret ambiguous surfaces under stress.

---

## 9. Visual standard

Ambitions should feel:
- premium
- minimal
- warm
- modern
- authored
- calm
- obvious
- tactile
- focused
- human

It should avoid:
- toy productivity visuals
- gradient gimmicks
- glass for its own sake
- confetti completion logic
- enterprise UI density
- dashboard clutter
- juvenile card spam
- chatbot-first framing

### 9.1 Visual target
Think:
- Apple-level hierarchy and tactility
- OpenAI-level clarity and inspectability
- Craft-level warmth and polish
- the composure of a flagship consumer app

Not:
- a template-driven productivity app
- a component-library showcase
- a startup MVP with premium aspirations

### 9.2 Interaction target
All recurring interactions must feel:
- fast
- soft
- precise
- unsurprising
- reversible where appropriate

---

## 10. Language standard

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
- “Overdue wall”

---

## 11. Current state of the product

As of the current roadmap state:
- foundational systems already exist
- the app already has onboarding, planning, review, rituals, and weekly shaping foundations
- the product is beyond prototype-shell stage
- the remaining work is about turning breadth into coherence, intelligence, premium clarity, and release-grade quality

This means future phases should **deepen, unify, and harden**, not restart major systems from scratch.

---

## 12. Roadmap continuity

The existing roadmap continuity should be preserved.

- Phase 18 remains completed
- Phase 18.1 remains the weekly hardening pass
- later phases should continue numerically from there
- older phases should not be renumbered
- completed work should not be re-proposed as future greenfield work

This master spec supersedes older future-phase planning language where there is conflict.

---

## 13. Phase roadmap going forward

The roadmap can take as many phases as necessary.
The correct priority is not shortest roadmap.
The correct priority is strongest product.

### Phase 18 — Completed
**Weekly review and next-week shaping**

Already landed on `main` and established:
- weekly review state
- next-week shaping state
- weekly carryover review
- weekly reminder model
- scheduling impact from weekly shaping
- initial Insights / Profile / Plan integration

### Phase 18.1 — In progress / hardening pass
**Weekly hardening + navigation correction**

Required outcome:
- weekly review reminder is fully controllable from UI
- Plan “Next week” row routes to the correct weekly review / shaping experience
- Profile top-level planning summary preserves unfinished-work handling visibility
- Insights hero progress logic is driven by the current weekly digest rather than stale summary math
- runtime validation limitations are documented clearly while better non-web validation paths are exercised

This phase is a correction phase, not a new conceptual product phase.

---

## 14. Future phase roadmap

## Phase 19 — Monthly Review + Strategy Layer

### Purpose
Extend the weekly review system into a real monthly truth and steering layer.

### Must accomplish
- monthly review state and storage model
- monthly strategy summary
- month-level pattern reads
- month-level pace truth across active goals
- month-level drift, overload, and carryover pattern detection
- recommended month posture for the next cycle
- month reflection that is useful, not journaling homework

### UX outcome
The user should be able to understand:
- what kind of month it was
- what actually moved
- what repeatedly drifted
- whether their current direction is working
- what the next month should emphasize

### Acceptance criteria
- monthly review feels connected to weekly review, not bolted on
- month summaries are readable, honest, and calm
- the product starts telling the truth across day, week, and month as one system

---

## Phase 20 — Plan workspace deepening

### Purpose
Turn Plan into a true weekly shaping workspace, not just a planning summary surface.

### Must accomplish
- more credible weekly capacity modeling
- better fixed vs flexible distinction
- clearer focus-window protection
- stronger carryover-pressure visibility
- stronger weekly tradeoff language
- more explicit “this week is believable / too full / needs a lighter shape” logic
- better task placement controls
- stronger “shape the week” interaction quality

### UX outcome
The user should be able to open Plan and feel:
- this week is understandable
- this week is believable
- this is where to protect meaningful work
- this is where pressure is accumulating

### Acceptance criteria
- Plan is clearly useful as a weekly shaping surface
- it reduces planning stress instead of increasing it
- it visibly supports goal pacing and deadline realism

### Phase 20.1 — Completed / existing deepening pass
This phase state should still be treated as part of the truth source if already landed on main.
The product already has credible weekly Plan foundations; future work should deepen rather than restart them.

---

## Phase 21 — Goal Intelligence Engine + Today execution integration

### Purpose
This is the core moat phase.
It turns Ambitions from a polished planning app into a true execution OS.

### Must accomplish
#### 21.1 Goal intake intelligence
Users must be able to enter a goal and deadline in plain language.
The app must:
- parse the goal
- identify goal type / likely work pattern
- infer milestone structure
- infer task categories
- estimate workload
- connect the plan to calendar capacity and current behavioral reality

#### 21.2 Feasibility engine
The app must evaluate whether the goal is realistic given:
- current free time
- fixed commitments
- weekly capacity
- learned execution behavior
- selected pace mode

It must return:
- feasible
- feasible but tight
- not realistically feasible

If not feasible, it must provide:
- revised deadline suggestion
- reduced-scope option
- pacing tradeoff explanation

#### 21.3 Pace modes
Goal setup must offer:
- Conservative pacing
- Balanced pacing
- Aggressive pacing

Each option must visibly change:
- projected finish confidence
- weekly hour load
- number of sessions/tasks
- required consistency
- risk level

#### 21.4 Goal strategy composer
This must become one of the most important premium surfaces in the product.
It should show:
- goal
- target date
- available capacity
- three pace options
- feasibility state
- revised deadline if needed
- first milestone path
- first-week action preview

#### 21.5 Today integration
Today must become aware of:
- goal pace pressure
- time-to-deadline pressure
- whether the user is still on track
- what is the highest-leverage next step for protecting the goal

### UX outcome
A user should be able to put in almost any goal and feel:
- the app understands what this requires
- the app is telling the truth
- the app has translated ambition into believable work

### Acceptance criteria
- goal setup reliably generates milestone/task scaffolds
- feasibility is clearly surfaced
- revised deadline suggestions exist when needed
- pace mode selection is obvious and meaningful
- Today clearly reflects pace and deadline pressure

---

## Phase 22 — Ambition layer above Goals + progress model

### Purpose
Create the real top-down model:
**Ambition → Goal → Plan → Day**

### Must accomplish
- first-class Ambition model above Goal
- goals grouped under ambitions
- ambition-level meaning and direction context
- better goal detail structure tied upward into ambition
- better pace and confidence expression at the goal level
- explicit representation of whether active ambitions are actually being served by the calendar and plan

### Progress model requirements
Progress must now connect:
- daily progress
- weekly progress
- goal pace
- deadline realism
- ambition direction

The product should be able to say:
- this goal is on pace
- this goal is slightly off pace
- this goal needs a reset
- this goal is no longer realistic under the current timeline
- this ambition is underrepresented in your time

### UX outcome
The product stops feeling like isolated goals and starts feeling like a life-direction system.

### Acceptance criteria
- users can see bigger direction above goals
- goals feel more meaningful and grounded
- progress feels more alive than completion counts
- ambitions help determine planning and review importance

---

## Phase 23 — Review/Insights unification + explainable recommendations

### Purpose
Turn the current reflective surfaces into one coherent system.

### Must accomplish
- unify day/week/month review flows into one review architecture
- reduce duplication between Insights and Review-like surfaces
- strengthen recommendation explainability
- show why the app is recommending certain work, plans, or recovery steps
- expose rationale without exposing raw scoring internals
- support “can I still make this?” review logic

### Explainability requirements
Users should be able to inspect why the system recommends:
- this task now
- this lighter week shape
- this revised deadline
- this carryover posture
- this recovery path

The system should explain in human language using factors like:
- time left
- room in the week
- goal pace pressure
- consistency pattern
- preferred task size
- energy fit

### UX outcome
The product should feel intellectually coherent and trustworthy.

### Acceptance criteria
- review feels like one system, not scattered analytics
- recommendations feel understandable and grounded
- users can trust the system without needing to inspect scoring formulas

---

## Phase 24 — Calm retention, re-entry, and progress feeling

### Purpose
Make Ambitions habit-forming in a healthy way.

### Must accomplish
- better reminders and timing
- better re-entry after missed day(s)
- better re-entry after missed week(s)
- better “regain context fast” surfaces
- progress feeling loops that are motivating without becoming manipulative
- low-pressure continuity cues

### Progress feeling requirements
The user should regularly feel:
- I’m still moving
- I’m back on track
- I know what to do next
- the app understands the situation
- missing time does not destroy the system

### Retention rules
Use:
- calm nudges
- honest timing
- recovery suggestions
- meaningful progress language

Avoid:
- streak pressure
- shame notifications
- panic language
- noisy engagement hacks

### UX outcome
The app becomes sticky because it reduces stress and restores clarity.

### Acceptance criteria
- re-entry after drift is dramatically easier
- reminders are useful and low-pressure
- the app feels habit-forming through relief and momentum, not guilt

---

## Phase 25 — Auth, sync, trust, and cross-device hardening

### Purpose
Make the product safe to rely on across devices and over time.

### Must accomplish
- better local-only vs connected-account clarity
- stronger pending-changes visibility
- better reconnect/retry behavior
- better conflict and stale-state handling
- clearer trust language around sync and safety
- fewer silent failure modes
- clearer integration health surfaces

### UX outcome
The user should feel:
- my data is safe
- this app is reliable
- I understand whether I am synced
- I can trust this across devices

### Acceptance criteria
- cross-device trust is materially stronger
- sync state is visible enough to be understandable
- silent failure risk is lower
- account and sync surfaces feel mature

---

## Phase 26 — Flagship polish, accessibility, performance, and product coherence

### Purpose
This is the finish-quality phase.
It makes Ambitions feel like one authored product worthy of flagship positioning.

### Must accomplish
#### 26.1 Product-wide visual coherence
- tighter spacing system
- tighter hierarchy
- better canvas/card balance
- stronger dark mode authorship
- more consistent motion and state changes
- fewer seams between older and newer surfaces

#### 26.2 Accessibility
- strong Dynamic Type behavior
- VoiceOver sanity on major flows
- contrast quality
- reduced-motion respect where appropriate
- clearer affordances for cognitively stressed users

#### 26.3 Performance
- faster perceived load on major screens
- smoother transitions and scroll performance
- lower jank in high-density surfaces
- reliable state restoration

#### 26.4 Product polish
- better empty states
- better loading states
- better error states
- better first-return states
- better edge-case UI quality

### UX outcome
The app should stop feeling like phases and start feeling like one premium product.

### Acceptance criteria
- hierarchy is consistently strong across all major surfaces
- the app looks and feels flagship-grade
- accessibility is no longer a “later” item
- the product feels authored, not assembled

---

## Phase 27 — Release-candidate hardening and App Store readiness

### Purpose
A separate final phase is required for honest launch readiness.
Product-complete is not the same as release-ready.

### Must accomplish
#### 27.1 Device QA and runtime truth
- real iPhone validation
- navigation sanity across all tabs
- offline / relaunch behavior testing
- reminders firing on device
- calendar permissions and refresh flows tested end-to-end
- sync recovery paths tested
- account deletion / trust expectations checked if required

#### 27.2 Native build and runtime validation
- successful native builds
- successful install / relaunch / persistence checks
- no blocker startup issues
- Expo/runtime blockers either resolved or fully isolated from production path

#### 27.3 Store delivery assets
- app name / subtitle / positioning
- screenshots
- preview strategy if used
- icon and launch assets
- App Store description
- onboarding/store narrative consistency

#### 27.4 Legal / trust / support
- privacy policy
- data handling clarity
- App Privacy disclosures
- support contact path
- terms if required

#### 27.5 Operational readiness
- analytics instrumentation
- crash reporting
- beta / TestFlight workflow
- release notes discipline
- feedback channel
- post-launch bug triage workflow

### UX outcome
The product is not merely beautiful and coherent.
It is actually safe to ship.

### Acceptance criteria
- the product is functionally launch-ready
- the store package is credible
- legal/trust basics are covered
- operational support exists for real users

---

## 15. What the finished product must be able to do

By the end of the roadmap, I would not consider Ambitions complete unless all of these are true:

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
12. the product is genuinely launch-ready, not just feature-complete

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

From this point forward, Codex phase planning should treat this document as the canonical source of truth.

When there is conflict between:
- older future-phase planning text
- stale assumptions about what Ambitions still needs
- generic strategy suggestions

this document should win.

All future Codex prompts should be generated against:
- the real repo state on `main`
- the actual completed phases
- the in-progress phase state
- this master product spec
