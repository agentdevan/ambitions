# Ambitions Master Product and Visual System v2 Decision Addendum

Status: Active canon addendum to `Ambitions_Master_Product_Visual_System_Spec_v2.md`.

Adoption date: 2026-04-30

Purpose: Preserve the latest high-impact product, IA, visual, scheduling, and interaction decisions that refine the Ambitions v2 master direction before implementation. If this addendum conflicts with older active docs, the updated master v2 spec and this addendum win unless a later explicit canon decision supersedes them.

---

## 1. Canon Board vs Product Depth

The canonical 12-screen board remains the marketing/product-architecture reference:

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

Additional surfaces are real product depth, but they are drill-downs, subflows, stateful expansions, or scrolled portions of those screens. They do not replace the canonical board and do not add top-level tabs.

Examples of allowed additional depth:

- Step Detail
- Step Session
- Goal Detail lane subviews
- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust
- Capture secondary flows: Needs a Place, Ready to Place, Grow into Goal
- Plan Day / Week / Month scopes
- Month Life Shape view

---

## 2. Terminology Lock

Deprecated normal UI copy:

- Your best next move
- next best move
- Start Focus
- Focus Session
- Overdue / Failed / Behind / Missed / Incomplete
- AI confidence / Productivity score / Optimization rating

Preferred copy:

- Start here
- Recommended step
- Start now
- Open step
- Adjust plan
- Why this?
- Close the loop
- Needs a quick check
- Still Counts
- Rescheduled
- Waiting
- Needs Review
- Needs Recovery
- Protected
- Clear
- Tight
- Ready

Use `step` for a user action. Avoid `move` as a noun for a user action. `Moved` may remain as an internal closure state; user-facing copy should usually say `Rescheduled`.

---

## 3. Focus, Context, and Step Session

Focus is not a Today CTA and should not be presented as a manually started mode.

Focus/work/school/free time are context states inside the Time Context Lens, not top-level destinations and not primary button labels.

Use context labels such as:

- Work · 2h left
- School · until 2:30
- Free time · 45m open
- Protected time · 1h
- Vacation · unavailable
- Recovery · light day
- Creative · good window

The real execution drill-down is `Step Session`, launched from `Start now` or `Open step`.

Step Session requirements:

- current step
- context state
- why it matters
- planned/suggested/user-set duration
- optional/secondary timer
- notes/proof capture
- Complete
- Still Counts
- Pause
- Adjust

Step Session is not timer-first by default. The timer must not create countdown pressure as the primary experience.

---

## 4. Hero Step Panel v2

The Today hero is the `HeroStepPanel`.

User-facing title: `Start here`.

Required anatomy:

1. Start here
2. recommended step title
3. why-now explanation
4. current context label
5. duration label with source
6. day progress or time remaining
7. primary CTA
8. secondary CTA
9. optional `Why this?`

The HeroStepPanel is adaptive:

- Compact on normal days.
- Standard when context/explanation/action is useful.
- Expanded only when explanation, recovery, closure, setup, schedule conflict, or trust is needed.

Normal days should not show a giant hero.

---

## 5. Today Rail and Closure Behavior

The Today rail is a first-class navigation spine, not decoration.

It uses:

- Now
- Next
- Later Today

Visual lock:

- left vertical rail
- connected dots
- thin line
- active/current dot strongest
- tappable rows
- rows visually imply navigation

Interaction lock:

- tap row -> lightweight Step Detail
- `Start now` from Step Detail -> Step Session
- quick action -> Complete when appropriate
- more actions -> Action Closure Sheet

Prior unclosed steps must not pollute Today. They appear as soft closure prompts such as:

- Yesterday has 2 loose ends · Review
- One step needs a quick check · Close the loop

Still Counts appears in closure/recovery sheets and relevant prompts, not everywhere completion appears.

---

## 6. Time Context Hierarchy and Real-Life Planning Rules

Recommendations must follow:

1. Hard Context
2. Availability Context
3. Cognitive Context
4. Recommendation Layer

Hard Context includes work, school, vacation/away, calendar events, commute, setup time, transition buffers, protected blocks, sleep/recovery blocks, family/household anchors, appointments, and fixed commitments.

Availability Context includes free time, open windows, flexible time, protected free time, unavailable, low-control time, available if needed, and open but do not fill.

Cognitive Context includes deep work, creative, admin, light, recovery-friendly, errands, social, planning, review, and household.

Only after those layers can Ambitions recommend a step.

The app must address these real-life issues:

- split-shift and irregular schedules
- on-call / low-control work
- commute, setup, and transition time
- family, partner, childcare, pet, and household obligations
- variable-duration steps
- hard commitments vs flexible steps
- dependencies and readiness
- location and tool constraints
- energy and cognitive fit
- over-automation and trust loss

Durations must be user-set, user-accepted, clearly suggested, historically grounded, actual, or unset. Guessed durations must never be presented as fact.

Early completion should create a reflow opportunity prompt, not silent rearrangement.

---

## 7. Plan Suite Decision

Plan may become a fuller multi-view planning suite, but it must preserve Ambitions’ believability/recovery purpose and must not become a generic calendar clone.

Use a compact scope chip for:

- Day
- Week
- Month

Default view is contextual:

- active day -> Day
- planning/review window -> Week
- long-range planning -> Month / Life Shape

Month is `Life Shape`, not a generic calendar grid.

Month emphasizes:

- life areas
- pressure weeks
- protected time
- goal milestones
- vacation / away
- major commitments
- review markers
- open weeks

Plan must show source/evidence labels where relevant:

- From your calendar
- Created in Ambitions
- Based on your plan
- From you
- Protected by you
- Suggested by Ambitions

---

## 8. Capture Decision

Top-level Capture stays minimalist and composer-driven.

First-use behavior:

- ultra-minimal first
- reveal routes after input
- no chat UI
- no normal scrolling under normal text sizes

Capture composer lock:

- bottom anchored
- text field at bottom
- mic inside field
- add button on the right
- safe-area correct

Core routes:

- Task / One-Step Goal
- Goal
- Proof
- Waiting
- Decision
- Needs a Place

Secondary flows use Ambitions-native language:

- Needs a Place
- Ready to Place
- Grow into Goal
- Recent
- Build Goal

A restrained dark-sky/starfield visual signature is allowed for Capture and First Run only.

---

## 9. You and Planning Setup

You remains the Personal System Center.

It should include a high `Planning Setup` section:

- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust

Default automation level is `Guided`.

Guided means Ambitions suggests and prepares changes, but asks before meaningful plan changes.

Vacation / away supports a default behavior plus per-vacation override.

Vacation is not free time unless explicitly marked available.

---

## 10. Goal Detail Decision

Goal Detail remains one destination with lane-based Mission Control.

Required lanes:

- Overview
- Path
- Steps
- Proof
- Decisions
- Risks
- Archive

Each lane can open deeper subviews. Do not split Goal Detail into multiple top-level destinations.

---

## 11. Receipts, Recovery, and Trust

Receipts should usually appear as subtle toast/inline confirmations with full detail available by tap/drill-down.

Recovery tone is calm, direct, and lightly supportive.

Use:

`The day changed. The goal does not have to disappear.`

Avoid failure/shame language.

---

## 12. Implementation Note

This addendum is canon direction only. It does not claim the corresponding UI, data models, behaviors, accessibility proof, real-device proof, TestFlight readiness, App Store readiness, or release readiness are already implemented. Implementation must remain evidence-gated.
