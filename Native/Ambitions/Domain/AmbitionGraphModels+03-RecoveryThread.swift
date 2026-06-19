import Foundation

struct RecoveryThread: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let goalThreadID: String?
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

    enum CodingKeys: String, CodingKey {
        case id
        case ambitionID
        case goalThreadID
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
        goalThreadID: String? = nil,
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
        self.goalThreadID = goalThreadID
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
        goalThreadID = try container.decodeIfPresent(String.self, forKey: .goalThreadID)
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

struct AmbitionGraphGoalThreadHierarchy: Codable, Sendable, Equatable, Hashable, Identifiable {
    let goalThread: GoalThread
    let ambitionReference: LifeGraphObjectReference
    let threadReference: LifeGraphObjectReference
    let goalReferences: [LifeGraphObjectReference]
    let commitmentReferences: [LifeGraphObjectReference]
    let stepReferences: [LifeGraphObjectReference]
    let proofReferences: [LifeGraphObjectReference]
    let receiptReferences: [LifeGraphObjectReference]

    var id: String { goalThread.id }

    init(
        goalThread: GoalThread,
        ambition: Ambition,
        commitments: [Commitment] = [],
        proofs: [Proof] = [],
        steps: [AmbitionGraphStep] = [],
        recoveryThreads: [RecoveryThread] = []
    ) {
        self.goalThread = goalThread
        ambitionReference = LifeGraphObjectReference(
            kind: .ambition,
            id: ambition.id,
            label: ambition.title,
            sourceDomain: .goals
        )
        threadReference = LifeGraphObjectReference(
            kind: .path,
            id: goalThread.id,
            parentContextID: goalThread.lifeAreaID ?? ambition.id,
            label: goalThread.name,
            sourceDomain: .goals
        )
        goalReferences = goalThread.goalIDs.map { goalID in
            LifeGraphObjectReference(
                kind: .goal,
                id: goalID,
                parentContextID: goalThread.id,
                label: goalID,
                sourceDomain: .goals
            )
        }
        commitmentReferences = commitments
            .filter { $0.goalThreadID == goalThread.id }
            .sorted(by: AmbitionGraphGoalThreadHierarchy.commitmentOrdering)
            .map { commitment in
                LifeGraphObjectReference(
                    kind: .commitment,
                    id: commitment.id,
                    parentContextID: goalThread.id,
                    label: commitment.minimumProofDescription ?? commitment.fitReason ?? commitment.expectedEffort ?? commitment.promisedFor ?? commitment.id,
                    sourceDomain: .commitment
                )
            }
        stepReferences = steps
            .filter { $0.goalThreadID == goalThread.id }
            .sorted(by: AmbitionGraphGoalThreadHierarchy.stepOrdering)
            .map { step in
                LifeGraphObjectReference(
                    kind: .step,
                    id: step.id,
                    parentContextID: goalThread.id,
                    label: step.name,
                    sourceDomain: .goalEngine
                )
            }
        proofReferences = proofs
            .filter { $0.goalThreadID == goalThread.id }
            .sorted(by: AmbitionGraphGoalThreadHierarchy.proofOrdering)
            .map { proof in
                LifeGraphObjectReference(
                    kind: .proof,
                    id: proof.id,
                    parentContextID: proof.commitmentID ?? goalThread.id,
                    label: proof.text ?? proof.source ?? proof.id,
                    sourceDomain: .proof
                )
            }
        receiptReferences = recoveryThreads
            .filter { $0.goalThreadID == goalThread.id && $0.receiptID != nil }
            .sorted(by: AmbitionGraphGoalThreadHierarchy.receiptOrdering)
            .compactMap { thread -> LifeGraphObjectReference? in
                guard let receiptID = thread.receiptID else { return nil }
                return LifeGraphObjectReference(
                    kind: .receipt,
                    id: receiptID,
                    parentContextID: thread.id,
                    label: thread.trigger,
                    sourceDomain: .receipt
                )
            }
    }

    var canonicalPath: [LifeGraphObjectReference] {
        [
            ambitionReference,
            threadReference,
            goalReferences.first,
            commitmentReferences.first,
            stepReferences.first,
            proofReferences.first,
            receiptReferences.first
        ]
        .compactMap { $0 }
    }

    var pathSummary: String {
        canonicalPath.map(\.displayLabel).joined(separator: " > ")
    }

    static func commitmentOrdering(_ lhs: Commitment, _ rhs: Commitment) -> Bool {
        if lhs.status.rawValue != rhs.status.rawValue {
            return lhs.status.rawValue < rhs.status.rawValue
        }
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        return lhs.id < rhs.id
    }

    static func stepOrdering(_ lhs: AmbitionGraphStep, _ rhs: AmbitionGraphStep) -> Bool {
        if lhs.targetOrder != rhs.targetOrder {
            return lhs.targetOrder < rhs.targetOrder
        }
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        return lhs.id < rhs.id
    }

    static func proofOrdering(_ lhs: Proof, _ rhs: Proof) -> Bool {
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt > rhs.createdAt
        }
        return lhs.id < rhs.id
    }

    static func receiptOrdering(_ lhs: RecoveryThread, _ rhs: RecoveryThread) -> Bool {
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        return lhs.id < rhs.id
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
