import Foundation

let ambitionGraphSchemaVersion = "ambition_graph.native.v1"

private func ambitionGraphStableUnique(_ values: [String]) -> [String] {
    var seen = Set<String>()
    return values.filter { seen.insert($0).inserted }
}

enum AmbitionPrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case privateUserText = "private_user_text"
    case privateProof = "private_proof"
    case privateConstraint = "private_constraint"
    case systemOwned = "system_owned"
    case sharedReceipt = "shared_receipt"

    var displayLabel: String {
        switch self {
        case .privateUserText: "Private"
        case .privateProof: "Proof Protected"
        case .privateConstraint: "Constraint Protected"
        case .systemOwned: "System owned"
        case .sharedReceipt: "Receipt Visible"
        }
    }
}

enum AmbitionGraphProofType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case artifact
    case text
    case receipt
    case checkpoint
    case voice
    case photo
    case reviewNote = "review_note"
}

enum AmbitionConstraintPattern: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case recurringSchedule = "recurring_schedule"
    case energyDemand = "energy_demand"
    case externalRequirement = "external_requirement"
    case environment
    case supportNeed = "support_need"
    case dependency
}

enum AmbitionRecoveryStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notNeeded = "not_needed"
    case active
    case held
    case paused
    case stalled
    case complete
    case interruptedButStillUseful = "interrupted_but_still_useful"
}

enum AmbitionCommitmentStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case open
    case promised
    case inFlight = "in_flight"
    case waiting
    case held
    case stalled
    case completed
    case moved
    case notNeeded = "not_needed"
    case stillCounts = "still_counts"
}

enum AmbitionRecommendationAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startNow = "start_now"
    case openStep = "open_step"
    case shorten
    case move
    case stillCounts = "still_counts"
    case notToday = "not_today"
    case wrongRecommendation = "wrong_recommendation"
    case forgetPattern = "forget_pattern"
    case none
}

enum AmbitionClosureState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case completed
    case stillCounts = "still_counts"
    case moved
    case shortened
    case waiting
    case blocked
    case needsRecovery = "needs_recovery"
    case needsReview = "needs_review"
    case held
    case paused
    case stalled
    case tooLarge = "too_large"
    case noLongerTrue = "no_longer_true"
    case readyToRestart = "ready_to_restart"
    case notNeeded = "not_needed"

    var displayLabel: String {
        switch self {
        case .completed: "Completed"
        case .stillCounts: "Still Counts"
        case .moved: "Moved"
        case .shortened: "Shortened"
        case .waiting: "Waiting"
        case .blocked: "Blocked"
        case .needsRecovery: "Needs Recovery"
        case .needsReview: "Needs Review"
        case .held: "Held"
        case .paused: "Paused"
        case .stalled: "Stalled"
        case .tooLarge: "Too Large"
        case .noLongerTrue: "No Longer True"
        case .readyToRestart: "Ready To Restart"
        case .notNeeded: "Not Needed"
        }
    }

    var isClosureForRecovery: Bool {
        switch self {
        case .stalled, .paused, .blocked, .waiting, .needsRecovery, .needsReview, .shortened, .held, .tooLarge, .noLongerTrue, .notNeeded:
            return true
        case .completed, .stillCounts, .moved, .readyToRestart:
            return false
        }
    }
}

struct Ambition: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let identityStatement: String
    let lifeAreaID: String?
    let desiredOutcome: String?
    let desiredProofDescription: String?
    let activeGoalThreadID: String?
    let activeCommitmentID: String?
    let knownConstraintIDs: [String]
    let recoveryPolicy: String?
    let privacyClass: AmbitionPrivacyClass
    let createdAt: String
    let updatedAt: String
    let archivedAt: String?

    init(
        id: String,
        title: String,
        identityStatement: String,
        lifeAreaID: String? = nil,
        desiredOutcome: String? = nil,
        desiredProofDescription: String? = nil,
        activeGoalThreadID: String? = nil,
        activeCommitmentID: String? = nil,
        knownConstraintIDs: [String] = [],
        recoveryPolicy: String? = nil,
        privacyClass: AmbitionPrivacyClass = .privateUserText,
        createdAt: String,
        updatedAt: String,
        archivedAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.identityStatement = identityStatement
        self.lifeAreaID = lifeAreaID
        self.desiredOutcome = desiredOutcome
        self.desiredProofDescription = desiredProofDescription
        self.activeGoalThreadID = activeGoalThreadID
        self.activeCommitmentID = activeCommitmentID
        self.knownConstraintIDs = ambitionGraphStableUnique(knownConstraintIDs)
        self.recoveryPolicy = recoveryPolicy
        self.privacyClass = privacyClass
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    var hasActiveThread: Bool {
        activeGoalThreadID != nil
    }
}

