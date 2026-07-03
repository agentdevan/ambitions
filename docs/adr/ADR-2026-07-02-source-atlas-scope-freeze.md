# ADR-2026-07-02 - Source Atlas Scope Freeze

## Status

Accepted for AMB-1680 / AMB-1725.

## Context

Source Atlas has grown enough source, tooling, QA evidence, R2 planning, and
domain-expansion material that it needs an explicit freeze boundary before any
more scope is added.

Active truth says Source Atlas and R2 are public/reference/freshness
infrastructure only. They are not the Private Life Runtime, not a private
planning authority, not a user-data backend, not a pack marketplace, and not a
place to reconstruct, profile, store, or route the private life graph.

AMB-1680 starts the freeze. AMB-1725 installs the first executable governance
slice only. This ADR does not change Swift behavior, does not add Source Atlas
scope, and does not claim production R2 proof or release proof.

## Decision

Freeze Source Atlas as boring public/reference/freshness infrastructure.

The remediation direction is binding for Source Atlas work:

- law over lore
- deep runtime, boring UI
- delete before naming
- Green requires linked evidence

Source Atlas may keep its current canonical implementation owner under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/` and its public/reference
tooling under `tools/source-atlas/`. Future scope must be justified by product
law, exact ownership, deletion or collapse of duplicate authority where
applicable, and current boundary proof. Broad architecture nouns, new split
files, new public-pack scope, or new R2 paths are not allowed because they sound
clarifying.

## Allowed Inputs

Source Atlas inputs are limited to public/reference/freshness material:

- official public source IDs, URLs, publisher metadata, license metadata, and
  authority tiers
- sourced public claim text, public requirements, public provenance, public
  source locators, content hashes, freshness timestamps, and revocation records
- public pack IDs, manifest versions, channel names, object keys, hashes,
  signatures, bundled/public cache metadata, and last-known-good pointers
- synthetic fixture data used to prove boundary acceptance or rejection
- coarse account or entitlement state only when it gates public/reference pack
  access and carries no private runtime data

Public recipes may provide composition hints only. They must not contain final
user paths, schedules, Step lists, personalized eligibility decisions, or cloud
personalization.

## Forbidden Inputs

Source Atlas must reject these inputs from request shapes, Foundry bundles,
schemas, caches, logs, fixtures intended as valid positives, R2 object keys, and
runtime bridge code:

- private life graph data
- goals, captures, goal text, capture text, closure history, proof payloads, or
  receipt payloads
- calendar data, schedule assumptions, capacity, Life Capital, or recovery
  state
- private user context, personalization, behavior history, inferred priorities,
  local profile data, private preferences, or user-specific reasoning
- account secrets, authorization headers, cookies, session tokens, API keys,
  user IDs, account IDs, phone numbers, emails, addresses, or user-keyed object
  paths
- command mutation inputs, transaction authority, event journal writes,
  projection materialization authority, side-effect authority, sync authority,
  migration authority, repair authority, or diagnostics authority that belongs
  outside Source Atlas

Negative fixtures may include synthetic private-looking fields only to prove
rejection. They must declare the expected failure and must never be promoted as
public/reference truth.

## Allowed Outputs

Source Atlas may output public/reference artifacts and redacted metadata:

- public bundle manifests, packs, schemas, shards, source registries, channel
  manifests, revocation manifests, freshness records, and last-known-good
  pointers
- validation results, blocked-source reasons, provenance IDs, hashes, timings,
  counts, issue codes, and quarantine metadata
- app-side public-reference cache records and Source inspection metadata that
  help the user understand why a public source was considered

The Private Life Runtime performs any user-specific join locally. Runtime
behavior remains governed by:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Source Atlas outputs must not bypass that chain or mutate canonical state.

## Forbidden Outputs

Source Atlas must not output, store, upload, or log:

- private life graph excerpts or reconstructed private graph shape
- final personalized plans, final schedules, final Step lists, private
  eligibility decisions, or user-specific ranking/profiling artifacts
- raw private prompts, raw private responses, local private file paths,
  secrets, authorization material, account identifiers, or unredacted URLs with
  keys
- command/event/projection/receipt writes that claim canonical authority
- user-facing architecture taxonomy, runtime depth, pack browsing, or a
  marketplace-style product center

Deep runtime may exist behind the app, but the user-facing UI remains plain,
native, object-led, and centered on Today / Goals / Time / You, global Capture,
Motion as behavior, and inspectable Trust.

## R2 Boundary

R2 is allowed only for Source Atlas public/reference/freshness artifacts. Safe
R2 interaction is public-reference metadata and public pack retrieval, with
request paths, query strings, headers, bodies, logs, cache records, and object
keys kept free of private user context.

Forbidden R2 behavior includes:

- R2 must not upload goals, captures, calendar context, schedule assumptions, closure
  history, proof, receipts, personalization, behavior history, inferred
  priorities, profile data, private user context, or the private life graph
- R2 must not use user/account/private object-key segments
- R2 must not act as a personal backend, private graph backend, planner backend, or
  hosted intelligence layer
- R2 must not block offline core Today / Goals / Time / You value when public/reference
  freshness is unavailable

Current repo proof may establish source/runtime-gate or local dry-run behavior
only when linked to current commands and artifacts. This ADR does not prove
deployed R2 behavior, app-wide R2 consumption, entitlement behavior,
privacy/legal approval, TestFlight status, App Store status, or release proof.

## Public-Pack Rules

Every public pack, shard, manifest, schema, channel pointer, R2 plan, or cache
artifact must be source/provenance-bound and declare or derive:

- public/reference data class
- source IDs and provenance IDs where claim-bearing
- content hash, byte count where applicable, version, channel, freshness state,
  and revocation state
- boundary result and non-claim ledger
- log-safe identifiers and redaction posture
- local personalization requirement where runtime join is relevant

Public-pack work is not product surface work. It must not create a pack
marketplace, pack-browsing center, Source Atlas tab, Capture replacement,
Motion surface, or private-planning authority.

## Growth Allowlist Policy

AMB-1725 adds no new Source Atlas source paths and no growth allowlist entries.

Future Source Atlas file additions, renames, or source-scope expansions require
all of the following before the source change lands:

- exact repo-relative file allowlist entry in an ADR using the checker-recognized
  format implemented by `scripts/ambitions-remediation-governance-check.py`
- linked Linear leaf that scopes the new file or rename
- boundary proof for the changed scope, including
  `python3 scripts/source-atlas-boundary-audit.py` and
  `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
