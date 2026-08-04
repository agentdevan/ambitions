+++
initiative = "adaptive-local-learning-and-replanning"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions should improve when reality teaches it something: a Step repeatedly
takes longer in one context, reminders are dismissed, a route assumption is
corrected, a capability is confirmed, an opportunity closes, or the user says a
suggestion was wrong. Improvement must not mean surveillance or a secret model
of discipline, motivation, aptitude, mood or personality. It must mean bounded,
inspectable evidence changes a declared planning decision and can be corrected,
disabled, reset or deleted.

The outcome is a local Learning & Replanning service that turns permitted events
and explicit correction into candidate influences, asks before activating
inferred patterns, and proposes versioned plan/schedule/simulation deltas when
material facts change. It never silently rewrites accepted Goals, Paths, Steps
or Time.

## Current truth

### Canon and approved portfolio

`SYSTEM-LOCAL-LEARNING` already requires local evidence lineage, uncertainty,
non-judgmental language, declared influence uses, user inspection/correction/
disable/reset/archive/delete, neutral sparse behavior, deterministic rebuild and
no hosted profiling. It allows bounded patterns from non-sensitive local
evidence but forbids emotional labels, productivity scores, streak pressure,
hidden personality, silent material commitments and capability decay.

The approved v1 portfolio adds:

- Capability facts are user-approved and do not decay automatically.
- Context-quality scheduling can record typed placement/completion/friction
  observations but retains confirmation authority.
- Adaptive path comparison and Life Branch reconciliation produce non-mutating
  alternatives and explicit selection.
- Personal Context Registry owns explicit facts/purpose grants; learning cannot
  write them without user confirmation.
- Grounded proposals and Private Generative Runtime provide typed drafts and
  version/provenance boundaries.

These plans do not prove interaction usefulness or justify turning implicit
patterns on by default.

### Live source seams

Live code contains local-learning canon owners under Private Life Runtime,
Planning, Inspection and PrivacySecurity; recommendation explanations;
completion/reschedule/reminder/schedule observations; Goal/Path/Step/Proof/
History/Receipt repositories; capability proposal controls; and simulation/
reconciliation seams. It does not prove a complete observation-to-influence-to-
replan experience, cross-feature correction propagation or longitudinal quality.

### External evidence

Apple's current [machine-learning HIG](https://developer.apple.com/design/human-interface-guidelines/machine-learning)
warns that implicit feedback can be sensitive and emphasizes user control.
Apple's [Generative AI HIG](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
asks systems to show when corrections take effect, support retry/revert, disclose
limitations and keep people in control. These principles align with candidate
influences rather than invisible adaptation.

NIST's [AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
and [Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial)
emphasize lifecycle measurement, validity, privacy, bias and human configuration.
A local algorithm is not automatically safe: it can still encode biased labels,
feedback loops and incorrect causal conclusions.

### Observation, hypothesis, influence and decision

The platform must preserve four layers:

1. **Observation:** an owner-created fact such as accepted completion time,
   explicit reschedule reason, reminder action, user-approved Proof relation,
   explicit correction, proposal selection/rejection reason, context at an
   accepted placement, or source change. It is not an interpretation.
2. **Pattern hypothesis:** a deterministic summary under a versioned policy,
   such as “three explicitly labeled after-gym writing Steps were moved.” It
   carries counterevidence, sample/context bounds and uncertainty.
3. **Influence:** a user-confirmed or policy-allowed bounded input such as
   “prefer writing before work,” with declared consumer/purpose/expiry.
4. **Decision receipt:** a proposal or simulation explains whether/how the
   influence affected it. The consumer owns the decision and any mutation.

An outcome does not reveal a reason. A missed Step may reflect illness, bad data,
an external conflict, changed priorities or no longer wanting the Goal. Learning
must use explicit reason categories/questions and remain neutral when absent.

### Allowed initial observations and influences

Initial observation categories can include accepted planned/actual duration
range; explicit context label; completed/moved/skipped/canceled with optional
user reason; reminder acknowledged/snoozed/dismissed; explicit recommendation/
proposal correction; accepted plan delta; user-approved capability/Proof link;
and public source/current claim change. Calendar titles, location history,
contacts, health, communications, background app activity, keystrokes, passive
biometrics and free-form private content are excluded.

Initial influence kinds should remain narrow: duration range by Step shape;
task-size preference; user-confirmed time-context preference; interruption/
transition buffer; reminder tolerance; proof-prompt timing; preference for
reversible/smaller-first options; and exact “not this reason/candidate” memory.
They do not include motivation, grit, productivity, mood, intelligence,
personality, employability, health, relationship quality or success probability.

### Evidence and activation policy

Explicit corrections can create active influences immediately after a clear
preview. Implicit pattern hypotheses remain candidate-only and cannot influence
planning until the user confirms them in the initial product. This is the safe
evidence-dependent boundary: v1 interaction studies can later justify narrow
auto-active low-consequence influences, but that expansion requires Scope
revision and evaluation, not a configuration shortcut.

Candidate derivation is deterministic from exact retained events, context and
policy. It requires minimum independent occurrences, counterevidence display,
bounded time/context window and exclusion of data after opt-out/deletion. No
model or embedding derives influences. A generative model may phrase a validated
explanation but cannot select evidence or activate the influence.

