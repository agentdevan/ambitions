+++
initiative = "hobby-destination-recommendations"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

The user can deliberately open a calm hobby-exploration session, say whether
they want to make or express something or notice, learn, and collect knowledge,
and choose whether existing Capabilities should influence the session. Ambitions
then offers a small unranked set of low-risk possibilities from the first-release
creative/making and knowledge/collecting families, each with an understandable
reason, a source-bounded description, a modest beginner entry point, and honest
unknowns about cost, equipment, space, access, and freshness.

The experience is an invitation, not an assessment or a commitment. It does not
declare identity, aptitude, proficiency, taste, productivity, or the correct use
of free time. The user may ignore every possibility, explore something unrelated,
or leave without creating a Goal, changing a Capability or Life Area, recording
a durable preference, contacting a provider, publishing activity, or scheduling
anything.

## In scope

- One explicit, local, no-account hobby-exploration session.
- Two first-release activity families: creative/making and
  knowledge/collecting.
- Two optional session choices: desired experience (`Make or express` or
  `Notice, learn, or collect`) and familiarity (`Build from something I know`,
  `Mix familiar and new`, or `Start completely new`).
- Deliberate selection of exact eligible Capabilities when the user wants prior
  progress to influence the session; capability-free exploration remains
  available.
- Fresh purpose-specific consent before an exact protected user fact may
  participate, with fail-quiet handling for unknown classification or
  over-revealing derived output.
- Two to four unranked possibilities when that many safely supported and
  meaningfully distinct candidates exist; fewer results and quiet unavailability
  are preferable to filler, while every additional eligible current-corpus
  possibility remains discoverable and user-refinable.
- For each possibility: activity and family, what the practice involves, why it
  appeared, selected prior progress that may lower the starting barrier, a
  low-pressure beginner entry point, known practical considerations, explicit
  unknowns, and inspectable source/provenance/freshness boundaries.
- A low-risk first-release eligibility boundary that does not depend on current
  provider availability, purchase, certification, legal interpretation,
  safety-bearing instruction, or an external account.
- Current-session dismissal, correction of selected inputs, and an explicit
  route to see unrelated possibilities without capability support.
- Offline fallback, local-only private matching, quiet degraded states, and
  direct accessibility verification.

## Out of scope

- Social/community and physical/safety-bearing recommendation families in the
  first release.
- A universal hobby taxonomy, popularity feed, nearby-provider search,
  marketplace, ranked list, score, personality profile, aptitude assessment,
  or declaration that an activity is a best fit.
- Inferring desired experience, protected facts, disability/access needs,
  health, age, relationships, location, schedule, affordability, or taste.
- Using hidden learned state, all Capabilities by default, durable rejection
  history, or a generic capability-use setting as consent for exploration.
- Creating or adopting a destination or Goal; generating routes or Steps;
  placing activity in Time; or mutating Capability, Life Area, Proof, learning,
  or schedule state.
- Current provider, club, class, instructor, price, capacity, location,
  accessibility, equipment-rental, weather, site, legal, certification,
  emergency, or medical claims.
- Provider contact, booking, purchase, enrollment, membership, waitlisting, or
  any other external transaction. No current initiative owns or authorizes
  these actions.
- Publishing, posting, sharing, exporting, community/profile integration, or
  external-account contribution. No current initiative owns or authorizes
  these actions.
- Treating community material as authority for rules, qualifications, legal
  duties, emergencies, or safety.
- Notifications, streaks, deadlines, progress pressure, monetization prompts,
  resume framing, credentialization, or automatic career/education reframing.

## Requirements

### REQ-001 — Exploration begins only by explicit choice

Ambitions must not surface personalized hobby destinations passively. The user
must deliberately start a hobby-exploration session, and the session must state
that it is private, local, optional, and non-committing. Starting or leaving the
session creates no Goal, preference, Receipt, external effect, or mutation.

### REQ-002 — First-release families are narrow

Eligible destinations must belong to the creative/making or
knowledge/collecting family and have a low-risk beginner entry that can be
described without current provider, safety, legal, certification, purchase, or
external-account dependence. A candidate that crosses those boundaries must be
omitted rather than simplified into an unsafe or incomplete suggestion.

### REQ-003 — Desired experience is temporary and user-stated

The user may select `Make or express` or `Notice, learn, or collect`, plus
`Build from something I know`, `Mix familiar and new`, or `Start completely
new`. These choices apply only to the current session and must not become a
personality label, Life Area, persistent preference, learned influence, or
claim about what the user should enjoy.

### REQ-004 — Capability use is granular and optional

