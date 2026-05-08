# 10 — Ambitions Flagship Interface Canon

Status: active flagship canon, docs-only.

This document upgrades Ambitions from product/design canon into a flagship interface system. It preserves every approved upgrade recorded in `09_Flagship_Interface_Preservation_Ledger.md` while presenting the clean active rules future design, Codex, and implementation work must follow.

## Flagship Thesis

Short thesis:

```text
Ambitions turns life direction into action today.
```

Flagship thesis:

```text
Ambitions turns the life you mean to build into the next step that fits today.
```

Ambitions is not a task app, calendar app, notes app, habit tracker, dashboard, chatbot, admin console, or generic SwiftUI demo. Ambitions is a premium native iPhone life operating system for turning intention into grounded action without shame, noise, or black-box automation.

## Final Product Spine

```text
Direction gives meaning.
Time gives reality.
Today gives action.
Capture gives safety.
You gives control.
```

Operational form:

```text
Goals define direction.
Time shapes capacity.
Today starts what fits now.
Capture holds what has no place yet.
You controls trust, privacy, and defaults.
```

Conceptual hierarchy:

```text
Goals → Time → Today
Capture feeds all three.
You governs the system.
```

Daily navigation order:

```text
Today → Goals → Capture → Time → You
```

Tab order is not hierarchy. Today remains first because it is the daily home. Goals remains conceptually higher because it defines what Time and Today serve.

## Final Top-Level IA

The only top-level tabs are:

1. Today
2. Goals
3. Capture
4. Time
5. You

Hard Red if any other destination becomes a primary tab, including Mission Control, Dashboard, Assistant, Calendar, Inbox, Settings, Habits, Insights, Profile, Captures, or any sixth tab.

Mission Control, if present, belongs inside Goal Detail only.

Calendar is a source for Time, not a tab.

Plan is not a top-level destination. Plan remains an action or contextual noun in copy such as Adjust plan, Shape week, or Review pressure.

## Surface Identity System

| Tab | Screen title | Product role | Primary object | Emotional role |
| --- | --- | --- | --- | --- |
| Today | Start Here | action now | Reality Meridian + Start Here Surface | relief / clarity |
| Goals | Your Direction | meaning | Constellation Atlas + Orbital Lens | orientation |
| Capture | Capture Anything | intake | Atmosphere Composer | safety |
| Time | Shape Time | capacity | LifeShape Field | realism |
| You | Your System | control | User System Profile | trust |

Every top-level screen must be understandable from its title, object, and primary action within three seconds.

## One Question Per Screen

| Screen | User question | Failure mode |
| --- | --- | --- |
| Today | What should I do now? | task list / generic dashboard |
| Goals | What is my life pointed at? | KPI portfolio / ranked life score |
| Capture | Where do I put this thought? | notes feed / inbox / chatbot |
| Time | What can my life actually hold? | calendar clone / schedule dashboard |
| You | How does Ambitions work for me? | social profile / admin console |

## Signature Object Model

```text
TodayScreen = AmbitionsShell + RealityMeridian + StartHereSurface
GoalsScreen = AmbitionsShell + ConstellationAtlas + OrbitalLens
CaptureScreen = AmbitionsShell + AtmosphereComposer
TimeScreen = AmbitionsShell + LifeShapeField
YouScreen = AmbitionsShell + UserSystemProfile
```

One living object dominates each top-level surface. The app fails flagship quality if a top-level screen is primarily a pile of cards, rows, dashboards, feeds, or generic modules.

## Human Object Explanations

| Object | Human explanation |
| --- | --- |
| Reality Meridian | Your day as it is actually unfolding. |
| Start Here Surface | The one place to begin now. |
| Constellation Atlas | Your life areas, visible without ranking them. |
| Orbital Lens | A focused view into one life area. |
| Atmosphere Composer | A quiet place to put anything. |
| LifeShape Field | A view of what your time can actually hold. |
| User System Profile | The controls for how Ambitions understands and helps you. |
| Trust Seam | The place where Ambitions explains why something happened. |
| Receipt Surface | Calm proof that something changed. |
| Quiet Reflow | A respectful preview when reality changes the plan. |
| Continuity Dock | Navigation that quietly carries state between surfaces. |
| Context Crown | A compact orientation line for where you are and what matters. |
| Meridian Edge | A subtle edge trace for continuity and current state. |

Users do not need to learn these internal object names to use Ambitions. These names are canon for design, implementation, QA, and product coherence.

## Product Grammar

```text
Capture → Clarify → Shape → Start → Close → Remember
```

| Stage | Primary surface |
| --- | --- |
| Capture | Capture |
| Clarify | Capture / Goals |
| Shape | Time |
| Start | Today |
| Close | Today / Receipt Surface |
| Remember | You / Trust Seam / Receipts & History |

Ambitions does not just manage tasks. Ambitions carries raw intention through clarification, capacity, action, closure, and memory.

## Ambitions Promise Ladder

```text
Capture anything.
Give it a place.
Shape your time around what matters.
Start where reality allows.
Close the loop without shame.
Trust what changed.
```

