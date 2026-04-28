# Ambitions Goals And Goal Detail

Status: Active canon consolidation layer.

Purpose: Consolidate Goals, Goal Detail, Goal Weather, Proof, progress, and next-step behavior into one implementation-readable reference. This document reflects Wave 7 product decisions.

## Core Goals Doctrine

Goals exists to help the user choose and protect direction.

Core job:

```text
Help the user choose and protect direction.
```

Goals is not:

- a project management board
- a spreadsheet
- a KPI dashboard
- a motivation quote wall
- a generic task manager

## Goals Top Screen Priority

The Goals top screen should prioritize:

```text
One protected / most important goal.
Goal portfolio health.
```

Supporting content below:

```text
Goal list.
Life Areas.
Recent progress.
```

Rules:

- Top-level Goals should protect direction before exposing management detail.
- The first screenful should not become a wall of equal-weight cards.
- Life Areas can support browsing, but they should not dominate as a sixth-tab substitute.
- Goal portfolio health should be qualitative and explainable, not a dense KPI dashboard.

## Project Management Boundary

Resolved direction:

```text
Top-level Goals should not look like a project management board.
```

Rules:

- Deep detail may use structured milestone/step views where useful.
- Do not expose kanban-style management as the top-level Goals identity.
- Milestones and steps should support direction, believability, proof, and next action.
- Project-management density belongs only in deep drilldown when the goal truly needs it.

## Goal Detail Main Questions

Primary question:

```text
What is the next visible step?
```

Secondary question:

```text
Is this goal still believable?
```

Rules:

- Goal Detail should lead with next action clarity.
- Believability/risk should be visible enough to avoid false confidence.
- Task lists, progress metrics, history, proof, and decisions should support these questions, not replace them.
- A goal with no next step should immediately help restore forward motion.

## Goal Weather

Goal Weather primarily communicates:

```text
Believability / risk / clarity.
```

Goal Weather is not:

- progress percentage
- mood
- motivation decoration
- deadline pressure only

Rules:

- Weather must be explainable through `Why This` / `Why Changed`.
- Users correct the inputs that affect weather instead of directly overriding weather.
- Weather should be supported by proof, blocker, deadline, scope, path, next-step, and plan evidence.
- Avoid fake precision.
- Avoid childish weather graphics.

## Progress Percentages

Resolved decision:

```text
Only show progress percentages when measurable and honest.
```

Rules:

- Do not show fake progress precision.
- Do not make percentages the primary goal health signal.
- Prefer milestone/proof/next-step clarity when the goal is not honestly quantifiable.
- Progress can be secondary when the underlying goal has measurable units.

## Proof Definition

Proof includes:

```text
Completed step.
Artifact created.
Decision made.
Feedback received.
Blocker resolved.
Reflection / review.
```

Rules:

- Proof is evidence of real progress.
- Proof is broader than task completion.
- Proof should support trust, Goal Weather, reviews, and archive learning.
- Proof should not become fake gamification.

## Manual Proof

Resolved decision:

```text
Users can manually add proof, but it should attach to a goal, milestone, or step.
```

Rules:

- Manual proof should not float as a disconnected object.
- Proof attachment should create a receipt where meaningful.
- Proof should remain correctable if attached to the wrong object.
- Capture may route to Proof when the object is clearly evidence.

## Missing Next Step

When a goal has no next step, Ambitions should:

```text
Ask the user to choose one.
Suggest one.
```

Rules:

- Do not merely warn.
- Do not hide the goal from Today solely because the next step is missing.
- Help the user restore forward motion.
- Suggestions should distinguish evidence from assumptions.
- User choice should remain primary when Ambitions is uncertain.

## Goal Detail Recommended Structure

A strong Goal Detail should include, in priority order:

1. Current direction / goal title.
2. Next Visible Step.
3. Believability / Goal Weather explanation.
4. Active milestone or path segment.
5. Proof / Proof Spine.
6. Blockers / Waiting / Risks where relevant.
7. Decision Trail.
8. Deeper steps and history.

Rules:

- Detail can be deep, but should not feel wide.
- Important proof and risk should not be buried below raw task lists.
- Decisions should make changes feel understandable and dignified.

## Goal Portfolio Health

Goal portfolio health should answer:

- Which direction needs protection?
- Which goals are clear?
- Which goals are foggy, blocked, waiting, or no longer believable?
- Which Life Areas are active or neglected?
- Where is proof accumulating?

Rules:

- Portfolio health should be qualitative.
- Avoid KPI-dashboard density.
- Avoid fake numerical scoring unless later verified and useful.

## Goals Must Never Become

Goals must never become:

```text
Project management board.
Spreadsheet.
KPI dashboard.
Motivation quote wall.
```

## QA Acceptance Criteria

Goals / Goal Detail is acceptable when:

- Top-level Goals helps choose and protect direction.
- Top screen prioritizes one protected/most important goal and portfolio health.
- Goal list, Life Areas, and recent progress are supporting content, not the first identity.
- Top-level Goals does not look like a project management board.
- Goal Detail leads with Next Visible Step and believability.
- Goal Weather communicates believability/risk/clarity.
- Progress percentages appear only when measurable and honest.
- Proof includes completed steps, artifacts, decisions, feedback, blocker resolution, and reflection/review.
- Manual proof attaches to a goal, milestone, or step.
- Missing next step flow asks user to choose and can suggest one.
- Goals never becomes a spreadsheet, KPI dashboard, motivation quote wall, or top-level project board.

## Open Questions For Future Waves

- What should the protected-goal hero visually show?
- Should portfolio health use Goal Weather distribution, Life Area distribution, or both?
- Should Proof Spine be visible on every goal detail or only when proof exists?
- How much milestone/step structure belongs above the fold?
- Should major goals have richer completion ceremonies than ordinary goals?