struct Constraint: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let label: String
    let patternDescription: String
    let patternType: AmbitionConstraintPattern
    let evidenceCount: Int
    let lastObservedAt: String?
    let userConfirmed: Bool
    let mitigation: String?
    let privacyClass: AmbitionPrivacyClass
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        label: String,
        patternDescription: String,
        patternType: AmbitionConstraintPattern = .environment,
        evidenceCount: Int = 0,
        lastObservedAt: String? = nil,
        userConfirmed: Bool = false,
        mitigation: String? = nil,
        privacyClass: AmbitionPrivacyClass = .privateConstraint,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.label = label
        self.patternDescription = patternDescription
        self.patternType = patternType
        self.evidenceCount = max(0, evidenceCount)
        self.lastObservedAt = lastObservedAt
        self.userConfirmed = userConfirmed
        self.mitigation = mitigation
        self.privacyClass = privacyClass
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct GoalThread: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let name: String
    let goalIDs: [String]
    let isActive: Bool
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        name: String,
        goalIDs: [String] = [],
        isActive: Bool = true,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.name = name
        self.goalIDs = ambitionGraphStableUnique(goalIDs)
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Commitment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let goalThreadID: String?
    let stepID: String?
    let promisedFor: String?
    let expectedEffort: String?
    let minimumProofDescription: String?
    let fitReason: String?
    let recoveryPolicy: String?
    let status: AmbitionCommitmentStatus
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        goalThreadID: String? = nil,
        stepID: String? = nil,
        promisedFor: String? = nil,
        expectedEffort: String? = nil,
        minimumProofDescription: String? = nil,
        fitReason: String? = nil,
        recoveryPolicy: String? = nil,
        status: AmbitionCommitmentStatus = .open,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.goalThreadID = goalThreadID
        self.stepID = stepID
        self.promisedFor = promisedFor
        self.expectedEffort = expectedEffort
        self.minimumProofDescription = minimumProofDescription
        self.fitReason = fitReason
        self.recoveryPolicy = recoveryPolicy
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Proof: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let goalThreadID: String?
    let commitmentID: String?
    let closureEventID: String?
    let proofType: AmbitionGraphProofType
    let artifactReference: String?
    let text: String?
    let source: String?
    let privacyClass: AmbitionPrivacyClass
    let userConfirmed: Bool
    let transferPolicy: String?
    let createdAt: String

    init(
        id: String,
        ambitionID: String,
        goalThreadID: String? = nil,
        commitmentID: String? = nil,
        closureEventID: String? = nil,
        proofType: AmbitionGraphProofType,
        artifactReference: String? = nil,
        text: String? = nil,
        source: String? = nil,
        privacyClass: AmbitionPrivacyClass = .privateProof,
        userConfirmed: Bool = false,
        transferPolicy: String? = nil,
        createdAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.goalThreadID = goalThreadID
        self.commitmentID = commitmentID
        self.closureEventID = closureEventID
        self.proofType = proofType
        self.artifactReference = artifactReference
        self.text = text
        self.source = source
        self.privacyClass = privacyClass
        self.userConfirmed = userConfirmed
        self.transferPolicy = transferPolicy
        self.createdAt = createdAt
    }
}

