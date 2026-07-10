@testable import Ambitions
import Foundation
import XCTest

final class CoreRuntimeCanonicalOwnershipTests: XCTestCase {
    func testAMB1714MovedRuntimeLeavesUseCanonicalLocalRuntimeOSOwners() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/PrivateLifeRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/RuntimeSnapshot.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/RuntimeProjectionPipeline.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1714 canonical owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("PrivateLifeRuntime.swift"),
            removedRuntimeOwnerPath("RuntimeSnapshot.swift"),
            removedRuntimeOwnerPath("RuntimeProjectionPipeline.swift"),
            removedRuntimeOwnerPath("RuntimeMutation.swift"),
            removedRuntimeOwnerPath("RuntimeValidator.swift"),
            removedRuntimeOwnerPath("AmbitionsCommandExecutor.swift"),
            removedRuntimeOwnerPath("PolicyGuardedCommandExecutor.swift"),
            removedRuntimeOwnerPath("ExternalActionCommandService.swift"),
            removedRuntimeOwnerPath("PrivacyBoundary.swift"),
            removedRuntimeOwnerPath("SourceAtlasAccessBoundary.swift"),
            removedRuntimeOwnerPath("SourceAtlasNoPrivateGraphEgressAudit.swift"),
            removedRuntimeOwnerPath("ProofLedger.swift"),
            "Native/Ambitions/Core/Persistence/SourceAtlasPublicArtifactPrivacyBoundary.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "Retired runtime-boundary owner still exists: \(retiredPath)"
            )
        }
    }

    func testAMB1716IsolatesTestSupportOutsideProductionRuntimeOwner() {
        let root = repoRoot()
        for requiredPath in [
            "Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1716 isolated test support file: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("LargeStoreFixtureGenerator.swift"),
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
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalDomainPackService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalDomainPacks.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalEnergyFitService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalEnergyLearningService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalFreshnessUpdateService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalPathCompilerService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalResourceGraphService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalTeachingSignalService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalUnderstandingService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/OneStepGoalProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/RecommendationExplanationAdapter.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical Planning owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("GoalDomainPackService.swift"),
            removedRuntimeOwnerPath("GoalDomainPacks.swift"),
            removedRuntimeOwnerPath("GoalEnergyFitService.swift"),
            removedRuntimeOwnerPath("GoalEnergyLearningService.swift"),
            removedRuntimeOwnerPath("GoalFreshnessUpdateService.swift"),
            removedRuntimeOwnerPath("GoalPathCompilerService.swift"),
            removedRuntimeOwnerPath("GoalResourceGraphService.swift"),
            removedRuntimeOwnerPath("GoalTeachingSignalService.swift"),
            removedRuntimeOwnerPath("GoalUnderstandingService.swift"),
            removedRuntimeOwnerPath("OneStepGoalProjector.swift"),
            removedRuntimeOwnerPath("RecommendationExplanationAdapter.swift"),
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
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/DefaultGoalClarificationServiceAssumptions.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/DefaultGoalClarificationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/ClassificationConfidencePlanningSupport.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalClarificationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/DefaultGoalContradictionServiceEnergyRules.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/DefaultGoalContradictionService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalResourceEntityPlanningSupport.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalContradictionService.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical clarification/contradiction owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("DefaultGoalClarificationServiceAssumptions.swift"),
            removedRuntimeOwnerPath("DefaultGoalClarificationService.swift"),
            removedRuntimeOwnerPath("ClassificationConfidencePlanningSupport.swift"),
            removedRuntimeOwnerPath("GoalClarificationService.swift"),
            removedRuntimeOwnerPath("DefaultGoalContradictionServiceEnergyRules.swift"),
            removedRuntimeOwnerPath("DefaultGoalContradictionService.swift"),
            removedRuntimeOwnerPath("GoalResourceEntityPlanningSupport.swift"),
            removedRuntimeOwnerPath("GoalContradictionService.swift"),
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 clarification/contradiction service still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testAMB1730MovesStandaloneSchedulingEnginesToCanonicalOwner() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/BufferEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/CapacityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/OpenCapacityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/PressureEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/RecoveryEngine.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical Scheduling owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("BufferEngine.swift"),
            removedRuntimeOwnerPath("CapacityEngine.swift"),
            removedRuntimeOwnerPath("OpenCapacityEngine.swift"),
            removedRuntimeOwnerPath("PressureEngine.swift"),
            removedRuntimeOwnerPath("RecoveryEngine.swift"),
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 scheduling engine still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testAMB1730MovesStepPlanningAndSchedulingRuntimeOwnersToCanonicalOwners() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepElasticityEngineEvaluation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepElasticityEngineReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepElasticityEngineCore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepElasticityEngineInputs.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepElasticityEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepGraphCompilerCompile.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepGraphCompilerEdgeKindResolution.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepGraphCompilerCore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepGraphCompiler.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/StepQualityFirewall.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ScheduleInstallKernel.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ScheduleInstallKernelCore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ScheduleInstallKernelEvaluation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ScheduleInstallKernelReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ScheduleInstallRecord.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ScheduleInstallRecordSupport.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/SimpleStepLifecycleService+Recurring.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/SimpleStepLifecycleService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/StepReallocationRuntimeBridge.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/TimeRitualGoalSemantics.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical step planning/scheduling owner: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("StepElasticityEngineEvaluation.swift"),
            removedRuntimeOwnerPath("StepElasticityEngineReceipt.swift"),
            removedRuntimeOwnerPath("StepElasticityEngineCore.swift"),
            removedRuntimeOwnerPath("StepElasticityEngineInputs.swift"),
            removedRuntimeOwnerPath("StepElasticityEngine.swift"),
            removedRuntimeOwnerPath("StepGraphCompilerCompile.swift"),
            removedRuntimeOwnerPath("StepGraphCompilerEdgeKindResolution.swift"),
            removedRuntimeOwnerPath("StepGraphCompilerCore.swift"),
            removedRuntimeOwnerPath("StepGraphCompiler.swift"),
            removedRuntimeOwnerPath("StepQualityFirewall.swift"),
            removedRuntimeOwnerPath("ScheduleInstallKernel+02-ScheduleInstallRecord.swift"),
            removedRuntimeOwnerPath("ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift"),
            removedRuntimeOwnerPath("ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift"),
            removedRuntimeOwnerPath("ScheduleInstallKernel+03-ScheduleInstallKernel.swift"),
            removedRuntimeOwnerPath("ScheduleInstallKernel+04-ScheduleInstallRecord.swift"),
            removedRuntimeOwnerPath("ScheduleInstallKernel.swift"),
            removedRuntimeOwnerPath("SimpleStepLifecycleService+Recurring.swift"),
            removedRuntimeOwnerPath("SimpleStepLifecycleService.swift"),
            removedRuntimeOwnerPath("StepReallocationRuntimeBridge.swift"),
            removedRuntimeOwnerPath("TimeRitualGoalSemantics.swift"),
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "AMB-1730 step planning/scheduling owner still lives under production runtime owner: \(retiredPath)"
            )
        }
    }

    func testAMB1730EliminatesRemainingLegacyRuntimeProductionAuthority() throws {
        let root = repoRoot()
        let legacyRuntimeOwner = root.appendingPathComponent(removedRuntimeOwnerPath(), isDirectory: true)
        let legacySwiftFiles = try? FileManager.default.contentsOfDirectory(
            at: legacyRuntimeOwner,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "swift" }

        XCTAssertEqual(legacySwiftFiles ?? [], [], "the removed runtime owner must not contain production Swift authority after AMB-1730.")

        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/CaptureService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/SmartAttachmentService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/MultiPathLattice.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Planning/RecommendationEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/HighRiskSafetyJurisdictionGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/AmbitionsRuntimeGoalIntelligence.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/ExecutionResilienceProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/FirstRunActivationRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/GoldenVerticalSliceRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/LearningAnticipationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/LifeConsequenceEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/RuntimeCoreUmbrellaGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/SharedLifeCoordinationService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/CanonicalNowStateProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/GoalBelievabilityProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/GoalExplainabilityProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/LifeAreaAtlasProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/NorthStarProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/PathIntelligenceProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/RealityModelProjector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Projections/ReviewsV1Projector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeFactory.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/AppServices.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/DedicatedDevicePrototypeRuntime.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/RealityIntegrationAdapters.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimePackageBoundaryModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/SnapshotRefreshingServices.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/AnyGoalRuntimeCoverage.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeClaimBoundaryHardener.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeIngestionService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/KnowledgeProviderBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ClosureEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeShapeBucketBuilder.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeShapeEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LocalScheduleBlockRepository.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ProtectionEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/RitualOrchestrationService.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing AMB-1730 canonical owner after full legacy runtime pass: \(requiredPath)"
            )
        }
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeContracts.swift").path
            ),
            "The superseded AmbitionsRuntimeContracts owner must remain deleted after RuntimeCommandClient extraction."
        )
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
