+++
initiative = "career-destination-recommendations"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

A user can deliberately explore United States career destinations through two
equal paths: a small portfolio of adjacent possibilities that may reuse
selected progress, or a destination the user names because they aspire to or
want to explore it. Each option explains why it appeared, what public sources
actually support, what is reusable, what remains unknown or gated, and what
Ambitions is not claiming.

The experience remains local, unranked, inspectable, non-mutating, and
subordinate to the user's authority. It helps a user consider directions; it
does not decide identity, employability, qualification, satisfaction, or the
career they should choose.

## In scope

- An explicit, opt-in career exploration session using only private inputs the
  user selects for that purpose.
- A capability-adjacency lane and a user-entered aspiration/exploration lane
  that remain independently available.
- A small portfolio of three to five unranked adjacent destinations when at
  least three source-eligible candidates exist; otherwise every eligible
  candidate is shown without padding or fabrication.
- A deterministic, non-scoring five-option selection contract when more than
  five adjacent destinations are eligible, plus discoverable omitted options
  that the user can inspect and substitute into the current portfolio.
- Direct exploration of a user-named destination even when current capability
  overlap is low, zero, or unknown.
- United States occupational context with clear jurisdiction; broader
  jurisdictions remain future work.
- Claim-specific explanations for occupational description, reusable progress,
  typical preparation, hard gates, selecting-organization rules, market
  context, missing facts, and source freshness.
- Ordinary, regulated, and competitive destinations when each affected claim
  has the appropriate current authority; otherwise source-check-first or quiet
  behavior.
- Refinement, correction, dismissal, and source inspection within the current
  exploration without creating a durable personality or preference profile.
- Accessible comparison and explanation without a compatibility score or a
  visually implied winner.

## Out of scope

- Choosing, activating, editing, pausing, or pivoting a Goal; those mutations
  belong to `destination-adoption-and-pivot`.
- Generating an intermediate-role chain, Goal Path, Steps, Proof plan, schedule,
  application, resume, interview plan, or job-search workflow.
- Education-program recommendation, credential/profile import, capability
  capture, public-reference ingestion, or capability export.
- Employer outreach, application submission, external profile updates, public
  posting, purchases, enrollment, or any other external write.
- A career compatibility, readiness, employability, success-probability,
  personality, prestige, salary-return, or happiness score.
- Treating typical education, experience, or capability overlap as a universal
  requirement, credential award, license, or finding that the user is qualified.
- A guaranteed promotion ladder or the claim that an intermediate role is
  required unless a current authority explicitly owns that gate.
- Personalized legal, licensing, immigration, admissions, financial, medical,
  security-clearance, or hiring advice.
- Hosted matching, private remote queries, or allowing Goals, Proof, history,
  capabilities, location, protected facts, or rejection to enter Source Atlas,
  R2, telemetry, or another hosted intelligence service.

## Requirements

### REQ-001 — Exploration is deliberate and locally bounded

Ambitions must start career exploration only after the user explicitly chooses
the adjacency lane or enters an aspiration/exploration destination. All private
matching and explanation must occur locally, work without an account, and use
only the inputs allowed for that session.

### REQ-002 — Eligible inputs are bounded, specific, and revocable

The only non-protected inputs eligible for one career exploration session are:

1. user-selected confirmed capabilities and their approved evidence links;
2. user-stated career interests or occupation families;
3. user-stated preferences for work activity/context, schedule shape, location
   radius, pay need, education tolerance, or relocation willingness when the
   applicable datum is classified non-protected; and
4. user-stated must-have or must-avoid constraints in those same categories;
   and
5. user-selected confirmed education, credential, experience, or eligibility
   facts, used only to explain a gate or unknown after candidate inclusion and
   never as hidden inclusion, omission, or ranking authority.

A preference may refine explanation or portfolio composition but must not
exclude a destination unless the user explicitly marks it as a constraint. A
constraint may exclude only when the user marks it hard and a current public
claim can evaluate it; otherwise the effect is shown as unknown. Qualification,
credential, education, experience, and eligibility facts may explain a known or
unknown gate but cannot themselves become hidden preferences or exclusions.

Starting exploration must not grant blanket use of private history. Every
selected input and its exact use must be inspectable and removable. Selection
expires when the session ends by default; remembering an input requires a
separate named scope and retention choice with inspect, reset, and delete
controls. Removing or expiring one input must recompute only dependent portfolio
items and rationale without changing source evidence.

