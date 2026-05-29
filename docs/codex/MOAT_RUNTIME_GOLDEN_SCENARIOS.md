# Moat Runtime Golden Scenarios

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-92225986, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-4683724

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
- Today does not shame it as needs review.
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
