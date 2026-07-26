import AmbitionsRuntimeSQLite
import Foundation

let runtimeCommittedReceiptSchemaVersion = 6

enum CanonicalRuntimeCommittedReceiptSchemaPlan {
    static let sourceSchemaVersion = runtimeCanonicalProjectionSchemaVersion
    static let targetSchemaVersion = runtimeCommittedReceiptSchemaVersion
    static let tables: Set<String> = [
        "runtime_committed_receipt_cores",
        "runtime_receipt_compensation_dispositions",
        "runtime_receipt_object_links",
        "runtime_object_history",
        "runtime_object_tombstone_history",
        "runtime_receipt_artifact_links",
        "runtime_receipt_retention_references",
        "runtime_compensation_plans",
        "runtime_compensation_plan_targets",
        "runtime_compensation_plan_external_operations",
        "runtime_irreversibility_evidence",
        "runtime_compensation_consumptions",
    ]
    static let indexes: Set<String> = [
        "runtime_commit_receipts_event_idx",
        "runtime_committed_receipt_cores_command_idx",
        "runtime_committed_receipt_cores_confirmation_idx",
        "runtime_object_history_object_event_idx",
        "runtime_object_history_receipt_idx",
        "runtime_object_tombstone_history_event_idx",
        "runtime_receipt_artifact_lookup_idx",
        "runtime_receipt_retention_lookup_idx",
        "runtime_compensation_plans_expiry_idx",
        "runtime_compensation_consumptions_receipt_idx",
    ]

