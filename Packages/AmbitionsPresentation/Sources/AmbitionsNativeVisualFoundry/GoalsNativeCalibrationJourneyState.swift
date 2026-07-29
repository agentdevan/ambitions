public enum GoalsNativeCalibrationRoute: Hashable, Sendable {
    case lifeArea(id: String)
    case focusedGoal(id: String)
    case relationship(primaryGoalID: String, relatedGoalID: String)
    case goalPath(id: String)
}

public enum GoalsNativeCalibrationFocusAnchor: String, Equatable, Sendable {
    case lifeArea
    case selectedGoal = "selected-goal"
    case linkedLens = "linked-lens"
    case focusedGoal = "focused-goal"
    case relationship
    case goalPath = "goal-path"
    case pathNode = "path-node"
}

public enum GoalsNativeCalibrationPathJump: String, CaseIterable, Equatable, Sendable {
    case start
    case now
    case next
    case finish
}

public struct GoalsNativeCalibrationJourneyState: Equatable, Sendable {
    public private(set) var selectedLifeAreaID: String
    public private(set) var selectedGoalID: String?
    public private(set) var isLinkedLensExpanded: Bool
    public private(set) var navigationPath: [GoalsNativeCalibrationRoute]
    public private(set) var selectedPathNodeID: String
    public private(set) var focusAnchor: GoalsNativeCalibrationFocusAnchor

    private let lifeAreaGoalIDs: [String: [String]]
    private let primaryGoalID: String
    private let relatedGoalID: String
    private let relationshipID: String
    private let goalPathID: String
    private let pathNodeIDs: [String]
    private let currentPathNodeID: String
    private let nextPathNodeID: String

    public init(
        content: GoalsNativeCalibrationContent,
        lensExpanded: Bool = false
    ) {
        selectedLifeAreaID = content.selectedLifeAreaID
        selectedGoalID = content.selectedGoalID
        isLinkedLensExpanded = lensExpanded
        navigationPath = []
        selectedPathNodeID = content.goalPath.currentNodeID
        focusAnchor = .lifeArea
        lifeAreaGoalIDs = Dictionary(
            uniqueKeysWithValues: content.lifeAreas.map { ($0.id, $0.goals.map(\.id)) }
        )
        primaryGoalID = content.primaryGoal.id
        relatedGoalID = content.relationship.relatedGoalID
        relationshipID = content.relationship.id
        goalPathID = content.goalPath.id
        pathNodeIDs = content.goalPath.nodes.map(\.id)
        currentPathNodeID = content.goalPath.currentNodeID
        nextPathNodeID = content.goalPath.nextNodeID
    }

    public var expandedLifeAreaIDs: [String] { [selectedLifeAreaID] }

    public var hasMutation: Bool { false }

    public func isLifeAreaExpanded(id: String) -> Bool {
        selectedLifeAreaID == id
    }

    public func isGoalSelected(id: String) -> Bool {
        selectedGoalID == id
    }

    @discardableResult
    public mutating func openLifeArea(id: String) -> Bool {
        guard lifeAreaGoalIDs[id] != nil, navigationPath.isEmpty else { return false }
        selectedLifeAreaID = id
        selectedGoalID = lifeAreaGoalIDs[id]?.contains(primaryGoalID) == true
            ? primaryGoalID
            : lifeAreaGoalIDs[id]?.first
        isLinkedLensExpanded = false
        navigationPath = [.lifeArea(id: id)]
        focusAnchor = .lifeArea
        return true
    }

    @discardableResult
    public mutating func selectLifeArea(id: String) -> Bool {
        openLifeArea(id: id)
    }

    @discardableResult
    public mutating func selectGoal(id: String) -> Bool {
        guard
            navigationPath == [.lifeArea(id: selectedLifeAreaID)],
            lifeAreaGoalIDs[selectedLifeAreaID]?.contains(id) == true
        else { return false }
        selectedGoalID = id
        isLinkedLensExpanded = false
        focusAnchor = .selectedGoal
        return true
    }

    @discardableResult
    public mutating func openLinkedLens() -> Bool {
        guard
            navigationPath == [.lifeArea(id: selectedLifeAreaID)],
            selectedGoalID == primaryGoalID
        else { return false }
        isLinkedLensExpanded = true
        focusAnchor = .linkedLens
        return true
    }

