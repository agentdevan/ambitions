import XCTest
@testable import Ambitions

final class GoalEnergyFitModelsTests: XCTestCase {
    func testGoalEnergyModelRoundTripsThroughCodable() throws {
        let model = GoalEnergyModel(
            schemaVersion: goalEnergyFitSchemaVersion,
            sourceCompiledPathSchemaVersion: goalPathCompilerSchemaVersion,
            capacityContext: .assumedNeutral(),
            overallBand: .sustainable,
            candidateSummaries: [
                GoalEnergyCandidateSummary(
                    candidateID: "candidate-primary",
                    fitBand: .sustainable,
                    score: 0.72,
                    evaluationIDs: ["energy-candidate-primary"]
                )
            ],
            evaluations: [
                GoalEnergyFitEvaluation(
                    id: "energy-candidate-primary",
                    targetKind: .pathCandidate,
                    targetID: "candidate-primary",
                    candidateID: "candidate-primary",
                    stageID: nil,
                    stepID: nil,
                    workShape: .planning,
                    effortDemand: .moderate,
                    focusDemand: .moderate,
                    recoveryCompatibility: .compatible,
                    pacingPosture: .steady,
                    fitBand: .sustainable,
                    score: 0.72,
                    reasons: [
                        GoalEnergyFitReason(
                            code: .assumedNeutralCapacity,
                            targetKind: .pathCandidate,
                            targetID: "candidate-primary",
                            relatedStageKind: nil,
                            relatedStepType: nil,
                            impact: .neutral,
                            summary: "Assumed neutral planning context."
                        )
                    ]
                )
            ],
            audit: GoalEnergyModelAuditMetadata(
                entries: [
                    GoalEnergyModelAuditEntry(
                        id: "audit-energy-candidate-primary",
                        targetKind: .pathCandidate,
                        targetID: "candidate-primary",
                        reasonCodes: [.assumedNeutralCapacity]
                    )
                ]
            )
        )

        let decoded = try JSONDecoder().decode(GoalEnergyModel.self, from: JSONEncoder().encode(model))

        XCTAssertEqual(decoded, model)
        XCTAssertEqual(decoded.evaluations.first?.reasons.map(\.code), [.assumedNeutralCapacity])
    }

    func testUnevaluatedFallbackUsesExplicitUnknownPlanningContext() {
        let model = GoalEnergyModel.unevaluated()

        XCTAssertEqual(model.schemaVersion, goalEnergyFitSchemaVersion)
        XCTAssertEqual(model.capacityContext.capacityLevel, .unknown)
        XCTAssertEqual(model.capacityContext.recoveryState, .unknown)
        XCTAssertEqual(model.capacityContext.source, .unknown)
        XCTAssertEqual(model.overallBand, .unknown)
        XCTAssertTrue(model.candidateSummaries.isEmpty)
        XCTAssertTrue(model.evaluations.isEmpty)
    }

    func testLegacyOrchestrationMetadataWithoutEnergyModelDecodesSafely() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        guard case let .planned(result) = fixture.result else {
            return XCTFail("Expected planned result.")
        }
        let encoded = try JSONSerialization.jsonObject(with: JSONEncoder().encode(result.metadata)) as? [String: Any]
        var legacy = try XCTUnwrap(encoded)
        legacy.removeValue(forKey: "energyModel")
        let legacyData = try JSONSerialization.data(withJSONObject: legacy)

        let decoded = try JSONDecoder().decode(GoalOrchestrationMetadata.self, from: legacyData)

        XCTAssertEqual(decoded.energyModel.overallBand, .unknown)
        XCTAssertEqual(decoded.energyModel.capacityContext.source, .unknown)
    }
}
