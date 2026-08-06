+++
initiative = "grounded-generative-goal-path-proposals"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Extend the approved Goal Path proposal system with a deterministic
`RouteEvidenceGraphAssembler`, registered alias-only `GenerativeRouteComposer`,
ordered `RouteProposalValidationPipeline` and `RouteProposalDeltaEngine`. Reuse
the v1 candidate/review repository and activation/comparison handoffs. Models
receive graph aliases and allowed generic-step slots, never authority to create
facts or canonical objects.

## User flows

1. User chooses **Build a path** for an adopted destination.
2. Overview shows exact Goal/outcome, public route authority/coverage and private
   context categories; unknown sensitive facts may remain undisclosed.
3. Evidence graph assembles locally. Material ambiguity asks one neutral
   clarification; sparse sources offer sourced envelope or manual/v1 composer.
4. User starts the disclosed generation task and can cancel.
5. Validated proposal opens at stage overview with current/assumed start,
   branches, gates, preparation, decisions, opportunities, Proof expectations,
   resources, unknowns and sources.
6. Drill-down shows ordered list-equivalent dependencies and exact authority.
7. User edits only user-controlled work, corrects facts/assumptions, rejects,
   saves, regenerates or asks to compare materially different candidates.
8. Choosing one proposal creates an activation preview input; Goal Path owner
   revalidates. Step/Proof activation and Time placement are shown as separate
   scopes and require confirmation.

On regeneration, a delta view groups retained, moved, made conditional, added
and unsupported nodes; completed accepted work remains in History. The user may
keep the current path, accept selected changes downstream, or save the draft.

## States and recovery

Evidence: `assembling`, `domainBacked`, `sourcedEnvelope`, `genericOnly`,
`needsClarification`, `sourceNeeded`, `invalid`. Proposal: `generating`,
`validating`, `ready`, `partial`, `comparisonRequired`, `superseded`, `rejected`,
`archived`, `deleted`. Delta: `notCompared`, `ready`, `stale`, `conflicted`.

One proposal actor captures Goal/outcome/path, corpus, relationship, current,
capability/Proof/resource/constraint, task/model/prompt/schema/policy and locale
revisions. All callbacks recheck them. Source refresh or private correction
marks exact nodes stale; generation is not restarted automatically. Journals
make save/archive/delete/purge idempotent. A crash cannot resume a model session
or activation implicitly.

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

### Exact modules

Under `Native/Ambitions/Core/Domain/GoalPathGeneration/` add/extend:

- `RouteEvidenceGraphModels.swift`, assembler and semantic classifier;
- public route/current/relationship and private fact/capability/resource adapters;
- `RouteNodeKind`, `RouteEdgeKind`, fact relation, authority/source and
  opportunity models;
- generative task input/output alias models and composer;
- identity/source/graph/authority/private-fact/prohibited-claim validators;
- progressive graph/detail projector and editable work policy;
- candidate repository migration, coordinator, invalidation and purge;
- material-difference classifier/comparison handoff;
- `RouteProposalDeltaModels.swift` and delta engine;
- activation input builder and owner revalidation adapter.

Reuse existing `GoalPathCompilerService` as deterministic/manual fallback and
existing Goal Path candidate types where their semantics match. Add schema
versions rather than parallel types when a new semantic is necessary.

### Evidence graph and model contract

Graph nodes contain stable evidence IDs, semantic kind, owner, public claim or
private fact relation, source/purpose/freshness, conditions, resources,
reversibility, uncertainty and allowed model operations. Edges are explicit
typed logic. Aliases are ephemeral, sorted and bound to graph hash.

The model output may select/sequence/group aliases, select only registered edge
relations already allowed by the graph, add explanatory reason codes, choose
from allowed generic practice templates, and propose review points. It cannot
emit source IDs, arbitrary requirements, `met/eligible`, canonical IDs,
placements, commands, dates/prices not in the graph or prediction scores.

Validation checks alias membership; all-of/one-of/condition correctness;
acyclic executable portions; selection/outcome authority; source/freshness;
private unknown preservation; generated-step bounds; coverage; duplicates;
size/depth; and prohibited claims. Invalid affected subgraphs are removed only
when a coherent partial route remains; otherwise the proposal fails.

