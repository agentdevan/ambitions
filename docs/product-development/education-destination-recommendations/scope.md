+++
initiative = "education-destination-recommendations"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

A user with a chosen learning or life objective can understand three materially
different ways to learn next: a degree program, a provider-issued professional
certificate, and an open self-study course. Ambitions explains what each route
form can and cannot establish, how selected user-owned capabilities may reduce
learning repetition, and which offering, recognition, transfer, cost, and
outcome facts remain unknown.

The experience begins without named-provider pressure. Only after the user
explicitly asks to explore current providers may Ambitions show a small,
unranked set of named offerings. Starting exploration is not consent to use all
private context. The user selects each input that may participate, and a
protected fact participates only after a fresh disclosure and consent for that
exact education purpose.

The result is a calm decision aid, not a school marketplace or admissions
oracle. The user can inspect, correct, save, dismiss, or choose a destination to
take into the separate Goal-adoption flow. Recommendation never enrolls,
applies, contacts a provider, awards credit, creates a Goal, generates a Goal
Path, or places learning into Time.

## In scope

- Explicit, user-initiated exploration from one stated learning objective or
  already chosen life direction.
- A first-stage comparison of exactly three route forms: degree program,
  provider-issued professional certificate, and open self-study course.
- Separate explanations for classification, learning meaning, current offering,
  recognition/accreditation, transfer/prior learning, and descriptive outcomes.
- Local use of only the capability, education/training, objective, preference,
  and constraint facts the user selects for this exploration.
- Fresh, purpose-specific selection and consent before any protected fact may
  influence matching, filtering, omission, or explanation.
- An explicit provider-intent action before named institutions, programs,
  certificates, or courses appear.
- After provider intent, zero to two source-qualified current offerings per
  requested route form, with coverage limits, inclusion reasons, and a
  non-scoring way to inspect and choose among every additional eligible
  offering in the approved corpus.
- Unranked qualitative comparison, prior-learning overlap, missing evidence,
  correction, save/defer, bounded dismissal, and Goal-adoption handoff.
- Local-first, offline-degraded, private, accessible, stale-state, interruption,
  and recovery behavior.

## Out of scope

- Certifications, apprenticeships, employer training, community programs,
  bootcamps, tutoring, or other route forms in this increment.
- A complete provider directory, universal catalog, sponsored placement,
  monetized ranking, search-engine replacement, or claim of market coverage.
- Named-provider results before explicit provider intent.
- Admissions, financial-aid, financing, return-on-investment, licensing,
  accreditation, transfer-credit, or professional eligibility decisions.
- Claiming that capability overlap proves mastery, waives a prerequisite,
  awards credit, shortens a program, or guarantees acceptance or completion.
- Provider contact, enrollment, application execution, payment, document
  submission, external writes, or calendar changes.
- Credential or profile import, destination discovery outside education, career
  recommendation, Goal creation, Goal Path generation, Step creation, Proof-rule
  acceptance, or schedule placement.
- Inferring disability/accommodation needs, immigration or citizenship status,
  age, finances, family context, location, or another protected fact.
- Sending private objectives, capabilities, history, constraints, preferences,
  recommendation context, or provider choices to Source Atlas, R2, Account,
  hosted AI, telemetry, or an external profile.
- A compatibility, program-quality, employability, earnings, prestige, or
  best-option score.

## Requirements

### REQ-001 — Exploration begins from user-owned direction

Education exploration must begin only after the user explicitly requests it
and states or selects one learning objective or already chosen life direction.
The product must show that the objective is user-owned and that recommendations
are possibilities, not new Goals or judgments about what the user should do.

### REQ-002 — The first comparison preserves three route forms

Before named-provider exploration, Ambitions must compare the degree program,
provider-issued professional certificate, and open self-study course forms as
distinct options. Each form must explain its typical learning commitment,
credential or completion meaning, recognition limits, transfer limits, and
unknowns. A form with insufficient current evidence remains visible as
unavailable or unknown rather than being silently replaced by an out-of-scope
form or treated as equivalent to another.

### REQ-003 — Provider intent is a separate threshold

Named institutions, programs, certificates, or courses may appear only after
the user chooses an explicit action to explore current providers for one or more
route forms. Before that action, the experience may explain route types but
must not name, rank, or imply endorsement of a provider. Provider intent does
not authorize enrollment, contact, application, external writes, or use of
additional private facts.

