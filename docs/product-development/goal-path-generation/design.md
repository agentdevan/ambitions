+++
initiative = "goal-path-generation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

This design adds a local, deterministic route-composition pipeline for one
stable user-owned Goal outcome. It reads a frozen `GoalPlanningSnapshot`, an
optional verified public `RouteKnowledgePack`, and explicit user corrections;
produces one or more immutable `GeneratedRouteCandidate` values; and persists
only a private `RouteReviewDraft` when the user keeps or edits a proposal. No
generation or review operation creates or changes a Goal Path, Step, Proof,
Closure, placement, or Time fact.

One-route review is the generator's ownership boundary. The selected focus
candidate has typed stages, dependencies, route meanings, authority partitions,
sources, assumptions, unknowns, risks, Proof expectations, and resources. If
two candidates differ in a material route consequence, the generator packages
them for `adaptive-path-comparison` and does not label either best. Wording-only
or timeslot-only variants stay inside one review draft.

When the user finishes reviewing one proposal, the generator emits a
`GoalPathActivationProposal`. This is a non-canonical handoff envelope, not a
command. The existing Goal Path owner re-reads the Goal and current path,
revalidates sources, private facts, assumptions, dependencies, and confirmation
scope, then alone decides whether to create the first Goal Path or a new version
and which proposed nodes, Steps, and Proof expectations enter the accepted
scope. Scheduling remains a later Time-owner confirmation.

Authority-backed generation is enabled only for a domain corpus whose approved
pack contains current claims for the intended program/region. The existing
public-reference foundation's O*NET slice is not a NASA corpus. Until a separate
NASA/domain-corpus Research and Scope is approved and implemented, astronaut
candidacy must take the generic/manual degraded path and cannot pass the NASA-
backed acceptance case. A generic route is useful planning scaffolding but
contains no borrowed authority, eligibility judgment, or personalized gap claim.

## User flows

### Start generation from an adopted Goal

1. From a provisional, ready, or active Goal, choose `Build a route`. The entry
   shows the stable Goal identity and exact desired outcome.
2. The planner freezes the Goal revision, outcome fingerprint, current Goal Path
   revision if present, local confirmed facts, constraints, capability/Proof
   references, resources, policy revision, and installed public-pack manifest.
3. If the requested wording changes the desired outcome, stop and offer
   `Review as a new destination`; do not reinterpret it as a route edit.
4. Classify available knowledge before composition:
   `domainBacked`, `sourcedEnvelope`, `genericOnly`, or `blockedForClarification`.
   A missing or stale material authority can never select `domainBacked`.
5. Compose off-main and present the candidate as `Route proposal — not yet your
   Goal Path`. The Goal and any accepted path remain visible and unchanged.

### Review one route

1. The summary shows current or assumed starting position, qualitative posture,
   authority/freshness status, assumptions, unknowns, and next clarification.
2. The ordered list exposes each stage's kind and owner, dependencies, hard
   gates, prerequisites, optional strengthening, official alternatives,
   preparation, selection points, post-selection states, Proof expectations,
   resources, risks, and source facts.
3. Expand a source to see authority, exact supported claim, program/region,
   version/effective context, retrieval date, freshness, and uncertainty.
   Capability or Proof evidence appears in a separate `What you have told
   Ambitions` section and never marks a public gate satisfied.
4. Correct an explicit starting fact; accept, correct, or reject a safe
   assumption; edit user-controlled wording/preparation; omit optional content;
   or request one neutral clarification. Authority-owned gates and states are
   locked as sourced claims—editing their meaning removes the source and turns
   the item into an explicitly user-authored generic note or rejects the edit.
5. Choose `Keep for later`, `Regenerate`, `Use a generic outline`, `Build
   manually`, `Reject route`, or `Review for Goal Path`. Every action before the
   final handoff remains proposal-only.

### Degraded and blocked generation

- **Current public facts, missing private facts:** show a sourced route envelope
  and label the person's position `Unknown`. Ask at most the next necessary
  neutral clarification; do not state a gap, readiness, or eligibility result.
- **Stale, contradictory, unavailable, or inapplicable material authority:**
  name the unavailable claim and its consequence. Offer only `Generic starter
  outline` or `Build manually`. All domain source badges, gate assertions, and
  provider/program availability claims are absent from the generic result.
