+++
initiative = "context-quality-scheduling"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Context-quality scheduling adds a private, local explanation layer inside the
existing Scheduling system. For one accepted Step and two or more structurally
eligible windows, it compares the relationship between the Step's work shape
and each window's observable context. It may recommend one window, describe
equivalent options, or say that no safe preference is known. It never assigns a
quality, energy, productivity, or ability score to a time or person.

The design separates four kinds of authority:

1. `StructuralFitAssessment` applies existing Scheduling law first: duration,
   hard stops, Protected and Fixed boundaries, transitions, setup and recovery,
   place, tools, connectivity, interruption safety, dependencies, deadlines,
   recurrence, and accepted placement rules. A structural failure is final for
   that candidate window and cannot be overridden by learning.
2. `ContextFitProjection` is a deterministic, non-durable explanation of
   matched, different, and unknown factors for one Step/window pair. It may use
   explicit user direction or a current confirmed influence, but has no command
   capability.
3. `ContextFitInfluence` is a private, user-confirmed local-learning object with
   a narrow signature, cited observations, uncertainty, contradiction state,
   correction scope, and complete user-controlled lifecycle. Raw behavior
   cannot create one.
4. `ScheduleChangeSet` and `SchedulePlacement` remain the only canonical
   placement/reflow authorities. Accepting a comparison enters their existing
   consequence preview and confirmation flow; context fit contributes reasons
   and a policy revision, never a commit token.

The current `GoalEnergyFit` numeric values may remain an internal legacy input
for existing behavior, but the new boundary neither reads them as user truth
nor exposes, migrates, or persists them as context-fit authority. Context fit
starts empty. Until qualifying explicit evidence exists, ordinary structural
Scheduling remains fully useful.

## User flows

### 1. Compare eligible windows for an accepted Step

1. From an accepted Step or a Scheduling preview, the user chooses **Compare
   windows**. The coordinator captures the exact Step revision, schedule graph
   revision, locale/time-zone database revision, recurrence instance, and
   applicable policy revision.
2. Scheduling computes eligible windows using structural rules only. Windows
   that fail show their exact blocking constraint and remain unselectable. No
   learned influence can restore them.
3. For each eligible window, `ContextSignatureProjector` produces a bounded
   Step/window signature. It excludes event titles, free-form notes, health
   data, inferred mood, and any factor outside the approved signature.
4. The context comparator lists, in order, the Step shape, exact window,
   decisive structural facts, explicit direction, applicable confirmed
   influence, matched factors, differing factors, unknowns, conflicts, and
   uncertainty.
5. The result is exactly one of:
   - **Recommended for this Step**, with decisive reasons;
   - **Equivalent known fit**, with no forced ordering; or
   - **No safe preference known**, with structural options and missing facts.
6. The screen states **Nothing changes until you review and confirm the
   Scheduling preview**. Cancelling leaves every canonical object unchanged.

Equal-duration windows may differ because one lacks a required tool, ends at a
hard stop, follows a high-transition commitment, or has unsafe interruption
conditions. The same windows may compare differently for a decomposable phone
call than for uninterrupted study. The explanation never generalizes either
result to the inherent quality of the hour or the user.

### 2. Use explicit direction

The user may say that a fact applies only to:

- this placement;
- this event-relative relationship, such as “after the gym, allow recovery”;
  or
- a reusable narrow context relationship.

Before saving, the review names the exact Step-shape boundary, window factors,
and future matches. Current-placement direction stays inside the active
non-durable preview and is discarded if the preview is cancelled. Narrow
context direction becomes a confirmed influence only after the user reviews
its matching boundary. A reusable correction supersedes only intersecting
influences and preserves unrelated preferences.

### 3. Reflect on a completed or disrupted session

A completion, deferral, resize, interruption, repeated friction, cancellation,
or missed Step may make one neutral question available, for example: **Did the
context of this session fit this kind of Step?** The prompt is optional,
dismissible, and not repeated for that observation after dismissal.

- Dismissal stores no feedback or negative inference.
- **Worked**, **did not work**, and **unsure** are explicit feedback values;
  only the first two can support learning.
- The user inspects the narrow factors captured before accepting the feedback.
- The observation never claims low energy, inability, lack of discipline,
  burnout, or another personal trait.

Raw behavioral events cannot cross the confirmation boundary. They may only
produce the neutral question and its local deduplication key.