### REQ-004 — Named offerings remain bounded and non-comprehensive

For each route form the user asks to explore, Ambitions may show zero, one, or
two named offerings that meet the source and freshness contract. If the user
names a specific offering, it occupies one of those two positions when it passes
source review; otherwise the product shows the exact unavailable or insufficient-
evidence reason instead of a candidate. The product must state the coverage
boundary and inclusion reason for every offering and must never claim that
omitted options are worse or that the set represents the full market.

When more than two offerings in the approved corpus are eligible for the same
route form, the product must disclose the total eligible count, show that the
two-option comparison is a user-manageable window rather than a top-two result,
and make every other eligible offering discoverable by identity and inclusion
basis. Until the user chooses a pair, the window uses stable neutral ordering by
provider identity and offering identity, never relevance, quality, popularity,
outcome, price, prestige, or another hidden score. The user may inspect the
omitted eligible set, select any eligible offering into the two-option window,
or narrow with an already selected or separately consented input under REQ-009
and REQ-010. A narrowed or user-selected window must retain the eligible count,
active narrowing basis, and access to the remaining eligible set. A result
suppressed under REQ-010 is not display-eligible and must not contribute to the
count, identity list, or omission explanation.

### REQ-005 — Every option preserves six authority lanes

Each named education option must keep these evidence lanes independently
inspectable:

1. classification of the field or program family;
2. learning meaning or competencies and their publisher;
3. provider-owned current offering facts;
4. recognition, accreditation, approval, certification, or licensing status
   from the authority that owns that status;
5. transfer or prior-learning recognition from the receiving authority or a
   named agreement; and
6. descriptive outcomes with cohort, geography, date, suppression, and method
   limits.

An absent lane must be labeled unknown or not applicable. One lane cannot
substitute for another.

### REQ-006 — Provider-owned offering facts are exact and current

Program identity, provider/branch, catalog or course version, delivery mode,
dates, duration, cost, prerequisites, technology or location requirements, and
current availability must cite the provider or authority that owns each fact,
with region, retrieval date, freshness, and contradiction state. Classification
or discovery sources cannot impersonate a provider catalog or current opening.

### REQ-007 — Accreditation and recognition do not imply fit

Accreditation or other recognition must state the exact institution/program
scope, reporting authority, status, monitoring/action state, effective or review
date, and limitations. It must not be presented as admission, transfer,
licensure, affordability, program quality, individual fit, or guaranteed
outcome. Conflicting or incomplete authority records remain visible and block a
simple recognized/not-recognized conclusion.

### REQ-008 — Prior learning is explained without awarding credit

Selected capabilities, Proof, education history, training, and credentials may
show curriculum overlap, possible reduced repetition, or eligibility for formal
evaluation. Ambitions may claim a waiver, transfer value, requirement
satisfaction, or awarded credit only from a current receiving-institution
decision or explicit applicable agreement. Exact catalog year, credential
version, completion artifact, receiving program, and individual evaluation must
remain material where applicable.

### REQ-009 — Private inputs are selected, inspectable, and revocable

Starting education exploration authorizes no private input by default beyond
the objective the user just supplied. Before matching, the user must be able to
select which eligible non-protected capabilities, education/training facts,
preferences, and constraints may participate, inspect how each affected the
result, remove one, and recompute. A generic capability future-use setting is
not education-specific permission. If the supplied objective itself reveals or
may reveal protected context, REQ-010 applies before it influences a result.

### REQ-010 — Protected inputs require exact fresh consent and fail quiet

Ambitions must never infer a protected fact. A protected fact may participate
only when the user deliberately selects that exact fact after a fresh disclosure
of the education purpose, affected comparison behavior, local-only handling,
retention, and revocation consequence, then explicitly consents. Consent to one
fact or purpose does not authorize another. If classification is uncertain, the
fact is missing, consent is absent/revoked, or a destination or rationale would
reveal protected context beyond the consent, the affected result must be omitted
quietly without a proxy, negative inference, or explanation that exposes why.

### REQ-011 — Recommendation is qualitative and user-correctable

