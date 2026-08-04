+++
initiative = "production-education-credential-provider-corpus"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions will maintain a source-native, production-grade United States
education, credential, and provider reference corpus whose first release
includes CIP 2020, exact IPEDS and College Scorecard releases, and an exact
DAPIP download. A user inspecting or later receiving an education option can
understand what the institution, field, outcome, or reported recognition record
actually says, its population and time period, what is missing or suppressed,
and what Ambitions is not claiming.

The corpus is public reference, not a school marketplace or personal decision
engine. It never decides admission, acceptance, transfer, licensure, fit,
quality, likely completion, earnings, return, prestige, or worth. It does not
query sources with private intent, prove that the user holds a credential,
create a current offering, generate a Goal/path, or mutate the private graph.

This Scope defines the first production release, source and identity authority,
statistical and accreditation ceilings, access/rights gates, coverage, failure,
inspection, and downstream eligibility. Structural delivery is not evidence of
recommendation usefulness or release readiness.

## In scope

- Complete CIP 2020 hierarchy, descriptions, status, and published 2010–2020
  crosswalk records as classification only.
- A fixed U.S. IPEDS release manifest containing institution identity and
  selected Institutional Characteristics, Completions, Admissions, Student
  Financial Aid, Graduation Rates/Outcome Measures, and price/finance
  components only where their exact files, years, definitions, and product
  treatment are listed in the release manifest.
- A fixed College Scorecard institution- and field-of-study release manifest
  containing only named documented identity, cost, aid, completion, debt, and
  earnings measures with cohort, source-year, coverage, unit, and suppression.
- A fixed DAPIP data download containing reported agency, recognition,
  institution, branch/site, program, scope, action, status, and effective-date
  records with the Department's currency/completeness disclaimer.
- Source-native identity records for CIP code, UNITID, OPEID, DAPIP entity,
  agency, branch/site, program, Scorecard field/credential level, and other
  exact source identifiers.
- Explicit, evidence-bound identity assertions across sources, including
  confirmed, ambiguous, conflicting, superseded, and unmapped states.
- Reserved CTDL Registry and CASE adapter contracts whose records remain
  unavailable until exact access, redistribution, attribution, retention,
  update, publisher, version, and content-rights review passes.
- Per-release and per-record rights, access, attribution, transformation,
  retention, withdrawal, source-locator, and review state.
- Release diffs, semantic validation, staged promotion, atomic current and
  last-known-good pointers, rollback, invalidation, withdrawal, correction,
  and historical lineage.
- Fixed public refresh identities independent of users and the existing Source
  Atlas public-only boundary.
- Local immutable projections for later education discovery, recommendation,
  model, Goal Path, inspection, and evaluation consumers.
- Accessible source inspection and honest offline, imputed, derived,
  suppressed, preliminary, stale, conflicted, ambiguous, withdrawn,
  rights-blocked, unsupported, invalidated, and unavailable states.
- A representative evaluation portfolio containing ordinary institutions,
  alternative-provider absence, branch ambiguity, mergers/closures,
  suppressed cohorts, changed accreditation, and conflicting identities.

## Out of scope

- Current provider catalog, term, course section, admissions window,
  prerequisite, tuition/fee quote, aid offer, modality, schedule, seat/capacity,
  application, transfer agreement, licensure rule, recognition decision, or
  current availability. These belong to
  `current-opportunity-availability-intelligence`.
- Complete CTDL Registry mirroring or CASE framework packaging until the exact
  feed/framework passes the required rights and access review.
- Global institution/provider coverage, non-U.S. classification, or translation
  of source-authoritative content.
- Cross-taxonomy equivalence among CIP, occupations, competencies, credentials,
  courses, Capabilities, or other frameworks. Those relationships belong to
  `cross-taxonomy-relationship-authority`.
- User-held credential import, verification, revocation, or Proof. Those belong
  to `verifiable-credential-import` and Capability/Proof owners.
- Program/provider ranking; universal quality, value, ROI, prestige,
  employability, or person scores; admission/completion/earnings prediction;
  or hidden personalization.
- Education destination recommendation policy, capability matching, generative
  destination/path creation, Goal adoption, scheduling, simulation, learning,
  external actions, or private graph mutation.
