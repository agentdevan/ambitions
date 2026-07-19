import XCTest
@testable import Ambitions

final class LifeContextRepositoryTests: XCTestCase {
    func testSwiftDataRepositorySavesLoadsUpdatesMarksDeletedAndProjectsSafely() async throws {
        let repository = try await makeRepository()
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z"))
        let initial = LifeContextFixtureProfiles.adultWorkshopLaunchWithMakerAccess()

        try await repository.saveBundles([initial])
        let loadedBundle = try await repository.bundle(id: initial.id)
        let loaded = try XCTUnwrap(loadedBundle)

        XCTAssertEqual(loaded, initial)
        let savedBundleIDs = try await repository.listBundles().map(\.id)
        XCTAssertEqual(savedBundleIDs, [initial.id])

        let pausedFact = try XCTUnwrap(initial.historicalFacts.first).markedPaused(at: "2026-05-22T13:00:00Z")
        let updated = initial
            .replacingHistoricalFact(pausedFact, updatedAt: "2026-05-22T13:00:00Z")
            .updated(updatedAt: "2026-05-22T13:00:00Z")

        try await repository.saveBundles([updated])

        let reloadedBundle = try await repository.bundle(id: initial.id)
        let reloaded = try XCTUnwrap(reloadedBundle)
        XCTAssertEqual(reloaded.updatedAt, "2026-05-22T13:00:00Z")
        XCTAssertEqual(reloaded.historicalFacts.first?.pausedAt, "2026-05-22T13:00:00Z")

        let runtimeProjection = try await repository.projectRuntime(for: initial.id, asOf: now)
        let projection = try XCTUnwrap(runtimeProjection)
        XCTAssertEqual(projection.historySummary.map(\.id), [])
        XCTAssertTrue(projection.hardConstraints.contains { $0.detail.localizedCaseInsensitiveContains("No nearby maker space") })

        try await repository.deleteBundle(id: initial.id, at: "2026-05-22T14:00:00Z")

        let deletedBundle = try await repository.bundle(id: initial.id)
        let remainingBundles = try await repository.listBundles()
        let deletedProjection = try await repository.projectRuntime(for: initial.id, asOf: now)

        XCTAssertNil(deletedBundle)
        XCTAssertTrue(remainingBundles.isEmpty)
        XCTAssertNil(deletedProjection)
    }

