+++
initiative = "life-branch-reconciliation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Sometimes one changed fact cannot be resolved by editing one Step, selecting a
different Goal Path route, or moving a timeslot. A job loss, relocation,
caregiving obligation, health constraint explicitly supplied by the user,
school admission decision, major capacity change, or deliberate life-direction
change may affect several Goals, accepted Paths, protected Time, Proof rules,
resources, recipients, and external commitments together. The user needs to
understand complete ways forward without Ambitions leaving the graph in a
half-changed state.

Life Branch reconciliation is the highest-order alternative mechanism in this
initiative family. It compares **complete, cross-object semantic deltas over
already-real canonical state**. It is not a recommendation candidate, a dormant
aspiration, a second Goal, an alternate Goal Path, a copied private-life graph,
or a visual scenario tree. It should appear only when ordinary object-owned
edits cannot honestly express the complete consequence of changed reality.

The product problem is to make such alternatives understandable and safe. Each
candidate must say what it protects, changes, sacrifices, assumes, leaves
unresolved, and requires from the user. Comparison remains simulation. Only an
explicitly selected, currently valid candidate may proceed to a coordinated
local commit, with external or recipient-owned effects still separated from
local success.

## Current truth

This Research inspected `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, current canon, live source and
tests, and the related initiative-family Research at
`docs/product-development/adaptive-skills-and-pathways/research.md`. No focused
Life Branch implementation or test files were found in the live source tree.
That absence is significant: current normative documents establish design
intent and a future contract, not implementation completeness.

Canon defines Life Branch in unusually precise terms:

- `OBJ-LIFE-BRANCH-IDENTITY-001` requires stable branch identity, source or
  parent, base graph revision, bounded horizon, explicit trigger, policy
  revision, certificate, status, and lineage.
- `OBJ-LIFE-BRANCH-DELTA-001` requires typed, ordered, revision-aware operations
  against existing canonical object identities. Each operation declares human
  consequence, protected invariants, dependencies, authority owner,
  materiality, and reversibility. Duplicate object authority, silent copies,
  untyped payloads, and timeslot-only alternatives are invalid.
- `OBJ-LIFE-BRANCH-LINEAGE-001` preserves selection, promotion,
  supersession, rollback, certificate, decision basis, confirmation, Receipt,
  History, replay, and recovery lineage. Later facts may invalidate a branch
  but cannot rewrite why it was accepted.
- `OBJ-LIFE-BRANCH-AUTHORITY-001` partitions user-owned, recipient-owned,
  joint, and external effects. Only user-owned effects can enter the local
  mutation sequence; other effects remain proposals or post-commit intents.
- The Life Branch completeness contract allows at most one active branch over
  one canonical personal-state graph. It explicitly says the branch is not a
  second Goal, Goal Path, Step, placement, or private graph.
- `SYSTEM-CEBR-ACTIVE-BRANCH-001` defines the active branch as a revision-bound
  semantic delta. Candidate branches remain non-durable until an owning command
  commits one.
- `SYSTEM-CEBR-CERTIFICATE-001` requires a current immutable viability
  certificate before a branch can be presented as feasible or promoted.
- `SYSTEM-CEBR-IMPACT-CONE-001` limits recertification to declared dependents
  of a changed revision rather than rebuilding or rewriting unrelated state.
- `SYSTEM-CEBR-CANDIDATE-MATERIALIZATION-001` allows bounded complete
  candidates from policy-distinct correction sets, but suppresses timeslot-only
  and consequence-equivalent candidates. A generative model cannot certify,
  authorize, or commit one.
- `SYSTEM-CEBR-PROMOTION-001` requires revalidation, explicit user
  confirmation, one parent semantic transaction, canonical mutation lineage,
  and separate external effects.
- `OBJ-BRANCH-CERTIFICATE-GATE-001` permits only a current `valid` certificate
  to gate active or promotable status. Fragile and blocked results may explain
  repairs but cannot be presented as success; stale or superseded certificates
  authorize nothing.
- `JOURNEY-LIFE-BRANCH-RECONCILIATION` defines review, selection, promotion,
  and humane recovery. The user may inspect, edit, reject all, keep a conflict,
  choose a lighter correction, or defer. No hidden model score chooses.

These documents are normative but their own proof ceilings explicitly disclaim
current source implementation, runtime, performance, accessibility, device,
and release proof.

The broader repository offers component seams but not Life Branch itself:

- Goal, Goal Path, Step, Proof, Schedule Placement, Receipt, History, Closure,
  and Recovery Segment have stable identities and object-owned commands.
- `SYSTEM-RUNTIME-SIMULATION-001` establishes deterministic, local,
  side-effect-free simulation before commit.
- scheduling and schedule-reflow canon already support non-durable consequence
  previews, protected boundaries, grouped adjustment, explicit confirmation,
  rollback, and separate external writes.
- `AlternatePathPortfolio.swift` and `MultiPathLattice.swift` compare supplied
  route candidates and block hidden mutation. Their scope is path-selection
  value modeling, not complete cross-object branch reconciliation.
- transaction, command, Receipt, replay, rollback, privacy, and inspection
  infrastructure exists elsewhere in the runtime. Presence of those owners
  does not prove they can atomically promote a Life Branch.

No `LifeBranch`, branch-certificate, impact-cone, correction-set, or
branch-promotion implementation/test file was found under `Native/Ambitions`
or `Native/AmbitionsTests` by targeted filename and symbol searches. Research
therefore cannot claim that the canonical design is executable today.

## Evidence

### Product and canon evidence

- Current object laws already handle ordinary edits. A missed Step can use
  Recovery Segment; a route change toward the same outcome can create a Goal
  Path version; one placement conflict can use schedule reflow; a changed
  destination can preserve the old Goal and adopt a new one. Life Branch adds
  value only when the safe correction is intrinsically cross-object.
- The one-active-branch law prevents a scenario workspace from becoming a
  second private graph or alternate life state that silently diverges from
  canonical truth.
- Typed deltas preserve existing owners. Life Branch coordinates consequences;
  it does not absorb Goal, Path, Step, Time, Proof, or external authority.
- Certificate status is an operational gate, not a user score or model
  confidence. Unknowns remain explicit instead of being converted into a
  probability.
- Candidate materialization is simulation. Promotion is mutation. This mirrors
  the broader Ambitions rule that preview, comparison, editing, and cancellation
  must preserve the last honest state until confirmation and revalidation.
- Authority partition is essential for scenarios involving another person,
  institution, employer, calendar, or provider. Local success cannot claim
  that an external party accepted, scheduled, admitted, hired, licensed, or
  completed anything.

### Repository evidence and proof ceiling

- Canon identifies exact target owner families for future work:
  `Core/Domain/`, runtime Planning, Scheduling, Commands, Transactions,
  Inspection, existing root surfaces, and Quality. These paths are ownership
  guidance, not evidence of current Life Branch code.
- Existing command/transaction/persistence laws require one local causal chain,
  idempotency, Receipt/History, replay, rollback, and external-after-local
  behavior. A branch implementation would need to compose these without
  inventing parallel mutation authority.
- Existing path-comparison tests are useful negative evidence. They demonstrate
  that route candidates can be explicit-selection-gated and non-mutating, but
  they operate on path portfolios with supplied metadata and do not construct
  typed cross-object deltas or certificates.
- Existing schedule-reflow and recovery journeys prove that Ambitions already
  has less-powerful mechanisms. A future Scope must state why a Life Branch is
  necessary rather than treating the canonical noun itself as sufficient user
  value.

### Worked threshold scenario: confirmed relocation with coupled obligations

Research chooses one concrete scenario for validation. The user confirms a
permanent relocation on a known date in order to assume a protected caregiving
commitment. Before that trigger, the canonical graph contains:

- an active Goal to complete an in-person credential at a named institution,
  with one accepted Goal Path, accepted course-related Steps and placements,
  and an external tuition or enrollment obligation;
- an active Goal to remain in an onsite job through the credential, with its
  own Goal Path, fixed work commitments, and placements;
- protected Time that must become available for caregiving after the move; and
- user-confirmed rules that the move and caregiving time are fixed, that an
  unavailable in-person program must not remain represented as executable, and
  that a chosen alternative must apply all of its local changes or none.

The trigger alone does not authorize any mutation. Current provider and
employer facts are separate external claims: whether the program permits
remote continuation or transfer and whether the role can move must be current
and inspectable. If either is unknown, a candidate relying on it is fragile or
blocked rather than feasible.

The ordinary mechanisms are tested first:

1. **Time reflow is insufficient** when no placement can satisfy physical
   location, fixed caregiving, program attendance, and onsite work constraints.
   Moving timeslots cannot make a location-bound provider or job available.
2. **One Goal Path revision is insufficient** because changing the education
   route does not resolve the separate employment Goal, protected Time, or the
   external enrollment effect; changing the employment route leaves the
   education route and placements unresolved.
3. **Independent Goal edits are insufficient for the selected all-or-none
   decision** when the user chooses a complete alternative such as “move,
   defer the current program, transition away from the current onsite role,
   protect caregiving time, and retain separately labeled provider/employer
   follow-ups.” Committing only some local changes would violate the user's
   declared confirmation scope and leave the graph asserting a plan the user
   rejected.
4. **A Life Branch is unnecessary** if current facts reveal a simpler honest
   repair—for example, the same job is officially remote and only placements
   need reflow, or the credential Goal alone can take a valid new Goal Path
   while every other accepted object remains coherent.

Under the coupled facts above, Life Branch becomes necessary only after the
simpler checks fail. It can compare complete policy-distinct corrections, such
as preserving the credential by delaying an otherwise flexible move, or
honoring the fixed move by deferring the current program and changing the work
route. In the stated scenario the move is fixed, so a “delay the move” option
must be shown as blocked or omitted rather than presented as viable. A
destination provider application, employer agreement, tuition cancellation,
or recipient response remains an external or recipient-owned proposal; branch
promotion cannot claim any of those outcomes.

The necessity test is therefore not merely “several objects change.” Life
Branch is justified when one confirmed changed-reality trigger creates a
revision-bound conflict whose acceptable correction requires coordinated
material changes across multiple canonical owners, the user binds those
changes as one confirmation scope, and no independently committable Goal, Goal
Path, Recovery Segment, or Time correction preserves the declared invariants.
If any simpler owner can restore an honest graph, that owner remains the right
mechanism.

### Scenarios that do not meet the threshold

- choosing among several routes to the same Goal before one is accepted;
- holding or rejecting an unselected career recommendation;
- changing one Goal Path stage or Step order;
- moving one occurrence to another timeslot;
- displaying several future-self narratives;
- creating a second copy of all Goals and Time for experimentation; or
- asking a model to predict which future life will succeed.

### Evidence and proof ceiling for the worked scenario

The worked scenario is a consistency proof against current normative object,
Goal Path, schedule-reflow, Life Branch, certificate, authority, transaction,
and recovery contracts. Targeted source searches also found the existing Goal
Path candidate and Time-reflow seams but no `LifeBranch`, viability-certificate,
impact-cone, correction-set, or branch-promotion implementation or focused
tests. That supports the boundary between existing simpler mechanisms and the
unimplemented cross-object contract.

It does **not** prove that users encounter this relocation pattern often, that
the proposed comparison is understandable, that candidate sets can be bounded
at product scale, or that atomic promotion, rollback, privacy, accessibility,
performance, persistence, replay, and device behavior work. The scenario also
uses declared provider/employer conditions rather than a live external case;
those conditions must be fresh and authority-bound in any real review. The
evidence ceiling is Research-level conditional necessity, not implementation,
runtime, usability, or release proof.

## Alternatives

### 1. Use ordinary object-owned edits in sequence

For many changes, this is the simplest and safest experience. Goal, Path, Step,
and Time owners can each preview and commit their own mutation. The weakness is
that a genuinely coupled change can leave an impossible intermediate state or
force the user to reconstruct dependencies manually.

### 2. Offer a grouped preview but commit independent commands

This improves understanding while retaining existing owners. However, partial
failure or a changed revision between commands can leave a mixed result unless
the group has a real parent transaction and rollback semantics. It may be
adequate for loosely coupled edits but not a complete branch promotion.

### 3. Use a typed Life Branch delta with viability certificate

This matches current canon for a genuinely cross-object alternative. It can
bind exact revisions, protected invariants, authority, capacity, assumptions,
and rollback before one parent local transaction. It is expensive in product
complexity, implementation, verification, and explanation, so it should be
reserved for situations where simpler owners cannot preserve coherence.

### 4. Copy the private graph into multiple scenario worlds

This seems flexible but creates duplicate object authority, synchronization,
deletion, privacy, storage, and identity problems. It also contradicts canon's
definition of a branch as a typed delta rather than a second graph.

### 5. Let a generative system propose and certify the best branch

Generative help could suggest explanatory text or candidate conditions, but it
cannot evaluate deterministic viability, partition authority, or commit state.
Hidden ranking would convert unknowns and value tradeoffs into false model
authority.

### 6. Treat every path or scheduling fork as a Life Branch

This would make ordinary adaptation bureaucratic and produce
consequence-equivalent branches. Canon explicitly suppresses timeslot-only
alternatives. Goal Path and schedule-reflow should remain the normal owners.

## Unknowns and risks

- **Demonstrated frequency and comprehension:** the relocation scenario
  establishes conditional product need, but no current user evidence shows how
  often the threshold occurs or whether users understand complete correction
  sets. Scope should stay bounded to the worked scenario rather than infer a
  general scenario platform.
- **Threshold false positives:** the selected test rejects "more than one
  object changes" as sufficient, but candidate generation could still escalate
  a repair that Goal, Goal Path, Recovery Segment, or Time can own. The simpler-
  owner checks and reason for escalation must remain inspectable.
- **Completeness:** an incomplete candidate can appear attractive by omitting a
  cost, affected Goal, external obligation, or protected boundary. Certificate
  construction must fail closed without making every unknown look like a user
  error.
- **Policy ownership:** candidate correction sets are derived under current
  policy, but which user rules and object policies may relax—and who may relax
  them—needs exact ownership.
- **Certificate language:** users need plain consequences, not an internal
  "certificate" spectacle. The operational gate must remain inspectable
  without turning the interface into diagnostics.
- **Staleness:** any dependent Goal, Step, schedule, source, authority, or policy
  revision can stale a candidate during review. Revalidation must be bounded
  and preserve the user's review context.
- **Atomicity:** one parent semantic transaction still composes multiple object
  owners. Crash, conflict, cancellation, rollback, and external-after-local
  behavior need proof at every phase.
- **Rollback limits:** subsequent work, external effects, or another person's
  decision may make exact reversal unsafe. Recovery may require compensation
  rather than pretending the branch never committed.
- **External authority:** provider, employer, school, recipient, or calendar
  actions remain proposals or outbox intents. Branch `active` status must never
  imply external completion.
- **Sensitive inputs:** changed-reality scenarios may contain health, family,
  finances, location, relationships, or legal context. All branch facts and
  derived candidates remain private local graph data; public enrichment cannot
  receive personalized context.
- **Overreach:** an always-visible life-simulation feature could encourage
  obsessive optimization, false prediction, or a dashboard of hypothetical
  selves. The experience should solve a concrete conflict and then recede.
- **Candidate explosion:** combinatorial correction sets can overwhelm
  computation and review. Canon requires bounded deterministic materialization,
  but no product-scale limit or prioritization rule is yet justified.
- **Value conflicts:** some options sacrifice different user priorities that
  cannot be objectively ranked. Ambitions must explain, not adjudicate, those
  tradeoffs.
- **Accessibility:** every complete alternative needs ordered semantic detail
  for affected objects, protected/sacrificed conditions, authority,
  consequence, confirmation, and recovery. A branching graph visualization
  cannot carry exclusive meaning.
- **Implementation absence:** no live Life Branch, certificate, impact-cone, or
  promotion tests were found. This is a high proof burden across runtime,
  persistence, privacy, accessibility, performance, and device behavior.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Surfaces/Goals/LifeBranchReviewView.swift`.
- Evidence and unknowns: Repository audit identifies Task 7 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Preserve Life Branch as a **guarded reconciliation mechanism for complete,
policy-distinct, cross-object alternatives after a concrete change invalidates
the current personal-state branch**. Do not use it for destination discovery,
same-outcome route comparison, ordinary recovery, or timeslot choice.

The strongest research direction is the worked **confirmed relocation with
coupled education, work, and caregiving obligations** case. Scope should define
the plain-language review of that one changed-reality conflict and use the
selected necessity test: first exhaust honest Goal, Goal Path, Recovery Segment,
and Time repairs; escalate only when a complete correction is materially cross-
owner and all-or-none under the user's confirmation.

Candidate creation should remain local deterministic simulation, with
generative assistance limited to non-authoritative proposals or explanations.
Only a current valid certificate, explicit selection, authority review, and
revalidation may approach promotion. The next Scope should not begin as a
general scenario engine, assume that normative canon equals implementation, or
commit architecture before the user-visible comparison and safe recovery
behavior are resolved.