- Live lookup shaped by a user's ambition, history, finances, location,
  disability/accommodation, immigration, schedule, selection, or rejection.
- Scraped arbitrary provider pages, marketing copy, logos/images, unapproved
  source fields, or any record without release-specific rights.
- Treating installation, row count, source authority, offline availability, or
  corpus breadth as proof of semantic correctness, user value, implementation
  completion, merge, deployment, or release readiness.
- Product source, canon, tests, project state, workflows, or lifecycle tooling
  changes during this documentation phase.

## Fixed first-release baseline

Design must bind every entry below to exact archive/file bytes, schemas, hashes,
release dates, terms review, and field allowlists. It may narrow a file or field
for safety, device limits, or unavailable rights; it may not add a source,
component, or product claim without returning to Scope.

| Layer | Fixed baseline and product treatment |
|---|---|
| CIP | Full CIP 2020 hierarchy, descriptions, status, and the official 2010–2020 crosswalk. Classification and source-published crosswalk only; never offering, curriculum, equivalence, or quality. |
| IPEDS identity | Exact selected release of Institutional Characteristics/Header/Directory identity needed to represent UNITID, institution, branch-relevant fields, control/level/sector, location, active/closed/merged state where source-published. Identity and survey-universe context only. |
| IPEDS programs | Exact selected release of Completions by CIP/award level and approved related counts. Historical reported/imputed output context only; never current offering or curriculum. |
| IPEDS costs and aid | Exact selected release components/fields for published price and student-aid aggregates. Each value retains academic year, population, unit, reported/imputed/derived state, and definition; never an individual quote or affordability decision. |
| IPEDS completion/outcome | Exact selected Graduation Rates and Outcome Measures fields only where cohort and inclusion rules are fully represented. Descriptive aggregates only. |
| IPEDS admissions | Exact selected aggregate admissions fields where documented. Historical institution-level context only; never individual probability, current requirement, or current cycle. |
| College Scorecard institution | Exact fixed release fields for approved identity, cost, aid, completion, debt, earnings, and other measures named in the semantic manifest. Measure-specific source year/cohort and suppression required. |
| College Scorecard field of study | Exact fixed release fields for institution, CIP, credential level, credentials conferred, debt and post-completion earnings named in the semantic manifest. No field-level value may inherit to an individual program or person. |
| DAPIP | Exact fixed download of recognized agency and reported institution/program/site accreditation/approval actions and status. Exact entity/scope/date required; Department disclaimer and agency-verification path always retained. |
| CTDL Registry | Adapter/schema reservation only. Records are `rights_blocked` until exact consumer access and redistribution/retention/update terms pass; publisher claims remain publisher claims. |
| CASE | Adapter/schema reservation only. Specification implementation does not approve any framework content. Each future framework requires publisher, version, jurisdiction, access, and content rights. |

The first release must record the exact IPEDS and College Scorecard release IDs,
component years, archive member names, field names, definitions, and hashes in
its semantic manifest. “Latest” is forbidden as a release identity.

## Requirements

### REQ-001 — Source-native release and record identity

Every corpus release, source release, file, survey component, taxonomy item,
institution, branch/site, program/field, credential level, agency, recognition
record, measure, and claim must have stable source-native and Ambitions
identities. A visible or consumer-eligible claim must bind the exact source
record, release/component/cohort, semantic definition, retrieval, and review.
Reused identifiers with changed meaning must fail validation.

### REQ-002 — Complete CIP 2020 classification coverage

The corpus must account for every included CIP 2020 hierarchy record and its
published status. Crosswalk relationships must bind both editions and exact
relationship semantics. A CIP code must never render as proof of an offering,
curriculum, competency, recognition, transfer, or equivalence.

### REQ-003 — IPEDS survey semantics remain explicit

Every IPEDS value must preserve component, collection/reporting year,
institution universe, UNITID, variable/definition, unit, population, and
reported, imputed, derived, suppressed, not-applicable, missing, or revised
state. Components with different years may coexist but must not be presented as
one same-date institution snapshot.

### REQ-004 — Completions do not create current programs

An IPEDS completion by CIP and award level may support a historical statement
that credentials were reported/conferred for the named collection. It must not
create a provider program, current curriculum, current availability, admission
gate, or future continuation claim.

### REQ-005 — Scorecard measurements retain cohort and suppression

