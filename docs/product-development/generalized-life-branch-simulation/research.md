+++
initiative = "generalized-life-branch-simulation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Some changes cannot be understood one object at a time. Accepting a new role,
returning to school, moving, taking on caregiving, recovering from disruption or
changing a major Goal may alter several Goals, Paths, Steps, protected Time,
Proof expectations, resources and future external commitments together. The user
needs to see complete alternatives and consequences before any material change,
then apply only the branch they explicitly choose with reliable recovery.

The outcome is a generalized, side-effect-free Life Branch simulation and a
typed multi-owner reconciliation plan. A branch is a complete prospective set
of local owner changes under explicit assumptions—not an alternate copy of the
person, a prediction, or a model-controlled future. External effects remain
separate previewed operations and cannot be hidden inside a branch commit.

## Current truth

### Approved v1 baseline and future delta

The approved `life-branch-reconciliation` portfolio defines bounded complete
alternatives across already-real canonical objects, explicit selection,
side-effect-free comparison and reconciliation. Goal Path comparison handles one
outcome; destination adoption handles outcome changes; scheduling handles Time;
each typed owner retains authority.

Multi-Goal Portfolio Simulation adds cross-Goal resource/consequence scenarios
and escalates inseparable proposal bundles here. External Action Orchestration
will own authorized integrations. Generalized Life Branch must add a formal
operation/dependency/reversibility/compensation model and local multi-owner
transaction protocol without becoming a universal write owner.

These are approved documents, not runtime proof. Production activation depends
on v1 Life Branch and multi-Goal conformance/user evidence.

### Live source seams

Live source contains Life Branch and reconciliation value models, event/command/
projection/receipt/replay patterns, Goal/Path/Step/Time owners, local runtime
transactional storage, conflict/degraded states, undo/recovery, external outbox
and step-impact simulation seams. It does not prove one generalized coordinator
can obtain consistent snapshots, validate multi-owner plans, commit compatible
local operations, recover partial failure, preserve undo or coordinate external
effects without violating owner authority.

### What makes a branch complete

A Life Branch is appropriate only when:

- at least two canonical owner domains or several inseparably dependent objects
  change;
- the alternative has a coherent end state, not merely a list of suggestions;
- changed and intentionally unchanged objects are named;
- shared constraints/resources and external preconditions are accounted for;
- operation ordering and failure consequences are defined; and
- the user can compare it with keeping the current branch.

A branch has an immutable baseline snapshot, explicit assumptions, proposed
owner commands (unconfirmed), dependency/precondition graph, consequence set,
reversibility class, compensation/rollback plan, external-effect plan, unknowns,
source/current/context bindings, and final consistency invariants.

### Reversibility vocabulary

- `localAtomicReversible`: all local changes can commit in one supported atomic
  boundary and have an owner-approved inverse/undo window.
- `localCompensatable`: commits may span owner boundaries but every completed
  local operation has an idempotent compensation restoring a coherent state.
- `externallyPending`: local state may prepare an authorized external operation,
  but branch success excludes its execution.
- `externallyCompensatable`: a later external effect may have a provider-defined
  cancellation/undo, never guaranteed by the branch.
- `externallyIrreversible`: sending, applying, purchasing, publishing or other
  effect cannot be reliably undone; it requires a separate last-moment preview
  and confirmation under External Action owner.
- `unknownReversibility`: blocks branch execution.

“Undo” must never imply an external system was reversed when only local state
was. Compensation is a new explicit action with its own possible failure, not
time travel.

### Multi-owner authority

The branch coordinator may ask typed owners to:

1. snapshot an exact revision;
2. validate a proposed owner-local delta;
3. return preconditions, conflicts, prepared command token and compensation;
4. prepare under a branch transaction ID;
5. commit or abort; and
6. reconcile/replay/compensate using receipts.

It cannot construct raw repository writes. Owners remain responsible for their
invariants and reject unsupported commands. When all affected owners share a
transactional local store, the runtime may commit prepared events atomically.
Otherwise an idempotent local saga uses dependency order and compensation, with
visible partial/recovery state. No owner is reported committed before its receipt.

### External effects

External data may be read as current evidence. A branch may contain an
`ExternalActionIntent` describing a future action and prerequisite, but selection
does not execute, authenticate, contact, apply, enroll, purchase, reserve,
publish or delete remotely. After local branch commit, External Action owner
revalidates current source/provider state, shows exact payload/effect and asks
confirmation. If external execution fails, accepted local changes remain
truthfully separate and reconciliation offers retry/compensate/change plan.

