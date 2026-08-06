+++
initiative = "goal-path-generation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

A user can know what they want without knowing the credible sequence that
makes it possible. "Become an astronaut," "change careers," "earn a degree,"
"learn woodworking," or "publish a novel" may involve prerequisites,
alternative routes, intermediate experiences, competitive decisions,
resources, evidence, and uncertainty that are not visible from the outcome
alone. Ambitions should help turn an adopted Goal into an understandable route
without fabricating expertise or taking ownership of the user's life.

Goal-path generation is the job of proposing how one already-chosen outcome
could become real. It is not destination recommendation, which asks what the
user may want to pursue. It is not path comparison, which lets the user compare
several route candidates for the same adopted outcome. It is not schedule
placement, which fits accepted Steps into Time. It is not Life Branch
reconciliation, which compares complete alternatives across several already-
real canonical objects after changed reality.

The key product problem is to generate enough structure to be useful while
remaining honest about what is known. A generated route may need to distinguish
hard gates, prerequisites, common preparation, optional strengthening,
equivalencies, selection points, post-selection training, and continuing
requirements. It must show assumptions and missing context, preserve user
editing and rejection, and create no accepted Path, Step, Proof requirement, or
placement until the relevant confirmation boundary is crossed.

## Current truth

This Research used baseline main SHA: `40894e92c61de55841c31fd797fd5ae39625c5dc`,
current canon, live source, focused
tests, and the related initiative-family Research at
`docs/product-development/adaptive-skills-and-pathways/research.md`. Referenced
tests were inspected rather than executed for this document; source presence
does not prove a shipped or complete experience.

Canon already defines the central identity and authority laws:

- `OBJ-GOAL-IDENTITY-001` defines a Goal as one stable desired outcome with a
  living route. The outcome is user-owned and remains distinct from its Steps,
  Proof, placements, and route.
- `OBJ-GOAL-PATH-IDENTITY-001` defines one versioned, inspectable adaptive route
  owned by a Goal. Its ordered nodes may reference canonical Steps, Proof
  targets, Recovery Segments, review points, schedule changes, adaptive
  changes, decision points, and Closure without copying those objects.
- The same Goal Path specification requires one current identity with immutable
  version lineage. Regeneration, reflow, node edits, and recovery make new
  versions, not parallel unlinked canonical paths.
- `OBJ-GOAL-PATH-STRATEGY-001` requires path strategy to be inspectable,
  assumption-bound, editable, and subordinate to confirmed Goal intent.
- `OBJ-GOAL-PATH-RECEIPT-001` requires material path changes to be reviewed,
  confirmed, receipted, replayable, and reversible. Rejected preview preserves
  the prior path.
- `JOURNEY-GOAL-ACTIVATION-001` requires an inspectable draft route with
  assumptions, milestones, Steps, Substeps, Proof expectations, and schedule
  suggestions. The route, Path, Step, and placement proposals remain
  non-durable until reviewed activation; optional scheduling remains a
  separate commit.
- `OBJ-GOAL-CREATION-FAILURE-001` preserves a provisional Goal shell and
  original intent if pathing cannot honestly finish. Manual continuation and
  safe reversal must remain available.
- `SYSTEM-RUNTIME-SIMULATION-001` requires planning simulation to remain
  deterministic, local, inspectable, bounded, and side-effect-free until
  commit.
- Source Atlas may provide only public/reference and freshness infrastructure.
  It cannot receive the private Goal, become a private planner, or choose the
  path.

These laws answer who owns the accepted route and when mutation is permitted.
They do not fully answer how a useful candidate route is generated from mixed
public sources, private facts, capability evidence, and uncertainty.

The source has substantial partial machinery:

- `GoalPathCompilerModels.swift` represents provisional, stronger, and blocked
  compile postures; ordered stages; dependencies; assumptions; risks;
  requirement hints; readiness criteria; resource hooks; blocking reasons;
  alternate interpretations; and fallback or blocked branches.
