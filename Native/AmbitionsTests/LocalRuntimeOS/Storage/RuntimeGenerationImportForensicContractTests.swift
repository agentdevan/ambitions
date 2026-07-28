@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationImportForensicContractTests: XCTestCase {
    private let digestA = String(repeating: "a", count: 64)
    private let digestB = String(repeating: "b", count: 64)

    func testAllTwentyOneSourceModelContractsAreReviewOnly() {
        let expected: Set<RuntimeLegacySwiftDataSourceModelType> = [
            .goal, .goalDraft, .goalPlan, .planSection, .step,
            .progressEvidence, .feedbackEvent, .capture, .reminder,
            .teachingSignal, .eventLedger, .commandExecution,
            .sideEffectLedger, .entityRevisionTombstone, .appState,
            .actionReceipt, .runtimeSnapshot, .lifeContext,
            .graphOperational, .graphProof, .graphProjection,
        ]
        let actual = Set(RuntimeLegacySwiftDataSourceModelType.allCases)

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 21)
        for modelType in actual {
            XCTAssertTrue(modelType.sourceDisposition.isReviewableDiscovery)
            XCTAssertFalse(modelType.sourceDisposition.isMaterializable)
        }
    }

    func testAllTwentyOneTypedRecordMappersPreservePayloadAndEnvelopeIdentity() throws {
        let mappedRecords = try Self.makeAllTypedExportRecords()

        XCTAssertEqual(mappedRecords.count, 21)
        XCTAssertEqual(Set(mappedRecords.map(\.modelType)), Set(
            RuntimeLegacySwiftDataSourceModelType.allCases
        ))
        for mapped in mappedRecords {
            XCTAssertEqual(mapped.export.payload.modelType, mapped.modelType)
            XCTAssertEqual(mapped.export.payload.stableRecordID, mapped.stableRecordID)
            XCTAssertEqual(
                mapped.export.relationshipClaims,
                try mapped.export.payload.derivedRelationshipClaims()
            )

            let envelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
                sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
                transportSessionDigest: digestA,
                payload: mapped.export.payload,
                relationshipClaims: mapped.export.relationshipClaims
            )
            try envelope.validate()
            XCTAssertEqual(envelope.payload, mapped.export.payload)
            XCTAssertEqual(envelope.relationshipClaims, mapped.export.relationshipClaims)
            XCTAssertEqual(envelope.sourceIdentity.modelType, mapped.modelType)
            XCTAssertEqual(envelope.sourceIdentity.stableRecordID, mapped.stableRecordID)
            XCTAssertEqual(
                envelope.sourceIdentity.orderingKey.components.count,
                mapped.modelType.cursorArity + 1
            )
            XCTAssertTrue(envelope.requiresReview)
            XCTAssertFalse(envelope.materializationAuthorized)
        }
    }

    func testEveryModelCursorOwnsExactArityAndStrictMonotonicOrdering() throws {
        let number = "00000000000000000001"
        let cases: [(RuntimeLegacySwiftDataSourceModelType, [String])] = [
            (.goal, ["time", number, "id-a"]),
            (.goalDraft, ["time", "id-a"]),
            (.goalPlan, ["goal", number, "id-a"]),
            (.planSection, ["goal", "plan", number, "id-a"]),
            (.step, ["goal", "plan", "section", number, "id-a"]),
            (.progressEvidence, ["time", "goal", "0", "", "id-a"]),
            (.feedbackEvent, ["time", "goal", "step", "id-a"]),
            (.capture, ["time", "id-a"]),
            (.reminder, ["0", "", "time", "id-a"]),
            (.teachingSignal, ["time", "id-a"]),
            (.eventLedger, ["time", "id-a"]),
            (.commandExecution, ["time", "id-a"]),
            (.sideEffectLedger, ["time", "id-a"]),
            (.entityRevisionTombstone, ["time", "kind", "entity", "revision", "id-a"]),
            (.appState, ["id-a"]),
            (.actionReceipt, ["occurred", "created", "id-a"]),
            (.runtimeSnapshot, ["time", "id-a"]),
            (.lifeContext, ["time", "id-a"]),
            (.graphOperational, ["time", "goal", "id-a"]),
            (.graphProof, ["goal", number, "proof", "id-a"]),
            (.graphProjection, ["time", "goal", "id-a"]),
        ]

        for (modelType, components) in cases {
            XCTAssertEqual(modelType.cursorArity, components.count)
            try modelType.validateCursorComponents(components)
            let prior = try RuntimeLegacySwiftDataModelCursor(
                modelType: modelType,
                components: components
            )
            var laterComponents = components
            laterComponents[laterComponents.count - 1] = "id-b"
            let later = try RuntimeLegacySwiftDataModelCursor(
                modelType: modelType,
                components: laterComponents
            )

            XCTAssertEqual(prior.count, components.count)
            XCTAssertEqual(prior[0], components[0])
            XCTAssertEqual(prior[prior.count - 1], "id-a")
            XCTAssertTrue(later.isStrictlyAfter(prior))
            XCTAssertFalse(prior.isStrictlyAfter(later))
        }
    }

    func testOptionalCursorNilAndPresentValuesHaveStableMonotonicBoundaries() throws {
        let evidenceWithoutStep = try RuntimeLegacySwiftDataModelCursor(
            modelType: .progressEvidence,
            components: ["time", "goal", "0", "", "evidence-a"]
        )
        let evidenceWithStep = try RuntimeLegacySwiftDataModelCursor(
            modelType: .progressEvidence,
            components: ["time", "goal", "1", "step", "evidence-b"]
        )
        XCTAssertTrue(evidenceWithStep.isStrictlyAfter(evidenceWithoutStep))

        let reminderWithoutTrigger = try RuntimeLegacySwiftDataModelCursor(
            modelType: .reminder,
            components: ["0", "", "created", "reminder-a"]
        )
        let reminderWithTrigger = try RuntimeLegacySwiftDataModelCursor(
            modelType: .reminder,
            components: ["1", "trigger", "created", "reminder-b"]
        )
        XCTAssertTrue(reminderWithTrigger.isStrictlyAfter(reminderWithoutTrigger))
        XCTAssertFalse(reminderWithTrigger.isStrictlyAfter(evidenceWithoutStep))
    }

    func testCursorRejectsEmptyWrongArityInvalidOptionalTagsAndMalformedNumbers() {
        let invalid: [(RuntimeLegacySwiftDataSourceModelType, [String])] = [
            (.appState, []),
            (.appState, [""]),
            (.goalDraft, ["time"]),
            (.progressEvidence, ["time", "goal", "0", "step", "id"]),
            (.progressEvidence, ["time", "goal", "2", "", "id"]),
            (.reminder, ["0", "trigger", "time", "id"]),
            (.reminder, ["2", "", "time", "id"]),
            (.goal, ["time", "1", "id"]),
            (.graphProof, ["goal", "-0000000000000000001", "proof", "id"]),
        ]

        for (modelType, components) in invalid {
            XCTAssertThrowsError(try RuntimeLegacySwiftDataModelCursor(
                modelType: modelType,
                components: components
            )) { error in
                XCTAssertEqual(
                    error as? RuntimeGenerationControlError,
                    .importReviewRequired
                )
            }
        }
    }

    func testMappedArtifactAuthenticatorAcceptsBoundV1AndV2Artifacts() throws {
        let v1 = try Self.makeMappedV1Fixture()
        XCTAssertNoThrow(try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
            item: v1.item,
            observedArtifact: v1.observedArtifact,
            decodedArtifact: v1.decodedArtifact
        ))

        let v2 = try Self.makeMappedV2Fixture()
        XCTAssertNoThrow(try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
            item: v2.item,
            observedArtifact: v2.observedArtifact,
            decodedArtifact: v2.decodedArtifact
        ))
    }

    func testV1ReceiptAndTombstoneRecordsMapAndAuthenticateAsTypedReviewArtifacts() throws {
        let fixtures = try [
            Self.makeMappedV1ReceiptFixture(),
            Self.makeMappedV1TombstoneFixture(),
        ]

        XCTAssertEqual(
            fixtures.map(\.decodedArtifact.canonicalFamily),
            ["receipt", "tombstone"]
        )
        for fixture in fixtures {
            XCTAssertEqual(fixture.decodedArtifact.formatVersion, 1)
            XCTAssertEqual(fixture.item.disposition, .reviewableDiscovery)
            XCTAssertFalse(fixture.item.materializationAuthorized)
            XCTAssertNoThrow(try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: fixture.item,
                observedArtifact: fixture.observedArtifact,
                decodedArtifact: fixture.decodedArtifact
            ))
        }
    }

    func testV1ReceiptAndTombstoneTamperFailsAuthenticatedBinding() throws {
        for fixture in try [
            Self.makeMappedV1ReceiptFixture(),
            Self.makeMappedV1TombstoneFixture(),
        ] {
            guard case let .canonicalSQLite(canonical) = fixture.decodedArtifact.payload else {
                return XCTFail("Expected canonical SQLite artifact")
            }
            let tamperedPayload = Data("legacy-v1-tamper".utf8)
            let tamperedCanonical = Self.replacingV1Canonical(
                canonical,
                payload: tamperedPayload,
                payloadChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: tamperedPayload)
            )
            let tampered = try Self.makeMappedFixture(
                formatVersion: 1,
                sourceSchema: fixture.decodedArtifact.sourceSchema,
                sourceRecordID: fixture.decodedArtifact.sourceRecordID,
                sourceRecordDigest: fixture.decodedArtifact.sourceRecordDigest,
                canonicalFamily: fixture.decodedArtifact.canonicalFamily,
                canonicalID: fixture.decodedArtifact.canonicalID,
                payloadVersion: fixture.decodedArtifact.payloadVersion,
                payload: .canonicalSQLite(tamperedCanonical),
                warningCodes: fixture.item.warningCodes,
                lossiness: fixture.item.lossiness
            )
            Self.assertImportReviewRequired {
                try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                    item: tampered.item,
                    observedArtifact: tampered.observedArtifact,
                    decodedArtifact: tampered.decodedArtifact
                )
            }
        }
    }

    func testMappedArtifactAuthenticatorRejectsObservedBindingAndDecodedTamper() throws {
        let fixture = try Self.makeMappedV2Fixture()
        let wrongObservation = try RuntimeGenerationArtifact(
            relativePath: fixture.observedArtifact.relativePath,
            sha256: digestB,
            byteCount: fixture.observedArtifact.byteCount,
            protectionClass: "complete"
        )
        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: fixture.item,
                observedArtifact: wrongObservation,
                decodedArtifact: fixture.decodedArtifact
            )
        }

        let wrongImport = RuntimeLegacyMappedImportArtifact(
            formatVersion: fixture.decodedArtifact.formatVersion,
            importID: "different-import",
            sourceSchema: fixture.decodedArtifact.sourceSchema,
            sourceRecordID: fixture.decodedArtifact.sourceRecordID,
            sourceRecordDigest: fixture.decodedArtifact.sourceRecordDigest,
            canonicalFamily: fixture.decodedArtifact.canonicalFamily,
            canonicalID: fixture.decodedArtifact.canonicalID,
            payloadVersion: fixture.decodedArtifact.payloadVersion,
            payload: fixture.decodedArtifact.payload
        )
        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: fixture.item,
                observedArtifact: fixture.observedArtifact,
                decodedArtifact: wrongImport
            )
        }

        let substitutedEnvelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: digestA,
            payload: try Self.appStatePayload(
                id: fixture.decodedArtifact.canonicalID,
                userDisplayName: "Substituted same-ID payload"
            ),
            relationshipClaims: []
        )
        let substitutedPayload = try Self.makeMappedFixture(
            formatVersion: fixture.decodedArtifact.formatVersion,
            sourceSchema: fixture.decodedArtifact.sourceSchema,
            sourceRecordID: fixture.decodedArtifact.sourceRecordID,
            sourceRecordDigest: fixture.decodedArtifact.sourceRecordDigest,
            canonicalFamily: fixture.decodedArtifact.canonicalFamily,
            canonicalID: fixture.decodedArtifact.canonicalID,
            payloadVersion: fixture.decodedArtifact.payloadVersion,
            payload: .swiftData(substitutedEnvelope),
            warningCodes: fixture.item.warningCodes,
            lossiness: fixture.item.lossiness
        )
        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: substitutedPayload.item,
                observedArtifact: substitutedPayload.observedArtifact,
                decodedArtifact: substitutedPayload.decodedArtifact
            )
        }

        let v1 = try Self.makeMappedV1Fixture()
        let wrongV1Format = RuntimeLegacyMappedImportArtifact(
            formatVersion: 2,
            importID: v1.decodedArtifact.importID,
            sourceSchema: v1.decodedArtifact.sourceSchema,
            sourceRecordID: v1.decodedArtifact.sourceRecordID,
            sourceRecordDigest: v1.decodedArtifact.sourceRecordDigest,
            canonicalFamily: v1.decodedArtifact.canonicalFamily,
            canonicalID: v1.decodedArtifact.canonicalID,
            payloadVersion: v1.decodedArtifact.payloadVersion,
            payload: v1.decodedArtifact.payload
        )
        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: v1.item,
                observedArtifact: v1.observedArtifact,
                decodedArtifact: wrongV1Format
            )
        }
    }

    func testMappedArtifactAuthenticatorRejectsSameIDRelationshipSubstitution() throws {
        let originalPayload = RuntimeLegacySwiftDataSourcePayload.planSection(.init(
            id: "section-1",
            goalID: "goal-1",
            planID: "plan-1",
            title: "Original section",
            summaryText: nil,
            kindRaw: PlanSectionKind.overview.rawValue,
            orderIndex: 0
        ))
        let fixture = try Self.makeMappedV2Fixture(payload: originalPayload)
        let substitutedPayload = RuntimeLegacySwiftDataSourcePayload.planSection(.init(
            id: "section-1",
            goalID: "goal-substituted",
            planID: "plan-1",
            title: "Original section",
            summaryText: nil,
            kindRaw: PlanSectionKind.overview.rawValue,
            orderIndex: 0
        ))
        let substitutedEnvelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: digestA,
            payload: substitutedPayload,
            relationshipClaims: try substitutedPayload.derivedRelationshipClaims()
        )
        let substituted = try Self.makeMappedFixture(
            formatVersion: fixture.decodedArtifact.formatVersion,
            sourceSchema: fixture.decodedArtifact.sourceSchema,
            sourceRecordID: fixture.decodedArtifact.sourceRecordID,
            sourceRecordDigest: fixture.decodedArtifact.sourceRecordDigest,
            canonicalFamily: fixture.decodedArtifact.canonicalFamily,
            canonicalID: fixture.decodedArtifact.canonicalID,
            payloadVersion: fixture.decodedArtifact.payloadVersion,
            payload: .swiftData(substitutedEnvelope),
            warningCodes: fixture.item.warningCodes,
            lossiness: fixture.item.lossiness
        )

        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: substituted.item,
                observedArtifact: substituted.observedArtifact,
                decodedArtifact: substituted.decodedArtifact
            )
        }
    }

    func testMappedArtifactAuthenticatorRejectsCoherentlyBoundUnsupportedV2PayloadVersion() throws {
        let fixture = try Self.makeMappedV2Fixture(payloadVersion: 2)
        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: fixture.item,
                observedArtifact: fixture.observedArtifact,
                decodedArtifact: fixture.decodedArtifact
            )
        }
    }

    func testMappedArtifactAuthenticatorRejectsCoherentlyReboundMapperMetadata() throws {
        let v1 = try Self.makeMappedV1Fixture()
        let v2 = try Self.makeMappedV2Fixture()
        let variants = try [
            Self.makeMappedFixture(
                copying: v1,
                warningCodes: ["manufactured_v1_warning"],
                lossiness: v1.item.lossiness
            ),
            Self.makeMappedFixture(
                copying: v1,
                warningCodes: v1.item.warningCodes,
                lossiness: .metadataOnly
            ),
            Self.makeMappedFixture(
                copying: v2,
                warningCodes: ["manufactured_v2_warning"],
                lossiness: v2.item.lossiness
            ),
            Self.makeMappedFixture(
                copying: v2,
                warningCodes: v2.item.warningCodes,
                lossiness: .metadataOnly
            ),
        ]

        for variant in variants {
            Self.assertImportReviewRequired {
                try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                    item: variant.item,
                    observedArtifact: variant.observedArtifact,
                    decodedArtifact: variant.decodedArtifact
                )
            }
        }
    }

    func testMappedArtifactAuthenticatorRejectsCoherentlyRehashedV1SemanticSubstitution() throws {
        let fixture = try Self.makeMappedV1Fixture()
        guard case let .canonicalSQLite(canonical) = fixture.decodedArtifact.payload else {
            XCTFail("Expected a canonical v1 fixture")
            return
        }
        let changedPrimaryKey = RuntimeLegacyDecodedRecord(
            table: canonical.sourceRecord.table,
            primaryKey: [.init(column: "rowid", kind: "integer", value: "2")],
            values: canonical.sourceRecord.values
        )
        let changedSourceTable = RuntimeLegacyDecodedRecord(
            table: "runtime_receipts",
            primaryKey: canonical.sourceRecord.primaryKey,
            values: canonical.sourceRecord.values
        )
        var changedValues = canonical.sourceRecord.values
        let revisionIndex = try XCTUnwrap(changedValues.firstIndex {
            $0.column == "revision"
        })
        changedValues[revisionIndex] = .init(
            column: "revision", kind: "integer", value: "2"
        )
        let valueSubstitutedRecord = RuntimeLegacyDecodedRecord(
            table: canonical.sourceRecord.table,
            primaryKey: canonical.sourceRecord.primaryKey,
            values: changedValues
        )
        let substitutedPayload = Data("coherently-rehashed-substitution".utf8)
        let variants: [(canonical: RuntimeLegacyCanonicalSQLiteArtifact, sourceSchema: String,
                        sourceRecordID: String, sourceRecordDigest: String,
                        family: String, canonicalID: String)] = [
            (canonical, "canonical.sqlite.v9", fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(canonical, table: "runtime_receipts"),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(canonical, family: "receipt"),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, "receipt",
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(canonical, canonicalID: "substituted-id"),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             "substituted-id"),
            (Self.replacingV1Canonical(canonical, sourceRecord: changedPrimaryKey),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(canonical, sourceRecord: changedSourceTable),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(canonical, sourceRecord: valueSubstitutedRecord),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(
                canonical,
                payload: substitutedPayload,
                payloadChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: substitutedPayload)
             ), fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (Self.replacingV1Canonical(canonical, payloadChecksum: digestB),
             fixture.decodedArtifact.sourceSchema, fixture.decodedArtifact.sourceRecordID,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (canonical, fixture.decodedArtifact.sourceSchema, digestB,
             fixture.decodedArtifact.sourceRecordDigest, fixture.decodedArtifact.canonicalFamily,
             fixture.decodedArtifact.canonicalID),
            (canonical, fixture.decodedArtifact.sourceSchema,
             fixture.decodedArtifact.sourceRecordID, digestB,
             fixture.decodedArtifact.canonicalFamily, fixture.decodedArtifact.canonicalID),
        ]

        for variant in variants {
            let tampered = try Self.makeMappedFixture(
                formatVersion: 1,
                sourceSchema: variant.sourceSchema,
                sourceRecordID: variant.sourceRecordID,
                sourceRecordDigest: variant.sourceRecordDigest,
                canonicalFamily: variant.family,
                canonicalID: variant.canonicalID,
                payloadVersion: canonical.payloadVersion,
                payload: .canonicalSQLite(variant.canonical),
                warningCodes: fixture.item.warningCodes,
                lossiness: fixture.item.lossiness
            )
            Self.assertImportReviewRequired {
                try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                    item: tampered.item,
                    observedArtifact: tampered.observedArtifact,
                    decodedArtifact: tampered.decodedArtifact
                )
            }
        }
        let versionSubstituted = Self.replacingV1Canonical(
            canonical,
            payloadVersion: 2
        )
        let versionFixture = try Self.makeMappedFixture(
            formatVersion: 1,
            sourceSchema: fixture.decodedArtifact.sourceSchema,
            sourceRecordID: fixture.decodedArtifact.sourceRecordID,
            sourceRecordDigest: fixture.decodedArtifact.sourceRecordDigest,
            canonicalFamily: fixture.decodedArtifact.canonicalFamily,
            canonicalID: fixture.decodedArtifact.canonicalID,
            payloadVersion: 2,
            payload: .canonicalSQLite(versionSubstituted),
            warningCodes: fixture.item.warningCodes,
            lossiness: fixture.item.lossiness
        )
        Self.assertImportReviewRequired {
            try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
                item: versionFixture.item,
                observedArtifact: versionFixture.observedArtifact,
                decodedArtifact: versionFixture.decodedArtifact
            )
        }
    }

    func testSemanticRecordIdentityExcludesTransportSessionIdentity() throws {
        let payload = try Self.appStatePayload()
        let first = RuntimeSwiftDataImportRecord(
            payloadVersion: 1,
            envelope: try .make(
                sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
                transportSessionDigest: digestA,
                payload: payload,
                relationshipClaims: []
            )
        )
        let second = RuntimeSwiftDataImportRecord(
            payloadVersion: 1,
            envelope: try .make(
                sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
                transportSessionDigest: digestB,
                payload: payload,
                relationshipClaims: []
            )
        )

        let firstSourceRecordID = try first.canonicalSourceRecordID()
        let secondSourceRecordID = try second.canonicalSourceRecordID()
        let firstSemanticDigest = try first.semanticRecordDigest()
        let secondSemanticDigest = try second.semanticRecordDigest()
        XCTAssertNotEqual(first.envelope.envelopeDigest, second.envelope.envelopeDigest)
        XCTAssertEqual(firstSourceRecordID, secondSourceRecordID)
        XCTAssertEqual(firstSemanticDigest, secondSemanticDigest)
    }

    func testSemanticRecordIdentityChangesWhenCanonicalPayloadChanges() throws {
        let original = RuntimeSwiftDataImportRecord(
            payloadVersion: 1,
            envelope: try .make(
                sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
                transportSessionDigest: digestA,
                payload: try Self.appStatePayload(userDisplayName: "Original local name"),
                relationshipClaims: []
            )
        )
        let changed = RuntimeSwiftDataImportRecord(
            payloadVersion: 1,
            envelope: try .make(
                sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
                transportSessionDigest: digestA,
                payload: try Self.appStatePayload(userDisplayName: "Changed local name"),
                relationshipClaims: []
            )
        )

        XCTAssertEqual(
            try original.canonicalSourceRecordID(),
            try changed.canonicalSourceRecordID()
        )
        XCTAssertNotEqual(
            try original.semanticRecordDigest(),
            try changed.semanticRecordDigest()
        )
    }

    func testNestedReferenceTamperIsRejectedByEnvelopeDerivation() throws {
        let payload = RuntimeLegacySwiftDataSourcePayload.planSection(
            RuntimeLegacySwiftDataPlanSectionPayload(
                id: "section-1",
                goalID: "goal-1",
                planID: "plan-1",
                title: "Section",
                summaryText: nil,
                kindRaw: PlanSectionKind.overview.rawValue,
                orderIndex: 0
            )
        )
        let claims = try payload.derivedRelationshipClaims()
        XCTAssertEqual(claims.count, 2)
        let first = try XCTUnwrap(claims.first)
        let tampered = try RuntimeLegacySwiftDataRelationshipClaim.make(
            sourceColumnName: first.sourceColumnName,
            kind: first.kind,
            targetModelType: first.targetModelType,
            targetTypeName: first.targetTypeName,
            targetStableID: "different-goal",
            isRequired: first.isRequired,
            orderIndex: first.orderIndex
        )
        let altered = [tampered] + Array(claims.dropFirst())

        XCTAssertThrowsError(try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: digestA,
            payload: payload,
            relationshipClaims: altered
        )) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .malformed(field: "swiftdata_relationship_claim_derivation")
            )
        }
    }

    func testForensicCopyIsDurableExplicitlyNonrestorableAndSourcePreserving() throws {
        try withForensicFixture { fixture in
            let sourceBytes = Data("forensic-source".utf8)
            try fixture.writeSource(named: "Runtime.sqlite", bytes: sourceBytes)

            let result = try RuntimeGenerationForensicArtifactPreserver.preserve(
                sources: [("database", fixture.sourceURL("Runtime.sqlite"))],
                evidenceDirectoryURL: fixture.evidenceURL,
                evidenceDirectoryRelativePath: "Evidence"
            )
            let reference = try XCTUnwrap(result.references.only)

            XCTAssertEqual(reference.preservation, .copied)
            XCTAssertEqual(reference.captureCoherence, .rawSequentialNoncoherent)
            XCTAssertEqual(reference.durability, .durable)
            XCTAssertEqual(reference.isRestorable, false)
            XCTAssertNotNil(reference.copiedArtifact)
            XCTAssertEqual(result.observations.only?.reference, reference)
            XCTAssertNotNil(result.observations.only?.observedArtifact)
            XCTAssertTrue(result.copiedArtifacts.isEmpty)
            XCTAssertEqual(
                try Data(contentsOf: fixture.sourceURL("Runtime.sqlite")),
                sourceBytes
            )
        }
    }

    func testForensicPublishedEvidenceBindsObservationToPublishedBytesAndLeavesNoStagingEntry() throws {
        try withForensicFixture { fixture in
            let sourceBytes = Data("forensic-published-evidence".utf8)
            try fixture.writeSource(named: "Runtime.sqlite", bytes: sourceBytes)

            let result = try RuntimeGenerationForensicArtifactPreserver.preserve(
                sources: [("database", fixture.sourceURL("Runtime.sqlite"))],
                evidenceDirectoryURL: fixture.evidenceURL,
                evidenceDirectoryRelativePath: "Evidence"
            )
            let observation = try XCTUnwrap(result.observations.only)
            let observed = try XCTUnwrap(observation.observedArtifact)
            let reference = observation.reference
            let publishedURL = fixture.rootURL.appendingPathComponent(observed.relativePath)

            XCTAssertEqual(reference.preservedRelativePath, observed.relativePath)
            XCTAssertEqual(reference.copiedArtifact, observed.semanticArtifact())
            XCTAssertEqual(try Data(contentsOf: publishedURL), sourceBytes)
            XCTAssertEqual(
                LocalRuntimeStorageChecksum.sha256Hex(for: try Data(contentsOf: publishedURL)),
                observed.sha256
            )
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: publishedURL,
                artifact: "published_forensic_evidence"
            )
            let evidenceEntryNames = try FileManager.default.contentsOfDirectory(
                atPath: fixture.evidenceURL.path
            )
            XCTAssertFalse(evidenceEntryNames.contains { $0.contains(".staging-") })
        }
    }

    func testForensicAggregateBudgetSkipsOnlyTheOverflowingSource() throws {
        try withForensicFixture { fixture in
            try fixture.writeSource(named: "one", bytes: Data([0x01, 0x02]))
            try fixture.writeSource(named: "two", bytes: Data([0x03, 0x04]))

            let result = try RuntimeGenerationForensicArtifactPreserver.preserve(
                sources: [
                    ("one", fixture.sourceURL("one")),
                    ("two", fixture.sourceURL("two")),
                ],
                evidenceDirectoryURL: fixture.evidenceURL,
                evidenceDirectoryRelativePath: "Evidence",
                maximumSourceBytes: 2,
                maximumCaptureSetBytes: 3
            )

            XCTAssertEqual(result.references.map(\.preservation), [
                .copied, .skippedBudgetExceeded,
            ])
            XCTAssertEqual(result.references[1].durability, .notApplicable)
            XCTAssertEqual(result.references[1].isRestorable, false)
            XCTAssertNotNil(result.references[1].failureFingerprint)
        }
    }

    func testForensicSourceCountLimitUsesExactTypedError() throws {
        try withForensicFixture { fixture in
            let sources = (0 ... RuntimeGenerationForensicArtifactPreserver.maximumSourceCount)
                .map { index in
                    ("source-\(index)", fixture.sourceURL("missing-\(index)"))
                }
            XCTAssertThrowsError(try RuntimeGenerationForensicArtifactPreserver.preserve(
                sources: sources,
                evidenceDirectoryURL: fixture.evidenceURL,
                evidenceDirectoryRelativePath: "Evidence"
            )) { error in
                XCTAssertEqual(
                    error as? RuntimeGenerationForensicBudgetError,
                    .sourceCountExceeded(
                        maximumCount:
                            RuntimeGenerationForensicArtifactPreserver.maximumSourceCount,
                        actualCount: sources.count
                    )
                )
            }
        }
    }

    func testCancellationPublishesDurableNonrestorablePartialEvidence() async throws {
        try await withForensicFixture { fixture in
            try fixture.writeSource(
                named: "Runtime.sqlite",
                bytes: Data(repeating: 0x5a, count: 1_024)
            )
            let task = Task { () -> ForensicCancellationOutcome in
                withUnsafeCurrentTask { $0?.cancel() }
                do {
                    _ = try RuntimeGenerationForensicArtifactPreserver.preserve(
                        sources: [("database", fixture.sourceURL("Runtime.sqlite"))],
                        evidenceDirectoryURL: fixture.evidenceURL,
                        evidenceDirectoryRelativePath: "Evidence"
                    )
                    return .unexpectedSuccess
                } catch is CancellationError {
                    return .cancelled
                } catch {
                    return .unexpectedError(String(reflecting: type(of: error)))
                }
            }

            let outcome = await task.value
            XCTAssertEqual(outcome, .cancelled)
            let entries = try FileManager.default.contentsOfDirectory(
                at: fixture.evidenceURL,
                includingPropertiesForKeys: nil
            )
            let journalURL = try XCTUnwrap(entries.first {
                $0.lastPathComponent.hasSuffix(".partial-0.json")
            })
            let reference = try RuntimeGenerationControlCodec.decode(
                RuntimeGenerationForensicArtifactReference.self,
                from: Data(contentsOf: journalURL)
            )
            XCTAssertEqual(reference.preservation, .partial)
            XCTAssertEqual(reference.durability, .durable)
            XCTAssertEqual(reference.isRestorable, false)
            XCTAssertNotNil(reference.preservedRelativePath)
        }
    }
}

