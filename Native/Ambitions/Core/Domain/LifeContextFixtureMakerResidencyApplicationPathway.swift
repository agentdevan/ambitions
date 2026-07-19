import Foundation

extension LifeContextFixtureProfiles {

    static func makerResidencyApplicationPathway() -> LifeContextBundle {
        makeBundle(
            id: "fixture.maker.residency.application",
            profile: LifeContextProfile(
                id: "profile.maker.residency.application",
                exactAgeYears: 22,
                ageSource: LifeContextSource(
                    id: "source.age.maker.residency",
                    label: "Self-reported age",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age was confirmed by the applicant.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/Los_Angeles",
                locale: "en_US",
                generalLocationLabel: "Metro area",
                locationPrecision: .cityRegion,
                sexOrEligibilityContext: "Maker residency application pathway.",
                lifeStage: .earlyCareer,
                schoolOrWorkContext: "Residency application and prototype schedule",
                travelRadiusMinutes: 60,
                travelRadiusMiles: 40,
                transportationAccess: .rideshare,
                scheduleAnchors: ["prototype", "portfolio review", "recovery", "travel"],
                dependencyConstraints: ["Travel windows depend on residency review schedule."],
                budgetConstraintBand: .moderate,
                energyPattern: .midday,
                recoveryConstraints: ["Needs structured recovery after travel and review sessions."],
                accessibilityNeeds: [],
                userNotes: "Maker residency pathway with local and travel exposure."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.maker.residency",
                    pathwayType: .creative,
                    eligibilityRulesSummary: "Maker residency pathway with prototype, portfolio, and interview requirements.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: "Maker residency pathway",
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.maker.residency",
                        label: "Residency pathway summary",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "Pathway came from the applicant's confirmed career intent.",
                        canDelete: true,
                        canPause: true,
                        canEdit: true
                    ),
                    freshness: .current,
                    userConfirmed: true
                )
            ],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.maker.travel",
                    facilities: [.makerSpace, .studio, .library],
                    equipmentAccess: ["workbench", "prototype tools", "presentation room"],
                    coachingMentorAccess: "Professional mentor network",
                    localOrganizations: ["regional maker residency"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    travelRequirement: "Frequent regional travel",
                    costRequirement: "Travel and application costs apply",
                    seasonalAvailability: "Year-round",
                    verificationStatus: .partiallyVerified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.maker.prototype",
                    category: .pastAchievement,
                    title: "Notable prototype samples",
                    detail: "Has a prototype library and live review history.",
                    dateRange: LifeContextDateRange(start: "2024-09-01", end: "2026-05-01"),
                    confidence: 0.8,
                    sourceType: .correctedByUser,
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.eligibility, .opportunity, .explanation],
                    createdAt: "2026-05-22T00:00:00Z",
                    updatedAt: "2026-05-22T00:00:00Z",
                    confirmedAt: "2026-05-22T00:00:00Z"
                )
            ],
            sources: [
                LifeContextSource(
                    id: "source.bundle.maker.residency",
                    label: "Applicant interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The applicant confirmed the residency pathway directly.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }


    static func adultWorkshopLaunchWithMakerAccess() -> LifeContextBundle {
        makeBundle(
            id: "fixture.adult.workshop.maker_access",
            profile: LifeContextProfile(
                id: "profile.adult.workshop.maker_access",
                exactAgeYears: 31,
                ageSource: LifeContextSource(
                    id: "source.age.workshop",
                    label: "User confirmed age",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age was confirmed by the user.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/Denver",
                locale: "en_US",
                generalLocationLabel: "Suburban area",
                locationPrecision: .cityRegion,
                lifeStage: .adult,
                schoolOrWorkContext: "Full-time work with weekend workshop blocks",
                travelRadiusMinutes: 30,
                travelRadiusMiles: 18,
                transportationAccess: .car,
                scheduleAnchors: ["workday", "weekend mornings"],
                dependencyConstraints: ["No nearby maker space within the weekday radius."],
                budgetConstraintBand: .moderate,
                energyPattern: .morning,
                recoveryConstraints: ["Needs recovery days after harder build sessions."],
                accessibilityNeeds: [],
                userNotes: "Goal is a workshop launch with limited weekday access."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.workshop.launch",
                    pathwayType: .creative,
                    eligibilityRulesSummary: "Build skill, equipment access, and a reviewable workshop launch path.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.workshop",
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
                    id: "opportunity.local.maker_space",
                    facilities: [.makerSpace, .studio],
                    equipmentAccess: ["shared workbench", "basic tool kit"],
                    coachingMentorAccess: "Remote coaching only",
                    localOrganizations: [],
                    eventExposureAccess: false,
                    remoteAccess: true,
                    travelRequirement: "Maker-space access requires a longer drive",
                    costRequirement: "Materials and access fees may apply",
                    seasonalAvailability: "Weekend hours only",
                    verificationStatus: .unverified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.workshop.no_nearby_maker_space",
                    category: .locationHistory,
                    title: "No nearby maker space",
                    detail: "Local radius has no maker space within the normal weekday distance.",
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
                    id: "source.bundle.workshop",
                    label: "User interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The user confirmed travel limits and local workshop gaps.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }
}
