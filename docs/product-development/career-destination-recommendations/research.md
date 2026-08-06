+++
initiative = "career-destination-recommendations"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

When a user has accumulated useful capabilities through Goals, work,
education, or hobbies, Ambitions should be able to help them explore career
directions that reuse that progress. The value is greatest during a pivot: the
user may no longer want the original destination, but the work already done
should not disappear from the next decision.

The user does not need a verdict about the one career they "should" pursue.
They need a small set of plausible destinations with an honest explanation of:

- which user-confirmed capabilities and evidence appear reusable;
- which capabilities or prerequisites are missing or uncertain;
- which requirements are typical descriptions versus hard legal,
  certification, employer, or selection gates;
- whether an intermediate role is a source-supported option or merely one
  possible route;
- which work context, education, experience, location, pay, and outlook facts
  are public reference rather than personalized predictions; and
- what information Ambitions does not know.

The astronaut scenario remains a useful stress case. "Become an astronaut" is
a legitimate long-range destination, but it cannot be reduced to an occupation
skill match. NASA's current selection requirements, education and experience,
medical qualification, competitive selection, and training authority matter.
An honest recommendation system could surface adjacent destinations that reuse
verified progress, but it must not promise selection, invent a promotion chain,
or call a user qualified from inferred skills.

This Research isolates career destination discovery and explanation from
public-reference ingestion, education recommendation, route generation,
destination adoption, scheduling, credential import, and capability capture.
It explores what makes a career recommendation trustworthy; it does not commit
the number of recommendations, a scoring model, a UI, or an implementation.

## Current truth

