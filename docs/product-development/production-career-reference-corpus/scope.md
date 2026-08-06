+++
initiative = "production-career-reference-corpus"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions will maintain a source-native, production-grade United States career
reference corpus that makes the full O*NET 30.3 occupation taxonomy and eligible
descriptive data available offline, with independently versioned SOC, OOH,
OEWS, and ORS overlays. A user inspecting or later receiving a career option can
understand what the occupation/source actually says, the population and
geography to which a statistic applies, what is missing or stale, and what
Ambitions is not claiming.

The corpus is broad public reference, not personal intelligence. It never
decides qualification, fit, employability, likely success, prestige, identity,
or worth. It does not query public sources with private intent, create a current
job opening, resolve licensure, perform cross-taxonomy equivalence, generate a
Goal or path, or mutate the private graph.

This Scope defines the first production source release, its visible and
consumer-eligible claim families, source clocks, rights, validation, coverage,
failure, and inspection behavior. Passing structural delivery does not imply
semantic eligibility, recommendation usefulness, or release readiness.

## In scope

- Complete O*NET 30.3 occupation identity coverage: all 1,016 O*NET-SOC
  occupations with explicit data-level, title-only, aggregate, military, and
  `all other` status where published.
- Release-pinned O*NET 30.3 source-native records for occupation identity,
  titles, descriptions, essential/transferable skills, knowledge, education,
  training/experience, job zones, tasks/ratings, work activities/hierarchies,
  work context, related occupations, content-model/scales/anchors, and
  collection/occupation metadata.
- Source-native O*NET Abilities, Work Styles, Interests/Basic Interests,
  emerging tasks, software/technology skills, and related-domain material as
  inspection-only or restricted-use categories whose product eligibility is
  explicit rather than inferred.
- Independent United States SOC 2018 classification records and source-owned
  O*NET-SOC relationship records, without equating hierarchy levels.
- Independently versioned BLS OOH profile facts, employment-projection periods,
  May 2025 OEWS estimates, and 2025 ORS preliminary estimates with complete
  source, population, geography, methodology, unit, reliability, suppression,
  footnote, and limitation context where applicable.
- Per-release and per-claim rights, attribution, modification, trademark,
  locator, retrieval, and source-exception state.
- Per-source clocks, release diffs, semantic validation, staged promotion,
  atomic current/last-known-good pointers, rollback, invalidation, withdrawal,
  and historical lineage.
- Per-claim consumer eligibility and coverage: identity, description, typical
  preparation, work context, labor-market estimate, occupational-requirement
  estimate, discovery relation, inspection-only, and unavailable.
- Fixed public refresh identities independent of users and the existing
  Source Atlas public-only boundary.
- Local immutable projections for later Planning, recommendation, Goal Path,
  model, and evaluation consumers.
- Accessible source and corpus inspection with honest offline, missing,
  suppressed, preliminary, stale, conflicted, rights-blocked, unsupported,
  invalidated, and unavailable states.
- A representative evaluation portfolio covering ordinary, regulated, and
  competitive occupations without claiming regulation/current opportunity data
  is part of this corpus.

## Out of scope

- ESCO content packaging or multilingual European occupation coverage. That
  requires a completed release-specific content-rights review and its own
  source-native pack.
- Equivalence between O*NET, SOC, ESCO, employer titles, education programs,
  credentials, Capabilities, or other taxonomies. Cross-source relationships
  belong to `cross-taxonomy-relationship-authority`.
- Current vacancies, employer requirements, regulator/licensure rules,
  selecting-organization eligibility, application cycles, availability,
  deadlines, fees, or provider capacity. Those belong to
  `current-opportunity-availability-intelligence`.
- Education, credential, and provider corpora or hobby/life-path corpora.
- Personal Capability/Proof matching, user trait/personality inference,
  compatibility, readiness, employability, success probability, ranking by
  prestige/pay, or recommendation policy.
- Generative destination/path creation, Goal adoption, Step creation,
  scheduling, simulation, learning, external actions, or canonical mutation.
- Live web/API lookup shaped by a user's ambition or private state, remote
  personalization, private-derived cache/request/log identities, or corpus
  feedback containing user behavior.
- O*NET Career Exploration Tools, including Interest Profiler outputs; arbitrary
  O*NET web content or external-source content not covered by the database
  license; BLS logos/images; and any record lacking approved release-specific
  rights.
- Treating structural pack verification, row count, source authority, offline
  availability, or corpus breadth as proof of factual adjudication,
  recommendation quality, user usefulness, implementation completion, merge,
  deployment, or release readiness.
