import XCTest
@testable import Ambitions

final class LifeContextModelsTests: XCTestCase {
    func testFixtureProfilesProduceTypedProjectionsAndMissingQuestionsForEmptyContext() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z"))
        let fixtures: [(LifeContextBundle, Int, LifeContextLifeStage, LifeContextTransportationAccess)] = [
            (LifeContextFixtureProfiles.fourteenYearOldVarsityFootballGoal(), 14, .highSchool, .parentGuardian),
            (LifeContextFixtureProfiles.sixteenYearOldVarsityFootballGoal(), 16, .highSchool, .walk),
            (LifeContextFixtureProfiles.womanPursuingProfessionalBasketball(), 22, .earlyCareer, .rideshare),
            (LifeContextFixtureProfiles.adultMountainBikingGoal(), 31, .adult, .car)
        ]

        for (fixture, expectedAge, expectedLifeStage, expectedTransportationAccess) in fixtures {
            let projection = fixture.projection(asOf: now)

            XCTAssertEqual(projection.ageYears, expectedAge)
            XCTAssertEqual(projection.lifeStage, expectedLifeStage)
            XCTAssertEqual(projection.travelModel.transportationAccess, expectedTransportationAccess)
            XCTAssertFalse(projection.availableOpportunityAnchors.isEmpty)
            XCTAssertFalse(projection.eligibilityModel.isEmpty)
            XCTAssertFalse(projection.sourceFreshnessSummary.isEmpty)
            XCTAssertTrue(projection.availableOpportunityAnchors.allSatisfy { $0.verificationStatus != .blocked })
        }

        let proBasketball = LifeContextFixtureProfiles.womanPursuingProfessionalBasketball().projection(asOf: now)
        XCTAssertEqual(proBasketball.eligibilityModel.first?.pathwayType, .sport)
        XCTAssertEqual(proBasketball.eligibilityModel.first?.sexLeaguePathway, "Women's league pathway")
        XCTAssertEqual(proBasketball.availableOpportunityAnchors.first?.verificationStatus, .partiallyVerified)

        let mountainBike = LifeContextFixtureProfiles.adultMountainBikingGoal().projection(asOf: now)
        XCTAssertTrue(mountainBike.hardConstraints.contains { $0.detail.localizedCaseInsensitiveContains("No nearby trail network") })

        let empty = LifeContextFixtureProfiles.emptyContext().projection(asOf: now)
        XCTAssertEqual(
            empty.missingContextQuestions.map(\.id),
            ["missing.age", "missing.timezone", "missing.locale", "missing.life_stage"]
        )
    }

    func testProjectionExcludesDeletedPausedAndSensitiveFactsWithoutPermission() throws {
        let source = LifeContextSource(
            id: "source.bundle.test",
            label: "Manual interview",
            kind: .userConfirmed,
            timestamp: "2026-05-22T00:00:00Z",
            visibleExplanation: "Used to seed the bundle."
        )
        let activeFact = HistoricalContextFact(
            id: "fact.active",
            category: .priorExperience,
            title: "Active fact",
            detail: "Keeps the path grounded.",
            sourceType: .userToldAmbitions,
            freshness: .current,
            sensitivity: .normal,
            runtimeUseAllowed: true,
            usedFor: [.feasibility, .sequencing],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z",
            confirmedAt: "2026-05-22T00:00:00Z"
        )
        let pausedFact = HistoricalContextFact(
            id: "fact.paused",
            category: .trainingHistory,
            title: "Paused fact",
            detail: "Should not enter projections.",
            sourceType: .userToldAmbitions,
            freshness: .current,
            sensitivity: .normal,
            runtimeUseAllowed: true,
            usedFor: [.sequencing],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        ).markedPaused(at: "2026-05-22T01:00:00Z")
        let deletedFact = HistoricalContextFact(
            id: "fact.deleted",
            category: .trainingHistory,
            title: "Deleted fact",
            detail: "Should not enter projections.",
            sourceType: .userToldAmbitions,
            freshness: .current,
            sensitivity: .normal,
            runtimeUseAllowed: true,
            usedFor: [.sequencing],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        ).markedDeleted(at: "2026-05-22T01:00:00Z")
        let blockedSensitiveFact = HistoricalContextFact(
            id: "fact.sensitive.blocked",
            category: .healthBaseline,
            title: "Sensitive blocked fact",
            detail: "Should warn but not project.",
            sourceType: .userToldAmbitions,
            freshness: .current,
            sensitivity: .sensitive,
            runtimeUseAllowed: false,
            usedFor: [.eligibility, .safety],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
        let allowedSensitiveFact = HistoricalContextFact(
            id: "fact.sensitive.allowed",
            category: .healthBaseline,
            title: "Sensitive allowed fact",
            detail: "Can be used when explicitly permitted.",
            sourceType: .correctedByUser,
            freshness: .current,
            sensitivity: .highlySensitive,
            runtimeUseAllowed: true,
            usedFor: [.safety, .eligibility],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )

        let bundle = LifeContextBundle(
            id: "bundle.test",
            profile: LifeContextProfile(
                id: "profile.test",
                exactAgeYears: 28,
                timezone: "America/New_York",
                locale: "en_US",
                lifeStage: .adult,
                transportationAccess: .car
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.test",
                    pathwayType: .health,
                    eligibilityRulesSummary: "Fitness and safety path.",
                    source: source,
                    freshness: .current,
                    userConfirmed: true
                )
            ],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.test",
                    facilities: [.gym],
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [activeFact, pausedFact, deletedFact, blockedSensitiveFact, allowedSensitiveFact],
            sources: [source],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )

        let projection = bundle.projection(asOf: try XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z")))

        XCTAssertEqual(projection.historySummary.map(\.id), ["fact.active", "fact.sensitive.allowed"])
        XCTAssertEqual(projection.sensitiveUseWarnings.map(\.factID), ["fact.sensitive.blocked"])
        XCTAssertFalse(projection.historySummary.contains { $0.id == "fact.paused" })
        XCTAssertFalse(projection.historySummary.contains { $0.id == "fact.deleted" })
        XCTAssertEqual(projection.availableOpportunityAnchors.first?.verificationStatus, .verified)
    }
}
