# Ambitions Launch Scope, MVP, And Quality Bar

Status: Active canon consolidation layer.

Purpose: Consolidate launch proof, MVP boundaries, quality bar, acceptance gates, delayed-feature policy, and launch north star into one implementation-readable reference. This document reflects Wave 17 product decisions.

## Core Launch Doctrine

Launch should prove:

```text
Ambitions can organize one meaningful goal into a believable execution system.
```

Launch north star:

```text
Prove Ambitions can make a meaningful goal feel organized, believable, and actionable.
```

Rules:

- Launch is not a feature-count contest.
- Launch does not need every canon idea.
- Launch should prove the core loop with enough quality that the product feels trustworthy.
- A smaller complete system is better than a wide partial system.

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

- Prefer one complete goal-to-plan-to-today loop over many unfinished capabilities.
- Prefer strong empty/error/recovery states over extra surfaces.
- Prefer privacy truth over marketing claims.
- Prefer visible receipts over silent behavior.

## What Should Not Ship

Do not ship:

```text
Fake AI.
Broken sync claims.
Unclear data controls.
Dead-end flows.
```

Additional no-ship conditions:

- Feature appears in UI but cannot complete its core job.
- User data behavior is unclear.
- Flow loses user input.
- External writes happen silently.
- Suggestions imply certainty without evidence.
- Recovery flow shames the user or leads nowhere.

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
Core loop.
Empty states.
Error states.
Accessibility.
Privacy truth.
```

Minimum acceptance interpretation:

### Core Loop

- User can create or capture one meaningful object.
- Object can become or attach to a goal/task/plan route.
- Goal has or can choose a next visible step.
- Plan can make that step feel believable/actionable.
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

## MVP Boundary

MVP must never mean:

```text
Ugly.
Untrustworthy.
Incomplete core loop.
Confusing.
```

Rules:

- MVP can be narrower, but not careless.
- MVP can defer advanced capability, but not core trust.
- MVP can be simple, but not shallow where depth is necessary for core value.
- MVP should still feel like a premium calm OS.

## Delay If Not Excellent

Delay if not excellent:

```text
Sync.
Advanced memory.
Widgets / Live Activities.
Native AI-style suggestions.
```

Rules:

- Sync should wait until export/trust/failure states are strong.
- Advanced memory should wait until correction, privacy, and user control are strong.
- Widgets/Live Activities should wait if they risk privacy leaks, noise, or shallow dashboard behavior.
- Native AI-style suggestions should wait if they would feel fake, overconfident, or uncorrectable.

## Launch No-Drift Checklist

Before treating a batch or milestone as launch-ready, verify:

- Does this strengthen the core goal-to-plan-to-today loop?
- Does this preserve local-first/data truth?
- Does this avoid fake AI/sync/export claims?
- Does this include empty and error states?
- Does this preserve accessibility meaning?
- Does this avoid widening the top-level IA?
- Does this make one meaningful goal more organized, believable, and actionable?

## QA Acceptance Criteria

Launch scope work is acceptable when:

- Launch proves one meaningful goal can become a believable execution system.
- Launch does not attempt every canon idea.
- Quality bar is stable, understandable, useful, and trustworthy.
- Fewer complete loops are prioritized over more partial features.
- Fake AI, broken sync claims, unclear data controls, and dead-end flows do not ship.
- Advanced canon can remain planned when accurately labeled.
- Launch acceptance covers core loop, empty states, error states, accessibility, and privacy truth.
- MVP does not mean ugly, untrustworthy, incomplete, or confusing.
- Sync, advanced memory, widgets/Live Activities, and native AI-style suggestions are delayed if not excellent.
- Launch north star remains making a meaningful goal feel organized, believable, and actionable.

## Open Questions For Future Waves

- What exact launch feature set should be marked must-ship versus defer?
- Which advanced canon docs should be explicitly labeled post-launch?
- What exact manual QA script proves the core launch loop?
- What minimum accessibility matrix is required before launch?
- Which monetization elements should be absent from first launch even if planned?
