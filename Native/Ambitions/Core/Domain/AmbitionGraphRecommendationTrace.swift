import Foundation

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
    let goalThreads: [GoalThread]
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

    enum CodingKeys: String, CodingKey {
        case id
        case ambition
        case goalThreads
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
        goalThreads: [GoalThread] = [],
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
        self.goalThreads = goalThreads
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
        self.goalThreads = try container.decodeIfPresent([GoalThread].self, forKey: .goalThreads) ?? []
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

extension AmbitionGraphSnapshot {
    var canonicalGoalThreadHierarchy: AmbitionGraphGoalThreadHierarchy? {
        if let activeID = ambition.activeGoalThreadID,
           let hierarchy = goalThreadHierarchy(for: activeID) {
            return hierarchy
        }

        return goalThreads.first.map { goalThreadHierarchy(for: $0) }
    }

    var canonicalGoalThreadPath: [LifeGraphObjectReference] {
        canonicalGoalThreadHierarchy?.canonicalPath ?? []
    }

    func goalThreadHierarchy(for threadID: String) -> AmbitionGraphGoalThreadHierarchy? {
        guard let thread = goalThreads.first(where: { $0.id == threadID }) else {
            return nil
        }
        return goalThreadHierarchy(for: thread)
    }

    func goalThreadHierarchy(for thread: GoalThread) -> AmbitionGraphGoalThreadHierarchy {
        AmbitionGraphGoalThreadHierarchy(
            goalThread: thread,
            ambition: ambition,
            commitments: commitments,
            proofs: proofs,
            steps: steps,
            recoveryThreads: recoveryThreads
        )
    }
}
