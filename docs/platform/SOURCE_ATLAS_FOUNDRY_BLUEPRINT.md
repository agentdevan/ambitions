# Source Atlas Foundry Blueprint

Status: active implementation blueprint
Scope: Source Atlas public/reference data factory, R2 staging, freshness, provenance, and future Ambitions local runtime consumption
Owner posture: blueprint and tooling plan, not release proof

## Thesis

Ambitions cannot generate world-class paths for any goal by inventing advice. It needs a public/reference knowledge substrate that is broad, fresh, inspectable, and locally composable with the Private Life Runtime.

The Source Atlas Foundry is that substrate factory.

It should compile public/reference sources into versioned packs that Ambitions can use locally for:

- eligibility rules
- deadlines and selection cycles
- skill ladders
- occupational requirements
- program requirements
- credential pathways
- training and preparation structures
- transfer maps between related goals
- freshness warnings and review triggers

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
- private context

The join must happen locally in Ambitions. R2 stores packs, manifests, revocation lists, and provenance receipts for public/reference data only.

## Data Strategy

The foundry needs five data planes.

### 1. Requirements Plane

Examples:

- U.S. president eligibility
- NASA astronaut requirements
- licensure requirements
- application windows
- age gates
- residency/citizenship gates
- credential requirements

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

### 2. Skill Atom Plane

Skills are reusable capital. If a user leaves the astronaut path, Ambitions should preserve earned progress and propose adjacent paths using shared skill atoms.

Examples:

- systems engineering
- public speaking
- physical readiness
- technical communication
- coalition building
- leadership
- risk management

### 3. Pathway Lattice Plane

Paths are not static checklists. A pathway is a lattice of milestones, dependencies, gates, alternate futures, and review states.

The foundry should compile reference lattices. The app should personalize them locally.

### 4. Freshness Plane

Every source has a freshness policy:

- stable law watch
- release watch
- selection-cycle watch
- daily job/program watch
- dataset release watch
- source-of-sources discovery

Freshness changes can trigger local review states and receipts when they affect behavior.

### 5. Provenance Plane

Every pack must carry:

- source IDs
- source URLs
- publisher
- license
- authority tier
- retrieved/reviewed time
- adapter version
- hash
- claim IDs
- non-claims

## High-Impact Source Lanes

Initial official/public-reference lanes:

- National Archives for constitutional eligibility.
- NASA for astronaut requirements and selection cycles.
- O*NET database and Web Services for occupations, tasks, skills, knowledge, abilities, work activities, job zones, and transfer mapping.
- BLS APIs for labor-market freshness and trend context.
- USAJOBS APIs for current and historic federal opportunity requirements.
- Data.gov CKAN metadata as a source-of-sources discovery layer, not claim truth.
- College Scorecard for education/program/cost/outcome context.

The foundry should prefer bulk official datasets and structured APIs over web scraping when available.

## R2 Architecture

Use R2 as object storage for versioned public/reference packs.

Recommended layout:

```text
source-atlas/v1/releases/<version>/manifest.json
source-atlas/v1/releases/<version>/packs/<pack-id>.json
source-atlas/v1/releases/<version>/registries/source-registry.json
source-atlas/v1/releases/<version>/freshness-manifest.json
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
5. writes a promotion receipt
6. updates stable channel only if all gates pass

## Automation North Star

Automation should be aggressive but not naive:

```text
discover -> fetch -> normalize -> validate -> diff -> compile -> stage -> promote -> verify -> notify
```

Automate collection and freshness detection. Keep high-risk claims review-bound. Generated research seeds may create candidates, but official/public source adapters must produce production packs.

## Existing Tooling Reuse

The current `tools/source-atlas` folder is useful if treated as a factory, not as one-off scripts:

- `ambitions-pack-crypto.py` remains the pack hash/signature/revocation primitive.
- `ambitions-pack-diff.py` remains the freshness and claim-impact diff primitive.
- `ambitions-freshness-broker.py` remains the freshness-manifest primitive.
- `coverage*.py` scripts are the coverage-frontier engine for discovering weak domains and missing pathway atoms.
- `research-import/` can ingest candidate research seeds, but those candidates stay below official-source adapters until reviewed.
- `lakehouse-workbench/` is a useful prototype for a large staging corpus, but it needs dependency, schema, and privacy gates before it becomes production infrastructure.
- `foundry/` is the opinionated compiler and R2 staging planner that turns approved public/reference source records into versioned bundles.

## Seed Factory Shape

The seed factory should run as a deterministic public-reference pipeline:

```text
source registry
  -> adapter snapshot
  -> normalized source records
  -> claim records
  -> requirement records
  -> pathway lattice records
  -> skill atom records
  -> transfer graph records
  -> versioned pack bundle
  -> R2 staging plan
  -> promotion gate
```

The factory should create three classes of output:

- `candidate` packs from broad discovery and generated research seeds.
- `reviewed` packs whose claims are backed by official/public sources and pass privacy/schema/provenance checks.
- `stable` packs promoted only after hash, signature, revocation, freshness, and public/reference-only gates.

This lets Ambitions become broad without becoming reckless. A goal like `become an astronaut` can be decomposed into official gates, skill atoms, preparation milestones, and adjacent transfer paths. A goal like `become U.S. president` can expose a legal age gate, preserve useful waiting-period progress, and refresh if authoritative requirements change.

## Proof Boundary

Current foundry tooling can prove local compilation, schema validation, privacy scanning, hash verification, and R2 staging-plan shape.

It does not prove:

- R2 production freshness
- app runtime fetch/cache
- entitlement gating
- privacy/legal approval
- official source approval
- release readiness

Those claims require current source, network/request proof, app runtime validation, and release evidence.
