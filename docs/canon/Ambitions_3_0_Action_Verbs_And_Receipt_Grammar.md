# Ambitions 3.0 — Action Verbs And Receipt Grammar

Status: Active Ambitions 3.0 copy and trust canon contract  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Ambitions should use a consistent action grammar across Today, Capture, Place, Plan, Goals, Closure, Proof, Trust, and You.

This document prevents generic productivity language, AI theater, shame language, and inconsistent receipts.

---

## Canonical Action Verbs

| User intent | Preferred CTA | Avoid |
|---|---|---|
| Begin a step | Start now | Start Focus |
| Inspect before doing | Open step | View task |
| Change plan | Adjust plan | Optimize |
| Explain recommendation | Why this? | AI reasoning |
| Make a step smaller | Make smaller | Simplify with AI |
| Put somewhere | Place it | Route / classify |
| Save evidence | Save as proof | Log progress |
| Resolve reality state | Close the loop | Mark failed |
| Change time | Reschedule | Move as a final-state noun where Rescheduled fits better |
| Leave intentionally | Not needed | Drop |
| Delay decision | Review later | Snooze forever |
| Correct system | Change this | Fix AI |
| Undo reversible action | Undo | Revert system event |
| Confirm external write | Add to Calendar | Sync automatically |
| Set availability | Set schedule | Configure availability engine |
| Choose automation | Use Guided | Enable AI mode |

---

## Preferred User-Facing Terms

Use:

- Start here
- Recommended step
- Start now
- Open step
- Adjust plan
- Why this?
- Make smaller
- Place it
- Needs a Place
- Ready to Place
- Grow into Goal
- Close the loop
- Still Counts
- Rescheduled
- Waiting
- Blocked
- Needs Review
- Needs Recovery
- Review later
- Saved as proof
- What counted
- No silent changes

Avoid in normal UI:

- Your best next move
- next best move
- Start Focus
- Focus Session
- AI confidence
- Productivity score
- Optimization rating
- Overdue
- Failed
- Behind
- Missed
- Incomplete
- Streak
- Hustle-coded pressure language

---

## Internal vs Visible Copy

Internal names may use precise implementation language only when necessary.

Visible UI must translate internal concepts into human copy.

| Internal / product term | Preferred visible copy |
|---|---|
| Believability Kernel | Looks doable / Too much planned |
| Recommendation Engine | Suggested because |
| Event Ledger | Receipts |
| Memory Graph | What Ambitions Knows |
| Action Closure | Close the loop |
| Day Rail Projection | Today |
| Optimization | Adjust plan / Make doable |
| Confidence | Why this / Based on |
| Recovery Cascade | Make today doable |

---

## Receipt Copy Pattern

Receipts should use:

```text
[Result] · [Object] · [Destination or consequence]
```

Examples:

```text
Saved as Step · Today
Attached as Proof · Music Goal
Rescheduled · Friday
Still Counts · Saved as proof
Plan adjusted · You approved this
Memory updated · Based on your correction
Saved locally · Calendar block was not created
```

---

## Receipt Anatomy

A meaningful receipt should be able to answer:

1. What happened?
2. What changed?
3. Why did it change?
4. Who or what changed it?
5. Can the user undo it?
6. Can the user correct it?
7. Is anything private or hidden?
8. Where can the user see the full trail?

---

## Receipt Visibility Levels

- Toast: small confirmation
- Peek: short drill-down from toast/card
- Trail: chronological object history
- Search: full receipt history
- Export: user-controlled data package

A toast alone is not enough for a meaningful change. The receipt must be recoverable later through history/search when that surface is implemented.

---

## Copy Temperature

Ambitions copy should be:

- calm
- adult
- precise
- lightly supportive
- non-performative

Avoid:

- hype
- hustle
- therapy-speak
- childlike encouragement
- AI assistant chatter
- corporate productivity jargon

---

## Sensitive Copy Pattern

Sensitive/private objects use:

- Private item
- Hidden details
- Saved privately
- Details hidden here
- Open to review

Avoid harsh privacy wording that makes the user feel monitored or alarmed.

---

## Task vs Step Resolution

`Task` remains valid only for standalone One-Step Goal objects.

`Step` is preferred when the action belongs to a Goal, Path, Plan, Today rail, or Step Session.

Capture may route to Task when standalone.

Today should generally say `Recommended step`.

---

## Move vs Rescheduled Resolution

Internal state may remain `moved`.

Closure action may appear as `Move` where space is constrained.

Receipt and final user-facing state should usually prefer `Rescheduled`.

---

## Acceptance Criteria

A copy or receipt change passes when:

- visible UI avoids deprecated language
- buttons are verb-led and specific
- receipts follow the result/object/consequence pattern
- sensitive copy is privacy-safe and calm
- user-facing language is human, not AI/product-system language
- implementation summaries call out any temporary compatibility wording
