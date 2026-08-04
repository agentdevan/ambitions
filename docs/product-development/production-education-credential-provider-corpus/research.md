+++
initiative = "production-education-credential-provider-corpus"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

The approved v1 portfolio can explain three structurally different learning
routes and can inspect a tiny public `education_credentialing` Source Atlas
pack. The eventual intelligence platform needs a maintained reference corpus
broad enough to discover real institutions, fields of study, credentials,
providers, and public learning opportunities without inventing program
identity, recognition, cost, outcomes, or what a credential means.

The user problem is not a shortage of school names. A person choosing how to
learn or qualify encounters several public facts that are routinely collapsed
into one misleading “program” record:

- a classification system names a field of study but does not prove an
  offering exists;
- an institution registry identifies an organization but does not prove the
  status of every branch or program;
- an accreditor reports recognition within an exact scope and period but does
  not decide admission, transfer, licensure, or user fit;
- a provider or publisher describes a credential, curriculum, course, or
  competency framework but does not establish universal equivalence;
- a government dataset reports cohort statistics, price components, aid, or
  outcomes but does not predict a person's result; and
- only the receiving institution, regulator, employer, or other deciding body
  can own the acceptance decision within its authority.

Without a production corpus, Ambitions would either remain limited to
hand-authored examples or ask a model/live search to fabricate education facts.
Without source-native boundaries, it could also imply that a CIP code is a
curriculum, accreditation is transferability, a CTDL relationship is an
independent endorsement, a suppressed outcome is zero, or an observed cohort
is a personal forecast.

The product value is an offline-capable public knowledge foundation from which
local Planning can discover and explain education destinations while retaining
exact publisher, record identity, release, coverage population, geography,
reference period, suppression, freshness, rights, and claim limitations. This
initiative owns slow-changing education, credential, and provider reference
truth. It does not own current term availability, admissions, applications,
transfer or licensure decisions, user-held credentials, personal ranking,
financing advice, or Goal/path mutation.

## Current truth

Research was performed against `main` at
`8154e17e004e15cfff9a388092dea3d1a12d5d35` on 2026-08-04. Current canon, live
Source Atlas and Life Context source, tests, the approved v1 portfolio, and
official external sources were inspected. Approved v1 documents are plans, not
evidence that their runtime behavior or production coverage has shipped. Tests
were inspected, not executed, for this Research.

### Governing canon

- Source Atlas may carry only approved public/reference artifacts, provenance,
  rights, freshness, conflicts, and non-sensitive access state. Private Goals,
  education history, finances, location, schedule, disability information,
  immigration status, selections, or corrections cannot shape a remote
  request, object key, cache key, log, diagnostic, or feedback record.
- Private comparison belongs to local Planning against immutable verified
  public projections. Corpus collection cannot accept private queries or learn
  from the user's education exploration.
- Public-source failure must degrade honestly and must not block the local
  core. Bundled or last-verified records can remain available offline with
  their actual age. Missing, suppressed, stale, conflicting, withdrawn,
  rights-blocked, and unsupported remain explicit states.
- Public data or a model may propose. Existing typed owners validate and own
  accepted Goal, Goal Path, Step, schedule, Capability, Proof, and Life Context
  mutations. A public credential description is never Proof that the user
  holds it.

### Approved v1 boundary

`public-reference-knowledge-foundation` approves the source-preserving claim
envelope, independent authority/rights/freshness/conflict axes, inspection,
offline behavior, and a narrow O*NET validation corpus. It does not approve a
production education catalog.

`education-destination-recommendations` establishes the essential semantic
split among classification, learning meaning, offering, recognition, transfer,
and descriptive outcomes. It exercises one degree, one provider-issued
certificate, and one open course, but explicitly does not establish current
provider coverage, acceptance, admissions, transfer, or recommendation
usefulness at production scale.

Other v1 initiatives retain independent authority:

- Capability continuity may provide user-approved local evidence, but the
  corpus cannot infer mastery or credit.
