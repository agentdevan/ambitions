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

python3 tools/source-atlas/source-atlas-foundry.py harvest \
  --output-root output/source-atlas/harvest \
  --run-id source-atlas-harvest-2026-06-25 \
  --limit 25

python3 tools/source-atlas/source-atlas-foundry.py compile \
  --output-root output/source-atlas/foundry \
  --version-id source-atlas-2026-06-25 \
  --channel staging \
  --harvest-root output/source-atlas/harvest/source-atlas-harvest-2026-06-25

python3 tools/source-atlas/source-atlas-foundry.py validate \
  --bundle-root output/source-atlas/foundry/source-atlas-2026-06-25

python3 tools/source-atlas/source-atlas-foundry.py r2-plan \
  --bundle-root output/source-atlas/foundry/source-atlas-2026-06-25 \
  --bucket ambitions-source-atlas-staging \
  --prefix source-atlas/v1 \
  --channel staging \
  --output output/source-atlas/foundry/source-atlas-2026-06-25/r2-plan.json
```

The first compiled seed bundle covers:

- U.S. presidency eligibility, including age-gated future pathing.
- NASA astronaut candidacy, including source-backed requirements, preparation lanes, and alternate paths that reuse earned skills.

The harvest command runs official public/reference adapters:

- National Archives Constitution transcript.
- NASA astronaut requirements.
- NASA astronaut selection program.
- O*NET downloadable text database.
- O*NET Career Cluster crosswalk from O*NET OnLine.
- BLS Public Data API.
- Data.gov API v4 search.
- College Scorecard API.
- USAJOBS Search API when `USAJOBS_USER_AGENT` and `USAJOBS_AUTHORIZATION_KEY` are present.

The O*NET adapter normalizes career-cluster adjacency, related occupations, skills, essential skills, transferable skills, work activities, interests, job zones, education, training/experience, work styles/context, and software skills. That gives Ambitions public/reference structure for skill transfer and alternate-path reasoning when a user pivots from one goal to another.

Adapters write local raw snapshots under `output/source-atlas/harvest/<run>/snapshots/` and normalized harvest records under `output/source-atlas/harvest/<run>/normalized/`. The bundle compiler only carries bounded provenance summaries, record counts, hashes, freshness signals, and blocker reasons into R2-ready packs. It does not upload raw source dumps, user data, or credentials.

Native MCP entry points mirror the CLI:

- `source_atlas_foundry_status`
- `source_atlas_foundry_harvest`
- `source_atlas_foundry_compile_bundle`
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
  --plan output/source-atlas/foundry/source-atlas-2026-06-25/r2-plan.json \
  --confirm-public-reference-only \
  --execute
```

The foundry does not read or print credentials. The shell environment must provide approved, scoped R2 write credentials for Wrangler. Generated R2 plans force Wrangler `--remote`; local Wrangler simulation is not accepted as proof of R2 staging.

## Cloudflare and Wrangler Setup

Official Cloudflare agent setup for Codex:

```bash
codex mcp add cloudflare --url https://mcp.cloudflare.com/mcp
codex mcp add cloudflare-docs --url https://docs.mcp.cloudflare.com/mcp
codex mcp add cloudflare-bindings --url https://bindings.mcp.cloudflare.com/mcp
codex mcp add cloudflare-builds --url https://builds.mcp.cloudflare.com/mcp
codex mcp add cloudflare-observability --url https://observability.mcp.cloudflare.com/mcp
codex mcp login cloudflare
```

For this workstation, the main Cloudflare API MCP may already exist as `cloudflare-api` with the same URL. Do not add a duplicate endpoint just for naming symmetry.

Wrangler verification:

```bash
wrangler --version
wrangler whoami
wrangler r2 bucket list
```

Expected Ambitions buckets:

```text
ambitions-source-atlas-dev
ambitions-source-atlas-staging
ambitions-source-atlas-prod
```

Use `ambitions-source-atlas-staging` for Foundry staging plans. Promote to production only through a validation/promotion gate.

## Local API Keys

Do not paste secrets into chat and do not commit real keys. Put Source Atlas adapter keys in:

```text
tools/source-atlas/foundry/.env
```

Start from:

```text
tools/source-atlas/foundry/.env.example
```

Supported keys:

```bash
DATAGOV_API_KEY=...
COLLEGE_SCORECARD_API_KEY=...
USAJOBS_USER_AGENT=you@example.com
USAJOBS_AUTHORIZATION_KEY=...
CLOUDFLARE_API_TOKEN=...
```

The Foundry loads `.env` files from repo root, `tools/source-atlas/.env`, and `tools/source-atlas/foundry/.env`, without overriding variables already exported in the shell.

## Next Production Step

Add a Cloudflare Worker promotion gate that reads staging objects through an R2 binding, validates the bundle, verifies hashes and signatures, checks revocation/last-known-good posture, writes a promotion receipt, and copies only accepted artifacts to the public/reference channel.

No current foundry output proves R2 freshness, entitlement gating, app runtime fetch/cache behavior, privacy/legal approval, or production readiness.
