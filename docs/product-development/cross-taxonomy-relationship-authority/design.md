+++
initiative = "cross-taxonomy-relationship-authority"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The Relationship Registry is an immutable public Source Atlas domain whose
unit is a versioned relationship claim, not a merged node or inferred graph.
Foundry adapters capture exact publisher mapping sets, endpoint scheme releases,
source predicates and mapping metadata, then apply a separate Ambitions
consumer-use policy. The app verifies, stages and atomically promotes signed
mapping shards. Local consumers request one exact purpose and receive explicit
edges, limits and dependency bindings.

The registry stores SKOS/SSSOM/source semantics but does not run OWL/SKOS
inference for product authority. Even when a source predicate is symmetric or
transitive, product traversal occurs only across the exact stored edge and
direction allowed by its consumer profile. Non-mapping claims never propagate.

Initial current-capable mapping sets are CIP 2010–2020, CIP 2020–SOC 2018 and
O*NET-SOC 2019–SOC 2018. O*NET–ESCO is represented as a rights/release-gated set
with separate QA partitions. CTDL/CASE alignments remain publisher claims.
Wikidata/lexical/model mappings stay candidate/review-only.

## User flows

### Flow 1 — Inspect a relationship without false equivalence

1. From a source claim, destination explanation or Trust, the user opens
   `Relationship details`.
2. The header names both source schemes/concepts/releases and displays the
   source relationship in plain language: for example `broader mapping`,
   `education-to-occupation relevance`, `moved to`, or `provider-declared
   alignment`—never bare `equivalent`.
3. Separate sections show `Source mapping says` and `Ambitions permits this for`.
4. The user can inspect mapping-set publisher/version, predicate/direction,
   method/justification/QA/review, confidence if source-published, rights,
   freshness, conflicts and exact non-claims.
5. If a consumer used the edge, `Used by` shows public dependency type/revision
   without private context. Private proposal inspection remains with its owner.

### Flow 2 — Inspect a chain or multiple routes

1. A concept pair may have multiple source edges or a visible path through
   other concepts.
2. The UI renders each edge as a separate ordered list item with source,
   predicate and versions.
3. It states `Ambitions does not combine these into a new relationship`.
4. Conflicting paths remain side by side; a majority, highest confidence or
   shortest route does not become truth.
5. Assistive users receive the same list semantics and can open each edge
   without relying on a graph/spatial view.

### Flow 3 — Use a relationship for an exact purpose

1. A local consumer requests `searchExpansion`, `destinationDiscovery`,
   `explanation`, `sourceOverlayJoin` or `versionMigration` with exact subject,
   registry snapshot and endpoint source releases.
2. The registry returns stored edges eligible for that purpose/direction plus
   non-claims, conflicts, coverage and dependency token.
3. It never returns derived transitive edges, transfers unrelated source claims
   or accepts private context.
4. The consumer records the dependency token in its own evidence. It decides
   nothing beyond its own authority and cannot feed results back.

### Flow 4 — Migrate a source concept version

1. A source owner asks for exact version-migration relations between declared
   old/new scheme releases.
2. Unchanged or source-authorized moved-to records can produce a deterministic
   migration candidate under the fixed policy.
3. Text-changed, split, merge, deleted/report-under-many or ambiguous cases
   return review-required alternatives with no automatic identity rewrite.
4. The source owner—not Relationship Registry—performs any typed migration and
   records its own receipt.

### Flow 5 — Review a candidate mapping

1. Foundry/evaluation imports a lexical/model/Wikidata/community candidate into
   an offline review set.
2. Reviewers inspect endpoint releases, proposed predicate/direction, method,
   evidence, confidence, conflicts and applicable gold cases.
3. Approve/restrict/reject/no-match creates a new signed review revision. No app
   user behavior or private query appears.
4. Until an approved product profile exists, the candidate is invisible to
   normal consumers and available only to review/evaluation tools.

### Flow 6 — Stage/promote a mapping release

