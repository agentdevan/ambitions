import Foundation

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
