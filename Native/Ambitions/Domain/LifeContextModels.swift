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

struct HistoricalContextFact: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let category: HistoricalContextFactCategory
    let title: String
    let detail: String?
    let dateRange: LifeContextDateRange?
    let confidence: Double
    let sourceType: HistoricalContextFactSourceType
    let freshness: HistoricalContextFactFreshness
    let sensitivity: HistoricalContextFactSensitivity
    let runtimeUseAllowed: Bool
    let usedFor: [HistoricalContextFactUse]
    let createdAt: String
    let updatedAt: String
    let confirmedAt: String?
    let deletedAt: String?
    let pausedAt: String?

    init(
        id: String,
        category: HistoricalContextFactCategory,
        title: String,
        detail: String? = nil,
        dateRange: LifeContextDateRange? = nil,
        confidence: Double = 1,
        sourceType: HistoricalContextFactSourceType,
        freshness: HistoricalContextFactFreshness = .current,
        sensitivity: HistoricalContextFactSensitivity = .normal,
        runtimeUseAllowed: Bool = true,
        usedFor: [HistoricalContextFactUse] = [],
        createdAt: String,
        updatedAt: String,
        confirmedAt: String? = nil,
        deletedAt: String? = nil,
        pausedAt: String? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.detail = detail
        self.dateRange = dateRange
        self.confidence = confidence
        self.sourceType = sourceType
        self.freshness = freshness
        self.sensitivity = sensitivity
        self.runtimeUseAllowed = runtimeUseAllowed
        self.usedFor = usedFor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.confirmedAt = confirmedAt
        self.deletedAt = deletedAt
        self.pausedAt = pausedAt
    }

    var isDeletedOrPaused: Bool {
        deletedAt != nil || pausedAt != nil || sourceType == .deleted || sourceType == .paused
    }

    var isRuntimeEligible: Bool {
        isDeletedOrPaused == false && (sensitivity == .normal || runtimeUseAllowed)
    }

    func markedDeleted(at timestamp: String) -> HistoricalContextFact {
        HistoricalContextFact(
            id: id,
            category: category,
            title: title,
            detail: detail,
            dateRange: dateRange,
            confidence: confidence,
            sourceType: .deleted,
            freshness: freshness,
            sensitivity: sensitivity,
            runtimeUseAllowed: runtimeUseAllowed,
            usedFor: usedFor,
            createdAt: createdAt,
            updatedAt: timestamp,
            confirmedAt: confirmedAt,
            deletedAt: timestamp,
            pausedAt: pausedAt
        )
    }

    func markedPaused(at timestamp: String) -> HistoricalContextFact {
        HistoricalContextFact(
            id: id,
            category: category,
            title: title,
            detail: detail,
            dateRange: dateRange,
            confidence: confidence,
            sourceType: .paused,
            freshness: freshness,
            sensitivity: sensitivity,
            runtimeUseAllowed: runtimeUseAllowed,
            usedFor: usedFor,
            createdAt: createdAt,
            updatedAt: timestamp,
            confirmedAt: confirmedAt,
            deletedAt: deletedAt,
            pausedAt: timestamp
        )
    }
}

struct LifeContextQuestion: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let prompt: String
    let reason: String
    let priority: Int

    init(id: String, prompt: String, reason: String, priority: Int) {
        self.id = id
        self.prompt = prompt
        self.reason = reason
        self.priority = priority
    }
}

struct LifeContextConstraintSummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let isHardConstraint: Bool

    init(id: String, title: String, detail: String, isHardConstraint: Bool) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isHardConstraint = isHardConstraint
    }
}

struct LifeContextOpportunityAnchor: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let verificationStatus: LifeContextVerificationStatus

    init(id: String, title: String, detail: String, verificationStatus: LifeContextVerificationStatus) {
        self.id = id
        self.title = title
        self.detail = detail
        self.verificationStatus = verificationStatus
    }
}

struct LifeContextTravelModel: Codable, Sendable, Equatable {
    let radiusMinutes: Int?
    let radiusMiles: Double?
    let transportationAccess: LifeContextTransportationAccess
    let locationLabel: String?
    let locationPrecision: LifeContextLocationPrecision
}

struct LifeContextSourceFreshnessSummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let sourceID: String
    let label: String
    let freshness: LifeContextFreshness
    let detail: String
}

struct LifeContextSensitiveUseWarning: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let factID: String
    let title: String
    let detail: String
}

struct LifeContextHistorySummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let freshness: HistoricalContextFactFreshness
    let usedFor: [HistoricalContextFactUse]
}

enum LifeContextHistoryExclusionReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case deleted
    case paused
}

struct LifeContextHistoryExclusionSummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let factID: String
    let reason: LifeContextHistoryExclusionReason
}

struct LifeContextRuntimeProjection: Codable, Sendable, Equatable {
    let ageYears: Int?
    let lifeStage: LifeContextLifeStage
    let availableOpportunityAnchors: [LifeContextOpportunityAnchor]
    let hardConstraints: [LifeContextConstraintSummary]
    let softConstraints: [LifeContextConstraintSummary]
    let travelModel: LifeContextTravelModel
    let eligibilityModel: [LifeContextEligibilityPathway]
    let historySummary: [LifeContextHistorySummary]
    let excludedHistorySummary: [LifeContextHistoryExclusionSummary]
    let sourceFreshnessSummary: [LifeContextSourceFreshnessSummary]
    let sensitiveUseWarnings: [LifeContextSensitiveUseWarning]
    let missingContextQuestions: [LifeContextQuestion]
}

