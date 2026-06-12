# PLOS-024 Receipt Retention, Delete, Reset, and Export Policy

Status: Green for AMB-657 receipt policy documentation scope; Yellow for later receipt-browser implementation, retention enforcement, delete/reset/export UX, CloudKit lifecycle transport, compaction, measured storage performance, device, accessibility, privacy/legal, and release proof
Linear issue: AMB-657
Parent issue: AMB-610
Program phase: PLOS-M02 local data, CloudKit, R2 boundary, and data lifecycle foundation
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-657
- Parent issue: AMB-610
- Green/Yellow/Red status: Green for receipt retention/delete/reset/export policy documentation scope; Yellow for unimplemented retention enforcement, receipt-browser UX, durable delete/reset/export flows, compaction, measured storage performance, CloudKit propagation, device, accessibility, privacy/legal, and release proof.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 were already complete before this M02 child started.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for AMB-657 documentation scope
- Yellow limits: this report defines receipt data policy. It does not implement retention jobs, delete/reset/export UX, receipt browsing, CloudKit transport, compaction, or source changes.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-657 commit, push, and Linear closeout, continue AMB-658 / PLOS-025 only.

## Scope

AMB-657 defines how Ambitions receipt, tombstone, and lineage proof data should be retained, deleted, reset, and exported across the local-first path and future optional user-owned CloudKit path. It protects user agency over proof data while preventing receipts from becoming undeletable dark data.

