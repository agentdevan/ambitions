+++
initiative = "cross-taxonomy-relationship-authority"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions will maintain a versioned public Relationship Registry that connects
source-native concepts without merging them. A user or downstream system can
inspect who asserted a relationship, between which exact scheme releases,
which predicate/direction/method/quality state applies, what purpose Ambitions
permits, and what the relationship cannot establish.

The registry supports honest discovery and explanation across career,
education, credential, competency, and possibility sources. It never returns a
bare universal “equivalent,” transfers unrelated source claims through an edge
or chain, or establishes user Capability, qualification, credit, transfer,
licensure, acceptance, fit, success, or a required path.

This Scope defines mapping-set/edge identity, first-release source sets,
metadata, predicates, purpose eligibility, candidates/conflicts/no-match,
lifecycle, downstream invalidation, inspection, privacy, and evaluation.
Structural conformance or an official publisher is not proof that every use is
eligible.

## In scope

- Source-native concepts bound to exact source scheme and release identities.
- First-class mapping sets with source/publisher/curator, release/version,
  license, creator/reviewer, method, coverage, dates, schema, and QA partitions.
- Directional typed relationship families: within-scheme relation, scheme-
  version migration, official cross-scheme mapping, publisher-authored
  alignment, current-authority reference, and unapproved candidate.
- Exact source predicates including SKOS exact/close/broad/narrow/related and
  source-specific moved/deleted/report-under/split/merge/alignment/preparation
  predicates without flattening.
- A pinned SSSOM-compatible metadata subset plus preserved source-specific
  fields, justification, evidence, confidence/similarity where published,
  creator/reviewer, and review state.
- Ambitions consumer-use profiles separate from the source predicate:
  inspection, search expansion, destination discovery, explanation,
  version migration, and unavailable.
- Explicit forbidden propagation per edge, including qualification, credit,
  acceptance, user Capability, unrelated claim families, inverse and chain use.
- Candidate, approved, restricted, rejected, explicit no-match, conflicted,
  stale, superseded, withdrawn, and unavailable states.
- Exact initial source sets: CIP 2010–2020 version migration; CIP 2020–SOC 2018;
  O*NET-SOC 2019–SOC 2018. The O*NET–ESCO mapping is schema-supported but
  rights/release blocked until ESCO source/mapping review passes.
- CTDL/CASE publisher alignments as publisher-claim records only when exact
  source access/rights/version pass.
- Wikidata, lexical, embedding, and model outputs as review candidates only.
- Fixed public acquisition independent of users; release diff, validation,
  staged promotion, atomic snapshots, quarantine, LKG, rollback, invalidation,
  withdrawal, purge, offline, and coverage.
- Immutable typed read projections and accessible source/method/purpose/limit
  inspection.
- Dependency receipts binding downstream evidence to exact relationship and
  endpoint revisions so change can invalidate it.

## Out of scope

- A universal Ambitions taxonomy, merged concept graph, `sameAs` identity,
  automatic OWL/SKOS reasoning, transitive product inference, arbitrary graph
  traversal, or inferred inverse relations.
- Source concept ingestion/meaning; owned by production source corpora.
- Current admissions, transfer/articulation, regulator/licensure, employer,
  provider, program, opportunity, or receiving-authority decisions; owned by
  `current-opportunity-availability-intelligence`.
- User Capability/Proof creation, hidden trait/skill inference, personal
  transfer conclusions, correction learning, recommendation ranking, or
  personalization.
- Goal/destination/path/Step creation, schedule placement, simulation,
  canonical mutation, application, provider contact, or external action.
- Treating an official, human-reviewed, high-confidence, `exactMatch`, shared
  code, label similarity, or SSSOM-conformant row as universal equivalence.
- Letting mapping confidence become personal confidence, employability,
  provider/program quality, source quality, or likely success.
- Packaging ESCO or other mappings before exact content/mapping rights and
  endpoint source releases pass.
- Product source, canon, tests, project state, workflows, or lifecycle tooling
  changes during this documentation phase.

## Fixed first-release mapping sets

Design/implementation must bind exact file bytes, schemas, hashes, source terms,
and endpoint releases. New mapping sets or wider purpose profiles require
review against this Scope.

