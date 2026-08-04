+++
initiative = "adaptive-skills-and-pathways"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Completing a Goal changes more than its completion state. The user may have
learned a hard skill, practiced a soft skill, earned proof, discovered a better
working method, completed a prerequisite, or made progress that remains useful
even if the original destination changes. Ambitions should preserve and reuse
that progress instead of making every new direction begin from zero.

The initiating idea is an adaptive skills-and-pathways system with four related
jobs:

1. Recognize soft and hard skills developed through completed Goals, milestones,
   Steps, and accepted Proof.
2. Use those capabilities to explain and recommend plausible career, hobby, or
   education paths.
3. Generate and simulate the milestones, prerequisites, intermediate roles,
   selection points, and—where a current authoritative source supports them—
   roles or promotions that could connect the user's current position to an
   end Goal.
4. Fit resulting Steps into the user's actual life while recognizing that equal
   amounts of open time may have different value. For example, an hour after
   the gym may support different work than an hour before leaving for work.

The astronaut example makes the desired continuity concrete. "Become an
astronaut" is the outcome, while qualifications, education, experience,
applications, competitive selection, training, and any source-supported role
options form a revisable path. If the
user changes direction midway, Ambitions should identify which evidence-linked
capabilities and completed prerequisites still count, then offer alternative
destinations that reuse them. It should explain both the reusable progress and
the remaining gaps.

This is broader than a career tracker, career-advancement program, or
LinkedIn-style profile. The intended value is private life continuity: real
activity creates evidence; evidence improves future choices; and changing
one's mind does not erase honest progress. Career may be a strong first
example, but the same product problem applies to education, hobbies, creative
work, health-supporting routines, and other user-chosen directions.

## Current truth

This Research used baseline main SHA: `40894e92c61de55841c31fd797fd5ae39625c5dc`,
together with current canon,
source, tests, and prior audit evidence. External sources were reviewed on
2026-08-03. Source presence and test fixtures are reported as implementation
evidence only; they do not establish shipped or release-ready behavior.

Canon strongly supports the intended outcome and guardrails, but it does not
yet resolve this initiative's complete product behavior:

- `MISSION-ORIGIN-OUTCOME-001` says Ambitions turns intent into an
  understandable path, reality-fit schedule, Steps, Proof, review, and Life
  Capital including durable skills and knowledge that improve future choice.
- `MISSION-FUNCTION-001` requires contextual Goal Paths, scheduled next
  actions, adaptive schedule change, Proof-backed progress, and user learning.
  `MISSION-NAMING-001` identifies generative goal pathing with schedule reflow
  as the core product capability, while `MISSION-INTEGRATION-001` requires
  learning to carry forward across the full orchestration loop.
- `OBJ-HISTORY-EVENT-IDENTITY-001` says previous progress should transfer as
  context, Proof, skill, resource knowledge, or capability knowledge when a
  Goal changes or pivots.
- `OBJ-GOAL-IDENTITY-001` and `OBJ-GOAL-PATH-IDENTITY-001` already define a
  Goal as a stable outcome with a living route and a Goal Path as a versioned,
  inspectable, adaptive route. Goal Path nodes can represent Steps, Proof,
  recovery, schedule changes, adaptive changes, and decision points.
- `SYSTEM-RUNTIME-SIMULATION-001` requires simulation to be deterministic,
  local, inspectable, bounded, and side-effect-free until commit.
- `SYSTEM-SCHEDULING-CAPACITY-001` and `SYSTEM-SCHEDULING-REFLOW-001`
  already require fit to consider availability, energy, context, Step shape,
  transitions, Protected time, Fixed time, and downstream consequences.
- `SYSTEM-LEARNING-LOCAL-001` permits capability inference from local,
  non-sensitive evidence only when uncertainty, evidence linkage, inspection,
  correction, disablement, and non-judgmental language are preserved.
  `SYSTEM-LEARNING-CONTROL-001` additionally requires Life Capital changes to
  resimulate affected paths and says capabilities must not decay automatically.
- `OBJ-LIFE-CAPITAL-EDITABILITY-001` already recognizes inspectable,
  user-editable Life Capital records, and `OBJ-PROOF-IDENTITY-001` permits
  user-approved Proof to link to Life Capital context and carry useful
  experience forward. Proof works on the honor system and must never be graded
  by strength.
- Life Capital is intentionally broader than skills. The Constitution includes
  durable knowledge, relationships, health, resources, confidence, skills, and
  other compounding capacity. Capability continuity can be a focused first
  slice, but a future-path recommendation must not pretend skills alone explain
  what is desirable or feasible, and it must not infer sensitive Life Capital
  from behavior.
- Goal suggestions may already be made from local non-sensitive evidence, but
  they must expose rationale, uncertainty, confirmation, correction, and
  disablement before creation (`OBJ-GOAL-AUTOMATION-LADDER-001` and
  `SYSTEM-LEARNING-GOAL-SUGGESTION-001`).

The constitutional boundaries are equally important. Ambitions must remain
local-first, inspectable, non-shaming, and user-controlled. It must not become a
social-performance surface, cloud-backed private-life profiler, hidden
personality model, or generic life score. It may suggest, simulate, or schedule
within granted authority, but it cannot force a Goal, route, deadline,
interpretation, or material change (`MISSION-HARD-RED-001`,
`MISSION-ORIGIN-STRUCTURE-001`, `MISSION-ANTI-METRICS-001`, and
`CONTROL-FORCE-NOTHING-001`).

The live implementation contains useful but incomplete primitives:

- `NorthStarModels.swift` can preserve a dormant, identity-level direction such
  as "Become an Astronaut" without creating a Goal. Its reference hooks can
  connect that direction to later Goals, paths, milestones, Steps, Proof, and
  decisions. This supplies a candidate pre-commitment seam between an
  aspiration and an adopted route; it is source evidence, not proof of a
  finished or canonically complete experience.
- Goal Path compilation represents candidate routes, stages, dependencies,
  requirements, assumptions, risks, branches, and confidence in
  `GoalPathCompilerModels.swift` and `GoalPathCompilerService.swift`.
- Source Atlas already has structural public-reference models for capability
  graphs, nodes and edges, level ladders, role/path overlays, requirements,
  alternative paths, and plan skeletons. `SourceAtlasCapabilityPathComposer`
  combines those structures with local context to choose a source path and
  exposes an internal scalar `score`. These models are a substantial path-
  knowledge seam, but they do not define the private user's capability
  identity or derive one from completed work. The score ranks composer inputs;
  it is not authority for a user-facing capability, compatibility,
  employability, success, or "best path" score.
  Its current placement is also nonconforming source evidence rather than a
  reusable owner: code under `Core/LocalRuntimeOS/SourceAtlas/` consumes private
  `goalID`, `LifeContextRuntimeProjection`, and local influence signals even
  though Source Atlas canon assigns public delivery there and reserves the
  private join for local `Planning/`. Future work must isolate or relocate that
  private matching boundary instead of inheriting the current placement.
- `PathIntelligenceModels.swift`, `AlternatePathPortfolio.swift`, and
  `MultiPathLatticeTests.swift` already distinguish current, alternate,
  fallback, paused, future, exploration, and North Star paths; preserve
  transferable Proof; compare tradeoffs; label future-self scenarios as
  scenarios rather than predictions; and block selection until the user
  explicitly chooses. These value models do not yet discover destinations or
  calculate capability reuse.
- `GoalResourceGraphModels.swift` already separates required and optional
  resources, preserves source/freshness/audit metadata, and relates resources
  to candidate stages. `LifeContextModels.swift` represents sourced,
  freshness-aware eligibility pathways for career, academic, sport, creative,
  and other domains. Together they are evidence that route requirements,
  supporting resources, eligibility, and personal capability claims must stay
  distinct.
- `TimeContextHierarchy.swift` distinguishes work, school, commute, setup,
  transition, recovery, protected, open, and free contexts. Step occurrences
  can carry context requirements and cognitive-fit evidence.
- `GoalEnergyFitModels.swift` and `GoalEnergyFitService.swift` model capacity,
  recovery posture, work shape, effort, focus demand, and inspectable fit
  reasons. The current capacity source is still coarse: unknown, assumed
  neutral, or structural plan.
- `LearningAnticipationService.swift` learns goal-local session length,
  morning/afternoon/evening focus windows, completion fit, and drift patterns
  from progress and feedback. These are broad time buckets, not yet the
  relational context needed to distinguish "after the gym" from "before
  work."
- `RecommendationEngine.swift`, recommendation traces, Trust projections, and
  step-impact simulation provide bounded recommendation, explanation, and
  preview seams.
- `GoalTeachingModels.swift` records explicit corrections to interpretation,
  requirement relevance, contradictions, and energy fit against stable
  artifacts. It is a useful correction seam: when the user says a requirement
  is irrelevant or a window needs lighter work, the affected candidate can be
  reconsidered without treating that correction as a global truth about the
  person.
- `ProofResourceGraphModels.swift` contains a partial Proof-capital seam:
  evidence anchors, source/freshness/contradiction state, and a deterministic
  pivot-preservation result of preserved, review, or non-transferable. Focused
  test fixtures assert those value-model behaviors. Those assertions transfer
  Proof between already-known source and destination object IDs; they do not
  identify a learned skill, establish proficiency, discover a new destination,
  or feed a generated pathway. The tests were inspected, not executed, for
  this Research.

No specific canonical private-user Skill or Capability identity contract or complete
evidence-to-capability-to-new-path consumer flow was found. Canon recognizes
editable Life Capital records, and source has Proof-capital value models, but
their relationship to a named hard or soft skill remains unresolved. The
repository has career and education domains, resource freshness machinery,
public capability/path graph structures, path candidates, and tested Proof
pivot preservation, but it does not yet establish an authoritative populated
occupation-to-skill knowledge base or prove that completed work can derive a
user-correctable capability and use it to recommend a new destination.
Existing energy and time models show the concept but do not yet model the full
quality of a specific open window.

The earlier Skill Transference readiness audit is adjacent historical evidence,
not the scope of this initiative or a current-state verdict. Its evidence
baseline SHA: `448ad0b9db62ac52d3e6f16b406254def123c970`, which predates
this Research baseline. It explored whether a demonstrated strategy or
capability from one context could help in another and concluded that its
repository evidence was insufficient to choose a representation or receiving
owner. It also rejected a capability dossier, universal score, automatic Goal
or path mutation, hosted inference, and a new dashboard. Current
Proof-capital source narrows part of that earlier evidence gap but still does
not supply the skill-acquisition and new-path consumer flow. This initiative
can absorb the transfer value while resolving a broader end-to-end problem
rather than treating transfer as a standalone feature.

## Evidence

### Product and canon evidence

- `docs/canon/CONSTITUTION.md` establishes Life Capital, generative goal
  pathing, schedule reflow, learning continuity, private inspection, humane
  language, and user authority as connected product laws.
- `docs/canon/specifications/objects/history-event.md:28` explicitly names
  skill and capability knowledge as progress that should survive a Goal pivot.
