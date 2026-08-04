+++
initiative = "multi-goal-portfolio-simulation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

People pursue more than one Goal at once. Career preparation, education, health,
caregiving, creative work and relationships draw on the same time, money,
attention, equipment, places and opportunity windows. Optimizing each Goal in
isolation can produce a portfolio that is impossible or punishing. Ambitions
needs to reveal shared constraints, collisions, synergies and reversible choices
without ranking the person's life or pretending to predict outcomes.

The outcome is a side-effect-free Portfolio Scenario Set over existing user-
selected Goals and accepted/draft paths. It shows what is preserved, delayed,
conditional, conflicted or unsupported under explicit assumption sets. The user
can compare a small number of meaningfully different allocations, adjust inputs
and hand selected changes to each existing owner for confirmation. No simulation
changes a Goal, Path, Step or Time.

## Current truth

### Approved portfolio baseline

- Goal/Goal Path/Step/Time have separate canonical owners and receipts.
- Context-quality scheduling can assess placements for one accepted workload.
- Adaptive path comparison compares routes for one stable Goal outcome.
- Life Branch reconciliation v1 handles bounded complete alternatives when
  several already-real objects must change together.
- Personal Context Registry supplies explicit purpose-controlled constraints;
  Capability Continuity supplies reusable progress without universal scores.
- Current Authority supplies time-limited opportunity dependencies.
- Adaptive Learning can request non-mutating owner replans.

These are approved designs, not runtime evidence. Portfolio simulation must be
enabled only after its conformance harness and the required v1 owner/runtime
evidence pass; the architecture does not assume those implementations exist.

### Live source seams

The tree contains Goal portfolios, multi-path lattice/value models, Step impact
simulation, time block graphs, protected time/placement policies, Goal resource
graphs, Life Branch/reconciliation types, capability/Proof references and
side-effect-free simulation canon. It does not prove complete cross-Goal resource
accounting, scenario semantics, atomic snapshots or direct-user usefulness.

### Portfolio versus route versus branch

- **Route comparison:** different ways to reach one stable Goal.
- **Portfolio simulation:** alternative allocations/assumption sets across
  several selected Goals; proposals remain owner-specific.
- **Life Branch:** a complete executable prospective bundle across existing
  objects, with commit order, reversibility and external boundaries.

A portfolio scenario can reveal that a Life Branch is needed but cannot become
one automatically. It may include “pause Goal B” as a simulated consequence,
but pause is committed only by the Goal owner after explicit confirmation.

### Inputs and shared resource model

The simulation consumes immutable revisions of user-selected Goals/current Path
or candidate Path, accepted/planned Steps, protected/fixed Time, explicit
Personal Context, approved Capability/Proof, current opportunity conditions and
resource envelopes. It never selects Goals from hidden behavior.

Resource dimensions remain heterogeneous:

- time windows, duration ranges, transitions, recovery and context quality;
- money by currency/period/one-time versus recurring and uncertainty;
- place/travel/remote/on-site dependencies;
- equipment, space, connectivity and shared availability;
- user-stated energy/focus/social/privacy contexts;
- caregiving/coordination/relationship commitments without person scoring;
- public opportunity/application/cohort deadlines and authority decisions;
- prerequisites, proof moments and capability reuse; and
- reversibility, lead time, cancellation cost and option preservation.

The simulator cannot add unlike dimensions into one score. A constraint
violation is dimension-level and source/owner-bound. Unknown never becomes zero
capacity; ranges remain ranges. Shared resources cannot be double-counted.

### Scenario semantics

Scenarios are explicit assumption sets, not forecasts. Useful initial families:

1. **Current commitments:** no proposed priority/strategy change; expose conflicts.
2. **Protect one named Goal:** user chooses which Goal to protect; show effects.
3. **Protect must-respect constraints:** preserve protected obligations and show
   the smaller feasible set/unknowns.
4. **Reversible bridge:** emphasize actions supporting multiple routes or keeping
   options open, with exact overlap evidence.
5. **Lower near-term load:** reduce/split/defer proposed work while keeping
   outcomes unchanged.
6. **User-authored:** explicit priority/tradeoff assumptions.

The engine does not generate “optimal,” “balanced,” “most successful,” or
“recommended life” without the user selecting a posture. It may order scenarios
stably, group dominated-invalid variants and state why one violates explicit
constraints. It cannot infer that one Goal matters less.

### Computation and model boundary

