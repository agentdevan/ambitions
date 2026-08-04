+++
initiative = "destination-adoption-and-pivot"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions may eventually identify a career, education, hobby, or other life
direction that appears worth exploring because it fits the user's stated
interests, preserves useful progress, or exposes a new possibility. That idea
is not yet a Goal. The user needs a deliberate way to inspect it, keep it
without pressure, reject it, or adopt it as an outcome they actually want.

The same boundary becomes more important when the user changes direction. A
person who began a path toward one destination may later decide that the
destination itself is no longer right. Ambitions should help the user preserve
honest completed work, Proof, capability evidence, and history while choosing
what happens to the old Goal and whether a different destination becomes a new
Goal. It must not disguise a changed destination as routine route adaptation.

This Research therefore examines two connected transitions:

1. a recommendation candidate, aspiration, or dormant direction becoming a
   user-owned Goal; and
2. a user deliberately leaving one desired outcome for a different desired
   outcome while carrying forward only progress that honestly remains useful.

The product distinction is load-bearing. A recommendation candidate is an
advisory possibility. A Goal is a stable desired outcome the user has chosen.
A Goal Path is the living route toward that chosen outcome. Changing the route
while keeping the outcome is not a destination pivot. Changing the outcome is
not merely a new Goal Path version. Neither transition may be inferred from
inactivity, missed work, capability overlap, or a recommendation score.

## Current truth

This Research used baseline main SHA: `40894e92c61de55841c31fd797fd5ae39625c5dc`,
current canon, live source, focused
tests, and the umbrella Research at
`docs/product-development/adaptive-skills-and-pathways/research.md`. Source and
test presence are implementation evidence only; the focused tests cited below
were inspected rather than executed for this document.

Canon already fixes much of the authority boundary:

- `OBJ-GOAL-IDENTITY-001` defines a Goal as one stable desired outcome with a
  living route. A Goal may own at most one current Goal Path plus version
  history. It is not an AI-owned plan or a recommendation candidate.
- `OBJ-GOAL-AUTOMATION-LADDER-001` permits local, non-sensitive Goal
  suggestions only when rationale, uncertainty, confirmation, correction, and
  disablement are available before creation.
- `SYSTEM-LEARNING-GOAL-SUGGESTION-001` requires suggestions to remain local,
  inspectable, reversible, confidence-bounded, and unable to mutate canonical
  Goal state without confirmation.
- `CONTROL-FORCE-NOTHING-001` lets Ambitions suggest, warn, and simulate but
  reserves the decision to choose a Goal or tradeoff to the user.
- `JOURNEY-GOAL-ACTIVATION-001` says Goal creation first commits a provisional
  Goal shell and original intent. Route, Step, and placement proposals remain
  non-durable until later reviewed confirmation, and scheduling is a separate
  commit boundary.
- `OBJ-GOAL-PATH-IDENTITY-001` preserves one versioned Goal Path identity for a
  selected outcome. Regeneration and reflow create versions, not unrelated
  parallel canonical paths.
- `OBJ-HISTORY-EVENT-IDENTITY-001` says prior progress should transfer as
  context, Proof, skill, resource knowledge, or capability knowledge when a
  Goal changes or pivots. It does not say the original Goal should be rewritten
  into a different outcome.
- Goal, Proof, Closure, History, archive, Trash, and permanent deletion each
  have distinct lifecycle meaning. Ending an old direction must not erase what
  actually happened, and carrying Proof forward must not fabricate completion
  against the new destination.

Canon also provides a candidate boundary for unresolved input. A
Saved-for-Later Draft may preserve original input, inferred route candidates,
and later promotion lineage, but its candidates remain advisory links rather
than canonical objects before explicit promotion. Dismissal is non-destructive.

The live source contains an adjacent `NorthStar` value model. It can retain a
long-range direction with dormant, active-direction, parked, ready-to-shape,
needs-review, or archived postures. It exposes `canBeShaped`, a
`shapeIntoGoalLabel`, and reference hooks to later Goals, paths, milestones,
Steps, Proof, decisions, and reviews. `NorthStarModelsTests.swift` includes a
"Become an Astronaut" fixture and asserts that a dormant North Star can remain
held without creating a Goal. The redacted projection also says that no Goal is
created automatically.

That source seam is useful but incomplete. No normative North Star object
specification was found. The source model does not by itself establish the
canonical promotion command, duplicate handling, old-Goal closure decision,
progress-transfer review, rollback, or a finished user-facing experience. A
future Scope must not treat the presence of `NorthStarModels.swift` as settled
product ownership.

Other source models provide partial pivot ingredients:

- `AlternatePathPortfolio.swift` represents active, alternate, paused, future,
  retired, exploration, fallback, and North Star path candidates. Its
  validation rejects hidden life-graph mutation, guaranteed outcomes, shame
  language, unsupported Proof transfer, unsafe external projection, and stale
  professional or source-sensitive paths.
- `AmbitionsOSPathChangeReceipt` records a from-path, to-path, reason, and Proof
  that still counts. This is a useful value-model seam, not evidence that a
  changed destination can be adopted safely.
