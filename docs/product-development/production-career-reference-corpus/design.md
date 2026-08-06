+++
initiative = "production-career-reference-corpus"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The production career corpus is a source-native Source Atlas product composed
of independently versioned releases, not a normalized `Career` table. A build-
time/public foundry converts fixed official archives and captured BLS records
into signed, immutable public shards. The app verifies, stages, semantically
validates, and atomically promotes those shards into the existing public cache.
Local consumers receive immutable claim-bounded projections and never send
private context back to the corpus.

The release has four independent source families:

1. O*NET 30.3 base occupation and descriptor shards;
2. SOC 2018 classification and O*NET-published relationship records;
3. OOH/Employment Projections 2024–34 profile overlays;
4. May 2025 OEWS and 2025 preliminary ORS statistical overlays.

Each preserves its own source-native identity, clock, population, geography,
measurement semantics, missingness, rights, attribution, validation, coverage,
and consumer eligibility. Shared SOC codes enable an inspectable relation but
do not merge records or transfer authority.

O*NET identities and the approved core descriptive categories form the bundled
offline launch floor. Larger BLS overlays use fixed national release artifacts
whose fetch identities never encode a user, location, Goal, or query. Design
uses source-family/major-SOC shards for atomicity and bounded local access, but
shard selection is a public release operation, not personalization.

## User flows

### Flow 1 — Inspect a production occupation

1. From the existing Public reference sources/Trust route, the user opens
   `United States career reference`.
2. The corpus summary names O*NET 30.3, SOC 2018, installed overlays, actual
   checked dates, coverage, and missing/limited source families. It never says
   recommendation-ready based only on installation.
3. Search runs locally over installed public labels and source-native IDs. No
   search text or selection leaves the device.
4. An occupation page begins with source-native identity, definition, and
   data-level/title-only/aggregate status. Categories appear only when the
   underlying claim is usable; unavailable categories remain explicitly
   discoverable through coverage/limits.
5. Selecting a claim opens existing source inspection with exact release,
   source record, authority/purpose, category/scale or statistical context,
   jurisdiction/geography/population, freshness, rights/attribution, and
   limitations.
6. Inspection-only categories are visibly labeled and cannot be confused with
   personal evidence or a recommendation signal.

### Flow 2 — Inspect source differences without flattening

1. For an occupation with overlays, the user can inspect separate panels such
   as `O*NET description`, `BLS typical preparation`, `Employment and wages`,
   and `Job requirements`.
2. Each panel names its source clock and claim type. A shared SOC relationship
   is inspectable between the records.
3. Apparent disagreement is not resolved by overwriting. The UI shows what each
   source measures, population/geography, dates, and any conflict or limitation.
4. Typical preparation never renders as a hard gate; ORS never renders as the
   user's ability; OEWS never renders as an offered/predicted salary.

### Flow 3 — Use the corpus offline

1. The bundled O*NET launch floor is immediately searchable and inspectable
   without account/network.
2. Installed BLS overlays remain available from their verified local release
   with actual age and preliminary/final state.
3. If a requested category or overlay is absent, the page keeps independent
   occupation facts visible and says exactly what reference is unavailable.
4. Today, Goals, Time, You, and local Planning remain functional even if every
   career pack is unavailable.

### Flow 4 — Stage and promote a source release

1. The public refresh registry schedules a fixed source/release manifest; no
   private context participates.
2. Download writes to an isolated staging directory and verifies public-only
   identity, size, decompression limits, bytes/hash/signature, schema, source and
   rights bindings.
3. Source-specific semantic validators account for all records, rebuild claims,
   compute release deltas, and run the required evaluation partitions.
4. A release with any mandatory hard failure is quarantined. Independent prior
   current shards remain active.
5. Passing shards promote through one atomic corpus snapshot pointer only when
   the manifest's required set is complete. Historical/last-known-good pointers
   remain.
6. Open inspection views remain bound to their old snapshot and show `Source
   updated`; choosing `Review update` opens the new revision.

### Flow 5 — Recover from invalid, partial, or interrupted refresh

1. An interrupted transfer resumes by public artifact hash where supported or
   restarts that shard; it never promotes partial bytes.
