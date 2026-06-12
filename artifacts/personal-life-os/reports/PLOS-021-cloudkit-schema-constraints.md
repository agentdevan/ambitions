# PLOS-021 CloudKit Schema Constraints

Status: Green for AMB-654 schema-constraint documentation scope; Yellow for later CloudKit schema rollout, record transport, conflict UI, migration, delete/reset/export, privacy-label, device, release, accessibility, and performance proof
Linear issue: AMB-654
Parent issue: AMB-610
Program phase: PLOS-M02 local data, CloudKit, R2 boundary, and data lifecycle foundation
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-654
- Parent issue: AMB-610
- Green/Yellow/Red status: Green for early CloudKit schema-constraint documentation scope; Yellow for unimplemented CloudKit record persistence, sync transport, conflict resolution UI, migration, deletion/reset/export, privacy declaration, performance measurement, device proof, and release proof.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 were already complete before this M02 child started.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for AMB-654 documentation scope
- Yellow limits: this report constrains future schema work. It does not create, migrate, deploy, or save CloudKit records and does not prove sync behavior.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-654 commit, push, and Linear closeout, continue AMB-655 / PLOS-022 only.

## Scope

AMB-654 defines the early CloudKit schema constraints that later M23 CloudKit/iCloud sync hardening must obey. The goal is migration safety, local-first continuity, and no widening of the AMB-653 local data/cloud boundary.

