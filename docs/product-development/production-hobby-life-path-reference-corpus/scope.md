+++
initiative = "production-hobby-life-path-reference-corpus"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions will maintain a source-native, offline-capable catalog of reviewed
non-career and non-formal-education possibilities. It will make real creative/
making, knowledge/collecting, service/community, and physical/recreation
identities inspectable while admitting only sufficiently supported low-risk
creative/making and knowledge/collecting records to the existing hobby
recommendation consumer.

A person can understand what a possibility is called, which public source and
revision supplied the identity, why Ambitions admitted or restricted it, what
starter materials or public overlays exist, which facts remain unknown, and
what the corpus cannot decide. The catalog never defines the user's identity,
value, interests, proficiency, best use of time, or preferred life.

This is a public possibility catalog, not a universal taxonomy, marketplace,
safety guide, personality model, recommendation engine, or canonical Life
Branch. Structural coverage never implies suitability, current opportunity,
complete safety, recommendation usefulness, or release readiness.

## In scope

- A finite, versioned, manually reviewed allowlist of Wikidata structured-data
  entities representing non-career/non-formal-education possibilities.
- Source-native QID, dump/revision, language labels and aliases, redirects/
  merges, direct reviewed source relations, references/ranks where present, and
  CC0 structured-data provenance.
- A separate Ambitions editorial eligibility record for inclusion, non-
  exclusive facets, risk class, eligible purposes, evidence, non-claims,
  reviewed state, correction, and change lineage.
- Four non-exclusive top-level discovery facets: creative/making,
  knowledge/collecting, service/community, and physical/recreation. Records may
  have multiple or no resolved facet; facets are not a universal hierarchy.
- Recommendation eligibility only for records independently reviewed as
  low-risk creative/making or knowledge/collecting with a complete minimum
  claim set and no unresolved exclusion.
- Inspection-only discovery for service/community and physical/recreation
  records whose current provider/safeguarding or safety/legal/site claim set is
  incomplete.
- Optional source-native Smithsonian CC0 and Library of Congress rights-
  qualified starter material records for inspiration/inspection.
- Independent NPS general-recreation and AmeriCorps civic-statistics overlays
  with their exact authority, clocks, and non-claims.
- Per-source/record rights, attribution, cultural/ethical review, freshness,
  conflicts, correction, withdrawal, and purge behavior.
- Fixed public acquisition identities independent of users; release diffs,
  semantic validation, staged promotion, atomic snapshot pointers, quarantine,
  last-known-good, rollback, invalidation, and historical lineage.
- Local immutable projections for recommendation, Planning, model, Trust, and
  evaluation consumers.
- Accessible inspection and honest missing, unreviewed, ambiguous, deprecated,
  merged, stale, conflicted, unsafe-to-generalize, rights/culturally blocked,
  withdrawn, unsupported, and unavailable states.
- A representative evaluation portfolio for cultural breadth, productivity
  pressure, source authority, unsafe omission, accessibility, correction,
  offline use, and user comprehension.

## Out of scope

- A universal hobby/life-path taxonomy, mutually exclusive categories, hidden
  ontology inference, transitive graph closure, or semantic equivalence among
  Wikidata, communities, Capabilities, careers, education, or Life Areas.
- Current providers, clubs, organizations, events, courses, roles, openings,
  programs, price, equipment availability, place, weather, conditions, permits,
  membership, schedule, accessibility accommodations, or capacity. These
  belong to `current-opportunity-availability-intelligence`.
- Complete rules, emergency/medical/legal advice, safety instruction,
  certification, provider qualification, safeguarding, or participation
  eligibility for a sport/activity/site/jurisdiction.
- Recommendation matching/session behavior, private rationale, durable
  interest/personality profiling, popularity feedback, or personalization.
- User-held participation, membership, account, post, sighting, collection,
  media, Capability, Proof, health, relationship, religion, politics, or other
  private data.
- Goal/Life Area/Life Branch creation, Goal Path/Step generation, scheduling,
  adaptive learning, simulation, provider contact, application, payment,
  account creation, publishing, upload, or any external action.
- Copying non-structured Wikidata page text as CC0; non-CC0 Smithsonian/Library
  media; portal-wide rights inheritance; trademarks/logos; arbitrary source
  URLs; or content without exact access and rights.
- Ranking possibilities, people, cultures, communities, or leisure by value,
  skill reuse, popularity, progress, money, status, productivity, or likely
  success.
- Treating source count, installation, editorial approval, offline availability,
  or corpus breadth as user-value, safety, runtime, merge, deployment, or
  release proof.
- Product source, canon, tests, project state, workflows, or lifecycle tooling
  changes during this documentation phase.

## Fixed first-release policy

