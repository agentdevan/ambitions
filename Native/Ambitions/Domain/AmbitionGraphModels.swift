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

enum AmbitionRecoveryReceiptBehavior: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preserveExistingReceipt = "preserve_existing_receipt"
    case createOnReentry = "create_on_reentry"
    case receiptAlreadyRecorded = "receipt_already_recorded"
    case receiptNotNeeded = "receipt_not_needed"

    var isReceiptReady: Bool {
        switch self {
        case .preserveExistingReceipt, .createOnReentry, .receiptAlreadyRecorded:
            return true
        case .receiptNotNeeded:
            return false
        }
    }
}

enum AmbitionCommitmentStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case open
    case promised
    case inFlight = "in_flight"
    case waiting
    case blocked
    case held
    case stalled
    case completed
    case moved
    case shortened
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

    var preservesProof: Bool {
        switch self {
        case .waiting, .blocked, .needsRecovery, .needsReview, .held, .paused, .stalled, .tooLarge:
            return true
        case .completed, .stillCounts, .moved, .shortened, .readyToRestart:
            return true
        case .notNeeded, .noLongerTrue:
            return false
        }
    }

    var shouldCreateRecoveryThread: Bool {
        switch self {
        case .completed, .stillCounts, .moved, .shortened, .notNeeded:
            return false
        case .waiting, .blocked, .needsRecovery, .needsReview, .held, .paused, .stalled, .tooLarge, .noLongerTrue, .readyToRestart:
            return true
        }
    }

    var nextCommitmentStatus: AmbitionCommitmentStatus {
        switch self {
        case .completed:
            return .completed
        case .stillCounts:
            return .stillCounts
        case .moved:
            return .moved
        case .shortened, .tooLarge:
            return .shortened
        case .waiting, .needsRecovery, .readyToRestart:
            return .waiting
        case .blocked, .needsReview:
            return .blocked
        case .held:
            return .held
        case .paused:
            return .held
        case .stalled:
            return .stalled
        case .noLongerTrue, .notNeeded:
            return .notNeeded
        }
    }

    var allowsReentry: Bool {
        switch self {
        case .completed, .stillCounts, .moved, .shortened, .notNeeded:
            return false
        case .waiting, .blocked, .needsRecovery, .needsReview, .held, .paused, .stalled, .tooLarge, .noLongerTrue, .readyToRestart:
            return true
        }
    }

    func transition(hasProof: Bool) -> CommitmentLifecycleTransition {
        .init(closureState: self, hasProof: hasProof)
    }
}

struct CommitmentLifecycleTransition: Sendable, Equatable {
    let closureState: AmbitionClosureState
    let nextCommitmentStatus: AmbitionCommitmentStatus
    let preservesProof: Bool
    let shouldCreateRecoveryThread: Bool
    let allowsReentry: Bool

    init(closureState: AmbitionClosureState, hasProof: Bool) {
        self.closureState = closureState
        nextCommitmentStatus = closureState.nextCommitmentStatus
        preservesProof = closureState.preservesProof && hasProof
        shouldCreateRecoveryThread = closureState.shouldCreateRecoveryThread
        allowsReentry = closureState.allowsReentry
    }
}

enum AmbitionIdentityPriority: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case primary = "primary"
    case supporting = "supporting"
    case experimental = "experimental"
}

enum AmbitionOutcomeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case behavior
    case state
    case identity
    case capacity
    case relationship
    case financial
    case wellBeing = "well_being"
    case custom
}

struct IdentityDirection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let title: String
    let statement: String?
    let priority: AmbitionIdentityPriority
    let isActive: Bool
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        title: String,
        statement: String? = nil,
        priority: AmbitionIdentityPriority = .supporting,
        isActive: Bool = true,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.title = title
        self.statement = statement
        self.priority = priority
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Outcome: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let identityDirectionID: String?
    let goalThreadID: String?
    let title: String
    let detail: String?
    let targetAt: String?
    let kind: AmbitionOutcomeKind
    let isPrimary: Bool
    let metric: String?
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        identityDirectionID: String? = nil,
        goalThreadID: String? = nil,
        title: String,
        detail: String? = nil,
        targetAt: String? = nil,
        kind: AmbitionOutcomeKind = .custom,
        isPrimary: Bool = false,
        metric: String? = nil,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.identityDirectionID = identityDirectionID
        self.goalThreadID = goalThreadID
        self.title = title
        self.detail = detail
        self.targetAt = targetAt
        self.kind = kind
        self.isPrimary = isPrimary
        self.metric = metric
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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