    @discardableResult
    public mutating func closeLinkedLens() -> Bool {
        guard
            navigationPath == [.lifeArea(id: selectedLifeAreaID)],
            isLinkedLensExpanded
        else { return false }
        isLinkedLensExpanded = false
        focusAnchor = .selectedGoal
        return true
    }

    @discardableResult
    public mutating func openSelectedGoal(id: String? = nil) -> Bool {
        let targetID = id ?? selectedGoalID
        guard
            navigationPath == [.lifeArea(id: selectedLifeAreaID)],
            selectedLifeAreaID == lifeAreaID,
            targetID == primaryGoalID,
            selectedGoalID == primaryGoalID
        else { return false }
        navigationPath.append(.focusedGoal(id: primaryGoalID))
        focusAnchor = .focusedGoal
        return true
    }

    @discardableResult
    public mutating func openRelationship() -> Bool {
        guard navigationPath == focusedGoalPath else { return false }
        navigationPath.append(
            .relationship(primaryGoalID: primaryGoalID, relatedGoalID: relatedGoalID)
        )
        focusAnchor = .relationship
        return true
    }

    @discardableResult
    public mutating func openGoalPath() -> Bool {
        guard navigationPath == focusedGoalPath else { return false }
        navigationPath.append(.goalPath(id: goalPathID))
        selectedPathNodeID = currentPathNodeID
        focusAnchor = .pathNode
        return true
    }

    @discardableResult
    public mutating func selectPathNode(id: String) -> Bool {
        guard
            navigationPath.last == .goalPath(id: goalPathID),
            pathNodeIDs.contains(id)
        else { return false }
        selectedPathNodeID = id
        focusAnchor = .pathNode
        return true
    }

    @discardableResult
    public mutating func jumpTo(_ jump: GoalsNativeCalibrationPathJump) -> Bool {
        let targetID: String
        switch jump {
        case .start:
            guard let first = pathNodeIDs.first else { return false }
            targetID = first
        case .now:
            targetID = currentPathNodeID
        case .next:
            targetID = nextPathNodeID
        case .finish:
            guard let last = pathNodeIDs.last else { return false }
            targetID = last
        }
        return selectPathNode(id: targetID)
    }

    public mutating func reconcileNavigationPath(_ path: [GoalsNativeCalibrationRoute]) {
        guard path != navigationPath else { return }
        guard isValidNavigationPath(path) else { return }

        let previousPath = navigationPath
        navigationPath = path

        switch path.last {
        case .lifeArea(id: let id):
            selectedLifeAreaID = id
            selectedGoalID = lifeAreaGoalIDs[id]?.contains(primaryGoalID) == true
                ? primaryGoalID
                : lifeAreaGoalIDs[id]?.first
            focusAnchor = previousPath.count > path.count ? .selectedGoal : .lifeArea
        case .focusedGoal:
            selectedGoalID = primaryGoalID
            focusAnchor = .focusedGoal
        case .relationship:
            focusAnchor = .relationship
        case .goalPath:
            selectedPathNodeID = currentPathNodeID
            focusAnchor = .pathNode
        case nil:
            focusAnchor = .lifeArea
        }
    }

    public var relationshipRouteID: String { relationshipID }

    private var lifeAreaID: String {
        lifeAreaGoalIDs.first { $0.value.contains(primaryGoalID) }?.key ?? selectedLifeAreaID
    }

    private var focusedGoalPath: [GoalsNativeCalibrationRoute] {
        [
            .lifeArea(id: lifeAreaID),
            .focusedGoal(id: primaryGoalID)
        ]
    }

    private func isValidNavigationPath(_ path: [GoalsNativeCalibrationRoute]) -> Bool {
        if path.isEmpty {
            return true
        }

        guard case let .lifeArea(id: areaID) = path[0] else { return false }
        guard lifeAreaGoalIDs[areaID] != nil else { return false }

        if path.count == 1 {
            return true
        }

        guard
            areaID == lifeAreaID,
            case let .focusedGoal(id: goalID) = path[1],
            goalID == primaryGoalID
        else { return false }

        if path.count == 2 {
            return true
        }

        guard path.count == 3 else { return false }
        switch path[2] {
        case let .relationship(primaryID, relatedID):
            return primaryID == primaryGoalID && relatedID == relatedGoalID
        case let .goalPath(pathID):
            return pathID == goalPathID
        case .lifeArea, .focusedGoal:
            return false
        }
    }
}

