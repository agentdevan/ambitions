import XCTest
@testable import Ambitions

final class ActionReceiptAttachmentUndoTests: XCTestCase {
    func testEveryAttachmentActionIsClassifiedAsUndoNotSupported() throws {
        for action in RuntimeAttachmentMutationAction.allCases {
            let command = try attachmentCommand(action: action)
            let originalPayload = command.typedPayload
            let receipt = ActionReceipt.fromCommandResult(
                command: command,
                result: AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Attachment command completed.",
                    target: command.target
                ),
                occurredAt: "2026-07-26T12:01:00Z"
            )

            XCTAssertEqual(receipt.undoAvailability, .notSupportedYet, action.rawValue)
            XCTAssertEqual(receipt.resultState, .changed, action.rawValue)
            XCTAssertEqual(receipt.changedFacts.map(\.kind), [.changedField], action.rawValue)
            XCTAssertEqual(command.typedPayload, originalPayload, action.rawValue)
        }
    }

    func testNonSuccessAttachmentUndoDispositionRemainsConservative() throws {
        let command = try attachmentCommand(action: .authorizeDeletion)
        let failedReceipt = ActionReceipt.fromCommandResult(
            command: command,
            result: AmbitionsCommandExecutionResult(
                status: .failed,
                summary: "Attachment command failed without mutation.",
                target: command.target
            ),
            occurredAt: "2026-07-26T12:01:00Z"
        )
        let confirmationReceipt = ActionReceipt.fromCommandResult(
            command: command,
            result: AmbitionsCommandExecutionResult(
                status: .requiresConfirmation,
                summary: "Attachment command requires confirmation.",
                target: command.target
            ),
            occurredAt: "2026-07-26T12:02:00Z"
        )

        XCTAssertEqual(failedReceipt.undoAvailability, .unavailable)
        XCTAssertEqual(failedReceipt.resultState, .failedSafely)
        XCTAssertEqual(confirmationReceipt.undoAvailability, .requiresConfirmation)
        XCTAssertEqual(confirmationReceipt.resultState, .needsConfirmation)
    }
}

private extension ActionReceiptAttachmentUndoTests {
    func attachmentCommand(action: RuntimeAttachmentMutationAction) throws -> AmbitionsCommand {
        let hasReference = [
            RuntimeAttachmentMutationAction.linkStaged,
            .unlink,
            .replaceRevision
        ].contains(action)
        let replacesRevision = action == .replaceRevision
        let aggregateID = try RuntimeAggregateID(validating: "receipt-capture-1")
        let intent = RuntimeAttachmentCommandIntent(
            version: runtimeCanonicalAttachmentModelVersion,
            action: action,
            attachmentID: try XCTUnwrap(RuntimeAttachmentID(rawValue: "receipt-attachment-1")),
            revisionID: try XCTUnwrap(RuntimeAttachmentRevisionID(rawValue: "receipt-attachment-revision-2")),
            blobID: try XCTUnwrap(RuntimeAttachmentBlobID(rawValue: "receipt-blob-2")),
            referenceID: hasReference ? try XCTUnwrap(RuntimeAttachmentReferenceID(rawValue: "receipt-reference-1")) : nil,
            replacesReferenceID: replacesRevision ? try XCTUnwrap(RuntimeAttachmentReferenceID(rawValue: "receipt-reference-0")) : nil,
            replacesRevisionID: replacesRevision ? try XCTUnwrap(RuntimeAttachmentRevisionID(rawValue: "receipt-attachment-revision-1")) : nil,
            replacesBlobID: replacesRevision ? try XCTUnwrap(RuntimeAttachmentBlobID(rawValue: "receipt-blob-1")) : nil,
            target: hasReference ? RuntimeSemanticAggregate(kind: .capture, id: aggregateID) : nil,
            expectedLifecycleVersion: 3,
            expectedReplacedLifecycleVersion: replacesRevision ? 4 : nil,
            manifestDigest: String(repeating: "a", count: 64),
            replacesManifestDigest: replacesRevision ? String(repeating: "b", count: 64) : nil,
            quarantineReason: action == .quarantine ? .authenticationFailed : nil,
            quarantineEvidenceFingerprint: action == .quarantine ? String(repeating: "c", count: 64) : nil,
            privacy: .sensitive,
            provenance: RuntimeAttachmentProvenance(
                version: runtimeCanonicalAttachmentModelVersion,
                kind: .capture,
                sourceRecordID: "receipt-capture-1",
                receivedAt: Date(timeIntervalSince1970: 1_774_089_600),
                sourceApplicationFingerprint: nil
            )
        )
        return AmbitionsCommand(
            id: "receipt-attachment-command-\(action.rawValue)",
            source: .capture,
            typedPayload: .attachment(RuntimeAttachmentCommand(
                intent: intent,
                target: AmbitionsCommandTarget(captureID: "receipt-capture-1"),
                content: RuntimeCommandContent()
            )),
            expectedRevision: action == .linkStaged ? .absent : .exact(3),
            createdAt: "2026-07-26T12:00:00Z",
            localOnly: true,
            privacy: .sensitive
        )
    }
}