struct RecoveryThread: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let trigger: String
    let priorProofRefs: [String]
    let whatChanged: String?
    let newSmallestCommitment: String?
    let status: AmbitionRecoveryStatus
    let receiptID: String?
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        trigger: String,
        priorProofRefs: [String] = [],
        whatChanged: String? = nil,
        newSmallestCommitment: String? = nil,
        status: AmbitionRecoveryStatus = .active,
        receiptID: String? = nil,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.trigger = trigger
        self.priorProofRefs = ambitionGraphStableUnique(priorProofRefs)
        self.whatChanged = whatChanged
        self.newSmallestCommitment = newSmallestCommitment
        self.status = status
        self.receiptID = receiptID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isRecoverable: Bool {
        status == .active || status == .held
    }
}

struct RecommendationTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let recommendedObjectID: String
    let sourceRefs: [String]
    let reasonCodes: [String]
    let uncertainty: Double
    let userAction: AmbitionRecommendationAction
    let declineReason: String?
    let createdAt: String
    let expiresAt: String?
    let isAiCopySuppressed: Bool
    let sourceLabels: [String]

    init(
        id: String,
        recommendedObjectID: String,
        sourceRefs: [String] = [],
        reasonCodes: [String] = [],
        uncertainty: Double = 0.0,
        userAction: AmbitionRecommendationAction = .none,
        declineReason: String? = nil,
        createdAt: String,
        expiresAt: String? = nil,
        isAiCopySuppressed: Bool = true,
        sourceLabels: [String] = []
    ) {
        self.id = id
        self.recommendedObjectID = recommendedObjectID
        self.sourceRefs = ambitionGraphStableUnique(sourceRefs)
        self.reasonCodes = ambitionGraphStableUnique(reasonCodes)
        self.uncertainty = max(0.0, min(1.0, uncertainty))
        self.userAction = userAction
        self.declineReason = declineReason
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.isAiCopySuppressed = isAiCopySuppressed
        self.sourceLabels = ambitionGraphStableUnique(sourceLabels)
    }

    var controlOptions: [AmbitionRecommendationAction] {
        switch userAction {
        case .none:
            return [.startNow, .openStep, .shorten, .move, .stillCounts, .notToday, .wrongRecommendation, .forgetPattern]
        case .wrongRecommendation:
            return [.notToday, .move]
        case .notToday:
            return [.stillCounts, .move, .shorten]
        default:
            return [.notToday, .wrongRecommendation]
        }
    }
}

struct Reflection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let proofID: String?
    let closureEventID: String?
    let text: String
    let learnedSignal: String
    let createdAt: String

    init(
        id: String,
        ambitionID: String,
        proofID: String? = nil,
        closureEventID: String? = nil,
        text: String,
        learnedSignal: String,
        createdAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.proofID = proofID
        self.closureEventID = closureEventID
        self.text = text
        self.learnedSignal = learnedSignal
        self.createdAt = createdAt
    }
}

struct AdaptationPivot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let triggerProofID: String?
    let sourceThreadID: String?
    let proposedChange: String
    let resultingCommitmentID: String?
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        triggerProofID: String? = nil,
        sourceThreadID: String? = nil,
        proposedChange: String,
        resultingCommitmentID: String? = nil,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.triggerProofID = triggerProofID
        self.sourceThreadID = sourceThreadID
        self.proposedChange = proposedChange
        self.resultingCommitmentID = resultingCommitmentID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct AmbitionGraphSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambition: Ambition
    let commitments: [Commitment]
    let proofs: [Proof]
    let constraints: [Constraint]
    let recoveryThreads: [RecoveryThread]
    let recommendationTraces: [RecommendationTrace]
    let schemaVersion: String

    init(
        id: String,
        ambition: Ambition,
        commitments: [Commitment] = [],
        proofs: [Proof] = [],
        constraints: [Constraint] = [],
        recoveryThreads: [RecoveryThread] = [],
        recommendationTraces: [RecommendationTrace] = [],
        schemaVersion: String = ambitionGraphSchemaVersion
    ) {
        self.id = id
        self.ambition = ambition
        self.commitments = commitments
        self.proofs = proofs
        self.constraints = constraints
        self.recoveryThreads = recoveryThreads
        self.recommendationTraces = recommendationTraces
        self.schemaVersion = schemaVersion
    }
}