- Verifiable credential import may verify an issuer's assertion about a
  user-held credential, but it neither creates the public catalog nor proves
  another authority will accept the credential.
- Goal Path generation may consume exact source-bound prerequisites, but it
  cannot invent provider requirements.
- Destination adoption/pivot may preserve progress but cannot decide corpus
  truth.
- Intelligence evaluation can measure grounding, privacy, dignity, failure,
  accessibility, and regression, but cannot manufacture source rights.

### Live architecture and test seams

The repository already contains reusable public delivery infrastructure:

- `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/` contains pack, manifest,
  signature, hash, schema, quarantine, cache journal, last-known-good,
  revocation, public-only transport, background refresh, inspection, and local
  composition components.
- `tools/source-atlas/foundry/registry.py`, `terms_registry.py`, and
  `adapters.py` register and retrieve the official College Scorecard API. The
  live adapter fetches a few named schools and a small field set. That is a
  source adapter proof, not a full release ingest.
- `coverage-frontiers.json` defines three education gold claims: two candidate
  College Scorecard references and one West Point curriculum reference. Its
  non-claims reject admissions advice, personalized degree planning,
  credentialing authority, universal coverage, and release readiness.
- `source-atlas-public-refresh-targets.json` configures an active stable
  `education_credentialing` public pack, while its own non-claims reject native
  readiness, universal Goal coverage, recommendation proof, and final path
  generation.
- Native Source Atlas tests cover verified public packs, refresh, rollback,
  offline/no-account behavior, public-only queries, and private-egress canaries.
  They do not prove complete CIP, IPEDS, College Scorecard, DAPIP, or public
  credential coverage, semantic joins, change handling, or user comprehension.

No live source or test proves an institution identity graph across UNITID,
OPEID, branch, DAPIP, and CTID; full release ingestion; program/completion
coverage; provisional/final statistical semantics; accreditation-action
history; publisher currency; production storage/query budgets; or a production
eligibility bar for downstream recommendation.

## Evidence

All external sources below were accessed on 2026-08-04.

### United States field classification

