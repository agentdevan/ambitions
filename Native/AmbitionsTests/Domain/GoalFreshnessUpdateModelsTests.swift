import XCTest
@testable import Ambitions

final class GoalFreshnessUpdateModelsTests: XCTestCase {
    func testFreshnessMetadataRoundTripsThroughCodable() throws {
        let metadata = GoalResourceGraphFreshnessMetadata(
            evaluatedAt: "2026-04-20T12:00:00Z",
            overallPosture: .stale,
            updateNeeded: true,
            maxSeverity: .recommended,
            resourceImpacts: [
                GoalResourceFreshnessImpact(
                    resourceID: "resource-1",
                    posture: .stale,
                    updateNeeded: true,
                    severity: .recommended,
                    flags: [.sourceStale],
                    lineage: [
                        GoalFreshnessLineageRef(
                            providerID: "official-api",
                            sourceRecordID: "source-1",
                            claimID: "claim-1",
                            resourceID: "resource-1",
                            candidateID: "candidate-1",
                            stageID: "stage-readiness",
                            reason: .sourceStale
                        )
                    ],
                    rankingImpactScore: -0.12,
                    rankingFlagsAdded: [.staleSource, .updateRecommended]
                )
            ],
            candidateSummaries: [
                GoalPathCandidateFreshnessSummary(
                    candidateID: "candidate-1",
                    affectedResourceIDs: ["resource-1"],
                    posture: .stale,
                    updateNeeded: true,
                    severity: .recommended
                )
            ],
            lineage: [
                GoalFreshnessLineageRef(
                    providerID: "official-api",
                    sourceRecordID: "source-1",
                    claimID: "claim-1",
                    resourceID: "resource-1",
                    candidateID: "candidate-1",
                    stageID: "stage-readiness",
                    reason: .sourceStale
                )
            ]
        )

        let encoded = try JSONEncoder().encode(metadata)
        let decoded = try JSONDecoder().decode(GoalResourceGraphFreshnessMetadata.self, from: encoded)

        XCTAssertEqual(decoded, metadata)
    }

    func testSeverityOrderingIsStable() {
        XCTAssertTrue(GoalUpdateNeededSeverity.blocked.isMoreSevere(than: .required))
        XCTAssertTrue(GoalUpdateNeededSeverity.required.isMoreSevere(than: .recommended))
        XCTAssertTrue(GoalUpdateNeededSeverity.recommended.isMoreSevere(than: .monitor))
        XCTAssertTrue(GoalUpdateNeededSeverity.monitor.isMoreSevere(than: .none))
        XCTAssertEqual([.recommended, .none, .blocked, .monitor, .required].sortedBySeverityDescending(), [.blocked, .required, .recommended, .monitor, .none])
    }
}