Each option must explain why it is relevant, selected capability overlap and
its limits, material differences, prerequisites, commitment, cost evidence,
recognition, transfer evidence, descriptive outcomes, source freshness, and
unknowns. The user can correct selected inputs, source interpretation, or
relevance. The product must not rank options or expose a compatibility,
quality, earnings, prestige, employability, completion, or return score.

### REQ-012 — User controls preserve agency and avoid hidden profiling

The user can inspect, save for later, defer, dismiss an exact option/rationale,
request a different route-form mix within the three forms, remove provider
intent, or end exploration. Dismissal applies only to the exact option,
rationale, evidence basis, and review context and keeps that unchanged basis
quiet until the user requests reconsideration or a material objective, offering,
source, or selected-input change creates a new basis. Any broader exclusion
requires a separate scoped, inspectable, reversible choice and must not become
a hidden trait, financial judgment, or education-potential profile.

### REQ-013 — Stale, conflicting, and unavailable evidence degrades honestly

If a provider catalog, accreditation status, articulation, outcome measure, or
other material source becomes stale, contradictory, revoked, unavailable, or
inapplicable, the affected fact and options must be marked for review and cannot
be presented as current. Verified cached public facts may remain available
offline with their freshness state. When current provider claims cannot be
established, Ambitions must fall back to route-form comparison or manual source
inspection rather than fabricate a named recommendation.

### REQ-014 — Choosing an option creates only a handoff

Selecting an education option must show the exact destination meaning, provider
identity if named, evidence/unknown summary, and unresolved external decisions,
then offer handoff to `destination-adoption-and-pivot`. It must not create a
Goal, accept a route, create Steps, set Proof requirements, schedule learning,
contact a provider, submit an application, or assert admission or transfer.

### REQ-015 — Ownership remains explicit

Capability continuity owns user capability evidence; the public-reference
foundation and Source Atlas own public artifact delivery, provenance, and
freshness; providers own offerings; recognized accreditors/approval bodies own
recognition; receiving institutions or named agreements own transfer; licensing
and certification bodies own their gates; College Scorecard-like sources own
only their stated descriptive measures. Credential/profile import,
destination adoption, Goal Path generation, and scheduling retain their named
boundaries. Education recommendation owns only local option composition and
explanation.

### REQ-016 — Recommendation remains private, local, and offline-capable

Objectives, selected inputs, protected consent, local matches, corrections,
dismissals, recommendation history, and provider interest are private local
graph data. They must work without account or network using verified cached or
bundled public facts where available. Public-reference requests must use only a
finite public artifact identity and contain no private-derived query, identifier,
cache key, log, or feedback. Every prohibited destination must fail closed.

### REQ-017 — Interruption and recovery preserve honest review state

Resume must restore the objective, route-form selection, provider-intent state,
selected input/consent scope, option identities, sources, corrections, dismissal,
review position, and focus after revalidating changed facts. Cancellation before
handoff creates no canonical object. Source refresh or input removal must update
only dependent explanations/options and never silently retain withdrawn input.

### REQ-018 — The full comparison is accessible

Route form, provider identity, evidence-lane ownership, source/freshness,
selected-input use, protected-consent state, overlap limits, unknowns,
dismissal, handoff consequence, and recovery must have an ordered semantic
representation. VoiceOver, Voice Control, Switch Control, Full Keyboard Access,
Dynamic Type, increased contrast, reduced motion, RTL, and non-color cues must
support all actions. Missing public accessibility-support information must be
shown as unknown, not as evidence that support is absent. Focus and status
announcements must return to the exact changed option, consent, source, or
recovery action.

### REQ-019 — Named education offerings require approved domain-corpus expansion

The approved public-reference foundation's first validation corpus is limited
to the O*NET 30.3 United States `15-1252.00 Software Developers` slice. That
occupation-description corpus cannot establish UMGC, Google, CS50x, or any
other education provider, offering, curriculum, recognition, transfer,
licensing, rights, or current-availability claim. Before a named education
offering may participate in product recommendation or the production
evaluation corpus, a separately approved education-domain corpus expansion must
establish its exact sources, claim-level authority, rights and redistribution
state, jurisdiction, version, freshness, conflicts, offline behavior, and
coverage limits under `public-reference-knowledge-foundation`.

