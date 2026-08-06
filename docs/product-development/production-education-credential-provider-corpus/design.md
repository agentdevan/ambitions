+++
initiative = "production-education-credential-provider-corpus"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The production education corpus is a source-native Source Atlas product, not a
normalized school marketplace. A public foundry converts fixed official source
releases into signed immutable shards. The app verifies, stages, semantically
validates, and atomically promotes those shards through existing public-cache
infrastructure. Local consumers receive immutable claim-bounded projections and
never send private context back to the corpus.

The first corpus has four independent source families:

1. CIP 2020 classification and official edition-crosswalk records;
2. an exact IPEDS institution/survey release set;
3. an exact College Scorecard institution/field-of-study release set; and
4. an exact DAPIP agency/recognition/action download.

Each preserves source-native identifiers, release/component/cohort clocks,
population, definitions, processing/suppression, scope, rights, coverage, and
consumer eligibility. Cross-source identity is an explicit assertion with its
own evidence and state. It never merges records by name or transfers authority.
CTDL and CASE models are present as disabled source families; no record is
packable until an approved source-rights manifest enables the exact feed or
framework.

A representative bootstrap is bundled. Larger source-family shards are fixed
public artifacts whose identities never encode a user, location, Goal, or
query. Sharding supports device budgets and atomic updates; it is not remote
personalization.

## User flows

### Flow 1 — Inspect an institution or field record

1. From the existing Public reference sources/Trust route, the user opens
   `United States education reference`.
2. The summary names CIP, IPEDS, Scorecard, and DAPIP exact releases, checked
   dates, installed coverage, and unavailable/right-blocked layers. It never
   equates installation with recommendation readiness.
3. Search runs locally over installed public labels and source IDs. No search
   text or selection leaves the device.
4. An institution page presents separate source panels: `Institution identity`,
   `Reported fields and credentials`, `Published measures`, and `Reported
   recognition`. Panels appear only when their exact claims are eligible;
   missing/suppressed/ambiguous states remain inspectable.
5. Selecting a claim opens exact source release, record, definition, cohort,
   processing/suppression, recognition scope, identity relation, freshness,
   rights, and limitations.
6. The page never shows a total score, quality rank, personal result, or
   “recommended because of your profile.”

### Flow 2 — Inspect a field of study without creating an offering

1. The user searches a CIP title or code locally.
2. The field page shows CIP hierarchy/description and exact edition.
3. Historical IPEDS completions and eligible Scorecard field measures appear as
   separate observations with institution, award level, cohort/year, and
   coverage.
4. If there is no approved current-offering record, the page says `Current
   offering not established by this corpus`.
5. A CIP crosswalk is labeled as a source-published edition relationship, never
   identity or competency equivalence.

### Flow 3 — Inspect recognition without overclaiming

1. The user opens a DAPIP-sourced record.
2. The view names the reporting/recognized agency, institution/program/site,
   exact scope, action/status, dates, dataset retrieval, and Department
   disclaimer.
3. Institution-level recognition does not appear on a program or sibling site
   unless an exact DAPIP record applies.
4. For material current use, `Verify with agency` opens or copies the public
   agency locator only after explicit user action. It performs no submission or
   private query.
5. Transfer, licensure, admissions, and current standing remain explicitly
   unknown unless their future owning source provides an eligible claim.

### Flow 4 — Compare source measures without ranking

1. A user can inspect eligible public dimensions such as historical price,
   completion, debt, or earnings.
2. Each measure retains its source, cohort, population, year/horizon, unit,
   processing and suppression state.
3. Measures are never combined into a score or sorted by an implicit “best.”
   A later consumer may present user-selected dimensions, but the corpus emits
   only typed values and limits.
4. Suppressed or incomparable measures remain visibly unavailable; the UI does
   not estimate them or interpret absence as poor performance.

### Flow 5 — Use the corpus offline

1. The bundled representative bootstrap is searchable and inspectable without
   account/network.
2. Installed full/sharded releases remain available with their actual age and
   release state.
3. If one source family is absent, independent eligible records remain usable
   and the exact unavailable coverage is shown.
4. Today, Goals, Time, You, and local Planning remain functional even if every
   education public pack is unavailable.

### Flow 6 — Stage and promote a release

