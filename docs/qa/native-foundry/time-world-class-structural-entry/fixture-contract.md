<!-- markdownlint-disable MD013 -->

# Time Research Fixture Contract

Fixture ID: `time-flagship/week/protected-family-and-launch/v1`

Fixture status: `IMMUTABLE_SYNTHETIC_RESEARCH_CONTRACT`

Implementation status: `NOT_IMPLEMENTED`

This fixture exists only to keep the six text directions semantically comparable. It is non-canon, non-production, disconnected from runtime data, and does not authorize fixture code, SwiftUI, mutation, screenshots, or settlement.

## Range and focus

- Active range: `This week`
- Current day: `Wednesday`
- First bounded viewport: Week
- Required depth: Wednesday → temporal object detail and Wednesday → conflict-review trigger → current/proposed review → cancel or fixture-only settlement → exact return

## Accepted local truth

### Fixed work handoff

- ID: `placement.send-launch-brief.wed-1400`
- Title: `Send the launch brief`
- Time: `Wednesday · 2:00–2:30 PM`
- State: `Accepted · Fixed`
- Goal identity: `goal.ship-launch-well`

### Protected family time

- ID: `placement.family-time.wed-1730`
- Title: `Family time`
- Time: `Wednesday · 5:30–7:30 PM`
- State: `Accepted · Protected`
- Meaning: `No work`

## Open capacity

- ID: `opening.wed-after-1830`
- Time: `After 6:30 PM`
- State: `Open`
- Meaning: `Available calendar space; personal usability is not automatically inferred.`

The overlap between the open-calendar observation beginning at 6:30 PM and protected family time ending at 7:30 PM is intentional: calendar openness and personal usability are different truths. No direction may turn the opening into a recommendation or erase the protected interval.

## External observation

- ID: `external.prenatal-appointment.thu-0900`
- Title: `Prenatal appointment`
- Time: `Thursday · 9:00–10:00 AM`
- Source: `Apple Calendar observation`
- State: `External observation`
- Authority: `Not an accepted Ambitions Event or placement`

## Proposed placement

- ID: `proposal.paint-nursery-wall.thu-1030`
- Title: `Paint the nursery wall`
- Time: `Thursday · 10:30–11:30 AM`
- Goal: `Welcome our baby home`
- Step ID: `step.paint-nursery-wall`
- State: `Proposed · Not scheduled`
- Consequence: `The movement fits after the appointment while leaving protected family time unchanged.`

No viewport, detail, accessibility label, legend, material, fill, or motion may display this proposal as accepted scheduled work before settlement.

## Conflict-review fixture

- Proposed change: `Move launch review to Wednesday · 5:45–6:15 PM`
- Current truth: `Family time remains protected from 5:30–7:30 PM.`
- Consequence: `The proposed change would consume protected family time.`
- Participants: the proposed launch-review placement and accepted protected family-time placement
- Current authority: protected family time remains accepted and unchanged throughout preview

### Identity boundary

The conflict-review fixture is a distinct scenario from `Send the launch brief`. The supplied contract does not define a stable ID or current accepted time for `launch review`, and no direction may invent either one or treat `placement.send-launch-brief.wed-1400` as that object.

The review must therefore state only the supplied facts:

- `Current`: Family time remains accepted and protected from 5:30–7:30 PM.
- `Current launch-review placement`: not specified by this research fixture.
- `Proposed`: launch review at 5:45–6:15 PM.
- `Consequence`: the proposed interval would consume protected family time.

`Keep current time` is retained as a supplied outcome label, but the review cannot visualize an invented prior launch-review range. Cancellation or fixture-only inspection returns to the originating Wednesday conflict-review trigger and focus. The separate compact-detail path returns to `Send the launch brief`.

Valid later calibration outcomes:

- `Cancel`
- `Keep current time`
- `fixture-only proposed alternative inspection`

No automatic recommendation, silent reflow, accepted change, local commit, external write, Receipt, or Undo is implied.

## Required semantic order

The standard and accessibility forms preserve:

1. active range and relationship to Now;
2. Wednesday identity;
3. accepted fixed work handoff;
4. accepted protected family time and “No work” meaning;
5. open calendar observation with usability disclaimer;
6. Thursday external observation with source;
7. proposed nursery Step with “Not scheduled” state;
8. selected `Send the launch brief` identity and exact return from compact detail;
9. distinct launch-review conflict trigger with its current placement explicitly unspecified;
10. accepted protected family-time truth;
11. proposed 5:45–6:15 PM launch-review truth and consequence;
12. conflict participants and protected meaning;
13. cancel/keep-current outcomes; and
14. return to the originating conflict trigger and focus.

## Density variants for later prototype testing

This research contract defines only the named truth. A later authorized fixture implementation may derive quiet, typical, dense, and very-dense permutations by adding synthetic neutral objects, but it must not alter the identity, authority, timing, source, protection, or proposal state of the named records.

## Automatic invalidation

The fixture is invalid if any representation:

- marks `proposal.paint-nursery-wall.thu-1030` scheduled or accepted;
- calls the prenatal appointment an Ambitions Event;
- treats `opening.wed-after-1830` as personally usable or recommended;
- weakens or moves family time during preview;
- explains conflict only as red overlap;
- omits source or freshness when authority depends on it;
- offers a working commit, Receipt, Undo, or external settlement; or
- loses the exact period/day/object/focus return target.