### REQ-003 — Protected context is never inferred

A protected fact may influence exploration only when the user deliberately
selects that exact fact after a fresh purpose-specific disclosure and consent.
If classification is uncertain, or a destination or rationale would expose
protected context beyond that consent, Ambitions must omit the affected result
and fail quiet without substituting a proxy. Protected-fact consent is limited
to the named fact, career-exploration purpose, affected decision, and current
session unless the user separately chooses a permitted retention scope. It must
be inspectable and revocable; revocation removes every dependent influence and
must not produce a negative inference.

### REQ-004 — Adjacency and aspiration remain independent

The adjacency lane must offer three to five unranked, source-eligible options
when available and explain the selected progress relevant to each. The
aspiration lane must preserve and explain a user-entered destination even when
overlap is low, zero, or unknown. Neither lane may silently prune or demote the
other.

A source-eligible adjacent candidate must have one stable United States public
occupation identity, a current or explicitly qualified descriptive source, and
at least one inspectable relationship to an allowed session input. Duplicate
occupation identities collapse into one candidate without losing rationale.
When one to five candidates are eligible, every candidate is shown. When more
than five are eligible, Ambitions must show exactly five using this stable,
non-scoring coverage rule. A candidate's coverage basis is the first allowed
input in the user-visible session input order that has a current public
relationship to that occupation; every additional relationship remains in its
explanation. In that visible input order, take one candidate per distinct basis
before taking a second from the same basis; within each basis take one per
distinct public occupation family before repeating a family; break remaining
ties by canonical occupation title and then stable public identifier. No weight,
similarity total, pay, outlook, or hidden quality value may influence this rule.

Every omitted eligible candidate must remain discoverable in the session,
grouped by its input basis and occupation family, with the exact reason it was
eligible and omitted. The user can inspect it, choose **Show this instead** to
replace a visible candidate, or refine the selected inputs/families and
deterministically recompute the set. Substitution changes no underlying rank and
must not affect the independent aspiration lane.

### REQ-005 — Every destination explains its inclusion and limits

Each candidate must show its public occupation identity and jurisdiction, the
exact selected inputs that influenced its inclusion, potentially reusable
capabilities without equating them to qualification, typical work and work
context, common preparation, applicable gates, material unknowns, and why it
may be worth exploring without calling it the best fit.

### REQ-006 — Public claims retain authority and freshness

Occupational description, typical preparation, market context, legal or
licensing gates, employer requirements, and competitive selection must remain
separate claim types bound to the source that owns each one. Generic occupation
sources must not override a current regulator, employer, licensing body, or
selecting organization. Stale, mixed-cycle, missing, or conflicting authority
must be visible and must qualify or block only the affected claim.

### REQ-007 — Regulated and competitive destinations fail honestly

A regulated or competitive destination may appear only with a visible
source-check state for every material jurisdictional or cycle-bound gate. A
minimum-eligibility match must never become a probability of selection,
permission to practice, or guaranteed outcome. Without a named current cycle,
mixed-cycle selecting-organization guidance must not appear as current opening
or complete eligibility.

### REQ-008 — The portfolio is non-ranked and non-exhaustive

Ambitions must not present a compatibility score, winner, hidden optimality
claim, or implication that the bounded corpus exhausts the user's possible
careers. Every shown option must have an inspectable inclusion reason, and
corpus limits or omitted source coverage must be stated in plain language.

### REQ-009 — User feedback does not become a hidden profile

The user must be able to refine an exploration, correct an input or rationale,
inspect sources, and dismiss an exact candidate. By default, dismissal applies
only to that candidate and rationale in the current exploration session. Any
broader remembered preference requires a separate explicit choice that names
its scope and consequence and remains inspectable, resettable, and deletable.

### REQ-010 — Failure preserves user authority and prior progress

When sources are absent, stale, contradictory, unsupported for the claim, or
unavailable offline, Ambitions must show the affected uncertainty, offer direct
aspiration exploration where safe, or remain quiet. It must not fabricate an
alternative, characterize prior work as wasted, or imply the user failed.

### REQ-011 — Recommendations remain non-mutating

Career options and refinements must not create or alter a Goal, Goal Path, Step,
schedule, Proof, capability, application, external profile, or provider record.
Any later adoption must enter its separately approved explicit review flow.

### REQ-012 — Career exploration is accessible and calm

