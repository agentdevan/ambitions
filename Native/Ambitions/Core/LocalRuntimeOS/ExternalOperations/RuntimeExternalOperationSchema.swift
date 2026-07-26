import AmbitionsRuntimeSQLite
import Foundation

enum CanonicalRuntimeExternalOperationSchemaPlan {
    static let sourceSchemaVersion = runtimeCommittedReceiptSchemaVersion
    static let targetSchemaVersion = runtimeCanonicalExternalOperationSchemaVersion

    static let tables: Set<String> = [
        "runtime_external_operation_creations",
        "runtime_external_operation_targets",
        "runtime_external_operation_current",
        "runtime_external_operation_history",
        "runtime_external_operation_attempt_starts",
        "runtime_external_operation_attempt_outcomes",
        "runtime_external_operation_transition_invalidations",
    ]

    static let indexes: Set<String> = [
        "runtime_external_operation_creations_receipt_idx",
        "runtime_external_operation_current_due_idx",
        "runtime_external_operation_history_operation_idx",
        "runtime_external_operation_attempt_starts_operation_idx",
        "runtime_external_operation_attempt_outcomes_operation_idx",
        "runtime_external_operation_transition_invalidations_operation_idx",
    ]

    private static let creationTable = """
        CREATE TABLE runtime_external_operation_creations (
            operation_id TEXT PRIMARY KEY CHECK (length(operation_id) > 0 AND length(operation_id) <= 1024),
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            operation_kind TEXT NOT NULL CHECK (operation_kind IN ('reminder', 'calendar_event')),
            operation_action TEXT NOT NULL CHECK (operation_action IN ('create', 'compensate_removal')),
            source_operation_id TEXT,
            source_provider_reference TEXT CHECK (source_provider_reference IS NULL OR length(source_provider_reference) BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumProviderReferenceBytes)),
            source_receipt_id TEXT,
            compensation_plan_id TEXT,
            compensation_plan_digest TEXT CHECK (compensation_plan_digest IS NULL OR (length(compensation_plan_digest) = 64 AND compensation_plan_digest NOT GLOB '*[^0-9a-f]*')),
            provider_id TEXT NOT NULL CHECK (length(provider_id) BETWEEN 1 AND 128),
            stable_idempotency_key TEXT NOT NULL UNIQUE CHECK (length(stable_idempotency_key) = 64 AND stable_idempotency_key NOT GLOB '*[^0-9a-f]*'),
            privacy TEXT NOT NULL CHECK (privacy IN ('standard', 'sensitive', 'private_user_text', 'calendar_derived', 'sync_metadata')),
            local_only INTEGER NOT NULL CHECK (local_only = 1),
            policy_version INTEGER NOT NULL CHECK (policy_version = 1),
            creation_version INTEGER NOT NULL CHECK (creation_version = 1),
            creation_payload BLOB NOT NULL CHECK (length(creation_payload) <= \(RuntimeExternalOperationLimits.maximumCreationBytes)),
            creation_digest TEXT NOT NULL UNIQUE CHECK (length(creation_digest) = 64 AND creation_digest NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            CHECK (
                (operation_action = 'create' AND source_operation_id IS NULL AND source_provider_reference IS NULL
                 AND source_receipt_id IS NULL AND compensation_plan_id IS NULL AND compensation_plan_digest IS NULL)
                OR
                (operation_action = 'compensate_removal' AND source_operation_id IS NOT NULL
                 AND source_provider_reference IS NOT NULL AND source_receipt_id IS NOT NULL
                 AND compensation_plan_id IS NOT NULL AND compensation_plan_digest IS NOT NULL
                 AND source_operation_id <> operation_id)
            ),
            UNIQUE (source_operation_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence),
            FOREIGN KEY (source_operation_id) REFERENCES runtime_external_operation_creations(operation_id),
            FOREIGN KEY (source_receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (compensation_plan_id) REFERENCES runtime_compensation_plans(plan_id)
        ) WITHOUT ROWID
        """