1. A fixed source lock captures mapping-set bytes, endpoint release manifests,
   rights and policy revisions.
2. Foundry parsing preserves source rows/fields and creates deterministic edge
   IDs. Validators check predicates, directions, integrity conflicts,
   justification/method/QA, counts/coverage, rights and product profiles.
3. Signed immutable shards download through the public-only Source Atlas path,
   then native semantic parity validates them in staging.
4. A complete passing snapshot promotes atomically. Failure quarantines the
   candidate and preserves LKG.
5. Open readers remain bound to the old snapshot and receive `Relationship
   source updated` before reopening.

### Flow 7 — Change, invalidate or withdraw a mapping

1. Mapping-set or endpoint source change produces a typed edge/source diff.
2. Affected edges become stale/ineligible before downstream reuse.
3. The dependency index emits invalidation notices to owning local consumers;
   it does not open/edit canonical objects.
4. Consumers mark their own evidence/proposals stale and choose their own
   recovery. Accepted historic canonical events are not rewritten.
5. Rights withdrawal disables affected edges immediately and starts resumable
   purge when required.

### Flow 8 — Offline, reset and recovery

1. Bundled/LKG relationships remain inspectable offline with exact age and
   endpoint bindings.
2. Never-fetched sets are `unavailable`, never `no match`.
3. Corrupt indices rebuild from verified immutable shards. Invalid bytes fall
   back to compatible LKG/bootstrap.
4. The user can clear downloaded public relationship data/reset to bootstrap
   without changing private state or downstream owner records; those owners see
   missing/stale dependencies honestly.

## States and recovery

### Orthogonal state axes

| Axis | States |
|---|---|
| artifact | bundled, downloading, staged, structurally_valid, structurally_invalid, quarantined, verified, purging, purged, unavailable |
| mapping set | candidate, current, last_known_good, superseded, invalidated, withdrawn |
| edge review | unreviewed, source_published, approved, restricted, rejected, explicit_no_match, conflicted |
| endpoint | current_for_mapping, newer_than_mapping, changed, split, merged, deprecated, deleted, unavailable |
| freshness | current, aging, stale_allowed, stale_blocked, source_changed, superseded, unknown |
| rights | approved, attribution_required, transformation_restricted, inspection_only, review_required, withdrawn |
| consumer eligibility | inspection, search_expansion, destination_discovery, explanation, source_overlay_join, version_migration, review_only, unavailable |
| dependency | unbound, bound_current, affected, invalidated, consumer_acknowledged |
| evidence | untested, insufficient, pass, needs_revision, invalidated |

Source confidence/similarity remains metadata, not an axis that can override
review or eligibility. No generic `active`, `truth`, `equivalence` or person
confidence state exists.

### Recovery laws

- No required partial/unreviewed/unknown-predicate/wrong-endpoint/rights-blocked
  shard becomes current.
- No edge becomes eligible from source predicate alone; an exact product profile
  revision is mandatory.
- Derived chain/inverse/transitive edges are never persisted or returned.
- Source endpoint changes invalidate exact affected edges/profiles; labels do
  not retarget them.
- Independent unaffected edges remain usable and coverage exposes partiality.
- Promotion/rollback use complete immutable snapshot manifests; readers never
  observe mixed set/profile revisions.
- Retry never changes source, method, predicate, direction, rights or purpose.
- Unknown future schema/predicate/profile values fail closed while compatible
  LKG remains.
- Mandatory purge blocks affected reads immediately and wins over historical
  navigation when retention is forbidden.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 9 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and boundaries

