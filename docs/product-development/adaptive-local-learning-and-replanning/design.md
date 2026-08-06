+++
initiative = "adaptive-local-learning-and-replanning"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add a protected `LocalLearningRuntime` with separate immutable stores for
`LearningObservation`, `PatternHypothesis`, `PlanningInfluence` and
`LearningCorrection`. Owner-specific adapters emit allowlisted observations.
A deterministic incremental policy engine builds candidates; explicit preview/
confirm creates active influences. Capability-scoped consumers receive minimal
influence views. A dependency planner asks existing owners for non-mutating
replan simulations and assembles `AdaptiveReplanProposal` deltas.

## User flows

- **Explicit correction:** user selects Wrong timing -> after-gym context. A
  preview shows scope and consumers. Confirm creates an active influence and
  offers a side-effect-free recompute; accepted work stays unchanged.
- **Pattern candidate:** at a calm review moment, “You moved three similar Steps
  from after the gym. Prefer another context?” shows evidence/counterevidence,
  uncertainty and Not now/Not this/Confirm. Until confirm, it affects nothing.
- **Why this changed:** a result lists active influence, evidence categories,
  exact effect and override. User can correct/disable it and recompute.
- **Replan:** an explicit trigger yields a delta grouped by no change, move,
  resize, split, replace, conditional, pause, review or source-needed. User keeps
  current state or enters the owning confirmation flow.
- **Controls/delete:** category/consumer toggles, resets and delete show impact,
  purge progress and neutral post-delete behavior.

## States and recovery

Observation: `accepted`, `excluded`, `superseded`, `deleted`. Hypothesis:
`candidate`, `insufficient`, `contradicted`, `expired`, `confirmed`, `dismissed`,
`archived`, `deleted`. Influence: `activeExplicit`, `activeConfirmedPattern`,
`overridden`, `conflicted`, `disabled`, `expired`, `archived`, `deleted`.
Replan: `impacting`, `simulating`, `ready`, `noChange`, `partial`, `stale`,
`canceled`, `failed`, `superseded`.

An ingestion actor deduplicates owner-event IDs. A policy actor serializes
incremental/rebuild generations. A replan actor captures observation/influence/
owner/source/context/policy revisions; stale results discard. No plan simulation
auto-retries after crash or commits. Delete/reset journals resume idempotently.

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
- Experience authority: Task 8 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Modules

Add under `Native/Ambitions/Core/LocalRuntimeOS/LocalLearning/`:

- observation/event/category/retention models, adapters and ledger;
- hypothesis/evidence/counterevidence/uncertainty models;
- deterministic policy registry, incremental aggregator and rebuild service;
- influence kind/scope/purpose/state models and repository;
- confirmation/correction/dismissal/reset/archive/delete commands/receipts;
- consumer capability registry and `PlanningInfluenceReadClient`;
- influence explanation/use receipt projector;
- dependency index/impact planner;
- owner-specific replan request clients and proposal/delta assembler;
- migration/replay/invalidation/reset/purge;
- privacy/security/copy validators and diagnostics.

Initial owner adapters are exact: accepted Step completion/reschedule/cancel with
optional reason, reminder action, Context/Capability/Proof revision, explicit
proposal correction/selection reason, accepted plan delta and public source/
current claim change. Each adapter maps an owner event to a minimal category
record; no raw object content is copied.

### Deterministic policy

Policy artifacts declare allowed observations, grouping keys, independent-event
definition, minimum/counterevidence rules, time/context bounds, candidate copy,
allowed influence, purposes, expiry and evaluation version. Stable event order
is causal owner sequence then ID. The engine emits a hypothesis only; no
candidate-to-active transition exists except a mutation command confirmed by
the user. Generative runtime may paraphrase after semantic validation but is not
part of derivation.

### Consumer and replan interfaces

