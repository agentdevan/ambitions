# PLOS-020 Local Data / Cloud Boundary

Status: Green for AMB-653 boundary-map documentation scope; Yellow for later CloudKit, R2, privacy-label, lifecycle, export, and implementation proof owned by later M02 children and M23-M26
Linear issue: AMB-653
Parent issue: AMB-610
Program phase: PLOS-M02 local data, CloudKit, R2 boundary, and data lifecycle foundation
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-653
- Parent issue: AMB-610
- Green/Yellow/Red status: Green for local data/cloud boundary map scope; Yellow for unimplemented CloudKit sync, R2 distribution, app privacy declaration, receipt retention, lifecycle, index, yearly archive, diagnostics/export, release, privacy/legal, accessibility, performance, and device proof.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 were already complete before this M02 child started.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for AMB-653 documentation scope
- Yellow limits: this boundary map is a planning/control artifact. It does not implement storage, CloudKit, R2, export, deletion, reset, diagnostics, privacy labels, or app runtime behavior.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-653 commit, push, and Linear closeout, continue AMB-654 / PLOS-021 only.

## Scope

AMB-653 defines the first M02 boundary map: which Ambitions data stays local, which may later sync through user-owned iCloud/CloudKit after explicit proof, which material may come from or go to R2 as public reference/source data, which data may be user-exported, and which diagnostics remain optional and redacted.

