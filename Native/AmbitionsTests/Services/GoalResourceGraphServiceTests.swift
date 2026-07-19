import XCTest
@testable import Ambitions

final class GoalResourceGraphServiceTests: XCTestCase {
    func testServiceBuildsDeterministicGraphForRepeatedInputs() {
        let service = DefaultGoalResourceGraphService()
        let compiledPath = GoalCompiledPath.legacyFallback(from: sampleUnderstanding())
        let context = sampleKnowledgeContext()

        let first = service.build(compiledPath: compiledPath, knowledgeContext: context)
        let second = service.build(compiledPath: compiledPath, knowledgeContext: context)

        XCTAssertEqual(first, second)
    }

    func testServiceKeepsPlaceholderHooksWhenKnowledgeContextIsAbsent() throws {
        let service = DefaultGoalResourceGraphService()
        let compiledPath = compiledPathWithPlaceholderHook()

        let graph = service.build(compiledPath: compiledPath, knowledgeContext: nil)

        let placeholder = try XCTUnwrap(graph.resources.first(where: { $0.resolutionState == .placeholderOnly }))
        XCTAssertEqual(placeholder.missingResourceState, .resourceNeeded)
        XCTAssertTrue(graph.sources.isEmpty)
        XCTAssertEqual(graph.freshness.overallPosture, .blockedMissingEvidence)
        XCTAssertEqual(graph.freshness.resourceImpacts.map(\.resourceID), [placeholder.id])
    }

    func testServiceRanksCompetingConcreteResourcesDeterministically() {
        let service = DefaultGoalResourceGraphService()
        let graph = service.build(compiledPath: compiledPathWithSourcedHook(), knowledgeContext: competingKnowledgeContext())

        let selectionGroupID = graph.resources
            .first(where: { $0.claimIDs.contains("claim-high") })?
            .selectionGroupID
        let ranked = graph.resources
            .filter { $0.selectionGroupID == selectionGroupID }
            .sorted { $0.ranking.rank < $1.ranking.rank }

        XCTAssertEqual(ranked.map(\.claimIDs.first), ["claim-high", "claim-medium"])
        XCTAssertEqual(ranked.map(\.ranking.rank), [1, 2])
        XCTAssertTrue(graph.freshness.resourceImpacts.contains(where: { $0.posture == .blockedMissingEvidence }))
        XCTAssertEqual(graph.freshness.resourceImpacts.first(where: { $0.resourceID == ranked[1].id })?.posture, .stale)
        XCTAssertTrue(graph.freshness.candidateSummaries.first?.affectedResourceIDs.contains(ranked[1].id) == true)
        XCTAssertTrue(ranked[1].ranking.flags.contains(.updateRecommended))
    }

    func testServiceUsesClaimEmbeddedSourcesWhenKnowledgeContextSourcesAreEmpty() {
        let service = DefaultGoalResourceGraphService()
        let graph = service.build(compiledPath: compiledPathWithSourcedHook(), knowledgeContext: knowledgeContextWithClaimOnlySources())

        XCTAssertEqual(graph.sources.map(\.sourceRecordID), ["source-high"])
    }

    func testServiceAppliesDateBasedFreshnessEvaluationAfterGraphBuild() throws {
        let service = DefaultGoalResourceGraphService()
        let claim = KnowledgeClaim(
            id: "claim-date-stale",
            providerID: "official-api",
            subject: "career requirements",
            payload: KnowledgeClaimPayload(summary: "Date stale claim", detail: nil),
            source: KnowledgeSourceRecord(
                id: "source-date-stale",
                providerID: "official-api",
                entityTitle: "Date Stale Requirements",
                publisher: "Official Org",
                locator: "https://example.com/date-stale",
                provenanceKind: .official,
                isOfficial: true
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-20T10:00:00Z",
                publishedAt: "2026-04-01T00:00:00Z",
                staleAfter: "2026-04-19T12:00:00Z",
                expiresAt: nil,
                state: .fresh
            ),
            trustLevel: .high,
            confidence: .high,
            uncertaintyFlags: [],
            explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: ["source-date-stale"], notes: [])
        )
        let graph = service.build(
            compiledPath: compiledPathWithSourcedHook(claimIDs: [claim.id], sourceIDs: [claim.source.id]),
            knowledgeContext: GoalUnderstandingKnowledgeContext(claims: [claim], providerStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(id: "official-api", type: .officialAPI, displayName: "Official API"),
                    availability: .available,
                    detail: "Available",
                    runtimeTrustPosture: .localOnly
                )
            ]),
            referenceNow: "2026-04-20T12:00:00Z"
        )

        let impact = try XCTUnwrap(graph.freshness.resourceImpacts.first(where: { $0.resourceID.contains("claim-date-stale") }))
        let resource = try XCTUnwrap(graph.resources.first(where: { $0.id == impact.resourceID }))
        XCTAssertEqual(impact.posture, .stale)
        XCTAssertEqual(impact.lineage.map(\.reason), [.sourceStale])
        XCTAssertTrue(resource.ranking.flags.contains(.updateRecommended))
    }
}

