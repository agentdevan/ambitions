public struct GoalsNativeCalibrationGoalSummary: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let acceptedPosture: String

    public init(id: String, title: String, acceptedPosture: String) {
        self.id = id
        self.title = title
        self.acceptedPosture = acceptedPosture
    }
}

public struct GoalsNativeCalibrationLifeArea: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let currentTruth: String
    public let goals: [GoalsNativeCalibrationGoalSummary]
    public let rank: Int?

    public init(
        id: String,
        title: String,
        currentTruth: String,
        goals: [GoalsNativeCalibrationGoalSummary],
        rank: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.currentTruth = currentTruth
        self.goals = goals
        self.rank = rank
    }
}

public struct GoalsNativeCalibrationGoal: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let lifeAreaID: String
    public let lifeAreaTitle: String
    public let currentDirection: String
    public let currentAcceptedTruth: String
    public let activeThread: String
    public let nextMeaningfulMovement: String
    public let followingMovement: String
    public let materialConsequence: String
    public let scheduleFit: String

    public init(
        id: String,
        title: String,
        lifeAreaID: String,
        lifeAreaTitle: String,
        currentDirection: String,
        currentAcceptedTruth: String,
        activeThread: String,
        nextMeaningfulMovement: String,
        followingMovement: String,
        materialConsequence: String,
        scheduleFit: String
    ) {
        self.id = id
        self.title = title
        self.lifeAreaID = lifeAreaID
        self.lifeAreaTitle = lifeAreaTitle
        self.currentDirection = currentDirection
        self.currentAcceptedTruth = currentAcceptedTruth
        self.activeThread = activeThread
        self.nextMeaningfulMovement = nextMeaningfulMovement
        self.followingMovement = followingMovement
        self.materialConsequence = materialConsequence
        self.scheduleFit = scheduleFit
    }
}

public struct GoalsNativeCalibrationLinkedLens: Equatable, Sendable {
    public let goalID: String
    public let currentTruth: String
    public let consequence: String
    public let activeThread: String
    public let nextMovement: String
    public let proofPosture: [String]
    public let openActionTitle: String

    public init(
        goalID: String,
        currentTruth: String,
        consequence: String,
        activeThread: String,
        nextMovement: String,
        proofPosture: [String],
        openActionTitle: String
    ) {
        self.goalID = goalID
        self.currentTruth = currentTruth
        self.consequence = consequence
        self.activeThread = activeThread
        self.nextMovement = nextMovement
        self.proofPosture = proofPosture
        self.openActionTitle = openActionTitle
    }
}

public struct GoalsNativeCalibrationRelationship: Equatable, Sendable {
    public let id: String
    public let primaryGoalID: String
    public let primaryGoalTitle: String
    public let ownerLifeAreaID: String
    public let ownerLifeAreaTitle: String
    public let relatedGoalID: String
    public let relatedGoalTitle: String
    public let relatedLifeAreaID: String
    public let relatedLifeAreaTitle: String
    public let meaning: String
    public let practicalConsequence: String

    public var consequence: String { meaning }
    public var protectedBoundary: String { practicalConsequence }

    public init(
        id: String,
        primaryGoalID: String,
        primaryGoalTitle: String,
        ownerLifeAreaID: String,
        ownerLifeAreaTitle: String,
        relatedGoalID: String,
        relatedGoalTitle: String,
        relatedLifeAreaID: String,
        relatedLifeAreaTitle: String,
        meaning: String,
        practicalConsequence: String
    ) {
        self.id = id
        self.primaryGoalID = primaryGoalID
        self.primaryGoalTitle = primaryGoalTitle
        self.ownerLifeAreaID = ownerLifeAreaID
        self.ownerLifeAreaTitle = ownerLifeAreaTitle
        self.relatedGoalID = relatedGoalID
        self.relatedGoalTitle = relatedGoalTitle
        self.relatedLifeAreaID = relatedLifeAreaID
        self.relatedLifeAreaTitle = relatedLifeAreaTitle
        self.meaning = meaning
        self.practicalConsequence = practicalConsequence
    }
}

public struct GoalsNativeCalibrationProofMoment: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public enum GoalsNativeCalibrationPathNodeState: String, Equatable, Sendable {
    case completed
    case settled
    case current
    case next
    case planned
    case conditional
    case finish

    public var label: String {
        switch self {
        case .completed: "Completed"
        case .settled: "Settled"
        case .current: "Current"
        case .next: "Next"
        case .planned: "Planned"
        case .conditional: "Conditional"
        case .finish: "Finish"
        }
    }
}

public struct GoalsNativeCalibrationPathNode: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let state: GoalsNativeCalibrationPathNodeState
    public let proof: [String]
    public let proofIDs: [String]
    public let detail: String

    public init(
        id: String,
        title: String,
        state: GoalsNativeCalibrationPathNodeState,
        proof: [String] = [],
        proofIDs: [String] = [],
        detail: String
    ) {
        self.id = id
        self.title = title
        self.state = state
        self.proof = proof
        self.proofIDs = proofIDs
        self.detail = detail
    }
}

public struct GoalsNativeCalibrationPath: Equatable, Identifiable, Sendable {
    public let id: String
    public let nodes: [GoalsNativeCalibrationPathNode]
    public let currentNodeID: String
    public let nextNodeID: String

    public init(
        id: String,
        nodes: [GoalsNativeCalibrationPathNode],
        currentNodeID: String,
        nextNodeID: String
    ) {
        self.id = id
        self.nodes = nodes
        self.currentNodeID = currentNodeID
        self.nextNodeID = nextNodeID
    }

    public func node(id: String) -> GoalsNativeCalibrationPathNode? {
        nodes.first { $0.id == id }
    }
}

