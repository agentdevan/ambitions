import AmbitionsRuntimeSQLite
import Foundation

enum CanonicalRuntimeAttachmentSchemaPlan {
    static let sourceSchemaVersion = runtimeCanonicalExternalOperationSchemaVersion
    static let targetSchemaVersion = runtimeCanonicalAttachmentSchemaVersion

    static let tables: Set<String> = [
        "runtime_attachment_identities", "runtime_attachment_revisions", "runtime_blob_records",
        "runtime_blob_dedup_authority",
        "runtime_attachment_references", "runtime_attachment_current_lifecycle",
        "runtime_attachment_lifecycle_history", "runtime_attachment_reference_history",
        "runtime_blob_key_envelopes", "runtime_blob_key_rewrap_jobs",
        "runtime_blob_key_rewrap_items",
        "runtime_blob_quota_ledgers", "runtime_blob_quota_reservations", "runtime_blob_retention_holds",
        "runtime_blob_retention_hold_history",
        "runtime_blob_quarantine", "runtime_blob_finalization_intents",
        "runtime_blob_finalization_completions",
        "runtime_blob_gc_leases", "runtime_blob_gc_lease_history",
        "runtime_blob_deletion_tombstones",
        "runtime_blob_staging_orphans", "runtime_attachment_receipt_links",
        "runtime_attachment_recovery_findings", "runtime_attachment_recovery_attempts",
        "runtime_attachment_recovery_reopen_history",
        "runtime_attachment_recovery_cursors",
        "runtime_attachment_manifest_deletion_claims",
        "runtime_attachment_manifest_deletion_tombstones",
    ]

    static let indexes: Set<String> = [
        "runtime_attachment_revisions_blob_idx", "runtime_attachment_references_target_idx",
        "runtime_attachment_references_blob_idx", "runtime_attachment_references_active_unique_idx",
        "runtime_attachment_lifecycle_due_idx",
        "runtime_attachment_history_blob_idx", "runtime_blob_quota_expiry_idx",
        "runtime_attachment_reference_history_idx",
        "runtime_blob_holds_blob_idx", "runtime_blob_quarantine_blob_idx",
        "runtime_blob_hold_history_idx",
        "runtime_blob_finalization_due_idx", "runtime_blob_gc_lease_expiry_idx",
        "runtime_blob_gc_lease_history_idx", "runtime_attachment_recovery_findings_identity_idx",
        "runtime_blob_staging_orphans_due_idx",
        "runtime_attachment_recovery_findings_due_idx",
        "runtime_attachment_recovery_attempts_due_idx",
        "runtime_attachment_receipt_links_receipt_idx",
        "runtime_blob_dedup_authority_blob_idx",
        "runtime_blob_key_rewrap_active_source_idx", "runtime_blob_key_rewrap_items_due_idx",
        "runtime_attachment_manifest_deletion_claims_due_idx",
    ]

