+++
initiative = "adaptive-path-comparison"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

A chosen destination can often be reached through more than one plausible
route. One route may preserve more completed work, another may cost less, a
third may fit present capacity, and a fourth may keep more options open. A user
needs to compare these possibilities without Ambitions collapsing them into a
single opaque recommendation or silently replacing the route they already
accepted.

Adaptive path comparison concerns **multiple routes toward the same stable Goal
outcome**. It should help the user understand tradeoffs among continuing the
current route, changing preparation, using a different intermediate role or
education option, pausing, taking a smaller first move, or testing a bridge
milestone. It may explain which Proof or capability evidence remains relevant,
which requirements differ, and what time or resource pressure each candidate
would create.

It does not choose a new destination. If the desired outcome changes, that is a
destination-adoption-and-pivot problem. It does not create parallel canonical
Goal Paths: canon permits one current Goal Path identity with version lineage.
It does not mutate Goals, Steps, Proof, or Time during comparison. It is also
not a Life Branch unless an alternative is complete across several already-
real canonical objects, not merely a different route or timeslot.

## Current truth

This Research used baseline main SHA: `40894e92c61de55841c31fd797fd5ae39625c5dc`,
current canon, live source, focused
tests, and the umbrella Research at
`docs/product-development/adaptive-skills-and-pathways/research.md`. The tests
below were inspected rather than executed for this document. Their value-model
assertions do not establish a complete runtime or user experience.

Canon establishes a precise comparison boundary:

- `OBJ-GOAL-IDENTITY-001` keeps the Goal outcome stable while its route adapts.
- `OBJ-GOAL-PATH-IDENTITY-001` permits one versioned current Goal Path identity
  per Goal. Regeneration, reflow, node edits, and recovery produce versions,
  not parallel unlinked canonical paths.
- `OBJ-GOAL-PATH-RECEIPT-001` requires material path change to be previewed,
  confirmed, receipted, and replayable. Rejecting the preview preserves the
  current path.
- `OBJ-GOAL-PATH-ADAPTATION-TRIGGERS-001` allows adaptation in response to
  missed Steps, changed time reality, Proof or completion changes, learned
  behavior, and new scheduled Steps, while preserving confirmation and
  reversibility for material effects.
- `OBJ-GOAL-PATH-ADAPTATION-BOUNDARY-001` requires assumptions and consequences
  to be visible and prior path history to survive.
- `SYSTEM-RUNTIME-SIMULATION-001` requires deterministic, local,
  side-effect-free, inspectable, and bounded simulation until commit.
- `CONTROL-FORCE-NOTHING-001` gives the user authority to reject a
  recommendation, accept a conflict, choose a different tradeoff, or withdraw
  delegated authority.
- `SYSTEM-LEARNING-CONTROL-001` requires changed Life Capital to resimulate
  affected paths and show impact. Capabilities do not decay automatically.
- `JOURNEY-LIFE-BRANCH-SELECTION-001` reserves Life Branch for bounded,
  complete ways forward across existing Goals, Today, Time, Proof, recovery,
  recipients, or external systems when the current branch cannot remain valid.
  A route-only option is not automatically that object.

The live source contains unusually direct comparison seams:

- `AlternatePathPortfolio.swift` models active, alternate, backup, paused,
  future, retired, completed, superseded, exploration, fallback, North Star,
  source-check-first, and professional-boundary candidates. Each candidate can
  carry requirement slots, transferable Proof Receipt IDs, requirement
  overlap, source claims, freshness, review state, privacy class, and
  professional boundaries.
- `AmbitionsOSPathPortfolio` defaults to `mutatesLifeGraph = false` and a
  `valueModelOnly` runtime boundary. Its validator blocks hidden mutation,
  guaranteed outcomes, shame language, unsafe external projection, stale
  source-sensitive candidates, and unsupported Proof transfer.
- `MultiPathLattice.swift` builds candidates and comparison rows with tradeoffs
  for capacity, Proof continuity, source confidence, time fit, reversibility,
  and privacy. It requires at least two viable paths, explicit selection,
  source records, Receipts, replay traces, inspection routes, and comparison
  tradeoffs before its value-level runtime segment can become ready.
- `PathIntelligenceModels.swift` offers route forks and future-self scenarios.
  Focused tests require "Scenario, not prediction," user correction prompts,
  and qualitative copy that avoids "best path," "highest score," and promises
  about what will happen.
- `ProofResourceGraphModels.swift` can classify supplied Proof as preserved,
  review-required, or non-transferable between supplied objects based on
  overlap, freshness, and contradiction. This is useful comparison evidence,
  not proof of proficiency or official recognition.
- `StepImpactSimulationSupport.swift` provides a consequence-preview seam for
  Step changes. It does not establish a complete path portfolio or accepted
  Goal Path transition.

Focused tests are directionally strong. `MultiPathLatticeTests.swift` asserts
that no route can drive execution before explicit selection, selection produces
a value-level Receipt/persistence snapshot, missing tradeoffs block comparison,
missing source/Receipt/replay/inspection data blocks the selected candidate,
ordering is stable, and hidden mutation or unsafe projection blocks the
lattice. `AlternatePathPortfolioTests.swift` asserts the non-mutating value
boundary and source/review requirements. `PathIntelligenceProjectorTests.swift`
asserts qualitative scenarios and avoids user-facing score authority.