public enum GoalsNativeCalibrationLifeAreaPostureKind: Equatable, Sendable {
    case activeConstruction
    case protectedBalance
    case containedWork
}

public struct GoalsNativeCalibrationLifeAreaPosture: Equatable, Sendable {
    public let lifeAreaID: String
    public let kind: GoalsNativeCalibrationLifeAreaPostureKind
}

public struct GoalsNativeCalibrationRootPresentation: Equatable, Sendable {
    public let accessibilityScreenHeading = "Goals"
    public let selectedRootTitle = "Goals"
    public let rootOrder = ["Today", "Goals", "Time", "You"]
    public let globalActions = ["Search", "Capture"]
    public let lifeAreaIDs: [String]
    public let lifeAreaPostures: [GoalsNativeCalibrationLifeAreaPosture]
    public let visibleText: [String]

    public init(content: GoalsNativeCalibrationContent) {
        lifeAreaIDs = content.lifeAreas.map(\.id)
        lifeAreaPostures = content.lifeAreas.enumerated().map { index, area in
            let kind: GoalsNativeCalibrationLifeAreaPostureKind = switch index {
            case 0: .activeConstruction
            case 1: .protectedBalance
            default: .containedWork
            }
            return GoalsNativeCalibrationLifeAreaPosture(
                lifeAreaID: area.id,
                kind: kind
            )
        }
        visibleText = [content.presentContext]
            + content.lifeAreas.flatMap { [$0.title, $0.currentTruth] }
    }
}

public enum GoalsNativeCalibrationGoalAnchorRole: Equatable, Sendable {
    case pursuit
}

public enum GoalsNativeCalibrationCompactGoalInteractionRole: Equatable, Sendable {
    case opensFocusedGoal
    case inspectionOnly
}

public struct GoalsNativeCalibrationCompactGoalPresentation: Equatable, Sendable {
    public let id: String
    public let title: String
    public let acceptedTruth: String
    public let anchorRole: GoalsNativeCalibrationGoalAnchorRole
    public let proofFoundation: [String]
    public let currentMovement: String?
    public let interactionRole: GoalsNativeCalibrationCompactGoalInteractionRole
}

public struct GoalsNativeCalibrationHomePresentation: Equatable, Sendable {
    public let lifeAreaID: String
    public let lifeAreaTitle: String
    public let goalIDs: [String]
    public let supportedFocusedGoalIDs: [String]
    public let goals: [GoalsNativeCalibrationCompactGoalPresentation]

    public init(
        content: GoalsNativeCalibrationContent,
        lifeAreaID requestedLifeAreaID: String? = nil
    ) {
        let requestedLifeAreaID = requestedLifeAreaID ?? content.selectedLifeAreaID
        let lifeArea = content.lifeArea(id: requestedLifeAreaID)
        lifeAreaID = lifeArea?.id ?? requestedLifeAreaID
        lifeAreaTitle = lifeArea?.title ?? content.primaryGoal.lifeAreaTitle
        goalIDs = lifeArea?.goals.map(\.id) ?? []
        supportedFocusedGoalIDs = lifeArea?.goals.contains { $0.id == content.primaryGoal.id } == true
            ? [content.primaryGoal.id]
            : []
        goals = (lifeArea?.goals ?? []).map { goal in
            let isPrimary = goal.id == content.primaryGoal.id
            return GoalsNativeCalibrationCompactGoalPresentation(
                id: goal.id,
                title: goal.title,
                acceptedTruth: isPrimary
                    ? content.primaryGoal.currentAcceptedTruth
                    : goal.acceptedPosture,
                anchorRole: .pursuit,
                proofFoundation: isPrimary ? content.linkedLens.proofPosture : [],
                currentMovement: isPrimary ? content.primaryGoal.nextMeaningfulMovement : nil,
                interactionRole: isPrimary ? .opensFocusedGoal : .inspectionOnly
            )
        }
    }
}
