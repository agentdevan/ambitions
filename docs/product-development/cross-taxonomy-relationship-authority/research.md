+++
initiative = "cross-taxonomy-relationship-authority"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions' eventual intelligence platform must connect career occupations,
education fields, credentials, competencies, skills, hobbies, providers, and
user-approved Capabilities. Without explicit relationships, destination and
path generation cannot explain why prior progress might transfer or why a
learning route might be relevant. With overly broad relationships, however,
the platform can create some of its most harmful false claims:

- related occupations become identical or a promotion ladder;
- a CIP-to-SOC mapping becomes “this degree qualifies you for this job”;
- curriculum overlap becomes transfer credit or credential equivalence;
- a provider-authored competency alignment becomes proof of mastery;
- a lexical/model match becomes source authority;
- O*NET and ESCO concepts collapse despite different taxonomies,
  jurisdictions, granularity, and release clocks; or
- a public skill mapping becomes a hidden conclusion about the user.

The product problem is not to build one knowledge graph. It is to preserve each
relationship as an inspectable, versioned claim with an owner, direction,
predicate, justification, evidence, scope, confidence/review state, consumer-
purpose ceiling, and lifecycle. Absence or rejection must leave concepts
separate. Relationships may support discovery and explanation; only the exact
authority that owns a consequential decision can establish acceptance,
qualification, credit, licensure, eligibility, or user capability.

The user value is safer continuity. Ambitions can say “these concepts are
related in this published mapping, for this purpose and release” or “this prior
progress may be worth inspecting,” while showing what does not transfer. It
cannot silently promise that progress counts in another taxonomy, institution,
profession, or person's life.

This initiative owns public relationship authority and product eligibility
across source schemes. It does not own the source concepts themselves, private
Capability inference, current receiving-authority decisions, recommendation
ranking, generated paths, canonical mutation, or external actions.

## Current truth

Research was performed against `main` at
`8154e17e004e15cfff9a388092dea3d1a12d5d35` on 2026-08-04. Canon, live Source
Atlas foundry/runtime source and tests, approved v1/future corpus documentation,
and primary external standards/sources were inspected. Approved documents are
plans, not evidence that runtime crosswalk behavior has shipped. Tests were
inspected, not executed.

### Governing canon and v1 authority

- The public-reference foundation already requires crosswalks to be first-
  class versioned claims carrying publisher/curator, relationship kind,
  subject/object versions, review/confidence, limitations, and no identity
  merge. Rejecting or removing a crosswalk leaves concepts separate.
- Source Atlas may carry public relationships, but private Goals, Capability/
  Proof, education history, location, recommendation context, selections, and
  corrections cannot shape remote acquisition or enter public artifacts.
- Models/sources may propose. Existing typed owners validate and own accepted
  mutations. A relationship cannot write a Goal, Path, Capability, Proof,
  credential, education credit, or Life Context fact.
- Career, education, and possibility corpora preserve source-native concepts.
  Their docs explicitly hand cross-source relationship claims to this owner.
- Capability continuity explicitly excludes public taxonomy ingestion,
  crosswalking, and equivalency. User-approved Capability relationships remain
  private and cannot be exported into this public graph.
- Education destination and credential import documents already distinguish
  classification/alignment from mastery, credit, transfer, accreditation,
  licensure, employment, and acceptance.

### Live source and test seams

- `public-reference-knowledge-foundation` Design defines a versioned crosswalk
  record and inspect-without-equivalence flow but intentionally ships no ESCO
  or broader production mapping.
- `tools/source-atlas/foundry/adapters.py` and related registries contain a
  Wikidata structured-entity crosswalk adapter. The live policy marks it
  crosswalk-only and rejects regulated-authority use. The adapter emits generic
  candidate records; it is not a production mapping adjudicator.
- The broad occupational foundry can collect crosswalk arrays, and existing
  audits block crosswalk-only sources from regulated claims. This is a useful
  negative boundary, not proof that relationship meaning, versioning,
  transitivity, conflict, or downstream eligibility is correct.
- No live domain owner was found for mapping-set lifecycle, source-vs-curated
  relationship distinction, SSSOM-like metadata, crosswalk conflict, split/
  merge/version migration, consumer-purpose eligibility, or invalidation of
  dependent proposals when a mapping changes.

