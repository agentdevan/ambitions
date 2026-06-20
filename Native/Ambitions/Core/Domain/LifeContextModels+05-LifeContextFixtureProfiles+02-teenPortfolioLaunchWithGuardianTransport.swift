import Foundation

extension LifeContextFixtureProfiles {
    static func teenPortfolioLaunchWithGuardianTransport() -> LifeContextBundle {
        makeBundle(
            id: "fixture.teen.portfolio.guardian_transport",
            profile: LifeContextProfile(
                id: "profile.teen.portfolio.guardian_transport",
                exactAgeYears: 14,
                ageSource: LifeContextSource(
                    id: "source.age.14",
                    label: "Parent confirmed age",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age came from a parent-confirmed entry.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/Chicago",
                locale: "en_US",
                generalLocationLabel: "Small town",
                locationPrecision: .cityRegion,
                sexOrEligibilityContext: nil,
                lifeStage: .highSchool,
                schoolOrWorkContext: "Freshman school day and creative portfolio lab",
                travelRadiusMinutes: 25,
                travelRadiusMiles: 12,
                transportationAccess: .parentGuardian,
                scheduleAnchors: ["school", "portfolio lab", "homework", "family dinner"],
                dependencyConstraints: ["Needs guardian transportation to reach the workshop space."],
                budgetConstraintBand: .tight,
                energyPattern: .afterSchoolFallback,
                recoveryConstraints: ["Avoid late-night heavy build sessions before school days."],
                accessibilityNeeds: [],
                userNotes: "Goal is a portfolio launch with limited local mobility."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.portfolio.school",
                    pathwayType: .creative,
                    eligibilityRulesSummary: "School portfolio pathway with age, permission, and review progression.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 14, upperBoundYears: 18),
                    gradeWindow: "Freshman through senior",
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.portfolio.school",
                        label: "Mentor and school handbook",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "School and mentor rules confirmed the path.",
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
                    id: "opportunity.school.workshop",
                    facilities: [.school, .makerSpace, .library],
                    equipmentAccess: ["laptop", "printer", "quiet review table"],
                    coachingMentorAccess: "Occasional guardian-organized mentor help",
                    localOrganizations: ["School media lab"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    travelRequirement: "Guardian ride only",
                    costRequirement: "Low-cost supplies preferred",
                    seasonalAvailability: "School term",
                    verificationStatus: .selfReported
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.portfolio.early",
                    category: .priorExperience,
                    title: "Early portfolio pieces",
                    detail: "Has several school-term creative pieces ready for review.",
                    dateRange: LifeContextDateRange(start: "2024-08-01", end: "2025-10-01"),
                    confidence: 0.9,
                    sourceType: .userToldAmbitions,
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.feasibility, .sequencing],
                    createdAt: "2026-05-22T00:00:00Z",
                    updatedAt: "2026-05-22T00:00:00Z",
                    confirmedAt: "2026-05-22T00:00:00Z"
                )
            ],
            sources: [
                LifeContextSource(
                    id: "source.bundle.14",
                    label: "Guardian interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Family context and transportation limits came from a guardian interview.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }


    static func teenPortfolioLaunchWithSchoolAccess() -> LifeContextBundle {
        makeBundle(
            id: "fixture.teen.portfolio.school_access",
            profile: LifeContextProfile(
                id: "profile.teen.portfolio.school_access",
                exactAgeYears: 16,
                ageSource: LifeContextSource(
                    id: "source.age.16",
                    label: "Student self-report",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age was confirmed directly by the student.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/New_York",
                locale: "en_US",
                generalLocationLabel: "School district",
                locationPrecision: .cityRegion,
                lifeStage: .highSchool,
                schoolOrWorkContext: "Portfolio studio and school media room",
                travelRadiusMinutes: 20,
                travelRadiusMiles: 8,
                transportationAccess: .walk,
                scheduleAnchors: ["before school editing", "classes", "after-school studio time"],
                dependencyConstraints: ["Build sessions must fit the school bell schedule."],
                budgetConstraintBand: .moderate,
                energyPattern: .afterSchoolFallback,
                recoveryConstraints: ["Needs enough sleep to handle review sessions and classwork."],
                accessibilityNeeds: [],
                userNotes: "Compressed timeline to finish a portfolio-ready first pass."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.portfolio.16",
                    pathwayType: .creative,
                    eligibilityRulesSummary: "Portfolio path with compressed review and submission timeline.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 15, upperBoundYears: 18),
                    gradeWindow: "Sophomore through senior",
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.portfolio.16",
                        label: "Mentor guidance",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "Mentor confirmed the compressed timeline.",
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
                    id: "opportunity.school.media_room",
                    facilities: [.school, .studio],
                    equipmentAccess: ["school laptop", "editing station", "presentation display"],
                    coachingMentorAccess: "School portfolio mentor",
                    localOrganizations: ["School media room"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    travelRequirement: "No travel during weekdays",
                    costRequirement: "Included in school program",
                    seasonalAvailability: "Year-round",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.portfolio.practice",
                    category: .trainingHistory,
                    title: "Recent build consistency",
                    detail: "Has kept a regular editing and review cadence.",
                    dateRange: LifeContextDateRange(start: "2026-01-10", end: "2026-05-15"),
                    confidence: 0.85,
                    sourceType: .inferredFromLocalAction,
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.sequencing, .duration],
                    createdAt: "2026-05-22T00:00:00Z",
                    updatedAt: "2026-05-22T00:00:00Z",
                    confirmedAt: nil
                )
            ],
            sources: [
                LifeContextSource(
                    id: "source.bundle.16",
                    label: "Mentor notes",
                    kind: .inferred,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The timeline came from mentor context and school schedule.",
                    canDelete: true,
                    canPause: true,
                    canEdit: true
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }


    static func creatorCohortApplicationPathway() -> LifeContextBundle {
        makeBundle(
            id: "fixture.creator.cohort.application",
            profile: LifeContextProfile(
                id: "profile.creator.cohort.application",
                exactAgeYears: 22,
                ageSource: LifeContextSource(
                    id: "source.age.creator.cohort",
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
                sexOrEligibilityContext: "Creator cohort application pathway.",
                lifeStage: .earlyCareer,
                schoolOrWorkContext: "Portfolio build and application schedule",
                travelRadiusMinutes: 60,
                travelRadiusMiles: 40,
                transportationAccess: .rideshare,
                scheduleAnchors: ["portfolio build", "review", "recovery", "travel"],
                dependencyConstraints: ["Travel windows depend on cohort review schedule."],
                budgetConstraintBand: .moderate,
                energyPattern: .midday,
                recoveryConstraints: ["Needs structured recovery after travel and review sessions."],
                accessibilityNeeds: [],
                userNotes: "Creator cohort pathway with local and travel exposure."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.creator.cohort",
                    pathwayType: .creative,
                    eligibilityRulesSummary: "Creator cohort pathway with application, portfolio, and review requirements.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: "Creator cohort pathway",
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.creator.cohort",
                        label: "Cohort pathway summary",
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
                    id: "opportunity.studio.travel",
                    facilities: [.studio, .makerSpace, .library],
                    equipmentAccess: ["studio table", "editing station", "presentation room"],
                    coachingMentorAccess: "Professional mentor network",
                    localOrganizations: ["regional creator cohort"],
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
                    id: "fact.creator.portfolio",
                    category: .pastAchievement,
                    title: "Notable portfolio samples",
                    detail: "Has a portfolio library and live review history.",
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
                    id: "source.bundle.creator.cohort",
                    label: "Applicant interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The applicant confirmed the cohort pathway directly.",
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