    func testSwiftDataRepositoryRoundTripsFutureProofContextCandidates() async throws {
        let repository = try await makeRepository()
        let bundle = LifeContextBundle(
            id: "bundle.future-proof",
            profile: LifeContextProfile(
                id: "profile.future-proof",
                exactAgeYears: 30,
                timezone: "America/New_York",
                locale: "en_US",
                lifeStage: .adult,
                transportationAccess: .car
            ),
            futureProofContextCandidates: [
                FutureProofContextCandidate(
                    captureID: "capture.pickleball",
                    contextCategory: .activityHistory,
                    potentialFutureUses: [
                        "future fitness planning",
                        "social context",
                        "activity history"
                    ],
                    sourceLabel: "Capture",
                    freshness: .current,
                    reviewNeeded: false,
                    runtimeUseAllowed: true,
                    visibleInYou: true,
                    deletionSupported: true
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )

        try await repository.saveBundles([bundle])

        let loadedBundle = try await repository.bundle(id: bundle.id)
        let loaded = try XCTUnwrap(loadedBundle)

        XCTAssertEqual(loaded.futureProofContextCandidates, bundle.futureProofContextCandidates)
        XCTAssertEqual(loaded.futureProofContextCandidates.first?.contextCategory, .activityHistory)
        XCTAssertEqual(loaded.futureProofContextCandidates.first?.sourceLabel, "Capture")
    }

    func testSwiftDataRepositoryKeepsSensitiveFactsOutOfProjectionUnlessExplicitlyAllowed() async throws {
        let repository = try await makeRepository()
        let source = LifeContextSource(
            id: "source.sensitive.test",
            label: "Sensitive interview",
            kind: .userConfirmed,
            timestamp: "2026-05-22T00:00:00Z",
            visibleExplanation: "User confirmed the bundle."
        )
        let blockedSensitiveFact = HistoricalContextFact(
            id: "fact.blocked",
            category: .healthBaseline,
            title: "Blocked sensitive fact",
            detail: "This should stay out of runtime projection.",
            sourceType: .userToldAmbitions,
            freshness: .current,
            sensitivity: .sensitive,
            runtimeUseAllowed: false,
            usedFor: [.eligibility, .safety],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
        let allowedSensitiveFact = HistoricalContextFact(
            id: "fact.allowed",
            category: .healthBaseline,
            title: "Allowed sensitive fact",
            detail: "This should enter runtime projection.",
            sourceType: .correctedByUser,
            freshness: .current,
            sensitivity: .highlySensitive,
            runtimeUseAllowed: true,
            usedFor: [.eligibility, .safety],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
        let bundle = LifeContextBundle(
            id: "bundle.sensitive",
            profile: LifeContextProfile(
                id: "profile.sensitive",
                exactAgeYears: 24,
                timezone: "America/Los_Angeles",
                locale: "en_US",
                lifeStage: .earlyCareer,
                transportationAccess: .transit
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.sensitive",
                    pathwayType: .health,
                    eligibilityRulesSummary: "Safety and recovery path.",
                    source: source,
                    freshness: .current,
                    userConfirmed: true
                )
            ],
            historicalFacts: [blockedSensitiveFact, allowedSensitiveFact],
            sources: [source],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )

        try await repository.saveBundles([bundle])
        let projectionDate = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z"))
        let projectedRuntime = try await repository.projectRuntime(for: bundle.id, asOf: projectionDate)
        let projection = try XCTUnwrap(projectedRuntime)

        XCTAssertEqual(projection.historySummary.map(\.id), ["fact.allowed"])
        XCTAssertEqual(projection.sensitiveUseWarnings.map(\.factID), ["fact.blocked"])
        XCTAssertEqual(projection.eligibilityModel.first?.pathwayType, .health)
    }

    func testSwiftDataRepositorySurfacesInspectableLifeContextRecordsWithPrivacyBoundaries() async throws {
        let repository = try await makeRepository()
        let normalFact = HistoricalContextFact(
            id: "fact.visible",
            category: .priorExperience,
            title: "Visible maker history",
            detail: "Built three beginner projects.",
            confidence: 0.86,
            sourceType: .userToldAmbitions,
            freshness: .current,
            sensitivity: .normal,
            usedFor: [.explanation, .sequencing],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
        let sensitiveFact = HistoricalContextFact(
            id: "fact.private",
            category: .healthBaseline,
            title: "Private recovery context",
            detail: "Raw sensitive recovery detail must not render in You.",
            confidence: 0.64,
            sourceType: .correctedByUser,
            freshness: .mayNeedReview,
            sensitivity: .highlySensitive,
            runtimeUseAllowed: false,
            usedFor: [.safety],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
        let pausedFact = HistoricalContextFact(
            id: "fact.paused",
            category: .trainingHistory,
            title: "Paused training context",
            detail: "Former routine",
            confidence: 0.92,
            sourceType: .paused,
            freshness: .basedOnOlderContext,
            sensitivity: .normal,
            runtimeUseAllowed: false,
            usedFor: [.duration],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T01:00:00Z",
            pausedAt: "2026-05-22T01:00:00Z"
        )
        let bundle = LifeContextBundle(
            id: "bundle.inspectable",
            profile: LifeContextProfile(
                id: "profile.inspectable",
                exactAgeYears: 29,
                timezone: "America/New_York",
                locale: "en_US",
                lifeStage: .adult,
                transportationAccess: .car
            ),
            historicalFacts: [sensitiveFact, pausedFact, normalFact],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T01:00:00Z"
        )

        try await repository.saveBundles([bundle])
        let loadedBundle = try await repository.bundle(id: bundle.id)
        let loaded = try XCTUnwrap(loadedBundle)
        let records = loaded.inspectableRecords()

        XCTAssertEqual(records.map(\.id), ["fact.paused", "fact.private", "fact.visible"])

        let visible = try XCTUnwrap(records.first { $0.id == "fact.visible" })
        XCTAssertEqual(visible.visibleDetail, "Built three beginner projects.")
        XCTAssertEqual(visible.sourceLabel, "User confirmed")
        XCTAssertEqual(visible.sourceRecordID, "SourceRecord.life-context.fact.visible")
        XCTAssertEqual(visible.receiptID, "Receipt.life-context.fact.visible")
        XCTAssertEqual(visible.replayTraceID, "ReplayTrace.life-context.fact.visible")
        XCTAssertEqual(visible.confidence, 0.86)
        XCTAssertEqual(visible.privacyIndexingBoundary, .summaryOnly)
        XCTAssertTrue(visible.controlActionIDs.contains("edit"))
        XCTAssertTrue(visible.controlActionIDs.contains("reset"))
        XCTAssertTrue(visible.controlActionIDs.contains("delete"))
        XCTAssertEqual(visible.inspectionSurfaceTitle, "Search Ambitions")
        XCTAssertTrue(visible.inspectionSummary.contains("SourceRecord"))
        XCTAssertTrue(visible.inspectionSummary.contains("Receipt"))
        XCTAssertTrue(visible.inspectionSummary.contains("ReplayTrace"))

        let privateRecord = try XCTUnwrap(records.first { $0.id == "fact.private" })
        XCTAssertEqual(privateRecord.visibleDetail, "Private detail hidden; review in Search Ambitions.")
        XCTAssertEqual(privateRecord.sourceLabel, "Corrected by user")
        XCTAssertEqual(privateRecord.privacyIndexingBoundary, .privateDetailHidden)
        XCTAssertEqual(privateRecord.freshness, .mayNeedReview)
        XCTAssertFalse(privateRecord.visibleDetail.contains("Raw sensitive recovery detail"))

        let paused = try XCTUnwrap(records.first { $0.id == "fact.paused" })
        XCTAssertEqual(paused.visibleDetail, "Excluded from runtime use.")
        XCTAssertEqual(paused.sourceLabel, "Paused")
        XCTAssertEqual(paused.privacyIndexingBoundary, .excludedFromRuntime)
        XCTAssertEqual(paused.controlActionIDs, ["edit", "review", "pause", "delete", "reset"])
    }
}

private extension LifeContextRepositoryTests {
    func makeRepository() async throws -> SwiftDataLifeContextRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataLifeContextRepository(store: store)
    }
}