This child does not implement a receipt browser, retention enforcement, delete/reset/export controls, CloudKit propagation, sync conflict handling, storage compaction, privacy manifest changes, App Review work, release work, or app runtime behavior.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-610` and child `AMB-657` by actual `AMB-*` identifiers.
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`.
- `artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md`.
- `artifacts/personal-life-os/reports/PLOS-022-user-data-lifecycle-archive-strategy.md`.
- `artifacts/personal-life-os/reports/PLOS-023-local-database-index-query-strategy.md`.
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`.
- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift`.
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`.
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`.
- `Native/Ambitions/Persistence/SwiftDataStore.swift`.
- `Native/Ambitions/Persistence/SwiftDataModels.swift`.
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`.

Validation artifacts:

- `artifacts/personal-life-os/validation/PLOS-024-receipt-policy-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-024-focused-receipt-policy-search-log.txt`

## M00 / M01 Consumption Evidence

AMB-657 consumes M00 governance outputs and M01 runtime maps as load-bearing inputs:

- M00 local data/cloud boundary law requires user life data and derived proof data to remain local-first unless later proof authorizes optional user-owned sync.
- AMB-646 / PLOS-010 active runtime path proof keeps this child documentation-scoped instead of mutating receipt or persistence source.
- AMB-649 / PLOS-013 identifies action receipts, proof, replay, lineage, tombstones, local learning, and CloudKit continuity as distinct existing owners.
- AMB-651 / PLOS-015 prevents treating tests, fixtures, generated logs, or proof artifacts as receipt runtime behavior proof.
- AMB-655 / PLOS-022 defines delete/reset/export lifecycle semantics; this child specializes those rules for receipt and lineage proof data.
- AMB-656 / PLOS-023 identifies receipt history, event ledgers, tombstones, and runtime snapshots as long-running query/scale risk areas.

No source file is changed by AMB-657, so source-ownership gating is not applicable for implementation. Current source was inspected only to define policy.

## Source Anchors

Current source already provides policy anchors but not full product Green:

- `ActionReceiptHistoryRecord` defaults `localOnly` to `true` and carries `privacyLevel`, `proofRelevance`, `requiresConfirmationBeforeBroaderUse`, and `proofFreshnessLineage`.
- Receipt privacy levels require redaction by default for private, sensitive, redacted, and unavailable receipts.
- Receipt search projections dedupe malformed or repeated receipt keys and can filter by date, related goal, capture, plan item, source domain, privacy level, trust status, proof relevance, freshness review, and search text.
- `PortableExportManifest` treats receipts as proof-restricted, export-review-only data with preview rules for changed facts, revision markers, and lineage views.
- `PortableStoredActionReceiptHistoryRecord` preserves receipt, privacy level, local-only posture, proof relevance, confirmation-before-broader-use, and proof freshness lineage for portable packages.
- `PortableSnapshotService` includes receipt history and export-safe tombstones only when the receipts category is selected.
- `EntityRevisionTombstone.exportSafeTombstone` and `exportSafeLineageView` redact source, receipt, and replay references depending on privacy class.
- `AmbitionsPersistenceStore.resetAllData()` currently hard-deletes action receipt history records, tombstone records, runtime snapshot ledger records, and other SwiftData families.

## Receipt Policy Principles

1. Receipts are user-owned proof and trust data, not telemetry.
2. Receipts are local-first and local-only by default.
3. Receipts may explain why something changed, what was affected, whether proof was created, and whether broader use requires confirmation.
4. Receipts must not become undeletable dark data. The user must have an explicit policy path for delete, reset, and export.
5. Ordinary delete should preserve only the minimum tombstone or lineage needed to prevent false proof, silent resurrection, or unsafe conflict recovery.
6. Full reset may clear receipt data after explicit confirmation, with any backup/export treated as user-selected and local-only.
7. Exported receipts require category selection, preview, redaction, and manifest counts. Export is not silent sync.
8. Future CloudKit propagation must preserve delete/reset/tombstone intent and must not resurrect receipt data after user deletion.

## Retention Semantics

| Receipt family | Default retention | Why retained | Delete/reset rule | Export rule | Storage risk |
|---|---|---|---|---|---|
| User action receipts | Retain while they can explain material user-visible changes, proof, schedule impact, closure, recovery, correction, or undo/correction availability. | Trust, inspection, recovery, and proof continuity. | User delete may remove detail and preserve only a minimal tombstone when needed to block false resurrection or stale proof. Full reset may hard-delete after explicit confirmation. | Included only when `.receipts` is selected and previewed. Redact private/sensitive detail by default. | High over years if every action is retained with full changed facts. |
| Proof-relevant receipts | Retain while connected proof may be shown, counted, corrected, exported, or used in source freshness. | Prevents fake proof and preserves explainability. | Delete must say whether proof is removed, redacted, or left as a summarized lineage marker. | Export-review-only; proof relevance and freshness lineage must be preserved or explicitly excluded. | High if proof detail and receipt detail duplicate each other. |
| Safe-failure receipts | Retain at least enough to explain blocked, failed safely, or confirmation-required operations. | Safety and user trust. | User delete can clear detail after no active unsafe state depends on it; a minimal failure marker may remain if it prevents retry/resurrection. | Export only by receipt category selection and redaction. | Medium; useful for diagnostics but must not become tracking. |
| Tombstones and lineage markers | Retain while needed to prevent deleted/reset/replaced records from returning through import, replay, or future sync. | No-resurrection and conflict safety. | Recoverable tombstones may expire only by a future retention owner; finalized tombstones should persist until compaction or reset policy says otherwise. | Export-safe tombstones and lineage views redact private source/receipt/replay ids. | Medium/high over long local history. |
| Runtime replay/snapshot receipt links | Retain only as long as they support current trust, source freshness, or rollback paths. | Explains recommendation provenance. | Detail should compact before long-term history unless user explicitly keeps it. Reset can clear. | Usually excluded or redacted summary unless a future export owner proves safe detail. | High because replay traces are sensitive and can grow quickly. |
| Export/import receipts | Retain enough to explain package creation/import, selected categories, exclusions, and conflict outcomes. | User agency over portable data. | Delete clears local package history unless tombstone/lineage is needed for conflict safety. | Export packages do not recursively include old package artifacts by default. | Medium if repeated exports keep duplicate package summaries. |

## Delete Semantics

Receipt delete must be explicit about what disappears and what remains:

- Delete receipt detail: removes title, summary, changed facts, proof references, or other inspectable detail where no active proof/safety state depends on it.
- Redact receipt detail: preserves a receipt shell with privacy, date, source domain, proof relevance, and no-private-detail summary when full deletion would create false proof or conflict risk.
- Tombstone-only delete: retains the smallest lineage marker needed to block resurrection by import, replay, or future CloudKit sync.
- Final delete after reset: full local reset may remove receipt history and tombstones after explicit confirmation, with no hidden cloud/account restore claim.
- Delete is not archive. Archive keeps history available but inactive; delete removes normal inspection detail or replaces it with a minimal safety marker.

Future UI must not describe a receipt as deleted if private detail remains available in another surface, export category, replay trace, or synced copy.

## Reset Semantics

Reset is broader than delete:

- Category reset clears selected receipt families only after explicit confirmation and preview of consequences.
- Full local reset may hard-delete action receipt history, tombstones, replay ledgers, proof records, event ledgers, and related local stores, matching the current source posture of `resetAllData()`.
- Reset must not auto-create a cloud backup. Any pre-reset backup/export is separate, user-selected, previewed, and local-only unless a future issue proves optional user-owned CloudKit behavior.
- Reset must mark or propagate no-resurrection intent before any future sync implementation can be Green.
- Reset cannot claim privacy/legal deletion compliance, device proof, or release readiness from this documentation alone.

## Export Semantics

Receipt export is user-initiated, category-selected, previewed, and redacted:

- The receipts category can include goal feedback, canonical action receipts, revision tombstones, and redacted lineage views.
- Export manifest counts and exclusions must make receipt inclusion visible before package creation.
- Private, sensitive, unavailable, and confirmation-required receipts must use redacted preview/detail by default.
- Export-safe tombstones must redact private source, receipt, and replay identifiers according to privacy class.
- Export preserves enough local-only/proof relevance/freshness metadata for import review, but it does not convert receipts into public claims or hosted diagnostics.
- Export does not mutate or delete local data.

## Local and Synced Path Policy

Local path:

- Current authority is local-first SwiftData plus portable local export.
- Receipt history stays local-only by default.
- Delete/reset/export semantics are local authoritative until a future issue implements and proves sync behavior.

Future user-owned CloudKit path:

- Optional CloudKit continuity must carry receipt, tombstone, reset, and delete intent without hidden resurrection.
- CloudKit record names, indexes, and conflict metadata must avoid raw receipt text or changed facts.
- CloudKit failure must never block local delete/reset/export decisions.
- CloudKit cannot be claimed Green until M23 proves schema, conflict, tombstone, retention, reset, rollback, privacy, and user-control behavior.

R2 path:

- Private receipts, receipt summaries, proof lineage, replay ids, user goal references, and user-derived tombstones must never be stored in R2.
- R2 remains public Source Atlas/source/pathing distribution only.

## Performance and Storage Flags

AMB-657 does not measure performance. It flags storage risks for future owners:

- Required receipt policy search produced 62,089 lines and focused receipt policy search produced 7,692 lines, showing broad receipt/delete/export/reset vocabulary across source, tests, docs, and artifacts.
- Receipt history, event ledger, tombstones, runtime snapshots, proof evidence, and import/export reports can grow for decades.
- Full-detail changed facts and replay references should not be retained forever without compaction.
- Receipt search currently projects from loaded records; AMB-656 owns later query/index follow-up and AMB-660 owns 20-year compaction.
- Future retention enforcement needs date-bounded queries, paging, compacted lineage views, and storage measurement before performance Green.

## Validation

Commands run for AMB-657:

- `git status --short --branch` - clean on `main` before AMB-657 execution except newly generated PLOS-024 validation logs after search.
- `git pull --ff-only` - already up to date.
- `git rev-parse HEAD` - BASE_SHA `b4661b84145d471f8e95bad1d80b15bf60553534`.
- Linear issue fetch for `AMB-657` - succeeded.
- Linear status update for `AMB-657` to In Progress - succeeded.
- `rg -n "receipt|export|reset|delete" . > artifacts/personal-life-os/validation/PLOS-024-receipt-policy-required-search-log.txt` - exited `0`, 62,089 lines.
- Focused receipt policy search over Persistence, Domain, Services, tests, docs/codex, and PLOS-020 through PLOS-023 reports - exited `0`, 7,692 lines, artifact `artifacts/personal-life-os/validation/PLOS-024-focused-receipt-policy-search-log.txt`.
- Focused source inspection of action receipt history, privacy/proof/freshness metadata, receipt projection/search, portable snapshot export/import, export manifest, tombstone redaction, SwiftData reset, and lifecycle/query M02 reports.

Closeout validation run after report creation:

- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T174900.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T174900.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-024-receipt-retention-delete-reset-export-policy.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 52 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T174932.log`.
- `git diff --cached --check` - pending until staging.

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-657 is documentation/control-plane receipt policy work and no app source, project, UI, runtime, test source, privacy manifest, entitlement, retention enforcement, delete/reset/export implementation, receipt browser, or CloudKit transport changed.