| Mapping set | Relationship family | Initial product eligibility | Mandatory non-claims |
|---|---|---|---|
| CIP 2010–2020 | scheme-version migration: unchanged/text-changed/new/deleted/moved-from/moved-to/report-under | inspection and exact historical-version migration only | not generic identity; not program availability; not competency/credit |
| CIP 2020–SOC 2018 | official many-to-many education-to-occupation relevance based on source descriptions | inspection, search expansion, destination discovery/explanation with direction and many-to-many limits | not degree requirement, qualification, licensure, employment, unique route, individual outcome |
| O*NET-SOC 2019–SOC 2018 | official taxonomy relationship | inspection, search expansion, source overlay join only at exact allowed granularity | not identity of detailed/aggregate/title-only records; no sibling inheritance; not current job |
| O*NET–ESCO | official AI-assisted/human-validated mapping with predicate/QA partitions | schema/inspection reservation; unavailable until exact endpoint releases and rights pass; related-match lower-QA partition remains restricted | not jurisdictional identity, qualification, skill/career/user equivalence |
| CTDL/CASE alignment | publisher-authored association to framework node | inspection/explanation only when source rights/version pass | not independent verification, mastery, credit, acceptance, Capability |
| Wikidata/lexical/model candidate | method-generated candidate | review/evaluation only | not consumer fact or authority |

`skos:exactMatch` may be stored as the source predicate and displayed with its
retrieval-oriented definition. Ambitions does not execute its formal
transitivity for product use. Every consumer request evaluates one explicit
edge and purpose profile.

## Requirements

### REQ-001 — Mapping-set identity and release binding

Every mapping set must have stable identity, publisher/curator, release/version,
source locator/bytes/hash, schema, license/rights, creator/reviewer, generation/
review date, method, coverage declaration, QA partitions, supersession, and
exact endpoint scheme releases. “Latest” and floating endpoint versions fail.

### REQ-002 — Endpoint concepts remain source-native

Every edge binds exact subject/object scheme IDs, scheme versions, concept IDs,
labels for inspection only, and endpoint lifecycle states. Labels/shared codes
cannot replace identifiers. A source concept change, split, merge, deprecation,
or deletion cannot silently retarget an edge.

### REQ-003 — Relationship family, predicate, and direction are explicit

Each edge must state relationship family, exact source predicate, direction,
source meaning, and product-readable explanation. Version migration,
hierarchy/association, cross-scheme mapping, publisher alignment, current-
authority decision, and candidate must remain distinct. Symmetry/inverse exists
only where the source predicate and product profile explicitly permit it.

### REQ-004 — Justification, evidence, method, and review survive ingestion

Each edge retains the pinned SSSOM-compatible/source-native metadata available
for justification, creator, reviewer, dates, confidence/similarity, tool/model,
evidence, QA partition, comments, and source row. Missing metadata remains
missing. Numeric confidence cannot substitute for validation or authority.

### REQ-005 — Source state and Ambitions review state remain separate

Official/publisher, maintainer-curated, human-reviewed, lexical/model, community,
rejected, and no-match provenance must be distinguishable. Ambitions review can
restrict/approve a purpose profile but cannot rewrite the source predicate or
claim that an external authority accepted the mapping.

### REQ-006 — Consumer-use profiles are narrower than source predicates

Every edge must declare eligible purposes from the fixed set and explicit
forbidden propagation. Consumers must request one purpose and receive only
eligible edges plus exact non-claims. An edge eligible for search expansion is
not automatically eligible for destination explanation, path requirements, or
version migration.

### REQ-007 — No automatic chain, transitive, inverse, or claim propagation

Ambitions must not derive consumer-eligible edges through chains, including
SKOS `exactMatch` transitivity, or propagate non-mapping claims across any edge.
Close/broad/narrow/related remain non-transitive. A directional edge cannot be
reversed unless a separately stored/permitted inverse exists. Chain exploration
may appear only as multiple inspectable source edges with no derived conclusion.

### REQ-008 — Version migration preserves source actions

Unchanged, text-changed, new, deleted, moved, split, merge, report-under, and
other publisher actions must retain exact semantics. Migration consumers may
move an identifier only where the source action/policy explicitly permits;
one-to-many/many-to-one or meaning-changed cases require ambiguity/review and
cannot become generic equivalence.

### REQ-009 — Conflicts, candidates, rejection, and no-match are first-class