### 4. Review a reusable influence proposal

`ContextLearningEvaluator` considers a proposal only after three or more
separate completed sessions, each explicitly accepted with fit feedback, share
the same material bounded signature and have no unresolved contradiction. A
repeated recurrence instance counts only when it was a distinct completed
session and separately confirmed. Same-session edits, retries, or duplicate
feedback do not increase the count.

The proposal shows:

- the Step-shape and event-relative context it would match;
- the accepted observation dates/categories without exposing unrelated event
  content;
- which signature factors matched, differed, or were unknown;
- supporting and contradicting feedback;
- uncertainty, expiry/review conditions, and where it could affect future
  comparisons; and
- **Confirm influence**, **Narrow boundary**, **Not now**, and **Reject**.

Sparse, mixed, stale, protected, or contradictory evidence yields no proposal.
Confirmation creates one influence through the local-learning owner; it does
not place or reflow a Step.

### 5. Inspect, correct, or remove an influence

The influence detail shows plain-language meaning, signature boundary,
evidence categories, cited relationships, uncertainty, contradiction state,
last revision, and current uses. The user can:

- correct the meaning or boundary, creating a new revision;
- disable and later re-enable it;
- reset all context-fit learning after a consequence preview;
- archive and restore it; or
- move it to Trash, restore it, and permanently delete it after a preview.

Disable, reset, archive, Trash, and deletion stop future comparison use without
rewriting the original Step, Event, placement, feedback, Receipt, or History.
Permanent deletion removes reconstructive meaning and relationships, retaining
only a disclosed content-free integrity fact when required for replay safety.

### 6. Accept a placement or reflow

1. Choosing a proposed window creates an in-memory `ContextFitSelection` bound
   to the exact comparison and policy revisions.
2. Scheduling revalidates the Step, constraints, recurrence instance, existing
   placements, deadlines, influence revision, time zone, and affected graph.
3. Its ordinary preview shows trigger, affected objects, before/after windows,
   Protected and Fixed boundaries, conflicts, deadlines, transition/recovery,
   downstream schedule and Goal effects, recurrence/confirmation scope, and
   recovery.
4. Only explicit Scheduling confirmation may commit a `ScheduleChangeSet` and
   resulting placements with its own Receipt, History, replay, rollback, and
   external-effect state.
5. If anything changed, the selection becomes stale and the user returns to an
   updated comparison. The old schedule remains authoritative.

No context-fit action creates a Goal, Goal Path, Step, Event, placement,
notification, or external-calendar operation.

### 7. Quiet fallback and recovery

When there is no confirmed influence, comparison uses structural Scheduling
facts and explicit one-off direction. When a context factor is unknown, the
explanation names it and does not fabricate a value. When structural facts
cannot establish safe fit, the current schedule is preserved and the user may
choose another eligible window, change an owned constraint through its owner,
use duration-only scheduling, or leave the Step unplaced.

## States and recovery

### Comparison states

`ContextComparisonState` is one of:

- `resolving`: exact Step, schedule, recurrence, context, and policy revisions
  are loading;
- `readyRecommended`: at least two eligible windows exist and one has a
  materially safer or more realistic explained fit;
- `readyEquivalent`: available evidence does not distinguish eligible windows;
- `noSafePreference`: windows remain structurally eligible but evidence is
  insufficient, mixed, or unknown;
- `structurallyBlocked`: no candidate survives existing Scheduling rules;
- `partiallyUnknown`: comparison remains useful with named unknown factors;
- `contradicted`: an applicable influence conflicts with current confirmed
  evidence and is excluded pending review;
- `stale`: a bound Step, schedule, source, influence, time-zone, recurrence, or
  policy revision changed;
- `previewPending`: Scheduling is showing its own non-durable change preview;
- `committing`: Scheduling, not context fit, owns a confirmed mutation; and
- `failed`: the last coherent schedule and explanation remain visible with a
  retry or exit action.

The UI never labels an influence as truth or a preview as scheduled. Unknown,
not applicable, contradicted, blocked, stale, and unavailable are distinct
semantic states.

### Influence states

`ContextFitInfluenceState` is `proposed`, `confirmed`, `disabled`, `contradicted`,
`stale`, `archived`, `trashed`, or `deletedTombstone`. Only a current,
non-contradicted `confirmed` influence can contribute an explanation. A
proposal has no scheduling effect. Restore always revalidates citations and
the current signature policy before use.

