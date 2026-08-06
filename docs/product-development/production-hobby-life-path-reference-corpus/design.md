+++
initiative = "production-hobby-life-path-reference-corpus"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The production possibility catalog is a source-native Source Atlas product with
two deliberately separate authorities:

1. fixed public sources supply identity, labels, direct relationships,
   materials, and public overlays; and
2. a versioned Ambitions editorial manifest decides whether and how a record is
   eligible for product use.

Neither authority can do the other's job. Wikidata does not approve product
risk or recommendation use. Ambitions editorial review does not become the
factual authority over an activity, culture, organization, safety rule, or
person. The shared representation is a claim envelope and explicit relation,
not a universal `Hobby` row.

The first release includes a finite list of revision-bound Wikidata entities,
optional exact Smithsonian/Library starter materials, and independently
versioned NPS/AmeriCorps overlays. Only low-risk creative/making and knowledge/
collecting records with a complete minimum claim set expose
`recommendationDiscovery`. Service/community and physical/recreation remain
inspection-only.

A public foundry captures exact allowlisted source bytes, applies schema and
rights policies, joins the separately reviewed editorial manifest, evaluates
the candidate, and emits signed immutable shards. The app verifies, stages,
semantically validates, and atomically promotes snapshots through Source Atlas.
Local read clients accept only public selectors. No private context, interest
profile, recommendation feedback, mutation, or external action enters the
corpus.

## User flows

### Flow 1 — Browse the public possibility catalog

1. From Public reference sources/Trust, the user opens `Possibility catalog`.
2. The summary names the installed source/editorial releases, checked dates,
   eligible versus inspection-only coverage, languages/facets, and important
   exclusions. It never says “complete” or “for you.”
3. The user may browse non-exclusive facets or search installed labels locally.
   No query or selection leaves the device.
4. Results show source label, facets, public source, and eligibility state.
   `Creative/making` and `knowledge/collecting` are organizational facets, not
   personality labels. Multi-facet records remain visibly multi-facet.
5. Opening a record shows plain activity identity/description, source revision,
   editorial decision/non-claims, starter materials/overlays, and explicit
   missing practical/current facts.

### Flow 2 — Inspect why a record is eligible or restricted

1. The user opens `Why this catalog can use this`.
2. The view separates `Public source says` from `Ambitions review decided`.
3. A recommendation-eligible record shows the complete minimum claim set and
   review evidence. It does not say the activity is safe for every person or
   worthwhile.
4. A service/recreation record says `Reference only` and names the missing
   current organization/safeguarding or safety/site/legal evidence.
5. Source conflict, stale review, rights/cultural block, unknown risk, or
   harmful-label review appears as an exact restricted/unavailable state with
   correction/retry information.

### Flow 3 — Inspect starter material without rights inheritance

1. A possibility may show `Materials to explore` from exact Smithsonian or
   Library records.
2. Each item displays record identity, collection/unit, source locator, rights
   designation/advisory, media-specific state, checked date, credit, and any
   cultural/ethical caution.
3. Restricted or culturally blocked media does not render, export, or enter a
   model context even if the metadata is public/CC0.
4. Opening/copying an eligible public source URL is explicit and labeled as
   leaving Ambitions. No account, upload, publication, or derivative is created.

### Flow 4 — Inspect general public overlays

1. NPS general planning context and AmeriCorps civic statistics appear in
   separate source panels, never in the base identity description.
2. NPS always displays federal-park/general-context limitations and cannot
   change a physical activity to recommendation-eligible.
3. AmeriCorps values display methodology, population, geography, period, unit,
   freshness, and non-claims; they cannot rank communities or create a current
   service opportunity.
4. Missing/stale overlays do not remove the base identity or strengthen a
   remaining claim.

### Flow 5 — Read from the existing hobby recommendation consumer

1. A local recommendation session requests the exact
   `recommendationDiscovery` public projection and snapshot.
2. The catalog returns only eligible identities, plain public descriptions,
   facets, claim limits, coverage, and source bindings. It accepts no private
   filters or context.
3. The recommendation owner performs private local matching, keeps its
   rationale/session ephemeral as already approved, and cites the snapshot.
4. The catalog receives no viewed/selected/dismissed/adopted result and never
   widens eligibility based on use.

### Flow 6 — Use the catalog offline or partially installed

1. A representative bootstrap is available without account/network.
2. Installed source/editorial snapshots remain searchable with actual age and
   eligibility.
