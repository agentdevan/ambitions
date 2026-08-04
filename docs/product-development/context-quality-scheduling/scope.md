+++
initiative = "context-quality-scheduling"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

The user can compare otherwise eligible windows for an accepted Step and
understand why one is more realistic for that Step than another. Ambitions
considers duration together with the Step's work shape, hard stops, Protected
and Fixed time, transitions, place, required tools or connectivity, likely
interruption, and narrow preferences the user explicitly stated or confirmed.

The product does not label an hour, a time of day, or the user as inherently
high- or low-quality. It makes a task-specific placement proposal, shows known
facts and unknowns, and leaves the schedule unchanged until existing Scheduling
authority accepts the applicable placement or reflow command. When evidence is
insufficient or contradictory, Ambitions uses conservative structural fit,
offers an ordinary duration-only fallback, or says that no safe fit is known.

## In scope

- Context-fit comparison for existing accepted Steps, including manually
  created Steps; generated-path Steps may use the same behavior when they exist.
- Window structure: exact duration, hard stop, Protected/Fixed boundary,
  preceding and following commitment categories, transition/setup/recovery,
  place, required tools or connectivity, and likely interruption.
- Step shape: duration or duration range, decomposability, focus and effort
  demand, interruption tolerance, location, tools, connectivity, and
  dependencies.
- Explicit user direction for one placement, one event-relative relationship,
  or a reusable narrow context-fit preference.
- A reviewable local-learning proposal after at least three separate accepted
  sessions with explicit fit feedback in the same bounded context signature.
- Side-by-side or ordered comparison of eligible windows using plain-language
  reasons, material differences, uncertainty, and missing context without a
  quality score.
- Non-durable placement and reflow previews followed by existing Scheduling
  confirmation, commit, Receipt, History, replay, recovery, and external-effect
  reconciliation.
- Inspection, correction, disablement, reset, archive, and deletion of a
  confirmed context-fit influence without rewriting the source Step, Event,
  placement, completion, or History truth.
- Offline, local-first, private, accessible, fail-quiet behavior.

## Out of scope

- A universal energy curve, chronotype, productivity score, or ranking of the
  user's hours, days, routines, or identity.
- Diagnosis or inference of health, disability, burnout, mood, discipline,
  personality, sleep quality, fitness, or cognitive ability.
- Automatic Goal, Goal Path, Step, Event, deadline, priority, recurrence,
  Protected-time, Fixed-time, or completion mutation.
- Silent placement or reflow beyond existing, explicit Scheduling automation
  authority.
- Calendar ingestion, location tracking, route calculation, sensor/health data,
  hosted AI, account dependence, or private-context egress.
- Destination recommendations, capability inference, career or education
  pathing, and Goal Path generation.
- A new Time root, separate energy dashboard, or exposed behavioral dossier.

## Requirements

### REQ-001 — Fit is relational and Step-specific

Ambitions must evaluate a candidate window for a specific accepted Step rather
than assigning an intrinsic quality to the window. The evaluation must keep
Step shape, window structure, event-relative context, and user direction
distinct and must not expose a scalar quality, productivity, or personal-energy
score.

### REQ-002 — Structural constraints take precedence

Duration, hard stops, Protected and Fixed boundaries, transition/setup/recovery
needs, place, required tools or connectivity, interruption safety, dependencies,
deadline safety, and existing placement rules must be evaluated before learned
fit. A structural failure cannot be overridden by a learned preference. Unknown
context remains unknown and must not be filled with a fabricated assumption.

### REQ-003 — Context signatures are narrow and inspectable

A reusable context signature may include only the Step's focus, effort,
decomposability, interruption, place/tool/connectivity shape and the window's
preceding/following commitment categories, hard-stop, transition, setup,
recovery, location/resource availability, and interruption conditions. Two
observations are meaningfully similar only when the factors that affected the
earlier fit are present in both. Ambitions must show which factors matched,
which differed, and which are unknown; label or time-of-day similarity alone is
insufficient.

### REQ-004 — Raw behavior cannot silently become a preference

Deferral, resizing, interruption, repeated friction, cancellation, a missed
Step, or completion timing may prompt one neutral fit question, but none may
become a durable context-fit influence without explicit user confirmation.
Absence or failure must not be interpreted as inability, low energy, or a
personal trait.

### REQ-005 — Learned proposals require repeated accepted evidence