struct AmbitionGraphStep: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let goalThreadID: String?
    let outcomeID: String?
    let name: String
    let description: String?
    let targetOrder: Int
    let expectedEffortMinutes: Int?
    let isMilestone: Bool
    let isCompleted: Bool
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        goalThreadID: String? = nil,
        outcomeID: String? = nil,
        name: String,
        description: String? = nil,
        targetOrder: Int = 0,
        expectedEffortMinutes: Int? = nil,
        isMilestone: Bool = false,
        isCompleted: Bool = false,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.goalThreadID = goalThreadID
        self.outcomeID = outcomeID
        self.name = name
        self.description = description
        self.targetOrder = targetOrder
        self.expectedEffortMinutes = expectedEffortMinutes.map { max(0, $0) }
        self.isMilestone = isMilestone
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct ClosureEvent: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let goalThreadID: String?
    let ambitionGraphStepID: String?
    let commitmentID: String?
    let proofID: String?
    let closureState: AmbitionClosureState
    let reason: String?
    let followUpPlan: String?
    let createdAt: String

    init(
        id: String,
        ambitionID: String,
        goalThreadID: String? = nil,
        ambitionGraphStepID: String? = nil,
        commitmentID: String? = nil,
        proofID: String? = nil,
        closureState: AmbitionClosureState,
        reason: String? = nil,
        followUpPlan: String? = nil,
        createdAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.goalThreadID = goalThreadID
        self.ambitionGraphStepID = ambitionGraphStepID
        self.commitmentID = commitmentID
        self.proofID = proofID
        self.closureState = closureState
        self.reason = reason
        self.followUpPlan = followUpPlan
        self.createdAt = createdAt
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
    let lastHonestPoint: RecoveryLastHonestPoint?
    let preservedProofRefs: [String]
    let reentryStep: RecoveryReentryStep?
    let receiptBehavior: AmbitionRecoveryReceiptBehavior
    let whatChanged: String?
    let newSmallestCommitment: String?
    let status: AmbitionRecoveryStatus
    let receiptID: String?
    let createdAt: String
    let updatedAt: String

    private enum CodingKeys: String, CodingKey {
        case id
        case ambitionID
        case trigger
        case priorProofRefs
        case lastHonestPoint
        case preservedProofRefs
        case reentryStep
        case receiptBehavior
        case whatChanged
        case newSmallestCommitment
        case status
        case receiptID
        case createdAt
        case updatedAt
    }

    init(
        id: String,
        ambitionID: String,
        trigger: String,
        priorProofRefs: [String] = [],
        lastHonestPoint: RecoveryLastHonestPoint? = nil,
        preservedProofRefs: [String]? = nil,
        reentryStep: RecoveryReentryStep? = nil,
        receiptBehavior: AmbitionRecoveryReceiptBehavior = .createOnReentry,
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
        let stablePriorProofRefs = ambitionGraphStableUnique(priorProofRefs)
        self.priorProofRefs = stablePriorProofRefs
        self.lastHonestPoint = lastHonestPoint
        self.preservedProofRefs = ambitionGraphStableUnique(preservedProofRefs ?? stablePriorProofRefs)
        self.reentryStep = reentryStep
        self.receiptBehavior = receiptBehavior
        self.whatChanged = whatChanged
        self.newSmallestCommitment = newSmallestCommitment
        self.status = status
        self.receiptID = receiptID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        ambitionID = try container.decode(String.self, forKey: .ambitionID)
        trigger = try container.decode(String.self, forKey: .trigger)
        let decodedPriorProofRefs = ambitionGraphStableUnique(
            try container.decodeIfPresent([String].self, forKey: .priorProofRefs) ?? []
        )
        priorProofRefs = decodedPriorProofRefs
        lastHonestPoint = try container.decodeIfPresent(RecoveryLastHonestPoint.self, forKey: .lastHonestPoint)
        preservedProofRefs = ambitionGraphStableUnique(
            try container.decodeIfPresent([String].self, forKey: .preservedProofRefs) ?? decodedPriorProofRefs
        )
        reentryStep = try container.decodeIfPresent(RecoveryReentryStep.self, forKey: .reentryStep)
        receiptBehavior = try container.decodeIfPresent(
            AmbitionRecoveryReceiptBehavior.self,
            forKey: .receiptBehavior
        ) ?? .createOnReentry
        whatChanged = try container.decodeIfPresent(String.self, forKey: .whatChanged)
        newSmallestCommitment = try container.decodeIfPresent(String.self, forKey: .newSmallestCommitment)
        status = try container.decodeIfPresent(AmbitionRecoveryStatus.self, forKey: .status) ?? .active
        receiptID = try container.decodeIfPresent(String.self, forKey: .receiptID)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }

    var isRecoverable: Bool {
        switch status {
        case .active, .held, .paused, .stalled, .interruptedButStillUseful:
            return true
        case .notNeeded, .complete:
            return false
        }
    }

    var effectiveProofRefs: [String] {
        ambitionGraphStableUnique(priorProofRefs + preservedProofRefs)
    }

    var hasReentryStep: Bool {
        reentryStep != nil || newSmallestCommitment != nil
    }

    var isReceiptReady: Bool {
        receiptID != nil || receiptBehavior.isReceiptReady
    }
}