The UMGC, Google, and CS50x materials in approved Research remain paper-pilot
evidence only until that expansion is approved. Without it, Ambitions must keep
named-provider recommendation unavailable and offer route-form comparison or
manual source inspection; it must not promote a Research URL, live ad hoc fetch,
or the O*NET slice into education-domain authority.

## Acceptance criteria

1. **AC-001 (REQ-001):** Education exploration starts only after an explicit
   user request with one objective and states that outputs are possibilities,
   not Goals or personal-potential judgments.
2. **AC-002 (REQ-002):** The first review shows degree, provider certificate,
   and open self-study as distinct forms with commitment, completion/credential,
   recognition, transfer, and unknown meanings; unsupported forms remain visibly
   unavailable rather than being substituted.
3. **AC-003 (REQ-003):** No named provider appears before the provider-intent
   action; activating it names the requested form scope and creates no Goal,
   enrollment, contact, application, write, or additional-input permission.
4. **AC-004 (REQ-004):** Provider review shows no more than two offerings per
   requested form, gives every inclusion and coverage reason, honors a specific
   user-named offering within the bound only when it passes source review, shows
   the exact insufficiency otherwise, and makes no completeness or omitted-option
   quality claim. A fixture with more than two eligible offerings exposes the
   total eligible count and every omitted eligible identity/inclusion basis,
   uses stable provider/offering identity order until the user selects a pair,
   and lets the user inspect, choose, or explicitly narrow without a hidden
   score or loss of access to the remaining eligible set; privacy-suppressed
   results contribute no count, identity, or omission explanation.
5. **AC-005 (REQ-005):** Each named option independently exposes all six evidence
   lanes or labels a lane unknown/not applicable; substituting classification,
   provider, accreditation, transfer, or outcome authority fails validation.
6. **AC-006 (REQ-006):** Every offering fact resolves to the exact provider or
   owning authority, identity/version, region, retrieval date, freshness, and
   contradiction state; discovery metadata alone cannot claim current offering.
7. **AC-007 (REQ-007):** The UMGC fixture separately shows institution-wide
   accreditation, distance-education scope, active monitoring/report state, and
   limitations without claiming admission, transfer, quality, fit, or outcome.
8. **AC-008 (REQ-008):** Google-certificate and CS50x overlap can be described,
   but neither reduces the UMGC program or awards credit without exact current
   receiving-institution evidence; the free CS50 certificate is not treated as
   the ACE-backed artifact.
9. **AC-009 (REQ-009):** A fresh exploration initially uses only the stated
   objective; adding and removing one eligible input visibly changes only its
   dependent rationale/options and education use never relies on a generic
   future-use flag. A protected or uncertain objective cannot influence a result
   until REQ-010 consent succeeds.
10. **AC-010 (REQ-010):** Each protected input requires its own fresh purpose
    disclosure and explicit consent; absent, revoked, uncertain, or out-of-scope
    protected context yields no affected result, proxy, negative claim, or
    revealing explanation.
11. **AC-011 (REQ-011):** All three route forms show qualitative relevance,
    overlap limits, commitment, evidence, source state, and unknowns without a
    rank or quality/earnings/prestige/employability/completion/return score; each
    correction recomputes only declared use.
12. **AC-012 (REQ-012):** Save, defer, exact dismissal, route-form adjustment,
   provider-intent removal, and end-exploration actions preserve their stated
   scope; unchanged dismissed content returns only on user reconsideration or a
   materially new basis; broader exclusion is explicit, inspectable, reversible,
   and creates no hidden trait.
13. **AC-013 (REQ-013):** A stale catalog, changed accreditation action, missing
    articulation, and suppressed outcome measure each stale only dependent
    claims/options; unavailable current facts fall back to type-level or manual
    inspection without a fabricated named recommendation.
14. **AC-014 (REQ-014):** Selecting an option produces only a destination handoff
    with identity, evidence, and unknowns; Goal, Path, Step, Proof, Time, provider,
    application, and transfer state remain unchanged.
15. **AC-015 (REQ-015):** Inspection identifies the named owner for every
    capability, public source, offering, recognition, transfer, gate, outcome,
    import, Goal, path, and placement fact; education recommendation claims only
    local composition/explanation authority.
16. **AC-016 (REQ-016):** Type and cached-provider review work offline, public
    requests contain only allowlisted artifact identity, and privacy-egress
    tests show no private value or derived signal at a prohibited destination.
