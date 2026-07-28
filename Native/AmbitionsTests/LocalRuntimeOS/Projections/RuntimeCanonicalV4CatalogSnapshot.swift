// Independent, literal V4 authority. Do not derive this snapshot from any
// production schema array: its purpose is to make every V4 table, index,
// trigger, constraint, and foreign key byte-visible to migration tests.
enum RuntimeCanonicalV4CatalogSnapshot {
    static let statements: [String] = base + semanticEvents + atomicCommit + replay

    private static let base: [String] = [
        """
        CREATE TABLE runtime_store_metadata (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            schema_version INTEGER NOT NULL CHECK (schema_version > 0),
            generation_id TEXT NOT NULL UNIQUE CHECK (length(generation_id) > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0)
        )
        """,
        """
        CREATE TABLE runtime_aggregates (
            aggregate_kind TEXT NOT NULL CHECK (length(aggregate_kind) > 0),
            aggregate_id TEXT NOT NULL CHECK (length(aggregate_id) > 0),
            revision INTEGER NOT NULL CHECK (revision >= 0),
            payload_version INTEGER NOT NULL CHECK (payload_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (aggregate_kind, aggregate_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_events (
            sequence INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            command_id TEXT NOT NULL CHECK (length(command_id) > 0),
            aggregate_kind TEXT NOT NULL CHECK (length(aggregate_kind) > 0),
            aggregate_id TEXT NOT NULL CHECK (length(aggregate_id) > 0),
            correlation_id TEXT,
            causation_event_id TEXT,
            event_version INTEGER NOT NULL CHECK (event_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            previous_event_hash TEXT CHECK (previous_event_hash IS NULL OR (length(previous_event_hash) = 64 AND previous_event_hash NOT GLOB '*[^0-9a-f]*')),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            recorded_at_ms INTEGER NOT NULL CHECK (recorded_at_ms >= 0),
            FOREIGN KEY (aggregate_kind, aggregate_id)
                REFERENCES runtime_aggregates(aggregate_kind, aggregate_id),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (causation_event_id)
                REFERENCES runtime_events(event_id)
        )
        """,
        "CREATE INDEX runtime_events_command_sequence_idx ON runtime_events(command_id, sequence)",
        "CREATE INDEX runtime_events_aggregate_sequence_idx ON runtime_events(aggregate_kind, aggregate_id, sequence)",
        "CREATE INDEX runtime_events_correlation_sequence_idx ON runtime_events(correlation_id, sequence) WHERE correlation_id IS NOT NULL",
        """
        CREATE TABLE runtime_command_idempotency (
            scope TEXT NOT NULL CHECK (length(scope) > 0),
            idempotency_key TEXT NOT NULL CHECK (length(idempotency_key) > 0),
            command_id TEXT NOT NULL UNIQUE CHECK (length(command_id) > 0),
            command_fingerprint TEXT NOT NULL CHECK (length(command_fingerprint) = 64 AND command_fingerprint NOT GLOB '*[^0-9a-f]*'),
            claim_version INTEGER NOT NULL CHECK (claim_version > 0),
            claim_payload BLOB NOT NULL,
            claimed_at_ms INTEGER NOT NULL CHECK (claimed_at_ms >= 0),
            final_result_version INTEGER CHECK (final_result_version IS NULL OR final_result_version > 0),
            final_result_payload BLOB,
            final_result_checksum TEXT CHECK (final_result_checksum IS NULL OR (length(final_result_checksum) = 64 AND final_result_checksum NOT GLOB '*[^0-9a-f]*')),
            finalized_at_ms INTEGER CHECK (finalized_at_ms IS NULL OR finalized_at_ms >= claimed_at_ms),
            CHECK (
                (final_result_version IS NULL AND final_result_payload IS NULL AND final_result_checksum IS NULL AND finalized_at_ms IS NULL)
                OR
                (final_result_version IS NOT NULL AND final_result_payload IS NOT NULL AND final_result_checksum IS NOT NULL AND finalized_at_ms IS NOT NULL)
            ),
            PRIMARY KEY (scope, idempotency_key)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_receipts (
            receipt_id TEXT PRIMARY KEY CHECK (length(receipt_id) > 0),
            command_id TEXT NOT NULL UNIQUE,
            committed_event_sequence INTEGER NOT NULL CHECK (committed_event_sequence > 0),
            receipt_version INTEGER NOT NULL CHECK (receipt_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (committed_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_projection_checkpoints (
            projection_id TEXT PRIMARY KEY CHECK (length(projection_id) > 0),
            last_event_sequence INTEGER NOT NULL DEFAULT 0 CHECK (last_event_sequence >= 0),
            cursor_stable_id TEXT NOT NULL CHECK (length(cursor_stable_id) > 0),
            cursor_checksum TEXT NOT NULL CHECK (length(cursor_checksum) = 64 AND cursor_checksum NOT GLOB '*[^0-9a-f]*'),
            projection_version INTEGER NOT NULL CHECK (projection_version > 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_projection_invalidations (
            invalidation_id INTEGER PRIMARY KEY AUTOINCREMENT,
            projection_id TEXT NOT NULL CHECK (length(projection_id) > 0),
            causal_event_sequence INTEGER NOT NULL CHECK (causal_event_sequence > 0),
            reason TEXT NOT NULL CHECK (length(reason) > 0),
            invalidation_version INTEGER NOT NULL CHECK (invalidation_version > 0),
            payload BLOB NOT NULL,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (projection_id)
                REFERENCES runtime_projection_checkpoints(projection_id),
            FOREIGN KEY (causal_event_sequence)
                REFERENCES runtime_events(sequence)
        )
        """,
        "CREATE INDEX runtime_projection_invalidations_projection_id_idx ON runtime_projection_invalidations(projection_id, invalidation_id)",
        """
        CREATE TABLE runtime_external_operations (
            operation_id TEXT PRIMARY KEY CHECK (length(operation_id) > 0),
            command_id TEXT NOT NULL,
            receipt_id TEXT,
            operation_kind TEXT NOT NULL CHECK (length(operation_kind) > 0),
            status TEXT NOT NULL CHECK (length(status) > 0),
            operation_version INTEGER NOT NULL CHECK (operation_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
            next_retry_at_ms INTEGER CHECK (next_retry_at_ms IS NULL OR next_retry_at_ms >= 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id)
                REFERENCES runtime_receipts(receipt_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operations_retry_idx ON runtime_external_operations(status, next_retry_at_ms, operation_id) WHERE next_retry_at_ms IS NOT NULL",
        """
        CREATE TABLE runtime_blob_records (
            blob_id TEXT PRIMARY KEY CHECK (length(blob_id) > 0),
            checksum TEXT NOT NULL UNIQUE CHECK (length(checksum) = 64 AND checksum NOT GLOB '*[^0-9a-f]*'),
            byte_count INTEGER NOT NULL CHECK (byte_count >= 0),
            media_type TEXT,
            protection_class TEXT NOT NULL CHECK (length(protection_class) > 0),
            declared_reference_count INTEGER NOT NULL DEFAULT 0 CHECK (declared_reference_count >= 0),
            created_event_sequence INTEGER NOT NULL CHECK (created_event_sequence > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (created_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_references (
            blob_id TEXT NOT NULL,
            owner_kind TEXT NOT NULL CHECK (length(owner_kind) > 0),
            owner_id TEXT NOT NULL CHECK (length(owner_id) > 0),
            reference_kind TEXT NOT NULL CHECK (length(reference_kind) > 0),
            created_event_sequence INTEGER NOT NULL CHECK (created_event_sequence > 0),
            PRIMARY KEY (blob_id, owner_kind, owner_id, reference_kind),
            FOREIGN KEY (blob_id)
                REFERENCES runtime_blob_records(blob_id) ON DELETE RESTRICT,
            FOREIGN KEY (created_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_references_owner_idx ON runtime_blob_references(owner_kind, owner_id, blob_id)",
        """
        CREATE TABLE runtime_tombstones (
            object_kind TEXT NOT NULL CHECK (length(object_kind) > 0),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0),
            revision INTEGER NOT NULL CHECK (revision >= 0),
            causal_event_sequence INTEGER NOT NULL CHECK (causal_event_sequence > 0),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version > 0),
            payload BLOB NOT NULL,
            checksum TEXT NOT NULL CHECK (length(checksum) = 64 AND checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            PRIMARY KEY (object_kind, object_id),
            FOREIGN KEY (causal_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_tombstones_causal_object_idx ON runtime_tombstones(causal_event_sequence, object_kind, object_id)",
    ]

    private static let semanticEvents: [String] = [
        """
        CREATE TABLE runtime_semantic_events (
            sequence INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            command_id TEXT NOT NULL CHECK (length(command_id) > 0),
            aggregate_kind TEXT NOT NULL CHECK (length(aggregate_kind) > 0),
            aggregate_id TEXT NOT NULL CHECK (length(aggregate_id) > 0),
            canonical_revision INTEGER NOT NULL CHECK (canonical_revision >= 0),
            correlation_id TEXT NOT NULL CHECK (length(correlation_id) > 0),
            causation_event_id TEXT,
            envelope_version INTEGER NOT NULL CHECK (envelope_version > 0),
            type_id TEXT NOT NULL CHECK (length(type_id) > 0),
            payload_version INTEGER NOT NULL CHECK (payload_version >= 0),
            source_bytes BLOB NOT NULL CHECK (length(source_bytes) <= 1048576),
            source_digest TEXT NOT NULL CHECK (length(source_digest) = 64 AND source_digest NOT GLOB '*[^0-9a-f]*'),
            previous_event_hash TEXT CHECK (previous_event_hash IS NULL OR (length(previous_event_hash) = 64 AND previous_event_hash NOT GLOB '*[^0-9a-f]*')),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            FOREIGN KEY (aggregate_kind, aggregate_id)
                REFERENCES runtime_aggregates(aggregate_kind, aggregate_id),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (causation_event_id)
                REFERENCES runtime_semantic_events(event_id)
        )
        """,
        "CREATE INDEX runtime_semantic_events_command_sequence_idx ON runtime_semantic_events(command_id, sequence)",
        "CREATE INDEX runtime_semantic_events_aggregate_sequence_idx ON runtime_semantic_events(aggregate_kind, aggregate_id, sequence)",
        "CREATE INDEX runtime_semantic_events_correlation_sequence_idx ON runtime_semantic_events(correlation_id, sequence)",
        """
        CREATE TRIGGER runtime_semantic_events_immutable_update
        BEFORE UPDATE ON runtime_semantic_events
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event'); END
        """,
        """
        CREATE TRIGGER runtime_semantic_events_immutable_delete
        BEFORE DELETE ON runtime_semantic_events
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event'); END
        """,
        """
        CREATE TABLE runtime_semantic_event_quarantine (
            quarantine_sequence INTEGER PRIMARY KEY AUTOINCREMENT,
            quarantine_key TEXT NOT NULL UNIQUE CHECK (length(quarantine_key) = 64 AND quarantine_key NOT GLOB '*[^0-9a-f]*'),
            source_event_id TEXT,
            source_event_sequence INTEGER,
            reason TEXT NOT NULL CHECK (length(reason) > 0),
            source_digest TEXT NOT NULL CHECK (length(source_digest) = 64 AND source_digest NOT GLOB '*[^0-9a-f]*'),
            source_byte_count INTEGER NOT NULL CHECK (source_byte_count >= 0),
            inline_source_bytes BLOB NOT NULL CHECK (length(inline_source_bytes) <= 1048576),
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            CHECK (source_event_sequence IS NULL OR source_event_sequence > 0),
            CHECK (length(inline_source_bytes) = source_byte_count)
        )
        """,
        "CREATE INDEX runtime_semantic_event_quarantine_sequence_idx ON runtime_semantic_event_quarantine(quarantine_sequence)",
        """
        CREATE TRIGGER runtime_semantic_event_quarantine_immutable_update
        BEFORE UPDATE ON runtime_semantic_event_quarantine
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event quarantine'); END
        """,
        """
        CREATE TRIGGER runtime_semantic_event_quarantine_immutable_delete
        BEFORE DELETE ON runtime_semantic_event_quarantine
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event quarantine'); END
        """,
    ]

    private static let atomicCommit: [String] = [
        """
        CREATE TABLE runtime_commit_receipts (
            receipt_id TEXT PRIMARY KEY CHECK (length(receipt_id) > 0),
            preparation_id TEXT NOT NULL UNIQUE CHECK (length(preparation_id) > 0),
            command_id TEXT NOT NULL UNIQUE CHECK (length(command_id) > 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            receipt_version INTEGER NOT NULL CHECK (receipt_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_commit_projection_invalidations (
            invalidation_id TEXT PRIMARY KEY CHECK (length(invalidation_id) > 0),
            projection_id TEXT NOT NULL CHECK (length(projection_id) > 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            invalidation_version INTEGER NOT NULL CHECK (invalidation_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_commit_projection_invalidations_projection_idx ON runtime_commit_projection_invalidations(projection_id, invalidation_id)",
        """
        CREATE TABLE runtime_pending_external_operations (
            operation_id TEXT PRIMARY KEY CHECK (length(operation_id) > 0),
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            operation_kind TEXT NOT NULL CHECK (length(operation_kind) > 0),
            status TEXT NOT NULL CHECK (status = 'pending'),
            operation_version INTEGER NOT NULL CHECK (operation_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            attempt_count INTEGER NOT NULL CHECK (attempt_count = 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_pending_external_operations_status_idx ON runtime_pending_external_operations(status, operation_id)",
        """
        CREATE TABLE runtime_confirmation_consumptions (
            token TEXT PRIMARY KEY CHECK (length(token) > 0),
            preparation_id TEXT NOT NULL,
            command_id TEXT NOT NULL,
            decision_digest TEXT NOT NULL CHECK (length(decision_digest) = 64 AND decision_digest NOT GLOB '*[^0-9a-f]*'),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_commit_tombstones (
            object_id TEXT NOT NULL,
            family TEXT NOT NULL,
            terminal_revision INTEGER NOT NULL CHECK (terminal_revision >= 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            PRIMARY KEY (family, object_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_commit_tombstones_event_idx ON runtime_commit_tombstones(terminal_event_sequence, family, object_id)",
    ]

    private static let replay: [String] = [
        """
        CREATE TABLE runtime_replay_checkpoints (
            checkpoint_id TEXT PRIMARY KEY CHECK (length(checkpoint_id) > 0),
            high_water_sequence INTEGER NOT NULL UNIQUE CHECK (high_water_sequence > 0),
            high_water_event_id TEXT NOT NULL CHECK (length(high_water_event_id) > 0),
            high_water_event_hash TEXT NOT NULL CHECK (length(high_water_event_hash) = 64 AND high_water_event_hash NOT GLOB '*[^0-9a-f]*'),
            source_chain_digest TEXT NOT NULL CHECK (length(source_chain_digest) = 64 AND source_chain_digest NOT GLOB '*[^0-9a-f]*'),
            checkpoint_version INTEGER NOT NULL CHECK (checkpoint_version > 0),
            state_digest TEXT NOT NULL CHECK (length(state_digest) = 64 AND state_digest NOT GLOB '*[^0-9a-f]*'),
            manifest_digest TEXT NOT NULL UNIQUE CHECK (length(manifest_digest) = 64 AND manifest_digest NOT GLOB '*[^0-9a-f]*'),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_checkpoints_sequence_idx ON runtime_replay_checkpoints(high_water_sequence, checkpoint_id)",
        """
        CREATE TABLE runtime_replay_checkpoint_aggregates (
            checkpoint_id TEXT NOT NULL,
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (checkpoint_id, aggregate_kind, aggregate_id),
            FOREIGN KEY (checkpoint_id) REFERENCES runtime_replay_checkpoints(checkpoint_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_checkpoint_aggregates_order_idx ON runtime_replay_checkpoint_aggregates(checkpoint_id, aggregate_kind, aggregate_id)",
        """
        CREATE TRIGGER runtime_replay_checkpoint_aggregates_immutable_update
        BEFORE UPDATE ON runtime_replay_checkpoint_aggregates
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint aggregate'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoint_aggregates_immutable_delete
        BEFORE DELETE ON runtime_replay_checkpoint_aggregates
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint aggregate'); END
        """,
        """
        CREATE TABLE runtime_replay_checkpoint_tombstones (
            checkpoint_id TEXT NOT NULL,
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (checkpoint_id, aggregate_kind, aggregate_id),
            FOREIGN KEY (checkpoint_id) REFERENCES runtime_replay_checkpoints(checkpoint_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_checkpoint_tombstones_order_idx ON runtime_replay_checkpoint_tombstones(checkpoint_id, aggregate_kind, aggregate_id)",
        """
        CREATE TRIGGER runtime_replay_checkpoint_tombstones_immutable_update
        BEFORE UPDATE ON runtime_replay_checkpoint_tombstones
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint tombstone'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoint_tombstones_immutable_delete
        BEFORE DELETE ON runtime_replay_checkpoint_tombstones
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint tombstone'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoints_immutable_update
        BEFORE UPDATE ON runtime_replay_checkpoints
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoints_immutable_delete
        BEFORE DELETE ON runtime_replay_checkpoints
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint'); END
        """,
        """
        CREATE TABLE runtime_replay_retention_holds (
            hold_id TEXT PRIMARY KEY CHECK (length(hold_id) > 0),
            hold_kind TEXT NOT NULL CHECK (length(hold_kind) > 0),
            through_sequence INTEGER NOT NULL CHECK (through_sequence > 0),
            through_event_id TEXT NOT NULL CHECK (length(through_event_id) > 0),
            through_event_hash TEXT NOT NULL CHECK (length(through_event_hash) = 64 AND through_event_hash NOT GLOB '*[^0-9a-f]*'),
            reason_code TEXT NOT NULL CHECK (length(reason_code) > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            released_at_ms INTEGER CHECK (released_at_ms IS NULL OR released_at_ms >= created_at_ms)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_retention_holds_sequence_idx ON runtime_replay_retention_holds(through_sequence, hold_id)",
        """
        CREATE TABLE runtime_replay_quarantine_occurrences (
            occurrence_id TEXT PRIMARY KEY CHECK (length(occurrence_id) = 64 AND occurrence_id NOT GLOB '*[^0-9a-f]*'),
            quarantine_key TEXT NOT NULL,
            source_event_id TEXT,
            source_event_sequence INTEGER,
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            CHECK (source_event_sequence IS NULL OR source_event_sequence > 0),
            FOREIGN KEY (quarantine_key) REFERENCES runtime_semantic_event_quarantine(quarantine_key)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_quarantine_occurrences_source_idx ON runtime_replay_quarantine_occurrences(source_event_sequence, occurrence_id)",
        """
        CREATE TRIGGER runtime_replay_quarantine_occurrences_immutable_update
        BEFORE UPDATE ON runtime_replay_quarantine_occurrences
        BEGIN SELECT RAISE(ABORT, 'immutable quarantine occurrence'); END
        """,
        """
        CREATE TRIGGER runtime_replay_quarantine_occurrences_immutable_delete
        BEFORE DELETE ON runtime_replay_quarantine_occurrences
        BEGIN SELECT RAISE(ABORT, 'immutable quarantine occurrence'); END
        """,
        """
        CREATE TABLE runtime_replay_verified_high_water (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            event_sequence INTEGER NOT NULL CHECK (event_sequence > 0),
            event_id TEXT NOT NULL CHECK (length(event_id) > 0),
            event_hash TEXT NOT NULL CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            chain_anchor_digest TEXT NOT NULL CHECK (length(chain_anchor_digest) = 64 AND chain_anchor_digest NOT GLOB '*[^0-9a-f]*'),
            reconstruction_digest TEXT CHECK (reconstruction_digest IS NULL OR (length(reconstruction_digest) = 64 AND reconstruction_digest NOT GLOB '*[^0-9a-f]*')),
            verified_at_ms INTEGER NOT NULL CHECK (verified_at_ms >= 0)
        )
        """,
        """
        CREATE TABLE runtime_replay_verified_reconstructions (
            event_sequence INTEGER PRIMARY KEY CHECK (event_sequence > 0),
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            source_chain_digest TEXT NOT NULL CHECK (length(source_chain_digest) = 64 AND source_chain_digest NOT GLOB '*[^0-9a-f]*'),
            reconstruction_digest TEXT NOT NULL CHECK (length(reconstruction_digest) = 64 AND reconstruction_digest NOT GLOB '*[^0-9a-f]*'),
            verified_at_ms INTEGER NOT NULL CHECK (verified_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_verified_reconstructions_digest_idx ON runtime_replay_verified_reconstructions(reconstruction_digest, event_sequence)",
        """
        CREATE TRIGGER runtime_replay_verified_reconstructions_immutable_update
        BEFORE UPDATE ON runtime_replay_verified_reconstructions
        BEGIN SELECT RAISE(ABORT, 'immutable verified reconstruction'); END
        """,
        """
        CREATE TRIGGER runtime_replay_verified_reconstructions_immutable_delete
        BEFORE DELETE ON runtime_replay_verified_reconstructions
        BEGIN SELECT RAISE(ABORT, 'immutable verified reconstruction'); END
        """,
    ]
}