The release manifest must contain the exact approved entity and material IDs;
arbitrary search results or a live “hobby” query cannot enter production. Scope
does not impose a vanity record count: the launch floor is the complete set that
passes the fixed policy and evaluation portfolio. Coverage must report its
limits explicitly.

| Layer | Product treatment |
|---|---|
| Wikidata structured identity | Fixed dump/revision and allowlisted QIDs only. Admit labels/aliases, redirects/merges, and individually reviewed direct statements/references. No wiki-page prose, media, arbitrary neighbors, or transitive closure. |
| Editorial eligibility | Ambitions-owned review record for inclusion, facets, risk, claim families, non-claims, evidence, and change history. It controls product eligibility but does not become factual authority over the activity or user. |
| Creative/making and knowledge/collecting | May become `recommendation_discovery` eligible only after low-risk and complete minimum-claim review. Capability/proficiency, cost, equipment, access, and personal meaning remain outside the corpus. |
| Service/community | Identity/inspection only in v1 production. Current organization/role/safeguarding/eligibility and availability evidence is required before recommendation eligibility. |
| Physical/recreation | Identity/inspection only in v1 production. General NPS context does not complete sport/site/weather/equipment/legal/safety claims. |
| Smithsonian Open Access | Exact record and media assets explicitly designated CC0; record/media rights remain separate; credit/source and cultural/ethical state retained. Inspiration/inspection only. |
| Library of Congress | Exact item/set with its own Rights and Access/Advisory state. No portal-wide inheritance. Inspiration/inspection only. |
| NPS overlay | Fixed general planning/responsible-recreation pages with federal park scope and explicit non-claims. General context only. |
| AmeriCorps overlay | Fixed survey release/measure/population/geography/period/method. Descriptive civic context only, never opportunity or normative participation. |

The minimum claim set for `recommendation_discovery` is: eligible stable public
identity; user-readable source label; reviewed non-exclusive facet; low-risk
editorial state; exact source revision and rights; a plain activity description
whose source and editorial modifications are visible; no unresolved harmful/
demeaning label; no required provider/account/current opportunity; no safety,
legal, certification, health, or protected-context dependency; and explicit
unknown practical/accessibility facts. It does not require skill reuse.

## Requirements

### REQ-001 — Finite source-native identity

Every possibility, source entity, statement, material, overlay, editorial
record, release, and claim must have stable source-native and Ambitions IDs.
Visible/eligible claims bind the exact dump/revision/release, language, source
record/statement, retrieval, rights, and review. Live arbitrary graph queries
cannot populate the catalog.

### REQ-002 — No universal taxonomy or transitive meaning

Discovery facets are non-exclusive editorial organization only. Source-native
instance/subclass/part and other relations retain exact direction/source and do
not transitively classify a possibility, prove equivalence, define a user, or
create a required progression. Ambiguous overlap remains inspectable.

### REQ-003 — Wikidata extraction is bounded and revision-aware

Only allowlisted structured entity data under the approved CC0 posture may be
packaged. Each entity retains revision/dump, ranks, references where used,
redirect/merge/deprecation, and unreviewed-statement exclusion. Non-structured
wiki text and media are excluded absent separate rights.

### REQ-004 — Editorial eligibility is inspectable and limited

Every included record must have a versioned editorial decision containing
review evidence, inclusion reason, facets, risk, allowed purposes, non-claims,
language/cultural review state, correction route, reviewer/date, and change
lineage. Editorial approval controls Ambitions use; it does not claim external
factual authority or user suitability.

### REQ-005 — Risk and purpose eligibility fail closed

Only a record satisfying the complete fixed minimum claim set may become
`recommendation_discovery` eligible. Unknown risk, safety/legal/certification/
health dependency, current-provider/account dependency, harmful label,
insufficient rights, stale identity, or unresolved conflict makes it
inspection-only or unavailable. One broad family label cannot widen a record.

### REQ-006 — Social/service and physical/recreation stay inspection-only

Service/community and physical/recreation identities may be browsed and
inspected but cannot drive live hobby recommendations in this release. General
civic or recreation overlays cannot substitute for current organization,
safeguarding, provider, site, equipment, weather, legal, certification, or
safety authority.

### REQ-007 — Starter-material rights remain item and media specific

Each Smithsonian or Library record must retain collection/unit, item/media IDs,
exact rights designation/advisory, source locator, modification/attribution,
third-party/trademark/privacy/publicity/cultural state, and checked date.
Metadata rights must not upgrade a linked media asset. Unclear rights or
cultural/ethical review blocks reuse while preserving allowed inspection.

### REQ-008 — Public overlays retain claim ceilings

NPS records remain federal general recreation context and never complete
activity/site safety or emergency/medical/legal advice. AmeriCorps measures
retain release, method, population, geography, period, unit, and limitations
and never become current opportunities, eligibility, placement, community
ranking, or normative participation.

