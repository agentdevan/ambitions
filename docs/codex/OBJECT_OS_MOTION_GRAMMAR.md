# Object OS Motion Grammar

Status: Active supporting canon
Parent: docs/codex/AMBITIONS_OBJECT_OS_CANON.md
Runtime impact in this batch: None

## Purpose

Ambitions motion must communicate object state, continuity, causality, trust, proof, and recovery. Motion is not decoration. It should make the app feel living, evolving, adapting, and premium while preserving accessibility and Reduce Motion behavior.

## Motion principles

1. Motion belongs to objects, not screens.
2. Motion explains state change, not visual flourish.
3. Motion must be calm, physical, native, and restrained.
4. Motion should preserve continuity across Today, Goals, Capture, Time, You, and native surfaces.
5. Motion must never carry essential meaning without a static fallback.
6. Reduce Motion must preserve all information through static transitions, labels, receipts, and state changes.
7. Motion should avoid gamified celebration unless proof/closure genuinely warrants subtle feedback.

## Motion families

### 1. Object birth

Used when a capture becomes an object.

Sequence:

- composer input condenses
- route candidates emerge
- selected route becomes object node
- object receives origin marker
- receipt peek appears

Reduce Motion fallback:

- route selected state change
- object origin label
- receipt row inserted

### 2. Action commitment

Used when an Action Slip becomes an Active Commitment.

Sequence:

- slip lifts into Continuity Dock
- active commitment state anchors to Reality Meridian
- proof opportunity glints if present
- closure controls become available

Reduce Motion fallback:

- Action Slip state changes to Active
- Continuity Dock shows active commitment
- Receipt Peek confirms start

### 3. Closure

Used when a step or commitment closes.

Variants:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

Sequence:

- active object resolves to closure state
- proof trace anchors if proof exists
- receipt peek appears
- recovery path appears if needed

Still Counts should feel calm and valid, not lesser.

### 4. Proof attachment

Used when proof attaches to an object.

Sequence:

- proof trace travels from proof source to object
- object emits subtle proof anchor
- Proof Vault receives new receipt

Reduce Motion fallback:

- proof count/state updates
- receipt inserted
- proof source visible

### 5. Proof transfer

Used during pivot/delete/archive.

Sequence:

- transferable proof stays fixed
- stale proof fades into review state
- moved proof follows new object path
- deleted proof requires explicit confirmation

Reduce Motion fallback:

- proof transfer preview table
- resulting proof states listed

### 6. Recovery creation

Used when a Recovery Thread starts.

Sequence:

- broken path softens
- last honest point becomes anchor
- return path appears
- smallest re-entry step emerges

Reduce Motion fallback:

- Recovery Thread detail appears with last honest point and re-entry step

### 7. Reflow

Used when Time/LifeShape changes.

Sequence:

- old plan compresses
- fixed/protected objects remain anchored
- movable objects slide to new capacity field
- proof survivors stay highlighted
- receipt ticks mark changed objects

Reduce Motion fallback:

- before/after list
- moved/protected/unchanged labels
- receipt row

### 8. Source freshness change

Used when source freshness changes.

Sequence:

- source anchor subtly changes material/brightness
- affected recommendation seam updates
- stale/needs-source state becomes visible

Reduce Motion fallback:

- source state label updates
- affected recommendation shows Source Needed or Stale Source

### 9. Correction

Used when user corrects a route/recommendation/source/time-fit decision.

Sequence:

- incorrect route folds back
- correct route expands
- learning receipt appears
- future pattern marker updates

Reduce Motion fallback:

- corrected state label
- learning receipt
- updated route

### 10. Native surface handoff

Used when entering from widget, Live Activity, App Intent, Share Extension, Spotlight, or Control Center.

Sequence:

- external object expands into matching in-app object
- state and receipt path persist
- no visual reset

Reduce Motion fallback:

- direct navigation to object detail with preserved state

## Ambient state motion

Ambient motion should be subtle and state-driven.

Allowed ambient states:

- clear
- pressure rising
- proof-rich
- source-stale
- recovery-needed
- overloaded
- protected
- simulation pending

Do not animate constantly. Ambient motion should be interruptible, battery-conscious, and disabled under Reduce Motion.

## Haptics

Optional haptics may accompany:

- proof attached
- receipt created
- commitment started
- Still Counts recorded
- recovery started
- correction accepted

Haptics must not be required to understand state.

## Timing guidance

General durations:

- micro feedback: 120-220ms
- object state transition: 220-420ms
- cross-surface continuity transition: 380-650ms
- reflow/simulation transition: 450-800ms

Use native spring behavior only when it supports object continuity. Avoid bouncy, playful, or game-like motion for serious life state changes.

## Motion anti-patterns

Do not use:

- confetti for productivity
- streak animations
- shame/failure animations
- arbitrary particle effects
- casino/sportsbook-style urgency
- motion that hides information
- motion that only works in perfect happy path

## MRI alignment

Motion grammar is binding for:

- MRI25 Shell / Continuity Dock Runtime
- MRI26 Today Reality Meridian Runtime
- MRI27 Goals Constellation Atlas Runtime
- MRI28 Capture Atmosphere Composer Runtime
- MRI29 Time LifeShape Field Runtime
- MRI30 You User System Profile Runtime
- MRI31 Native Apple Surfaces With Receipts
- MRI32 Visual State Screens
- MRI33 Visual QA Preview Fixtures
- MRI34 Visual Runtime Acceptance

## Claims not made

This file defines motion canon only. It does not implement animations or prove runtime motion quality.