## Runtime Path Proof

Not applicable for implementation proof. AMB-657 inspects current source owners and prior PLOS reports to define policy, but it does not implement or change runtime behavior.

## Privacy / Safety / Source Checks

Green for AMB-657 documentation scope:

- Receipts are local-first and local-only by default.
- Receipts are user-owned proof/trust data, not telemetry.
- Delete, reset, and export paths are explicit enough to prevent undeletable dark data claims.
- R2 is excluded from private receipt/proof/replay data.
- Future CloudKit sync remains proof-gated and cannot resurrect deleted/reset receipt data.

## Accessibility Checks

Not applicable. No UI or accessibility behavior changed. No accessibility verification or certification is claimed.

## Rollback / Failure Behavior

Rollback is to revert this AMB-657 artifact/control-plane commit. Later receipt-browser, retention enforcement, delete/reset/export UX, CloudKit, compaction, and performance work must hold if this policy is removed or fails validation.

## Remaining Yellow / Red

Yellow:

- R2 source-only boundary remains AMB-658 / PLOS-025.
- App privacy declaration map remains AMB-659 / PLOS-026.
- 20-year data compaction and annual snapshot model remains AMB-660 / PLOS-027.
- M19 owns measured performance hardening.
- M23 owns CloudKit sync hardening.
- M24 owns diagnostics/export support proof.
- M26 owns certification gauntlets.

