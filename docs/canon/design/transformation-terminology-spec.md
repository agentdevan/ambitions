# Transformation Terminology Spec

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