| Owner | Responsibility | Forbidden responsibility |
|---|---|---|
| Relationship Foundry | fixed set acquisition, adapter/source metadata, validation, review-set import, deterministic build/diff/coverage | private queries, runtime inference, user decisions |
| Mapping review policy | product use profiles, forbidden propagation, candidate decision evidence | rewriting source predicate, external acceptance, user capability |
| Source Atlas verification/cache | public firewall, byte verification, staging, immutable storage, snapshots/LKG/quarantine/purge | mapping semantics or private state |
| Relationship Registry domain | mapping sets, source-native edges, review/profile states, coverage/dependencies | source concept ownership, recommendation, mutation |
| Relationship query actor | exact local edge/purpose queries and inspection | graph inference, arbitrary traversal, network, private filters |
| Dependency notifier | public edge revision impact tokens to registered local owners | editing owners' evidence/canonical state |
| Trust inspection | accessible relationship/method/limit display | equivalence/qualification/acceptance claim |
| Intelligence evaluation | gold adjudication, leakage, bias/comprehension/regression | source/profile mutation or waiver |

New foundry code is cohesive `relationship_registry_*.py` under
`tools/source-atlas/foundry/`. New native code lives under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/`.
Existing pack, signature, cache, LKG, refresh, public firewall and Trust owners
are reused. Corpus/domain owners expose source concept descriptors through
read-only public projections; the registry does not copy their full facts.

### Release and shard model

`RelationshipRegistryReleaseManifest` binds:

- registry/profile/schema releases;
- each mapping set ID/version/publisher/locator/raw hash/license/method/QA/
  coverage/source schema;
- exact endpoint scheme IDs/releases/manifests/hashes;
- source predicate vocabulary and preserved source fields;
- pinned SSSOM compatibility profile;
- product-use profile and forbidden-propagation policy versions;
- shard IDs/dependencies/sizes/counts/hashes/signatures;
- coverage/evaluation/dependency-index bindings and lifecycle state.

Shards are partitioned by mapping set and stable hash prefix of subject concept.
One mapping-set metadata shard and one conflict/no-match index accompany each
set. A compact global lookup maps endpoint typed IDs to shard IDs. Partitioning
is a fixed public function, never user/query-derived.

### Core data contracts

All public types are `Codable`, `Sendable`, schema-versioned and stable-ID
bound.

- `RelationshipConceptRef`: scheme ID/version, concept ID, source lifecycle and
  inspection label/locator.
- `RelationshipMappingSet`: source/publisher/creator/reviewer, release, method,
  rights, dates, QA partitions, coverage, endpoint schemes and source bytes.
- `RelationshipSourcePredicate`: source URI/code, family, direction/symmetry/
  inverse/transitivity as source metadata, definition and integrity rules.
- `RelationshipEdge`: stable edge ID, mapping set/revision, subject/predicate/
  object, source row, justification/evidence/method/reviewer/date/confidence/
  QA/comments and review state.
- `RelationshipUseProfile`: edge/review policy version, allowed purposes and
  directions, forbidden propagation, required endpoint states, non-claims and
  expiry.
- `RelationshipConflict`: pair/path, competing edges/predicates/sets/versions,
  review and unresolved state without winner inference.
- `RelationshipDependencyToken`: snapshot, set/edge/profile revisions,
  endpoint scheme/concept releases, direction/purpose and digest.
- `RelationshipCoverage`: exact counts by set/predicate/family/method/QA/review/
  purpose/conflict/unmapped/no-match/stale/rights.
- `RelationshipRegistrySnapshot`: immutable sets/shards/profile/index hashes,
  coverage/evaluation, lifecycle state and pointer generation.

### Typed interfaces

```swift
protocol RelationshipRegistryReading: Sendable {
    func snapshot() async throws -> RelationshipRegistrySnapshotSummary
    func relationships(
        _ request: RelationshipPublicRequest,
        in snapshotID: RelationshipRegistrySnapshotID
    ) async throws -> RelationshipPage
    func migration(
        _ request: RelationshipVersionMigrationRequest,
        in snapshotID: RelationshipRegistrySnapshotID
    ) async throws -> RelationshipMigrationProjection
    func inspection(
        edgeID: RelationshipEdgeID,
        in snapshotID: RelationshipRegistrySnapshotID
    ) async throws -> RelationshipInspection
    func coverage(in snapshotID: RelationshipRegistrySnapshotID)
        async throws -> RelationshipCoverage
}

