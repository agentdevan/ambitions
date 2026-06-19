import Foundation

enum LifeContextSourceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userConfirmed = "user_confirmed"
    case imported
    case inferred
    case corrected
}

struct LifeContextSource: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let label: String
    let kind: LifeContextSourceKind
    let timestamp: String
    let visibleExplanation: String
    let canDelete: Bool
    let canPause: Bool
    let canEdit: Bool

    init(
        id: String,
        label: String,
        kind: LifeContextSourceKind,
        timestamp: String,
        visibleExplanation: String,
        canDelete: Bool = true,
        canPause: Bool = true,
        canEdit: Bool = true
    ) {
        self.id = id
        self.label = label
        self.kind = kind
        self.timestamp = timestamp
        self.visibleExplanation = visibleExplanation
        self.canDelete = canDelete
        self.canPause = canPause
        self.canEdit = canEdit
    }
}

enum LifeContextLocationPrecision: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case timezone
    case cityRegion = "city_region"
    case userEnteredPlace = "user_entered_place"
    case precisePermissioned = "precise_permissioned"
}

enum LifeContextLifeStage: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case middleSchool = "middle_school"
    case highSchool = "high_school"
    case college
    case earlyCareer = "early_career"
    case adult
    case parent
    case caregiver
    case custom
    case unknown
}

enum LifeContextTransportationAccess: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case walk
    case bike
    case transit
    case rideshare
    case car
    case parentGuardian = "parent_guardian"
    case limited
    case custom
    case unknown
}

enum LifeContextBudgetConstraintBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case tight
    case moderate
    case flexible
    case custom
    case unknown
}

enum LifeContextEnergyPattern: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case morning
    case midday
    case evening
    case variable
    case unknown
}

enum LifeContextVerificationStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unverified
    case selfReported = "self_reported"
    case partiallyVerified = "partially_verified"
    case verified
    case blocked
}

struct LifeContextProfile: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let birthdate: String?
    let exactAgeYears: Int?
    let ageSource: LifeContextSource?
    let ageLastConfirmedAt: String?
    let timezone: String?
    let locale: String?
    let generalLocationLabel: String?
    let locationPrecision: LifeContextLocationPrecision
    let sexOrEligibilityContext: String?
    let lifeStage: LifeContextLifeStage
    let schoolOrWorkContext: String?
    let travelRadiusMinutes: Int?
    let travelRadiusMiles: Double?
    let transportationAccess: LifeContextTransportationAccess
    let scheduleAnchors: [String]
    let dependencyConstraints: [String]
    let budgetConstraintBand: LifeContextBudgetConstraintBand
    let energyPattern: LifeContextEnergyPattern
    let recoveryConstraints: [String]
    let accessibilityNeeds: [String]
    let userNotes: String?

    init(
        id: String,
        birthdate: String? = nil,
        exactAgeYears: Int? = nil,
        ageSource: LifeContextSource? = nil,
        ageLastConfirmedAt: String? = nil,
        timezone: String? = nil,
        locale: String? = nil,
        generalLocationLabel: String? = nil,
        locationPrecision: LifeContextLocationPrecision = .none,
        sexOrEligibilityContext: String? = nil,
        lifeStage: LifeContextLifeStage = .unknown,
        schoolOrWorkContext: String? = nil,
        travelRadiusMinutes: Int? = nil,
        travelRadiusMiles: Double? = nil,
        transportationAccess: LifeContextTransportationAccess = .unknown,
        scheduleAnchors: [String] = [],
        dependencyConstraints: [String] = [],
        budgetConstraintBand: LifeContextBudgetConstraintBand = .unknown,
        energyPattern: LifeContextEnergyPattern = .unknown,
        recoveryConstraints: [String] = [],
        accessibilityNeeds: [String] = [],
        userNotes: String? = nil
    ) {
        self.id = id
        self.birthdate = birthdate
        self.exactAgeYears = exactAgeYears
        self.ageSource = ageSource
        self.ageLastConfirmedAt = ageLastConfirmedAt
        self.timezone = timezone
        self.locale = locale
        self.generalLocationLabel = generalLocationLabel
        self.locationPrecision = locationPrecision
        self.sexOrEligibilityContext = sexOrEligibilityContext
        self.lifeStage = lifeStage
        self.schoolOrWorkContext = schoolOrWorkContext
        self.travelRadiusMinutes = travelRadiusMinutes
        self.travelRadiusMiles = travelRadiusMiles
        self.transportationAccess = transportationAccess
        self.scheduleAnchors = scheduleAnchors
        self.dependencyConstraints = dependencyConstraints
        self.budgetConstraintBand = budgetConstraintBand
        self.energyPattern = energyPattern
        self.recoveryConstraints = recoveryConstraints
        self.accessibilityNeeds = accessibilityNeeds
        self.userNotes = userNotes
    }
}

