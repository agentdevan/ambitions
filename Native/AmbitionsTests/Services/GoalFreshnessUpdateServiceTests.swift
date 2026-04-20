import XCTest
@testable import Ambitions

final class GoalFreshnessUpdateServiceTests: XCTestCase {
    private let referenceNow = "2026-04-20T12:00:00Z"

    func testFreshResourceStaysCurrentEnough() throws {
        let service = DefaultGoalFreshnessUpdateService()
        let claim = knowledgeClaim(
            id: "claim-fresh",
            sourceID: "source-fresh",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-06-01T00:00:00Z",
                expiresAt: nil,
                state: .fresh
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [resource(id: "resource-fresh", claimID: claim.id, sourceID: claim.source.id, freshnessState: .fresh)]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [claim], providerStatuses: [providerStatus()]),
            referenceNow: referenceNow
        )

        let impact = try XCTUnwrap(metadata.resourceImpacts.first)
        XCTAssertEqual(metadata.overallPosture, .currentEnough)
        XCTAssertFalse(metadata.updateNeeded)
        XCTAssertEqual(impact.posture, .currentEnough)
        XCTAssertEqual(impact.severity, .none)
        XCTAssertTrue(impact.rankingFlagsAdded.isEmpty)
    }

    func testNearStaleResourceBecomesAging() throws {
        let service = DefaultGoalFreshnessUpdateService()
        let claim = knowledgeClaim(
            id: "claim-aging",
            sourceID: "source-aging",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-04-23T12:00:00Z",
                expiresAt: nil,
                state: .fresh
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [resource(id: "resource-aging", claimID: claim.id, sourceID: claim.source.id, freshnessState: .fresh)]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [claim], providerStatuses: [providerStatus()]),
            referenceNow: referenceNow
        )

        let impact = try XCTUnwrap(metadata.resourceImpacts.first)
        XCTAssertEqual(impact.posture, .aging)
        XCTAssertEqual(impact.severity, .monitor)
        XCTAssertEqual(impact.flags, [.sourceAging])
        XCTAssertEqual(impact.rankingFlagsAdded, [.agingSource])
    }

    func testStaleAfterBeforeReferenceNowBecomesStaleEvenWhenStateIsFresh() throws {
        let service = DefaultGoalFreshnessUpdateService()
        let claim = knowledgeClaim(
            id: "claim-stale",
            sourceID: "source-stale",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-04-19T12:00:00Z",
                expiresAt: nil,
                state: .fresh
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [resource(id: "resource-stale", claimID: claim.id, sourceID: claim.source.id, freshnessState: .fresh)]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [claim], providerStatuses: [providerStatus()]),
            referenceNow: referenceNow
        )

        let impact = try XCTUnwrap(metadata.resourceImpacts.first)
        XCTAssertEqual(impact.posture, .stale)
        XCTAssertEqual(impact.severity, .recommended)
        XCTAssertEqual(impact.flags, [.sourceStale])
        XCTAssertEqual(impact.lineage.map(\.reason), [.sourceStale])
        XCTAssertEqual(impact.rankingFlagsAdded, [.staleSource, .updateRecommended])
    }

    func testExpiredResourceRequiresUpdate() throws {
        let service = DefaultGoalFreshnessUpdateService()
        let claim = knowledgeClaim(
            id: "claim-expired",
            sourceID: "source-expired",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-04-19T12:00:00Z",
                expiresAt: "2026-04-19T18:00:00Z",
                state: .fresh
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [resource(id: "resource-expired", claimID: claim.id, sourceID: claim.source.id, freshnessState: .fresh)]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [claim], providerStatuses: [providerStatus()]),
            referenceNow: referenceNow
        )

        let impact = try XCTUnwrap(metadata.resourceImpacts.first)
        XCTAssertEqual(metadata.maxSeverity, .required)
        XCTAssertEqual(impact.posture, .expired)
        XCTAssertEqual(impact.severity, .required)
        XCTAssertEqual(impact.rankingFlagsAdded, [.expiredSource, .updateRequired])
    }

    func testUnknownFreshnessIsNotPromoted() throws {
        let service = DefaultGoalFreshnessUpdateService()
        let claim = knowledgeClaim(
            id: "claim-unknown",
            sourceID: "source-unknown",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: nil,
                staleAfter: nil,
                expiresAt: nil,
                state: .unknown
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [resource(id: "resource-unknown", claimID: claim.id, sourceID: claim.source.id, freshnessState: .unknown)]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [claim], providerStatuses: [providerStatus()]),
            referenceNow: referenceNow
        )

        let impact = try XCTUnwrap(metadata.resourceImpacts.first)
        XCTAssertEqual(impact.posture, .unknownFreshness)
        XCTAssertTrue(impact.updateNeeded)
        XCTAssertEqual(impact.rankingFlagsAdded, [.unknownFreshness, .updateRecommended])
    }

    func testProviderUnavailableMarksImpactedResourceAndCandidate() throws {
        let service = DefaultGoalFreshnessUpdateService()
        let claim = knowledgeClaim(
            id: "claim-provider",
            sourceID: "source-provider",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-06-01T00:00:00Z",
                expiresAt: nil,
                state: .fresh
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [resource(id: "resource-provider", claimID: claim.id, sourceID: claim.source.id, freshnessState: .fresh)]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(
                claims: [claim],
                providerStatuses: [providerStatus(availability: .providerUnavailable)]
            ),
            referenceNow: referenceNow
        )

        let impact = try XCTUnwrap(metadata.resourceImpacts.first)
        let candidate = try XCTUnwrap(metadata.candidateSummaries.first)
        XCTAssertEqual(impact.posture, .providerUnavailable)
        XCTAssertEqual(impact.severity, .blocked)
        XCTAssertEqual(impact.rankingFlagsAdded, [.providerUnavailable, .updateRequired])
        XCTAssertEqual(candidate.affectedResourceIDs, ["resource-provider"])
        XCTAssertEqual(candidate.posture, .providerUnavailable)
    }

    func testPlaceholderAndUnresolvedResourcesRemainFirstClassBlockedEvidence() {
        let service = DefaultGoalFreshnessUpdateService()
        let placeholder = resource(
            id: "resource-placeholder",
            resolutionState: .placeholderOnly,
            missingResourceState: .resourceNeeded
        )
        let unresolved = resource(
            id: "resource-unresolved",
            resolutionState: .unresolved,
            missingResourceState: .referencedEvidenceMissing
        )

        let metadata = service.evaluate(
            graph: graph(resources: [placeholder, unresolved]),
            knowledgeContext: nil,
            referenceNow: referenceNow
        )

        XCTAssertEqual(metadata.resourceImpacts.map(\.resourceID), ["resource-placeholder", "resource-unresolved"])
        XCTAssertEqual(Set(metadata.resourceImpacts.map(\.posture)), [.blockedMissingEvidence])
        XCTAssertEqual(metadata.maxSeverity, .blocked)
        XCTAssertEqual(metadata.resourceImpacts.map(\.rankingFlagsAdded), [
            [.missingFreshnessEvidence, .updateRequired],
            [.missingFreshnessEvidence, .updateRequired],
        ])
    }

    func testCompetingResourcesProduceDeterministicFreshnessLineage() {
        let service = DefaultGoalFreshnessUpdateService()
        let fresh = knowledgeClaim(
            id: "claim-fresh",
            sourceID: "source-fresh",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-06-01T00:00:00Z",
                expiresAt: nil,
                state: .fresh
            )
        )
        let stale = knowledgeClaim(
            id: "claim-stale",
            sourceID: "source-stale",
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-01-01T00:00:00Z",
                staleAfter: "2026-04-19T12:00:00Z",
                expiresAt: nil,
                state: .stale
            )
        )

        let metadata = service.evaluate(
            graph: graph(resources: [
                resource(id: "resource-stale", claimID: stale.id, sourceID: stale.source.id, freshnessState: .stale),
                resource(id: "resource-fresh", claimID: fresh.id, sourceID: fresh.source.id, freshnessState: .fresh),
            ]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [stale, fresh], providerStatuses: [providerStatus()]),
            referenceNow: referenceNow
        )

        XCTAssertEqual(metadata.resourceImpacts.map(\.resourceID), ["resource-fresh", "resource-stale"])
        XCTAssertEqual(metadata.lineage.map { "\($0.resourceID ?? "")|\($0.claimID ?? "")|\($0.reason.rawValue)" }, [
            "resource-stale|claim-stale|source_stale",
        ])
        XCTAssertEqual(metadata.candidateSummaries.first?.affectedResourceIDs, ["resource-stale"])
    }
}