- `docs/canon/specifications/objects/life-area.md` establishes editable Life
  Capital records and forbids turning them into a score, rank, streak, or
  hidden authority.
- `docs/canon/specifications/objects/proof.md` defines user-approved,
  non-graded Proof that can link to Life Capital, survive progress transfer,
  and carry inferred capability context without auto-completing work.
- `docs/canon/specifications/objects/goal.md` permits local, explained,
  correctable Goal suggestions and preserves a provisional Goal when pathing
  cannot honestly finish.
- `docs/canon/specifications/objects/goal-path.md` provides the versioning,
  dependency, assumption, Proof, decision-point, adaptation, and rollback
  semantics needed for long routes with intermediate milestones. It preserves
  one current Goal Path identity per Goal; candidate routes do not become
  parallel canonical paths without explicit selection and versioning.
- `docs/canon/specifications/objects/life-branch.md` and
  `docs/canon/specifications/journeys/life-branch-reconciliation.md` reserve
  Life Branch for complete alternatives that reconcile already-real Goals,
  Time, Proof, constraints, or other objects through explicit choice. An
  unselected destination idea is not yet a Life Branch.
- `docs/canon/specifications/systems/local-learning.md` already defines
  evidence-linked capability inference, explicit Life Capital, bounded
  recommendation input, deletion effects, and path resimulation.
- `docs/canon/specifications/systems/scheduling-and-capacity.md` recognizes
  energy, context, Step shape, transition buffers, protected boundaries, and
  deterministic simulation as schedule-fit inputs.

### Source and test evidence

- `Native/Ambitions/Core/Domain/NorthStarModels.swift` and
  `Native/AmbitionsTests/Domain/NorthStarModelsTests.swift` preserve long-range
  directions without automatically creating Goals. The existing astronaut
  fixture makes North Star a strong source-backed candidate for holding the
  initiating aspiration before it becomes an active Goal. No normative North
  Star object specification was found, so this is not a canonical completeness
  claim.
- `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels.swift` and
  `Native/AmbitionsTests/Services/GoalPathCompilerServiceTests.swift` show a
  route model capable of representing alternatives, requirements,
  dependencies, uncertainty, and domain hints. They do not model acquired
  capabilities or occupational progression.
- `Native/Ambitions/Core/Domain/TimeContextHierarchy.swift` and
  `Native/AmbitionsTests/Domain/TimeContextHierarchyTests.swift` show that open
  windows are derived around hard context and can retain cognitive/context
  requirements. The inspected tests assert structural exclusion and user
  approval, not qualitative before/after-event fit.
- `Native/Ambitions/Core/Domain/GoalEngine/GoalEnergyFitModels.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalEnergyFitService.swift`,
  and `Native/AmbitionsTests/Services/GoalEnergyFitServiceTests.swift` provide
  deterministic fit bands and reasons, but the tested inputs are mostly
  assumed-neutral or static structural metadata.
- `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/LearningAnticipationService.swift`
  derives goal-local patterns from accepted evidence and friction. Its current
  time model uses morning, afternoon, and evening buckets; it does not prove
  cross-goal skill learning or event-relative energy fit.
- `Native/Ambitions/Core/LocalRuntimeOS/Planning/RecommendationEngine.swift`
  and `StepImpactSimulationSupport.swift` show explainable local suggestions
  and non-committing consequence previews. They do not currently recommend new
  life directions from reusable skills.
- `Native/Ambitions/Core/Domain/GoalEngine/PathIntelligenceModels.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/Planning/AlternatePathPortfolio.swift`,
  `Native/AmbitionsTests/Services/PathIntelligenceProjectorTests.swift`, and
  `Native/AmbitionsTests/Runtime/MultiPathLatticeTests.swift` assert qualitative
  scenario labels, explicit path selection, source review, Proof-continuity
  tradeoffs, and non-mutating path portfolios at the value-model/test level.
  They do not prove option-generating intelligence or a user-facing pivot flow.
- `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPackModels+04-SourceAtlasLevelLadder.swift`,
  `SourceAtlasPackModels+07-PlanSkeletonRiskFlag.swift`, and the
  `SourceAtlasCapabilityPathComposer` files define public capability graphs,
  source-backed traversal, role/path overlays, alternative paths, requirement
  projections, local-context influence, plan skeletons, and an internal path
  score. Inspected focused tests assert those structural behaviors. They do not
  supply a canonical private capability record, external occupation corpus, or
  evidence-to-new-destination product flow; their scalar score must not leak
  into user ability, compatibility, employability, or path-authority claims.
- `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphModels.swift` and
  `Native/Ambitions/Core/Domain/LifeContextModels.swift` provide source-backed
  resource, optionality, eligibility, region/freshness, and audit seams. Their
  presence argues against collapsing a route requirement, a useful resource,
  and a user capability into one generic edge.
- `Native/Ambitions/Core/Domain/ProofResourceGraphModels.swift`,
  `Native/AmbitionsTests/Domain/ProofResourceGraphModelsTests.swift`, and
  `Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift`
  define deterministic Proof-preservation fixtures across a known pivot,
  including freshness, contradiction, evidence overlap, and review-required
  results. This is real reusable source and verification infrastructure, but
  its unexecuted proof ceiling here is transfer classification between supplied
  object IDs—not skill acquisition, proficiency, destination discovery, or
  pathway generation. The source also carries a `ProofStrength` field even
  though current canon says Proof is never graded by strength; future work must
  follow canon rather than treating that field as permission to score ability.
- `docs/audits/skill-transference-readiness.md` records reusable Trust,
  privacy, replay, and recommendation seams, as well as missing
  source/destination representation, receiving-owner, sensitive-domain, and
  transfer lifecycle proof. Its final result was "repository evidence is
  insufficient to decide," so it is evidence of unresolved work rather than
  evidence of implementation.