Lane choice, candidate identity, inclusion reason, source, freshness,
jurisdiction, gate, uncertainty, corpus limit, omitted-candidate state,
substitution consequence, input/consent scope, and actions must be available in
a coherent semantic order. Every action must have a named, reachable,
non-gesture path for VoiceOver, Voice Control, Switch Control, Full Keyboard
Access, and hardware keyboard focus. Dynamic Type, Bold Text, Button Shapes,
Increase Contrast, Differentiate Without Color, Reduce Motion, Reduce
Transparency, RTL/localization, reach/handedness, and sensitive locked-device
presentation must preserve equivalent meaning and control.

Understanding or comparing options must not depend on color, spatial ranking,
charts, animation, timing, gesture, haptics, or dense source jargon. Reading
order, headings, rotor grouping, modal containment, and focus restoration must
be deterministic. Loading, omitted, stale, blocked, failed, privacy-quiet,
recomputed, and completed states must expose status, next action, retry/cancel,
and safe focus without visual observation.

### REQ-013 — Domain authority corpora require separate approval

`public-reference-knowledge-foundation` supplies the general public-artifact,
provenance, freshness, rights, offline, and firewall contract and its currently
bounded O*NET corpus. It does not make New York licensure or NASA selection facts
recommendation-ready. A separately researched, scoped, and approved
`career-domain-authority-corpus-expansion` dependency must establish evaluated
NYSED registered-nursing authority and NASA program/selection-cycle sources,
their licensing/rights, claim coverage, refresh and contradiction rules, and
failure fixtures before those source-specific claims can support adjacency
inclusion or current-gate explanation. Until then, user-entered RN or astronaut
aspirations remain directly explorable, but the missing authority layer is
source-check-first and cannot be presented as current or complete.

## Acceptance criteria

- **AC-001 (REQ-001, REQ-002):** Starting career exploration requires an
  explicit lane choice and offers only the bounded capability, interest,
  preference, and constraint categories. Preferences do not exclude unless
  explicitly made constraints; hard constraints exclude only against current
  evaluable claims. Session inputs expire by default, remembered scope is
  separately controlled, and removing one input changes only its dependent
  local results and rationale without changing source evidence.
- **AC-002 (REQ-003):** A protected fact is absent unless the user deliberately
  selects that exact fact after a current purpose disclosure. Unknown
  classification or an over-revealing derived result causes that result to be
  omitted without a proxy, diagnostic leak, or disclosure through explanation.
  Consent is fact-, purpose-, decision-, and session-bound by default;
  revocation removes every dependent influence without a negative inference.
- **AC-003 (REQ-004, REQ-008):** With five eligible adjacent candidates, the
  experience shows all five; with two it shows two rather than fabricating a
  third. With eight eligible candidates spanning repeated input bases and
  occupation families, the five visible options follow the exact coverage and
  title/identifier tie-break rule with no score. All three omitted candidates
  remain discoverable with inclusion/omission reasons, support **Show this
  instead**, and recompute deterministically after an input/family refinement.
- **AC-004 (REQ-004):** A user-entered NASA astronaut aspiration remains
  explorable when capability overlap is zero, while the explanation states the
  gap and does not remove, lower, or replace the aspiration with an adjacent
  occupation.
- **AC-005 (REQ-005, REQ-006):** A software-developer candidate separates O*NET
  occupational description, BLS typical preparation and market context, and
  unknown employer-specific requirements; selected capabilities explain
  relevance but never appear as qualification.
- **AC-006 (REQ-006, REQ-007):** A New York registered-nurse candidate shows
  jurisdiction-specific licensure as a current-authority gate distinct from
  O*NET/BLS context. Missing or stale NYSED authority blocks the current gate
  claim without erasing the user's reusable capabilities.
- **AC-007 (REQ-006, REQ-007):** Astronaut guidance without a named current
  vacancy/selection cycle is labeled mixed-cycle and cannot state that
  applications are open, that the full current gate set is known, or that
  minimum eligibility predicts selection.
- **AC-008 (REQ-008):** No candidate, ordering, accessibility label, or spoken
  description calls an option the best, highest match, most compatible, or most
  likely to succeed; an absent occupation corpus is identified rather than
  implied to contain no suitable careers.
- **AC-009 (REQ-009):** Dismissing one candidate removes it from the current
  session only. A broader preference is not retained unless the user separately
  confirms its named scope, after which it can be inspected, reset, and deleted.