This child does not implement CloudKit, R2, export, deletion, reset, indexing, archive, diagnostics, privacy manifest changes, entitlement changes, App Review work, release work, or app source behavior.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-610` and child `AMB-653` by actual `AMB-*` identifiers.
- Linear referenced documents `Source Atlas Pack and Seed Release Contract` and `App Review and High-Risk Safety Contract`.
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`.
- M01 maps: `PLOS-010` through `PLOS-016` reports under `artifacts/personal-life-os/reports/`.
- `Native/Ambitions/Persistence/CloudKitContinuityModels.swift`.
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`.
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`.
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`.
- `Native/Ambitions/Support/ReleasePrivacyProtectedStorageReport.swift`.

Validation artifacts:

- `artifacts/personal-life-os/validation/PLOS-020-local-cloud-boundary-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-020-focused-boundary-search-log.txt`

## Boundary Rules

1. Private user life data is local-first and device-authoritative.
2. User-owned iCloud/CloudKit may become an optional continuity lane only after a later active issue proves schema, conflict, tombstone, rollback, delete, export, privacy, and user-control behavior.
3. R2 is public-reference/source/pathing distribution only. R2 must not store, receive, derive, or personalize from private user goals, captures, schedules, proof, receipts, local learning, private source imports, private share artifacts, or private context.
4. User export is user-initiated, previewed, redacted where needed, local by default, and never a hidden hosted projection.
5. Optional diagnostics must be local, redacted, user-controlled, and unable to become analytics/tracking telemetry without separate approval.
6. Source-present CloudKit models, privacy manifests, portable export models, or Source Atlas store models are evidence anchors, not implementation Green.

## Data Zone Definitions

| Zone | Meaning | Allowed material | Not allowed | Current proof |
|---|---|---|---|---|
| Local-only | Private user life data and private derived state stay on device and local stores by default. | Goals, goal intents, captures, schedules, protected time, proofs, receipts, replays, corrections, local learning, user profile, private imports. | Hosted Ambitions account storage, R2, cloud LLM/core server, tracking telemetry. | SwiftData/local repository and protected-storage source anchors exist; runtime completion is not claimed by this child. |
| User iCloud / CloudKit eligible | User-owned continuity lane for private data after explicit enablement and proof. | Goal, step, capture, proof, receipt, preference, tombstone, and sync ledger families after schema/conflict/delete proof. | Default-on sync, hidden upload, custom backend, R2, release/privacy claims before proof. | `CloudKitContinuityModels` and `SyncCapabilityContracts` are source-present; default flag is off and local operation remains authoritative. |
| R2 downloaded source/pathing | Public, reusable Source Atlas and seed/pathing material. | Source packs, seed packs, starter packs, manifests, signatures, revocations, compatibility metadata, release receipts, validation reports. | User goals, schedules, proof, receipts, captures, context, learning, private imports, private share artifacts, identifiers, raw user text. | Source Atlas store and Linear contract define this boundary; production R2 distribution is not implemented or claimed. |
| User-initiated export | Explicit user export/share package or preview. | Selected redacted goals/plans, captures, proof, receipts, memory, settings after review. | Silent export, unredacted sensitive raw fields, cloud account data, rendered external state. | `PortableSnapshotContracts` defines local-only export selection and redaction rules; export UX/runtime proof is later-owned. |
| Optional diagnostics | Local support/debug evidence after user control and redaction. | Redacted validation/support summaries, local logs, proof artifact references. | Analytics/tracking SDKs, crash SDKs, personal-data telemetry, secret-reading tools, hosted support upload by default. | M24 owns diagnostics/export proof. This child sets the boundary only. |

## Core Object Boundary Matrix

| Object / data family | Primary zone now | Future eligible zone | R2 allowed? | Export eligible? | Privacy class | Boundary / owner |
|---|---|---|---|---|---|---|
| Goal | Local-only | User iCloud after M23 proof | No | Redacted export review | Private user life data | GoalEngine and SwiftData are current owners; no custom backend. |
| Goal intent | Local-only | User iCloud after M23 proof | No | Redacted export review | Private intent/context | Any Goal work must not send raw intent to R2. |
| Goal path / path option | Local-only derived state until source-backed public seeds are composed locally | User iCloud after proof | Public reusable pathing seeds only, not user-specific path outputs | Redacted export review | Private planning data plus public source references | M12 owns path lattice maturity; M04-M06 own public pack/source authority. |
| Step / compiled step | Local-only | User iCloud after proof | Public starter seed or pathing template only | Redacted export review | Private execution data | No hardcoded finished user Steps in public packs. |
| Step candidate / elastic variant | Local-only derived state | User iCloud after proof | Public reusable seed/fallback pattern only | Usually excluded or redacted summary | Private recommendation/fit data | M09/M13/M14 own quality, compiler, and elasticity proof. |
| Schedule install / block | Local-only | User iCloud after proof and explicit user control | No | Redacted export review | Sensitive schedule/protected-time data | M15/M16 own preview, conflict, rollback, and reflow receipts. |
| Calendar/native context | Local-only derived projection | User iCloud only if a later issue proves user-owned sync for Ambitions-derived context | No | Derived/redacted summary only | Sensitive permissioned context | Raw native calendar details are not R2 or default export material. |
| Capture / held item | Local-only | User iCloud after proof | No | Redacted export review | Private user input | Global Capture stays local-first; no cloud classification requirement. |
| Proof / evidence | Local-only | User iCloud after proof | No | Redacted export review | Proof-restricted private data | Source references can be public; user proof content cannot be public pack data. |
| Receipt / action history | Local-only | User iCloud after proof | No | Redacted export review | Proof/replay restricted | M17/M24 own inspection/export lifecycle proof. |
| Replay trace / runtime snapshot | Local-only or ephemeral local projection | User iCloud only after strong replay/privacy proof | No | Usually excluded or redacted summary | Highly sensitive decision trace | Current report does not claim replay UI or durable sync. |
| Local learning / memory signal | Local-only | User iCloud after reset/delete proof | No | Redacted or excluded | Sensitive behavioral pattern data | M22 owns local compounding controls and resettable learning. |
| Coverage need / source-needed state | Local-only when derived from user intent; public seed-gap category may be detached | Anonymous/public seed-gap category only after privacy proof | Only sanitized non-user-specific category | Redacted summary | Private if user-derived | R2 request must never include raw goal text or private context. |
| Source Atlas pack | Downloaded source/pathing data | Local cache / last-known-good | Yes, public only | Public/reference export only | Public reference unless combined with user context | M04-M06 own release receipt, revocation, freshness, review, and rollback. |
| Source Atlas seed | Downloaded source/pathing data | Local cache / last-known-good | Yes, public reusable seeds only | Public/reference export only | Public reference | Seeds are reusable ingredients, not finished user Steps. |
| Source record / claim / requirement | Downloaded source/pathing data | Local cache / last-known-good | Yes, public source authority only | Public/reference export only | Public or high-risk public reference | High-risk domains need M18 jurisdiction/source/professional-boundary gates. |
| User profile / settings | Local-only | User iCloud after proof | No | Preference labels only; no secrets | Private preferences/profile | You surface controls local data/trust; no Profile tab revival. |
| Privacy manifest facts | Repo/release artifact, not user runtime data | App Review evidence after proof | No | N/A | Release/legal evidence | Current manifest declares no tracking and no collected data; this is source evidence, not privacy/legal approval. |
| Diagnostics/support bundle | Optional local redacted artifact | User-initiated export only | No private data; public validation report references only | Redacted export review | Sensitive unless proven redacted | M24 owns support/export diagnostics. |
| Year snapshot / annual recap | Future local compaction output | User iCloud after proof | No | Redacted export/story only after M20/M21 proof | Private longitudinal life data | AMB-660, M21, and M26 own recap/compaction proof; no gamification/score drift. |

## Boundary Crossing Rules

| Crossing | Allowed only when | Blocked when |
|---|---|---|
| Local -> CloudKit | The active issue proves user-owned iCloud/CloudKit enablement, schema, conflict review, tombstones, delete/reset/export, rollback, privacy copy, and local fallback. | Default-on sync, account requirement, hidden upload, missing delete/export semantics, privacy/legal overclaim. |
| Local -> R2 | Never for private user data. Only detached, non-user-specific seed-gap categories may be considered after privacy proof. | Raw user text, goals, schedules, receipts, proof, local learning, identifiers, or inferred priorities are included. |
| R2 -> Local | Public source/seed/pathing packs pass source binding, hash/signature, freshness, revocation, review, release receipt, rollback, and eligibility gates. | Pack is revoked, contradicted, hash-mismatched, missing review, private-data-bearing, or cannot prove release receipt. |
| Local -> Export/share | User initiates, preview/redaction happens first, high-risk/share gates pass, and rollback/delete rules are clear. | Export is silent, raw sensitive detail leaks, hosted default path is introduced, or share creates social pressure. |
| Local -> Diagnostics/support | User controls the action, data is redacted, secrets and private raw context are excluded, and no analytics/tracking SDK is introduced. | Diagnostics become telemetry, default upload, crash SDK, secret reader, or production-affecting service without approval. |

## Performance / Storage Flags

AMB-653 does not measure performance. It identifies costly boundary crossings for later owners:

- Replay traces, receipt history, proof/evidence, local learning, and year snapshots can grow quickly and need retention/index/compaction policy before runtime Green.
- CloudKit outbox/conflict ledgers need bounded payloads and local fallback before any sync claim.
- R2 source pack caches need hash validation, quarantine, last-known-good fallback, and revocation handling before runtime eligibility.
- Export packages need preview counts and redaction before generation to avoid accidental large/private projection.

## Validation

Commands run for AMB-653:

- `git status --short --branch` - clean on `main` before M02 execution, then PLOS-020 validation artifacts were created.
- `git rev-parse HEAD` - BASE_SHA `5f61d0bb4de84c3fc40ea273faaaa8dc0d2fc3f6`.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-610` - succeeded.
- Linear child list for `parentId: AMB-610` - resolved `AMB-653` through `AMB-660`.
- Linear issue fetch for `AMB-653` - succeeded.
- Linear document fetch for `Source Atlas Pack and Seed Release Contract` - succeeded.
- Linear document fetch for `App Review and High-Risk Safety Contract` - succeeded.
- `scripts/codex/program-preflight.sh plos` - exited `0`, Green, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T171203.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T171203.log`.
- `rg -n "CloudKit|iCloud|R2|privacy" . > artifacts/personal-life-os/validation/PLOS-020-local-cloud-boundary-search-log.txt` - exited `0`, 8,557 lines.
- Focused boundary search over docs/artifacts/Persistence/Domain/Resources/Support - exited `0`, 6,639 lines, artifact `artifacts/personal-life-os/validation/PLOS-020-focused-boundary-search-log.txt`.
- Focused source inspection of CloudKit continuity, sync capability, portable snapshot, Source Atlas store, privacy manifest, and protected storage report source.

Closeout validation run after report creation:

- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T172022.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T172022.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 48 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T172031.log`.
- `git diff --cached --check` - initially found trailing whitespace inside generated validation logs; sanitized `PLOS-020-focused-boundary-search-log.txt` and `PLOS-020-local-cloud-boundary-search-log.txt`, then exited `0`.

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-653 is documentation/control-plane boundary work and no app source, project, UI, runtime, test source, privacy manifest, entitlement, CloudKit, R2, export, or diagnostic implementation changed.

