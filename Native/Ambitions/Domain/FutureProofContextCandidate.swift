import Foundation

enum CaptureRuntimeFactoringCandidateType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case step
    case scheduledActivity = "scheduled_activity"
    case proof
    case lifeContext = "life_context"
    case historicalContext = "historical_context"
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case blocker
    case opportunity
    case recovery
    case recurringCommitment = "recurring_commitment"
    case goalSeed = "goal_seed"
    case decideLater = "decide_later"

    var displayTitle: String {
        switch self {
        case .step:
            return "Step"
        case .scheduledActivity:
            return "Scheduled activity"
        case .proof:
            return "Proof"
        case .lifeContext:
            return "Life context"
        case .historicalContext:
            return "Historical context"
        case .facilityAccess:
            return "Facility access"
        case .equipmentAccess:
            return "Equipment access"
        case .blocker:
            return "Blocker"
        case .opportunity:
            return "Opportunity"
        case .recovery:
            return "Recovery"
        case .recurringCommitment:
            return "Recurring commitment"
        case .goalSeed:
            return "Goal seed"
        case .decideLater:
            return "Decide later"
        }
    }
}

enum FutureProofContextCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case activityHistory = "activity_history"
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case accessConstraint = "access_constraint"
    case scheduleDrift = "schedule_drift"
    case recurringCommitment = "recurring_commitment"
    case recoveryConstraint = "recovery_constraint"
    case skillContext = "skill_context"
    case lifeContext = "life_context"
    case historicalContext = "historical_context"
    case goalSeed = "goal_seed"
    case opportunity
    case decideLater = "decide_later"

    var displayTitle: String {
        switch self {
        case .activityHistory:
            return "Activity history"
        case .facilityAccess:
            return "Facility access"
        case .equipmentAccess:
            return "Equipment access"
        case .accessConstraint:
            return "Access constraint"
        case .scheduleDrift:
            return "Schedule drift"
        case .recurringCommitment:
            return "Recurring commitment"
        case .recoveryConstraint:
            return "Recovery constraint"
        case .skillContext:
            return "Skill context"
        case .lifeContext:
            return "Life context"
        case .historicalContext:
            return "Historical context"
        case .goalSeed:
            return "Goal seed"
        case .opportunity:
            return "Opportunity"
        case .decideLater:
            return "Decide later"
        }
    }
}

struct CaptureRuntimeFactoringCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let captureID: String
    let candidateType: CaptureRuntimeFactoringCandidateType
    let suggestedDestination: String
    let runtimeUseAllowed: Bool
    let requiresApproval: Bool
    let sourceFreshness: LifeContextFreshness
    let sensitivity: HistoricalContextFactSensitivity
    let reason: String
    let rejectedReason: String?

    var id: String {
        "\(captureID).\(candidateType.rawValue)"
    }
}

struct FutureProofContextCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let captureID: String
    let contextCategory: FutureProofContextCategory
    let potentialFutureUses: [String]
    let sourceLabel: String
    let freshness: LifeContextFreshness
    let reviewNeeded: Bool
    let runtimeUseAllowed: Bool
    let visibleInYou: Bool
    let deletionSupported: Bool

    var id: String {
        "\(captureID).\(contextCategory.rawValue)"
    }
}

extension SmartAttachmentResult {
    var captureRuntimeFactoringCandidate: CaptureRuntimeFactoringCandidate? {
        FutureProofContextClassifier.captureRuntimeFactoringCandidate(from: self)
    }

    var futureProofContextCandidate: FutureProofContextCandidate? {
        FutureProofContextClassifier.futureProofContextCandidate(from: self)
    }
}
