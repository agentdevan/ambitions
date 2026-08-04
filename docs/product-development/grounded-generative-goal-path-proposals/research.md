+++
initiative = "grounded-generative-goal-path-proposals"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Once a user chooses a destination, Ambitions must turn it into a credible living
route: prerequisites, preparation, milestones, decision points, alternate
routes, conditional opportunities, evidence moments and revisable next Steps.
The v1 Goal Path design defines a bounded, deterministic candidate composer and
canonical activation boundary. The eventual platform adds generative planning
so unfamiliar or long-horizon goals can be decomposed and explained with more
fidelity—without letting fluent output invent a ladder or bypass those owners.

The outcome is a grounded, inspectable, versioned Goal Path Proposal. It can
express a long route such as astronaut candidacy without pretending there is a
guaranteed promotion chain: qualifying education/experience are alternatives,
selection is authority-controlled, application windows are current facts, and
post-selection training is not a user-completable preselection milestone.

## Current truth

### Approved baseline and delta

The approved `goal-path-generation` Research/Scope/Design already establishes:

- one stable user-owned Goal outcome and one canonical Goal Path identity;
- non-canonical candidate routes with ordered stages, dependencies, requirement
  kinds, assumptions, risks, unknowns, resources and Proof expectations;
- hard-gate/preparation, prerequisite/optional, official-substitution/similarity,
  current-opening/theoretical-route, intermediate-option/required-promotion,
  competitive-selection/user-milestone and post-selection/preparation distinctions;
- no activation, Step, Proof or Time mutation during generation/review;
- comparison handoff for materially different same-outcome routes; and
- NASA astronaut candidacy as a demanding validation case.

The future initiative does not replace that contract. It supplies a production
generative composition lane over the now-planned public corpora, Relationship
Registry, Current Authority Registry and Private Generative Runtime. It also
adds route decomposition at scale, exact grounding manifests, regeneration
deltas and downstream resimulation hooks.

### Live repository seams

Live source has `GoalPathCompilerModels`, `GoalPathCompilerService`,
`PathIntelligenceModels`, `GoalResourceGraphModels`, alternate-path and lattice
value types, Goal/Path/Step/Proof owners, Source Atlas public planning bridges,
simulation and command boundaries. Tests preserve assumptions, uncertainty,
dependencies, blocked candidates and non-prediction copy. No evidence proves a
production generative model can construct source-grounded routes across domains
or that such results pass the canonical activation contract.

### External evidence

NASA's current [Become an Astronaut](https://www.nasa.gov/humans-in-space/astronauts/become-an-astronaut/)
page distinguishes citizenship, STEM master's or stated alternatives,
post-degree professional experience or the pilot-hours route, physical
qualification, leadership/teamwork/communication, competitive selection and
later candidate training. NASA's [Selection Program](https://www.nasa.gov/humans-in-space/astronauts/astronaut-selection-program/)
says the 2024 application cycle is closed, selections occur as needed, and ten
candidates were selected from more than 8,000 applicants. This is exactly why a
planner needs authority/time/alternative/selection semantics rather than a
single generated job ladder.

O*NET describes occupations, tasks, skills, preparation and related occupations,
not employer-specific promotion routes or personal qualification. CASE 1.1
exchanges competency frameworks and associations; association is not learner
mastery or credit. Education providers, credential issuers, licensing bodies
and employers retain their own requirements. These sources support route nodes
only for exact predicates and purpose profiles.

### Generative route architecture

The safe planning sequence is:

1. capture a stable Goal outcome, chosen destination/route form and exact public
   destination identity;
2. assemble a deterministic `RouteEvidenceGraph` from admitted public claims,
   relationship edges, current facts and separately confirmed private starting
   facts;
3. deterministically classify gates, alternatives, authority-controlled states
   and unknowns before the model runs;
4. expose the graph through a registered read-only generation task using
   ephemeral aliases;
5. let the model propose node grouping, ordering, explanatory framing,
   optional preparation and conditional branches only within supported facts;
6. validate every node/edge/type/source/condition and compare it with the input
   evidence graph; and
7. produce an immutable proposal revision and delta, never a canonical path.

The model cannot mint a prerequisite, public destination/credential/program,
equivalency, current opening, satisfaction claim or authority decision. It can
propose a generic user-controlled practice Step only when its semantic class is
allowed and labeled as generated—not source-required.

### Route model

A proposal graph needs:

- `start` and user-confirmed/unknown current-position facts;
- `authorityRequirement`, `userControlledPreparation`, `optionalStrengthening`,
  `officialAlternative`, `decisionPoint`, `competitiveSelection`,
  `authorityControlledOutcome`, `postSelectionTraining`, `reviewPoint`,
  `conditionalOpportunity`, `proofExpectation`, `recovery` and `closure` nodes;
- dependency edges with `requires`, `oneOf`, `allOf`, `supports`, `after`,
  `conditionalOn`, `notBefore`, `reviewBefore` and `sourceOnly` semantics;