protocol RelationshipDependencyRegistering: Sendable {
    func register(
        _ token: RelationshipDependencyToken,
        consumer: PublicRelationshipConsumerID
    ) async throws -> RelationshipDependencyReceipt
    func affectedDependencies(
        by change: RelationshipRegistryChangeID
    ) async throws -> [RelationshipDependencyImpact]
}

protocol RelationshipRegistryAdministering: Sendable {
    func stage(_ release: VerifiedRelationshipRegistryRelease) async throws
        -> RelationshipStageReceipt
    func validate(_ stagedID: RelationshipStagedReleaseID) async throws
        -> RelationshipValidationReport
    func promote(_ stagedID: RelationshipStagedReleaseID) async throws
        -> RelationshipPromotionReceipt
    func rollback(to snapshotID: RelationshipRegistrySnapshotID) async throws
        -> RelationshipRollbackReceipt
    func invalidate(_ command: RelationshipInvalidationCommand) async throws
        -> RelationshipInvalidationReceipt
    func clearDownloadedData() async throws -> RelationshipResetReceipt
    func purge(_ command: RelationshipPurgeCommand) async throws
        -> RelationshipPurgeReceipt
}
```

`RelationshipPublicRequest` contains exact typed public concept refs, purpose,
direction, mapping-set allowlist and page token. It cannot accept user/private
context, arbitrary predicates/URLs, traversal depth, inference toggle or a
request to transfer another claim. The dependency registrar stores only public
consumer/evidence identifiers; private proposal detail remains with its owner.

### Query execution and no-inference law

The query actor performs one indexed lookup for exact stored edges. It then
filters by mapping-set/endpoint/profile revision, requested purpose/direction,
review, freshness, rights and conflict state. It does not:

- recursively query neighbors;
- materialize source-declared transitive/symmetric/inverse edges;
- combine exact/close/broad/narrow/related paths;
- choose among conflicts by count/confidence;
- join or copy endpoint source claims; or
- run lexical/vector/model similarity.

Chain inspection explicitly issues independent one-edge requests and renders
them without a derived conclusion. Search expansion returns target concept IDs
only; the target corpus still owns all target facts and claim eligibility.

### Mapping review and candidate workflow

Candidate sets are public review artifacts stored separately from current
consumer shards. A deterministic review record binds candidate ID/bytes,
endpoint releases, proposed predicate/direction, method/tool/model, evidence,
gold cases, reviewer and decision. Approval creates a new product profile;
restriction/rejection/no-match never modifies source bytes.

Model/lexical mapping generation runs offline against public locked corpora. It
cannot be triggered by a user query and cannot promote itself. Model version,
prompt/config/seed/output and evaluator revisions are required evidence, not
authority.

### Dependency invalidation

Dependency tokens are content-addressed public bindings. During release diff,
the registry computes affected tokens when:

- an edge/set/profile/endpoint revision changes or disappears;
- review/conflict/freshness/rights changes purpose eligibility; or
- a mapping is corrected/withdrawn.

`RelationshipDependencyNotifier` publishes typed local impacts to registered
owners. The notification contains token and public reason only. Owners mark
their own disposable evidence/proposals stale and decide whether the user needs
review. The notifier has no canonical command client and ordinary replay does
not repeat mutation/external effects.

## Persistence, migration, concurrency, replay, and deletion

### Persistence layout

```text
SourceAtlas/Public/RelationshipRegistry/
  bootstrap/<snapshot-id>/
  releases/<mapping-set-id>/<release-id>/<shard-id>.sarr
  indices/<snapshot-id>/<index-id>.sqlite
  dependencies/dependency-index.sqlite
  snapshots/<snapshot-id>/manifest.json
  staging/<transaction-id>/
  quarantine/<transaction-id>/
  journal/relationship-registry-journal.jsonl
  pointers/current.json
  pointers/last-known-good.json
