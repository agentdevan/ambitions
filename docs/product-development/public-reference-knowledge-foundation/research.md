+++
initiative = "public-reference-knowledge-foundation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions cannot responsibly recommend a new career, education route, or hobby
from private capability evidence alone. It also needs current public knowledge:
what a destination is, which capabilities commonly relate to it, which
requirements are hard gates, where alternatives exist, who has authority to
make each claim, and when the claim was last checked.

The user problem is not simply missing search results. Public facts that look
similar can have materially different authority:

- an occupation taxonomy can describe typical work but cannot decide whether a
  particular person is employable;
- national labor statistics can describe a market but cannot establish a local
  employer's requirements;
- a field-of-study code can classify a program but cannot prove that a school
  offers it or that credits will transfer;
- a competency framework can name a learning outcome but cannot prove that a
  specific course teaches it;
- an association can publish rules or safety standards for one activity while
  a provider or community guide may only describe one way to learn it.

Without a shared foundation, each future recommendation domain would have to
invent its own source identities, provenance, freshness, jurisdiction,
crosswalk, attribution, withdrawal, and offline behavior. That duplication
would make explanations inconsistent and could allow stale or low-authority
claims to become apparently personal advice.

This Research examines a bounded public-reference knowledge foundation shared
by later career-, education-, and hobby-destination work. It is not a decision
to build one universal ontology, authorize production ingestion, or define a
recommendation surface. It does nominate a deliberately narrow first corpus for
validating source inspection and offline behavior. It does not decide how
private capabilities will be matched to public facts. The foundation's job is
to preserve public meaning and authority so later local planning can make an
honest, inspectable match.

## Current truth

This Research inspected `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, the umbrella portfolio synthesis at
`docs/product-development/adaptive-skills-and-pathways/research.md`, current
canon, relevant Source Atlas source, tests, resources, and retained QA
artifacts. The umbrella synthesis has been reopened as a draft so its domains
can be decomposed and researched independently; it is not current approval
authority for this initiative. External sources were reviewed on 2026-08-03.
Repository tests were inspected, not executed, for this Research.

Canon already fixes the most important boundary:

- `LAW-R2-PUBLIC-ONLY-001` and `SYSTEM-SOURCE-ATLAS-PUBLIC-001` allow Source
  Atlas and R2 to carry approved public references, provenance, freshness, and
  non-sensitive access state. They forbid private Goals, Proof, schedules,
  behavior, recommendation context, or the private graph from entering those
  systems.
- `SYSTEM-SOURCE-ATLAS-FIREWALL-001` requires a finite allowlisted artifact
  namespace. A free-form private intent cannot become a remote query, cache
  key, log value, or feedback payload.
- Local Planning may combine a verified public corpus with private context only
  on device. It must preserve the source, freshness, uncertainty, correction,
  rejection, and unavailable fallback.
- `LAW-OFFLINE-NO-ACCOUNT-001` requires public-reference failure to degrade an
  optional feature rather than block the local core.
- `CONST-PROOF-EVIDENCE-001` and the Source Reference contract distinguish
  public source evidence from user Proof and system Receipts. A cited
  occupational or educational claim does not prove anything about the user.

The implementation contains a substantial structural foundation:

- `SourceAtlasPackModels.swift` distinguishes official, semi-official, expert,
  community, maintainer-curated, user-provided, candidate, and unknown source
  states, plus freshness and domain risk classes.
- `SourceAtlasPack`, `SourceAtlasDomainPack`, `SourceAtlasSpecificDomainPack`,
  capability graphs, requirements, role/path overlays, proof maps, source
  records, projection recipes, and composition contracts can preserve a graph
  with provenance and bounded runtime eligibility.
- Manifest, signature, hash, schema, cache, quarantine, last-known-good,
  rollback, public-only boundary, and optional remote-refresh code already
  exist under `Core/LocalRuntimeOS/SourceAtlas/`.
- `SourceAtlasPublicOnlyBoundaryGateTests` exercises rejection of private
  runtime markers in endpoints, headers, request shapes, and projections.
  `SourceAtlasOfflineNoAccountScenarioTests` exercises bundled fallback and
  honest reference unavailability without blocking core surfaces.
- `SourceAtlasCapabilityPathCompositionModelsTests` shows deterministic
  composition and provenance traces for synthetic fixtures. Those fixtures
  demonstrate model behavior; they do not validate real-world destination
  coverage or recommendation quality.

One current seam conflicts with the governing boundary and is not reusable as
placed. `SourceAtlasCapabilityPathComposer`, under
`Core/LocalRuntimeOS/SourceAtlas/`, accepts private `goalID`,
`LifeContextRuntimeProjection`, and local influence signals while choosing a
path. Source Atlas canon limits that owner to public delivery; local
`Planning/` owns the private join. This is nonconforming source evidence. A
future design must isolate the public composition input from private context or
transfer private matching to Planning. The current directory and API are not
architectural authority for any dependent initiative.

The repository also contains configured public packs, but their current proof
ceiling is narrow. The retained production sweep reports 26 packable claims for
`occupation_foundation`, eight for `education_credentialing`, and three for
`hobbies_recreation`. Inspection shows occupation fixtures around O*NET and
BLS, education fixtures around College Scorecard and one institutional
curriculum, and hobby fixtures around general National Park Service health and
safety references. The sweep itself says it is not a new harvest, universal
coverage, a final user path, or runtime recommendation proof. These artifacts
prove delivery mechanics and a small public frontier, not a populated shared
destination knowledge base.

No current contract was found that fully resolves:

- durable external concept identity across source releases and crosswalks;
- claim-level authority by predicate rather than by source reputation alone;
- jurisdiction and locale applicability;
- distinction among taxonomy, descriptive evidence, hard-gate authority,
  provider availability, and personal recommendation use;
- lossless mapping among occupation, skill, competency, program, credential,
  activity, milestone, and resource concepts;
- source-specific attribution and redistribution obligations;
- conflict precedence when two valid authorities disagree; or
- a calibrated coverage and quality bar for declaring a destination domain
  usable rather than merely packable.

## Evidence

### Repository and canon evidence

- `docs/canon/specifications/systems/source-atlas.md` defines verified public
  artifact delivery and the no-private-graph firewall. It deliberately leaves
  private matching to local Planning.
- `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPackModels.swift`
  contains the authority, freshness, risk, and validation vocabulary needed to
  represent heterogeneous public evidence.
- `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
  allowlists `occupation_foundation`, `education_credentialing`, and
  `hobbies_recreation`, but explicitly says those targets are not universal
  coverage or final planning.