private extension GoalResourceGraphServiceTests {
    func sampleUnderstanding() -> GoalUnderstanding {
        GoalPathCompilerServiceTests().sampleUnderstanding()
    }

    func sampleKnowledgeContext() -> GoalUnderstandingKnowledgeContext {
        GoalUnderstandingKnowledgeContext(
            claims: [
                KnowledgeClaim(
                    id: "claim-1",
                    providerID: "official-api",
                    subject: "career requirements",
                    payload: KnowledgeClaimPayload(summary: "Applications require a portfolio.", detail: nil),
                    source: KnowledgeSourceRecord(
                        id: "source-1",
                        providerID: "official-api",
                        entityTitle: "Portfolio Requirements",
                        publisher: "Example Org",
                        locator: "https://example.com/portfolio",
                        provenanceKind: .official,
                        isOfficial: true
                    ),
                    freshness: KnowledgeFreshnessMetadata(
                        retrievedAt: GoalEngineFixtures.fixedNow,
                        publishedAt: "2026-04-01T00:00:00Z",
                        staleAfter: "2026-09-01T00:00:00Z",
                        expiresAt: nil,
                        state: .fresh
                    ),
                    trustLevel: .high,
                    confidence: .high,
                    uncertaintyFlags: [],
                    explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: ["source-1"], notes: [])
                )
            ],
            sources: [],
            providerStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(id: "official-api", type: .officialAPI, displayName: "Official API"),
                    availability: .available,
                    detail: "Available",
                    runtimeTrustPosture: .localOnly
                )
            ]
        )
    }

    func compiledPathWithSourcedHook(
        claimIDs: [String] = ["claim-high", "claim-medium"],
        sourceIDs: [String] = ["source-high", "source-medium"]
    ) -> GoalCompiledPath {
        let base = GoalCompiledPath.legacyFallback(from: sampleUnderstanding())
        let primary = base.candidates[0]
        let readinessStageID = primary.stages.first(where: { $0.kind == .readiness })?.id ?? "stage-readiness"
        let sourcedHook = GoalCompiledPathResourceHook(
            id: "hook-ranked",
            summary: "Rank requirement references",
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.career],
            sourceClaimIDs: claimIDs,
            sourceRecordIDs: sourceIDs,
            optionality: .required,
            placeholderState: .resourceNeeded
        )
        let placeholderHook = GoalCompiledPathResourceHook(
            id: "hook-placeholder",
            summary: "Keep placeholder coverage",
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.career],
            sourceClaimIDs: [],
            sourceRecordIDs: [],
            optionality: .required,
            placeholderState: .resourceNeeded
        )

        let candidate = GoalCompiledPathCandidate(
            id: primary.id,
            title: primary.title,
            summary: primary.summary,
            isPrimary: primary.isPrimary,
            posture: primary.posture,
            safeForStarterPlanning: primary.safeForStarterPlanning,
            stages: primary.stages,
            dependencies: primary.dependencies,
            branches: primary.branches,
            assumptions: primary.assumptions,
            risks: primary.risks,
            appliedPacks: primary.appliedPacks,
            requirementHints: primary.requirementHints,
            readinessCriteria: primary.readinessCriteria,
            resourceHooks: [placeholderHook, sourcedHook],
            blockingReasons: primary.blockingReasons,
            confidence: primary.confidence
        )

        return GoalCompiledPath(
            schemaVersion: base.schemaVersion,
            sourceUnderstandingSchemaVersion: base.sourceUnderstandingSchemaVersion,
            overallPosture: base.overallPosture,
            safeForStarterPlanning: base.safeForStarterPlanning,
            candidates: [candidate],
            uncertainty: base.uncertainty,
            audit: GoalCompiledPathAuditMetadata(
                entries: base.audit.entries,
                packEntries: [
                    GoalCompiledPathPackAuditEntry(
                        id: "pack-audit-1",
                        packID: "career",
                        contributionKind: .resourceHook,
                        artifactID: "hook-placeholder",
                        targetCandidateID: primary.id,
                        targetStageID: readinessStageID,
                        summary: "Placeholder hook lineage."
                    ),
                    GoalCompiledPathPackAuditEntry(
                        id: "pack-audit-2",
                        packID: "career",
                        contributionKind: .resourceHook,
                        artifactID: "hook-ranked",
                        targetCandidateID: primary.id,
                        targetStageID: readinessStageID,
                        summary: "Ranked hook lineage."
                    )
                ]
            )
        )
    }

    func compiledPathWithPlaceholderHook() -> GoalCompiledPath {
        let base = GoalCompiledPath.legacyFallback(from: sampleUnderstanding())
        let primary = base.candidates[0]
        let readinessStageID = primary.stages.first(where: { $0.kind == .readiness })?.id ?? "stage-readiness"
        let placeholderHook = GoalCompiledPathResourceHook(
            id: "hook-placeholder-only",
            summary: "Keep placeholder-only resource coverage",
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.career],
            sourceClaimIDs: [],
            sourceRecordIDs: [],
            optionality: .required,
            placeholderState: .resourceNeeded
        )

        let candidate = GoalCompiledPathCandidate(
            id: primary.id,
            title: primary.title,
            summary: primary.summary,
            isPrimary: primary.isPrimary,
            posture: primary.posture,
            safeForStarterPlanning: primary.safeForStarterPlanning,
            stages: primary.stages,
            dependencies: primary.dependencies,
            branches: primary.branches,
            assumptions: primary.assumptions,
            risks: primary.risks,
            appliedPacks: primary.appliedPacks,
            requirementHints: primary.requirementHints,
            readinessCriteria: primary.readinessCriteria,
            resourceHooks: [placeholderHook],
            blockingReasons: primary.blockingReasons,
            confidence: primary.confidence
        )

        return GoalCompiledPath(
            schemaVersion: base.schemaVersion,
            sourceUnderstandingSchemaVersion: base.sourceUnderstandingSchemaVersion,
            overallPosture: .provisional,
            safeForStarterPlanning: base.safeForStarterPlanning,
            candidates: [candidate],
            uncertainty: base.uncertainty,
            audit: GoalCompiledPathAuditMetadata(
                entries: base.audit.entries,
                packEntries: [
                    GoalCompiledPathPackAuditEntry(
                        id: "pack-audit-placeholder-only",
                        packID: "career",
                        contributionKind: .resourceHook,
                        artifactID: "hook-placeholder-only",
                        targetCandidateID: primary.id,
                        targetStageID: readinessStageID,
                        summary: "Placeholder-only hook lineage."
                    )
                ]
            )
        )
    }

    func competingKnowledgeContext() -> GoalUnderstandingKnowledgeContext {
        GoalUnderstandingKnowledgeContext(
            claims: [
                KnowledgeClaim(
                    id: "claim-high",
                    providerID: "official-api",
                    subject: "career requirements",
                    payload: KnowledgeClaimPayload(summary: "Official entry requirements", detail: nil),
                    source: KnowledgeSourceRecord(
                        id: "source-high",
                        providerID: "official-api",
                        entityTitle: "Official Requirements",
                        publisher: "Official Org",
                        locator: "https://example.com/high",
                        provenanceKind: .official,
                        isOfficial: true
                    ),
                    freshness: KnowledgeFreshnessMetadata(
                        retrievedAt: GoalEngineFixtures.fixedNow,
                        publishedAt: "2026-04-01T00:00:00Z",
                        staleAfter: "2026-09-01T00:00:00Z",
                        expiresAt: nil,
                        state: .fresh
                    ),
                    trustLevel: .high,
                    confidence: .high,
                    uncertaintyFlags: [],
                    explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: ["source-high"], notes: [])
                ),
                KnowledgeClaim(
                    id: "claim-medium",
                    providerID: "dataset-api",
                    subject: "career requirements",
                    payload: KnowledgeClaimPayload(summary: "Community compiled requirements", detail: nil),
                    source: KnowledgeSourceRecord(
                        id: "source-medium",
                        providerID: "dataset-api",
                        entityTitle: "Community Requirements",
                        publisher: "Community Org",
                        locator: "https://example.com/medium",
                        provenanceKind: .providerReported,
                        isOfficial: false
                    ),
                    freshness: KnowledgeFreshnessMetadata(
                        retrievedAt: GoalEngineFixtures.fixedNow,
                        publishedAt: "2025-12-01T00:00:00Z",
                        staleAfter: "2026-05-01T00:00:00Z",
                        expiresAt: nil,
                        state: .stale
                    ),
                    trustLevel: .medium,
                    confidence: .medium,
                    uncertaintyFlags: [.stale],
                    explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: ["source-medium"], notes: [])
                )
            ],
            sources: [],
            providerStatuses: []
        )
    }

    func knowledgeContextWithClaimOnlySources() -> GoalUnderstandingKnowledgeContext {
        GoalUnderstandingKnowledgeContext(
            claims: [
                KnowledgeClaim(
                    id: "claim-high",
                    providerID: "official-api",
                    subject: "career requirements",
                    payload: KnowledgeClaimPayload(summary: "Claim carries its own source.", detail: nil),
                    source: KnowledgeSourceRecord(
                        id: "source-high",
                        providerID: "official-api",
                        entityTitle: "Claim Embedded Source",
                        publisher: "Example Org",
                        locator: "https://example.com/claim-only",
                        provenanceKind: .official,
                        isOfficial: true
                    ),
                    freshness: KnowledgeFreshnessMetadata(
                        retrievedAt: GoalEngineFixtures.fixedNow,
                        publishedAt: "2026-04-01T00:00:00Z",
                        staleAfter: "2026-09-01T00:00:00Z",
                        expiresAt: nil,
                        state: .fresh
                    ),
                    trustLevel: .high,
                    confidence: .high,
                    uncertaintyFlags: [],
                    explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: ["source-claim-only"], notes: [])
                )
            ],
            sources: [],
            providerStatuses: []
        )
    }
}
