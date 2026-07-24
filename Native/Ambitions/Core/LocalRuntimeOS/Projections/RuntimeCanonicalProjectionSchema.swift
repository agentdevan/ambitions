import AmbitionsRuntimeSQLite
import Foundation

let runtimeCanonicalProjectionSchemaVersion = 5

enum CanonicalRuntimeProjectionSchemaPlan {
    static let sourceSchemaVersion = runtimeCanonicalReplaySchemaVersion
    static let targetSchemaVersion = runtimeCanonicalProjectionSchemaVersion
    static let tables: Set<String> = [
        "runtime_canonical_replay_verification_certificates",
        "runtime_canonical_projection_generations",
        "runtime_canonical_projection_entries",
        "runtime_canonical_projection_shards",
        "runtime_canonical_projection_active_generations",
        "runtime_canonical_projection_jobs",
        "runtime_canonical_projection_leases",
        "runtime_canonical_projection_invalidation_acks",
        "runtime_canonical_projection_quarantine",
        "runtime_canonical_search_generations",
        "runtime_canonical_search_documents",
        "runtime_canonical_search_postings",
        "runtime_canonical_search_shards",
        "runtime_canonical_search_active_generation",
        "runtime_canonical_generation_gc_jobs",
        "runtime_canonical_generation_scrub_jobs",
        "runtime_canonical_scrub_certificates",
        "runtime_canonical_build_cleanup_jobs",
        "runtime_canonical_repair_requirements",
        "runtime_canonical_repair_incidents",
        "runtime_canonical_scheduler_state",
    ]

    static let indexes: Set<String> = [
        "runtime_commit_projection_invalidations_lineage_idx",
        "runtime_canonical_projection_generations_cursor_idx",
        "runtime_canonical_projection_entries_order_idx",
        "runtime_canonical_projection_jobs_phase_idx",
        "runtime_canonical_projection_acks_invalidation_idx",
        "runtime_canonical_search_documents_filter_idx",
        "runtime_canonical_search_postings_lookup_idx",
        "runtime_canonical_generation_gc_jobs_phase_idx",
        "runtime_canonical_generation_scrub_jobs_phase_idx",
        "runtime_canonical_search_postings_document_idx",
        "runtime_canonical_projection_acks_generation_idx",
        "runtime_canonical_projection_quarantine_generation_idx",
        "runtime_canonical_generation_gc_jobs_eligibility_idx",
        "runtime_canonical_generation_scrub_jobs_eligibility_idx",
        "runtime_semantic_events_payload_version_idx",
        "runtime_canonical_build_cleanup_jobs_eligibility_idx",
        "runtime_canonical_repair_requirements_projection_idx",
        "runtime_canonical_scrub_certificates_projection_idx",
    ]