private extension GoalFreshnessUpdateServiceTests {
    func providerStatus(
        providerID: String = "official-api",
        availability: KnowledgeProviderAvailability = .available
    ) -> KnowledgeProviderStatus {
        KnowledgeProviderStatus(
            provider: KnowledgeProviderDescriptor(id: providerID, type: .officialAPI, displayName: "Official API"),
            availability: availability,
            detail: "Fixture",
            runtimeTrustPosture: .localOnly
        )
    }

    func knowledgeClaim(
        id: String,
        sourceID: String,
        providerID: String = "official-api",
        freshness: KnowledgeFreshnessMetadata
    ) -> KnowledgeClaim {
        KnowledgeClaim(
            id: id,
            providerID: providerID,
            subject: "career requirements",
            payload: KnowledgeClaimPayload(summary: "Fixture claim", detail: nil),
            source: KnowledgeSourceRecord(
                id: sourceID,
                providerID: providerID,
                entityTitle: "Fixture Source",
                publisher: "Fixture Publisher",
                locator: "https://example.com/\(sourceID)",
                provenanceKind: .official,
                isOfficial: true
            ),
            freshness: freshness,
            trustLevel: .high,
            confidence: .high,
            uncertaintyFlags: [],
            explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: [sourceID], notes: [])
        )
    }

    func resource(
        id: String,
        claimID: String? = nil,
        sourceID: String? = nil,
        freshnessState: KnowledgeFreshnessState? = nil,
        resolutionState: GoalResourceResolutionState = .concrete,
        missingResourceState: GoalResourceMissingState = .none
    ) -> GoalResourceEntity {
        GoalResourceEntity(
            id: id,
            candidateID: "candidate-1",
            targetStageID: "stage-readiness",
            hookID: "hook-1",
            selectionGroupID: "selection-1",
            hookKind: .requirementReference,
            resourceType: .reference,
            resourceRole: .requirementSupport,
            resolutionState: resolutionState,
            originRelation: claimID == nil ? .packContributed : .packAndKnowledge,
            optionality: .required,
            relatedDomains: [.career],
            appliedPackIDs: ["career"],
            claimIDs: claimID.map { [$0] } ?? [],
            sourceRecordIDs: sourceID.map { [$0] } ?? [],
            trustLevel: claimID == nil ? nil : .high,
            freshnessState: freshnessState,
            uncertaintyFlags: [],
            missingResourceState: missingResourceState,
            ranking: GoalResourceRankingMetadata(
                rank: 1,
                totalScore: 0.9,
                sourceTrustScore: 0.3,
                sourceFreshnessScore: 0.2,
                domainRelevanceScore: 0.12,
                stageRelevanceScore: 0.12,
                readinessRelevanceScore: 0.12,
                optionalityScore: 0.09,
                tieBreakKey: id,
                flags: []
            )
        )
    }

    func graph(resources: [GoalResourceEntity]) -> GoalResourceGraph {
        GoalResourceGraph(
            schemaVersion: goalResourceGraphSchemaVersion,
            sourceCompiledPathSchemaVersion: goalPathCompilerSchemaVersion,
            overallPosture: .provisional,
            candidateGraphs: [
                GoalResourceGraphCandidate(
                    candidateID: "candidate-1",
                    isPrimary: true,
                    posture: .provisional,
                    stageIDs: ["stage-readiness"],
                    resourceIDs: resources.map(\.id).sorted()
                )
            ],
            resources: resources,
            sources: resources.compactMap { resource in
                guard let sourceID = resource.sourceRecordIDs.first else { return nil }
                return GoalResourceSourceEntity(
                    id: sourceID,
                    sourceRecordID: sourceID,
                    providerID: "official-api",
                    provenanceKind: .official,
                    isOfficial: true,
                    publisher: "Fixture Publisher",
                    locator: "https://example.com/\(sourceID)"
                )
            },
            audit: GoalResourceGraphAuditMetadata(entries: [])
        )
    }
}
