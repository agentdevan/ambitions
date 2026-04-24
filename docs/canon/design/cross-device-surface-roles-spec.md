# Cross-Device Surface Roles Spec

## Purpose

Define future platform roles without turning this planning task into implementation work.

## Continuity Doctrine

Cross-device continuity means shared product semantics, not shared layouts.

The governing State Continuity Mesh contract lives in [../Ambitions_State_Continuity_Mesh.md](../Ambitions_State_Continuity_Mesh.md).
Future platforms inherit its continuity semantics; they do not invent separate sync, provenance, handoff, or degraded-state truth.

Every future platform must preserve the same meaning for:

- what the current dominant truth is
- what the next safe action is
- what pressure, momentum, freshness, confidence, recovery, and sync mean
- what command, recall, and trust surfaces are for

Each platform may realize those meanings differently based on form factor, input model, and session length.
No later platform should inherit iPhone layout literally when a more native composition would preserve the semantics more clearly.

## Batch Boundary

- This file defines continuity semantics only.
- It does not authorize cross-device architecture or product implementation work before the relevant active batch.
- Batch 54 defined the State Continuity Mesh contract.
- Batch 55 may consume that contract for widgets, Live Activities, notifications, and Focus Screenlet.
- Batch 56 may consume that contract for share extension, App Intents, shortcuts, routing, and external creation.
- Batch 58 is a deferred/alignment batch that keeps iPad and Mac out of v1 while preserving future optionality.
- Batch 59 is a deferred/alignment batch that keeps Watch and Apple TV out of v1 while preserving future compatibility.

## Shared Product Rule

All platforms share:

- calm trust posture
- restrained visual language
- same semantic meaning for pressure, confidence, freshness, momentum, and sync
- same meaning for hero, recovery, shaping, command, recall, and continuity signals

## Inheritance Rules

- iPhone remains the primary source of future surface semantics.
- State Continuity Mesh remains the source for continuity, sync-trust, provenance, and degraded-sync semantics.
- iPad, Mac, Watch, and Apple TV inherit product meaning, hierarchy intent, and trust posture, not phone-specific layout rules.
- Command and recall flows may widen on larger screens, but they must preserve the same consumer-facing meaning.
- Recovery, trust, and continuity cues may simplify on smaller ambient surfaces, but they must not reverse their meaning.

## iPhone

### For

- daily command center
- quick shaping
- active execution
- fast corrections

### Not for

- dense multi-pane analysis

## iPad

### For

- larger planning workspace
- Strategy Composer depth
- multi-pane goal and week inspection
- keyboard-assisted command and recall

### Not for

- desktop-style settings sprawl

## Mac

### For

- review
- planning
- reflection
- deep recall and command use
- multi-window or multi-pane productivity where it improves clarity

### Not for

- stretched-phone UI

## Watch

### For

- glanceable momentum
- focus confirmation
- quick recovery or defer
- reminders and short confirmations

### Not for

- complex editing
- deep audit or correction depth

## Apple TV

### For

- room-scale review
- weekly reset
- ambient reflection

### Not for

- dense editing
- capture or strategy composition

## Carry-Through Rules

- Living Hero Surface logic carries across, but not always the same form factor
- Time Aperture is primarily iPhone and larger-screen, not Watch
- Focus Screenlet carries to widgets, Live Activities, and Watch
- Appearance Studio and deep Trust Center remain primarily phone and larger-screen surfaces
- cross-device work should preserve semantic continuity first and choose native platform composition second