    static let statements: [String] = [
        "CREATE UNIQUE INDEX runtime_commit_projection_invalidations_lineage_idx ON runtime_commit_projection_invalidations(projection_id, terminal_event_sequence)",
        """
        CREATE TRIGGER runtime_commit_projection_invalidations_immutable_update
        BEFORE UPDATE ON runtime_commit_projection_invalidations
        BEGIN SELECT RAISE(ABORT, 'immutable projection invalidation'); END
        """,
        """
        CREATE TRIGGER runtime_commit_projection_invalidations_immutable_delete
        BEFORE DELETE ON runtime_commit_projection_invalidations
        BEGIN SELECT RAISE(ABORT, 'immutable projection invalidation'); END
        """,
        "CREATE INDEX runtime_semantic_events_payload_version_idx ON runtime_semantic_events(payload_version, sequence)",
        """
        CREATE TABLE runtime_canonical_replay_verification_certificates (
            event_sequence INTEGER PRIMARY KEY CHECK (event_sequence > 0),
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            source_chain_digest TEXT NOT NULL CHECK (length(source_chain_digest) = 64 AND source_chain_digest NOT GLOB '*[^0-9a-f]*'),
            reconstruction_digest TEXT NOT NULL CHECK (length(reconstruction_digest) = 64 AND reconstruction_digest NOT GLOB '*[^0-9a-f]*'),
            verified_at_ms INTEGER NOT NULL CHECK (verified_at_ms >= 0),
            certificate_digest TEXT NOT NULL UNIQUE CHECK (length(certificate_digest) = 64 AND certificate_digest NOT GLOB '*[^0-9a-f]*'),
            FOREIGN KEY (event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TRIGGER runtime_canonical_replay_verification_certificates_immutable_update
        BEFORE UPDATE ON runtime_canonical_replay_verification_certificates
        BEGIN SELECT RAISE(ABORT, 'immutable replay verification certificate'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_replay_verification_certificates_immutable_delete
        BEFORE DELETE ON runtime_canonical_replay_verification_certificates
        BEGIN SELECT RAISE(ABORT, 'immutable replay verification certificate'); END
        """,
        """
        CREATE TABLE runtime_canonical_projection_generations (
            generation_id TEXT PRIMARY KEY CHECK (length(generation_id) = 64 AND generation_id NOT GLOB '*[^0-9a-f]*'),
            projection_id TEXT NOT NULL CHECK (length(projection_id) > 0),
            definition_version INTEGER NOT NULL CHECK (definition_version > 0),
            definition_digest TEXT NOT NULL CHECK (length(definition_digest) = 64 AND definition_digest NOT GLOB '*[^0-9a-f]*'),
            output_version INTEGER NOT NULL CHECK (output_version > 0),
            source_sequence INTEGER NOT NULL CHECK (source_sequence >= 0),
            source_event_id TEXT NOT NULL CHECK (length(source_event_id) > 0),
            source_event_hash TEXT NOT NULL CHECK (length(source_event_hash) = 64 AND source_event_hash NOT GLOB '*[^0-9a-f]*'),
            source_chain_digest TEXT NOT NULL CHECK (length(source_chain_digest) = 64 AND source_chain_digest NOT GLOB '*[^0-9a-f]*'),
            first_invalidation_id TEXT NOT NULL CHECK (length(first_invalidation_id) > 0),
            last_invalidation_id TEXT NOT NULL CHECK (length(last_invalidation_id) > 0),
            invalidation_digest TEXT NOT NULL CHECK (length(invalidation_digest) = 64 AND invalidation_digest NOT GLOB '*[^0-9a-f]*'),
            entry_count INTEGER NOT NULL CHECK (entry_count >= 0),
            shard_count INTEGER NOT NULL CHECK (shard_count >= 0),
            entry_root_digest TEXT NOT NULL CHECK (length(entry_root_digest) = 64 AND entry_root_digest NOT GLOB '*[^0-9a-f]*'),
            privacy TEXT NOT NULL,
            local_only INTEGER NOT NULL CHECK (local_only IN (0, 1)),
            status TEXT NOT NULL CHECK (status IN ('building', 'sealed', 'published', 'retired', 'abandoned')),
            generation_certificate_digest TEXT CHECK (generation_certificate_digest IS NULL OR (length(generation_certificate_digest) = 64 AND generation_certificate_digest NOT GLOB '*[^0-9a-f]*')),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            sealed_at_ms INTEGER CHECK (sealed_at_ms IS NULL OR sealed_at_ms >= created_at_ms),
            CHECK ((status IN ('sealed', 'published', 'retired')) = (generation_certificate_digest IS NOT NULL))
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_projection_generations_cursor_idx ON runtime_canonical_projection_generations(projection_id, source_sequence, status, generation_id)",
        """
        CREATE TABLE runtime_canonical_projection_entries (
            generation_id TEXT NOT NULL,
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            revision INTEGER NOT NULL CHECK (revision >= 0),
            lifecycle TEXT NOT NULL CHECK (length(lifecycle) > 0),
            canonical_state_bytes BLOB NOT NULL CHECK (length(canonical_state_bytes) <= 1048576),
            canonical_state_digest TEXT NOT NULL CHECK (length(canonical_state_digest) = 64 AND canonical_state_digest NOT GLOB '*[^0-9a-f]*'),
            privacy TEXT NOT NULL CHECK (length(privacy) > 0),
            local_only INTEGER NOT NULL CHECK (local_only IN (0, 1)),
            source_sequence INTEGER NOT NULL CHECK (source_sequence > 0),
            source_event_id TEXT NOT NULL CHECK (length(source_event_id) > 0),
            source_event_hash TEXT NOT NULL CHECK (length(source_event_hash) = 64 AND source_event_hash NOT GLOB '*[^0-9a-f]*'),
            entry_digest TEXT NOT NULL CHECK (length(entry_digest) = 64 AND entry_digest NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (generation_id, aggregate_kind, aggregate_id),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_projection_generations(generation_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_projection_entries_order_idx ON runtime_canonical_projection_entries(generation_id, aggregate_kind, aggregate_id)",
        """
        CREATE TABLE runtime_canonical_projection_shards (
            generation_id TEXT NOT NULL,
            shard_ordinal INTEGER NOT NULL CHECK (shard_ordinal >= 0),
            first_aggregate_kind TEXT NOT NULL,
            first_aggregate_id TEXT NOT NULL,
            last_aggregate_kind TEXT NOT NULL,
            last_aggregate_id TEXT NOT NULL,
            entry_count INTEGER NOT NULL CHECK (entry_count > 0 AND entry_count <= 128),
            prior_shard_digest TEXT NOT NULL CHECK (length(prior_shard_digest) = 64 AND prior_shard_digest NOT GLOB '*[^0-9a-f]*'),
            shard_digest TEXT NOT NULL CHECK (length(shard_digest) = 64 AND shard_digest NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (generation_id, shard_ordinal),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_projection_generations(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_canonical_projection_active_generations (
            projection_id TEXT PRIMARY KEY,
            generation_id TEXT NOT NULL UNIQUE,
            generation_certificate_digest TEXT NOT NULL UNIQUE CHECK (length(generation_certificate_digest) = 64 AND generation_certificate_digest NOT GLOB '*[^0-9a-f]*'),
            activated_at_ms INTEGER NOT NULL CHECK (activated_at_ms >= 0),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_projection_generations(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_active_generation_valid_insert
        BEFORE INSERT ON runtime_canonical_projection_active_generations
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = NEW.generation_id
              AND generation.projection_id = NEW.projection_id
              AND generation.status = 'published'
              AND generation.generation_certificate_digest = NEW.generation_certificate_digest
        )
        BEGIN SELECT RAISE(ABORT, 'invalid active projection generation'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_active_generation_valid_update
        BEFORE UPDATE ON runtime_canonical_projection_active_generations
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = NEW.generation_id
              AND generation.projection_id = NEW.projection_id
              AND generation.status = 'published'
              AND generation.generation_certificate_digest = NEW.generation_certificate_digest
        )
        BEGIN SELECT RAISE(ABORT, 'invalid active projection generation'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_active_generation_protected_delete
        BEFORE DELETE ON runtime_canonical_projection_active_generations
        BEGIN SELECT RAISE(ABORT, 'active projection authority cannot be deleted'); END
        """,
        """
        CREATE TABLE runtime_canonical_projection_jobs (
            projection_id TEXT PRIMARY KEY,
            generation_id TEXT NOT NULL UNIQUE,
            phase TEXT NOT NULL CHECK (phase IN ('clone', 'replay', 'seal_projection', 'index_search', 'seal_search', 'ready', 'recovering', 'blocked')),
            blocked_reason_code TEXT,
            base_generation_id TEXT,
            base_certificate_digest TEXT,
            base_root_digest TEXT,
            base_entry_count INTEGER CHECK (base_entry_count IS NULL OR base_entry_count >= 0),
            base_scrub_certificate_digest TEXT CHECK (base_scrub_certificate_digest IS NULL OR (length(base_scrub_certificate_digest) = 64 AND base_scrub_certificate_digest NOT GLOB '*[^0-9a-f]*')),
            base_scrub_completed_at_ms INTEGER CHECK (base_scrub_completed_at_ms IS NULL OR base_scrub_completed_at_ms >= 0),
            target_sequence INTEGER NOT NULL CHECK (target_sequence > 0),
            target_event_id TEXT NOT NULL,
            target_event_hash TEXT NOT NULL CHECK (length(target_event_hash) = 64 AND target_event_hash NOT GLOB '*[^0-9a-f]*'),
            progress_sequence INTEGER NOT NULL CHECK (progress_sequence >= 0 AND progress_sequence <= target_sequence),
            progress_event_id TEXT,
            progress_event_hash TEXT,
            progress_source_digest TEXT NOT NULL CHECK (length(progress_source_digest) = 64 AND progress_source_digest NOT GLOB '*[^0-9a-f]*'),
            after_aggregate_kind TEXT NOT NULL,
            after_aggregate_id TEXT NOT NULL,
            shard_ordinal INTEGER NOT NULL CHECK (shard_ordinal >= 0),
            rolling_root_digest TEXT NOT NULL CHECK (length(rolling_root_digest) = 64 AND rolling_root_digest NOT GLOB '*[^0-9a-f]*'),
            entry_count INTEGER NOT NULL CHECK (entry_count >= 0),
            sealed_entry_count INTEGER NOT NULL CHECK (sealed_entry_count >= 0 AND sealed_entry_count <= entry_count),
            privacy_standard_count INTEGER NOT NULL CHECK (privacy_standard_count >= 0),
            privacy_sensitive_count INTEGER NOT NULL CHECK (privacy_sensitive_count >= 0),
            privacy_private_text_count INTEGER NOT NULL CHECK (privacy_private_text_count >= 0),
            privacy_calendar_count INTEGER NOT NULL CHECK (privacy_calendar_count >= 0),
            privacy_sync_count INTEGER NOT NULL CHECK (privacy_sync_count >= 0),
            nonlocal_entry_count INTEGER NOT NULL CHECK (nonlocal_entry_count >= 0 AND nonlocal_entry_count <= entry_count),
            search_document_count INTEGER NOT NULL CHECK (search_document_count >= 0),
            sealed_search_document_count INTEGER NOT NULL CHECK (sealed_search_document_count >= 0 AND sealed_search_document_count <= search_document_count),
            search_posting_count INTEGER NOT NULL CHECK (search_posting_count >= 0),
            search_posting_bytes INTEGER NOT NULL CHECK (search_posting_bytes >= 0),
            first_invalidation_id TEXT NOT NULL,
            last_invalidation_id TEXT NOT NULL,
            invalidation_digest TEXT NOT NULL CHECK (length(invalidation_digest) = 64 AND invalidation_digest NOT GLOB '*[^0-9a-f]*'),
            owner_id TEXT NOT NULL,
            fence_version INTEGER NOT NULL CHECK (fence_version > 0),
            service_ticket INTEGER NOT NULL CHECK (service_ticket >= 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_projection_generations(generation_id)
            ,CHECK ((progress_sequence = 0) = (progress_event_id IS NULL))
            ,CHECK ((progress_sequence = 0) = (progress_event_hash IS NULL))
            ,CHECK ((phase = 'blocked') = (blocked_reason_code IS NOT NULL))
            ,CHECK ((base_generation_id IS NULL) = (base_certificate_digest IS NULL))
            ,CHECK ((base_generation_id IS NULL) = (base_root_digest IS NULL))
            ,CHECK ((base_generation_id IS NULL) = (base_entry_count IS NULL))
            ,CHECK ((base_generation_id IS NULL) = (base_scrub_certificate_digest IS NULL))
            ,CHECK ((base_generation_id IS NULL) = (base_scrub_completed_at_ms IS NULL))
            ,CHECK (privacy_standard_count + privacy_sensitive_count
                + privacy_private_text_count + privacy_calendar_count
                + privacy_sync_count = entry_count)
            ,CHECK (search_document_count <= entry_count)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_projection_jobs_phase_idx ON runtime_canonical_projection_jobs(phase, projection_id)",
        """
        CREATE TABLE runtime_canonical_projection_leases (
            projection_id TEXT PRIMARY KEY,
            owner_id TEXT NOT NULL,
            lease_version INTEGER NOT NULL CHECK (lease_version > 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_canonical_projection_invalidation_acks (
            projection_id TEXT NOT NULL,
            invalidation_id TEXT NOT NULL,
            generation_id TEXT NOT NULL,
            source_sequence INTEGER NOT NULL CHECK (source_sequence > 0),
            generation_certificate_digest TEXT NOT NULL CHECK (length(generation_certificate_digest) = 64 AND generation_certificate_digest NOT GLOB '*[^0-9a-f]*'),
            acknowledged_at_ms INTEGER NOT NULL CHECK (acknowledged_at_ms >= 0),
            PRIMARY KEY (projection_id, invalidation_id),
            FOREIGN KEY (invalidation_id) REFERENCES runtime_commit_projection_invalidations(invalidation_id),
            CHECK (length(generation_id) = 64 AND generation_id NOT GLOB '*[^0-9a-f]*')
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_projection_acks_invalidation_idx ON runtime_canonical_projection_invalidation_acks(invalidation_id, projection_id)",
        "CREATE INDEX runtime_canonical_projection_acks_generation_idx ON runtime_canonical_projection_invalidation_acks(projection_id, generation_id, invalidation_id)",
        """
        CREATE TABLE runtime_canonical_projection_quarantine (
            quarantine_id TEXT PRIMARY KEY CHECK (length(quarantine_id) = 64 AND quarantine_id NOT GLOB '*[^0-9a-f]*'),
            projection_id TEXT NOT NULL,
            generation_id TEXT,
            artifact_kind TEXT NOT NULL,
            artifact_id TEXT NOT NULL,
            artifact_digest TEXT,
            reason_code TEXT NOT NULL,
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_projection_quarantine_generation_idx ON runtime_canonical_projection_quarantine(generation_id, reason_code)",
        """
        CREATE TABLE runtime_canonical_search_generations (
            generation_id TEXT PRIMARY KEY CHECK (length(generation_id) = 64 AND generation_id NOT GLOB '*[^0-9a-f]*'),
            projection_generation_id TEXT NOT NULL UNIQUE,
            coverage TEXT NOT NULL CHECK (coverage = 'aggregate_metadata_only'),
            definition_digest TEXT NOT NULL CHECK (length(definition_digest) = 64 AND definition_digest NOT GLOB '*[^0-9a-f]*'),
            source_sequence INTEGER NOT NULL CHECK (source_sequence >= 0),
            source_event_hash TEXT NOT NULL CHECK (length(source_event_hash) = 64 AND source_event_hash NOT GLOB '*[^0-9a-f]*'),
            document_count INTEGER NOT NULL CHECK (document_count >= 0),
            posting_count INTEGER NOT NULL CHECK (posting_count >= 0),
            posting_bytes INTEGER NOT NULL CHECK (posting_bytes >= 0),
            shard_count INTEGER NOT NULL CHECK (shard_count >= 0),
            document_root_digest TEXT NOT NULL CHECK (length(document_root_digest) = 64 AND document_root_digest NOT GLOB '*[^0-9a-f]*'),
            status TEXT NOT NULL CHECK (status IN ('building', 'sealed', 'published', 'retired', 'abandoned')),
            generation_certificate_digest TEXT CHECK (generation_certificate_digest IS NULL OR (length(generation_certificate_digest) = 64 AND generation_certificate_digest NOT GLOB '*[^0-9a-f]*')),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (projection_generation_id) REFERENCES runtime_canonical_projection_generations(generation_id),
            CHECK ((status IN ('sealed', 'published', 'retired')) = (generation_certificate_digest IS NOT NULL))
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_canonical_search_documents (
            generation_id TEXT NOT NULL,
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            privacy TEXT NOT NULL,
            local_only INTEGER NOT NULL CHECK (local_only IN (0, 1)),
            title TEXT NOT NULL CHECK (length(CAST(title AS BLOB)) <= 16384),
            body TEXT NOT NULL CHECK (length(CAST(body AS BLOB)) <= 16384),
            source_sequence INTEGER NOT NULL CHECK (source_sequence > 0),
            source_event_id TEXT NOT NULL,
            source_event_hash TEXT NOT NULL CHECK (length(source_event_hash) = 64 AND source_event_hash NOT GLOB '*[^0-9a-f]*'),
            document_digest TEXT NOT NULL CHECK (length(document_digest) = 64 AND document_digest NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (generation_id, aggregate_kind, aggregate_id),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_search_generations(generation_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_search_documents_filter_idx ON runtime_canonical_search_documents(generation_id, privacy, local_only, aggregate_kind, aggregate_id)",
        """
        CREATE TABLE runtime_canonical_search_postings (
            generation_id TEXT NOT NULL,
            normalized_token TEXT NOT NULL CHECK (length(CAST(normalized_token AS BLOB)) > 0 AND length(CAST(normalized_token AS BLOB)) <= 128),
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            field_ordinal INTEGER NOT NULL CHECK (field_ordinal IN (0, 1)),
            token_ordinal INTEGER NOT NULL CHECK (token_ordinal >= 0 AND token_ordinal < 64),
            posting_digest TEXT NOT NULL CHECK (length(posting_digest) = 64 AND posting_digest NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (generation_id, normalized_token, aggregate_kind, aggregate_id, field_ordinal, token_ordinal),
            FOREIGN KEY (generation_id, aggregate_kind, aggregate_id)
                REFERENCES runtime_canonical_search_documents(generation_id, aggregate_kind, aggregate_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_search_postings_lookup_idx ON runtime_canonical_search_postings(generation_id, normalized_token, aggregate_kind, aggregate_id)",
        "CREATE INDEX runtime_canonical_search_postings_document_idx ON runtime_canonical_search_postings(generation_id, aggregate_kind, aggregate_id, field_ordinal, token_ordinal)",
        """
        CREATE TABLE runtime_canonical_search_shards (
            generation_id TEXT NOT NULL,
            shard_ordinal INTEGER NOT NULL CHECK (shard_ordinal >= 0),
            first_aggregate_kind TEXT NOT NULL,
            first_aggregate_id TEXT NOT NULL,
            last_aggregate_kind TEXT NOT NULL,
            last_aggregate_id TEXT NOT NULL,
            document_count INTEGER NOT NULL CHECK (document_count > 0 AND document_count <= 128),
            prior_shard_digest TEXT NOT NULL CHECK (length(prior_shard_digest) = 64 AND prior_shard_digest NOT GLOB '*[^0-9a-f]*'),
            shard_digest TEXT NOT NULL CHECK (length(shard_digest) = 64 AND shard_digest NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (generation_id, shard_ordinal),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_search_generations(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_canonical_search_active_generation (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            generation_id TEXT NOT NULL UNIQUE,
            generation_certificate_digest TEXT NOT NULL UNIQUE CHECK (length(generation_certificate_digest) = 64 AND generation_certificate_digest NOT GLOB '*[^0-9a-f]*'),
            activated_at_ms INTEGER NOT NULL CHECK (activated_at_ms >= 0),
            FOREIGN KEY (generation_id) REFERENCES runtime_canonical_search_generations(generation_id)
        )
        """,
        """
        CREATE TRIGGER runtime_canonical_search_active_generation_valid_insert
        BEFORE INSERT ON runtime_canonical_search_active_generation
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_search_generations AS generation
            WHERE generation.generation_id = NEW.generation_id
              AND generation.status = 'published'
              AND generation.generation_certificate_digest = NEW.generation_certificate_digest
        )
        BEGIN SELECT RAISE(ABORT, 'invalid active search generation'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_active_generation_valid_update
        BEFORE UPDATE ON runtime_canonical_search_active_generation
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_search_generations AS generation
            WHERE generation.generation_id = NEW.generation_id
              AND generation.status = 'published'
              AND generation.generation_certificate_digest = NEW.generation_certificate_digest
        )
        BEGIN SELECT RAISE(ABORT, 'invalid active search generation'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_active_generation_protected_delete
        BEFORE DELETE ON runtime_canonical_search_active_generation
        BEGIN SELECT RAISE(ABORT, 'active search authority cannot be deleted'); END
        """,
        """
        CREATE TABLE runtime_canonical_generation_gc_jobs (
            generation_id TEXT PRIMARY KEY,
            generation_kind TEXT NOT NULL CHECK (generation_kind IN ('projection', 'search')),
            phase TEXT NOT NULL,
            after_aggregate_kind TEXT NOT NULL,
            after_aggregate_id TEXT NOT NULL,
            owner_id TEXT NOT NULL,
            fence_version INTEGER NOT NULL CHECK (fence_version > 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms >= 0),
            expected_certificate_digest TEXT NOT NULL CHECK (length(expected_certificate_digest) = 64 AND expected_certificate_digest NOT GLOB '*[^0-9a-f]*'),
            last_served_at_ms INTEGER NOT NULL CHECK (last_served_at_ms >= 0),
            service_ticket INTEGER NOT NULL CHECK (service_ticket > 0),
            CHECK ((generation_kind = 'search' AND phase IN ('postings', 'documents', 'shards', 'header'))
                OR (generation_kind = 'projection' AND phase IN ('entries', 'shards', 'header')))
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_generation_gc_jobs_phase_idx ON runtime_canonical_generation_gc_jobs(generation_kind, phase, generation_id)",
        "CREATE INDEX runtime_canonical_generation_gc_jobs_eligibility_idx ON runtime_canonical_generation_gc_jobs(expires_at_ms, service_ticket, owner_id, generation_kind, generation_id)",
        """
        CREATE TABLE runtime_canonical_generation_scrub_jobs (
            generation_id TEXT PRIMARY KEY CHECK (length(generation_id) = 64 AND generation_id NOT GLOB '*[^0-9a-f]*'),
            generation_kind TEXT NOT NULL CHECK (generation_kind IN ('projection', 'search')),
            phase TEXT NOT NULL,
            shard_ordinal INTEGER NOT NULL CHECK (shard_ordinal >= 0),
            observed_count INTEGER NOT NULL CHECK (observed_count >= 0),
            observed_posting_count INTEGER NOT NULL CHECK (observed_posting_count >= 0),
            observed_posting_bytes INTEGER NOT NULL CHECK (observed_posting_bytes >= 0),
            expected_posting_count INTEGER NOT NULL CHECK (expected_posting_count >= 0),
            expected_posting_bytes INTEGER NOT NULL CHECK (expected_posting_bytes >= 0),
            observed_privacy_standard_count INTEGER NOT NULL CHECK (observed_privacy_standard_count >= 0),
            observed_privacy_sensitive_count INTEGER NOT NULL CHECK (observed_privacy_sensitive_count >= 0),
            observed_privacy_private_text_count INTEGER NOT NULL CHECK (observed_privacy_private_text_count >= 0),
            observed_privacy_calendar_count INTEGER NOT NULL CHECK (observed_privacy_calendar_count >= 0),
            observed_privacy_sync_count INTEGER NOT NULL CHECK (observed_privacy_sync_count >= 0),
            observed_nonlocal_count INTEGER NOT NULL CHECK (observed_nonlocal_count >= 0),
            after_posting_token TEXT NOT NULL,
            after_posting_kind TEXT NOT NULL,
            after_posting_id TEXT NOT NULL,
            after_posting_field INTEGER NOT NULL CHECK (after_posting_field >= -1 AND after_posting_field <= 1),
            after_posting_ordinal INTEGER NOT NULL CHECK (after_posting_ordinal >= -1 AND after_posting_ordinal < 64),
            rolling_root_digest TEXT NOT NULL CHECK (length(rolling_root_digest) = 64 AND rolling_root_digest NOT GLOB '*[^0-9a-f]*'),
            previous_last_kind TEXT NOT NULL,
            previous_last_id TEXT NOT NULL,
            owner_id TEXT NOT NULL CHECK (length(owner_id) > 0),
            fence_version INTEGER NOT NULL CHECK (fence_version > 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms >= 0),
            expected_certificate_digest TEXT NOT NULL CHECK (length(expected_certificate_digest) = 64 AND expected_certificate_digest NOT GLOB '*[^0-9a-f]*'),
            last_served_at_ms INTEGER NOT NULL CHECK (last_served_at_ms >= 0),
            service_ticket INTEGER NOT NULL CHECK (service_ticket > 0),
            CHECK ((generation_kind = 'projection' AND phase = 'shards')
                OR (generation_kind = 'search' AND phase IN ('shards', 'postings'))),
            CHECK ((generation_kind = 'projection' AND
                    observed_privacy_standard_count + observed_privacy_sensitive_count
                    + observed_privacy_private_text_count + observed_privacy_calendar_count
                    + observed_privacy_sync_count = observed_count)
                OR (generation_kind = 'search' AND
                    observed_privacy_standard_count = 0
                    AND observed_privacy_sensitive_count = 0
                    AND observed_privacy_private_text_count = 0
                    AND observed_privacy_calendar_count = 0
                    AND observed_privacy_sync_count = 0
                    AND observed_nonlocal_count = 0))
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_generation_scrub_jobs_phase_idx ON runtime_canonical_generation_scrub_jobs(generation_kind, phase, generation_id)",
        "CREATE INDEX runtime_canonical_generation_scrub_jobs_eligibility_idx ON runtime_canonical_generation_scrub_jobs(expires_at_ms, service_ticket, owner_id, generation_kind, generation_id)",
        """
        CREATE TABLE runtime_canonical_scrub_certificates (
            generation_id TEXT PRIMARY KEY,
            generation_kind TEXT NOT NULL CHECK (generation_kind IN ('projection', 'search')),
            projection_id TEXT NOT NULL,
            generation_certificate_digest TEXT NOT NULL CHECK (length(generation_certificate_digest) = 64 AND generation_certificate_digest NOT GLOB '*[^0-9a-f]*'),
            observed_count INTEGER NOT NULL CHECK (observed_count >= 0),
            observed_shard_count INTEGER NOT NULL CHECK (observed_shard_count >= 0),
            observed_posting_count INTEGER NOT NULL CHECK (observed_posting_count >= 0),
            observed_posting_bytes INTEGER NOT NULL CHECK (observed_posting_bytes >= 0),
            root_digest TEXT NOT NULL CHECK (length(root_digest) = 64 AND root_digest NOT GLOB '*[^0-9a-f]*'),
            completed_at_ms INTEGER NOT NULL CHECK (completed_at_ms >= 0),
            scrub_certificate_digest TEXT NOT NULL UNIQUE CHECK (length(scrub_certificate_digest) = 64 AND scrub_certificate_digest NOT GLOB '*[^0-9a-f]*')
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_scrub_certificates_projection_idx ON runtime_canonical_scrub_certificates(projection_id, generation_kind, generation_id)",
        """
        CREATE TABLE runtime_canonical_build_cleanup_jobs (
            generation_id TEXT PRIMARY KEY,
            projection_id TEXT NOT NULL,
            search_generation_id TEXT,
            phase TEXT NOT NULL CHECK (phase IN ('search_postings', 'search_documents', 'search_shards', 'search_header', 'projection_entries', 'projection_shards', 'projection_header')),
            after_aggregate_kind TEXT NOT NULL,
            after_aggregate_id TEXT NOT NULL,
            reason_code TEXT NOT NULL,
            owner_id TEXT NOT NULL,
            fence_version INTEGER NOT NULL CHECK (fence_version > 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms >= 0),
            last_served_at_ms INTEGER NOT NULL CHECK (last_served_at_ms >= 0),
            service_ticket INTEGER NOT NULL CHECK (service_ticket > 0)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_build_cleanup_jobs_eligibility_idx ON runtime_canonical_build_cleanup_jobs(expires_at_ms, service_ticket, projection_id)",
        """
        CREATE TABLE runtime_canonical_repair_requirements (
            requirement_id TEXT PRIMARY KEY CHECK (length(requirement_id) = 64 AND requirement_id NOT GLOB '*[^0-9a-f]*'),
            projection_id TEXT NOT NULL,
            generation_id TEXT,
            authority_kind TEXT NOT NULL CHECK (authority_kind IN ('build', 'projection', 'search')),
            reason_code TEXT NOT NULL,
            source_certificate_digest TEXT CHECK (source_certificate_digest IS NULL OR (length(source_certificate_digest) = 64 AND source_certificate_digest NOT GLOB '*[^0-9a-f]*')),
            state TEXT NOT NULL CHECK (state IN ('required', 'resolved')),
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            resolved_at_ms INTEGER,
            resolution_digest TEXT CHECK (resolution_digest IS NULL OR (length(resolution_digest) = 64 AND resolution_digest NOT GLOB '*[^0-9a-f]*')),
            CHECK ((state = 'required' AND resolved_at_ms IS NULL AND resolution_digest IS NULL)
                OR (state = 'resolved' AND resolved_at_ms IS NOT NULL
                    AND resolved_at_ms >= observed_at_ms AND resolution_digest IS NOT NULL))
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_canonical_repair_requirements_projection_idx ON runtime_canonical_repair_requirements(projection_id, state, authority_kind, generation_id)",
        """
        CREATE TABLE runtime_canonical_repair_incidents (
            incident_key TEXT PRIMARY KEY CHECK (length(incident_key) = 64 AND incident_key NOT GLOB '*[^0-9a-f]*'),
            projection_id TEXT NOT NULL,
            generation_id TEXT,
            authority_kind TEXT NOT NULL CHECK (authority_kind IN ('build', 'projection', 'search')),
            reason_code TEXT NOT NULL,
            source_certificate_digest TEXT CHECK (source_certificate_digest IS NULL OR (length(source_certificate_digest) = 64 AND source_certificate_digest NOT GLOB '*[^0-9a-f]*')),
            next_occurrence_ordinal INTEGER NOT NULL CHECK (next_occurrence_ordinal >= 0),
            active_requirement_id TEXT UNIQUE,
            FOREIGN KEY (active_requirement_id) REFERENCES runtime_canonical_repair_requirements(requirement_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_canonical_scheduler_state (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            next_service_ticket INTEGER NOT NULL CHECK (next_service_ticket > 0)
        )
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_jobs_valid_insert
        BEFORE INSERT ON runtime_canonical_projection_jobs
        WHEN NEW.phase NOT IN ('clone', 'replay')
          OR NEW.progress_sequence != 0 OR NEW.progress_event_id IS NOT NULL
          OR NEW.progress_event_hash IS NOT NULL
          OR NEW.after_aggregate_kind != '' OR NEW.after_aggregate_id != ''
          OR NEW.progress_source_digest != 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
          OR NEW.rolling_root_digest != 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
          OR NEW.shard_ordinal != 0 OR NEW.entry_count != 0
          OR NEW.sealed_entry_count != 0 OR NEW.nonlocal_entry_count != 0
          OR NEW.search_document_count != 0 OR NEW.sealed_search_document_count != 0
          OR NEW.search_posting_count != 0 OR NEW.search_posting_bytes != 0
          OR NEW.privacy_standard_count != 0 OR NEW.privacy_sensitive_count != 0
          OR NEW.privacy_private_text_count != 0 OR NEW.privacy_calendar_count != 0
          OR NEW.privacy_sync_count != 0 OR NEW.blocked_reason_code IS NOT NULL
          OR (NEW.phase = 'clone' AND NEW.base_generation_id IS NULL)
          OR (NEW.phase = 'replay' AND NEW.base_generation_id IS NOT NULL)
          OR (NEW.phase = 'clone' AND NOT EXISTS (
              SELECT 1
              FROM runtime_canonical_projection_active_generations AS active
              JOIN runtime_canonical_projection_generations AS base
                ON base.generation_id = active.generation_id
               AND base.generation_certificate_digest = active.generation_certificate_digest
              JOIN runtime_canonical_scrub_certificates AS scrub
                ON scrub.generation_id = base.generation_id
               AND scrub.generation_kind = 'projection'
               AND scrub.projection_id = base.projection_id
              WHERE base.generation_id = NEW.base_generation_id
                AND base.projection_id = NEW.projection_id
                AND base.status = 'published'
                AND base.generation_certificate_digest = NEW.base_certificate_digest
                AND base.entry_root_digest = NEW.base_root_digest
                AND base.entry_count = NEW.base_entry_count
                AND scrub.scrub_certificate_digest = NEW.base_scrub_certificate_digest
                AND scrub.completed_at_ms = NEW.base_scrub_completed_at_ms
                AND scrub.generation_certificate_digest = NEW.base_certificate_digest
                AND scrub.observed_count = NEW.base_entry_count
                AND scrub.observed_shard_count = base.shard_count
                AND scrub.root_digest = NEW.base_root_digest
          ))
          OR NOT EXISTS (
              SELECT 1 FROM runtime_canonical_projection_generations AS generation
              WHERE generation.generation_id = NEW.generation_id
                AND generation.projection_id = NEW.projection_id
                AND generation.status = 'building'
                AND generation.source_sequence = NEW.target_sequence
                AND generation.source_event_id = NEW.target_event_id
                AND generation.source_event_hash = NEW.target_event_hash
                AND generation.first_invalidation_id = NEW.first_invalidation_id
                AND generation.last_invalidation_id = NEW.last_invalidation_id
                AND generation.invalidation_digest = NEW.invalidation_digest
          )
          OR NOT EXISTS (
              SELECT 1 FROM runtime_canonical_projection_leases AS lease
              WHERE lease.projection_id = NEW.projection_id
                AND lease.owner_id = NEW.owner_id
                AND lease.lease_version = NEW.fence_version
                AND lease.expires_at_ms > NEW.updated_at_ms
          )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical projection job insert'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_jobs_valid_update
        BEFORE UPDATE ON runtime_canonical_projection_jobs
        WHEN NEW.projection_id != OLD.projection_id
          OR NEW.generation_id != OLD.generation_id
          OR NEW.base_generation_id IS NOT OLD.base_generation_id
          OR NEW.base_certificate_digest IS NOT OLD.base_certificate_digest
          OR NEW.base_root_digest IS NOT OLD.base_root_digest
          OR NEW.base_entry_count IS NOT OLD.base_entry_count
          OR NEW.base_scrub_certificate_digest IS NOT OLD.base_scrub_certificate_digest
          OR NEW.base_scrub_completed_at_ms IS NOT OLD.base_scrub_completed_at_ms
          OR NEW.target_sequence != OLD.target_sequence
          OR NEW.target_event_id != OLD.target_event_id
          OR NEW.target_event_hash != OLD.target_event_hash
          OR NEW.first_invalidation_id != OLD.first_invalidation_id
          OR NEW.last_invalidation_id != OLD.last_invalidation_id
          OR NEW.invalidation_digest != OLD.invalidation_digest
          OR NEW.progress_sequence < OLD.progress_sequence
          OR NEW.entry_count < OLD.entry_count
          OR NEW.sealed_entry_count < OLD.sealed_entry_count
          OR NEW.search_document_count < OLD.search_document_count
          OR NEW.sealed_search_document_count < OLD.sealed_search_document_count
          OR NEW.search_posting_count < OLD.search_posting_count
          OR NEW.search_posting_bytes < OLD.search_posting_bytes
          OR NEW.service_ticket < OLD.service_ticket
          OR NEW.updated_at_ms < OLD.updated_at_ms
          OR (NEW.projection_id != 'runtime.search'
              AND NEW.phase IN ('index_search', 'seal_search'))
          OR (OLD.phase = 'seal_projection' AND NEW.phase = 'ready'
              AND NEW.projection_id = 'runtime.search')
          OR (OLD.phase = 'seal_projection' AND NEW.phase = 'index_search'
              AND NEW.projection_id != 'runtime.search')
          OR (NEW.phase = OLD.phase AND NEW.shard_ordinal < OLD.shard_ordinal)
          OR (NEW.phase = OLD.phase AND (
              NEW.after_aggregate_kind < OLD.after_aggregate_kind OR
              (NEW.after_aggregate_kind = OLD.after_aggregate_kind
               AND NEW.after_aggregate_id < OLD.after_aggregate_id)
          ))
          OR NOT (
              NEW.phase = OLD.phase OR
              (OLD.phase = 'clone' AND NEW.phase IN ('replay', 'recovering', 'blocked')) OR
              (OLD.phase = 'replay' AND NEW.phase IN ('seal_projection', 'recovering', 'blocked')) OR
              (OLD.phase = 'seal_projection' AND NEW.phase IN ('index_search', 'ready', 'recovering', 'blocked')) OR
              (OLD.phase = 'index_search' AND NEW.phase IN ('seal_search', 'recovering', 'blocked')) OR
              (OLD.phase = 'seal_search' AND NEW.phase IN ('ready', 'recovering', 'blocked')) OR
              (OLD.phase = 'ready' AND NEW.phase = 'recovering') OR
              (OLD.phase = 'blocked' AND NEW.phase = 'recovering')
          )
          OR NOT EXISTS (
              SELECT 1 FROM runtime_canonical_projection_leases AS lease
              WHERE lease.projection_id = NEW.projection_id
                AND lease.owner_id = NEW.owner_id
                AND lease.lease_version = NEW.fence_version
                AND lease.expires_at_ms > NEW.updated_at_ms
          )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical projection job update'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_jobs_fenced_delete
        BEFORE DELETE ON runtime_canonical_projection_jobs
        WHEN OLD.phase NOT IN ('ready', 'recovering') OR NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_leases AS lease
            WHERE lease.projection_id = OLD.projection_id
              AND lease.owner_id = OLD.owner_id
              AND lease.lease_version = OLD.fence_version
        )
        BEGIN SELECT RAISE(ABORT, 'fenced canonical projection job delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_repair_incidents_valid_update
        BEFORE UPDATE ON runtime_canonical_repair_incidents
        WHEN NEW.incident_key != OLD.incident_key
          OR NEW.projection_id != OLD.projection_id
          OR NEW.generation_id IS NOT OLD.generation_id
          OR NEW.authority_kind != OLD.authority_kind
          OR NEW.reason_code != OLD.reason_code
          OR NEW.source_certificate_digest IS NOT OLD.source_certificate_digest
          OR NOT (
              (OLD.active_requirement_id IS NULL
               AND NEW.active_requirement_id IS NOT NULL
               AND NEW.next_occurrence_ordinal = OLD.next_occurrence_ordinal + 1
               AND EXISTS (
                   SELECT 1 FROM runtime_canonical_repair_requirements AS repair
                   WHERE repair.requirement_id = NEW.active_requirement_id
                     AND repair.projection_id = NEW.projection_id
                     AND repair.generation_id IS NEW.generation_id
                     AND repair.authority_kind = NEW.authority_kind
                     AND repair.reason_code = NEW.reason_code
                     AND repair.source_certificate_digest IS NEW.source_certificate_digest
                     AND repair.state = 'required'
               )) OR
              (OLD.active_requirement_id IS NOT NULL
               AND NEW.active_requirement_id IS NULL
               AND NEW.next_occurrence_ordinal = OLD.next_occurrence_ordinal
               AND EXISTS (
                   SELECT 1 FROM runtime_canonical_repair_requirements AS repair
                   WHERE repair.requirement_id = OLD.active_requirement_id
                     AND repair.state = 'resolved'
               ))
          )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical repair incident update'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_repair_incidents_immutable_delete
        BEFORE DELETE ON runtime_canonical_repair_incidents
        BEGIN SELECT RAISE(ABORT, 'immutable canonical repair incident'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_repair_requirements_clear_incident
        AFTER UPDATE OF state ON runtime_canonical_repair_requirements
        WHEN OLD.state = 'required' AND NEW.state = 'resolved'
        BEGIN
            UPDATE runtime_canonical_repair_incidents
            SET active_requirement_id = NULL
            WHERE active_requirement_id = NEW.requirement_id;
        END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_acks_immutable_update
        BEFORE UPDATE ON runtime_canonical_projection_invalidation_acks
        BEGIN SELECT RAISE(ABORT, 'immutable projection invalidation acknowledgement'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_acks_valid_insert
        BEFORE INSERT ON runtime_canonical_projection_invalidation_acks
        WHEN NOT EXISTS (
            SELECT 1
            FROM runtime_canonical_projection_generations AS generation
            JOIN runtime_commit_projection_invalidations AS invalidation
              ON invalidation.invalidation_id = NEW.invalidation_id
             AND invalidation.projection_id = NEW.projection_id
            WHERE generation.generation_id = NEW.generation_id
              AND generation.projection_id = NEW.projection_id
              AND generation.status = 'published'
              AND generation.source_sequence = NEW.source_sequence
              AND generation.generation_certificate_digest = NEW.generation_certificate_digest
              AND invalidation.terminal_event_sequence <= generation.source_sequence
        )
        BEGIN SELECT RAISE(ABORT, 'invalid projection invalidation acknowledgement'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_acks_immutable_delete
        BEFORE DELETE ON runtime_canonical_projection_invalidation_acks
        BEGIN SELECT RAISE(ABORT, 'immutable projection invalidation acknowledgement'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_quarantine_immutable_update
        BEFORE UPDATE ON runtime_canonical_projection_quarantine
        BEGIN SELECT RAISE(ABORT, 'immutable projection quarantine'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_quarantine_immutable_delete
        BEFORE DELETE ON runtime_canonical_projection_quarantine
        BEGIN SELECT RAISE(ABORT, 'immutable projection quarantine'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_entries_fenced_insert
        BEFORE INSERT ON runtime_canonical_projection_entries
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = NEW.generation_id AND generation.status = 'building'
        )
        BEGIN SELECT RAISE(ABORT, 'projection entry generation is sealed'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_entries_fenced_update
        BEFORE UPDATE ON runtime_canonical_projection_entries
        WHEN NEW.generation_id != OLD.generation_id
          OR NEW.aggregate_kind != OLD.aggregate_kind
          OR NEW.aggregate_id != OLD.aggregate_id
          OR NEW.source_sequence <= OLD.source_sequence
          OR NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = OLD.generation_id AND generation.status = 'building'
          )
        BEGIN SELECT RAISE(ABORT, 'invalid projection entry update'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_entries_fenced_delete
        BEFORE DELETE ON runtime_canonical_projection_entries
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.generation_id = OLD.generation_id
              AND cleanup.phase = 'projection_entries'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
            JOIN runtime_canonical_projection_generations AS generation
              ON generation.generation_id = job.generation_id AND generation.status = 'retired'
            WHERE job.generation_id = OLD.generation_id
              AND job.generation_kind = 'projection' AND job.phase = 'entries'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_leases AS lease
              ON lease.projection_id = job.projection_id
             AND lease.owner_id = job.owner_id
             AND lease.lease_version = job.fence_version
            WHERE job.generation_id = OLD.generation_id AND job.phase = 'recovering'
        )
        BEGIN SELECT RAISE(ABORT, 'fenced projection entry delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_shards_fenced_insert
        BEFORE INSERT ON runtime_canonical_projection_shards
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = NEW.generation_id AND generation.status = 'building'
        )
        BEGIN SELECT RAISE(ABORT, 'projection shard generation is sealed'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_shards_immutable_update
        BEFORE UPDATE ON runtime_canonical_projection_shards
        BEGIN SELECT RAISE(ABORT, 'immutable projection shard'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_shards_fenced_delete
        BEFORE DELETE ON runtime_canonical_projection_shards
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.generation_id = OLD.generation_id
              AND cleanup.phase = 'projection_shards'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
            JOIN runtime_canonical_projection_generations AS generation
              ON generation.generation_id = job.generation_id AND generation.status = 'retired'
            WHERE job.generation_id = OLD.generation_id
              AND job.generation_kind = 'projection' AND job.phase = 'shards'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_leases AS lease
              ON lease.projection_id = job.projection_id
             AND lease.owner_id = job.owner_id
             AND lease.lease_version = job.fence_version
            WHERE job.generation_id = OLD.generation_id AND job.phase = 'recovering'
        )
        BEGIN SELECT RAISE(ABORT, 'fenced projection shard delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_generations_fenced_update
        BEFORE UPDATE ON runtime_canonical_projection_generations
        WHEN NEW.generation_id != OLD.generation_id
          OR NEW.projection_id != OLD.projection_id
          OR NEW.definition_version != OLD.definition_version
          OR NEW.definition_digest != OLD.definition_digest
          OR NEW.output_version != OLD.output_version
          OR NEW.source_sequence != OLD.source_sequence
          OR NEW.source_event_id != OLD.source_event_id
          OR NEW.source_event_hash != OLD.source_event_hash
          OR NEW.source_chain_digest != OLD.source_chain_digest
          OR NEW.first_invalidation_id != OLD.first_invalidation_id
          OR NEW.last_invalidation_id != OLD.last_invalidation_id
          OR NEW.invalidation_digest != OLD.invalidation_digest
          OR NEW.created_at_ms != OLD.created_at_ms
          OR NOT ((OLD.status = 'building' AND NEW.status = 'sealed')
               OR (OLD.status = 'building' AND NEW.status = 'abandoned'
                   AND NEW.generation_certificate_digest IS NULL
                   AND EXISTS (
                       SELECT 1 FROM runtime_canonical_projection_jobs AS job
                       JOIN runtime_canonical_projection_leases AS lease
                         ON lease.projection_id = job.projection_id
                        AND lease.owner_id = job.owner_id
                        AND lease.lease_version = job.fence_version
                       WHERE job.generation_id = OLD.generation_id AND job.phase = 'recovering'
                   ))
               OR (OLD.status = 'sealed' AND NEW.status = 'published')
               OR (OLD.status = 'sealed' AND NEW.status = 'abandoned'
                   AND NEW.generation_certificate_digest IS NULL
                   AND EXISTS (
                       SELECT 1 FROM runtime_canonical_projection_jobs AS job
                       JOIN runtime_canonical_projection_leases AS lease
                         ON lease.projection_id = job.projection_id
                        AND lease.owner_id = job.owner_id
                        AND lease.lease_version = job.fence_version
                       WHERE job.generation_id = OLD.generation_id AND job.phase = 'recovering'
                   ))
               OR (OLD.status = 'published' AND NEW.status = 'retired')
               )
          OR (OLD.status != 'building'
              AND NOT (OLD.status = 'sealed' AND NEW.status = 'abandoned'
                   AND EXISTS (
                       SELECT 1 FROM runtime_canonical_projection_jobs AS job
                       JOIN runtime_canonical_projection_leases AS lease
                         ON lease.projection_id = job.projection_id
                        AND lease.owner_id = job.owner_id
                        AND lease.lease_version = job.fence_version
                       WHERE job.generation_id = OLD.generation_id AND job.phase = 'recovering'
                   ))
              AND (
                NEW.entry_count != OLD.entry_count OR NEW.shard_count != OLD.shard_count
                OR NEW.entry_root_digest != OLD.entry_root_digest OR NEW.privacy != OLD.privacy
                OR NEW.local_only != OLD.local_only
                OR NEW.generation_certificate_digest IS NOT OLD.generation_certificate_digest
                OR NEW.sealed_at_ms IS NOT OLD.sealed_at_ms
             ))
        BEGIN SELECT RAISE(ABORT, 'invalid projection generation transition'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_projection_generations_fenced_delete
        BEFORE DELETE ON runtime_canonical_projection_generations
        WHEN NOT (
            (OLD.status = 'abandoned' AND EXISTS (
                SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
                WHERE cleanup.generation_id = OLD.generation_id
                  AND cleanup.phase = 'projection_header'
            )) OR
            (OLD.status = 'retired' AND EXISTS (
                SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
                WHERE job.generation_id = OLD.generation_id
                  AND job.generation_kind = 'projection' AND job.phase = 'header'
            )) OR
            (OLD.status IN ('building', 'sealed', 'abandoned') AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_jobs AS job
                JOIN runtime_canonical_projection_leases AS lease
                  ON lease.projection_id = job.projection_id
                 AND lease.owner_id = job.owner_id
                 AND lease.lease_version = job.fence_version
                WHERE job.generation_id = OLD.generation_id AND job.phase = 'recovering'
            ))
        )
        BEGIN SELECT RAISE(ABORT, 'fenced projection generation delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_documents_fenced_insert
        BEFORE INSERT ON runtime_canonical_search_documents
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_search_generations AS generation
            WHERE generation.generation_id = NEW.generation_id AND generation.status = 'building'
        )
        BEGIN SELECT RAISE(ABORT, 'search document generation is sealed'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_documents_immutable_update
        BEFORE UPDATE ON runtime_canonical_search_documents
        BEGIN SELECT RAISE(ABORT, 'immutable search document'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_documents_fenced_delete
        BEFORE DELETE ON runtime_canonical_search_documents
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.search_generation_id = OLD.generation_id
              AND cleanup.phase = 'search_documents'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
            JOIN runtime_canonical_search_generations AS generation
              ON generation.generation_id = job.generation_id AND generation.status = 'retired'
            WHERE job.generation_id = OLD.generation_id
              AND job.generation_kind = 'search' AND job.phase = 'documents'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_leases AS lease
              ON lease.projection_id = job.projection_id
             AND lease.owner_id = job.owner_id
             AND lease.lease_version = job.fence_version
            WHERE job.generation_id = (
                SELECT projection_generation_id FROM runtime_canonical_search_generations
                WHERE generation_id = OLD.generation_id
            ) AND job.phase = 'recovering'
        )
        BEGIN SELECT RAISE(ABORT, 'fenced search document delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_postings_fenced_insert
        BEFORE INSERT ON runtime_canonical_search_postings
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_search_generations AS generation
            WHERE generation.generation_id = NEW.generation_id AND generation.status = 'building'
        )
        BEGIN SELECT RAISE(ABORT, 'search posting generation is sealed'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_postings_immutable_update
        BEFORE UPDATE ON runtime_canonical_search_postings
        BEGIN SELECT RAISE(ABORT, 'immutable search posting'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_postings_fenced_delete
        BEFORE DELETE ON runtime_canonical_search_postings
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.search_generation_id = OLD.generation_id
              AND cleanup.phase = 'search_postings'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
            JOIN runtime_canonical_search_generations AS generation
              ON generation.generation_id = job.generation_id AND generation.status = 'retired'
            WHERE job.generation_id = OLD.generation_id
              AND job.generation_kind = 'search' AND job.phase = 'postings'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_leases AS lease
              ON lease.projection_id = job.projection_id
             AND lease.owner_id = job.owner_id
             AND lease.lease_version = job.fence_version
            WHERE job.generation_id = (
                SELECT projection_generation_id FROM runtime_canonical_search_generations
                WHERE generation_id = OLD.generation_id
            ) AND job.phase = 'recovering'
        )
        BEGIN SELECT RAISE(ABORT, 'fenced search posting delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_shards_fenced_insert
        BEFORE INSERT ON runtime_canonical_search_shards
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_search_generations AS generation
            WHERE generation.generation_id = NEW.generation_id AND generation.status = 'building'
        )
        BEGIN SELECT RAISE(ABORT, 'search shard generation is sealed'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_shards_immutable_update
        BEFORE UPDATE ON runtime_canonical_search_shards
        BEGIN SELECT RAISE(ABORT, 'immutable search shard'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_shards_fenced_delete
        BEFORE DELETE ON runtime_canonical_search_shards
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.search_generation_id = OLD.generation_id
              AND cleanup.phase = 'search_shards'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
            JOIN runtime_canonical_search_generations AS generation
              ON generation.generation_id = job.generation_id AND generation.status = 'retired'
            WHERE job.generation_id = OLD.generation_id
              AND job.generation_kind = 'search' AND job.phase = 'shards'
        )
        AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_leases AS lease
              ON lease.projection_id = job.projection_id
             AND lease.owner_id = job.owner_id
             AND lease.lease_version = job.fence_version
            WHERE job.generation_id = (
                SELECT projection_generation_id FROM runtime_canonical_search_generations
                WHERE generation_id = OLD.generation_id
            ) AND job.phase = 'recovering'
        )
        BEGIN SELECT RAISE(ABORT, 'fenced search shard delete required'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_generations_fenced_update
        BEFORE UPDATE ON runtime_canonical_search_generations
        WHEN NEW.generation_id != OLD.generation_id
          OR NEW.projection_generation_id != OLD.projection_generation_id
          OR NEW.coverage != OLD.coverage
          OR NEW.definition_digest != OLD.definition_digest
          OR NEW.source_sequence != OLD.source_sequence
          OR NEW.source_event_hash != OLD.source_event_hash
          OR NEW.created_at_ms != OLD.created_at_ms
          OR NOT ((OLD.status = 'building' AND NEW.status = 'sealed')
               OR (OLD.status = 'building' AND NEW.status = 'abandoned'
                   AND NEW.generation_certificate_digest IS NULL
                   AND EXISTS (
                       SELECT 1 FROM runtime_canonical_projection_jobs AS job
                       JOIN runtime_canonical_projection_leases AS lease
                         ON lease.projection_id = job.projection_id
                        AND lease.owner_id = job.owner_id
                        AND lease.lease_version = job.fence_version
                       WHERE job.generation_id = OLD.projection_generation_id
                         AND job.phase = 'recovering'
                   ))
               OR (OLD.status = 'sealed' AND NEW.status = 'published')
               OR (OLD.status = 'sealed' AND NEW.status = 'abandoned'
                   AND NEW.generation_certificate_digest IS NULL
                   AND EXISTS (
                       SELECT 1 FROM runtime_canonical_projection_jobs AS job
                       JOIN runtime_canonical_projection_leases AS lease
                         ON lease.projection_id = job.projection_id
                        AND lease.owner_id = job.owner_id
                        AND lease.lease_version = job.fence_version
                       WHERE job.generation_id = OLD.projection_generation_id
                         AND job.phase = 'recovering'
                   ))
               OR (OLD.status = 'published' AND NEW.status = 'retired'))
          OR (OLD.status != 'building'
              AND NOT (OLD.status = 'sealed' AND NEW.status = 'abandoned'
                   AND EXISTS (
                       SELECT 1 FROM runtime_canonical_projection_jobs AS job
                       JOIN runtime_canonical_projection_leases AS lease
                         ON lease.projection_id = job.projection_id
                        AND lease.owner_id = job.owner_id
                        AND lease.lease_version = job.fence_version
                       WHERE job.generation_id = OLD.projection_generation_id
                         AND job.phase = 'recovering'
                   ))
              AND (
                NEW.document_count != OLD.document_count OR NEW.shard_count != OLD.shard_count
                OR NEW.posting_count != OLD.posting_count OR NEW.posting_bytes != OLD.posting_bytes
                OR NEW.document_root_digest != OLD.document_root_digest
                OR NEW.generation_certificate_digest IS NOT OLD.generation_certificate_digest
             ))
        BEGIN SELECT RAISE(ABORT, 'invalid search generation transition'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_generation_gc_jobs_valid_insert
        BEFORE INSERT ON runtime_canonical_generation_gc_jobs
        WHEN NEW.phase != CASE NEW.generation_kind
                WHEN 'search' THEN 'postings' ELSE 'entries' END
          OR NEW.after_aggregate_kind != '' OR NEW.after_aggregate_id != ''
          OR NEW.owner_id != 'unclaimed' OR NEW.fence_version != 1
          OR NEW.service_ticket <= 0
          OR NEW.service_ticket != COALESCE((
              SELECT next_service_ticket - 1
              FROM runtime_canonical_scheduler_state WHERE singleton_id = 1
          ), -1) OR NOT (
            (NEW.generation_kind = 'projection' AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_generations AS generation
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'retired'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            )) OR
            (NEW.generation_kind = 'search' AND EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS generation
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'retired'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            ))
        )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical generation GC target'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_generation_gc_jobs_valid_update
        BEFORE UPDATE ON runtime_canonical_generation_gc_jobs
        WHEN NEW.generation_id != OLD.generation_id
          OR NEW.generation_kind != OLD.generation_kind
          OR NEW.expected_certificate_digest != OLD.expected_certificate_digest
          OR NEW.fence_version < OLD.fence_version
          OR NEW.service_ticket <= 0
          OR NEW.service_ticket < OLD.service_ticket
          OR (NEW.service_ticket != OLD.service_ticket
              AND NEW.service_ticket != COALESCE((
                  SELECT next_service_ticket - 1
                  FROM runtime_canonical_scheduler_state WHERE singleton_id = 1
              ), -1))
          OR (NEW.service_ticket != OLD.service_ticket AND (
              NEW.fence_version != OLD.fence_version + 1
              OR NEW.owner_id = 'unclaimed'
          ))
          OR (NEW.service_ticket = OLD.service_ticket
              AND NEW.fence_version != OLD.fence_version)
          OR (NEW.owner_id != OLD.owner_id
              AND NEW.service_ticket = OLD.service_ticket
              AND NEW.owner_id != 'unclaimed')
          OR (NEW.phase = OLD.phase AND (
              NEW.after_aggregate_kind < OLD.after_aggregate_kind OR
              (NEW.after_aggregate_kind = OLD.after_aggregate_kind
               AND NEW.after_aggregate_id < OLD.after_aggregate_id)
          ))
          OR (NEW.phase != OLD.phase AND
              (NEW.after_aggregate_kind != '' OR NEW.after_aggregate_id != ''))
          OR NOT (
            NEW.phase = OLD.phase OR
            (NEW.generation_kind = 'search' AND OLD.phase = 'postings' AND NEW.phase = 'documents') OR
            (NEW.generation_kind = 'search' AND OLD.phase = 'documents' AND NEW.phase = 'shards') OR
            (NEW.generation_kind = 'search' AND OLD.phase = 'shards' AND NEW.phase = 'header') OR
            (NEW.generation_kind = 'projection' AND OLD.phase = 'entries' AND NEW.phase = 'shards') OR
            (NEW.generation_kind = 'projection' AND OLD.phase = 'shards' AND NEW.phase = 'header')
          )
          OR NOT (
            (NEW.generation_kind = 'projection' AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_generations AS generation
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'retired'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            )) OR
            (NEW.generation_kind = 'search' AND EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS generation
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'retired'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            ))
          )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical generation GC update'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_generation_gc_jobs_fenced_delete
        BEFORE DELETE ON runtime_canonical_generation_gc_jobs
        WHEN OLD.phase != 'header' OR OLD.owner_id = 'unclaimed'
        BEGIN SELECT RAISE(ABORT, 'canonical generation GC must finish at claimed header'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_generation_scrub_jobs_valid_insert
        BEFORE INSERT ON runtime_canonical_generation_scrub_jobs
        WHEN NEW.phase != 'shards' OR NEW.shard_ordinal != 0
          OR NEW.observed_count != 0 OR NEW.observed_posting_count != 0
          OR NEW.observed_posting_bytes != 0 OR NEW.expected_posting_count != 0
          OR NEW.expected_posting_bytes != 0 OR NEW.observed_nonlocal_count != 0
          OR NEW.observed_privacy_standard_count != 0
          OR NEW.observed_privacy_sensitive_count != 0
          OR NEW.observed_privacy_private_text_count != 0
          OR NEW.observed_privacy_calendar_count != 0
          OR NEW.observed_privacy_sync_count != 0
          OR NEW.after_posting_token != '' OR NEW.after_posting_kind != ''
          OR NEW.after_posting_id != '' OR NEW.after_posting_field != -1
          OR NEW.after_posting_ordinal != -1
          OR NEW.previous_last_kind != '' OR NEW.previous_last_id != ''
          OR NEW.rolling_root_digest != 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
          OR NEW.owner_id != 'unclaimed' OR NEW.fence_version != 1
          OR NEW.service_ticket <= 0
          OR NEW.service_ticket != COALESCE((
              SELECT next_service_ticket - 1
              FROM runtime_canonical_scheduler_state WHERE singleton_id = 1
          ), -1) OR NOT (
            (NEW.generation_kind = 'projection' AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_generations AS generation
                JOIN runtime_canonical_projection_active_generations AS active
                  ON active.generation_id = generation.generation_id
                 AND active.generation_certificate_digest = generation.generation_certificate_digest
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'published'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            )) OR
            (NEW.generation_kind = 'search' AND EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS generation
                JOIN runtime_canonical_search_active_generation AS active
                  ON active.generation_id = generation.generation_id
                 AND active.generation_certificate_digest = generation.generation_certificate_digest
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'published'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            ))
        )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical generation scrub target'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_generation_scrub_jobs_valid_update
        BEFORE UPDATE ON runtime_canonical_generation_scrub_jobs
        WHEN NEW.generation_id != OLD.generation_id
          OR NEW.generation_kind != OLD.generation_kind
          OR NEW.expected_certificate_digest != OLD.expected_certificate_digest
          OR NEW.fence_version < OLD.fence_version
          OR NEW.service_ticket <= 0
          OR NEW.service_ticket < OLD.service_ticket
          OR (NEW.service_ticket != OLD.service_ticket
              AND NEW.service_ticket != COALESCE((
                  SELECT next_service_ticket - 1
                  FROM runtime_canonical_scheduler_state WHERE singleton_id = 1
              ), -1))
          OR (NEW.service_ticket != OLD.service_ticket AND (
              NEW.fence_version != OLD.fence_version + 1
              OR NEW.owner_id = 'unclaimed'
          ))
          OR (NEW.service_ticket = OLD.service_ticket
              AND NEW.fence_version != OLD.fence_version)
          OR (NEW.owner_id != OLD.owner_id
              AND NEW.service_ticket = OLD.service_ticket
              AND NEW.owner_id != 'unclaimed')
          OR NOT (
            NEW.phase = OLD.phase OR
            (NEW.generation_kind = 'search' AND OLD.phase = 'shards' AND NEW.phase = 'postings')
          )
          OR (OLD.phase = 'shards' AND NEW.phase = 'postings' AND (
              NEW.after_posting_token != '' OR NEW.after_posting_kind != ''
              OR NEW.after_posting_id != '' OR NEW.after_posting_field != -1
              OR NEW.after_posting_ordinal != -1
          ))
          OR NEW.shard_ordinal < OLD.shard_ordinal
          OR NEW.observed_count < OLD.observed_count
          OR NEW.observed_posting_count < OLD.observed_posting_count
          OR NEW.observed_posting_bytes < OLD.observed_posting_bytes
          OR NEW.expected_posting_count < OLD.expected_posting_count
          OR NEW.expected_posting_bytes < OLD.expected_posting_bytes
          OR NEW.observed_privacy_standard_count < OLD.observed_privacy_standard_count
          OR NEW.observed_privacy_sensitive_count < OLD.observed_privacy_sensitive_count
          OR NEW.observed_privacy_private_text_count < OLD.observed_privacy_private_text_count
          OR NEW.observed_privacy_calendar_count < OLD.observed_privacy_calendar_count
          OR NEW.observed_privacy_sync_count < OLD.observed_privacy_sync_count
          OR NEW.observed_nonlocal_count < OLD.observed_nonlocal_count
          OR (NEW.phase = 'shards' AND (
              NEW.previous_last_kind < OLD.previous_last_kind OR
              (NEW.previous_last_kind = OLD.previous_last_kind
               AND NEW.previous_last_id < OLD.previous_last_id)
          ))
          OR (NEW.phase = 'postings' AND OLD.phase = 'postings' AND (
              NEW.after_posting_token < OLD.after_posting_token OR
              (NEW.after_posting_token = OLD.after_posting_token
               AND NEW.after_posting_kind < OLD.after_posting_kind) OR
              (NEW.after_posting_token = OLD.after_posting_token
               AND NEW.after_posting_kind = OLD.after_posting_kind
               AND NEW.after_posting_id < OLD.after_posting_id) OR
              (NEW.after_posting_token = OLD.after_posting_token
               AND NEW.after_posting_kind = OLD.after_posting_kind
               AND NEW.after_posting_id = OLD.after_posting_id
               AND NEW.after_posting_field < OLD.after_posting_field) OR
              (NEW.after_posting_token = OLD.after_posting_token
               AND NEW.after_posting_kind = OLD.after_posting_kind
               AND NEW.after_posting_id = OLD.after_posting_id
               AND NEW.after_posting_field = OLD.after_posting_field
               AND NEW.after_posting_ordinal < OLD.after_posting_ordinal)
          ))
          OR NOT (
            (NEW.generation_kind = 'projection' AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_generations AS generation
                JOIN runtime_canonical_projection_active_generations AS active
                  ON active.generation_id = generation.generation_id
                 AND active.generation_certificate_digest = generation.generation_certificate_digest
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'published'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            )) OR
            (NEW.generation_kind = 'search' AND EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS generation
                JOIN runtime_canonical_search_active_generation AS active
                  ON active.generation_id = generation.generation_id
                 AND active.generation_certificate_digest = generation.generation_certificate_digest
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.status = 'published'
                  AND generation.generation_certificate_digest = NEW.expected_certificate_digest
            ))
          )
        BEGIN SELECT RAISE(ABORT, 'invalid canonical generation scrub update'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_scrub_certificates_valid_insert
        BEFORE INSERT ON runtime_canonical_scrub_certificates
        WHEN NOT (
            (NEW.generation_kind = 'projection' AND NEW.observed_posting_count = 0
             AND NEW.observed_posting_bytes = 0 AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_generations AS generation
                JOIN runtime_canonical_projection_active_generations AS active
                  ON active.projection_id = generation.projection_id
                 AND active.generation_id = generation.generation_id
                 AND active.generation_certificate_digest = generation.generation_certificate_digest
                WHERE generation.generation_id = NEW.generation_id
                  AND generation.projection_id = NEW.projection_id
                  AND generation.status = 'published'
                  AND generation.generation_certificate_digest = NEW.generation_certificate_digest
                  AND generation.entry_count = NEW.observed_count
                  AND generation.shard_count = NEW.observed_shard_count
                  AND generation.entry_root_digest = NEW.root_digest
             )) OR
            (NEW.generation_kind = 'search' AND EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS search
                JOIN runtime_canonical_search_active_generation AS active
                  ON active.generation_id = search.generation_id
                 AND active.generation_certificate_digest = search.generation_certificate_digest
                JOIN runtime_canonical_projection_generations AS projection
                  ON projection.generation_id = search.projection_generation_id
                WHERE search.generation_id = NEW.generation_id
                  AND projection.projection_id = NEW.projection_id
                  AND search.status = 'published'
                  AND search.generation_certificate_digest = NEW.generation_certificate_digest
                  AND search.document_count = NEW.observed_count
                  AND search.shard_count = NEW.observed_shard_count
                  AND search.posting_count = NEW.observed_posting_count
                  AND search.posting_bytes = NEW.observed_posting_bytes
                  AND search.document_root_digest = NEW.root_digest
             ))
        )
        BEGIN SELECT RAISE(ABORT, 'scrub certificate does not match active authority'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_scrub_certificates_immutable_update
        BEFORE UPDATE ON runtime_canonical_scrub_certificates
        BEGIN SELECT RAISE(ABORT, 'immutable canonical scrub certificate'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_scrub_certificates_immutable_delete
        BEFORE DELETE ON runtime_canonical_scrub_certificates
        WHEN NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.generation_id = OLD.generation_id
              AND cleanup.phase = 'projection_header'
        ) AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
            WHERE cleanup.search_generation_id = OLD.generation_id
              AND cleanup.phase = 'search_header'
        ) AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_generation_gc_jobs AS gc
            WHERE gc.generation_id = OLD.generation_id
              AND gc.generation_kind = OLD.generation_kind AND gc.phase = 'header'
        )
        BEGIN SELECT RAISE(ABORT, 'immutable canonical scrub certificate'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_build_cleanup_jobs_valid_insert
        BEFORE INSERT ON runtime_canonical_build_cleanup_jobs
        WHEN NEW.phase != CASE WHEN NEW.search_generation_id IS NULL
                THEN 'projection_entries' ELSE 'search_postings' END
          OR NEW.after_aggregate_kind != '' OR NEW.after_aggregate_id != ''
          OR NEW.owner_id != 'unclaimed' OR NEW.fence_version != 1
          OR NEW.service_ticket <= 0
          OR NEW.service_ticket != COALESCE((
              SELECT next_service_ticket - 1
              FROM runtime_canonical_scheduler_state WHERE singleton_id = 1
          ), -1) OR EXISTS (
            SELECT 1 FROM runtime_canonical_projection_active_generations AS active
            WHERE active.generation_id = NEW.generation_id
        ) OR NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = NEW.generation_id
              AND generation.projection_id = NEW.projection_id
              AND generation.status = 'abandoned'
        ) OR NOT (
            (NEW.search_generation_id IS NULL AND NOT EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS search
                WHERE search.projection_generation_id = NEW.generation_id
            )) OR
            (NEW.search_generation_id IS NOT NULL
             AND EXISTS (
                SELECT 1 FROM runtime_canonical_search_generations AS search
                WHERE search.generation_id = NEW.search_generation_id
                  AND search.projection_generation_id = NEW.generation_id
                  AND search.status = 'abandoned'
             ))
        )
        BEGIN SELECT RAISE(ABORT, 'cleanup target must be unpublished abandoned authority'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_build_cleanup_jobs_valid_update
        BEFORE UPDATE ON runtime_canonical_build_cleanup_jobs
        WHEN NEW.generation_id != OLD.generation_id
          OR NEW.projection_id != OLD.projection_id
          OR NEW.search_generation_id IS NOT OLD.search_generation_id
          OR NEW.reason_code != OLD.reason_code
          OR NEW.fence_version < OLD.fence_version
          OR NEW.service_ticket <= 0
          OR NEW.service_ticket < OLD.service_ticket
          OR (NEW.service_ticket != OLD.service_ticket
              AND NEW.service_ticket != COALESCE((
                  SELECT next_service_ticket - 1
                  FROM runtime_canonical_scheduler_state WHERE singleton_id = 1
              ), -1))
          OR (NEW.service_ticket != OLD.service_ticket AND (
              NEW.fence_version != OLD.fence_version + 1
              OR NEW.owner_id = 'unclaimed'
          ))
          OR (NEW.service_ticket = OLD.service_ticket
              AND NEW.fence_version != OLD.fence_version)
          OR (NEW.owner_id != OLD.owner_id
              AND NEW.service_ticket = OLD.service_ticket
              AND NEW.owner_id != 'unclaimed')
          OR (NEW.phase = OLD.phase AND (
              NEW.after_aggregate_kind < OLD.after_aggregate_kind OR
              (NEW.after_aggregate_kind = OLD.after_aggregate_kind
               AND NEW.after_aggregate_id < OLD.after_aggregate_id)
          ))
          OR (NEW.phase != OLD.phase AND
              (NEW.after_aggregate_kind != '' OR NEW.after_aggregate_id != ''))
          OR NOT (
            NEW.phase = OLD.phase OR
            (OLD.phase = 'search_postings' AND NEW.phase = 'search_documents') OR
            (OLD.phase = 'search_documents' AND NEW.phase = 'search_shards') OR
            (OLD.phase = 'search_shards' AND NEW.phase = 'search_header') OR
            (OLD.phase = 'search_header' AND NEW.phase = 'projection_entries') OR
            (OLD.phase = 'projection_entries' AND NEW.phase = 'projection_shards') OR
            (OLD.phase = 'projection_shards' AND NEW.phase = 'projection_header')
          )
          OR NOT EXISTS (
            SELECT 1 FROM runtime_canonical_projection_generations AS generation
            WHERE generation.generation_id = NEW.generation_id
              AND generation.projection_id = NEW.projection_id
              AND generation.status = 'abandoned'
          )
          OR (NEW.phase LIKE 'search_%' AND NOT EXISTS (
            SELECT 1 FROM runtime_canonical_search_generations AS search
            WHERE search.generation_id = NEW.search_generation_id
              AND search.projection_generation_id = NEW.generation_id
              AND search.status = 'abandoned'
          ))
        BEGIN SELECT RAISE(ABORT, 'invalid cleanup transition'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_build_cleanup_jobs_fenced_delete
        BEFORE DELETE ON runtime_canonical_build_cleanup_jobs
        WHEN OLD.phase != 'projection_header' OR OLD.owner_id = 'unclaimed'
        BEGIN SELECT RAISE(ABORT, 'canonical cleanup must finish at claimed projection header'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_repair_requirements_fenced_update
        BEFORE UPDATE ON runtime_canonical_repair_requirements
        WHEN OLD.state != 'required' OR NEW.state != 'resolved'
          OR NEW.requirement_id != OLD.requirement_id
          OR NEW.projection_id != OLD.projection_id
          OR NEW.generation_id IS NOT OLD.generation_id
          OR NEW.authority_kind != OLD.authority_kind
          OR NEW.reason_code != OLD.reason_code
          OR NEW.source_certificate_digest IS NOT OLD.source_certificate_digest
          OR NEW.observed_at_ms != OLD.observed_at_ms
          OR NEW.resolved_at_ms IS NULL OR NEW.resolution_digest IS NULL
          OR NOT EXISTS (
              SELECT 1 FROM runtime_canonical_repair_incidents AS incident
              WHERE incident.active_requirement_id = OLD.requirement_id
                AND incident.projection_id = OLD.projection_id
                AND incident.generation_id IS OLD.generation_id
                AND incident.authority_kind = OLD.authority_kind
                AND incident.reason_code = OLD.reason_code
                AND incident.source_certificate_digest IS OLD.source_certificate_digest
          )
        BEGIN SELECT RAISE(ABORT, 'invalid repair requirement transition'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_repair_requirements_immutable_delete
        BEFORE DELETE ON runtime_canonical_repair_requirements
        BEGIN SELECT RAISE(ABORT, 'immutable repair requirement'); END
        """,
        """
        CREATE TRIGGER runtime_canonical_search_generations_fenced_delete
        BEFORE DELETE ON runtime_canonical_search_generations
        WHEN NOT (
            (OLD.status = 'abandoned' AND EXISTS (
                SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
                WHERE cleanup.search_generation_id = OLD.generation_id
                  AND cleanup.phase = 'search_header'
            )) OR
            (OLD.status = 'retired' AND EXISTS (
                SELECT 1 FROM runtime_canonical_generation_gc_jobs AS job
                WHERE job.generation_id = OLD.generation_id
                  AND job.generation_kind = 'search' AND job.phase = 'header'
            )) OR
            (OLD.status = 'building' AND EXISTS (
                SELECT 1 FROM runtime_canonical_projection_jobs AS job
                JOIN runtime_canonical_projection_leases AS lease
                  ON lease.projection_id = job.projection_id
                 AND lease.owner_id = job.owner_id
                 AND lease.lease_version = job.fence_version
                WHERE job.generation_id = OLD.projection_generation_id
                  AND job.phase = 'recovering'
            ))
        )
        BEGIN SELECT RAISE(ABORT, 'fenced search generation delete required'); END
        """,
    ]

    static let stagedIntegratedStatements = CanonicalRuntimeReplaySchemaPlan.stagedIntegratedStatements + statements

    static func requireIntegratedSchema(in database: isolated SQLiteDatabase) throws {
        let rows = try database.query("PRAGMA user_version")
        guard rows.count == 1,
              rows[0].values.first == .integer(Int64(targetSchemaVersion)) else {
            let actual: Int
            if case let .integer(value)? = rows.first?.values.first { actual = Int(value) }
            else { actual = 0 }
            throw RuntimeCanonicalReplayError.migrationRequired(expected: targetSchemaVersion, actual: actual)
        }
        // The replay validator compares the full normalized V5 SQL catalog because the
        // effective version is V5. These explicit plan-local checks prevent a future
        // refactor from accidentally validating only the inherited V4 ownership set.
        try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
        for table in tables {
            let observed = try database.query(
                "SELECT 1 FROM sqlite_schema WHERE type = 'table' AND name = ? LIMIT 2",
                bindings: [.text(table)]
            )
            guard observed.count == 1 else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
        for index in indexes {
            let observed = try database.query(
                "SELECT 1 FROM sqlite_schema WHERE type = 'index' AND name = ? LIMIT 2",
                bindings: [.text(index)]
            )
            guard observed.count == 1 else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
    }
}