Each line must be visible in the product through surface behavior, copy, state, and proof.

## Signature Moments

Every top-level surface owns one unforgettable moment.

| Surface | Signature moment |
| --- | --- |
| Today | Start Here emerges from the Reality Meridian. |
| Goals | Life areas are visible without being ranked by the system. |
| Capture | A thought is safely held before it needs structure. |
| Time | The week’s real capacity becomes visible without becoming a calendar. |
| You | The user sees exactly how Ambitions is allowed to help. |

These are QA targets, not marketing garnish.

## Flagship Experience Laws

1. One living object per top-level surface.
2. Every visual detail must do product work.
3. The app must be understandable without knowing the canon.
4. The app must be recognizable with text removed.
5. Celestial means orientation, not space decoration.
6. Luxury means restraint, not ornament.
7. Intelligence means explanation, not AI chrome.
8. Executive means command clarity, not dashboards.
9. Alive means current state, not animation.
10. Evolving means user-owned adaptation, not fake personalization.
11. Trust appears exactly when earned.
12. Receipts are proof, not notifications.
13. Recovery is normal, not failure.
14. Manual mode is first-class.
15. A tired user should feel less burdened after opening Ambitions.

## Luxury Restraint Budget

At rest, each top-level surface is limited to:

- 1 primary object
- 1 primary action
- 1 accent system
- 1 active proof/receipt
- 1 open trust explanation max
- 3 visible modules max
- 0 badges
- 0 score widgets
- 0 decorative stars
- 0 generic dashboard tiles

If more is needed, it belongs in drill-down, Trust Seam, receipt archive, or a focused sheet.

## Three-Second Identity Test

A reviewer should understand the surface identity within three seconds. If a screenshot reads as task app, calendar app, notes app, dashboard, habit tracker, chatbot, SaaS admin panel, astrology app, sci-fi HUD, or generic SwiftUI demo, the surface fails.

## Founder Clarity Script

The UI must support this 60-second founder demo without explanation beyond what appears onscreen:

```text
This is Today. It shows what fits now.
This is Goals. It shows what your life is pointed at.
This is Capture. It catches anything before it has a place.
This is Time. It shows what your week can actually hold.
This is You. It controls trust, privacy, and how Ambitions helps.
```

If the UI cannot support this script visually, the UI is not done.

## Award-Caliber Screenshot Gate

Before flagship completion, five top-level screenshots must plausibly stand on their own in an Apple Design Award-style review without requiring a lengthy canon explanation.

A top-level surface cannot be Green for visual quality without screenshot or rendered preview evidence.

## Memorable Patterns

### Reality Check

Used when intention and reality diverge.

```text
Reality changed.
This still has a path.
```

Actions may include Still counts, Move it, Make it lighter, Not needed.

### Capacity Truth

Used in Time.

```text
This week can hold:
3 focused blocks
2 light steps
1 protected recovery window
```

This replaces calendar-clone and schedule-dashboard behavior.

### Thread to Today

Used in Goals.

```text
This thread can feed Today.
```

Goals have threads that can become grounded daily action.

### Safe Capture

Used in Capture.

```text
Saved safely.
Needs a Place.
```

Capture must reduce pressure, not force organization.

### Trust Before Action

Used before adaptive recommendations.

```text
Why this?
Source: Music goal + 25 minutes open
```

### Proof Without Noise

Receipts appear as quiet proof, not alerts.

```text
Receipt
Week shaped · You approved this
```

### Less, But Better Recovery

Used when overloaded.

```text
Make today lighter.
```

Actions may include Keep one step, Move the rest, Protect time.

### Manual Is Respected

Used when automation is off.

```text
Manual mode
Ambitions will suggest nothing until you ask.
```

### Quiet Intelligence Marker

Use concrete sources, not AI branding.

```text
Source: Calendar
Source: Music goal
Source: Planning default
```

### Open Loop Closure

Prior unfinished steps do not become overdue; they become closure prompts.

```text
Needs closure
Still counts, move it, or let it go.
```

## Founder Acceptance Gates

Founder feedback is product evidence.

1. Founder confusion is a Yellow/Red signal.
2. If the founder cannot explain hierarchy, canon is not done.
3. If the founder says card-like, composition must change.
4. If the founder says underwhelming, object silhouette needs stronger invention.
5. If the founder says too cold, copy/material needs human warmth.
6. If the founder says gimmicky, ornament must be reduced.
7. If the founder says confusing, IA/language must simplify.
8. If the founder says flagship only, Yellow cannot be called complete.
9. Founder review is required after major visual object changes.
10. Founder override requires a written decision record.

## Flagship Completion Rule

A flagship claim requires:

- final top-level IA: Today, Goals, Capture, Time, You
- no active compatibility names
- one dominant object per top-level surface
- screenshot/rendered preview evidence
- visual QA scoring
- accessibility notes
- Reduce Motion notes
- trust/source/receipt notes
- validation evidence
- no unresolved Hard Red

Without proof, the status is Yellow, not Green.