1. The public refresh registry schedules a fixed source/release manifest; no
   private context participates.
2. Transfer writes to isolated staging and verifies public-only identity,
   compressed/uncompressed size, decompression bounds, bytes/hash/signature,
   schema, source and rights bindings.
3. Source-specific validators account for records/fields, reconstruct claim
   semantics, validate source counts, create identity assertions, compute
   release deltas, and run evaluation partitions.
4. Any required hard failure quarantines the candidate. Existing current
   source-family snapshots remain active.
5. A complete passing corpus snapshot promotes atomically; historical and
   last-known-good pointers remain.
6. Open views stay bound to their original snapshot and announce `Source
   updated`; the user may reopen against the new snapshot without focus loss.

### Flow 7 — Recover from interruption or corruption

1. An interrupted public transfer resumes by artifact hash where supported or
   restarts the affected shard; partial bytes never promote.
2. Schema, semantic, rights, count, identity, evaluation, or device-budget
   failure reports the exact source/release/file/field and quarantines only the
   candidate.
3. Retry uses the same fixed public artifact or a separately approved newer
   manifest; validation cannot be relaxed.
4. Index corruption rebuilds from verified immutable shards. Failed source
   bytes resolve to verified last-known-good/bootstrap or honest unavailability.

### Flow 8 — Correct, withdraw, clear, or purge content

1. A signed revocation/rights manifest or verified source correction identifies
   affected release/records/claims.
2. Consumer eligibility is removed immediately and dependent evaluation/
   proposal evidence is invalidated.
3. A source correction stages a new immutable revision and explicit
   supersession; historical values are not silently rewritten.
4. A user may clear downloaded corpus data and return to the bundled bootstrap
   without affecting private records.
5. When rights require purge, a replayable transaction removes prohibited
   bytes, indices, extracted text, thumbnails/renderings, and derived caches.
   Only legally permitted opaque audit lineage remains.

### Flow 9 — Read from Planning or a model

1. A local consumer requests an exact public claim family and corpus snapshot
   through a typed read client.
2. The client returns eligible records, source meaning, missingness,
   limitations, coverage, identity state, and snapshot binding. It accepts no
   private value.
3. Planning/model code performs any private join within its own local boundary
   and must retain citations to every used public claim.
4. The corpus receives no feedback about which record appeared, was selected,
   corrected, rejected, or adopted.

## States and recovery

### Orthogonal state axes

| Axis | States |
|---|---|
| artifact | bundled, downloading, staged, structurally_valid, structurally_invalid, quarantined, verified, purging, purged, unavailable |
| release | candidate, current, last_known_good, superseded, invalidated, revoked, rights_withdrawn |
| source processing | reported, imputed, derived, suppressed, not_applicable, missing, revised, unknown |
| semantic review | unreviewed, complete, incomplete, disputed, regression_detected |
| freshness | current, aging, stale_allowed, stale_blocked, preliminary, final, source_changed, superseded, unknown |
| rights/access | approved_verbatim, approved_modified, attribution_required, individual_access_only, bulk_approval_required, research_agreement_required, inspection_only, transformation_blocked, review_required, withdrawn |
| identity assertion | confirmed, ambiguous, conflicting, superseded, unmapped |
| consumer eligibility | classification, institution_identity, historical_completion, descriptive_cost, descriptive_aid, descriptive_outcome, reported_recognition, source_relationship, inspection_only, unavailable |
| evidence | untested, insufficient, pass, needs_revision, invalidated |

These axes never collapse to a generic `active`, confidence, or quality score.
A file may be byte-valid but semantically incomplete; a record may be current
but rights-blocked; an identity claim may be confirmed while an outcome is
suppressed; an institution may be visible while its current offering remains
unknown.

### Source-specific visible states

- CIP: current edition, historical edition, added, deleted, split/combined
  crosswalk, hierarchy unavailable, unmapped.
- IPEDS: in-universe/out-of-universe/unknown, active/closed/merged as published,
  reported/imputed/derived/suppressed/not-applicable, provisional/final/revised,
  component year present/missing.
- Scorecard: institution/field record present, cohort unavailable, measure
  unavailable, privacy suppressed, source year, field/credential-level
  aggregate, revised.
