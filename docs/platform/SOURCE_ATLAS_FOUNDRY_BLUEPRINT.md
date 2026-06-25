# Source Atlas Foundry Blueprint

Status: active implementation blueprint
Scope: Source Atlas public/reference intelligence supply chain, reusable knowledge graph, R2 staging, freshness, provenance, and future Ambitions local runtime consumption
Owner posture: blueprint and tooling plan, not release proof

## Thesis

Ambitions cannot generate world-class paths for broad user goals by inventing advice or by hard-coding one path per goal. It needs a public/reference knowledge substrate that is broad, fresh, inspectable, composable, and locally joinable with the Private Life Runtime.

The Source Atlas Foundry is that substrate factory.

The end state is not a goal-template marketplace and not a library of hard-coded paths. It is a Source Atlas intelligence supply chain: a deterministic public/reference pipeline that turns official sources, public datasets, standards, occupation data, credential data, education data, and platform references into reusable knowledge graph primitives.

Ambitions should then compose those primitives locally for the exact user, exact goal, exact Life Capital, exact constraints, and exact schedule reality.

Source Atlas remains invisible by default. It is not a marketplace. It is not the user. It never receives the private life graph.

## Canon Boundary

Source Atlas knows public/reference structure.

The Private Life Runtime knows:

- the user's goals
- captures
- schedule assumptions
- protected time
- proof
- receipts
- personalization
- behavior history
- Life Capital
- private context

The join must happen locally in Ambitions. R2 stores public/reference artifacts only: manifests, reusable knowledge shards, revocation lists, provenance receipts, freshness manifests, and promotion receipts.

R2 must never receive goals, captures, schedule assumptions, proof, receipts, behavior history, inferred priorities, private user context, Life Capital records, or the private life graph.

## North-Star Nine Upgrades

Source Atlas should be upgraded as a governed intelligence supply chain with nine explicit layers.

1. Source authority registry
   - source type, publisher, license/terms posture, authority tier, freshness cadence, risk class, review requirement, adapter owner, and blocked-source behavior.

2. Certified adapters
   - each source lane has fetch limits, fixtures, schema contracts, API-drift tests, auth/secret boundaries, blocked-source receipts, and source-specific normalization.

3. Canonical knowledge graph
   - entities, claims, requirements, occupations, credentials, institutions, skills, tests, interviews, timelines, constraints, prerequisites, transfer edges, caveats, and source references.

4. Claim adjudication
   - source-backed, candidate, stale, disputed, contradicted, revoked, review-required, and unsupported states; multi-source conflict handling; high-risk human review gates.

5. Deterministic pack builds
   - canonical JSON, stable ordering, hashes, signatures, manifests, provenance receipts, freshness diffs, revocation lists, and last-known-good rollback pointers.

6. R2 staging and promotion
   - local compile/validate creates staging plans; stable promotion requires a Cloudflare Worker gate that validates schema, privacy boundary, hashes, signatures, freshness, revocation, and promotion receipt.

7. Runtime-safe local consumption
   - the app requests only public/reference pack IDs, hashes, manifests, and versions; no private context in requests; all personalization happens locally.

8. Pathing intelligence contracts
   - eligibility-aware paths, age gates, credential bridges, skill transfer, readiness gaps, alternate routes, "Still counts" preservation, source freshness review states, and no false completion.

9. Coverage frontier
   - measure domain coverage, missing sources, weak atom types, stale domains, unsupported claims, source-risk gaps, and expansion priority.

## Methodology Upgrade: Reusable Knowledge, Not Goal Packs

The core design law:

```text
Do not create one pack per goal.
Create reusable public/reference building blocks.
Let the Private Life Runtime compose paths locally.
```

A goal like `become an NFL player` should not be a separate hard-coded path disconnected from `become a college football player`. College football, high school recruiting, athletic performance, training, eligibility, team positions, academic requirements, injury risk, transfer rules, scouting exposure, combine preparation, agent/legal boundaries, and draft pathways are overlapping public/reference structures.

Source Atlas should model the shared structures once, then let Ambitions compose:

- a high school athlete route
- a college football route
- an NFL draft route
- a walk-on route
- a transfer route
- a coaching or sports-performance adjacent route
- an injury-recovery or delayed-timeline route
- a "what still counts" transfer route if the user pivots away from football

The production artifact is not "the NFL path." It is a set of reusable, sourced, versioned primitives that can support many paths.

## Data Unit Taxonomy

Use precise data units instead of vague "seeds" when possible.

### Source

An official or public/reference origin:

- public API
- public dataset
- government page
- official rulebook
- standards/specification document
- education/credential dataset
- occupational dataset
- Apple platform reference where relevant

### Snapshot

The raw fetched source artifact for one adapter run. Snapshots stay in ignored local output unless a future policy explicitly approves retaining a bounded fixture. Raw snapshots are not the product artifact.