    private static let normalizedStatements: [String] = [
        "CREATE INDEX runtime_external_operation_creations_receipt_idx ON runtime_external_operation_creations(receipt_id, operation_id)",
        """
        CREATE TABLE runtime_external_operation_targets (
            operation_id TEXT NOT NULL,
            family TEXT NOT NULL CHECK (family IN ('capture','goal','step','schedule','reminder','profile','history','repair','import_deletion','external_operation')),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0 AND length(object_id) <= 1024),
            PRIMARY KEY (operation_id, family, object_id),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_external_operation_current (
            operation_id TEXT PRIMARY KEY,
            creation_digest TEXT NOT NULL,
            provider_id TEXT NOT NULL CHECK (length(provider_id) BETWEEN 1 AND 128),
            workflow_status TEXT NOT NULL CHECK (workflow_status IN (
                'pending','claimed','executing','succeeded','retry_scheduled',
                'permanent_failure','reconciliation_required','operator_required','cancelled'
            )),
            effect_disposition TEXT NOT NULL CHECK (effect_disposition IN (
                'not_attempted','confirmed_absent','confirmed_present','indeterminate'
            )),
            status_version INTEGER NOT NULL CHECK (status_version BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumTransitions)),
            policy_version INTEGER NOT NULL CHECK (policy_version = 1),
            attempt_count INTEGER NOT NULL CHECK (attempt_count BETWEEN 0 AND \(RuntimeExternalOperationLimits.maximumAttempts)),
            next_attempt_at_ms INTEGER CHECK (next_attempt_at_ms >= 0),
            claim_purpose TEXT CHECK (claim_purpose IN ('execute','reconcile')),
            lease_token TEXT,
            lease_owner TEXT,
            lease_acquired_at_ms INTEGER CHECK (lease_acquired_at_ms >= 0),
            lease_expires_at_ms INTEGER CHECK (lease_expires_at_ms >= 0),
            external_reference TEXT CHECK (length(external_reference) BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumProviderReferenceBytes)),
            reason_code TEXT CHECK (reason_code IN (\(reasonCodesSQL))),
            reason_fingerprint TEXT CHECK (reason_fingerprint IS NULL OR (length(reason_fingerprint) = 64 AND reason_fingerprint NOT GLOB '*[^0-9a-f]*')),
            state_payload BLOB NOT NULL CHECK (length(state_payload) <= \(RuntimeExternalOperationLimits.maximumCurrentStateBytes)),
            state_digest TEXT NOT NULL CHECK (length(state_digest) = 64 AND state_digest NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= created_at_ms),
            CHECK ((reason_code IS NULL) = (reason_fingerprint IS NULL)),
            CHECK (
                (workflow_status = 'pending' AND effect_disposition = 'not_attempted') OR
                (workflow_status = 'claimed' AND effect_disposition IN ('not_attempted','confirmed_absent')) OR
                (workflow_status = 'executing' AND effect_disposition IN ('not_attempted','confirmed_absent')) OR
                (workflow_status = 'retry_scheduled' AND effect_disposition IN ('not_attempted','confirmed_absent')) OR
                (workflow_status = 'reconciliation_required' AND effect_disposition = 'indeterminate') OR
                (workflow_status = 'operator_required' AND effect_disposition = 'indeterminate') OR
                (workflow_status = 'succeeded' AND effect_disposition IN ('confirmed_present','confirmed_absent')) OR
                (workflow_status = 'permanent_failure' AND effect_disposition IN ('not_attempted','confirmed_absent','indeterminate')) OR
                (workflow_status = 'cancelled' AND effect_disposition IN ('not_attempted','confirmed_absent'))
            ),
            CHECK (
                ((lease_token IS NULL) AND (lease_owner IS NULL) AND
                 (lease_acquired_at_ms IS NULL) AND (lease_expires_at_ms IS NULL)) OR
                ((lease_token IS NOT NULL) AND (lease_owner IS NOT NULL) AND
                 (lease_acquired_at_ms IS NOT NULL) AND (lease_expires_at_ms IS NOT NULL) AND
                 lease_expires_at_ms > lease_acquired_at_ms AND
                 lease_expires_at_ms - lease_acquired_at_ms <= \(Int(RuntimeExternalOperationLimits.maximumLeaseSeconds * 1_000)))
            ),
            CHECK (
                (workflow_status IN ('claimed','executing') AND lease_token IS NOT NULL AND claim_purpose = 'execute') OR
                (workflow_status = 'reconciliation_required' AND
                    ((lease_token IS NULL AND claim_purpose IS NULL) OR
                     (lease_token IS NOT NULL AND claim_purpose = 'reconcile'))) OR
                (workflow_status NOT IN ('claimed','executing','reconciliation_required') AND
                    lease_token IS NULL AND claim_purpose IS NULL)
            ),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id),
            FOREIGN KEY (creation_digest) REFERENCES runtime_external_operation_creations(creation_digest)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operation_current_due_idx ON runtime_external_operation_current(workflow_status, next_attempt_at_ms, updated_at_ms, operation_id)",
        """
        CREATE TABLE runtime_external_operation_history (
            history_id TEXT PRIMARY KEY CHECK (length(history_id) = 64 AND history_id NOT GLOB '*[^0-9a-f]*'),
            operation_id TEXT NOT NULL,
            status_version INTEGER NOT NULL CHECK (status_version BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumTransitions)),
            from_workflow_status TEXT,
            from_effect_disposition TEXT,
            from_state_digest TEXT,
            to_workflow_status TEXT NOT NULL,
            to_effect_disposition TEXT NOT NULL,
            to_state_digest TEXT NOT NULL CHECK (length(to_state_digest) = 64 AND to_state_digest NOT GLOB '*[^0-9a-f]*'),
            attempt_id TEXT,
            transition_version INTEGER NOT NULL CHECK (transition_version = 1),
            transition_payload BLOB NOT NULL CHECK (length(transition_payload) <= \(RuntimeExternalOperationLimits.maximumHistoryBytes)),
            transition_payload_digest TEXT NOT NULL CHECK (length(transition_payload_digest) = 64 AND transition_payload_digest NOT GLOB '*[^0-9a-f]*'),
            transition_digest TEXT NOT NULL UNIQUE CHECK (length(transition_digest) = 64 AND transition_digest NOT GLOB '*[^0-9a-f]*'),
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            UNIQUE (operation_id, status_version),
            CHECK ((from_workflow_status IS NULL) = (from_effect_disposition IS NULL)),
            CHECK ((from_workflow_status IS NULL) = (from_state_digest IS NULL)),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id),
            FOREIGN KEY (attempt_id, operation_id)
                REFERENCES runtime_external_operation_attempt_starts(attempt_id, operation_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operation_history_operation_idx ON runtime_external_operation_history(operation_id, status_version)",
        """
        CREATE TABLE runtime_external_operation_attempt_starts (
            attempt_id TEXT PRIMARY KEY CHECK (length(attempt_id) > 0 AND length(attempt_id) <= 256),
            operation_id TEXT NOT NULL,
            attempt_number INTEGER NOT NULL CHECK (attempt_number BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumAttempts)),
            purpose TEXT NOT NULL CHECK (purpose IN ('execute','reconcile')),
            operation_action TEXT NOT NULL CHECK (operation_action IN ('create','compensate_removal')),
            source_status_version INTEGER NOT NULL CHECK (source_status_version BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumTransitions - 1)),
            policy_version INTEGER NOT NULL CHECK (policy_version = 1),
            provider_id TEXT NOT NULL CHECK (length(provider_id) BETWEEN 1 AND 128),
            operation_kind TEXT NOT NULL CHECK (operation_kind IN ('reminder','calendar_event')),
            lease_token TEXT NOT NULL,
            lease_owner TEXT NOT NULL,
            lease_acquired_at_ms INTEGER NOT NULL CHECK (lease_acquired_at_ms >= 0),
            lease_expires_at_ms INTEGER NOT NULL CHECK (lease_expires_at_ms > lease_acquired_at_ms),
            stable_idempotency_key TEXT NOT NULL CHECK (length(stable_idempotency_key) = 64 AND stable_idempotency_key NOT GLOB '*[^0-9a-f]*'),
            request_digest TEXT NOT NULL CHECK (length(request_digest) = 64 AND request_digest NOT GLOB '*[^0-9a-f]*'),
            start_version INTEGER NOT NULL CHECK (start_version = 1),
            start_payload BLOB NOT NULL CHECK (length(start_payload) <= \(RuntimeExternalOperationLimits.maximumAttemptStartBytes)),
            start_digest TEXT NOT NULL UNIQUE CHECK (length(start_digest) = 64 AND start_digest NOT GLOB '*[^0-9a-f]*'),
            started_at_ms INTEGER NOT NULL CHECK (started_at_ms BETWEEN lease_acquired_at_ms AND lease_expires_at_ms),
            UNIQUE (operation_id, attempt_number),
            UNIQUE (operation_id, source_status_version),
            UNIQUE (attempt_id, operation_id),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operation_attempt_starts_operation_idx ON runtime_external_operation_attempt_starts(operation_id, attempt_number)",
        """
        CREATE TABLE runtime_external_operation_attempt_outcomes (
            attempt_id TEXT PRIMARY KEY,
            operation_id TEXT NOT NULL,
            outcome_kind TEXT NOT NULL CHECK (outcome_kind IN (
                'confirmed_success','confirmed_cancellation','cancellation_retryable_before_effect',
                'cancellation_unsupported','cancellation_source_still_present',
                'reconciled_cancellation_absent','confirmed_presence','confirmed_absence',
                'rejected_before_effect','retryable_before_effect',
                'permission_unavailable_before_effect','indeterminate',
                'lease_expired_without_outcome','ambiguous_reconciliation',
                'incompatible_provider_state'
            )),
            effect_disposition TEXT NOT NULL CHECK (effect_disposition IN (
                'not_attempted','confirmed_absent','confirmed_present','indeterminate'
            )),
            external_reference TEXT CHECK (length(external_reference) BETWEEN 1 AND \(RuntimeExternalOperationLimits.maximumProviderReferenceBytes)),
            reason_code TEXT CHECK (reason_code IN (\(reasonCodesSQL))),
            reason_fingerprint TEXT CHECK (reason_fingerprint IS NULL OR (length(reason_fingerprint) = 64 AND reason_fingerprint NOT GLOB '*[^0-9a-f]*')),
            outcome_version INTEGER NOT NULL CHECK (outcome_version = 1),
            outcome_payload BLOB NOT NULL CHECK (length(outcome_payload) <= \(RuntimeExternalOperationLimits.maximumAttemptOutcomeBytes)),
            outcome_digest TEXT NOT NULL UNIQUE CHECK (length(outcome_digest) = 64 AND outcome_digest NOT GLOB '*[^0-9a-f]*'),
            recorded_at_ms INTEGER NOT NULL CHECK (recorded_at_ms >= 0),
            CHECK ((reason_code IS NULL) = (reason_fingerprint IS NULL)),
            FOREIGN KEY (attempt_id) REFERENCES runtime_external_operation_attempt_starts(attempt_id),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id),
            FOREIGN KEY (attempt_id, operation_id)
                REFERENCES runtime_external_operation_attempt_starts(attempt_id, operation_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operation_attempt_outcomes_operation_idx ON runtime_external_operation_attempt_outcomes(operation_id, recorded_at_ms, attempt_id)",
        """
        CREATE TABLE runtime_external_operation_transition_invalidations (
            invalidation_id TEXT PRIMARY KEY CHECK (length(invalidation_id) = 64 AND invalidation_id NOT GLOB '*[^0-9a-f]*'),
            operation_id TEXT NOT NULL,
            status_version INTEGER NOT NULL CHECK (status_version BETWEEN 2 AND \(RuntimeExternalOperationLimits.maximumTransitions)),
            history_id TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL CHECK (length(payload) <= \(RuntimeExternalOperationLimits.maximumTransitionInvalidationBytes)),
            payload_digest TEXT NOT NULL UNIQUE CHECK (length(payload_digest) = 64 AND payload_digest NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            UNIQUE (operation_id, status_version),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id),
            FOREIGN KEY (history_id) REFERENCES runtime_external_operation_history(history_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operation_transition_invalidations_operation_idx ON runtime_external_operation_transition_invalidations(operation_id, status_version)",
    ] + invariantTriggers

    /// Exact v6 objects whose semantics change in v7. Every other statement is
    /// retained byte-for-byte; a future v6 object is never silently rewritten.
    private static let removedBaseObjectNames: Set<String> = [
        "runtime_external_operations",
        "runtime_external_operations_retry_idx",
    ]

    private static let replacedV6ObjectNames: Set<String> = [
        "runtime_pending_external_operations",
        "runtime_pending_external_operations_status_idx",
        "runtime_compensation_plan_external_operations",
        "runtime_pending_external_operations_immutable_update",
        "runtime_pending_external_operations_immutable_delete",
        "runtime_pending_external_operations_reject_insert_after_finalization",
        "runtime_pending_external_operations_bind_receipt_command_event",
        "runtime_compensation_plan_external_operations_bind_source",
        "runtime_receipt_artifact_links_bind_authority",
        "runtime_command_idempotency_require_complete_receipt",
    ]

    static let stagedIntegratedStatements: [String] = {
        let replacements: [String: String] = [
            "runtime_pending_external_operations": creationTable,
            "runtime_pending_external_operations_status_idx":
                "CREATE INDEX runtime_external_operation_creations_receipt_idx ON runtime_external_operation_creations(receipt_id, operation_id)",
            "runtime_compensation_plan_external_operations": compensationExternalOperationsTableV7,
        ]
        let source = CanonicalRuntimeCommittedReceiptSchemaPlan.stagedIntegratedStatements
        let parsedSourceNames = source.compactMap(schemaObjectName)
        let sourceNames = Set(parsedSourceNames)
        guard parsedSourceNames.count == source.count,
              sourceNames.count == source.count,
              Set(replacements.keys).isSubset(of: sourceNames),
              replacedV6ObjectNames.isSubset(of: sourceNames) else { return [] }
        let base = source.compactMap {
            statement -> String? in
            guard let name = schemaObjectName(statement) else { return nil }
            if let replacement = replacements[name] { return replacement }
            if replacedV6ObjectNames.contains(name) { return nil }
            return statement
        }
        return base + normalizedStatements.dropFirst() + [
            compensationExternalBindingV7,
            receiptArtifactBindingV7,
            receiptFinalizationBindingV7,
        ]
    }()

    /// The sole authoritative full schema-v7 generation consumed by T15.
    /// It is also the exact catalog authenticated for every v7 open.
    static let fullGenerationStatements: [String] = {
        let baseSource = CanonicalRuntimeStore.schemaStatements
        let parsedBaseNames = baseSource.compactMap(schemaObjectName)
        let baseNames = Set(parsedBaseNames)
        guard parsedBaseNames.count == baseSource.count,
              baseNames.count == baseSource.count,
              removedBaseObjectNames.isSubset(of: baseNames) else { return [] }
        let sanitizedBase = baseSource.filter { statement in
            guard let name = schemaObjectName(statement) else { return false }
            return removedBaseObjectNames.contains(name) == false
        }
        return sanitizedBase + stagedIntegratedStatements
    }()

    static func requireIntegratedSchema(in database: isolated SQLiteDatabase) throws {
        let versionRows = try database.query("PRAGMA user_version")
        guard versionRows.count == 1,
              versionRows[0].values.first == .integer(Int64(targetSchemaVersion)) else {
            let actual: Int
            if case let .integer(value)? = versionRows.first?.values.first { actual = Int(value) }
            else { actual = 0 }
            throw RuntimeCanonicalExternalOperationError.migrationRequired(
                expected: targetSchemaVersion, actual: actual
            )
        }
        let entries = fullGenerationStatements.compactMap { statement -> (String, RuntimeExternalSchemaCatalogEntry)? in
            guard let name = schemaObjectName(statement), let type = schemaObjectType(statement) else {
                return nil
            }
            return (name, RuntimeExternalSchemaCatalogEntry(type: type, sql: normalizeSQL(statement)))
        }
        guard fullGenerationStatements.isEmpty == false,
              entries.count == fullGenerationStatements.count,
              Set(entries.map(\.0)).count == entries.count else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        let expected = Dictionary(uniqueKeysWithValues: entries)
        let rows = try database.query(
            "SELECT name, type, sql FROM sqlite_schema WHERE name LIKE 'runtime_%' AND type IN ('table','index','trigger') ORDER BY name"
        )
        let actualEntries = try rows.map { row -> (String, RuntimeExternalSchemaCatalogEntry) in
            guard case let .text(name)? = row.value(named: "name"),
                  case let .text(type)? = row.value(named: "type"),
                  case let .text(sql)? = row.value(named: "sql") else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            return (name, RuntimeExternalSchemaCatalogEntry(type: type, sql: normalizeSQL(sql)))
        }
        guard Set(actualEntries.map(\.0)).count == actualEntries.count,
              Dictionary(uniqueKeysWithValues: actualEntries) == expected,
              expected["runtime_pending_external_operations"] == nil,
              expected["runtime_external_operations"] == nil else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        let metadata = try database.query(
            "SELECT schema_version FROM runtime_store_metadata WHERE singleton_id = 1 LIMIT 2"
        )
        guard metadata.count == 1,
              metadata[0].value(named: "schema_version") == .integer(Int64(targetSchemaVersion)) else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
    }

    private static let reasonCodesSQL = RuntimeExternalReasonCode.allSQLValues

    private struct RuntimeExternalSchemaCatalogEntry: Equatable {
        let type: String
        let sql: String
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

    private static func normalizeSQL(_ sql: String) -> String {
        sql.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    private static let compensationExternalOperationsTableV7 = """
        CREATE TABLE runtime_compensation_plan_external_operations (
            plan_id TEXT NOT NULL,
            operation_id TEXT NOT NULL,
            operation_version INTEGER NOT NULL CHECK (operation_version = 1),
            PRIMARY KEY (plan_id, operation_id),
            FOREIGN KEY (plan_id) REFERENCES runtime_compensation_plans(plan_id),
            FOREIGN KEY (operation_id) REFERENCES runtime_external_operation_creations(operation_id)
        ) WITHOUT ROWID
        """

    private static let compensationExternalBindingV7 = """
        CREATE TRIGGER runtime_compensation_plan_external_operations_bind_source
        BEFORE INSERT ON runtime_compensation_plan_external_operations
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1
                FROM runtime_compensation_plans AS p
                JOIN runtime_external_operation_creations AS o
                  ON o.operation_id = NEW.operation_id
                JOIN runtime_external_operation_current AS current
                  ON current.operation_id = o.operation_id
                WHERE p.plan_id = NEW.plan_id
                  AND o.receipt_id = p.source_receipt_id
                  AND o.terminal_event_sequence = p.source_event_sequence
                  AND current.workflow_status = 'pending'
                  AND current.effect_disposition = 'not_attempted'
                  AND current.status_version = 1
            ) THEN RAISE(ABORT, 'compensation external operation source mismatch') END;
        END
        """

    private static let receiptArtifactBindingV7 = """
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
                SELECT 1 FROM runtime_committed_receipt_cores AS c
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
                SELECT 1 FROM runtime_external_operation_creations AS o
                WHERE o.receipt_id = NEW.receipt_id
                  AND o.operation_id = NEW.artifact_id
                  AND o.creation_digest = NEW.artifact_digest
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
        """

    private static let receiptFinalizationBindingV7: String = {
        guard let source = CanonicalRuntimeCommittedReceiptSchemaPlan.statements.first(where: {
            schemaObjectName($0) == "runtime_command_idempotency_require_complete_receipt"
        }) else { return "" }
        let pendingStatePredicate = "o.status = 'pending'"
        let creationStatePredicate = """
        EXISTS (
                                      SELECT 1 FROM runtime_external_operation_current AS current
                                      WHERE current.operation_id = o.operation_id
                                        AND current.workflow_status = 'pending'
                                        AND current.effect_disposition = 'not_attempted'
                                        AND current.status_version = 1
                                        AND current.attempt_count = 0
                                  )
        """
        let replacements: [(String, String)] = [
            ("runtime_pending_external_operations AS o", "runtime_external_operation_creations AS o"),
            (pendingStatePredicate, creationStatePredicate),
            ("o.payload_checksum", "o.creation_digest"),
        ]
        var ported = source
        for (legacyClause, normalizedClause) in replacements {
            guard ported.contains(legacyClause) else { return "" }
            ported = ported.replacingOccurrences(of: legacyClause, with: normalizedClause)
        }
        guard ported.contains("runtime_pending_external_operations") == false,
              ported.contains("o.status") == false,
              ported.contains("o.payload_checksum") == false else { return "" }
        return ported
    }()

    private static var invariantTriggers: [String] {
        let immutable = [
            "runtime_external_operation_targets",
            "runtime_external_operation_history",
            "runtime_external_operation_attempt_starts",
            "runtime_external_operation_attempt_outcomes",
            "runtime_external_operation_transition_invalidations",
        ].flatMap { table in
            [
                "CREATE TRIGGER \(table)_immutable_update BEFORE UPDATE ON \(table) BEGIN SELECT RAISE(ABORT, 'immutable external operation authority'); END",
                "CREATE TRIGGER \(table)_immutable_delete BEFORE DELETE ON \(table) BEGIN SELECT RAISE(ABORT, 'immutable external operation authority'); END",
            ]
        }
        return immutable + [
            "CREATE TRIGGER runtime_external_operation_creations_immutable_update BEFORE UPDATE ON runtime_external_operation_creations BEGIN SELECT RAISE(ABORT, 'immutable external operation creation'); END",
            "CREATE TRIGGER runtime_external_operation_creations_immutable_delete BEFORE DELETE ON runtime_external_operation_creations BEGIN SELECT RAISE(ABORT, 'immutable external operation creation'); END",
            "CREATE TRIGGER runtime_external_operation_current_immutable_delete BEFORE DELETE ON runtime_external_operation_current BEGIN SELECT RAISE(ABORT, 'immutable external operation authority'); END",
            """
            CREATE TRIGGER runtime_external_operation_current_fenced_transition
            BEFORE UPDATE ON runtime_external_operation_current
            BEGIN
                SELECT CASE WHEN OLD.workflow_status IN ('succeeded','permanent_failure','operator_required','cancelled')
                    THEN RAISE(ABORT, 'terminal external operation is immutable') END;
                SELECT CASE WHEN NEW.operation_id <> OLD.operation_id
                    OR NEW.creation_digest <> OLD.creation_digest
                    OR NEW.provider_id <> OLD.provider_id
                    OR NEW.policy_version <> OLD.policy_version
                    OR NEW.created_at_ms <> OLD.created_at_ms
                    OR NEW.status_version <> OLD.status_version + 1
                    OR NEW.updated_at_ms < OLD.updated_at_ms
                    THEN RAISE(ABORT, 'invalid external operation fence') END;
                SELECT CASE WHEN NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_history AS h
                    WHERE h.operation_id = NEW.operation_id
                      AND h.status_version = NEW.status_version
                      AND h.from_state_digest = OLD.state_digest
                      AND h.to_state_digest = NEW.state_digest
                      AND h.to_workflow_status = NEW.workflow_status
                      AND h.to_effect_disposition = NEW.effect_disposition
                      AND h.occurred_at_ms = NEW.updated_at_ms
                ) THEN RAISE(ABORT, 'missing external transition history') END;
                SELECT CASE WHEN NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_transition_invalidations AS i
                    JOIN runtime_external_operation_history AS h ON h.history_id = i.history_id
                    WHERE i.operation_id = NEW.operation_id
                      AND i.status_version = NEW.status_version
                      AND h.from_state_digest = OLD.state_digest
                      AND h.to_state_digest = NEW.state_digest
                ) THEN RAISE(ABORT, 'missing external transition invalidation') END;
            END
            """,
            """
            CREATE TRIGGER runtime_external_operation_history_bind_current
            BEFORE INSERT ON runtime_external_operation_history
            WHEN NEW.status_version > 1
            BEGIN
                SELECT CASE WHEN NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_current AS c
                    WHERE c.operation_id = NEW.operation_id
                      AND c.status_version = NEW.status_version - 1
                      AND c.workflow_status = NEW.from_workflow_status
                      AND c.effect_disposition = NEW.from_effect_disposition
                      AND c.state_digest = NEW.from_state_digest
                ) THEN RAISE(ABORT, 'external transition source mismatch') END;
            END
            """,
            """
            CREATE TRIGGER runtime_external_operation_initial_history_bind_current
            BEFORE INSERT ON runtime_external_operation_history
            WHEN NEW.status_version = 1
            BEGIN
                SELECT CASE WHEN NEW.from_workflow_status IS NOT NULL
                    OR NEW.from_effect_disposition IS NOT NULL
                    OR NEW.from_state_digest IS NOT NULL
                    OR NEW.attempt_id IS NOT NULL
                    OR NOT EXISTS (
                        SELECT 1 FROM runtime_external_operation_current AS c
                        WHERE c.operation_id = NEW.operation_id
                          AND c.status_version = 1
                          AND c.workflow_status = NEW.to_workflow_status
                          AND c.effect_disposition = NEW.to_effect_disposition
                          AND c.state_digest = NEW.to_state_digest
                          AND c.created_at_ms = NEW.occurred_at_ms
                          AND c.updated_at_ms = NEW.occurred_at_ms
                    )
                THEN RAISE(ABORT, 'invalid initial external history') END;
            END
            """,
            """
            CREATE TRIGGER runtime_external_operation_attempt_start_bind_current
            BEFORE INSERT ON runtime_external_operation_attempt_starts
            BEGIN
                SELECT CASE WHEN NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_current AS c
                    JOIN runtime_external_operation_creations AS d ON d.operation_id = c.operation_id
                    WHERE c.operation_id = NEW.operation_id
                      AND c.status_version = NEW.source_status_version
                      AND c.attempt_count + 1 = NEW.attempt_number
                      AND c.lease_token = NEW.lease_token
                      AND c.lease_owner = NEW.lease_owner
                      AND c.lease_acquired_at_ms = NEW.lease_acquired_at_ms
                      AND c.lease_expires_at_ms = NEW.lease_expires_at_ms
                      AND c.claim_purpose = NEW.purpose
                      AND d.operation_action = NEW.operation_action
                      AND d.provider_id = NEW.provider_id
                      AND d.operation_kind = NEW.operation_kind
                      AND d.stable_idempotency_key = NEW.stable_idempotency_key
                ) THEN RAISE(ABORT, 'external attempt fence mismatch') END;
            END
            """,
            """
            CREATE TRIGGER runtime_external_operation_attempt_outcome_bind_start
            BEFORE INSERT ON runtime_external_operation_attempt_outcomes
            BEGIN
                SELECT CASE WHEN NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_attempt_starts AS a
                    JOIN runtime_external_operation_creations AS c ON c.operation_id = a.operation_id
                    WHERE a.attempt_id = NEW.attempt_id AND a.operation_id = NEW.operation_id
                      AND a.operation_action = c.operation_action
                      AND (
                          (c.operation_action = 'create' AND a.purpose = 'execute'
                           AND NEW.outcome_kind IN (
                              'confirmed_success','rejected_before_effect',
                              'retryable_before_effect','permission_unavailable_before_effect',
                              'indeterminate','lease_expired_without_outcome'
                           )) OR
                          (c.operation_action = 'create' AND a.purpose = 'reconcile'
                           AND NEW.outcome_kind IN (
                              'confirmed_presence','confirmed_absence',
                              'ambiguous_reconciliation','incompatible_provider_state',
                              'lease_expired_without_outcome'
                           )) OR
                          (c.operation_action = 'compensate_removal' AND a.purpose = 'execute'
                           AND NEW.outcome_kind IN (
                              'confirmed_cancellation','cancellation_retryable_before_effect',
                              'cancellation_unsupported','permission_unavailable_before_effect',
                              'indeterminate','lease_expired_without_outcome'
                           )) OR
                          (c.operation_action = 'compensate_removal' AND a.purpose = 'reconcile'
                           AND NEW.outcome_kind IN (
                              'cancellation_source_still_present','reconciled_cancellation_absent',
                              'ambiguous_reconciliation','incompatible_provider_state',
                              'lease_expired_without_outcome'
                           ))
                      )
                      AND NEW.recorded_at_ms >= a.started_at_ms
                      AND ((NEW.outcome_kind = 'lease_expired_without_outcome' AND NEW.recorded_at_ms >= a.lease_expires_at_ms)
                        OR (NEW.outcome_kind <> 'lease_expired_without_outcome' AND NEW.recorded_at_ms <= a.lease_expires_at_ms))
                ) THEN RAISE(ABORT, 'external attempt outcome mismatch') END;
            END
            """,
            """
            CREATE TRIGGER runtime_external_operation_invalidation_bind_history
            BEFORE INSERT ON runtime_external_operation_transition_invalidations
            BEGIN
                SELECT CASE WHEN NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_history AS h
                    WHERE h.history_id = NEW.history_id
                      AND h.operation_id = NEW.operation_id
                      AND h.status_version = NEW.status_version
                      AND h.transition_payload = NEW.payload
                      AND h.transition_payload_digest = NEW.payload_digest
                      AND h.occurred_at_ms = NEW.created_at_ms
                ) THEN RAISE(ABORT, 'external invalidation history mismatch') END;
            END
            """,
            creationInsertSeal,
            creationAuthorityBinding,
            targetInsertSeal,
            currentInsertSeal,
            creationMaximum,
            targetMaximum,
            initialCurrentBinding,
            finalizedGraphBinding,
        ]
    }

    private static let creationInsertSeal = """
        CREATE TRIGGER runtime_external_operation_creations_reject_insert_after_finalization
        BEFORE INSERT ON runtime_external_operation_creations
        WHEN EXISTS (
            SELECT 1 FROM runtime_command_idempotency
            WHERE command_id = NEW.command_id AND final_result_version IS NOT NULL
        ) OR EXISTS (
            SELECT 1 FROM runtime_commit_receipts AS r
            JOIN runtime_command_idempotency AS i ON i.command_id = r.command_id
            WHERE r.receipt_id = NEW.receipt_id AND i.final_result_version IS NOT NULL
        )
        BEGIN SELECT RAISE(ABORT, 'finalized external creation graph is sealed'); END
        """

    private static let creationAuthorityBinding = """
        CREATE TRIGGER runtime_external_operation_creations_bind_receipt_command_event
        BEFORE INSERT ON runtime_external_operation_creations
        BEGIN
            SELECT CASE WHEN NOT EXISTS (
                SELECT 1 FROM runtime_commit_receipts AS r
                JOIN runtime_semantic_events AS e ON e.sequence = r.terminal_event_sequence
                WHERE r.receipt_id = NEW.receipt_id
                  AND r.command_id = NEW.command_id
                  AND r.terminal_event_sequence = NEW.terminal_event_sequence
                  AND r.created_at_ms = NEW.created_at_ms
                  AND e.command_id = NEW.command_id
            ) THEN RAISE(ABORT, 'external creation authority mismatch') END;
            SELECT CASE WHEN NEW.operation_action = 'compensate_removal' AND NOT EXISTS (
                SELECT 1 FROM runtime_external_operation_creations AS source
                JOIN runtime_external_operation_current AS source_current
                  ON source_current.operation_id = source.operation_id
                JOIN runtime_compensation_plans AS plan
                  ON plan.plan_id = NEW.compensation_plan_id
                JOIN runtime_compensation_plan_external_operations AS planned
                  ON planned.plan_id = plan.plan_id AND planned.operation_id = source.operation_id
                WHERE source.operation_id = NEW.source_operation_id
                  AND source.receipt_id = NEW.source_receipt_id
                  AND source.operation_kind = NEW.operation_kind
                  AND source.provider_id = NEW.provider_id
                  AND source.privacy = NEW.privacy
                  AND source.local_only = NEW.local_only
                  AND source_current.workflow_status = 'succeeded'
                  AND source_current.effect_disposition = 'confirmed_present'
                  AND source_current.external_reference = NEW.source_provider_reference
                  AND plan.source_receipt_id = NEW.source_receipt_id
                  AND plan.plan_digest = NEW.compensation_plan_digest
                  AND plan.expires_at_ms >= NEW.created_at_ms
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_compensation_consumptions AS consumed
                      WHERE consumed.plan_id = plan.plan_id
                         OR consumed.source_receipt_id = plan.source_receipt_id
                  )
            ) THEN RAISE(ABORT, 'external compensation relation mismatch') END;
        END
        """

    private static let targetInsertSeal = """
        CREATE TRIGGER runtime_external_operation_targets_reject_insert_after_finalization
        BEFORE INSERT ON runtime_external_operation_targets
        BEGIN
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM runtime_external_operation_creations AS o
                JOIN runtime_command_idempotency AS i ON i.command_id = o.command_id
                WHERE o.operation_id = NEW.operation_id AND i.final_result_version IS NOT NULL
            ) THEN RAISE(ABORT, 'finalized external creation is sealed') END;
        END
        """

    private static let currentInsertSeal = """
        CREATE TRIGGER runtime_external_operation_current_reject_insert_after_finalization
        BEFORE INSERT ON runtime_external_operation_current
        BEGIN
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM runtime_external_operation_creations AS o
                JOIN runtime_command_idempotency AS i ON i.command_id = o.command_id
                WHERE o.operation_id = NEW.operation_id AND i.final_result_version IS NOT NULL
            ) THEN RAISE(ABORT, 'finalized external creation is sealed') END;
        END
        """

    private static let creationMaximum = """
        CREATE TRIGGER runtime_external_operation_creations_maximum_per_receipt
        BEFORE INSERT ON runtime_external_operation_creations
        WHEN (SELECT COUNT(*) FROM runtime_external_operation_creations
              WHERE receipt_id = NEW.receipt_id) >= \(RuntimeExternalOperationLimits.maximumOperationsPerReceipt)
        BEGIN SELECT RAISE(ABORT, 'too many external operations for receipt'); END
        """

    private static let targetMaximum = """
        CREATE TRIGGER runtime_external_operation_targets_maximum
        BEFORE INSERT ON runtime_external_operation_targets
        WHEN (SELECT COUNT(*) FROM runtime_external_operation_targets
              WHERE operation_id = NEW.operation_id) >= \(RuntimeExternalOperationLimits.maximumTargets)
        BEGIN SELECT RAISE(ABORT, 'too many external operation targets'); END
        """

    private static let initialCurrentBinding = """
        CREATE TRIGGER runtime_external_operation_current_bind_creation
        BEFORE INSERT ON runtime_external_operation_current
        BEGIN
            SELECT CASE WHEN NEW.workflow_status <> 'pending'
                OR NEW.effect_disposition <> 'not_attempted'
                OR NEW.status_version <> 1 OR NEW.attempt_count <> 0
                OR NEW.next_attempt_at_ms IS NOT NULL OR NEW.claim_purpose IS NOT NULL
                OR NEW.lease_token IS NOT NULL OR NEW.external_reference IS NOT NULL
                OR NEW.reason_code IS NOT NULL OR NOT EXISTS (
                    SELECT 1 FROM runtime_external_operation_creations AS c
                    WHERE c.operation_id = NEW.operation_id
                      AND c.creation_digest = NEW.creation_digest
                      AND c.provider_id = NEW.provider_id
                      AND c.policy_version = NEW.policy_version
                      AND c.created_at_ms = NEW.created_at_ms
                      AND c.created_at_ms = NEW.updated_at_ms
                ) THEN RAISE(ABORT, 'invalid initial external operation current state') END;
        END
        """

    private static let finalizedGraphBinding = """
        CREATE TRIGGER runtime_command_idempotency_require_external_operation_graph_v7
        BEFORE UPDATE OF final_result_version ON runtime_command_idempotency
        WHEN OLD.final_result_version IS NULL AND NEW.final_result_version IS NOT NULL
        BEGIN
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM runtime_external_operation_creations AS c
                WHERE c.command_id = NEW.command_id AND (
                    NOT EXISTS (SELECT 1 FROM runtime_external_operation_targets AS t
                                WHERE t.operation_id = c.operation_id)
                    OR NOT EXISTS (
                        SELECT 1 FROM runtime_external_operation_current AS s
                        WHERE s.operation_id = c.operation_id
                          AND s.workflow_status = 'pending'
                          AND s.effect_disposition = 'not_attempted'
                          AND s.status_version = 1 AND s.attempt_count = 0
                    )
                    OR 1 <> (SELECT COUNT(*) FROM runtime_external_operation_history AS h
                              WHERE h.operation_id = c.operation_id
                                AND h.status_version = 1
                                AND h.from_state_digest IS NULL
                                AND h.to_workflow_status = 'pending'
                                AND h.to_effect_disposition = 'not_attempted')
                    OR EXISTS (SELECT 1 FROM runtime_external_operation_history AS h
                               WHERE h.operation_id = c.operation_id AND h.status_version <> 1)
                    OR EXISTS (SELECT 1 FROM runtime_external_operation_attempt_starts AS a
                               WHERE a.operation_id = c.operation_id)
                    OR EXISTS (SELECT 1 FROM runtime_external_operation_attempt_outcomes AS o
                               WHERE o.operation_id = c.operation_id)
                    OR EXISTS (SELECT 1 FROM runtime_external_operation_transition_invalidations AS i
                               WHERE i.operation_id = c.operation_id)
                )
            ) THEN RAISE(ABORT, 'incomplete external operation creation graph') END;
        END
        """

}

private extension RuntimeExternalReasonCode {
    static var allSQLValues: String {
        [
            providerRejected, retryableBeforeEffect, permissionUnavailableBeforeEffect,
            indeterminateAfterInvocation, reconciliationAbsent, reconciliationAmbiguous,
            incompatibleProviderState, providerCancellationUnsupported, retryLimitReached,
            leaseExpiredAfterAttemptStart, transitionBudgetExhausted, cancelledBeforeEffect,
        ].map { "'\($0.rawValue)'" }.joined(separator: ",")
    }
}