Conflicting predicates/methods/versions for a pair must coexist with review
state and cannot be majority-voted into truth. Candidate mappings remain
ineligible. Rejected mappings remain auditable. `noMatch` is valid only when an
authoritative mapping set explicitly reviewed the endpoint within declared
coverage; absence remains unmapped/unknown.

### REQ-010 — Rights and attribution are mapping-set and source specific

Packaging, transformation, display, retention, and derivation require exact
mapping-set and endpoint rights. Attribution/changes/trademark limits survive.
A standard/schema license cannot authorize source mapping content. Rights
failure isolates affected sets/rows and withdrawal triggers exact invalidation/
purge without widening another edge.

### REQ-011 — Public acquisition is independent of users

Remote acquisition may request only fixed mapping-set/source release IDs.
User/device ID, ambition, Goal, Capability, Proof, education history, schedule,
location, recommendation, correction, selection, or rejection cannot influence
requests, parameters, keys, artifacts, caches, logs, diagnostics, analytics, or
source feedback.

### REQ-012 — Freshness and source/mapping change are independent

Mapping set and both endpoint scheme releases retain separate clocks. Source
concept, method/QA, review, license, or mapping changes produce explicit diffs.
An endpoint newer than the mapping's declared version makes the affected edge
stale/ineligible for version-sensitive uses until reviewed; it does not float.

### REQ-013 — Staging, validation, promotion, rollback, and purge

Candidates must pass byte/schema/signature/size, exact set/endpoint releases,
predicate/integrity/direction, source counts/coverage, rights/attribution,
method/review, conflict, purpose-profile, evaluation, and device gates before
atomic promotion. Failure quarantines and preserves LKG. Lifecycle actions are
idempotent/replay-safe; withdrawal purge removes prohibited raw/derived/index/
render/cache/export bytes.

### REQ-014 — Downstream dependencies bind and invalidate exactly

Every recommendation, generated proposal, evaluation result, or other
downstream evidence using an edge must record registry snapshot, mapping set/
edge revision, endpoint concept/release, purpose profile, and used direction.
Change/withdrawal invalidates only affected dependencies before reuse; it never
silently rewrites accepted canonical history or automatically issues mutation.

### REQ-015 — Offline, reset, correction, and deletion behavior

Bundled/LKG eligible relationships remain inspectable offline with actual age.
Never-fetched/blocked is unavailable, not no-match. Corrections create immutable
supersession and invalidate dependencies. Users may clear downloaded public
registry data/reset to bootstrap without changing private objects. Mandatory
purge resumes after interruption.

### REQ-016 — Accessible relationship inspection

Users/evaluators can inspect subject/object schemes/concepts/releases, mapping
set/publisher, relationship family/predicate/direction, plain meaning,
justification/method/QA/review/confidence, purpose eligibility, forbidden
propagation, conflicts, freshness, rights, evidence, dependencies, and non-
claims with accessible progressive disclosure.

### REQ-017 — Mapping evaluation and coverage

Each release publishes exact set/edge/endpoint/predicate/method/QA/review/
purpose/conflict/unmapped/no-match/stale/rights coverage. Evaluation must test
gold mapping adjudication, predicate correctness, chain/inverse/claim leakage,
precision/recall where ground truth exists, conflict, version drift, privacy,
bias/dignity, accessibility, comprehension, correction, offline, and regression.
Aggregate metrics cannot waive a hard false-equivalence failure.

### REQ-018 — Read-only typed consumer boundary

Consumers receive immutable purpose-eligible edges/limits/dependency bindings
from an exact snapshot. The registry accepts no private state and exposes no
recommendation, model-candidate approval, Capability/Proof, Goal/Path/Step,
schedule, canonical mutation, current-authority adjudication, or external-
action API.

## Acceptance criteria

1. **AC-001 (REQ-001):** Floating/mismatched set or endpoint releases, unknown
   schema, missing rights/method/coverage, or reused set ID fail promotion.
2. **AC-002 (REQ-002):** Changed/split/merged/deprecated/deleted endpoint
   fixtures retain source states and cannot retarget by label/shared code.
3. **AC-003 (REQ-003):** Every fixed family/predicate/direction round-trips;
   generic `equivalent` input and unapproved inverse fail validation.
4. **AC-004 (REQ-004):** SSSOM/source metadata survives Python/Swift parity;
   absent evidence stays absent and confidence cannot enable an edge.
5. **AC-005 (REQ-005):** Official, publisher, human, lexical/model, community,
   rejected and no-match fixtures remain distinguishable from product review.