struct RecoveryLastHonestPoint: Codable, Sendable, Equatable, Hashable {
    let commitmentID: String?
    let closureEventID: String?
    let stepID: String?
    let summary: String
    let capturedAt: String

    init(
        commitmentID: String? = nil,
        closureEventID: String? = nil,
        stepID: String? = nil,
        summary: String,
        capturedAt: String
    ) {
        self.commitmentID = commitmentID
        self.closureEventID = closureEventID
        self.stepID = stepID
        self.summary = summary
        self.capturedAt = capturedAt
    }
}

struct RecoveryReentryStep: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commitmentID: String?
    let stepID: String?
    let title: String
    let reason: String?
    let estimatedEffortMinutes: Int?

    init(
        id: String,
        commitmentID: String? = nil,
        stepID: String? = nil,
        title: String,
        reason: String? = nil,
        estimatedEffortMinutes: Int? = nil
    ) {
        self.id = id
        self.commitmentID = commitmentID
        self.stepID = stepID
        self.title = title
        self.reason = reason
        self.estimatedEffortMinutes = estimatedEffortMinutes
    }
}

struct AmbitionGraphRecommendationTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
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
    let recommendationTraces: [AmbitionGraphRecommendationTrace]
    let identityDirections: [IdentityDirection]
    let outcomes: [Outcome]
    let steps: [AmbitionGraphStep]
    let closureEvents: [ClosureEvent]
    let schemaVersion: String

    private enum CodingKeys: String, CodingKey {
        case id
        case ambition
        case commitments
        case proofs
        case constraints
        case recoveryThreads
        case recommendationTraces
        case identityDirections
        case outcomes
        case steps
        case closureEvents
        case schemaVersion
    }

    init(
        id: String,
        ambition: Ambition,
        commitments: [Commitment] = [],
        proofs: [Proof] = [],
        constraints: [Constraint] = [],
        recoveryThreads: [RecoveryThread] = [],
        recommendationTraces: [AmbitionGraphRecommendationTrace] = [],
        identityDirections: [IdentityDirection] = [],
        outcomes: [Outcome] = [],
        steps: [AmbitionGraphStep] = [],
        closureEvents: [ClosureEvent] = [],
        schemaVersion: String = ambitionGraphSchemaVersion
    ) {
        self.id = id
        self.ambition = ambition
        self.commitments = commitments
        self.proofs = proofs
        self.constraints = constraints
        self.recoveryThreads = recoveryThreads
        self.recommendationTraces = recommendationTraces
        self.identityDirections = identityDirections
        self.outcomes = outcomes
        self.steps = steps
        self.closureEvents = closureEvents
        self.schemaVersion = schemaVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.ambition = try container.decode(Ambition.self, forKey: .ambition)
        self.commitments = try container.decodeIfPresent([Commitment].self, forKey: .commitments) ?? []
        self.proofs = try container.decodeIfPresent([Proof].self, forKey: .proofs) ?? []
        self.constraints = try container.decodeIfPresent([Constraint].self, forKey: .constraints) ?? []
        self.recoveryThreads = try container.decodeIfPresent([RecoveryThread].self, forKey: .recoveryThreads) ?? []
        self.recommendationTraces = try container.decodeIfPresent([AmbitionGraphRecommendationTrace].self, forKey: .recommendationTraces) ?? []
        self.identityDirections = try container.decodeIfPresent([IdentityDirection].self, forKey: .identityDirections) ?? []
        self.outcomes = try container.decodeIfPresent([Outcome].self, forKey: .outcomes) ?? []
        self.steps = try container.decodeIfPresent([AmbitionGraphStep].self, forKey: .steps) ?? []
        self.closureEvents = try container.decodeIfPresent([ClosureEvent].self, forKey: .closureEvents) ?? []
        self.schemaVersion = try container.decodeIfPresent(String.self, forKey: .schemaVersion) ?? ambitionGraphSchemaVersion
    }
}
