# Goals Mission Control Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX03 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

Goals is the strategic direction and Mission Control surface. It should feel like a premium goal operating system: a map of meaningful direction, not a list of aspirations, kanban board, OKR tool, habit tracker, or vision-board collage.

Goals owns goal portfolio, Goal Detail, lane-based Mission Control, lifecycle rail, goal health, assumptions, proof rail, milestones, next recommended step, alternate paths, progress, tradeoffs, blockers, recovery paths, source truth, goal memory/proof, why a goal changed, Today linkage, risk, momentum, commitment realism, and user-owned adjustment.

Highest-priority future Goals improvement: make a goal feel visually alive. Path, progress, proof, risk, next step, and alternate route should be readable without becoming a dashboard.

## PX03 Top-Level Orientation Surface

Goals answers one question first:

```text
What am I moving toward?
```

The first viewport should orient around one dominant object: the Ambition
Portfolio. It is a strategic map of active goals and their life-shaping status,
not a task database, analytics dashboard, project board, OKR tracker, or habit
grid.

The top-level Goals composition is:

1. Compact direction header: active season, current emphasis, and source/trust
   posture.
2. Ambition Portfolio: goal vitality, path shape, next strategic decision, and
   proof/risk signals.
3. One contextual prompt only when relevant: blocked path, proof update,
   decision needed, alternate path, or stale assumption.
4. Secondary content only below the first viewport and only when it does not
   duplicate Goal Detail or Mission Control lanes.

Goals must not show every step, every receipt, every risk, every metric, or
every path branch at the top level. Those belong behind Goal Detail and Mission
Control lanes.

## Primary Object And Action

Primary object: the goal or ambition needing the clearest strategic attention.

Primary action: open the owned goal depth surface when a goal needs attention.
The action label should be specific to the state, such as `Open goal`, `Review
path`, `Choose next step`, `Review risk`, or `View proof`.

Goals should show one primary action at a time. Secondary actions route deeper:

- `Open goal` opens Goal Detail.
- `Mission Control` opens lane-based goal depth.
- `View proof` opens proof/history for that goal.
- `Review path` opens path, assumptions, or alternate-path lanes.
- `Choose next step` opens the goal-owned step decision before Today execution.
- `Review risk` opens blockers, tradeoffs, or commitment realism.

## Mission Control Lanes

Goal Detail / Mission Control owns depth. Required future lanes:

| Lane | Purpose | Top-level Goals behavior |
| --- | --- | --- |
| Overview | what the goal is and why it matters | show vitality and one current signal |
| Path | current route, milestones, and constraints | show path shape, not all steps |
| Steps | next meaningful actions | show one next strategic step |
| Proof | evidence that movement happened | show compact proof signal |
| Decisions | user-owned choices and changes | show decision-needed prompt only |
| Risks | blockers, tradeoffs, weak assumptions | show risk state without alarmism |
| Assumptions | source facts and belief checks | show stale/needs-review label |
| Archive | parked or finished context | keep off the top-level surface |

## Goal Vitality Model

Future Goals may express goal vitality through a compact, source-bound model:

- direction: clear, forming, or needs review;
- path: visible, partial, blocked, or alternate available;
- proof: recent, older, absent, or private;
- risk: low, rising, blocked, or unknown;
- next step: ready, needs plan, needs source, or not yet honest;
- commitment realism: fits, tight, overcommitted, or needs adjustment.

Vitality is not a score, grade, streak, or productivity metric. It is a visual
orientation language for whether a goal is alive, believable, and owned.

## Product Depth Boundaries

PX03 defines future Goals expression only. Product Depth later owns richer
implementation and drill-down behavior for goal requirements, path
visualization, proof/decision history, alternate paths, and cross-surface proof.

PX03 does not start Product Depth. It only names the boundary:

- PX03: future Goals/Mission Control canon.
- PX14: product-depth drill-down architecture.
- PD05-PD08: future implementation/depth for Goal Detail, lifecycle/path,
  proof/decision history, and alternate path depth.

## Trust, Proof, And Source Truth

Goals should show proof as evidence of movement, not gamification. It may
summarize recent proof, source freshness, blocked assumptions, or private
evidence, but sensitive details stay behind intentional drill-downs.

Meaningful goal changes must remain explainable:

- why the goal changed;
- what proof moved it;
- what source or assumption changed;
- what the user approved;
- what remains uncertain.

Goals must not claim hidden intelligence, automatic strategy, or certainty when
source truth is stale, missing, private, or conflicting.

## Visual Orientation Examples

Good Goals:

- one Ambition Portfolio object with clear hierarchy;
- one goal or decision visually dominant;
- path/proof/risk visible as shape and state;
- Goal Detail and Mission Control lanes clearly available;
- source/freshness labels quiet but present;
- no more than one primary action.

Bad Goals:

- a generic grid of same-size goal cards;
- task-board columns as the first viewport;
- OKR scorecards or KPI dashboards;
- all steps, risks, proof, and decisions exposed at once;
- motivational vision-board collage with no next decision;
- confidence percentages or fake certainty.

## Accessibility And Cognitive Load

Goals must support Dynamic Type, VoiceOver summaries for goal vitality and the
primary action, Reduce Motion alternatives for path/lifecycle motion, no
color-only risk/proof meaning, visible alternatives for gestures, and a first
viewport that asks for no more than one strategic decision.

The 3-second glance test passes only when the user can identify what they are
moving toward, which goal needs attention, and where to go next without reading
every label.

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.