### REQ-009 — Corpus never defines the user or value of leisure

No public record, facet, view, query, or downstream projection may state or
infer the user's interest, identity, personality, proficiency, capability,
health/access suitability, likely enjoyment/success, best use of time, or duty
to improve, publish, compete, credentialize, monetize, or contribute.

### REQ-010 — Public collection is independent of users

Remote acquisition may request only fixed allowlisted public source/release
identities. User/device ID, ambition, Goal, Life Area, Capability, Proof,
interest, schedule, location, health, disability/access, relationship,
religion/politics, selection, correction, rejection, or recommendation result
must not influence endpoints, parameters, headers, keys, artifacts, logs,
diagnostics, analytics, or source feedback.

### REQ-011 — Per-source freshness, correction, and graph change

Wikidata dump/revision, editorial decision, each material record/media right,
NPS page, and AmeriCorps release keep independent clocks. Source redirects,
merges, deletions, changed statements, corrections, vandalism/regression,
rights changes, and editorial revisions stage as explicit diffs. They do not
silently rewrite history or broaden eligibility.

### REQ-012 — Rights, cultural withdrawal, and attribution

Packaging/visibility/reuse must follow exact source/record/media rights and
required credit. Rights, privacy/publicity, trademark, sacred/culturally
sensitive, community-stewardship, or ethical withdrawal can block affected
content without implying a judgment about the activity or person. Required
purge removes prohibited bytes/derivatives while retaining only permitted
opaque lineage.

### REQ-013 — Per-claim states and consumer eligibility remain orthogonal

Structural validity, source authority, rights, cultural review, freshness,
risk, editorial approval, coverage, conflict, and consumer-purpose eligibility
are separate. A valid source entity may be inspection-only; a CC0 asset may be
culturally blocked; a current record may lack safety or practical facts.

### REQ-014 — Staging, validation, promotion, rollback, and invalidation

Every release must pass public identity, size/decompression, hash/signature,
schema, exact allowlist, source/entity count, redirect/merge, direct-relation,
rights/cultural, editorial, risk, coverage, evaluation, and device gates before
atomic promotion. Failure quarantines the candidate and preserves LKG.
Lifecycle operations are idempotent and replay-safe.

### REQ-015 — Offline, reset, correction, and deletion behavior

The bootstrap or last-verified snapshot remains usable offline with exact age
and coverage. Never-fetched/blocked content is unavailable, not empty. Source
and editorial corrections supersede and invalidate dependent evidence. Users
may clear downloaded catalog data and return to bootstrap without changing
private objects. Rights/cultural purge resumes after interruption.

### REQ-016 — Accessible source and limitation inspection

Users/evaluators can inspect source identity, revision/release, labels/aliases,
direct relations, editorial facets/risk/purpose, rights/cultural state,
freshness, conflicts, starter-material rights, overlay meaning, missing facts,
and non-claims. Progressive disclosure supports VoiceOver, Dynamic Type,
non-color status, stable focus, and Reduced Motion.

### REQ-017 — Coverage, diversity, dignity, and safety evaluation

Each release publishes exact machine-readable coverage/change reports by
family, language, geographic/cultural scope, risk, rights, source/editorial
state, eligibility, missing claim, and exclusion. It must pass grounding,
authority, unsafe omission, privacy, dignity/bias, cultural breadth,
accessibility, productivity-framing, correction, offline, and regression gates.
Counts cannot compensate for a hard failure.

### REQ-018 — Read-only typed downstream boundary and measured budgets

Consumers receive only immutable purpose-eligible public projections with
coverage/limitations and snapshot identity. The corpus accepts no private
context and exposes no recommendation, profile, popularity, mutation,
participation, or external-action API. Bootstrap/full release storage, staging,
query, memory, energy, refresh, rollback, clear, and purge budgets must be
measured on supported devices; thresholds derive from evidence before release.

## Acceptance criteria

1. **AC-001 (REQ-001):** An arbitrary search result, unknown QID/revision, or
   claim without exact source/review binding cannot enter or render from a
   candidate release.
2. **AC-002 (REQ-002):** Multi-facet and ambiguous fixtures preserve overlap;
   transitive/source relation chains do not create classification, equivalence,
   identity, progression, or eligibility.
3. **AC-003 (REQ-003):** Structured allowlisted entity fields round-trip with
   revision/rank/reference/redirect state; wiki prose/media fixtures fail the
   CC0 extraction policy.
4. **AC-004 (REQ-004):** Every included identity links an exact editorial
   decision/history; missing, expired, or widened decisions fail eligibility.
5. **AC-005 (REQ-005):** Low-risk complete creative/knowledge fixtures become
   eligible; unknown risk, tool/safety, protected-context, provider/account,
   harmful-label, stale, conflict, or rights cases fail closed.