- **Destination, hard gate, authority, route identity, or protected-context
  ambiguity:** block domain-backed output and ask one necessary question. The
  user may decline and continue generically.
- **No safe structure:** preserve the Goal and current Goal Path, explain that a
  credible route could not be built, and offer manual planning or return.

### NASA validation flow

When and only when an approved, installed NASA corpus exists, the route review
must separately present current cited citizenship; qualifying degree and stated
alternatives; professional-experience or pilot-route alternatives; the long-
duration flight physical as an authority-controlled gate; leadership, teamwork,
and communication statements; named application-cycle availability;
competitive selection; candidate training; and later flight-assignment
eligibility. Selection, physical determination, training, and assignment are
never user-completable milestones or forecasts. Without that corpus, the same
Goal opens a generic/manual route that may say `Confirm current NASA requirements`
but may not display NASA-backed gates or claim AC-009 coverage.

### Multiple meaningful routes

1. Material-difference detection compares destination fingerprint, authority
   path, hard-gate alternative, ordered dependency graph, material resources,
   and user consequences. Titles, prose, ordering of equal items, and suggested
   timeslots are not material differences.
2. If several material candidates remain, show their names and why comparison
   is needed, with no primary/best label. The user may choose one focus candidate
   for continued one-route review or open adaptive path comparison.
3. The comparison handoff contains immutable candidate revisions, source and
   assumption snapshots, material-difference reasons, and the same Goal/outcome
   binding. It performs no Goal Path mutation.

### Hand off one reviewed proposal

1. `Review for Goal Path` shows included and omitted stages, proposed Goal Path
   nodes, proposed canonical Steps, proposed Proof expectations, unresolved
   assumptions, and the explicit statement `Nothing is scheduled here`.
2. The generator validates its review draft and creates a signed-in-process
   activation proposal bound to Goal revision, current Goal Path revision,
   candidate revision, input/source fingerprints, and confirmation scope.
3. The Goal Path owner re-reads every binding. A mismatch returns to the exact
   stale item; it cannot auto-refresh and accept within the old confirmation.
4. The Goal Path owner presents its own material confirmation and, if accepted,
   commits the first path or next version plus only the disclosed object scope.
   Optional placement is a separate Time-owner action.
5. The generator records only handoff outcome in its draft. The Goal Path
   Receipt/History remains the authoritative record of any accepted mutation.

### Resume, reject, and recover

- `Keep for later` persists the review draft with candidate, edits, omissions,
  assumptions, sources, review position, and focus; it creates no canonical path.
- Resume rechecks Goal, current path, public pack, Proof, capability, resource,
  constraint, and relevant Time revisions. Only affected stages are marked stale.
- Rejection or deletion of a review draft leaves Goal and current Goal Path
  untouched. Failure preserves the last valid draft and offers retry,
  correction, generic/manual continuation, or return.
- Cancellation during composition discards an unretained value result. Crash
  recovery restores retained drafts only and never treats an unfinished handoff
  as path activation.

## States and recovery

### Generation and review states

`RouteGenerationRun` is `capturingSnapshot`, `classifyingKnowledge`,
`needsClarification`, `composing`, `produced`, `materialAlternatives`,
`degradedGeneric`, `blocked`, `cancelled`, or `failed`. Runs are ephemeral and
side-effect-free.

`RouteReviewDraft` is `reviewable`, `editing`, `waitingForClarification`,
`stale`, `comparisonEligible`, `handoffReady`, `handedOff`, `rejected`, or
`archived`. Candidate posture is separately `provisional`, `sourceBounded`, or
`blocked`; authority status is separately `domainBacked`, `sourcedEnvelope`,
`genericOnly`, or `unavailable`. No single `confidence` or `ready` field may
collapse these axes or become a user score.

Each stage carries inclusion (`included`, `optionalOmitted`, `rejected`,
`stale`), control owner (`user`, `externalAuthority`, `informational`), semantic
kind, and fact state (`confirmedUserFact`, `unknown`, `assumption`,
`publicClaim`, `unsupported`). A gate can be current as a public claim while the
user's relation to it remains unknown.

### Recovery rules

- Snapshot or composition failure preserves the Goal and existing path and may
  retry from the same immutable inputs. A changed input starts a new run ID.
- Invalid/corrupt public packs are quarantined. Use only an installed bundled or
  last-verified applicable pack; otherwise degrade to generic/manual.
- Cancellation is cooperative. Late worker output is discarded unless its run
  ID still matches the current review session.
