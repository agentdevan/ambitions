@testable import Ambitions
import Foundation
import XCTest

/// Source-level contract coverage for the shipping schema-v8 generation
/// lifecycle. These tests deliberately contain no legacy-v1 construction path
/// and do not enable AMBITIONS_LEGACY_RUNTIME_TEST_SUPPORT.
final class CanonicalRuntimeStoreGenerationTests: XCTestCase {
    private let digest = String(repeating: "a", count: 64)

    func testActiveSelectorRejectsFutureAndOlderFormats() throws {
        let generationID = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        let future = RuntimeGenerationActiveSelector(
            formatVersion: runtimeGenerationActiveSelectorVersion + 1,
            generationID: generationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            relativeDatabasePath: "Stores/\(generationID.rawValue)/Runtime.sqlite",
            authorityManifestDigest: digest,
            authorityManifestFileSHA256: digest,
            verificationID: "verification-1",
            activationIntentID: "intent-1",
            priorGenerationID: nil,
            priorAuthorityManifestDigest: nil,
            preparedAtMilliseconds: 1
        )
        XCTAssertThrowsError(try future.validate()) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .futureVersion(
                    maximumSupported: runtimeGenerationActiveSelectorVersion,
                    actual: runtimeGenerationActiveSelectorVersion + 1
                )
            )
        }
        let older = RuntimeGenerationActiveSelector(
            formatVersion: runtimeGenerationActiveSelectorVersion - 1,
            generationID: generationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            relativeDatabasePath: future.relativeDatabasePath,
            authorityManifestDigest: digest,
            authorityManifestFileSHA256: digest,
            verificationID: "verification-1",
            activationIntentID: "intent-1",
            priorGenerationID: nil,
            priorAuthorityManifestDigest: nil,
            preparedAtMilliseconds: 1
        )
        XCTAssertThrowsError(try older.validate()) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .unsupportedVersion(
                    expected: runtimeGenerationActiveSelectorVersion,
                    actual: runtimeGenerationActiveSelectorVersion - 1
                )
            )
        }
    }

    func testSelectorRequiresPriorIdentityPairAndExactV8Schema() throws {
        let generationID = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        let selector = RuntimeGenerationActiveSelector(
            formatVersion: runtimeGenerationActiveSelectorVersion,
            generationID: generationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            relativeDatabasePath: "Stores/\(generationID.rawValue)/Runtime.sqlite",
            authorityManifestDigest: digest,
            authorityManifestFileSHA256: digest,
            verificationID: "verification-1",
            activationIntentID: "intent-1",
            priorGenerationID: generationID,
            priorAuthorityManifestDigest: nil,
            preparedAtMilliseconds: 1
        )
        XCTAssertThrowsError(try selector.validate()) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .malformed(field: "active_selector")
            )
        }
    }

    func testOnlyCompiledLegacySQLiteVersionIsV1() {
        XCTAssertEqual(RuntimeLegacyCanonicalSchemaVersion.allCases, [.v1])
    }

    func testV1AcceptedCatalogIsNarrowAndSchemaOwned() {
        XCTAssertEqual(
            RuntimeGenerationLegacyImportService.testOnlyAcceptedCanonicalTables(for: .v1),
            ["runtime_aggregates", "runtime_receipts", "runtime_tombstones"]
        )
    }

    func testTypedSwiftDataPayloadBindsFamilyModelAndStableIdentity() throws {
        let record = try Self.appStateImportRecord()
        XCTAssertEqual(record.modelType, .appState)
        XCTAssertEqual(record.stableRecordID, AppStateSnapshot.default.id)
        XCTAssertEqual(record.envelope.sourceDisposition, .splitAuthorityAndRestoration)
        XCTAssertTrue(record.envelope.requiresReview)
        XCTAssertFalse(record.envelope.materializationAuthorized)
        try RuntimeGenerationLegacyImportService.testOnlyValidateSwiftDataRecord(record)
        let encoded = try RuntimeGenerationControlCodec.encode(record)
        XCTAssertEqual(
            try RuntimeGenerationControlCodec.decode(
                RuntimeSwiftDataImportRecord.self, from: encoded
            ),
            record
        )
    }

    func testSwiftDataTypedPayloadRejectsIdentityFamilyModelAndVersionAmbiguity() throws {
        let valid = try Self.appStateImportRecord()
        let differentIdentity = try RuntimeLegacySwiftDataSourceIdentity.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            modelType: .appState,
            orderingComponents: valid.envelope.payload.orderingComponents,
            stableRecordID: "different-id"
        )
        let differentModel = try RuntimeLegacySwiftDataSourceIdentity.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            modelType: .capture,
            orderingComponents: valid.envelope.payload.orderingComponents,
            stableRecordID: valid.stableRecordID
        )
        for identity in [differentIdentity, differentModel] {
            let malformedEnvelope = Self.replacingSourceIdentity(
                in: valid.envelope,
                with: identity
            )
            XCTAssertThrowsError(try malformedEnvelope.validate()) { error in
                XCTAssertEqual(
                    error as? RuntimeGenerationControlError,
                    .malformed(field: "swiftdata_envelope_payload_binding")
                )
            }
        }

        let futureEnvelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: "future",
            transportSessionDigest: digest,
            payload: valid.envelope.payload,
            relationshipClaims: valid.envelope.relationshipClaims
        )
        for malformed in [
            RuntimeSwiftDataImportRecord(payloadVersion: 2, envelope: valid.envelope),
            RuntimeSwiftDataImportRecord(payloadVersion: 1, envelope: futureEnvelope),
        ] {
            XCTAssertThrowsError(
                try RuntimeGenerationLegacyImportService
                    .testOnlyValidateSwiftDataRecord(malformed)
            ) { error in
                XCTAssertEqual(
                    error as? RuntimeGenerationControlError,
                    .importReviewRequired
                )
            }
        }
    }

    func testV1TypedMapperRejectsUnknownPayloadVersionAndChecksum() {
        let record = RuntimeLegacyDecodedRecord(
            table: "runtime_aggregates",
            primaryKey: [
                .init(column: "rowid", kind: "integer", value: "1"),
            ],
            values: [
                .init(column: "aggregate_kind", kind: "text", value: "goal"),
                .init(column: "aggregate_id", kind: "text", value: "goal-1"),
                .init(column: "revision", kind: "integer", value: "1"),
                .init(column: "payload_version", kind: "integer", value: "99"),
                .init(column: "payload", kind: "blob_base64", value: Data([1]).base64EncodedString()),
                .init(column: "payload_checksum", kind: "text", value: digest),
            ]
        )
        XCTAssertThrowsError(
            try RuntimeGenerationLegacyImportService.testOnlyMapCanonicalSQLiteRecord(
                record, version: .v1
            )
        ) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .malformed(field: "legacy_runtime_aggregates_payload")
            )
        }
    }

    func testAcceptedImportItemRequiresCanonicalTuple() throws {
        let item = try RuntimeGenerationControlRecordFactory.importItem(
            importID: "import-1",
            sourceRecordID: "record-1",
            sourceRecordDigest: digest,
            canonicalFamily: nil,
            canonicalID: nil,
            canonicalPayloadDigest: nil,
            disposition: .reviewableDiscovery,
            warningCodes: [],
            lossiness: .none
        )
        XCTAssertThrowsError(try item.validate()) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .malformed(field: "import_item")
            )
        }
    }

    func testRejectedImportItemCannotRetainCanonicalPayloadAuthority() throws {
        XCTAssertThrowsError(try RuntimeGenerationControlRecordFactory.importItem(
            importID: "import-1",
            sourceRecordID: "record-1",
            sourceRecordDigest: digest,
            canonicalFamily: "goal",
            canonicalID: "goal-1",
            canonicalPayloadDigest: digest,
            disposition: .ambiguous,
            warningCodes: ["unmapped_family"],
            lossiness: .lossyRequiresReview
        )) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .recordCorrupt(kind: "import_item_artifact_presence", id: "record-1")
            )
        }
    }

    func testImportReviewAuthorizationRequiresCountsToCoverDecisionSet() throws {
        let authorization = try RuntimeGenerationControlRecordFactory
            .importReviewAuthorization(
            id: "review-1",
            importID: "import-1",
            sourceDigest: digest,
            manifestDigest: digest,
            itemCount: 1,
            retainedForFutureMigrationItemCount: 1,
            retainedLossyForFutureMigrationItemCount: 1,
            rejectedItemCount: 0,
            orderedItemSetDigest: digest,
            orderedDecisionSetDigest: digest,
            lossinessConsequenceDigest: digest,
            dispositionIntentDigest: digest,
            nonce: "nonce-1",
            authorizedAtMilliseconds: 1,
            expiresAtMilliseconds: 2
        )
        XCTAssertThrowsError(
            try RuntimeGenerationControlRecordFactory.validate(authorization)
        ) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .importLossNotAccepted
            )
        }
    }

    func testRecoveryActionsDistinguishReadOnlyAndExplicitlyAuthorizedMutation() {
        XCTAssertNotEqual(
            RuntimeGenerationRecoveryAction.inspectReadOnly,
            .explicitlyAuthorizedReset
        )
        XCTAssertNotEqual(
            RuntimeGenerationRecoveryAction.exportOriginal,
            .rebuildDerivedState
        )
        XCTAssertEqual(Set(RuntimeGenerationRecoveryAction.allCases).count, 6)
    }

    func testWriterLeaseBlocksFinalBarrierAndBarrierBlocksAllWorkerKinds() async throws {
        let generation = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        let barrier = RuntimeGenerationBarrierAuthority(activeGenerationID: generation)
        let lease = try await barrier.beginUse(
            token: "writer-lease", generationID: generation, kind: .canonicalWriter
        )
        await XCTAssertThrowsRuntimeGenerationError(
            try await barrier.acquireFinalBarrier(
                token: "activation", expectedGenerationID: generation
            ),
            equals: .generationWorkerBarrierBusy
        )
        try await barrier.endUse(lease)
        let final = try await barrier.acquireFinalBarrier(
            token: "activation", expectedGenerationID: generation
        )
        for kind in [
            RuntimeGenerationUseKind.canonicalWriter,
            .projectionWorker, .searchWorker, .externalOperationWorker,
            .attachmentWorker, .maintenanceWorker,
        ] {
            await XCTAssertThrowsRuntimeGenerationError(
                try await barrier.beginUse(
                    token: "blocked-\(kind.rawValue)",
                    generationID: generation,
                    kind: kind
                ),
                equals: .generationWorkerBarrierBusy
            )
        }
        try await barrier.releaseUnchanged(final)
    }

    func testUnknownActivationBarrierCanOnlyResolveExactSource() async throws {
        let source = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        let target = try RuntimeStoreGenerationID(
            validating: "66666666-7777-4888-8999-aaaaaaaaaaaa"
        )
        let barrier = RuntimeGenerationBarrierAuthority(activeGenerationID: source)
        _ = try await barrier.acquireFinalBarrier(
            token: "unknown-activation", expectedGenerationID: source
        )
        await XCTAssertThrowsRuntimeGenerationError(
            try await barrier.resolveUnknownActivation(
                expectedSourceGenerationID: nil,
                resolution: .committed(target)
            ),
            equals: .generationWorkerBarrierMismatch
        )
        try await barrier.resolveUnknownActivation(
            expectedSourceGenerationID: source,
            resolution: .committed(target)
        )
        let currentGenerationID = await barrier.currentGenerationID()
        XCTAssertEqual(currentGenerationID, target)
    }

    func testEveryActivationCrashClassificationHasTruthfulRecoveryDisposition() throws {
        let selector = try validSelector()
        let bytes = RuntimeGenerationCrashByteEvidence(sha256: digest, byteCount: 42)
        let cases: [RuntimeGenerationActivationCrashClassification] = [
            .committed(selector), .unchanged, .selectorMissing,
            .selectorCorrupt(bytes), .selectorFutureVersion(bytes),
            .selectorUnavailable, .unexpectedSelector(selector),
            .targetAuthorityMissing, .targetAuthorityCorrupt(bytes),
            .targetAuthorityUnavailable, .targetDatabaseMissing,
            .targetDatabaseCorrupt, .targetDatabaseUnavailable,
            .controlAuthorityUnavailable,
            .splitAuthority, .externalAuthorityAmbiguous(observedSelectorFileSHA256: nil),
        ]
        XCTAssertEqual(cases.count, 16)
        for value in cases {
            let disposition = RuntimeGenerationRecoveryService
                .testOnlyQuarantineDisposition(for: value)
            XCTAssertFalse(disposition.code.isEmpty)
            XCTAssertTrue(disposition.actions.contains(.inspectReadOnly))
            XCTAssertTrue(disposition.actions.contains(.exportOriginal))
        }
    }

    func testCorruptAndMissingAuthorityExposeResetOnlyBehindAuthorization() throws {
        let bytes = RuntimeGenerationCrashByteEvidence(sha256: digest, byteCount: 42)
        for value in [
            RuntimeGenerationActivationCrashClassification.selectorCorrupt(bytes),
            .targetAuthorityMissing,
            .targetDatabaseMissing,
            .targetDatabaseCorrupt,
        ] {
            let disposition = RuntimeGenerationRecoveryService
                .testOnlyQuarantineDisposition(for: value)
            XCTAssertTrue(disposition.actions.contains(.explicitlyAuthorizedReset))
        }
        let ambiguous = RuntimeGenerationRecoveryService.testOnlyQuarantineDisposition(
            for: .splitAuthority
        )
        XCTAssertFalse(ambiguous.actions.contains(.explicitlyAuthorizedReset))
    }

    private func validSelector() throws -> RuntimeGenerationActiveSelector {
        let generationID = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        return RuntimeGenerationActiveSelector(
            formatVersion: runtimeGenerationActiveSelectorVersion,
            generationID: generationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            relativeDatabasePath: "Stores/\(generationID.rawValue)/Runtime.sqlite",
            authorityManifestDigest: digest,
            authorityManifestFileSHA256: digest,
            verificationID: "verification-1",
            activationIntentID: "intent-1",
            priorGenerationID: nil,
            priorAuthorityManifestDigest: nil,
            preparedAtMilliseconds: 1
        )
    }

    private static func appStateImportRecord() throws -> RuntimeSwiftDataImportRecord {
        let snapshot = AppStateSnapshot.default
        let snapshotColumn = try RuntimeLegacySwiftDataEncodedColumn.make(
            columnName: "snapshotData",
            encodedTypeName: "AppStateSnapshot",
            bytes: RuntimeGenerationControlCodec.encode(snapshot)
        )
        let payload = RuntimeLegacySwiftDataSourcePayload.appState(
            RuntimeLegacySwiftDataAppStatePayload(
                id: snapshot.id,
                preferredTabRaw: snapshot.preferredTab.rawValue,
                userDisplayName: snapshot.userDisplayName,
                appearancePreferenceRaw: snapshot.appearancePreference.rawValue,
                accentFamilyRaw: snapshot.accentFamily.rawValue,
                hasCompletedBootstrap: snapshot.hasCompletedBootstrap,
                lastBootstrapSourceRaw: snapshot.lastBootstrapSource?.rawValue,
                lastBootstrapAt: snapshot.lastBootstrapAt,
                lastSeedVersion: snapshot.lastSeedVersion,
                lastSeededAt: snapshot.lastSeededAt,
                lastOpenedGoalID: snapshot.lastOpenedGoalID,
                snapshot: snapshotColumn
            )
        )
        let envelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: String(repeating: "b", count: 64),
            payload: payload,
            relationshipClaims: []
        )
        return RuntimeSwiftDataImportRecord(payloadVersion: 1, envelope: envelope)
    }

    private static func replacingSourceIdentity(
        in envelope: RuntimeLegacySwiftDataSourceEnvelope,
        with sourceIdentity: RuntimeLegacySwiftDataSourceIdentity
    ) -> RuntimeLegacySwiftDataSourceEnvelope {
        RuntimeLegacySwiftDataSourceEnvelope(
            formatVersion: envelope.formatVersion,
            transportSessionDigest: envelope.transportSessionDigest,
            sourceIdentity: sourceIdentity,
            sourceDisposition: envelope.sourceDisposition,
            requiresReview: envelope.requiresReview,
            materializationAuthorized: envelope.materializationAuthorized,
            payload: envelope.payload,
            relationshipClaims: envelope.relationshipClaims,
            payloadDigest: envelope.payloadDigest,
            relationshipSetDigest: envelope.relationshipSetDigest,
            envelopeDigest: envelope.envelopeDigest
        )
    }
}
