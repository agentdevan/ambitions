@testable import Ambitions
import Foundation
import XCTest

final class CoreRuntimeCanonicalOwnershipTests: XCTestCase {
    func testCanonicalCoreRuntimeOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift",
            "Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift",
            "Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift",
            "Native/Ambitions/Core/Runtime/RecommendationEngine.swift",
            "Native/Ambitions/Core/Runtime/CapacityEngine.swift",
            "Native/Ambitions/Core/Runtime/PressureEngine.swift",
            "Native/Ambitions/Core/Runtime/RecoveryEngine.swift",
            "Native/Ambitions/Core/Runtime/ProofLedger.swift",
            "Native/Ambitions/Core/Runtime/PrivacyBoundary.swift",
            "Native/Ambitions/Core/Runtime/RuntimeMutation.swift",
            "Native/Ambitions/Core/Runtime/RuntimeValidator.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Core/Runtime owner: \(requiredPath)"
            )
        }
    }

    func testRuntimeProjectionPipelineProducesLocalSnapshotWithProofCapacityAndRecovery() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))
        let nowState = CanonicalNowState.empty(generatedAt: DomainTimestamp.string(from: now))
        let runtime = PrivateLifeRuntime(
            projectionPipeline: RuntimeProjectionPipeline(projector: StaticNowStateProjector(nowState: nowState))
        )

        let snapshot = runtime.snapshot(input: NowStateProjectionInput(now: now))

        XCTAssertEqual(snapshot.nowState.id, nowState.id)
        XCTAssertEqual(snapshot.recommendation.title, "Start here")
        XCTAssertTrue(snapshot.capacityShape.hasBreathingRoom)
        XCTAssertEqual(snapshot.pressureReading.kind, .light)
        XCTAssertTrue(snapshot.pressureReading.hiddenFromRootUI)
        XCTAssertEqual(snapshot.recoveryState.state, .stable)
        XCTAssertTrue(snapshot.privacyBoundary.isSatisfied)
        XCTAssertTrue(snapshot.localOnly)
        XCTAssertEqual(snapshot.schemaVersion, runtimeSnapshotSchemaVersion)
    }

    func testRuntimeValidatorBlocksNonLocalCommandBeforeMutation() {
        let runtime = PrivateLifeRuntime()
        let command = AmbitionsCommand(
            id: "command-non-local",
            kind: .quickCapture,
            source: .appIntent,
            payload: AmbitionsCommandPayload(rawText: "Remember the local proof"),
            createdAt: "2026-04-25T12:00:00Z",
            localOnly: false
        )

        let validation = runtime.validate(command)
        let mutation = runtime.mutation(
            for: command,
            beforeSnapshot: "before",
            afterSnapshot: "after",
            targetSurface: .today
        )

        XCTAssertEqual(validation.validationState, .blockedByMissingFoundation)
        XCTAssertFalse(validation.canMutate)
        XCTAssertTrue(validation.blockedReasons.contains(RuntimePrivacyBoundaryIssue.commandNotLocalOnly.rawValue))
        XCTAssertNil(mutation)
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

    func testCommandExecutorValidationRoutesThroughRuntimeValidator() {
        let executor = AmbitionsCommandExecutor()
        let command = AmbitionsCommand(
            id: "command-empty-capture",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "   "),
            createdAt: "2026-04-25T12:00:00Z"
        )

        XCTAssertEqual(executor.validate(command), .invalid)
    }
}

private struct StaticNowStateProjector: NowStateProjecting {
    let nowState: CanonicalNowState

    func project(input: NowStateProjectionInput) -> CanonicalNowState {
        nowState
    }
}

private extension CoreRuntimeCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/Runtime")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