However, these tests do not prove that the lattice is integrated with the
canonical Goal Path owner, that selection creates exactly one new Goal Path
version through the required mutation sequence, that rejected candidates stay
non-canonical, or that comparison is available, accessible, private, and
recoverable in the app. Some source names imply persistence or runtime
readiness, but current canon remains the authority and source presence is not a
runtime proof claim.

## Evidence

### Product and canon evidence

- A Goal Path is already a living route, so comparison should inform a version
  decision rather than establish a second path identity system.
- Material adaptation must show before/after consequences and preserve the
  previous version. This supports reversible route selection rather than a
  destructive replacement.
- Simulation is explicitly distinct from mutation. Candidate generation,
  comparison, editing, and rejection must leave canonical Goal, Path, Steps,
  Proof, and placements unchanged.
- Scheduling canon requires capacity, transitions, Protected/Fixed time, Step
  shape, energy/context, and downstream consequences. Comparison may use a
  schedule-pressure simulation but cannot commit placements.
- Proof canon prohibits grading by strength. A route can show evidence overlap
  and missing requirements without a weighted capability or employability
  score.
- Accessibility canon requires route order, state, rationale, Proof rules,
  schedule impact, and actions in an ordered nonvisual representation. A visual
  comparison matrix cannot be the only meaningful surface.

### Source and test evidence

- The path portfolio models already distinguish route kind, source/freshness,
  professional boundary, privacy, Proof continuity, and hidden mutation risk.
  This is a stronger base than a generic list of AI options.
- The lattice's explicit-selection and fail-closed tests support the correct
  authority posture. They also reveal the proof ceiling: the engine consumes
  preassembled candidates and metadata rather than discovering or validating
  real-world routes.
- The available tradeoff dimensions are useful but incomplete as product
  semantics. `weight: Int` exists in the value model; current evidence does not
  authorize exposing weights, summing them, or selecting the highest score.
- Path-intelligence scenarios demonstrate a humane framing for continue,
  smaller-first, fallback, and waiting-review options. They remain scenarios,
  not predictions or canonical path versions.
- Proof-transfer fixtures require requirement overlap and source claims, which
  supports traceability. The result still cannot claim that a school, employer,
  licensing body, or credential issuer accepts the transfer.

### Domain evidence carried forward from portfolio synthesis

The umbrella Research found that route comparison should include more
than skill adjacency. Depending on the destination, credible tradeoffs may
include hard eligibility, education/training, location, cost, duration range,
current availability, resource access, selection risk, reversible first moves,
schedule pressure, Proof portability, and source freshness. These are
heterogeneous facts and should not be compressed into one compatibility score.

CTDL pathway models and recognition-of-prior-learning concepts reinforce the
need to distinguish route structure, transfer policy, submitted evidence, and
receiver decision. O*NET, BLS, and ESCO support occupation and capability
relationships but do not establish one employer's path, one user's eligibility,
or a guaranteed outcome. A bridge milestone can be described as
option-preserving when it advances multiple sourced routes or produces portable
Proof; simulation cannot promise that it will cause admission, selection,
promotion, or employment.

### Boundary examples

- **Same outcome, different route:** for "qualify to apply for astronaut
  candidacy," compare an experience route and a pilot-hours route when both are
  supported by current sources. Selecting one creates a reviewed version of
  the same Goal Path identity.
- **Smaller first move:** compare committing to a degree program with first
  validating interest through a sourced prerequisite course. The smaller move
  is a candidate route or stage, not a new destination by implication.
- **Pause:** show what remains current, what may become stale, and what evidence
  still counts if the route is paused. Pausing is not failure and does not
  delete the path.
- **Bridge:** compare a milestone that supports several routes against a more
  specialized commitment. "Option-preserving" describes the modeled overlap;
  it is not a prediction.
- **Changed destination:** comparing astronaut candidacy with aerospace safety
  engineering changes the outcome and belongs in destination adoption/pivot,
  even if many capabilities overlap.
- **Cross-object alternative:** a choice that simultaneously changes several
  Goals, protected schedules, external commitments, and Proof conditions may be
  a complete Life Branch candidate. Merely moving one route or timeslot is not.

## Alternatives

### 1. Show one recommended path

This is cognitively simple but hides tradeoffs, overstates model authority, and
makes it difficult to preserve user values that were not part of ranking. It
also encourages an opaque "best path" posture rejected by current tests and
canon.

### 2. Rank every candidate with a composite score

A score appears comparable but mixes unlike claims: factual eligibility,
capacity fit, user preference, source confidence, cost, reversibility, and
Proof overlap. Weighting them silently would turn a planning aid into hidden
life authority. Internal deterministic ordering may be needed for presentation,
but it is not a user verdict.

### 3. Present a qualitative, evidence-linked comparison

