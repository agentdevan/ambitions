import Foundation

struct DependencyResolution: Codable, Sendable, Equatable, Hashable {
    let graphID: String
    let readyNodeIDs: [String]
    let blockedNodeIDs: [String]
    let completedNodeIDs: [String]
    let missingDependencyIDs: [String]
    let cyclicNodeIDs: [String]
    let topologicalOrder: [String]
    let runtimeTrace: PlanningRuntimeTrace

    var hasBlockingFailures: Bool {
        blockedNodeIDs.isEmpty == false || missingDependencyIDs.isEmpty == false || cyclicNodeIDs.isEmpty == false
    }
}

struct DependencyResolver: Sendable {
    func resolve(_ graph: PlanningGraph) -> DependencyResolution {
        let nodesByID = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        let dependencyMap = Dictionary(grouping: graph.dependencies.filter(\.blocking), by: \.blockedNodeID)
        let completed = graph.nodes
            .filter { $0.state.satisfiesDependency }
            .map(\.id)
            .sorted()
        let completedSet = Set(completed)
        let cyclic = cyclicNodeIDs(graph: graph, nodesByID: nodesByID)
        var ready: [String] = []
        var blocked: [String] = []
        var missing: [String] = []

        for node in graph.nodes {
            guard node.state.canBeScheduled else {
                if node.state == .blocked {
                    blocked.append(node.id)
                }
                continue
            }

            let dependencies = dependencyMap[node.id] ?? []
            let missingForNode = dependencies.filter { nodesByID[$0.requiredNodeID] == nil }
            missing.append(contentsOf: missingForNode.map { "\(node.id)->\($0.requiredNodeID)" })
            let unmet = dependencies.filter { completedSet.contains($0.requiredNodeID) == false }
            if missingForNode.isEmpty == false || unmet.isEmpty == false || cyclic.contains(node.id) {
                blocked.append(node.id)
            } else {
                ready.append(node.id)
            }
        }

        let order = topologicalOrder(graph: graph, nodesByID: nodesByID)
        let trace = PlanningRuntimeTrace.make(
            owner: "DependencyResolver",
            generatedAt: graph.generatedAt,
            components: [
                graph.id,
                ready.sorted().joined(separator: ","),
                blocked.sorted().joined(separator: ","),
                completed.joined(separator: ","),
                missing.sorted().joined(separator: ","),
                cyclic.sorted().joined(separator: ","),
                order.joined(separator: ",")
            ],
            localOnly: graph.localOnly
        )

        return DependencyResolution(
            graphID: graph.id,
            readyNodeIDs: ready.sorted(),
            blockedNodeIDs: blocked.removingDuplicates().sorted(),
            completedNodeIDs: completed,
            missingDependencyIDs: missing.removingDuplicates().sorted(),
            cyclicNodeIDs: cyclic.sorted(),
            topologicalOrder: order,
            runtimeTrace: trace
        )
    }

    private func topologicalOrder(
        graph: PlanningGraph,
        nodesByID: [String: PlanningGraphNode]
    ) -> [String] {
        var incoming: [String: Int] = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, 0) })
        var dependents: [String: [String]] = [:]
        for dependency in graph.dependencies where dependency.blocking && nodesByID[dependency.requiredNodeID] != nil {
            incoming[dependency.blockedNodeID, default: 0] += 1
            dependents[dependency.requiredNodeID, default: []].append(dependency.blockedNodeID)
        }

        var ready = graph.nodes
            .filter { incoming[$0.id, default: 0] == 0 }
            .sorted(by: graphSort)
        var output: [String] = []
        while ready.isEmpty == false {
            let node = ready.removeFirst()
            output.append(node.id)
            for dependentID in dependents[node.id, default: []].sorted() {
                incoming[dependentID, default: 0] -= 1
                if incoming[dependentID, default: 0] == 0, let dependent = nodesByID[dependentID] {
                    ready.append(dependent)
                    ready.sort(by: graphSort)
                }
            }
        }

        let remaining = graph.nodes
            .filter { output.contains($0.id) == false }
            .sorted(by: graphSort)
            .map(\.id)
        return output + remaining
    }

    private func cyclicNodeIDs(
        graph: PlanningGraph,
        nodesByID: [String: PlanningGraphNode]
    ) -> [String] {
        let dependencies = Dictionary(
            grouping: graph.dependencies.filter { $0.blocking && nodesByID[$0.requiredNodeID] != nil },
            by: \.blockedNodeID
        )
        var visiting: Set<String> = []
        var visited: Set<String> = []
        var cyclic: Set<String> = []

        func visit(_ nodeID: String, path: [String]) {
            if visiting.contains(nodeID) {
                cyclic.formUnion(path.drop { $0 != nodeID })
                cyclic.insert(nodeID)
                return
            }
            if visited.contains(nodeID) {
                return
            }
            visiting.insert(nodeID)
            for dependency in dependencies[nodeID, default: []] {
                visit(dependency.requiredNodeID, path: path + [dependency.requiredNodeID])
            }
            visiting.remove(nodeID)
            visited.insert(nodeID)
        }

        for node in graph.nodes.sorted(by: graphSort) {
            visit(node.id, path: [node.id])
        }
        return cyclic.sorted()
    }

    private func graphSort(lhs: PlanningGraphNode, rhs: PlanningGraphNode) -> Bool {
        if lhs.orderIndex != rhs.orderIndex { return lhs.orderIndex < rhs.orderIndex }
        return lhs.id < rhs.id
    }
}
