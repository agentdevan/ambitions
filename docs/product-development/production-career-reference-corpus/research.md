+++
initiative = "production-career-reference-corpus"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

The approved v1 portfolio can represent and inspect one narrow O*NET software-
developer slice, and it can use synthetic career fixtures to prove bounded
recommendation behavior. The eventual intelligence platform needs a maintained
career reference corpus broad enough to discover ordinary, adjacent, and
aspirational occupations without fabricating what work is, what preparation is
typical, what conditions people encounter, or what the labor market currently
measures.

The user problem is not simply a lack of job titles. A person considering a
career change needs several kinds of public truth that look similar in a search
result but have different owners and claim ceilings:

- an occupation taxonomy identifies and describes a class of work;
- a survey may estimate tasks, skills, work context, preparation, wages, or
  employment for a population;
- an employer owns the requirements of one role;
- a regulator owns licensure or practice authority in one jurisdiction;
- a selecting organization owns eligibility and availability for a competitive
  program; and
- none of those sources can decide that a particular person is qualified,
  compatible, employable, likely to succeed, or obligated to pursue the work.

Without a production career corpus, destination discovery and path generation
would either remain toy-fixture behavior or drift into live web/model invention.
Without a strict source-native corpus, Ambitions could also create false
equivalence: treating a national composite as a local requirement, a survey
relationship as a personal trait, an occupation code as a job opening, or an
O*NET/ESCO mapping as semantic identity.

The product value is a maintained offline-capable public knowledge base from
which local Planning can discover and explain career destinations while
preserving exact source, release, population, geography, freshness, uncertainty,
rights, and limitations. This initiative owns career reference facts. It does
not own personal matching, recommendations, current vacancies, licensure
decisions, education-provider facts, cross-taxonomy equivalence, or Goal/path
mutation.

## Current truth

Research was performed against `main` at
`8154e17e004e15cfff9a388092dea3d1a12d5d35` on 2026-08-04. Current canon, live
Source Atlas and Planning source, tests, the approved v1 product-development
portfolio, and official external sources were inspected. Approved v1 documents
are plans, not evidence that runtime behavior or production corpus coverage has
shipped. Tests were inspected, not executed, for this Research.

### Governing canon

- Source Atlas may carry only approved public/reference artifacts, provenance,
  freshness, rights, and non-sensitive access state. The finite public-artifact
  namespace and no-private-graph firewall prohibit Goal text, Capability/Proof,
  schedule, recommendation context, correction, or other private state from
  shaping a remote request, object key, cache key, log, diagnostic, or feedback.
- Private matching belongs to local Planning against an immutable verified
  public projection. A production corpus cannot accept private queries or learn
  from private selection behavior.
- Public-reference failure must degrade honestly and must not block the local
  core. Bundled or last-verified facts can remain available offline with their
  real age; absence stays unavailable.
- A source citation is not Proof about the user. Models and public data may
  propose; existing typed owners validate and own any accepted change.

### Approved v1 boundary

`public-reference-knowledge-foundation` approves the source-preserving claim
envelope, claim-specific authority, independent rights/freshness/conflict axes,
source inspection, offline behavior, and only one validation corpus: O*NET 30.3
Software Developers `15-1252.00`. It explicitly excludes broader production
ingestion, BLS market facts, ESCO mappings, qualification, and recommendation
readiness.

`career-destination-recommendations` proves product semantics with synthetic
ordinary, regulated, and competitive cases. It distinguishes why a destination
appeared, what a public source says, what still needs checking, and what
Ambitions does not claim. It does not establish real corpus coverage or source
refresh operations.

The remaining v1 initiatives depend on this work but do not expand its owner:

- Capability continuity can supply user-approved local evidence but cannot
  populate career facts.
- Goal Path generation can consume source-bound prerequisites and milestones
  but cannot invent occupation or market facts.
- Destination adoption/pivot can preserve progress but cannot decide corpus
  correctness.
- The new evaluation foundation can measure grounding, coverage, privacy,
  dignity, failure, and regression, but it cannot manufacture source rights or
  semantic authority.

### Live architecture and test seams

The repository already contains substantial reusable delivery infrastructure:

- `SourceAtlasPackModels.swift` and related source-truth contracts represent
  publisher, source kind, claim state, freshness, risk, review, provenance,
  conflict, and source-pack identity.
- Manifest, signature, hash, schema, decompression/size, quarantine,
  last-known-good, cache journal, refresh target registry, public-only boundary,
  background refresh, and local composition components already exist under
  `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/`.
- `source-atlas-public-refresh-targets.json` contains an active
  `occupation_foundation` target, but its own non-claims say it is not universal
  coverage, recommendation proof, native runtime readiness, or release
  authority.
- Source Atlas tests exercise public-only requests, verified packs, cache and
  rollback, offline/no-account fallback, private-egress canaries, source truth,
  local inspection, and planning bridges.
- The current frontier taxonomy contains many speculative occupation subdomains
  with `source_specific_review_required`; their presence is an inventory, not
  source approval or coverage evidence.

One existing seam remains non-authoritative: a Source Atlas composer that
accepts private Goal/Life Context inputs places the private join inside the
public owner. The approved foundation excludes that path. Production career
adapters must emit public immutable projections; local Planning performs any
private comparison.

No live source or test proves full O*NET release ingestion, source-native
release deltas, complete OOH/OEWS/ORS overlays, statistical suppression and
reliability semantics, production corpus coverage, or user comprehension at
that breadth.

## Evidence

### Official source-family evidence

All external sources below were accessed on 2026-08-04.

#### O*NET occupational content