This order avoids claiming cross-system atomicity. For cases where local change
should depend on external success, the branch can remain `awaitingExternalResult`
with a prepared, expiring local plan; final local commit still requires current
validation and a clearly defined policy. The design must not lock private state
indefinitely or auto-replay consent.

### Simulation and generative boundary

Branch construction/accounting/validation are deterministic. A generative model
may propose a branch framing or explanations over a closed set of validated
owner deltas through Private Generative Runtime. It cannot mint objects,
commands, preconditions, compensation, external actions or choose a branch.

Simulation shows qualitative assumptions/consequences and bounded sensitivity,
never probability or future-self certainty. “Keep current” is always a branch.
Unknown material precondition/reversibility blocks execution but may remain a
simulation. Changed evidence invalidates only dependent operations.

### Selection, commit and recovery

Selection first creates a branch reconciliation preview with before/after by
owner, operation order, unchanged protections, external separation, reversibility
and failure paths. Confirmation binds exact baseline/plan/owner/source/policy and
an expiry. The coordinator prepares all owners, aborts if any reject/stale, then
uses atomic local commit where proven or saga order otherwise.

Receipts form one branch receipt plus owner receipts and compensation/recovery
links. Relaunch resumes from the journal without duplicating commands. If partial
local commit cannot immediately compensate, the product enters a visible
`reconciliationRequired` state with safe unaffected operations and explicit
recovery; it never declares success or silently rolls forward.

### Privacy, deletion and history

Branch simulations, assumptions, sensitive consequences, prepared commands and
external intents are private. Public acquisition receives no branch/user data.
Diagnostics use branch/owner/operation/reason IDs and states, not payloads.

Deleting an uncommitted branch removes all draft/snapshot/explanation/prepared-
token bytes. A committed branch is History/Receipts; deletion/redaction follows
those owners and cannot pretend the actions never occurred. Any provider secrets
or external payloads belong only to External Action owner, never a branch.

### Evidence dependency and evaluation

Production activation requires v1 Life Branch runtime proof, Portfolio
Simulation conformance, owner prepare/commit/abort/compensate conformance, and
direct-user comprehension of branch versus prediction, local undo versus
external compensation, partial failure and confirmation. Evaluation covers
snapshot consistency, complete consequence/accounting, owner invariants,
reversibility truth, privacy/security, bias/dignity, recovery and usefulness.

## Evidence

Existing owner/replay patterns make a typed coordinator feasible, but only if it
uses owner-prepared commands and admits that not every local or external change
is atomic/reversible. The product needs branch-level receipts and recovery, not a
new repository that bypasses owners. External separation is essential to honest
status and consent.

## Alternatives

1. **Copy the entire life graph and swap it.** Simplifies branching but breaks
   owner identities, merges, histories and external truth. Reject.
2. **Best-effort sequential writes.** Easy, but partial failure becomes hidden
   corruption. Reject.
3. **Demand universal atomicity.** Impossible across external systems and some
   owners. Reject.
4. **Owner-prepared atomic-local-or-saga reconciliation with external separation.**
   Complex but truthful and recoverable. Recommend.

## Unknowns and risks

- Actual storage/owner transaction boundaries require implementation proof.
- Compensation may itself fail; recovery states and support diagnostics must be
  first-class.
- Large branches are cognitively/algorithmically complex; strict affected-owner/
  operation/horizon budgets are necessary.
- Consequence narratives can overstate certainty or encode bias.
- External systems can change between preview and action; revalidation is always
  required and cross-system atomicity must never be claimed.

No hard fork remains. The protocol explicitly supports atomic-local where proven
and saga/recovery otherwise; production stays gated until evidence passes.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Surfaces/Goals/LifeBranch/`.
- Evidence and unknowns: Repository audit identifies Task 9 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Build a generalized `LifeBranchCoordinator` over owner-provided snapshots,
validated prepared commands and compensation contracts. Simulate complete
branches deterministically, always include keep-current, classify reversibility,
commit locally through atomic/saga protocols with receipts, and hand external
intents to a separately confirmed action owner.

### Five compounding ruthless review passes

1. Completeness: added branch qualification, complete model, reversibility,
   owner protocol, external separation, recovery, deletion and evaluation.
2. Connections: separated route/portfolio/destination/schedule/owner/external/
   History responsibilities.
3. Authority/failure: prohibited raw writes, model commands, fake atomicity,
   misleading undo and consent replay.
4. Feasibility: supported proven atomic local stores or idempotent saga rather
   than assuming one universal transaction.
5. Coherence/value: kept current branch, partial recovery and unchanged objects
   visible; bounded branch size and unknown blockers.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.