- `GoalPathCompilerService.swift` compiles an already-structured
  `GoalUnderstanding` into one or more candidate projections. Focused tests
  assert that unsafe understanding blocks compilation, alternate
  interpretations remain candidates, dependencies resolve, uncertainty is
  preserved, and a lower-uncertainty input can yield a stronger posture.
- `PathIntelligenceModels.swift` projects stages, prerequisites, assumptions,
  correction prompts, Proof requirements, fallback paths, domain-pack limits,
  fork comparisons, source boundaries, and future-self scenarios. Its tests
  require scenarios to say "Scenario, not prediction" and reject "best path,"
  "highest score," and guaranteed-outcome language.
- `GoalResourceGraphModels.swift` distinguishes required and optional
  resources, source records, freshness, and audit relationships. This guards
  against treating every helpful resource as a prerequisite.
- `LifeContextModels.swift` represents sourced eligibility pathways and
  freshness-aware context across career, academic, creative, and other
  domains. Eligibility remains distinct from capability and desire.
- Source Atlas capability graphs, level ladders, role/path overlays,
  requirements, alternative paths, and plan skeletons can describe public
  reference structure. `SourceAtlasCapabilityPathComposer` exposes an internal
  scalar score used in composition; it is not authority for a user-facing
  route, ability, compatibility, employability, or success score.
- `NorthStarModels.swift` can retain a long-range direction and reference later
  path artifacts. It does not establish path-generation completeness or
  canonical ownership.

The source is materially ahead of a blank slate, but it is not end-to-end
proof. The inspected compiler uses supplied understandings and domain packs;
it does not establish a complete, current occupation, education, hobby, or
licensing knowledge base. The models do not prove that generated stages map
safely into canonical Goal Path nodes, Steps, Proof rules, and placements under
the full activation and replay contract. No evidence was found that current
source can generate a reliable astronaut-style route from authoritative facts,
keep source claims fresh, let the user revise every material assumption, and
commit exactly one current Goal Path without hidden object creation.

## Evidence

### Product and canon evidence

- Goal Path canon already supplies the correct accepted-route identity. The
  product does not need a second canonical "generated path" object merely
  because several proposals were considered.
- Goal activation canon separates four boundaries: provisional Goal creation,
  clarification commits, non-durable route/Path/Step/placement simulation, and
  optional scheduling. A path generator must respect all four.
- The Goal Path node vocabulary is broad enough to represent a practical long
  route: start/current position, recommended Step, Steps and Substeps, Proof
  moments, recovery, schedule and adaptive changes, decision points, pause,
  resume, and Closure.
- Canon requires an ordered nonvisual representation. Path generation cannot
  rely on a diagram to communicate dependencies, alternatives, or current
  position.
- Proof remains user-approved and ungraded. A generated route may propose a
  Proof expectation under predeclared rules, but it cannot grade evidence or
  infer that a requirement is satisfied from an automatic Receipt.
- Local-learning influences may inform declared planning decisions, but sparse,
  stale, contradictory, or deleted evidence must yield neutral behavior rather
  than fabricated route confidence.

### Source and test evidence

- `GoalPathCompilerServiceTests.swift` proves useful value-level behaviors for
  supplied fixtures: blocked compilation, candidate alternatives, preserved
  assumptions/risks, and resolvable stage dependencies. It does not prove
  factual route quality for a real external destination.
- `PathIntelligenceProjectorTests.swift` establishes good copy and projection
  constraints: source boundaries, user-correctable assumptions, qualitative
  scenarios, explicit domain limits, and no silent "best" route selection.
- `AlternatePathPortfolio.swift` and `MultiPathLattice.swift` show how route
  candidates can remain non-mutating, source-bound, and unselected until review.
  They are value models and do not override Goal Path's one-current-identity
  law.
- `ProofResourceGraphModels.swift` can preserve supplied Proof across a known
  route change when overlap and source claims support it. That is evidence for
  continuity review, not permission to mark generated prerequisites complete.
- Existing source and tests distinguish public reference data from local
  private context. This supports local composition: public packs may be cached
  by finite identifiers, while private Goal/capability facts never become
  Source Atlas requests.