2. Schema, semantic, rights, coverage, or evaluation failure reports the exact
   source/file/claim family and quarantines only the candidate release.
3. Retry requests the same fixed public artifact or a newer approved manifest;
   it cannot relax validation.
4. Cache/index corruption rebuilds from verified immutable shards. If bytes
   fail verification, the resolver selects verified last-known-good/bundled
   data or honest unavailability.

### Flow 6 — Withdraw or purge source content

1. A signed revocation/rights manifest or verified source correction identifies
   affected source releases/records.
2. The resolver immediately removes consumer eligibility and app projections,
   then invalidates dependent evaluation/consumer evidence.
3. A purge transaction removes disallowed distributed bytes, indices, cached
   renderings, and derived searchable text.
4. Only permitted non-recoverable lineage—opaque IDs, hashes, dates, status, and
   reason—remains. Interrupted purge resumes before the content can be used.

### Flow 7 — Read from Planning or a future model

1. A local consumer requests an exact public claim family/source snapshot via a
   read client.
2. The client returns eligible public records, missingness, limitations,
   coverage, and snapshot identity. It accepts no Goal, Capability, Proof,
   schedule, location, recommendation, correction, or user identifier.
3. Planning/model code performs any private join in its own local boundary.
4. The corpus receives no feedback about which records appeared, were selected,
   corrected, rejected, or adopted.

## States and recovery

### Orthogonal release and claim states

| Axis | States |
|---|---|
| artifact | bundled, downloading, staged, structurally_valid, structurally_invalid, quarantined, verified, purging, purged, unavailable |
| release | candidate, current, last_known_good, superseded, invalidated, revoked, rights_withdrawn |
| semantic review | unreviewed, complete, incomplete, disputed, regression_detected |
| freshness | current, aging, stale_allowed, stale_blocked, source_changed, preliminary, superseded, unknown |
| rights | approved_verbatim, approved_modified, attribution_required, inspection_only, transformation_blocked, review_required, withdrawn |
| consumer eligibility | identity, descriptive, typical_preparation, work_context, labor_market_estimate, occupational_requirement_estimate, discovery_relation, inspection_only, unavailable |
| evidence | untested, insufficient, pass, needs_revision, invalidated |

These axes never collapse into a generic `active` or confidence score. A
download may be verified but semantically incomplete; a claim may be current
but rights-blocked; a title-only occupation may be identity-eligible while all
descriptive categories are unavailable.

### Source-specific visible states

- O*NET: data-level, title-only, aggregate, military, `all other`, missing
  category, collection metadata absent, category updated, release superseded.
- OOH/EP: profile present/absent, profile modified, projection period current/
  superseded, national composite limitation.
- OEWS: estimate present, suppressed, footnoted, geography/industry unavailable,
  measure not published, reference period superseded.
- ORS: detailed/group estimate, point/range, standard error present/absent,
  preliminary/final, population exclusion, estimate unavailable.

### Recovery laws

- No empty, partial, skipped, quarantined, or unreviewed required shard can
  become current.
- Independent valid claims remain usable when another source/category fails;
  the snapshot records exact partial coverage.
- Promotion and rollback operate on immutable snapshot manifests, not mutable
  rows. A reader never observes a mixed release.
- Retry never changes source, terms, validation, or claim eligibility.
- A removed current release does not reveal historical bytes when rights forbid
  retention.
- Unknown future schema and unknown eligibility values fail closed but preserve
  older supported current data.
- Focus/status recovery returns to the exact occupation, claim, failed source,
  update disclosure, retry result, or purge status.

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
- Experience authority: Task 8 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and module boundaries

The design extends, rather than replaces, the approved public-reference
foundation and existing Source Atlas delivery.

