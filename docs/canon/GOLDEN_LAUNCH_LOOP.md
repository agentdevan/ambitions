# Ambitions Golden Launch Loop

Status: Active product-strengthening canon layer.

Purpose: Turn the SWOT weaknesses, opportunities, and threats into one practical product-strength doctrine. This document defines the smallest undeniable Ambitions loop, the launch demo story, the user/internal language translation table, and the decision rules that convert broad ambition into a strong, human, shippable product.

## Core Doctrine

Ambitions becomes strongest when the product proves one thing extremely well:

```text
A meaningful goal can become organized, doable, and actionable today.
```

The product should not try to prove the entire life operating system at launch. It should prove the core loop so clearly that the bigger system feels inevitable.

## Golden Launch Loop

Every launch-critical feature should strengthen this loop:

```text
1. Capture one meaningful goal or task.
2. Put it in the right place.
3. Turn it into a doable plan.
4. Show what to do today.
5. When today is too much, make it doable.
6. Save proof that progress happened.
```

If a launch feature does not strengthen one of those six steps, it should be marked post-launch, deferred, or decision-gated.

## User Story To Prove

The launch demo should be built around one ordinary but meaningful goal.

Recommended example:

```text
Release 3 songs by August 1.
```

Demo sequence:

1. User captures: `Release 3 songs by August 1`.
2. Ambitions saves it under Creative and shows where it went.
3. Ambitions creates a simple plan with a first step.
4. Today shows: `Start here`.
5. The day becomes too full.
6. Today says: `Too much for today`.
7. User taps: `Make today doable`.
8. Ambitions asks what should stay on today.
9. User keeps one thing and moves the rest later.
10. User completes the step.
11. Ambitions saves proof that progress happened.

This demo should feel understandable without explaining product architecture.

## Product Strength Conversion Matrix

| Former weakness / threat | Strengthened product rule | Required fix |
| --- | --- | --- |
| Too much internal/product language | UI sounds human and obvious | Follow `HUMAN_LANGUAGE_REVIEW.md` and the v2 master spec; visible UI uses `Start here`, `Recommended step`, `Too much for today`, `Make today doable`, `Adjust plan`. |
| Roadmap too broad for launch | Launch proves one complete loop | Mark launch-critical work only if it supports the Golden Launch Loop. |
| Life OS overpromise | Bigger vision is earned through the first loop | Keep `life OS` as internal/investor language; user-facing launch copy focuses on organizing goals, plans, and next steps. |
| ADHD support too philosophical | Focus support becomes visible product quality | One primary decision per screen, clear next action, non-shaming recovery, no dense dashboard above the fold. |
| Too many named systems | Internal systems translate to plain user copy | Use the translation table below. Named systems stay internal unless they are already obvious to users. |
| Goals / Plan / Today overlap | Each surface has one job | Today = what now. Plan = what fits. Goals = why it matters. |
| Monetization underdefined | Paid value is depth, not trust ransom | Trust/privacy/data controls stay free; paid unlocks deeper planning, reviews, memory, personalization, and advanced surfaces. |
| Memory could feel creepy | Memory is visible and controllable | Every memory is inspectable, editable, deletable, pausable, and sensitive memories require confirmation. |
| Launch lacks a concrete demo | One demo proves the product | Use the Release 3 Songs demo or another single-goal story. |
| Roadmap becomes implementation theater | Every batch must move visible proof or unlock a required system | Batches must map to Golden Launch Loop steps or be marked deferred. |

## Internal Words vs User Words

Internal precision is useful for planning. Normal UI should use words people immediately understand.

| Internal / canon term | User-facing direction |
| --- | --- |
| Best Next Action | Recommended step |
| Now State | Right now / Why this now |
| Believability | Looks doable |
| Fragile | Too much planned |
| Broken / No Longer Holds | No longer works |
| Protected / Protect | Keep this / Adjust plan / What should stay? |
| Goal Weather | How this goal is going |
| Proof Rail / Proof Spine | Progress saved / Proof |
| Action Closure | Saved / Rescheduled / Changed / Undo |
| Smart Attachment | Suggested place / Move it here? |
| Personal System Center | You / Your settings and history |
| Intelligence | Suggestions |
| Confidence | Why this / Based on... |
| Optimization | Make it doable / Adjust |
| Calendar-aware | Find open time from Calendar |
| Recovery Cascade | Make today doable |
| Continuity | What changed / Still on track |
| Trust Layer | You are in control |
| Memory Graph | What Ambitions knows |

## Surface Strength Rules

### Today

Today is strongest when it answers:

```text
What should I do next?
```

Today should lead with:

- `Do this next`
- `Why this now`
- `Too much for today` when overloaded
- `Make today doable` when recovery is needed
- the daily schedule below the main action

Today should not lead with:

- a task dump
- a full calendar
- analytics
- product/system language
- AI-feeling copy

### Goals

Goals is strongest when it answers:

```text
Where am I headed, and what matters most?
```

Goals should lead with:

- the most important goal
- how the goal is going
- what is next
- proof that progress happened

Goals should not become:

- a project board
- a KPI dashboard
- a spreadsheet
- a motivation wall

### Plan

Plan is strongest when it answers:

```text
Does this actually fit?
```

Plan should lead with:

- what the day/week can hold
- what is too much
- what can move later
- open time when Calendar is connected
- clear confirmation before external writes

Plan should not become:

- a raw calendar clone
- a fantasy schedule generator
- a silent rescheduler
- a dense planning table

### Capture

Capture is strongest when it answers:

```text
Where does this belong?
```

Capture should lead with:

- `What needs a place?`
- `Saved as...`
- `Suggested place`
- `Move it here?`
- `Needs a Place`

Capture should not become:

- a generic notes app
- an AI chat box
- a permanent inbox graveyard

### You

You is strongest when it answers:

```text
What does Ambitions know, and how do I control it?
```

You should lead with:

- `You are in control`
- `What Ambitions knows`
- settings and history
- privacy/data controls
- reviews that help decide what changes next

You should not become:

- a junk drawer
- a social profile
- an analytics dashboard
- a data-console screen

## Launch Cutline

### Launch-critical

A feature is launch-critical only when it directly supports:

- capture one meaningful goal/task
- route it clearly
- create or choose a next step
- make the plan/day doable
- show what to do today
- recover when too much is planned
- save proof/receipt
- preserve trust and privacy truth

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

## Threat Neutralization Rules

| Threat | Neutralizing rule |
| --- | --- |
| Scope creep | Every launch item maps to the Golden Launch Loop or defers. |
| AI-wrapper perception | Normal UI follows `HUMAN_LANGUAGE_REVIEW.md`; no AI/model/confidence/product-system language. |
| Over-designed UI | Top-level screens show one dominant decision; deeper richness lives in drilldowns. |
| Trust risk from memory | Memory is visible, controllable, and sensitive memory requires confirmation. |
| Canon ahead of implementation | Docs and UI distinguish shipped/planned/deferred. |
| Dashboard creep | Top-level screens answer one question above the fold. |
| Calendar/sync overclaim | Calendar writes require confirmation; sync/export claims appear only when implemented. |
| ADHD patronizing risk | Use adult language; Focus Support is quiet and universal. |
| Implementation theater | Batch completion requires visible product movement or clear infrastructure unlock. |

## Batch Mapping Rule

Every roadmap item and implementation batch should include this section:

```markdown
## Golden Launch Loop Mapping
- Capture:
- Place/routing:
- Plan/doable path:
- Today/next action:
- Recovery:
- Proof/receipt:
- Trust/privacy:
- Launch status: launch-critical / post-launch / deferred / decision-gated
```

If every line is empty, the work is not launch-critical.

## Acceptance Criteria

A feature, batch, or roadmap item strengthens Ambitions when:

- It makes one meaningful goal easier to organize, make doable, act on today, recover, or prove.
- It uses human, obvious visible language.
- It keeps top-level screens focused on one dominant question.
- It does not widen the top-level IA.
- It does not add AI/producty language to normal UI.
- It does not overclaim sync/export/memory/platform behavior.
- It distinguishes launch-critical from post-launch/deferred work.
- It creates user-visible clarity or unlocks a required shared system.

## Next Prompt

```markdown
Apply `docs/canon/GOLDEN_LAUNCH_LOOP.md` to the Ambitions roadmap and batch docs.

Read first:
1. `docs/canon/SOURCE_OF_TRUTH_MAP.md`
2. `docs/canon/GOLDEN_LAUNCH_LOOP.md`
3. `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
4. `docs/canon/LAUNCH_SCOPE_MVP_QUALITY_BAR.md`
5. `docs/canon/ROADMAP_BATCH_GOVERNANCE.md`
6. `docs/canon/Ambitions_2_0_Roadmap.md`
7. `docs/canon/Ambitions_2_0_Batch_Plan.md`
8. `docs/codex/BATCH_REGISTRY.md`

Task:
- Do not implement app code.
- Add Golden Launch Loop mapping to roadmap/batch planning docs where appropriate.
- Mark launch-critical, post-launch, deferred, and decision-gated work.
- Do not invent new canon.
- Do not archive docs.
- Preserve Today / Goals / Capture / Plan / You.
- Preserve local-first launch and no launch sync.
- Preserve human visible copy rules.

Acceptance:
- Every launch-critical item maps to the Golden Launch Loop.
- Future-only systems are clearly marked post-launch/deferred/decision-gated.
- Roadmap no longer reads like everything must ship at once.
- User-facing wording avoids AI/producty language.
```