public struct GoalsNativeCalibrationRecovery: Equatable, Identifiable, Sendable {
    public let id: String
    public let goalID: String
    public let interruptionFact: String
    public let retainedAcceptedTruth: String
    public let retainedProofIDs: [String]
    public let interruptedPathNodeID: String
    public let possibleNextPathNodeID: String
    public let unchangedPathStatement: String

    public init(
        id: String,
        goalID: String,
        interruptionFact: String,
        retainedAcceptedTruth: String,
        retainedProofIDs: [String],
        interruptedPathNodeID: String,
        possibleNextPathNodeID: String,
        unchangedPathStatement: String
    ) {
        self.id = id
        self.goalID = goalID
        self.interruptionFact = interruptionFact
        self.retainedAcceptedTruth = retainedAcceptedTruth
        self.retainedProofIDs = retainedProofIDs
        self.interruptedPathNodeID = interruptedPathNodeID
        self.possibleNextPathNodeID = possibleNextPathNodeID
        self.unchangedPathStatement = unchangedPathStatement
    }
}

public struct GoalsNativeCalibrationHistoryEntry: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String

    public init(id: String, title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}

public struct GoalsNativeCalibrationClosure: Equatable, Identifiable, Sendable {
    public let id: String
    public let goalID: String
    public let acceptedTruth: String
    public let relationshipResult: String
    public let remainingOpenItem: String
    public let proofIDs: [String]
    public let history: [GoalsNativeCalibrationHistoryEntry]
    public let isOutcomeAchieved: Bool
    public let isGoalClosed: Bool

    public init(
        id: String,
        goalID: String,
        acceptedTruth: String,
        relationshipResult: String,
        remainingOpenItem: String,
        proofIDs: [String],
        history: [GoalsNativeCalibrationHistoryEntry],
        isOutcomeAchieved: Bool,
        isGoalClosed: Bool
    ) {
        self.id = id
        self.goalID = goalID
        self.acceptedTruth = acceptedTruth
        self.relationshipResult = relationshipResult
        self.remainingOpenItem = remainingOpenItem
        self.proofIDs = proofIDs
        self.history = history
        self.isOutcomeAchieved = isOutcomeAchieved
        self.isGoalClosed = isGoalClosed
    }
}

public struct GoalsNativeCalibrationContent: Equatable, Sendable {
    public let familyID: String
    public let isSynthetic: Bool
    public let presentContext: String
    public let selectedLifeAreaID: String
    public let selectedGoalID: String
    public let lifeAreas: [GoalsNativeCalibrationLifeArea]
    public let primaryGoal: GoalsNativeCalibrationGoal
    public let linkedLens: GoalsNativeCalibrationLinkedLens
    public let relationship: GoalsNativeCalibrationRelationship
    public let goalPath: GoalsNativeCalibrationPath
    public let proofMoments: [GoalsNativeCalibrationProofMoment]
    public let recovery: GoalsNativeCalibrationRecovery
    public let closure: GoalsNativeCalibrationClosure

    public init(
        familyID: String,
        isSynthetic: Bool,
        presentContext: String,
        selectedLifeAreaID: String,
        selectedGoalID: String,
        lifeAreas: [GoalsNativeCalibrationLifeArea],
        primaryGoal: GoalsNativeCalibrationGoal,
        linkedLens: GoalsNativeCalibrationLinkedLens,
        relationship: GoalsNativeCalibrationRelationship,
        goalPath: GoalsNativeCalibrationPath,
        proofMoments: [GoalsNativeCalibrationProofMoment],
        recovery: GoalsNativeCalibrationRecovery,
        closure: GoalsNativeCalibrationClosure
    ) {
        self.familyID = familyID
        self.isSynthetic = isSynthetic
        self.presentContext = presentContext
        self.selectedLifeAreaID = selectedLifeAreaID
        self.selectedGoalID = selectedGoalID
        self.lifeAreas = lifeAreas
        self.primaryGoal = primaryGoal
        self.linkedLens = linkedLens
        self.relationship = relationship
        self.goalPath = goalPath
        self.proofMoments = proofMoments
        self.recovery = recovery
        self.closure = closure
    }

    public var visibleEvaluationText: [String] {
        [presentContext]
            + lifeAreas.flatMap { area in
                [area.title, area.currentTruth]
                    + area.goals.flatMap { [$0.title, $0.acceptedPosture] }
            }
            + [
                primaryGoal.title,
                primaryGoal.lifeAreaTitle,
                primaryGoal.currentDirection,
                primaryGoal.currentAcceptedTruth,
                primaryGoal.activeThread,
                primaryGoal.nextMeaningfulMovement,
                primaryGoal.followingMovement,
                primaryGoal.materialConsequence,
                primaryGoal.scheduleFit,
                linkedLens.consequence,
                linkedLens.openActionTitle,
                relationship.meaning,
                relationship.practicalConsequence
            ]
            + linkedLens.proofPosture
            + goalPath.nodes.flatMap { [$0.title, $0.state.label, $0.detail] + $0.proof }
            + proofMoments.map(\.title)
            + [
                recovery.interruptionFact,
                recovery.retainedAcceptedTruth,
                recovery.unchangedPathStatement,
                closure.acceptedTruth,
                closure.relationshipResult,
                closure.remainingOpenItem
            ]
            + closure.history.flatMap { [$0.title, $0.detail] }
    }

    public func lifeArea(id: String) -> GoalsNativeCalibrationLifeArea? {
        lifeAreas.first { $0.id == id }
    }

    public func goalSummary(id: String) -> GoalsNativeCalibrationGoalSummary? {
        lifeAreas.lazy.flatMap(\.goals).first { $0.id == id }
    }
}