- DAPIP: institution/program/site record, reported action/status, effective/end
  date, recognized-agency scope, possibly stale, agency verification required,
  entity identity ambiguous/conflicting.
- CTDL/CASE: adapter supported, source unreviewed, bulk approval required,
  content rights blocked, publisher record eligible, withdrawn.

### Recovery laws

- No partial, unknown-field, skipped, quarantined, unreviewed, or incomplete
  required shard becomes current.
- Independent eligible source claims remain usable when another source or
  identity relation fails; the snapshot carries exact partial coverage.
- Promotion and rollback use immutable snapshot manifests. Readers never
  observe mixed source-family releases inside one snapshot binding.
- Retry never changes source, access, terms, validation, or claim eligibility.
- A right-withdrawn release is not recoverable through history when retention
  is forbidden.
- Unknown future schemas and enum states fail closed while preserving older
  supported current data.
- Focus/status recovery returns to the exact institution/field/claim, failed
  source, update disclosure, retry result, or purge status.

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
| Education Corpus Foundry | fixed-source acquisition, source adapters, semantic/rights manifests, validation, identity assertions, release diff, coverage/evaluation input, signed shard production | private queries, app decisions, user telemetry |
| Source Atlas verification/cache | public firewall, transfer, byte verification, staging, immutable shard storage, atomic snapshot pointers, last-known-good, quarantine, purge | source-semantic invention or private state |
| Education Corpus domain | source-native records/measures, identity assertions, claim ceilings, coverage, release snapshots | personal match, ranking, acceptance, recommendation, mutation |
| Education Corpus query actor | local indices and immutable paged projections | network lookup or canonical writes |
| Trust/source inspection | accessible presentation of source meaning/state/limits | quality score, endorsement, recommendation authority |
| Intelligence evaluation | grounding, eligibility and regression evidence | source rights, release mutation, waiver |