- `ProofResourceGraphModels.swift` provides deterministic classifications for
  whether supplied Proof may be preserved, needs review, or is not
  transferable between already-known object identities. It does not discover
  a destination, decide that the user wants it, or establish external credit.
- `GoalPathCompilerModels.swift` and `PathIntelligenceModels.swift` can express
  candidate interpretations, assumptions, requirements, risks, fallback
  routes, and scenarios. Their candidates remain planning projections; they do
  not confer Goal identity.

No complete source/test flow was found that starts with a capability-informed
destination candidate, lets the user hold or reject it, adopts it into a
canonical Goal, deliberately resolves an existing Goal with a different
outcome, preserves transferable progress, and proves receipt/replay/rollback
across all affected identities.

## Evidence

### Product and repository evidence

- The Goal object and Goal activation journey establish the decisive boundary:
  advice can exist before commitment, while Goal identity begins only through
  an explicit durable user-owned transition.
- The umbrella Research found that capability overlap is suitable for
  candidate generation but insufficient for destination selection. Interest,
  exclusions, Life Area, motivation, location, eligibility, resources, and
  user-chosen aspirations remain independent inputs.
- The umbrella Research also distinguishes five meanings often collapsed into
  "this still counts": retained personal evidence, overlap with a destination,
  apparent satisfaction of a sourced condition, recognition under a named
  policy, and formal acceptance by an external authority. Adoption must not
  overclaim any of the latter four.
- `NorthStarModelsTests.swift` shows a source-backed way to preserve a dormant
  direction without Goal creation. It supports the product need for an
  exploration state, but the lack of normative ownership means Research cannot
  select North Star as the required persistence architecture.
- `AlternatePathPortfolioTests.swift` and `MultiPathLatticeTests.swift` assert
  that path portfolios do not mutate the life graph during comparison, that
  explicit selection is required, and that source, Receipt, replay, and
  inspection gaps block selection. Those tests concern supplied route
  candidates, not the full destination-adoption journey.
- Goal and History canon preserve old identity and mutation lineage. A new
  destination can reuse relevant evidence without retroactively changing why
  the old Goal existed or what its Closure meant.

### Domain evidence carried forward from portfolio synthesis

The umbrella Research examined O*NET, BLS, ESCO, CTDL, CASE,
CareerOneStop, credential standards, and career-mobility research. Together
they show that capability adjacency can identify plausible options but cannot
decide desire, eligibility, availability, formal transfer, hiring, or success.
For example, NASA's published astronaut requirements identify current
eligibility and selection inputs, not a guaranteed ladder or an instruction
that a person should adopt the destination.

This supports a two-stage product posture: public and local evidence may
justify "worth exploring," while only the user can decide "this is now my
Goal." It also supports preserving an aspirational exploration lane whose
options do not need high overlap with the user's history. Otherwise capability
continuity could narrow the person's future to historically adjacent choices.

### Boundary examples

- **Recommendation candidate:** "Your project coordination experience may
  carry into technical program management." This may be inspected, saved,
  dismissed, or explored. It is not a Goal.
- **Dormant aspiration:** "Become an astronaut" may remain a direction held
  without pressure. It has no current Goal Path or scheduled Steps.
- **Adopted destination:** after explicit review, "Qualify to apply for an
  astronaut-candidate program" could become a Goal with a provisional shell.
  Route generation and scheduling still have later confirmation boundaries.
- **Same-outcome route change:** choosing a different degree, intermediate
  role, or preparation sequence while keeping the same desired outcome is a
  Goal Path version decision, not a new destination.
- **Changed destination:** deciding to pursue aerospace safety engineering
  instead of astronaut candidacy changes the desired outcome. The old Goal's
  lifecycle and Closure need an honest user decision; relevant Proof and
  capability evidence may be linked to the new Goal without copying or
  rewriting them.
- **Cross-object life conflict:** if that pivot also requires coordinated
  changes across several already-real Goals, Time placements, Proof rules, and
  external commitments, it may later qualify for Life Branch reconciliation.
  The unselected destination suggestion itself is not a Life Branch.

## Alternatives

### 1. Turn every accepted recommendation directly into a Goal

This is simple and action-oriented, but it collapses exploration into
commitment and lets the recommendation system manufacture canonical intent.
It would create Goal clutter, pressure users to maintain options they never
chose, and violate the Goal suggestion and Force Nothing boundaries.

### 2. Keep all possible destinations as Goal drafts

Provisional Goals preserve intent safely, so this avoids silent activation.
However, it still assigns Goal identity too early and makes low-commitment
exploration indistinguishable from a desired outcome the user has begun to
shape. It may work for an explicitly entered outcome but is a poor default for
system-generated candidates.

### 3. Maintain a separate candidate or dormant-direction state, then promote

This preserves the strongest semantic boundary. A candidate can be explained,
saved, corrected, dismissed, or parked without creating a Goal. Explicit
adoption then crosses into the existing provisional-Goal journey, and route
review follows separately. The unresolved question is which existing owner—an
earned suggestion, Saved-for-Later Draft, North Star, or a smaller relationship
record—should carry the pre-Goal state.