| Owner | Responsibility | Forbidden responsibility |
|---|---|---|
| Career Corpus Foundry | fixed-source acquisition, source adapter, rights manifest, semantic validation, release diff, coverage/evaluation input, signed shard production | private queries, app decisions, user telemetry |
| Source Atlas verification/cache | public firewall, transfer, byte verification, staging, immutable shard storage, atomic snapshot pointers, last-known-good, quarantine, purge | source-semantic invention or private state |
| Career Corpus domain | source-native records, measurements, statistical estimates, claim eligibility, coverage, release snapshots | personal matching, qualification, recommendation, mutation |
| Career Corpus query actor | local indices and immutable paged projections | network lookup or canonical writes |
| Trust/source inspection | accessible presentation of source meaning, state, and limits | quality score or recommendation authority |
| Intelligence evaluation | claim-family eligibility evidence and regression | source rights, release mutation, waiver |

New foundry code is isolated under
`tools/source-atlas/career-corpus/` with source adapters and schemas. New native
domain/cache/query code lives under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/CareerCorpus/`. The existing
Source Atlas manifest, signature, cache journal, last-known-good, refresh, and
public-firewall owners are reused through typed extensions. The private-input
`SourceAtlasCapabilityPathComposer` is neither imported nor called.

### Release and shard model

`CareerCorpusReleaseManifest` binds:

- corpus/source family and source release identity;
- source acquisition locator, retrieved time, content hash, archive member list,
  schema/data-dictionary revision, and fixed public artifact ID;
- exact Scope allowlist and eligibility-policy version;
- rights decision, attribution template, change/trademark requirements, and
  excluded/external members;
- shard IDs, dependencies, uncompressed/compressed sizes, record counts, and
  hashes/signatures;
- source clocks, semantic validator version, coverage/evaluation binding,
  invalidation/supersession, and claim ceiling.

The O*NET base uses one metadata shard plus shards by 2018 SOC major group. Each
occupation and related record occurs in exactly one authoritative shard; cross-
shard relations reference stable IDs. A small identity index spans all 1,016
occupations. Source files are parsed once in the foundry and projected into
shards without losing the original file/row/element identity.

BLS overlays use independent release manifests. OOH/EP records partition by SOC
major group. OEWS and ORS publish fixed national release artifacts containing
all approved geographies/populations; local indices partition them for access.
No remote request selects a user-derived region. If measurement proves that an
overlay cannot fit the supported device/storage budget, the overlay remains an
optional fixed public release rather than silently removing geography or using
private location to fetch a shard.

### Core public data contracts

All value types are `Codable`, `Sendable`, stable-ID and schema-versioned.

- `CareerCorpusOccupationRecord`: O*NET-SOC identity, title/definition,
  taxonomy/release, published occupation type/status, parent/child IDs where
  source-owned, and source row.
- `CareerCorpusDescriptorClaim`: occupation, claim family, O*NET source file,
  element/task/category ID, source text/value, scale/anchor/measurement,
  collection/update metadata, eligibility, and claim envelope.
- `CareerCorpusRelationshipClaim`: source/target native IDs, source-owned
  relation kind/direction/rank, releases, limitations, and discovery eligibility.
- `CareerCorpusBLSProfileClaim`: OOH/EP profile field, SOC identity, profile/
  projection revision, national-composite limitation, and claim envelope.
- `CareerCorpusStatisticalEstimate`: source family/series, SOC, reference period,
  population/exclusions, geography/industry, measure/unit/statistic, value or
  range, standard error/reliability, suppression/footnotes, preliminary/final,
  methodology locator, and eligibility.
- `CareerCorpusRightsBinding`: release/member, permitted use, attribution,
  modification/trademark instruction, exception/withdrawal state, review, and
  evidence reference.
- `CareerCorpusCoverage`: source/release/claim family, expected/accounted/usable/
  missing/suppressed/blocked counts, exclusions, evaluation binding, and claim
  ceiling.
- `CareerCorpusSnapshot`: immutable manifest IDs and hashes for every installed
  source family/shard, promotion time, previous snapshot, current limitations,
  and invalidation state.

Raw numeric values are stored with their source scale and unit; display
formatting never replaces them. Null, zero, suppressed, not-collected,
not-applicable, and unavailable are distinct. Source text and Ambitions plain-
language explanation are separate fields with separate attribution.

### Typed interfaces

```swift
protocol CareerCorpusSnapshotResolving: Sendable {
    func currentSnapshot() async -> CareerCorpusSnapshotResolution
}

