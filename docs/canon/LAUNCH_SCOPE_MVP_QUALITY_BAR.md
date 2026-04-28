# Ambitions Launch Scope, MVP, And Quality Bar

Status: Active canon consolidation layer.

Purpose: Consolidate launch proof, MVP boundaries, quality bar, acceptance gates, delayed-feature policy, launch north star, and Golden Launch Loop cutline into one implementation-readable reference. This document reflects Wave 17 product decisions and the product-strength rules in `GOLDEN_LAUNCH_LOOP.md`.

## Core Launch Doctrine

Launch should prove:

```text
A meaningful goal can become organized, doable, and actionable today.
```

Launch north star:

```text
Prove Ambitions can make one meaningful goal feel organized, doable, recoverable, and real.
```

Rules:

- Launch is not a feature-count contest.
- Launch does not need every canon idea.
- Launch should prove the core loop with enough quality that the product feels trustworthy.
- A smaller complete system is better than a wide partial system.
- Launch-critical work must map to the Golden Launch Loop.

## Golden Launch Loop

Launch-critical features must support at least one step in this loop:

```text
1. Capture one meaningful goal or task.
2. Put it in the right place.
3. Turn it into a doable plan.
4. Show what to do today.
5. When today is too much, make it doable.
6. Save proof that progress happened.
```

Recommended launch demo:

```text
Release 3 songs by August 1.
```

The demo should show capture, routing, simple planning, Today next action, recovery when too much is planned, and proof/receipt after progress.

## Launch Quality Bar

Launch quality bar:

```text
Stable, understandable, useful, and trustworthy.
```

This means:

- Stable enough to avoid app-breaking errors in normal use.
- Understandable enough that the user knows what matters next.
- Useful enough to organize a meaningful goal into action.
- Trustworthy enough to avoid fake claims, unclear data behavior, and silent risky changes.
- Human enough that normal UI does not sound like AI, productivity jargon, or internal product strategy.

## Scope Principle

Better for launch:

```text
Fewer complete loops.
```

Worse for launch:

```text
More partial features.
```

Rules:

- Prefer one complete goal-to-plan-to-today-to-recovery-to-proof loop over many unfinished capabilities.
- Prefer strong empty/error/recovery states over extra surfaces.
- Prefer privacy truth over marketing claims.
- Prefer visible receipts over silent behavior.
- Prefer human copy over clever/producty copy.

## Launch-Critical / Post-Launch / Decision-Gated Cutline

### Launch-critical

A feature is launch-critical only when it directly supports:

- capturing one meaningful goal/task
- routing it clearly
- creating or choosing a next step
- making the plan/day doable
- showing what to do today
- recovering when too much is planned
- saving proof/receipt
- preserving trust and privacy truth

### Post-launch

A feature is post-launch when it improves the system but is not required to prove the Golden Launch Loop:

- advanced memory
- widgets
- Live Activities
- rich reviews
- long-range path intelligence
- semantic zoom
- extensive personalization
- sync
- paid tiers
- advanced analytics

### Decision-gated

A feature is decision-gated when it requires a separate product decision before implementation:

- exact pricing/free-tier limits
- exact export format/categories
- exact sync provider/path
- exact widget actions
- exact Live Activity scope
- exact household/shared-life behavior
- exact device/runtime expansion

## What Should Not Ship

Do not ship:

```text
Fake AI.
Broken sync claims.
Unclear data controls.
Dead-end flows.
AI-feeling visible copy.
```

Additional no-ship conditions:

- Feature appears in UI but cannot complete its core job.
- User data behavior is unclear.
- Flow loses user input.
- External writes happen silently.
- Suggestions imply certainty without evidence.
- Recovery flow shames the user or leads nowhere.
- Normal UI says AI, model, confidence, protected/protection, anchor, optimize, or execution context.

## Advanced Canon Policy

Advanced canon may remain planned.

Rules:

- Planned canon should remain clearly distinguished from shipped capability.
- UI should not claim unimplemented planned features.
- Roadmap and docs may describe future phases when labeled accurately.
- Codex prompts should avoid implementing advanced ideas before core launch loops are mature.

## Launch Acceptance Requirements

Launch acceptance requires:

```text
Golden Launch Loop.
Core loop.
Empty states.
Error states.
Accessibility.
Privacy truth.
Human language.
```

Minimum acceptance interpretation:

### Golden Launch Loop