### Adapter

Deterministic source-specific code that fetches, parses, normalizes, and emits typed records. An adapter must not emit private user context. Authenticated adapters must redact credentials and create blocked-source receipts when required environment variables are missing.

### Entity

A canonical public/reference object:

- occupation
- credential
- institution
- program
- rule
- skill
- task
- test
- interview
- requirement
- domain
- role
- governing body
- timeline
- source publisher

### Claim

A sourced assertion about an entity or relationship. Claims carry source IDs, source URLs or dataset versions, adapter version, fetched time, license/terms posture, freshness state, risk class, review state, and transformation trace.

### Requirement

A structured rule derived from claims:

- minimum age
- citizenship/residency
- degree or equivalent path
- license/certification
- experience duration
- test score
- interview/selection step
- physical or medical gate
- application window
- prerequisite sequence

Requirements must be machine-checkable where feasible, but they do not make private eligibility decisions in R2. Eligibility against a user happens locally.

### Atom

A reusable planning building block:

- skill atom
- capability atom
- credential atom
- resource atom
- equipment atom
- proof atom
- training atom
- preparation atom
- institution atom
- timeline atom
- role atom

Atoms are the closest match to the user's "building-block stockpile" idea. They are small enough to reuse across many goals and specific enough to support grounded planning.

### Edge

A typed relationship between units:

- prerequisite_of
- satisfies_requirement
- transfers_to
- similar_to
- adjacent_to
- prepares_for
- required_by
- accepted_equivalent_for
- expires_after
- governed_by
- source_conflicts_with

Edges are what let Ambitions understand that college football is often on the way to the NFL, but also that not every college-football path means the same thing for every user.

### Lattice

A partial-order graph of milestones, gates, dependencies, alternate futures, and review states. A lattice is not a final user path. It is reference structure that the app can compose locally.

### Recipe

A composition recipe describes how public/reference primitives may be assembled for a class of goals. Recipes are not final schedules, not final Steps, and not user-specific recommendations. They are hints for local runtime composition.

### Pack

A pack is a versioned distribution shard for public/reference graph units. A pack may be domain-level, source-level, region-level, credential-level, or occupation-cluster-level. It should not be one user's path and should not be a one-goal template.

### Seed

A seed is an unpromoted candidate input. It may come from broad discovery, generated research, manual curation, or a source-of-sources index. A seed is not production truth. It must become source-backed graph records before reviewed or stable use.

## Data Strategy

The foundry needs ten data planes.

### 1. Source Authority Plane

Every source must declare:

- source ID
- publisher
- source type
- canonical URL or dataset locator
- license/terms posture
- authority tier
- freshness cadence
- risk class
- review requirement
- adapter ID and version
- blocked-source behavior

Data.gov-style source discovery can identify sources, but source-of-sources metadata is not claim truth.

### 2. Entity Plane

The entity plane deduplicates and normalizes canonical objects. It prevents the same institution, credential, occupation, role, or governing body from being modeled repeatedly under different goal names.

The entity plane should support stable IDs, aliases, jurisdiction, source bindings, and deprecation/supersession.

### 3. Claim Plane

Every meaningful assertion becomes a claim with:

- source IDs
- source URLs or dataset versions
- publisher
- fetched time
- adapter version
- transformation steps
- license/terms posture
- freshness state
- risk class
- review state
- confidence posture without arbitrary confidence scores
- non-claims

Claims must be able to become stale, disputed, contradicted, or revoked without deleting the historical provenance.

### 4. Requirements Plane

Examples:

- U.S. president eligibility
- NASA astronaut requirements
- college athletic eligibility rules
- licensure requirements
- application windows
- age gates
- residency/citizenship gates
- credential requirements
- testing/interview requirements

Shape:

```json
{
  "requirementID": "requirement.astronaut.stem_masters_or_equivalent",
  "claimID": "claim.astronaut.stem_masters_or_equivalent",
  "gateType": "credential",
  "structuredRule": {
    "type": "education_or_equivalent",
    "acceptedPaths": ["stem_masters", "doctoral_work", "medical_degree", "test_pilot_school"]
  }
}
```

### 5. Atom Plane

Atoms are reusable public/reference units that support Life Capital matching and progress transfer.

Examples:

- systems engineering
- public speaking
- physical readiness
- technical communication
- coalition building
- leadership
- risk management
- athletic conditioning
- position-specific football skill
- film study
- academic eligibility
- interview readiness

If a user leaves an astronaut, football, medicine, music, or civic path, Ambitions should preserve useful progress through shared atoms and propose adjacent routes without false completion.

### 6. Edge Plane

Edges define how units connect.

Examples:

- a high school football role prepares for a college football role
- college football may prepare for NFL eligibility
- athletic conditioning transfers to other sport or fitness goals
- public speaking transfers to civic leadership, interviews, teaching, sales, and performance
- a credential satisfies a requirement in one jurisdiction but not another