### Failure and interruption rules

- **Interrupted comparison:** cancel in-flight work and retain the last
  coherent projection in memory; relaunch recomputes from current canonical
  inputs rather than treating a preview as saved intent.
- **Interrupted feedback save:** the idempotency key returns either the one
  committed observation relationship or no relationship; duplicate sessions
  cannot satisfy the evidence threshold.
- **Interrupted influence mutation:** command replay settles one lifecycle
  state. A partially written evidence graph is never visible.
- **Source archived:** lineage remains inspectable but cannot alone create new
  support. Existing influence eligibility is re-evaluated.
- **Source trashed:** support becomes unavailable and the influence is stale or
  ineligible until restoration and revalidation.
- **Source deleted or redacted:** reconstructive linkage is removed/minimized;
  support counts are recomputed without inventing replacement evidence.
- **Time-zone or DST change:** wall-clock, instant, recurrence, and transition
  semantics are recomputed. Ambiguous or nonexistent local times block the
  affected option rather than shifting silently.
- **Concurrent Step/schedule/influence edit:** late projections are discarded;
  preserved user focus moves to the first changed factor and the action is
  announced.
- **Preview cancellation or commit failure:** the preexisting schedule remains
  authoritative. Scheduling supplies the retry, rollback, or reconciliation
  action; context fit cannot repair canonical state.
- **External calendar failure after local settlement:** existing Scheduling
  reconciliation reports pending/failed external effect without reversing or
  overstating the local commit.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 5 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Component ownership

- `ContextFitComparisonCoordinator` lives inside Scheduling and orchestrates
  read snapshots, cancellation, deterministic projection, and the handoff to
  existing Scheduling preview. It holds no canonical executor.
- `StructuralFitAssessing` is the existing Scheduling-owned gate. Its result is
  evaluated before any learning adapter and cannot be weakened downstream.
- `ContextSignatureProjector` creates an allow-listed `ContextSignatureV1` from
  Step and window snapshots and emits factor-level provenance.
- `ContextFitComparator` compares structurally eligible candidates and returns
  qualitative `recommended`, `equivalent`, or `noSafePreference` posture plus
  reasons. It has no scalar output field.
- `ContextObservationCoordinator` owns the neutral question and confirmed
  feedback relationship. Behavioral signals are input only to prompt
  eligibility, never influence evidence.
- `ContextLearningEvaluator` is a pure local-learning function that enforces
  separate-session count, explicit feedback, narrow similarity, freshness,
  privacy, and contradiction rules before producing a proposal.
- `ContextFitInfluenceRepository` is actor-isolated private graph storage for
  influence revisions and source relationships. Its commands own confirmation,
  correction, disable/re-enable, reset, archive/restore, Trash/restore, and
  deletion.
- `SchedulePreviewing` consumes a non-durable selection and current policy
  binding. Existing Schedule Change Set/Placement owners alone validate and
  commit placement or reflow.
- Time renders the primary comparison. Today and Goals may show existing
  projections only and cannot originate influence or placement commands.

### Core records

`ContextSignatureV1` contains only:

- Step shape: focus demand, effort demand, decomposability, interruption
  tolerance, required place, tools, connectivity, dependencies, and duration
  range;
- window shape: preceding/following commitment categories, hard-stop presence,
  Protected/Fixed intersections, transition/setup/recovery requirements,
  resource/location availability, interruption conditions, and exact
  recurrence-instance identity; and
- policy version, per-factor known/unknown state, source owner/revision, and
  privacy handling class.

It contains no event title, free-form note, inferred health/energy/mood trait,
unbounded location history, or time-quality label. Similarity is factor-based:
every factor that materially explained the earlier result must match; a
difference or unknown is shown and prevents that observation from supporting
the same signature when material.

`ContextFitObservationV1` contains observation ID, completed session/placement
ID, Step-shape fingerprint, bounded context fingerprint, explicit feedback,
accepted-at instant, source revisions, privacy class, and lifecycle state. A
unique constraint on session/placement ID plus feedback kind prevents one
session from counting twice.

`ContextFitInfluenceV1` contains stable ID, revision, plain-language meaning,
matching signature/mask, correction scope, supporting observation IDs,
contradiction IDs, uncertainty, created/confirmed/reviewed times, policy
version, state, superseded revision, and privacy class. It contains no numeric
strength or person score.

