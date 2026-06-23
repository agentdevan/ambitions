# AMB-1197 — Time Native Life Calendar

## Objective

Make Time read as a real native Life Calendar and block fake step-placement behavior, while preserving equal placement rights for free-floating steps.

## Covered Linear issues

- `AMB-1188`
- `AMB-1197`
- Time QA leaves attached to `AMB-1188`

## Covered repo issue IDs

- `AMB-ISSUE-0009`
- `AMB-ISSUE-0501`
- `AMB-ISSUE-0502`
- `AMB-ISSUE-0503`
- `AMB-ISSUE-0504`
- `AMB-ISSUE-0505`
- `AMB-ISSUE-0506`
- `AMB-ISSUE-0507`
- `AMB-ISSUE-0913`
- `AMB-ISSUE-1401`
- `AMB-ISSUE-1402`
- `AMB-ISSUE-1403`
- `AMB-ISSUE-1404`
- `AMB-ISSUE-1405`

## Product law

Time is Ambitions’ native Life Calendar: calendar-grade, Apple-native, Weather-rich, and Private Life Runtime intelligent.

## Architecture law

Day/week/month/year/list are real orientations. Open capacity, protected time, pressure, recovery, goal load, and transition are real lenses. Place Step exists only for a real Step object in a real window.

## Runtime honesty law

No fake `Place Step`. If no eligible Step or no real window exists, show an honest unavailable, recovery, or shape option instead.

## Visual law

- native now seam
- fixed point anchors
- visible open windows
- six lenses: Open Capacity, Protected Time, Pressure, Recovery, Goal Load, Transition
- sparse native labels
- no root `TIME · LifeShape Field`

## Copy and iconography law

Remove internal object-name headers and unexplained layer jargon. Dots, bars, seams, fixed points, and windows must be legible without manifesto copy.

## State model

- real Step required for placement
- free-floating steps equal to goal-linked steps
- protected boundary object with conflict behavior
- shared Today/Time placement truth
- proof residue on windows
- list view is the operational/accessibility equivalent

## Required deletion / replacement

- delete fake placement success without a real Step
- remove internal root header copy
- replace abstract lens labels with understandable calendar semantics where needed
- remove any row/card fallback that dominates the root object

## Required implementation

- Time = native Life Calendar
- calendar-grade, Apple-native, Weather-rich, Private Life Runtime intelligent
- day/week/month/year/list real
- native now seam
- fixed point anchors
- visible open windows
- six lenses: Open Capacity, Protected Time, Pressure, Recovery, Goal Load, Transition
- Place Step only for real Step object
- free-floating steps equal
- protected boundary object
- deterministic conflict proposals
- shared Today/Time placement truth
- Goals feasibility checks
- Capture creates time objects
- proof residue on windows
- list as operational/accessibility equivalent

## Files likely in scope

Codex must inspect current source before editing. Likely areas include Time root/orientations, placement gating, calendar rendering, lensing, conflict proposals, root-header copy, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated shell/search/goals rewrites
- backend/network/R2 files
- product canon files other than required cross-links

## Accessibility requirements

List mode must be a real operational equivalent. Preserve Dynamic Type, VoiceOver clarity, reduced motion fallback, and honest mutation feedback.

## Testing / audit requirements

Run build/tests plus no-Step fake-mutation check, valid placement check, orientation proof, Dynamic Type proof, and light-mode checks.

## Screenshot / device proof requirements

Provide dark/light screenshots, fake-state proof with no eligible Step, valid-state placement proof, day-week-month-year evidence where implemented, and list/accessibility proof.

## docs/qa/KNOWN_ISSUES.md update requirements

Update Time rows for fake-placement status, readability, orientation proof, and Light Mode state.

## Status ceiling

Without valid-state and no-Step proof, Time remains Yellow.

## Closeout template

```text
Status:
Bundle:
Linear issues covered:
Repo issue IDs covered:
Files changed:
Product law implemented:
Architecture law implemented:
Runtime honesty proof:
Validation run:
Validation not run:
Screenshots/videos:
Accessibility proof:
docs/qa/KNOWN_ISSUES.md updates:
Status ceiling:
Known risks:
Rollback plan:
```