Capability reuse is one possible explanation, not the purpose of leisure. The
user must select each eligible Capability that may influence the session; no
default-all selection or generic permission is sufficient. The user may select
none, may request unrelated possibilities, and must never be told that selected
progress proves aptitude, proficiency, identity, or likely enjoyment.

### REQ-005 — Protected input is exact, fresh, and fail-quiet

Ambitions must never infer a protected fact for hobby exploration. An exact
protected user fact may participate only after the user deliberately selects it
and reviews a fresh purpose-specific explanation of what it could change and
what could appear in the rationale. Unknown classification blocks its use. If
a candidate or explanation would reveal protected context beyond that exact
consent, Ambitions must omit the affected result without substituting a proxy
or revealing why it was suppressed.

### REQ-006 — The set is small, unranked, and never padded

When evidence supports them, Ambitions must offer two to four meaningfully
distinct possibilities. No order, emphasis, number, confidence display, or copy
may imply a winner, score, ranking, popularity, or prescribed choice. If fewer
than two candidates safely satisfy the selected inputs and source boundary, the
experience must show the smaller truthful set or quiet unavailability rather
than repeat, stretch, or invent a candidate. When more than four qualify, the
visible four and eligible overflow must follow REQ-015; the four-result boundary
must never silently prune or make the remainder undiscoverable.

### REQ-007 — Every possibility has an honest minimum explanation

Each possibility must identify the activity and family, describe what the
practice involves, state which exact session choices caused it to appear, name
only the selected Capabilities that may lower its starting barrier, offer a
modest beginner entry point, and distinguish known practical considerations
from unknown cost, equipment, space, access, local, seasonal, or freshness
facts. The explanation must not predict enjoyment or completion.

### REQ-008 — Public claims retain claim-specific authority

Activity descriptions, practice vocabulary, and beginner ideas must remain
bound to approved public references with source kind, authority-for-purpose,
version, freshness, jurisdiction where relevant, conflict, and uncertainty.
Program owners may describe only their programs; community or provider material
cannot become authority for universal progression, user meaning, rules,
qualification, legal, emergency, or safety claims. Missing or conflicting
required authority makes the candidate unavailable.

### REQ-009 — Source detail is inspectable without becoming pressure

The user must be able to inspect the source, freshness, supported claim,
limitations, and unknowns behind a possibility. The resting explanation may
remain concise and human-readable; provenance must not become a badge, quality
score, endorsement, or implication that the source knows the user's private
context.

### REQ-010 — Matching and feedback remain private and session-scoped

Selected Capabilities, experience choices, protected consent, candidate set,
rationale, dismissal, correction, and exploration history are private graph
context used locally for the current session only. Dismissing a possibility
must remove it from that session without shame or argument. Correcting inputs
must recompute the session without retaining the rejected interpretation as a
durable learning signal.

### REQ-011 — Public-reference egress contains no private signal

Source Atlas or R2 may deliver only allowlisted public packs and freshness data.
No private selection, Capability, desired experience, dismissal, protected
fact, location, schedule, candidate, rationale, query, derived identifier, or
feedback may influence a request, cache key, log, diagnostic, or telemetry
payload. Offline, stale, invalid, or unavailable public data must use a verified
local fallback or yield quiet unavailability without relaxing this boundary.

### REQ-012 — Recommendation owns no downstream mutation

Opening, dismissing, or expressing interest in a possibility must not create or
change a Goal, Step, Path, schedule, Capability, Life Area, Proof, credential,
or provider relationship. `destination-adoption-and-pivot` owns any later
explicit destination/Goal adoption, `goal-path-generation` owns route and Step
proposals, and `context-quality-scheduling` owns Time placement. Each remains a
separate reviewed action under its own approved Scope.

### REQ-013 — The language and controls remain invitational

The experience must support `None of these`, `Try something unrelated`, input
correction, and exit at every decision point. Copy must avoid `best`, `perfect
fit`, `should`, productivity, employability, mastery, wasted-time, streak,
urgency, or identity framing. No rejection lowers a score, closes future access,
or produces repeated persuasion.

### REQ-014 — The experience is accessible and fail-quiet

Session purpose and privacy, temporary inputs, Capability selection, protected
consent, candidate count, explanations, unknowns, source inspection, dismissal,
correction, unrelated exploration, empty/degraded state, and exit must have a
deterministic semantic order. All controls must support VoiceOver, Voice
Control, Switch Control, Full Keyboard Access, Dynamic Type, increased
contrast, reduced effects, non-color state, named non-gesture controls, status
announcements, and predictable focus restoration. Failure must preserve user
choices locally, disclose no protected rationale, create no mutation, and offer
a quiet retry, correction, or exit.

### REQ-015 — Eligible overflow uses stable diversity without scoring

