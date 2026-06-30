@testable import Ambitions
import XCTest

final class PlanningEngineTests: XCTestCase {
    func testPlanningEngineOwnerFilesExistUnderCanonicalTreeAndOldPlannerOwnersAreRemoved() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/PlanningGraph.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepCandidateFieldModels+05-StepCandidateField.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalPathPlanner.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/FreeFloatingStepPlanner.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/PlanRepairEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/SmallerStepEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/DependencyResolver.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/ProgressPreservationEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/DeterministicGoalPlanner.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/PlanningEvaluation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/SourceAtlasStepCandidateFieldBridge.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepCandidateFieldGenerator.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/Planning").path),
            "Planning source must be owned by Core/LocalRuntimeOS/PlanningEngine."
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Runtime/StepCandidateFieldGenerator.swift").path),
            "StepCandidateFieldGenerator must be owned by Core/LocalRuntimeOS/PlanningEngine."
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/GoalEngine/StepCandidateFieldModels.swift").path),
            "StepCandidateField models must be owned by Core/LocalRuntimeOS/PlanningEngine."
        )
    }

    func testGoalPathPlannerBuildsReplayReadyLocalPlanFromPlanSteps() {
        let plan = GoalPathPlanner().plan(
            goalID: "goal-runtime-os",
            title: "Install local runtime OS",
            steps: [
                PlanStep(
                    id: "scope",
                    title: "Define command spine",
                    summary: "Describe command event projection receipt replay.",
                    type: .actionUnit,
                    pace: .untimed,
                    repeatEveryDays: 18,
                    evidenceHint: "Command spine is written."
                ),
                PlanStep(
                    id: "journal",
                    title: "Install event journal",
                    summary: "Add the append-only journal.",
                    type: .actionUnit,
                    pace: .untimed,
                    repeatEveryDays: 22,
                    evidenceHint: "Journal proof exists."
                ),
            ],
            generatedAt: "2026-06-30T12:00:00Z"
        )

        XCTAssertEqual(plan.goalID, "goal-runtime-os")
        XCTAssertTrue(plan.localOnly)
        XCTAssertTrue(plan.isReplayReady)
        XCTAssertEqual(plan.planningGraph.nodeIDs, ["scope", "journal"])
        XCTAssertNotNil(plan.selectedCandidate)
        XCTAssertEqual(plan.candidateField.goalID, "goal-runtime-os")
        XCTAssertTrue(plan.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay)
        XCTAssertTrue([PlanRepairActionKind.useSelectedCandidate, .proposeSmallerStep].contains(plan.repairTrace.actionKind))
    }

    func testDependencyResolverBlocksDependentNodeUntilRequiredNodeIsComplete() {
        let graph = PlanningGraph(
            goalID: "goal-dependencies",
            generatedAt: "2026-06-30T12:10:00Z",
            nodes: [
                PlanningGraphNode(id: "setup", title: "Finish setup", orderIndex: 0),
                PlanningGraphNode(id: "execute", title: "Execute step", orderIndex: 1, dependencyIDs: ["setup"]),
            ]
        )
        let blocked = DependencyResolver().resolve(graph)

        XCTAssertEqual(blocked.readyNodeIDs, ["setup"])
        XCTAssertEqual(blocked.blockedNodeIDs, ["execute"])
        XCTAssertTrue(blocked.hasBlockingFailures)

        let completedGraph = graph.replacing(nodeStates: ["setup": .completed])
        let resolved = DependencyResolver().resolve(completedGraph)

        XCTAssertEqual(resolved.readyNodeIDs, ["execute"])
        XCTAssertFalse(resolved.hasBlockingFailures)
        XCTAssertEqual(resolved.topologicalOrder, ["setup", "execute"])
    }

    func testPlanRepairEngineProposesSmallerStepForReviewRiskCandidateField() {
        let plan = GoalPathPlanner().plan(
            goalID: "goal-repair",
            title: "Repair an oversized step",
            steps: [
                PlanStep(
                    id: "oversized",
                    title: "Complete the whole migration",
                    summary: "Move a broad runtime owner.",
                    type: .actionUnit,
                    pace: .untimed,
                    repeatEveryDays: 32,
                    evidenceHint: "Migration is complete."
                ),
            ],
            generatedAt: "2026-06-30T12:20:00Z"
        )

        XCTAssertEqual(plan.repairTrace.actionKind, .proposeSmallerStep)
        let proposal = plan.repairTrace.smallerStepProposal
        XCTAssertNotNil(proposal)
        XCTAssertTrue(proposal?.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay == true)
        XCTAssertTrue(proposal?.reasons.isEmpty == false)
        XCTAssertNotEqual(proposal?.originalCandidateID, proposal?.proposedCandidateID)
    }

    func testProgressPreservationKeepsCompletedProofAndActiveNodesVisibleToRepair() {
        let graph = PlanningGraph(
            goalID: "goal-preserve",
            generatedAt: "2026-06-30T12:30:00Z",
            nodes: [
                PlanningGraphNode(id: "done", stepID: "step-done", title: "Done", orderIndex: 0, state: .completed),
                PlanningGraphNode(id: "proof", stepID: "step-proof", title: "Proof", orderIndex: 1, proofRequired: true),
                PlanningGraphNode(id: "active", stepID: "step-active", title: "Active", orderIndex: 2, dependencyIDs: ["done"]),
            ]
        )

        let report = ProgressPreservationEngine().preserve(
            graph: graph,
            proofBearingNodeIDs: ["step-proof"],
            activeNodeIDs: ["step-active"]
        )

        XCTAssertEqual(report.preservedNodeIDs, ["done", "proof"])
        XCTAssertEqual(report.proofBearingNodeIDs, ["proof"])
        XCTAssertEqual(report.activeNodeIDs, ["active"])
        XCTAssertFalse(report.preservedDependencyIDs.isEmpty)
        XCTAssertTrue(report.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay)
    }

    func testFreeFloatingStepPlannerStaysLocalOnlyAndUnscopedToGoalGraph() {
        let plan = FreeFloatingStepPlanner().plan(
            title: "Review runtime notes",
            summary: "Turn notes into a next step.",
            generatedAt: "2026-06-30T12:40:00Z",
            estimatedMinutes: 9,
            contextRequirements: ["Local notes"]
        )

        XCTAssertNil(plan.planningGraph.goalID)
        XCTAssertNil(plan.candidateField.goalID)
        XCTAssertTrue(plan.localOnly)
        XCTAssertNotNil(plan.selectedCandidate)
        XCTAssertTrue(plan.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay)
        XCTAssertTrue(plan.candidateField.localOnly)
    }
}

private extension PlanningEngineTests {
    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "PlanningEngineTests", code: 1)
    }
}