3. Missing starter materials or overlays are independently unavailable; base
   identities remain usable when eligible.
4. If all public data is unavailable, Today, Goals, Time, You, and existing
   private data remain usable. The recommendation consumer returns honest no-
   eligible-corpus, not fabricated results.

### Flow 7 — Stage and promote a source/editorial release

1. The foundry compiles a source lock containing fixed QIDs/revisions/entity
   JSON hashes, exact material/overlay records, rights, and editorial manifest.
2. Source acquisition has no user input. Entity APIs are used only to capture
   declared QID/revision records; subsequent builds run from locked bytes.
3. Validators reject unknown entities/fields, unreviewed relations, rights/
   cultural conflicts, expired editorial decisions, facet/risk widening,
   count/coverage drift, and evaluation failures.
4. A candidate archive downloads into isolated staging and passes existing
   public-only, size, decompression, hash/signature, and schema gates plus native
   semantic parity.
5. Promotion compare-and-swaps one immutable catalog snapshot pointer. Readers
   remain on leased old snapshots until reopened. LKG/history remain.

### Flow 8 — Correct source/editorial data or recover from failure

1. A source redirect, merge, deletion, vandalism/reversion, changed statement,
   or rights change produces a new source revision and explicit diff.
2. An editorial correction produces a new signed decision; it cannot mutate
   source history.
3. Any eligibility-affecting change invalidates dependent evaluation and
   downstream proposal evidence before the new record becomes current.
4. Invalid/partial/corrupt candidates quarantine. Retry uses identical fixed
   public artifacts or a separately approved source lock and cannot relax gates.
5. Index corruption rebuilds from verified shards; failed bytes resolve to
   verified LKG/bootstrap or unavailability.

### Flow 9 — Clear downloaded data or purge withdrawn content

1. The user may clear non-bundled public catalog downloads and return to the
   verified bootstrap without deleting private objects/history.
2. A rights, privacy/publicity, trademark, sacred/cultural, stewardship, or
   ethical withdrawal immediately disables affected projections.
3. A replayable purge removes disallowed source/media bytes, derived indices,
   extracted text, renderings, thumbnails/contact sheets, exports, and caches.
4. Only legally/ethically permitted opaque lineage remains. Interrupted purge
   resumes before the content can be used.

## States and recovery

### Orthogonal state axes

| Axis | States |
|---|---|
| artifact | bundled, downloading, staged, structurally_valid, structurally_invalid, quarantined, verified, purging, purged, unavailable |
| release | candidate, current, last_known_good, superseded, invalidated, revoked |
| source entity | current_revision, redirected, merged, deprecated, deleted, disputed, reverted, unknown |
| editorial review | unreviewed, approved, restricted, needs_revision, expired, withdrawn |
| facet resolution | single, multiple, ambiguous, none |
| risk | reviewed_low, source_check_required, safety_authority_required, protected_context_review, unknown |
| rights | cc0_record, cc0_media, free_to_use_item, attribution_required, inspection_only, reuse_blocked, review_required, withdrawn |
| cultural/ethical | reviewed, caution, consultation_required, blocked, unknown |
| freshness | current, aging, stale_allowed, stale_blocked, source_changed, superseded, unknown |
| consumer eligibility | identity_inspection, starter_material_inspection, public_overlay, recommendation_discovery, unavailable |
| evidence | untested, insufficient, pass, needs_revision, invalidated |

No axis collapses into `active`, safety, quality, confidence, or person score.
A current CC0 record can be culturally blocked; a source identity can be
eligible for inspection but not recommendation; a low-risk editorial record can
be stale; a reviewed material record can have restricted media.

### Recovery laws

- Only complete allowlisted records with current compatible source and
  editorial revisions may become current.
- Source change never automatically preserves an editorial eligibility
  decision; affected records return to review or the explicitly declared
  safe-no-semantic-change path.
- No relation is followed transitively. Redirect/merge targets require their
  own reviewed identity and migration decision.
- Independent valid records/overlays remain usable when another record fails;
  coverage exposes the exact gap.
- Promotion/rollback use immutable snapshot manifests. Readers never observe a
  mixture of source/editorial revisions.
- Retry cannot change source, rights, risk, facets, or purpose eligibility.
- Rights/cultural purge wins over history navigation when retention is blocked.
- Unknown future schema/enum values fail closed while compatible LKG remains.
- Focus recovery returns to the exact record/material/overlay, update notice,
  failed gate, retry, or purge status.

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
- Experience authority: Task 10 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and module boundaries