- source/effective/freshness/rights/purpose bindings;
- private fact relation `confirmed`, `unknown`, `notIncluded`, `conflicting`,
  `userCorrected`, never inferred `met`;
- uncertainty, assumptions, consequences, reversibility and option preservation;
- material resource/constraint implications without scheduling; and
- proposal/task/model/prompt/schema/policy/corpus versions.

Graph depth and granularity should be progressive. The overview shows stages
and decision points; detail reveals nodes and evidence. The user may split,
combine, rename or omit generated user-controlled work, but editing a sourced
requirement removes its source claim rather than falsifying authority.

### Dynamic replanning and versioning

Regeneration must be a delta against a selected proposal or current accepted
path. It classifies: source changed, current opportunity expired, user fact
corrected, constraint changed, capability/Proof added, Step completion/failure,
user changed route strategy, or model/policy changed. The new proposal states
what remains, moves, becomes conditional, is added, or is no longer supported,
with reasons.

Completed accepted work and user-approved capabilities are not deleted from
history because a model finds a new route. Option-preserving progress is
highlighted but not overstated. Canonical path reconciliation and schedule
reflow remain downstream owners. Model/version changes alone cannot rewrite a
current accepted route.

### Grounding and failure

`RouteEvidenceGraph` is the factual ceiling. Every source-owned node/edge must
trace to an exact claim and use profile. Generated generic steps are visibly
unsourced planning suggestions and may not impersonate requirements. The
validator rejects invented IDs, missing source dependencies, cycles, impossible
one-of/all-of structures, authority decisions presented as user work, current
facts outside freshness, false gate satisfaction, copied private text in public
evidence and prohibited prediction language.

Sparse evidence yields a sourced route envelope, clarification, generic outline
or manual builder. Model unavailable uses the v1 deterministic composer. A route
can be useful while an application is closed; the conditional opportunity node
states that the future window is unknown.

### Privacy, correction, deletion and evaluation

Goal outcome, current position, capabilities/Proof, resources, constraints,
route edits and completion history are private. The model receives the smallest
registered capsule; public acquisition never receives it. Generated proposals
and deltas are private drafts. Delete removes them and their derived context/
explanations/feedback while leaving separately accepted canonical/history/public
objects under their owners.

Evaluation requires graph validity, source support, route semantic accuracy,
unknown preservation, appropriate granularity, useful alternatives, no hidden
prerequisite/prediction, capability continuity, correction/delta stability,
privacy/bias/dignity and direct-user comprehension/usefulness. Tests must include
simple hobbies, education routes, career transitions, regulated paths, sparse
sources, closed opportunities and the NASA case.

## Evidence

The approved v1 contract and live compiler provide a strong deterministic
foundation. Production corpora/relationships/current claims provide the missing
grounding substrate; the private runtime provides controlled generation. The
future work should therefore add a generative composer and evidence manifest,
not a new Goal/Path authority or a chatbot that writes canonical Steps.

## Alternatives

1. **Model generates an unconstrained checklist.** Fluent but factually unsafe,
   no dependency semantics or replay. Reject.
2. **Deterministic templates only.** Safe and valuable fallback, but limited
   decomposition/explanation across novel goals. Retain, not sole path.
3. **Model proposes over a closed evidence graph.** Supports expressive routes
   with exact validation and graceful gaps. Recommend.
4. **Continuously auto-regenerate accepted paths.** Appears adaptive but creates
   instability and bypasses confirmation. Reject; propose explicit deltas.

## Unknowns and risks

- Production route facts will remain uneven across domains; coverage must be
  claim-visible and never filled by model priors.
- Excessive graph detail can overwhelm; progressive disclosure needs user proof.
- “Common preparation” may encode privileged conventional routes; alternatives
  and resource assumptions need bias review.
- Professional/licensure/medical facts may require short freshness and direct
  authority recheck at activation/action time.
- A model can produce logically valid but strategically poor routes; direct-user
  usefulness and longitudinal evidence are required.

No hard fork remains. The generative lane can be built on the existing proposal
owner while retaining deterministic/manual fallback and source-needed states.

## Recommended direction

Extend the approved Goal Path candidate architecture with a closed
`RouteEvidenceGraph`, registered generative graph composer, exact semantic/source
validator, progressive proposal renderer and versioned delta generator. Keep
activation, comparison, scheduling and external action separate and explicit.

### Five compounding ruthless review passes

1. Completeness: added graph vocabulary, generative boundary, delta semantics,
   failure, privacy, deletion and evaluation.
2. Connections: anchored v1 compiler, corpora, relationships, current facts,
   runtime, capability, comparison, path activation and scheduling owners.
3. Authority: prohibited invented gates/satisfaction, automatic regeneration,
   canonical mutation and private public-source queries.
4. Feasibility: reused live GoalPath/compiler/path models and deterministic
   fallback rather than introducing a second path system.
5. Coherence: preserved long-horizon aspirations, conditional openings,
   completed progress and option-preserving alternatives.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.
