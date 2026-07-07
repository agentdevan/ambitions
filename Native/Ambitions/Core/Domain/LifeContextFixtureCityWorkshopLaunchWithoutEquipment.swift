import Foundation

extension LifeContextFixtureProfiles {

    static func cityWorkshopLaunchWithoutEquipment() -> LifeContextBundle {
        makeBundle(
            id: "fixture.city.workshop.no_equipment",
            profile: LifeContextProfile(
                id: "profile.city.workshop.no_equipment",
                exactAgeYears: 31,
                ageSource: LifeContextSource(
                    id: "source.age.city.workshop",
                    label: "User confirmed age",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age was confirmed by the user.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/New_York",
                locale: "en_US",
                generalLocationLabel: "City center",
                locationPrecision: .cityRegion,
                lifeStage: .adult,
                schoolOrWorkContext: "Full-time work with city transit",
                travelRadiusMinutes: 20,
                travelRadiusMiles: 6,
                transportationAccess: .transit,
                scheduleAnchors: ["commute", "weekend afternoons"],
                dependencyConstraints: ["No nearby maker space within the local radius.", "No personal tool kit yet."],
                budgetConstraintBand: .tight,
                energyPattern: .variable,
                recoveryConstraints: ["Needs recovery days after harder build sessions."],
                accessibilityNeeds: [],
                userNotes: "City workshop launch with no tool kit and limited maker-space access."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.workshop.city",
                    pathwayType: .creative,
                    eligibilityRulesSummary: "Build skill and access before workshop launch work.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.workshop.city",
                        label: "Workshop plan",
                        kind: .inferred,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "The pathway came from the user's workshop launch goal.",
                        canDelete: true,
                        canPause: true,
                        canEdit: true
                    ),
                    freshness: .mayNeedReview,
                    userConfirmed: false
                )
            ],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.city.home_studio",
                    facilities: [.home, .library],
                    equipmentAccess: ["borrowed laptop", "library printer"],
                    coachingMentorAccess: "Remote mentor or community class options",
                    localOrganizations: ["Community library"],
                    eventExposureAccess: false,
                    remoteAccess: true,
                    travelRequirement: "Transit or rideshare only",
                    costRequirement: "Class fees may apply",
                    seasonalAvailability: "Year-round",
                    verificationStatus: .unverified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.workshop.city.no_tool_kit",
                    category: .trainingHistory,
                    title: "No tool kit yet",
                    detail: "The next step may need equipment access before workshop build sessions.",
                    dateRange: LifeContextDateRange(start: "2026-05-01", end: "2026-05-22"),
                    confidence: 0.9,
                    sourceType: .userToldAmbitions,
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.opportunity, .sequencing, .explanation],
                    createdAt: "2026-05-22T00:00:00Z",
                    updatedAt: "2026-05-22T00:00:00Z",
                    confirmedAt: "2026-05-22T00:00:00Z"
                ),
                HistoricalContextFact(
                    id: "fact.workshop.city.maker_gap",
                    category: .locationHistory,
                    title: "No nearby maker space",
                    detail: "The local radius does not include a maker space.",
                    dateRange: LifeContextDateRange(start: "2026-05-01", end: "2026-05-22"),
                    confidence: 0.95,
                    sourceType: .userToldAmbitions,
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.travel, .feasibility],
                    createdAt: "2026-05-22T00:00:00Z",
                    updatedAt: "2026-05-22T00:00:00Z",
                    confirmedAt: "2026-05-22T00:00:00Z"
                )
            ],
            sources: [
                LifeContextSource(
                    id: "source.bundle.city.workshop",
                    label: "User interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The user confirmed maker-space gaps and the missing tool kit.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }


    static func emptyContext() -> LifeContextBundle {
        makeBundle(
            id: "fixture.empty.context",
            profile: LifeContextProfile(
                id: "profile.empty.context",
                lifeStage: .unknown,
                transportationAccess: .unknown
            ),
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }


    static func makeBundle(
        id: String,
        profile: LifeContextProfile,
        eligibilityPathways: [LifeContextEligibilityPathway] = [],
        opportunityContexts: [OpportunityContext] = [],
        historicalFacts: [HistoricalContextFact] = [],
        sources: [LifeContextSource] = [],
        createdAt: String,
        updatedAt: String
    ) -> LifeContextBundle {
        LifeContextBundle(
            id: id,
            profile: profile,
            eligibilityPathways: eligibilityPathways,
            opportunityContexts: opportunityContexts,
            historicalFacts: historicalFacts,
            sources: sources,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
