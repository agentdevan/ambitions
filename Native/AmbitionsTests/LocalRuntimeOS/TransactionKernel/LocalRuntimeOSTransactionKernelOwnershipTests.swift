@testable import Ambitions
import XCTest

final class LocalRuntimeOSTransactionKernelOwnershipTests: XCTestCase {
    func testRuntimeMutationBelongsToTransactionKernelAndOldOwnerIsGone() {
        let root = repoRoot()
        let canonicalPath = "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutation.swift"
        let retiredPath = "Native/Ambitions/Core/Runtime/RuntimeMutation.swift"

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(canonicalPath).path),
            "Missing canonical TransactionKernel owner: \(canonicalPath)"
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
            "Retired transaction owner still exists: \(retiredPath)"
        )
    }

    func testRuntimeMutationRepresentsVisibleStageMutationAnnouncementAndProof() {
        let runtime = PrivateLifeRuntime()
        let command = AmbitionsCommand(
            id: "command-start-step",
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let mutation = runtime.mutation(
            for: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today
        )

        XCTAssertNotNil(mutation)
        XCTAssertTrue(mutation?.hasCompleteActionFlowProof == true)
        XCTAssertEqual(mutation?.stageMutation.affectedObjectIDs, ["goal-1", "step-1"])
        XCTAssertEqual(mutation?.stageMutation.motionEvent, "stage.motion.start_focus")
        XCTAssertEqual(mutation?.stageMutation.accessibilityAnnouncement.message, "Step started. Proof is available.")
        XCTAssertEqual(mutation?.userVisibleMutation.headline, "Step started")
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