- Product source, canon, test, project, workflow, or tooling changes during this
  documentation phase.

## Fixed source-release baseline

The O*NET names below are the official 30.3 downloadable-file labels. Design
must bind them to exact archive members, schemas, and hashes; it may not add a
file or widen its eligibility without returning to Scope.

| O*NET 30.3 file group | Product treatment |
|---|---|
| `Occupation Data`, `Job Titles`, `Sample of Reported Titles` | identity/label/description eligibility with exact data-level status; titles are not openings |
| `Essential Skills`, `Transferable Skills`, `Knowledge` | descriptive occupation relationship eligibility; never user capability or proficiency |
| `Education`, `Education Categories`, `Training and Experience`, `Training and Experience Categories`, `Job Zones`, `Job Zone Reference` | distributional/typical-preparation eligibility; never a hard gate |
| `Task Statements`, `Task Ratings`, `Task Categories` | descriptive task eligibility with exact scale/collection metadata |
| `Work Activities`, `GWAs to IWAs`, `GWAs to IWAs to DWAs`, `Tasks to DWAs` | source-native activity/hierarchy eligibility; relation direction remains explicit |
| `Work Context`, `Work Context Categories` | descriptive population/context eligibility; never a personal tolerance or compatibility judgment |
| `Related Occupations` | source-owned discovery relation only; never identity, fit, promotion sequence, or required path |
| `Content Model Reference`, `Occupation Level Metadata`, `Level Scale Anchors`, `Scales Reference`, `Survey Booklet Locations` | supporting schema/method/scale provenance; not standalone user claims |
| `Abilities`; `Career Interest Types`; `Specific Interest Areas`; `Career Interest Type Keywords`; `Specific Interest Areas to Career Interest Types`; `Interests Illustrative Activities`; `Interests Illustrative Occupations`; `Work Styles`; `Emerging Tasks`; `Software Skills`; `Abilities to Work Activities`; `Abilities to Work Context`; `Essential Skills to Work Activities`; `Essential Skills to Work Context`; `Transferable Skills to Work Activities`; `Transferable Skills to Work Context`; `Work Styles to Work Activities`; `Work Styles to Work Context` | retain only as source-native inspection/research records unless a narrower eligibility is separately approved; never hidden traits, current demand, qualification, or personal matching |
| `Software Skills Competencies`, `Essential Skills Competencies`, `Transferable Skills Competencies`, `Knowledge Competencies`, `Abilities Competencies`, `Work Activities Competencies`, `O*NET-SOC Occupations` competency-framework downloads | supporting source-native hierarchy/serialization only, with the eligibility of the underlying approved data; duplicate representation cannot create a new or stronger claim |

The following are excluded from the production package: O*NET Career
Exploration Tools and Interest Profiler results; arbitrary Resource Center or
O*NET OnLine page content; non-database external-source material not covered by
the 30.3 content license; graphics/logos; web-service results outside the fixed
release manifest; and any unknown archive member.

The fixed BLS baseline is SOC 2018; OOH profiles and Employment Projections for
the 2024–34 projection period bound to captured page/data revisions; May 2025
OEWS; and 2025 preliminary ORS. Each remains a separate overlay. A newer release
can be staged and evaluated, but it cannot silently replace this baseline.

## Requirements

### REQ-001 — Release and source-native identity

Every corpus, source family, release, occupation, descriptor, statistical
series, estimate, relationship, and claim must have stable source-native and
Ambitions identities. A visible or consumer-eligible claim must bind its exact
source release/taxonomy/reference period, source record, category/measure, and
retrieval/review state. An ID reused with different meaning must fail.

### REQ-002 — Complete O*NET occupation identity coverage

The O*NET 30.3 base must account for every published O*NET-SOC occupation
identity and explicitly label data-level, title-only, aggregate, military,
`all other`, missing, withdrawn, and unsupported states. Missing descriptive
data must not be inherited from a parent or neighboring occupation without a
separate source-owned relationship and visible limitation.

### REQ-003 — Exact O*NET category policy

The production allowlist must name each accepted downloadable O*NET 30.3 file
and map it to a claim family. Occupation identity/titles/descriptions,
essential/transferable skills, knowledge, education, training/experience, job
zones, tasks, work activities, work context, related occupations, scales,
anchors, and collection metadata may become eligible only for their exact
source-owned descriptive purpose.

Abilities, Work Styles, career/basic interests, emerging tasks,
software/technology designations, and related-domain records must default to
`inspection_only` or a narrower named eligibility. They must never become an
inferred user trait, compatibility decision, hard gate, current demand, or
personal recommendation signal merely because they exist in O*NET.

