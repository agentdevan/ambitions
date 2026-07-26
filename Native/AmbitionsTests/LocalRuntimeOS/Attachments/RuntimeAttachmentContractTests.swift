import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentContractTests: XCTestCase {
    func testAttachmentCommandIsTypedCanonicalAndRoundTripsWithoutLosingAuthority() throws {
        let attachment = Self.command(action: .linkStaged, expectedRevision: .absent)
        let command = AmbitionsCommand(
            id: "command-attachment-link-1",
            source: .capture,
            typedPayload: .attachment(attachment),
            expectedRevision: .absent,
            idempotencyKey: CommandIdempotencyKey("runtime.command.attachment-link-1"),
            createdAt: "2026-07-26T12:00:00Z",
            requestedAt: "2026-07-26T12:00:00Z",
            localOnly: true,
            privacy: .sensitive
        )

        let bytes = try RuntimeCommandCodec().encode(command)
        guard case let .supported(decoded, upgraded) = RuntimeCommandCodec().decode(bytes),
              case let .attachment(decodedAttachment) = decoded.typedPayload else {
            return XCTFail("Attachment command must remain a supported typed v2 command")
        }
        XCTAssertFalse(upgraded)
        XCTAssertEqual(decodedAttachment, attachment)
        XCTAssertEqual(decoded.typedPayload.operation, .linkAttachment)
        XCTAssertEqual(decoded.typedPayload.registrationCaseID.rawValue, "attachment.link_staged")
        XCTAssertEqual(RuntimeFeatureMutationRouter().feature(for: decoded.typedPayload), .attachment)
        XCTAssertEqual(RuntimeSemanticEventClassifier.classify(decoded.typedPayload), .mutating(.attachmentLinked))
        XCTAssertEqual(decoded.expectedRevision, .absent)
        XCTAssertEqual(decoded.idempotencyKey, command.idempotencyKey)
        XCTAssertTrue(decoded.localOnly)
        XCTAssertEqual(decoded.privacy, .sensitive)
    }

    func testAttachmentSemanticEventRoundTripPreservesLifecyclePrivacyAndProvenance() throws {
        let command = Self.command(action: .linkStaged, expectedRevision: .exact(0))
        let mutation = try RuntimeSemanticMutation(
            semanticType: .attachmentLinked,
            aggregateID: try RuntimeAggregateID(validating: command.intent.attachmentID.rawValue),
            priorRevision: 0,
            resultingRevision: 1,
            changedObjectIDs: [try RuntimeDomainObjectID(validating: command.intent.attachmentID.rawValue)],
            privacy: .sensitive,
            localOnly: true
        )
        let event = RuntimeSemanticEvent.attachment(.linked(
            try RuntimeAttachmentMutationPayload(mutation: mutation, facts: command)
        ))

        let bytes = try RuntimeSemanticEventCodec().encode(event)
        let decoded = try RuntimeSemanticEventCodec().decode(bytes)
        XCTAssertEqual(decoded.event, event)
        XCTAssertEqual(decoded.event.commandPayload, .attachment(command))
        XCTAssertEqual(decoded.event.aggregateKind, .attachment)
        XCTAssertEqual(decoded.event.mutation.privacy, .sensitive)
        XCTAssertEqual(decoded.event.mutation.localOnly, true)
    }

    func testEveryAttachmentActionHasAnExplicitOperationEventAndRegistrationCase() {
        let expected: [(RuntimeAttachmentMutationAction, RuntimeCommandOperation, RuntimeSemanticEventTypeID, String)] = [
            (.linkStaged, .linkAttachment, .attachmentLinked, "attachment.link_staged"),
            (.unlink, .unlinkAttachment, .attachmentUnlinked, "attachment.unlink"),
            (.replaceRevision, .replaceAttachmentRevision, .attachmentRevisionReplaced, "attachment.replace_revision"),
            (.authorizeDeletion, .authorizeAttachmentDeletion, .attachmentDeletionAuthorized, "attachment.authorize_deletion"),
            (.quarantine, .quarantineAttachment, .attachmentQuarantined, "attachment.quarantine"),
        ]

        XCTAssertEqual(expected.map(\.0), RuntimeAttachmentMutationAction.allCases)
        for (action, operation, event, registration) in expected {
            let payload = RuntimeCommandPayload.attachment(Self.command(
                action: action,
                expectedRevision: action == .linkStaged ? .absent : .exact(2)
            ))
            XCTAssertEqual(payload.operation, operation)
            XCTAssertEqual(payload.registrationCaseID.rawValue, registration)
            XCTAssertEqual(RuntimeSemanticEventClassifier.classify(payload), .mutating(event))
        }
    }

    func testAttachmentSchemaOwnsNormalizedAuthorityAndReceiptParity() {
        let schema = CanonicalRuntimeAttachmentSchemaPlan.fullGenerationStatements.joined(separator: "\n")
        for table in CanonicalRuntimeAttachmentSchemaPlan.tables {
            XCTAssertTrue(schema.contains("CREATE TABLE \(table)"), table)
        }
        XCTAssertTrue(schema.contains("runtime_attachment_reference_count_insert_guard"))
        XCTAssertTrue(schema.contains("runtime_blob_gc_lease_eligibility"))
        XCTAssertTrue(schema.contains("runtime_blob_deletion_tombstone_requires_lease"))
        XCTAssertTrue(schema.contains("runtime_attachment_finalization_bind_receipt"))
        XCTAssertTrue(schema.contains("runtime_attachment_receipt_link_seal_after_command_finalization"))
        XCTAssertTrue(schema.contains("runtime_attachment_finalization_sidecar_bind_completed_intent"))
        XCTAssertTrue(schema.contains("runtime_blob_finalization_completions"))
        XCTAssertTrue(schema.contains("runtime_attachment_finalization_completion_closure"))
        XCTAssertTrue(schema.contains("DEFERRABLE INITIALLY DEFERRED"))
        XCTAssertTrue(schema.contains("h.system_evidence_fingerprint = NEW.lease_token"))
        XCTAssertTrue(schema.contains("runtime_blob_gc_lease_reacquire_bind_fence_history"))
        XCTAssertTrue(schema.contains("runtime_attachment_manifest_deletion_claims"))
        XCTAssertTrue(schema.contains("runtime_attachment_manifest_deletion_tombstones"))
        XCTAssertTrue(schema.contains("runtime_blob_records_block_manifest_deletion_claim"))
        XCTAssertTrue(schema.contains("expires_at_ms > created_at_ms"))
        XCTAssertFalse(schema.contains("complete_until_first_user_authentication"))
        XCTAssertTrue(schema.contains("attachment_revision"))
        XCTAssertTrue(schema.contains("attachment_finalization_intent"))
        XCTAssertTrue(schema.contains("a.artifact_kind = 'attachment_revision' AND EXISTS"))
        XCTAssertTrue(schema.contains("a.artifact_kind = 'attachment_finalization_intent' AND EXISTS"))
        XCTAssertTrue(schema.contains("finalized attachment receipt graph is sealed"))
        XCTAssertTrue(schema.contains("unproven attachment finalization sidecar"))
        XCTAssertTrue(schema.contains("'external_operation', 'attachment'"))
        XCTAssertEqual(CanonicalRuntimeAttachmentSchemaPlan.targetSchemaVersion, 8)
    }

    func testInvalidQuarantineEvidenceAndRemoteAttachmentCommandAreRejected() throws {
        var invalid = Self.intent(action: .quarantine)
        invalid = RuntimeAttachmentCommandIntent(
            version: invalid.version, action: invalid.action,
            attachmentID: invalid.attachmentID, revisionID: invalid.revisionID,
            blobID: invalid.blobID, referenceID: invalid.referenceID,
            replacesReferenceID: invalid.replacesReferenceID,
            replacesRevisionID: invalid.replacesRevisionID,
            replacesBlobID: invalid.replacesBlobID, target: invalid.target,
            expectedLifecycleVersion: invalid.expectedLifecycleVersion,
            expectedReplacedLifecycleVersion: invalid.expectedReplacedLifecycleVersion,
            manifestDigest: invalid.manifestDigest,
            replacesManifestDigest: invalid.replacesManifestDigest,
            quarantineReason: invalid.quarantineReason,
            quarantineEvidenceFingerprint: "not-a-digest",
            privacy: invalid.privacy, provenance: invalid.provenance
        )
        XCTAssertThrowsError(try RuntimeAttachmentCodec.validate(invalid))

        let remote = AmbitionsCommand(
            id: "command-attachment-remote-1", source: .system,
            typedPayload: .attachment(Self.command(action: .unlink, expectedRevision: .exact(1))),
            expectedRevision: .exact(1), createdAt: "2026-07-26T12:00:00Z",
            localOnly: false, privacy: .sensitive
        )
        XCTAssertThrowsError(try RuntimeCommandCodec().encode(remote))
    }

    func testRecoveryWorkIdentityIsStableWhileOccurrenceEvidenceIsCycleScoped() throws {
        let workID = try CanonicalRuntimeAttachmentStore.recoveryAttemptAuthorityID(
            scan: .manifestDirectories, key: "1:aa:owned-entry"
        )
        let repeatedWorkID = try CanonicalRuntimeAttachmentStore.recoveryAttemptAuthorityID(
            scan: .manifestDirectories, key: "1:aa:owned-entry"
        )
        XCTAssertEqual(workID, repeatedWorkID)

        let firstOccurrence = try CanonicalRuntimeAttachmentStore.recoveryFindingEvidenceFingerprint(
            issue: .manifestWithoutRow, blobID: RuntimeBlobID(rawValue: "blob-recovery")!,
            relativeDirectory: "v1/aa/owned-entry", cycle: 1
        )
        let secondOccurrence = try CanonicalRuntimeAttachmentStore.recoveryFindingEvidenceFingerprint(
            issue: .manifestWithoutRow, blobID: RuntimeBlobID(rawValue: "blob-recovery")!,
            relativeDirectory: "v1/aa/owned-entry", cycle: 2
        )
        XCTAssertNotEqual(firstOccurrence, secondOccurrence)
    }

    private static func command(
        action: RuntimeAttachmentMutationAction,
        expectedRevision: RuntimeExpectedRevision
    ) -> RuntimeAttachmentCommand {
        RuntimeAttachmentCommand(
            intent: intent(action: action),
            target: AmbitionsCommandTarget(captureID: "capture-attachment-owner-1"),
            content: RuntimeCommandContent()
        )
    }

    private static func intent(action: RuntimeAttachmentMutationAction) -> RuntimeAttachmentCommandIntent {
        let target = RuntimeSemanticAggregate(
            kind: .capture,
            id: try! RuntimeAggregateID(validating: "capture-attachment-owner-1")
        )
        let reference = RuntimeAttachmentReferenceID(rawValue: "attachment-reference-1")!
        let replacement = action == .replaceRevision
        return RuntimeAttachmentCommandIntent(
            version: runtimeCanonicalAttachmentModelVersion,
            action: action,
            attachmentID: RuntimeAttachmentID(rawValue: "attachment-1")!,
            revisionID: RuntimeAttachmentRevisionID(rawValue: "attachment-revision-2")!,
            blobID: RuntimeBlobID(rawValue: "blob-2")!,
            referenceID: [.linkStaged, .unlink, .replaceRevision].contains(action) ? reference : nil,
            replacesReferenceID: replacement ? RuntimeAttachmentReferenceID(rawValue: "attachment-reference-0")! : nil,
            replacesRevisionID: replacement ? RuntimeAttachmentRevisionID(rawValue: "attachment-revision-1")! : nil,
            replacesBlobID: replacement ? RuntimeBlobID(rawValue: "blob-1")! : nil,
            target: [.linkStaged, .unlink, .replaceRevision].contains(action) ? target : nil,
            expectedLifecycleVersion: 3,
            expectedReplacedLifecycleVersion: replacement ? 4 : nil,
            manifestDigest: String(repeating: "a", count: 64),
            replacesManifestDigest: replacement ? String(repeating: "b", count: 64) : nil,
            quarantineReason: action == .quarantine ? .authenticationFailed : nil,
            quarantineEvidenceFingerprint: action == .quarantine ? String(repeating: "c", count: 64) : nil,
            privacy: .sensitive,
            provenance: RuntimeAttachmentProvenance(
                version: runtimeCanonicalAttachmentModelVersion,
                kind: .capture,
                sourceRecordID: "capture-attachment-owner-1",
                receivedAt: Date(timeIntervalSince1970: 1_774_089_600),
                sourceApplicationFingerprint: nil
            )
        )
    }
}