Ambitions may propose a reusable context-fit influence only after at least
three separate completed sessions in the same bounded context signature, each
with explicit user feedback that the fit did or did not work, and no unresolved
contradiction. The proposal must identify the affected Step shape and
event-relative context, cite the accepted observations, state uncertainty, and
remain non-authoritative until confirmed. Sparse, mixed, stale, or sensitive
evidence produces no learned rule.

### REQ-006 — User direction has explicit scope

When the user corrects a fit result, Ambitions must ask whether the change
applies only to the current placement, to the same narrow context relationship,
or to a reusable context-fit influence. A one-off exception must not become a
general rule. A reusable correction must identify its matching boundary and
supersede or contradict only the affected influence.

### REQ-007 — Window comparison is explanatory, not ranking

For two or more eligible windows, Ambitions must show the Step, each exact
window, decisive structural facts, applicable user-confirmed influence,
material differences, missing context, conflicts, and why a proposal is safer
or more realistic. It may recommend one window, show equivalent options, or
state that no safe preference is known, but must not rank the user's time or
claim certainty unsupported by evidence.

### REQ-008 — Quiet fallback preserves useful scheduling

If no confirmed context-fit influence applies, Ambitions must continue using
ordinary Scheduling facts such as duration, capacity, deadlines, transition,
Protected/Fixed time, and explicit preferences. If those facts cannot establish
a safe fit, it must preserve the current schedule, explain the blocking or
missing context, and offer user-controlled alternatives rather than degrade a
constraint or fabricate placement confidence.

### REQ-009 — Scheduling remains the sole placement authority

A context-fit result is a proposal input only. Preview must remain non-durable.
Any accepted placement or reflow must use existing Scheduling confirmation,
canonical mutation, Receipt, History, replay, rollback, recurrence scope, and
external-effect rules. Context learning must not directly mutate a Step, Event,
Schedule Placement, Goal, Goal Path, notification, or external calendar.

### REQ-010 — Material consequences remain visible

A placement or reflow preview must show the trigger, affected objects,
before/after windows, Protected and Fixed boundaries, conflicts, deadlines,
transition/recovery effects, downstream schedule and Goal effects, confirmation
scope, and available recovery. Grouped or material changes require confirmation
under existing Scheduling law; no learned influence expands automation
authority.

### REQ-011 — Learned influences are user-controlled

The user must be able to inspect an influence's plain-language meaning,
evidence categories, matching boundary, uncertainty, where it is used, last
revision, and contradiction state; correct it; disable or re-enable it; reset
context-fit learning; archive or restore it; and permanently delete it after a
consequence preview. Disablement, reset, archive, and deletion must stop its
future use without rewriting source observations or unrelated preferences.

### REQ-012 — Deletion and source lifecycle are truthful

Removing a cited placement or feedback relationship must remove that support
from the influence and re-evaluate its eligibility. Source archive preserves
inspectable lineage but cannot create new influence by itself. Source Trash
makes the relationship unavailable and recoverable; governed source deletion
or redaction removes or minimizes the relationship. Permanent influence
deletion removes its meaning, relationships, and future effect while retaining
at most a disclosed content-free integrity fact; the original Step, Event,
placement, Receipt, and History remain governed by their own lifecycle.

### REQ-013 — Privacy includes derived fit explanations

Context signatures, feedback, learned influences, comparisons, placement
reasons, and correction history must remain private local graph data, work
without an account or network, and never reach Account, R2, Source Atlas,
hosted AI, telemetry, or an external calendar payload. Explanations,
notifications, diagnostics, and exports must minimize event and location
details. Protected or uncertain context cannot produce a learned proposal;
Ambitions must fall back to non-sensitive structural facts or remain quiet.

### REQ-014 — Context-fit behavior remains accessible

Window identity, Step shape, matched and differing factors, unknowns,
uncertainty, conflicts, recommendation, preview consequences, controls, and
results must have a deterministic semantic order. Every comparison and action
must be usable through VoiceOver, Voice Control, Switch Control, Full Keyboard
Access, Dynamic Type, increased contrast, reduced effects, and non-color
indicators, with named alternatives to timeline or drag interaction and
predictable focus and status announcements.

## Acceptance criteria

1. **AC-001 (REQ-001, REQ-007):** Two equal-duration windows can produce
   different explained fit results for one Step based on observable context,
   while another Step shape can produce a different result for those same
   windows; no window or user quality score appears.
2. **AC-002 (REQ-002):** A hard stop, insufficient duration, missing required
   tool, unsafe interruption, or Protected/Fixed boundary blocks the affected
   proposal even when a learned preference favors that context, and the exact
   constraint is visible.
