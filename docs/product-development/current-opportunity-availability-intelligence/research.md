+++
initiative = "current-opportunity-availability-intelligence"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Reference knowledge can explain an occupation, program, activity, requirement,
or typical route without proving that a specific opening, cohort, appointment,
permit, class, or application window exists now. Ambitions needs a separate
current-authority layer so a user can distinguish a credible destination from a
real opportunity they may act on.

The outcome is not a universal marketplace. It is an inspectable, local-first
set of source-owned current facts: what is offered, by whom, where, during which
effective window, with which price/capacity/eligibility claims, when it was
checked, and whether it is still safe to present. A destination or path may
remain useful while current availability is unknown.

## Current truth

### Approved product baseline

- Public Reference Knowledge Foundation owns public source identity,
  authority-for-purpose, rights, freshness, conflicts, offline/LKG, and the
  public/private firewall.
- The three production corpora own durable career, education, and hobby/life
  identities. They intentionally do not claim current openings or capacity.
- Relationship Registry owns exact public cross-taxonomy edges and expressly
  cannot establish qualification, admission, licensure, transfer, or current
  acceptance.
- The v1 recommendation and Goal Path documents can use sourced type-level
  knowledge but degrade when a named current provider or opportunity is not
  established.
- Context-quality scheduling owns private fit after a user adopts work. It does
  not make public availability true.

These are approved plans, not shipped-runtime evidence.

### Live repository seams