Each candidate states what it preserves, changes, assumes, requires, costs,
leaves unknown, and does to near-term Time. The user can inspect evidence,
correct inputs, edit an option, reject all, or select explicitly. This best
matches current canon and source direction, though it requires careful
information hierarchy and cannot hide behind one number.

### 4. Persist all candidates as parallel Goal Paths

This would make alternatives recoverable but violates the one-current-path
identity and creates ambiguous ownership for Steps, Proof, placements, and
progress. Candidate comparison state may need durable draft recovery, but
durability does not make each candidate a canonical Goal Path.

### 5. Treat route comparison as Life Branch reconciliation

Life Branch has stronger cross-object certification, complete correction sets,
and atomic promotion semantics. Applying it to every route fork would add
unnecessary complexity and violate the rule suppressing timeslot-only or
consequence-equivalent branches. It becomes relevant only when a complete
alternative spans several canonical owners.

### 6. Let schedule fit select the path automatically

Capacity is important, but the easiest route to schedule may conflict with the
user's motivations, values, costs, or long-term intent. Schedule fit is one
explainable tradeoff and never path-selection authority.

## Unknowns and risks

- **Comparison set:** too many alternatives overwhelm review; too few may hide
  materially different routes. Research does not yet justify a universal count
  or pruning threshold. Every eligible candidate needs an inspectable inclusion
  or omission reason, and omitted candidates must remain discoverable rather
  than disappearing behind a hidden score.
- **Meaningful difference:** candidates should differ in consequences, not
  wording or timeslot. The rule for suppressing equivalent routes needs a
  stable, explainable product meaning.
- **Tradeoff vocabulary:** the current source dimensions are a useful start but
  may omit money, location, availability, credential validity, external
  authority, relationship impact, or user-defined priorities. Scope must avoid
  an unbounded comparison dashboard.
- **Weight leakage:** source has numeric weights and internal scalar scores.
  They must not become a compatibility, ability, employability, success, or
  path-authority score.
- **Candidate provenance:** every hard gate and route distinction needs source,
  version, region, freshness, and uncertainty. Stale inputs may invalidate one
  candidate without invalidating all.
- **Private inference:** comparing routes can reveal sensitive capability,
  health, finances, citizenship, family, location, or schedule context. Public
  reference systems must never receive personalized candidate queries.
- **Evidence transfer:** overlap, personal continuity, policy recognition, and
  formal acceptance are different. "Still counts" must identify which meaning
  applies.
- **Current-path baseline:** a comparison is misleading if it omits completed
  nodes, accepted Proof, current placements, source changes, or user edits from
  the active Goal Path version.
- **Staleness during review:** Time, Proof, source facts, Goal edits, or
  capability corrections may change before selection. The comparison and
  selected candidate need revalidation before commit.
- **Selection scope:** accepting a route version must not silently accept all
  proposed Steps, Proof rules, dates, or placements unless each consequence is
  disclosed under the owning confirmation boundary.
- **Rejected candidates:** rejection should preserve the active path and enough
  explanation/history for trust without turning discarded simulation into
  canonical object clutter.
- **Rollback:** undo must restore the prior Goal Path version and affected
  accepted relationships without deleting the selection Receipt or pretending
  subsequent started work never occurred.
- **Accessibility:** route comparison must remain understandable as an ordered
  list with candidate identity, tradeoffs, source/unknown state, inclusion,
  selection consequence, and named actions. No chart, color, swipe, or spatial
  lattice can be required.
- **Proof ceiling:** current tests demonstrate value-model constraints, not the
  full mutation boundary, app integration, persistence, replay, privacy,
  accessibility, performance, or device behavior.

## Recommended direction

Continue with a **qualitative, source-bound, side-effect-free comparison of
meaningfully different routes toward one stable Goal outcome**. Comparison
should preserve the current Goal Path as the baseline, show reusable progress
and route-specific gaps, expose assumptions and freshness, and let the user
edit, reject all, defer, or explicitly choose without a composite score. A
bounded display should use explainable diversity and ordering, not compatibility
authority: each included or omitted route retains a visible reason, and an
omitted route remains available for deliberate inspection.

Research favors retaining candidates as simulation state through qualitative
review. This initiative owns selection among multiple same-outcome candidates
and returns one selected proposal; it does not activate it. The canonical Goal
Path boundary must then revalidate current facts and, after explicit
confirmation, create a new version under the existing one-current-Goal-Path
identity. Neither simulation owns that canonical mutation. Selection must not
silently create a different Goal or commit Time placements. A changed
destination should handoff to the separate adoption-and-pivot lifecycle; a
complete cross-object alternative should handoff to Life Branch only when its
stricter semantic threshold is met.

Goal Path generation is a dependency when comparison consumes generated route
candidates; manually supplied or already-existing candidates may enter only
under an equivalent source, identity, and freshness contract.

The next Scope should settle the bounded candidate set, comparison dimensions,
current-path baseline, correction and staleness behavior, explicit selection
consequences, and accessible review experience. It should not select a scoring
algorithm or storage architecture and should not assume that the current
portfolio/lattice value models already satisfy the canonical runtime path.