This child does not implement production schema rollout, CloudKit record save/fetch transport, database subscription behavior, merge UI, migration code, entitlement changes, privacy manifest changes, App Review work, release work, or app runtime behavior.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-610` and child `AMB-654` by actual `AMB-*` identifiers.
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`.
- `Native/Ambitions/Persistence/CloudKitContinuityModels.swift`.
- `Native/Ambitions/Persistence/CloudKitContinuityClient.swift`.
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`.
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`.
- `Native/AmbitionsTests/Persistence/CloudKitContinuityFoundationTests.swift`.
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`.

Validation artifacts:

- `artifacts/personal-life-os/validation/PLOS-021-cloudkit-schema-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-021-focused-cloudkit-schema-search-log.txt`

## Source Anchors

Current source already defines CloudKit continuity as a constrained, local-first lane:

- `CloudKitContinuityContainerConfiguration.production` names container `iCloud.com.ambitions.ios` and zone `AmbitionsCoreZone`.
- `LiveCloudKitContinuityClient` uses `container.privateCloudDatabase`; no public or shared database lane is approved by current source.
- `LocalFirstCloudKitContinuitySyncCoordinator.prepareCoreZoneIfEligible()` prepares the zone only when diagnostics are `healthy_after_proof`.
- `CloudKitContinuityFeatureFlag.defaultEnabled` is `false`.
- `LocalOnlySyncCapability` reports local operation authoritative, `writesUserData: false`, `userDataCaptured: false`, and `localOperationBlocked: false`.
- `CloudKitContinuityPortableRecordEnvelope` is the existing portable envelope shape for future record payloads.
- `CloudKitContinuityRecordFamily.approvedFamilies` is currently the allowlist of `goal`, `step`, `capture`, `proof`, `receipt`, `memory_signal`, `preference`, `tombstone`, and `sync_ledger`.

## Non-Negotiable Schema Rules

1. CloudKit is optional user-owned iCloud continuity only; local device state remains authoritative.
2. Records may use the private database and `AmbitionsCoreZone` only. Public database, shared database, R2, custom hosted storage, analytics, telemetry, and cloud LLM lanes are not schema targets.
3. Any future record type must map to an approved `CloudKitContinuityRecordFamily`.
4. Every record must be envelope-first: stable `id`, `family`, `recordName`, `schemaVersion`, `localRevision`, `createdAt`, `updatedAt`, `reviewState`, and bounded `payloadData`.
5. `schemaVersion`, `recordName`, `localRevision`, tombstone metadata, receipt lineage, and replay/source references are migration-sensitive and cannot be renamed, overloaded, or dropped without a migration plan and pre-migration backup proof.
6. CloudKit setup, write, import, delete, reset, and conflict behavior must fail local-first. CloudKit unavailability cannot block local writes.
7. No private user data may cross into R2 or public Source Atlas material through schema fields, indexes, diagnostics, or record names.

## Record Family Constraint Matrix

| Family | Allowed purpose | Required stable identity | Migration-sensitive fields | CloudKit performance flag | Boundary |
|---|---|---|---|---|---|
| `goal` | User-owned goal object continuity. | `recordName` derived from stable local goal id, not title text. | `schemaVersion`, local revision, timestamps, source/receipt references. | Medium churn; avoid large embedded histories. | Private database only. |
| `step` | User-owned step or compiled step continuity after proof. | Stable step id plus family prefix. | Parent goal id, revision, receipt/replay references. | High churn risk if every recommendation variant syncs. | Private database only; no public seed leakage. |
| `capture` | User-owned Capture items after explicit continuity proof. | Stable capture id, not raw capture text. | Status, linked goal id, timestamps, revision. | Potentially sensitive raw text; payload must stay bounded. | Private database only. |
| `proof` | User proof/evidence continuity after redaction and lifecycle rules. | Stable evidence id. | Proof privacy class, source record, receipt, captured timestamp. | Attachment-sized proof is high risk; do not embed large binaries in envelope. | Private database only. |
| `receipt` | Action receipt, feedback, revision, and lineage continuity. | Stable receipt or history id. | Changed facts, proof relevance, privacy level, source/replay lineage. | High longitudinal growth; retention policy required. | Private database only. |
| `memory_signal` | Explicit local teaching/correction signal continuity after reset proof. | Stable teaching signal id. | Source, freshness, correction scope, reset lineage. | Sensitive derived behavior; minimize payload and index fields. | Private database only. |
| `preference` | App/user settings continuity. | Stable preference namespace id. | Schema version, selected tab/surface, local mode, consent state. | Low churn but migration-sensitive. | Private database only. |
| `tombstone` | Delete/replacement/finalization proof. | Stable tombstone id plus entity kind/id. | `entityKind`, `entityID`, `reason`, `recordedAt`, `localOnly`, source/receipt/replay references. | Must remain compact and queryable. | Private database only. |
| `sync_ledger` | Device-local sync progress and review state. | Device-scoped ledger record name. | `deviceID`, `lastProcessedRevision`, `pendingRecordCount`, `reviewRecordCount`, `syncState`. | High churn if updated per mutation; batch and compact. | Private database only; no cross-user analytics. |

## Field Constraints

Identity fields:

- `recordName` must be deterministic and title-free. It may include family and stable local id, but not raw goal text, capture text, schedule titles, proof text, or user display names.
- `id` remains `family.rawValue.recordName` in the portable envelope unless a future migration plan proves a safer identity scheme.
- `sourceRecordID`, `receiptID`, and `replayTraceID` are references only; they must not embed raw source text, proof content, or replay payloads.

Version and ordering fields:

- `schemaVersion` is required for every payload family and must be monotonic by family.
- `localRevision` is required for conflict review and cannot be replaced with wall-clock time.
- `createdAt` and `updatedAt` must use stable string encoding compatible with existing source contracts and must not be used as the only conflict authority.

Payload fields:

- `payloadData` must remain encoded, family-scoped, and bounded. Large proof media, replay traces, screenshots, export archives, or diagnostics bundles must not be embedded in ordinary continuity records.
- Payloads should be JSON-encoded with stable keys when using `CloudKitContinuityPortableRecordCodec`.
- New top-level CloudKit fields should be minimal and privacy-safe: family, schema version, local revision, review state, update timestamp, and record identity. Sensitive user content should stay inside bounded private payload data, not query/index fields.

Review and deletion fields:

- `reviewState` must remain one of `ready`, `needs_review`, `conflict`, or `tombstoned` until a future migration explicitly extends it.
- Tombstones must preserve entity kind, entity id, reason, recorded timestamp, and local-only indicator.
- Delete/reset/export semantics remain future-owned by AMB-657 / PLOS-024 and M24; AMB-654 only constrains the fields those policies must preserve.

## Migration-Sensitive Fields

These fields are migration-sensitive because losing or changing them can cause duplicate records, lost deletions, unsafe merges, or hidden user-data resurrection:

- Envelope: `id`, `family`, `recordName`, `schemaVersion`, `localRevision`, `createdAt`, `updatedAt`, `reviewState`, `payloadData`.
- Lineage: `sourceRecordID`, `receiptID`, `replayTraceID`.
- Tombstone: `entityKind`, `entityID`, `reason`, `recordedAt`, `localOnly`.
- Sync ledger: `deviceID`, `lastProcessedRevision`, `lastSyncedAt`, `pendingRecordCount`, `reviewRecordCount`, `syncState`.
- Diagnostics/capability: `syncMode`, `syncState`, `featureFlagEnabled`, `accountStatus`, `proofVerified`, `userPausedSync`, `localOnlyFallbackActive`, `localOperationBlocked`, `writesUserData`, `userDataCaptured`.

Any future migration must provide:

- Pre-migration local backup receipt.
- Dry-run count of affected records by family.
- Tombstone preservation proof.
- Conflict-review fallback for ambiguous revisions.
- Rollback path that returns to explicit local-only operation without blocking local writes.

## Conflict and Review Constraints

Future CloudKit sync must treat conflict review as a first-class schema state, not a transport error:

- `CloudKitContinuityConflictReview` is the existing shape for local/remote envelope review.
- A remote envelope with a newer `updatedAt` but equal or lower `localRevision` is not automatically authoritative.
- Ambiguous conflicts must move to `needs_review` or `conflict` and preserve both local and remote envelopes until a user-safe resolution path exists.
- Local writes and local recommendations remain available while CloudKit is unavailable, paused, restricted, or in review.
- `LocalFirstCloudKitContinuitySyncCoordinator` queuing behavior is the current source anchor; it queues local changes and only prepares the zone when proof-backed diagnostics are healthy.

## Performance and Storage Flags

High-churn or oversized record risks flagged for later owners:

- Step candidates, elastic variants, recommendation traces, and replay records can churn heavily; do not sync every transient candidate as a durable CloudKit record.
- Receipts, proof, tombstones, and ledger records grow over time; M02 lifecycle and M24 export/diagnostics work must define retention, compaction, and query strategy before runtime Green.
- Capture and proof payloads can contain sensitive free text or media; record names and query fields must not expose that content.
- Sync ledger updates should be batched or compacted; one ledger write per local mutation risks quota and performance pressure.
- Large proof media, screenshots, diagnostics bundles, source packs, and export packages are not ordinary CloudKit envelope payloads.

## Boundary Preservation Against AMB-653

AMB-654 does not widen the AMB-653 boundary:

- Private user data remains local-first and eligible only for user-owned private CloudKit continuity after proof.
- R2 remains public-reference/source/pathing distribution only and is not a CloudKit schema destination.
- Optional diagnostics remain local, redacted, user-controlled, and not analytics telemetry.
- CloudKit schema source presence remains evidence only, not runtime implementation Green.

## Validation

Commands run for AMB-654:

- `git status --short --branch` - clean on `main` before AMB-654 execution except generated AMB-654 validation logs after search.
- `git rev-parse HEAD` - BASE_SHA `a79aefc62f18ffd64cc33b2b032a3bf8ee06155f`.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-610` - succeeded.
- Linear issue fetch for `AMB-654` - succeeded.
- Linear status update for `AMB-654` to In Progress - succeeded.
- `rg -n "CloudKit|CKRecord|iCloud" . > artifacts/personal-life-os/validation/PLOS-021-cloudkit-schema-search-log.txt` - exited `0`, 3,436 lines.
- Focused CloudKit schema search over Persistence, Domain, Support, tests, and the AMB-653 boundary report - exited `0`, 3,058 lines, artifact `artifacts/personal-life-os/validation/PLOS-021-focused-cloudkit-schema-search-log.txt`.
- Focused source inspection of CloudKit continuity models/client, sync capability contracts, portable snapshot contracts, and CloudKit continuity/portable snapshot tests.