Eligibility must be decided only by the explicit session inputs, first-release
family boundary, privacy suppression, and source/safety requirements already
defined in this Scope. When more than four non-suppressed candidates qualify,
the visible set must preserve family diversity before repetition: if both
creative/making and knowledge/collecting contain eligible candidates, at least
one from each family appears before another slot is filled from either family.
Remaining slots alternate between families while both have unseen eligible
options. Within each family, stable public activity identity and then
user-visible activity name break ties. These rules are neutral inclusion rules,
not fit, quality, popularity, confidence, or preference scores, and the product
must say that display order carries no recommendation meaning.

The experience must disclose the count of additional non-suppressed eligible
possibilities and let the user inspect all of their identities, families,
inclusion bases, and known/unknown state in the same neutral order. The user may
select an omitted eligible possibility into the visible set or refine the
explicit experience, familiarity, family, or Capability inputs and recompute.
That action must not create a durable preference or demote another activity.
Dismissal advances the next eligible possibility under the same neutral rule.
Privacy-suppressed candidates are not counted, identified, or exposed through
an omission reason.

## Acceptance criteria

1. **AC-001 (REQ-001):** No personalized hobby destination appears before the
   user starts exploration. Entering and exiting with no selection creates no
   Goal, preference, Receipt, external request, or durable mutation.
2. **AC-002 (REQ-002):** First-release fixtures produce only low-risk
   creative/making and knowledge/collecting possibilities. Social/community,
   physical/safety-bearing, provider-dependent, purchase-dependent,
   certification-dependent, and external-account-dependent candidates are
   omitted rather than softened into unsupported advice.
3. **AC-003 (REQ-003):** The experience offers exactly the two desired-
   experience choices and three familiarity choices defined by Scope. Leaving
   or restarting clears them, and inspection finds no resulting personality,
   Life Area, learned influence, or durable preference.
4. **AC-004 (REQ-004):** Only deliberately selected eligible Capabilities can
   affect a session. Selecting none and choosing `Start completely new`
   produces capability-free exploration without an aptitude or identity claim.
5. **AC-005 (REQ-005):** A protected fact cannot participate before exact
   selection and fresh purpose review. Unknown classification or an
   over-revealing rationale suppresses only the affected result, exposes no
   proxy or suppression reason, and leaves unrelated eligible results usable.
6. **AC-006 (REQ-006):** Supported fixtures return two to four distinct
   unranked possibilities with no winner signal. Sparse evidence returns fewer
   or an honest empty state without duplicates, invented facts, or filler.
7. **AC-007 (REQ-007):** Every visible possibility identifies its family,
   practice, exact selected-input rationale, bounded prior-progress relevance,
   beginner entry, known considerations, and explicit unknowns without
   predicting enjoyment, ability, or completion.
8. **AC-008 (REQ-008, REQ-009):** Source inspection binds every public claim to
   its authority-for-purpose, version/freshness, limitations, conflicts, and
   unknowns. A community or program source cannot satisfy a rule, legal,
   qualification, emergency, safety, user-meaning, or universal-progression
   claim.
9. **AC-009 (REQ-010):** Dismissal removes a possibility only for the current
   session, correction recomputes from the revised explicit inputs, and session
   end leaves no durable rejection profile, protected-consent reuse, candidate
   history, or hidden learning influence.
10. **AC-010 (REQ-011):** Privacy-egress and offline tests show that equivalent
    allowlisted public requests contain no private-derived signal and that
    stale, invalid, unavailable, or offline source states select only verified
    local fallback or quiet unavailability.
11. **AC-011 (REQ-012):** Opening, dismissing, or expressing interest changes
    no Goal, Step, Path, Time placement, Capability, Life Area, Proof,
    credential, provider, or external system. Any later adoption, path, or
    scheduling action visibly transfers to its named owner as a separate
    proposal.
12. **AC-012 (REQ-013):** `None of these`, `Try something unrelated`, correction,
    and exit remain available without penalty or repeated persuasion; language
    review finds no ranking, optimization, shame, urgency, careerization, or
    identity framing.
13. **AC-013 (REQ-014):** Direct accessibility verification covers session
    framing, inputs, Capability and protected-fact selection, results,
    explanations, unknowns, source inspection, dismissal, correction, unrelated
    exploration, empty/degraded states, retry, and exit without gesture, color,
    motion, side-by-side layout, or visual-only meaning; failure causes no
    mutation or protected disclosure.
14. **AC-014 (REQ-015):** A fixture with more than four eligible candidates
    produces a stable four-option window with at least one option from each
    eligible family before family repetition, alternates remaining family slots,
    and resolves same-family ties by public activity identity then visible name.
    The experience states that order is non-ranking, exposes the complete
    non-suppressed eligible overflow and its inclusion bases, supports choosing
    or refining it, and advances the next neutral option after dismissal without
    revealing the count or identity of a privacy-suppressed candidate.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