private enum ForensicCancellationOutcome: Sendable, Equatable {
    case cancelled
    case unexpectedSuccess
    case unexpectedError(String)
}

private struct TypedExportFixture: Sendable {
    let modelType: RuntimeLegacySwiftDataSourceModelType
    let stableRecordID: String
    let export: RuntimeSwiftDataExportRecord
}

private struct MappedArtifactFixture: Sendable {
    let item: RuntimeLegacyImportItem
    let observedArtifact: RuntimeGenerationArtifact
    let decodedArtifact: RuntimeLegacyMappedImportArtifact
}

private struct RuntimeGenerationForensicTestFixture: Sendable {
    let rootURL: URL
    let sourcesURL: URL
    let evidenceURL: URL

    func sourceURL(_ name: String) -> URL {
        sourcesURL.appendingPathComponent(name)
    }

    func writeSource(named name: String, bytes: Data) throws {
        let url = sourceURL(name)
        try bytes.write(to: url, options: .withoutOverwriting)
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: url,
            artifact: "forensic_test_source"
        )
    }
}

private extension RuntimeGenerationImportForensicContractTests {
    static func appStatePayload(
        id: String = AppStateSnapshot.default.id,
        userDisplayName: String? = nil
    ) throws -> RuntimeLegacySwiftDataSourcePayload {
        let baseline = AppStateSnapshot.default
        let snapshot = AppStateSnapshot(
            id: id,
            preferredTab: baseline.preferredTab,
            userDisplayName: userDisplayName ?? baseline.userDisplayName,
            appearancePreference: baseline.appearancePreference,
            accentFamily: baseline.accentFamily,
            reviewCadenceDays: baseline.reviewCadenceDays,
            localOnlyModeEnabled: baseline.localOnlyModeEnabled,
            hasCompletedBootstrap: baseline.hasCompletedBootstrap,
            hasCompletedOnboarding: baseline.hasCompletedOnboarding,
            onboardingVersion: baseline.onboardingVersion,
            onboardingCompletedAt: baseline.onboardingCompletedAt,
            onboardingEntryChoice: baseline.onboardingEntryChoice,
            lastBootstrapSource: baseline.lastBootstrapSource,
            lastBootstrapAt: baseline.lastBootstrapAt,
            lastSeedVersion: baseline.lastSeedVersion,
            lastSeededAt: baseline.lastSeededAt,
            lastImportSummary: baseline.lastImportSummary,
            lastOpenedGoalID: baseline.lastOpenedGoalID,
            goalPriorityOrder: baseline.goalPriorityOrder
        )
        return .appState(RuntimeLegacySwiftDataAppStatePayload(
            id: id,
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
            snapshot: try .make(
                columnName: "snapshotData",
                encodedTypeName: "AppStateSnapshot",
                bytes: RuntimeGenerationControlCodec.encode(snapshot)
            )
        ))
    }

