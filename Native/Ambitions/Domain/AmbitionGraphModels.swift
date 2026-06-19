import Foundation

let ambitionGraphSchemaVersion = "ambition_graph.native.v1"

func ambitionGraphStableUnique(_ values: [String]) -> [String] {
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
