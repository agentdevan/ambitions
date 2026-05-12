# Moat Runtime Golden Scenarios

Status: active control-plane overlay  
Batch: MRI00-MOAT-RUNTIME-GAP-LOCK

## Purpose

Golden scenarios define the product behaviors Ambitions must eventually prove end-to-end.

These scenarios are not release proof by themselves. They are acceptance targets for future implementation and QA.

## Scenario 1 — Busy Day Breaks

A user starts the day with a planned commitment. Work expands, protected time appears, and the original step no longer fits.

Expected behavior:

- Reality state changes.
- Start Here updates or explains why the step no longer fits.
- Ambitions offers Still Counts, Moved, Shortened, Waiting, Blocked, or Needs Recovery.
- Proof already earned is preserved.
- Receipt explains what changed.

## Scenario 2 — Capture Becomes Proof

A user captures a screenshot, note, or statement that proves progress on a goal thread.

Expected behavior:

- Capture routes to Proof, not generic note.
- User can correct route if wrong.
- Proof attaches to the relevant Ambition/Goal Thread/Commitment.
- Receipt records the proof placement.

## Scenario 3 — Source Becomes Stale

A source-backed recommendation depends on a claim whose freshness expires.

Expected behavior:

- Source state changes to stale or review-needed.
- Recommendation confidence/wording downgrades without using fake AI confidence.
- Why This? shows the stale source.
- User can review or replace the source.

## Scenario 4 — Goal Pivots and Proof Transfers

A user pivots from one outcome path to another.

Expected behavior:

- Ambitions previews what transfers and what does not.
- Valid proof remains attached.
- Invalid/obsolete proof is marked but not silently destroyed.
- Pivot receipt records why and what changed.

## Scenario 5 — Recommendation Rejected and Corrected

A user rejects Start Here because it is the wrong kind of work.

Expected behavior:

- User can say why: wrong time, wrong goal, too big, already done, wrong source, low energy/context.
- Ambitions records local correction.
- Future recommendations change inspectably.
- User can reset/delete this learning later.

## Scenario 6 — User Resets Local Learning

A user opens You and clears a learned pattern.

Expected behavior:

- You shows what Ambitions learned and used.
- User can disable/reset/delete the signal.
- Receipt records the local change.
- Recommendations no longer use that signal.

## Scenario 7 — Protected Time Appears

A calendar/protected block changes the day.

Expected behavior:

- LifeShape Field updates pressure/capacity.
- Start Here recommendation adjusts fit.
- Reflow is suggested, not silently applied.
- Receipt records accepted reflow.

## Scenario 8 — Blocked Commitment Recovers

A commitment becomes blocked because it waits on someone/something.

Expected behavior:

- Commitment state becomes Waiting or Blocked.
- Today does not shame it as failed.
- Recovery Thread tracks last honest point.
- Re-entry step appears when unblocked.

## Scenario 9 — Wrong Capture Route Corrected

Ambitions classifies a capture as Ready to Place, but the user says it is a Constraint.

Expected behavior:

- Correction Fold lets the user fix it.
- Capture route changes.
- Local pattern can update if user allows.
- Receipt records correction.

## Scenario 10 — Source Needed Before Recommendation

A user asks for a recommendation that depends on missing or untrusted source truth.

Expected behavior:

- Ambitions shows Source Needed mode.
- It does not pretend certainty.
- User can add/review source.
- Recommendation is withheld, degraded, or marked provisional.

## Scenario 11 — Native Surface Action Creates Receipt

A user completes a step from a widget/App Intent/notification.

Expected behavior:

- External action routes through policy guard.
- Command/event ledger records action.
- Receipt is created.
- Today/Goals reflect closure.

## Scenario 12 — Visual Runtime Anti-Generic Review

A top-level screen is rendered for review.

Expected behavior:

- It is clearly Ambitions-specific.
- Primary object dominates.
- It cannot be mistaken for a generic task/calendar/notes/dashboard/chatbot screen.
- Accessibility and reduced-motion meaning are preserved.
