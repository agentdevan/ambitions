public enum GoalsNativeCalibrationRoute: Hashable, Sendable {
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
        focusAnchor = lensExpanded ? .linkedLens : .selectedGoal
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
    public mutating func selectLifeArea(id: String) -> Bool {
        guard lifeAreaGoalIDs[id] != nil, navigationPath.isEmpty else { return false }
        selectedLifeAreaID = id
        selectedGoalID = nil
        isLinkedLensExpanded = false
        focusAnchor = .lifeArea
        return true
    }

    @discardableResult
    public mutating func selectGoal(id: String) -> Bool {
        guard
            navigationPath.isEmpty,
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
            navigationPath.isEmpty,
            selectedGoalID == primaryGoalID
        else { return false }
        isLinkedLensExpanded = true
        focusAnchor = .linkedLens
        return true
    }

    @discardableResult
    public mutating func closeLinkedLens() -> Bool {
        guard navigationPath.isEmpty, isLinkedLensExpanded else { return false }
        isLinkedLensExpanded = false
        focusAnchor = .selectedGoal
        return true
    }

    @discardableResult
    public mutating func openSelectedGoal(id: String? = nil) -> Bool {
        let targetID = id ?? selectedGoalID
        guard
            navigationPath.isEmpty,
            targetID == primaryGoalID,
            selectedGoalID == primaryGoalID
        else { return false }
        navigationPath = [.focusedGoal(id: primaryGoalID)]
        focusAnchor = .focusedGoal
        return true
    }

    @discardableResult
    public mutating func openRelationship() -> Bool {
        guard navigationPath == [.focusedGoal(id: primaryGoalID)] else { return false }
        navigationPath.append(
            .relationship(primaryGoalID: primaryGoalID, relatedGoalID: relatedGoalID)
        )
        focusAnchor = .relationship
        return true
    }

    @discardableResult
    public mutating func openGoalPath() -> Bool {
        guard navigationPath == [.focusedGoal(id: primaryGoalID)] else { return false }
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

        switch (navigationPath, path) {
        case (
            [
                .focusedGoal(id: primaryGoalID),
                .relationship(primaryGoalID: primaryGoalID, relatedGoalID: relatedGoalID)
            ],
            [.focusedGoal(id: primaryGoalID)]
        ), (
            [.focusedGoal(id: primaryGoalID), .goalPath(id: goalPathID)],
            [.focusedGoal(id: primaryGoalID)]
        ):
            navigationPath = path
            focusAnchor = .focusedGoal
        case ([.focusedGoal(id: primaryGoalID)], []):
            navigationPath = []
            isLinkedLensExpanded = true
            focusAnchor = .linkedLens
        default:
            return
        }
    }

    public var relationshipRouteID: String { relationshipID }
}

public struct GoalsNativeCalibrationPresentation: Equatable, Sendable {
    public let accessibilityScreenHeading = "Goals"
    public let selectedRootTitle = "Goals"
    public let rootOrder = ["Today", "Goals", "Time", "You"]
    public let globalActions = ["Search", "Capture"]
    public let expandedLifeAreaIDs: [String]
    public let selectedGoalIDs: [String]
    public let attachedLensGoalIDs: [String]
    public let primaryActionTitle: String

    public init(
        content: GoalsNativeCalibrationContent,
        state: GoalsNativeCalibrationJourneyState
    ) {
        expandedLifeAreaIDs = state.expandedLifeAreaIDs
        selectedGoalIDs = state.selectedGoalID.map { [$0] } ?? []
        attachedLensGoalIDs = state.isLinkedLensExpanded ? [content.primaryGoal.id] : []
        primaryActionTitle = state.isLinkedLensExpanded
            ? content.linkedLens.openActionTitle
            : "Show Linked Goal Lens"
    }
}