- `docs/qa/source-atlas/source-atlas-production-sweep-train-131.md` reports a
  green configured-frontier delivery sweep while preserving an overall Source
  Atlas Yellow ceiling. Delivery readiness is therefore distinct from domain
  completeness.
- The reviewed public-only, cache, fallback, capability composition, query, and
  inspection tests show reusable mechanics. Their synthetic source labels and
  bounded fixture graphs cannot establish semantic accuracy in a real domain.

### External authority evidence

All external links below were accessed on 2026-08-03.

- The [O*NET 30.3 database](https://www.onetcenter.org/database.html) publishes
  downloadable and API-accessible United States occupation data under a
  versioned release, including skills, knowledge, abilities, education,
  experience, work activities, tasks, work context, and market-related data.
  O*NET says its database is updated quarterly. That makes release identity and
  source attribution first-class freshness facts, not incidental metadata.
- The [O*NET Content Model](https://www.onetcenter.org/content.html) separates
  worker characteristics, worker requirements, experience requirements,
  occupational requirements, occupation-specific information, and market
  characteristics. A shared foundation must preserve those distinctions; for
  example, a work style is not interchangeable with an acquired capability.
- The [BLS Occupational Outlook Handbook information guide](https://www.bls.gov/ooh/About/Occupational-Information-Included-in-the-OOH.htm)
  describes typical duties, work environment, entry education, related work
  experience, training, pay, outlook, and similar occupations. The
  [BLS disclaimer](https://www.bls.gov/ooh/about/disclaimer.htm) says the
  handbook is a national composite, not a local establishment description,
  qualification decision, or legal standard. Authority is therefore
  predicate- and jurisdiction-specific.
- [ESCO](https://esco.ec.europa.eu/en/use-esco) publishes linked open data for
  occupations, skills, knowledge, and competencies with stable URI concept
  identifiers and multilingual labels. Its
  [web-service API](https://esco.ec.europa.eu/en/use-esco/use-esco-services-api/esco-web-service-api)
  exposes selectable versions; the site reported ESCO 1.2.1 as current. A
  crosswalk must retain source version and cannot assume an ESCO concept is
  semantically identical to an O*NET element.
- The [Credential Engine schemas handbook](https://www.credreg.net/ctdl/handbook)
  uses CTDL to describe credentials, learning opportunities, assessments,
  competencies, organizations, pathways, progression, and recognition of
  prior learning. It also states that CTDL describes credentials offered, not
  credentials awarded to a person. Its rich graph is useful public metadata,
  not personal Proof.
- The [1EdTech CASE standard](https://www.1edtech.org/standards/case) gives
  frameworks, competencies, learning outcomes, associations, and rubrics
  stable exchange identities. CASE supports an authority publishing a
  framework and associations among frameworks; it does not by itself prove
  that a specific provider offers a current program.
- The NCES [CIP 2020 browser](https://nces.ed.gov/ipeds/cipcode/browse.aspx?y=56%2C)
  provides a United States taxonomy for instructional programs. A CIP code
  classifies a field; availability, admission, curriculum, transfer, cost, and
  accreditation require other authorities.
- Hobby knowledge has no single comparable national ontology. The official
  [Scouting America Merit Badge Hub](https://www.scouting.org/skills/merit-badges/)
  shows that one organization can maintain explicit, revisable requirements
  across many interests. [US Sailing's accreditation material](https://www.ussailing.org/wp-content/uploads/2022/11/2022-Accreditation-Application_Final-11.9.22.pdf)
  demonstrates association-owned skill progression and safety standards for
  one activity. An [American Alpine Club account of climbing education](https://publications.americanalpineclub.org/articles/13201213433/Climbing-Education)
  describes the inconsistency among otherwise useful providers outside a
  certification system. These sources support a domain-specific authority
  ladder, not a universal hobby credential graph.

### Completed three-domain validation pilot

A bounded paper pilot was performed on 2026-08-03 rather than leaving the
shared contract as a hypothesis. The pilot did not ingest data or test a user
experience. It took one real claim bundle from each destination domain and
attempted to preserve, without flattening, the source-native identity, claim
type, authority for that claim, jurisdiction, version or effective period,
retrieval date, freshness limit, attribution or redistribution constraint, and
known uncertainty.

| Domain slice | Sources and freshness inspected | Claims the sources can support | Boundary exposed by the pilot |
| --- | --- | --- | --- |
| United States software developer | [O*NET Software Developers 15-1252.00](https://www.onetonline.org/link/summary/15-1252.00), backed by O*NET 30.3 (May 2026, quarterly releases, CC BY 4.0), and the [BLS Software Developers OOH profile](https://www.bls.gov/ooh/computer-and-information-technology/software-developers.htm) (last modified August 28, 2025; 2024-34 projection period), all retrieved 2026-08-03 | O*NET can support versioned occupation, task, skill, knowledge, and work-context descriptions. BLS can support national typical preparation, pay, and outlook with its published limits. | A typical bachelor's degree is descriptive, not a legal or universal employer gate. The O*NET release and individual category update dates are distinct freshness facts. Neither source can decide whether a user is qualified. |
| One current computer-science learning route | [UMGC's 2026-27 B.S. in Computer Science](https://www.umgc.edu/online-degrees/bachelors/computer-science), the [MSCHE statement for UMGC](https://www.msche.org/institution/0198/) (accreditation reaffirmed November 20, 2025), and the [CIP 2020 browser](https://nces.ed.gov/ipeds/cipcode/browse.aspx?y=56%2C), retrieved 2026-08-03 | UMGC owns its current 120-credit offering, curriculum, prerequisites, and delivery claims. MSCHE owns the institution's accreditation status and expressly does not accredit individual programs. CIP supplies classification only. | A provider, accreditor, and taxonomy can describe the same route without being interchangeable. The offering is bound to catalog year; accreditation has a separate review clock. No inspected page grants transfer credit or proves personal fit. Public access does not establish redistribution permission for provider text, so packaging remains blocked pending license review. |
| United States beginner sailing | The [US Sailing First Sail program handbook](https://www.ussailing.org/wp-content/uploads/2024/07/first-sail-program-handbook.pdf2_.23.pdf) (2024-hosted program document), current [US Sailing course listings](https://www1.ussailing.org/Calendar/Pf.aspx?gid=8), and the [U.S. Coast Guard life-jacket guidance](https://www.uscgboating.org/recreational-boaters/life-jacket-wear-wearing-your-life-jacket.php), retrieved 2026-08-03 | US Sailing can describe its own beginner program and recognized providers. The Coast Guard can support federal carriage and equipment guidance. A listed provider owns its actual date, place, price, capacity, and accessibility facts. | Program progression, provider availability, and federal safety are three claims with three freshness policies. State and site rules may differ. US Sailing material is not assumed redistributable merely because it is public; citation is possible, but transformation or packaging needs rights review. |

The pilot passed the narrow question: one source-preserving claim envelope can
represent all three bundles without inventing a universal domain authority.
It failed any flatter approach. A source-level `official` flag could not
express that MSCHE owns institutional accreditation but not curriculum, that
BLS owns national statistics but not qualification, or that the Coast Guard
and a sailing provider own different parts of one beginner route. The pilot
therefore adds an evidence-backed requirement for predicate-level authority,
independent freshness clocks, jurisdiction, and explicit redistribution state.

The pilot does **not** prove source licensing for production, crosswalk
accuracy, corpus coverage, ingestion feasibility, or recommendation quality.
Those remain separate evidence questions rather than reasons to defer the
claim-boundary finding.

### Synthesis

The common reusable unit is not a generic web page or a universal "skill." It
is a versioned public claim whose meaning includes at least its subject,
predicate, object, source, source authority for that predicate, jurisdiction,
effective/retrieval dates, freshness policy, license/attribution, risk class,
review state, and any supersession or contradiction. Crosswalks are claims too
and need their own provenance and confidence. This is an inference from the
repository and external authorities, not an approved data model.

The foundation also has an independently observable product outcome before any
recommendation consumer exists: a person inspecting a supported public fact can
see what the source actually claims, who owns that claim, its release and
jurisdiction, when it was checked, its freshness or conflict state, and required
attribution. The same already-verified fact remains inspectable offline; if no
safe bundled or last-verified fact exists, inspection says the reference is
unavailable instead of reconstructing or implying it. This outcome tests the
foundation itself rather than treating a later recommendation as its only proof
of usefulness.

## Alternatives

### 1. Let every destination initiative build its own source layer

Career, education, and hobby work could each ingest only what it needs. This
may accelerate the first demo, but duplicates provenance, freshness, licensing,
offline fallback, and conflict rules. The same public capability could acquire
three incompatible identities and explanations.

### 2. Adopt one external taxonomy as the Ambitions ontology

O*NET or ESCO could anchor everything. Both are valuable occupation systems,
but neither owns institutional admissions, transfer, provider curricula,
activity-specific safety, or the user's meaning. Extending either into all
life domains would turn source convenience into false authority.

### 3. Flatten sources into a universal knowledge graph

A single graph of normalized nodes and edges is easy to query, but
normalization can erase source meaning, jurisdiction, release identity, and
claim authority. An apparent edge such as "capability leads to destination"
could hide whether it came from a regulator, a statistical association, a
provider, or a community guide.

### 4. Preserve source-native records behind a shared claim and authority layer

Each adapter retains lossless source identifiers and versioned records, then
projects only explicitly mapped claims into a common public contract.
Crosswalks remain provenance-bearing claims rather than silent merges. This is
more work, but best fits current Source Atlas and supports consistent
freshness, inspection, offline fallback, and domain-specific authority.

### 5. Query the web or a hosted model when a user asks

Live retrieval could improve breadth but creates unstable outputs, private
query egress, weak reproducibility, and unclear licensing. It directly
conflicts with the finite public-artifact namespace and local private matching
boundary. Public collection may happen separately, but private intent cannot
shape the request.

## Unknowns and risks

### Dependencies

- Later recommendation work depends on an approved capability-continuity
  contract so public capability concepts can be compared with user-owned
  capability meaning without collapsing one into the other.
- Career, education, and hobby Research must each define its own authority
  hierarchy and claim classes. This foundation cannot decide domain truth by
  itself.
- Destination adoption, path comparison, goal-path generation, scheduling, and
  external credential/profile import remain separate initiatives.

### Material unknowns

- Which public concept becomes the stable Ambitions reference when a source
  splits, merges, deprecates, or renames it?
- Which crosswalks are published by an authority, which are Ambitions-curated,
  and what confidence and review state should each carry?
- What minimum coverage, freshness, and contradiction rate makes a domain
  eligible for recommendations rather than search-only inspection?
- How should bundled breadth be balanced against device storage, decode time,
  update size, and accessibility of source explanations?
- Which source licenses allow transformed and redistributed packs, and which
  require local fetch, attribution, or omission?
- How are geographic and temporal applicability represented without sending a
  private location or intent to the server?
- How should emergency, legal, medical, regulated-profession, admissions, and
  safety-sensitive claims be blocked or routed to a current governing source?

### Risks

- A source can be official yet not authoritative for the claim Ambitions wants
  to make. "Official" alone is an unsafe confidence shortcut.
- Crosswalks can produce false equivalence, especially among O*NET skills,
  ESCO concepts, CASE outcomes, credentials, and user-described capabilities.
- Broad data coverage can look like product quality while hiding sparse
  relationships, stale regional facts, and unsupported hard gates.
- Source refresh can silently change recommendation behavior unless releases,
  deltas, accepted mappings, and last-known-good behavior remain inspectable.
- Hobby community evidence is often the best source of vocabulary and project
  ideas but may be unsafe as rules, qualification, or risk authority.
- A public graph can still become a hidden ranking engine if its internal
  confidence or source popularity is exposed as a verdict about the user.
- Attribution, trademarks, and redistribution terms can vary by dataset and
  release. Legal review may be required before packaging real corpora.

## Recommended direction

Continue toward a shared, source-preserving public-reference foundation, with
one important constraint: common infrastructure must not imply common domain
authority.

The recommended first validation corpus is the O*NET 30.3 United States
`15-1252.00 Software Developers` slice only. It is source-native, versioned,
downloadable, and published under CC BY 4.0. The validation slice should retain
only O*NET-owned occupation identity and descriptive task, skill, knowledge,
work-activity, work-context, education, and experience claims. It should exclude
BLS market claims, ESCO crosswalks, employer requirements, qualification, and
personal-fit conclusions until those sources and claim classes pass their own
rights and authority review. This is intentionally a source-inspection corpus,
not enough coverage for career recommendations.

The minimum bar for that slice is complete rather than statistical: every fact
made visible has its O*NET identifier, 30.3 release binding, United States
applicability, predicate-level authority, retrieval/freshness state, and CC BY
attribution; any unmapped, conflicted, or unlicensed field remains unavailable.
The bundled or last-verified offline inspection must preserve the same fact and
provenance, while absence must be reported honestly. Broader coverage cannot
compensate for a single visible claim that fails this bar.

The next phase should consider a bounded product contract in which:

1. public artifacts are selected from finite, non-private namespaces and remain
   useful offline from bundled or last-verified state;
2. every usable statement retains claim-level provenance, source-native
   identity, version, jurisdiction, freshness, authority-for-purpose,
   attribution, risk, review, and conflict state;
3. occupation, education, and hobby adapters preserve their source-native
   semantics and expose only explicit mappings;
4. crosswalks remain inspectable, versioned claims with no silent equivalence;
5. public packs cannot store a private match, user rejection, personal
   capability, Goal, Proof, schedule, or recommendation outcome;
6. local consumers can say "source needed," use a safe stale fallback where
   allowed, or remain quiet rather than fabricate coverage; and
7. delivery validity, semantic/domain completeness, and recommendation quality
   remain separate evidence claims.

The completed software-development, computer-science education, and sailing
pilot supports this shared boundary at Research fidelity. It shows that the
foundation can preserve three very different claim bundles only when authority
is attached to a predicate and freshness is attached to the particular source
claim—not to the destination as a whole. Before a broader corpus is
contemplated, the initiative's production evaluation still needs rights review,
source-release diff tests, crosswalk evaluation, and explicit domain coverage
bars.

This direction recommends one validation corpus but does not authorize its
production ingestion, commit a schema, define a recommendation score, or
approve hosted retrieval. It identifies the public truth boundary and bounded
quality bar that this initiative's Scope must resolve without redesigning
Source Atlas into a private intelligence service.
