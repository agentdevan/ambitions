# AMB-1197 — Time Native Life Calendar

## Objective

Rebuild Time as Ambitions’ native Life Calendar: Apple Calendar obviousness, Weather richness, and Private Life Runtime intelligence through real calendar-grade orientations, placement, protection, conflict, proof, and capacity behavior.

## Covered Linear issues

- `AMB-1188` parent train
- `AMB-1197` execution bundle
- Time QA leaves under `AMB-1188`

## Product law

Time is a first-class calendar-grade surface. It is not avoiding calendar behavior. It is richer than a calendar because it understands open capacity, protected time, pressure, recovery, goal load, transition, proof residue, and fit.

## Architecture law

Today and Time share placement/protection truth. Time places only real Step objects. A Step can be goal-linked or free-floating but must have title, estimated size/duration, source, and state. Thoughts convert through Capture before placement.

## Runtime honesty law

No fake `Place Step`. No real Step means no Place Step. No real window means honest unavailable/recovery/shape options. No silent conflict resolution.

## Visual law

Calendar-grade LifeShape Calendar Field. Day/week/month/year/list are real orientations. Now is native seam/line related to next fixed point and open window. Fixed points are event anchors with semantic glyphs. No unexplained dots.

## Copy and iconography law

Sparse native labels and tap-to-explain. No root `TIME · LifeShape Field` or `LifeShape Field` marketing copy. Internal names are inspection/help only.

## State model

Lenses: Open Capacity, Protected Time, Pressure, Recovery, Goal Load, Transition. Protected time is a boundary object with start/end, reason, strength, recurrence, source, and conflict behavior. Conflicts produce local deterministic proposals with alternatives.

## Required deletion / replacement

- Remove fake `Place Step` behavior.
- Remove unexplained dot/bar/Now semantics.
- Remove root internal naming.
- Remove generic fallback rows that substitute for calendar behavior.
- Remove Light Mode grey-on-grey rendering in Time.

## Required implementation

- Calendar-grade day view around now.
- Native horizon access to week/month/year/list.
- Day/week/list operational first; month/year real summary views.
- Real Step placement flow.
- Protect Window selection/protection flow.
- Protected boundary persistence.
- Conflict proposal flow.
- Proof residue on windows and receipt detail.
- Capture route support for fixed points, protected windows, step candidates, constraints, and time notes.

## Files likely in scope

- Time surface/views/models
- placement/protection models and repositories
- calendar orientation views
- Capture/Today/Goals route contracts
- design-system calendar tokens
- tests and QA docs

## Files forbidden unless justified

- unrelated Goals path algorithms beyond route contracts
- cloud calendar services unless already approved/local-safe
- product truth files except cross-links

## Accessibility requirements

List orientation must be accessibility-equivalent to visual calendar field. VoiceOver labels for now, fixed points, open windows, protected boundaries, placed steps, conflicts. Dynamic Type and Reduce Motion required.

## Testing / audit requirements

Real Step placement, no-step no-action state, no-window unavailable state, protect-window persistence, conflict proposals, reload persistence, Today/Goals/Capture route proof, forbidden string audit.

## Screenshot / device proof requirements

Day/week/month/year/list, real placement, no-step state, no-window state, protect window, conflict proposal, proof residue, Light/Dark, Dynamic Type, VoiceOver notes.

## Known issues update

Update Time rows including `AMB-ISSUE-0009`, `0501` through `0507`, `0913`, and `1401` through `1405`.

## Status ceiling

Any fake placement = Red. No persistence proof = Runtime Yellow max. No orientation screenshot matrix = Visual Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