- A retained draft has a content revision and base-input fingerprint. Concurrent
  edits use compare-and-swap; conflicts keep both local draft revisions for
  review and never create parallel canonical paths.
- Before comparison or activation handoff, dependency cycles, orphan source IDs,
  unsupported claims, stale material facts, unresolved protected ambiguity, and
  changed Goal outcome are blocking. Optional stale preparation can be removed
  or refreshed; authority cannot be downgraded silently.
- Unknown activation outcome is resolved by querying the Goal Path owner using
  the handoff/idempotency key. The generator never retries a canonical command
  itself or assumes that a path exists.

## Architecture and data

### Components and authority

- **Goal planning snapshot builder:** reads canonical Goal, existing Goal Path,
  explicit local facts, capability/Proof/resource relationships, constraints,
  and relevant Time revision into one immutable private snapshot. It never
  writes or infers protected facts.
- **Public route-pack provider:** reads only verified finite public artifact IDs
  from the Source Atlas cache. It exposes manifest, authority, region/program,
  effective context, retrieval, freshness, contradiction, integrity, and
  applicability. It accepts no Goal text or private-derived key.
- **Knowledge classifier:** selects domain-backed, sourced-envelope, generic, or
  blocked behavior from typed facts. Unknown/inapplicable material authority
  fails closed.
- **Route composer:** a pure deterministic function of snapshot, applicable
  public pack, composition policy, clock, and injected seed. It produces typed
  candidates and audit lineage, not display prose as authority.
- **Route validator:** checks outcome identity, graph acyclicity, semantic-kind
  distinctions, source support, assumption policy, privacy, score/shame copy,
  and absence of canonical object IDs falsely presented as created.
- **Review draft repository:** persists candidate snapshots and user edits as
  private proposal state. It has no write access to Goal/Path/Step/Proof/Time
  stores.
- **One-route review projector:** creates the ordered semantic presentation and
  progressive disclosure from typed values.
- **Comparison handoff adapter:** emits immutable material alternatives to
  `adaptive-path-comparison`; it cannot choose or activate one.
- **Goal Path activation adapter:** emits one `GoalPathActivationProposal` to the
  existing Goal Path owner; that owner alone revalidates and commands mutation.

The existing `GoalPathCompilerModels`, `GoalPathCompilerService`, and
`PathIntelligenceProjector` are reusable seams, not sufficient contracts. Their
current scalar confidence and limited stage/requirement enums must not leak into
user authority. Implementation should version them or introduce bounded v2
types rather than reinterpret stored v1 values. `AlternatePathPortfolio` remains
a value-model comparison seam and cannot become a runtime store or path owner.

### Typed input and proposal data

`GoalPlanningSnapshotV1` contains Goal ID/revision, exact outcome and
fingerprint, Life Area, lifecycle, current Goal Path ID/revision if any,
user-confirmed fact references and revisions, separately typed capability,
Proof, credential, experience, resource, location, constraint and user-chosen
sensitive facts, relevant Time revision, policy revision, and snapshot hash.
Absence is encoded as `unknown`, never `false` or `unmet`.

`RouteKnowledgePackV1` contains public pack ID/version/hash, domain/program,
region, authoritative sources, typed claims, alternatives, dependency edges,
effective/retrieval/expiry/freshness facts, contradiction state, and pack limits.
Each claim has one authority owner and supported semantic meaning. Crosswalk or
label similarity is `informational`; it cannot establish substitution.

`GeneratedRouteCandidateV1` contains candidate ID/revision, Goal/outcome
binding, input/pack/policy fingerprints, authority status, ordered stages,
dependencies, branches, requirement facts, resources, assumptions, unknowns,
risks, Proof expectation proposals, material-difference keys, qualitative
posture/reasons, and deterministic audit entries. It contains no accepted Goal
Path/Step/Proof/placement IDs and no user-facing scalar score.

`RouteStageV1` uses explicit semantic kinds: current position, hard gate,
prerequisite, optional strengthening, common preparation, official alternative,
user-controlled work, intermediate-role option, authority decision, competitive
selection, post-selection training, continuing requirement, decision point,
review, and finish boundary. Each stage binds owner, inclusion, dependencies,
source claims, user-fact relation, assumption/unknown state, Proof expectation,
resources, and whether it may ever be proposed as a canonical Step.