Every College Scorecard claim must preserve its institution/field identity,
credential level, cohort/source year, measurement horizon, population,
coverage, unit, definition, privacy suppression, missingness, and limitations.
Suppressed values must not be displayed, approximated, inferred, ranked, or
treated as zero. Measures with different cohorts must remain distinguishable.

### REQ-006 — Descriptive outcomes never become predictions or rankings

Cost, aid, completion, debt, earnings, admission, and other aggregates must be
labeled as descriptive source measures. They must not render as personal cost,
aid, debt, earnings, completion/admission probability, ROI, program quality,
prestige, or a universal ordering. Consumers receive no corpus-produced score.

### REQ-007 — DAPIP reports exact recognition scope and limits

Every DAPIP claim must retain reporting agency, recognized agency status/scope,
institution/program/site identity, recognition or action type, status,
effective/end/action dates, dataset retrieval, and the Department disclaimer.
Institution recognition must not be inherited by a program, branch, delivery
mode, or jurisdiction absent an exact record. Material current use must expose
the named agency verification path.

### REQ-008 — Accreditation is not acceptance, transfer, licensure, or endorsement

The corpus must not translate a DAPIP or publisher recognition relationship
into Department endorsement, admission, transfer credit, licensure eligibility,
certification acceptance, employability, or personal fit. Conflicting or
incomplete recognition evidence must remain visible and block stronger claims.

### REQ-009 — Cross-source identity uses explicit assertions

UNITID, OPEID, DAPIP identifiers, CTID, provider URL, institution/program name,
and other identifiers may be connected only by an assertion carrying source,
method, evidence, scope, version, review state, and confirmed, ambiguous,
conflicting, superseded, or unmapped status. Name similarity or shared address
cannot silently merge records. Downstream claims cannot cross an ambiguous or
conflicting identity link.

### REQ-010 — CTDL and CASE remain access- and rights-gated

The corpus may reserve CTDL and CASE models/adapters, but it must not package or
expose a Registry record or framework until the exact source passes access,
redistribution, attribution, transformation, retention, update, withdrawal,
publisher, version, and content-rights review. Schema/specification licensing
must not be substituted for content rights.

### REQ-011 — Rights and attribution are source-, release-, and record-specific

Every packaged artifact and transformation must have an allowed use and
required attribution for the exact source/release/file/record. Logos, images,
marketing assets, and excluded fields remain excluded. Rights ambiguity blocks
only affected records/layers. Rights withdrawal invalidates new use and follows
the exact retention/deletion obligation without erasing audit lineage that may
legally remain.

### REQ-012 — Public collection is independent of users

Remote refresh may request only finite allowlisted public source/release
identities. Ambition, Goal, education history, credential holdings, Capability,
Proof, finances, schedule, location, disability/accommodation, immigration,
recommendation, correction, selection, or rejection data must not influence a
request, endpoint, parameter, object key, header, cache key, artifact ID, log,
diagnostic, analytics event, or source feedback.

### REQ-013 — Per-source freshness and honest age

CIP edition, each IPEDS component, each Scorecard measure/cohort, DAPIP
download/action, and each future CTDL/CASE source must retain independent
clocks. Claims must distinguish current, aging, stale-allowed, stale-blocked,
preliminary, final, revised, source-changed, superseded, withdrawn, conflicted,
unknown, and unavailable where applicable. A newer release does not silently
rewrite historical records or erase last-known-good state.

### REQ-014 — Per-claim eligibility and claim ceilings

Structural validity, source authority, rights, freshness, identity resolution,
semantic validation, coverage, and consumer-purpose eligibility are separate.
Each projection must state exact eligible claim families and non-claims.
Installing one layer must not make all layers or all uses eligible.

### REQ-015 — Staging, semantic validation, promotion, and rollback

Every release must pass schema/hash/signature/size validation, exact release and
field allowlists, source-native count/coverage checks, semantic invariants,
rights/attribution checks, identity-conflict checks, evaluation gates, and
device budgets before atomic promotion. Failure quarantines the candidate and
preserves the last-known-good snapshot. Promotion, rollback, invalidation, and
withdrawal must be idempotent and replay-safe.

### REQ-016 — Offline, unavailable, correction, and deletion behavior

