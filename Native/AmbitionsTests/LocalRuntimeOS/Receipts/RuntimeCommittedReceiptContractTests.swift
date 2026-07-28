@testable import Ambitions
import Foundation
import XCTest

final class RuntimeCommittedReceiptContractTests: XCTestCase {
    func testV6ReceiptCatalogOwnsNormalizedAuthorityAndRequiredTriggers() {
        XCTAssertEqual(CanonicalRuntimeCommittedReceiptSchemaPlan.targetSchemaVersion, 6)
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.indexes.contains(
            "runtime_committed_receipt_cores_confirmation_idx"
        ))
        XCTAssertEqual(CanonicalRuntimeCommittedReceiptSchemaPlan.tables, Set([
            "runtime_committed_receipt_cores",
            "runtime_receipt_compensation_dispositions",
            "runtime_object_history",
            "runtime_receipt_object_links",
            "runtime_object_tombstone_history",
            "runtime_receipt_artifact_links",
            "runtime_receipt_retention_references",
            "runtime_compensation_plans",
            "runtime_compensation_plan_targets",
            "runtime_compensation_plan_external_operations",
            "runtime_irreversibility_evidence",
            "runtime_compensation_consumptions",
        ]))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_command_idempotency_require_complete_receipt"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_command_idempotency_seal_authority"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_compensation_plan_external_operations_bind_source"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_receipt_artifact_links_bind_authority"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_compensation_plan_targets_maximum"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_compensation_plan_external_operations_maximum"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_pending_external_operations_bind_receipt_command_event"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_confirmation_consumptions_bind_receipt_command_event"
        ))
        XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_commit_receipts_bind_command_event"
        ))
        let constructionSealedTables: Set<String> = [
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
        XCTAssertEqual(
            CanonicalRuntimeCommittedReceiptSchemaPlan.postFinalizationInsertSealedTables,
            constructionSealedTables
        )
        for table in constructionSealedTables {
            XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
                "\(table)_reject_insert_after_finalization"
            ))
            XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
                "\(table)_immutable_update"
            ))
            XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
                "\(table)_immutable_delete"
            ))
        }
        XCTAssertFalse(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
            "runtime_compensation_consumptions_reject_insert_after_finalization"
        ))
        for table in CanonicalRuntimeCommittedReceiptSchemaPlan.tables {
            XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
                "\(table)_immutable_update"
            ))
            XCTAssertTrue(CanonicalRuntimeCommittedReceiptSchemaPlan.requiredTriggerNames.contains(
                "\(table)_immutable_delete"
            ))
        }
        guard let anchorStatement = CanonicalRuntimeCommitSchemaPlan.statements.first(where: {
            $0.contains("CREATE TABLE runtime_commit_receipts")
        }), let confirmationStatement = CanonicalRuntimeCommitSchemaPlan.statements.first(where: {
            $0.contains("CREATE TABLE runtime_confirmation_consumptions")
        }) else {
            return XCTFail("Expected normalized anchor and confirmation schema statements")
        }
        XCTAssertTrue(anchorStatement.contains(
            "receipt_version INTEGER NOT NULL CHECK (receipt_version = 1)"
        ))
        XCTAssertFalse(anchorStatement.contains("payload BLOB"))
        XCTAssertFalse(anchorStatement.contains("payload_checksum"))
        XCTAssertTrue(confirmationStatement.contains("receipt_id TEXT NOT NULL UNIQUE"))
        XCTAssertTrue(confirmationStatement.contains("UNIQUE (receipt_id, token, decision_digest)"))
    }

    func testReceiptCoreDecoderRejectsOversizedBytesBeforeDecoding() {
        let bytes = Data(
            repeating: 0x7b,
            count: RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes + 1
        )
        XCTAssertThrowsError(try RuntimeCommittedReceiptCodec.decodeCore(
            bytes,
            storedChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        )) { error in
            XCTAssertEqual(error as? RuntimeCommittedReceiptCodecError, .digestMismatch)
        }
    }

    func testIrreversibilityEvidenceDigestIsBoundToExactSourceAuthority() throws {
        let evidence = RuntimeIrreversibilityEvidence(
            version: 1,
            permanence: .currentRuntimeUnsupported,
            reason: .unsupportedSemanticInverse,
            commandFamily: "goal",
            commandAction: "goal.update"
        )
        let first = try RuntimeCommittedReceiptCodec.evidenceDigest(
            evidence,
            sourceReceiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "receipt-a")),
            sourceLineage: RuntimeAuthorityLineageReference(
                eventID: try RuntimeEventID(validating: "event-a"),
                eventSequence: 1,
                eventHash: String(repeating: "a", count: 64)
            )
        )
        let second = try RuntimeCommittedReceiptCodec.evidenceDigest(
            evidence,
            sourceReceiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "receipt-b")),
            sourceLineage: RuntimeAuthorityLineageReference(
                eventID: try RuntimeEventID(validating: "event-b"),
                eventSequence: 2,
                eventHash: String(repeating: "b", count: 64)
            )
        )
        XCTAssertNotEqual(first, second)
    }

    func testReceiptReadAccessCannotSelfAssertReviewOrAuthentication() async throws {
        let receiptDigest = String(repeating: "a", count: 64)
        let authority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .denied }
        )
        let access = try XCTUnwrap(try await authority.issue(RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(
                coreDigest: receiptDigest,
                privacy: .standard
            )],
            maximumRows: 500,
            maximumBytes: 20_000_000
        )))
        XCTAssertEqual(access.fullReceiptDigests, Set([receiptDigest]))
        XCTAssertTrue(access.redactedReceiptDigests.isEmpty)
        XCTAssertEqual(access.maximumRows, 50)
        XCTAssertEqual(
            access.maximumBytes,
            RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
        )
        XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(access.digest))
        XCTAssertNil(try await authority.issue(RuntimeReceiptAccessRequest(
            surface: .encryptedVault,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(
                coreDigest: receiptDigest,
                privacy: .standard
            )]
        )))
    }

    func testReceiptReadAccessCanRepresentTwoMaximumEventRowsAndReceiptOverhead() async throws {
        let minimumExactAuthenticationWindow =
            2 * (
                RuntimeSemanticEventLimits.canonical.maximumEnvelopeBytes +
                    RuntimeCommittedReceiptReadBounds.selectedRowMetadataAllowanceBytes
            ) + RuntimeCommittedReceiptReadBounds.maximumCoreRowBytes
        let receiptDigest = String(repeating: "b", count: 64)
        let authority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .denied }
        )
        let access = try XCTUnwrap(try await authority.issue(RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(
                coreDigest: receiptDigest,
                privacy: .standard
            )],
            maximumBytes: minimumExactAuthenticationWindow
        )))
        XCTAssertEqual(access.maximumBytes, minimumExactAuthenticationWindow)
        XCTAssertLessThanOrEqual(
            minimumExactAuthenticationWindow,
            RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
        )
    }

    func testAccessAuthorityRequiresPolicyAuthenticationAndUniqueDigestBinding() async throws {
        let receiptDigest = String(repeating: "a", count: 64)
        let request = RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(
                coreDigest: receiptDigest,
                privacy: .privateUserText
            )],
            maximumRows: 500,
            maximumBytes: 20_000_000
        )
        let authorized = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .authenticated }
        )
        let access = try await authorized.issue(request)
        XCTAssertEqual(access?.surface, .localInspection)
        XCTAssertEqual(access?.fullReceiptDigests, Set([receiptDigest]))
        XCTAssertEqual(access?.redactedReceiptDigests, Set<String>())
        XCTAssertEqual(access?.authorizedReceiptDigests, Set([receiptDigest]))
        XCTAssertEqual(access?.maximumRows, 50)
        XCTAssertEqual(
            access?.maximumBytes,
            RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
        )

        let deniedAuthority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .denied }
        )
        let denied = try XCTUnwrap(try await deniedAuthority.issue(request))
        XCTAssertTrue(denied.authorizedReceiptDigests.isEmpty)

        let forgedExternalReview = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .authenticated },
            testingReview: { _ in .unavailable }
        )
        let externallyDenied = try XCTUnwrap(try await forgedExternalReview.issue(
            RuntimeReceiptAccessRequest(
                surface: .portableExport,
                purpose: .interactiveInspection,
                subjects: request.subjects
            )
        ))
        XCTAssertTrue(externallyDenied.authorizedReceiptDigests.isEmpty)

        let ambiguousPrivacy = try await authorized.issue(RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [
                RuntimeReceiptAccessSubject(
                    coreDigest: receiptDigest,
                    privacy: .privateUserText
                ),
                RuntimeReceiptAccessSubject(
                    coreDigest: receiptDigest,
                    privacy: .standard
                ),
            ]
        ))
        XCTAssertNil(ambiguousPrivacy)
    }

    func testCurrentSemanticCompensationActionsAreOnlyProvableCreateTombstones() throws {
        let objectID = try RuntimeDomainObjectID(validating: "object-1")
        let actions: [RuntimeSemanticCompensationAction] = [
            .discardCreatedCapture(objectID),
            .discardCreatedGoal(objectID),
            .discardCreatedSchedule(objectID),
            .discardCreatedReminder(objectID),
        ]
        XCTAssertEqual(actions.map(\.transition), Array(repeating: .tombstone, count: 4))
        XCTAssertEqual(
            actions.map(\.aggregateKind),
            [.capture, .goal, .schedule, .reminder]
        )
    }

    func testCompensationSemanticTypesAreProjectionOwnedWithoutLegacyScheduleUndo() {
        let compensationTypes: Set<RuntimeSemanticEventTypeID> = [
            .captureCreatedCompensated,
            .goalCreatedCompensated,
            .scheduleCreatedCompensated,
            .reminderCreatedCompensated,
        ]
        XCTAssertTrue(compensationTypes.isSubset(of: RuntimeCanonicalProjectionRegistry.allEventTypeIDs))
        XCTAssertTrue(compensationTypes.allSatisfy {
            RuntimeCanonicalProjectionRegistry.projectionIDs(for: $0) == [.aggregateState, .search]
        })
    }

    func testAbsentReceiptAndTenEligibilityStatesRemainDistinct() {
        XCTAssertEqual(RuntimeReceiptAuthorityState.unavailable, .unavailable)
        let values: [RuntimeRedactedCompensationEligibility] = [
            .available, .confirmationRequired, .expired, .consumed, .stale,
            .pendingExternalWork, .irreversible, .unsupported, .sourceBlocked, .unavailable,
        ]
        XCTAssertEqual(Set(values).count, 10)
    }
}