17. **AC-017 (REQ-017):** Interruption/resume, source refresh, input withdrawal,
    consent revocation, cancellation, and retry preserve review state and focus,
    remove withdrawn influence, and create no duplicate or canonical mutation.
18. **AC-018 (REQ-018):** Direct assistive-technology verification proves
    ordered form/provider/evidence/consent semantics, every action, focus and
    announcements, Dynamic Type, contrast, reduced motion, RTL, non-color parity,
    and an explicit unknown state for unavailable accessibility-support facts.
19. **AC-019 (REQ-019):** With only the approved O*NET validation slice, UMGC,
    Google IT Automation with Python, and CS50x cannot appear as production
    named offerings and the experience falls back to route-form comparison or
    manual inspection. They become eligible for recommendation fixtures only
    after a separately approved education-domain corpus binds every required
    authority, rights, version, freshness, conflict, offline, and coverage fact;
    Research links and ad hoc network fetches cannot satisfy the gate.

## Dependencies

- Approved capability continuity supplies only user-selected local capability
  evidence and never credit, mastery, or recommendation authority.
- `public-reference-knowledge-foundation` and Source Atlas supply verified
  public artifact identity, authority, licensing, jurisdiction, freshness,
  contradiction, cached/offline behavior, and the no-private-query firewall.
- Its approved first validation corpus is only the O*NET 30.3 Software
  Developers slice. Named education offerings—including the UMGC, Google, and
  CS50x pilot routes—depend on a separate approved education-domain corpus
  expansion before product recommendation or production evaluation.
- Career destination work may hand off a learning need but cannot select the
  education destination.
- `verifiable-credential-import` and `user-profile-archive-import` own inbound
  evidence and remain optional, separately consented inputs.
- `destination-adoption-and-pivot` owns Goal creation;
  `goal-path-generation` owns route and Step proposals; and
  `context-quality-scheduling` owns placement.
- Application execution, enrollment, financing, provider contact, and external
  writes are excluded future ideas, not implied dependencies.

## Canon impact

- A new education-recommendation system contract should own explicit exploration,
  the three-form portfolio, provider-intent threshold, local option composition,
  qualitative explanation, neutral two-option comparison windows, discoverable
  eligible overflow, bounded dismissal, and destination handoff.
- Source Atlas canon retains public artifact/freshness delivery and firewall
  ownership; it must not receive private objectives or become the recommender.
- Privacy/data-classification canon should own education-purpose input selection,
  per-protected-fact consent, derived-output handling, quiet omission, retention,
  revocation, and prohibited egress.
- Local-learning and capability canon should own selected evidence influence,
  inspection, correction, and removal without scoring or mastery claims.
- Goals surface or the appropriate education exploration presentation owner
  should expose the comparison without a new root surface; Goal, Goal Path,
  Proof, History, Receipt, Time, and external authorities retain their owners.
- Accessibility canon remains fully applicable to route-form, provider,
  evidence-lane, consent, stale, and recovery states.

## Risks and open decisions

Resolved product decisions:

- The initial portfolio contains exactly the degree, provider-issued
  professional-certificate, and open self-study forms.
- Named offerings require explicit provider intent and are limited to zero to
  two per requested form; the comparison window is unranked and
  non-comprehensive, and every additional eligible current-corpus offering
  remains visible and user-selectable without hidden pruning.
- The O*NET 30.3 Software Developers validation slice is not an education
  offering corpus. UMGC, Google, CS50x, or any other named offering requires a
  separately approved education-domain corpus expansion before product use.
- Six evidence lanes remain separate and missing lanes remain unknown.
- Exploration uses only explicitly selected inputs. Each protected fact requires
  fresh exact-purpose consent and otherwise fails quiet without a proxy.
- Capability overlap never awards credit; a receiving authority or applicable
  agreement owns formal transfer.
- Option selection hands off to destination adoption and commits nothing else.

Remaining Design-level risks are comprehension of type-level versus named
provider review, dense six-lane evidence, source conflict/freshness language,
quiet omission without confusing gaps, and consent fatigue. Design may resolve
presentation and progressive disclosure but may not weaken provider intent,
protected-input consent, authority ownership, or the no-ranking boundary.