3. **AC-003 (REQ-003):** Inspection lists the factors that match, differ, and
   remain unknown between the cited observations and candidate window. A shared
   hour label or time-of-day bucket alone never establishes similarity.
4. **AC-004 (REQ-004):** A missed, moved, interrupted, or cancelled Step can
   prompt at most a neutral question; dismissing it leaves no durable influence,
   diagnosis, or negative claim.
5. **AC-005 (REQ-005):** One or two accepted sessions produce no reusable
   learned proposal. Three separate, explicitly rated sessions in one bounded
   context may produce one reviewable proposal with citations and uncertainty;
   a contradiction suppresses it pending review.
6. **AC-006 (REQ-006):** A correction can be saved as current-placement-only,
   narrow-context, or reusable influence. The first leaves all future fit
   unchanged; the latter two affect only their stated matching boundary.
7. **AC-007 (REQ-007, REQ-008):** A comparison can recommend one window, show
   equivalent options, or say no safe preference is known. Missing learned
   evidence falls back to duration and structural scheduling without a score or
   false certainty.
8. **AC-008 (REQ-009, REQ-010):** Opening or cancelling a comparison changes no
   canonical object. Accepting a material reflow shows all required consequences
   and commits only through Scheduling with truthful Receipt, History, replay,
   rollback, and external-effect state.
9. **AC-009 (REQ-011):** The user can inspect, correct, disable, reset, archive,
   restore, and delete a context-fit influence, and each action shows exactly
   where future behavior changes and where it does not.
10. **AC-010 (REQ-012):** Source Trash makes cited support unavailable until
    restore; source deletion/redaction removes reconstructive linkage; influence
    deletion stops all future use while leaving source objects and truthful
    history under their own lifecycle.
11. **AC-011 (REQ-013):** The complete fit, comparison, correction, and
    scheduling flow works offline, privacy tests show no prohibited egress, and
    sensitive or uncertain context yields a non-sensitive fallback or quiet
    state.
12. **AC-012 (REQ-014):** Direct assistive-technology verification confirms
    complete comparison, preview, confirmation, cancellation, result, and
    recovery behavior without dependence on timeline position, gesture, color,
    motion, or visual-only relationships.

## Canon impact

- `docs/canon/specifications/systems/scheduling-and-capacity.md` should own the
  bounded context signature as a fit input, relational comparison, structural
  precedence, quiet fallback, and the rule that Scheduling alone owns placement
  and reflow.
- `docs/canon/specifications/systems/local-learning.md` should own evidence
  threshold, confirmation, narrow matching, contradiction, correction,
  disable/reset/archive/delete behavior, and the boundary between observation
  and learned influence.
- `docs/canon/specifications/objects/schedule-placement.md` should preserve the
  relationship between the accepted placement and the fit-policy revision
  without making context fit a second placement owner.
- `docs/canon/specifications/surfaces/time.md` should own window comparison,
  preview, result, and recovery presentation; Today and Goals may show only
  contextual projections through existing ownership.
- `docs/canon/specifications/systems/privacy-and-data-classification.md` should
  own classification and minimization of context signatures and derived fit
  explanations.
- Existing Receipt, History, replay, deletion, Scheduling, and accessibility
  canon remains fully applicable and is not narrowed by this Scope.

No new root surface, Step type, Goal Path authority, or scheduling mutation
owner is introduced.

## Risks and open decisions

Resolved product decisions:

- Context fit is Step-specific and relational, never a universal time or person
  score.
- Structural constraints always outrank learned fit.
- A reusable learned proposal requires three separate accepted sessions with
  explicit feedback in one inspectable bounded signature.
- Raw behavior may prompt reflection but cannot silently become preference.
- Corrections have explicit current-placement, narrow-context, or reusable
  scope.
- Scheduling remains the sole placement/reflow authority, and ordinary
  duration-based behavior remains the fallback.

Delivery risks for Design and grooming:

- The bounded signature contains many factors; Design must keep comparison and
  control language understandable without hiding decisive differences.
- A temporary life circumstance may still satisfy the three-session threshold.
  The proposal must remain uncertain, correctable, and easy to disable.
- Event titles, locations, and recovery context can reveal protected facts;
  fixtures must cover derived-output classification and redacted explanation.
- Existing source models expose internal scalar scores. They cannot become a
  user-facing time-quality or personal-energy score.
- Verification must cover deterministic comparison, DST/time-zone changes,
  recurrence scope, interruption, replay, privacy egress, no-adjacent mutation,
  and direct accessibility behavior at representative schedule scale.