- User can capture one meaningful goal or task.
- Ambitions shows where it went.
- Goal/task can become a doable plan or next step.
- Today can show what to do next.
- Recovery can make an overloaded day doable.
- Progress creates proof or receipt.

### Core Loop

- User can create or capture one meaningful object.
- Object can become or attach to a goal/task/plan route.
- Goal has or can choose a next visible step.
- Plan can make that step feel doable/actionable.
- Today can surface what matters now.
- Receipts show where meaningful actions went.

### Empty States

- Today empty state guides Capture first and goal suggestion second.
- Capture has a safe low-confidence path through Needs a Place.
- Goals/Plan/You empty states do not shame the user.

### Error States

- Failed saves preserve user input.
- Failed external/export-style actions explain what remains safe.
- Error states offer a next recovery action.

### Accessibility

- Dynamic Type is considered in core screens.
- VoiceOver receives meaningful labels/states for core controls.
- Color is not the only meaning carrier.
- Reduce Motion preserves meaning.

### Privacy Truth

- Local-first truth is clear.
- No account required at launch unless later canon changes this.
- Sync/export claims are not shown before implementation.
- Sensitive/private items collapse as Private item on compact/external surfaces.
- Delete-all-memory affects memory only.

### Human Language

- Visible UI follows `HUMAN_LANGUAGE_REVIEW.md`.
- Today uses `Do this next`, `Too much for today`, and `Make today doable` style copy.
- Plan uses `Looks doable`, `Tight`, `Too much planned`, and `No longer works` style copy.
- Goals uses `Most important goal`, `What is next?`, and `How is this going?` style copy.
- Normal UI avoids AI/model/confidence/protected/protection/anchor/optimize/execution-context language.

## MVP Boundary

MVP must never mean:

```text
Ugly.
Untrustworthy.
Incomplete core loop.
Confusing.
Robotic.
```

Rules:

- MVP can be narrower, but not careless.
- MVP can defer advanced capability, but not core trust.
- MVP can be simple, but not shallow where depth is necessary for core value.
- MVP should still feel like a premium calm OS.
- MVP should sound human and obvious.

## Delay If Not Excellent

Delay if not excellent:

```text
Sync.
Advanced memory.
Widgets / Live Activities.
Native AI-style suggestions.
Advanced reviews.
Long-range path intelligence.
```

Rules:

- Sync should wait until export/trust/failure states are strong.
- Advanced memory should wait until correction, privacy, and user control are strong.
- Widgets/Live Activities should wait if they risk privacy leaks, noise, or shallow dashboard behavior.
- Native AI-style suggestions should wait if they would feel fake, overconfident, or uncorrectable.
- Advanced reviews/path intelligence should wait if the Golden Launch Loop is not yet strong.

## Launch No-Drift Checklist

Before treating a batch or milestone as launch-ready, verify:

- Does this strengthen the Golden Launch Loop?
- Does this strengthen the core goal-to-plan-to-today-to-recovery-to-proof loop?
- Does this preserve local-first/data truth?
- Does this avoid fake AI/sync/export claims?
- Does this include empty and error states?
- Does this preserve accessibility meaning?
- Does this follow human-language rules?
- Does this avoid widening the top-level IA?
- Does this make one meaningful goal more organized, doable, and actionable today?

## QA Acceptance Criteria

Launch scope work is acceptable when:

- Launch proves one meaningful goal can become organized, doable, and actionable today.
- Launch does not attempt every canon idea.
- Quality bar is stable, understandable, useful, trustworthy, and human.
- Fewer complete loops are prioritized over more partial features.
- Fake AI, broken sync claims, unclear data controls, dead-end flows, and AI-feeling copy do not ship.
- Advanced canon can remain planned when accurately labeled.
- Launch acceptance covers Golden Launch Loop, core loop, empty states, error states, accessibility, privacy truth, and human language.
- MVP does not mean ugly, untrustworthy, incomplete, confusing, or robotic.
- Sync, advanced memory, widgets/Live Activities, native AI-style suggestions, advanced reviews, and long-range path intelligence are delayed if not excellent.
- Launch north star remains making one meaningful goal feel organized, doable, recoverable, and real.

## Open Questions For Future Waves

- What exact launch feature set should be marked must-ship versus defer?
- Which advanced canon docs should be explicitly labeled post-launch?
- What exact manual QA script proves the Golden Launch Loop?
- What minimum accessibility matrix is required before launch?
- Which monetization elements should be absent from first launch even if planned?