```

The store contains public mapping/consumer binding IDs only. It never stores
private inputs, recommendations, user capabilities or source corpus facts.
Indices are rebuildable from verified shards and public dependency receipts.

### Migration from existing crosswalk records

Existing generic crosswalk arrays/Wikidata candidates stay legacy review
artifacts. Migration:

1. installs the registry/bootstrap independently;
2. imports only rows whose source bytes, endpoint releases, predicate, rights
   and review can be reconstructed exactly;
3. marks all others `legacy_candidate`/unavailable, never guessing metadata;
4. creates no consumer-purpose profile from confidence alone;
5. atomically promotes the new snapshot; and
6. retains/purges legacy public artifacts under their rights.

Unknown schema/predicate/profile versions fail closed. Downgrade uses compatible
LKG without rewriting newer artifacts.

### Concurrency and replay

`RelationshipRegistryCoordinator` is the single lifecycle writer. Mapping sets
may stage concurrently; one snapshot promotion/rollback/purge commits at a time.
Promotion validates endpoint manifest availability, builds immutable indices,
fsyncs artifacts and compare-and-swaps one pointer generation. Readers lease
snapshots. Commands are idempotent by set/release/hash/operation key. Crash
replay removes incomplete staging, rebuilds derived indices, resumes mandatory
purge and never invents a review/profile/dependency decision.

### Correction, reset and purge

Corrections create immutable superseding edges/profile revisions and dependent
invalidations. `clearDownloadedData` selects bootstrap after leases close and
leaves private owners untouched; missing dependencies become unavailable.

Rights purge blocks affected reads, removes raw mapping bytes, shards, indices,
source-row text, renderings, caches, exports and prohibited dependency metadata,
then retains only explicitly allowed opaque lineage. Interrupted purge resumes
before any read.

## Privacy and accessibility

### Public/private and model boundaries

- Acquisition/source locks contain fixed public mapping/source IDs only.
- Public requests/keys/artifacts/logs/coverage never contain private context.
- Relationship queries accept typed public concept refs, not user-derived text
  or vector embeddings.
- Candidate models operate offline on locked public corpora; no private prompt
  or user query participates, and models cannot approve/promote.
- Private Capability/path/recommendation owners join locally and keep their
  private explanation/evidence; only opaque public dependency tokens register.
- The registry exposes no command/mutation/current-authority/external-action
  client.

### Bias, dignity, observability and external effects

Coverage exposes unmapped informal/cultural concepts without interpreting them
as low value. Reviewer conflict/rejection uses semantic reasons, not source/
person quality scores. Confidence is never user confidence or worth.

Allowed telemetry contains public set/edge/profile/endpoint IDs, count/schema/
timing, eligibility/conflict/invalidation reason counts and device metrics.
Forbidden telemetry includes user identity/context, queries, used destination,
Capability/Proof, private proposal or correction.

Production network effects are fixed public source release fetches and explicit
user-opened public source links. There is no application, credential/credit
request, source edit, message, upload, purchase or other external write.

### Accessible interaction

- Relationship views use ordered semantic sections and list-equivalent chains;
  spatial graphs are optional decoration only.
- Every predicate/direction/profile/conflict/status has plain text and is not
  color/icon-only.
- VoiceOver reads subject, relation direction/meaning, object, source, purpose
  and non-claim as one coherent group.
- Dynamic Type converts mapping tables to labeled cards; codes/abbreviations
  have readable accessibility labels.
- Conflict/update/retry/reset/purge announcements preserve focus. Reduced Motion
  removes graph/path animation; RTL preserves semantic direction through words,
  not arrow orientation alone.
- External links announce destination/publisher and that they do not establish
  acceptance or equivalence.

## Requirement traceability

| Requirement | Owning design elements | Primary verification |
|---|---|---|
| REQ-001 | release/mapping-set model | fixed set/endpoint/hash/schema tests |
| REQ-002 | concept refs and endpoint lifecycle | split/merge/deprecate/label-retarget tests |
| REQ-003 | source predicate/family/direction model | round-trip and generic-equivalent rejection |
| REQ-004 | edge metadata and review workflow | SSSOM/source parity and missing-metadata tests |
| REQ-005 | separate source/review records | provenance/review-state matrix |
| REQ-006 | use profile and request API | purpose-isolation tests |
| REQ-007 | no-inference query law | chain/cycle/inverse/claim-leakage tests |
| REQ-008 | version migration flow | CIP action/split/merge ambiguity tests |
| REQ-009 | conflict/candidate/rejected/no-match index | state and no-majority/absence tests |
| REQ-010 | rights model and purge | source/standard license and purge tests |
| REQ-011 | public firewall | private-canary byte identity |
| REQ-012 | independent clocks and release diff | endpoint/mapping drift tests |
| REQ-013 | coordinator/snapshots | quarantine/promotion/LKG/replay/purge |
| REQ-014 | dependency token/notifier | exact impact and no-mutation tests |
| REQ-015 | offline/reset/correction/purge | lifecycle/private-nonmutation tests |
| REQ-016 | Trust/accessibility flows | projection and assistive evidence |
| REQ-017 | coverage/evaluation binding | gold/leakage/bias/comprehension suites |
| REQ-018 | read-only typed clients | compile/runtime boundary tests |

## Verification design

### Foundry/contract/evaluation

- golden mapping sets for all fixed initial sets and source predicates;
- endpoint version mismatch/change/split/merge/deprecate/delete;
- SKOS integrity, exact/close/broad/narrow/related chain/cycle/inverse cases;
- CIP version actions and many-to-many CIP–SOC non-claims;
- O*NET-SOC granularity and O*NET–ESCO QA/right gates;
- CTDL/CASE publisher and lexical/model/Wikidata candidates;
- SSSOM/source metadata missing/round-trip/extra-field preservation;
- conflicts/rejected/no-match/unmapped, rights/withdrawal, coverage and
  deterministic repeat-build hashes;
- gold precision/recall where valid plus hard false-equivalence tests.

### Native/integration/privacy/recovery

- Python/Swift semantic parity and unknown fail-closed;
- exact one-edge/purpose/direction query behavior and no inference;
- snapshot/lease/concurrent staging/promotion/rollback/LKG/replay;
- dependency registration/diff/invalidation/no private data/no mutation;
- offline/never-fetched/reset/correction/purge and legacy candidate migration;
- public canary and no command/model/current-authority/external-action boundary.

### Accessibility/performance/device

- ordered list/optional graph equivalence, VoiceOver, Dynamic Type, non-color,
  focus/status, Reduced Motion, RTL direction language, Voice Control, Switch
  Control and hardware keyboard;
- supported-device mapping set/shard/index/dependency sizes, staging peak,
  validation/promotion, cold/warm exact query, conflict/chain inspection,
  dependency diff, rebuild, rollback, clear, purge, memory, energy, background
  budget and responsiveness;
- direct-user comprehension that exact/close/broad/narrow/related and provider
  alignment do not imply qualification/credit/mastery.

No test count, schema conformance, official source label, simulator run or high
precision score proves universal equivalence, user transfer, current acceptance,
device/accessibility approval, merge, deployment or release readiness.

## Open decisions

No unresolved product decision remains. Exact source bytes/licenses and measured
device thresholds are implementation evidence. Enabling O*NET–ESCO, a new
mapping family, automatic inference or a broader purpose profile requires
review and, when behavior widens, Scope revision.

Review verdict: **PASS** after one reconciliation round. Review found that a
dependency index could leak private proposal identity; the repair restricts it
to opaque public consumer/evidence identifiers, leaving private detail with the
owner. The query API now has no traversal-depth or inference control, preventing
consumers from bypassing the one-edge law. All requirements trace through flows,
states, types, lifecycle, persistence, migration, concurrency/replay,
invalidation, deletion, privacy, accessibility and verification.

Devan delegated approval authority for this documentation program. This Design
was approved under that authority on 2026-08-04. Approval authorizes
implementation grooming; it does not authorize or claim product/canon/source
changes, runtime behavior, merge, deployment or release readiness.