Closeout validation run after report creation:

- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T172915.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T172915.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 49 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T172919.log`.
- `git diff --cached --check` - pending until staging.

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-654 is documentation/control-plane schema-constraint work and no app source, project, UI, runtime, test source, privacy manifest, entitlement, CloudKit transport, or persistence migration implementation changed.

## Runtime Path Proof

Not applicable for implementation proof. AMB-654 consumes current source anchors and AMB-653 boundary proof to constrain later CloudKit work, but it does not implement or change runtime behavior.

## Privacy / Safety / Source Checks

Green for AMB-654 documentation scope:

- CloudKit is constrained to optional private database continuity only.
- Current source keeps CloudKit continuity disabled by default and local operation authoritative.
- Record names and indexes must not include private raw user text.
- R2 remains excluded from private user-data continuity.
- Migration-sensitive deletion, tombstone, receipt, and ledger fields are explicitly identified.

## Accessibility Checks

Not applicable. No UI or accessibility behavior changed. No accessibility verification or certification is claimed.

## Performance Notes

No performance measurements were run. The report flags high-churn Step/replay/ledger records, large proof/capture payloads, receipt/tombstone growth, and oversized diagnostics/export artifacts as later owners.

## Rollback / Failure Behavior

Rollback is to revert this AMB-654 artifact/control-plane commit. Downstream CloudKit implementation, lifecycle, index, receipt retention, export, privacy declaration, M23 sync, and M24 diagnostics/export work must hold if this schema constraint report is removed or fails validation.

## Remaining Yellow / Red

Yellow:

- User data lifecycle remains AMB-655 / PLOS-022.
- Local index/query strategy remains AMB-656 / PLOS-023.
- Receipt retention/delete/reset/export remains AMB-657 / PLOS-024.
- R2 source-only boundary remains AMB-658 / PLOS-025.
- App privacy declaration map remains AMB-659 / PLOS-026.
- Yearly archive/compaction remains AMB-660 / PLOS-027.
- M23 owns implementation-level CloudKit/iCloud sync hardening.
- M24 owns diagnostics/export support proof.
- M25/M26 own App Review/compliance/certification evidence.

Red blockers: none for AMB-654 scope.

## Follow-Up Issues Created

None.

## Next Issue To Run

AMB-655 / PLOS-022 only, after AMB-654 is committed, pushed to `main`, and updated in Linear.

## Non-Claims

AMB-654 does not claim runtime implementation, app source change, storage implementation, CloudKit implementation, CloudKit schema deployment, record transport, iCloud sync behavior, conflict UI, source-pack publication, export/delete/reset implementation, diagnostics implementation, privacy manifest correctness, privacy/legal approval, App Review readiness, release readiness, TestFlight readiness, App Store readiness, screenshot proof, accessibility verification, performance proof, owner approval, or PLOS-M03+ execution.

## PLOS Child Closeout

PLOS child closeout

Linear issue: AMB-654

Parent issue: AMB-610

Green/Yellow/Red status: Green for AMB-654 early CloudKit schema-constraint documentation scope; Yellow for later CloudKit schema rollout, sync transport, conflict UI, lifecycle, index, receipt, R2, privacy declaration, archive, implementation, release, accessibility, performance, device, and privacy/legal proof not claimed.

Pushed to main: pending at report creation

Push hash: pending at report creation

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no; AMB-608 and AMB-609 were already complete before this M02 child started.

Linear identifiers used: AMB issue identifiers only

Validation run:
- `git status --short --branch` - clean on `main` before child execution; AMB-654 validation artifacts created after.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-610` and `AMB-654` - succeeded.
- Linear status update for `AMB-654` to In Progress - succeeded.
- `rg -n "CloudKit|CKRecord|iCloud" . > artifacts/personal-life-os/validation/PLOS-021-cloudkit-schema-search-log.txt` - exited `0`.
- Focused CloudKit schema search - exited `0`.
- Focused source inspection of CloudKit continuity, sync capability, portable snapshot, and related tests.

Validation run after report creation:
- `git diff --check` - exited `0`.
- JSON validation for PLOS queue/map - exited `0`.
- PLOS readiness validation - exited `0`.
- PLOS preflight - exited `0`.
- PLOS M02 phase gate - exited `0`.
- PLOS child closeout validation - exited `0`.
- PLOS proof index regeneration - exited `0`.
- `git diff --cached --check` - pending until staging.

Red blockers: none for AMB-654 scope.

Yellow limits: no CloudKit runtime implementation, schema deployment, sync proof, conflict UI, migration proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, performance proof, device proof, or owner approval is claimed.

Next recommended action: after AMB-654 commit, push, and Linear closeout, continue AMB-655 / PLOS-022 only.