This Research inspected `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, the umbrella portfolio synthesis,
current canon, relevant Source Atlas and recommendation source, tests, and
retained production-pack evidence. The umbrella synthesis has been reopened as
a draft for domain decomposition and is not current approval authority for
this initiative. External sources were reviewed on 2026-08-03. Tests were
inspected, not executed.

Canon already permits but sharply constrains this idea:

- `MISSION-FUNCTION-001` and `MISSION-MOAT-CONTINUITY-001` require contextual
  Goal Paths, proof-backed progress, learning continuity, and recommendations
  whose reason survives over time.
- `OBJ-HISTORY-EVENT-IDENTITY-001` says prior progress may transfer as context,
  Proof, skill, resource knowledge, or capability knowledge after a Goal
  changes or pivots.
- `SYSTEM-LEARNING-GOAL-SUGGESTION-001` allows local Goal suggestions only when
  inspectable, reversible, confidence-bounded, and incapable of changing Goal
  state without confirmation.
- `CONTROL-FORCE-NOTHING-001` and Goal activation law require recommendations,
  route proposals, and adoption to remain distinct. A destination suggestion
  cannot silently become a Goal or active path.
- Life Capital is broader than employability and must not become a score,
  rank, streak, badge system, or hidden personality profile.
- Source Atlas may deliver public occupational context, but matching public
  data to private capabilities must happen locally and must not send private
  intent, Proof, history, or rejection upstream.
- A generic capability-use setting is not consent for career exploration. The
  user must deliberately start the exploration and select the private inputs
  that may influence it. Protected facts are never inferred. A protected input
  may participate only when the user deliberately selects that exact fact after
  a fresh purpose-specific disclosure and consent. If classification is unknown
  or a derived destination or explanation reveals protected context beyond that
  consent, the affected result remains quiet rather than substituting a proxy.

The live source offers useful seams without completing the product behavior:

- The retained `occupation_foundation` public pack contains 26 packable claims
  sourced principally from O*NET and BLS, plus explicit non-claims. Inspection
  shows bounded fixture facts about selected occupations and labor-market
  context, not comprehensive occupation-capability coverage.
- Source Atlas models capability graphs, role overlays, path overlays,
  requirements, source/freshness states, proof maps, and alternative path sets.
  `SourceAtlasCapabilityPathComposer` calculates an internal scalar to choose
  among already supplied path overlays. That score is not canonical authority
  for employability, compatibility, success, or a "best career."
- `AmbitionsOSPathPortfolio` distinguishes active, alternate, fallback,
  paused, future, and source-check-first paths, preserves overlapping Proof,
  blocks guaranteed-outcome and shaming language, and requires explicit path
  change Receipts. It compares already-known candidates; it does not discover
  careers.
- `RecommendationEngine` selects a current local action from a canonical
  `NowState`. It does not recommend destinations.
- Recommendation explanation adapters preserve reasons, evidence categories,
  confidence, corrections, and local-only state for existing Goals. They are a
  possible explanation seam, not proof of career recommendation behavior.
- North Star source can retain an identity-level direction such as "Become an
  Astronaut" without automatically creating a Goal. Canon has not yet assigned
  North Star complete normative ownership.

No current source or test proves an end-to-end flow from user-approved
capability evidence to a source-backed set of career destinations. No evidence
was found for calibrated recommendation quality, occupational coverage,
regulated-role gating, geographic applicability, work-values fit, false-match
rates, or user comprehension of why one destination was suggested.

## Evidence

### Repository and product evidence

- `docs/product-development/adaptive-skills-and-pathways/research.md` concludes
  that capability continuity should precede any destination consumer and that
  a future path must not treat skills as the whole person.
- `docs/canon/specifications/systems/local-learning.md` permits only local,
  evidence-linked, non-sensitive capability influence with uncertainty,
  inspection, correction, disablement, reset, archive, and deletion controls.
- `docs/canon/specifications/objects/goal.md` requires a provisional Goal and
  explicit review if pathing cannot honestly finish. A career suggestion must
  therefore tolerate missing source data without fabricating a complete path.
- `SourceAtlasCapabilityPathCompositionModelsTests` demonstrates deterministic
  path selection and safe fallback for synthetic known paths. It does not test
  career discovery or employability.
- `AlternatePathPortfolioTests` rejects guaranteed outcomes, hidden mutation,
  unsafe private projection, and unsourced professional-boundary paths. Those
  are appropriate constraints for career candidates.

### External career evidence

All external links below were accessed on 2026-08-03.

- The [O*NET 30.3 database](https://www.onetcenter.org/database.html) provides
  versioned United States occupation descriptions across skills, knowledge,
  abilities, tasks, work activities, work context, education, experience,
  training, and other worker/job characteristics. O*NET reports quarterly
  database updates, so recommendation evidence must bind to a release and
  preserve changes.
- The [O*NET Content Model](https://www.onetcenter.org/content.html) expressly
  separates skills and knowledge from abilities, interests, and work styles.
  Ambitions should not relabel a Work Style or inferred personality tendency as
  a learned soft skill, nor use it to profile the user silently.
- The [BLS Occupational Outlook Handbook](https://www.bls.gov/ooh/About/Occupational-Information-Included-in-the-OOH.htm)
  adds typical duties, work environment, entry education, related experience,
  on-the-job training, pay, outlook, and similar occupations. The
  [BLS disclaimer](https://www.bls.gov/ooh/about/disclaimer.htm) says this is a
  national composite, does not reflect every establishment or locality, does
  not establish licensing or practice standards, and should not determine
  whether a person is qualified. These caveats belong in the product's claim
  model, not a footnote hidden from the recommendation.
- [ESCO](https://esco.ec.europa.eu/en/use-esco) supplies multilingual
  occupation, skill, knowledge, and competence concepts with stable URI
  identifiers and occupation-skill relationships. The site reported ESCO
  1.2.1 as current. ESCO is useful for European/multilingual coverage, but
  mapping it to O*NET requires explicit crosswalk provenance and cannot erase
  jurisdiction.
- NASA's official [Become an Astronaut](https://www.nasa.gov/humans-in-space/astronauts/become-an-astronaut/)
  page is selecting-organization guidance, but its date-qualified content is
  mixed-cycle and does not establish a current opening or complete current gate
  set. A named vacancy/selection cycle is required for current application and
  eligibility claims. O*NET or BLS may describe related occupations, but
  neither can override cycle-bound selecting-organization facts.
- The BLS distinction between typical entry education, related experience, and
  on-the-job training shows why a capability overlap is not enough. A candidate
  destination explanation needs separate evidence for reusable capability,
  prerequisite, common preparation, and authoritative qualification.

### Completed ordinary, regulated, and competitive career pilot

A bounded claim-validation pilot was performed on 2026-08-03 using three
United States destinations. The same hypothetical input was used for each: a
user has confirmed evidence of analytical problem solving, written and verbal
communication, coordinating work with others, and some technical learning.
The pilot asked what those capabilities can honestly explain, which source
owns each gate, and whether the destination can be presented without implying
qualification or success. It did not score a real user, generate a route, or
test a UI.

#### Ordinary occupation: software developer

- [O*NET Software Developers 15-1252.00](https://www.onetonline.org/link/summary/15-1252.00)
  was inspected against O*NET 30.3, released May 2026 under CC BY 4.0.
  O*NET marks the occupation updated in 2026 while individual content
  categories carry their own 2025 or 2026 update dates.
- The [BLS Software Developers OOH profile](https://www.bls.gov/ooh/computer-and-information-technology/software-developers.htm),
  last modified August 28, 2025 and using 2024-34 projections, was inspected
  for typical duties, education, pay, and outlook.
- Result: the hypothetical capabilities can explain why the occupation is
  worth exploring, and O*NET can identify additional capabilities to inspect.
  BLS's typical bachelor's-degree statement is not a hard gate, employer
  promise, or finding that the user can do the job. Employer-specific
  requirements and local conditions remain unknown.

#### Regulated occupation: registered nurse in New York

- [O*NET Registered Nurses 29-1141.00](https://www.onetonline.org/link/details/29-1141.00)
  and the [BLS Registered Nurses OOH profile](https://www.bls.gov/ooh/healthcare/registered-nurses.htm)
  were inspected for occupational description, common education routes, work
  context, and national outlook. Both identify licensure as required; the BLS
  profile uses the 2024-34 projection period.
- The [New York State Education Department RN requirements](https://www.op.nysed.gov/professions/registered-professional-nursing/license-requirements),
  retrieved 2026-08-03, were inspected as the jurisdiction-specific gate. They
  require, among other things, acceptable nursing education, specified New
  York coursework, the NCLEX-RN or another accepted examination, and an NYSED
  application. The page exposes no release identifier, so its retrieval date
  is not enough for durable freshness; the gate requires a current recheck.
- Result: communication and coordination may explain relevance but satisfy
  none of the licensure requirements. O*NET and BLS cannot override NYSED, and
  a nursing license elsewhere cannot be silently treated as authorization to
  practice in New York.

#### Competitive selection: NASA astronaut candidate

- NASA's [Become an Astronaut](https://www.nasa.gov/humans-in-space/astronauts/become-an-astronaut/)
  page, last updated March 27, 2026, was inspected for published U.S.
  citizenship, qualifying STEM education, related experience or pilot-hours,
  and long-duration-flight-physical eligibility requirements. NASA warns that
  requirements change with its goals and missions. The page mixes general
  guidance with date-qualified application-cycle wording, while the selection
  page says applications open only as needed. It therefore cannot establish a
  currently open vacancy or a complete current-cycle gate set.
- NASA's [Astronaut Selection Program](https://www.nasa.gov/humans-in-space/astronauts/astronaut-selection-program/)
  reports that more than 8,000 people applied in 2024 and 10 were selected as
  the 2025 astronaut-candidate class, followed by about two years of training.
  NASA, not an occupational taxonomy, owns both the gates and the competitive
  selection.
- Result: even complete minimum eligibility would not support a probability of
  selection, a guaranteed intermediate-role chain, or the claim that one
  qualifying STEM field is the correct route. User capabilities can explain
  adjacent evidence to preserve. Eligibility and availability must bind to a
  named current vacancy/selection cycle; absent one, these pages support only
  mixed-cycle guidance and selection remains unresolved.

The three cases falsified a single `capability overlap = career readiness`
interpretation. The minimum useful evidence model needs separate classes for
descriptive occupational relationships, typical preparation, jurisdictional
hard gates, organization-specific eligibility, and competitive selection.
Every case also needs independent source and freshness labels. The pilot did
not validate recommendation recall, user comprehension, geographic breadth,
or source-pack licensing; those remain evaluation needs, not unresolved claim
semantics.

### User-value synthesis

A useful recommendation is closer to an evidence-backed option portfolio than
to a ranked occupation list. The minimum credible explanation has four layers:

1. **Why it appeared:** the exact user-owned capabilities or preferences that
   were allowed to influence the result.
2. **What the public source says:** the occupation, common work, context,
   capabilities, education/experience, and market facts with source and date.
3. **What still needs checking:** hard gates, local variation, employer or
   organization-specific requirements, and missing user context.
4. **What Ambitions is not claiming:** qualification, guaranteed employment,
   predicted satisfaction, salary outcome, identity fit, or automatic Goal
   adoption.

This is a research synthesis, not an approved interaction or data contract.

Discovery needs two independent entrances. A capability-adjacency lane can
surface destinations that reuse selected progress. A user-entered aspiration or
exploration lane must preserve destinations the user names or deliberately asks
to explore even when current capability overlap is low or zero. Low overlap may
be explained as a gap; it must never prune the aspiration lane or turn the
user's history into a destiny filter.

## Alternatives

### 1. Exact title or keyword matching

Match the user's current Goal or capability names to occupation titles. This is
simple and explainable but misses transferable capabilities, adjacent work,
and terminology differences. It also overweights wording rather than evidence.

### 2. Rank careers by capability overlap

Calculate one similarity percentage and show the highest matches. This is easy
to scan but hides hard gates, source uncertainty, unwanted work context,
location, accessibility, and the distinction between learned skill and trait.
A high overlap can still be a poor or impossible path.

### 3. Recommend high-growth or high-pay occupations

BLS market facts could drive a popularity ranking. Market context is relevant,
but it cannot stand in for user values, local availability, qualification, or
feasibility. This direction risks turning Ambitions into generic career media.

### 4. Ask the user to choose a career first, then show gaps

This avoids inference and is useful for known destinations, but it does not
solve the pivot problem: helping a user discover credible directions that reuse
progress they may not know how to translate.

### 5. Offer a small, unranked evidence-backed destination portfolio

Generate multiple source-backed options locally, explain reusable progress and
gaps, distinguish hard gates from typical patterns, expose uncertainty, and
let the user refine or reject the rationale. This best matches Ambitions'
continuity and user-authority laws, though it requires better public knowledge
and evaluation than a simple matcher.

## Unknowns and risks

### Dependencies

- Approved capability-continuity work must define which private capabilities
  and evidence may influence recommendations and how the user disables them.
- The public-reference knowledge foundation must establish source identities,
  authority-for-purpose, versioning, licensing, crosswalk, and offline rules.
- Education recommendations are separate. A career option may identify a
  learning gap, but it should not silently choose a school or program.
- `destination-adoption-and-pivot`, `adaptive-path-comparison`,
  `goal-path-generation`, and `context-quality-scheduling` retain their named
  mutation boundaries. `verifiable-credential-import` and
  `user-profile-archive-import` own their distinct inbound evidence contracts;
  this initiative does not absorb them.

### Material unknowns

- Which explicitly selected, non-protected inputs beyond capabilities add
  enough value to justify their use: desired work, values, location radius, pay
  needs, schedule, risk, education tolerance, or willingness to relocate?
- Which protected constraints warrant enough user value to justify a
  purpose-specific consent flow? The bounded direction never infers them and
  fails quiet unless the user deliberately selects the exact fact after fresh
  disclosure and consent.
- What evaluation set can measure useful adjacent recommendations, harmful
  omissions, false hard-gate claims, and explanation comprehension?
- How should O*NET and ESCO be crosswalked without pretending equivalence?
- How should regulated professions, government selection programs, licenses,
  security clearances, union rules, and employer-specific requirements be
  sourced and refreshed?
- When does an intermediate role have enough authoritative evidence to appear
  as a route option rather than an invented promotion ladder?
- How many destinations can remain meaningfully comparable without producing a
  noisy career browser or covert rank?
- What does "reuse" mean when a capability is relevant to work but does not
  satisfy a credential, experience, or hiring requirement?

### Risks

- Recommendation language can imply employability, identity, or predicted
  happiness even when the underlying data only describes an occupation.
- Historical labor-market bias can be laundered into personalized exclusion if
  observed pathways are treated as requirements.
- Missing or inaccessible careers may be silently omitted, making a bounded
  corpus appear exhaustive.
- Pay and outlook can dominate user judgment despite geographic, temporal, and
  methodological limits.
- Soft-skill matching can become a hidden personality assessment.
- A user changing direction may be emotionally vulnerable; language that calls
  prior work wasted or a new path optimal would violate Ambitions' posture.
- A technically deterministic score can still be product-invalid if source
  mappings, weights, or omissions are uncalibrated.
- External facts can change between recommendation and adoption. Staleness must
  block or qualify the affected claim without erasing the user's own progress.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Surfaces/Goals/CareerExplorationView.swift`, `Native/Ambitions/Trust/CareerRecommendationInspectionView.swift`.