The bundled bootstrap or last-verified eligible snapshot must remain usable
offline with exact age and coverage. Never-fetched or rights-blocked content is
unavailable, not empty. Source corrections produce versioned supersession and
downstream invalidation. Users may clear downloaded corpus data and reset to
the bundled floor without deleting private Goals, Capabilities, Proof, or
history; corpus reset must not imply source correction or erase required public
artifact audit lineage.

### REQ-017 — Inspection and accessible explanation

A user and evaluator must be able to inspect plain-language meaning, publisher,
source record, release/component/cohort, population, unit, source processing
state, suppression, identity link, recognition scope, freshness, rights,
conflicts, limitations, and non-claims. Technical detail must remain reachable
through accessible progressive disclosure, Dynamic Type, VoiceOver, non-color
status, stable focus, and Reduced Motion behavior.

### REQ-018 — Coverage and evaluation evidence

Each release must publish machine-readable coverage and change reports for CIP,
IPEDS components/universe, Scorecard measures/cohorts/suppression, DAPIP
entities/actions, identity links, rights, missingness, conflicts, and eligible
claims. It must pass the intelligence evaluation foundation's grounding,
authority, privacy, dignity/bias, failure, accessibility, regression, and
device-budget gates over representative and adversarial fixtures.

### REQ-019 — Downstream consumers remain read-only and typed

Education recommendation, model, Goal Path, inspection, and evaluation
consumers may receive only immutable purpose-eligible public projections and
explicit unknowns/limitations. The corpus exposes no interface that accepts
private state, ranks options, creates/edits Goals or paths, schedules Steps,
creates Capability/Proof, writes Life Context, or performs external actions.

### REQ-020 — Useful bootstrap and measured device budgets

The first installed experience must contain a source-valid, representative
bootstrap that exercises each first-release layer and offline inspection
without claiming national completeness. Full/sharded releases must be measured
on supported devices for download size, installed size, staging peak, parse,
validation, promotion, cold/warm query, memory, energy, background budget, and
rollback. Product thresholds must be set from measured evidence before release,
not invented in documentation.

## Acceptance criteria

1. **AC-001 (REQ-001):** Reusing a source identifier for changed meaning or
   rendering a claim without exact release/record/definition binding fails
   validation and cannot promote.
2. **AC-002 (REQ-002):** The CIP coverage report accounts for every baseline
   hierarchy record; edition-crosswalk fixtures preserve non-identity relations;
   no CIP-only fixture renders as an offering or curriculum.
3. **AC-003 (REQ-003):** Reported, imputed, derived, suppressed,
   not-applicable, missing, provisional, and revised IPEDS fixtures remain
   distinguishable, and mixed component years never render as one date.
4. **AC-004 (REQ-004):** A historical completion fixture with no current
   provider offering remains “historical completions; current offering
   unknown” and cannot become a destination offering.
5. **AC-005 (REQ-005):** Scorecard cohort and field-of-study fixtures preserve
   exact measure definitions/source years and do not expose, estimate, or sort
   suppressed values.
6. **AC-006 (REQ-006):** No corpus API or reference UI emits a rank, ROI,
   quality, prestige, admission/completion probability, or personal outcome;
   adversarial copy tests reject those transformations.
7. **AC-007 (REQ-007):** Institution, branch, program, expired/action, and
   changing-agency fixtures render exact DAPIP scope/dates/disclaimer and a
   current agency verification route.
8. **AC-008 (REQ-008):** An accredited institution fixture with unknown
   program accreditation, transfer, and licensure retains all three unknowns
   and cannot inherit or infer them.
9. **AC-009 (REQ-009):** Exact confirmed, ambiguous, conflicting, merged,
   closed, and unmapped identity fixtures produce their named states; claims do
   not traverse ambiguous/conflicting links.
10. **AC-010 (REQ-010):** CTDL bulk and CASE framework fixtures cannot package
    while exact access/content-rights evidence is absent, even when schema and
    technical conformance pass.
11. **AC-011 (REQ-011):** A source-specific rights or attribution failure
    blocks only affected records/layers, and withdrawal follows the declared
    retention/deletion action while preserving lawful audit lineage.
12. **AC-012 (REQ-012):** Public-boundary tests seeded with every named private
    field prove byte-identical requests, keys, logs, diagnostics, artifacts,
    and refresh behavior.
