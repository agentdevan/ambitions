+++
spec_id = "JOURNEY-BACKUP-RESTORE-RESET"
title = "Backup Restore Reset"
kind = "journey"
status = "normative"
owner_domain = "journey-backup-restore-reset"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.delete-restore.trash"]
inherits = ["OBJECT-LIFECYCLE-DELETION-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "SURFACE-YOU", "APP-DEGRADED-STATES", "OBJECT-RECEIPT", "OBJECT-HISTORY-EVENT", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Surfaces/You/", "Native/Ambitions/Core/LocalRuntimeOS/Storage/", "Native/Ambitions/Core/LocalRuntimeOS/Repair/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Continuity/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Backup Restore Reset

This shadow journey coordinates distinct backup, restore, export, Trash, reset, and deletion operations without asserting a currently enabled backup/continuity mechanism or redefining per-object deletion lifecycle. `Storage/` owns backup/migration stores, `Repair/` owns schema/migration planning, backup verification, quarantine, repair, and rollback, and `PrivacySecurity/` owns scoped export/egress.

## JOURNEY-DELETE-RESTORE-001 — Trash, restore, reset, and permanent deletion stay distinct

- **Concept:** `journey.delete-restore.trash`
- **Modality:** `MUST`
- **Scope:** Object Trash/restore and separate whole-local-graph backup, restore, export, reset, or deletion operations
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-DELETE-RESTORE-001`
- **Supersedes:** none

Trash MUST remain recoverable and distinct from permanent deletion or reset. Backup MUST be a verified restorable recovery artifact before it may satisfy a safe-recovery-point precondition. No cited owning contract declares ordinary data export restorable, so export in this journey is a scoped, previewed egress package and is explicitly not restorable. Export cannot serve as a backup or recovery point. Restore and reset previews are non-durable until validation and explicit scope confirmation; irreversible operations require precise consequence, retained/excluded data, rollback limit, account/continuity distinction, and proof of a safe local boundary before success.

<!-- canon-section: trigger-starting-state -->
The trigger record binds one chosen operation to a local store fingerprint, exact data scope, artifact class, and user-visible origin.
Triggers are separately: create/verify backup, restore from a verified backup, create a full/selective non-restorable export, object Trash/restore, reset, permanent deletion, or degraded-store recovery. Backup/restore starting state records store health, protected-data availability, backup integrity/schema compatibility, free space, and latest verified backup recovery point. Export starting state records selected fields/objects, redaction and destination/egress scope, format, and explicit non-restorable status. Destructive starting state records exact local scope, continuity/account distinction, and rollback limit.

<!-- canon-section: preconditions -->
Each operation has a separate preflight and cannot borrow another operation's guarantee.
Backup preflight verifies local authority, complete declared backup scope, artifact integrity, schema metadata, and restorable verification before designating a recovery point. Restore preflight accepts only a verified backup, authenticates and integrity/schema-checks it, verifies destination capacity, and stages migration/repair without overwriting the last honest store. Export preflight validates selection, redaction, format, destination, and egress confirmation and states that the package is not restorable. Trash/reset/deletion preflight enumerates exact consequences and accepts only a verified backup—not an export—where a safe recovery point is required. Optional account or CloudKit state never substitutes for verified local backup proof.

<!-- canon-section: happy-path -->
Choose exactly one operation and scope. Backup creates an artifact, verifies integrity/schema/restorability, then marks it as a recovery point and issues a backup Receipt. Export previews selected/redacted content and destination, confirms egress, and creates a non-restorable package without mutating canonical private object content; successful generation durably commits canonical export Receipt/history metadata and replay state in the trust/history graph. Restore stages only a verified backup, validates migration/repair and consequences, confirms, activates atomically, rebuilds projections, verifies replay/integrity, and issues a restore Receipt. Trash/reset/deletion preview their own consequences before their distinct commit.

<!-- canon-section: branches -->
Branches are create/verify restorable backup, full non-restorable export, selective non-restorable export, staged restore from verified backup, object Trash, restore from Trash, merge only where an owning approved contract exists, reset preferences, reset learned influences, reset private graph, permanent deletion, cancel, or quarantine corrupt backup/staging input. Export never enters restore/staging/merge branches. Account deletion, sign-out, continuity disablement, and local deletion remain separate.

<!-- canon-section: cancellation -->
The cancellation record stores operation class, phase, artifact ID, content-store fingerprint, Receipt ID, and action set.
Cancel backup before verification without designating a recovery point. Cancel export preview before successful generation without producing/sharing a package or committing successful export Receipt/history metadata; a command rejection remains truthful under the owning Receipt contract. After successful export, dismissal cannot cancel or erase the artifact result or canonical export Receipt/history metadata. Cancel restore before activation with the active content store untouched and only safe staging removed; cancel Trash/reset/deletion before commit with no content mutation. Once an irreversible boundary begins, the UI follows that operation's declared atomic/repair plan rather than offering a false cancel.

<!-- canon-section: interruption-resume -->
The durable operation journal identifies operation class, artifact class, source, staging or export destination, active store, completed phase, and the sole safe next phase after relaunch.
Backup resumes verification before recovery-point designation. Before successful generation, Export resumes from its redacted selection/egress phase; after success, it resumes from durable export Receipt/history metadata and artifact result without rereading that state as content mutation or restore input. Restore resumes from verified-backup source, staging, active-store identities, integrity results, confirmation revision, and repair state. Destructive work resumes from its exact journal. Relaunch selects the last proven valid store or enters explicit repair; it never guesses between partial copies or treats export as backup.

<!-- canon-section: commit-boundary -->
Backup construction is not a recovery point until integrity/schema/restorability verification commits its designation and Receipt. Export selection/preview is non-durable. Successful export generation leaves canonical private object content unchanged but crosses a durable trust/history boundary that commits canonical export Receipt/history metadata, artifact identity/result, egress scope, and replay state. It never activates a content store or qualifies as a recovery point. Backup inspection, migration plan, diff, restore simulation, deletion/reset preview, and staging are non-durable to the active content graph. Restore commits at validated atomic activation; Trash commits as recoverable state; reset/permanent deletion commits only after exact destructive confirmation, any required verified-backup precondition, and durable operation journal/Receipt.

<!-- canon-section: failure -->
The failure record stores operation class, phase, artifact ID, content-store fingerprint, trust/history result, and exact recovery set.
Incomplete/corrupt/incompatible backup cannot be designated a recovery point or restored. Export selection/redaction/destination failure cannot claim export success, mutate private object content, or issue successful export metadata; its rejected/failed command result remains truthful in Receipt/history where required. Failure after artifact generation preserves canonical export Receipt/history metadata and exact artifact/egress result and has no restore fallback. Other failures cannot discard the last honest recoverable content state or claim a later operation phase.

<!-- canon-section: recovery -->
Each recovery choice begins from the verified active store and names the backup, export, or staging artifact and operation phase it will inspect, retry, quarantine, or discard.
Backup recovery retries verification or quarantines the backup and never marks it safe prematurely. Before successful export, recovery retries redaction/destination/egress. After success, it may inspect the canonical export Receipt/history metadata or delete the export artifact through an explicit action, but it never edits private object content, erases trust/history, or offers export for restore. Restore recovery retries integrity/migration idempotently or returns to the active store. Redacted diagnostic export is troubleshooting egress, not backup. Destructive reset is never routine recovery for an unclassified failure.

<!-- canon-section: undo-rollback -->
Trash restores through object law. Backup verification may revoke an invalid recovery-point designation without changing the active content graph. Export has no private-content rollback because it does not mutate canonical private object content; deleting its artifact cannot restore data and does not erase canonical export Receipt/history metadata. Any governed correction appends trust/history lineage. Restore/reset rollback reactivates a verified prior store only while the declared verified backup recovery point exists; permanent deletion states its irreversible boundary and cannot promise Undo.

<!-- canon-section: receipts-proof -->
Each Receipt binds one operation class and cannot transfer guarantees to another class.
Backup Receipts record scope, store/schema fingerprints, integrity and restorable verification, recovery-point designation, and revocation. Every successful export durably commits canonical export Receipt/history metadata containing full/selective scope, redactions, format, artifact identity, destination/egress result, explicit non-restorable status, and replay outcome while leaving canonical private object content unchanged. Rejected/failed export commands remain truthful under the Receipt owner. Restore and destructive Receipts remain operation-specific. A backup artifact is not release proof, and this specification is not data-safety proof.

<!-- canon-section: accessibility -->
Ordered semantics place operation and scope before consequence, confirmation, progress, result, and recovery actions.
Semantics announce Backup, Restore, Export, Trash, Reset, or Delete as distinct operations and expose scope, artifact class, restorable/non-restorable status, retained/deleted data, backup identity/date/schema/integrity, export redaction/destination, consequences, rollback limit, confirmation, progress, and recovery in order. Destructive controls are explicit, comparisons do not depend on color/layout, Dynamic Type preserves full warnings, and focus returns to operation status.

<!-- canon-section: offline -->
Local backup creation/verification, staged restore from verified backup, full/selective non-restorable export generation to a user-chosen local destination, Trash/restore, reset, permanent deletion, operation-specific receipts, replay, integrity, and repair work without account/network where applicable. Offline export leaves canonical private object content unchanged while durably committing canonical export Receipt/history metadata and replay after successful generation. Export remains explicit egress and never becomes a recovery point.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-DELETE-RESTORE-001`, `SCENARIO-JOURNEY-BACKUP-INTEGRITY-001`, `SCENARIO-JOURNEY-BACKUP-RECOVERY-POINT-001`, `SCENARIO-JOURNEY-EXPORT-FULL-NONRESTORABLE-001`, `SCENARIO-JOURNEY-EXPORT-SELECTIVE-NONRESTORABLE-001`, `SCENARIO-JOURNEY-EXPORT-CONTENT-UNCHANGED-001`, `SCENARIO-JOURNEY-EXPORT-RECEIPT-COMMIT-001`, `SCENARIO-JOURNEY-EXPORT-CANCEL-BEFORE-AFTER-001`, `SCENARIO-JOURNEY-EXPORT-ARTIFACT-DELETE-HISTORY-001`, `SCENARIO-JOURNEY-EXPORT-NOT-BACKUP-001`, `SCENARIO-JOURNEY-RESTORE-VERIFIED-BACKUP-ONLY-001`, `SCENARIO-JOURNEY-RESTORE-MIGRATION-001`, `SCENARIO-JOURNEY-RESTORE-INTERRUPTION-001`, `SCENARIO-JOURNEY-RESET-SCOPE-001`, `SCENARIO-JOURNEY-PERMANENT-DELETE-001`, and `SCENARIO-JOURNEY-BACKUP-EXPORT-OFFLINE-001`; independently assert export leaves canonical private object content byte/fact-identical, successful export durably commits canonical Receipt/history metadata and replay, before/after-success cancellation semantics, artifact deletion preserves trust/history, backup verification, export non-restorability, restore rejection, operation-specific ownership/receipts, accessibility, and no false success.