`ContextFitProjectionV1` contains Step/window IDs and revisions, structural
result, factor-level matches/differences/unknowns, applicable explicit direction
and influence revision, qualitative posture, material reasons, uncertainty,
privacy-safe explanation fragments, comparison fingerprint, and stale reasons.
It is ephemeral and cannot conform to canonical mutation protocols.

`ContextFitSelection` contains only the selected window, exact projection
fingerprint, Step/schedule/recurrence/influence revisions, and creation time. It
expires on dependency change and carries no mutation, Receipt, or placement ID.

### Persistence and migration

The influence repository uses the existing protected local graph and
Command/Event/Projection persistence conventions. Writes are revision-checked,
checksummed, flushed, and atomically replaced or journal-settled according to
the selected existing primitive during grooming. Evidence relationships point
to governed source identities; they do not copy Step, Event, placement, or
feedback content into a second authority.

Schema v1 begins empty. Existing `GoalEnergyFit`, time-of-day buckets, friction
counts, schedule history, and implicit behavioral patterns are not backfilled
as context observations or influences. A future importer may migrate only
explicit user-confirmed direction with an inspectable compatible boundary; all
other legacy values remain outside this feature. Unknown schema versions fail
closed and leave ordinary Scheduling available.

Archive, Trash, restore, redaction, and deletion are explicit graph events.
Reset batches lifecycle commands for context influences only and exposes the
count and future behavior impact before confirmation. It never rewrites source
objects or canonical History. A deleted influence tombstone contains only
identifier, terminal event/revision, deletion policy version, and integrity
digest when required; no meaning, signature, source link, or private context is
recoverable from it.

### Determinism, concurrency, and replay

Every projection receives an injected clock, calendar, locale, time zone and
time-zone database version, recurrence policy, context policy, stable factor
order, and immutable input manifest. Equal manifests produce equal structural
results, factor classifications, qualitative posture, reasons, and fingerprint.
No dictionary order, task completion order, model score, or wall-clock read may
change the result.

The comparison and influence repositories are actors. Each asynchronous
comparison uses a generation token and captured revision manifest; superseding
work cancels it and late results are discarded. Influence commands use
expected revision and idempotency keys. Proposal confirmation rechecks the
three-distinct-session threshold and contradictions inside one transaction.
Scheduling separately performs compare-and-swap on its canonical read set at
commit time.

Replay reconstructs observation relationships and influence lifecycle from
their own events, then recomputes projections under the recorded policy version.
Schedule replay remains entirely owned by Scheduling and retains only the
accepted influence/policy revision as explanatory lineage. A replayed context
selection cannot create or duplicate a placement.

### Canon and expected source impact

Grooming should update Scheduling canon with relational fit, structural
precedence, quiet fallback, and sole placement authority; Local Learning canon
with evidence threshold and influence lifecycle; Schedule Placement canon with
the accepted explanatory policy binding; Time surface canon with the comparison
and recovery flow; and privacy canon with signature/explanation handling.

Expected source owners are Scheduling policy/projection, Local Learning,
private graph persistence, Time presentation, and focused Quality fixtures.
No new root surface, Step type, Goal Path owner, calendar ingestion path, or
external service is introduced.

## Privacy and accessibility

Context signatures, observations, feedback, influences, comparisons, reasons,
correction history, and selections are private local graph or ephemeral data.
The complete flow works without account or network. Account, R2, Source Atlas,
hosted AI, telemetry, analytics, diagnostics payloads, support upload, external
calendars, widgets, Spotlight, clipboard, and notifications receive no private
context payload. No calendar ingestion, location tracking, sensor/health data,
or route calculation is added.

All inputs and derived explanations carry a handling class. Mixed public and
private output inherits the private class. Protected or uncertain context
cannot support a learned proposal. The evaluator removes that factor and uses
non-sensitive structural facts only when safe; otherwise it remains quiet.
Diagnostics are limited to correlation IDs, schema/policy versions,
factor-category names, state/reason codes, and non-reconstructive shape hashes.
They exclude event titles, place details, exact windows, Step text, feedback,
signatures, reasons, and source relationships. Unknown classification denies
the destination.

The primary accessible representation is an ordered list, never a timeline or
matrix alone. Semantic order is: Step identity and shape; comparison state;
each exact window; structural constraints; matched factors; differing factors;
unknowns and conflicts; applicable direction/influence and uncertainty;
recommendation posture; preview consequence; then actions.