- **AC-010 (REQ-010):** Offline or stale public evidence leaves the aspiration
  and user-owned progress intact, identifies the unavailable public layer, and
  neither invents a substitute career nor blocks unrelated local core use.
- **AC-011 (REQ-011):** Exploring, refining, correcting, or dismissing a career
  option produces no Goal, Goal Path, Step, schedule, Proof, application, or
  external write; adoption remains a separate explicit action.
- **AC-012 (REQ-012):** Direct verification proves the full lane, visible and
  omitted candidate, substitution, input/consent, source, gate, refinement,
  dismissal, status/error, and recovery flow with VoiceOver, Voice Control,
  Switch Control, Full Keyboard Access, hardware keyboard, deterministic focus
  and announcements, Dynamic Type, Bold Text, Button Shapes, increased contrast,
  non-color differentiation, reduced motion/transparency, RTL/localization,
  reach/handedness, and sensitive locked-device parity. No meaning or action
  depends on spatial rank, chart, color, motion, timing, gesture, or haptics.
- **AC-013 (REQ-006, REQ-007, REQ-013):** The bounded O*NET foundation alone
  cannot make NYSED licensure or NASA selection claims current. Before the
  separately approved career-domain corpus expansion exists, user-entered RN
  and astronaut aspirations remain available but display source-check-first
  gaps; neither can enter adjacency or claim a complete current gate from the
  missing domain authority.

## Canon impact

- A new owning destination-recommendation specification may be needed for the
  two-lane career exploration contract, unranked/non-exhaustive portfolio,
  claim ceilings, input consent, protected-context omission, and non-mutation
  boundary.
- `docs/canon/specifications/systems/local-learning.md` may need to define the
  declared local use of user-selected capabilities and corrections without
  creating a hidden career or personality profile.
- `docs/canon/specifications/systems/source-atlas.md` remains owner of public
  delivery and the no-private-graph firewall; it may need explicit support for
  domain claim classes but must not own the private match.
- Separately approved career-domain corpus canon must own evaluated NYSED and
  NASA authority coverage, rights, refresh, contradiction, and failure fixtures;
  the general public-reference foundation does not imply that coverage.
- `docs/canon/specifications/objects/goal.md` and the Goals surface/journey canon
  may need to distinguish a non-mutating career option from later explicit Goal
  adoption.
- `docs/canon/specifications/global/trust-inspection.md` and the relevant Goals
  or You surface specification may need accessible recommendation rationale,
  source, correction, and reset/delete inspection.
- Existing user-authority, offline/no-account, proof-evidence, privacy, and
  material-confirmation laws remain governing and must not be weakened.

## Risks and open decisions

### Dependencies

- `capability-continuity-foundation` must define eligible, user-owned,
  correctable capability evidence and consent controls.
- `public-reference-knowledge-foundation` must supply claim-specific source,
  authority, jurisdiction, freshness, rights, conflict, and offline behavior.
- `career-domain-authority-corpus-expansion` must be separately researched,
  scoped, and approved before NYSED registered-nursing or NASA program/cycle
  claims can become recommendation-eligible beyond the foundation's bounded
  O*NET corpus.
- Other career-domain content cannot become recommendation-eligible until its
  evaluated corpus coverage and authority bars exist for the supported United
  States destination class.
- `destination-adoption-and-pivot`, `adaptive-path-comparison`,
  `goal-path-generation`, and `context-quality-scheduling` own later mutation,
  comparison, route, and placement behavior.
- `verifiable-credential-import` and `user-profile-archive-import` own their
  distinct inbound evidence contracts.

### Risks

- Source coverage or ordering can invisibly narrow the user's future even when
  no score is shown.
- Historical labor patterns and typical preparation can be mistaken for gates
  or launder inequity into personalized exclusion.
- Career language can overstate employability, identity, happiness, salary, or
  probability of success.
- Protected-context inference can expose sensitive information through the
  destination itself, not only through the written rationale.
- Competitive and regulated facts can become materially wrong between
  exploration and adoption.

### Decisions carried into Design

- Design may express the defined coverage rotation, omitted-candidate inspection,
  substitution, and refinement contract, but may not change its order, introduce
  a winner or compatibility score, or silently prune an eligible candidate.
- The exact plain-language labels for typical, hard-gate, mixed-cycle,
  source-check-first, and unavailable states must be comprehension-tested while
  preserving their distinctions.
- Representative corpus scale, response-time, accessibility, and comprehension
  targets require measurement during grooming; no unmeasured numeric claim is
  approved here.