struct LifeContextBundle: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let profile: LifeContextProfile
    let eligibilityPathways: [LifeContextEligibilityPathway]
    let opportunityContexts: [OpportunityContext]
    let historicalFacts: [HistoricalContextFact]
    let sources: [LifeContextSource]
    let futureProofContextCandidates: [FutureProofContextCandidate]
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?

    init(
        id: String,
        profile: LifeContextProfile,
        eligibilityPathways: [LifeContextEligibilityPathway] = [],
        opportunityContexts: [OpportunityContext] = [],
        historicalFacts: [HistoricalContextFact] = [],
        sources: [LifeContextSource] = [],
        futureProofContextCandidates: [FutureProofContextCandidate] = [],
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil
    ) {
        self.id = id
        self.profile = profile
        self.eligibilityPathways = eligibilityPathways
        self.opportunityContexts = opportunityContexts
        self.historicalFacts = historicalFacts
        self.sources = sources
        self.futureProofContextCandidates = futureProofContextCandidates
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    var isDeleted: Bool {
        deletedAt != nil
    }

    func updated(
        profile: LifeContextProfile? = nil,
        eligibilityPathways: [LifeContextEligibilityPathway]? = nil,
        opportunityContexts: [OpportunityContext]? = nil,
        historicalFacts: [HistoricalContextFact]? = nil,
        sources: [LifeContextSource]? = nil,
        futureProofContextCandidates: [FutureProofContextCandidate]? = nil,
        updatedAt: String
    ) -> LifeContextBundle {
        LifeContextBundle(
            id: id,
            profile: profile ?? self.profile,
            eligibilityPathways: eligibilityPathways ?? self.eligibilityPathways,
            opportunityContexts: opportunityContexts ?? self.opportunityContexts,
            historicalFacts: historicalFacts ?? self.historicalFacts,
            sources: sources ?? self.sources,
            futureProofContextCandidates: futureProofContextCandidates ?? self.futureProofContextCandidates,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    func markedDeleted(at timestamp: String) -> LifeContextBundle {
        LifeContextBundle(
            id: id,
            profile: profile,
            eligibilityPathways: eligibilityPathways,
            opportunityContexts: opportunityContexts,
            historicalFacts: historicalFacts,
            sources: sources,
            futureProofContextCandidates: futureProofContextCandidates,
            createdAt: createdAt,
            updatedAt: timestamp,
            deletedAt: timestamp
        )
    }

    func replacingHistoricalFact(_ fact: HistoricalContextFact, updatedAt: String) -> LifeContextBundle {
        var facts = historicalFacts
        if let index = facts.firstIndex(where: { $0.id == fact.id }) {
            facts[index] = fact
        } else {
            facts.append(fact)
        }
        return updated(historicalFacts: facts, updatedAt: updatedAt)
    }

    func markHistoricalFactDeleted(id: String, at timestamp: String) -> LifeContextBundle {
        updated(
            historicalFacts: historicalFacts.map { $0.id == id ? $0.markedDeleted(at: timestamp) : $0 },
            updatedAt: timestamp
        )
    }

    func markHistoricalFactPaused(id: String, at timestamp: String) -> LifeContextBundle {
        updated(
            historicalFacts: historicalFacts.map { $0.id == id ? $0.markedPaused(at: timestamp) : $0 },
            updatedAt: timestamp
        )
    }

    func projection(asOf now: Date = .now) -> LifeContextRuntimeProjection {
        let activeFacts = historicalFacts.filter(\.isRuntimeEligible)
        let ageYears = resolvedAgeYears(asOf: now)
        let anchors = opportunityContexts.flatMap { opportunity in
            opportunity.facilities.map { facility in
                LifeContextOpportunityAnchor(
                    id: "\(opportunity.id).\(facility.rawValue)",
                    title: facility.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: opportunityDetail(for: opportunity),
                    verificationStatus: opportunity.verificationStatus
                )
            }
        }
        .sorted { $0.id < $1.id }

        let hardConstraints = deriveConstraints(from: activeFacts, isHard: true)
        let softConstraints = deriveConstraints(from: activeFacts, isHard: false)
        let historySummary = activeFacts.map {
            LifeContextHistorySummary(
                id: $0.id,
                title: $0.title,
                detail: $0.detail ?? $0.category.rawValue.replacingOccurrences(of: "_", with: " "),
                freshness: $0.freshness,
                usedFor: $0.usedFor
            )
        }
        .sorted { $0.id < $1.id }
        let excludedHistorySummary = historicalFacts.compactMap { fact -> LifeContextHistoryExclusionSummary? in
            guard fact.isDeletedOrPaused else {
                return nil
            }

            let reason: LifeContextHistoryExclusionReason = fact.deletedAt != nil || fact.sourceType == .deleted ? .deleted : .paused
            return LifeContextHistoryExclusionSummary(
                id: fact.id,
                factID: fact.id,
                reason: reason
            )
        }
        .sorted { $0.id < $1.id }
        let sourceFreshnessSummary = sources.map { source in
            LifeContextSourceFreshnessSummary(
                id: source.id,
                sourceID: source.id,
                label: source.label,
                freshness: freshness(for: source, asOf: now),
                detail: source.visibleExplanation
            )
        }
        .sorted { $0.id < $1.id }
        let sensitiveUseWarnings: [LifeContextSensitiveUseWarning] = historicalFacts.compactMap { fact -> LifeContextSensitiveUseWarning? in
            guard fact.isDeletedOrPaused == false, fact.sensitivity != .normal, fact.runtimeUseAllowed == false else {
                return nil
            }
            return LifeContextSensitiveUseWarning(
                id: fact.id,
                factID: fact.id,
                title: fact.title,
                detail: "Runtime use is blocked until the user explicitly allows it."
            )
        }
        .sorted { $0.id < $1.id }
        let missingContextQuestions = missingContextQuestions(ageYears: ageYears)

        return LifeContextRuntimeProjection(
            ageYears: ageYears,
            lifeStage: profile.lifeStage,
            availableOpportunityAnchors: anchors,
            hardConstraints: hardConstraints,
            softConstraints: softConstraints,
            travelModel: LifeContextTravelModel(
                radiusMinutes: profile.travelRadiusMinutes,
                radiusMiles: profile.travelRadiusMiles,
                transportationAccess: profile.transportationAccess,
                locationLabel: profile.generalLocationLabel,
                locationPrecision: profile.locationPrecision
            ),
            eligibilityModel: eligibilityPathways.sorted { $0.id < $1.id },
            historySummary: historySummary,
            excludedHistorySummary: excludedHistorySummary,
            sourceFreshnessSummary: sourceFreshnessSummary,
            sensitiveUseWarnings: sensitiveUseWarnings,
            missingContextQuestions: missingContextQuestions
        )
    }

    private func resolvedAgeYears(asOf now: Date) -> Int? {
        if let exactAgeYears = profile.exactAgeYears {
            return exactAgeYears
        }

        guard let birthdate = profile.birthdate,
              let birthdateDate = DomainTimestamp.date(from: birthdate) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let years = calendar.dateComponents([.year], from: birthdateDate, to: now).year ?? 0
        return max(0, years)
    }

    private func deriveConstraints(from facts: [HistoricalContextFact], isHard: Bool) -> [LifeContextConstraintSummary] {
        var summaries: [LifeContextConstraintSummary] = []

        if isHard {
            if let schoolOrWorkContext = profile.schoolOrWorkContext {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.school_or_work",
                    title: "School or work context",
                    detail: schoolOrWorkContext,
                    isHardConstraint: true
                ))
            }
            if let travelRadiusMinutes = profile.travelRadiusMinutes {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.travel_radius_minutes",
                    title: "Travel radius",
                    detail: "\(travelRadiusMinutes) minutes",
                    isHardConstraint: true
                ))
            }
            if profile.dependencyConstraints.isEmpty == false {
                summaries.append(contentsOf: profile.dependencyConstraints.enumerated().map { index, constraint in
                    LifeContextConstraintSummary(
                        id: "profile.dependency.\(index)",
                        title: "Dependency constraint",
                        detail: constraint,
                        isHardConstraint: true
                    )
                })
            }
            if profile.recoveryConstraints.isEmpty == false {
                summaries.append(contentsOf: profile.recoveryConstraints.enumerated().map { index, constraint in
                    LifeContextConstraintSummary(
                        id: "profile.recovery.\(index)",
                        title: "Recovery constraint",
                        detail: constraint,
                        isHardConstraint: true
                    )
                })
            }
            if profile.accessibilityNeeds.isEmpty == false {
                summaries.append(contentsOf: profile.accessibilityNeeds.enumerated().map { index, need in
                    LifeContextConstraintSummary(
                        id: "profile.accessibility.\(index)",
                        title: "Accessibility need",
                        detail: need,
                        isHardConstraint: true
                    )
                })
            }
            summaries.append(contentsOf: facts.flatMap { fact in
                fact.usedFor.contains(.safety) || fact.usedFor.contains(.eligibility) || fact.usedFor.contains(.travel)
                    ? [LifeContextConstraintSummary(
                        id: "fact.\(fact.id)",
                        title: fact.title,
                        detail: fact.detail ?? fact.category.rawValue,
                        isHardConstraint: true
                    )]
                    : []
            })
        } else {
            if let budgetConstraintBand = profile.budgetConstraintBand.displayLabelIfMeaningful {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.budget",
                    title: "Budget",
                    detail: budgetConstraintBand,
                    isHardConstraint: false
                ))
            }
            if let generalLocationLabel = profile.generalLocationLabel {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.location",
                    title: "Location",
                    detail: generalLocationLabel,
                    isHardConstraint: false
                ))
            }
            if profile.scheduleAnchors.isEmpty == false {
                summaries.append(contentsOf: profile.scheduleAnchors.enumerated().map { index, anchor in
                    LifeContextConstraintSummary(
                        id: "profile.anchor.\(index)",
                        title: "Schedule anchor",
                        detail: anchor,
                        isHardConstraint: false
                    )
                })
            }
            if let energyPattern = profile.energyPattern.displayLabelIfMeaningful {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.energy",
                    title: "Energy pattern",
                    detail: energyPattern,
                    isHardConstraint: false
                ))
            }
            summaries.append(contentsOf: facts.flatMap { fact in
                fact.usedFor.contains(.sequencing) || fact.usedFor.contains(.duration) || fact.usedFor.contains(.explanation) || fact.usedFor.contains(.opportunity)
                    ? [LifeContextConstraintSummary(
                        id: "fact.soft.\(fact.id)",
                        title: fact.title,
                        detail: fact.detail ?? fact.category.rawValue,
                        isHardConstraint: false
                    )]
                    : []
            })
        }

        return summaries.sorted { $0.id < $1.id }
    }

    private func opportunityDetail(for opportunity: OpportunityContext) -> String {
        var components: [String] = []
        if opportunity.equipmentAccess.isEmpty == false {
            components.append(opportunity.equipmentAccess.joined(separator: ", "))
        }
        if let coachingMentorAccess = opportunity.coachingMentorAccess {
            components.append(coachingMentorAccess)
        }
        if opportunity.localOrganizations.isEmpty == false {
            components.append(opportunity.localOrganizations.joined(separator: ", "))
        }
        if let travelRequirement = opportunity.travelRequirement {
            components.append(travelRequirement)
        }
        if let costRequirement = opportunity.costRequirement {
            components.append(costRequirement)
        }
        if let seasonalAvailability = opportunity.seasonalAvailability {
            components.append(seasonalAvailability)
        }
        if opportunity.eventExposureAccess {
            components.append("event exposure available")
        }
        if opportunity.remoteAccess {
            components.append("remote access available")
        }
        return components.isEmpty ? "Local opportunity anchor" : components.joined(separator: ", ")
    }

    private func freshness(for source: LifeContextSource, asOf now: Date) -> LifeContextFreshness {
        guard let sourceDate = DomainTimestamp.date(from: source.timestamp) else {
            return .current
        }

        let days = now.timeIntervalSince(sourceDate) / 86_400
        switch days {
        case ..<90:
            return .current
        case ..<365:
            return .mayNeedReview
        case ..<730:
            return .basedOnOlderContext
        default:
            return .stale
        }
    }

    private func missingContextQuestions(ageYears: Int?) -> [LifeContextQuestion] {
        var questions: [LifeContextQuestion] = []

        if ageYears == nil {
            questions.append(LifeContextQuestion(
                id: "missing.age",
                prompt: "What age context should the runtime use?",
                reason: "Age unlocks eligibility and safe-fit reasoning.",
                priority: 0
            ))
        }
        if profile.timezone == nil {
            questions.append(LifeContextQuestion(
                id: "missing.timezone",
                prompt: "Which timezone should the runtime assume?",
                reason: "Timezone keeps time, travel, and scheduling grounded.",
                priority: 1
            ))
        }
        if profile.locale == nil {
            questions.append(LifeContextQuestion(
                id: "missing.locale",
                prompt: "Which locale should the runtime use?",
                reason: "Locale keeps dates and labels readable.",
                priority: 2
            ))
        }
        if profile.lifeStage == .unknown {
            questions.append(LifeContextQuestion(
                id: "missing.life_stage",
                prompt: "Which life stage best describes this context?",
                reason: "Life stage shapes safe opportunity and recovery choices.",
                priority: 3
            ))
        }
        return questions.sorted { $0.priority < $1.priority }
    }
}