protocol CareerCorpusQuerying: Sendable {
    func occupations(_ query: CareerCorpusPublicQuery) async
        -> CareerCorpusOccupationPage
    func claims(_ query: CareerCorpusClaimQuery) async
        -> CareerCorpusClaimPage
    func coverage(_ query: CareerCorpusCoverageQuery) async
        -> CareerCorpusCoverageProjection
}

protocol CareerCorpusReleaseStaging: Sendable {
    func stage(_ verifiedArtifact: SourceAtlasVerifiedPublicArtifact) async throws
        -> CareerCorpusStagedRelease
    func validate(_ release: CareerCorpusStagedRelease) async
        -> CareerCorpusReleaseValidation
    func promote(_ candidate: CareerCorpusPromotionCandidate) async throws
        -> CareerCorpusPromotionReceipt
}

protocol CareerCorpusReadClient: Sendable {
    func publicClaims(_ request: CareerCorpusConsumerRequest) async
        -> CareerCorpusConsumerProjection
}
```

`CareerCorpusPublicQuery` contains only public text/IDs, paging, public locale,
and installed-source filters and never crosses the network boundary.
`CareerCorpusConsumerRequest` contains source/occupation/claim-family/snapshot
selectors only. There is no user ID, Goal, Capability, Proof, schedule,
location, preference, recommendation, feedback, command, or mutation method.

### Foundry-to-device data flow

```text
fixed official archive/page/data release
              |
              v
 public acquisition + byte/source/rights ledger
              |
              v
 source-specific adapter -> source-native records
              |
              v
 semantic/coverage/evaluation gates -> release diff
              |
              v
 signed immutable source-family shards + manifest
              |
        fixed public registry
              |
              v
 app firewall -> download -> byte verification -> staging
              |
              v
 native semantic parity validation -> atomic snapshot promotion
              |
       local indices/read client
          |              |
          v              v
 source inspection   local Planning/model consumer