enum LifeContextEligibilityPathwayType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sport
    case academic
    case career
    case creative
    case health
    case finance
    case custom
}

enum LifeContextFreshness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case mayNeedReview = "may_need_review"
    case basedOnOlderContext = "based_on_older_context"
    case stale
}

struct LifeContextAgeWindow: Codable, Sendable, Equatable, Hashable {
    let lowerBoundYears: Int?
    let upperBoundYears: Int?

    init(lowerBoundYears: Int? = nil, upperBoundYears: Int? = nil) {
        self.lowerBoundYears = lowerBoundYears
        self.upperBoundYears = upperBoundYears
    }
}

struct LifeContextEligibilityPathway: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let pathwayType: LifeContextEligibilityPathwayType
    let eligibilityRulesSummary: String
    let ageWindow: LifeContextAgeWindow?
    let gradeWindow: String?
    let sexLeaguePathway: String?
    let locationDependent: Bool
    let source: LifeContextSource
    let freshness: LifeContextFreshness
    let userConfirmed: Bool

    init(
        id: String,
        pathwayType: LifeContextEligibilityPathwayType,
        eligibilityRulesSummary: String,
        ageWindow: LifeContextAgeWindow? = nil,
        gradeWindow: String? = nil,
        sexLeaguePathway: String? = nil,
        locationDependent: Bool = false,
        source: LifeContextSource,
        freshness: LifeContextFreshness = .current,
        userConfirmed: Bool = false
    ) {
        self.id = id
        self.pathwayType = pathwayType
        self.eligibilityRulesSummary = eligibilityRulesSummary
        self.ageWindow = ageWindow
        self.gradeWindow = gradeWindow
        self.sexLeaguePathway = sexLeaguePathway
        self.locationDependent = locationDependent
        self.source = source
        self.freshness = freshness
        self.userConfirmed = userConfirmed
    }
}

enum LifeContextFacility: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ymca
    case gym
    case field
    case court
    case studio
    case library
    case school
    case park
    case trail
    case rink
    case pool
    case makerSpace = "maker_space"
    case home
    case custom
}

struct OpportunityContext: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let facilities: [LifeContextFacility]
    let equipmentAccess: [String]
    let coachingMentorAccess: String?
    let localOrganizations: [String]
    let eventExposureAccess: Bool
    let remoteAccess: Bool
    let travelRequirement: String?
    let costRequirement: String?
    let seasonalAvailability: String?
    let verificationStatus: LifeContextVerificationStatus

    init(
        id: String,
        facilities: [LifeContextFacility],
        equipmentAccess: [String] = [],
        coachingMentorAccess: String? = nil,
        localOrganizations: [String] = [],
        eventExposureAccess: Bool = false,
        remoteAccess: Bool = false,
        travelRequirement: String? = nil,
        costRequirement: String? = nil,
        seasonalAvailability: String? = nil,
        verificationStatus: LifeContextVerificationStatus = .unverified
    ) {
        self.id = id
        self.facilities = facilities
        self.equipmentAccess = equipmentAccess
        self.coachingMentorAccess = coachingMentorAccess
        self.localOrganizations = localOrganizations
        self.eventExposureAccess = eventExposureAccess
        self.remoteAccess = remoteAccess
        self.travelRequirement = travelRequirement
        self.costRequirement = costRequirement
        self.seasonalAvailability = seasonalAvailability
        self.verificationStatus = verificationStatus
    }
}

enum HistoricalContextFactCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case priorExperience = "prior_experience"
    case priorAttempt = "prior_attempt"
    case pastAchievement = "past_achievement"
    case injuryLimitation = "injury_limitation"
    case trainingHistory = "training_history"
    case educationHistory = "education_history"
    case workHistory = "work_history"
    case creativeCatalog = "creative_catalog"
    case financialBaseline = "financial_baseline"
    case healthBaseline = "health_baseline"
    case relationshipDependency = "relationship_dependency"
    case locationHistory = "location_history"
    case custom
}

enum HistoricalContextFactSourceType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userToldAmbitions = "user_told_ambitions"
    case imported
    case inferredFromLocalAction = "inferred_from_local_action"
    case correctedByUser = "corrected_by_user"
    case deleted
    case paused
}

enum HistoricalContextFactFreshness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case mayNeedReview = "may_need_review"
    case basedOnOlderContext = "based_on_older_context"
    case stale
}

enum HistoricalContextFactSensitivity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normal
    case sensitive
    case highlySensitive = "highly_sensitive"
}

enum HistoricalContextFactUse: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case feasibility
    case sequencing
    case safety
    case eligibility
    case opportunity
    case recovery
    case duration
    case travel
    case explanation
}

struct LifeContextDateRange: Codable, Sendable, Equatable, Hashable {
    let start: String?
    let end: String?

    init(start: String? = nil, end: String? = nil) {
        self.start = start
        self.end = end
    }
}