### External domain evidence

The related initiative-family Research examined several primary reference
families:

- O*NET and BLS separate occupation tasks, skills, knowledge, education,
  experience, work context, outlook, and related occupations. Their facts
  describe typical work and aggregate conditions, not one person's fitness or
  one employer's requirements.
- ESCO offers stable multilingual identifiers and relationships for skills,
  knowledge, competences, and occupations, but it does not replace regional
  licensing or hiring authority.
- CTDL models pathways as courses, credentials, competencies, jobs,
  assessments, conditions, and constraints. Its shape supports branching
  routes rather than a single fabricated promotion ladder.
- CASE and CIP provide stable education/competency identifiers and field-of-
  study classification, but not institutional admission, curriculum,
  availability, transfer credit, or equivalency decisions.
- NASA's current astronaut guidance demonstrates a high-consequence path with
  hard eligibility, alternative experience routes, competitive selection, and
  later training. It does not define a guaranteed sequence of lesser roles and
  promotions.

This evidence supports typed route facts with provenance, region, version,
retrieval date, and freshness. It rejects the idea that label similarity or a
generic occupation graph can produce an authoritative personalized ladder.

### Bounded first validation domain: NASA astronaut candidacy

Research chooses **NASA astronaut candidacy in the United States** as the first
validation domain. This is a validation case, not a promise that Scope must ship
an astronaut-specific experience. It is narrow enough to check against one
primary authority and demanding enough to expose whether path generation can
distinguish eligibility, preparation, competitive selection, and later
training without inventing a guaranteed ladder.

NASA's public guidance, retrieved 2026-08-03, establishes mixed-cycle facts the
validation case must preserve. It does not establish a currently open
application cycle or a complete current-cycle gate set:

- NASA names U.S. citizenship, a qualifying STEM master's degree or
  stated alternatives, related professional experience or the stated pilot
  route, and ability to pass the long-duration flight astronaut physical as
  application qualifications. It separately names leadership, teamwork, and
  communication skills. Source: [NASA, Become An Astronaut](https://www.nasa.gov/humans-in-space/astronauts/become-an-astronaut/).
- The qualification page contains route alternatives and date-qualified
  wording, including degree alternatives and experience treatment. A route
  cannot flatten these into one mandatory education-and-promotion sequence or
  treat an old retrieved copy as timeless authority. The selection-program page
  states that applications open only as needed, so availability and exact
  eligibility must bind to a named vacancy/selection cycle before a route can
  describe them as current.
- NASA reports that more than 8,000 people applied in 2024 and 10 were selected
  as astronaut candidates. Selection therefore remains a competitive
  authority-owned decision after minimum qualifications; satisfying public
  gates is not a prediction of selection. Source: [NASA, Astronaut Selection
  Program](https://www.nasa.gov/humans-in-space/astronauts/astronaut-selection-program/).
- Selected candidates complete approximately two years of training before
  becoming eligible for flight assignment. Candidate training and later flight
  assignment are post-selection states, not preparation Steps the applicant can
  claim to complete in advance, and eligibility for assignment is not an
  assignment guarantee. Sources: NASA's selection-program page and [NASA,
  Astronaut Candidates Get to Work at Johnson Space Center](https://www.nasa.gov/centers-and-facilities/johnson/astronaut-candidates-get-to-work-at-johnson-space-center/).

The repository cannot currently pass this validation from source alone.
`DeterministicGoalPlanner.swift` recognizes the word `astronaut` and emits a
generic degree -> experience -> application-readiness progression. The current
career domain pack adds a placeholder saying requirements need confirmation;
it carries no NASA Source Reference or current qualification facts. Compiler
tests prove stable candidate structure and uncertainty behavior for supplied
fixtures, not that the astronaut route is factually current, that alternatives
are modeled correctly, or that private starting facts are safely matched.

This case sets the research boundary for an acceptable degraded result:

1. A source-bounded candidate may name an external gate or alternative only
   when the applicable NASA claim, authority, retrieval date, and freshness are
   available. User facts remain separately confirmed; absence of a user fact
   means `unknown`, not `unmet`.
2. With current public facts but insufficient private starting context, the
   result may show the sourced route envelope and ask neutral clarification. It
   may not claim personal eligibility, readiness, missing qualifications, or a
   required intermediate role.
3. If a material authority claim is stale, unavailable, contradictory, or not
   applicable to the user's intended program or region, the result falls below
   the domain-backed path threshold. It may preserve the Goal, show exactly
   which fact could not be established, and offer a plainly generic manual
   starter outline, but it may not present an authoritative or personalized
   candidate route.
4. No evidence state may turn competitive selection, the physical, candidate
   training, or flight assignment into a user-controlled milestone or success
   forecast. Unsupported equivalency, professional eligibility, and protected
   personal facts fail closed.

This degraded-path boundary preserves usefulness without allowing generic
planning to inherit the authority of a missing or stale domain source. Scope
still needs to define the observable review experience and confirmation
boundary; Design still owns how evidence and route facts are represented.

### Required semantic distinctions

A credible path proposal needs to keep at least these meanings separate:

- a hard eligibility gate versus a commonly observed preparation step;
- a prerequisite versus an optional strengthening activity;
- an official equivalency or substitution rule versus a similar capability;
- a user's capability evidence versus an external requirement;
- a currently available program/opening versus a route that exists in theory;
- an intermediate role option versus a required promotion;
- a competitive selection point versus a user-controlled milestone;
- post-selection training versus preparation before selection;
- a sourced fact versus a declared assumption;
- a candidate route versus the one accepted Goal Path version;
- a generated Step proposal versus a canonical Step; and
- route acceptance versus schedule placement.

## Alternatives

### 1. Generate a generic milestone list from the Goal title

This can provide immediate momentum and work offline, but it easily fabricates
requirements, hides uncertainty, and produces shallow plans for regulated or
high-consequence outcomes. It is suitable only as explicitly generic starter
planning where no claim of domain authority is made.

### 2. Require complete authoritative knowledge before showing any path

This maximizes factual caution but would make Ambitions unusable for novel,
personal, or poorly documented Goals. Canon already permits provisional paths,
clarification, manual continuation, and labeled assumptions. The better
boundary is honest degradation rather than all-or-nothing generation.

### 3. Use versioned public route packs plus local private composition

Public packs can describe known requirements, common alternatives, source
lineage, and freshness without receiving private facts. Local planning can
combine those references with user-confirmed Goal meaning, constraints,
capability evidence, and explicit assumptions. This direction best matches
Source Atlas and privacy canon, though it creates a significant curation,
freshness, mapping, and fallback burden.

### 4. Ask a hosted model to generate the personalized route

This may be flexible but conflicts with local authority and the prohibition on
exporting the private Goal graph. Model output also cannot certify public facts,
eligibility, viability, or mutation. Generative assistance could propose
bounded public structures or local explanatory language only within an
approved privacy boundary; it cannot become route authority.

### 5. Create several active Goal Paths and let the user switch among them

This appears natural for alternatives but violates one current Goal Path
identity and produces ambiguous Step, Proof, placement, and progress ownership.
Candidate routes can be compared side-effect-free; selection should produce a
version of the one owned path.

### 6. Encode every intermediate role, course, or credential as a Goal

This provides visible structure but confuses public route components with
user-owned outcomes and could flood Goals with unwanted commitments.
Intermediate items should remain sourced stages, requirements, or options until
the user explicitly chooses a canonical object transition.

## Unknowns and risks

- **Transfer beyond the validation case:** NASA astronaut candidacy establishes
  a hard validation boundary, but it does not prove that the same minimum
  source set or degraded result is right for education, licensing, hobbies, or
  creative Goals. Broader domains require their own authority and usefulness
  evidence.
- **Clarification burden:** asking every unresolved question before showing a
  route creates friction; assuming too much creates false authority. The
  threshold between safe assumption and blocking ambiguity needs product
  resolution.
- **Source ownership and freshness:** hard requirements may be governed by a
  licensing board, school, issuer, employer, provider, or program rather than a
  general taxonomy. Refresh and contradiction behavior must be inspectable.
- **Knowledge gaps:** hobbies and broad personal Goals lack an O*NET-like public
  source. Career coverage cannot masquerade as general path intelligence.
- **Crosswalk risk:** O*NET, ESCO, CTDL, CASE, CIP, and provider vocabularies
  differ in granularity and meaning. Label matching is not equivalency.
- **Starting-position accuracy:** capabilities are only part of readiness.
  Credentials, experience, resources, location, money, transport, equipment,
  time, eligibility, and user-chosen sensitive facts remain distinct.
- **Sensitive and professional boundaries:** route generation may expose
  health, disability, citizenship, finances, family, age, or legal context.
  Ambitions cannot adjudicate professional gates or infer protected facts.
- **Availability:** a valid route may have no current nearby provider, opening,
  seat, funding source, or schedule fit. Existence and availability require
  separate claims and freshness.
- **Path granularity:** too little detail produces a vague aspiration; too much
  detail creates false precision and large review overhead. The route must
  support progressive elaboration without identity churn.
- **Capability reuse:** evidence overlap can reduce redundant work, but it does
  not automatically satisfy a sourced condition. Formal recognition stays
  with the receiving authority.
- **Automatic object creation:** generated milestones, Steps, Proof targets,
  dates, and placements must remain proposals until their owners' confirmation
  boundaries. A single "accept path" action may still have several material
  scopes that need explicit disclosure.
- **One-path lineage:** candidate alternatives, rejection, later regeneration,
  and rollback must preserve the one current Goal Path identity and its version
  lineage without persisting a shadow set of active paths.
- **Determinism:** public source updates, collection order, and generative text
  must not make equivalent accepted inputs produce uninspectably different
  canonical results.
- **Accessibility:** route order, dependencies, alternatives, source status,
  current position, and actions need an ordered semantic form with named
  controls and focus restoration.
- **Proof ceiling:** existing compiler and projector tests do not establish
  factual quality, persistence, end-to-end activation, runtime scheduling,
  privacy egress, accessibility, performance, or device behavior.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Surfaces/Goals/GoalPathGenerationView.swift`.
- Evidence and unknowns: Repository audit identifies Task 5 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Continue toward **source-bounded, assumption-explicit candidate route
generation for an already-adopted Goal**. The generated output should be
treated as a reviewable simulation: it explains stages, dependencies,
requirements, alternatives, Proof expectations, sources, freshness, unknowns,
and safe manual continuation without creating accepted objects by itself.

Research favors current authoritative public facts with inspectable provenance
and a strict boundary around the user's private, confirmed starting position.
The generator should fail closed on unsupported hard claims while still
offering a plainly labeled generic or manual path when domain knowledge is
unavailable. It should avoid universal scores, guaranteed ladders, and
automatic conversion of public route components into Goals or Steps. Scope and
Design must still decide the observable contract and technical means; this
Research does not require a particular pack, storage, retrieval, or composition
architecture.

The next Scope should use NASA astronaut candidacy as the bounded validation
case, choose an observable product promise within the degraded-path boundary,
settle how assumptions and unavailable authority appear, and define the review
boundary before one current Goal Path version is accepted. It should not assume
that validating this difficult case requires shipping an astronaut-specific
product or that it proves other domains. It should leave architecture and exact
data representation to Design, preserve optional scheduling as a later commit,
and route qualitative review and selection among multiple candidates to the
separate `adaptive-path-comparison` initiative. This initiative constructs
candidates and owns review of one generated route. When comparison returns one
selected proposal, the canonical Goal Path activation boundary still owns
freshness revalidation, explicit confirmation, and creation of the new version;
neither generator nor comparison simulation mutates the Goal Path by itself.

`public-reference-knowledge-foundation` is a conditional dependency whenever
generation makes sourced route, gate, availability, or freshness claims. A
plainly generic or manual degraded path may proceed without that dependency but
must not inherit its authority.