6. **AC-006 (REQ-006):** Service and sailing/climbing-like fixtures remain
   inspection-only even with AmeriCorps/NPS general overlays.
7. **AC-007 (REQ-007):** CC0 metadata with restricted media and collection-
   portal “free” with item ambiguity retain their narrower rights; no asset is
   reused without exact media/item clearance.
8. **AC-008 (REQ-008):** NPS and AmeriCorps fixtures display exact scope,
   method/limitations, and non-claims and cannot satisfy safety/opportunity/
   placement/ranking requirements.
9. **AC-009 (REQ-009):** API, projection, and copy tests contain no personal
   interest/identity/fit/proficiency/value/productivity or success claim.
10. **AC-010 (REQ-010):** Unique private canaries produce byte-identical public
    requests, keys, artifacts, logs, diagnostics, and refresh behavior.
11. **AC-011 (REQ-011):** Redirect, merge, deletion, vandalism, changed label/
    relation, material-rights, NPS/AmeriCorps, and editorial changes produce
    explicit diffs/invalidation and never silent history rewrite.
12. **AC-012 (REQ-012):** Rights/cultural block and withdrawal isolate affected
    content; interrupted purge resumes and removes prohibited raw/derived/
    rendered/search/export bytes while retaining only permitted lineage.
13. **AC-013 (REQ-013):** The state matrix proves structural/source/rights/
    cultural/freshness/risk/editorial/coverage/eligibility independence.
14. **AC-014 (REQ-014):** Every named hard failure quarantines the candidate;
    duplicate/interrupted lifecycle commands replay to the same receipt and LKG
    remains consistent.
15. **AC-015 (REQ-015):** Offline, never-fetched, clear/reset, correction,
    supersession, invalidation, and purge fixtures preserve exact public state
    and do not mutate private data.
16. **AC-016 (REQ-016):** Inspection exposes every named fact/limit with
    VoiceOver, largest Dynamic Type, non-color status, stable focus, Reduced
    Motion, and accessible external-link labeling.
17. **AC-017 (REQ-017):** Coverage reconciles exact denominators/exclusions and
    the cultural/safety/dignity portfolio passes every hard gate without
    claiming recommendation usefulness.
18. **AC-018 (REQ-018):** Static/runtime tests prove no private-input,
    recommendation/profile/popularity/mutation/external-action path; real-device
    measurements cover every named resource/performance operation and hold
    release until thresholds are approved.

## Canon impact

Implementation would add a bounded Source Atlas possibility-corpus contract:
source/editorial identity, non-exclusive facets, purpose/risk eligibility,
starter-material rights/cultural state, independent overlays, public-only
collection, inspection/offline/reset/purge, and downstream claim ceilings. The
existing hobby destination specification would consume the eligible projection
without duplicating corpus authority. Life Branch canon is unaffected.

No constitution change is anticipated. This documentation does not edit canon;
implementation grooming will name exact existing owners and require the canon
compiler/check during authorized implementation.

## Risks and open decisions

### Decisions resolved by this Scope

- A reviewed finite allowlist replaces arbitrary live hobby queries.
- Wikidata supplies structured discovery identity only.
- Non-exclusive facets replace a universal taxonomy.
- Low-risk creative/making and knowledge/collecting are the only first-release
  recommendation-eligible families.
- Service/community and physical/recreation remain inspection-only.
- Starter material rights are exact record/media decisions.
- NPS/AmeriCorps overlays cannot complete safety/current opportunities.
- The corpus is public-only, read-only, unranked, non-personal, and not a Life
  Branch owner.
- Device thresholds await measured evidence, with an explicit release hold.

### Residual risks carried into Design and implementation

- The initial allowlist can encode cultural/geographic/ability bias despite
  review; coverage evidence and correction are required.
- Entity merges/vandalism and editorial changes can invalidate downstream
  proposals.
- “Low risk” cannot mean zero risk; the claim ceiling and missing practical
  facts must remain visible.
- Legal reuse and ethical/cultural appropriateness can diverge.
- Multilingual labels and source materials may exceed device/storage and
  translation-review budgets.
- Rich inspection can overwhelm users; accessible summaries must not erase
  material uncertainty.

Review verdict: **PASS** after one reconciliation round. Review rejected a
minimum record-count target as a false proxy for useful cultural coverage and
replaced it with a complete fixed-policy allowlist plus hard evaluation gates.
Every requirement has an observable acceptance criterion; state, failure,
recovery, correction, clear/purge, accessibility, privacy, dignity, authority,
dependencies, and downstream handoffs are explicit without selecting an
implementation architecture.

Devan delegated approval authority for this documentation program. This Scope
was approved under that authority on 2026-08-04. Approval authorizes Design; it
does not authorize or claim source/canon changes, ingestion, runtime behavior,
recommendation use, merge, deployment, or release readiness.