- Evidence and unknowns: Repository audit identifies Task 5 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Continue researching an opt-in, local, evidence-backed career destination
portfolio rather than a career score or automated counselor. Preserve both a
capability-adjacency lane and a user-entered aspiration/exploration lane; neither
is a fallback for the other.

The most promising bounded direction would let a user ask for adjacent career
possibilities based on selected user-owned capabilities, directly enter a
destination, or request an area they want to explore. A directly entered or
requested aspiration remains eligible even with no current overlap. Each
candidate would remain an uncommitted option and would explain:

- the public occupation identity and jurisdiction;
- the exact allowed capability evidence that contributed;
- reusable capabilities and adjacent experience, without equating either to
  qualification;
- typical work and work context;
- common education, experience, or training;
- hard gates only from the authority that owns them;
- market context with BLS limitations;
- missing, stale, conflicting, or organization-specific facts; and
- why the candidate may be worth exploring without calling it the best fit.

Starting either lane is explicit consent to perform that local exploration, not
consent to every private fact. The user selects the non-protected capabilities
and preferences that may participate. A protected fact is never inferred and
may participate only when the user deliberately selects that exact fact after a
fresh purpose-specific disclosure and consent. When classification is
uncertain, or the derived destination or its rationale would itself disclose
protected context beyond that consent, Ambitions omits that affected result and
fails quiet. It must not infer a less explicit proxy, while a user-entered
aspiration remains available for direct exploration.

O*NET plus BLS are the strongest initial United States descriptive sources;
ESCO is a complementary multilingual/European source. A role-specific
employer, regulator, licensing body, credentialing body, or selecting
organization must override generic summaries for its own current gate. The
completed pilot across software development, registered nursing in New York,
and NASA astronaut selection confirmed that these authority lanes cannot be
flattened.
It also showed that the astronaut stress case must distinguish eligibility
from selection and that an ordinary occupation's typical education cannot be
promoted to a universal gate.

Recommendation evaluation should separately test source correctness,
capability-trace accuracy, hard-gate handling, diversity of plausible options,
unsafe omission, explanation comprehension, correction behavior, and quiet
fallback. It must also prove that low capability overlap never removes a
user-entered aspiration and that protected or uncertain inputs and derived
destinations fail quiet. A single offline similarity metric would be
insufficient evidence.

This direction does not decide a UI, ranking, matching algorithm, source pack,
number of options, or adoption behavior. It does not authorize creating Goals,
routes, Steps, schedules, or external profile changes. Those decisions belong
to later approved Scope and dependent initiatives.