New foundry code is isolated as cohesive `education_corpus_*.py` modules under
`tools/source-atlas/foundry/`. New native domain/query code lives under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/EducationCorpus/`. Existing
Source Atlas manifest, signature, cache journal, last-known-good, refresh,
remote-transport, and public-firewall owners are reused through typed
extensions. Private-capability/path composers are not imported or called.

### Release and shard model

`EducationCorpusReleaseManifest` binds:

- corpus and source-family release identities;
- acquisition locator, retrieved time, content hash, archive members, source
  schemas/data dictionaries, and fixed public artifact IDs;
- exact Scope allowlist and semantic-manifest version;
- source component/collection/cohort/reference years;
- rights/access decision, attribution, transformation/retention/withdrawal,
  excluded assets/fields, and review evidence;
- shard IDs, dependencies, compressed/uncompressed sizes, record counts,
  hashes/signatures, and minimum app/schema versions;
- source clocks, validator versions, identity-policy version, coverage and
  evaluation bindings, invalidation/supersession, and claim ceilings.

The bootstrap uses one compact metadata/identity shard plus representative
records for all four first-release families and adversarial states. Full source
releases use:

- one CIP taxonomy/crosswalk shard;
- IPEDS identity shards by a stable public institution partition and separate
  component/year value shards;
- Scorecard institution and field-of-study shards by the same public partition;
- DAPIP agency plus entity/action shards by stable source identifiers; and
- one explicit identity-assertion index that references, never rewrites,
  source-native IDs.

The partition is declared in the release manifest and never derived from user
location or intent. If measurement proves the full installed corpus exceeds
supported budgets, additional fixed public partitions may be optional; the
coverage report and downstream eligibility must expose what is absent.

### Core public data contracts

All value types are `Codable`, `Sendable`, schema-versioned, and stable-ID
bound.

- `EducationCorpusSourceRelease`: publisher/source, release/component IDs,
  retrieval, bytes/schema/data dictionary, rights/access, freshness,
  attribution, limitations, and supersession.
- `CIPClassificationRecord`: edition, code, hierarchy level, title,
  description, status, parent, and source locator.
- `CIPEditionRelationship`: source/target editions/codes, source-published
  relationship type, notes, and non-identity limitation.
- `IPEDSInstitutionRecord`: UNITID, source identity/name, location and
  classification fields admitted by the allowlist, universe/active/closure/
  merger state where published, component/year, and source processing.
- `IPEDSObservation`: UNITID, component, variable, CIP/award level where
  applicable, population, year, value/unit, processing state, definition,
  footnote, and claim ceiling.
- `ScorecardObservation`: UNITID/OPEID, CIP/credential level where applicable,
  measure ID, cohort/source years, population/coverage, value/unit,
  suppression/missingness, definition, and limitation.
- `DAPIPRecognitionRecord`: source entity/program/site and agency IDs,
  recognition/action/status/scope, dates, locations where source-owned,
  dataset retrieval, disclaimer, and agency verification locator.
- `EducationIdentityAssertion`: left/right typed IDs, relationship scope,
  source/method/evidence, version, review, confirmed/ambiguous/conflicting/
  superseded/unmapped state, and prohibited traversal rules.
- `EducationCorpusClaimEnvelope`: claim family, authority/purpose, source
  release/record, rights, freshness, processing/suppression, identity state,
  conflict, eligibility, non-claims, and inspection locator.
- `EducationCorpusCoverage`: exact counts and eligibility/ineligibility reasons
  by source/release/component/cohort/claim/identity/rights/state.
- `EducationCorpusSnapshot`: immutable source-release/shard set, index hashes,
  coverage/evaluation binding, promoted/superseded state, and current/LKG
  pointer generation.

Reserved `CTDLPublicRecordEnvelope` and `CASEFrameworkEnvelope` preserve exact
publisher/schema/version/access/rights and default to no consumer eligibility.
Enabling a source requires an approved semantic/rights manifest, not a code
flag or successful parse.

### Typed interfaces

```swift
protocol EducationCorpusReading: Sendable {
    func snapshot() async throws -> EducationCorpusSnapshotSummary
    func searchPublicLabels(
        _ query: EducationCorpusPublicTextQuery,
        in snapshotID: EducationCorpusSnapshotID
    ) async throws -> EducationCorpusSearchPage
    func institution(
        id: EducationCorpusInstitutionID,
        in snapshotID: EducationCorpusSnapshotID
    ) async throws -> EducationInstitutionProjection?
    func classification(
        cip: CIPCode,
        edition: CIPEdition,
        in snapshotID: EducationCorpusSnapshotID
    ) async throws -> EducationClassificationProjection?
    func claims(
        _ request: EducationPublicClaimRequest,
        in snapshotID: EducationCorpusSnapshotID
    ) async throws -> EducationPublicClaimPage
    func inspection(
        claimID: EducationCorpusClaimID,
        in snapshotID: EducationCorpusSnapshotID
    ) async throws -> EducationClaimInspection
    func coverage(in snapshotID: EducationCorpusSnapshotID)
        async throws -> EducationCorpusCoverage
}