## Evidence

All external sources below were accessed on 2026-08-04.

### SKOS mapping semantics

The W3C [SKOS Reference](https://www.w3.org/TR/skos-reference/) defines five
cross-scheme mapping predicates:

- `exactMatch`: high confidence that concepts can be used interchangeably in a
  wide range of information-retrieval applications;
- `closeMatch`: sufficiently similar for some information-retrieval uses;
- `broadMatch` and `narrowMatch`: directional hierarchical mappings; and
- `relatedMatch`: an associative mapping.

Important formal behavior is easy to misuse:

- `exactMatch`, `closeMatch`, and `relatedMatch` are symmetric;
- only `exactMatch` is transitive;
- `closeMatch`, broad/narrow, and related are not transitive;
- `exactMatch` is disjoint with broad/narrow and related for the same pair; and
- SKOS permits some cycles/alternate paths that an application must handle.

SKOS describes concept-scheme mapping, primarily for knowledge organization and
retrieval. It does not establish legal equivalence, transfer credit,
qualification, mastery, provider acceptance, or identity of all source claims.
Even a formally transitive `exactMatch` must not cause Ambitions to transfer a
non-mapping claim or skip product review across a chain. Ambitions can preserve
the source predicate while refusing derived transitive product eligibility.

### Mapping metadata and provenance

The Mapping Commons [SSSOM](https://mapping-commons.github.io/sssom/dev/)
standard represents a mapping as subject, predicate, object plus metadata such
as mapping justification, author/creator, confidence, and mapping-set metadata.
Its primary TSV serialization binds one mapping set with a metadata block and
mapping rows. The project published 1.0.0 in 2024 and continues to evolve.

SSSOM demonstrates the minimum shape needed for exchange and evaluation:

- scheme/entity identifiers and versions;
- mapping predicate and direction;
- mapping justification/method;
- creator/reviewer and date;
- confidence or similarity when present;
- mapping-set version/license; and
- provenance/evidence.

SSSOM conformance does not make a mapping correct. A lexical/model-generated
`exactMatch` row remains a method output until the responsible mapping owner
validates it for a declared purpose. Ambitions should use a pinned, compatible
metadata subset and preserve extra source fields rather than allowing SSSOM or
OWL inference to broaden product meaning.

### Official occupational mappings

- The O*NET Resource Center's current
  [crosswalk page](https://www.onetcenter.org/crosswalks.html) publishes
  separate mappings to BLS OOH, SOC 2018, and ESCO. Those files have different
  creators and purposes.
- The O*NET-SOC 2019-to-SOC 2018 mapping represents the relationship between an
  O*NET extension and its underlying federal classification. Title-only,
  detailed, aggregate, military, and `all other` records prevent naive one-to-
  one identity.
- The European Commission's official
  [O*NET–ESCO crosswalk](https://esco.ec.europa.eu/en/use-esco/other-crosswalks)
  uses exact, narrow, broad, close, and optional related mappings. The
  methodology combined AI suggestions with human validation. ESCO notes that
  related matches in the expanded file were not included in the same quality-
  assurance/U.S. DOL validation and should be treated as lower quality.
- ESCO v1.2.1 and O*NET 30.3 now have source releases later than the original
  2022 report/table context. A mapping set is therefore bound to its actual
  subject/object scheme versions and cannot silently float to current source
  releases.

An official mapping improves provenance; it does not make source concepts
identical in jurisdiction, language, granularity, descriptors, regulation, or
downstream claims. Product use must bind the exact mapping file, source scheme
versions, predicate, QA class, and consumer purpose.

### Education and occupation mappings

- NCES's [CIP 2010–2020 crosswalk](https://nces.ed.gov/IPEDS/cipcode/crosswalk.aspx?y=56)
  distinguishes no substantive change, new, deleted, moved-from/moved-to, text
  change, and report-under relationships. These are version-migration actions,
  not one generic equivalence.
- The official [CIP–SOC FAQ](https://nces.ed.gov/IPEDS/CIPCODE/FAQ.aspx?y=56)
  says the joint NCES/BLS 2020 CIP–SOC crosswalk matches six-digit codes based
  on descriptions and the principle that the academic program provides skills
  and knowledge required for an occupation. Many-to-many mappings remain
  possible. This supports field-to-occupation exploration, not a promise that
  one program admits, qualifies, licenses, or employs an individual, or that an
  occupation requires that field.

CIP edition migration and CIP-to-SOC relevance are materially different
relationship families. They cannot share one `equivalent` predicate.

### Provider/framework alignments

- Credential Engine's CTDL defines a `CredentialAlignmentObject` as an
  affiliation/association between a credential, learning opportunity, or
  assessment and a node in a structured framework. It can carry framework,
  target node/name/description, notation, alignment type/date, and weight.
- CTDL also defines exact/broad/narrow and other relations, plus preparation,
  requirement, recommendation, and transfer-value structures. These are
  publisher-authored data whose authority depends on who published the record
  and the target authority.
- 1EdTech CASE supports framework items and associations, but a CASE association
  is a source relationship, not automatically a product equivalence, mastery,
  credit, or acceptance decision.

A provider can authoritatively state its own intended curriculum alignment. It
cannot unilaterally decide another institution's transfer credit, an employer's
acceptance, a regulator's gate, or the user's mastery. Ambitions must expose the
publisher and relationship type rather than relabeling all alignments as
verified skills.

### Relationship-family authority matrix

| Relationship family | Owner/meaning | Permitted product use | Forbidden promotion |
|---|---|---|---|
| within-scheme hierarchy/association | source scheme | browse/source-native reasoning within exact release | cross-scheme identity, user progression |
| scheme-version migration | scheme publisher | preserve historical identity; exact moved/split/merged/deleted/report-under action | silent rewrite, generic exact equivalence |
| official cross-scheme mapping | mapping-set publisher/curators | source-declared retrieval/discovery purpose with exact predicate/versions/QA | transfer of unrelated claims, qualification, personal fit |
| publisher-authored alignment | provider/framework publisher | explain publisher's declared association | mastery, credit, independent endorsement, receiving-authority acceptance |
| lexical/model mapping candidate | method/operator | review queue and evaluation only | consumer eligibility before human/authority validation |
| receiving-authority articulation/acceptance | receiving institution/regulator/employer | exact current decision within scope | universal portability or taxonomy equivalence |
| private capability-transfer hypothesis | local Planning/user correction owner | future local proposal with explicit consent/evidence | public corpus write, hidden user trait, automatic Capability |

### Completed mapping-shape pilot

Research completed a no-redistribution pilot over five mapping cases:

1. **CIP edition migration:** one old code may be unchanged, moved, deleted, or
   report under one/more new codes. Each action retains both editions and cannot
   be reduced to `sameAs`.
2. **CIP–SOC:** a many-to-many relevance mapping can support exploration while
   preserving the non-claims “not degree requirement,” “not qualification,” and
   “not individual outcome.”
3. **O*NET-SOC–SOC:** a detailed O*NET occupation can map to a broader SOC
   identity without inheriting detailed data to every sibling or making the
   records identical.
4. **O*NET–ESCO:** exact/close/broad/narrow/related rows retain source scheme
   versions and QA class. Lower-QA related mappings are not consumer-eligible
   merely because they ship in an official expanded file.
5. **CTDL/CASE alignment:** a provider-authored mapping can remain inspectable
   while mastery, credit, transfer, acceptance, and capability remain unknown.

The pilot requires source mapping predicate plus an Ambitions
`consumerUseProfile`. One predicate cannot decide every use. A mapping may be
eligible for search expansion but ineligible for recommendation explanation,
path prerequisite transfer, or current authority.

### Conflict, chain, and negative evidence

The relationship layer must preserve:

- conflicting predicates for the same versioned pair;
- one-way directional relationships;
- mapping-set supersession and withdrawal;
- source concept deprecation/merge/split;
- unmapped concepts and explicit reviewed `noMatch` decisions;
- mapping candidates rejected by review;
- exact/close chains without automatic product inference;
- multiple mapping paths with different predicates/methods; and
- downstream evidence bound to exact relationship revisions.

Absence is not proof of no relation unless an authoritative mapping set records
an explicit reviewed no-match within its declared coverage. Likewise, a single
mapping does not authorize inverse meaning when the predicate is directional.

### Privacy, bias, and sensitive inference

- Public mapping acquisition is fixed by mapping-set/source releases, never a
  user's ambition or private capabilities.
- Mapping coverage and granularity reflect institutional priorities, language,
  jurisdiction, historical data, and labor/education bias. Unmapped or weakly
  mapped progress must not be treated as worthless.
- Crosswalks can privilege formalized careers/credentials over informal,
  community, cultural, caregiving, or lived capabilities.
- A mapping from an occupation/program to a skill cannot be reversed into “the
  user has this skill.” User capability requires its private evidence owner.
- Confidence scores must not become user confidence, employability, success,
  provider quality, or value rankings.
- Reviewer disagreements and rejected mappings need dignity-safe presentation
  and correction, not hidden deletion or a generic truth score.

## Alternatives

### 1. Merge concepts into one canonical Ambitions taxonomy

This simplifies query and generation but erases source releases, jurisdiction,
granularity, and authority, and makes correction/withdrawal nearly impossible.
Rejected.

### 2. Store SKOS/OWL and allow standards-defined inference

This is interoperable, but `exactMatch` transitivity and ontology reasoning can
derive product relationships that were never reviewed for Ambitions purposes.
Store source semantics; do not grant inference engine output product authority.

### 3. Accept only official exact mappings

This minimizes ambiguity but loses useful broad/narrow/close/related discovery,
version migration, and provider alignments. Exact mappings also do not justify
non-retrieval claims. Too blunt.

### 4. Generate mappings with embeddings/models at query time

This improves recall and adapts quickly, but private intent may leak, results
are hard to reproduce, and lexical/semantic similarity can masquerade as
authority. Model candidates may feed an offline review/evaluation queue; they
cannot be direct consumer facts.

### 5. Build a versioned relationship-claim registry with purpose eligibility

Preserve source predicates and mapping-set metadata, add explicit product use
profiles, block transitive claim transfer, keep candidates/conflicts/no-match,
and invalidate downstream evidence on change. This is recommended.

## Unknowns and risks

### Resolved product decisions

- Concepts remain source-native and are never merged into a universal graph.
- Every relationship is a versioned claim inside a mapping set with exact
  subject/object scheme versions.
- Source predicates are retained; Ambitions adds a narrower consumer-purpose
  eligibility profile instead of rewriting the predicate.
- No automatic transitive product inference, including through
  `skos:exactMatch` chains.
- Version migration, hierarchy, cross-scheme mapping, provider alignment,
  current acceptance, and private capability hypotheses are separate families.
- Lexical/model/community mappings are candidates until explicitly validated;
  confidence alone cannot enable them.
- Public mappings never establish user Capability, credit, qualification,
  licensure, acceptance, or fit.
- Current receiving-authority decisions remain in the current-availability
  owner; private transfer proposals remain local.

### Material risks

- **Predicate overclaim:** users/developers may read “exact” as universal
  identity rather than source-declared retrieval equivalence.
- **Compound error:** chains across several schemes can amplify small semantic
  differences even when each edge appears plausible.
- **Version drift:** a mapping remains installed while one or both concept
  schemes change, split, merge, or deprecate records.
- **Method opacity:** official mappings can mix AI suggestions, human review,
  lexical methods, and differing QA partitions.
- **Many-to-many confusion:** a user may interpret one CIP–SOC edge as a unique
  route or hard education requirement.
- **Publisher conflict:** provider-authored alignments may disagree with
  framework owners, receivers, or other mappings.
- **Coverage/bias:** formal taxonomies omit informal and culturally specific
  capabilities; mapping density can become an unjust proxy for value.
- **Graph performance:** versioned multi-edge queries, conflicts, and dependency
  invalidation can be expensive on device.
- **Downstream stale use:** generated proposals can outlive a mapping/source
  release unless exact bindings are invalidated.

### Dependencies

- Production career, education, and possibility corpora supply immutable
  source-native concept projections; this owner does not ingest their facts.
- The public-reference foundation supplies claim envelopes, rights/freshness/
  conflict, inspection, offline, public-only and lifecycle contracts.
- Intelligence evaluation supplies mapping precision/recall, predicate,
  conflict, bias/dignity, privacy, regression and comprehension gates.
- Current opportunity/availability owns live articulation, acceptance,
  provider, regulator, employer and other deciding-authority relationships.
- Personal context/capability transfer owners later consume public mappings
  locally and preserve user correction/consent.
- Generative destination/path owners may use only exact purpose-eligible
  relationships and must cite relationship revisions.
- Change management later coordinates source/mapping/model/policy promotion and
  impact; this owner still owns mapping semantic lifecycle.

### Evidence required before Scope

Research has enough evidence to Scope a relationship registry if Scope requires:

1. source-native concepts and exact scheme/release bindings;
2. separate relationship families and direction;
3. mapping-set metadata compatible with a pinned SSSOM subset plus preserved
   source-specific fields;
4. exact source predicate and product consumer-use profile;
5. no automatic transitive/inverse/product claim transfer;
6. candidates, rejected/no-match, conflicts, supersession, withdrawal, and
   source concept change;
7. purpose eligibility and explicit non-claims for qualification, credit,
   transfer, acceptance, user Capability, fit, and prediction;
8. fixed public acquisition, rights/attribution, atomic promotion/LKG/
   invalidation/offline/purge and read-only consumers;
9. downstream dependency binding and invalidation; and
10. evaluation across official, provider, model/lexical, many-to-many,
    broad/narrow/close/related, chain, conflict, unmapped and biased cases.

No v1 runtime/user evidence is required to define public mapping semantics.
Personal capability-transfer usefulness and generated-path usefulness require
their own direct-user evidence later.

## Recommended direction

Scope a local, source-native `Relationship Registry` whose records include:

- mapping set/source, release, license, creator/publisher, method, QA partition,
  review date and coverage;
- subject/object source scheme, version and concept IDs;
- exact source predicate/direction, justification, evidence, confidence where
  source-published, reviewer and state;
- relationship family and Ambitions consumer-use profile;
- explicit non-claims and forbidden propagation;
- current/aging/stale/conflicted/superseded/withdrawn/rejected/no-match/
  candidate states;
- downstream evidence dependencies and invalidation; and
- accessible source/predicate/method/version/limitation inspection.

First production mapping sets should be exact source-published releases already
required by the approved corpora: CIP 2010–2020 migration, CIP 2020–SOC 2018,
O*NET-SOC 2019–SOC 2018, and the official O*NET–ESCO mapping only after ESCO
content/mapping rights and exact scheme-version review pass. CTDL/CASE
alignments remain publisher-authored records admitted per exact source rights;
Wikidata/lexical/model mappings remain candidate/review-only unless separately
validated.

The registry never returns a bare “equivalent.” It returns a typed relationship
projection with purpose eligibility and limits. Downstream consumers cannot
traverse an edge or chain outside the exact use profile.

### Five compounding ruthless review passes

1. **Completeness and unsupported assumptions:** added formal SKOS behavior,
   pinned SSSOM-style metadata, official O*NET–ESCO QA distinctions, CIP
   migration/CIP–SOC semantics, CTDL/CASE publisher alignments, conflicts,
   explicit no-match and downstream invalidation.
2. **Connections, duplication, and missing owners:** separated source concepts,
   mapping registry, current receiver decisions, private capability transfer,
   recommendation/generation, evaluation and change management.
3. **Privacy, authority, failure, deletion, and external effects:** prohibited
   private acquisition and user-capability reversal; added candidate/rejected/
   conflict/stale/withdrawn/purge/offline states, no mutation and no external
   effect.
4. **Feasibility against live architecture:** grounded the design direction in
   existing crosswalk claim shapes, Wikidata crosswalk-only guards, foundry
   arrays, Source Atlas lifecycle/inspection/privacy seams and corpus releases;
   identified missing registry/query/invalidation proof.
5. **Product coherence and long-term fidelity:** preserved useful discovery and
   option-transfer connections without a universal taxonomy, inference graph,
   qualification oracle or user score; made exact-purpose claim ceilings the
   permanent platform boundary.

Review verdict: **PASS**. The Research completes the semantic-standard,
source/method, version, authority, privacy, bias, conflict, lifecycle,
architecture, dependency and product-use investigation needed for Scope. It
does not claim mappings have shipped or that any relationship proves personal
transfer, qualification, credit, acceptance or release readiness.

Devan delegated approval authority for this documentation program. This
Research was approved under that authority on 2026-08-04. Approval authorizes a
bounded Scope; it does not authorize or claim source/canon changes, ingestion,
runtime behavior, merge, deployment or release readiness.
