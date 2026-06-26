# Source Atlas Data Classification Matrix

Status: active operational boundary contract
Scope: Source Atlas Foundry, public/reference pack artifacts, R2 staging plans, request shapes, caches, logs, schemas, fixtures, and validation
Owner posture: platform implementation support, not product canon, release proof, privacy/legal approval, or R2 production readiness

This matrix operationalizes the active product law: Source Atlas and R2 are public/reference/freshness infrastructure only. The Private Life Runtime stays local and owns private user context.

## Allowed Public/Reference Classes

| Data class | Examples | R2 | App cache | Logs | Fixtures | Schema requirement |
|---|---|---|---|---|---|---|
| `official_public_source` | source ID, publisher, URL, authority tier, license, freshness cadence, adapter ID/version | allowed | allowed | metadata only | public/synthetic | source-bound |
| `public_reference_claim` | sourced claim text, claim type, state, freshness, source IDs | allowed | allowed | IDs/counts/state only | public/synthetic | source/provenance-bound |
| `public_requirement` | eligibility rule, credential rule, structured public rule | allowed | allowed | IDs/counts/state only | public/synthetic | claim/source/provenance-bound |
| `public_provenance` | source locator, content hash, retrieved time, adapter run summary, receipt hash | allowed | allowed | IDs/hashes/timings only | public/synthetic | source-bound |
| `public_ontology` | namespace prefixes, schema descriptors, forbidden fields | allowed | allowed | IDs/version only | public/synthetic | versioned |
| `public_atom_edge_lattice` | atoms, edges, lattices, reusable graph primitives | allowed | allowed | IDs/counts only | public/synthetic | source/provenance-bound |
| `public_recipe` | goal-class composition hints, required/optional public atoms | allowed | allowed | IDs/counts only | public/synthetic | no final user path or schedule |
| `public_freshness` | freshness manifest, revocation list, channel manifest, last-known-good pointer | allowed | allowed | IDs/hashes/state only | public/synthetic | versioned |
| `public_r2_object_key` | `source-atlas/v1/releases/...`, `source-atlas/v1/channels/staging/...` | allowed | n/a | object key only | public/synthetic | no user/private segment |
| `synthetic_fixture` | positive/negative validator fixture with no real PII or secrets | not promoted | test only | test output only | allowed | expected result declared |

## Forbidden Private Classes

These classes must be rejected from Foundry bundles, schema shards, request shapes, cache artifacts, logs, fixtures intended as valid positives, and R2 object keys:

- `goal_text`
- `capture_text`
- `schedule_or_capacity`
- `calendar_data`
- `life_capital`
- `proof_payload`
- `receipt_payload`
- `account_secret`
- `user_identifier`
- `private_life_graph`
- `personalization`
- `behavior_history`
- `inferred_priority`
- `private_user_context`

## R2 Implications

Allowed R2 keys are public/reference paths only, such as:

```text
source-atlas/v1/releases/<version>/manifest.json
source-atlas/v1/releases/<version>/packs/<pack>.json
source-atlas/v1/releases/<version>/schemas/<schema>.json
source-atlas/v1/releases/<version>/shards/<shard>.json
source-atlas/v1/channels/staging/manifest.json
source-atlas/v1/channels/stable/manifest.json
source-atlas/v1/revocations/<version>.json
```

Forbidden object-key segments include user/account/private graph terms, goals, captures, schedule/capacity, Life Capital, proof, receipts, personalization, behavior history, phone/email/address, and UUID-like user identifiers.

## Request Shape Implications

App-side Source Atlas requests may include only public pack IDs, manifest versions, hashes, channels, source IDs, and public route paths.

Forbidden in request path, query, headers, body, and logs:

- raw goal text
- raw capture text
- calendar events
- schedule/capacity
- Life Capital
- proof or receipt payloads
- account secrets, authorization headers, cookies, session tokens, API keys
- user IDs or account IDs
- private graph fields

## Cache Implications

Source Atlas cache may hold bundled/cached/last-known-good public packs, manifests, hashes, revocations, quarantines, provenance, and freshness metadata.

It must not store locally joined personalized output. User-specific composition belongs to the local Private Life Runtime, not Source Atlas or R2.

## Log Implications

Allowed logs:

- counts
- pack IDs
- claim IDs
- source IDs
- hashes
- timings
- validation issue codes
- blocked-source reasons
- missing environment variable names

Forbidden logs:

- raw private payloads
- raw prompts or responses containing user context
- secrets
- authorization headers
- unredacted URLs with keys
- local private file paths
- runtime graph excerpts

## Fixture Implications

Positive fixtures must be public/synthetic and promotion-safe.

Negative fixtures may contain synthetic private-looking fields only to prove rejection. They must declare expected failure and must never be promoted as public/reference truth.

## Schema Implications

Every Foundry/R2 artifact must declare or derive:

- `dataClass`
- `r2Allowed`
- `appCacheAllowed`
- `logAllowed`
- `fixtureAllowed`
- `runtimeRole`
- `sourceBound`
- `publicReferenceOnly`
- `localPersonalizationRequired` where runtime join is relevant
- `privacyBoundary`
- `nonClaims`

Recipes may provide composition hints only. They must not contain final user paths, final schedules, final Step lists, private eligibility decisions, or cloud personalization.

## Enforcement Paths

- `tools/source-atlas/foundry/boundary.py`
- `tools/source-atlas/foundry/validator.py`
- `tools/source-atlas/foundry/publisher.py`
- `tools/source-atlas/foundry/contracts/`
- `tools/source-atlas/foundry/tests/test_boundary.py`
- `scripts/source-atlas-boundary-audit.py`
- `scripts/source-atlas-no-private-graph-egress-audit.py`

This matrix does not prove R2 production readiness, app-side fetch/cache behavior, entitlement gating, privacy/legal approval, release readiness, or offline no-account runtime behavior.