### External domain research

#### Occupation and skill taxonomies

The [O*NET Content Model](https://www.onetcenter.org/content.html) separates
skills from knowledge, abilities, work styles, education, experience,
credentials, tasks, work activities, and work context. It also separates
essential, transferable, and software skills. That structure is evidence that
the everyday "hard skill / soft skill" split is too coarse for reliable path
reasoning. In particular, O*NET Work Styles are personality tendencies, not
evidence that a user possesses a learned skill; Ambitions must not infer them
from behavior.

The current [O*NET database](https://www.onetcenter.org/database.html) is
versioned, downloadable, available through an API, and mostly licensed under
CC BY 4.0 with attribution and exception requirements. It is a strong United
States reference source for occupation requirements and relationships, but its
ratings describe occupations and workers in aggregate. They do not establish
an individual user's capability or guarantee a path.

[ESCO](https://esco.ec.europa.eu/en/use-esco) provides stable identifiers and
relationships for occupations, skills, knowledge, and competences in multiple
languages. It is available as downloadable linked open data, a web API, and a
local API. The service reported version 1.2.1 during this Research. ESCO is a
useful multilingual and European complement, not an interchangeable source of
United States licensing or hiring requirements.

The [BLS Occupational Outlook Handbook](https://www.bls.gov/ooh/About/Occupational-Information-Included-in-the-OOH.htm)
adds duties, work environment, typical education and training, related
experience, pay, outlook, and similar occupations. BLS explicitly warns that
employment projections contain uncertainty and should not be the sole basis
for a career choice. Ambitions must therefore present market information as a
dated input, never as a promised outcome.

These sources support a public-reference layer with version, region,
provenance, attribution, and freshness. They do not supply a universal hobby
taxonomy, a definitive promotion ladder, or evidence about the private user.

#### Career transitions and reused progress

Research supports skill adjacency as a candidate-generation signal, not a
career verdict. A 2024 study, [Network constraints on worker mobility](https://www.nature.com/articles/s44284-023-00009-1),
found that occupation skill similarity predicted observed job-transition rates
and that local labor-market structure also mattered. OECD analyses likewise
compare origin and destination skill profiles, but include education,
training, demand, and other transition costs rather than treating overlap as
sufficient ([Moving between jobs](https://www.oecd.org/en/publications/moving-between-jobs_d35017ee-en.html)).

This supports showing reusable capabilities and missing requirements while
rejecting a single opaque "best career" score. User desire, location,
eligibility, cost, time, education, market conditions, and alternative routes
remain first-class constraints.

The astronaut scenario demonstrates why path facts need authoritative,
fresh sources. NASA says its requirements change with missions. Its current
[Become an Astronaut](https://www.nasa.gov/humans-in-space/astronauts/become-an-astronaut/)
page names United States citizenship, qualifying graduate STEM education,
related professional experience or qualifying pilot hours, the flight
physical, and leadership, teamwork, and communication; selected candidates
then complete additional training. Those facts define eligibility and
selection inputs, not a guaranteed sequence of promotions. A generated path
must distinguish hard requirements, common preparation, optional routes,
competitive selection, and post-selection training.

#### Education, credentials, and structured pathways

Credential Engine's [CTDL pathway model](https://guidance.credentialengine.org/pathway-builder-ctdl-and-pathway-builder-terminology/)
represents routes as components such as courses, credentials, competencies,
jobs, and assessments, joined by conditions and constraints. That is a better
external analogy than a single promotion ladder: a real route may combine
education, experience, assessment, work, selection, and alternative ways to
satisfy a condition. The publisher's pathway is still a public reference;
Ambitions must not mistake it for a route accepted by the user or proof that a
condition has been met.

CTDL's [Recognition of Prior Learning model](https://www.credreg.net/ctdl/handbook)
separately represents recognition policies, transfer agreements, transfer
value, evaluation evidence and outcomes, conditions, and applicability. That
separation is decisive for "what still counts": Ambitions may preserve and
explain relevant progress, while a named receiving authority controls formal
credit, equivalency, placement, or acceptance.

The [1EdTech CASE standard](https://www.1edtech.org/standards/case) gives
academic standards, competencies, learning outcomes, hierarchies, and
cross-framework associations stable identifiers. It can improve the
traceability of educational claims, but an association between frameworks is
publisher-authored context, not automatic equivalence and not evidence that an
individual has mastered the item.

The United States Department of Education's [Classification of Instructional
Programs](https://nces.ed.gov/ipeds/cipcode/Default.aspx?y=55) classifies fields
of study and completions and publishes versioned crosswalks. It does not define
one institution's admissions, curriculum, transfer-credit decision, or current
program availability. Those facts need the relevant provider, receiving
institution, articulation agreement, accreditor, or licensing authority.

The U.S. Department of Labor-sponsored
[CareerOneStop APIs](https://cloudfront.careeronestop.org/Developers/WebAPI/Certifications/get-certification-details-by-id.aspx)
expose occupation certifications, licenses, training, and skills-match data and
can complement O*NET/BLS in a later United States career increment. Their
records remain discovery aids: the named issuing or licensing authority and
its current regional rules control eligibility.

#### Evidence and credentials

[Open Badges 3.0](https://www.1edtech.org/standards/open-badges) models an
issuer's achievement claim with criteria, evidence, issuance information, and
cryptographic verification. Verification establishes issuer and artifact
integrity; it does not establish present competence, issuer quality, receiver
acceptance, licensing eligibility, or continuing validity by itself.
This supports keeping user statements, Ambitions-observed practice,
user-approved Proof, and issuer-backed credentials distinct.

LinkedIn's official [account-data download](https://www.linkedin.com/help/linkedin/answer/a1339364?lang=en)
can include user-entered skills, certifications, courses, education,
positions, and projects. However, LinkedIn's
[Profile API](https://learn.microsoft.com/en-us/linkedin/shared/integrations/people/profile-api?view=li-lms-2025-04)
is restricted to approved developers and constrained fields, and its
[User Agreement](https://www.linkedin.com/legal/user-agreement) prohibits
scraping. Therefore LinkedIn is not a foundation dependency. The focused
`user-profile-archive-import` Research evaluates a user-requested archive as
user-provided claims with provenance; Ambitions must not crawl profiles, imply
LinkedIn verification, or silently write back.

#### Time quality

Time quality is real but individualized. A 2025 systematic review of 65 studies
on [chronotype and cognitive performance](https://pubmed.ncbi.nlm.nih.gov/40293205/)
found that most studies did not show a general chronotype effect, while a
subset found time-of-day alignment effects that varied by age, task, and
context. A 2025 meta-review of 30 meta-analyses found a small-to-medium average
benefit of [acute exercise on cognition](https://pubmed.ncbi.nlm.nih.gov/39883421/),
with assessment timing affecting results. Neither finding supports a universal
rule that an hour after the gym is worse or better than an hour before work.

The defensible product conclusion is to start with user-declared fit and
structural context, then cautiously learn event-relative patterns from local
completion and friction evidence. Fit must remain task-specific, uncertain,
inspectable, correctable, and quiet when evidence is sparse.

### User evidence represented by the initiating scenario

The idea supplies five high-value cases that the product must eventually
distinguish:

1. **Long destination:** an ambitious outcome such as becoming an astronaut
   needs a route through sourced prerequisites, education, experience,
   applications, competitive selection, training, and any legitimate role
   options rather than a flat task list or a fabricated promotion ladder.
2. **Useful pivot:** a user who changes direction should see which progress is
   reusable and which gaps differ, then choose among explained alternatives.
3. **Unequal open time:** duration alone does not determine placement quality;
   adjacent commitments, transitions, recovery, focus, and user-declared
   context can change which Step realistically fits.
4. **Aspiration before commitment:** the user may want to explore an identity-
   level direction without turning it into an active Goal. Capability reuse can
   explain an entry point, but low current overlap must not hide the aspiration
   or pressure the user to activate it.
5. **Option-preserving progress:** when the destination is uncertain, a useful
   next move may satisfy a shared prerequisite, create portable Proof, or test
   interest across several plausible paths. Ambitions should show that option
   value qualitatively rather than manufacture a universal score or silently
   select the path.

These are product hypotheses from the initiating idea. External source and
literature research now supports the taxonomy, pathway, credential, and
time-quality decisions below. This Research did not perform external user
interviews or validate market demand for the experience; those remain product
validation gaps rather than hidden assumptions.

## Alternatives

### 1. Manual skills profile

Let users maintain a list of skills and use it as optional recommendation
input. This is understandable and maximally controllable, and it can deliver
value before inference exists. It also creates upkeep, disconnects skills from
Proof and completed work, and may become a static resume surface that misses
Ambitions' continuity advantage.

### 2. Automatic skill inference from completion

Treat completed Goals or Steps as proof that named skills were acquired. This
would feel effortless but is not trustworthy. Completion can mean exposure,
practice, assistance, partial competence, or mastery; soft-skill claims are
especially subjective. Direct inference risks false credentials, personality
profiling, and hidden employability scoring.

### 3. Evidence-backed capability continuity

Represent a capability as a user-owned or Ambitions-proposed claim bound to
specific Goal, Step, Proof, credential, or correction evidence. Distinguish
user-stated, practiced, Proof-linked, and externally credentialed provenance
facets that may coexist rather than form a rank;
expose uncertainty and intended use; and let the user confirm, edit, dismiss,
suppress, or delete its influence. Recommendation and simulation consume these
claims without owning or silently changing them.

This best matches current canon and is the leading research direction. It is
more demanding because the product must resolve identity, evidence meaning,
overlap, provenance, correction, deletion, and presentation without turning
the result into a score or dossier.

### 4. Career-first vertical

Build role ladders, credentials, promotions, and alternative-career simulation
as a career product first. It offers a concrete, legible use case and could
validate the astronaut-style route. It may also overfit the underlying model
to employment, invite LinkedIn comparison, and delay benefits for education,
hobbies, and other life directions. Career could be a first validation domain
without becoming the product boundary.

### 5. Universal life-skill graph

Model every activity, capability, prerequisite, role, and destination in a
single graph. This appears flexible but creates the largest privacy,
explainability, maintenance, and taxonomy burden. It risks becoming the
rejected capability dossier or a hidden model of the person. Current evidence
does not justify this architecture.

### 6. Path generation without durable skills

Generate routes from the Goal and current stated facts, then use completed
milestones only inside that Goal Path. This reduces model complexity and may
improve near-term pathing, but it fails the central promise that progress can
compound across a changed destination.

## Unknowns and risks

### Resolved research questions

- **Vocabulary:** `capability` is the umbrella product concept; user-facing
  language can use skills, knowledge, experience, methods, and credentials when
  that is more precise. "Soft" and "hard" remain intake language, not the data
  model. Transferable or social skills must not be conflated with personality,
  Work Styles, values, interests, health, or moral character.
- **Evidence meaning:** the product needs categorical provenance, not a scalar
  proficiency score. The minimum honest facets are user-stated,
  practiced through accepted activity, Proof-linked through user-approved
  evidence, and issuer-credentialed. They are non-exclusive and non-monotonic:
  recent practice and an expired credential can coexist and answer different
  questions. Imported profile data remains user-provided until reviewed. A
  canonical completion or History observation may support proposing
  `practiced`; its related Receipt supplies mutation provenance but is not, by
  itself, evidence of practice. User-approved Proof may support `Proof-linked`.
  None of these facets independently claims assessed competence or mastery.
  Externally defined levels such as a degree level, certification class, years
  of experience, or language framework can remain sourced requirements without
  becoming an Ambitions-generated universal proficiency score.
- **What "counts" means:** the product must not collapse five different claims:
  evidence remains part of the user's Life Capital; it overlaps a candidate
  destination; it appears to satisfy a sourced pathway condition; a named
  policy recognizes prior learning or transfer value; and the receiving school,
  employer, issuer, or licensing authority formally accepts it. Ambitions can
  establish the first, explain evidence for the middle claims, and record the
  last only from an authoritative decision. Reuse is not official equivalency.
- **Proof boundary:** Proof remains ungraded under canon. Evidence type,
  recency, source, context, and contradictions can affect whether a capability
  is safe to use, but the existing source-level `ProofStrength` field is not
  authority for skill, worth, or employability scoring.
- **Capability lifecycle:** a capability does not silently decay. Evidence and
  external requirements may become stale or contradicted independently. The
  user can inspect, correct, suppress, archive, or delete future influence, and
  affected route suggestions are resimulated after a change. Deletion removes
  future influence without rewriting the historical Goal, Proof, Receipt, or
  History Event that honestly records what happened. "Not transferable to this
  destination" likewise means irrelevant or insufficient for that comparison,
  not worthless or erased from Life Capital.
- **Reference sources:** O*NET plus BLS are the recommended initial United
  States occupation sources; ESCO is a complementary multilingual/European
  source. CTDL, CASE, CIP, and CareerOneStop are later discovery/cross-reference
  candidates for structured pathways, competencies, education, licenses, and
  certifications. Authoritative licensing, credentialing, education, employer,
  provider, or receiving-institution sources override generic summaries for
  hard requirements, acceptance, and availability. Every fact needs source,
  region, version, retrieved date, and freshness.
- **Privacy boundary:** public pathway data can be downloaded or refreshed
  without private payloads. Private capabilities, Proof, Goals, schedules,
  comparisons, and recommendation history remain local and never become a
  hosted prompt or Source Atlas query. A capability label, its evidence context,
  an eligibility state, or a suggested destination may itself expose health,
  disability, religion, finances, relationships, citizenship, age, or other
  protected context even when its input was not labeled sensitive. Derived
  outputs therefore need explicit sensitivity classification, suppression, and
  no cross-domain inference from protected context. Eligibility must distinguish
  user-declared, source-backed, credential-verified, and professional-
  determination states; Ambitions cannot adjudicate medical, legal, licensing,
  hiring, or similar professional gates. This portfolio excludes sensitive
  capability inference unless a distinct future initiative completes its own
  Research and privacy review; no broader switch or generic consent can enable
  it.
- **Starting-position fidelity:** capability evidence is only one part of the
  user's starting position. Credentials, experience, resources, opportunity
  access, explicit constraints, and user-chosen sensitive facts remain distinct
  inputs. Citizenship, licensing, education, location, transport, money,
  equipment, mentor access, or a competitive opening must not be mislabeled as
  a skill gap or inferred without appropriate user control.
- **Recommendation method:** capability overlap can generate candidates, but
  user interest, exclusions, chosen Life Areas, and active or dormant North
  Stars are independent inputs. A continuity lane can surface adjacent paths
  that reuse progress; an exploration lane must preserve user-chosen or
  aspirational paths with little current overlap so history does not become a
  destiny filter. Every suggestion must show
  reused progress, missing or uncertain requirements, hard eligibility gates,
  important costs or location limits, source freshness, and why alternatives
  were considered. No single compatibility or employability score is valid.
- **Path semantics:** external occupations, credentials, and requirements are
  Source References until the user adopts a route. Goal Path remains the owner
  of a selected route. Route facts must distinguish a hard gate, prerequisite,
  preferred qualification, common preparation, optional strengthening,
  substitution or equivalency, competitive selection, post-selection training,
  and continuing-validity requirement. Intermediate roles may appear as sourced
  route options or milestones; they become Goals or Steps only through existing
  confirmed conversion, never because a generic ladder says so.
- **Change identity:** the workflow must distinguish changing the route to the
  same destination, deliberately adopting a new destination that reuses prior
  progress, holding a dormant North Star without an active Goal, and reconciling
  several already-real objects after life changes. The first revises Goal Path;
  the second preserves the old Goal/Proof/History while creating or adopting a
  new destination; the third creates no Goal; the fourth may use Life Branch
  only after there are concrete objects to reconcile. Unselected ideas are not
  automatically Goals, Goal Paths, or Life Branches.
- **Capability bundles:** destinations generally depend on combinations of
  capabilities, credentials, experience, resources, and conditions rather than
  one matched skill. Comparison can show each requirement as evidenced,
  partially supported, unknown, contradicted, or authority-confirmed, but must
  not aggregate the bundle into a compatibility score.
- **Simulation boundary:** comparison is side-effect-free. It can compare
  reused evidence, gaps, duration ranges, constraints, uncertainty, and
  schedule pressure across continuing, pivoting, pausing, taking a smaller
  first move, or testing a bridge milestone. A bridge can be described as
  option-preserving when it advances several sourced routes or produces
  portable Proof, but simulation cannot predict selection, promotion, income,
  or success as fact.
- **Availability and eligibility:** a structurally plausible route is not
  necessarily offered nearby, open now, affordable, or available to this user.
  Pathway existence, current offering, current opening, and user eligibility
  are separate sourced claims with separate freshness and uncertainty.
- **Time quality:** begin with user-declared context and existing structural
  facts. Later local learning may propose event-relative patterns using clock
  time, preceding/following context or hard stops, transition or recovery,
  setup cost, duration, place, tools, connectivity, interruption risk, and Step
  focus/effort shape. This is a task-specific context signature, not a universal
  time-quality or energy score. It must not diagnose chronotype, health, mood,
  burnout, discipline, or disability. Sparse or conflicting evidence yields no
  learned preference, and a pattern should generalize only to meaningfully
  similar contexts.
- **LinkedIn boundary:** no LinkedIn dependency, scraping, or silent write-back.
  The focused `user-profile-archive-import` initiative may accept a
  user-requested archive and preserve each item as a reviewable user-provided
  claim with provenance.
- **Correction and learning:** explicit corrections should be bound to the
  affected capability, requirement, candidate, or time context. They can
  resimulate dependent comparisons, but a correction such as "not relevant on
  this route" or "lighter work after the gym" must not become an unbounded
  global trait about the user.

### Remaining risks and portfolio decisions

- O*NET is United States-centered and ESCO is European; mapping them can lose
  meaning. `public-reference-knowledge-foundation`, together with each consuming
  domain initiative, must evaluate one regional source family at a time rather
  than pretend the taxonomies are globally equivalent.
- O*NET, ESCO, CASE, CTDL, CIP, credential issuers, schools, and employers can
  use different identities and granularity for apparently similar concepts.
  Crosswalks need publisher, framework version, relationship type, and
  uncertainty; a close label match is not an equivalency decision.
- Occupation data describes typical requirements, not one employer, licensing
  board, school, or exceptional route. High-consequence requirements need a
  named authoritative source and conservative freshness policy.
- Skill-similarity methods can reproduce historical mobility, access, and labor
  market bias. Recommendations must include aspirational routes and user-chosen
  interests rather than only the nearest historical transition. This also
  guards against path dependence: capability reuse should expand agency, not
  confine the user to what their past already resembles.
- Hobby and broad education pathways lack an equivalent single public
  taxonomy. The completed `education-destination-recommendations` and
  `hobby-destination-recommendations` Research documents establish their
  separate authority limits; career-source coverage must not masquerade as
  general life-path coverage.
- Employer-specific career-advancement programs and promotion criteria are not
  supplied by O*NET or BLS and may be private, temporary, or organization
  specific. They must enter as a user-provided or named employer Source
  Reference with freshness and access limits; Ambitions must not fabricate a
  company ladder from a generic occupation profile.
- The precise Life Capital persistence representation and receiving service are
  Design decisions after Scope fixes the behavior. Existing Proof-capital
  models are reusable evidence, not automatic architectural authority.
- External credentials can prove issuer and artifact integrity without proving
  present ability or universal acceptance. Expiration, revocation, selective
  disclosure, and local deletion are evaluated by
  `verifiable-credential-import`; outbound credential presentation is excluded
  from this portfolio.
- Education and career routes can exist in reference data while no provider,
  seat, apprenticeship, job opening, transfer agreement, or license route is
  currently available. `public-reference-knowledge-foundation` and the named
  career and education recommendation initiatives must surface that distinction
  and avoid converting a taxonomy or historical route into an actionable offer.
- No external user interviews establish whether people prefer a persistent
  Life Capital inventory, contextual suggestions, or both. The recommended
  first Scope can support inspection plus contextual prompts, but this remains
  a usability hypothesis requiring prototype and user validation.
- Current source and tests do not prove the end-to-end behavior. Runtime,
  privacy-egress, replay, deletion, accessibility, and recommendation-quality
  proof remain implementation obligations, not Research evidence.

## Recommended direction

Treat this document as portfolio Research, not as authority for one umbrella
Scope. The evidence supports a connected product system, but its delivery
contracts have different owners, source authorities, privacy risks, and commit
boundaries. Each named initiative below therefore needs its own self-contained
Research and approved Scope before Design.

The leading product direction is an evidence-linked Life Capital experience,
not a resume, social profile, capability graph, or universal skill score. A
user can add a capability directly, or Ambitions can propose one after accepted
activity. Every item exposes its meaning, source, evidence category, relevant
context, uncertainty, and current uses. The user can confirm, refine, reject,
suppress, archive, or delete its influence. An accepted completion supports a
practice claim only when the capability-bearing activity or an explicit,
user-confirmed reflection identifies what was practiced; completion by itself,
or wording unrelated to the completed activity, does not. User-approved Proof
and an issuer-backed credential support different provenance claims, not higher
points on one strength ladder. Scope and Design still decide the smallest
representation that satisfies this experience without creating a duplicate
object family.

Capability evidence explains possible continuity; it does not supply desire.
User-chosen Life Areas, interests, exclusions, motivations, and active or
dormant North Stars anchor direction. Recommendations should preserve both an
adjacency lane that explains reusable progress and an exploration lane that can
hold a low-overlap aspiration without creating a Goal. Capability continuity
must widen the user's future choices rather than turn their history into a
destiny filter.

Recommendation, path generation, simulation, and scheduling should remain
separate consumers with existing authority boundaries:

- Recommendation explains which direction signals and capabilities make a
  destination worth exploring, which progress is directly reusable or needs
  review, which gaps and non-skill constraints remain, and why the suggestion
  appeared.
- Goal path generation can present candidate route alternatives with sourced
  gates, prerequisites, equivalencies, role or education options, selection
  points, Proof, and uncertainty. After explicit selection, one current Goal
  Path identity owns versioned routes toward that Goal; changing the destination
  does not silently rewrite the existing Goal.
- Simulation compares continue, pivot, pause, smaller-first, bridge, and
  exploration scenarios without mutating Goals, paths, or Time or claiming a
  success probability.
- Scheduling uses explicit context plus cautious local learning to match Step
  shape with a particular window, including surrounding commitments and hard
  stops, setup, transition, recovery, place/tools, interruption risk, and
  relevant prior evidence—not duration alone and never a universal time score.

Public pathway knowledge and private person knowledge must remain separated.
Ambitions should use locally cached, provenance-bearing, freshness-aware public
references to describe possible roles or prerequisites, beginning with O*NET
and BLS for United States career research and using authoritative role-specific
sources for hard gates. CTDL, CASE, CIP, and CareerOneStop can later improve
structured pathway, education, competency, license, and certification discovery
without supplying equivalency or receiver acceptance. Private capabilities,
Proof, schedule, and recommendation history stay local. Generated routes are
assumption-bound possibilities, not guarantees or professional certification.

The portfolio contains the following distinct initiatives; the numbering is a
catalog, not a serial implementation order:

1. **`capability-continuity-foundation`:** durable user-owned capability meaning,
   evidence facets, proposals, correction, lifecycle, privacy, and continuity;
   no consumer.
2. **`public-reference-knowledge-foundation`:** public-only source identity,
   provenance, licensing, freshness, conflict, crosswalk, revocation, and
   offline fallback; no private matching.
3. **`career-destination-recommendations`:** explained career candidates using
   career-specific authority, an adjacency lane, and an aspiration lane; no
   employability score or Goal creation.
4. **`education-destination-recommendations`:** education candidates that keep
   program existence, current offering, admissions, affordability, transfer,
   equivalency, accreditation, and receiver acceptance distinct.
5. **`hobby-destination-recommendations`:** low-pressure hobby and creative
   exploration without pretending a universal taxonomy or career-style ladder
   exists.
6. **`destination-adoption-and-pivot`:** explicit adoption of a candidate or
   direct destination; a changed outcome creates a separately confirmed Goal
   and never silently rewrites the old one.
7. **`goal-path-generation`:** assumption-bound route generation for one stable
   Goal, with sourced gates, prerequisites, milestones, intermediate options,
   Steps, Proof targets, and exactly one adopted Goal Path lineage.
8. **`adaptive-path-comparison`:** side-effect-free comparison of same-outcome
   route candidates such as continue, pause, bridge, smaller-first, and
   alternatives; simulation owns no commit.
9. **`context-quality-scheduling`:** event-relative Step fit, placement preview,
   and reflow using structural context and cautious local learning rather than
   duration alone.
10. **`life-branch-reconciliation`:** complete cross-object alternatives only
    when several already-real Goals, paths, placements, Proof, or constraints
    must be reconciled together.
11. **`user-profile-archive-import`:** user-requested LinkedIn-style archive
    ingestion as reviewable user-provided claims, with no scraping or write-back.
12. **`verifiable-credential-import`:** issuer-backed credential ingestion with
    artifact integrity, issuer, expiry, revocation, and acceptance kept distinct
    from present competence.
13. **`capability-export`:** selective, previewed outbound disclosure with
    minimization and no automatic profile publishing.

The actual dependency graph is narrower:

- Capability continuity and public-reference knowledge are independent
  foundations. Career, education, and hobby recommendations consume the
  Capability foundation only when capability-based matching is enabled and
  consume public references only for the source families they use.
- Goal Path generation consumes `public-reference-knowledge-foundation`
  whenever it makes sourced route, gate, availability, or freshness claims. A
  plainly generic or manual degraded path may remain independent of that edge.
- Destination adoption can accept a direct user-entered destination without a
  recommendation or Capability. Recommendation candidates may hand off to it,
  but do not own Goal creation.
- Destination adoption precedes generated Goal Paths for a newly chosen
  outcome. Goal Path generation constructs candidates and owns single-route
  review. Adaptive comparison depends on Goal Path generation when it compares
  multiple generated candidates, selects one proposal without mutation, and
  returns it to the canonical Goal Path activation boundary for revalidation,
  explicit confirmation, and version creation.
- Context-quality scheduling works for existing Steps independently. Goal Path
  generation is a dependency only when Scheduling consumes generated Steps.
- Profile import and Capability export depend on Capability ownership for the
  claims they create or disclose. Credential import can exist as credential/
  Proof evidence independently; Capability is required only for a capability
  relationship.
- Life Branch reconciliation is not downstream of an ordinary destination or
  route change. It begins only when several already-real objects require one
  complete policy-distinct alternative.

Application execution, provider contact or purchase, community integration,
credential presentation, automatic publishing, and named-platform write-back
are excluded, uncommitted future ideas outside this portfolio. They have no
implied Scope or delivery dependency here.

Research and appropriately independent implementation can therefore proceed in
parallel wherever these hard edges do not apply. Every focused Scope must name
only the dependencies its observable behavior actually consumes.

This decomposition supersedes the earlier five-bucket delivery shorthand. It
does not change the product thesis: completed progress should compound into
future choice while remaining private, inspectable, source-aware, and under the
user's authority. It prevents the thesis from becoming one unreviewable Scope
or allowing a shared implementation seam to erase distinct product contracts.