`RouteReviewDraftV1` contains stable draft/candidate IDs, content and base
revisions, edits, omissions, accepted/rejected assumptions, corrections,
clarification results, source snapshots, review position/focus, stale markers,
comparison/handoff status, and creation/update times. Keeping a draft is durable
proposal persistence, not canonical Goal Path activation.

`GoalPathActivationProposalV1` contains one candidate revision, Goal and current
path expected revisions, included stage/dependency graph, proposed node roles,
proposed Step and Proof-expectation definitions, source/assumption/input hashes,
unresolved unknowns, confirmation-scope fingerprint, and handoff key. It contains
no placement commands and expires when a bound revision changes.

### Data flow and mutation boundary

```text
canonical Goal/private facts ──> immutable local snapshot ─┐
verified public pack cache ────────────────────────────────┼─> pure composer
explicit corrections/policy/seed ─────────────────────────┘       │
                                                                  v
                                                candidate value(s) + audit
                                                       │              │
                                          one-route review      comparison handoff
                                                       │
                                           activation proposal (no mutation)
                                                       │
                                                       v
                                  Goal Path owner revalidation + confirmation
                                                       │
                                              canonical version commit
                                                       │
                                         optional Time commit remains separate
```

Generation, draft save/edit, source refresh, comparison handoff, and activation
proposal creation cannot call canonical mutation APIs. The activation owner
revalidates Goal identity, source and fact freshness, assumptions, dependencies,
current path revision, and exact object scope. Accepted path mutation uses
`Command → Event → Projection → Receipt → Replay`, preserves one Goal Path
identity/version lineage, and leaves omitted proposals non-canonical.

### Persistence, migration, replay, and determinism

Review-draft storage is an additive versioned private store. Existing canonical
Goal Paths are never migrated into drafts. Existing v1 compiler/projector values
may decode through an explicit legacy adapter only as `genericOnly` unless every
new semantic/source invariant is present; the adapter cannot manufacture source
authority, substitutions, materiality, or user facts. Unknown enums, missing
hashes, and unresolved source IDs become needs-review or quarantine states.

Draft replay reconstructs review state from its immutable base candidate plus
ordered local edit events. Draft events/receipts never impersonate canonical
Goal Path History. Accepted path replay remains entirely with the Goal Path
owner and deterministically resolves the activation handoff key. Downgrade keeps
unknown drafts opaque/exportable and leaves accepted paths untouched. Store
migration is crash-safe, resumable, and verified before deleting old encodings.

Equivalent snapshot, verified pack, policy revision, clock, and seed produce
equivalent typed candidates, stable ordering, material-difference results, and
explanations. Display text can evolve only when its copy-policy revision is
recorded; it cannot alter semantic identity or confirmation scope. Source
updates create new candidate revisions and mark affected old content stale.

### Concurrency and resource behavior

Composition and validation run off-main over immutable `Sendable` values with
structured cancellation. Draft writes serialize per draft ID and use expected
revision. Source-pack replacement is atomic and readers pin a verified manifest.
The activation adapter is read-only; the Goal Path owner serializes mutation per
Goal/Path identity. No task holds locks across user interaction or owner handoff.

Candidate count, graph nodes/edges, pack size, clarification history, and audit
retention are bounded by calibrated implementation policy. Grooming must define
representative domain and long-goal fixtures, device/OS/build/tool, warm/cold
percentiles and maxima, memory/energy/storage measures, cancellation limits, and
regression thresholds; this design invents no numeric claim.

## Privacy and accessibility

Goal meaning, planning snapshots, local matches, capabilities, Proof, credentials,
experience, resources, constraints, protected facts, candidates, drafts,
corrections, rejections, assumptions, unknowns, review history, and handoffs are
private life graph data. They remain on device, work without account/network,
and are prohibited from Account, R2, Source Atlas, hosted AI, analytics,
telemetry, support upload, and server profiling. Public packs are fetched only
by finite allowlisted artifact ID independent of private intent. Joining a
public ID to a Goal makes the join private and ineligible for egress.

Protected facts are never inferred. A professional or sensitive unknown remains
unknown, and the user is not required to disclose it to receive a generic/manual
route. Public claims about protected gates may be shown only as external general
facts under current authority; no local matching output declares the user's
status. Classification/redaction failure blocks presentation or egress while
preserving local data. Redacted diagnostics store schema/policy/pack/correlation
IDs and failure categories, not outcomes, facts, claims, or route text.

