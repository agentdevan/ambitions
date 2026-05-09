# 11 — Canonical Vocabulary And Copy Bible

Status: active canon, docs-only.

Purpose:

- define user-facing Ambitions language
- separate user-facing labels from internal object names
- purge compatibility names from active canon
- lock copy tone, banned phrases, and state language
- prevent AI/productivity/dashboard/habit/calendar drift

## Voice

Ambitions sounds:

```text
calm
direct
human
specific
non-shaming
source-aware
quietly intelligent
confident but humble
never cute
never mystical
never motivational
never AI-branded
never productivity-bro
never system-admin
```

Ambitions should sound like a calm operating surface, not a coach, therapist, boss, AI, productivity influencer, or admin console.

## User-Facing Surface Labels

| Surface | Tab label | Screen title | Primary role |
| --- | --- | --- | --- |
| Today | Today | Start Here | action now |
| Goals | Goals | Your Direction | meaning |
| Capture | Capture | Capture Anything | intake |
| Time | Time | Shape Time | capacity |
| You | You | Your System | control |

## User-Facing Core Language

Approved terms:

- Start here
- Recommended step
- Start now
- Open step
- Adjust plan
- Why this?
- Still counts
- Shape week
- Review pressure
- Open time
- Goal time
- Protected
- Pressure
- Needs a Place
- Ready to Place
- Grow into Goal
- Trust & Automation
- Privacy
- Receipt
- Receipts & History
- Source
- Manual mode
- Preview Reflow
- Waiting
- Blocked
- Needs recovery
- Needs review
- Make today lighter
- Reality changed
- Saved safely
- Place
- Hold
- Held item
- Held for Review
- Close Today
- Personal Runtime
- Proof
- Proof Transfers
- Source Needed
- Source Needed Mode
- Correction Fold
- This week can hold

## Internal Object Names

These names are canon for design, implementation, QA, docs, and product architecture. They do not need to appear as primary user-facing labels.

- AmbitionsShell
- Context Crown
- Continuity Dock
- Meridian Edge
- Trust Seam
- Receipt Surface
- Quiet Reflow
- Cross-Object Threads
- Reality Meridian
- Start Here Surface
- Constellation Atlas
- Orbital Lens
- Atmosphere Composer
- LifeShape Field
- User System Profile

Rule: users should not need internal object names to understand Ambitions.

## Canonical Concept Words

| Concept | Canon word | Notes |
| --- | --- | --- |
| long-term outcome | Goal | never score/rank by system preference |
| life category | Life area | visible in Goals |
| concrete action | Step | not task as primary language |
| today’s recommendation | Start here / Recommended step | never best next move |
| capacity surface | Time | replaces Plan as top-level tab |
| capacity action | Shape | Shape week, Shape Time |
| proof | Receipt | not notification/feed |
| explanation | Why this? | source-aware |
| partial completion | Still counts | validates real progress |
| raw input | Capture | singular label |
| unplaced input | Needs a Place | safe, non-shaming |
| route-ready input | Ready to Place | user-owned placement |
| goal seed | Grow into Goal | not automatic overclassification |
| uncertain or sensitive item | Hold / Held item | safe until reviewed |
| personal intelligence profile | Personal Runtime | You drill-down, not top-level label |
| Today closure ritual | Close Today | small closure, not daily dashboard |
| path/pivot proof continuity | Proof Transfers | Goals / Option Value language |
| unsafe or unproven source state | Source Needed Mode | consistent trust/source state |
| focused correction reveal | Correction Fold | secondary action, not generic settings |
| system controls | You / Your System | not Profile |
| automation controls | Trust & Automation | trust before automation |
| unavailable by choice | Protected | not blocked |
| too much load | Pressure | not danger |
| user control | Adjust | never hidden |

## Compatibility Name Purge Protocol

Active canon must not use compatibility names as active names.

Forbidden active terms:

- DayTimelineRail
- Reality Rail
- Day Rail
- Hero Step Panel
- Hero Step Module
- LifePath View
- LifeShape Map
- Personal System Center
- Ambition Meridian Shell
- Trust Receipt Layer
- Plan as top-level tab
- Profile as top-level label
- Captures as top-level label
- Habits as primary IA
- Insights as primary IA
- Dashboard
- Assistant
- Calendar as primary tab
- Inbox as primary tab

Canonical replacements:

| Compatibility term | Canon term |
| --- | --- |
| DayTimelineRail | Reality Meridian |
| Reality Rail | Reality Meridian |
| Day Rail | Reality Meridian |
| Hero Step Panel | Start Here Surface |
| Hero Step Module | Start Here Surface |
| LifePath View | Constellation Atlas / Orbital Lens |
| LifeShape Map | LifeShape Field |
| Personal System Center | User System Profile / Your System |
| Profile | You / User System Profile / Your System |
| Captures | Capture / Atmosphere Composer |
| Ambition Meridian Shell | AmbitionsShell + Continuity Dock + Meridian Edge |
| Trust Receipt Layer | Trust Seam + Receipt Surface |
| Plan tab | Time tab |
| Plan screen | Time / Shape Time / LifeShape Field |
| Automation & Trust | Trust & Automation |
| Receipts archive | Receipts & History |

Rules:

1. Active canon uses final names only.
2. Old names may appear only in Archive, Migration Map, or explicit compatibility reports.
3. Prompts fail if old names are used as active names.
4. Code may temporarily retain old symbols only with migration notes and no user-facing leakage.
5. User-facing UI contains no compatibility names.
6. Preview fixtures use final canon names.
7. Visual QA reports use final canon names.
8. Batch reports distinguish legacy owner file from canon object.
9. Docs say superseded by, not mapped from, once cleanup is complete.
10. Any resurfacing of old names requires a cleanup ticket.