Red blockers: none for AMB-657 scope.

## Follow-Up Issues Created

None.

## Next Issue To Run

AMB-658 / PLOS-025 only, after AMB-657 is committed, pushed to `main`, and updated in Linear.

## Non-Claims

AMB-657 does not claim runtime implementation, app source change, receipt-browser implementation, retention enforcement, delete/reset/export UX, export package release readiness, CloudKit implementation, sync conflict behavior, R2 implementation, diagnostics implementation, privacy manifest correctness, privacy/legal approval, App Review readiness, release readiness, TestFlight readiness, App Store readiness, screenshot proof, accessibility verification, measured performance proof, storage scale proof, owner approval, or PLOS-M03+ execution.

## PLOS Child Closeout

PLOS child closeout

Linear issue: AMB-657

Parent issue: AMB-610

Green/Yellow/Red status: Green for AMB-657 receipt retention/delete/reset/export policy documentation scope; Yellow for later retention enforcement, receipt-browser UX, delete/reset/export implementation, compaction, performance, CloudKit, R2 boundary, privacy declaration, release, accessibility, device, and privacy/legal proof not claimed.

Pushed to main: pending at report creation

Push hash: pending at report creation

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no; AMB-608 and AMB-609 were already complete before this M02 child started.

Linear identifiers used: AMB issue identifiers only

Validation run:
- `git status --short --branch` - clean on `main` before child execution except generated AMB-657 logs after search.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-657` - succeeded.
- Linear status update for `AMB-657` to In Progress - succeeded.
- `rg -n "receipt|export|reset|delete" . > artifacts/personal-life-os/validation/PLOS-024-receipt-policy-required-search-log.txt` - exited `0`.
- Focused receipt policy search - exited `0`.
- Focused source inspection of action receipt history, portable export/import, tombstones, SwiftData reset, and M02 boundary/lifecycle/query reports.

Validation run after report creation:
- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T174900.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T174900.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-024-receipt-retention-delete-reset-export-policy.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 52 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T174932.log`.
- `git diff --cached --check` - pending until staging.

Validation not run:
- Build/test/screenshot/accessibility/performance validation was not run because no app source, project, UI, runtime, test source, retention enforcement, delete/reset/export implementation, receipt browser, CloudKit transport, privacy manifest, or release artifact changed.

Proof/claim boundaries:
- Documentation/control-plane policy only.
- No runtime behavior, source implementation, release readiness, accessibility verification, privacy/legal approval, device proof, or performance proof claimed.

Rollback notes:
- Revert the AMB-657 commit to remove this policy/report/control-plane update.

Next eligible action:
- AMB-658 / PLOS-025 only after AMB-657 is committed, pushed to `main`, and updated in Linear.