protocol EducationCorpusAdministering: Sendable {
    func stage(_ release: VerifiedEducationCorpusRelease) async throws
        -> EducationCorpusStageReceipt
    func validate(_ stagedID: EducationCorpusStagedReleaseID) async throws
        -> EducationCorpusValidationReport
    func promote(_ stagedID: EducationCorpusStagedReleaseID) async throws
        -> EducationCorpusPromotionReceipt
    func rollback(to snapshotID: EducationCorpusSnapshotID) async throws
        -> EducationCorpusRollbackReceipt
    func invalidate(_ command: EducationCorpusInvalidationCommand) async throws
        -> EducationCorpusInvalidationReceipt
    func clearDownloadedData() async throws -> EducationCorpusResetReceipt
    func purge(_ command: EducationCorpusPurgeCommand) async throws
        -> EducationCorpusPurgeReceipt
}
```

`EducationCorpusReading` accepts only validated public value types, never a
Goal, Capability, Proof, user/location identifier, schedule, education history,
recommendation context, model prompt, or arbitrary URL. The admin interface is
available only to Source Atlas lifecycle owners, not Planning/model/UI clients.

### Identity resolution

The foundry applies deterministic, source-declared identity rules in this order:

1. exact publisher crosswalk or shared identifier with documented identical
   scope;
2. exact federal cross-source identifier relation documented in the source;
3. reviewed compound evidence whose fields and scope are stored in the
   assertion; or
4. ambiguous, conflicting, or unmapped.

Name/address/domain similarity may produce a review candidate but never a
confirmed runtime link. Closure, merger, branch, program, and ownership changes
produce new/superseding assertions. A consumer can traverse only a confirmed
link whose scope permits the requested claim family. DAPIP program recognition
cannot travel through an institution-only link; field-of-study statistics
cannot travel to a named provider curriculum.

### Statistical semantics

Numeric records carry a typed definition and source processing state, not just
`Double?`:

```swift
enum EducationSourceValue<T: Codable & Sendable>: Codable, Sendable {
    case reported(T)
    case imputed(T, methodLocator: SourceLocator?)
    case derived(T, definition: SourceDefinitionID)
    case suppressed(reason: SuppressionReason)
    case notApplicable
    case missing
    case revised(previousRecordID: EducationSourceRecordID)
}
```

Comparison projection requires the same measure definition, compatible
population/credential level, unit, and source-documented comparable period.
Otherwise it returns `incomparable(reasons:)`. It never imputes, estimates,
scores, sorts by value, or converts a historical observation to a personal
prediction.

### Query and inspection projections

The query actor opens immutable read-only indices for one snapshot generation.
Search may normalize case/diacritics locally but returns source labels and does
not semantically merge records. Results paginate by stable public ID.

An `EducationInstitutionProjection` contains separate groups:

- source identity and identity assertions;
- historical programs/completions;
- Scorecard descriptive measures;
- DAPIP reported recognition;
- explicit unavailable current-offering/acceptance lanes; and
- source/coverage/limitations inspection.

No projection contains a ranking score, private match, recommended label,
admission prediction, or mutation command.

## Persistence, migration, and concurrency

### Persistence layout

Corpus bytes are stored outside private object repositories in the Source Atlas
public cache:

```text
SourceAtlas/Public/EducationCorpus/
  bootstrap/<snapshot-id>/
  releases/<source-family>/<release-id>/<shard-id>.saep
  indices/<snapshot-id>/<index-id>.sqlite
  snapshots/<snapshot-id>/manifest.json
  staging/<transaction-id>/
  quarantine/<transaction-id>/
  journal/education-corpus-journal.jsonl
  pointers/current.json
  pointers/last-known-good.json