13. **AC-013 (REQ-013):** Mixed-clock and newer-release fixtures display their
    independent states; staged new bytes cannot silently replace or rewrite
    last-known-good/history.
14. **AC-014 (REQ-014):** A structurally valid but rights-blocked, stale,
    identity-conflicted, suppressed, or semantically invalid claim is
    ineligible for the affected purpose while unaffected claims remain usable.
15. **AC-015 (REQ-015):** Corrupt, incomplete, wrong-release, unknown-field,
    count-drift, semantic-drift, identity-conflict, rights, evaluation, and
    device-budget failures quarantine the candidate; replay produces the same
    decision and last-known-good remains selected.
16. **AC-016 (REQ-016):** Offline, never-fetched, clear-download, reset,
    correction, supersession, invalidation, and rights-withdrawal fixtures
    preserve exact status and do not mutate or delete private data.
17. **AC-017 (REQ-017):** Reference and Trust inspection exposes every named
    meaning/limitation with VoiceOver, Dynamic Type, non-color status, keyboard
    or assistive navigation, stable focus, and Reduced Motion evidence.
18. **AC-018 (REQ-018):** Coverage reports reconcile exact source counts and
    eligible/ineligible reasons, and the representative/adversarial portfolio
    passes the approved evaluation gates without claiming user usefulness.
19. **AC-019 (REQ-019):** Compile-time/API and runtime-effect tests prove no
    private-input, mutation, ranking, learning, or external-action path exists
    from the corpus owner.
20. **AC-020 (REQ-020):** A representative bootstrap works offline, and real
    supported-device measurements record all named storage/performance/energy
    budgets; release remains unready until product thresholds are approved from
    that evidence.

## Canon impact

Implementation would require a bounded extension to the Source Atlas owning
specification for the production education corpus identity, source-family
authority matrix, release/semantic manifest, per-claim eligibility, identity
assertions, statistical and accreditation ceilings, public-only collection,
offline/reset behavior, and CTDL/CASE rights gates. The existing education
destination canon would reference these projections rather than duplicate
source semantics.

No constitution change is anticipated. This documentation does not edit canon;
implementation grooming will name the exact candidate canon files and require
the canon compiler/check at the authorized implementation stage.

## Risks and open decisions

### Decisions resolved by this Scope

- The first production geography is the United States.
- The first release uses CIP 2020 plus exact IPEDS, College Scorecard, and DAPIP
  releases; the semantic manifest must replace every “latest” with exact IDs.
- Source-native layers and explicit identity assertions replace a normalized
  universal program record.
- CTDL and CASE are reserved but rights-blocked until exact feed/framework
  access and content rights pass.
- Current offerings and deciding-authority facts remain a separate initiative.
- The corpus is unranked, read-only, public-only, and non-personal.
- Performance/storage thresholds wait for measured device evidence; the
  required measurements and release hold are not optional.

### Residual risks carried into Design and implementation

- Exact first-release IPEDS and Scorecard archive members/fields must be
  selected from documented releases without widening the product claim.
- Cross-source identity may remain incomplete; Design must prefer unresolved
  records over heuristic merge.
- Source corrections, closures, mergers, recognition actions, rights changes,
  and mixed survey clocks create downstream invalidation pressure.
- Full data may exceed practical bundled/on-device budgets; sharding and the
  bootstrap must preserve source semantics and honest coverage.
- Detailed source limitations can overwhelm users; accessible progressive
  disclosure must not hide material uncertainty.
- Government and voluntary-publisher coverage bias can narrow visible routes.
  Evaluation must report missingness and prohibit absence-as-quality.

Review verdict: **PASS** after one reconciliation round. Scope review found and
repaired an initially underspecified source allowlist by fixing the product
treatment for each source family and requiring the semantic manifest to name
exact IPEDS/Scorecard release IDs, archive members, fields, definitions, and
hashes before implementation. Every requirement has an observable acceptance
criterion; state, failure, recovery, correction, reset, accessibility, privacy,
authority, dependencies, and downstream handoffs are explicit without choosing
an implementation architecture.

Devan delegated approval authority for this documentation program. This Scope
was approved under that authority on 2026-08-04. Approval authorizes Design; it
does not authorize or claim source/canon changes, ingestion, runtime behavior,
recommendation use, merge, deployment, or release readiness.