| Owner | Responsibility | Forbidden responsibility |
|---|---|---|
| Possibility Catalog Foundry | fixed public acquisition, structured extraction, source/rights locks, editorial-manifest join, validation, diff, coverage/evaluation input, signed archive | private query, user analytics, factual/editorial invention |
| Editorial manifest | inclusion, non-exclusive facets, risk, allowed purposes, non-claims, evidence and history | external truth, user interest/fit, current safety/provider facts |
| Source Atlas verification/cache | public firewall, transfer, bytes/schema, staging, immutable storage, snapshot pointers, LKG, quarantine, purge | source meaning, editorial waiver, private state |
| Possibility Catalog domain | source-native records/relations/materials/overlays, editorial decisions, claim eligibility, coverage | recommendation, personality, ranking, mutation |
| Catalog query actor | local indices and immutable projections | network lookup, private filters, write/feedback |
| Trust/source inspection | accessible presentation of source/editorial meaning and limits | recommendation, endorsement, safety clearance |
| Intelligence evaluation | grounding, privacy, dignity/cultural/safety/accessibility/regression evidence | source rights or release mutation |

New foundry code is isolated as cohesive `possibility_catalog_*.py` modules
under `tools/source-atlas/foundry/`. New native code lives under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/`. Existing
Source Atlas manifest, signature, cache, LKG, refresh, firewall, and inspection
owners are extended through typed interfaces. Hobby recommendation code gets a
read client only.

### Release and shard model

`PossibilityCatalogReleaseManifest` binds:

- catalog/source/editorial release IDs and schema versions;
- exact QIDs, entity revisions and JSON hashes, extraction policy, excluded
  namespaces/fields/media, acquisition/retrieval and User-Agent policy;
- exact material/overlay source IDs, records/assets, rights and checked dates;
- editorial manifest hash/signature, policy version and required evidence;
- shard IDs/dependencies, compressed/uncompressed sizes, record counts,
  hashes/signatures and minimum app version;
- eligibility-policy, validator, coverage/evaluation, invalidation,
  supersession, and claim-ceiling bindings.

The catalog uses:

- one metadata/policy/source shard;
- identity shards by a stable manifest-declared hash prefix of QID;
- one direct-relation shard containing only approved one-hop relations;
- separate starter-material metadata/media-reference shards;
- independent NPS and AmeriCorps overlay shards;
- one editorial eligibility shard; and
- derived local indices tied to the complete snapshot.

No shard selection depends on user language, location, interest, Capability, or
query. Optional large media is a separately fixed public artifact and absence
does not alter identity eligibility.

### Core public data contracts

All value types are `Codable`, `Sendable`, stable-ID and schema-versioned.

- `PossibilitySourceIdentity`: QID, revision/dump, language labels/aliases,
  description source, redirect/merge/deprecation state, extraction locator, and
  CC0 source provenance.
- `PossibilityDirectRelation`: subject/object QIDs, property, rank, direct
  source reference state, revision, editorial admission, exact meaning and non-
  transitive limitation.
- `PossibilityEditorialDecision`: stable possibility ID, source identity,
  inclusion, facets, risk, allowed purposes, description edits with source/
  editorial distinction, evidence, non-claims, language/cultural state,
  reviewer/date, expiry and supersession.
- `PossibilityStarterMaterial`: provider/unit/collection, record/media IDs,
  source locator, rights/advisory, media availability, credit, cultural/ethical
  state, checked date, transformations and claim ceiling.
- `PossibilityPublicOverlay`: base possibility relation, source/release/record,
  claim family, scope/jurisdiction/population/method/period/unit as applicable,
  freshness, limitations and non-claims.
- `PossibilityClaimEnvelope`: authority/purpose, source/editorial revisions,
  rights/cultural/freshness/risk/conflict, eligibility, missing facts,
  non-claims and inspection locator.
- `PossibilityCatalogCoverage`: exact included/restricted/rejected/missing counts
  by facet/language/cultural/geographic/risk/source/right/eligibility/reason.
- `PossibilityCatalogSnapshot`: immutable source/editorial/shard set, index
  hashes, evaluation binding, lifecycle state and pointer generation.

### Typed interfaces

```swift
protocol PossibilityCatalogReading: Sendable {
    func snapshot() async throws -> PossibilityCatalogSnapshotSummary
    func browse(
        _ request: PossibilityPublicBrowseRequest,
        in snapshotID: PossibilityCatalogSnapshotID
    ) async throws -> PossibilityCatalogPage
    func record(
        id: PossibilityCatalogID,
        in snapshotID: PossibilityCatalogSnapshotID
    ) async throws -> PossibilityProjection?
    func eligibleRecords(
        for purpose: PossibilityPublicPurpose,
        in snapshotID: PossibilityCatalogSnapshotID
    ) async throws -> PossibilityEligiblePage
    func inspection(
        claimID: PossibilityClaimID,
        in snapshotID: PossibilityCatalogSnapshotID
    ) async throws -> PossibilityClaimInspection
    func coverage(in snapshotID: PossibilityCatalogSnapshotID)
        async throws -> PossibilityCatalogCoverage
}

