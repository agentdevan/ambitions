+++
initiative = "education-destination-recommendations"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions should eventually help a user find education or training destinations
that build on what they already know and move toward a chosen life direction.
The destination could be a degree program, certificate, certification,
apprenticeship, course sequence, community program, or another legitimate
learning opportunity. It should not assume that a degree is always the answer.

The user problem is deceptively difficult. "What should I learn next?" combines
several facts owned by different authorities:

- a classification authority can name a field of study;
- a framework publisher can define a competency or learning outcome;
- a provider can say which program, course, curriculum, schedule, delivery
  mode, price, and prerequisites it currently offers;
- an accreditor or government database can report recognized accreditation;
- a licensing or certification body can define a profession-specific gate;
- a receiving institution decides whether prior learning or credit transfers;
  and
- only the user can decide whether the learning experience, cost, duration,
  location, and intended outcome fit their life.

A capability match cannot collapse these distinctions. Knowing programming may
make a computer-science route more plausible, but it does not award credit,
waive admission, prove mastery of a published outcome, or show that a specific
program is current and available. Likewise, a credential's existence does not
prove quality, affordability, admission, transfer value, or relevance to the
user's goal.

This Research isolates education destination discovery and explanation from
capability capture, the shared public-reference foundation, career
recommendations, credential import, destination adoption, generated Goal Paths,
schedule placement, application execution, and financing advice. It does not
commit an education taxonomy, provider marketplace, scoring model, UI, or
implementation.

## Current truth