### 4. Edit the existing Goal title and outcome in place when the user pivots

This minimizes object count but destroys the distinction between route
adaptation and a changed destination. It risks rewriting historical meaning,
misattributing old Proof to the new outcome, and making rollback or inspection
misleading.

### 5. End or pause the old Goal and explicitly adopt a new Goal with links

This preserves both outcome identities and lets the user choose the old Goal's
honest lifecycle state. Reusable evidence can be related rather than copied.
It has more reconciliation work and must avoid presenting "start over" or
"failure" language. Research currently favors this semantic direction, while
leaving exact lifecycle choices to Scope.

### 6. Treat every pivot as a Life Branch

Life Branch can reconcile complete cross-object alternatives, but using it for
an unselected destination or a single Goal change would be overpowered and
canonically incorrect. Life Branch is a semantic delta across already-real
canonical objects; it is not a recommendation container or a second Goal.

## Unknowns and risks

- **Pre-Goal owner:** canon does not yet identify one normative object for a
  dormant recommendation candidate. Saved-for-Later Draft and the source-level
  North Star model offer different semantics. Scope must settle observable
  behavior before Design selects or introduces ownership.
- **Adoption vocabulary:** "Explore," "Save for later," "Shape into a Goal,"
  and "Make this a Goal" imply different commitment. The language must make
  the durable boundary obvious without implementation theater.
- **Pivot lifecycle:** the user may want to pause, end, complete, archive, or
  retain the old Goal while adopting a new one. Automatic closure would be
  dishonest; requiring a large reconciliation form could make changing one's
  mind punitive.
- **Identity and duplicates:** a candidate may already correspond to a dormant
  direction, provisional Goal, active Goal, or an equivalent outcome worded
  differently. Adoption needs duplicate and relationship review without an
  opaque semantic merge.
- **Transfer overclaim:** old Proof can remain relevant without satisfying a
  new requirement. Reuse must distinguish personal continuity, contextual
  overlap, and authoritative acceptance.
- **Selective transfer:** users need to understand why some evidence carries,
  some requires review, and some is unrelated. "Not transferable here" must
  never imply that the underlying work was worthless.
- **Recommendation bias:** suggestions based mainly on past capability overlap
  can reproduce occupational or access bias and suppress aspirational options.
  An exploration lane and user-entered destinations remain necessary.
- **Sensitive outputs:** a destination suggestion can reveal inferred health,
  citizenship, religion, finances, age, disability, or family context even if
  its inputs were not labeled sensitive. Cross-domain inference needs a much
  stricter boundary than ordinary relevance matching.
- **Source freshness:** occupation, program, license, and selection facts may
  change. A candidate must not look adoptable merely because a stale public
  route once existed.
- **Professional authority:** Ambitions cannot decide medical fitness,
  licensing, admissions, hiring, transfer credit, or credential acceptance.
  Adoption expresses the user's intent, not external eligibility.
- **Rejection learning:** dismissing one candidate may mean "not now," "not
  this outcome," "bad rationale," or "do not use this evidence." Treating all
  rejections as one permanent preference would create a hidden profile. The
  safe default is dismissal of the exact candidate, rationale or evidence, and
  current review context only. Any broader suppression must be a separate,
  explicit action whose scope and consequence are inspectable, resettable, and
  never silently converted into a durable preference or trait.
- **Rollback and history:** undoing adoption must preserve the candidate,
  provisional Goal Receipt, and any separately accepted clarification or
  lifecycle decisions without duplicating later retries.
- **Accessibility:** candidate comparison, adoption consequences, transferred
  progress, old-Goal options, and confirmation must have ordered nonvisual
  semantics and named controls; relationship diagrams cannot be required.
- **Proof ceiling:** current models and focused tests do not prove the complete
  user flow, persistence, privacy egress, replay, accessibility, or runtime
  behavior.

## Recommended direction

Continue product discovery around an explicit **candidate-to-Goal adoption
boundary** and an equally explicit **changed-destination pivot boundary**.
Recommendation candidates should remain non-canonical possibilities that can
be inspected, parked, dismissed, or deliberately promoted. Promotion should
enter the existing provisional Goal journey; it should not also accept a route
or schedule by implication. Dismissal should be candidate- and session-local by
default. The product may remember a broader exclusion only when the user
deliberately chooses its scope and can later inspect, correct, or reset it.

For a deliberate pivot, preserve the old Goal, Closure choice, Proof, History,
and capability lineage while examining a separately identified new outcome.
Research favors relating reusable evidence rather than copying it, and favors
an honest lifecycle decision for the old Goal rather than editing its outcome
in place. Same-outcome route changes should remain Goal Path version decisions.

The next Scope should decide the smallest user-visible adoption and pivot
experience, including candidate retention, explicit confirmation, old-Goal
choices, transfer explanation, cancellation, and recovery. It should not yet
select the persistence architecture, automatically create a Goal from a
recommendation, treat a selected destination as an accepted route, or invoke
Life Branch unless multiple already-real canonical objects require a complete
cross-object alternative.