## Banned Copy

Hard-ban in active user-facing UI:

- best next move
- next best move
- AI recommends
- AI decided
- optimize your day
- optimize your life
- maximize productivity
- crush your goals
- get back on track
- you missed it
- overdue
- failed
- streak broken
- habit score
- life score
- productivity score
- assistant
- AI assistant
- coach
- AI coach
- chatbot
- dashboard
- inbox zero
- focus mode as primary CTA
- smart, when used as vague product adjective
- smart capture
- AI-powered, inside product UI
- GPT
- GPT-like
- model confidence
- confidence percentage
- best local AI
- write text
- draft email
- draft message
- message-writing assistant
- boost
- hustle
- grind

## Surface Encapsulation Signature Addendum

This addendum preserves mature signature language for future AmbitionsOS / AIR
surface encapsulation. It does not implement UI/runtime behavior.

Required additions:

- `Hold` / `Held item` is the user-facing uncertainty and safety language for
  items that need review, source, privacy confirmation, or placement.
- `Personal Runtime` is a You drill-down concept for visible local
  personalization, not a top-level label, AI profile, or theme setting.
- `Close Today` is the Today closure phrase for resolving what closed, moved,
  still counts, or remains held.
- `Proof Transfers` is the Goals / Option Value phrase for path and pivot proof
  continuity.
- `This week can hold` is protected Tier 1 Time language and must remain tied
  to capacity truth, not calendar availability theater.
- `Source Needed Mode` is the consistent source/trust state for facts Ambitions
  cannot safely use as guidance yet.
- `Correction Fold` is the secondary action/fold concept for focused
  corrections such as wrong place, wrong time, wrong size, wrong goal, too
  personal, stop using this, and forget this.

Forbidden active user-facing product language also includes chatbot, AI
assistant, AI coach, model confidence, confidence percentage, GPT, GPT-like,
best local AI, write text, draft email, draft message, and message-writing
assistant. Internal architecture docs may discuss a GPT-like understanding
effect only as non-user-facing explanation.

## Surface Copy Patterns

### Today

Preferred:

```text
Start Here
Recommended step
Fits now
Still counts
Open step
Adjust plan
Why this?
Reality changed
Make today lighter
Needs closure
```

Example:

```text
Start Here
Recommended step
Draft the chorus idea
25 min · Fits before your next protected block
Why this?
Start now
```

Still Counts example:

```text
Still counts
You made progress. Close the loop without changing the plan.
```

Recovery example:

```text
Reality changed
This no longer fits cleanly. Review a lighter version.
```

Avoid:

```text
Today dashboard
Tasks
Focus mode
Best next move
Overdue
Failed
```

### Goals

Preferred:

```text
Your Direction
Life areas
Goal thread
Open Music
Connected to Today
This thread can feed Today
```

Example:

```text
Your Direction
Music, Career, Money, Health, Relationships
Music has one thread feeding Today.
```

Avoid:

```text
Portfolio
KPI
Score
Performance
Mission Control as top-level
North Star overload
```

### Capture

Preferred:

```text
Capture Anything
What needs a place?
Needs a Place
Ready to Place
Grow into Goal
Saved safely
Save capture
```

Example:

```text
Capture Anything
What needs a place?
```

Low-confidence example:

```text
Saved safely.
Needs a Place.
```

Avoid:

```text
Inbox
Notes
AI sorted this
Smart capture
Classified automatically
```

### Time

Preferred:

```text
Shape Time
Open time
Goal time
Protected
Pressure
Shape week
Review pressure
This week can hold
Capacity truth
```

Example:

```text
Shape Time
6 hours open
2 protected blocks
Pressure is highest Friday afternoon.
Review pressure
```

Capacity Truth example:

```text
This week can hold:
3 focused blocks
2 light steps
1 protected recovery window
```

Avoid:

```text
Calendar
Agenda
Schedule dashboard
Availability grid
Overloaded
Warning
```

### You

Preferred:

```text
Your System
Planning Setup
Trust & Automation
Privacy
Receipts & History
Planning Defaults
Schedule & Availability
Manual mode
```

Example:

```text
Your System
Set how Ambitions plans, explains, remembers, and asks.
```

Trust example:

```text
Trust & Automation
Choose how much Ambitions can suggest or reflow.
```

Receipts example:

```text
Receipts & History
Review what changed and why.
```

Avoid:

```text
Profile
Account hub
Admin
AI settings
Control panel
```

## Trust Copy Contract

Every Why this? explanation should use:

```text
Recommendation
Source
Reason
Uncertainty, if any
User control
Receipt behavior
```

Example:

```text
Recommended step: Draft chorus idea
Source: Music goal + 30 minutes open
Reason: This fits before your next protected block
Control: Start now, adjust plan, or skip for now
Receipt: Starting leaves no schedule change
```

## Emotional Tone Rules

1. Pressure is not danger.
2. Protected is not blocked.
3. Waiting is not failure.
4. Still Counts is not consolation.
5. Recovery is not punishment.
6. Manual mode is not lesser.
7. No calendar access is not broken.
8. Empty state is not failure.
9. Source unavailable is not blame.
10. User drift is expected.

## Copy QA Gates

A phrase fails if:

1. it sounds like productivity guilt
2. it sounds like an AI assistant
3. it sounds like admin software
4. it sounds mystical/astrological
5. it could appear unchanged in any generic task app
6. it implies certainty Ambitions does not have
7. it implies automation without control
8. it shames delay, partial completion, or recovery
9. it hides source or trust
10. it makes the founder confused about hierarchy

Founder read-aloud QA is required for major surface copy.