    static let statements: [String] = [
        """
        CREATE TABLE runtime_attachment_identities (
            attachment_id TEXT PRIMARY KEY CHECK (length(attachment_id) BETWEEN 1 AND 1024),
            privacy TEXT NOT NULL CHECK (privacy IN ('standard','sensitive','private_user_text','calendar_derived','sync_metadata')),
            local_only INTEGER NOT NULL CHECK (local_only = 1),
            identity_version INTEGER NOT NULL CHECK (identity_version = 1),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_records (
            blob_id TEXT PRIMARY KEY CHECK (length(blob_id) BETWEEN 1 AND 1024),
            privacy_domain TEXT NOT NULL CHECK (privacy_domain IN ('standard','sensitive','private_user_text','calendar_derived','sync_metadata')),
            quota_owner_id TEXT NOT NULL CHECK (length(quota_owner_id) BETWEEN 1 AND 1024),
            dedup_policy TEXT NOT NULL CHECK (dedup_policy IN ('within_privacy_domain','never')),
            keyed_content_address TEXT NOT NULL CHECK (length(keyed_content_address) = 64 AND keyed_content_address NOT GLOB '*[^0-9a-f]*'),
            manifest_version INTEGER NOT NULL CHECK (manifest_version = 1),
            manifest_payload BLOB NOT NULL CHECK (length(manifest_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            manifest_digest TEXT NOT NULL CHECK (length(manifest_digest) = 64 AND manifest_digest NOT GLOB '*[^0-9a-f]*'),
            plaintext_byte_count INTEGER NOT NULL CHECK (plaintext_byte_count BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumAttachmentBytes)),
            ciphertext_byte_count INTEGER NOT NULL CHECK (ciphertext_byte_count > plaintext_byte_count),
            protection_class TEXT NOT NULL CHECK (protection_class = 'complete'),
            opaque_relative_directory TEXT NOT NULL UNIQUE CHECK (length(opaque_relative_directory) BETWEEN 5 AND 1024 AND opaque_relative_directory NOT LIKE '/%' AND opaque_relative_directory NOT LIKE '%..%'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            UNIQUE (blob_id, manifest_digest),
            FOREIGN KEY (privacy_domain, quota_owner_id) REFERENCES runtime_blob_quota_ledgers(privacy_domain, owner_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_dedup_authority (
            privacy_domain TEXT NOT NULL CHECK (privacy_domain IN ('standard','sensitive','private_user_text','calendar_derived','sync_metadata')),
            keyed_content_address TEXT NOT NULL CHECK (length(keyed_content_address) = 64 AND keyed_content_address NOT GLOB '*[^0-9a-f]*'),
            manifest_version INTEGER NOT NULL CHECK (manifest_version = 1),
            protection_class TEXT NOT NULL CHECK (protection_class = 'complete'),
            canonical_blob_id TEXT NOT NULL UNIQUE,
            authority_version INTEGER NOT NULL CHECK (authority_version = 1),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            PRIMARY KEY (privacy_domain, keyed_content_address, manifest_version, protection_class),
            FOREIGN KEY (canonical_blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_dedup_authority_blob_idx ON runtime_blob_dedup_authority(canonical_blob_id)",
        """
        CREATE TABLE runtime_attachment_revisions (
            revision_id TEXT PRIMARY KEY CHECK (length(revision_id) BETWEEN 1 AND 1024),
            attachment_id TEXT NOT NULL,
            attachment_revision INTEGER NOT NULL CHECK (attachment_revision > 0),
            quota_reservation_id TEXT NOT NULL UNIQUE,
            blob_id TEXT NOT NULL,
            manifest_digest TEXT NOT NULL,
            content_version INTEGER NOT NULL CHECK (content_version = 1),
            content_payload BLOB NOT NULL CHECK (length(content_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            content_digest TEXT NOT NULL UNIQUE CHECK (length(content_digest) = 64 AND content_digest NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            UNIQUE (attachment_id, attachment_revision),
            UNIQUE (revision_id, blob_id),
            FOREIGN KEY (attachment_id) REFERENCES runtime_attachment_identities(attachment_id),
            FOREIGN KEY (quota_reservation_id) REFERENCES runtime_blob_quota_reservations(reservation_id),
            FOREIGN KEY (blob_id, manifest_digest) REFERENCES runtime_blob_records(blob_id, manifest_digest)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_revisions_blob_idx ON runtime_attachment_revisions(blob_id, attachment_id, attachment_revision)",
        """
        CREATE TRIGGER runtime_attachment_revision_sequence_guard
        BEFORE INSERT ON runtime_attachment_revisions
        WHEN NEW.attachment_revision <> COALESCE(
            (SELECT MAX(v.attachment_revision) + 1 FROM runtime_attachment_revisions AS v WHERE v.attachment_id = NEW.attachment_id),
            1
        )
        BEGIN SELECT RAISE(ABORT, 'attachment revision sequence mismatch'); END
        """,
        """
        CREATE TABLE runtime_blob_key_envelopes (
            blob_id TEXT PRIMARY KEY,
            wrapping_key_id TEXT NOT NULL CHECK (length(wrapping_key_id) BETWEEN 1 AND 256),
            wrapping_key_version INTEGER NOT NULL CHECK (wrapping_key_version > 0),
            envelope_version INTEGER NOT NULL CHECK (envelope_version = 1),
            algorithm TEXT NOT NULL CHECK (algorithm = 'AES.GCM.keywrap.v1'),
            envelope_payload BLOB NOT NULL CHECK (length(envelope_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumEnvelopeBytes)),
            envelope_digest TEXT NOT NULL UNIQUE CHECK (length(envelope_digest) = 64 AND envelope_digest NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_key_rewrap_jobs (
            job_id TEXT PRIMARY KEY CHECK (length(job_id) BETWEEN 1 AND 1024),
            source_key_id TEXT NOT NULL CHECK (length(source_key_id) BETWEEN 1 AND 256),
            source_key_version INTEGER NOT NULL CHECK (source_key_version > 0),
            target_key_id TEXT NOT NULL CHECK (length(target_key_id) BETWEEN 1 AND 256),
            target_key_version INTEGER NOT NULL CHECK (target_key_version = source_key_version + 1),
            job_state TEXT NOT NULL CHECK (job_state IN ('active','completed')),
            total_envelope_count INTEGER NOT NULL CHECK (total_envelope_count >= 0),
            completed_envelope_count INTEGER NOT NULL CHECK (completed_envelope_count BETWEEN 0 AND total_envelope_count),
            failed_envelope_count INTEGER NOT NULL CHECK (failed_envelope_count BETWEEN 0 AND total_envelope_count - completed_envelope_count),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= created_at_ms),
            completed_at_ms INTEGER CHECK (completed_at_ms >= created_at_ms),
            CHECK (source_key_id <> target_key_id),
            CHECK ((job_state = 'completed') = (completed_at_ms IS NOT NULL))
        ) WITHOUT ROWID
        """,
        "CREATE UNIQUE INDEX runtime_blob_key_rewrap_active_source_idx ON runtime_blob_key_rewrap_jobs(source_key_id, source_key_version) WHERE job_state = 'active'",
        """
        CREATE TABLE runtime_blob_key_rewrap_items (
            job_id TEXT NOT NULL,
            blob_id TEXT NOT NULL,
            expected_envelope_digest TEXT NOT NULL CHECK (length(expected_envelope_digest) = 64 AND expected_envelope_digest NOT GLOB '*[^0-9a-f]*'),
            item_state TEXT NOT NULL CHECK (item_state IN ('pending','in_progress','failed','completed')),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            attempt_count INTEGER NOT NULL CHECK (attempt_count BETWEEN 0 AND \(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
            next_retry_at_ms INTEGER NOT NULL CHECK (next_retry_at_ms >= 0),
            lease_owner_id TEXT CHECK (lease_owner_id IS NULL OR length(lease_owner_id) BETWEEN 1 AND 1024),
            lease_token TEXT CHECK (lease_token IS NULL OR length(lease_token) BETWEEN 1 AND 256),
            lease_expires_at_ms INTEGER CHECK (lease_expires_at_ms >= 0),
            last_error_fingerprint TEXT CHECK (last_error_fingerprint IS NULL OR (length(last_error_fingerprint) = 64 AND last_error_fingerprint NOT GLOB '*[^0-9a-f]*')),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            completed_at_ms INTEGER CHECK (completed_at_ms >= 0),
            PRIMARY KEY (job_id, blob_id),
            CHECK ((item_state = 'in_progress') = (lease_owner_id IS NOT NULL AND lease_token IS NOT NULL AND lease_expires_at_ms IS NOT NULL)),
            CHECK ((item_state = 'completed') = (completed_at_ms IS NOT NULL)),
            FOREIGN KEY (job_id) REFERENCES runtime_blob_key_rewrap_jobs(job_id),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_key_envelopes(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_key_rewrap_items_due_idx ON runtime_blob_key_rewrap_items(job_id, item_state, next_retry_at_ms, lease_expires_at_ms, blob_id)",
        """
        CREATE TABLE runtime_attachment_current_lifecycle (
            blob_id TEXT PRIMARY KEY,
            lifecycle_state TEXT NOT NULL CHECK (lifecycle_state IN ('staged','referenced','finalized','orphaned','quarantined','deletion_pending')),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            reference_count INTEGER NOT NULL CHECK (reference_count BETWEEN 0 AND \(RuntimeAttachmentLimits.maximumReferences)),
            manifest_digest TEXT NOT NULL,
            retention_until_ms INTEGER CHECK (retention_until_ms >= 0),
            quarantine_reason TEXT CHECK (quarantine_reason IN ('malformed_source','content_type_mismatch','signature_mismatch','size_limit_exceeded','manifest_mismatch','ciphertext_missing','authentication_failed','protection_insufficient','path_authority_violation','future_format')),
            lifecycle_version INTEGER NOT NULL CHECK (lifecycle_version = 1),
            lifecycle_payload BLOB NOT NULL CHECK (length(lifecycle_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            lifecycle_digest TEXT NOT NULL CHECK (length(lifecycle_digest) = 64 AND lifecycle_digest NOT GLOB '*[^0-9a-f]*'),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            CHECK ((lifecycle_state IN ('staged','orphaned','deletion_pending') AND reference_count = 0) OR lifecycle_state = 'quarantined' OR (lifecycle_state IN ('referenced','finalized') AND reference_count > 0)),
            CHECK ((lifecycle_state = 'quarantined') = (quarantine_reason IS NOT NULL)),
            FOREIGN KEY (blob_id, manifest_digest) REFERENCES runtime_blob_records(blob_id, manifest_digest)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_lifecycle_due_idx ON runtime_attachment_current_lifecycle(lifecycle_state, retention_until_ms, updated_at_ms, blob_id)",
        """
        CREATE TABLE runtime_attachment_references (
            reference_id TEXT PRIMARY KEY CHECK (length(reference_id) BETWEEN 1 AND 1024),
            revision_id TEXT NOT NULL,
            blob_id TEXT NOT NULL,
            target_family TEXT NOT NULL CHECK (target_family IN ('capture','goal','step','schedule','reminder','profile','history','repair','import_deletion','external_operation','attachment')),
            target_object_id TEXT NOT NULL CHECK (length(target_object_id) BETWEEN 1 AND 1024),
            target_revision INTEGER NOT NULL CHECK (target_revision >= 0),
            reference_state TEXT NOT NULL CHECK (reference_state IN ('active','removed')),
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            reference_version INTEGER NOT NULL CHECK (reference_version = 1),
            reference_payload BLOB NOT NULL CHECK (length(reference_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            reference_digest TEXT NOT NULL UNIQUE CHECK (length(reference_digest) = 64 AND reference_digest NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            removed_at_ms INTEGER CHECK (removed_at_ms >= created_at_ms),
            CHECK ((reference_state = 'active' AND removed_at_ms IS NULL) OR (reference_state = 'removed' AND removed_at_ms IS NOT NULL)),
            UNIQUE (reference_id, revision_id, blob_id),
            FOREIGN KEY (revision_id, blob_id) REFERENCES runtime_attachment_revisions(revision_id, blob_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_references_target_idx ON runtime_attachment_references(target_family, target_object_id, reference_state, reference_id)",
        "CREATE INDEX runtime_attachment_references_blob_idx ON runtime_attachment_references(blob_id, reference_state, reference_id)",
        "CREATE UNIQUE INDEX runtime_attachment_references_active_unique_idx ON runtime_attachment_references(revision_id, target_family, target_object_id) WHERE reference_state = 'active'",
        """
        CREATE TABLE runtime_attachment_reference_history (
            history_id TEXT PRIMARY KEY CHECK (length(history_id) BETWEEN 1 AND 1024),
            reference_id TEXT NOT NULL,
            revision_id TEXT NOT NULL,
            blob_id TEXT NOT NULL,
            from_state TEXT CHECK (from_state IN ('active','removed')),
            to_state TEXT NOT NULL CHECK (to_state IN ('active','removed')),
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            history_version INTEGER NOT NULL CHECK (history_version = 1),
            history_payload BLOB NOT NULL CHECK (length(history_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            history_digest TEXT NOT NULL UNIQUE CHECK (length(history_digest) = 64 AND history_digest NOT GLOB '*[^0-9a-f]*'),
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            UNIQUE (reference_id, to_state),
            CHECK ((from_state IS NULL AND to_state = 'active') OR (from_state = 'active' AND to_state = 'removed')),
            FOREIGN KEY (reference_id, revision_id, blob_id)
                REFERENCES runtime_attachment_references(reference_id, revision_id, blob_id)
                DEFERRABLE INITIALLY DEFERRED,
            FOREIGN KEY (revision_id, blob_id) REFERENCES runtime_attachment_revisions(revision_id, blob_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_reference_history_idx ON runtime_attachment_reference_history(reference_id, occurred_at_ms, history_id)",
        """
        CREATE TABLE runtime_attachment_lifecycle_history (
            history_id TEXT PRIMARY KEY CHECK (length(history_id) BETWEEN 1 AND 1024),
            blob_id TEXT NOT NULL,
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            from_state TEXT CHECK (from_state IN ('staged','referenced','finalized','orphaned','quarantined','deletion_pending')),
            to_state TEXT NOT NULL CHECK (to_state IN ('staged','referenced','finalized','orphaned','quarantined','deletion_pending')),
            from_reference_count INTEGER CHECK (from_reference_count BETWEEN 0 AND \(RuntimeAttachmentLimits.maximumReferences)),
            to_reference_count INTEGER NOT NULL CHECK (to_reference_count BETWEEN 0 AND \(RuntimeAttachmentLimits.maximumReferences)),
            command_id TEXT,
            receipt_id TEXT,
            terminal_event_sequence INTEGER,
            finalization_completion_id TEXT UNIQUE,
            system_authority_kind TEXT CHECK (system_authority_kind IN (
                'staged_expiry','recovery_quarantine','garbage_collection_fence',
                'garbage_collection_lease'
            )),
            system_authority_id TEXT CHECK (
                system_authority_id IS NULL OR length(system_authority_id) BETWEEN 1 AND 1024
            ),
            system_evidence_fingerprint TEXT CHECK (
                system_evidence_fingerprint IS NULL OR (
                    length(system_evidence_fingerprint) = 64
                    AND system_evidence_fingerprint NOT GLOB '*[^0-9a-f]*'
                )
            ),
            history_version INTEGER NOT NULL CHECK (history_version = 1),
            history_payload BLOB NOT NULL CHECK (length(history_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            history_digest TEXT NOT NULL UNIQUE CHECK (length(history_digest) = 64 AND history_digest NOT GLOB '*[^0-9a-f]*'),
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            UNIQUE (blob_id, state_version),
            CHECK ((from_state IS NULL) = (from_reference_count IS NULL)),
            CHECK ((command_id IS NULL) = (receipt_id IS NULL) AND (receipt_id IS NULL) = (terminal_event_sequence IS NULL)),
            CHECK ((system_authority_kind IS NULL) = (system_authority_id IS NULL)
                AND (system_authority_id IS NULL) = (system_evidence_fingerprint IS NULL)),
            CHECK (((from_state = 'referenced' AND to_state = 'finalized'))
                = (finalization_completion_id IS NOT NULL)),
            CHECK (
                (from_state IS NULL AND command_id IS NULL AND system_authority_kind IS NULL)
                OR (from_state IS NOT NULL AND (
                    (command_id IS NOT NULL AND system_authority_kind IS NULL)
                    OR (command_id IS NULL AND system_authority_kind IS NOT NULL)
                ))
            ),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence),
            FOREIGN KEY (finalization_completion_id)
                REFERENCES runtime_blob_finalization_completions(completion_id)
                DEFERRABLE INITIALLY DEFERRED
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_history_blob_idx ON runtime_attachment_lifecycle_history(blob_id, state_version)",
        """
        CREATE TABLE runtime_blob_quota_ledgers (
            privacy_domain TEXT NOT NULL CHECK (privacy_domain IN ('standard','sensitive','private_user_text','calendar_derived','sync_metadata')),
            owner_id TEXT NOT NULL CHECK (length(owner_id) BETWEEN 1 AND 1024),
            limit_bytes INTEGER NOT NULL CHECK (limit_bytes BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumQuotaBytesPerPrivacyDomain)),
            reserved_bytes INTEGER NOT NULL CHECK (reserved_bytes BETWEEN 0 AND limit_bytes),
            stored_bytes INTEGER NOT NULL CHECK (stored_bytes BETWEEN 0 AND limit_bytes),
            orphan_bytes INTEGER NOT NULL CHECK (orphan_bytes BETWEEN 0 AND limit_bytes),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            CHECK (reserved_bytes + stored_bytes + orphan_bytes <= limit_bytes),
            PRIMARY KEY (privacy_domain, owner_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_quota_reservations (
            reservation_id TEXT PRIMARY KEY CHECK (length(reservation_id) BETWEEN 1 AND 1024),
            privacy_domain TEXT NOT NULL CHECK (privacy_domain IN ('standard','sensitive','private_user_text','calendar_derived','sync_metadata')),
            reserved_bytes INTEGER NOT NULL CHECK (reserved_bytes BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumAttachmentBytes)),
            owner_id TEXT NOT NULL CHECK (length(owner_id) BETWEEN 1 AND 1024),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > created_at_ms AND expires_at_ms - created_at_ms <= \(Int64(RuntimeAttachmentLimits.maximumQuotaReservationSeconds * 1_000))),
            consumed_by_blob_id TEXT,
            released_at_ms INTEGER CHECK (released_at_ms >= created_at_ms),
            reservation_version INTEGER NOT NULL CHECK (reservation_version = 1),
            CHECK ((consumed_by_blob_id IS NULL) OR released_at_ms IS NULL),
            FOREIGN KEY (consumed_by_blob_id) REFERENCES runtime_blob_records(blob_id),
            FOREIGN KEY (privacy_domain, owner_id) REFERENCES runtime_blob_quota_ledgers(privacy_domain, owner_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_quota_expiry_idx ON runtime_blob_quota_reservations(expires_at_ms, consumed_by_blob_id, reservation_id)",
        """
        CREATE TABLE runtime_blob_retention_holds (
            hold_id TEXT PRIMARY KEY CHECK (length(hold_id) BETWEEN 1 AND 1024),
            blob_id TEXT NOT NULL,
            hold_kind TEXT NOT NULL CHECK (hold_kind IN ('receipt','replay','compensation','backup','migration','export','recovery')),
            authority_id TEXT NOT NULL CHECK (length(authority_id) BETWEEN 1 AND 1024),
            retain_until_ms INTEGER CHECK (retain_until_ms > created_at_ms),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            released_at_ms INTEGER CHECK (released_at_ms >= created_at_ms),
            hold_version INTEGER NOT NULL CHECK (hold_version = 1),
            UNIQUE (blob_id, hold_kind, authority_id),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_holds_blob_idx ON runtime_blob_retention_holds(blob_id, retain_until_ms, hold_id)",
        """
        CREATE TABLE runtime_blob_retention_hold_history (
            history_digest TEXT PRIMARY KEY CHECK (length(history_digest) = 64 AND history_digest NOT GLOB '*[^0-9a-f]*'),
            hold_id TEXT NOT NULL,
            blob_id TEXT NOT NULL,
            transition_kind TEXT NOT NULL CHECK (transition_kind IN ('acquired','released')),
            authority_id TEXT NOT NULL CHECK (length(authority_id) BETWEEN 1 AND 1024),
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            terminal_event_id TEXT NOT NULL CHECK (length(terminal_event_id) BETWEEN 1 AND 1024),
            terminal_event_hash TEXT NOT NULL CHECK (length(terminal_event_hash) = 64 AND terminal_event_hash NOT GLOB '*[^0-9a-f]*'),
            history_version INTEGER NOT NULL CHECK (history_version = 1),
            history_payload BLOB NOT NULL CHECK (length(history_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            UNIQUE (hold_id, transition_kind),
            FOREIGN KEY (hold_id) REFERENCES runtime_blob_retention_holds(hold_id)
                DEFERRABLE INITIALLY DEFERRED,
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence),
            FOREIGN KEY (terminal_event_id) REFERENCES runtime_semantic_events(event_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_hold_history_idx ON runtime_blob_retention_hold_history(blob_id, occurred_at_ms, history_digest)",
        """
        CREATE TABLE runtime_blob_quarantine (
            quarantine_id TEXT PRIMARY KEY CHECK (length(quarantine_id) BETWEEN 1 AND 1024),
            blob_id TEXT NOT NULL,
            reason_code TEXT NOT NULL CHECK (reason_code IN ('malformed_source','content_type_mismatch','signature_mismatch','size_limit_exceeded','manifest_mismatch','ciphertext_missing','authentication_failed','protection_insufficient','path_authority_violation','future_format')),
            evidence_fingerprint TEXT NOT NULL CHECK (length(evidence_fingerprint) = 64 AND evidence_fingerprint NOT GLOB '*[^0-9a-f]*'),
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            resolved_at_ms INTEGER CHECK (resolved_at_ms >= observed_at_ms),
            quarantine_version INTEGER NOT NULL CHECK (quarantine_version = 1),
            UNIQUE (blob_id, evidence_fingerprint),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_quarantine_blob_idx ON runtime_blob_quarantine(blob_id, resolved_at_ms, observed_at_ms)",
        """
        CREATE TABLE runtime_blob_finalization_intents (
            blob_id TEXT PRIMARY KEY,
            manifest_digest TEXT NOT NULL,
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            expected_state_version INTEGER NOT NULL CHECK (expected_state_version > 0),
            intent_digest TEXT NOT NULL CHECK (length(intent_digest) = 64 AND intent_digest NOT GLOB '*[^0-9a-f]*'),
            marker_digest TEXT,
            finalized_at_ms INTEGER CHECK (finalized_at_ms >= 0),
            intent_version INTEGER NOT NULL CHECK (intent_version = 1),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            CHECK ((marker_digest IS NULL) = (finalized_at_ms IS NULL)),
            finalization_completion_id TEXT UNIQUE,
            CHECK ((finalization_completion_id IS NULL) = (finalized_at_ms IS NULL)),
            CHECK (marker_digest IS NULL OR (length(marker_digest) = 64 AND marker_digest NOT GLOB '*[^0-9a-f]*')),
            FOREIGN KEY (blob_id, manifest_digest) REFERENCES runtime_blob_records(blob_id, manifest_digest),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence),
            FOREIGN KEY (finalization_completion_id)
                REFERENCES runtime_blob_finalization_completions(completion_id)
                DEFERRABLE INITIALLY DEFERRED
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_finalization_due_idx ON runtime_blob_finalization_intents(finalized_at_ms, created_at_ms, blob_id)",
        """
        CREATE TABLE runtime_blob_gc_leases (
            blob_id TEXT PRIMARY KEY,
            lease_id TEXT NOT NULL UNIQUE CHECK (length(lease_id) BETWEEN 1 AND 1024),
            lease_token TEXT NOT NULL UNIQUE CHECK (length(lease_token) = 64 AND lease_token NOT GLOB '*[^0-9a-f]*'),
            expected_state_version INTEGER NOT NULL CHECK (expected_state_version > 0),
            owner_id TEXT NOT NULL CHECK (length(owner_id) BETWEEN 1 AND 1024),
            acquired_at_ms INTEGER NOT NULL CHECK (acquired_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > acquired_at_ms AND expires_at_ms - acquired_at_ms <= \(Int64(RuntimeAttachmentLimits.maximumLeaseSeconds * 1_000))),
            lease_state TEXT NOT NULL CHECK (lease_state IN ('active','expired','released')),
            authority_version INTEGER NOT NULL CHECK (authority_version > 0),
            lease_version INTEGER NOT NULL CHECK (lease_version = 1),
            lease_payload BLOB NOT NULL CHECK (length(lease_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            lease_digest TEXT NOT NULL CHECK (length(lease_digest) = 64 AND lease_digest NOT GLOB '*[^0-9a-f]*'),
            released_at_ms INTEGER,
            CHECK ((lease_state = 'released') = (released_at_ms IS NOT NULL)),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_gc_lease_expiry_idx ON runtime_blob_gc_leases(lease_state, expires_at_ms, blob_id)",
        """
        CREATE TABLE runtime_blob_gc_lease_history (
            history_id TEXT PRIMARY KEY CHECK (length(history_id) = 64 AND history_id NOT GLOB '*[^0-9a-f]*'),
            blob_id TEXT NOT NULL,
            transition_kind TEXT NOT NULL CHECK (transition_kind IN ('acquired','renewed','reacquired','expired','released')),
            lease_id TEXT NOT NULL CHECK (length(lease_id) BETWEEN 1 AND 1024),
            lease_token TEXT NOT NULL CHECK (length(lease_token) = 64 AND lease_token NOT GLOB '*[^0-9a-f]*'),
            owner_id TEXT NOT NULL CHECK (length(owner_id) BETWEEN 1 AND 1024),
            expected_state_version INTEGER NOT NULL CHECK (expected_state_version > 0),
            prior_lease_id TEXT,
            prior_lease_token TEXT,
            prior_owner_id TEXT,
            prior_authority_version INTEGER,
            authority_version INTEGER NOT NULL CHECK (authority_version > 0),
            prior_acquired_at_ms INTEGER,
            prior_expires_at_ms INTEGER,
            acquired_at_ms INTEGER NOT NULL,
            expires_at_ms INTEGER NOT NULL,
            occurred_at_ms INTEGER NOT NULL,
            system_authority_kind TEXT NOT NULL CHECK (system_authority_kind = 'garbage_collection_lease'),
            system_authority_id TEXT NOT NULL CHECK (length(system_authority_id) = 64),
            system_evidence_fingerprint TEXT NOT NULL CHECK (length(system_evidence_fingerprint) = 64),
            history_version INTEGER NOT NULL CHECK (history_version = 1),
            history_payload BLOB NOT NULL CHECK (length(history_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            transition_digest TEXT NOT NULL UNIQUE CHECK (length(transition_digest) = 64 AND transition_digest NOT GLOB '*[^0-9a-f]*'),
            history_payload_digest TEXT NOT NULL UNIQUE CHECK (length(history_payload_digest) = 64 AND history_payload_digest NOT GLOB '*[^0-9a-f]*'),
            UNIQUE (blob_id, authority_version),
            CHECK ((prior_authority_version IS NULL) = (transition_kind = 'acquired')),
            CHECK ((prior_authority_version IS NULL AND authority_version = 1)
                OR authority_version = prior_authority_version + 1),
            CHECK ((prior_lease_id IS NULL) = (prior_authority_version IS NULL)),
            CHECK ((prior_lease_token IS NULL) = (prior_authority_version IS NULL)),
            CHECK ((prior_owner_id IS NULL) = (prior_authority_version IS NULL)),
            CHECK ((prior_acquired_at_ms IS NULL) = (prior_authority_version IS NULL)),
            CHECK ((prior_expires_at_ms IS NULL) = (prior_authority_version IS NULL)),
            CHECK (prior_lease_id IS NULL OR length(prior_lease_id) BETWEEN 1 AND 1024),
            CHECK (prior_lease_token IS NULL OR (length(prior_lease_token) = 64 AND prior_lease_token NOT GLOB '*[^0-9a-f]*')),
            CHECK (prior_owner_id IS NULL OR length(prior_owner_id) BETWEEN 1 AND 1024),
            CHECK (acquired_at_ms >= 0 AND expires_at_ms > acquired_at_ms
                AND expires_at_ms - acquired_at_ms <= \(Int64(RuntimeAttachmentLimits.maximumLeaseSeconds * 1_000))),
            CHECK (occurred_at_ms >= 0),
            FOREIGN KEY (blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_gc_lease_history_idx ON runtime_blob_gc_lease_history(blob_id, authority_version)",
        """
        CREATE TABLE runtime_blob_deletion_tombstones (
            tombstone_id TEXT PRIMARY KEY CHECK (length(tombstone_id) BETWEEN 1 AND 1024),
            blob_id TEXT NOT NULL UNIQUE,
            manifest_digest TEXT NOT NULL,
            final_state_version INTEGER NOT NULL CHECK (final_state_version > 0),
            deletion_authorization_id TEXT NOT NULL CHECK (length(deletion_authorization_id) BETWEEN 1 AND 1024),
            physical_deletion_confirmed INTEGER NOT NULL CHECK (physical_deletion_confirmed = 1),
            physical_deletion_disposition TEXT NOT NULL CHECK (physical_deletion_disposition IN ('removed_owned_directory','confirmed_already_absent')),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version = 1),
            tombstone_payload BLOB NOT NULL CHECK (length(tombstone_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            tombstone_digest TEXT NOT NULL UNIQUE CHECK (length(tombstone_digest) = 64 AND tombstone_digest NOT GLOB '*[^0-9a-f]*'),
            deleted_at_ms INTEGER NOT NULL CHECK (deleted_at_ms >= 0),
            FOREIGN KEY (blob_id, manifest_digest) REFERENCES runtime_blob_records(blob_id, manifest_digest)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_staging_orphans (
            losing_blob_id TEXT PRIMARY KEY CHECK (length(losing_blob_id) BETWEEN 1 AND 1024),
            canonical_blob_id TEXT NOT NULL,
            manifest_version INTEGER NOT NULL CHECK (manifest_version = 1),
            manifest_payload BLOB NOT NULL CHECK (length(manifest_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            manifest_digest TEXT NOT NULL CHECK (length(manifest_digest) = 64 AND manifest_digest NOT GLOB '*[^0-9a-f]*'),
            envelope_version INTEGER NOT NULL CHECK (envelope_version = 1),
            envelope_payload BLOB NOT NULL CHECK (length(envelope_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumEnvelopeBytes)),
            envelope_digest TEXT NOT NULL CHECK (length(envelope_digest) = 64 AND envelope_digest NOT GLOB '*[^0-9a-f]*'),
            opaque_relative_directory TEXT NOT NULL UNIQUE CHECK (length(opaque_relative_directory) BETWEEN 5 AND 1024),
            quota_owner_id TEXT NOT NULL CHECK (length(quota_owner_id) BETWEEN 1 AND 1024),
            plaintext_byte_count INTEGER NOT NULL CHECK (plaintext_byte_count BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumAttachmentBytes)),
            reason_code TEXT NOT NULL CHECK (reason_code = 'dedup_collision'),
            recorded_at_ms INTEGER NOT NULL CHECK (recorded_at_ms >= 0),
            cleaned_at_ms INTEGER CHECK (cleaned_at_ms >= recorded_at_ms),
            orphan_version INTEGER NOT NULL CHECK (orphan_version = 1),
            FOREIGN KEY (canonical_blob_id) REFERENCES runtime_blob_records(blob_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_staging_orphans_due_idx ON runtime_blob_staging_orphans(cleaned_at_ms, recorded_at_ms, losing_blob_id)",
        """
        CREATE TABLE runtime_attachment_recovery_findings (
            evidence_fingerprint TEXT PRIMARY KEY CHECK (length(evidence_fingerprint) = 64 AND evidence_fingerprint NOT GLOB '*[^0-9a-f]*'),
            issue_code TEXT NOT NULL CHECK (issue_code IN (
                'temporary_without_manifest','manifest_without_row','finalization_missing',
                'referenced_bytes_missing','referenced_bytes_tampered','interrupted_deletion',
                'staged_expired','intake_leftover'
            )),
            blob_id TEXT,
            opaque_relative_directory TEXT NOT NULL CHECK (length(opaque_relative_directory) BETWEEN 1 AND 1024),
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            resolved_at_ms INTEGER CHECK (resolved_at_ms >= observed_at_ms),
            finding_version INTEGER NOT NULL CHECK (finding_version = 1)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_recovery_findings_due_idx ON runtime_attachment_recovery_findings(resolved_at_ms, observed_at_ms, evidence_fingerprint)",
        "CREATE INDEX runtime_attachment_recovery_findings_identity_idx ON runtime_attachment_recovery_findings(issue_code, blob_id, opaque_relative_directory, resolved_at_ms, observed_at_ms)",
        """
        CREATE TABLE runtime_attachment_recovery_attempts (
            work_kind TEXT NOT NULL CHECK (work_kind IN ('finalization','temporary_directory','intake_leftover','manifest_directory','authority_graph','staging_orphan')),
            authority_id TEXT NOT NULL CHECK (length(authority_id) BETWEEN 1 AND 1024),
            occurrence_fingerprint TEXT NOT NULL CHECK (length(occurrence_fingerprint) = 64 AND occurrence_fingerprint NOT GLOB '*[^0-9a-f]*'),
            attempt_count INTEGER NOT NULL CHECK (attempt_count BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
            next_retry_at_ms INTEGER NOT NULL CHECK (next_retry_at_ms >= last_attempt_at_ms),
            last_error_fingerprint TEXT CHECK (last_error_fingerprint IS NULL OR (length(last_error_fingerprint) = 64 AND last_error_fingerprint NOT GLOB '*[^0-9a-f]*')),
            last_attempt_at_ms INTEGER NOT NULL CHECK (last_attempt_at_ms >= 0),
            resolved_at_ms INTEGER CHECK (resolved_at_ms >= last_attempt_at_ms),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            PRIMARY KEY (work_kind, authority_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_recovery_attempts_due_idx ON runtime_attachment_recovery_attempts(work_kind, resolved_at_ms, next_retry_at_ms, authority_id)",
        """
        CREATE TABLE runtime_attachment_recovery_reopen_history (
            reopen_id TEXT PRIMARY KEY CHECK (length(reopen_id) = 64 AND reopen_id NOT GLOB '*[^0-9a-f]*'),
            work_kind TEXT NOT NULL,
            authority_id TEXT NOT NULL,
            prior_occurrence_fingerprint TEXT NOT NULL CHECK (length(prior_occurrence_fingerprint) = 64 AND prior_occurrence_fingerprint NOT GLOB '*[^0-9a-f]*'),
            next_occurrence_fingerprint TEXT NOT NULL CHECK (length(next_occurrence_fingerprint) = 64 AND next_occurrence_fingerprint NOT GLOB '*[^0-9a-f]*'),
            prior_attempt_count INTEGER NOT NULL CHECK (prior_attempt_count BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
            prior_resolved_at_ms INTEGER NOT NULL CHECK (prior_resolved_at_ms >= 0),
            reopened_at_ms INTEGER NOT NULL CHECK (reopened_at_ms >= prior_resolved_at_ms),
            prior_state_version INTEGER NOT NULL CHECK (prior_state_version > 0),
            next_state_version INTEGER NOT NULL CHECK (next_state_version = prior_state_version + 1),
            history_version INTEGER NOT NULL CHECK (history_version = 1),
            UNIQUE (work_kind, authority_id, next_occurrence_fingerprint),
            FOREIGN KEY (work_kind, authority_id)
                REFERENCES runtime_attachment_recovery_attempts(work_kind, authority_id)
                DEFERRABLE INITIALLY DEFERRED
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_attachment_recovery_cursors (
            scan_kind TEXT PRIMARY KEY CHECK (scan_kind IN ('temporary_directories','manifest_directories','authority_graphs','intake_leftovers','manifest_deletion_claims')),
            last_key TEXT CHECK (last_key IS NULL OR length(last_key) BETWEEN 1 AND 1024),
            cycle INTEGER NOT NULL CHECK (cycle >= 0),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_attachment_manifest_deletion_claims (
            claim_id TEXT PRIMARY KEY CHECK (length(claim_id) = 64 AND claim_id NOT GLOB '*[^0-9a-f]*'),
            blob_id TEXT NOT NULL UNIQUE CHECK (length(blob_id) BETWEEN 1 AND 1024),
            manifest_digest TEXT NOT NULL CHECK (length(manifest_digest) = 64 AND manifest_digest NOT GLOB '*[^0-9a-f]*'),
            opaque_relative_directory TEXT NOT NULL UNIQUE CHECK (length(opaque_relative_directory) BETWEEN 5 AND 1024),
            observed_device INTEGER NOT NULL CHECK (observed_device >= 0),
            observed_inode INTEGER NOT NULL CHECK (observed_inode > 0),
            recovery_authority_id TEXT NOT NULL CHECK (length(recovery_authority_id) = 64 AND recovery_authority_id NOT GLOB '*[^0-9a-f]*'),
            claimed_at_ms INTEGER NOT NULL CHECK (claimed_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (
                expires_at_ms > claimed_at_ms
                AND expires_at_ms - claimed_at_ms <= \(Int64(RuntimeAttachmentLimits.maximumLeaseSeconds * 1_000))
            ),
            claim_state TEXT NOT NULL CHECK (claim_state IN ('active','completed')),
            state_version INTEGER NOT NULL CHECK (state_version > 0),
            claim_version INTEGER NOT NULL CHECK (claim_version = 1),
            claim_payload BLOB NOT NULL CHECK (length(claim_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            claim_digest TEXT NOT NULL CHECK (length(claim_digest) = 64 AND claim_digest NOT GLOB '*[^0-9a-f]*'),
            completed_at_ms INTEGER CHECK (completed_at_ms >= claimed_at_ms),
            CHECK ((claim_state = 'completed') = (completed_at_ms IS NOT NULL))
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_manifest_deletion_claims_due_idx ON runtime_attachment_manifest_deletion_claims(claim_state, expires_at_ms, claim_id)",
        """
        CREATE TABLE runtime_attachment_manifest_deletion_tombstones (
            claim_id TEXT PRIMARY KEY,
            blob_id TEXT NOT NULL UNIQUE,
            manifest_digest TEXT NOT NULL CHECK (length(manifest_digest) = 64 AND manifest_digest NOT GLOB '*[^0-9a-f]*'),
            opaque_relative_directory TEXT NOT NULL UNIQUE,
            observed_device INTEGER NOT NULL CHECK (observed_device >= 0),
            observed_inode INTEGER NOT NULL CHECK (observed_inode > 0),
            quarantine_relative_directory TEXT NOT NULL UNIQUE,
            quarantine_device INTEGER NOT NULL CHECK (quarantine_device >= 0),
            quarantine_inode INTEGER NOT NULL CHECK (quarantine_inode > 0),
            proof_payload BLOB NOT NULL CHECK (length(proof_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            proof_digest TEXT NOT NULL UNIQUE CHECK (length(proof_digest) = 64 AND proof_digest NOT GLOB '*[^0-9a-f]*'),
            deleted_at_ms INTEGER NOT NULL CHECK (deleted_at_ms >= 0),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version = 1),
            FOREIGN KEY (claim_id) REFERENCES runtime_attachment_manifest_deletion_claims(claim_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_attachment_receipt_links (
            receipt_id TEXT NOT NULL,
            revision_id TEXT NOT NULL,
            blob_id TEXT NOT NULL,
            manifest_digest TEXT NOT NULL,
            link_kind TEXT NOT NULL CHECK (link_kind IN ('reference','finalization_intent','finalization','unlink','deletion_authorization','quarantine')),
            artifact_payload BLOB NOT NULL CHECK (length(artifact_payload) BETWEEN 1 AND \(RuntimeAttachmentLimits.maximumManifestBytes)),
            artifact_digest TEXT NOT NULL CHECK (length(artifact_digest) = 64 AND artifact_digest NOT GLOB '*[^0-9a-f]*'),
            finalization_completion_id TEXT UNIQUE,
            link_version INTEGER NOT NULL CHECK (link_version = 1),
            CHECK ((link_kind = 'finalization') = (finalization_completion_id IS NOT NULL)),
            PRIMARY KEY (receipt_id, revision_id, link_kind),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (revision_id, blob_id) REFERENCES runtime_attachment_revisions(revision_id, blob_id),
            FOREIGN KEY (blob_id, manifest_digest) REFERENCES runtime_blob_records(blob_id, manifest_digest),
            FOREIGN KEY (finalization_completion_id)
                REFERENCES runtime_blob_finalization_completions(completion_id)
                DEFERRABLE INITIALLY DEFERRED
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_finalization_completions (
            completion_id TEXT PRIMARY KEY CHECK (length(completion_id) = 64 AND completion_id NOT GLOB '*[^0-9a-f]*'),
            blob_id TEXT NOT NULL UNIQUE,
            revision_id TEXT NOT NULL,
            manifest_digest TEXT NOT NULL,
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            final_state_version INTEGER NOT NULL CHECK (final_state_version > 0),
            marker_digest TEXT NOT NULL CHECK (length(marker_digest) = 64 AND marker_digest NOT GLOB '*[^0-9a-f]*'),
            finalized_at_ms INTEGER NOT NULL CHECK (finalized_at_ms >= 0),
            completion_version INTEGER NOT NULL CHECK (completion_version = 1),
            FOREIGN KEY (blob_id, manifest_digest) REFERENCES runtime_blob_records(blob_id, manifest_digest),
            FOREIGN KEY (revision_id, blob_id) REFERENCES runtime_attachment_revisions(revision_id, blob_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_attachment_receipt_links_receipt_idx ON runtime_attachment_receipt_links(receipt_id, link_kind, revision_id)",
    ] + invariantTriggers

    static let fullGenerationStatements: [String] = {
        let source = CanonicalRuntimeExternalOperationSchemaPlan.fullGenerationStatements
        let names = source.compactMap(schemaObjectName)
        let supersededLegacyBlobObjects: Set<String> = [
            "runtime_blob_records",
            "runtime_blob_references",
            "runtime_blob_references_owner_idx",
        ]
        guard names.count == source.count,
              Set(names).count == names.count,
              supersededLegacyBlobObjects.isSubset(of: Set(names)),
              Set([
                  "runtime_receipt_artifact_links", "runtime_receipt_artifact_links_bind_authority",
                  "runtime_command_idempotency_require_complete_receipt",
              ])
                .isSubset(of: Set(names)) else { return [] }
        let base = source.compactMap { statement -> String? in
            guard let name = schemaObjectName(statement) else { return nil }
            // Schema v8 replaces the v1 opaque blob rows and references with
            // the attachment vault's encrypted manifest, key-envelope,
            // lifecycle, and receipt-linked authority graph. Retaining either
            // legacy table would create a second blob authority and, because
            // the new `runtime_blob_records` has a different shape, an invalid
            // foreign-key contract. Legacy rows are admitted only through the
            // staged T15 provenance importer; they are never copied into a v8
            // generation under their old schema.
            if supersededLegacyBlobObjects.contains(name) { return nil }
            if name == "runtime_receipt_artifact_links" { return receiptArtifactTableV8 }
            if name == "runtime_receipt_artifact_links_bind_authority" { return nil }
            if name == "runtime_command_idempotency_require_complete_receipt" { return nil }
            return expandingSemanticFamiliesForV8(statement)
        }
        guard receiptFinalizationBindingV8.isEmpty == false else { return [] }
        let authorityBase = base + statements + [receiptArtifactBindingV8, receiptFinalizationBindingV8]
        let authorityTables = authorityBase.compactMap { statement -> String? in
            guard schemaObjectType(statement) == "table",
                  let name = schemaObjectName(statement),
                  name != "runtime_store_metadata",
                  name.hasPrefix("runtime_canonical_") == false,
                  name.hasPrefix("runtime_replay_") == false,
                  name.hasPrefix("runtime_projection_") == false else {
                return nil
            }
            return name
        }.sorted()
        let fenceTable = """
        CREATE TABLE runtime_authority_fence (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            change_epoch INTEGER NOT NULL CHECK (change_epoch >= 0),
            last_changed_table TEXT NOT NULL,
            last_change_operation TEXT NOT NULL CHECK (last_change_operation IN ('bootstrap','insert','update','delete'))
        )
        """
        let fenceTriggers = authorityTables.flatMap { table in
            [
                ("insert", "INSERT"),
                ("update", "UPDATE"),
                ("delete", "DELETE"),
            ].map { operation, sqlOperation in
                """
                CREATE TRIGGER runtime_authority_fence_\(table)_\(operation)
                AFTER \(sqlOperation) ON \(table)
                BEGIN
                    UPDATE runtime_authority_fence
                    SET change_epoch = change_epoch + 1,
                        last_changed_table = '\(table)',
                        last_change_operation = '\(operation)'
                    WHERE singleton_id = 1;
                END
                """
            }
        }
        let result = authorityBase + [fenceTable] + fenceTriggers
        let resultNames = result.compactMap(schemaObjectName)
        guard resultNames.count == result.count,
              Set(resultNames).count == resultNames.count,
              supersededLegacyBlobObjects.isDisjoint(with: Set(resultNames).subtracting(["runtime_blob_records"])),
              resultNames.filter({ $0 == "runtime_blob_records" }).count == 1,
              Set(["runtime_blob_references", "runtime_blob_references_owner_idx"])
                .isDisjoint(with: Set(resultNames))
        else { return [] }
        return result
    }()

    static func requireIntegratedSchema(in database: isolated SQLiteDatabase) throws {
        let versionRows = try database.query("PRAGMA user_version")
        guard versionRows.count == 1,
              versionRows[0].values.first == .integer(Int64(targetSchemaVersion)) else {
            let actual: Int
            if case let .integer(value)? = versionRows.first?.values.first { actual = Int(value) }
            else { actual = 0 }
            throw RuntimeCanonicalAttachmentError.migrationRequired(expected: targetSchemaVersion, actual: actual)
        }
        let expectedEntries = fullGenerationStatements.compactMap { statement -> (String, CatalogEntry)? in
            guard let name = schemaObjectName(statement), let type = schemaObjectType(statement) else { return nil }
            return (name, CatalogEntry(type: type, sql: normalizeSQL(statement)))
        }
        guard fullGenerationStatements.isEmpty == false,
              expectedEntries.count == fullGenerationStatements.count,
              Set(expectedEntries.map(\.0)).count == expectedEntries.count else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let rows = try database.query(
            "SELECT name, type, sql FROM sqlite_schema WHERE name LIKE 'runtime_%' AND type IN ('table','index','trigger') ORDER BY name"
        )
        let actualEntries = try rows.map { row -> (String, CatalogEntry) in
            guard case let .text(name)? = row.value(named: "name"),
                  case let .text(type)? = row.value(named: "type"),
                  case let .text(sql)? = row.value(named: "sql") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return (name, CatalogEntry(type: type, sql: normalizeSQL(sql)))
        }
        guard Set(actualEntries.map(\.0)).count == actualEntries.count,
              Dictionary(uniqueKeysWithValues: expectedEntries) == Dictionary(uniqueKeysWithValues: actualEntries) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let metadata = try database.query("SELECT schema_version FROM runtime_store_metadata WHERE singleton_id = 1 LIMIT 2")
        guard metadata.count == 1,
              metadata[0].value(named: "schema_version") == .integer(Int64(targetSchemaVersion)) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
    }

    private struct CatalogEntry: Equatable { let type: String; let sql: String }

    private static func expandingSemanticFamiliesForV8(_ statement: String) -> String {
        statement
            .replacingOccurrences(
                of: "'repair', 'import_deletion', 'external_operation'",
                with: "'repair', 'import_deletion', 'external_operation', 'attachment'"
            )
            .replacingOccurrences(
                of: "'repair','import_deletion','external_operation'",
                with: "'repair','import_deletion','external_operation','attachment'"
            )
    }

    private static func schemaObjectName(_ statement: String) -> String? {
        let tokens = statement.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard tokens.first == "CREATE" else { return nil }
        if tokens.count > 2, tokens[1] == "TABLE" || tokens[1] == "TRIGGER" { return tokens[2] }
        if tokens.count > 2, tokens[1] == "INDEX" { return tokens[2] }
        if tokens.count > 3, tokens[1] == "UNIQUE", tokens[2] == "INDEX" { return tokens[3] }
        return nil
    }

    private static func schemaObjectType(_ statement: String) -> String? {
        let tokens = statement.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard tokens.first == "CREATE", tokens.count > 1 else { return nil }
        if tokens[1] == "TABLE" { return "table" }
        if tokens[1] == "TRIGGER" { return "trigger" }
        if tokens[1] == "INDEX" || tokens[1] == "UNIQUE" { return "index" }
        return nil
    }

    private static func normalizeSQL(_ value: String) -> String {
        value.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    private static let invariantTriggers: [String] = [
        immutableUpdate("runtime_attachment_identities"), immutableDelete("runtime_attachment_identities"),
        immutableUpdate("runtime_blob_records"), immutableDelete("runtime_blob_records"),
        immutableUpdate("runtime_blob_dedup_authority"),
        immutableUpdate("runtime_attachment_revisions"), immutableDelete("runtime_attachment_revisions"),
        immutableDelete("runtime_blob_key_envelopes"),
        immutableDelete("runtime_blob_key_rewrap_jobs"),
        immutableDelete("runtime_blob_key_rewrap_items"),
        """
        CREATE TRIGGER runtime_blob_key_envelopes_authorized_rewrap
        BEFORE UPDATE ON runtime_blob_key_envelopes
        WHEN OLD.blob_id <> NEW.blob_id OR OLD.created_at_ms <> NEW.created_at_ms
          OR NOT EXISTS (
              SELECT 1 FROM runtime_blob_key_rewrap_items AS i
              JOIN runtime_blob_key_rewrap_jobs AS j ON j.job_id = i.job_id
              WHERE i.blob_id = OLD.blob_id AND i.item_state = 'in_progress'
                AND i.expected_envelope_digest = OLD.envelope_digest
                AND j.job_state = 'active'
                AND j.source_key_id = OLD.wrapping_key_id
                AND j.source_key_version = OLD.wrapping_key_version
                AND j.target_key_id = NEW.wrapping_key_id
                AND j.target_key_version = NEW.wrapping_key_version
          )
        BEGIN SELECT RAISE(ABORT, 'unauthorized attachment key rewrap'); END
        """,
        """
        CREATE TRIGGER runtime_blob_key_rewrap_jobs_transition_guard
        BEFORE UPDATE ON runtime_blob_key_rewrap_jobs
        WHEN OLD.job_id <> NEW.job_id OR OLD.source_key_id <> NEW.source_key_id
          OR OLD.source_key_version <> NEW.source_key_version
          OR OLD.target_key_id <> NEW.target_key_id OR OLD.target_key_version <> NEW.target_key_version
          OR OLD.created_at_ms <> NEW.created_at_ms OR NEW.total_envelope_count < OLD.total_envelope_count
          OR OLD.job_state = 'completed' OR NEW.state_version <> OLD.state_version + 1
          OR NEW.updated_at_ms < OLD.updated_at_ms
          OR NEW.total_envelope_count <> (
              SELECT COUNT(*) FROM runtime_blob_key_rewrap_items WHERE job_id = OLD.job_id
          )
          OR NEW.completed_envelope_count <> (
              SELECT COUNT(*) FROM runtime_blob_key_rewrap_items
              WHERE job_id = OLD.job_id AND item_state = 'completed'
          )
          OR NEW.failed_envelope_count <> (
              SELECT COUNT(*) FROM runtime_blob_key_rewrap_items
              WHERE job_id = OLD.job_id AND item_state = 'failed'
          )
          OR (NEW.job_state <> OLD.job_state AND NOT (OLD.job_state = 'active' AND NEW.job_state = 'completed'))
        BEGIN SELECT RAISE(ABORT, 'invalid attachment key rewrap job transition'); END
        """,
        """
        CREATE TRIGGER runtime_blob_key_rewrap_items_transition_guard
        BEFORE UPDATE ON runtime_blob_key_rewrap_items
        WHEN OLD.job_id <> NEW.job_id OR OLD.blob_id <> NEW.blob_id
          OR OLD.expected_envelope_digest <> NEW.expected_envelope_digest
          OR OLD.item_state = 'completed' OR NEW.state_version <> OLD.state_version + 1
          OR NEW.attempt_count < OLD.attempt_count OR NEW.updated_at_ms < OLD.updated_at_ms
          OR NOT (
              (OLD.item_state IN ('pending','failed','in_progress')
               AND NEW.item_state = 'in_progress'
               AND NEW.attempt_count = OLD.attempt_count + 1
               AND NEW.lease_owner_id IS NOT NULL AND NEW.lease_token IS NOT NULL
               AND NEW.lease_expires_at_ms IS NOT NULL AND NEW.completed_at_ms IS NULL)
              OR
              (OLD.item_state = 'in_progress' AND NEW.item_state = 'completed'
               AND NEW.attempt_count = OLD.attempt_count
               AND NEW.lease_owner_id IS NULL AND NEW.lease_token IS NULL
               AND NEW.lease_expires_at_ms IS NULL AND NEW.completed_at_ms IS NOT NULL
               AND NEW.last_error_fingerprint IS NULL)
              OR
              (OLD.item_state = 'in_progress' AND NEW.item_state = 'failed'
               AND NEW.attempt_count = OLD.attempt_count
               AND NEW.lease_owner_id IS NULL AND NEW.lease_token IS NULL
               AND NEW.lease_expires_at_ms IS NULL AND NEW.completed_at_ms IS NULL
               AND NEW.last_error_fingerprint IS NOT NULL)
              OR
              (OLD.item_state = 'in_progress' AND NEW.item_state = 'pending'
               AND NEW.attempt_count = OLD.attempt_count
               AND NEW.lease_owner_id IS NULL AND NEW.lease_token IS NULL
               AND NEW.lease_expires_at_ms IS NULL AND NEW.completed_at_ms IS NULL)
          )
        BEGIN SELECT RAISE(ABORT, 'invalid attachment key rewrap item transition'); END
        """,
        immutableDelete("runtime_blob_quota_ledgers"),
        immutableUpdate("runtime_blob_retention_hold_history"), immutableDelete("runtime_blob_retention_hold_history"),
        immutableUpdate("runtime_attachment_lifecycle_history"), immutableDelete("runtime_attachment_lifecycle_history"),
        immutableUpdate("runtime_attachment_reference_history"), immutableDelete("runtime_attachment_reference_history"),
        immutableUpdate("runtime_blob_deletion_tombstones"), immutableDelete("runtime_blob_deletion_tombstones"),
        immutableUpdate("runtime_attachment_receipt_links"), immutableDelete("runtime_attachment_receipt_links"),
        """
        CREATE TRIGGER runtime_attachment_references_protect_identity
        BEFORE UPDATE ON runtime_attachment_references
        WHEN OLD.reference_id <> NEW.reference_id OR OLD.revision_id <> NEW.revision_id OR OLD.blob_id <> NEW.blob_id
          OR OLD.target_family <> NEW.target_family OR OLD.target_object_id <> NEW.target_object_id
          OR OLD.target_revision <> NEW.target_revision OR OLD.command_id <> NEW.command_id
          OR OLD.receipt_id <> NEW.receipt_id OR OLD.terminal_event_sequence <> NEW.terminal_event_sequence
          OR OLD.reference_version <> NEW.reference_version OR OLD.reference_payload <> NEW.reference_payload
          OR OLD.reference_digest <> NEW.reference_digest OR OLD.created_at_ms <> NEW.created_at_ms
          OR OLD.reference_state <> 'active' OR NEW.reference_state <> 'removed'
        BEGIN SELECT RAISE(ABORT, 'invalid attachment reference transition'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_references_immutable_delete
        BEFORE DELETE ON runtime_attachment_references
        BEGIN SELECT RAISE(ABORT, 'immutable attachment reference'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_reference_insert_requires_history
        BEFORE INSERT ON runtime_attachment_references
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_attachment_reference_history AS h
            WHERE h.reference_id = NEW.reference_id AND h.revision_id = NEW.revision_id
              AND h.blob_id = NEW.blob_id AND h.from_state IS NULL AND h.to_state = 'active'
              AND h.command_id = NEW.command_id AND h.receipt_id = NEW.receipt_id
              AND h.terminal_event_sequence = NEW.terminal_event_sequence
        )
        BEGIN SELECT RAISE(ABORT, 'attachment reference history missing'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_reference_removal_requires_history
        BEFORE UPDATE OF reference_state ON runtime_attachment_references
        WHEN NEW.reference_state = 'removed' AND NOT EXISTS (
            SELECT 1 FROM runtime_attachment_reference_history AS h
            WHERE h.reference_id = NEW.reference_id AND h.revision_id = NEW.revision_id
              AND h.blob_id = NEW.blob_id AND h.from_state = 'active' AND h.to_state = 'removed'
              AND h.occurred_at_ms = NEW.removed_at_ms
        )
        BEGIN SELECT RAISE(ABORT, 'attachment reference removal history missing'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_references_block_gc_lease_insert
        BEFORE INSERT ON runtime_attachment_references
        WHEN NEW.reference_state = 'active' AND EXISTS (
            SELECT 1 FROM runtime_blob_gc_leases AS l
            WHERE l.blob_id = NEW.blob_id AND l.lease_state = 'active'
              AND l.expires_at_ms > NEW.created_at_ms
        )
        BEGIN SELECT RAISE(ABORT, 'attachment blob is leased for deletion'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_one_active_revision_per_target
        BEFORE INSERT ON runtime_attachment_references
        WHEN NEW.reference_state = 'active' AND EXISTS (
            SELECT 1
            FROM runtime_attachment_references AS existing
            JOIN runtime_attachment_revisions AS existing_revision
              ON existing_revision.revision_id = existing.revision_id
            JOIN runtime_attachment_revisions AS proposed_revision
              ON proposed_revision.revision_id = NEW.revision_id
            WHERE existing.reference_state = 'active'
              AND existing.target_family = NEW.target_family
              AND existing.target_object_id = NEW.target_object_id
              AND existing_revision.attachment_id = proposed_revision.attachment_id
        )
        BEGIN SELECT RAISE(ABORT, 'attachment target already has an active revision'); END
        """,
        """
        CREATE TRIGGER runtime_blob_holds_block_gc_lease
        BEFORE INSERT ON runtime_blob_retention_holds
        WHEN EXISTS (
            SELECT 1 FROM runtime_blob_gc_leases AS l
            WHERE l.blob_id = NEW.blob_id AND l.lease_state = 'active'
              AND l.expires_at_ms > NEW.created_at_ms
        ) OR EXISTS (
            SELECT 1 FROM runtime_attachment_current_lifecycle AS s
            WHERE s.blob_id = NEW.blob_id AND s.lifecycle_state = 'deletion_pending'
        ) OR EXISTS (
            SELECT 1 FROM runtime_blob_deletion_tombstones AS t WHERE t.blob_id = NEW.blob_id
        )
        BEGIN SELECT RAISE(ABORT, 'attachment blob is leased for deletion'); END
        """,
        """
        CREATE TRIGGER runtime_blob_hold_insert_requires_history
        BEFORE INSERT ON runtime_blob_retention_holds
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_blob_retention_hold_history AS h
            WHERE h.hold_id = NEW.hold_id AND h.blob_id = NEW.blob_id
              AND h.transition_kind = 'acquired' AND h.authority_id = NEW.authority_id
              AND h.occurred_at_ms = NEW.created_at_ms
        )
        BEGIN SELECT RAISE(ABORT, 'attachment hold acquisition history missing'); END
        """,
        """
        CREATE TRIGGER runtime_blob_hold_history_bind_receipt
        BEFORE INSERT ON runtime_blob_retention_hold_history
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_commit_receipts AS r
            JOIN runtime_committed_receipt_cores AS c ON c.receipt_id = r.receipt_id
            JOIN runtime_semantic_events AS e ON e.sequence = r.terminal_event_sequence
            WHERE r.receipt_id = NEW.receipt_id AND r.command_id = NEW.command_id
              AND c.command_id = NEW.command_id
              AND c.terminal_event_sequence = NEW.terminal_event_sequence
              AND c.terminal_event_id = NEW.terminal_event_id
              AND c.terminal_event_hash = NEW.terminal_event_hash
              AND e.sequence = NEW.terminal_event_sequence
              AND e.event_id = NEW.terminal_event_id
              AND e.event_hash = NEW.terminal_event_hash
              AND e.command_id = NEW.command_id
        )
        BEGIN SELECT RAISE(ABORT, 'attachment hold lineage mismatch'); END
        """,
        """
        CREATE TRIGGER runtime_blob_quota_consume_guard
        BEFORE UPDATE ON runtime_blob_quota_reservations
        WHEN OLD.reservation_id <> NEW.reservation_id OR OLD.privacy_domain <> NEW.privacy_domain
          OR OLD.reserved_bytes <> NEW.reserved_bytes OR OLD.owner_id <> NEW.owner_id
          OR OLD.created_at_ms <> NEW.created_at_ms OR OLD.expires_at_ms <> NEW.expires_at_ms
          OR OLD.reservation_version <> NEW.reservation_version
          OR OLD.consumed_by_blob_id IS NOT NULL OR OLD.released_at_ms IS NOT NULL
          OR ((NEW.consumed_by_blob_id IS NULL) = (NEW.released_at_ms IS NULL))
        BEGIN SELECT RAISE(ABORT, 'invalid attachment quota transition'); END
        """,
        immutableDelete("runtime_blob_quota_reservations"),
        """
        CREATE TRIGGER runtime_blob_quota_ledger_cas
        BEFORE UPDATE ON runtime_blob_quota_ledgers
        WHEN OLD.privacy_domain <> NEW.privacy_domain OR OLD.owner_id <> NEW.owner_id
          OR OLD.limit_bytes <> NEW.limit_bytes OR NEW.state_version <> OLD.state_version + 1
          OR NEW.updated_at_ms < OLD.updated_at_ms
        BEGIN SELECT RAISE(ABORT, 'invalid attachment quota ledger cas'); END
        """,
        """
        CREATE TRIGGER runtime_blob_hold_release_guard
        BEFORE UPDATE ON runtime_blob_retention_holds
        WHEN OLD.hold_id <> NEW.hold_id OR OLD.blob_id <> NEW.blob_id OR OLD.hold_kind <> NEW.hold_kind
          OR OLD.authority_id <> NEW.authority_id OR OLD.retain_until_ms IS NOT NEW.retain_until_ms
          OR OLD.created_at_ms <> NEW.created_at_ms OR OLD.hold_version <> NEW.hold_version
          OR OLD.released_at_ms IS NOT NULL OR NEW.released_at_ms IS NULL
          OR NOT EXISTS (
              SELECT 1 FROM runtime_blob_retention_hold_history AS h
              WHERE h.hold_id = NEW.hold_id AND h.blob_id = NEW.blob_id
                AND h.transition_kind = 'released' AND h.occurred_at_ms = NEW.released_at_ms
          )
        BEGIN SELECT RAISE(ABORT, 'invalid attachment hold release'); END
        """,
        immutableDelete("runtime_blob_retention_holds"),
        """
        CREATE TRIGGER runtime_blob_quarantine_resolution_guard
        BEFORE UPDATE ON runtime_blob_quarantine
        WHEN OLD.quarantine_id <> NEW.quarantine_id OR OLD.blob_id <> NEW.blob_id
          OR OLD.reason_code <> NEW.reason_code OR OLD.evidence_fingerprint <> NEW.evidence_fingerprint
          OR OLD.observed_at_ms <> NEW.observed_at_ms OR OLD.quarantine_version <> NEW.quarantine_version
          OR OLD.resolved_at_ms IS NOT NULL OR NEW.resolved_at_ms IS NULL
        BEGIN SELECT RAISE(ABORT, 'invalid attachment quarantine resolution'); END
        """,
        immutableDelete("runtime_blob_quarantine"),
        """
        CREATE TRIGGER runtime_attachment_current_lifecycle_cas
        BEFORE UPDATE ON runtime_attachment_current_lifecycle
        WHEN NEW.blob_id <> OLD.blob_id OR NEW.manifest_digest <> OLD.manifest_digest
          OR NEW.lifecycle_version <> OLD.lifecycle_version OR NEW.state_version <> OLD.state_version + 1
          OR NEW.updated_at_ms < OLD.updated_at_ms
        BEGIN SELECT RAISE(ABORT, 'invalid attachment lifecycle cas'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_current_lifecycle_immutable_delete
        BEFORE DELETE ON runtime_attachment_current_lifecycle
        BEGIN SELECT RAISE(ABORT, 'attachment lifecycle cannot be deleted'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_initial_lifecycle_requires_history
        BEFORE INSERT ON runtime_attachment_current_lifecycle
        WHEN NEW.state_version <> 1 OR NEW.lifecycle_state <> 'staged' OR NEW.reference_count <> 0
          OR NOT EXISTS (
              SELECT 1 FROM runtime_attachment_lifecycle_history AS h
              WHERE h.blob_id = NEW.blob_id AND h.state_version = 1
                AND h.from_state IS NULL AND h.to_state = 'staged'
                AND h.from_reference_count IS NULL AND h.to_reference_count = 0
          )
        BEGIN SELECT RAISE(ABORT, 'attachment initial lifecycle history missing'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_reference_count_insert_guard
        BEFORE INSERT ON runtime_attachment_lifecycle_history
        WHEN NEW.to_reference_count <> (
            SELECT COUNT(*) FROM runtime_attachment_references AS r
            JOIN runtime_attachment_revisions AS v ON v.revision_id = r.revision_id
            WHERE v.blob_id = NEW.blob_id AND r.reference_state = 'active'
        )
        BEGIN SELECT RAISE(ABORT, 'attachment reference count mismatch'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_history_matches_current
        BEFORE UPDATE ON runtime_attachment_current_lifecycle
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_attachment_lifecycle_history AS h
            WHERE h.blob_id = NEW.blob_id AND h.state_version = NEW.state_version
              AND h.from_state = OLD.lifecycle_state AND h.to_state = NEW.lifecycle_state
              AND h.from_reference_count = OLD.reference_count AND h.to_reference_count = NEW.reference_count
        )
        BEGIN SELECT RAISE(ABORT, 'attachment lifecycle history missing'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_lifecycle_legal_transition
        BEFORE INSERT ON runtime_attachment_lifecycle_history
        WHEN NOT (
            (NEW.from_state IS NULL AND NEW.to_state = 'staged' AND NEW.from_reference_count IS NULL AND NEW.to_reference_count = 0)
            OR (NEW.from_state IN ('staged','orphaned') AND NEW.to_state = 'referenced' AND NEW.from_reference_count = 0 AND NEW.to_reference_count > 0)
            OR (NEW.from_state = 'orphaned' AND NEW.to_state = 'finalized' AND NEW.from_reference_count = 0 AND NEW.to_reference_count > 0)
            OR (NEW.from_state IN ('staged','orphaned') AND NEW.to_state IN ('quarantined','deletion_pending') AND NEW.from_reference_count = 0 AND NEW.to_reference_count = 0)
            OR (NEW.from_state = 'referenced' AND NEW.to_state IN ('referenced','finalized') AND NEW.from_reference_count > 0 AND NEW.to_reference_count > 0)
            OR (NEW.from_state = 'finalized' AND NEW.to_state = 'finalized' AND NEW.from_reference_count > 0 AND NEW.to_reference_count > 0)
            OR (NEW.from_state IN ('referenced','finalized') AND NEW.to_state = 'orphaned' AND NEW.from_reference_count = 1 AND NEW.to_reference_count = 0)
            OR (NEW.from_state IN ('referenced','finalized','quarantined') AND NEW.to_state = 'quarantined' AND NEW.from_reference_count >= 0 AND NEW.to_reference_count >= 0)
            OR (NEW.from_state = 'quarantined' AND NEW.to_state = 'deletion_pending' AND NEW.from_reference_count = 0 AND NEW.to_reference_count = 0)
            OR (NEW.from_state = 'deletion_pending' AND NEW.to_state = 'deletion_pending' AND NEW.from_reference_count = 0 AND NEW.to_reference_count = 0)
        )
        BEGIN SELECT RAISE(ABORT, 'illegal attachment lifecycle transition'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_finalized_orphan_relink_authority
        BEFORE INSERT ON runtime_attachment_lifecycle_history
        WHEN NEW.from_state = 'orphaned' AND NEW.to_state = 'finalized'
          AND NOT EXISTS (
              SELECT 1
              FROM runtime_blob_finalization_completions AS c
              JOIN runtime_blob_finalization_intents AS f
                ON f.finalization_completion_id = c.completion_id
               AND f.blob_id = c.blob_id AND f.manifest_digest = c.manifest_digest
               AND f.command_id = c.command_id AND f.receipt_id = c.receipt_id
               AND f.terminal_event_sequence = c.terminal_event_sequence
               AND f.marker_digest = c.marker_digest AND f.finalized_at_ms = c.finalized_at_ms
              JOIN runtime_attachment_lifecycle_history AS prior
                ON prior.blob_id = c.blob_id AND prior.state_version = c.final_state_version
               AND prior.from_state = 'referenced' AND prior.to_state = 'finalized'
               AND prior.finalization_completion_id = c.completion_id
              JOIN runtime_attachment_receipt_links AS l
                ON l.receipt_id = c.receipt_id AND l.revision_id = c.revision_id
               AND l.blob_id = c.blob_id AND l.manifest_digest = c.manifest_digest
               AND l.link_kind = 'finalization' AND l.artifact_digest = c.marker_digest
               AND l.finalization_completion_id = c.completion_id
              JOIN runtime_blob_records AS b
                ON b.blob_id = c.blob_id AND b.manifest_digest = c.manifest_digest
              WHERE c.blob_id = NEW.blob_id AND c.manifest_digest = NEW.manifest_digest
          )
        BEGIN SELECT RAISE(ABORT, 'unproven finalized attachment relink'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_lifecycle_system_authority_guard
        BEFORE INSERT ON runtime_attachment_lifecycle_history
        WHEN (
            NEW.system_authority_kind = 'staged_expiry' AND NOT EXISTS (
                SELECT 1 FROM runtime_attachment_recovery_findings AS f
                JOIN runtime_attachment_recovery_attempts AS a
                  ON a.work_kind = 'staging_orphan'
                 AND a.authority_id = NEW.system_authority_id
                 AND a.resolved_at_ms IS NULL
                WHERE f.evidence_fingerprint = NEW.system_evidence_fingerprint
                  AND f.issue_code = 'staged_expired' AND f.blob_id = NEW.blob_id
                  AND f.resolved_at_ms IS NULL
            )
        ) OR (
            NEW.system_authority_kind = 'recovery_quarantine' AND NOT EXISTS (
                SELECT 1 FROM runtime_attachment_recovery_findings AS f
                WHERE f.evidence_fingerprint = NEW.system_evidence_fingerprint
                  AND f.evidence_fingerprint = NEW.system_authority_id
                  AND f.issue_code IN ('referenced_bytes_missing','referenced_bytes_tampered')
                  AND f.blob_id = NEW.blob_id AND f.resolved_at_ms IS NULL
            )
        )
        BEGIN SELECT RAISE(ABORT, 'unproven attachment system transition'); END
        """,
        """
        CREATE TRIGGER runtime_blob_gc_lease_eligibility
        BEFORE INSERT ON runtime_blob_gc_leases
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_attachment_current_lifecycle AS s
            WHERE s.blob_id = NEW.blob_id AND s.state_version = NEW.expected_state_version
              AND s.lifecycle_state = 'deletion_pending' AND s.reference_count = 0
              AND (s.retention_until_ms IS NULL OR s.retention_until_ms <= NEW.acquired_at_ms)
        ) OR EXISTS (
            SELECT 1 FROM runtime_blob_retention_holds AS h
            WHERE h.blob_id = NEW.blob_id AND h.released_at_ms IS NULL
              AND (h.retain_until_ms IS NULL OR h.retain_until_ms > NEW.acquired_at_ms)
        )
        BEGIN SELECT RAISE(ABORT, 'blob is not gc eligible'); END
        """,
        """
        CREATE TRIGGER runtime_blob_gc_lease_bind_fence_history
        BEFORE INSERT ON runtime_blob_gc_leases
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_attachment_lifecycle_history AS h
            WHERE h.blob_id = NEW.blob_id AND h.state_version = NEW.expected_state_version
              AND h.system_authority_kind = 'garbage_collection_fence'
              AND h.system_authority_id = NEW.lease_id
              AND h.system_evidence_fingerprint = NEW.lease_token
              AND h.to_state = 'deletion_pending' AND h.to_reference_count = 0
              AND h.occurred_at_ms = NEW.acquired_at_ms
        )
        BEGIN SELECT RAISE(ABORT, 'attachment gc fence authority mismatch'); END
        """,
        """
        CREATE TRIGGER runtime_blob_gc_lease_insert_requires_history
        BEFORE INSERT ON runtime_blob_gc_leases
        WHEN NEW.authority_version <> 1 OR NEW.lease_state <> 'active'
          OR NEW.released_at_ms IS NOT NULL OR NOT EXISTS (
              SELECT 1 FROM runtime_blob_gc_lease_history AS h
              WHERE h.blob_id = NEW.blob_id AND h.transition_kind = 'acquired'
                AND h.lease_id = NEW.lease_id AND h.lease_token = NEW.lease_token
                AND h.owner_id = NEW.owner_id
                AND h.expected_state_version = NEW.expected_state_version
                AND h.prior_authority_version IS NULL AND h.authority_version = 1
                AND h.acquired_at_ms = NEW.acquired_at_ms
                AND h.expires_at_ms = NEW.expires_at_ms
                AND h.occurred_at_ms = NEW.acquired_at_ms
                AND h.system_authority_id = NEW.lease_token
          )
        BEGIN SELECT RAISE(ABORT, 'attachment gc lease acquisition history missing'); END
        """,
        """
        CREATE TRIGGER runtime_blob_gc_lease_history_cas
        BEFORE UPDATE ON runtime_blob_gc_leases
        WHEN OLD.blob_id <> NEW.blob_id OR NEW.authority_version <> OLD.authority_version + 1
          OR NEW.lease_version <> OLD.lease_version
          OR NOT EXISTS (
              SELECT 1 FROM runtime_blob_gc_lease_history AS h
              WHERE h.blob_id = NEW.blob_id AND h.authority_version = NEW.authority_version
                AND h.prior_authority_version = OLD.authority_version
                AND h.prior_lease_id = OLD.lease_id
                AND h.prior_lease_token = OLD.lease_token
                AND h.prior_owner_id = OLD.owner_id
                AND h.lease_id = NEW.lease_id AND h.lease_token = NEW.lease_token
                AND h.owner_id = NEW.owner_id
                AND h.expected_state_version = NEW.expected_state_version
                AND h.prior_acquired_at_ms = OLD.acquired_at_ms
                AND h.prior_expires_at_ms = OLD.expires_at_ms
                AND h.acquired_at_ms = NEW.acquired_at_ms
                AND h.expires_at_ms = NEW.expires_at_ms
                AND h.system_authority_id = NEW.lease_token
                AND ((h.transition_kind = 'renewed'
                      AND OLD.lease_state = 'active' AND NEW.lease_state = 'active'
                      AND NEW.lease_id = OLD.lease_id AND NEW.owner_id = OLD.owner_id
                      AND NEW.expected_state_version = OLD.expected_state_version
                      AND NEW.acquired_at_ms = h.occurred_at_ms
                      AND NEW.acquired_at_ms >= OLD.acquired_at_ms
                      AND NEW.expires_at_ms > OLD.expires_at_ms
                      AND NEW.released_at_ms IS NULL)
                  OR (h.transition_kind = 'reacquired'
                      AND OLD.lease_state = 'expired' AND NEW.lease_state = 'active'
                      AND NEW.lease_id <> OLD.lease_id AND NEW.lease_token <> OLD.lease_token
                      AND NEW.acquired_at_ms = h.occurred_at_ms
                      AND NEW.acquired_at_ms >= OLD.expires_at_ms
                      AND NEW.released_at_ms IS NULL)
                  OR (h.transition_kind = 'expired'
                      AND OLD.lease_state = 'active' AND NEW.lease_state = 'expired'
                      AND NEW.lease_id = OLD.lease_id AND NEW.lease_token = OLD.lease_token
                      AND NEW.owner_id = OLD.owner_id
                      AND NEW.expected_state_version = OLD.expected_state_version
                      AND NEW.acquired_at_ms = OLD.acquired_at_ms
                      AND NEW.expires_at_ms = OLD.expires_at_ms
                      AND h.occurred_at_ms >= OLD.expires_at_ms
                      AND NEW.released_at_ms IS NULL)
                  OR (h.transition_kind = 'released'
                      AND OLD.lease_state = 'active' AND NEW.lease_state = 'released'
                      AND NEW.lease_id = OLD.lease_id AND NEW.lease_token = OLD.lease_token
                      AND NEW.owner_id = OLD.owner_id
                      AND NEW.expected_state_version = OLD.expected_state_version
                      AND NEW.acquired_at_ms = OLD.acquired_at_ms
                      AND NEW.expires_at_ms = OLD.expires_at_ms
                      AND h.occurred_at_ms BETWEEN OLD.acquired_at_ms AND OLD.expires_at_ms
                      AND NEW.released_at_ms = h.occurred_at_ms))
          )
        BEGIN SELECT RAISE(ABORT, 'attachment gc lease history missing'); END
        """,
        """
        CREATE TRIGGER runtime_blob_gc_lease_reacquire_bind_fence_history
        BEFORE UPDATE ON runtime_blob_gc_leases
        WHEN OLD.lease_state = 'expired' AND NEW.lease_state = 'active' AND (
            NOT EXISTS (
                SELECT 1 FROM runtime_attachment_lifecycle_history AS h
                WHERE h.blob_id = NEW.blob_id AND h.state_version = NEW.expected_state_version
                  AND h.system_authority_kind = 'garbage_collection_fence'
                  AND h.system_authority_id = NEW.lease_id
                  AND h.system_evidence_fingerprint = NEW.lease_token
                  AND h.to_state = 'deletion_pending' AND h.to_reference_count = 0
                  AND h.occurred_at_ms = NEW.acquired_at_ms
            ) OR NOT EXISTS (
                SELECT 1 FROM runtime_attachment_current_lifecycle AS s
                WHERE s.blob_id = NEW.blob_id AND s.state_version = NEW.expected_state_version
                  AND s.lifecycle_state = 'deletion_pending' AND s.reference_count = 0
                  AND (s.retention_until_ms IS NULL OR s.retention_until_ms <= NEW.acquired_at_ms)
            ) OR EXISTS (
                SELECT 1 FROM runtime_blob_retention_holds AS h
                WHERE h.blob_id = NEW.blob_id AND h.released_at_ms IS NULL
                  AND (h.retain_until_ms IS NULL OR h.retain_until_ms > NEW.acquired_at_ms)
            )
        )
        BEGIN SELECT RAISE(ABORT, 'attachment gc reacquisition fence missing'); END
        """,
        immutableDelete("runtime_blob_gc_leases"),
        immutableUpdate("runtime_blob_gc_lease_history"),
        immutableDelete("runtime_blob_gc_lease_history"),
        """
        CREATE TRIGGER runtime_blob_staging_orphan_cleanup_guard
        BEFORE UPDATE ON runtime_blob_staging_orphans
        WHEN OLD.losing_blob_id <> NEW.losing_blob_id OR OLD.canonical_blob_id <> NEW.canonical_blob_id
          OR OLD.manifest_version <> NEW.manifest_version OR OLD.manifest_payload <> NEW.manifest_payload
          OR OLD.manifest_digest <> NEW.manifest_digest
          OR OLD.envelope_version <> NEW.envelope_version OR OLD.envelope_payload <> NEW.envelope_payload
          OR OLD.envelope_digest <> NEW.envelope_digest
          OR OLD.opaque_relative_directory <> NEW.opaque_relative_directory
          OR OLD.quota_owner_id <> NEW.quota_owner_id
          OR OLD.plaintext_byte_count <> NEW.plaintext_byte_count
          OR OLD.reason_code <> NEW.reason_code OR OLD.recorded_at_ms <> NEW.recorded_at_ms
          OR OLD.orphan_version <> NEW.orphan_version OR OLD.cleaned_at_ms IS NOT NULL
          OR NEW.cleaned_at_ms IS NULL
        BEGIN SELECT RAISE(ABORT, 'invalid attachment staging orphan cleanup'); END
        """,
        immutableDelete("runtime_blob_staging_orphans"),
        """
        CREATE TRIGGER runtime_attachment_recovery_finding_resolution_guard
        BEFORE UPDATE ON runtime_attachment_recovery_findings
        WHEN OLD.evidence_fingerprint <> NEW.evidence_fingerprint
          OR OLD.issue_code <> NEW.issue_code OR OLD.blob_id IS NOT NEW.blob_id
          OR OLD.opaque_relative_directory <> NEW.opaque_relative_directory
          OR OLD.observed_at_ms <> NEW.observed_at_ms
          OR OLD.finding_version <> NEW.finding_version OR OLD.resolved_at_ms IS NOT NULL
          OR NEW.resolved_at_ms IS NULL
        BEGIN SELECT RAISE(ABORT, 'invalid attachment recovery resolution'); END
        """,
        immutableDelete("runtime_attachment_recovery_findings"),
        """
        CREATE TRIGGER runtime_attachment_recovery_attempt_update_guard
        BEFORE UPDATE ON runtime_attachment_recovery_attempts
        WHEN OLD.work_kind <> NEW.work_kind OR OLD.authority_id <> NEW.authority_id
          OR NEW.state_version <> OLD.state_version + 1
          OR NOT (
              (OLD.resolved_at_ms IS NULL AND NEW.occurrence_fingerprint = OLD.occurrence_fingerprint
               AND NEW.attempt_count = OLD.attempt_count
               AND NEW.last_attempt_at_ms = OLD.last_attempt_at_ms
               AND NEW.next_retry_at_ms = OLD.next_retry_at_ms
               AND (NEW.resolved_at_ms IS NOT NULL OR NEW.last_error_fingerprint IS NOT OLD.last_error_fingerprint))
              OR
              (OLD.resolved_at_ms IS NULL AND NEW.resolved_at_ms IS NULL
               AND NEW.attempt_count = OLD.attempt_count + 1
               AND NEW.last_attempt_at_ms >= OLD.last_attempt_at_ms
               AND NEW.next_retry_at_ms >= NEW.last_attempt_at_ms)
              OR
              (OLD.resolved_at_ms IS NOT NULL AND NEW.resolved_at_ms IS NULL
               AND NEW.occurrence_fingerprint <> OLD.occurrence_fingerprint
               AND NEW.attempt_count = 1 AND NEW.last_error_fingerprint IS NULL
               AND NEW.last_attempt_at_ms >= OLD.resolved_at_ms
               AND NEW.next_retry_at_ms >= NEW.last_attempt_at_ms
               AND EXISTS (
                   SELECT 1 FROM runtime_attachment_recovery_reopen_history AS h
                   WHERE h.work_kind = OLD.work_kind AND h.authority_id = OLD.authority_id
                     AND h.prior_occurrence_fingerprint = OLD.occurrence_fingerprint
                     AND h.next_occurrence_fingerprint = NEW.occurrence_fingerprint
                     AND h.prior_attempt_count = OLD.attempt_count
                     AND h.prior_resolved_at_ms = OLD.resolved_at_ms
                     AND h.reopened_at_ms = NEW.last_attempt_at_ms
                     AND h.prior_state_version = OLD.state_version
                     AND h.next_state_version = NEW.state_version
               ))
          )
        BEGIN SELECT RAISE(ABORT, 'invalid attachment recovery attempt transition'); END
        """,
        immutableDelete("runtime_attachment_recovery_attempts"),
        immutableUpdate("runtime_attachment_recovery_reopen_history"),
        immutableDelete("runtime_attachment_recovery_reopen_history"),
        """
        CREATE TRIGGER runtime_attachment_recovery_cursor_cas
        BEFORE UPDATE ON runtime_attachment_recovery_cursors
        WHEN OLD.scan_kind <> NEW.scan_kind OR NEW.state_version <> OLD.state_version + 1
          OR NEW.cycle NOT IN (OLD.cycle, OLD.cycle + 1)
          OR (NEW.cycle = OLD.cycle AND OLD.last_key IS NOT NULL AND (
              NEW.last_key IS NULL OR NEW.last_key <= OLD.last_key
          ))
          OR (NEW.cycle = OLD.cycle + 1 AND NEW.last_key IS NOT NULL)
        BEGIN SELECT RAISE(ABORT, 'invalid attachment recovery cursor transition'); END
        """,
        immutableDelete("runtime_attachment_recovery_cursors"),
        """
        CREATE TRIGGER runtime_blob_deletion_tombstone_requires_lease
        BEFORE INSERT ON runtime_blob_deletion_tombstones
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_blob_gc_leases AS l
            JOIN runtime_attachment_current_lifecycle AS s ON s.blob_id = l.blob_id
            WHERE l.blob_id = NEW.blob_id AND l.expected_state_version = NEW.final_state_version
              AND l.lease_state = 'active'
              AND s.state_version = NEW.final_state_version AND s.reference_count = 0
              AND s.lifecycle_state = 'deletion_pending'
              AND l.expires_at_ms > NEW.deleted_at_ms
        )
        BEGIN SELECT RAISE(ABORT, 'blob deletion is not leased'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_finalization_bind_receipt
        BEFORE INSERT ON runtime_blob_finalization_intents
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_commit_receipts AS r
            JOIN runtime_semantic_events AS e ON e.sequence = r.terminal_event_sequence
            WHERE r.receipt_id = NEW.receipt_id AND r.command_id = NEW.command_id
              AND e.sequence = NEW.terminal_event_sequence AND e.command_id = NEW.command_id
        ) OR NOT EXISTS (
            SELECT 1 FROM runtime_attachment_current_lifecycle AS s
            WHERE s.blob_id = NEW.blob_id AND s.manifest_digest = NEW.manifest_digest
              AND s.state_version = NEW.expected_state_version AND s.lifecycle_state IN ('referenced','finalized')
        )
        BEGIN SELECT RAISE(ABORT, 'attachment finalization lineage mismatch'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_finalization_update_guard
        BEFORE UPDATE ON runtime_blob_finalization_intents
        WHEN OLD.blob_id <> NEW.blob_id OR OLD.manifest_digest <> NEW.manifest_digest
          OR OLD.command_id <> NEW.command_id OR OLD.receipt_id <> NEW.receipt_id
          OR OLD.terminal_event_sequence <> NEW.terminal_event_sequence
          OR OLD.expected_state_version <> NEW.expected_state_version
          OR OLD.intent_digest <> NEW.intent_digest
          OR OLD.intent_version <> NEW.intent_version OR OLD.created_at_ms <> NEW.created_at_ms
          OR OLD.marker_digest IS NOT NULL OR NEW.marker_digest IS NULL OR NEW.finalized_at_ms IS NULL
          OR OLD.finalization_completion_id IS NOT NULL OR NEW.finalization_completion_id IS NULL
        BEGIN SELECT RAISE(ABORT, 'invalid attachment finalization transition'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_finalization_immutable_delete
        BEFORE DELETE ON runtime_blob_finalization_intents
        BEGIN SELECT RAISE(ABORT, 'immutable attachment finalization'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_receipt_link_bind_authority
        BEFORE INSERT ON runtime_attachment_receipt_links
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_attachment_revisions AS v
            JOIN runtime_blob_records AS b ON b.blob_id = v.blob_id
            WHERE v.revision_id = NEW.revision_id AND v.blob_id = NEW.blob_id
              AND b.manifest_digest = NEW.manifest_digest
        )
        BEGIN SELECT RAISE(ABORT, 'attachment receipt artifact mismatch'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_receipt_link_seal_after_command_finalization
        BEFORE INSERT ON runtime_attachment_receipt_links
        WHEN NEW.link_kind <> 'finalization' AND EXISTS (
            SELECT 1
            FROM runtime_commit_receipts AS r
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            WHERE r.receipt_id = NEW.receipt_id AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized attachment receipt graph is sealed'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_finalization_sidecar_bind_completed_intent
        BEFORE INSERT ON runtime_attachment_receipt_links
        WHEN NEW.link_kind = 'finalization' AND NOT EXISTS (
            SELECT 1
            FROM runtime_blob_finalization_intents AS f
            JOIN runtime_commit_receipts AS r ON r.receipt_id = f.receipt_id
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            JOIN runtime_committed_receipt_cores AS c ON c.receipt_id = r.receipt_id
            WHERE f.receipt_id = NEW.receipt_id
              AND f.blob_id = NEW.blob_id
              AND f.manifest_digest = NEW.manifest_digest
              AND f.marker_digest = NEW.artifact_digest
              AND f.finalization_completion_id = NEW.finalization_completion_id
              AND f.finalized_at_ms IS NOT NULL
              AND i.final_result_version IS NOT NULL
              AND c.command_id = r.command_id
              AND c.terminal_event_sequence = r.terminal_event_sequence
        )
        BEGIN SELECT RAISE(ABORT, 'unproven attachment finalization sidecar'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_finalization_completion_closure
        BEFORE INSERT ON runtime_blob_finalization_completions
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_blob_finalization_intents AS f
            WHERE f.blob_id = NEW.blob_id AND f.manifest_digest = NEW.manifest_digest
              AND f.command_id = NEW.command_id AND f.receipt_id = NEW.receipt_id
              AND f.terminal_event_sequence = NEW.terminal_event_sequence
              AND f.marker_digest = NEW.marker_digest
              AND f.finalized_at_ms = NEW.finalized_at_ms
              AND f.finalization_completion_id = NEW.completion_id
        ) OR NOT EXISTS (
            SELECT 1 FROM runtime_attachment_current_lifecycle AS s
            WHERE s.blob_id = NEW.blob_id AND s.manifest_digest = NEW.manifest_digest
              AND s.lifecycle_state = 'finalized'
              AND s.state_version = NEW.final_state_version
              AND s.updated_at_ms = NEW.finalized_at_ms
        ) OR NOT EXISTS (
            SELECT 1 FROM runtime_attachment_lifecycle_history AS h
            WHERE h.blob_id = NEW.blob_id AND h.state_version = NEW.final_state_version
              AND h.from_state = 'referenced' AND h.to_state = 'finalized'
              AND h.command_id = NEW.command_id AND h.receipt_id = NEW.receipt_id
              AND h.terminal_event_sequence = NEW.terminal_event_sequence
              AND h.occurred_at_ms = NEW.finalized_at_ms
              AND h.finalization_completion_id = NEW.completion_id
        ) OR NOT EXISTS (
            SELECT 1 FROM runtime_attachment_receipt_links AS l
            WHERE l.receipt_id = NEW.receipt_id AND l.revision_id = NEW.revision_id
              AND l.blob_id = NEW.blob_id AND l.manifest_digest = NEW.manifest_digest
              AND l.link_kind = 'finalization' AND l.artifact_digest = NEW.marker_digest
              AND l.finalization_completion_id = NEW.completion_id
        )
        BEGIN SELECT RAISE(ABORT, 'incomplete attachment finalization closure'); END
        """,
        immutableUpdate("runtime_blob_finalization_completions"),
        immutableDelete("runtime_blob_finalization_completions"),
        """
        CREATE TRIGGER runtime_blob_records_block_manifest_deletion_claim
        BEFORE INSERT ON runtime_blob_records
        WHEN EXISTS (
            SELECT 1 FROM runtime_attachment_manifest_deletion_claims AS c
            WHERE c.claim_state = 'active'
              AND (c.blob_id = NEW.blob_id OR c.opaque_relative_directory = NEW.opaque_relative_directory)
        ) OR EXISTS (
            SELECT 1 FROM runtime_attachment_manifest_deletion_tombstones AS t
            WHERE t.blob_id = NEW.blob_id OR t.opaque_relative_directory = NEW.opaque_relative_directory
        )
        BEGIN SELECT RAISE(ABORT, 'attachment manifest deletion is fenced'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_manifest_deletion_claim_eligibility
        BEFORE INSERT ON runtime_attachment_manifest_deletion_claims
        WHEN NEW.claim_state <> 'active' OR NEW.state_version <> 1 OR NEW.completed_at_ms IS NOT NULL
          OR EXISTS (
              SELECT 1 FROM runtime_blob_records AS b
              WHERE b.blob_id = NEW.blob_id
                 OR b.opaque_relative_directory = NEW.opaque_relative_directory
          ) OR EXISTS (
              SELECT 1 FROM runtime_attachment_manifest_deletion_tombstones AS t
              WHERE t.blob_id = NEW.blob_id
                 OR t.opaque_relative_directory = NEW.opaque_relative_directory
          )
        BEGIN SELECT RAISE(ABORT, 'attachment manifest deletion claim is ineligible'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_manifest_deletion_claim_cas
        BEFORE UPDATE ON runtime_attachment_manifest_deletion_claims
        WHEN OLD.claim_id <> NEW.claim_id OR OLD.blob_id <> NEW.blob_id
          OR OLD.manifest_digest <> NEW.manifest_digest
          OR OLD.opaque_relative_directory <> NEW.opaque_relative_directory
          OR OLD.observed_device <> NEW.observed_device OR OLD.observed_inode <> NEW.observed_inode
          OR OLD.recovery_authority_id <> NEW.recovery_authority_id
          OR OLD.claim_version <> NEW.claim_version OR NEW.state_version <> OLD.state_version + 1
          OR OLD.claim_state <> 'active'
          OR NOT (
              (NEW.claim_state = 'active' AND NEW.completed_at_ms IS NULL
               AND NEW.claimed_at_ms >= OLD.claimed_at_ms AND NEW.expires_at_ms > NEW.claimed_at_ms)
              OR (NEW.claim_state = 'completed' AND NEW.completed_at_ms IS NOT NULL
                  AND NEW.claimed_at_ms = OLD.claimed_at_ms AND NEW.expires_at_ms = OLD.expires_at_ms
                  AND EXISTS (
                      SELECT 1 FROM runtime_attachment_manifest_deletion_tombstones AS t
                      WHERE t.claim_id = NEW.claim_id AND t.blob_id = NEW.blob_id
                        AND t.manifest_digest = NEW.manifest_digest
                        AND t.opaque_relative_directory = NEW.opaque_relative_directory
                        AND t.observed_device = NEW.observed_device
                        AND t.observed_inode = NEW.observed_inode
                        AND t.deleted_at_ms = NEW.completed_at_ms
                  ))
          )
        BEGIN SELECT RAISE(ABORT, 'invalid attachment manifest deletion claim transition'); END
        """,
        """
        CREATE TRIGGER runtime_attachment_manifest_deletion_tombstone_guard
        BEFORE INSERT ON runtime_attachment_manifest_deletion_tombstones
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_attachment_manifest_deletion_claims AS c
            WHERE c.claim_id = NEW.claim_id AND c.blob_id = NEW.blob_id
              AND c.manifest_digest = NEW.manifest_digest
              AND c.opaque_relative_directory = NEW.opaque_relative_directory
              AND c.observed_device = NEW.observed_device AND c.observed_inode = NEW.observed_inode
              AND c.claim_state = 'active' AND c.claimed_at_ms <= NEW.deleted_at_ms
              AND c.expires_at_ms > NEW.deleted_at_ms
        ) OR EXISTS (
            SELECT 1 FROM runtime_blob_records AS b
            WHERE b.blob_id = NEW.blob_id OR b.opaque_relative_directory = NEW.opaque_relative_directory
        )
        BEGIN SELECT RAISE(ABORT, 'unproven attachment manifest deletion'); END
        """,
        immutableDelete("runtime_attachment_manifest_deletion_claims"),
        immutableUpdate("runtime_attachment_manifest_deletion_tombstones"),
        immutableDelete("runtime_attachment_manifest_deletion_tombstones"),
    ]

    private static func immutableUpdate(_ table: String) -> String {
        """
        CREATE TRIGGER \(table)_immutable_update
        BEFORE UPDATE ON \(table)
        BEGIN SELECT RAISE(ABORT, 'immutable attachment authority'); END
        """
    }

    private static func immutableDelete(_ table: String) -> String {
        """
        CREATE TRIGGER \(table)_immutable_delete
        BEFORE DELETE ON \(table)
        BEGIN SELECT RAISE(ABORT, 'immutable attachment authority'); END
        """
    }

    private static let receiptArtifactTableV8 = """
        CREATE TABLE runtime_receipt_artifact_links (
            receipt_id TEXT NOT NULL,
            artifact_kind TEXT NOT NULL CHECK (artifact_kind IN (
                'terminal_event','projection_invalidation','tombstone_history','external_operation',
                'compensation_plan','irreversibility_evidence','attachment_revision',
                'attachment_finalization_intent'
            )),
            artifact_id TEXT NOT NULL CHECK (length(artifact_id) > 0),
            artifact_digest TEXT CHECK (artifact_digest IS NULL OR (length(artifact_digest) = 64 AND artifact_digest NOT GLOB '*[^0-9a-f]*')),
            link_version INTEGER NOT NULL CHECK (link_version = 1),
            PRIMARY KEY (receipt_id, artifact_kind, artifact_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id)
        ) WITHOUT ROWID
        """

    private static let receiptArtifactBindingV8 = """
        CREATE TRIGGER runtime_receipt_artifact_links_bind_authority
        BEFORE INSERT ON runtime_receipt_artifact_links
        BEGIN
            SELECT CASE WHEN NEW.artifact_kind = 'terminal_event' AND NOT EXISTS (
                SELECT 1 FROM runtime_committed_receipt_cores AS c
                WHERE c.receipt_id = NEW.receipt_id AND c.terminal_event_id = NEW.artifact_id
                  AND c.terminal_event_hash = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'terminal event artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'projection_invalidation' AND NOT EXISTS (
                SELECT 1 FROM runtime_committed_receipt_cores AS c
                JOIN runtime_commit_projection_invalidations AS i ON i.terminal_event_sequence = c.terminal_event_sequence
                WHERE c.receipt_id = NEW.receipt_id AND i.invalidation_id = NEW.artifact_id
                  AND i.payload_checksum = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'projection invalidation artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'tombstone_history' AND NOT EXISTS (
                SELECT 1 FROM runtime_object_tombstone_history AS t
                WHERE t.receipt_id = NEW.receipt_id AND t.tombstone_history_id = NEW.artifact_id
                  AND t.payload_checksum = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'tombstone artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'external_operation' AND NOT EXISTS (
                SELECT 1 FROM runtime_external_operation_creations AS o
                WHERE o.receipt_id = NEW.receipt_id AND o.operation_id = NEW.artifact_id
                  AND o.creation_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'external operation artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'compensation_plan' AND NOT EXISTS (
                SELECT 1 FROM runtime_compensation_plans AS p
                WHERE p.source_receipt_id = NEW.receipt_id AND p.plan_id = NEW.artifact_id
                  AND p.plan_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'compensation plan artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'irreversibility_evidence' AND NOT EXISTS (
                SELECT 1 FROM runtime_irreversibility_evidence AS e
                WHERE e.source_receipt_id = NEW.receipt_id AND e.source_receipt_id = NEW.artifact_id
                  AND e.evidence_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'irreversibility evidence artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'attachment_revision' AND NOT EXISTS (
                SELECT 1 FROM runtime_attachment_receipt_links AS a
                WHERE a.receipt_id = NEW.receipt_id
                  AND a.revision_id || '#' || a.link_kind = NEW.artifact_id
                  AND a.link_kind <> 'finalization_intent'
                  AND a.artifact_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'attachment revision artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'attachment_finalization_intent' AND NOT EXISTS (
                SELECT 1 FROM runtime_blob_finalization_intents AS i
                WHERE i.receipt_id = NEW.receipt_id AND i.blob_id = NEW.artifact_id
                  AND i.intent_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'attachment finalization artifact mismatch') END;
        END
        """

    private static let receiptFinalizationBindingV8: String = {
        guard let source = CanonicalRuntimeExternalOperationSchemaPlan.fullGenerationStatements.first(where: {
            schemaObjectName($0) == "runtime_command_idempotency_require_complete_receipt"
        }) else { return "" }
        let anchor = """
                  AND (
                      NOT EXISTS (
                          SELECT 1 FROM runtime_semantic_events AS e
        """
        let attachmentParity = """
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_attachment_receipt_links AS ar
                      WHERE ar.receipt_id = c.receipt_id AND ar.link_kind <> 'finalization'
                        AND NOT EXISTS (
                            SELECT 1 FROM runtime_receipt_artifact_links AS a
                            WHERE a.receipt_id = c.receipt_id
                              AND a.artifact_digest = ar.artifact_digest
                              AND (
                                  (ar.link_kind = 'finalization_intent'
                                   AND a.artifact_kind = 'attachment_finalization_intent'
                                   AND a.artifact_id = ar.blob_id)
                                  OR
                                  (ar.link_kind <> 'finalization_intent'
                                   AND a.artifact_kind = 'attachment_revision'
                                   AND a.artifact_id = ar.revision_id || '#' || ar.link_kind)
                              )
                        )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_receipt_artifact_links AS a
                      WHERE a.receipt_id = c.receipt_id
                        AND a.artifact_kind IN ('attachment_revision','attachment_finalization_intent')
                        AND NOT EXISTS (
                            SELECT 1 FROM runtime_attachment_receipt_links AS ar
                            WHERE ar.receipt_id = c.receipt_id
                              AND ar.artifact_digest = a.artifact_digest
                              AND (
                                  (a.artifact_kind = 'attachment_finalization_intent'
                                   AND ar.link_kind = 'finalization_intent'
                                   AND ar.blob_id = a.artifact_id)
                                  OR
                                  (a.artifact_kind = 'attachment_revision'
                                   AND ar.link_kind NOT IN ('finalization_intent','finalization')
                                   AND ar.revision_id || '#' || ar.link_kind = a.artifact_id)
                              )
                        )
                  )
        """
        let whitelistAnchor = """
                          (a.artifact_kind = 'irreversibility_evidence'
                              AND d.disposition_kind = 'noncompensable'
                              AND a.artifact_id = c.receipt_id
                              AND a.artifact_digest = d.evidence_digest)
                        )
        """
        let attachmentPositiveWhitelist = """
                          (a.artifact_kind = 'irreversibility_evidence'
                              AND d.disposition_kind = 'noncompensable'
                              AND a.artifact_id = c.receipt_id
                              AND a.artifact_digest = d.evidence_digest) OR
                          (a.artifact_kind = 'attachment_revision' AND EXISTS (
                              SELECT 1 FROM runtime_attachment_receipt_links AS ar
                              WHERE ar.receipt_id = c.receipt_id
                                AND ar.link_kind NOT IN ('finalization_intent','finalization')
                                AND ar.revision_id || '#' || ar.link_kind = a.artifact_id
                                AND ar.artifact_digest = a.artifact_digest
                          )) OR
                          (a.artifact_kind = 'attachment_finalization_intent' AND EXISTS (
                              SELECT 1 FROM runtime_attachment_receipt_links AS ar
                              JOIN runtime_blob_finalization_intents AS i
                                ON i.receipt_id = ar.receipt_id AND i.blob_id = ar.blob_id
                              WHERE ar.receipt_id = c.receipt_id
                                AND ar.link_kind = 'finalization_intent'
                                AND ar.blob_id = a.artifact_id
                                AND ar.artifact_digest = a.artifact_digest
                                AND i.intent_digest = a.artifact_digest
                          ))
                        )
        """
        guard source.components(separatedBy: anchor).count == 2,
              source.components(separatedBy: whitelistAnchor).count == 2,
              let range = source.range(of: anchor) else { return "" }
        var ported = source
        ported.insert(contentsOf: attachmentParity, at: range.lowerBound)
        guard let whitelistRange = ported.range(of: whitelistAnchor) else { return "" }
        ported.replaceSubrange(whitelistRange, with: attachmentPositiveWhitelist)
        return ported
    }()
}
