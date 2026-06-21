@testable import Ambitions
import XCTest

final class MutationsCanonicalOwnershipTests: XCTestCase {
    func testCanonicalMutationOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Projection/Mutations/StageMutation.swift",
            "Native/Ambitions/Projection/Mutations/UserVisibleMutation.swift",
            "Native/Ambitions/Projection/Mutations/MutationProof.swift",
            "Native/Ambitions/Projection/Mutations/MutationReceipt.swift",
            "Native/Ambitions/Projection/Mutations/MutationUndo.swift",
            "Native/Ambitions/Projection/Mutations/MutationAccessibilityAnnouncement.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Projection/Mutations owner: \(requiredPath)"
            )
        }
    }

    func testRuntimeMutationUsesCanonicalProjectionMutationOwners() {
        let runtime = PrivateLifeRuntime()
        let command = AmbitionsCommand(
            id: "command-visible-flow",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Start now"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let mutation = runtime.mutation(
            for: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today
        )

        XCTAssertTrue(mutation?.hasCompleteActionFlowProof == true)
        XCTAssertEqual(mutation?.stageMutation.proofArtifact.localOnly, true)
        XCTAssertEqual(mutation?.stageMutation.receipt.saved, true)
        XCTAssertEqual(mutation?.stageMutation.undoAvailability.label, "Undo")
        XCTAssertEqual(mutation?.stageMutation.accessibilityAnnouncement.message, "Step completed. Proof is available.")
        XCTAssertEqual(mutation?.userVisibleMutation.headline, "Step completed")
    }

    func testClosureMutationProducesVisibleStageMutationProofReceiptAndAnnouncement() {
        let record = ClosureMutationRecord(
            stepID: "step-1",
            goalID: "goal-1",
            outcome: .completed,
            occurredAt: Date(timeIntervalSince1970: 0)
        )

        let mutation = TodayClosureStageMutation(
            record: record,
            stepTitle: "Write the draft",
            receiptSaved: true
        )

        XCTAssertTrue(mutation.stageMutation.isCanonComplete)
        XCTAssertTrue(mutation.userVisibleMutation.isCanonComplete)
        XCTAssertEqual(mutation.stageMutation.targetSurface, .today)
        XCTAssertEqual(mutation.stageMutation.proofArtifact.artifactID, "proof.closure.goal-1.step-1.completed.0")
        XCTAssertEqual(mutation.stageMutation.receipt.inspectionLabel, "Local receipt history")
        XCTAssertEqual(
            mutation.stageMutation.accessibilityAnnouncement.message,
            "Done. Write the draft is closed and proof is saved. Receipt saved locally."
        )
    }
}

private extension MutationsCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Projection/Mutations")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
