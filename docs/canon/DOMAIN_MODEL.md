# Ambitions Domain Model

Status: Active canon consolidation layer.

Purpose: Consolidate the Ambitions object model into one implementation-readable reference. This document extracts existing truth from the Master Product Spec, Design Constitution, Product Architecture, Systems Architecture, Visual System, Intelligence Standards, and product decision Waves 1-2. It does not replace those documents; it makes their object language easier to implement consistently.

## Canonical Hierarchy

```text
Life Area
-> Ambition / North Star
-> Goal
-> Path
-> Plan
-> Milestone
-> Step
-> Proof
-> Receipt / Review
```

Key distinction:

```text
Task = standalone One-Step Goal.
Step = action inside a Goal, Path, or Plan.
```

A Task can exist without a Goal. A Step cannot.

## Wave 1 Locked Decisions

- Ambitions is user-facing as a life organization system and internally as a personal life operating system / external brain.
- Primary opening feeling: `My life feels organized`.
- Immediate proof: `I know what matters now` and `I know the next concrete step`.
- Life Areas are inferred/recommended and correctable, not mandatory friction.
- Default Life Areas: Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin.
- Default Life Areas are renameable while preserving an internal canonical type.
- `North Star` is deeper-view language; new-user/top-level copy may use `long-term ambition`.
- A Goal is a meaningful outcome that may need a plan.
- User-facing term is `Task`; internal/design term is `One-Step Goal`.
- A Task can exist without a Goal, but Ambitions should suggest attaching or promoting when useful.
- System rule: every item has a place.
- Execution rules: every goal has a next step; every plan must be believable.
- Emotional rule: the user never feels punished for drifting.
- Product-shape rule: the app stays deep, not wide.

## Wave 2 Locked Decisions

- Internal `dropped` state should normally render as `No Longer Relevant` in UI.
- `cancelled` and `dropped` are internally separate, but launch UI may simplify.
- General intentional-ending action is `End Goal`, followed by a reason.
- Goal pause action is `Park Goal`; state is `parked`.
- Goal Weather is not directly manually overridden; users correct inputs that affect weather.
- Internal Plan states may be strong; UI should render `fragile` as `Needs Protection` and `broken` as `No Longer Holds`.
- Confirmation is required for destructive actions, external writes, and major deadline changes.
- Receipt + undo is preferred for Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density.
- Delete memory and calendar write require confirmation.
- Completed goals remain visibly emphasized for 30 days by default; major goals may remain emphasized longer.
- Product/design language is `Completion Archive`; normal UI language is `Archive`.

## Object Ownership Summary

| Object | Plain meaning | Primary owner surface | Supporting surfaces |
| --- | --- | --- | --- |
| Life Area | A major life lens such as Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin | Goals, You | Capture, Reviews |
| Ambition | A broad future direction that may contain goals | Goals | You, Reviews |
| North Star | Dormant or identity-level long-range ambition; user-facing mostly in deeper views | Goals, Life Areas | You, Path Builder |
| Goal | Meaningful outcome that may need a plan | Goals, Goal Detail | Today, Plan, Reviews |
| Path | Strategic route from current state to goal | Goal Detail, Path Builder | Plan, Reviews |
| Plan | Believable execution shape over day/week/phase | Plan | Today, Goals |
| Milestone | Meaningful checkpoint before task detail | Goal Detail | Goals, Plan |
| Step | Contained action inside a Goal, Path, or Plan | Goal Detail, Today, Plan | Reviews |
| Task / One-Step Goal | Standalone concrete action not requiring a goal container; UI says Task | Today, Capture, You | Goals, Plan |
| Proof | Evidence that progress happened | Goal Detail, Reviews | Goals, You |
| Decision | Reason a path, scope, plan, or goal state changed | Goal Detail, Plan, Reviews | You, Trust Center |
| Receipt | Action closure record explaining what happened and what changed | Global / Trust Layer | You, Reviews, Capture, Plan |
| Review | Reflection object that converts history into future guidance | You -> Reviews | Today, Plan, Goal Detail |
| Capture | Raw incoming item that needs a route | Capture | Today, Plan, Goals |
| Ritual | Recurring execution structure absorbed from habits | Plan | Today, Goal Detail, You |
| Waiting Item | Something blocked by another person/event/context | Capture, Plan | Goal Detail, You |
| Memory | User-visible remembered preference, pattern, or context | You -> What Ambitions Knows | Trust Center, Reviews |
| Schedule Block | Planned time block or calendar-aware work window | Plan | Today, Reviews |
| Archive / Completion Archive | Preserved learning from completed, ended, parked, merged, or replaced objects | Goals, You -> Reviews | Trust Center, Archive detail |