- Canon requires a Hobby Destination Recommendation contract to own the
  explicit session, first-release family eligibility, temporary experience
  choices, small unranked candidate set, neutral family-diverse overflow,
  discoverable omissions, rationale, current-session controls, quiet fallback,
  and prohibition on downstream mutation. It must remain distinct from a hobby
  taxonomy, marketplace, provider, or Goal owner.
- The canonical Capability owner must own capability identity, evidence,
  correction, deletion, and eligibility for explicit recommendation use;
  `capability-continuity-foundation` is the initiative expected to establish
  that contract. Hobby recommendation owns only the user's session-scoped
  selection and bounded explanation.
- `public-reference-knowledge-foundation` is expected to establish the public
  activity, claim-authority, provenance, freshness, licensing, conflict, and
  fallback contracts. `docs/canon/specifications/systems/source-atlas.md`
  continues to own finite public delivery and the no-private-signal firewall;
  local recommendation matching must not expand Source Atlas authority.
- `docs/canon/specifications/systems/privacy-and-data-classification.md` should
  own session input classification, exact protected-fact consent, derived-
  output suppression, retention, and the prohibition on private recommendation
  egress. `docs/canon/specifications/systems/local-learning.md` should make
  explicit that session choices and dismissals create no hidden personality or
  durable learning influence.
- `docs/canon/specifications/global/trust-inspection.md` should own layered
  rationale, source, freshness, limitations, privacy, and correction inspection
  without turning provenance into prominent scoring. The appropriate You-owned
  product surface should provide discoverability while preserving the Life Area
  rule that a suggestion cannot silently classify the user.
- `destination-adoption-and-pivot`, `goal-path-generation`, and
  `context-quality-scheduling` retain exclusive ownership of adoption/Goal
  creation, routes/Steps, and Time placement respectively. Provider contact,
  transactions, publishing, and external community/profile integration have no
  approved owner or authority in this portfolio and remain excluded.

## Risks and open decisions

Resolved product decisions:

- The first release includes only creative/making and knowledge/collecting
  activity families and only candidates with a low-risk, provider-independent,
  non-transactional beginner entry.
- The session uses the exact two desired-experience choices and three
  familiarity choices in REQ-003. They are temporary and user-stated, never
  inferred or retained as identity.
- The result contains two to four unranked possibilities when supported, may
  contain fewer, and is never padded. When more than four qualify, stable
  family-first alternation and public identity/name tie-breaking choose the
  visible window while every non-suppressed eligible remainder stays
  discoverable and user-refinable.
- Capability use is opt-in and granular; capability-free novelty is a first-
  class path. Protected facts require exact fresh consent and unknown or
  over-revealing output fails quiet.
- Public authority is claim-specific. The four-family Research pilot validates
  the boundary but does not approve photography, birdwatching, Scouting,
  Cornell, Toastmasters, sailing, or any source as a production corpus.
- The session records no durable preference or rejection. Adoption, Goal Path,
  and scheduling are separate named initiatives; provider contact and
  publishing remain unowned and excluded.

Dependencies and delivery risks:

- This Scope depends on approved Capability continuity and public-reference
  contracts before a production recommendation can use private progress or
  claim current public grounding. Missing dependencies require generic local
  exploration or quiet unavailability, not placeholder authority.
- Creative/making and knowledge/collecting still contain activities whose tools,
  locations, materials, field conditions, or subject matter can become unsafe.
  Eligibility and abuse fixtures must prove that the first-release boundary
  excludes any candidate whose beginner entry needs unavailable safety, legal,
  certification, provider, or external-account facts.
- Coverage may be culturally narrow, repetitive, inaccessible, costly, or
  biased toward activities with strong English-language institutional sources.
  Evaluation must distinguish missing data from user unsuitability and must not
  use popularity as a substitute for diversity.
- Cost, equipment, space, accessibility, season, and local availability can
  change or be absent. Unknown must remain visible and must not become a fit
  judgment, while a missing required boundary must suppress the candidate.
- Even non-ranked sets can create implied ranking through order, emphasis, copy,
  repetition, or overflow treatment. Comprehension and pressure testing must
  verify that neutral family diversity, tie handling, discoverable omissions,
  and user refinement do not read as a hidden score and that users experience
  the set as optional and invitational.
- Exact protected-output suppression must avoid both direct disclosure and
  proxy leakage through candidate absence, rationale wording, diagnostics,
  accessibility announcements, or source requests.