### REQ-004 — Measurements retain source semantics

Ratings, frequencies, levels, importance, percentages, sample metadata,
standard errors, ranges, scale anchors, category update dates, and missing/
suppressed values must retain their source definitions. Ambitions must not
compare values across different scales, populations, category versions, or
sources as if they were the same measurement.

### REQ-005 — BLS source families remain independent

SOC, OOH, employment projections, OEWS, and ORS records must preserve separate
identities, authority, clocks, populations, geographies, methods, and
limitations. Shared SOC codes may link source records but must not cause OOH
typical preparation, OEWS wages, ORS requirements, or projections to overwrite
or validate one another.

### REQ-006 — Statistical claims remain estimates

Every OEWS, ORS, or projections claim must expose its reference period,
population and exclusions, geography/industry, occupation granularity, measure,
unit, estimate kind, reliability/standard-error or range state, suppression and
footnotes, preliminary/final state, methodology locator, and source limitation.
It must not render as an offered salary, individual requirement, personal
outcome, guaranteed trend, or exact prediction.

### REQ-007 — Typical preparation is not a gate

OOH and O*NET education, experience, training, and job-zone material must be
labeled as source-described typical/distributional context. It must not become
an employer, regulator, program, or universal qualification gate. Unknown
current gates remain unknown and hand off to the current-authority initiative.

### REQ-008 — Rights and attribution are release- and file-specific

Packaging, transformation, and visibility must be allowed only when the exact
release/file rights permit the use. O*NET attribution must identify 30.3,
USDOL/ETA, CC BY 4.0, changes, and trademark use as applicable. BLS material
must preserve source/retrieval and downstream-analysis limitations and exclude
protected logos/images. External-source exceptions and unresolved rights make
only the affected records unavailable.

### REQ-009 — Public-only collection is independent of users

Remote refresh may request only fixed allowlisted public source/release
identities. Private ambition, Goal, Capability, Proof, schedule, location,
recommendation, correction, selection, or rejection data must not influence a
request, endpoint, object key, header, cache key, artifact ID, log, diagnostic,
analytics event, or source feedback.

### REQ-010 — Per-source freshness and honest age

O*NET database/taxonomy/category, OOH profile/projection, OEWS dataset, ORS wave,
and SOC edition clocks must remain independent. Each claim must distinguish
current, aging, stale-allowed, stale-blocked, source-changed, preliminary,
superseded, withdrawn, conflicted, unknown, and unavailable as applicable. A
newer source release invalidates affected consumer eligibility until reviewed;
it does not silently erase last-known-good history.

### REQ-011 — Staged validation, promotion, rollback, and recovery

A downloaded release must pass public-boundary, size/decompression, hash/
signature, schema, source-binding, rights, attribution, semantic, coverage, and
evaluation checks before promotion. Promotion is atomic. Failure or interruption
preserves the prior verified release, quarantines only the affected candidate,
and provides a retry/review path without weakening validation.

### REQ-012 — Per-claim missingness and eligibility

Delivery, structural validity, semantic validity, rights eligibility,
freshness, consumer eligibility, evaluation coverage, and recommendation
readiness must remain separate. A corpus percentage cannot hide one missing,
suppressed, title-only, unsupported, conflicted, rights-blocked, or stale-blocked
claim. `unavailable` and `insufficient_evidence` remain valid outcomes.

### REQ-013 — Source-owned relationships are not equivalence

Within-source O*NET hierarchy, related-occupation, and related-domain records and
O*NET-published SOC relationships must preserve relation type, direction,
release, source/target granularity, and limitations. They may support discovery
only to their declared eligibility. They must not assert identity, personal fit,
required career sequence, promotion path, or cross-taxonomy equivalence.

### REQ-014 — Consumer access is read-only and claim-bounded

Local consumers must receive immutable public projections filtered by exact
claim family and eligibility, plus source, freshness, rights, coverage, and
limitation metadata. The corpus must not accept a private query DTO, write a
canonical object, issue a command, or turn a source relationship into a
recommendation/Goal/path by itself.

### REQ-015 — Sensitive inference and dignity boundaries

The corpus must not build a user personality, work-style, interest, ability,
employability, compatibility, prestige, productivity, readiness, or success
score. Sparse historical relationships, lower wages/outlook, physical/cognitive
requirements, or title-only status must not eliminate aspirational options or
demean a person. ORS records cannot be individual medical, disability, or
accommodation conclusions.

### REQ-016 — Offline and partial availability remain useful