- The [O*NET 30.3 database](https://www.onetcenter.org/database.html) is the
  current downloadable release. The official page reports 1,016 O*NET-SOC
  occupation identities, 923 data-level occupations, quarterly updates with a
  primary annual update, archived releases, field documentation, and machine-
  readable downloads. It contains source-native occupation titles and
  descriptions; essential and transferable skills; knowledge and abilities;
  education, training, and experience distributions; tasks; work activities;
  work context; related occupations; data-collection metadata; and other
  categories.
- O*NET 30.3 substantially reorganizes the Content Model into Worker, Job, and
  Market dimensions and publishes a transition crosswalk. That release change
  proves adapters cannot assume field names or category meaning are stable
  across versions.
- The [O*NET-SOC taxonomy](https://www.onetcenter.org/taxonomy.html) is based on
  the 2018 SOC but adds O*NET-specific detail. The official page distinguishes
  data-level from title-only occupations and publishes explicit crosswalks.
  Title-only identities cannot silently inherit data from a broader parent.
- The [O*NET 30.3 content license](https://www.onetcenter.org/license_db.html)
  permits copying and adaptation under CC BY 4.0 with release-specific O*NET and
  USDOL/ETA credit, a license link, change indication, and trademark rules. It
  excludes separate O*NET tools and some external-source material. A production
  adapter therefore needs a file/category allowlist and attribution builder,
  not a source-wide `licensed = true` bit.

O*NET is strong production authority for its own United States occupation
taxonomy and published survey/content-model data. It is not an employer,
licensor, regulator, or prediction of personal success. Work Styles, Abilities,
Interests, and hybrid-derived Basic Interests may describe published occupation
profiles but must not become hidden user personality or compatibility features.

#### United States classification and labor statistics

- The [2018 Standard Occupational Classification](https://www.bls.gov/soc/)
  supplies the federal occupation classification used across statistical
  programs. O*NET-SOC is related but not identical; the source-native code and
  crosswalk version must remain visible.
- The [Occupational Outlook Handbook information guide](https://www.bls.gov/ooh/About/Occupational-Information-Included-in-the-OOH.htm)
  describes occupation-level duties, work environment, typical entry education,
  related experience, training, pay, employment, outlook, and similar
  occupations. The [OOH disclaimer](https://www.bls.gov/ooh/about/disclaimer.htm)
  says it is a national composite, not a specific establishment/locality,
  licensing or practice standard, legal authority, or qualification decision.
- The current [May 2025 OEWS occupation profiles](https://www.bls.gov/oes/current/oes_stru.htm)
  provide annual national, state, metropolitan/nonmetropolitan, and industry
  employment and wage estimates classified by SOC. An estimate needs reference
  period, geography, measure, unit, population, footnotes, suppression, and
  methodology; a displayed wage is not an offer or future earnings promise.
- The [Occupational Requirements Survey](https://www.bls.gov/ors/) provides
  population estimates for physical demands, environmental conditions,
  education/training/experience, and cognitive/mental requirements. Official
  guidance states these describe job requirements, not individual worker
  capabilities; 2025 estimates are preliminary and use 2018 SOC. ORS excludes
  some sectors and publishes standard errors/ranges, which must survive
  ingestion.
- [BLS copyright guidance](https://www.bls.gov/opub/copyright-information.htm)
  places published BLS material in the public domain except identified images,
  while the [BLS API terms](https://www.bls.gov/developers/termsOfService.htm)
  require retrieval-date citation and caution that BLS cannot vouch for
  downstream analysis after retrieval. Logos are not freely reusable.

BLS source families can support carefully bounded descriptive and statistical
claims. OOH prose, OEWS estimates, ORS estimates, and employment projections
have different populations, clocks, methodologies, and limitations even when
they share an SOC code.

#### European multilingual reference

- [ESCO v1.2.1](https://esco.ec.europa.eu/en/use-esco) publishes 3,039
  occupations and 13,939 skills/competences in 28 languages as linked open data
  with URI identifiers and downloadable/API/local-API access. The official site
  reports v1.2.1 updated 2025-12-10 and emphasizes version selection and
  long-lived URIs.
- The [ESCO web-service API](https://esco.ec.europa.eu/en/use-esco/use-esco-services-api/esco-web-service-api)
  exposes versioned concepts and relationships; documentation/current-version
  labels across ESCO pages are not perfectly synchronized. Production use must
  bind actual downloaded package bytes and manifest, not trust a site-wide
  banner or API default.
- The ESCO pages clearly license API software, but the reviewed pages did not
  yield a sufficiently explicit, release-bound content/attribution contract for
  Ambitions packaging. Until a rights review resolves classification-content
  reuse separately from API-library licensing, ESCO is research-qualified but
  not approved for the first bundled production release.

ESCO is valuable for later European and multilingual coverage. It cannot be
flattened into O*NET: occupation granularity, relationship meaning,
jurisdiction, language releases, and source methodology differ.

### Source-family authority matrix

| Source family | May support | Must not support by itself | Required binding |
|---|---|---|---|
| SOC | federal statistical occupation classification | O*NET detail, job availability, user fit | SOC edition, code, level, effective/implementation metadata |
| O*NET | O*NET-SOC identity and published occupation/worker/job descriptors | employer/regulatory gate, qualification, personal trait/compatibility, job opening | database release, taxonomy, file/category, source-native IDs, category update metadata, license/attribution |
| OOH | national composite duties, typical preparation, pay/outlook narrative, similar occupations | local/employer/legal rule, qualification, guaranteed outcome | profile revision, projection period, SOC mapping, retrieval date, disclaimer |
| OEWS | employment/wage estimates for stated geography/industry/occupation/reference period | offered salary, personal earnings, future guarantee | dataset/reference period, area/industry, SOC, estimate/percentile/unit, suppression/footnotes |
| ORS | population estimates of job requirements and conditions | a person's ability, accommodation decision, every sector | wave/preliminary-final state, reference year, SOC, population, estimate/range/SE/footnotes |
| ESCO | source-native EU occupations, skills/competences, labels and published relations | identity with O*NET, national gate, user fit | release bytes/version, URI, language pack, relationship type, rights decision |
| Regulator/employer/selecting organization | its own jurisdictional gate, role, or cycle | occupation-wide truth beyond its authority | separate future current-authority record, jurisdiction, effective/cycle state |

### Completed production-shape pilot

The Research performed a record-shape and authority pilot over four materially
different records. It did not ingest or redistribute source bytes.

1. **O*NET occupation identity and task:** Software Developers `15-1252.00` can
   preserve taxonomy edition, database release, data-level status, task/source
   element identity, category update metadata, scale where applicable, and CC
   BY attribution. It cannot promote a task rating into a user capability.
2. **OOH typical preparation:** the software-developer profile can preserve its
   page revision, 2024–34 projection period, national-composite limitation, and
   typical education statement. It cannot turn “typical” into a hard degree
   requirement.
3. **OEWS wage estimate:** a May 2025 occupation/area estimate can preserve
   geography, occupation, annual/hourly measure, percentile/mean, employment
   estimate, footnotes, and suppression. It cannot become “you will earn.”
4. **ORS requirement estimate:** a 2025 preliminary estimate can preserve
   preliminary/final status, population exclusions, range/standard error,
   requirement definition, and occupation grouping. It cannot become a medical,
   disability, accommodation, or individual ability conclusion.

The pilot passes only when each record remains source-native and the shared
layer is a claim envelope, not a flattened career row. A simple occupation table
with `skills`, `salary`, `education`, and `requirements` columns loses source,
population, statistical uncertainty, edition, geography, and authority. That
model is rejected.

### Coverage and quality implications

“Full O*NET” does not mean every occupation has every data category. Production
coverage must report at least:

- taxonomy identities, data-level/title-only/aggregate status, and source
  release coverage;
- per-category occupation coverage and missingness;
- source-native update/collection metadata;
- overlay coverage by OOH profile, OEWS geography/industry/estimate, and ORS
  detailed/group occupation;
- unsupported, suppressed, low-reliability, preliminary, stale, conflicted,
  rights-blocked, and unmapped records;
- language and accessibility coverage; and
- claim families evaluated for factual accuracy, authority, attribution,
  freshness, offline use, regression, bias/dignity, and comprehension.

A corpus can be structurally complete yet unusable for a particular claim.
Recommendation and Goal Path consumers must query eligibility by exact claim
family rather than infer readiness from pack installation.

### Privacy, bias, and sensitive-inference evidence

- Source collection is independent of users. A finite release/source registry,
  not a person's ambition, determines remote fetches and cache keys.
- Occupation taxonomies and historical labor-market data encode classification,
  collection, and labor-market biases. Sparse or aggregate coverage must not
  eliminate aspirational options or be interpreted as personal incompatibility.
- O*NET Work Styles, Interests, Abilities, and occupation associations are
  especially prone to hidden personality inference. They may remain public
  descriptive records, but personal use requires a future explicit, correctable
  owner and must never happen silently in this corpus.
- Wages, employment, and outlook can pressure users or imply prestige. The
  corpus must preserve statistical context and cannot rank human worth, career
  worth, employability, or likely success.
- Occupational requirements can interact with disability and accommodation.
  Population estimates cannot be converted into individual exclusion, medical
  advice, or a statement that reasonable accommodation is unavailable.
- Demographic slice data is not required for the first corpus. If later used for
  equity evaluation, it belongs in governed evaluation artifacts, not a hidden
  user model.

## Alternatives

### 1. Expand the existing O*NET validation adapter to every row and call it done

This is the fastest path to broad occupation descriptions and has clear CC BY
rights. It fails production truth because O*NET alone does not own wage/outlook,
local variation, employer requirements, or regulation; not all identities are
data-level; and the 30.3 schema change proves adapters need release migrations.

### 2. Build one normalized `Career` record per occupation

A denormalized title/skills/education/salary row is easy for UI and models. It
erases source-native meaning, statistical populations, conflicting clocks,
suppression, and authority. It encourages “typical education = requirement” and
“estimate = outcome.” Rejected.

### 3. Use live APIs at recommendation time

This reduces bundled size and may improve currency, but makes private intent
shape network traffic, removes offline reproducibility, exposes rate/outage
behavior to the core experience, and weakens byte/version binding. It conflicts
with the finite public namespace. Fixed-source refresh may use APIs in a
separate public collection lane; user-time private queries may not.

### 4. Use a hosted model or search index as the career corpus

Breadth would be high and ingestion simpler. Source citations, versioning,
licensing, corrections, deterministic replay, offline use, and false-claim
handling would be weaker, and private context could leak into retrieval. A
model may later summarize eligible local records; it cannot own the facts.

### 5. Launch O*NET, OOH, OEWS, ORS, and ESCO simultaneously

This maximizes geographic breadth but multiplies adapter, rights, language,
crosswalk, statistical, and evaluation risk. ESCO content rights need a clearer
release-bound review, and cross-taxonomy ownership belongs to another
initiative. A simultaneous launch would entangle independent owners.

### 6. Source-native United States corpus first, overlays added by explicit claim family

Ingest the full O*NET 30.3 downloadable database through source-native adapters,
then add independently versioned SOC/OOH/OEWS/ORS overlays only for claim
families whose semantics, rights, refresh, and evaluation pass. Preserve
missingness and source boundaries. Prepare but do not ship ESCO until its rights
and cross-taxonomy work pass. This gives real breadth without pretending one
source or launch solves the career domain. Recommended.

## Unknowns and risks

### Resolved research decisions

- The production owner stores source-native career records plus claim envelopes;
  it does not create a universal career object.
- The first production geography is the United States because O*NET/BLS rights,
  source formats, and the approved v1 seam are sufficiently researched.
- Full O*NET identity coverage and eligible data categories are the base.
  SOC/OOH/OEWS/ORS are independent overlays, never fallback authorities for one
  another.
- ESCO is a later source-native corpus. Its concepts remain separate until
  content rights and `cross-taxonomy-relationship-authority` are approved.
- Regulatory/employer/selection-cycle/current-opening facts are not smuggled
  into the slow-changing career corpus; they hand off to
  `current-opportunity-availability-intelligence`.
- Personal matching, ranking, traits, and recommendations remain local consumers
  outside this owner.

### Material risks

- **Release churn:** O*NET 30.3 changed the content model. Adapters need explicit
  source-release schemas, transition reports, and last-known-good behavior.
- **Partial identity coverage:** title-only and aggregate SOC/O*NET records can
  look complete while lacking detail. Eligibility must be per record/claim.
- **Statistical misuse:** OEWS/ORS/OOH values can be stripped of population,
  geography, suppression, standard error, preliminary state, or projection
  period and misrepresented as personal facts.
- **Rights drift:** O*NET license exceptions and BLS trademark/API terms require
  release/source-specific policy. ESCO content rights remain unresolved for
  packaging.
- **Corpus size and device cost:** complete downloadable datasets, historical
  releases, indices, and overlays can consume storage/memory and slow refresh.
  Partitioning must preserve honest coverage and offline usefulness.
- **Freshness mismatch:** O*NET quarterly, OEWS annual, OOH profile/projection,
  ORS wave, and taxonomy clocks differ. One corpus timestamp is invalid.
- **Bias and dignity:** historic occupational relationships may narrow options;
  work-style/interest/ability data may become hidden profiling; wage/outlook
  sorting may become prestige ranking.
- **Localization:** source labels and concepts may not have approved translations.
  Machine translation cannot silently become source-authoritative wording.
- **Inspection overload:** complete provenance/statistical detail can become
  unreadable. Plain-language projections must retain the exact technical record
  behind progressive disclosure.

### Dependencies

- `public-reference-knowledge-foundation` supplies the approved claim envelope,
  rights/freshness/conflict axes, inspection, offline, and public-only boundary.
- `intelligence-quality-safety-evaluation` supplies coverage, grounding,
  privacy, bias/dignity, failure, accessibility, and regression evaluation.
- `cross-taxonomy-relationship-authority` owns O*NET-SOC-to-ESCO and other
  cross-source relationship claims.
- `current-opportunity-availability-intelligence` owns vacancies, applications,
  selecting-organization cycles, jurisdictional gates, and live provider data.
- Career recommendations and generative destination/path proposals consume only
  eligible immutable projections; they cannot bypass corpus claim ceilings.
- `intelligence-change-management` later owns release promotion policy and
  impact handling, not source semantic truth.

### Evidence required before Scope

Research has enough evidence to Scope a bounded United States production
corpus, provided Scope keeps the following explicit:

1. exact included/excluded O*NET 30.3 files and sensitive-use rules for Work
   Styles, Interests, Abilities, and hybrid-derived data;
2. separate overlay contracts for SOC, OOH, OEWS, and ORS, including population,
   geography, statistical reliability, suppression, preliminary/final state,
   and source clock;
3. fixed public refresh identities with no private request shaping;
4. release-specific rights and attribution, including source exceptions;
5. per-claim eligibility, missingness, invalidation, rollback, and offline state;
6. measured device storage/query/update budgets rather than invented targets;
7. a coverage/evaluation launch bar and a representative ordinary/regulated/
   competitive occupation fixture portfolio; and
8. explicit exclusion of ESCO packaging, cross-taxonomy equivalence, current
   opportunities/gates, personal matching, and user qualification.

No runtime/user evidence from v1 is required to define these public data and
authority behaviors. Recommendation usefulness must still wait for its own
direct-user evidence.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Trust/CareerCorpusInspectionModels.swift`, `Native/Ambitions/Trust/CareerCorpusInspectionProjection.swift`, `Native/Ambitions/Trust/CareerCorpusInspectionView.swift`, `Native/Ambitions/Trust/CareerCorpusInspectionAccessibility.swift`, `Native/Ambitions/Trust/SourceInspectionView.swift`, `Native/Ambitions/Trust/InspectionSurface.swift`.
- Evidence and unknowns: Repository audit identifies Task 8 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Scope a source-native United States career corpus with a full O*NET 30.3 base
and independently eligible SOC/OOH/OEWS/ORS overlays. Reuse Source Atlas
delivery, verification, public-cache, offline, and inspection infrastructure,
but add production adapters and per-source release manifests rather than
expanding the narrow validation adapter blindly.

The public corpus should expose immutable read projections with:

- source-native occupation, descriptor, statistical-series, and estimate IDs;
- exact release/taxonomy/reference period, geography/population, method,
  reliability/suppression, rights/attribution, category update, and retrieval;
- separate identity, descriptive, typical-preparation, work-context,
  labor-market, and job-requirement claim families;
- per-claim current/aging/stale/conflicted/withdrawn/unsupported/rights-blocked
  and consumer-eligibility states;
- explicit data-level/title-only/aggregate and overlay missingness;
- release diffs, atomic promotion, last-known-good rollback, invalidation, and
  offline availability; and
- progressive, accessible inspection of source meaning and limitations.

O*NET Work Styles, Interests, Abilities, and similar categories may be retained
as source-native public descriptors only when their license and semantic adapter
pass. They must be ineligible for silent personal matching or trait inference.
Public source collection remains independent of user intent. Local Planning may
later compare a permitted user-controlled projection with an eligible corpus
projection, but the career corpus never receives or stores that private input.

ESCO should proceed as a later source pack after release-bound content rights
and the cross-taxonomy initiative pass. Employer, regulator, selection-cycle,
and current-opening facts remain a separate current-authority system. This
preserves a small coherent owner: maintained career reference truth, not every
fact that might affect a career decision.

### Five compounding ruthless review passes

1. **Completeness and unsupported assumptions:** added SOC, OOH, OEWS, ORS,
   O*NET release/schema/license exceptions, title-only coverage, statistics,
   explicit launch evidence, and ESCO rights uncertainty instead of assuming
   “full O*NET” or “open data” solved production readiness.
2. **Connections, duplication, and missing owners:** separated slow-changing
   career reference, cross-taxonomy claims, live opportunity/regulatory facts,
   education facts, personal matching, evaluation, and change management; added
   exact handoffs to each owner.
3. **Privacy, authority, failure, deletion, and external effects:** prohibited
   private request shaping and hidden trait inference; preserved source-specific
   authority, rights, suppression, invalidation, offline/unavailable behavior,
   and no mutation/external-action path.
4. **Feasibility against live architecture:** grounded the direction in existing
   Source Atlas manifests, cache, quarantine, last-known-good, public-only,
   inspection, and test seams; rejected the misplaced private Source Atlas
   composer; identified missing full-release/overlay/statistical proof.
5. **Product coherence and long-term fidelity:** chose a bounded US production
   corpus that creates real destination breadth while leaving ESCO, crosswalks,
   current facts, recommendations, and user usefulness to their proper phases;
   retained local-first, inspectable, correctable, non-shaming claim ceilings.

Review verdict: **PASS**. The Research completes the source, rights, freshness,
statistical, architecture, privacy, bias, failure, dependency, and launch-shape
investigation needed for Scope. It does not claim source ingestion, runtime
coverage, recommendation usefulness, or release readiness.

Devan delegated approval authority for this documentation program. This
Research was approved under that authority on 2026-08-04. Approval authorizes a
bounded Scope; it does not authorize or claim ingestion, canon/source changes,
runtime behavior, recommendation use, merge, deployment, or release readiness.