    static func makeAllTypedExportRecords() throws -> [TypedExportFixture] {
        guard let sourceFixture = GoalEngineFixtures.fixture(
            id: "clear-timed-self-goal"
        ) else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let planned: GoalPlannedResult
        switch sourceFixture.result {
        case let .planned(value):
            planned = value
        case .starterPlanned, .clarificationRequired, .blocked:
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let timestamp = GoalEngineFixtures.fixedNow
        let goal = Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: planned.plan.goalID,
            revision: 1,
            createdAt: timestamp,
            updatedAt: timestamp,
            state: .active,
            title: planned.draft.title,
            summary: planned.draft.summary,
            mode: planned.draft.mode,
            relationshipKind: planned.draft.relationshipKind,
            actor: planned.draft.actor,
            parentGoalID: planned.draft.parentGoalID,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: planned.draft.tags,
            timing: planned.draft.timing,
            planningStrategy: planned.draft.planningStrategy,
            progressStrategy: planned.draft.progressStrategy,
            plan: planned.plan,
            lifeGraph: planned.draft.lifeGraph
        )
        let draft = PersistedGoalDraft(
            id: "draft-1",
            createdAt: timestamp,
            updatedAt: timestamp,
            draft: planned.draft,
            classification: nil,
            clarification: planned.metadata.clarification,
            stagedPlan: planned.plan,
            assumptions: [],
            blockers: [],
            metadata: planned.metadata,
            plannedGoalID: goal.id,
            latestResultKind: .planned
        )
        guard let section = planned.plan.sections.first,
              let step = section.steps.first else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let evidence = ProgressEvidence(
            id: "evidence-1",
            goalID: goal.id,
            stepID: step.id,
            evidenceKind: .stepCompleted,
            source: .manual,
            capturedAt: timestamp,
            progressDelta: 0.2,
            confidenceDelta: 0.1,
            minutesInvested: 25,
            note: "Mapper parity"
        )
        let feedback = GoalFeedbackEvent.completed(
            base: GoalFeedbackEventBase(
                id: "feedback-1",
                stepID: step.id,
                occurredAt: timestamp,
                note: "Completed"
            ),
            actualDuration: 25,
            effortLevel: .medium,
            confidenceDelta: 0.1
        )
        let capture = Capture(
            id: "capture-1",
            createdAt: timestamp,
            updatedAt: timestamp,
            rawText: "Local capture",
            sourceType: .todayQuickCapture,
            status: .goalBound,
            linkedGoalID: goal.id
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .step,
            id: step.id,
            parentContextID: goal.id,
            label: step.title,
            sourceDomain: .today
        )
        let reminder = ReminderTrigger(
            id: "reminder-1",
            createdAt: timestamp,
            updatedAt: timestamp,
            title: "Do the next step",
            summary: "Local reminder",
            triggerAt: "2026-04-15T12:00:00Z",
            kind: .stepAttachment,
            deliveryPolicy: .inAppAndLocalNotification,
            state: .scheduled,
            source: ReminderSource(
                record: ReminderSourceRecord(
                    id: "source.reminder.reminder-1",
                    entityTitle: "Do the next step",
                    locator: "local://reminders/reminder-1",
                    provenanceKind: .step,
                    isOfficial: false
                ),
                sourceObject: sourceObject,
                surfaceTitle: "Today",
                inspectionSummary: "Local source",
                notes: []
            ),
            attachment: ReminderAttachment(
                kind: .step,
                object: sourceObject,
                note: "Attached locally"
            ),
            receiptID: "receipt-1",
            replayTraceID: "trace-1"
        )
        let teaching = GoalTeachingSignal(
            id: "teaching-1",
            goalID: goal.id,
            createdAt: timestamp,
            updatedAt: timestamp,
            source: .explicitManualCorrection,
            kind: .goalSubjectCorrection,
            disposition: .active,
            anchor: GoalTeachingStableAnchor(
                artifactKind: .goalSubjectField,
                canonicalField: .goalSubject,
                candidateID: nil,
                stageID: nil,
                stepID: nil,
                targetFingerprint: "goal_subject",
                contradictionCode: nil,
                contradictionArtifactRefs: []
            ),
            payload: .goalSubject(GoalTeachingGoalSubjectCorrection(
                correctedCanonicalIntent: goal.title
            )),
            applicationKey: "goal-1##goal_subject",
            userNote: nil
        )
        let event = EventLedgerEntry.fromProgressEvidence(evidence)
        let command = AmbitionsCommand(
            id: "command-1",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(goalID: goal.id, stepID: step.id),
            createdAt: timestamp,
            actor: .user,
            sourceSurface: "today",
            privacy: .privateUserText
        )
        let commandExecution = AmbitionsCommandExecutionRecord(
            command: command,
            result: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Completed locally",
                target: command.target,
                eventLedgerEntryIDs: [event.id]
            ),
            recordedAt: timestamp
        )
        let sideEffect = SideEffectLedgerRecord(
            decision: SafeAutomationPolicyEvaluator().evaluate(
                SafeAutomationProposedAction(
                    kind: .archiveItem,
                    sourceDomain: .capture,
                    targetObjects: [LifeGraphObjectReference(
                        kind: .capture,
                        id: capture.id,
                        label: capture.rawText,
                        sourceDomain: .capture
                    )]
                )
            ),
            commandID: command.id,
            occurredAt: timestamp
        )
        let tombstone = EntityRevisionTombstone(
            id: "tombstone-1",
            entityKind: .goal,
            entityID: goal.id,
            revisionMarker: "rev-2",
            reason: .deleted,
            recordedAt: timestamp,
            privacyClass: .privateProof,
            sourceRecordID: "source-1",
            receiptID: "receipt-1",
            replayTraceID: "trace-1"
        )
        let appState = AppStateSnapshot.default
        let receipt = ActionReceipt(
            id: "receipt-1",
            resultState: .completed,
            title: "Step completed",
            summary: "The next step completed locally.",
            sourceDomain: .today,
            occurredAt: timestamp,
            affectedObjects: [sourceObject],
            changedFacts: [ActionReceiptChangedFact(
                id: "receipt-1.changed",
                kind: .completedTask,
                object: sourceObject,
                summary: "Step completed."
            )],
            correctionAvailability: .unavailable,
            undoAvailability: .availableLocal
        )
        let snapshot = RuntimeSnapshotLedgerEnvelope(
            generatedAt: timestamp,
            sourceRecordIDs: ["source-1"],
            receiptIDs: [receipt.id],
            replayTraceIDs: ["trace-1"],
            recommendationInputReferenceIDs: ["recommendation-1"],
            proofInputReferenceIDs: ["proof-1"],
            afep02LineageReferenceIDs: ["afep02-1"]
        )
        let lifeContext = LifeContextFixtureProfiles.emptyContext()
        let graphOperational = AmbitionGraphOperationalRecord(
            id: "graph-operational-1",
            surface: .today,
            sourceSnapshotID: snapshot.id,
            ambitionID: goal.id,
            generatedAt: timestamp,
            localProjectionOnly: true,
            privacyClass: .privateProof,
            sourceObjectIDs: [goal.id],
            receiptIDs: [receipt.id],
            replayTraceIDs: ["trace-1"],
            sourceFields: ["title"]
        )
        let graphProof = AmbitionGraphProofRecord(
            proofID: "proof-1",
            sourceSnapshotID: snapshot.id,
            ambitionID: goal.id,
            generatedAt: timestamp,
            localProjectionOnly: true,
            privacyClass: .privateProof,
            sourceObjectIDs: [goal.id],
            receiptIDs: [receipt.id],
            replayTraceIDs: ["trace-1"],
            sourceFields: ["title"]
        )
        let graphProjection = AmbitionGraphProjectionRecord(
            id: "graph-projection-1",
            surface: .today,
            sourceSnapshotID: snapshot.id,
            ambitionID: goal.id,
            generatedAt: timestamp,
            localProjectionOnly: true,
            privacyClass: .privateProof,
            sourceObjectIDs: [goal.id],
            receiptIDs: [receipt.id],
            replayTraceIDs: ["trace-1"],
            sourceFields: ["title"]
        )
        var fixtures: [TypedExportFixture] = []