A verified bundled or last-known-good release must remain inspectable and
queryable offline with its actual version/age/eligibility. If one overlay,
occupation, category, geography, or estimate is unavailable, independent valid
records remain usable and the missing claim stays explicit. Corpus failure must
not block Today, Goals, Time, You, or the private local core.

### REQ-017 — Accessible inspection preserves exact meaning

Users and reviewers must be able to inspect occupation identity/status,
descriptive claims, statistical context, source/release, geography/population,
freshness, rights/attribution, missingness, conflicts, limitations, and consumer
eligibility in a coherent semantic order. No required meaning may depend only
on color, graph layout, hover, animation, abbreviation, or inaccessible table
geometry. VoiceOver, Dynamic Type, reduced motion, increased contrast, RTL,
keyboard, Voice Control, and Switch Control must preserve the flow and recovery.

### REQ-018 — Withdrawal, purge, and historical lineage

When rights are withdrawn, a source corrects/retracts data, or a release is no
longer permitted, affected current projections and distributable bytes must be
removed or blocked according to the source contract. Historical lineage may
retain only permitted identifiers, hashes, dates, and non-recoverable audit
metadata. Dependent evaluation and consumer evidence must invalidate.

### REQ-019 — Coverage and evaluation launch bar

Before any claim family is labeled production-eligible, evaluation must prove
identity/accounting, parser fidelity, authority, factual sampling, rights/
attribution, freshness, failure/rollback, offline behavior, privacy canaries,
bias/dignity safeguards, accessibility, query behavior, and regression for that
exact source/release/claim family. Coverage reports must include numerator,
denominator, exclusions, missingness, and evidence ceiling.

### REQ-020 — Representative domain proof without overclaim

The corpus evaluation portfolio must include ordinary, regulated, competitive,
title-only, aggregate, sparse-data, suppressed-statistic, preliminary-estimate,
stale, conflicted, and rights-blocked cases. Regulated/competitive fixtures must
show that occupation facts remain useful while current gates/availability stay
unknown and no success or qualification claim appears.

## Acceptance criteria

1. **AC-001 (`REQ-001`, `REQ-002`):** A release report accounts for all 1,016
   O*NET 30.3 occupation identities with stable native IDs and exact status;
   duplicate/reused identity or implicit parent inheritance fails validation.
2. **AC-002 (`REQ-003`, `REQ-004`):** Every accepted O*NET file/category is on
   an explicit allowlist and its source scale/metadata round-trips; restricted
   categories remain inspection-only and cannot enter personal matching.
3. **AC-003 (`REQ-005`, `REQ-006`):** Opening one OOH, OEWS, ORS, and projections
   record shows distinct source clocks/populations/methods; suppressed,
   preliminary, range, standard-error, geography, and unit meaning survives and
   no estimate becomes a personal fact.
4. **AC-004 (`REQ-007`):** O*NET/OOH preparation content is visibly typical or
   distributional; an absent employer/regulator gate remains unknown instead of
   becoming a requirement.
5. **AC-005 (`REQ-008`):** O*NET claims display release-specific attribution,
   license/change/trademark treatment; BLS claims display source/retrieval and
   limitations; excluded/external/logo/right-unknown material is absent.
6. **AC-006 (`REQ-009`):** Seeded private values across ambition, Goal,
   Capability, Proof, Time, location, recommendation, correction, and rejection
   produce zero bytes in every network, artifact, cache, log, diagnostic,
   analytics, and feedback path.
7. **AC-007 (`REQ-010`, `REQ-011`):** A new, malformed, interrupted,
   semantically invalid, rights-blocked, or regressive source release cannot
   replace current; affected claims show exact state and verified
   last-known-good remains available.
8. **AC-008 (`REQ-012`):** Delivered/valid/eligible/evaluated/recommendation-
   ready axes remain separate; a single missing or invalid claim is inspectable
   even when aggregate coverage is high.
9. **AC-009 (`REQ-013`):** Removing or changing a hierarchy/related-occupation/
   SOC relationship preserves source and target identities; no identity,
   personal-fit, required-sequence, or cross-taxonomy claim is inferred.
10. **AC-010 (`REQ-014`):** A consumer can query an exact eligible public claim
    projection with provenance/limitations, while compile-time and runtime tests
    show no private query input, canonical write, command, Goal/path creation, or
    external effect.
11. **AC-011 (`REQ-015`):** Counterfactual cases changing historical similarity,
    wage/outlook, work-style/interest/ability descriptors, or ORS conditions do
    not produce a person score, exclusion, demeaning language, medical claim, or
    disappearance of otherwise legitimate aspirational options.