Resource/accounting, dependency, conflict and consequence calculations are
deterministic. A generative model may propose a bounded scenario framing or
plain-language explanation through the Private Generative Runtime, using only
validated semantic data; it cannot change inputs, invent capacity, choose a
winner or produce commands. The simulation result remains useful without a
model.

Each scenario contains per-Goal deltas, shared resource ledgers, constraint
results, dependencies, current-source conditions, Capability/Proof continuity,
assumptions, unknowns, conflicts, reversibility and sensitivity statements.
Sensitivity varies one assumption/range at a time and reports changed decisions,
not probabilities.

### Fairness and dignity

Limited money/time/access is reality, not lack of ambition. The system should
surface lower-cost, slower, remote, bridge, pause or source-needed alternatives
without assuming hardship is permanent or suggesting that privileged routes are
better. Caregiving, disability/access needs and relationship commitments must
not be converted to penalties. Every exclusion must cite an explicit constraint
or unknown and be correctable.

### Lifecycle and handoff

Scenario sets are private immutable drafts bound to all owner revisions. A
selected scenario yields an `OwnerChangeProposalBundle`: proposed Goal/Path/Step/
Time changes, order/dependencies, assumptions and stale conditions. It has no
commands. Each owner revalidates and presents confirmation. If changes are
interdependent and cannot safely be committed independently, the bundle goes to
Generalized Life Branch, not ad hoc multi-owner writes.

Changes to a source, opportunity, context, capability, path or accepted object
mark exact scenarios stale. Recompute is explicit. Delete removes scenario,
assumptions, derived ledgers/explanations/feedback; canonical objects remain.

### Evidence dependency

Before user-facing activation, implementation must demonstrate:

- v1 scheduling and adaptive comparison produce stable typed simulations;
- Life Branch v1 enforces non-mutation and reconciliation boundaries;
- Personal Context/Capability owner inputs have usable correction semantics;
- representative multi-Goal fixtures do not double-count or hide conflicts; and
- users understand scenarios as alternatives, not predictions/instructions.

These are rollout gates within the design, not a reason to invent evidence or
leave ownership unresolved.

## Evidence

The existing architecture supports immutable owner snapshots and bounded
simulation. The gap is an explicit cross-Goal resource ledger and scenario
semantics. A deterministic engine is necessary because generated explanations
cannot safely own accounting. Evidence dependency argues for a conformance-
first implementation and unavailable production mode until upstream runtime
proof, not for a monolithic optimization service.

## Alternatives

1. **Global priority/utility score.** Easy to optimize, but collapses values and
   creates a universal person score. Reject.
2. **Schedule every Goal independently.** Produces cross-Goal collisions and
   hides resource constraints. Reject.
3. **Ask a model for a balanced life plan.** Uninspectable, biased and
   non-replayable. Reject.
4. **Deterministic resource/consequence scenarios with user-chosen postures.**
   More explicit but safe and correctable. Recommend.

## Unknowns and risks

- Direct-user evidence is needed to calibrate scenario count and vocabulary.
- Monetary/relationship/access constraints are sensitive and can produce
  stigmatizing alternatives if copy/evaluation is weak.
- Resource estimates may be sparse; the result must remain partial/unknown.
- Cross-Goal interactions can become combinatorial; strict scenario/goal/horizon
  budgets and user-selected scope are required.
- Upstream runtime evidence remains a production activation dependency.

No hard design fork remains. Implement conformance-first and leave production
mode unavailable until named upstream/evaluation gates pass.

## Recommended direction

Create a deterministic `PortfolioSimulationEngine` over an immutable
`PortfolioSnapshot`, heterogeneous `SharedResourceLedger` and explicit
`PortfolioScenarioAssumptions`. Generate a small non-ranked scenario set,
dimension-level explanations/sensitivity, and a command-free owner-change
bundle. Escalate inseparable changes to Life Branch reconciliation.

### Five compounding ruthless review passes

1. Completeness: defined input/resource/scenario/result/lifecycle/evidence gates.
2. Connections: separated route, scheduling, context, capability, current,
   learning, owner confirmation and Life Branch.
3. Privacy/authority: rejected hidden Goal selection, global scoring, model
   accounting, automatic pause/reflow and stigmatizing inference.
4. Feasibility: bounded combinatorics, deterministic core, conformance-first
   rollout and immutable owner revisions.
5. Coherence/value: added option-preserving bridge, sensitivity and explicit
   unknown/no-change scenarios.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.