- The NCES [CIP 2020 browser](https://nces.ed.gov/ipeds/CipCode/default.aspx?y=56)
  defines the current hierarchical Classification of Instructional Programs
  used to classify fields of study, with revision materials and a 2010–2020
  crosswalk. CIP codes support classification and reporting. They do not prove
  that a provider offers a program, define its curriculum, or establish
  admissions, recognition, transfer, cost, availability, or quality.
- Crosswalks between CIP editions are published relationships, not identity.
  Split, combined, added, and deleted codes require edition-aware mapping and
  cannot silently rewrite historical program records.

The production role for CIP is therefore a complete versioned taxonomy and
source-published crosswalk. It is not a program catalog or competency system.

### Postsecondary institution and survey data

- The NCES [About IPEDS](https://nces.ed.gov/ipeds/about-ipeds) page describes
  annual surveys from postsecondary institutions participating in federal
  student-aid programs. IPEDS covers institutional characteristics,
  enrollment, completions, graduation, finances, prices, student aid, staff,
  libraries, and other collections and assigns an institutional `UNITID`.
- The [IPEDS survey methodology](https://nces.ed.gov/ipeds/survey-components/ipeds-survey-methodology)
  documents collection, editing, imputation, nonresponse, and release
  practices. Published values may be reported, imputed, derived, suppressed,
  or not applicable. Those states cannot collapse into a numeric value.
- The [IPEDS data-release timing](https://nces.ed.gov/ipeds/use-the-data/timing-of-ipeds-data-collection)
  distinguishes provisional and final files and notes that provisional data
  generally appear months after collection. A provisional release and a final
  release can represent different reporting years; “latest” is not one
  coherent snapshot across every survey component.

IPEDS is strong authority for its own submitted and processed survey records,
but its institutional universe is bounded by the collection. It does not cover
every non-Title-IV training provider, does not prove a current course seat, and
does not convert a CIP completion record into the provider's current catalog.

### College Scorecard outcomes and comparison data

- The official College Scorecard data documentation publishes institution- and
  field-of-study files and technical documentation. The April 2025
  [field-of-study documentation](https://collegescorecard.ed.gov/files/FieldOfStudyDataDocumentation.pdf)
  defines credential counts, debt, and post-completion earnings with cohort,
  time, credential-level, CIP, and privacy/suppression rules.
- Institution-level documentation likewise combines sources and cohorts with
  measure-specific definitions. A single school can have different reference
  years across cost, completion, debt, and earnings fields.
- The official API uses `api.data.gov`; the live repository already treats an
  API key as an optional higher-budget collection credential and records
  retrieval/terms metadata. User-time private queries are unnecessary because
  fixed public releases and bounded public collection can be staged ahead of
  use.

Scorecard measures are descriptive observations for defined cohorts. They are
not admissions probabilities, program availability, personal return on
investment, quality rankings, or guarantees. Suppression protects people and
must remain suppression, not zero or missing-at-random.

### Accreditation and recognition reports

- The Department of Education's [DAPIP](https://ope.ed.gov/dapip/) contains
  accreditation data reported by recognized accrediting and state approval
  agencies. The Department says it does not itself accredit institutions or
  programs, the reported data is not audited, and it cannot guarantee accuracy,
  currency, or completeness; the appropriate agency is the source for the most
  current fact.
- DAPIP provides downloadable files and distinguishes institution/program,
  agency, scope, location, action, and status. Recognition is exact to the
  agency's recognized scope and the accredited entity; it cannot be inherited
  from an institution to every program or from one branch to another.
- A March 2026 Department [information-collection notice](https://fsapartners.ed.gov/knowledge-center/library/federal-registers/2026-03-02/comment-request-accrediting-agencies-reporting-activities-institutions-and-programs-database-accredited-postsecondary-institution-and-programs-dapip)
  confirms ongoing required agency reporting and the role of the collection in
  making DAPIP accurate and comprehensive. Reporting duty does not erase the
  database's own currency and completeness disclaimer.

DAPIP can support “reported accreditation/approval state as of this dataset and
scope.” A material current decision must direct the user to the named agency
and expose unresolved or conflicting evidence.

### Public credentials, providers, and learning metadata

- Credential Engine describes the
  [Credential Registry](https://credentialengine.org/credential-transparency/credential-registry/)
  as a public linked-data store using CTDL JSON-LD for credentials,
  organizations, programs, courses, assessments, competencies, pathways,
  transfer-value profiles, outcomes, and quality assurance.
- The current [Minimum Data Policy](https://www.credreg.net/registry/policy),
  last updated 2025-02-03, distinguishes required, recommended-benchmark, and
  optional properties and states that CTDL is a living language. Publisher
  authentication and required-field review improve provenance; they do not
  independently verify every optional claim or guarantee that a record remains
  current.
- Credential Engine's
  [consuming guidance](https://guidance.credentialengine.org/consuming-registry-data/)
  distinguishes unauthenticated individual-record/limited export access from
  search API and full bulk/offline access that require an account, approval,
  and in some cases a research agreement. Therefore “linked open data” is not
  enough to assume Ambitions may mirror the full registry in an app pack.
- CTDL identifiers and relationships are source-native public metadata. An
  `accreditedBy`, `requires`, `advancedStandingFrom`, or transfer profile is a
  publisher-supplied claim with its own source and currency; it is not an
  Ambitions-created equivalence or receiving-authority decision.

The Registry is the best investigated route to broader alternative-provider
and credential coverage, but a production bulk pack must wait for explicit
consumer access, redistribution, attribution, and update terms. A first launch
can reserve the adapter contract and admit only individually retrievable or
approved records whose exact rights posture passes review.

### Competency-framework interoperability

- 1EdTech [CASE 1.1](https://standards.1edtech.org/case/) defines data models and
  REST/JSON exchange for competency frameworks, documents, items,
  associations, rubrics, and criteria. Frameworks and items retain identifiers
  and their authorizing source.
- The 1EdTech
  [specification license](https://www.1edtech.org/standards/specification-license)
  governs use of the CASE specification for implementations. It does not grant
  Ambitions redistribution rights to every framework a CASE service exposes.

CASE is an interoperability format, not a global curriculum authority.
Framework content can enter a production corpus only when its publisher,
version, jurisdiction, access, and content rights are separately approved.
Unreviewed alignments cannot turn a competency into an equivalent Capability,
course, credit, or credential.

### Source-family authority matrix

| Source family | May support | Must not support by itself | Required binding |
|---|---|---|---|
| CIP 2020 | field classification and published edition crosswalk | offering, curriculum, competency, recognition, quality, transfer | edition, code level, title/description, crosswalk relation and target edition |
| IPEDS | source-reported/processed institution and survey measures within its universe | every provider, current catalog, seat availability, personal outcome | release, collection year/component, UNITID, reported/imputed/derived/suppressed state, methodology |
| College Scorecard | institution/field descriptive cost, completion, debt, earnings, aid, and other documented measures | admissions chance, ROI, ranking, current offering, personal prediction | data release, cohort/reference years, UNITID/OPEID/CIP/credential level, unit, suppression, definition |
| DAPIP | accreditation/approval records as reported for exact agency, entity, scope, location, action, and dates | Department endorsement, universal currency/completeness, transfer, licensure, every program | dataset retrieval/release, agency, recognition scope, entity/branch/program IDs, status/action/effective dates, disclaimer |
| CTDL Registry | publisher-authored identity and metadata for credentials, providers, learning opportunities, competencies, pathways, and QA | independent validation, universal coverage, current availability, receiving-authority acceptance | CTID, publisher/envelope, CTDL release, record lifecycle/update, source URL, access/rights decision |
| CASE source | publisher-authored competency framework and associations in CASE format | content rights, skill equivalence, mastery, credit, credential | framework/item GUID, publisher, CASE version, framework version/date, association type, rights |
| Provider/receiver/regulator | its own current offering, acceptance, transfer, admissions, or gate | broad neutral comparison outside its authority | separate future current-authority record and effective/cycle state |

### Completed production-shape pilot

Research completed a no-redistribution record-shape pilot over five materially
different public records:

1. **CIP identity:** a six-digit CIP 2020 code can retain its hierarchy,
   description, edition, and published crosswalks without becoming an offering.
2. **IPEDS institution/completion:** a UNITID and CIP completion count can
   retain survey component/year and reported/imputed/suppressed state without
   becoming a current curriculum or quality judgment.
3. **Scorecard field outcome:** a program-level earnings/debt metric can retain
   credential level, CIP, cohort, measurement horizon, coverage and suppression
   without becoming a personal forecast.
4. **DAPIP recognition:** a reported institutional or program accreditation can
   retain agency, branch/program scope, action, dates and disclaimer without
   being inherited by sibling records or treated as transfer/licensure.
5. **CTDL credential:** a CTID can retain publisher, type, status, subject page,
   offered-by relations, update metadata and approved access/rights without
   turning `requires` or `accreditedBy` into an independently verified fact.

The pilot passes only with source-native records joined through explicit,
versioned identity assertions. A universal `EducationProgram` row containing
`school`, `degree`, `skills`, `cost`, `earnings`, `accredited`, and `online`
loses source ownership, cohort, scope, currency, suppression, rights, and
conflicts. That model is rejected.

### Coverage and product-quality implications

Production coverage must report at least:

- CIP hierarchy and crosswalk coverage by edition;
- IPEDS institution universe, active/closed/merged status, component/year,
  program/completion coverage, and reported/imputed/suppressed states;
- Scorecard institution and field-of-study measure coverage by cohort,
  credential level, source year, and suppression;
- DAPIP institution/program/branch and recognized-agency coverage, with
  unresolved identity and current-agency verification requirements;
- CTDL/CASE eligible-record coverage separately from the apparent source
  universe, including access/rights/currency failures;
- identity links by their exact evidence and confidence, never silent merges;
- unavailable, stale, conflicted, withdrawn, rights-blocked, unsupported, and
  unmapped records;
- per-claim downstream eligibility rather than pack-wide “ready”; and
- factual grounding, privacy, dignity, accessibility, comprehension, offline,
  performance, and regression results through the evaluation initiative.

A structurally installed corpus may still be ineligible for a user's question.
Current offering facts, admissions dates, price, capacity, delivery, and
provider availability belong to a separate faster-clock owner.

### Privacy, bias, and sensitive-inference evidence

- Public collection is driven by a finite source/release registry, never the
  user's ambition or private constraints.
- Institution outcomes reflect selection, cohort, geography, program mix,
  access, and historic inequities. They must not be interpreted as causal
  quality or a prediction of an individual's completion or earnings.
- Rankings based on prestige, earnings, completion, cost, selectivity, or
  accreditation would collapse different values and could reproduce economic,
  racial, disability, geographic, and institutional bias. This corpus exposes
  dimensions and limits; it never ranks.
- Suppression, small cohorts, imputation, missing providers, and uneven CTDL
  participation must remain visible. Absence cannot become poor quality.
- Education history, debt, finances, immigration, age, disability,
  accommodation, location, and family obligations remain private typed data.
  They cannot be inferred from browsing or emitted into Source Atlas.
- Institution/provider descriptions and historical classifications can use
  outdated or marketing language. Source wording must remain attributable and
  accessible; Ambitions summaries must not silently strengthen it.

## Alternatives

### 1. Expand the current College Scorecard adapter and call it the catalog

This reuses working infrastructure and gives broad federal institution/outcome
data. It fails because Scorecard does not own current curricula, all alternative
providers, accreditation, transfer, or current offerings, and its measures use
different cohorts and suppression rules.

### 2. Normalize every source into one provider/program marketplace

This is easy to search and rank. It destroys authority boundaries, turns joins
into facts, hides missing/suppressed data, and invites a universal quality/ROI
score. Rejected.

### 3. Mirror the entire Credential Registry immediately

CTDL offers the richest common model and alternative-credential coverage.
However, full offline/bulk access requires approval and possibly an agreement;
publisher currency and verification vary; CTDL evolves; and linked metadata
does not supersede government, accreditor, provider, receiver, or regulator
authority. Reserve the adapter, but do not premise launch on unresolved rights.

### 4. Scrape provider catalogs at recommendation time

This might improve current breadth but leaks private intent into network
traffic, breaks deterministic replay and offline use, creates brittle rights
and parsing obligations, and mixes fast-changing offering truth into the slow
corpus. Rejected. Fixed approved source collection belongs to the future
current-opportunity owner.

### 5. Let a hosted model/search product answer education questions

Coverage appears immediate, but source version, rights, correction, conflicts,
suppression, reproducibility, and private-context boundaries weaken. A model
may later summarize eligible local records; it cannot own or retrieve the
underlying truth through private prompts.

### 6. Launch a source-native U.S. public corpus in layers

Use CIP 2020 as classification; independently version IPEDS, College Scorecard,
and DAPIP; admit CTDL and CASE records only after record/source access and rights
pass; expose explicit identity assertions; and leave current offerings and
acceptance to their owners. This is the recommended bounded direction.

## Unknowns and risks

### Resolved product decisions

- The first production geography is the United States. Global taxonomies and
  provider sources require their own release, language, rights, and authority
  research rather than being implied by a global label.
- CIP 2020, IPEDS, College Scorecard, and DAPIP are independent source-native
  layers. No source is the master universal program record.
- A provider record, learning opportunity, credential, competency framework,
  accreditation, transfer profile, and user-held credential remain different
  entities.
- CTDL/CASE content is conditional on exact source access and rights even when
  the schema or specification is open.
- Current term dates, price, admissions, seat/capacity, delivery, application,
  live provider status, current regulator gate, and current transfer decision
  hand off to `current-opportunity-availability-intelligence`.
- The corpus exposes measures and limitations; it does not rank providers,
  credentials, programs, fields, or people.
- User-held credentials stay in `verifiable-credential-import`; public records
  never become private Proof.

### Material risks

- **Identity ambiguity:** UNITID, OPEID, branch identifiers, DAPIP identifiers,
  CTIDs, provider URLs, and names have different scopes and change through
  mergers/closures. False merges can attach outcomes or recognition to the
  wrong entity.
- **Mixed clocks:** CIP editions, annual IPEDS components, Scorecard cohorts,
  DAPIP updates, provider records, and CTDL releases do not share one “updated”
  timestamp.
- **Statistical misuse:** imputed, suppressed, small-cohort, program-aggregate,
  and historical measures can be stripped of definitions and shown as personal
  return.
- **Accreditation overclaim:** DAPIP is reported and not guaranteed complete or
  current; institution-level recognition may not cover a program or distance
  mode, and recognition does not equal transfer or licensure.
- **Rights/access drift:** government dataset endpoints, CTDL access approval,
  publisher licenses, and CASE content rights can change. A source-wide open
  label is not enough.
- **Coverage bias:** IPEDS and Scorecard emphasize Title-IV institutions;
  voluntary public credential publishing is uneven. Missing alternative,
  community, apprenticeship, employer, or nontraditional routes cannot be
  treated as inferiority.
- **Storage and device cost:** full multi-release public datasets are large.
  Partitioning and a bounded bootstrap need measured device budgets without
  destroying honest coverage.
- **Change shock:** closure, merger, accreditation action, revised outcome,
  rights withdrawal, or identifier change can invalidate downstream proposals.
- **Inspection overload:** precise source semantics can be hard to understand.
  Plain-language views must retain an exact technical inspection path.

### Dependencies

- `public-reference-knowledge-foundation` supplies the claim envelope,
  rights/freshness/conflict axes, inspection, public-only boundary, and offline
  behavior.
- `intelligence-quality-safety-evaluation` supplies coverage, grounding,
  statistical misuse, privacy, dignity, accessibility, failure, and regression
  evaluation.
- `cross-taxonomy-relationship-authority` owns any claim joining CIP,
  competency frameworks, credentials, capabilities, occupations, or other
  taxonomies beyond source-published relations.
- `current-opportunity-availability-intelligence` owns fast-changing catalogs,
  provider terms, admissions, cost, dates, delivery, capacity, transfer,
  licensing, and other current-authority records.
- Education recommendations and future generative destinations/paths consume
  eligible immutable projections and cannot bypass claim ceilings.
- `intelligence-change-management` later owns promotion and downstream-impact
  policy across releases; this corpus still owns source-native semantic truth.

### Evidence required before Scope

Research has enough evidence to Scope a bounded U.S. public corpus if Scope
keeps these requirements explicit:

1. exact source/version allowlists for CIP 2020, selected IPEDS release
   components, College Scorecard release files/fields, and DAPIP downloads;
2. source-native records with reported/imputed/derived/suppressed, cohort,
   reference-period, geography, scope, and disclaimer semantics;
3. explicit identity-assertion records rather than automatic cross-source
   merges;
4. fixed public refresh identities with no private request shaping;
5. per-source and per-record rights, attribution, access, retention,
   redistribution, and withdrawal behavior;
6. CTDL/CASE ingestion disabled until exact access/content rights pass;
7. per-claim eligibility, missingness, invalidation, rollback, offline, and
   inspection states;
8. measured device storage/query/update budgets and a useful bootstrap floor;
9. launch evaluation over ordinary, alternative-provider, closed/merged,
   suppressed, changing-accreditation, and conflicting-identity fixtures; and
10. explicit exclusions for current offerings, acceptance, ranking,
    admissions, transfer/licensure decisions, private credentials, user fit,
    financing advice, and external action.

No v1 runtime or user evidence is required to define these public-data and
authority contracts. Direct-user evidence remains required before claiming
education recommendation usefulness.

## Recommended direction

Scope a source-native U.S. education, credential, and provider reference corpus
with four first-launch public layers:

1. full CIP 2020 classification and edition-crosswalk records;
2. an exact fixed IPEDS release manifest for institution identity and selected
   institution/program/completion/price/outcome components, preserving each
   component's year and processing state;
3. an exact fixed College Scorecard release manifest for approved institution
   and field-of-study measures, preserving cohort, definition, credential
   level, suppression, and source years; and
4. an exact fixed DAPIP download for reported agency, institution, branch,
   program, scope, action, and status records, preserving the Department's
   currency/completeness disclaimer and agency verification path.

CTDL Registry and CASE sources should use reserved source-native adapter
contracts but remain rights-gated. They may enter later corpus releases only
after access, redistribution, attribution, retention, update, publisher,
version, and content-rights review passes for the exact feed or framework.

Reuse Source Atlas delivery, verification, public cache, revocation,
last-known-good, offline, and inspection infrastructure. Add release-specific
adapters, semantic manifests, source-native indices, identity assertions,
release diffs, and per-claim eligibility. Public collection remains independent
of users. Local consumers may join an eligible public projection with an
explicitly permitted private projection, but this corpus never receives or
stores the private input.

Expose a calm education reference view that can answer:

- what this institution, field, credential, provider, or framework record is;
- which source says it and for which release, scope, population, and period;
- whether a value was reported, imputed, derived, suppressed, unavailable, or
  not applicable;
- what recognition was reported, by whom, for which exact entity/scope, and
  when it must be verified with the agency;
- which identities are explicitly linked, conflicting, ambiguous, or unmapped;
- whether the record is current, aging, stale, withdrawn, rights-blocked, or
  last-known-good; and
- what the record cannot establish about admission, acceptance, transfer,
  quality, availability, return, or the user.

This creates broad real public discovery without pretending to be a live
provider marketplace or education oracle.

### Five compounding ruthless review passes

1. **Completeness and unsupported assumptions:** added complete source-family
   research for CIP, IPEDS, Scorecard, DAPIP, CTDL Registry, and CASE; bound
   cohorts, suppression, provisional/final releases, reported accreditation,
   access approval, and content rights instead of assuming “official” or “open”
   meant a complete production catalog.
2. **Connections, duplication, and missing owners:** separated slow public
   reference, cross-taxonomy assertions, fast current offerings, public versus
   user-held credentials, recommendation, evaluation, and change management;
   rejected a universal normalized program owner.
3. **Privacy, authority, failure, deletion, and external effects:** prohibited
   private request shaping, rankings, personal predictions, and credential-to-
   Proof promotion; added suppression, rights withdrawal, record invalidation,
   offline/last-known-good, correction, deletion/reset handoffs, and no external
   action path.
4. **Feasibility against live architecture:** grounded the direction in the
   existing Scorecard adapter, terms registry, frontier, refresh target,
   verified-pack/cache/rollback components, and tests; identified the missing
   full-release, identity, statistical, rights, and device-budget proof.
5. **Product coherence and long-term fidelity:** selected a bounded U.S. launch
   that improves real destination breadth while keeping current availability,
   acceptance, global sources, personalization, and generation with their
   correct owners; preserved local-first, private, inspectable, correctable,
   non-shaming behavior.

Review verdict: **PASS**. The Research completes the source, access, rights,
freshness, statistics, authority, architecture, privacy, bias, failure,
dependency, and launch-shape investigation needed for Scope. It does not claim
corpus ingestion, runtime coverage, recommendation usefulness, or release
readiness.

Devan delegated approval authority for this documentation program. This
Research was approved under that authority on 2026-08-04. Approval authorizes a
bounded Scope; it does not authorize or claim source/canon changes, ingestion,
runtime behavior, recommendation use, merge, deployment, or release readiness.
