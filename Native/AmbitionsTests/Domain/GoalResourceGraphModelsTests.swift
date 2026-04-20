import XCTest
@testable import Ambitions

final class GoalResourceGraphModelsTests: XCTestCase {
    func testGoalResourceGraphRoundTripsThroughCodable() throws {
        let graph = sampleResourceGraph()

        let encoded = try JSONEncoder().encode(graph)
        let decoded = try JSONDecoder().decode(GoalResourceGraph.self, from: encoded)

        XCTAssertEqual(decoded, graph)
    }

    func testPlaceholderOnlyResourceStateRemainsStructural() throws {
        let resource = try XCTUnwrap(sampleResourceGraph().resources.first(where: { $0.resolutionState == .placeholderOnly }))

        XCTAssertEqual(resource.missingResourceState, .resourceNeeded)
        XCTAssertTrue(resource.claimIDs.isEmpty)
        XCTAssertTrue(resource.sourceRecordIDs.isEmpty)
        XCTAssertEqual(resource.ranking.flags, [.placeholderOnly, .missingConcreteResource])
    }
}

private extension GoalResourceGraphModelsTests {
    func sampleResourceGraph() -> GoalResourceGraph {
        GoalResourceGraph(
            schemaVersion: goalResourceGraphSchemaVersion,
            sourceCompiledPathSchemaVersion: goalPathCompilerSchemaVersion,
            overallPosture: .provisional,
            candidateGraphs: [
                GoalResourceGraphCandidate(
                    candidateID: "candidate-primary",
                    isPrimary: true,
                    posture: .provisional,
                    stageIDs: ["stage-readiness"],
                    resourceIDs: ["resource-placeholder", "resource-concrete"]
                )
            ],
            resources: [
                GoalResourceEntity(
                    id: "resource-placeholder",
                    candidateID: "candidate-primary",
                    targetStageID: "stage-readiness",
                    hookID: "hook-placeholder",
                    selectionGroupID: "selection-placeholder",
                    hookKind: .requirementReference,
                    resourceType: .reference,
                    resourceRole: .requirementSupport,
                    resolutionState: .placeholderOnly,
                    originRelation: .packContributed,
                    optionality: .required,
                    relatedDomains: [.career],
                    appliedPackIDs: ["career"],
                    claimIDs: [],
                    sourceRecordIDs: [],
                    trustLevel: nil,
                    freshnessState: nil,
                    uncertaintyFlags: [],
                    missingResourceState: .resourceNeeded,
                    ranking: GoalResourceRankingMetadata(
                        rank: 2,
                        totalScore: 0.45,
                        sourceTrustScore: 0,
                        sourceFreshnessScore: 0,
                        domainRelevanceScore: 0.12,
                        stageRelevanceScore: 0.12,
                        readinessRelevanceScore: 0.12,
                        optionalityScore: 0.09,
                        tieBreakKey: "selection-placeholder-placeholder",
                        flags: [.placeholderOnly, .missingConcreteResource]
                    )
                ),
                GoalResourceEntity(
                    id: "resource-concrete",
                    candidateID: "candidate-primary",
                    targetStageID: "stage-readiness",
                    hookID: "hook-placeholder",
                    selectionGroupID: "selection-placeholder",
                    hookKind: .requirementReference,
                    resourceType: .reference,
                    resourceRole: .requirementSupport,
                    resolutionState: .concrete,
                    originRelation: .packAndKnowledge,
                    optionality: .required,
                    relatedDomains: [.career],
                    appliedPackIDs: ["career"],
                    claimIDs: ["claim-1"],
                    sourceRecordIDs: ["source-1"],
                    trustLevel: .high,
                    freshnessState: .fresh,
                    uncertaintyFlags: [],
                    missingResourceState: .none,
                    ranking: GoalResourceRankingMetadata(
                        rank: 1,
                        totalScore: 0.92,
                        sourceTrustScore: 0.3,
                        sourceFreshnessScore: 0.2,
                        domainRelevanceScore: 0.12,
                        stageRelevanceScore: 0.12,
                        readinessRelevanceScore: 0.12,
                        optionalityScore: 0.09,
                        tieBreakKey: "selection-placeholder-claim-1",
                        flags: [.officialSource, .stageAligned, .readinessAligned]
                    )
                )
            ],
            sources: [
                GoalResourceSourceEntity(
                    id: "source-1",
                    sourceRecordID: "source-1",
                    providerID: "official-api",
                    provenanceKind: .official,
                    isOfficial: true,
                    publisher: "Example Org",
                    locator: "https://example.com"
                )
            ],
            audit: GoalResourceGraphAuditMetadata(
                entries: [
                    GoalResourceGraphAuditEntry(
                        id: "audit-resource-placeholder",
                        resourceID: "resource-placeholder",
                        candidateID: "candidate-primary",
                        targetStageID: "stage-readiness",
                        hookID: "hook-placeholder",
                        packAuditEntryID: "pack-audit-1",
                        claimID: nil,
                        sourceRecordID: nil,
                        rankingFlags: [.placeholderOnly, .missingConcreteResource]
                    ),
                    GoalResourceGraphAuditEntry(
                        id: "audit-resource-concrete",
                        resourceID: "resource-concrete",
                        candidateID: "candidate-primary",
                        targetStageID: "stage-readiness",
                        hookID: "hook-placeholder",
                        packAuditEntryID: "pack-audit-1",
                        claimID: "claim-1",
                        sourceRecordID: "source-1",
                        rankingFlags: [.officialSource, .stageAligned, .readinessAligned]
                    )
                ]
            )
        )
    }
}