```

The index is derived, contains only public records, and can be rebuilt from
verified shards. Snapshot manifests and lifecycle receipts are append-only.
Private databases never contain source corpus rows. User selection/history is
not stored by this owner.

### Migration from the existing pilot pack

The current `education_credentialing` pack remains readable as a legacy public
snapshot while the new schema is introduced. Migration is supersession, not
row mutation:

1. install/verify the new bootstrap independently;
2. map only exact legacy public claim IDs to new source records through a
   migration relation with both hashes;
3. mark unmatched legacy claims historical/unsupported rather than guessing;
4. build the new snapshot and indices;
5. atomically switch the current pointer after all validation/evaluation;
6. retain or purge legacy bytes according to their source rights; and
7. preserve permitted opaque lineage for inspection/replay.

Unknown schema versions fail closed. A downgrade continues using the newest
compatible current/LKG snapshot and does not rewrite newer bytes.

### Concurrency and atomicity

`EducationCorpusCoordinator` is an actor and the single writer for lifecycle
state. One transaction per source release may download/stage concurrently, but
only one corpus snapshot promotion or rollback may commit at a time.

- Transfers use immutable temp files and content-addressed IDs.
- Validation is pure over staged bytes and declared manifests.
- Promotion prepares indices, fsyncs immutable artifacts, writes the new
  snapshot manifest, then compare-and-swaps one current-pointer generation.
- Readers lease a snapshot generation; files remain until leases close.
- Repeated stage/promote/rollback/invalidate/purge commands use idempotency keys
  and return the original receipt.
- Crash replay reads the append-only journal, removes incomplete unreferenced
  staging, resumes mandatory purge, and never invents a pointer.

### Correction, invalidation, clear, and purge

Source correction creates a new record/release and a `supersedes` relation.
Affected claim/evaluation/proposal bindings become invalidated. Correction does
not mutate historic signed bytes.

`clearDownloadedData()` waits for active reader leases, removes non-bundled
downloaded snapshots/indices, and selects the verified bootstrap. It does not
touch Goals, Goal Paths, Steps, Capabilities, Proof, Life Context, imported
credentials, or other private state.

Rights purge is stronger: it removes prohibited shards, extracted/derived
indices, caches, searchable text, and renderings/contact sheets/thumbnails. The
journal retains only fields explicitly permitted by the rights decision. A
crash during purge leaves the affected claims ineligible and resumes purge
before any new read.

## Privacy and accessibility

This section combines the privacy, public/source, model, external-effect, and
accessible-interaction boundaries that every flow and interface must preserve.

### Public/private separation

- Foundry inputs are fixed source-release manifests.
- Public requests compile only from allowlisted source IDs and hashes.
- The public firewall rejects arbitrary URLs/parameters and private types.
- The corpus cache, index, coverage, logs, and diagnostics contain no private
  text, identity, device location, selections, or recommendation outcomes.
- Search text stays in volatile local query memory; this owner does not persist
  history or analytics.
- Any later private join happens inside a separate local Planning/model owner
  and returns no feedback to Source Atlas.

### Model boundary

A model is not used to acquire, join, validate, impute, rank, or approve corpus
facts. A future local/private model may summarize an eligible projection if it:

- receives only the minimum approved public claims plus separately authorized
  private context from its own owner;
- cites exact claim/snapshot IDs;
- emits structured output that deterministic validators can reject;
- preserves suppressed/unknown/conflicting/rights-blocked states; and
- cannot call the corpus admin interface or mutate any object.

Hosted-model transmission of private context or full source content is not
authorized by this Design.

### External effects

The only production network effects are fixed public Source Atlas release
fetches. `Verify with agency` is a user-initiated open/copy of a public locator.
There is no application, enrollment, provider contact, payment, credential
issuance, email, calendar action, file upload, or external write.

Foundry acquisition is a controlled build-time/public operation. Tests use
fixtures and recorded public manifests; default test execution performs no live
network calls. External-action integration remains a separate future owner.

### Observability without private leakage

Allowed operational signals are public artifact/release IDs, byte/count/schema
results, source-family timing, storage/memory/energy measurements, eligibility
reason counts, quarantine reason codes, and lifecycle receipt IDs. Forbidden
signals include user search text, viewed/selected institution, Goal,
Capability/Proof, location, education history, finance, disability,
immigration, schedule, or recommendation outcome.

User-visible errors name the public source and recovery. Developer diagnostics
use bounded enums/hashes, not source prose where rights forbid retention and
never private content.

### Accessibility and interaction design

- Source-family and status panels use semantic headings and retain a stable
  reading order at accessibility sizes.
- Every color/icon status includes text: `Suppressed`, `Imputed`, `Aging`,
  `Identity ambiguous`, `Recognition scope`, `Rights blocked`, `Offline`, or
  `Unavailable`.
- VoiceOver reads value, unit, cohort/year, processing/suppression, source, and
  limitation as a coherent group, with technical detail in a separate action.
- Dynamic Type reflows tables into labeled cards without horizontal-only
  comprehension. Long agency/institution names wrap.
- Update, retry, clear, and purge status announcements use polite live regions
  and preserve focus on the invoking control/result.
- Reduced Motion replaces animated refresh/promotion transitions with direct
  state changes. No essential meaning depends on motion.
- External source/agency links are labeled as leaving Ambitions and never imply
  an application or endorsement.

## Verification design

### Foundry and contract verification

- golden source-release fixtures for every allowlisted file/field and excluded
  unknown field;
- exact count/coverage reconciliation and source data-dictionary binding;
- CIP hierarchy and split/combined crosswalk semantics;
- IPEDS reported/imputed/derived/suppressed/not-applicable/missing and mixed
  component-year fixtures;
- Scorecard cohort/credential-level/suppression/definition fixtures;
- DAPIP institution/program/site/scope/action/agency-disclaimer fixtures;
- confirmed/ambiguous/conflicting/merged/closed/unmapped identity fixtures;
- CTDL/CASE parse-conformance-but-rights-blocked fixtures;
- rights/attribution/retention/withdrawal and source-change gates;
- release diff and deterministic repeat-build hashes.

### Native/unit/integration verification

- decode/migrate unknown-enum/schema fail-closed behavior;
- public request byte identity under every named private canary;
- staging/quarantine/promotion/rollback/LKG/crash-replay/idempotency;
- snapshot lease and concurrent refresh/read consistency;
- search/pagination/source-label behavior without semantic merge;
- claim eligibility and identity traversal restrictions;
- incomparable measure behavior and no ranking/prediction API;
- offline/never-fetched/clear/reset/correction/invalidation/rights purge;
- absence of private persistence, corpus feedback, mutation, or external action.

### Evaluation, accessibility, and device verification

- approved intelligence evaluation suites for grounding, authority, privacy,
  dignity/bias, failure, correction, coverage, and regression;
- adversarial portfolio for ordinary, alternative-provider absence,
  closed/merged, branch ambiguity, suppressed/small cohort, changed
  accreditation, conflicting identity, and rights withdrawal;
- VoiceOver, Dynamic Type, non-color status, focus recovery, Reduced Motion,
  offline, and external-link labeling;
- supported-device measurements for bootstrap/full/sharded download and
  installed size, staging peak, parse/validation/promotion, cold/warm query,
  memory, energy, background budget, rebuild, rollback, clear, and purge.

No test count, successful build, or simulator-only run establishes real-device
budgets, accessibility approval, recommendation usefulness, merge, deployment,
or release readiness.

## Requirement traceability

| Requirement | Owning design elements | Primary verification |
|---|---|---|
| REQ-001 | release/shard model; source record contracts | ID reuse and exact binding contract tests |
| REQ-002 | CIP records/relationships; Flow 2 | hierarchy/count/crosswalk fixtures |
| REQ-003 | IPEDS records; source value enum | processing and mixed-clock tests |
| REQ-004 | historical completion projection; Flow 2 | no-current-offering adversarial fixture |
| REQ-005 | Scorecard observation; statistical semantics | cohort/suppression/definition tests |
| REQ-006 | read-only unranked projections; model boundary | no score/prediction API and copy tests |
| REQ-007 | DAPIP record; Flow 3 | exact entity/scope/action/agency tests |
| REQ-008 | claim ceilings; identity traversal | no recognition inheritance/acceptance tests |
| REQ-009 | identity assertion model/resolution | ambiguous/conflicting/merger fixtures |
| REQ-010 | disabled CTDL/CASE envelopes | conformance-without-rights fail-closed tests |
| REQ-011 | rights manifest; purge | per-record rights/withdrawal/purge tests |
| REQ-012 | public firewall; public/private separation | private-canary byte-identity tests |
| REQ-013 | independent source clocks; snapshots | mixed release/source-change/LKG tests |
| REQ-014 | claim envelope/eligibility | orthogonal eligibility-state matrix |
| REQ-015 | coordinator; validation/promotion | quarantine/replay/idempotency tests |
| REQ-016 | offline/reset/correction/purge | lifecycle and private-nonmutation tests |
| REQ-017 | inspection/accessibility flows | projection and accessibility evidence |
| REQ-018 | coverage/evaluation binding | coverage reconciliation and eval suites |
| REQ-019 | read-only typed client; boundary table | API/runtime-effect negative tests |
| REQ-020 | bootstrap/shards; device measurement | offline bootstrap and device budget report |

## Design review and approval

Review verdict: **PASS** after one reconciliation round. Design review found
that a shared institution partition could accidentally look location-driven;
the repair requires the partition to be a manifest-declared public function of
source identifiers and explicitly forbids user location/intent. The review also
made CTDL/CASE enablement depend on an approved semantic/rights manifest rather
than parse success, and included extracted text/renderings in purge scope.

The Design resolves all 20 requirements across user flows, accessible states,
typed ownership and interfaces, source-native data, identity resolution,
persistence, migration, concurrency, replay, correction, clear/purge,
public/private separation, model boundaries, external effects, observability,
and verification. No blocking product fork remains.

Devan delegated approval authority for this documentation program. This Design
was approved under that authority on 2026-08-04. Approval authorizes
implementation grooming; it does not authorize or claim product/canon/source
changes, ingestion, runtime behavior, merge, deployment, or release readiness.

## Open decisions

No unresolved product decision remains. Exact IPEDS and College Scorecard
release/archive/field selections, product thresholds derived from device
measurements, and any future CTDL/CASE source-rights decision are bounded
implementation or future-Scope inputs; none may widen this approved Design.