The full route is an ordered semantic list. Its order is Goal/outcome and
proposal status; authority/freshness; starting position; assumptions/unknowns;
then stages with order, kind, owner, dependencies, source state, inclusion,
Proof expectation, and actions; followed by unresolved items, confirmation
scope, and recovery. A graph or timeline may supplement but never replace it.

Every reorder, edit, omit, restore, source inspection, assumption correction,
clarification, generic fallback, rejection, comparison handoff, and activation
handoff has a named non-gesture action. VoiceOver announces stage position and
dependency meaning. Voice Control, Switch Control, and Full Keyboard Access
reach the same controls. Dynamic Type converts columns/graphs to ordered cards;
increased contrast and non-color cues distinguish freshness, unknown, optional,
blocked, stale, and included states; Reduce Motion removes animated route
transitions without losing sequence. Focus returns to the edited stage, first
stale dependency, clarification field, handoff result, or recovery action.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| REQ-001 | Goal-bound snapshot and outcome fingerprint gate entry; changed outcomes hand off to destination adoption and provisional Goals survive every generator result. |
| REQ-002 | Pure composer, proposal-only types, isolated draft repository, and read-only handoff adapters prevent canonical Goal/Path/Step/Proof/Closure/Time mutation. |
| REQ-003 | `RouteStageV1`, typed facts, ownership, dependencies, assumptions, unknowns, resources, Proof proposals, risks, and ordered review provide the complete outline. |
| REQ-004 | Explicit stage/claim semantic kinds and validation preserve every hard-gate/preparation, prerequisite/optional, substitution/similarity, availability/theory, role/promotion, selection/milestone, training/preparation, and proposal/canonical distinction. |
| REQ-005 | Typed source claims and verified pack metadata bind authority, claim, region/program, version/effective context, retrieval, freshness, uncertainty, and crosswalk limits. |
| REQ-006 | Separately typed user facts and unknown state prevent capability/Proof overlap from becoming satisfaction, equivalency, eligibility, or professional authority. |
| REQ-007 | Assumption records show reason, affected stages, wrong-result consequence and correction; material/protected ambiguity blocks domain-backed output and asks one neutral question. |
| REQ-008 | Four-state knowledge classification and generic/manual fallback remove inherited authority when facts are stale, contradictory, unavailable, or inapplicable. |
| REQ-009 | Conditional NASA corpus contract encodes every named alternative and authority-controlled state; absent corpus forces generic/manual behavior and blocks NASA-backed acceptance. |
| REQ-010 | Review draft actions support source/assumption inspection, fact correction, edits, optional omission, rejection, deferral, generic/manual choice, and regeneration without source relabeling. |
| REQ-011 | Material-difference keys and comparison handoff prevent best-route selection while retaining one user-selected focus candidate as non-canonical. |
| REQ-012 | Expiring activation proposal plus Goal Path-owner revalidation and confirmation preserves one path/version owner and separate scheduling. |
| REQ-013 | No user-facing scalar, qualitative posture with reasons, copy validation, and no primary/best ordering prevent route or person scores from becoming authority. |
| REQ-014 | Local snapshot/composition/draft flow, finite public requests, protected-fact policy, and exhaustive egress denial preserve private offline operation. |
| REQ-015 | Versioned retained drafts, dependency-level stale markers, immutable pack pinning, cancellation, idempotency lookup, and recovery options preserve honest state. |
| REQ-016 | Ordered nonvisual route semantics, named controls, assistive-input parity, focus/announcement recovery, Dynamic Type, contrast, reduced motion, and non-color state preserve full meaning. |

## Verification design

### Automated semantic and boundary tests

- Unit/property tests cover deterministic snapshot composition, stable ordering,
  dependency-cycle rejection, typed semantic distinctions, unknown versus unmet,
  assumption correction, material-difference detection, score/shame copy denial,
  cancellation, and equivalent replay under permuted input.
- Mutation-boundary tests install spies for every Goal, Goal Path, Step, Proof,
  Closure, placement, and Time command. Generate, edit, omit, reject, keep,
  regenerate, compare, and create-handoff fixtures must issue zero canonical
  commands. Goal Path activation tests run in the owner suite, not the generator.
- Source tests cover valid current packs, older applicable packs, stale,
  contradictory, wrong-region/program, invalid signature/hash/schema, unknown
  source, crosswalk-only matches, quarantine, bundled fallback, and unavailable
  fallback. Generic candidates contain no copied domain claim or source badge.