protocol PossibilityCatalogAdministering: Sendable {
    func stage(_ release: VerifiedPossibilityCatalogRelease) async throws
        -> PossibilityCatalogStageReceipt
    func validate(_ stagedID: PossibilityCatalogStagedReleaseID) async throws
        -> PossibilityCatalogValidationReport
    func promote(_ stagedID: PossibilityCatalogStagedReleaseID) async throws
        -> PossibilityCatalogPromotionReceipt
    func rollback(to snapshotID: PossibilityCatalogSnapshotID) async throws
        -> PossibilityCatalogRollbackReceipt
    func invalidate(_ command: PossibilityCatalogInvalidationCommand)
        async throws -> PossibilityCatalogInvalidationReceipt
    func clearDownloadedData() async throws -> PossibilityCatalogResetReceipt
    func purge(_ command: PossibilityCatalogPurgeCommand) async throws
        -> PossibilityCatalogPurgeReceipt
}
```

`PossibilityPublicBrowseRequest` contains only public facet/language/page text
selectors. Search text remains ephemeral and local. `eligibleRecords` cannot
accept a Goal, Capability, Proof, user/location ID, schedule, health/access,
relationship, recommendation context, or arbitrary source URL. Admin interfaces
are restricted to Source Atlas lifecycle owners.

### Query and projection rules

The query actor opens one immutable snapshot lease. Search normalizes
case/diacritics locally but renders source/editorial labels distinctly. It does
not infer synonyms from embeddings, expand graph relations, rank by popularity,
or persist search history.

Ordering is deterministic public presentation order: editorially reviewed
locale-aware label, then stable ID. It is not relevance, quality, or personal
ranking. Facet browse exposes multi-facet/ambiguous states. The recommendation
projection includes only `recommendationDiscovery` records and their explicit
missing facts/non-claims.

### Editorial review lifecycle

Editorial decisions are signed public product artifacts, reviewed outside the
app, and never self-modified from user behavior. A decision can remain valid
across a source release only when a deterministic diff proves no used field,
statement, redirect, rights, or meaning changed and the policy explicitly
permits carry-forward. Otherwise it expires to `unreviewed`.

Corrections create a new decision linked by `supersedes`. Rejection/removal
reasons use dignity-safe product codes and are not presented as a judgment on
the practice/community. A public correction locator may be shown; the app does
not automatically send reports or private context.

## Persistence, migration, concurrency, replay, and deletion

### Persistence layout

```text
SourceAtlas/Public/PossibilityCatalog/
  bootstrap/<snapshot-id>/
  releases/<source-family>/<release-id>/<shard-id>.sapc
  indices/<snapshot-id>/<index-id>.sqlite
  snapshots/<snapshot-id>/manifest.json
  staging/<transaction-id>/
  quarantine/<transaction-id>/
  journal/possibility-catalog-journal.jsonl
  pointers/current.json
  pointers/last-known-good.json