    static let statements: [String] = [
        "CREATE UNIQUE INDEX runtime_commit_receipts_event_idx ON runtime_commit_receipts(terminal_event_sequence)",
        """
        CREATE TABLE runtime_committed_receipt_cores (
            receipt_id TEXT PRIMARY KEY,
            command_id TEXT NOT NULL UNIQUE,
            terminal_event_sequence INTEGER NOT NULL UNIQUE CHECK (terminal_event_sequence > 0),
            terminal_event_id TEXT NOT NULL UNIQUE CHECK (length(terminal_event_id) > 0),
            terminal_event_hash TEXT NOT NULL UNIQUE CHECK (length(terminal_event_hash) = 64 AND terminal_event_hash NOT GLOB '*[^0-9a-f]*'),
            correlation_id TEXT NOT NULL CHECK (length(correlation_id) > 0),
            privacy TEXT NOT NULL CHECK (privacy IN ('standard', 'sensitive', 'private_user_text', 'calendar_derived', 'sync_metadata')),
            local_only INTEGER NOT NULL CHECK (local_only = 1),
            core_version INTEGER NOT NULL CHECK (core_version = 2),
            core_digest TEXT NOT NULL UNIQUE CHECK (length(core_digest) = 64 AND core_digest NOT GLOB '*[^0-9a-f]*'),
            confirmation_token TEXT,
            confirmation_decision_digest TEXT,
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            CHECK (
                (confirmation_token IS NULL AND confirmation_decision_digest IS NULL)
                OR
                (confirmation_token IS NOT NULL AND confirmation_decision_digest IS NOT NULL
                 AND length(confirmation_token) > 0
                 AND length(confirmation_decision_digest) = 64
                 AND confirmation_decision_digest NOT GLOB '*[^0-9a-f]*')
            ),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence),
            FOREIGN KEY (terminal_event_id) REFERENCES runtime_semantic_events(event_id),
            FOREIGN KEY (receipt_id, confirmation_token, confirmation_decision_digest)
                REFERENCES runtime_confirmation_consumptions(receipt_id, token, decision_digest)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_committed_receipt_cores_command_idx ON runtime_committed_receipt_cores(command_id, receipt_id)",
        "CREATE INDEX runtime_committed_receipt_cores_confirmation_idx ON runtime_committed_receipt_cores(confirmation_token, confirmation_decision_digest) WHERE confirmation_token IS NOT NULL",
        """
        CREATE TABLE runtime_object_history (
            history_id TEXT PRIMARY KEY CHECK (length(history_id) = 64 AND history_id NOT GLOB '*[^0-9a-f]*'),
            receipt_id TEXT NOT NULL,
            family TEXT NOT NULL CHECK (family IN ('capture', 'goal', 'step', 'schedule', 'reminder', 'profile', 'history', 'repair', 'import_deletion', 'external_operation')),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0),
            prior_revision INTEGER CHECK (prior_revision IS NULL OR prior_revision >= 0),
            resulting_revision INTEGER NOT NULL CHECK (resulting_revision >= 0),
            lifecycle TEXT NOT NULL CHECK (lifecycle IN ('active', 'tombstoned')),
            transition_kind TEXT NOT NULL CHECK (transition_kind IN ('create', 'update', 'attach', 'detach', 'tombstone', 'restore')),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            state_digest TEXT NOT NULL CHECK (length(state_digest) = 64 AND state_digest NOT GLOB '*[^0-9a-f]*'),
            privacy TEXT NOT NULL CHECK (privacy IN ('standard', 'sensitive', 'private_user_text', 'calendar_derived', 'sync_metadata')),
            local_only INTEGER NOT NULL CHECK (local_only = 1),
            history_version INTEGER NOT NULL CHECK (history_version = 1),
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            UNIQUE (family, object_id, resulting_revision),
            UNIQUE (terminal_event_sequence, family, object_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_object_history_object_event_idx ON runtime_object_history(family, object_id, terminal_event_sequence, history_id)",
        "CREATE INDEX runtime_object_history_receipt_idx ON runtime_object_history(receipt_id, family, object_id)",
        """
        CREATE TABLE runtime_receipt_object_links (
            receipt_id TEXT NOT NULL,
            history_id TEXT NOT NULL,
            family TEXT NOT NULL CHECK (family IN ('capture', 'goal', 'step', 'schedule', 'reminder', 'profile', 'history', 'repair', 'import_deletion', 'external_operation')),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0),
            terminal_revision INTEGER NOT NULL CHECK (terminal_revision >= 0),
            link_version INTEGER NOT NULL CHECK (link_version = 1),
            PRIMARY KEY (receipt_id, family, object_id),
            UNIQUE (history_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (history_id) REFERENCES runtime_object_history(history_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_object_tombstone_history (
            tombstone_history_id TEXT PRIMARY KEY CHECK (length(tombstone_history_id) = 64 AND tombstone_history_id NOT GLOB '*[^0-9a-f]*'),
            history_id TEXT NOT NULL UNIQUE,
            receipt_id TEXT NOT NULL,
            family TEXT NOT NULL CHECK (family IN ('capture', 'goal', 'step', 'schedule', 'reminder', 'profile', 'history', 'repair', 'import_deletion', 'external_operation')),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0),
            terminal_revision INTEGER NOT NULL CHECK (terminal_revision >= 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            reason TEXT NOT NULL CHECK (reason IN ('archived', 'reminder_deleted', 'object_deleted', 'memory_forgotten', 'compensated_creation')),
            predecessor_digest TEXT NOT NULL CHECK (length(predecessor_digest) = 64 AND predecessor_digest NOT GLOB '*[^0-9a-f]*'),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version = 1),
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            UNIQUE (terminal_event_sequence, family, object_id),
            FOREIGN KEY (history_id) REFERENCES runtime_object_history(history_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_object_tombstone_history_event_idx ON runtime_object_tombstone_history(family, object_id, terminal_event_sequence, tombstone_history_id)",
        """
        CREATE TABLE runtime_receipt_artifact_links (
            receipt_id TEXT NOT NULL,
            artifact_kind TEXT NOT NULL CHECK (artifact_kind IN ('terminal_event', 'projection_invalidation', 'tombstone_history', 'external_operation', 'compensation_plan', 'irreversibility_evidence')),
            artifact_id TEXT NOT NULL CHECK (length(artifact_id) > 0),
            artifact_digest TEXT CHECK (artifact_digest IS NULL OR (length(artifact_digest) = 64 AND artifact_digest NOT GLOB '*[^0-9a-f]*')),
            link_version INTEGER NOT NULL CHECK (link_version = 1),
            PRIMARY KEY (receipt_id, artifact_kind, artifact_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_receipt_artifact_lookup_idx ON runtime_receipt_artifact_links(artifact_kind, artifact_id, receipt_id)",
        """
        CREATE TABLE runtime_receipt_retention_references (
            receipt_id TEXT NOT NULL,
            reference_kind TEXT NOT NULL CHECK (reference_kind IN ('object_history', 'tombstone_history', 'compensation_source', 'external_operation')),
            reference_id TEXT NOT NULL CHECK (length(reference_id) > 0),
            retain_until_ms INTEGER CHECK (retain_until_ms IS NULL OR retain_until_ms >= 0),
            reference_version INTEGER NOT NULL CHECK (reference_version = 1),
            PRIMARY KEY (receipt_id, reference_kind, reference_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_receipt_retention_lookup_idx ON runtime_receipt_retention_references(reference_kind, reference_id, receipt_id)",
        """
        CREATE TABLE runtime_compensation_plans (
            plan_id TEXT PRIMARY KEY CHECK (length(plan_id) > 0),
            source_receipt_id TEXT NOT NULL UNIQUE,
            source_event_sequence INTEGER NOT NULL CHECK (source_event_sequence > 0),
            source_event_hash TEXT NOT NULL CHECK (length(source_event_hash) = 64 AND source_event_hash NOT GLOB '*[^0-9a-f]*'),
            plan_version INTEGER NOT NULL CHECK (plan_version = 1),
            policy_version INTEGER NOT NULL CHECK (policy_version > 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms >= 0),
            requires_confirmation INTEGER NOT NULL CHECK (requires_confirmation IN (0, 1)),
            privacy TEXT NOT NULL CHECK (privacy IN ('standard', 'sensitive', 'private_user_text', 'calendar_derived', 'sync_metadata')),
            plan_digest TEXT NOT NULL UNIQUE CHECK (length(plan_digest) = 64 AND plan_digest NOT GLOB '*[^0-9a-f]*'),
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (source_receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (source_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_compensation_plans_expiry_idx ON runtime_compensation_plans(expires_at_ms, plan_id)",
        """
        CREATE TABLE runtime_compensation_plan_targets (
            plan_id TEXT NOT NULL,
            family TEXT NOT NULL CHECK (family IN ('capture', 'goal', 'step', 'schedule', 'reminder', 'profile', 'history', 'repair', 'import_deletion', 'external_operation')),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0),
            source_prior_revision INTEGER CHECK (source_prior_revision IS NULL OR source_prior_revision >= 0),
            source_revision INTEGER NOT NULL CHECK (source_revision >= 0),
            source_transition_kind TEXT NOT NULL CHECK (source_transition_kind = 'create'),
            required_current_revision INTEGER NOT NULL CHECK (required_current_revision >= 0),
            required_lifecycle TEXT NOT NULL CHECK (required_lifecycle = 'active'),
            source_state_digest TEXT NOT NULL CHECK (length(source_state_digest) = 64 AND source_state_digest NOT GLOB '*[^0-9a-f]*'),
            transition_kind TEXT NOT NULL CHECK (transition_kind IN ('update', 'detach', 'tombstone', 'restore')),
            target_version INTEGER NOT NULL CHECK (target_version = 1),
            CHECK (source_prior_revision IS NULL),
            PRIMARY KEY (plan_id, family, object_id),
            FOREIGN KEY (plan_id) REFERENCES runtime_compensation_plans(plan_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_compensation_plan_external_operations (
            plan_id TEXT NOT NULL,
            operation_id TEXT NOT NULL,
            operation_version INTEGER NOT NULL CHECK (operation_version = 1),
            PRIMARY KEY (plan_id, operation_id),
            FOREIGN KEY (plan_id) REFERENCES runtime_compensation_plans(plan_id),
            FOREIGN KEY (operation_id) REFERENCES runtime_pending_external_operations(operation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_irreversibility_evidence (
            source_receipt_id TEXT PRIMARY KEY,
            evidence_version INTEGER NOT NULL CHECK (evidence_version = 1),
            permanence TEXT NOT NULL CHECK (permanence IN ('semantic', 'current_runtime_unsupported')),
            reason TEXT NOT NULL CHECK (reason IN ('destructive_erasure', 'missing_prior_semantic_value', 'external_effect_constraint', 'legacy_projection_authority', 'compensation_of_compensation', 'unsupported_semantic_inverse')),
            evidence_digest TEXT NOT NULL UNIQUE CHECK (length(evidence_digest) = 64 AND evidence_digest NOT GLOB '*[^0-9a-f]*'),
            payload BLOB NOT NULL CHECK (length(payload) <= 262144),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (source_receipt_id) REFERENCES runtime_commit_receipts(receipt_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_receipt_compensation_dispositions (
            source_receipt_id TEXT PRIMARY KEY,
            disposition_kind TEXT NOT NULL CHECK (disposition_kind IN ('plan', 'noncompensable')),
            plan_id TEXT,
            evidence_digest TEXT,
            disposition_version INTEGER NOT NULL CHECK (disposition_version = 1),
            payload BLOB NOT NULL CHECK (length(payload) <= 262144),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            CHECK (
                (disposition_kind = 'plan' AND plan_id IS NOT NULL AND evidence_digest IS NULL)
                OR
                (disposition_kind = 'noncompensable' AND plan_id IS NULL AND evidence_digest IS NOT NULL)
            ),
            FOREIGN KEY (source_receipt_id) REFERENCES runtime_committed_receipt_cores(receipt_id),
            FOREIGN KEY (plan_id) REFERENCES runtime_compensation_plans(plan_id),
            FOREIGN KEY (evidence_digest) REFERENCES runtime_irreversibility_evidence(evidence_digest)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_compensation_consumptions (
            plan_id TEXT PRIMARY KEY,
            source_receipt_id TEXT NOT NULL UNIQUE,
            compensation_receipt_id TEXT NOT NULL UNIQUE,
            compensation_command_id TEXT NOT NULL UNIQUE,
            terminal_event_sequence INTEGER NOT NULL UNIQUE CHECK (terminal_event_sequence > 0),
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            consumption_version INTEGER NOT NULL CHECK (consumption_version = 1),
            FOREIGN KEY (plan_id) REFERENCES runtime_compensation_plans(plan_id),
            FOREIGN KEY (source_receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (compensation_receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (compensation_command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_compensation_consumptions_receipt_idx ON runtime_compensation_consumptions(source_receipt_id, compensation_receipt_id)",
    ] + invariantTriggers + immutableTriggers + postFinalizationInsertSealTriggers

    private static let immutableTables = [
        "runtime_commit_receipts", "runtime_commit_projection_invalidations",
        "runtime_pending_external_operations", "runtime_confirmation_consumptions",
        "runtime_commit_tombstones", "runtime_committed_receipt_cores",
        "runtime_receipt_compensation_dispositions",
        "runtime_receipt_object_links", "runtime_object_history",
        "runtime_object_tombstone_history", "runtime_receipt_artifact_links",
        "runtime_receipt_retention_references", "runtime_compensation_plans",
        "runtime_compensation_plan_targets", "runtime_compensation_plan_external_operations",
        "runtime_irreversibility_evidence",
        "runtime_compensation_consumptions",
    ]

    private static var immutableTriggers: [String] {
        immutableTables.flatMap { table in
            [
                "CREATE TRIGGER \(table)_immutable_update BEFORE UPDATE ON \(table) BEGIN SELECT RAISE(ABORT, 'immutable receipt authority'); END",
                "CREATE TRIGGER \(table)_immutable_delete BEFORE DELETE ON \(table) BEGIN SELECT RAISE(ABORT, 'immutable receipt authority'); END",
            ]
        }
    }

    /// Rows in these tables are assembled while the owning command remains an
    /// unfinalized idempotency claim. Once final_result_version is present, no
    /// additional authority or child row may extend the authenticated receipt
    /// graph. Compensation consumption is intentionally excluded: it is the
    /// sole row that binds a newly constructing compensation command to an
    /// already-finalized source receipt.
    static let postFinalizationInsertSealedTables: Set<String> = [
        "runtime_semantic_events",
        "runtime_commit_receipts",
        "runtime_commit_projection_invalidations",
        "runtime_pending_external_operations",
        "runtime_confirmation_consumptions",
        "runtime_commit_tombstones",
        "runtime_committed_receipt_cores",
        "runtime_receipt_compensation_dispositions",
        "runtime_receipt_object_links",
        "runtime_object_history",
        "runtime_object_tombstone_history",
        "runtime_receipt_artifact_links",
        "runtime_receipt_retention_references",
        "runtime_compensation_plans",
        "runtime_compensation_plan_targets",
        "runtime_compensation_plan_external_operations",
        "runtime_irreversibility_evidence",
    ]

    private static let postFinalizationInsertSealTriggers: [String] = [
        directCommandInsertSeal(table: "runtime_semantic_events", commandExpression: "NEW.command_id"),
        commitReceiptInsertSeal(),
        terminalEventInsertSeal(table: "runtime_commit_projection_invalidations"),
        pendingExternalOperationInsertSeal(),
        confirmationConsumptionInsertSeal(),
        terminalEventInsertSeal(table: "runtime_commit_tombstones"),
        directCommandInsertSeal(table: "runtime_committed_receipt_cores", commandExpression: "NEW.command_id"),
        receiptInsertSeal(table: "runtime_receipt_compensation_dispositions", receiptExpression: "NEW.source_receipt_id"),
        receiptInsertSeal(table: "runtime_receipt_object_links", receiptExpression: "NEW.receipt_id"),
        receiptInsertSeal(table: "runtime_object_history", receiptExpression: "NEW.receipt_id"),
        receiptInsertSeal(table: "runtime_object_tombstone_history", receiptExpression: "NEW.receipt_id"),
        receiptInsertSeal(table: "runtime_receipt_artifact_links", receiptExpression: "NEW.receipt_id"),
        receiptInsertSeal(table: "runtime_receipt_retention_references", receiptExpression: "NEW.receipt_id"),
        receiptInsertSeal(table: "runtime_compensation_plans", receiptExpression: "NEW.source_receipt_id"),
        planInsertSeal(table: "runtime_compensation_plan_targets"),
        planInsertSeal(table: "runtime_compensation_plan_external_operations"),
        receiptInsertSeal(table: "runtime_irreversibility_evidence", receiptExpression: "NEW.source_receipt_id"),
    ]

    private static func directCommandInsertSeal(
        table: String,
        commandExpression: String
    ) -> String {
        """
        CREATE TRIGGER \(table)_reject_insert_after_finalization
        BEFORE INSERT ON \(table)
        WHEN EXISTS (
            SELECT 1 FROM runtime_command_idempotency
            WHERE command_id = \(commandExpression) AND final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static func terminalEventInsertSeal(table: String) -> String {
        """
        CREATE TRIGGER \(table)_reject_insert_after_finalization
        BEFORE INSERT ON \(table)
        WHEN EXISTS (
            SELECT 1
            FROM runtime_semantic_events AS e
            JOIN runtime_command_idempotency AS i ON i.command_id = e.command_id
            WHERE e.sequence = NEW.terminal_event_sequence
              AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static func commitReceiptInsertSeal() -> String {
        """
        CREATE TRIGGER runtime_commit_receipts_reject_insert_after_finalization
        BEFORE INSERT ON runtime_commit_receipts
        WHEN EXISTS (
            SELECT 1 FROM runtime_command_idempotency
            WHERE command_id = NEW.command_id AND final_result_version IS NOT NULL
        ) OR EXISTS (
            SELECT 1
            FROM runtime_semantic_events AS e
            JOIN runtime_command_idempotency AS i ON i.command_id = e.command_id
            WHERE e.sequence = NEW.terminal_event_sequence
              AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static func pendingExternalOperationInsertSeal() -> String {
        """
        CREATE TRIGGER runtime_pending_external_operations_reject_insert_after_finalization
        BEFORE INSERT ON runtime_pending_external_operations
        WHEN EXISTS (
            SELECT 1 FROM runtime_command_idempotency
            WHERE command_id = NEW.command_id AND final_result_version IS NOT NULL
        ) OR EXISTS (
            SELECT 1
            FROM runtime_commit_receipts AS r
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            WHERE r.receipt_id = NEW.receipt_id AND i.final_result_version IS NOT NULL
        ) OR EXISTS (
            SELECT 1
            FROM runtime_semantic_events AS e
            JOIN runtime_command_idempotency AS i ON i.command_id = e.command_id
            WHERE e.sequence = NEW.terminal_event_sequence
              AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static func confirmationConsumptionInsertSeal() -> String {
        """
        CREATE TRIGGER runtime_confirmation_consumptions_reject_insert_after_finalization
        BEFORE INSERT ON runtime_confirmation_consumptions
        WHEN EXISTS (
            SELECT 1 FROM runtime_command_idempotency
            WHERE command_id = NEW.command_id AND final_result_version IS NOT NULL
        ) OR EXISTS (
            SELECT 1
            FROM runtime_commit_receipts AS r
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            WHERE r.receipt_id = NEW.receipt_id AND i.final_result_version IS NOT NULL
        ) OR EXISTS (
            SELECT 1
            FROM runtime_semantic_events AS e
            JOIN runtime_command_idempotency AS i ON i.command_id = e.command_id
            WHERE e.sequence = NEW.terminal_event_sequence
              AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static func receiptInsertSeal(
        table: String,
        receiptExpression: String
    ) -> String {
        """
        CREATE TRIGGER \(table)_reject_insert_after_finalization
        BEFORE INSERT ON \(table)
        WHEN EXISTS (
            SELECT 1
            FROM runtime_commit_receipts AS r
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            WHERE r.receipt_id = \(receiptExpression)
              AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static func planInsertSeal(table: String) -> String {
        """
        CREATE TRIGGER \(table)_reject_insert_after_finalization
        BEFORE INSERT ON \(table)
        WHEN EXISTS (
            SELECT 1
            FROM runtime_compensation_plans AS p
            JOIN runtime_commit_receipts AS r ON r.receipt_id = p.source_receipt_id
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            WHERE p.plan_id = NEW.plan_id
              AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized receipt graph is sealed'); END
        """
    }

    private static let invariantTriggers: [String] = [
        """
        CREATE TRIGGER runtime_commit_receipts_bind_command_event
        BEFORE INSERT ON runtime_commit_receipts
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_semantic_events AS e
                WHERE e.sequence = NEW.terminal_event_sequence
                  AND e.command_id = NEW.command_id
            ) THEN RAISE(ABORT, 'commit receipt authority mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_pending_external_operations_bind_receipt_command_event
        BEFORE INSERT ON runtime_pending_external_operations
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_commit_receipts AS r
                JOIN runtime_semantic_events AS e
                  ON e.sequence = r.terminal_event_sequence
                WHERE r.receipt_id = NEW.receipt_id
                  AND r.command_id = NEW.command_id
                  AND r.terminal_event_sequence = NEW.terminal_event_sequence
                  AND e.command_id = NEW.command_id
            ) THEN RAISE(ABORT, 'pending external operation authority mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_confirmation_consumptions_bind_receipt_command_event
        BEFORE INSERT ON runtime_confirmation_consumptions
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_commit_receipts AS r
                JOIN runtime_semantic_events AS e
                  ON e.sequence = r.terminal_event_sequence
                WHERE r.receipt_id = NEW.receipt_id
                  AND r.preparation_id = NEW.preparation_id
                  AND r.command_id = NEW.command_id
                  AND r.terminal_event_sequence = NEW.terminal_event_sequence
                  AND r.created_at_ms = NEW.consumed_at_ms
                  AND e.command_id = NEW.command_id
            ) THEN RAISE(ABORT, 'confirmation consumption authority mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_object_history_maximum_per_receipt
        BEFORE INSERT ON runtime_object_history
        WHEN (SELECT COUNT(*) FROM runtime_object_history WHERE receipt_id = NEW.receipt_id) >= \(RuntimeCommittedReceiptLimits.maximumHistoryEntries)
        BEGIN SELECT RAISE(ABORT, 'receipt object-history maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_receipt_object_links_maximum_per_receipt
        BEFORE INSERT ON runtime_receipt_object_links
        WHEN (SELECT COUNT(*) FROM runtime_receipt_object_links WHERE receipt_id = NEW.receipt_id) >= \(RuntimeCommittedReceiptLimits.maximumObjectLinks)
        BEGIN SELECT RAISE(ABORT, 'receipt object-link maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_object_tombstone_history_maximum_per_receipt
        BEFORE INSERT ON runtime_object_tombstone_history
        WHEN (SELECT COUNT(*) FROM runtime_object_tombstone_history WHERE receipt_id = NEW.receipt_id) >= \(RuntimeCommittedReceiptLimits.maximumTombstones)
        BEGIN SELECT RAISE(ABORT, 'receipt tombstone maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_receipt_artifact_links_maximum_per_receipt
        BEFORE INSERT ON runtime_receipt_artifact_links
        WHEN (SELECT COUNT(*) FROM runtime_receipt_artifact_links WHERE receipt_id = NEW.receipt_id) >= \(RuntimeCommittedReceiptLimits.maximumArtifacts)
        BEGIN SELECT RAISE(ABORT, 'receipt artifact maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_receipt_retention_references_maximum_per_receipt
        BEFORE INSERT ON runtime_receipt_retention_references
        WHEN (SELECT COUNT(*) FROM runtime_receipt_retention_references WHERE receipt_id = NEW.receipt_id) >= \(RuntimeCommittedReceiptLimits.maximumRetentionReferences)
        BEGIN SELECT RAISE(ABORT, 'receipt retention maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_compensation_plan_targets_maximum
        BEFORE INSERT ON runtime_compensation_plan_targets
        WHEN (SELECT COUNT(*) FROM runtime_compensation_plan_targets WHERE plan_id = NEW.plan_id) >= \(RuntimeCompensationLimits.maximumTargets)
        BEGIN SELECT RAISE(ABORT, 'compensation target maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_compensation_plan_external_operations_maximum
        BEFORE INSERT ON runtime_compensation_plan_external_operations
        WHEN (
            SELECT COUNT(*) FROM runtime_compensation_plan_external_operations
            WHERE plan_id = NEW.plan_id
        ) >= \(RuntimeCompensationLimits.maximumExternalOperations)
        BEGIN SELECT RAISE(ABORT, 'compensation external-operation maximum exceeded'); END
        """,
        """
        CREATE TRIGGER runtime_committed_receipt_cores_bind_terminal_event
        BEFORE INSERT ON runtime_committed_receipt_cores
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_commit_receipts AS r
                JOIN runtime_semantic_events AS e ON e.sequence = r.terminal_event_sequence
                WHERE r.receipt_id = NEW.receipt_id
                  AND r.preparation_id IS NOT NULL
                  AND r.command_id = NEW.command_id
                  AND r.terminal_event_sequence = NEW.terminal_event_sequence
                  AND r.receipt_version = \(runtimeCommitAnchorVersion)
                  AND r.created_at_ms = NEW.created_at_ms
                  AND e.event_id = NEW.terminal_event_id
                  AND e.event_hash = NEW.terminal_event_hash
                  AND e.correlation_id = NEW.correlation_id
                  AND e.command_id = NEW.command_id
            ) THEN RAISE(ABORT, 'receipt core terminal event mismatch') END;
            SELECT CASE WHEN NEW.confirmation_token IS NULL AND EXISTS (
                SELECT 1 FROM runtime_confirmation_consumptions
                WHERE receipt_id = NEW.receipt_id
                   OR preparation_id = (
                       SELECT preparation_id FROM runtime_commit_receipts
                       WHERE receipt_id = NEW.receipt_id
                   )
                   OR command_id = NEW.command_id
                   OR terminal_event_sequence = NEW.terminal_event_sequence
            ) THEN RAISE(ABORT, 'unexpected confirmation authority') END;
            SELECT CASE WHEN NEW.confirmation_token IS NOT NULL AND NOT EXISTS (
                SELECT 1
                FROM runtime_confirmation_consumptions AS confirmation
                JOIN runtime_commit_receipts AS r ON r.receipt_id = confirmation.receipt_id
                WHERE confirmation.receipt_id = NEW.receipt_id
                  AND confirmation.preparation_id = r.preparation_id
                  AND confirmation.command_id = NEW.command_id
                  AND confirmation.terminal_event_sequence = NEW.terminal_event_sequence
                  AND confirmation.token = NEW.confirmation_token
                  AND confirmation.decision_digest = NEW.confirmation_decision_digest
                  AND confirmation.consumed_at_ms = NEW.created_at_ms
            ) THEN RAISE(ABORT, 'missing exact confirmation authority') END;
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM runtime_semantic_event_quarantine
                WHERE source_event_id = NEW.terminal_event_id
                   OR source_event_sequence = NEW.terminal_event_sequence
            ) THEN RAISE(ABORT, 'receipt core terminal event quarantined') END;
        END
        """,
        """
        CREATE TRIGGER runtime_object_history_bind_receipt_event
        BEFORE INSERT ON runtime_object_history
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_committed_receipt_cores AS c
                JOIN runtime_semantic_events AS e ON e.sequence = c.terminal_event_sequence
                WHERE c.receipt_id = NEW.receipt_id
                  AND c.terminal_event_sequence = NEW.terminal_event_sequence
            ) THEN RAISE(ABORT, 'object history receipt event mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_receipt_object_links_bind_history
        BEFORE INSERT ON runtime_receipt_object_links
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_object_history
                WHERE history_id = NEW.history_id
                  AND receipt_id = NEW.receipt_id
                  AND family = NEW.family
                  AND object_id = NEW.object_id
                  AND resulting_revision = NEW.terminal_revision
            ) THEN RAISE(ABORT, 'receipt object link mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_object_tombstone_history_bind_history
        BEFORE INSERT ON runtime_object_tombstone_history
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_object_history
                WHERE history_id = NEW.history_id
                  AND receipt_id = NEW.receipt_id
                  AND family = NEW.family
                  AND object_id = NEW.object_id
                  AND resulting_revision = NEW.terminal_revision
                  AND terminal_event_sequence = NEW.terminal_event_sequence
                  AND lifecycle = 'tombstoned'
                  AND transition_kind = 'tombstone'
            ) THEN RAISE(ABORT, 'tombstone history mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_compensation_plans_bind_source
        BEFORE INSERT ON runtime_compensation_plans
        BEGIN
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM runtime_irreversibility_evidence
                WHERE source_receipt_id = NEW.source_receipt_id
            ) THEN RAISE(ABORT, 'receipt already has irreversibility evidence') END;
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_committed_receipt_cores
                WHERE receipt_id = NEW.source_receipt_id
                  AND terminal_event_sequence = NEW.source_event_sequence
                  AND terminal_event_hash = NEW.source_event_hash
                  AND privacy = NEW.privacy
            ) THEN RAISE(ABORT, 'compensation plan source mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_irreversibility_evidence_excludes_plan
        BEFORE INSERT ON runtime_irreversibility_evidence
        BEGIN
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM runtime_compensation_plans
                WHERE source_receipt_id = NEW.source_receipt_id
            ) THEN RAISE(ABORT, 'receipt already has compensation plan') END;
        END
        """,
        """
        CREATE TRIGGER runtime_compensation_plan_targets_bind_history
        BEFORE INSERT ON runtime_compensation_plan_targets
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_compensation_plans AS p
                JOIN runtime_object_history AS h ON h.receipt_id = p.source_receipt_id
                WHERE p.plan_id = NEW.plan_id
                  AND h.family = NEW.family
                  AND h.object_id = NEW.object_id
                  AND h.prior_revision IS NEW.source_prior_revision
                  AND h.resulting_revision = NEW.source_revision
                  AND h.transition_kind = NEW.source_transition_kind
                  AND h.lifecycle = NEW.required_lifecycle
                  AND h.state_digest = NEW.source_state_digest
                  AND NEW.required_current_revision = NEW.source_revision
            ) THEN RAISE(ABORT, 'compensation target source mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_compensation_plan_external_operations_bind_source
        BEFORE INSERT ON runtime_compensation_plan_external_operations
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_compensation_plans AS p
                JOIN runtime_pending_external_operations AS o
                  ON o.operation_id = NEW.operation_id
                WHERE p.plan_id = NEW.plan_id
                  AND o.receipt_id = p.source_receipt_id
                  AND o.terminal_event_sequence = p.source_event_sequence
                  AND o.status = 'pending'
            ) THEN RAISE(ABORT, 'compensation external operation source mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_receipt_artifact_links_bind_authority
        BEFORE INSERT ON runtime_receipt_artifact_links
        BEGIN
            SELECT CASE WHEN NEW.artifact_kind = 'terminal_event' AND NOT EXISTS (
                SELECT 1 FROM runtime_committed_receipt_cores AS c
                WHERE c.receipt_id = NEW.receipt_id
                  AND c.terminal_event_id = NEW.artifact_id
                  AND c.terminal_event_hash = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'terminal event artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'projection_invalidation' AND NOT EXISTS (
                SELECT 1
                FROM runtime_committed_receipt_cores AS c
                JOIN runtime_commit_projection_invalidations AS i
                  ON i.terminal_event_sequence = c.terminal_event_sequence
                WHERE c.receipt_id = NEW.receipt_id
                  AND i.invalidation_id = NEW.artifact_id
                  AND i.payload_checksum = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'projection invalidation artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'tombstone_history' AND NOT EXISTS (
                SELECT 1 FROM runtime_object_tombstone_history AS t
                WHERE t.receipt_id = NEW.receipt_id
                  AND t.tombstone_history_id = NEW.artifact_id
                  AND t.payload_checksum = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'tombstone artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'external_operation' AND NOT EXISTS (
                SELECT 1 FROM runtime_pending_external_operations AS o
                WHERE o.receipt_id = NEW.receipt_id
                  AND o.operation_id = NEW.artifact_id
                  AND o.payload_checksum = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'external operation artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'compensation_plan' AND NOT EXISTS (
                SELECT 1 FROM runtime_compensation_plans AS p
                WHERE p.source_receipt_id = NEW.receipt_id
                  AND p.plan_id = NEW.artifact_id
                  AND p.plan_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'compensation plan artifact mismatch') END;
            SELECT CASE WHEN NEW.artifact_kind = 'irreversibility_evidence' AND NOT EXISTS (
                SELECT 1 FROM runtime_irreversibility_evidence AS e
                WHERE e.source_receipt_id = NEW.receipt_id
                  AND e.source_receipt_id = NEW.artifact_id
                  AND e.evidence_digest = NEW.artifact_digest
            ) THEN RAISE(ABORT, 'irreversibility evidence artifact mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_receipt_compensation_dispositions_bind_child
        BEFORE INSERT ON runtime_receipt_compensation_dispositions
        BEGIN
            SELECT CASE WHEN NEW.disposition_kind = 'plan' AND NOT EXISTS (
                SELECT 1 FROM runtime_compensation_plans
                WHERE plan_id = NEW.plan_id AND source_receipt_id = NEW.source_receipt_id
            ) THEN RAISE(ABORT, 'receipt plan disposition mismatch') END;
            SELECT CASE WHEN NEW.disposition_kind = 'noncompensable' AND NOT EXISTS (
                SELECT 1 FROM runtime_irreversibility_evidence
                WHERE source_receipt_id = NEW.source_receipt_id
                  AND evidence_digest = NEW.evidence_digest
            ) THEN RAISE(ABORT, 'receipt evidence disposition mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_compensation_consumptions_bind_causation
        BEFORE INSERT ON runtime_compensation_consumptions
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_compensation_plans AS p
                JOIN runtime_committed_receipt_cores AS source ON source.receipt_id = p.source_receipt_id
                JOIN runtime_committed_receipt_cores AS compensation ON compensation.receipt_id = NEW.compensation_receipt_id
                JOIN runtime_semantic_events AS e ON e.sequence = NEW.terminal_event_sequence
                WHERE p.plan_id = NEW.plan_id
                  AND p.source_receipt_id = NEW.source_receipt_id
                  AND NEW.source_receipt_id <> NEW.compensation_receipt_id
                  AND source.receipt_id <> compensation.receipt_id
                  AND compensation.command_id = NEW.compensation_command_id
                  AND compensation.terminal_event_sequence = NEW.terminal_event_sequence
                  AND compensation.created_at_ms = NEW.consumed_at_ms
                  AND compensation.terminal_event_id = e.event_id
                  AND compensation.terminal_event_hash = e.event_hash
                  AND e.command_id = NEW.compensation_command_id
                  AND e.correlation_id = compensation.correlation_id
                  AND e.type_id IN (
                      'ambitions.compensation.capture_created',
                      'ambitions.compensation.goal_created',
                      'ambitions.compensation.schedule_created',
                      'ambitions.compensation.reminder_created'
                  )
                  AND e.causation_event_id = source.terminal_event_id
                  AND e.correlation_id = source.correlation_id
            ) THEN RAISE(ABORT, 'compensation consumption causation mismatch') END;
        END
        """,
        """
        CREATE TRIGGER runtime_command_idempotency_seal_authority
        BEFORE UPDATE ON runtime_command_idempotency
        BEGIN
            SELECT CASE WHEN NEW.scope IS NOT OLD.scope
                OR NEW.idempotency_key IS NOT OLD.idempotency_key
                OR NEW.command_id IS NOT OLD.command_id
                OR NEW.command_fingerprint IS NOT OLD.command_fingerprint
                OR NEW.claim_version IS NOT OLD.claim_version
                OR NEW.claim_payload IS NOT OLD.claim_payload
                OR NEW.claimed_at_ms IS NOT OLD.claimed_at_ms
            THEN RAISE(ABORT, 'idempotency claim authority is immutable') END;
            SELECT CASE WHEN OLD.final_result_version IS NOT NULL
            THEN RAISE(ABORT, 'finalized idempotency authority is immutable') END;
        END
        """,
        """
        CREATE TRIGGER runtime_command_idempotency_require_complete_receipt
        BEFORE UPDATE OF final_result_version ON runtime_command_idempotency
        WHEN OLD.final_result_version IS NULL AND NEW.final_result_version IS NOT NULL
          AND NEW.scope = 'runtime.command'
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_committed_receipt_cores AS c
                JOIN runtime_receipt_compensation_dispositions AS d
                  ON d.source_receipt_id = c.receipt_id
                WHERE c.command_id = NEW.command_id
                  AND EXISTS (
                      SELECT 1 FROM runtime_commit_receipts AS r
                      WHERE r.receipt_id = c.receipt_id
                        AND r.preparation_id IS NOT NULL
                        AND r.command_id = c.command_id
                        AND r.terminal_event_sequence = c.terminal_event_sequence
                        AND r.receipt_version = \(runtimeCommitAnchorVersion)
                        AND r.created_at_ms = c.created_at_ms
                  )
                  AND (
                      (
                          c.confirmation_token IS NULL
                          AND c.confirmation_decision_digest IS NULL
                          AND NOT EXISTS (
                              SELECT 1 FROM runtime_confirmation_consumptions AS confirmation
                              JOIN runtime_commit_receipts AS candidate
                                ON candidate.receipt_id = c.receipt_id
                              WHERE confirmation.receipt_id = c.receipt_id
                                 OR confirmation.preparation_id = candidate.preparation_id
                                 OR confirmation.command_id = c.command_id
                                 OR confirmation.terminal_event_sequence = c.terminal_event_sequence
                          )
                      )
                      OR
                      (
                          c.confirmation_token IS NOT NULL
                          AND c.confirmation_decision_digest IS NOT NULL
                          AND 1 = (
                              SELECT COUNT(*)
                              FROM runtime_confirmation_consumptions AS confirmation
                              JOIN runtime_commit_receipts AS candidate
                                ON candidate.receipt_id = c.receipt_id
                              WHERE confirmation.receipt_id = c.receipt_id
                                AND confirmation.preparation_id = candidate.preparation_id
                                AND confirmation.command_id = c.command_id
                                AND confirmation.terminal_event_sequence = c.terminal_event_sequence
                                AND confirmation.token = c.confirmation_token
                                AND confirmation.decision_digest = c.confirmation_decision_digest
                                AND confirmation.consumed_at_ms = c.created_at_ms
                          )
                      )
                  )
                  AND EXISTS (
                      SELECT 1 FROM runtime_receipt_object_links WHERE receipt_id = c.receipt_id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_receipt_object_links AS l
                      WHERE l.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_object_history AS h
                          WHERE h.history_id = l.history_id AND h.receipt_id = l.receipt_id
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_object_history AS h
                      WHERE h.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_object_links AS l
                          WHERE l.history_id = h.history_id AND l.receipt_id = h.receipt_id
                      )
                  )
                  AND (
                      d.disposition_kind <> 'plan'
                      OR (
                          EXISTS (
                              SELECT 1 FROM runtime_compensation_plan_targets
                              WHERE plan_id = d.plan_id
                          )
                          AND NOT EXISTS (
                              SELECT 1 FROM runtime_object_history AS h
                              WHERE h.receipt_id = c.receipt_id AND NOT EXISTS (
                                  SELECT 1 FROM runtime_compensation_plan_targets AS t
                                  WHERE t.plan_id = d.plan_id
                                    AND t.family = h.family AND t.object_id = h.object_id
                                    AND t.source_prior_revision IS h.prior_revision
                                    AND t.source_revision = h.resulting_revision
                                    AND t.source_transition_kind = h.transition_kind
                                    AND t.required_current_revision = h.resulting_revision
                                    AND t.required_lifecycle = h.lifecycle
                                    AND t.source_state_digest = h.state_digest
                              )
                          )
                          AND NOT EXISTS (
                              SELECT 1 FROM runtime_compensation_plan_external_operations AS po
                              WHERE po.plan_id = d.plan_id AND NOT EXISTS (
                                  SELECT 1 FROM runtime_pending_external_operations AS o
                                  WHERE o.operation_id = po.operation_id
                                    AND o.receipt_id = c.receipt_id
                                    AND o.terminal_event_sequence = c.terminal_event_sequence
                                    AND o.status = 'pending'
                              )
                          )
                          AND NOT EXISTS (
                              SELECT 1 FROM runtime_pending_external_operations AS o
                              WHERE o.receipt_id = c.receipt_id AND NOT EXISTS (
                                  SELECT 1 FROM runtime_compensation_plan_external_operations AS po
                                  WHERE po.plan_id = d.plan_id
                                    AND po.operation_id = o.operation_id
                              )
                          )
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_object_history AS h
                      WHERE h.receipt_id = c.receipt_id AND h.lifecycle = 'tombstoned'
                        AND NOT EXISTS (
                            SELECT 1 FROM runtime_object_tombstone_history AS t
                            WHERE t.history_id = h.history_id AND t.receipt_id = h.receipt_id
                        )
                  )
                  AND EXISTS (
                      SELECT 1 FROM runtime_receipt_artifact_links AS a
                      WHERE a.receipt_id = c.receipt_id AND a.artifact_kind = 'terminal_event'
                        AND a.artifact_id = c.terminal_event_id
                        AND a.artifact_digest = c.terminal_event_hash
                  )
                  AND 1 = (
                      SELECT COUNT(*) FROM runtime_receipt_artifact_links AS a
                      WHERE a.receipt_id = c.receipt_id AND a.artifact_kind = 'terminal_event'
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_object_tombstone_history AS t
                      WHERE t.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_artifact_links AS a
                          WHERE a.receipt_id = c.receipt_id AND a.artifact_kind = 'tombstone_history'
                            AND a.artifact_id = t.tombstone_history_id
                            AND a.artifact_digest = t.payload_checksum
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_commit_projection_invalidations AS i
                      WHERE i.terminal_event_sequence = c.terminal_event_sequence AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_artifact_links AS a
                          WHERE a.receipt_id = c.receipt_id AND a.artifact_kind = 'projection_invalidation'
                            AND a.artifact_id = i.invalidation_id
                            AND a.artifact_digest = i.payload_checksum
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_pending_external_operations AS o
                      WHERE o.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_artifact_links AS a
                          WHERE a.receipt_id = c.receipt_id AND a.artifact_kind = 'external_operation'
                            AND a.artifact_id = o.operation_id
                            AND a.artifact_digest = o.payload_checksum
                      )
                  )
                  AND (
                      (d.disposition_kind = 'plan' AND EXISTS (
                          SELECT 1 FROM runtime_receipt_artifact_links AS a
                          JOIN runtime_compensation_plans AS p ON p.plan_id = d.plan_id
                          WHERE a.receipt_id = c.receipt_id
                            AND a.artifact_kind = 'compensation_plan'
                            AND a.artifact_id = p.plan_id
                            AND a.artifact_digest = p.plan_digest
                      )) OR
                      (d.disposition_kind = 'noncompensable' AND EXISTS (
                          SELECT 1 FROM runtime_receipt_artifact_links AS a
                          WHERE a.receipt_id = c.receipt_id
                            AND a.artifact_kind = 'irreversibility_evidence'
                            AND a.artifact_id = c.receipt_id
                            AND a.artifact_digest = d.evidence_digest
                      ))
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_receipt_artifact_links AS a
                      WHERE a.receipt_id = c.receipt_id AND a.artifact_kind <> 'terminal_event'
                        AND NOT (
                          (a.artifact_kind = 'projection_invalidation' AND EXISTS (
                              SELECT 1 FROM runtime_commit_projection_invalidations AS i
                              WHERE i.invalidation_id = a.artifact_id
                                AND i.terminal_event_sequence = c.terminal_event_sequence
                                AND i.payload_checksum = a.artifact_digest
                          )) OR
                          (a.artifact_kind = 'tombstone_history' AND EXISTS (
                              SELECT 1 FROM runtime_object_tombstone_history AS t
                              WHERE t.tombstone_history_id = a.artifact_id
                                AND t.receipt_id = c.receipt_id
                                AND t.payload_checksum = a.artifact_digest
                          )) OR
                          (a.artifact_kind = 'external_operation' AND EXISTS (
                              SELECT 1 FROM runtime_pending_external_operations AS o
                              WHERE o.operation_id = a.artifact_id
                                AND o.receipt_id = c.receipt_id
                                AND o.payload_checksum = a.artifact_digest
                          )) OR
                          (a.artifact_kind = 'compensation_plan' AND d.disposition_kind = 'plan'
                              AND a.artifact_id = d.plan_id AND EXISTS (
                                  SELECT 1 FROM runtime_compensation_plans AS p
                                  WHERE p.plan_id = d.plan_id AND p.plan_digest = a.artifact_digest
                              )) OR
                          (a.artifact_kind = 'irreversibility_evidence'
                              AND d.disposition_kind = 'noncompensable'
                              AND a.artifact_id = c.receipt_id
                              AND a.artifact_digest = d.evidence_digest)
                        )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_object_history AS h
                      WHERE h.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_retention_references AS rr
                          WHERE rr.receipt_id = c.receipt_id AND rr.reference_kind = 'object_history'
                            AND rr.reference_id = h.history_id AND rr.retain_until_ms IS NULL
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_object_tombstone_history AS t
                      WHERE t.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_retention_references AS rr
                          WHERE rr.receipt_id = c.receipt_id
                            AND rr.reference_kind = 'tombstone_history'
                            AND rr.reference_id = t.tombstone_history_id
                            AND rr.retain_until_ms IS NULL
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_pending_external_operations AS o
                      WHERE o.receipt_id = c.receipt_id AND NOT EXISTS (
                          SELECT 1 FROM runtime_receipt_retention_references AS rr
                          WHERE rr.receipt_id = c.receipt_id
                            AND rr.reference_kind = 'external_operation'
                            AND rr.reference_id = o.operation_id
                            AND rr.retain_until_ms IS NULL
                      )
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_receipt_retention_references AS rr
                      WHERE rr.receipt_id = c.receipt_id AND NOT (
                          (rr.reference_kind = 'object_history' AND EXISTS (
                              SELECT 1 FROM runtime_object_history AS h
                              WHERE h.history_id = rr.reference_id AND h.receipt_id = c.receipt_id
                                AND rr.retain_until_ms IS NULL
                          )) OR
                          (rr.reference_kind = 'tombstone_history' AND EXISTS (
                              SELECT 1 FROM runtime_object_tombstone_history AS t
                              WHERE t.tombstone_history_id = rr.reference_id
                                AND t.receipt_id = c.receipt_id AND rr.retain_until_ms IS NULL
                          )) OR
                          (rr.reference_kind = 'external_operation' AND EXISTS (
                              SELECT 1 FROM runtime_pending_external_operations AS o
                              WHERE o.operation_id = rr.reference_id
                                AND o.receipt_id = c.receipt_id AND rr.retain_until_ms IS NULL
                          )) OR
                          (rr.reference_kind = 'compensation_source'
                              AND d.disposition_kind = 'plan' AND rr.reference_id = d.plan_id
                              AND rr.retain_until_ms = (
                                  SELECT expires_at_ms FROM runtime_compensation_plans
                                  WHERE plan_id = d.plan_id
                              ))
                        )
                  )
                  AND (
                      NOT EXISTS (
                          SELECT 1 FROM runtime_semantic_events AS e
                          WHERE e.sequence = c.terminal_event_sequence
                            AND e.type_id IN (
                                'ambitions.compensation.capture_created',
                                'ambitions.compensation.goal_created',
                                'ambitions.compensation.schedule_created',
                                'ambitions.compensation.reminder_created'
                            )
                      )
                      OR EXISTS (
                          SELECT 1
                          FROM runtime_compensation_consumptions AS cc
                          JOIN runtime_compensation_plans AS cp ON cp.plan_id = cc.plan_id
                          JOIN runtime_committed_receipt_cores AS source
                            ON source.receipt_id = cp.source_receipt_id
                          JOIN runtime_semantic_events AS e
                            ON e.sequence = cc.terminal_event_sequence
                          WHERE cc.compensation_receipt_id = c.receipt_id
                            AND cc.compensation_command_id = c.command_id
                            AND cc.terminal_event_sequence = c.terminal_event_sequence
                            AND cc.source_receipt_id = cp.source_receipt_id
                            AND e.causation_event_id = source.terminal_event_id
                            AND e.correlation_id = source.correlation_id
                      )
                  )
                  AND (
                      EXISTS (
                          SELECT 1 FROM runtime_semantic_events AS e
                          WHERE e.sequence = c.terminal_event_sequence
                            AND e.type_id IN (
                                'ambitions.compensation.capture_created',
                                'ambitions.compensation.goal_created',
                                'ambitions.compensation.schedule_created',
                                'ambitions.compensation.reminder_created'
                            )
                      )
                      OR NOT EXISTS (
                          SELECT 1 FROM runtime_compensation_consumptions AS cc
                          WHERE cc.compensation_receipt_id = c.receipt_id
                             OR cc.compensation_command_id = c.command_id
                             OR cc.terminal_event_sequence = c.terminal_event_sequence
                      )
                  )
            ) THEN RAISE(ABORT, 'incomplete committed receipt authority') END;
        END
        """,
    ]

    static let stagedIntegratedStatements =
        CanonicalRuntimeProjectionSchemaPlan.stagedIntegratedStatements + statements

    static let requiredTriggerNames: Set<String> = Set(immutableTables.flatMap { table in
        ["\(table)_immutable_update", "\(table)_immutable_delete"]
    }).union(postFinalizationInsertSealedTables.map { table in
        "\(table)_reject_insert_after_finalization"
    }).union([
        "runtime_committed_receipt_cores_bind_terminal_event",
        "runtime_object_history_bind_receipt_event",
        "runtime_receipt_object_links_bind_history",
        "runtime_object_tombstone_history_bind_history",
        "runtime_compensation_plans_bind_source",
        "runtime_irreversibility_evidence_excludes_plan",
        "runtime_compensation_plan_targets_bind_history",
        "runtime_compensation_plan_external_operations_bind_source",
        "runtime_receipt_artifact_links_bind_authority",
        "runtime_receipt_compensation_dispositions_bind_child",
        "runtime_compensation_consumptions_bind_causation",
        "runtime_object_history_maximum_per_receipt",
        "runtime_receipt_object_links_maximum_per_receipt",
        "runtime_object_tombstone_history_maximum_per_receipt",
        "runtime_receipt_artifact_links_maximum_per_receipt",
        "runtime_receipt_retention_references_maximum_per_receipt",
        "runtime_compensation_plan_targets_maximum",
        "runtime_compensation_plan_external_operations_maximum",
        "runtime_pending_external_operations_bind_receipt_command_event",
        "runtime_confirmation_consumptions_bind_receipt_command_event",
        "runtime_commit_receipts_bind_command_event",
        "runtime_semantic_events_immutable_update",
        "runtime_semantic_events_immutable_delete",
        "runtime_command_idempotency_seal_authority",
        "runtime_command_idempotency_require_complete_receipt",
    ])

    static func requireIntegratedSchema(in database: isolated SQLiteDatabase) throws {
        let rows = try database.query("PRAGMA user_version")
        if rows.count == 1,
           rows[0].values.first == .integer(Int64(runtimeCanonicalAttachmentSchemaVersion)) {
            try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            return
        }
        guard rows.count == 1, rows[0].values.first == .integer(Int64(targetSchemaVersion)) else {
            let actual: Int
            if case let .integer(value)? = rows.first?.values.first { actual = Int(value) }
            else { actual = 0 }
            throw RuntimeCanonicalReplayError.migrationRequired(expected: targetSchemaVersion, actual: actual)
        }
        try CanonicalRuntimeCommitSchemaPlan.requireIntegratedSchema(in: database)
    }
}