- proof-status classification from `docs/truth/CODEX_START_HERE.md`
- no new private runtime authority outside `Core/LocalRuntimeOS/`
- no new `+02`, `+03`, or `+04` split files
- no new broad `Models.swift`
- delete/collapse evidence when adding new architecture nouns or duplicate
  authority

Directory-wide, wildcard, package-wide, or inferred allowlists are forbidden.
An allowlist entry permits review of the named path; it is not implementation
Green and not release proof.

AMB-1730 relocates existing legacy runtime Source Atlas files into the canonical
LocalRuntimeOS SourceAtlas owner. These allowlist entries cover the source-owner
move only; they do not add public-pack, R2, product-surface, or private runtime
scope:

- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/AnyGoalRuntimeCoverage+02-PrivacySafeCoverageRequestBuilder.swift`
- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/AnyGoalRuntimeCoverage+03-AnyGoalRuntimeCoverageEngine.swift`
- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/AnyGoalRuntimeCoverage+04-AnyGoalCoverageInput.swift`
- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/AnyGoalRuntimeCoverage.swift`
- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeClaimBoundaryHardener.swift`
- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeIngestionService.swift`
- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeProviderBoundary.swift`

## Inspection Requirements

Source Atlas work must keep inspection boring and bounded:

- users may inspect public source/provenance/freshness reasons when Ambitions
  explains a recommendation or review state
- inspection must not expose private runtime internals as first-viewport product
  depth
- logs and proof artifacts must use IDs, hashes, counts, timings, and redacted
  reasons, not raw private context
- claim status must use Implemented Green, Implemented Yellow, Partial,
  Aspirational, Deprecated, Blocked, or Unknown
- Implemented Green requires linked current evidence for the exact claim

No fake Green: docs, plans, source names, generated ledgers, or stale proof do
not prove runtime behavior, privacy/legal approval, production R2 behavior,
device behavior, accessibility, TestFlight status, App Store status, or release
proof.

## Current Evidence and Proof Ceiling

Current supporting evidence:

- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/platform/SOURCE_ATLAS_DATA_CLASSIFICATION_MATRIX.md`
- `docs/platform/SOURCE_ATLAS_ACCOUNT_ACCESS_MATRIX.md`
- `docs/platform/SOURCE_ATLAS_R2_PROMOTION_GATE_SPEC.md`
- `scripts/ambitions-remediation-governance-check.py`
- `scripts/source-atlas-boundary-audit.py`
- `scripts/source-atlas-no-private-graph-egress-audit.py`
- `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/`
- `Native/AmbitionsTests/LocalRuntimeOS/RuntimeBoundary/`

AMB-1725 claim status is Implemented Yellow: the governance ADR is installed
and can be validated, but AMB-1680 remains open until the guard, import/mutation
denylist, payload/log tests, and deletion inventory leaves are completed or
accepted Yellow with linked residual gaps.

## Follow-Up Leaves

- AMB-1726: CI guard for allowlisted growth
- AMB-1727: private graph import and mutation denylist
- AMB-1728: public-pack, R2 payload, redaction, and log tests
- AMB-1729: stale file deletion inventory

## Consequences

Positive:

- Source Atlas has an explicit freeze boundary before further scope.
- Future growth has a single repo-backed allowlist and proof path.
- R2 remains public/reference/freshness infrastructure only.
- Product UI stays plain and object-led while local runtime depth remains
  inspectable.

Tradeoffs:

- Some existing Source Atlas scope remains to be inventoried before deletion.
- Existing source/test evidence remains bounded and does not close production
  R2, privacy/legal, or release proof.
- Future Source Atlas trains must spend effort on deletion, allowlist, and proof
  before adding names or files.