12. **AC-012 (`REQ-016`):** Offline/no-account returns the exact bundled or
    last-known-good release and age; failure of one source/overlay/record leaves
    independent public and private behavior usable.
13. **AC-013 (`REQ-017`):** Source/corpus inspection passes semantic, Dynamic
    Type, reduced motion, contrast, RTL, keyboard, VoiceOver, Voice Control, and
    Switch Control checks for complete, title-only, missing, statistical,
    suppressed, preliminary, stale, conflicted, rights-blocked, and unavailable
    states.
14. **AC-014 (`REQ-018`):** Rights withdrawal or correction removes/blocks all
    disallowed bytes and current projections, preserves only permitted lineage,
    and invalidates every dependent evaluation/consumer record.
15. **AC-015 (`REQ-019`, `REQ-020`):** The claim-family coverage report names
    exact source/release, numerator/denominator/exclusions, all required cases,
    tests and evidence types, limitations, and resulting eligibility; no broad
    corpus or recommendation claim follows from a narrower pass.

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

Implementation would likely extend the Source Atlas system specification with a
production career-corpus subsection and add narrow traceability to source
reference, Trust inspection, privacy/data classification, and future
intelligence-evaluation canon. It may require a canon-owned vocabulary for
statistical estimate, population, suppression, preliminary/final state,
data-level/title-only status, and per-claim consumer eligibility.

No canon change is authorized by this Scope. Design must name exact candidate
files and preserve current public-only/private-Planning ownership. If proposed
corpus behavior conflicts with current canon, current canon wins and the issue
returns to Scope.

## Risks and open decisions

### Resolved product decisions

- First production scope is United States and release-bound to O*NET 30.3,
  SOC 2018, May 2025 OEWS, 2025 preliminary ORS, and the exact OOH/profile and
  employment-projection revisions captured in its manifest.
- O*NET is the base occupation corpus. BLS families are overlays with separate
  claim authority and clocks.
- Abilities, Work Styles, Interests/Basic Interests, emerging tasks, and
  technology/demand descriptors default to inspection-only/restricted use.
- Full occupation accounting is required; full descriptive coverage is not
  fabricated where source data is title-only, aggregate, sparse, or missing.
- ESCO, cross-taxonomy equivalence, live opportunity/gates, personal matching,
  recommendations, and mutations are excluded.
- Source collection is fixed/public; local consumers are immutable/read-only.

### Dependencies and downstream handoffs

- Requires approved `public-reference-knowledge-foundation` contracts and the
  `intelligence-quality-safety-evaluation` suite before production eligibility.
- Provides source-native occupation and statistical projections to career
  recommendations, destination/path generation, and current-authority work.
- O*NET-to-ESCO and other cross-source relationships wait for
  `cross-taxonomy-relationship-authority`.
- Regulatory, employer, selection-cycle, and opening facts wait for
  `current-opportunity-availability-intelligence`.
- Release promotion/rollback policy later hands to
  `intelligence-change-management`, which cannot waive source or rights failure.

### Design risks to resolve

- Complete source files may exceed comfortable launch storage and query/update
  budgets. Design must define source-preserving partitions and measured budgets
  without silently reducing coverage.
- OOH HTML/profile structure and BLS dataset formats may change independently.
  Design must isolate adapters and bind exact bytes/manifest rather than scrape
  at user request.
- Statistical and provenance detail can overwhelm users. Design must support
  progressive disclosure while retaining exact accessible meaning.
- Rights withdrawal must purge distributed content without breaking immutable
  audit lineage. Design must separate recoverable bytes from permitted metadata.
- Refresh and consumer reads can race. Design must define immutable snapshots,
  atomic pointers, cancellation, replay, and invalidation ordering.

There is no unresolved product decision that Design must invent. Concrete
storage, indexing, packaging, adapter, refresh scheduling, and presentation
choices remain Design work within these fixed boundaries.

## Review and approval

Review verdict: **PASS** after one repair round. The repair replaced broad
O*NET category language with the normative 30.3 downloadable-file and
competency-framework groups plus their exact product eligibility. The final
Scope was checked for observable outcomes, inclusions/exclusions, numbered and
testable requirements, source and statistical authority, freshness, failure,
rollback, correction/withdrawal, privacy, sensitive inference, accessibility,
dependencies, downstream handoffs, and implementation neutrality. Every
requirement maps to acceptance criteria and no product fork remains.

Devan delegated approval authority for this documentation program. This Scope
was approved under that authority on 2026-08-04. Approval authorizes Design; it
does not claim ingestion, source/canon implementation, tests, runtime coverage,
recommendation use, merge, deployment, or release readiness.