```
influences(consumer, purpose, objectRevision, contextView) -> InfluenceView
recordUse(InfluenceUseDraft, resultRevision) -> InfluenceUseReceipt
impact(trigger) -> LearningImpactSet
simulate(ownerRequest, capturedRevisions) -> OwnerReplanCandidate
```

Consumers cannot enumerate observations/hypotheses, write influences or infer
missing values. `AdaptiveReplanProposal` holds typed owner candidates and deltas,
not authorized commands. Each owner regenerates its preview on user selection.

### Persistence, migration and deletion

All learning data is protected private state. Evidence links reference owner
events by opaque ID/revision/category; free-form values stay with owners. Existing
learning-like settings migrate only when exact meaning/purpose maps; otherwise
remain user settings or legacy disabled. Rebuild never mines historic content
outside admitted adapters.

Reset suggestions deletes candidates/dismissal memory but not active explicit
preferences. Reset influences removes derived/confirmed pattern influences but
preserves separately owned Context/Capability. Scoped purge removes permitted
observations, hypotheses, influences, corrections, use receipts, indices,
proposals, explanations, exports and continuity copies. Content-free tombstones
prevent replay; canonical History may remain but is excluded from new ingestion.

## Privacy and accessibility

No network or generative-provider dependency exists. Diagnostics use category/
policy/reason/count and randomized local correlation; no values/names/times/
places/object content. Learning toggles default to explicit corrections and
candidate generation only; generic/manual planning works with all off.

Evidence/counterevidence is a navigable ordered list. Uncertainty uses plain
language, never confidence theater. Deltas and scopes have text equivalents and
consistent actions. VoiceOver, Voice Control, Switch Control, keyboard, largest
Dynamic Type, Reduced Motion, RTL, non-color states and focus restoration cover
confirmation, Not now/Not this, correction, disable/reset/delete and replan.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Owner adapters and minimal observation ledger |
| REQ-002 | Deterministic hypothesis/evidence/counterevidence policy |
| REQ-003 | Command-only candidate activation |
| REQ-004 | Bounded enums/copy validator/no score |
| REQ-005 | Opaque read-only Capability/Context references |
| REQ-006 | Capability-scoped view and use receipts |
| REQ-007 | Scoped correction records and rebuild invalidation |
| REQ-008 | Dependency index/impact planner and owner request clients |
| REQ-009 | Non-authoritative AdaptiveReplanProposal |
| REQ-010 | Neutral empty/disabled/corrupt fallback |
| REQ-011 | Separate retention/expiry and no Capability mutation |
| REQ-012 | Dedicated lifecycle commands/previews/receipts |
| REQ-013 | Deterministic rebuild and journaled purge/tombstones |
| REQ-014 | Payload-free diagnostics |
| REQ-015 | Event validation, actors, budgets and stale discard |
| REQ-016 | Evaluation metadata per policy/influence/consumer |
| REQ-017 | Ordered calm accessible controls/deltas |

## Verification design

- Owner adapter acceptance/exclusion/deduplication and private-content canaries.
- Deterministic order-independent hypothesis/counterevidence/expiry fixtures.
- Mutation spies proving candidates inactive and replans non-mutating.
- Correction scope, influence use, contradiction, disable/reset/archive/delete.
- Concurrency/policy change/clock rollback/replay/migration/fault purge.
- Security/copy corpus for labels, scores, injection, cycles and resource bounds.
- Longitudinal simulation plus direct-user studies for false patterns, burden,
  correction, oscillation, dignity and usefulness—clearly not real-life proof.
- Accessibility/physical-device performance, storage, energy and rebuild evidence.

## Open decisions

None. Auto-active implicit learning is structurally absent from this design and
requires a future approved Scope, not a flag change.

Review verdict: **PASS** after two reconciliation rounds. Review made activation
command-only, raw owner content non-copied, reset scopes distinct and replanning
an owner simulation handoff. Devan delegated approval; Design approved
2026-08-04.