The live tree already contains Source Atlas public-pack transport, signature,
manifest, freshness, last-known-good, cache, public-only firewall, query, and
refresh-target seams under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/`. Foundry source governance,
adapter, certification, legal-readiness, transport, pack production, release,
freshness, and coverage seams exist under `tools/source-atlas/foundry/`.
`SourceAtlasBoundary.swift`, `SourceAtlasPublicArtifactBoundary.swift`, and the
no-private-graph-egress audit are the relevant firewalls. These seams demonstrate
shape, not production-source completeness or current-opportunity correctness.

### Product distinction

The layer must keep four things separate:

1. **Reference identity:** a destination/program/activity exists in a maintained
   corpus.
2. **Current authority claim:** a source says a named offering has a current
   date, place, price, capacity, status, or requirement.
3. **Personal applicability:** local private logic determines whether known
   constraints appear compatible, without declaring eligibility.
4. **External transaction:** application, reservation, enrollment, payment, or
   contact happens only under the later external-action owner.

### External evidence and source-family findings

Research used source pages retrieved 2026-08-04. Each source remains governed by
its current terms and exact claim authority.

#### Federal jobs

The official [USAJOBS Search API](https://developer.usajobs.gov/api-reference/get-api-search)
exposes public job announcements and search parameters. Its
[terms](https://developer.usajobs.gov/guides/terms-of-use) require registered
API use, restrict data to the registered consumer and prohibit unapproved
derivative uses; service and terms may change. The announcement owns its open/
close dates, locations, agency, duties, pay range, eligibility categories, and
application link. It does not prove a user is eligible, will be referred, or
will be selected. USAJOBS is viable only after written product-use/retention/
redistribution resolution and a source-specific ingestion contract.

#### Registered apprenticeships

The Department of Labor's official
[Apprenticeship Job Finder](https://www.apprenticeship.gov/apprenticeship-job-finder)
combines multiple sources and labels a posting by registered occupation or
registered partner. DOL explains that active listings come through the National
Labor Exchange and that the Finder sends users to employers to apply. The label
therefore describes a registration relationship, not the quality, availability,
eligibility, or outcome of every listing. No durable public bulk/API and rights
contract was established in this research, so Ambitions may deep-link to the
official finder but must not ingest listings until that contract is resolved.

#### Federal recreation

The official [RIDB API](https://ridb.recreation.gov/docs) publishes federal
recreation areas, facilities, activities, campsites, tours, and permits; source
agencies own data quality and the site warns that fields may be missing. Its
[access agreement](https://ridb.recreation.gov/access-agreement-ridb) makes the
service revocable, rate-limited, as-is, subject to registration and use
restrictions, and does not warrant accuracy or currency. RIDB can support
facility/activity identity and attributed current notices, but a live booking
inventory, site condition, safety fact, fee, or permit availability requires
the exact owning endpoint and a short freshness clock. It cannot support a
reservation promise.

#### Education, credentials, licensure, and local programs

IPEDS, College Scorecard, DAPIP, accreditation notices, CTDL, and CASE are
reference/provider/authority sources, not a universal current seat inventory.
Program catalogs, admissions windows, prices, modality, capacity, and
accessibility are provider-owned and fragmented. Licensure eligibility and
application state are jurisdiction/authority-owned. A provider adapter may be
admitted only when stable identity, terms, effective dates, historical replay,
and field-level authority are established. A public web page merely being
visible is not ingestion permission.

#### General market lesson

Aggregator breadth trades away provenance, terms clarity, deletion, and
source-specific semantics. Search results and model-generated summaries are
discovery candidates, never current authority. Availability is a predicate-level
claim with an expiration rule, not a property copied onto a destination.

### Required record semantics

A current claim needs: stable source and subject IDs; offering ID; claim type;
source-native value and unit; jurisdiction/location precision; effective start
and end when supplied; first seen, retrieved, last verified, expiry and source
publication timestamps; source locator; authority-for-purpose; rights and
retention policy; conflict state; uncertainty/missing state; supersession or
withdrawal; release hash; and a narrowly defined consumer-use policy.

Claims include `open_window`, `offering_status`, `place`, `delivery_mode`,
`price`, `capacity_signal`, `schedule`, `prerequisite_statement`,
`application_route`, and `accessibility_statement`. “Unknown” differs from zero,
closed, free, remote, unrestricted, or unavailable. A closed date is not a
permanent closed state. Capacity shown at retrieval is not a reservation.

Freshness policy is claim/source specific. A catalog identity may age slowly;
an application deadline or capacity signal may expire quickly. Last-known-good
can remain inspectable but cannot be called current after its policy expires.
Conflicting sources remain side by side with authority and timestamp; Ambitions
does not silently choose the user-favorable claim.

### Privacy, authority, and safety

- Acquisition may request only finite public source IDs, regions, releases, or
  predefined shards. It must not send Goal text, private profile attributes,
  location history, schedule, identity, corrections, selections, or rejection
  behavior to a source or hosted service.
- Exact location is private. Coarse regions may be user-approved local filters;
  remote query-shaped search still requires a separately reviewed privacy mode.
- Public announcements can contain public contact information. Ambitions should
  retain only the fields required for the user outcome and must not turn public
  contacts into a person graph.
- “Eligible,” “qualified,” “available to you,” “affordable,” and “safe” are
  material conclusions. This layer reports source claims and local compatibility
  unknowns; the relevant authority and user decide.
- No automatic application, booking, enrollment, payment, outreach, calendar
  mutation, or Goal creation.

### Direct-user evidence needed

Testing must establish whether users understand:

- the difference between a destination and a current opportunity;
- checked-at versus guaranteed-current information;
- source-reported prerequisite versus personal eligibility;
- capacity signal versus reservation;
- unavailable data versus no opportunities; and
- why an expired claim may remain inspectable but cannot drive a current action.

## Evidence

The evidence supports a source-specific current-authority registry built atop
Source Atlas, not a monolithic opportunity index. The registry must be valuable
even with one admitted family and must degrade per claim. USAJOBS and RIDB show
that authoritative APIs still have changing terms, keys, rate limits, incomplete
fields, and no guarantee. Apprenticeship and education sources show that a
public finder is not automatically a redistributable feed.

The smallest credible first release is an architecture and evaluation slice:
one rights-cleared source family, exact time semantics, offline inspection,
source-owned links, and no transactions. Source admission is independent, so a
blocked family does not block the registry.

## Alternatives

1. **Universal opportunity aggregator.** Broad and immediately attractive, but
   conflates sources, creates rights/deletion burden, leaks query intent, and
   becomes stale in ways hidden from users. Reject.
2. **Live remote search per user request.** Fresher and lower storage, but sends
   sensitive intent/location, yields non-replayable results, and makes offline
   behavior weak. Reject as the default; a future explicit privacy mode may be
   researched separately.
3. **Deep links only.** Safe and current at click time, but cannot ground local
   comparison, scheduling, or expiry. Retain as fallback, not the entire layer.
4. **Source-specific public packs plus local matching.** Narrower coverage but
   preserves terms, provenance, deterministic replay, private filtering, and
   honest gaps. Recommend.
5. **Model/browser summaries.** Useful for candidate discovery only. Reject as
   authority because citations, bytes, time, and deletion cannot be guaranteed.

## Unknowns and risks

- USAJOBS retention/derivative-use permission needs written resolution before
  source admission.
- RIDB content and API terms must be resolved field by field; availability and
  booking endpoints may have different authority.
- No production education seat/catalog or apprenticeship feed is admitted yet.
- Source volatility can create high update cost and app-resource growth.
- Location, income, disability, citizenship, age, family status, and criminal
  history can be sensitive. This layer must not infer them or encode hidden
  exclusion.
- Sparse coverage can bias suggestions toward institutional sources that are
  easiest to ingest. Evaluation must measure source-family and geography gaps.
- Current-opportunity usefulness requires user evidence before a broad Scope
  expansion or any query-shaped network mode.

No hard product fork remains for a bounded registry. Each source family can be
admitted or withheld independently behind explicit rights and quality gates.

## Recommended direction

Create a **Current Authority Registry** over Source Atlas with source-specific
adapters, typed time/freshness semantics, claim-level rights and authority,
immutable signed public releases, local-only filtering, exact dependency
invalidation, LKG inspection, and quiet unavailability.

Scope the first implementation to the registry, contracts, one synthetic
conformance source, and at most one real source whose terms are affirmatively
cleared before implementation. USAJOBS, apprenticeship listings, RIDB live
availability, provider catalogs, and licensure/application feeds remain
source-admission work items, not assumed content.

The layer returns evidence, not decisions. It never declares personal
eligibility, guarantees availability, or performs an external action. Current
facts can ground later destination/path proposals and simulations through typed
read-only bindings; accepted mutations remain with their existing owners.

### Five compounding ruthless review passes

1. **Completeness:** split reference identity, current claim, personal fit, and
   transaction; added exact temporal and unknown semantics.
2. **Connections/ownership:** made Source Atlas, corpora, relationship registry,
   personalization, evaluation, and external actions distinct owners.
3. **Privacy/authority/failure:** prohibited private query egress, eligibility
   claims, implicit contact graphs, and stale-as-current fallback.
4. **Feasibility:** grounded the direction in live public-pack/firewall/freshness
   seams and bounded initial sources to rights-cleared adapters.
5. **Coherence/value:** retained deep-link fallback and usable destination
   knowledge when current availability is absent, preventing sparse coverage
   from erasing user options.

Review verdict: **PASS** after reconciliation. Devan delegated phase approval;
Research was approved on 2026-08-04.
