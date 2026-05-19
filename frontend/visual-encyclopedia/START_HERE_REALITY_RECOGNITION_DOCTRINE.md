# Start Here Reality Recognition Doctrine

Status: Active frontend canon refinement
Installed: 2026-05-16
Authority: Subordinate to `docs/truth/*` and `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`; authoritative for Start Here state labeling, scheduled-reality recognition, recommendation boundaries, receipt source copy, and Today chrome behavior where compatible with higher truth.
Supersedes: Any lower-authority wording that treats Start Here as always a recommendation surface, uses `best next step`, or labels a currently scheduled step as `Recommended step`.
Implementation claim: Docs-only. This doctrine does not prove SwiftUI implementation, simulator/device parity, screenshot parity, accessibility conformance, performance, release readiness, or shipped behavior.

## Core Canon Decision

Start Here is a resolver-backed command object, not a generic recommendation card.

Ambitions must recognize scheduled reality before it recommends anything. If a user-scheduled, user-accepted, or calendar-backed step is currently inside its time window, the front end frames it as the current reality state. It must not repackage that scheduled item as an AI-discovered recommendation.

The product distinction:

- Generic planner: `Here is the best thing to do.`
- Ambitions: `This is what is actually active in your day. Here is the clearest way to engage with it.`

## Locked Copy Rule

- Use `Recommended step` only when Ambitions selects from unscheduled possible work.
- Use `Active step` when a scheduled step is currently inside its scheduled time window.
- Use `In progress` only after the user explicitly starts a step or session.
- Use `Up next` when a scheduled step is upcoming but not active yet.
- Never use `best next step`, `next best move`, `optimal move`, or equivalent recommendation language for scheduled reality.

## Authority and Temporal Truth

Start Here state is resolved from two independent truths.

| Dimension | Values |
| --- | --- |
| Authority | User scheduled, User accepted, Calendar commitment, Local recommendation, Recovery, Closure, Protected context, Away context, Setup |
| Temporal relation | Before window, Active window, In progress, Overrunning, Missed, Complete, Blocked, Deferred |

The visible state label is derived from authority plus temporal relation. A scheduled active window resolves to `Active step`, not `Recommended step`.

## Resolver Precedence

The Start Here resolver must be deterministic. Resolve candidates in this order unless higher truth changes precedence:

1. Active session → `In progress` → primary CTA `Resume`.
2. Hard current commitment → `Current commitment`, `Protected time`, or `Away mode`.
3. Scheduled active step → `Active step` → primary CTA `Start now`.
4. Overrunning active step → `Needs closure` → primary CTA `Close loop`.
5. High-priority unresolved loop → `Needs closure`.
6. Upcoming scheduled step → `Up next` → primary CTA `Open step`.
7. Open free window with no scheduled step → `Recommended step` → primary CTA `Start now`.
8. Broken fit / plan drift → `Recovery` → primary CTA `Recover plan`.
9. Missing context → `Set up today` → primary CTA `Add schedule`.
10. Competing hard/scheduled items → `Schedule conflict` → primary CTA `Resolve conflict`.

## Approved Start Here Labels

Only these labels are approved for the Start Here state position:

| Label | Use when |
| --- | --- |
| In progress | User explicitly started a step/session. |
| Active step | Scheduled step is currently active in time. |
| Current commitment | Calendar, work, school, commute, or hard schedule commitment is active. |
| Protected time | User marked the block unavailable. |
| Away mode | Vacation/away block is active. |
| Up next | Scheduled item is upcoming. |
| Recommended step | Ambitions selected from unscheduled options. |
| Needs closure | Prior step needs a landing place. |
| Recovery | Plan no longer fits reality. |
| Set up today | Not enough context exists. |
| Schedule conflict | Multiple hard or scheduled items compete for the same window. |

Forbidden labels: `Best next step`, `Next best move`, `Optimal move`, `AI pick`, `Suggested by AI`, `Productivity recommendation`, `Overdue`, `Failed`, `Behind`.

## Standard Start Here Anatomy

Use stable anatomy while content changes by state:

1. `Start Here · [State Label]`
2. Step, commitment, or recovery title
3. One-line reality explanation
4. Threadline
5. Time fit, schedule fit, or capacity fit
6. Primary CTA
7. Quieter correction path
8. Receipt Handle

### Active scheduled step copy

```text
Start Here · Active step
Outline product brief
Scheduled now. Fits your current window and keeps Launch v1.0 moving.
Launch v1.0 → Product → Outline brief
75 min · Good window · Until 7:30 PM
Start now
Adjust plan
Why this? · Scheduled step · 3 local signals
```

### Recommendation copy

```text
Start Here · Recommended step
Review marketing plan
You have an open 45-minute window. This fits your capacity and moves Launch v1.0 forward.
Launch v1.0 → Marketing → Review plan
45 min · Good fit · Low setup cost
Start now
See alternatives
Why this? · Local recommendation · 4 signals
```

### Recovery copy

```text
Start Here · Recovery
Rebuild the evening
Reality changed. Pick what still counts, then Ambitions will reshape the remaining day.
Today → Open loops → Evening plan
2 loops need a landing place
Recover plan
Keep as is
Why now? · Plan drift detected
```

## Receipt Source Rules

Receipt source must match authority. It should not always say `local reasoning`.