## Core Entities

### Life Area

A Life Area is a primary organization lens. It is visible inside Goals and You, not a sixth tab.

Default Life Areas:

```text
Career
Creative
Finance
Health
Home
Relationships
Education
Personal
Admin
```

Minimum fields:

- `id`
- `name`
- `canonicalType`
- `status`
- `sortOrder`
- `createdAt`
- `updatedAt`

Canonical type values:

- `career`
- `creative`
- `finance`
- `health`
- `home`
- `relationships`
- `education`
- `personal`
- `admin`
- `custom`

Useful future fields:

- `displayNameOverride`
- `iconToken`
- `accentToken`
- `hiddenSensitiveDetails`
- `northStarIds`
- `goalIds`
- `reviewIds`
- `memoryIds`

Rules:

- Life Areas help the user understand where life objects belong.
- They must not turn Ambitions into a dashboard of categories.
- A Life Area can exist without active goals.
- A user can rename a default Life Area, but the internal canonical type remains stable.
- Ambitions may infer a Life Area, but the user must be able to correct it.
- Life Area assignment should not block Capture or first-run flow.
- Renaming a Life Area should use receipt + undo, not confirmation.

### Ambition / North Star

An Ambition is broad direction. A North Star is long-range, dormant, or identity-level direction.

Minimum fields:

- `id`
- `lifeAreaId`
- `title`
- `kind`: `ambition | northStar`
- `state`: `dormant | active | parked | replaced | archived`
- `createdAt`
- `updatedAt`

Useful future fields:

- `whyItMatters`
- `candidateGoalIds`
- `proofIds`
- `decisionIds`
- `reviewIds`

Rules:

- North Stars should not force immediate planning.
- `North Star` is premium deeper-view language.
- New-user/top-level UI may use `long-term ambition` before introducing `North Star`.
- A North Star can be promoted into an active goal or spawn one or more goals.
- Long-range certainty must be qualitative, not fake precision.

### Goal

A Goal is a meaningful outcome that may need a plan. It is direction, not a task list.

Minimum fields:

- `id`
- `title`
- `state`
- `lifeAreaId?`
- `northStarId?`
- `deadline?`
- `createdAt`
- `updatedAt`

Recommended fields:

- `pathId?`
- `planIds`
- `milestoneIds`
- `nextVisibleStepId?`
- `proofIds`
- `decisionIds`
- `receiptIds`
- `reviewIds`
- `weatherState`
- `paceState`
- `priorityReality`
- `scopeState`
- `archiveState?`

Goal states and preferred UI labels:

| Internal state | Preferred UI label |
| --- | --- |
| `seed` | Seed / Idea |
| `active` | Active |
| `protected` | Protected |
| `waiting` | Waiting |
| `blocked` | Blocked |
| `parked` | Parked |
| `completed` | Completed |
| `cancelled` | Ended |
| `dropped` | No Longer Relevant |
| `merged` | Merged |
| `replaced` | Replaced |
| `archived` | Archive |

Rules:

- Every active goal should have one Next Visible Step unless blocked/waiting.
- Every significant goal change should be explainable.
- Completed, cancelled, dropped, merged, replaced, and parked goals remain learning artifacts, not trash.
- Goal Weather is user-facing visual language, not a separate engine.
- A goal should be important enough to justify direction, plan, proof, lifecycle, and review.
- `End Goal` is the general intentional-ending action and should ask the reason.
- `Park Goal` is the pause action and creates the Parked state.
- Completed goals remain visibly emphasized for 30 days by default; major goals may remain emphasized longer.

### Path

A Path is the strategic route between current state and desired outcome.

Minimum fields:

- `id`
- `goalId`
- `title`
- `state`
- `createdAt`
- `updatedAt`

Recommended fields:

- `stageIds`
- `milestoneIds`
- `assumptionIds`
- `riskIds`
- `decisionIds`
- `fallbackPathIds`
- `readinessState`
- `domainPackId?`

Rules:

- Path logic belongs to Path Intelligence / Long-Range Strategy, not per-screen templates.
- Goal Detail can preview/inspect Path, but must not duplicate full Path Builder logic before owning batches.