Every action has a unique label and equivalent accessibility action: inspect
factor, inspect influence, compare windows, choose for Scheduling preview,
correct scope, answer/dismiss feedback, confirm/narrow/reject influence,
disable/re-enable, reset, archive/restore, Trash/restore/delete, refresh, retry,
cancel, and return. No drag, timeline position, swipe, color, haptic, or motion
is required. Voice Control, Switch Control, Full Keyboard Access, hardware
keyboard, and VoiceOver reach the same content and actions.

Dynamic Type through accessibility sizes converts comparisons to stacked
sections without hiding evidence or actions. Increase Contrast, Bold Text,
Button Shapes, Differentiate Without Color, Reduce Transparency, Reduce Motion,
RTL, and localization preserve identity and state. Opening review moves focus
to its heading; changed inputs focus the first affected factor; a recommendation
announcement names the Step and posture without private detail on the lock
screen; preview handoff focuses Scheduling's consequence heading; cancellation,
failure, and result restore focus to the initiating or nearest stable control.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| `REQ-001` | `ContextFitProjection` binds one accepted Step to exact windows and preserves distinct Step/window/direction inputs; qualitative posture has no scalar or inherent time/person label. |
| `REQ-002` | `StructuralFitAssessing` runs first and its duration, boundary, transition, resource, interruption, dependency, deadline, and placement failures cannot be overridden; unknowns remain explicit. |
| `REQ-003` | The allow-listed signature and factor-level comparison expose every material match, difference, and unknown; time label alone never establishes similarity. |
| `REQ-004` | Behavioral signals may create one neutral dismissible question only; explicit accepted feedback is separately typed and no failure or trait inference is stored. |
| `REQ-005` | The evaluator transaction requires three distinct completed sessions, explicit accepted feedback, one bounded material signature, freshness, safe classification, and no unresolved contradiction before a reviewable proposal. |
| `REQ-006` | Correction review requires current-placement, narrow-context, or reusable scope and revisions/supersedes only intersecting influences. |
| `REQ-007` | Ordered qualitative comparison exposes decisive facts, influences, differences, missing context, conflicts, and reasons and returns recommend/equivalent/no-safe-preference without ranking time. |
| `REQ-008` | Empty, sparse, stale, mixed, and unavailable learning use existing structural Scheduling or preserve the schedule with user-owned recovery choices. |
| `REQ-009` | Context artifacts have no canonical executor; only existing Schedule Change Set/Placement owners revalidate, confirm, commit, receipt, replay, roll back, and reconcile external effects. |
| `REQ-010` | Scheduling's handoff preview lists trigger, affected objects, before/after windows, boundaries, conflicts, deadlines, transition/recovery, downstream effects, scope, and recovery; learning never expands automation. |
| `REQ-011` | Influence detail and commands provide inspection, correction, disable/re-enable, reset, archive/restore, Trash/restore, and permanent deletion with exact future-effect previews. |
| `REQ-012` | Source lifecycle recomputes support truthfully; influence deletion removes meaning/linkage/future effect while source objects and canonical Receipt/History remain under their owners. |
| `REQ-013` | Private local classification, offline operation, fail-closed destinations, minimized derived output, protected-factor exclusion, and no inferred legacy backfill enforce the complete privacy boundary. |
| `REQ-014` | Deterministic list semantics, named non-gesture controls, input parity, Dynamic Type, contrast/reduced-effects/RTL behavior, and focus/status rules preserve the complete comparison and lifecycle nonvisually. |

## Verification design

### Model, policy, and property tests

- Add `ContextSignatureProjectorTests` for the exact allow-list, known/unknown
  factors, material match/difference behavior, event-title exclusion,
  time-label insufficiency, and output handling classes.
- Add `StructuralPrecedenceTests` for duration, hard stop, Protected/Fixed
  boundaries, transition/setup/recovery, place/tool/connectivity, interruption,
  dependency, deadline, and accepted placement rules. Every failure must remain
  blocked under a favorable influence.
- Add `ContextFitComparatorTests` proving Step-relational results,
  recommended/equivalent/no-safe-preference states, explicit unknowns, and the
  absence of scalar, productivity, ability, chronotype, or personal-energy
  fields and copy.