### Decay, retention and contradiction

Capabilities never decay. Observations retain per category/purpose policy.
Pattern hypotheses can age, become contradicted or expire because they represent
recent context, not the person. Confirmed preferences remain until changed or
their user-set review/expiry. A new behavior pattern cannot silently override a
confirmed fact. Contradiction produces an inspectable candidate to review, not a
flip. Reset removes derived candidates/influences while preserving canonical
events and separately user-owned context/capabilities.

### Replanning triggers and consequences

Triggers include user correction; accepted Step outcome/reason; changed Context
Fact; new/removed Capability/Proof; source/current claim change; changed Goal
intent; path/placement conflict; and explicitly requested “reconsider.” The
system builds a dependency impact set, then asks the appropriate owner for a
side-effect-free new proposal/simulation. It does not run every engine after
every event or mutate accepted state.

Replan output is a typed delta: unchanged, move, resize, split, replace,
conditional, pause, add review, source-needed or no safe change. It shows trigger,
influence/evidence, affected objects, alternatives, tradeoffs, source/context
changes and what remains accepted. Material deltas require user confirmation;
notification/automation policies remain separate and cannot pressure action.

### Correction and feedback loops

“Not helpful” is not enough to learn why. Offer optional bounded reasons such as
wrong interpretation, wrong source, constraint missing, timing/context wrong,
too large/small, repeated, not interested, private/too personal, or other
user-authored correction. The user chooses whether the correction applies to
this draft, exact candidate, Step shape, context, consumer, Goal or everywhere.

Correction invalidates exact derived influences and drafts, rebuilds from
retained evidence, and shows the effect. It does not rewrite the original event
or falsely claim the system had always known. Rejection alone is local session/
candidate state unless the user explicitly saves a preference.

### Privacy, deletion and observability

Observations, hypotheses, influences, corrections, dependency graphs and
decisions are private. Nothing reaches Source Atlas/R2/telemetry/hosted AI.
Diagnostics contain policy/influence/observation category IDs, counts and reason
codes, never values, exact timestamps/locations, object names, prompt text or
feature vectors.

Users can disable collection by category, disable use by consumer/purpose,
archive, reset suggestions, reset all learned influences, delete observations or
corrections where policy permits, and clear decisions/drafts. Deletion performs
impact preview and resumable purge; canonical History truth may retain a
content-minimized event fact under its owner but can no longer be used if the
learning observation/link was deleted.

### Direct-user and longitudinal evidence

Evaluation must measure false pattern/confirmation burden, correction fidelity,
counterevidence visibility, explanation comprehension, suggestion usefulness,
replan stability, oscillation, overpersonalization, privacy/bias/dignity,
schedule/path outcomes and disable/reset trust. Longitudinal evidence is needed;
one simulator session cannot prove learning improves a person's life. Measure by
influence/consumer/context/policy version and report neutral/no-change outcomes.

## Evidence

Canon already establishes the right boundary. The missing product is disciplined
layering, initial activation policy, correction scope and owner-specific replan
orchestration. The evidence does not support default implicit personalization;
it supports deterministic candidate patterns with explicit confirmation and
complete user control.

## Alternatives

1. **Continuously trained personal model.** Powerful in theory, opaque,
   hard to delete/explain and unsupported by evidence. Reject.
2. **Rule-based auto-tuning from every action.** Deterministic but confuses
   behavior with intent and creates feedback loops. Reject.
3. **Never learn.** Predictable but wastes explicit correction and repeated
   confirmed context. Retain as a fully usable disabled mode.
4. **Evidence-linked candidate influences plus explicit activation.** Lower
   automation initially, but correctable and evidence-ready. Recommend.

## Unknowns and risks

- V1 scheduling/capability interaction data is required before any implicit
  influence becomes auto-active.
- Confirmation fatigue can nullify value; quiet thresholds/presentation need
  user evidence.
- Short histories and routine changes cause false patterns/oscillation.
- Structural constraints may look like preference; do not optimize around
  hardship without user confirmation or alternatives.
- Deleting derived data while retaining truthful canonical History needs clear
  content-minimized lineage.

No hard fork remains. Initial Scope can fully define explicit/candidate learning
and replan proposals while auto-active implicit learning stays excluded.

## Recommended direction

Implement a deterministic local observation ledger, pattern-candidate builder,
explicit influence activation, correction scope, influence inspector and
dependency-driven replan proposal coordinator. Keep learning off as a consumer
when disabled; keep implicit candidates non-influential until confirmed; never
let the service mutate product owners.

### Five compounding ruthless review passes

1. Completeness: separated layers, sources, activation, decay, correction,
   replan, deletion and longitudinal evaluation.
2. Connections: preserved context/capability/source/proposal/schedule/path/
   simulation/History owners and change/evaluation handoffs.
3. Privacy/authority: prohibited causal overreach, sensitive observation,
   behavior-as-consent, model derivation and silent mutations.
4. Feasibility: used deterministic local ledgers/policies and current live seams;
   isolated unsupported implicit activation.
5. Coherence/value: preserved learning-disabled core, neutral no-change, stable
   accepted state and option-preserving deltas.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.
