+++
spec_id = "SYSTEM-IMPORT-EXPORT-REPAIR"
title = "Import Export and Repair"
kind = "system"
status = "normative"
owner_domain = "system-import-export-repair"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.imported-source.no-silent-change", "system.data.export", "system.data.repair"]
inherits = ["LAW-RUNTIME-NO-DIRECT-WRITE-001", "RUNTIME-MUTATION-SEQUENCE-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "JOURNEY-EXTERNAL-CALENDAR-IMPORT", "JOURNEY-BACKUP-RESTORE-RESET", "SYSTEM-PERSISTENCE-REPLAY", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-DIAGNOSTICS"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Storage/", "Native/Ambitions/Core/LocalRuntimeOS/Repair/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Import Export and Repair

This shadow target coordinates hostile-input import, reviewed export, and protected repair.

## SYSTEM-IMPORTED-SOURCE-001 — Imported source changes never silently alter native truth

- **Concept:** `system.imported-source.no-silent-change`
- **Modality:** `MUST`
- **Scope:** External records, files, calendars, recurrence, attachments, source refresh/removal, duplicates, and reconciliation
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-IMPORTED-SOURCE-001`
- **Supersedes:** `CLAIM-LFT-0221`

An imported or linked source change MUST produce a local durable diff/provenance record and impact preview before it can alter an Ambitions-native object, placement, notification rule, or capacity decision. Adapters parse and report facts but never mutate. Accept, keep local, split, unlink, ignore, quarantine, or reject decisions use stable source lineage and the runtime mutation sequence; source removal never silently deletes native data.

External-only Events MUST remain outside Ambitions Time until imported.

## SYSTEM-EXPORT-001 — Export is explicit reviewed egress, distinct from backup

- **Concept:** `system.data.export`
- **Modality:** `MUST`
- **Scope:** Full/selective object, range, calendar, attachment, diagnostic, and portable data export
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-EXPORT-001`
- **Supersedes:** none

Export MUST preview selected fields, redactions, format, destination, sensitivity, included/excluded relationships and attachments, and non-restorable status unless an owning verified backup contract explicitly says otherwise. Successful generation leaves canonical private content unchanged and durably records artifact identity/result, egress scope, Receipt/History, and replay state. Deleting the artifact does not erase that history.

Goals, Receipts, Proof items, Time plans or views, and relevant objects MAY use contextual native iOS share, print, or export behavior.

Reviewed export egress MUST support a single object, range, calendar, or filtered set selected by the user.

Reviews SHOULD be exportable.

## SYSTEM-REPAIR-001 — Repair is previewed, protected, receipt-backed, and verified

- **Concept:** `system.data.repair`
- **Modality:** `MUST`
- **Scope:** Corruption, schema migration, invariant repair, projection rebuild, quarantine, restore rollback, and destructive reset
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-REPAIR-001`, `AUDIT-SYSTEM-REPAIR-NO-SILENT-001`
- **Supersedes:** none

A repair that may change canonical state MUST begin with redacted diagnosis and dry-run impact, preserve a verified rollback/backup boundary, require scoped confirmation, execute through the runtime sequence, verify post-repair invariants/replay, and issue Receipt/History. Silent deletion, automatic destructive reset, repair from an unverified export, or destruction of the only readable copy is forbidden.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns import parsing/diff/quarantine coordination, export policy/artifact result, migration/repair plan and dry run, backup/rollback protection, invariant verification, and operation-specific lineage. It does not own external source truth, object lifecycle, account/continuity, adapter mutation, or silent cleanup.

<!-- canon-section: inputs-outputs -->
The contract consumes hostile source bytes/facts, provenance/fingerprint, current canonical state, requested import/export/repair scope, classification/redaction, schema/invariants, capacity, rollback point, and confirmation. It emits bounded parse result, durable diff, preview, Command plan, export artifact/result, quarantine, repaired/rebuilt state, Receipt/History, and recovery actions.

<!-- canon-section: authority-boundary -->
Adapters and parsers produce facts only. `Repair/` plans and verifies; `PrivacySecurity/` owns egress; `Storage/` owns substrate/backup; `Commands/` owns mutation; `Inspection/` owns lineage. Export never becomes backup by naming, and diagnostics never execute repair.

<!-- canon-section: data-classification -->
Imported bytes and metadata are hostile external data; canonical imports become private graph; exports are explicit sensitive egress; backups/rollback points are protected private artifacts; diagnostic fields are redacted. Every format declares field, blob, retention, and destination policy.

<!-- canon-section: state-model -->
Operations distinguish scan/parse, candidate/diff, preview, confirmed, locally committed, artifact generated, externally pending/result, quarantined, repair planned/dry-run, protected, executing, verified, rolled back, failed, and irreversible boundary with stable IDs.

<!-- canon-section: failure-recovery -->
Malformed/oversized/tampered input, partial import/export, low storage, permission loss, interruption, migration incompatibility, corrupt backup, failed invariant, or external error preserves original input and last honest store. Recovery offers retry, narrower scope, quarantine, export/backup when safe, rollback, or explicit unsupported-store path without false success.

<!-- canon-section: local-network-boundary -->
Local file/calendar import review, export to user-chosen local destination, backup/restore/repair, receipts, and recovery work without account/network where applicable. External source/write unavailability waits after local facts; no private payload goes to R2/Source Atlas/Ambitions backend/hosted AI.

<!-- canon-section: determinism -->
Stable source bytes/fingerprint, schema, canonical state, operation scope, policy, and seed produce equivalent parse/diff/plan/export manifest/repair result. Duplicate retries are idempotent; ordinary replay never repeats egress.

<!-- canon-section: observability -->
Local redacted evidence binds operation/artifact/source/command IDs, schema/fingerprint, phase, selected field names/redactions, rollback point, invariant/checksum, Receipt, external result, and recovery without private values.

<!-- canon-section: source-ownership -->
Canonical ownership is divided among ExternalWrites, Storage, Repair, PrivacySecurity, Commands, Inspection, and Quality.
Exact targets are `Core/LocalRuntimeOS/ExternalWrites/`, `Storage/`, `Repair/`, `PrivacySecurity/`, `Commands/`, and `Inspection/`; `Quality/` owns hostile fixtures, crash matrices, and data-safety proof.

<!-- canon-section: tests-proof -->
Cover malformed/oversized/decompression/path/encoding input, duplicates/recurrence/time-zone, source update/removal, no-silent-change target, partial import, export full/selective/redaction/cancel/artifact deletion, export-not-backup, tampered backup, every migration path/crash point, low storage, quarantine, rollback, invariant/replay/projection rebuild, permission/network loss, privacy egress attacks, and accessibility.

<!-- canon-section: performance-resource-constraints -->
Parsing, hashing, diffing, export, migration, backup/restore, rebuild, and verification are size/recursion/decompression limited, streaming, bounded, cancellable, backpressured, and off-main where material. Article 31 calibration must define representative record/blob/store scales, device/OS/build/tool, percentile/maximum, memory/energy/storage, and regression thresholds; no numeric budget is invented.