## Runtime Path Proof

Not applicable for implementation proof. AMB-653 consumes the M01 runtime maps and current source anchors to define boundaries, but it does not implement or change runtime behavior.

## Privacy / Safety / Source Checks

Green for AMB-653 documentation scope:

- Private user data is explicitly local-first.
- CloudKit is optional and proof-gated, not default or claimed complete.
- R2 is public-reference/source/pathing only.
- Source Atlas packs and seeds require release receipt, freshness, revocation, review, rollback, and no private user data before runtime eligibility.
- High-risk/App Review and privacy-label claims remain future-owned and not claimed here.

## Accessibility Checks

Not applicable. No UI or accessibility behavior changed. No accessibility verification or certification is claimed.

## Performance Notes

No performance measurements were run. The report flags replay, receipt, proof, learning, source-pack cache, export package, and year snapshot growth as later index/retention/compaction owners.

## Rollback / Failure Behavior

Rollback is to revert this AMB-653 artifact/control-plane commit. Downstream AMB-654 through AMB-660 and M23/M24 must hold if this boundary is removed or fails validation, because CloudKit, lifecycle, index, receipt, R2, privacy, and archive decisions depend on this map.

## Remaining Yellow / Red

Yellow:

- CloudKit schema constraints remain AMB-654 / PLOS-021.
- User data lifecycle remains AMB-655 / PLOS-022.
- Local index/query strategy remains AMB-656 / PLOS-023.
- Receipt retention/delete/reset/export remains AMB-657 / PLOS-024.
- R2 source-only boundary remains AMB-658 / PLOS-025.
- App privacy declaration map remains AMB-659 / PLOS-026.
- Yearly archive/compaction remains AMB-660 / PLOS-027.
- M23 owns implementation-level CloudKit/iCloud sync hardening.
- M24 owns diagnostics/export support proof.
- M25/M26 own App Review/compliance/certification evidence.

