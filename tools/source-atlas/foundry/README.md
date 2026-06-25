# Source Atlas Foundry

Status: local developer tooling foundation.
Scope: public/reference Source Atlas pack compilation, validation, provenance, freshness, and R2 staging plans.

The foundry exists to make Source Atlas large enough and trustworthy enough for Ambitions goal pathing without turning R2 into a private user-data backend.

## Product Boundary

Source Atlas stores public/reference structure:

- eligibility rules
- public requirements
- skill ladders
- domain planning structures
- occupational skill and transfer graphs
- education and program references
- source freshness state

The Private Life Runtime stores the user and joins Source Atlas locally. The foundry must never send private user context, goals, captures, calendar data, proof, receipts, behavior history, personalization, or the private life graph to R2.

## Current Capabilities

```bash
python3 tools/source-atlas/source-atlas-foundry.py doctor
python3 tools/source-atlas/source-atlas-foundry.py catalog
python3 tools/source-atlas/source-atlas-foundry.py compile-demo \
  --output-root output/source-atlas/foundry \
  --version-id source-atlas-foundry-demo \
  --channel staging
python3 tools/source-atlas/source-atlas-foundry.py validate \
  --bundle-root output/source-atlas/foundry/source-atlas-foundry-demo
python3 tools/source-atlas/source-atlas-foundry.py r2-plan \
  --bundle-root output/source-atlas/foundry/source-atlas-foundry-demo \
  --bucket ambitions-source-atlas \
  --prefix source-atlas/v1 \
  --channel staging \
  --output output/source-atlas/foundry/source-atlas-foundry-demo/r2-plan.json
```

The first compiled seed bundle covers:

- U.S. presidency eligibility, including age-gated future pathing.
- NASA astronaut candidacy, including source-backed requirements, preparation lanes, and alternate paths that reuse earned skills.

Native MCP entry points mirror the CLI:

- `source_atlas_foundry_status`
- `source_atlas_foundry_compile_demo`
- `source_atlas_foundry_validate_bundle`
- `source_atlas_foundry_r2_plan`

## Architecture

```text
official public/reference source
  -> adapter snapshot
  -> source record
  -> claim graph
  -> requirement graph
  -> pathway lattice
  -> skill transfer graph
  -> versioned pack
  -> release manifest
  -> freshness manifest
  -> provenance receipt
  -> R2 staging plan
```

The existing Source Atlas scripts stay valuable as factory stages:

- pack crypto/signature/revocation primitives
- pack freshness diffing
- freshness manifest creation
- coverage-frontier expansion and scoring
- candidate research import
- lakehouse-workbench prototyping for large staging corpora

Direct R2 upload is intentionally gated:

```bash
python3 tools/source-atlas/source-atlas-foundry.py upload-r2 \
  --plan output/source-atlas/foundry/source-atlas-foundry-demo/r2-plan.json \
  --confirm-public-reference-only \
  --execute
```

The foundry does not read or print credentials. The shell environment must provide approved, scoped R2 write credentials for Wrangler.

## Next Production Step

Add a Cloudflare Worker promotion gate that reads staging objects through an R2 binding, validates the bundle, verifies hashes and signatures, checks revocation/last-known-good posture, writes a promotion receipt, and copies only accepted artifacts to the public/reference channel.

No current foundry output proves R2 freshness, entitlement gating, app runtime fetch/cache behavior, privacy/legal approval, or production readiness.
