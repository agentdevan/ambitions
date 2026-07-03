@testable import Ambitions
import Foundation
import XCTest

final class CoreRuntimeCanonicalOwnershipTests: XCTestCase {
    func testAMB1714MovedRuntimeLeavesUseCanonicalLocalRuntimeOSOwners() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/PrivateLifeRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RuntimeSnapshot.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RuntimeProjectionPipeline.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1714 canonical owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            "Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift",
            "Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift",
            "Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift",
            "Native/Ambitions/Core/Runtime/RuntimeMutation.swift",
            "Native/Ambitions/Core/Runtime/RuntimeValidator.swift",
            "Native/Ambitions/Core/Runtime/AmbitionsCommandExecutor.swift",
            "Native/Ambitions/Core/Runtime/PolicyGuardedCommandExecutor.swift",
            "Native/Ambitions/Core/Runtime/ExternalActionCommandService.swift",
            "Native/Ambitions/Core/Runtime/PrivacyBoundary.swift",
            "Native/Ambitions/Core/Runtime/SourceAtlasAccessBoundary.swift",
            "Native/Ambitions/Core/Runtime/SourceAtlasNoPrivateGraphEgressAudit.swift",
            "Native/Ambitions/Core/Runtime/ProofLedger.swift",
            "Native/Ambitions/Core/Persistence/SourceAtlasPublicArtifactPrivacyBoundary.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "Retired runtime-boundary owner still exists: \(retiredPath)"
            )
        }
    }

    func testAMB1716QuarantinesTestSupportOutsideProductionRuntimeOwner() {
        let root = repoRoot()
        for requiredPath in [
            "Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1716 quarantined test support file: \(requiredPath)"
            )
        }

        for retiredPath in [
            "Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1716 test support still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testAMB1730MovesStandalonePlanningServicesToCanonicalOwner() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalDomainPackService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalDomainPacks.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalEnergyFitService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalEnergyLearningService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalFreshnessUpdateService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalPathCompilerService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalResourceGraphService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalTeachingSignalService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalUnderstandingService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/OneStepGoalProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/RecommendationExplanationAdapter.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical PlanningEngine owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            "Native/Ambitions/Core/Runtime/GoalDomainPackService.swift",
            "Native/Ambitions/Core/Runtime/GoalDomainPacks.swift",
            "Native/Ambitions/Core/Runtime/GoalEnergyFitService.swift",
            "Native/Ambitions/Core/Runtime/GoalEnergyLearningService.swift",
            "Native/Ambitions/Core/Runtime/GoalFreshnessUpdateService.swift",
            "Native/Ambitions/Core/Runtime/GoalPathCompilerService.swift",
            "Native/Ambitions/Core/Runtime/GoalResourceGraphService.swift",
            "Native/Ambitions/Core/Runtime/GoalTeachingSignalService.swift",
            "Native/Ambitions/Core/Runtime/GoalUnderstandingService.swift",
            "Native/Ambitions/Core/Runtime/OneStepGoalProjector.swift",
            "Native/Ambitions/Core/Runtime/RecommendationExplanationAdapter.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 planning service still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testAMB1730MovesStandaloneTimeEnginesToCanonicalOwner() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/BufferEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/CapacityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/OpenCapacityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/PressureEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/RecoveryEngine.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical TimeEngine owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            "Native/Ambitions/Core/Runtime/BufferEngine.swift",
            "Native/Ambitions/Core/Runtime/CapacityEngine.swift",
            "Native/Ambitions/Core/Runtime/OpenCapacityEngine.swift",
            "Native/Ambitions/Core/Runtime/PressureEngine.swift",
            "Native/Ambitions/Core/Runtime/RecoveryEngine.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 time engine still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testRemainingLegacyRuntimeLeavesStayExplicitYellowUntilFollowUpMove() {
        let root = repoRoot()
        for yellowPath in [
            "Native/Ambitions/Core/Runtime/RecommendationEngine.swift",
            "Native/Ambitions/Core/Runtime/RuntimeCoreUmbrellaGate.swift",
            "Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime.swift",
            "Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime+02-GoldenVerticalSliceInput.swift",
            "Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime+03-GoldenVerticalSliceRuntime.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(yellowPath).path),
                "Remaining legacy runtime leaf moved without updating AMB-1714 Yellow proof: \(yellowPath)"
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
            let candidate = url.appendingPathComponent("project.yml")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