```

The foundry records original bytes and evidence in the controlled public build
workspace; the app package contains only approved transformed records and
required attribution. Foundry and native validators share golden manifests and
must produce equivalent accounting/eligibility results.

### Persistence, migration, and deletion

Career shards, release manifests, validation results, coverage, indices, and
snapshot pointers live in the existing public-reference cache boundary, not the
canonical private store. Shards are immutable and content-addressed. Search/
relation/geography/source indices are rebuildable and never own claims.

The narrow O*NET 30.3 software-developer validation pack remains independently
identifiable. Migration installs the new career-corpus schema and bundled base,
then marks the old validation pack inspection lineage as superseded; it does not
reinterpret or copy its claims into the new IDs. If new installation fails, the
old validation pack and private core remain unchanged. After verified promotion,
redundant old bytes may be purged according to existing public-cache policy.

No private-data migration exists. Uninstall/reset public references removes
downloaded BLS overlays and rebuildable indices while preserving the bundled
launch floor. A rights revocation can purge bundled content only through an app
update or signed disabling manifest plus removal from projections; no disallowed
bytes may be exportable or searchable.

### Concurrency, replay, and consistency

- A `CareerCorpusCoordinator` actor owns stage/validate/promote/rollback/purge
  transitions and serializes snapshot pointer mutation.
- Reads acquire an immutable `CareerCorpusSnapshotToken`; paging and inspection
  stay on that snapshot even if refresh completes concurrently.
- Transfers can run concurrently by independent shard with a fixed bound;
  validation canonicalizes record and finding order before hashing.
- Staging journals are idempotent by release/shard/hash. Duplicate completion
  cannot duplicate shards or promote twice.
- Promotion uses an atomic snapshot-manifest pointer after all required shard
  dependencies and native parity checks pass.
- Refresh, rollback, and purge receipts are replayable public events. Indices
  rebuild from verified shards and the active snapshot.
- A foundry run is reproducible from the exact source bytes, adapters, schemas,
  rights ledger, and clock. A live page capture is preserved as exact input; a
  later capture is a new source revision, not replay of old web state.
- Cancellation leaves staged artifacts resumable/quarantined and never changes
  current.

### Invalidation and change handoff

A reverse index maps source release/member/record, rights decision, schema,
semantic policy, evaluation suite, and claim ID to projections/evidence. Source
change or withdrawal appends an invalidation record, changes current eligibility,
and notifies read-only consumers through snapshot revision. It does not command
them to mutate. `intelligence-change-management` later consumes release diff,
coverage, evaluation, performance, and invalidation records but cannot waive
hard source/rights/privacy failures.

### Observability without private leakage

Local/public diagnostics may include fixed artifact/source/release/shard IDs,
byte counts, durations, record counts, validation codes, coverage totals,
snapshot IDs, retry/rollback outcomes, and redacted errors. They exclude local
search text, selected occupation, private location, Goals, Capabilities, Proof,
schedule, recommendation/adoption/correction/rejection, and rendered private
context. Foundry logs contain only public-source acquisition and build data.
Private canaries run across endpoint, headers, request, object key, cache,
filenames, logs, diagnostics, analytics, crash material, and feedback.

### Canon handoff

Implementation grooming will add a production career-corpus section to
`docs/canon/specifications/systems/source-atlas.md` and narrow statistical and
inspection vocabulary to `docs/canon/specifications/objects/source-reference.md`,
`docs/canon/specifications/global/trust-inspection.md`, and
`docs/canon/specifications/systems/privacy-and-data-classification.md`. It will
cross-reference the new intelligence-evaluation spec if that initiative has
landed. No new root surface, private-public owner, or recommendation authority
is introduced.

## Privacy and accessibility

### Privacy and sensitive-inference controls

- Acquisition manifests and remote refresh requests are predetermined public
  release identities. A public country-wide BLS overlay contains all approved
  geographies; the user's location never chooses a remote shard.
- Local search and consumer requests never cross the public gateway. No
  selection/adoption/correction feedback enters foundry, Source Atlas, R2,
  analytics, or logs.
- App public shards contain no user graph data. The native decoder rejects
  private data classes/markers and unexpected fields even after signature pass.
- Abilities, Work Styles, Interests/Basic Interests, emerging tasks, software/
  technology designations, and sensitive relationship categories carry an
  unforgeable restricted-eligibility value. Generic consumers cannot request
  them without a separately typed inspection/research purpose.
- Statistical records cannot form a person score or rank human/career worth.
  ORS projections include an explicit no-individual/no-accommodation claim
  ceiling. Missing/sparse data cannot become negative personal evidence.
- Export/share of source inspection includes only the selected public record,
  source/attribution, and limitations; it never attaches the private reason the
  user inspected it.
- Public-reference reset removes downloaded overlays and indices. Rights purge
  removes disallowed bytes and derived text. Neither operation changes private
  canonical state.

### Accessible inspection and recovery

- Occupation/source headings, data-level status, claim kind, value, population,
  geography, dates, preliminary/suppressed state, source, attribution,
  limitations, eligibility, and recovery actions have native semantic labels,
  values, traits, headings, and ordered grouping.
- Tables have list/card alternatives whose reading order includes row/column
  meaning. Abbreviations such as SOC, OEWS, ORS, standard error, and percentile
  have localized spoken expansions.
- Complete, title-only, aggregate, missing, suppressed, preliminary, stale,
  conflicted, rights-blocked, updated, downloading, invalid, offline, and
  unavailable states use redundant text and symbols; color/graph position is
  never required.
- Dynamic Type through accessibility sizes, increased contrast, reduced motion,
  RTL, VoiceOver, Voice Control, Switch Control, and hardware keyboard preserve
  search, filters, disclosures, source links, retry, update review, reset, and
  focus restoration.
- Release deltas are described in text; animation is optional. Screen updates
  announce the exact claim/source result without moving focus unexpectedly.
- Long official text and attribution remain selectable/scrollable without
  truncation. Plain-language explanation never replaces exact source text or
  numerical/statistical context.

## Requirement traceability

| Requirement | Design decisions | Primary verification |
|---|---|---|
| `REQ-001` | Versioned source-native models, release manifests, stable IDs, duplicate/reuse failure | Golden decode, ID accounting, release-delta tests |
| `REQ-002` | 1,016-entry identity index and explicit occupation status; no implicit inheritance | Full-release accounting and title-only/aggregate cases |
| `REQ-003` | Manifest-bound normative file allowlist and restricted eligibility | File/member matrix and forbidden-consumer tests |
| `REQ-004` | Typed measurements, scales, anchors, null/suppression semantics | Source-row round-trip and cross-scale rejection |
| `REQ-005` | Independent SOC/OOH/EP/OEWS/ORS records/manifests/snapshots | Overlay identity/clock/authority tests |
| `REQ-006` | Statistical-estimate contract with population/geography/method/reliability/suppression/preliminary state | OEWS/ORS/projection golden and misuse-negative cases |
| `REQ-007` | Typical-preparation eligibility and no hard-gate projection | OOH/O*NET display and consumer-negative tests |
| `REQ-008` | Member-specific rights ledger, attribution builder, excluded-content policy, purge | Rights/attribution golden, exception and withdrawal tests |
| `REQ-009` | Fixed public artifacts, country-wide overlay, local-only queries, private-marker rejection | Request/cache/log/feedback canary audit |
| `REQ-010` | Independent clocks and immutable snapshot invalidation/supersession | Source-change matrices and last-known-good lineage |
| `REQ-011` | Stage/validate/evaluate/atomic promote, quarantine, rollback coordinator | Fault injection at every transition |
| `REQ-012` | Orthogonal artifact/semantic/rights/freshness/eligibility/evidence axes and per-claim coverage | Mixed-state and high-aggregate/one-failure cases |
| `REQ-013` | Typed directed source-owned relationship with discovery-only ceiling | Direction/granularity/removal and no-equivalence tests |
| `REQ-014` | Immutable private-free read client with no command/mutation API | Compile-time boundary and runtime mutation-negative tests |
| `REQ-015` | Restricted sensitive categories, no score/ranking, ORS claim ceiling, aspiration counterfactuals | Static/API and dignity/counterfactual cases |
| `REQ-016` | Bundled base, installed overlay fallback, independent partial availability | Offline/no-account and corrupt-overlay scenarios |
| `REQ-017` | Native semantic inspection, list alternatives, spoken abbreviations, complete state matrix | Accessibility unit/snapshot/simulator/device evidence |
| `REQ-018` | Signed invalidation, immediate eligibility removal, resumable byte/index purge, permitted lineage | Withdrawal/purge interruption and residual scan |
| `REQ-019` | Foundry/native parity, claim-family coverage/evaluation bindings and hard gates | Coverage denominators, sampled truth, regression suite |
| `REQ-020` | Ordinary/regulated/competitive/title-only/aggregate/sparse/suppressed/preliminary/failure fixtures | End-to-end portfolio evaluation report |

## Verification design

### Foundry and source-fidelity proof

- Verify exact official source bytes, release/member hashes, schemas, data
  dictionaries, rights evidence, attribution, excluded content, and reproducible
  adapter output.
- Account for all O*NET occupation identities and every normative archive member;
  reconcile expected, parsed, usable, inspection-only, missing, rejected, and
  rights-blocked counts.
- Golden-sample every claim family across ordinary, regulated, competitive,
  title-only, aggregate, sparse, and `all other` occupations with independent
  factual/authority adjudication.
- Round-trip source numeric values/scales/anchors and BLS population/geography/
  method/standard-error/range/suppression/footnotes/preliminary metadata.
- Differential tests across prior/current release fixtures prove schema changes,
  record splits/merges, withdrawal, and eligibility invalidation.

### Native, persistence, migration, and recovery proof

- Foundry and Swift decoders/validators must accept/reject identical golden
  manifests and produce equivalent ID/coverage/eligibility accounting.
- Byte/signature/schema/source/rights/semantic/evaluation failures, decompression
  limits, disk full, cancellation, process kill, duplicate delivery, corrupt
  index/cache, and pointer interruption preserve current/last-known-good.
- Prove readers never observe mixed snapshots and open inspection remains bound
  during promotion/rollback/purge.
- Migrate from the narrow validation pack by fresh additive installation and
  supersession only; prove no ID reinterpretation, private migration, or lost
  fallback. Unknown future schema fails closed.
- Interrupt rights purge at every phase and prove resume plus zero recoverable
  disallowed content in shards, indices, render caches, exports, and search.

### Privacy, authority, safety, and bias proof

- Canary all private categories through foundry, network, R2/object keys,
  cache, logs, diagnostics, analytics, crash material, local queries, exports,
  and feedback; expected remote/private byte count is zero.
- Static ownership tests ensure Career Corpus cannot import canonical command
  clients, personal models, recommendation mutation, or production external
  operations.
- Negative cases prove restricted O*NET categories cannot enter generic consumer
  projections, estimates cannot become personal claims, typical preparation
  cannot become a gate, and source relations cannot become identity/fit/path.
- Counterfactual/slice tests detect aspiration loss, wage/prestige ranking,
  demeaning language, disability/accommodation overclaim, and sparse-data
  exclusion.

### Accessibility, runtime, and device proof

- Unit and rendered matrices cover every visible source/release/occupation/
  statistic/failure state, long source text, long attribution, large counts,
  localization/RTL, Dynamic Type, contrast, and reduced motion.
- Simulator interaction covers local search, occupation detail, separate source
  panels, statistical disclosure, offline fallback, update review, retry, reset,
  and focus/status restoration under accessibility inspection.
- A supported physical iPhone proves install/upgrade, bundled offline search,
  background/foreground refresh, protected storage transitions, snapshot
  consistency, rollback, purge/reset, VoiceOver order, largest Dynamic Type,
  keyboard/Voice Control/Switch Control paths, and relaunch.
- Direct-user recommendation usefulness remains N/A. A comprehension study is
  required before claiming users understand the expanded source/statistical
  presentation; its evidence stays separate.

### Performance and resource proof

- Measure source archive/shard/app/download sizes, install/update delta, peak
  decompression and validation memory, launch index open, local search, claim
  query, paging, promotion, rollback, index rebuild, and purge on the supported
  launch-floor physical device.
- Establish budgets from measured baseline before merge; do not invent numbers
  in documentation. If the bundled base exceeds the product budget, return to
  Scope rather than silently dropping occupation/category coverage.
- Verify bounded transfer/validation concurrency and no main-actor blocking.

### Build and repository proof

- Focused foundry/adapter/rights/coverage tests, native domain/cache/query/
  inspection tests, full Python and Ambitions suites, build-for-testing, and
  simulator/device lanes must record exact commands/counts.
- Regenerate `Ambitions.xcodeproj` from `project.yml`; recursive source globs are
  expected to cover new Swift files. Do not hand-edit generated state.
- Run canon compiler/checks after future canon edits, Source Atlas public-boundary
  audits, local-first/direct-write/static checks, SwiftLint, secrets scanning,
  and `git diff --check`.
- Evidence labels distinguish source/right review, foundry output, native decode,
  automated, build, simulator, physical-device, accessibility, privacy,
  performance, direct-user, recommendation, merge, deployment, and release.

## Open decisions

No unresolved product decision remains. Implementation may choose concrete
compression, index, and serialization mechanisms only if they preserve exact
source-native identity, fixed public artifacts, the normative category policy,
immutable snapshots, public-only storage, measured launch-floor feasibility,
read-only consumer boundaries, and all failure/withdrawal behavior. A need to
drop required coverage, fetch user-derived regional shards, flatten source
families, broaden restricted eligibility, or retain withdrawn bytes must return
to Scope.

## Review and approval

Review verdict: **PASS**. The Design was checked against all 20 approved Scope
requirements and for complete user/recovery flows, source-family ownership,
typed read-only interfaces, foundry-to-device flow, source-native measurements,
immutable persistence and migration, concurrency/replay, rollback/purge,
public/private separation, sensitive-inference controls, non-leaking
observability, accessibility, performance, and verification. The design leaves
no source-semantic, rights, authority, or product decision to implementation.

Devan delegated approval authority for this documentation program. This Design
was approved under that authority on 2026-08-04. Approval authorizes
implementation grooming only; it does not claim ingestion, canon/source/tests,
runtime or device proof, recommendation use, merge, deployment, or release.