### Proposal, delta and handoffs

`GroundedGoalPathProposal` stores immutable revision, graph/source hashes,
validated stage/node/edge semantics, assumptions, unknowns, risks, resources,
Proof proposals, explanation tokens and full runtime provenance. It does not
store raw model output or copied source/private bodies.

`RouteProposalDeltaEngine` compares semantic stable keys and exact dependencies,
not prose/order alone. It records trigger, old/new bindings, retained/moved/
conditional/added/unsupported, effect on completed/accepted nodes, and reason.

Comparison handoff contains immutable proposal revisions/difference keys and no
winner. Activation input contains selected revision, expected current Goal/Path,
proposed Path nodes/Step/Proof definitions, unresolved unknowns and confirmation
fingerprint. It contains no Time placement or authorized command. The owner
rebuilds the preview from current truth.

### Persistence, migration and deletion

Proposal/delta data is protected private draft state. Public evidence stays with
its registries; canonical Goal/Path/Step/Proof/Time/History remain separate.
Legacy v1 candidates migrate only when semantic/source fields map losslessly;
otherwise remain readable legacy drafts needing review. Clear/delete removes
proposal/delta/context/explanation/feedback/evidence snapshots. Accepted objects
and public cache are unaffected; deletion-terminal replay cannot restore drafts.

## Privacy and accessibility

Private adapters run locally and never influence public request IDs. The model
context uses minimal typed aliases and private fact categories/values allowed by
the registered task/mode. Logs and evaluation retain reason/version/hash data,
not Goal text, Proof bodies or sensitive facts. Correction is explicit and not
automatic learning.

Stage and dependency meaning has a complete ordered list view. Each node announces
kind, owner, dependency, source/current state, private fact relation, option,
risk and available action. Delta groups use text and headings, not color or
motion. Largest Dynamic Type, VoiceOver, Voice Control, Switch Control, keyboard,
Reduced Motion, RTL, focus restoration and non-shaming copy are required.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Goal/outcome fingerprint and destination-adoption return |
| REQ-002 | Deterministic evidence graph and exact adapters |
| REQ-003 | Typed node/edge enums and semantic classifier |
| REQ-004 | Separate private fact relation with no satisfaction inference |
| REQ-005 | Alias-only private-runtime composer and validator |
| REQ-006 | Exact evidence inspection and attribution-loss on edit |
| REQ-007 | Complete bounded graph plus progressive projector |
| REQ-008 | Conditional opportunity state and narrow invalidation |
| REQ-009 | Editable-work policy and revisioned review actions |
| REQ-010 | Material-difference classifier and no-winner handoff |
| REQ-011 | Non-authoritative activation input and owner revalidation |
| REQ-012 | Semantic delta engine preserving completed/history state |
| REQ-013 | v1/manual/sourced-envelope failure paths |
| REQ-014 | Captured revisions, repository/journals/migration/purge |
| REQ-015 | Local adapters, runtime firewall and graph security limits |
| REQ-016 | Claim-bound evaluation metadata |
| REQ-017 | Ordered accessible overview/detail/delta projections |

## Verification design

- NASA, regulated career, education-alternative, hobby, closed-opportunity and
  sparse/generic golden graphs.
- Alias/ID/source/current/private fact/graph logic/generated-step/prohibited-copy
  validators plus fuzz/property tests for cycles, bombs and injection.
- Deterministic/manual parity/fallback and no-command mutation spies.
- Revision/concurrency/source-change/cancel/retry/migration/archive/delete/purge/
  comparison/activation fault tests.
- Semantic delta tests preserve completion and explain every change.
- Slice evaluation/user evidence for correctness, route usefulness, granularity,
  alternatives, privacy/bias/dignity, correction and delta comprehension.
- Accessibility and physical-device performance/resource proof at representative
  graph scales and model/device versions.

## Open decisions

None. Unsupported domain details remain source-needed/generic/manual rather than
being generated from model memory.

Review verdict: **PASS** after two reconciliation rounds. Review made model
operations alias-limited, reused v1 types/fallback, defined semantic deltas and
prevented automatic regeneration/activation. Devan delegated approval; Design
approved 2026-08-04.