### Plan

A Plan is a believable execution shape. It tells whether a day/week/path holds together.

Minimum fields:

- `id`
- `scope`: `day | week | phase | goal`
- `state`
- `createdAt`
- `updatedAt`

Recommended fields:

- `goalIds`
- `scheduleBlockIds`
- `ritualIds`
- `openWindowIds`
- `conflictIds`
- `believabilityState`
- `planTreatyId?`
- `decisionIds`
- `receiptIds`
- `reviewIds`

Plan states and preferred UI labels:

| Internal state | Preferred UI label |
| --- | --- |
| `draft` | Draft |
| `believable` | Believable |
| `tight` | Tight |
| `fragile` | Needs Protection |
| `broken` | No Longer Holds |
| `reflowing` | Adjusting |
| `saved` | Saved |
| `reviewed` | Reviewed |
| `archived` | Archive |

Rules:

- Plan owns calendar permission.
- Calendar read requires explicit Plan action.
- Calendar write requires explicit confirmation.
- Plan works without calendar access.
- No silent rescheduling.
- Major deadline changes require confirmation or an explicit reviewed change flow.
- Every plan should communicate whether it is believable, tight, needs protection, or no longer holds.

### Milestone

A Milestone is a meaningful checkpoint inside a goal or path.

Minimum fields:

- `id`
- `goalId`
- `title`
- `state`
- `sortOrder`

Recommended fields:

- `deadline?`
- `stepIds`
- `proofIds`
- `blockerIds`
- `decisionIds`

Rules:

- Milestones come before dense task detail.
- Milestone Cards should show state, next action, proof count, and blockers without becoming a task board.

### Step

A Step is a contained action inside a Goal, Path, or Plan.

Minimum fields:

- `id`
- `parentType`: `goal | path | plan | milestone`
- `parentId`
- `title`
- `state`

Recommended fields:

- `estimatedDuration`
- `contextLens`
- `scheduleBlockId?`
- `proofRequirement?`
- `receiptIds`
- `decisionIds`

Rules:

- A Step cannot be rootless.
- A Step can become proof when completed if it creates evidence.
- Steps should feed Next Visible Step, Today, and Plan through shared systems.

### Task / One-Step Goal

A Task is a standalone One-Step Goal. It should not force creation of a full Goal.

User-facing language:

```text
Task
```

Internal/design language:

```text
One-Step Goal
```

Minimum fields:

- `id`
- `title`
- `state`
- `createdAt`
- `updatedAt`

Recommended fields:

- `lifeAreaId?`
- `category?`
- `time?`
- `reminder?`
- `location?`
- `priorityReality?`
- `proofIds`
- `historyIds`
- `reviewIds`

Allowed transformations:

- Attach to Goal.
- Promote to Goal.
- Convert to Ritual.
- Keep standalone.
- Complete.
- Park / Not Today.

Rules:

- A Task can exist without a Goal.
- Ambitions should suggest attaching or promoting a Task when useful.
- Do not create a top-level Tasks tab.
- One-Step Goals can appear in Today, Capture, Goals, Plan, and You when contextually useful.
- Avoid `To-Do` as the primary Ambitions object name.
- Mark Done, Move task, Park task, and Attach task to goal should prefer receipt + undo.

### Proof

Proof is evidence of real progress.

Minimum fields:

- `id`
- `targetType`: `goal | milestone | step | task | review | path`
- `targetId`
- `proofType`
- `title`
- `createdAt`

Proof types:

- action completed
- artifact created
- file/link/note saved
- reflection
- calendar block completed
- feedback received
- blocker resolved
- milestone reached
- decision made

Rules:

- Proof is not a streak gimmick.
- Proof Rail owns compact proof organization.
- Proof Spine is the Goal Detail vertical expression of Proof Rail.

### Decision

A Decision explains why a goal, plan, path, deadline, or scope changed.

Minimum fields:

- `id`
- `targetType`
- `targetId`
- `decisionType`
- `summary`
- `createdAt`

Decision types:

- started
- paused
- resumed
- protected
- moved
- scope increased
- scope reduced
- deadline changed
- cancelled
- dropped
- completed
- merged
- replaced
- parked

Rules:

- Major Plan Treaty and Goal Scope changes create Decision Trail entries.
- Decision Trail is user-facing change history over Event Ledger / Action Closure / Plan Treaty decisions.
- Destructive actions, external writes, and major deadline changes require confirmation.