- Add `ContextLearningEvaluatorTests` for zero/one/two observations, three
  distinct accepted sessions, duplicate-session rejection, explicit feedback,
  material-factor mismatch, contradiction, staleness, protected facts,
  recurrence instances, narrow proposals, and raw-behavior non-authority.
- Add correction and lifecycle tests covering every scope, supersession,
  disable/re-enable, reset, archive/restore, Trash/restore, deletion, source
  archive/Trash/restore/delete/redaction, and unrelated-source preservation.
- Add property tests that permuted inputs and asynchronous completion orders
  yield identical projections/fingerprints and that no structurally blocked
  window becomes selectable.

### Integration, persistence, concurrency, and replay

- Snapshot Goal, Goal Path, Step, Event, placement, recurrence, notification,
  and external-effect stores before and after open, compare, feedback prompt,
  proposal review, correction, and selection; require unchanged canonical
  bytes until Scheduling confirmation.
- Exercise the full Scheduling handoff: stale revision rejects before commit;
  success creates exactly the existing canonical mutation/Receipt/History;
  duplicate selection or command creates no duplicate placement.
- Crash at observation write, influence proposal confirmation, lifecycle
  mutation, preview construction, Scheduling commit, and external-effect
  dispatch. Recover one coherent influence state and truthful schedule state.
- Test optimistic conflicts and out-of-order projection completion. A stale
  result never replaces newer feedback, influence state, or schedule input.
- Test empty v1 initialization, round-trip, corrupt/unsupported schema,
  content-free deletion tombstone, reset, and explicit non-migration of numeric
  energy/time buckets or inferred behavior.
- Replay observation/influence events and compare projections/fingerprints;
  independently replay Scheduling to prove a context selection cannot mutate or
  duplicate placement.
- Cover spring-forward gaps, fall-back ambiguity, time-zone database changes,
  travel/time-zone changes, recurrence scopes, locale/calendar changes, and
  transition across midnight.

### Runtime, performance, privacy, and accessibility

- Run the approved before-work versus after-gym study fixture plus a
  decomposable low-interruption Step over the same windows. Cover missing tool,
  hard stop, Protected/Fixed overlap, unknown context, equivalent options,
  contradiction, sparse evidence, quiet fallback, no-safe-fit, cancelled
  preview, failed commit, source deletion, and offline relaunch.
- Measure projection and influence matching at representative schedule,
  recurrence, observation, and influence scale. Grooming must set device/OS,
  dataset, cold/warm percentile and maximum, memory, energy, cancellation
  latency, and regression thresholds before claiming performance.
- Execute class/destination privacy abuse tests for Account, R2, Source Atlas,
  hosted AI, telemetry, analytics, diagnostics, support, calendar payloads,
  notifications, widgets, Spotlight, clipboard, and protected/mixed derived
  explanations. Verify full offline/no-account behavior.
- Directly verify on representative iPhones and supported OS versions:
  VoiceOver order/rotor/actions/announcements/focus, Voice Control names,
  Switch Control, Full Keyboard Access and hardware keyboard, Dynamic Type,
  Bold Text, Button Shapes, Increase Contrast, Differentiate Without Color,
  Reduce Motion/Transparency, RTL/localization, locked-device privacy, timeline
  alternatives, every lifecycle action, stale/error recovery, and comparison
  parity. Automated checks and screenshots are supporting, not direct,
  accessibility evidence.
- Run changed-scope build, focused tests, lint, static analysis, canon, secrets,
  and privacy checks. Source/build evidence does not imply device,
  accessibility, deployment, or release proof.

## Open decisions

No product decision remains open. Grooming must resolve these technical choices
without changing approved behavior:

- select the existing protected graph/journal primitive and concrete schema
  registration for observations and influence revisions;
- identify the exact current Schedule Change Set/Placement preview protocol and
  remove any adapter capability that could bypass its confirmation command;
- define stable categorical encodings for focus, effort, interruption,
  commitment, place/resource, transition, setup, and recovery factors without
  introducing a hidden aggregate score;
- calibrate observation/influence retention and representative performance
  limits under existing privacy/deletion law; and
- choose the SwiftUI comparison decomposition while preserving the fixed
  semantic and focus contract.

If implementation requires implicit behavior to create an influence, a learned
preference to override a structural constraint, a context-fit component to
commit placement/reflow, or a universal time/person score, that is a Scope
conflict and must return to product review rather than be resolved in grooming.