- Private-fact matrices prove missing citizenship, education, experience,
  capability, credential, resource, location, constraint, health, and protected
  facts remain unknown and do not produce readiness or eligibility language.
- Review tests cover every edit/omit/restore/source/assumption/clarification/
  defer/reject/regenerate/manual action and prove a sourced gate cannot retain
  attribution after unsupported editing.
- Comparison tests distinguish material authority/dependency/resource/
  consequence alternatives from wording and timeslot variants and assert no
  best/primary/success ordering.
- Handoff contract tests change each bound revision independently and require
  Goal Path-owner rejection before mutation. Successful owner tests assert one
  stable path identity, immutable version lineage, disclosed node/Step/Proof
  scope, truthful Receipt/History/replay, prior-path rollback, and zero placement.

### NASA and degraded-path acceptance

- Before an approved NASA/domain corpus exists, an astronaut fixture must
  produce only generic/manual behavior; every NASA-backed assertion and AC-009
  evidence claim must fail. This is the authoritative current expected result.
- After that separate dependency is approved and implemented, corpus contract
  tests must bind every NASA claim to current primary authority and independently
  prove degree/experience alternatives, physical, application cycle, selection,
  training, and assignment semantics without user-completable or predictive
  conversion. A stale material claim returns to generic/manual behavior.
- Other domain packs cannot claim coverage from NASA success; each receives its
  own authority, usefulness, and degraded-path fixtures.

### Build, integration, migration, and performance evidence

- Run changed-scope format/lint/static analysis, secrets/privacy scanning,
  canon check, project generation check when `project.yml` changes, focused
  compiler/projector/repository/owner tests, and the relevant app build/test lane.
- Integration scenarios cover provisional Goal with no path, active Goal with a
  current version, comparison handoff, current public/missing private facts,
  stale authority, offline cached/bundled pack, no pack, correction/regeneration,
  background termination at every state, relaunch, and owner rejection.
- Migration fixtures decode legacy v1 compiler/projector results only as generic,
  unknown enums as needs-review, corrupted drafts as quarantined, interrupted
  store migration as resumable, downgrade as opaque/exportable, and accepted
  Goal Paths as byte/semantic unchanged.
- Performance calibration records candidate/stage/edge/source/draft scale,
  device/OS/build/tool, cold/warm generation and projection distributions,
  memory, energy, storage, cancellation latency, and pack verification. Grooming
  establishes numeric thresholds before a regression claim is enforced.

### Privacy, accessibility, and device evidence

- Executable egress attacks place each private field and derived join in URL,
  path, query, headers, body, artifact ID, cache key, log, telemetry, crash/support
  payload, Account, R2, Source Atlas, hosted AI, clipboard, Spotlight, widget,
  and external projection. Every prohibited destination must fail closed;
  public requests must remain within the finite allowlist.
- Direct VoiceOver, Voice Control, Switch Control, Full Keyboard Access,
  Dynamic Type, increased contrast, Differentiate Without Color, Reduce
  Transparency, and Reduce Motion testing covers normal, long, generic,
  clarification, blocked, stale, comparison, handoff, error, and resumed drafts
  on a physical supported iPhone. Automated audits supplement direct use.
- Verification reports source/build/unit/runtime/rendered/accessibility/privacy/
  performance/device proof separately; no successful model or simulator test is
  presented as factual route quality, assistive-technology, device, release, or
  broad-domain proof.

## Open decisions

No unresolved product decision blocks grooming. These technical selections
remain and may not weaken the authority or mutation boundaries:

- whether the v2 typed route model replaces `GoalCompiledPath` or is an adapter
  layer while legacy callers migrate;
- the concrete storage/event schema and compaction policy for review drafts and
  their non-canonical edit history;
- the in-process representation used to make activation proposals tamper-evident
  between generator and Goal Path owner without implying cryptographic or remote
  authority;
- the first approved domain-corpus schema after separate domain Research/Scope;
  NASA-backed verification remains blocked until that dependency exists; and
- calibrated graph/pack/draft scale and device performance thresholds.

If grooming cannot represent the typed route distinctions, a generic/manual
fallback without inherited authority, or a zero-mutation generator handoff, it
must return to Design or Scope rather than flatten meanings into the current v1
models.