### Receipt

A Receipt is the user-facing action closure record.

Minimum fields:

- `id`
- `actionType`
- `resultState`
- `summary`
- `createdAt`

Recommended fields:

- `whatHappened`
- `whatChanged`
- `whyChanged`
- `undoEligibility`
- `correctionRoute`
- `source`
- `privacyLevel`
- `relatedObjectIds`

Result states:

- created
- changed
- scheduled
- moved
- attached
- exported
- drafted / prepared
- completed
- failed safely
- needs confirmation
- undo available

Rules:

- Receipts are trust objects, not generic toasts.
- Meaningful commands should close with a receipt.
- Sensitive receipts hide details by default.
- Ordinary local reversible changes should prefer receipt + undo.
- Delete memory, calendar write, destructive actions, external writes, and major deadline changes require confirmation.

### Review

A Review converts what happened into what should happen next.

Review types:

- Recovery Review
- Daily Receipt
- Weekly Life OS Receipt
- Goal Review
- Memory Review
- Correction Review
- Pattern Review

Rules:

- Reviews primarily live under You -> Reviews.
- Reviews are contextual from Today, Plan, and Goal Detail.
- Reviews answer: what happened, what changed, what remains believable, and what action follows.

## Relationship Rules

- One Life Area can contain many North Stars, Goals, Tasks, Reviews, and Memories.
- One Goal can have one active Path and many historical/fallback paths.
- One Goal can contain many Milestones, Steps, Proof items, Decisions, Receipts, and Reviews.
- One Plan can contain many Schedule Blocks, Steps, Tasks, Rituals, Decisions, Receipts, and Review prompts.
- One Capture can become or attach to a Task, Step, Goal, Plan seed, Proof item, Decision, Ritual, Waiting item, or Archive item.
- One Receipt can reference multiple objects when a command changes more than one thing.
- Memory can influence recommendations only when it is evidence-backed, freshness-aware, and correctable.

## Product Rules

System rule:

```text
Every item has a place.
```

Execution rules:

```text
Every goal has a next step.
Every plan must be believable.
```

Emotional rule:

```text
The user never feels punished for drifting.
```

Product-shape rule:

```text
The app stays deep, not wide.
```

## Archive / Completion Archive

Product/design language:

```text
Completion Archive
```

Normal UI language:

```text
Archive
```

Rules:

- Archive preserves learning; it is not trash.
- Completed goals remain visibly emphasized for 30 days by default.
- Major completed goals may remain emphasized longer depending on importance.
- Cancelled, No Longer Relevant, Merged, Replaced, and Parked histories should preserve reason, proof, and decision trail.

## Implementation Guardrails

- Do not duplicate object relationship stores per surface.
- Do not let Capture become a graveyard inbox.
- Do not let Goals become a generic task board.
- Do not let Plan become a calendar clone.
- Do not let You become a junk drawer.
- Do not use AI/model language in user-facing object labels.
- Do not claim sync, accessibility, memory, or automation behavior before verified implementation evidence exists.
- Distinguish planned canon from shipped code in every implementation summary.
- Prefer drill-downs and contextual intelligence over new top-level tabs.

## Resolved Wave 1 Questions

- Default Life Areas are Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin.
- Users can rename default Life Areas while preserving internal canonical types.
- Life Areas are inferred/recommended and correctable, not required friction.
- A Goal is a meaningful outcome that may need a plan.
- User-facing standalone action language is Task; internal/design term is One-Step Goal.
- A Task can exist without a Goal.

## Resolved Wave 2 Questions

- Internal `dropped` renders as `No Longer Relevant` in normal UI.
- Cancelled and Dropped remain internally separate; launch UI may simplify.
- Intentional goal ending action is `End Goal`, followed by a reason.
- Intentional pause action is `Park Goal`; state is Parked.
- Goal Weather is corrected through inputs, not direct manual override.
- Internal Plan states can be strong; UI should use `Needs Protection` and `No Longer Holds`.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density prefer receipt + undo.
- Completed goals stay visibly emphasized for 30 days by default; major goals may remain emphasized longer.
- Product/design language is Completion Archive; normal UI language is Archive.

## Open Questions For Future Waves

- Which state changes should create a visible Decision Trail entry versus only a receipt?
- How detailed should the End Goal reason picker be?
- How long should undo remain available by action type?
- Which memories require explicit confirmation before use?