extension LifeContextBundle {
    enum CodingKeys: String, CodingKey {
        case id
        case profile
        case eligibilityPathways
        case opportunityContexts
        case historicalFacts
        case sources
        case futureProofContextCandidates
        case createdAt
        case updatedAt
        case deletedAt
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.profile = try container.decode(LifeContextProfile.self, forKey: .profile)
        self.eligibilityPathways = try container.decodeIfPresent([LifeContextEligibilityPathway].self, forKey: .eligibilityPathways) ?? []
        self.opportunityContexts = try container.decodeIfPresent([OpportunityContext].self, forKey: .opportunityContexts) ?? []
        self.historicalFacts = try container.decodeIfPresent([HistoricalContextFact].self, forKey: .historicalFacts) ?? []
        self.sources = try container.decodeIfPresent([LifeContextSource].self, forKey: .sources) ?? []
        self.futureProofContextCandidates = try container.decodeIfPresent([FutureProofContextCandidate].self, forKey: .futureProofContextCandidates) ?? []
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(profile, forKey: .profile)
        try container.encode(eligibilityPathways, forKey: .eligibilityPathways)
        try container.encode(opportunityContexts, forKey: .opportunityContexts)
        try container.encode(historicalFacts, forKey: .historicalFacts)
        try container.encode(sources, forKey: .sources)
        try container.encode(futureProofContextCandidates, forKey: .futureProofContextCandidates)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

private extension LifeContextBudgetConstraintBand {
    var displayLabelIfMeaningful: String? {
        switch self {
        case .unknown:
            return nil
        case .tight:
            return "Tight"
        case .moderate:
            return "Moderate"
        case .flexible:
            return "Flexible"
        case .custom:
            return "Custom"
        }
    }
}

private extension LifeContextEnergyPattern {
    var displayLabelIfMeaningful: String? {
        switch self {
        case .unknown:
            return nil
        case .morning:
            return "Morning"
        case .midday:
            return "Midday"
        case .evening:
            return "Evening"
        case .variable:
            return "Variable"
        }
    }
}

enum LifeContextFixtureProfiles {
    static func fourteenYearOldVarsityFootballGoal() -> LifeContextBundle {
        makeBundle(
            id: "fixture.14.varsity.football",
            profile: LifeContextProfile(
                id: "profile.14.varsity.football",
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
                schoolOrWorkContext: "Freshman football and school day",
                travelRadiusMinutes: 25,
                travelRadiusMiles: 12,
                transportationAccess: .parentGuardian,
                scheduleAnchors: ["school", "practice", "homework", "family dinner"],
                dependencyConstraints: ["Needs parent transportation to reach training facilities."],
                budgetConstraintBand: .tight,
                energyPattern: .afterSchoolFallback,
                recoveryConstraints: ["Avoid late-night heavy sessions before school days."],
                accessibilityNeeds: [],
                userNotes: "Goal is varsity football with limited local mobility."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.football.varsity",
                    pathwayType: .sport,
                    eligibilityRulesSummary: "Youth-to-varsity football pathway with age and grade progression.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 14, upperBoundYears: 18),
                    gradeWindow: "Freshman through senior",
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.football",
                        label: "Coach and school handbook",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "School and coach rules confirmed the path.",
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
                    id: "opportunity.ymca.field",
                    facilities: [.ymca, .field, .gym],
                    equipmentAccess: ["basic weights", "cones", "field space"],
                    coachingMentorAccess: "Occasional parent-organized coaching help",
                    localOrganizations: ["YMCA"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    travelRequirement: "Parent ride only",
                    costRequirement: "Low-cost membership preferred",
                    seasonalAvailability: "Fall season",
                    verificationStatus: .selfReported
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.football.youth",
                    category: .priorExperience,
                    title: "Played youth football",
                    detail: "Has several seasons of youth-level play.",
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
                    label: "Parent interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Family context and transportation limits came from a parent interview.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }

    static func sixteenYearOldVarsityFootballGoal() -> LifeContextBundle {
        makeBundle(
            id: "fixture.16.varsity.football",
            profile: LifeContextProfile(
                id: "profile.16.varsity.football",
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
                schoolOrWorkContext: "Varsity football and school weight room",
                travelRadiusMinutes: 20,
                travelRadiusMiles: 8,
                transportationAccess: .walk,
                scheduleAnchors: ["before school lifting", "classes", "after-school practice"],
                dependencyConstraints: ["Training must fit school bell schedule."],
                budgetConstraintBand: .moderate,
                energyPattern: .afterSchoolFallback,
                recoveryConstraints: ["Needs enough sleep to handle practices and classwork."],
                accessibilityNeeds: [],
                userNotes: "Compressed timeline to earn varsity minutes."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.football.16",
                    pathwayType: .sport,
                    eligibilityRulesSummary: "Varsity football path with compressed development timeline.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 15, upperBoundYears: 18),
                    gradeWindow: "Sophomore through senior",
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.football.16",
                        label: "Coach guidance",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "Coach confirmed the compressed timeline.",
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
                    id: "opportunity.school.weight_room",
                    facilities: [.school, .gym],
                    equipmentAccess: ["school racks", "dumbbells", "sled"],
                    coachingMentorAccess: "School strength coach",
                    localOrganizations: ["School athletics"],
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
                    id: "fact.football.practice",
                    category: .trainingHistory,
                    title: "Recent training consistency",
                    detail: "Has kept a regular lifting and practice cadence.",
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
                    label: "Coach notes",
                    kind: .inferred,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The timeline came from coaching context and school schedule.",
                    canDelete: true,
                    canPause: true,
                    canEdit: true
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }

    static func womanPursuingProfessionalBasketball() -> LifeContextBundle {
        makeBundle(
            id: "fixture.pro.basketball",
            profile: LifeContextProfile(
                id: "profile.pro.basketball",
                exactAgeYears: 22,
                ageSource: LifeContextSource(
                    id: "source.age.basketball",
                    label: "Self-reported age",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age was confirmed by the athlete.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/Los_Angeles",
                locale: "en_US",
                generalLocationLabel: "Metro area",
                locationPrecision: .cityRegion,
                sexOrEligibilityContext: "Women's professional basketball pathway.",
                lifeStage: .earlyCareer,
                schoolOrWorkContext: "Training and competition schedule",
                travelRadiusMinutes: 60,
                travelRadiusMiles: 40,
                transportationAccess: .rideshare,
                scheduleAnchors: ["training", "film", "recovery", "travel"],
                dependencyConstraints: ["Travel windows depend on team schedule."],
                budgetConstraintBand: .moderate,
                energyPattern: .midday,
                recoveryConstraints: ["Needs structured recovery after travel and games."],
                accessibilityNeeds: [],
                userNotes: "WNBA pathway with local and travel exposure."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.wnba",
                    pathwayType: .sport,
                    eligibilityRulesSummary: "Professional women's basketball pathway with roster and exposure requirements.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: "Women's league pathway",
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.wnba",
                        label: "League pathway summary",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "Pathway came from the athlete's confirmed career intent.",
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
                    id: "opportunity.gym.travel",
                    facilities: [.gym, .court, .studio],
                    equipmentAccess: ["full court", "weights", "mobility space"],
                    coachingMentorAccess: "Professional coach and mentor network",
                    localOrganizations: ["AAU", "regional showcase circuits"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    travelRequirement: "Frequent regional travel",
                    costRequirement: "Travel and camp costs apply",
                    seasonalAvailability: "Year-round",
                    verificationStatus: .partiallyVerified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.basketball.highlights",
                    category: .pastAchievement,
                    title: "Notable game film",
                    detail: "Has a game film library and live exposure history.",
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
                    id: "source.bundle.basketball",
                    label: "Athlete interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The athlete confirmed the professional pathway directly.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }

    static func manPursuingProfessionalBasketball() -> LifeContextBundle {
        makeBundle(
            id: "fixture.pro.basketball.men",
            profile: LifeContextProfile(
                id: "profile.pro.basketball.men",
                exactAgeYears: 22,
                ageSource: LifeContextSource(
                    id: "source.age.basketball.men",
                    label: "Self-reported age",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "Age was confirmed by the athlete.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                ),
                ageLastConfirmedAt: "2026-05-22T00:00:00Z",
                timezone: "America/Los_Angeles",
                locale: "en_US",
                generalLocationLabel: "Metro area",
                locationPrecision: .cityRegion,
                sexOrEligibilityContext: "Men's professional basketball pathway.",
                lifeStage: .earlyCareer,
                schoolOrWorkContext: "Training and competition schedule",
                travelRadiusMinutes: 60,
                travelRadiusMiles: 40,
                transportationAccess: .rideshare,
                scheduleAnchors: ["training", "film", "recovery", "travel"],
                dependencyConstraints: ["Travel windows depend on team schedule."],
                budgetConstraintBand: .moderate,
                energyPattern: .midday,
                recoveryConstraints: ["Needs structured recovery after travel and games."],
                accessibilityNeeds: [],
                userNotes: "Men's pathway with local and travel exposure."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.nba",
                    pathwayType: .sport,
                    eligibilityRulesSummary: "Professional men's basketball pathway with roster and exposure requirements.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: "Men's league pathway",
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.nba",
                        label: "League pathway summary",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "Pathway came from the athlete's confirmed career intent.",
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
                    id: "opportunity.gym.travel.men",
                    facilities: [.gym, .court, .studio],
                    equipmentAccess: ["full court", "weights", "mobility space"],
                    coachingMentorAccess: "Professional coach and mentor network",
                    localOrganizations: ["AAU", "regional showcase circuits"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    travelRequirement: "Frequent regional travel",
                    costRequirement: "Travel and camp costs apply",
                    seasonalAvailability: "Year-round",
                    verificationStatus: .partiallyVerified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.basketball.highlights.men",
                    category: .pastAchievement,
                    title: "Notable game film",
                    detail: "Has a game film library and live exposure history.",
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
                    id: "source.bundle.basketball.men",
                    label: "Athlete interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The athlete confirmed the professional pathway directly.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }

    static func adultMountainBikingGoal() -> LifeContextBundle {
        makeBundle(
            id: "fixture.adult.mtb",
            profile: LifeContextProfile(
                id: "profile.adult.mtb",
                exactAgeYears: 31,
                ageSource: LifeContextSource(
                    id: "source.age.mtb",
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
                schoolOrWorkContext: "Full-time work with weekend riding",
                travelRadiusMinutes: 30,
                travelRadiusMiles: 18,
                transportationAccess: .car,
                scheduleAnchors: ["workday", "weekend mornings"],
                dependencyConstraints: ["No nearby trail network within the local radius."],
                budgetConstraintBand: .moderate,
                energyPattern: .morning,
                recoveryConstraints: ["Needs recovery days after harder rides."],
                accessibilityNeeds: [],
                userNotes: "Goal is mountain biking with limited trail access."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.mtb.health",
                    pathwayType: .health,
                    eligibilityRulesSummary: "Build fitness, handling skill, and access to rideable terrain.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.mtb",
                        label: "Rider plan",
                        kind: .inferred,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "The pathway came from the user's mountain biking goal.",
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
                    id: "opportunity.local.park",
                    facilities: [.park, .trail],
                    equipmentAccess: ["bike rack", "basic repair kit"],
                    coachingMentorAccess: "Remote coaching only",
                    localOrganizations: [],
                    eventExposureAccess: false,
                    remoteAccess: true,
                    travelRequirement: "Trail access requires a longer drive",
                    costRequirement: "Fuel and trail fees may apply",
                    seasonalAvailability: "Dry months only",
                    verificationStatus: .unverified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.mtb.no_nearby_trails",
                    category: .locationHistory,
                    title: "No nearby trail network",
                    detail: "Local radius has no trail system within the normal ride distance.",
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
                    id: "source.bundle.mtb",
                    label: "User interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The user confirmed travel limits and local trail gaps.",
                    canDelete: false,
                    canPause: false,
                    canEdit: false
                )
            ],
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }

    static func cityMountainBikingGoalWithoutBike() -> LifeContextBundle {
        makeBundle(
            id: "fixture.city.mtb.no_bike",
            profile: LifeContextProfile(
                id: "profile.city.mtb.no_bike",
                exactAgeYears: 31,
                ageSource: LifeContextSource(
                    id: "source.age.city.mtb",
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
                dependencyConstraints: ["No nearby trail network within the local radius.", "No bike yet."],
                budgetConstraintBand: .tight,
                energyPattern: .variable,
                recoveryConstraints: ["Needs recovery days after harder rides."],
                accessibilityNeeds: [],
                userNotes: "City rider with no bike and limited trail access."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.mtb.city",
                    pathwayType: .health,
                    eligibilityRulesSummary: "Build fitness and access before trail riding.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    gradeWindow: nil,
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: LifeContextSource(
                        id: "source.pathway.mtb.city",
                        label: "Rider plan",
                        kind: .inferred,
                        timestamp: "2026-05-22T00:00:00Z",
                        visibleExplanation: "The pathway came from the user's mountain biking goal.",
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
                    id: "opportunity.city.gym",
                    facilities: [.gym, .home],
                    equipmentAccess: ["stationary bike", "basic weights"],
                    coachingMentorAccess: "Indoor coach or class options",
                    localOrganizations: ["Community fitness center"],
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
                    id: "fact.mtb.city.no_bike",
                    category: .trainingHistory,
                    title: "No bike yet",
                    detail: "The next step may need equipment access before trail riding.",
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
                    id: "fact.mtb.city.trail_gap",
                    category: .locationHistory,
                    title: "No nearby trail network",
                    detail: "The local radius does not include a trail system.",
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
                    id: "source.bundle.city.mtb",
                    label: "User interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T00:00:00Z",
                    visibleExplanation: "The user confirmed trail gaps and the missing bike.",
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

    private static func makeBundle(
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

private extension LifeContextEnergyPattern {
    static let afterSchoolFallback: LifeContextEnergyPattern = .variable
}