This Research inspected `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, the umbrella portfolio synthesis,
current canon, relevant Source Atlas and Life Context source, tests, and
retained public-pack evidence. The umbrella synthesis has been reopened as a
draft for domain decomposition and is not current approval authority for this
initiative. External sources were reviewed on 2026-08-03. Tests were inspected,
not executed.

Canon supports a private, user-controlled learning route but does not yet
define education recommendation behavior:

- Life Capital includes durable knowledge, skills, Proof, and other capacity,
  while `SYSTEM-LEARNING-LOCAL-001` permits only local, evidence-linked,
  correctable, non-sensitive learning influence.
- Goal and Goal Path law supports provisional intent, requirements,
  dependencies, alternatives, assumptions, Proof expectations, and explicit
  activation. A suggested education destination cannot silently create a Goal,
  enroll the user, or schedule work.
- Source Atlas may provide public education and credential references, but
  private capabilities, education history, financial context, location, and
  recommendation behavior cannot leave the device through Source Atlas/R2.
- `CONTROL-FORCE-NOTHING-001` preserves the user's choice to reject a program,
  route, source interpretation, or recommendation.
- Ambitions cannot provide professional admissions, financial-aid, licensing,
  or transfer decisions it does not own.
- A generic capability-use setting is not consent for education exploration.
  The user must deliberately start the exploration and select the private
  inputs that may influence it. Protected facts are never inferred. A protected
  input may participate only when the user deliberately selects that exact fact
  after a fresh purpose-specific disclosure and consent. If classification is
  unknown or a derived destination or explanation reveals protected context
  beyond that consent, the affected result remains quiet rather than
  substituting a proxy.

The live implementation contains partial education infrastructure:

- `LifeContextModels.swift` distinguishes education history, training history,
  eligibility pathways, sources, freshness, contradiction, and user
  confirmation. It can provide local context but is not an education catalog.
- Source Atlas supports education-eligibility and certification-eligibility
  risk classes, strict review, requirements, source/freshness status, pathway
  components, and local-only composition.
- The retained `education_credentialing` public pack contains eight packable
  claims. Inspection shows College Scorecard candidate institution/program
  references and a bounded official United States Military Academy curriculum
  source. The pack's own non-claims reject admissions advice, financial-aid
  advice, personalized degree planning, credentialing authority, and universal
  coverage.
- The refresh registry and production sweep prove configured pack delivery and
  readback for the domain. They do not prove a complete program catalog,
  current institutional requirements, accreditation accuracy, transfer
  eligibility, or recommendation quality.
- Source Atlas path models can represent requirements, alternatives,
  prerequisites, course or credential-like milestones, and Proof needs in
  synthetic fixtures. No inspected test starts with user-owned capabilities and
  produces a source-backed education destination portfolio.

No current canon/source contract was found that decides how Ambitions should
distinguish learning objective, program, course, credential, institution,
accreditation, transfer value, profession gate, provider offering, or personal
fit in a recommendation. No calibrated evidence exists for program coverage,
false eligibility claims, cost/outcome interpretation, or user comprehension.

## Evidence

### Repository and product evidence

- `docs/product-development/adaptive-skills-and-pathways/research.md` identifies
  education as a distinct destination domain and warns that skills alone do not
  explain desirability or feasibility.
- `docs/canon/specifications/objects/goal-path.md` can represent an ordered,
  revisable route with prerequisites, decisions, Proof, recovery, and source
  checks. This is compatible with education routes but does not establish
  provider or admissions truth.
- `docs/canon/specifications/systems/source-atlas.md` supplies the public-only,
  versioned, inspected reference boundary required for provider and framework
  facts.
- The `education_credentialing` pack demonstrates two important authority
  classes already: government discovery data and an official institution's
  curriculum. Its small fixture frontier also demonstrates why one source
  cannot answer every education question.
- Existing Life Context repository and runtime-effect tests cover local
  education/training facts and source/freshness behavior. They do not prove
  credit recognition or institution-specific eligibility.

### External education evidence

All external links below were accessed on 2026-08-03.

- The NCES [CIP 2020 browser](https://nces.ed.gov/ipeds/cipcode/browse.aspx?y=56%2C)
  supplies a hierarchical United States classification of instructional
  programs. CIP supports consistent field labels and reporting. It does not
  establish that a provider offers a program, its current curriculum, admission
  rules, accreditation, cost, delivery, or transfer behavior.
- The U.S. Department of Education's
  [Find a College or Educational Program](https://www.ed.gov/higher-education/find-college-or-educational-program)
  routes users to College Scorecard for institutions, fields of study, cost,
  admissions, and outcome comparisons and separately to accreditation
  resources. This separation is evidence that discovery/outcomes and quality
  recognition are distinct authority lanes.
- The Department's [College Accreditation](https://www.ed.gov/laws-and-policy/higher-education-laws-and-policy/college-accreditation)
  page provides recognized accrediting-agency information and a database of
  accredited institutions and programs as reported by accrediting and state
  approval agencies. Accreditation is important public evidence, but it is not
  the same as admission, individual program fit, credit transfer, licensure, or
  a guarantee of outcomes.
- The [Credential Engine schemas handbook](https://www.credreg.net/ctdl/handbook)
  describes credentials, organizations, learning opportunities, assessments,
  competencies, costs, conditions, pathways, progression, and recognition of
  prior learning as linked data. CTDL can express alternative pathway
  components and Transfer Value Profiles, but the handbook states that CTDL
  describes credentials offered rather than credentials awarded to a person.
  Published metadata remains a claim by its publisher and needs current source
  and applicability review.
- The [1EdTech CASE standard](https://www.1edtech.org/standards/case) provides
  stable identifiers for competency frameworks, learning outcomes,
  associations, and rubrics. It supports provider/consumer exchange and
  cross-framework associations. An association is useful traceability, not
  automatic equivalence, course completion, credit, or admissions authority.
- CASE's authority model is instructive: the framework authorizing body or its
  proxy publishes a framework, while a consumer uses it. Ambitions should
  preserve who authored a competency relationship instead of treating every
  framework as one global truth.
- The [CTDL Pathway definition](https://www.credreg.net/ctdl/terms/Pathway)
  and handbook show that education-to-work routes can contain course,
  credential, competency, assessment, job, and work-experience components with
  conditions and alternatives. That structure supports explanation, but a
  public pathway is not automatically the right or feasible personal route.

### Completed three-route and prior-learning pilot

A bounded paper pilot was performed on 2026-08-03 around one deliberately
broad objective: build foundational programming and software-development
capability. Three current routes were inspected to determine whether their
meaning, recognition, effort, and prior-learning implications could be
compared without treating them as equivalents. The pilot did not recommend a
provider, estimate a user's transfer award, or test enrollment.

#### Route 1: 2026-27 UMGC B.S. in Computer Science

The provider's [current program page](https://www.umgc.edu/online-degrees/bachelors/computer-science)
identifies a 120-credit bachelor's degree with 42 major credits, 41 general
education credits, 37 elective credits, current course requirements, online
delivery, and explicit technology requirements for students enrolling in the
2026-27 academic year. The
[Middle States Commission on Higher Education statement](https://www.msche.org/institution/0198/),
retrieved 2026-08-03, reports UMGC accredited with accreditation reaffirmed on
November 20, 2025 and distance education within scope. MSCHE also states that
its accreditation applies to the institution as a whole and does not accredit
individual programs. The same MSCHE status records an active supplemental
report due September 14, 2026 concerning disclosure and financial-viability
evidence. Reaffirmation, distance-education scope, and that monitoring/action
state are separate current facts; none can be omitted to make the institution
look simply settled. These sources therefore support different claims and
freshness obligations.

#### Route 2: Google IT Automation with Python Certificate

Google's [current certificate page](https://www.grow.google/certificates/it-automation-python/),
retrieved 2026-08-03, describes an advanced, fully online professional
certificate covering Python, Git, troubleshooting, testing, configuration
management, and IT automation. It estimates one to two months and states that
basic IT familiarity is expected, while no prior coding is required. Google
owns those curriculum and format claims; the page's 2024 labor-market figures
have a different and older evidence date. The certificate is narrower than a
computer-science degree and is oriented toward IT automation, so it cannot be
presented as the same route or as proof of software-developer employability.

#### Route 3: Harvard CS50x 2026 OpenCourseWare

The [CS50x 2026 course](https://cs50.harvard.edu/x/) is a free-to-take
OpenCourseWare introduction to computer science with material from Scratch and
C through algorithms, data structures, Python, SQL, web development, and a
final project. Its
[FAQ](https://cs50.harvard.edu/x/faqs/), last updated July 15, 2026 and
retrieved 2026-08-03, distinguishes a free CS50 certificate from an edX
verified certificate and says a learner must ask the receiving institution
whether an ACE-recommended verified completion will be accepted. The free
certificate does not fulfill the ACE process. The course is licensed
[CC BY-NC-SA 4.0](https://cs50.harvard.edu/x/license/), which allows bounded
noncommercial reuse with attribution and share-alike obligations, not
unqualified production redistribution.

#### Prior-learning question and result

The pilot asked: if a user completed the Google certificate or CS50x, may
Ambitions say that the work reduces the UMGC degree or awards credit? The
answer is no without receiving-institution evidence. UMGC's
[Google certificate equivalency page](https://www.umgc.edu/transfers-and-credits/fast-paths-to-credit/industry-certification-professional-courses/google)
lists specific current articulations and requires official completion
documentation, but says UMGC still decides whether and how credit applies to
the student's program and other credits. No inspected articulation established
that the Google IT Automation with Python certificate satisfies a particular
2026-27 computer-science major requirement. CS50 likewise instructs learners
to verify acceptance with their own institution, and its free certificate is
not the ACE-backed artifact.

The safe comparison can therefore say that prior work may overlap curriculum,
reduce subjective learning effort, or be eligible for formal evaluation. It
cannot say that the routes are stackable, that credit will transfer, or that a
particular requirement is waived. Exact catalog year, credential version,
completion artifact, receiving program, current articulation, and individual
evaluation are all material. The three-route pilot also found that
accessibility-support detail was not comparable across the inspected public
pages; absence must be shown as unknown rather than interpreted as a lack of
support.

### Authority synthesis

For a candidate education destination, at least six evidence lanes must remain
distinguishable:

1. **Classification:** what field or program family this is, such as CIP.
2. **Learning meaning:** competencies/outcomes and their publisher, such as a
   CASE framework or an official curriculum.
3. **Offering:** the provider's current program, course, format, dates, cost,
   prerequisites, and catalog version.
4. **Recognition:** accreditation, approval, certification, or licensing status
   from the authority that owns that status.
5. **Transfer:** explicit receiving-institution or agreement/policy evidence;
   user experience or capability similarity is not credit.
6. **Descriptive outcomes:** government or other appropriate public statistics,
   with cohort, geography, time, suppression, and methodological limits.

This synthesis is a Research conclusion, not an approved product or data
contract.

## Alternatives

### 1. Recommend a degree from the target career title

Map an occupation to a common degree and show nearby schools. This is simple
but overcommits one education form, ignores alternative credentials and prior
learning, and can mistake typical entry education for a hard requirement.

### 2. Rank programs by cost, completion, or earnings

Government statistics can support comparison, but a single rank hides cohort,
program, geography, selection, missing-data, and user-value differences. It
would also make Ambitions resemble a generic college marketplace.

### 3. Match user capabilities directly to competency frameworks

This can reveal likely learning overlap and gaps, but framework alignment does
not establish mastery, credit, admission, provider offering, or transfer. A
direct match would overstate what the evidence means.

### 4. Recommend only provider-authored programs

Official provider catalogs are authoritative for offerings and requirements,
but provider marketing is not neutral comparison and no provider owns the
user's broader destination choice. Coverage would be fragmented and hard to
compare.

### 5. Build an authority-layered, unranked education option portfolio

Begin with a learning objective, preserve alternative education forms, and
show each option with separate classification, provider, recognition,
transfer, outcome, capability-overlap, and missing-evidence layers. This is
more demanding but prevents taxonomy or metadata from masquerading as an
individual decision.

## Unknowns and risks

### Dependencies

- Capability continuity must establish which user-owned knowledge and skill
  evidence is eligible to influence the recommendation.
- The public-reference foundation must resolve source identity, version,
  authority-for-purpose, licensing, jurisdiction, conflict, and offline use.
- Career destination work may identify a learning need but must not own the
  education recommendation itself.
- `verifiable-credential-import`, `user-profile-archive-import`,
  `destination-adoption-and-pivot`, `goal-path-generation`, and
  `context-quality-scheduling` retain their named boundaries. Application
  execution and external writes are excluded, uncommitted future ideas outside
  this portfolio rather than implied initiatives.

### Material unknowns

- Does the recommended first set—degree program, provider-issued professional
  certificate, and open self-study course—give enough structural diversity
  without implying coverage of certifications, apprenticeships, community
  programs, or employer training?
- After the user explicitly asks to see named providers, how many current
  offerings can remain meaningfully comparable without becoming a directory or
  covert rank?
- How should location, modality, accessibility, schedule, cost tolerance,
  funding, prerequisite tolerance, and desired pace be requested without
  profiling or remote leakage?
- Which College Scorecard program-level measures are comparable and current
  enough for product use, and how should missing/suppressed data appear?
- How are institution, branch, program, catalog year, delivery mode, and
  accreditation identities reconciled over time?
- What source is authoritative for a transfer claim when a sending provider,
  receiving provider, agreement, and student experience disagree?
- How should prior learning be described when it may reduce learning effort but
  has no official transfer value?
- What evaluation corpus can test stale catalogs, closed programs, changing
  accreditation, false prerequisites, and misleading outcome comparisons?

### Risks

- "You already know this" can imply credit or mastery unsupported by formal
  evaluation.
- A program can be real and accredited yet unsuitable, unavailable, too costly,
  inaccessible, or irrelevant to the user's intended destination.
- Provider and ranking incentives may bias results toward monetized or easily
  indexed offerings.
- Cost and outcome data can be misread as guaranteed personal return.
- Education history, finances, disability accommodation needs, immigration
  status, age, and location can be sensitive. They cannot become remote query
  material or hidden exclusion signals.
- Program and admission facts change by term and catalog year. A stale generic
  summary can cause material harm.
- Framework and crosswalk associations can hide semantic mismatch and make a
  capability appear more transferable than it is.
- Overly broad results could become a provider directory rather than a calm
  decision aid tied to the user's chosen direction.

## Recommended direction

Continue researching a local, authority-layered education destination
portfolio centered on the user's chosen learning or life objective—not a
ranked school list.

The recommended first useful destination set is deliberately limited to the
three route forms exercised by the pilot: a degree program, a provider-issued
professional certificate, and an open self-study course. They expose materially
different offering, recognition, transfer, cost, and completion claims without
pretending to cover certifications, apprenticeships, community programs, or
employer training. This is a Research recommendation for Scope to accept or
revise, not approval of any named provider.

Provider intent is a separate threshold. A stated learning objective or desired
route form may support comparison at the destination-type level, but named
institutions, programs, or courses should appear only after the user explicitly
asks to explore current providers. That request does not authorize enrollment,
contact, an application, or use of every private constraint.

The most promising bounded direction would keep several kinds of option open
and explain each candidate through separate evidence blocks:

- what learning outcome or destination it supports;
- what selected user-owned capabilities appear relevant and what this overlap
  does **not** prove;
- the provider and exact current offering identity;
- curriculum or competency evidence and its publisher;
- prerequisites, duration, format, location, and cost from the appropriate
  source;
- accreditation, approval, certification, or licensure relevance from the
  authority that owns it;
- transfer or recognition-of-prior-learning facts only where the receiving
  authority or explicit agreement supports them;
- descriptive outcome evidence with limitations; and
- stale, conflicting, unavailable, or still-unknown information.

Starting exploration is explicit consent for that local comparison, not blanket
consent for education history, finances, disability or accommodation needs,
immigration status, age, or location. The user selects which non-protected facts
may participate. A protected fact is never inferred and may participate only
when the user deliberately selects that exact fact after a fresh
purpose-specific disclosure and consent. If classification is uncertain, or a
derived destination or rationale would expose protected context beyond that
consent, Ambitions omits the affected result and fails quiet; it does not
substitute a proxy. Explicit provider intent still does not waive this boundary.

CIP should support classification, CASE can support competency traceability,
and CTDL can support rich public credential/pathway descriptions. None should
override a current provider catalog, recognized accreditor, licensing body, or
receiving institution for the facts each owns. College Scorecard can support
United States discovery and descriptive comparison without becoming an
admissions or return-on-investment oracle.

The completed UMGC degree, Google professional certificate, and CS50x
OpenCourseWare pilot confirms that structurally different routes can be
compared only as distinct options. It caught the intended failure modes:
degree/certificate/course equivalence was false; formal prior-learning credit
could not be inferred; offering, labor-market, accreditation, and articulation
facts had different freshness clocks; and comparable accessibility details
were unavailable. Broader evaluation must retain those adversarial cases and
test whether users mistake the explanation for admissions, credit, or
financial advice.

This direction selects three route forms and an explicit provider-intent
threshold for Scope consideration. It does not select named providers, define
ranking, decide how many options appear, create applications, import
credentials, commit a Goal, or schedule learning. `verifiable-credential-import`
owns inbound credentials, `destination-adoption-and-pivot` owns Goal creation,
`goal-path-generation` owns route and Step proposals, and
`context-quality-scheduling` owns placement. Application execution and external
writes are excluded, uncommitted future ideas outside this portfolio.