```

The store contains public data only. Indices are derived/rebuildable. Snapshot
manifests and lifecycle receipts are append-only. User searches, views,
selections, dismissals, interests, and private recommendation sessions are not
persisted by this owner.

### Migration from existing narrow packs

The existing `creative_project_reference`, `hobbies_recreation`, and
`volunteering_public_reference` packs stay readable as independent legacy public
sources. Migration does not copy their claims into a universal row:

1. install/verify the catalog bootstrap independently;
2. bind an existing source claim only through an exact reviewed overlay relation
   with both source hashes;
3. keep unmatched legacy claims independent and visible through existing
   inspection;
4. atomically promote the catalog snapshot;
5. mark only explicitly superseded catalog-purpose projections; and
6. retain/purge legacy bytes under their own rights.

Unknown schemas fail closed. Downgrade selects the newest compatible LKG and
does not rewrite newer artifacts.

### Concurrency, atomicity, and replay

`PossibilityCatalogCoordinator` is the single lifecycle writer actor. Source
families may download/stage concurrently, but one snapshot promotion/rollback/
purge commits at a time.

- Staging uses content-addressed immutable temp files.
- Validation is pure over declared locked bytes and manifests.
- Promotion builds indices, fsyncs immutable artifacts, writes snapshot
  manifest, then compare-and-swaps one pointer generation.
- Readers lease generations; old files remain until leases close unless a
  mandatory rights/cultural purge blocks access immediately.
- Commands use idempotency keys and return original receipts on replay.
- Crash recovery reads the journal, deletes unreferenced partial staging,
  resumes mandatory purge, and never invents a pointer/decision.

### Clear, correction, invalidation, and purge

`clearDownloadedData()` removes non-bundled snapshots after reader leases close
and selects verified bootstrap. It never touches private objects.

Source/editorial correction stages immutable supersession and invalidates
dependent evaluation/recommendation evidence. No historic signed artifact is
mutated.

Purge immediately revokes projections, then removes prohibited raw source,
media, archive/shard, index, extracted text, rendering, thumbnail/contact sheet,
model cache, export and temporary bytes. Journal/audit fields remain only when
the exact rights/cultural decision allows them. Interrupted purge resumes
before reads.

## Privacy and accessibility

### Public/private boundary

- Acquisition is compiled from fixed source locks and editorial manifests.
- Public requests contain only allowlisted source IDs/revisions/hashes.
- The Source Atlas firewall rejects arbitrary URLs/parameters and private
  types.
- Corpus artifacts, indices, logs, diagnostics, and coverage contain no private
  user/device identity, query history, interest, capability, health/access,
  location, relationships, schedule, or outcome.
- Search text is volatile local memory; no history/analytics are written.
- A later private join happens in a separate local owner and sends no feedback.

### Sensitive inference and dignity boundary

- Facets describe public catalog organization, never the user.
- No record supports personality, protected-trait, health/access suitability,
  likely enjoyment/success, proficiency, or moral/productive-value inference.
- No selection is treated as a durable interest or consent to publish,
  monetize, compete, credentialize, join, or schedule.
- Editorial language avoids shaming and exposes source wording separately when
  necessary for provenance. Harmful labels can be blocked without erasing
  source lineage permitted for audit.
- Users can ignore capability continuity and explore unrelated beginner paths;
  that behavior belongs to the consumer, not this corpus.

### Model and source boundary

A model is not used to acquire, classify, translate, merge, risk-score, rights-
clear, validate, or approve catalog records. Future model summaries may receive
only eligible public claims from a separate local/private owner, must cite exact
snapshot/claim IDs, preserve all unknowns/blocks, and cannot access admin or
mutation interfaces. Hosted transmission of private context or restricted
source material is not authorized.

### External effects and observability

Production network effects are fixed public source release fetches and explicit
user-opened public source links. There is no provider contact, membership,
reservation, purchase, account, eBird/other submission, upload, post, calendar,
message, or external write.

Operational signals may contain public release/shard IDs, byte/count/schema
results, source timings, eligibility reason counts, quarantine codes, and
device-resource measurements. They must not contain user queries, viewed/
selected possibilities, private context, or recommendation outcomes.

### Accessible interaction

- Source and editorial sections use distinct semantic headings and reading
  order.
- Every icon/color state has text such as `Reference only`, `Multiple facets`,
  `Source changed`, `Rights blocked`, `Cultural review needed`, or `Offline`.
- VoiceOver groups label, source, eligibility, limitation, and available action;
  technical detail remains a separate reachable disclosure.
- Dynamic Type reflows tables/relations to labeled cards. Long multilingual
  labels wrap and language is announced.
- Update/retry/clear/purge announcements preserve focus and use polite status.
- Reduced Motion uses direct state changes; no meaning depends on animation.
- External links announce that they leave Ambitions and do not imply
  endorsement, participation, or safety clearance.

## Requirement traceability

| Requirement | Owning design elements | Primary verification |
|---|---|---|
| REQ-001 | source lock; release model; source identity | arbitrary/unknown entity and exact-binding tests |
| REQ-002 | direct relation and non-exclusive facet rules | multi-facet and no-transitive-closure fixtures |
| REQ-003 | bounded entity extraction | revision/rank/reference/prose-media exclusion tests |
| REQ-004 | editorial decision/lifecycle | missing/expired/widened decision tests |
| REQ-005 | risk/minimum claim state machine | eligible and fail-closed matrix |
| REQ-006 | purpose eligibility; Flow 2/4 | service/recreation inspection-only tests |
| REQ-007 | starter material model; Flow 3 | metadata/media and item-rights fixtures |
| REQ-008 | independent overlay model | NPS/AmeriCorps claim-ceiling tests |
| REQ-009 | dignity boundary and projection rules | API/copy inference-negative tests |
| REQ-010 | public firewall and acquisition | private-canary byte-identity tests |
| REQ-011 | source/editorial diff lifecycle | redirect/merge/vandalism/correction tests |
| REQ-012 | rights/cultural state and purge | isolation/resumable complete-purge tests |
| REQ-013 | orthogonal state axes/envelope | state-product matrix tests |
| REQ-014 | coordinator/immutable snapshots | quarantine/promotion/LKG/replay tests |
| REQ-015 | offline/reset/correction/purge flows | lifecycle and private-nonmutation tests |
| REQ-016 | Trust projection/accessibility | inspection and assistive evidence |
| REQ-017 | coverage/evaluation binding | exact reconciliation and hard-gate suites |
| REQ-018 | read-only client; shard/resource model | boundary tests and device measurements |

## Verification design

### Foundry and contract verification

- exact QID/revision entity fixtures, structured allowlist, unknown field,
  redirect/merge/deprecate/delete/dispute/revert and malformed source;
- direct versus transitive/multi-hop relations and ambiguous multi-facet cases;
- editorial missing/expired/widened/superseded decisions and deterministic
  carry-forward;
- low-risk complete/incomplete and safety/provider/protected-context blockers;
- Smithsonian record/media rights and Library item/collection rights fixtures;
- NPS and AmeriCorps independent overlay semantics;
- rights/cultural block/withdrawal and exact purge plans;
- deterministic repeat-build hashes, release diff and exact coverage.

### Native, integration, privacy, and recovery verification

- Python/Swift schema and semantic parity;
- public request byte identity under all private canaries;
- snapshot staging/quarantine/promotion/rollback/LKG/lease/concurrency/replay;
- local label/facet browse and stable unranked ordering;
- no transitive graph, embedding expansion, popularity, profile or feedback;
- inspection-only versus recommendation eligibility;
- offline/never-fetched/clear/correction/invalidation/rights-cultural purge;
- no private persistence, model/admin leakage, mutation or external action.

### Evaluation, accessibility, and device verification

- approved evaluation suites for factual grounding, authority, unsafe omission,
  privacy, dignity, cultural/geographic/language breadth, accessibility,
  productivity framing, correction, coverage and regression;
- adversarial cases for cultural/religious/protected inference, dangerous tools/
  environments, community harm, provider/account dependency, source vandalism,
  rights versus ethical divergence, and low-risk overconfidence;
- VoiceOver, Dynamic Type, non-color, focus recovery, Reduced Motion, RTL,
  Voice Control, Switch Control and hardware keyboard;
- supported-device measurements for bootstrap/full/media-optional download and
  installed size, staging peak, validation/promotion, cold/warm browse/search,
  memory, energy, rebuild, rollback, clear and purge.

No structural pass or simulator-only result proves cultural approval, complete
safety, recommendation usefulness, physical-device budgets, merge, deployment,
or release readiness.

## Open decisions

No unresolved product decision remains. Exact first-release source IDs and
editorial decisions are governed by the fixed approved policy and must be
reviewed evidence artifacts during implementation. Adding a family to
recommendation eligibility, allowing transitive/model classification, or
changing claim ceilings must return to Scope.

Review verdict: **PASS** after one reconciliation round. Review found that
source redirects/merges could otherwise inherit eligibility; the repair makes
every changed identity require its own reviewed migration/carry-forward
decision. It also makes mandatory cultural/rights purge block active reader
access immediately and includes model caches/renderings in deletion scope.
All 18 requirements trace through user flows, visible states, typed owners and
interfaces, data flow, persistence, migration, concurrency/replay, correction,
clear/purge, privacy, dignity, model/source boundaries, external effects,
observability, accessibility, and verification.

Devan delegated approval authority for this documentation program. This Design
was approved under that authority on 2026-08-04. Approval authorizes
implementation grooming; it does not authorize or claim product/canon/source
changes, ingestion, runtime behavior, merge, deployment, or release readiness.