| Start Here state | Receipt source |
| --- | --- |
| Active step | Scheduled step |
| In progress | Active session |
| Up next | Scheduled step |
| Recommended step | Local recommendation |
| Recovery | Reality change |
| Needs closure | Open loop |
| Protected time | Availability rule |
| Away mode | Away setting |
| Current commitment | Calendar / schedule source |
| Schedule conflict | Conflict source |
| Set up today | Missing context |

Trust rule: Ambitions is not always reasoning or recommending. Sometimes it is recognizing reality. The receipt language must make that clear.

## Reality Meridian Relationship

The Reality Meridian must visually prove the Start Here state.

- If Start Here is `Active step`, the scheduled block remains at its actual time, the current-time glow sits at exact now, and the Start Here Aperture is visibly linked to that active block.
- If the step is overrunning, the scheduled block remains in the past, the current-time glow is below it, and Start Here changes to `Needs closure`.
- If there is no scheduled step, any `Recommended step` must visually emerge from open free time rather than from a scheduled block.

## ADHD-Friendly Maturity Rules

- Scheduled-current work gets `Active step`, not ambiguous recommendation language.
- Recovery is part of the shell, not an error state.
- Use `Reality changed`, not `You missed this`.
- Use `Needs a landing place`, not `Overdue`.
- Every state gets one dominant CTA and one quieter correction path.
- Supporting reasons progressively disclose behind the receipt handle.
- Low-energy or high-pressure variants reduce visible choices.

## Primary CTA Matrix

| State | Primary CTA |
| --- | --- |
| In progress | Resume |
| Active step | Start now |
| Up next | Open step |
| Recommended step | Start now |
| Needs closure | Close loop |
| Recovery | Recover plan |
| Protected time | View block |
| Away mode | View commitments |
| Current commitment | View commitment |
| Schedule conflict | Resolve conflict |
| Set up today | Add schedule |

No state may present three equal-weight CTAs at rest.

## Command Object Contract

The Start Here surface must behave like a command object with one dominant action and one quieter correction path.

- It exposes authority, temporal relation, receipt source, and visible state label together.
- It never presents a generic recommendation-card hierarchy.
- It uses exactly one primary CTA at rest.
- It may offer one quieter correction path for adjustment, recovery, or inspection, but not an equal-weight second command.
- It must keep `Recommended step`, `Active step`, `In progress`, `Up next`, `Needs closure`, `Recovery`, `Protected time`, `Away mode`, `Current commitment`, and `Schedule conflict` exact.

## Runtime Contract

The local Start Here Resolver must return a reasoned state, not only a task id.

Required output fields:

- `StartHereMode`
- `StartHereAuthority`
- `TemporalRelation`
- display label
- primary object
- explanation copy
- primary CTA
- quieter correction path
- receipt source
- receipt signals
- visual tone
- accessibility label

Bad output: `taskId: 123`.

Good output: `state: activeStep`, `authority: userScheduled`, `temporalRelation: activeWindow`, `receiptSource: scheduledStep`, `signals: currentTimeInsideWindow, goalThread, timeFit`.

## Edge Cases

- Two scheduled steps overlap → `Schedule conflict`; primary CTA `Resolve conflict`.
- Hard calendar event overlaps an Ambitions step → `Current commitment` wins; Ambitions step moves toward recovery or closure.
- Flexible calendar event overlaps an Ambitions step → `Schedule conflict`.
- User starts a different step → visible state becomes `In progress`; displaced scheduled step may need closure later.
- Active step window ends while user is working → visible state remains `In progress`; Active Thread Strip may say `Window passed · Still working`.
- User ignores active step after a grace period → transition to `Needs closure`, not `Overdue`.
- Protected time override → explicit choice and receipt required.
- Away mode → no normal goal-work recommendation unless the away block is explicitly marked available.

## Implementation Sequence

1. `START-HERE-CANON-01` — install and validate canon, labels, copy, and state hierarchy.
2. `START-HERE-RESOLVER-01` — implement local resolver and tests.
3. `START-HERE-UI-01` — render Start Here Aperture from resolver output.
4. `RECEIPT-VEIL-01` — make receipt source and signal copy authority-aware.
5. `REALITY-MERIDIAN-LINK-01` — bind Start Here state to exact-time Meridian visuals.
6. `RECOVERY-LENS-01` — install closure, overrun, and drift states.
7. `ADHD-CHROME-PASS-01` — simplify choices and add restart/landing-place language.
8. `FRONTEND-PROOF-01` — generate previews/screenshots and validate accessibility/motion.

## Validation Gates

| Gate | Pass condition |
| --- | --- |
| Scheduled reality | Scheduled-current steps render as `Active step`, not `Recommended step`. |
| Recommendation boundary | `Recommended step` appears only when Ambitions selects from unscheduled possible work. |
| Resolver authority | UI labels come from resolver output, not ad hoc task data. |
| Receipt source | Receipt source matches authority. |
| Meridian proof | The Reality Meridian visually confirms the Start Here state. |
| ADHD clarity | One dominant action and one safe correction path are visible at rest. |
| Accessibility | State is understandable without color, glow, motion, or small type. |
| Release honesty | No implementation or screenshot parity claim without source and proof artifacts. |

## Hard Red Conditions

Stop any implementation or canon update that would use `best next step`, label scheduled-current work as `Recommended step`, hide receipt authority, detach Start Here from Reality Meridian, collapse `Active step`, `In progress`, and `Recommended step`, use shame language, silently reflow plans without preview/receipt/undo, or convey state only through color, glow, or animation.

## Bottom Line

The breakthrough is not `Ambitions found the best task`.

The breakthrough is `Ambitions understands your current reality`.