6. **AC-006 (REQ-006):** Search-only, explanation, version-migration,
   inspection-only and unavailable fixtures return different exact projections;
   no purpose widening occurs.
7. **AC-007 (REQ-007):** Exact/close/broad/narrow/related chains, cycles,
   inverse and unrelated source claims produce no derived consumer edge/claim.
8. **AC-008 (REQ-008):** CIP unchanged/text-change/new/deleted/moved/report-under
   and split/merge fixtures produce their exact migration outcomes, with
   ambiguity instead of generic equivalence.
9. **AC-009 (REQ-009):** Conflicting/candidate/rejected/explicit-no-match/
   unmapped fixtures retain distinct states and never resolve by vote/absence.
10. **AC-010 (REQ-010):** Set/source rights failure isolates affected edges;
    standard/schema license does not authorize content; withdrawal purges the
    complete affected footprint.
11. **AC-011 (REQ-011):** All named private canaries produce byte-identical
    public requests, artifacts, keys, logs, diagnostics, and refresh behavior.
12. **AC-012 (REQ-012):** Independent endpoint/mapping clocks and changes
    produce exact aging/stale/invalidation without floating to new concepts.
13. **AC-013 (REQ-013):** Every hard failure quarantines; repeated/interrupted
    lifecycle operations replay identically and LKG remains consistent.
14. **AC-014 (REQ-014):** Dependency fixtures bind exact revisions/purpose/
    direction; source/mapping changes invalidate only affected evidence and
    issue no canonical/external mutation.
15. **AC-015 (REQ-015):** Offline/never-fetched/reset/correction/supersession/
    invalidation/purge preserve exact state and do not mutate private data.
16. **AC-016 (REQ-016):** Inspection exposes every named relationship fact and
    limit with VoiceOver, Dynamic Type, non-color, stable focus, Reduced Motion,
    and accessible chain/conflict alternatives.
17. **AC-017 (REQ-017):** Coverage reconciles exact denominators/exclusions and
    all hard false-equivalence/privacy/dignity/accessibility gates pass.
18. **AC-018 (REQ-018):** Compile-time/runtime tests prove no private-input,
    inference-approval, recommendation, mutation, current-authority, or
    external-action path exists.

## Canon impact

Implementation would extend Source Atlas and source-reference canon with the
Relationship Registry owner, relationship families, mapping-set/edge identity,
purpose profiles, no-transitive/claim-propagation law, conflicts/no-match,
dependency invalidation, offline/reset/purge and inspection. Career, education,
possibility, Capability, and generation owners reference the typed projection;
they do not duplicate mapping semantics.

No constitution change is anticipated. This documentation does not edit canon;
implementation grooming will name exact existing owners and canon validation.

## Risks and open decisions

### Decisions resolved by this Scope

- Source concepts are never merged.
- Source predicate and product-use profile remain separate.
- No automatic chain/transitive/inverse or unrelated claim propagation.
- First source sets and their purpose ceilings are fixed.
- Version migration is distinct from cross-scheme relevance/alignment.
- Candidate/rejected/no-match/conflict states are first-class.
- All downstream use binds exact edge/endpoint revisions.
- Registry is public-only, read-only, non-personal, and mutation-free.

### Residual implementation risks

- Official source files may omit metadata desired by the pinned SSSOM subset;
  missing values must remain explicit rather than fabricated.
- Crosswalk source rights and endpoint corpus rights may differ.
- Mapping graphs and dependency indices may challenge device budgets.
- “Exact” terminology can still confuse; plain-language inspection and direct-
  user comprehension evidence are mandatory.
- Bias against informal/cultural capabilities cannot be solved by more mappings
  alone; coverage reporting must not imply low value.

Review verdict: **PASS** after one reconciliation round. Review identified the
formal transitivity of SKOS `exactMatch` as incompatible with silent product
inference; Scope now explicitly preserves the source predicate while forbidding
derived product edges and unrelated claim propagation. Every requirement maps
to an observable acceptance criterion and all authority, state, failure,
recovery, correction, deletion, privacy, accessibility, dependency, and
downstream boundaries are explicit.

Devan delegated approval authority for this documentation program. This Scope
was approved under that authority on 2026-08-04. Approval authorizes Design; it
does not authorize or claim source/canon changes, runtime behavior, merge,
deployment, or release readiness.
