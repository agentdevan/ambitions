import Foundation

enum PlanningGraphNodeState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case available
    case waiting
    case blocked
    case completed
    case cancelled
    case preserved

    var satisfiesDependency: Bool {
        switch self {
        case .completed, .preserved:
            return true
        case .available, .waiting, .blocked, .cancelled:
            return false
        }
    }

    var canBeScheduled: Bool {
        switch self {
        case .available, .waiting:
            return true
        case .blocked, .completed, .cancelled, .preserved:
            return false
        }
    }
}

struct PlanningGraphNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let stepID: String?
    let sourceCandidateID: String?
    let title: String
    let summary: String?
    let orderIndex: Int
    let state: PlanningGraphNodeState
    let estimatedMinutes: Int
    let proofRequired: Bool
    let dependencyIDs: [String]
    let tags: [String]

    init(
        id: String,
        stepID: String? = nil,
        sourceCandidateID: String? = nil,
        title: String,
        summary: String? = nil,
        orderIndex: Int,
        state: PlanningGraphNodeState = .available,
        estimatedMinutes: Int = 10,
        proofRequired: Bool = true,
        dependencyIDs: [String] = [],
        tags: [String] = []
    ) {
        self.id = Self.normalizedRequired(id)
        self.stepID = Self.normalizedOptional(stepID)
        self.sourceCandidateID = Self.normalizedOptional(sourceCandidateID)
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedOptional(summary)
        self.orderIndex = orderIndex
        self.state = state
        self.estimatedMinutes = max(1, estimatedMinutes)
        self.proofRequired = proofRequired
        self.dependencyIDs = Self.normalizedStrings(dependencyIDs)
        self.tags = Self.normalizedStrings(tags)
    }

    var planningKeySet: Set<String> {
        Set(([id] + [stepID, sourceCandidateID].compactMap { $0 }).filter { $0.isEmpty == false })
    }

    func replacingState(_ state: PlanningGraphNodeState) -> PlanningGraphNode {
        PlanningGraphNode(
            id: id,
            stepID: stepID,
            sourceCandidateID: sourceCandidateID,
            title: title,
            summary: summary,
            orderIndex: orderIndex,
            state: state,
            estimatedMinutes: estimatedMinutes,
            proofRequired: proofRequired,
            dependencyIDs: dependencyIDs,
            tags: tags
        )
    }

    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .compactMap { normalizedOptional($0) }
            .removingDuplicates()
            .sorted()
    }
}

struct PlanningGraphDependency: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let blockedNodeID: String
    let requiredNodeID: String
    let reason: String
    let blocking: Bool

    init(
        blockedNodeID: String,
        requiredNodeID: String,
        reason: String,
        blocking: Bool = true
    ) {
        self.blockedNodeID = PlanningGraphNode.normalizedRequired(blockedNodeID)
        self.requiredNodeID = PlanningGraphNode.normalizedRequired(requiredNodeID)
        self.reason = PlanningGraphNode.normalizedRequired(reason)
        self.blocking = blocking
        self.id = CandidateSource.stableIdentifier(
            prefix: "planning-dependency",
            components: [self.blockedNodeID, self.requiredNodeID, self.reason, blocking ? "blocking" : "advisory"]
        )
    }
}

struct PlanningGraph: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalID: String?
    let generatedAt: String
    let nodes: [PlanningGraphNode]
    let dependencies: [PlanningGraphDependency]
    let localOnly: Bool
    let runtimeTrace: PlanningRuntimeTrace

    init(
        goalID: String? = nil,
        generatedAt: String,
        nodes: [PlanningGraphNode],
        dependencies: [PlanningGraphDependency] = [],
        localOnly: Bool = true
    ) {
        self.goalID = PlanningGraphNode.normalizedOptional(goalID)
        self.generatedAt = PlanningGraphNode.normalizedRequired(generatedAt)
        let sortedNodes = nodes.sorted {
            if $0.orderIndex != $1.orderIndex { return $0.orderIndex < $1.orderIndex }
            return $0.id < $1.id
        }
        self.nodes = sortedNodes
        let derivedDependencies = sortedNodes.flatMap { node in
            node.dependencyIDs.map {
                PlanningGraphDependency(
                    blockedNodeID: node.id,
                    requiredNodeID: $0,
                    reason: "Declared dependency for \(node.title)."
                )
            }
        }
        self.dependencies = (dependencies + derivedDependencies)
            .removingDuplicateDependencies()
            .sorted {
                if $0.blockedNodeID != $1.blockedNodeID { return $0.blockedNodeID < $1.blockedNodeID }
                if $0.requiredNodeID != $1.requiredNodeID { return $0.requiredNodeID < $1.requiredNodeID }
                return $0.id < $1.id
            }
        self.localOnly = localOnly
        let graphFingerprint = CandidateSource.stableIdentifier(
            prefix: "planning-graph-source",
            components: [
                self.goalID ?? "unscoped",
                self.generatedAt,
                sortedNodes.map { "\($0.id):\($0.state.rawValue):\($0.orderIndex)" }.joined(separator: "|"),
                self.dependencies.map { "\($0.blockedNodeID)->\($0.requiredNodeID):\($0.blocking)" }.joined(separator: "|")
            ]
        )
        self.runtimeTrace = PlanningRuntimeTrace.make(
            owner: "PlanningGraph",
            generatedAt: self.generatedAt,
            components: [graphFingerprint],
            localOnly: localOnly
        )
        self.id = CandidateSource.stableIdentifier(
            prefix: "planning-graph",
            components: [self.goalID ?? "unscoped", self.generatedAt, graphFingerprint]
        )
    }

    var nodeIDs: [String] {
        nodes.map(\.id)
    }

    func node(id: String) -> PlanningGraphNode? {
        nodes.first { $0.id == id || $0.stepID == id || $0.sourceCandidateID == id }
    }

    func replacing(nodeStates: [String: PlanningGraphNodeState]) -> PlanningGraph {
        PlanningGraph(
            goalID: goalID,
            generatedAt: generatedAt,
            nodes: nodes.map { node in
                guard let state = nodeStates[node.id] ?? node.stepID.flatMap({ nodeStates[$0] }) else {
                    return node
                }
                return node.replacingState(state)
            },
            dependencies: dependencies,
            localOnly: localOnly
        )
    }

    static func make(
        goalID: String? = nil,
        generatedAt: String,
        steps: [PlanStep],
        localOnly: Bool = true
    ) -> PlanningGraph {
        PlanningGraph(
            goalID: goalID,
            generatedAt: generatedAt,
            nodes: steps.enumerated().map { index, step in
                PlanningGraphNode(
                    id: step.id,
                    stepID: step.id,
                    title: step.title,
                    summary: step.summary,
                    orderIndex: index,
                    estimatedMinutes: max(1, step.repeatEveryDays ?? 10),
                    proofRequired: step.evidenceHint != nil,
                    tags: [step.pace.rawValue, step.type.rawValue]
                )
            },
            localOnly: localOnly
        )
    }
}

private extension Array where Element == PlanningGraphDependency {
    func removingDuplicateDependencies() -> [PlanningGraphDependency] {
        var seen: Set<String> = []
        return filter { dependency in
            let key = "\(dependency.blockedNodeID)->\(dependency.requiredNodeID):\(dependency.reason):\(dependency.blocking)"
            return seen.insert(key).inserted
        }
    }
}