Red blockers: none for AMB-653 scope.

## Follow-Up Issues Created

None.

## Next Issue To Run

AMB-654 / PLOS-021 only, after AMB-653 is committed, pushed to `main`, and updated in Linear.

## Non-Claims

AMB-653 does not claim runtime implementation, app source change, storage implementation, CloudKit implementation, R2 implementation, sync behavior, source-pack publication, export/delete/reset implementation, diagnostics implementation, privacy manifest correctness beyond source inspection, privacy/legal approval, App Review readiness, release readiness, TestFlight readiness, App Store readiness, screenshot proof, accessibility verification, performance proof, owner approval, or PLOS-M03+ execution.

## PLOS Child Closeout

PLOS child closeout

Linear issue: AMB-653

Parent issue: AMB-610

Green/Yellow/Red status: Green for AMB-653 local data/cloud boundary-map documentation scope; Yellow for later CloudKit, lifecycle, index, receipt, R2, privacy declaration, archive, implementation, release, accessibility, performance, device, and privacy/legal proof not claimed.

Pushed to main: pending at report creation

Push hash: pending at report creation

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no; AMB-608 and AMB-609 were already complete before this M02 child started.

Linear identifiers used: AMB issue identifiers only

Validation run:
- `git status --short --branch` - clean on `main` before child execution; PLOS-020 validation artifacts created after.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-610` and `AMB-653` - succeeded.
- Linear child list for `parentId: AMB-610` - resolved `AMB-653` through `AMB-660`.
- Linear document fetch for referenced Source Atlas and App Review contracts - succeeded.
- `scripts/codex/program-preflight.sh plos` - exited `0`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`.
- `rg -n "CloudKit|iCloud|R2|privacy" . > artifacts/personal-life-os/validation/PLOS-020-local-cloud-boundary-search-log.txt` - exited `0`.
- Focused boundary search - exited `0`.
- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`.
- `git diff --cached --check` - exited `0` after generated validation log whitespace sanitization.

Red blockers: none for AMB-653 scope.

Yellow limits: no storage, sync, CloudKit, R2, export/delete/reset, diagnostics, privacy-label, release, accessibility, performance, device, or privacy/legal proof is claimed.

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Next recommended action: AMB-654 / PLOS-021 only after AMB-653 push and Linear closeout.