        func append(
            _ modelType: RuntimeLegacySwiftDataSourceModelType,
            _ stableRecordID: String,
            _ export: RuntimeSwiftDataExportRecord
        ) {
            fixtures.append(TypedExportFixture(
                modelType: modelType,
                stableRecordID: stableRecordID,
                export: export
            ))
        }

        append(.goal, goal.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.goalRecord(from: goal)
        ))
        append(.goalDraft, draft.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.draftRecord(from: draft)
        ))
        append(.goalPlan, planned.plan.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.planRecord(from: planned.plan)
        ))
        append(.planSection, section.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.sectionRecord(from: section, planID: planned.plan.id)
        ))
        append(.step, step.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.stepRecord(
                from: step,
                goalID: goal.id,
                planID: planned.plan.id,
                orderIndex: 0
            )
        ))
        append(.progressEvidence, evidence.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.evidenceRecord(from: evidence)
        ))
        append(.feedbackEvent, "feedback-1", try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.feedbackRecord(from: feedback, goalID: goal.id)
        ))
        append(.capture, capture.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.captureRecord(from: capture)
        ))
        append(.reminder, reminder.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.reminderRecord(from: reminder)
        ))
        append(.teachingSignal, teaching.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.teachingSignalRecord(from: teaching)
        ))
        append(.eventLedger, event.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.eventLedgerRecord(from: event)
        ))
        append(.commandExecution, commandExecution.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.commandExecutionRecord(from: commandExecution)
        ))
        append(.sideEffectLedger, sideEffect.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.sideEffectLedgerStorageRecord(from: sideEffect)
        ))
        append(.entityRevisionTombstone, tombstone.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.entityRevisionTombstoneRecord(from: tombstone)
        ))
        append(.appState, appState.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.appStateRecord(from: appState)
        ))
        append(.actionReceipt, receipt.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.actionReceiptHistoryRecord(
                from: ActionReceiptHistoryRecord(receipt: receipt)
            )
        ))
        append(.runtimeSnapshot, snapshot.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.runtimeSnapshotLedgerRecord(from: snapshot)
        ))
        append(.lifeContext, lifeContext.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            LifeContextBundleRecord(
                id: lifeContext.id,
                schemaVersion: lifeContextBundleRecordSchemaVersion,
                createdAt: lifeContext.createdAt,
                updatedAt: lifeContext.updatedAt,
                deletedAt: lifeContext.deletedAt,
                snapshotData: try PersistenceCoding.encode(lifeContext)
            )
        ))
        append(.graphOperational, graphOperational.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.ambitionGraphOperationalRecordModel(from: graphOperational)
        ))
        append(.graphProof, graphProof.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.ambitionGraphProofRecordModel(from: graphProof)
        ))
        append(.graphProjection, graphProjection.id, try RuntimeSwiftDataTypedExporter.TypedEnvelopeMapper.map(
            RepositoryMapping.ambitionGraphProjectionRecordModel(from: graphProjection)
        ))

        return fixtures
    }

    static func makeMappedV1Fixture() throws -> MappedArtifactFixture {
        let aggregateID = try RuntimeAggregateID(validating: "capture-1")
        let objectID = try RuntimeDomainObjectID(validating: "capture-1")
        let state = RuntimeCanonicalAggregateState(
            aggregate: RuntimeSemanticAggregate(kind: .capture, id: aggregateID),
            revision: 1,
            lifecycle: .active,
            transition: .update,
            commandPayload: .capture(CaptureCommand(
                action: .archive,
                target: AmbitionsCommandTarget(captureID: aggregateID.rawValue),
                content: RuntimeCommandContent(
                    AmbitionsCommandPayload(title: "Authenticate legacy capture")
                )
            )),
            changedObjectIDs: [objectID]
        )
        let payload = try RuntimeCanonicalAggregateStateCodec().encode(state)
        let checksum = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        let sourceRecord = RuntimeLegacyDecodedRecord(
            table: "runtime_aggregates",
            primaryKey: [RuntimeLegacyDecodedValue(
                column: "rowid", kind: "integer", value: "1"
            )],
            values: [
                .init(column: "aggregate_kind", kind: "text", value: "capture"),
                .init(column: "aggregate_id", kind: "text", value: aggregateID.rawValue),
                .init(column: "revision", kind: "integer", value: "1"),
                .init(column: "payload_version", kind: "integer", value: "1"),
                .init(column: "payload", kind: "blob_base64", value: payload.base64EncodedString()),
                .init(column: "payload_checksum", kind: "text", value: checksum),
            ]
        )
        let mapped = try XCTUnwrap(RuntimeLegacyCanonicalSQLiteMapper.map(
            sourceRecord,
            sourceSchemaVersion: .v1
        ))
        guard case let .canonicalSQLite(canonical) = mapped.payload else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        return try makeMappedFixture(
            formatVersion: 1,
            sourceSchema: "canonical.sqlite.v1",
            sourceRecordID: mapped.sourceRecordID,
            sourceRecordDigest: mapped.sourceRecordDigest,
            canonicalFamily: mapped.canonicalFamily,
            canonicalID: mapped.canonicalID,
            payloadVersion: mapped.payloadVersion,
            payload: mapped.payload,
            warningCodes: mapped.warningCodes,
            lossiness: mapped.lossiness
        )
    }

    static func makeMappedV1ReceiptFixture() throws -> MappedArtifactFixture {
        let digestA = String(repeating: "a", count: 64)
        let digestB = String(repeating: "b", count: 64)
        let receiptID = try RuntimeReceiptID(validating: "receipt-legacy-1")
        let commandID = try RuntimeCommandID(validating: "command-legacy-1")
        let aggregateID = try RuntimeAggregateID(validating: "capture-legacy-1")
        let lineage = RuntimeAuthorityLineageReference(
            eventID: try RuntimeEventID(validating: "event-legacy-1"),
            eventSequence: 3,
            eventHash: digestA
        )
        let core = try RuntimeCommittedReceiptCodec.makeCore(RuntimeCommittedReceiptCoreFacts(
            version: runtimeCommittedReceiptCoreVersion,
            receiptID: receiptID,
            preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "preparation-legacy-1")),
            commandID: commandID,
            lineage: lineage,
            correlationID: try XCTUnwrap(RuntimeCorrelationID(rawValue: "capture-legacy-1")),
            outcome: .changed,
            committedAt: Date(timeIntervalSince1970: 1_700_000_000),
            privacy: RuntimeCommittedReceiptPrivacy(classification: .privateUserText, localOnly: true),
            objects: [RuntimeCommittedReceiptObjectLink(
                aggregate: RuntimeSemanticAggregate(kind: .capture, id: aggregateID),
                priorRevision: 0,
                terminalRevision: 1,
                lifecycle: .active,
                transition: .update,
                stateDigest: digestB
            )],
            artifacts: [],
            presentationFacts: [.objectChanged(family: .capture, lifecycle: .active)],
            compensation: .noncompensable(
                evidenceDigest: digestA,
                evidence: RuntimeIrreversibilityEvidence(
                    version: 1,
                    permanence: .currentRuntimeUnsupported,
                    reason: .unsupportedSemanticInverse,
                    commandFamily: "capture",
                    commandAction: "capture.update"
                )
            ),
            retention: [],
            confirmationToken: nil,
            confirmationDecisionDigest: nil
        ))
        let payload = try RuntimeCommittedReceiptCodec.encode(core)
        let record = RuntimeLegacyDecodedRecord(
            table: "runtime_receipts",
            primaryKey: [.init(column: "rowid", kind: "integer", value: "1")],
            values: [
                .init(column: "receipt_id", kind: "text", value: receiptID.rawValue),
                .init(column: "command_id", kind: "text", value: commandID.rawValue),
                .init(column: "receipt_version", kind: "integer", value: String(runtimeCommittedReceiptCoreVersion)),
                .init(column: "payload", kind: "blob_base64", value: payload.base64EncodedString()),
                .init(column: "payload_checksum", kind: "text", value: LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
            ]
        )
        return try mappedV1Fixture(from: record)
    }

    static func makeMappedV1TombstoneFixture() throws -> MappedArtifactFixture {
        let digestA = String(repeating: "a", count: 64)
        let digestB = String(repeating: "b", count: 64)
        let objectID = try RuntimeDomainObjectID(validating: "capture-tombstone-legacy-1")
        let draft = RuntimeCanonicalTombstoneDraft(
            objectID: objectID,
            family: RuntimeSemanticAggregateKind.capture.rawValue,
            terminalRevision: 2,
            lineage: RuntimeAuthorityLineageReference(
                eventID: try RuntimeEventID(validating: "event-tombstone-legacy-1"),
                eventSequence: 4,
                eventHash: digestA
            ),
            authority: RuntimeCanonicalTombstoneAuthority(
                reason: .archived,
                predecessorDigest: digestB,
                retentionDisposition: .retainedUntilDownstreamPolicy,
                recoveryDisposition: .explicitTypedRestorationRequired
            )
        )
        let payload = try RuntimeCommittedReceiptCodec.encode(draft)
        let record = RuntimeLegacyDecodedRecord(
            table: "runtime_tombstones",
            primaryKey: [.init(column: "rowid", kind: "integer", value: "1")],
            values: [
                .init(column: "object_kind", kind: "text", value: RuntimeSemanticAggregateKind.capture.rawValue),
                .init(column: "object_id", kind: "text", value: objectID.rawValue),
                .init(column: "tombstone_version", kind: "integer", value: "1"),
                .init(column: "revision", kind: "integer", value: "2"),
                .init(column: "payload", kind: "blob_base64", value: payload.base64EncodedString()),
                .init(column: "checksum", kind: "text", value: LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
            ]
        )
        return try mappedV1Fixture(from: record)
    }

    static func mappedV1Fixture(
        from sourceRecord: RuntimeLegacyDecodedRecord
    ) throws -> MappedArtifactFixture {
        let mapped = try XCTUnwrap(RuntimeLegacyCanonicalSQLiteMapper.map(
            sourceRecord,
            sourceSchemaVersion: .v1
        ))
        return try makeMappedFixture(
            formatVersion: 1,
            sourceSchema: "canonical.sqlite.v1",
            sourceRecordID: mapped.sourceRecordID,
            sourceRecordDigest: mapped.sourceRecordDigest,
            canonicalFamily: mapped.canonicalFamily,
            canonicalID: mapped.canonicalID,
            payloadVersion: mapped.payloadVersion,
            payload: mapped.payload,
            warningCodes: mapped.warningCodes,
            lossiness: mapped.lossiness
        )
    }

    static func replacingV1Canonical(
        _ value: RuntimeLegacyCanonicalSQLiteArtifact,
        table: String? = nil,
        family: String? = nil,
        canonicalID: String? = nil,
        payloadVersion: Int? = nil,
        payload: Data? = nil,
        payloadChecksum: String? = nil,
        sourceRecord: RuntimeLegacyDecodedRecord? = nil
    ) -> RuntimeLegacyCanonicalSQLiteArtifact {
        RuntimeLegacyCanonicalSQLiteArtifact(
            sourceSchemaVersion: value.sourceSchemaVersion,
            table: table ?? value.table,
            canonicalFamily: family ?? value.canonicalFamily,
            canonicalID: canonicalID ?? value.canonicalID,
            payloadVersion: payloadVersion ?? value.payloadVersion,
            payload: payload ?? value.payload,
            payloadChecksum: payloadChecksum ?? value.payloadChecksum,
            sourceRecord: sourceRecord ?? value.sourceRecord
        )
    }

    static func makeMappedV2Fixture(
        payload suppliedPayload: RuntimeLegacySwiftDataSourcePayload? = nil,
        payloadVersion: Int = 1
    ) throws -> MappedArtifactFixture {
        let payload: RuntimeLegacySwiftDataSourcePayload
        if let suppliedPayload {
            payload = suppliedPayload
        } else {
            payload = try appStatePayload()
        }
        let envelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: String(repeating: "a", count: 64),
            payload: payload,
            relationshipClaims: try payload.derivedRelationshipClaims()
        )
        let record = RuntimeSwiftDataImportRecord(
            payloadVersion: payloadVersion,
            envelope: envelope
        )
        return try makeMappedFixture(
            formatVersion: 2,
            sourceSchema: objectStoreSwiftDataSchemaVersion,
            sourceRecordID: try record.canonicalSourceRecordID(),
            sourceRecordDigest: try record.semanticRecordDigest(),
            canonicalFamily: payload.modelType.rawValue,
            canonicalID: payload.stableRecordID,
            payloadVersion: record.payloadVersion,
            payload: .swiftData(envelope),
            warningCodes: [
                "typed_swiftdata_v3",
                "review_only_\(envelope.sourceDisposition.rawValue)"
            ]
        )
    }

    static func makeMappedFixture(
        copying fixture: MappedArtifactFixture,
        warningCodes: [String],
        lossiness: RuntimeLegacyImportLossiness
    ) throws -> MappedArtifactFixture {
        try makeMappedFixture(
            formatVersion: fixture.decodedArtifact.formatVersion,
            sourceSchema: fixture.decodedArtifact.sourceSchema,
            sourceRecordID: fixture.decodedArtifact.sourceRecordID,
            sourceRecordDigest: fixture.decodedArtifact.sourceRecordDigest,
            canonicalFamily: fixture.decodedArtifact.canonicalFamily,
            canonicalID: fixture.decodedArtifact.canonicalID,
            payloadVersion: fixture.decodedArtifact.payloadVersion,
            payload: fixture.decodedArtifact.payload,
            warningCodes: warningCodes,
            lossiness: lossiness
        )
    }

    static func makeMappedFixture(
        formatVersion: Int,
        sourceSchema: String,
        sourceRecordID: String,
        sourceRecordDigest: String,
        canonicalFamily: String,
        canonicalID: String,
        payloadVersion: Int,
        payload: RuntimeLegacyMappedImportPayload,
        warningCodes: [String] = [],
        lossiness: RuntimeLegacyImportLossiness = .none
    ) throws -> MappedArtifactFixture {
        let importID = "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee"
        let decoded = RuntimeLegacyMappedImportArtifact(
            formatVersion: formatVersion,
            importID: importID,
            sourceSchema: sourceSchema,
            sourceRecordID: sourceRecordID,
            sourceRecordDigest: sourceRecordDigest,
            canonicalFamily: canonicalFamily,
            canonicalID: canonicalID,
            payloadVersion: payloadVersion,
            payload: payload
        )
        let bytes = try RuntimeGenerationControlCodec.encode(decoded)
        let observed = try RuntimeGenerationArtifact(
            relativePath: "Imports/\(importID)/Mapped/artifact.json",
            sha256: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
            byteCount: Int64(bytes.count),
            protectionClass: "complete"
        )
        let reference = try RuntimeGenerationControlRecordFactory.mappedArtifactReference(
            importID: importID,
            sourceRecordID: sourceRecordID,
            sourceRecordDigest: sourceRecordDigest,
            artifact: observed,
            formatVersion: formatVersion,
            payloadVersion: payloadVersion
        )
        let item = try RuntimeGenerationControlRecordFactory.importItem(
            importID: importID,
            sourceRecordID: sourceRecordID,
            sourceRecordDigest: sourceRecordDigest,
            canonicalFamily: canonicalFamily,
            canonicalID: canonicalID,
            canonicalPayloadDigest: observed.sha256,
            mappedArtifact: reference,
            disposition: .reviewableDiscovery,
            warningCodes: warningCodes,
            lossiness: lossiness
        )
        return MappedArtifactFixture(
            item: item,
            observedArtifact: observed,
            decodedArtifact: decoded
        )
    }

    static func assertImportReviewRequired(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> Void
    ) {
        XCTAssertThrowsError(try operation(), file: file, line: line) { error in
            XCTAssertEqual(
                error as? RuntimeGenerationControlError,
                .importReviewRequired,
                file: file,
                line: line
            )
        }
    }

    func withForensicFixture<Result>(
        _ operation: (RuntimeGenerationForensicTestFixture) throws -> Result
    ) throws -> Result {
        let fixture = try Self.makeForensicFixture()
        defer {
            XCTAssertNoThrow(try FileManager.default.removeItem(at: fixture.rootURL))
        }
        return try operation(fixture)
    }

    func withForensicFixture<Result: Sendable>(
        _ operation: @Sendable (RuntimeGenerationForensicTestFixture) async throws -> Result
    ) async throws -> Result {
        let fixture = try Self.makeForensicFixture()
        do {
            let result = try await operation(fixture)
            try FileManager.default.removeItem(at: fixture.rootURL)
            return result
        } catch {
            let operationError = error
            do {
                try FileManager.default.removeItem(at: fixture.rootURL)
            } catch {
                XCTFail("Forensic fixture cleanup failed: \(error)")
            }
            throw operationError
        }
    }

    static func makeForensicFixture() throws -> RuntimeGenerationForensicTestFixture {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationForensic-\(UUID().uuidString)",
            isDirectory: true
        )
        let sourcesURL = rootURL.appendingPathComponent("Sources", isDirectory: true)
        let evidenceURL = rootURL.appendingPathComponent("Evidence", isDirectory: true)
        try FileManager.default.createDirectory(
            at: sourcesURL,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: evidenceURL,
            withIntermediateDirectories: false
        )
        for directory in [rootURL, sourcesURL, evidenceURL] {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: directory,
                artifact: "forensic_test_directory"
            )
        }
        return RuntimeGenerationForensicTestFixture(
            rootURL: rootURL,
            sourcesURL: sourcesURL,
            evidenceURL: evidenceURL
        )
    }
}

private extension Array {
    var only: Element? { count == 1 ? first : nil }
}
