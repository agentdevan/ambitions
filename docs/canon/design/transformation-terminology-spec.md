# Transformation Terminology Spec

Historical/superseded note: This file is preserved pre-Batch-61 frontend transformation context. Active Ambitions 2.0 terminology now lives in [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md), including `Task = standalone One-Step Goal` and `Step = contained action inside a Goal, Path, or Plan`.

## Purpose

Define the shared language for the front-end transformation program so later batches use one consistent vocabulary.

This file is terminology truth for the future-wave design canon.
It does not change current shipping behavior on its own.

## Core Terms

### Hero surface

The dominant top-of-screen truth region for a major surface.
It states what matters most here before supporting modules appear.

### Recovery

The calm system for turning drift, overload, or broken plans into a safer next move.
Recovery is not an error state or punishment layer.

### Trust Whisper

The first-layer trust hint shown inline or near the dominant decision.
It answers quiet questions like why this, based on what, or whether newer input may matter.

### Reasoning

The expanded explanation layer shown after the whisper layer.
It explains why a recommendation won, what was considered, and what remains uncertain.

### Audit

The deeper trust and correction layer for source context, contradictions, recent changes, and user-visible corrections.
Audit is progressive depth, not a default top-level module.

### Shaping

The act of structuring time, scope, or week posture into something believable.
In Ambitions, shaping most often refers to week-level and strategy-level tradeoff work.

### Command

The consumer-facing quick-action posture for capture, open, recover, explain, correct, reschedule, and focus.
Command is not a developer command palette and not a chat shell.

### Recall

The act of retrieving what changed, what was learned, and why the current state looks the way it does.
Recall should feel like mental relief, not archive search.

### Memory Lens

The named recall surface in the transformation program.
It is a shell-level utility surface for search and recall, not a top-level tab.

### Continuity

The feeling that state, object identity, trust cues, and active context persist coherently across surfaces and platforms.
Continuity carries meaning forward without forcing the user to reconstruct context.

## Goal / Plan / Task Canonical Terms

### Goal Lifecycle Rail

Premium lifecycle timeline for goals. Canonical states are Previous, Active, Future, Parked, Blocked, Waiting, Protected, Completed, and Cancelled / Dropped. Completed means successfully finished; Cancelled / Dropped means intentionally ended and preserves why.

### Goal Atlas

Visual map of related life goals. It begins as a Goals overview preview, appears as connected goals in Goal Detail, expands into Path Builder, and matures into the Ambition Portfolio Manager view.

### Proof Spine

Vertical, receipt-like expression of Proof Rail for one goal. It shows evidence that the goal is becoming real without turning proof into a streak mechanic.

### Next Visible Step

The single visually obvious next action for an active goal. It reduces interpretation burden and prevents Goals or Plan from becoming vague dashboards.

### Goal Weather

User-facing visual language for goal health. Canonical states are Clear, Cloudy, Stormy, Foggy, and Protected, with explanation available in drilldown.

### Decision Trail

Human-readable record of why a goal or plan changed, paused, resumed, completed, cancelled, merged, replaced, or was parked. It is the visible product expression of relevant Event Ledger, Action Closure, and Plan Treaty decisions.

### Timeline View

Clean horizontal or vertical time context for goals, milestones, tasks, proof, decisions, pauses, and recovery moments.

### Milestone Cards

Goal-detail checkpoint cards that show meaningful progress structure before exposing detailed tasks. They may summarize tasks, notes, proof, blockers, deadlines, assumptions, risks, and decision notes.

### Kanban-lite Task Lane

Restrained goal-specific task lane with Later, Next, Doing, Waiting, and Done columns. It belongs inside Goal Detail and must not become Ambitions' top-level identity.

### Weekly Plan Strip

Seven-day visual strip showing how active goals become real this week. It should include buffer, rest, and recovery when those make the week believable.

### Completion Archive

Premium archive for completed, cancelled, dropped, parked, replaced, merged, transformed, or no-longer-relevant goals. It preserves what happened, why, proof collected, what replaced the goal, Decision Trail, and final status.

## Shell Layer Terms

### Persistent shell layer

The always-present top-level shell frame, including the tab bar, adaptive header rail, and contextual global compose affordance.

### Primary route layer

The currently active top-level destination under the shell.

### Subroute layer

Owned detail or supporting routes that stay inside the active top-level destination's narrative.

### Transient overlay layer

Temporary surfaces such as sheets, full-screen composition flows, trust drawers, recovery overlays, and recall overlays.

## Usage Rules

- Use these terms consistently across future batch docs, design specs, and validation notes.
- If another canon file needs a new frontend-program term, add it here rather than inventing local synonyms.
- If terminology conflicts with current shipping language, shipping truth still belongs to `MASTER_PRODUCT_SPEC.md` and live app behavior until the owning future batch lands.
