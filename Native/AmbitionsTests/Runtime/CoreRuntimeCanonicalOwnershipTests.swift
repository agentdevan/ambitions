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

    func testAMB1730MovesGoalClarificationAndContradictionServicesToCanonicalOwner() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService+02-DefaultGoalClarificationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService+03-ClassificationConfidence.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService+02-DefaultGoalContradictionService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService+03-GoalResourceEntity.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical clarification/contradiction owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            "Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift",
            "Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService.swift",
            "Native/Ambitions/Core/Runtime/GoalClarificationService+03-ClassificationConfidence.swift",
            "Native/Ambitions/Core/Runtime/GoalClarificationService.swift",
            "Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift",
            "Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService.swift",
            "Native/Ambitions/Core/Runtime/GoalContradictionService+03-GoalResourceEntity.swift",
            "Native/Ambitions/Core/Runtime/GoalContradictionService.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 clarification/contradiction service still lives under production runtime owner: \(retiredPath)"
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

    func testAMB1730MovesStepPlanningAndSchedulingRuntimeOwnersToCanonicalOwners() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+02-StepElasticityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+03-StepElasticityEngineInput.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler+02-StepGraphCompiler+02-compile.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler+02-StepGraphCompiler.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepQualityFirewall.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+02-ScheduleInstallRecord.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+03-ScheduleInstallKernel.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+04-ScheduleInstallRecord.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/SimpleStepLifecycleService+Recurring.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/SimpleStepLifecycleService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/StepReallocationRuntimeBridge.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/TimeRitualGoalSemantics.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical step planning/scheduling owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            "Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift",
            "Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift",
            "Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine.swift",
            "Native/Ambitions/Core/Runtime/StepElasticityEngine+03-StepElasticityEngineInput.swift",
            "Native/Ambitions/Core/Runtime/StepElasticityEngine.swift",
            "Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+02-compile.swift",
            "Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift",
            "Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler.swift",
            "Native/Ambitions/Core/Runtime/StepGraphCompiler.swift",
            "Native/Ambitions/Core/Runtime/StepQualityFirewall.swift",
            "Native/Ambitions/Core/Runtime/ScheduleInstallKernel+02-ScheduleInstallRecord.swift",
            "Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift",
            "Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift",
            "Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel.swift",
            "Native/Ambitions/Core/Runtime/ScheduleInstallKernel+04-ScheduleInstallRecord.swift",
            "Native/Ambitions/Core/Runtime/ScheduleInstallKernel.swift",
            "Native/Ambitions/Core/Runtime/SimpleStepLifecycleService+Recurring.swift",
            "Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift",
            "Native/Ambitions/Core/Runtime/StepReallocationRuntimeBridge.swift",
            "Native/Ambitions/Core/Runtime/TimeRitualGoalSemantics.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 step planning/scheduling owner still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testAMB1730EliminatesRemainingLegacyRuntimeProductionAuthority() throws {
        let root = repoRoot()
        let legacyRuntimeOwner = root.appendingPathComponent("Native/Ambitions/Core/Runtime", isDirectory: true)
        let legacySwiftFiles = try? FileManager.default.contentsOfDirectory(
            at: legacyRuntimeOwner,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "swift" }

        XCTAssertEqual(legacySwiftFiles ?? [], [], "Core/Runtime must not contain production Swift authority after AMB-1730.")

        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/SmartAttachmentService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/MultiPathLattice.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/RecommendationEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/HighRiskSafetyJurisdictionGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/AmbitionsRuntimeGoalIntelligence.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/ExecutionResilienceProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/FirstRunActivationRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/GoldenVerticalSliceRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/LearningAnticipationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/LifeConsequenceEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/RuntimeCoreUmbrellaGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/SharedLifeCoordinationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/CanonicalNowStateProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/GoalBelievabilityProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/GoalExplainabilityProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/LifeAreaAtlasProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/NorthStarProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/PathIntelligenceProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RealityModelProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ReviewsV1Projector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/AmbitionsRuntimeContracts.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/AmbitionsRuntimeFactory.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/AmbitionsRuntimeServices.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/AppServices.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/DedicatedDevicePrototypeRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/RealityIntegrationAdapters.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/RuntimePackageBoundaryModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/SnapshotRefreshingServices.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/AnyGoalRuntimeCoverage.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeClaimBoundaryHardener.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeIngestionService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeProviderBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ClosureEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeShapeBucketBuilder.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeShapeEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockRepository.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ProtectionEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/RitualOrchestrationService.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical owner after full legacy runtime pass: \(requiredPath)"
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