Edges need source bindings or clear review state. Unsourced edge guesses stay candidate-only.

### 7. Pathway Lattice Plane

Paths are not static checklists. A pathway lattice is a graph of milestones, dependencies, gates, alternate futures, review states, proof opportunities, and time-sensitive constraints.

The foundry should compile reference lattices. The app should personalize them locally.

### 8. Freshness Plane

Every source and claim has a freshness policy:

- stable law watch
- release watch
- selection-cycle watch
- daily job/program watch
- dataset release watch
- source-of-sources discovery
- rule-change watch
- standards/specification watch

Freshness changes can trigger local review states and receipts when they affect behavior.

### 9. Provenance Plane

Every pack and every claim must carry enough receipt data to explain:

- what source supported it
- when it was fetched
- what adapter transformed it
- what version was built
- what hash/signature covered it
- what license/terms posture applied
- what freshness window applied
- what review status applied
- what non-claims remain

### 10. Coverage Plane

Coverage is a product-quality input. The foundry should report:

- domains covered
- domains missing
- source lanes blocked
- stale source clusters
- atom types underrepresented
- requirement types underrepresented
- transfer edges missing
- high-risk claims waiting for review
- public API drift
- source conflicts
- pack-size and shard health

Coverage reports should guide expansion without becoming user-facing pack browsing.

## High-Impact Source Lanes

Implemented official/public-reference lanes:

- National Archives for constitutional eligibility.
- NASA for astronaut requirements and selection cycles.
- O*NET downloadable text database for occupations, tasks, skills, essential skills, transferable skills, knowledge, abilities, work activities, work styles/context, education, training/experience, job zones, interest areas, software skills, related occupations, and job titles.
- O*NET OnLine Career Cluster crosswalk for occupation adjacency by field of work and similar-skill cluster/subcluster structure.
- BLS Public Data API for labor-market freshness and trend context.
- USAJOBS Search API for current federal opportunity requirements when registered API headers are present.
- Data.gov API v4 search as a source-of-sources discovery layer, not claim truth.
- College Scorecard for education/program/cost/outcome context.

Near-term expansion lanes should prioritize reusable public/reference structure before narrow goal examples:

- education and credential taxonomies
- licensing and certification bodies
- standards/specification sources
- occupational ladders and apprenticeship sources
- athletic eligibility and recruiting sources
- public-sector selection processes
- scholarship/grant/public program requirements
- official exam, interview, and application-window references
- Apple platform references for implementation-domain goals where relevant

The foundry should prefer bulk official datasets and structured APIs over web scraping when available.

## Pipeline Shape

Current CLI path:

```text
harvest -> compile -> validate -> r2-plan -> upload-r2
```

Target supply-chain path:

```text
discover
  -> source-register
  -> fetch/snapshot
  -> normalize
  -> entity-resolve
  -> claim-extract
  -> adjudicate
  -> graph-build
  -> coverage-score
  -> diff
  -> compile-shards
  -> validate
  -> stage
  -> promote
  -> verify
  -> notify
```

The harvest step stores raw official snapshots only in ignored local output. The compiled bundle carries bounded provenance summaries, record counts, hashes, freshness signals, source URLs, and blocked-source reasons. Raw snapshots, API keys, private user context, and the Private Life Runtime are not compiled into R2-ready bundles.

O*NET is a transfer substrate, not just an occupation source. Career clusters, related occupations, transferable skills, work activities, interests, job zones, education, training, work styles, and software skills should feed alternate-path and Life Capital preservation logic so progress on one goal can remain useful when the user changes direction.

## Composition Example: College Football and NFL

Do not model `become a college football player` and `become an NFL player` as two sealed path products.

Model the shared public/reference graph:

- football roles and positions
- sport skill atoms
- physical preparation atoms
- academic eligibility requirements
- recruiting timeline concepts
- college athletics structures
- performance/proof artifacts
- scouting/combine/interview preparation
- transfer and alternate-route edges
- adjacent outcomes such as coaching, sports medicine, training, analytics, broadcasting, and athletic administration

Then Ambitions can compose a path locally based on the user:

- age and school stage
- current athletic history
- existing proof and performance artifacts
- schedule reality
- academic context
- resources and access
- injury/recovery constraints
- location and institution options
- willingness to pursue alternate routes

The public/reference graph can say which pieces exist and how they relate. The Private Life Runtime decides which pieces fit this user and creates local Steps, schedules, receipts, and review states.

## R2 Architecture

Use R2 as object storage for versioned public/reference shards.

Recommended layout:

```text
source-atlas/v1/releases/<version>/manifest.json
source-atlas/v1/releases/<version>/packs/<pack-id>.json
source-atlas/v1/releases/<version>/registries/source-registry.json
source-atlas/v1/releases/<version>/registries/entity-registry.json
source-atlas/v1/releases/<version>/registries/ontology-registry.json
source-atlas/v1/releases/<version>/freshness-manifest.json
source-atlas/v1/releases/<version>/coverage-manifest.json
source-atlas/v1/releases/<version>/provenance/<receipt-id>.json
source-atlas/v1/channels/staging/manifest.json
source-atlas/v1/channels/stable/manifest.json
source-atlas/v1/revocations/revocation-list.json
```

Local foundry tooling may upload to staging after validation. Stable promotion should be handled by a Cloudflare Worker gate that:

1. reads staging objects through an R2 binding
2. validates schema and privacy boundary
3. verifies hashes and signatures
4. checks revocation and last-known-good posture
5. checks freshness, coverage, and high-risk review posture
6. writes a promotion receipt
7. updates stable channel only if all gates pass

Wrangler upload plans must force remote R2 operations. A local Wrangler storage upload is developer simulation, not Source Atlas staging proof.

## Automation North Star

Automation should be aggressive but not naive:

```text
discover -> fetch -> normalize -> validate -> diff -> compile -> stage -> promote -> verify -> notify
```

Automate collection, source drift detection, schema drift detection, freshness detection, deduplication, graph compilation, diffing, staging, and alerts.

Keep high-risk claims review-bound. Generated research seeds may create candidates, but official/public source adapters must produce reviewed or stable production graph records.

## Existing Tooling Reuse

The current `tools/source-atlas` folder is useful if treated as a factory, not as one-off scripts:

- `ambitions-pack-crypto.py` remains the pack hash/signature/revocation primitive.
- `ambitions-pack-diff.py` remains the freshness and claim-impact diff primitive.
- `ambitions-freshness-broker.py` remains the freshness-manifest primitive.
- `coverage*.py` scripts are the coverage-frontier engine for discovering weak domains and missing pathway atoms.
- `research-import/` can ingest candidate research seeds, but those candidates stay below official-source adapters until reviewed.
- `lakehouse-workbench/` is a useful prototype for a large staging corpus, but it needs dependency, schema, and privacy gates before it becomes production infrastructure.
- `foundry/` is the opinionated compiler and R2 staging planner that turns approved public/reference source records into versioned bundles.

## Production Artifact Classes

The factory should create four classes of output:

- `candidate` graph records from broad discovery, source-of-sources metadata, generated research seeds, or manual curation.
- `reviewed` graph records whose claims are backed by official/public sources and pass privacy/schema/provenance checks.
- `stable` graph shards promoted only after hash, signature, revocation, freshness, review, coverage, and public/reference-only gates.
- `revoked` or `superseded` graph records retained for provenance and rollback, but blocked from current runtime use.

This lets Ambitions become broad without becoming reckless. A goal like `become an astronaut` can be decomposed into official gates, reusable skill atoms, preparation milestones, and adjacent transfer paths. A goal like `become U.S. president` can expose a legal age gate, preserve useful waiting-period progress, and refresh if authoritative requirements change.

## No Hard-Coded Pathing Law

Foundry output must not encode final user schedules, final Step lists, private eligibility decisions, or user-specific recommendations.

Allowed:

- public/reference requirements
- reusable atoms
- source-backed edges
- reference lattices
- composition recipes
- example structures
- freshness warnings
- caveats and non-claims

Forbidden:

- one-goal-only production packs
- hard-coded final path for a user
- hard-coded final schedule
- private user assumptions
- private eligibility decisions in R2
- cloud-side personalization
- Source Atlas marketplace browsing
- hidden recommendation behavior

## Runtime Composition Contract

Ambitions runtime should consume Source Atlas like this:

```text
goal intent
  -> local clarification
  -> public/reference match by local query
  -> pack/manifest/hash request with no private context
  -> local graph load
  -> local Life Capital match
  -> local schedule/capacity simulation
  -> local path composition
  -> local Steps/Future Steps
  -> local proof, receipt, review, undo, and freshness inspection
```

If Source Atlas is unavailable, Ambitions must still support local planning. It may use generic starter paths, ask clarifying questions, or mark external context as unavailable. It must not send private context to recover missing packs.

## Proof Boundary

Current foundry tooling can prove local compilation, schema validation, privacy scanning, hash verification, and R2 staging-plan shape.

Current foundry adapter tooling can also prove that public/reference harvest records were produced or that an authenticated source was explicitly blocked with named missing environment variables.

This blueprint does not prove:

- R2 production freshness
- Cloudflare Worker promotion
- app runtime fetch/cache
- app runtime local composition
- entitlement gating
- privacy/legal approval
- official source approval
- release readiness
- coverage for almost any goal

Those claims require current source, network/request proof, app runtime validation, coverage evidence, and release evidence.
