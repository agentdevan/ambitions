import Foundation

struct ProgressPreservationReport: Codable, Sendable, Equatable, Hashable {
    let graphID: String
    let preservedNodeIDs: [String]
    let proofBearingNodeIDs: [String]
    let activeNodeIDs: [String]
    let preservedDependencyIDs: [String]
    let summary: String
    let runtimeTrace: PlanningEngineRuntimeTrace

    var hasPreservedProgress: Bool {
        preservedNodeIDs.isEmpty == false || proofBearingNodeIDs.isEmpty == false || activeNodeIDs.isEmpty == false
    }
}

struct ProgressPreservationEngine: Sendable {
    func preserve(
        graph: PlanningGraph,
        completedNodeIDs: [String] = [],
        proofBearingNodeIDs: [String] = [],
        activeNodeIDs: [String] = []
    ) -> ProgressPreservationReport {
        let completedKeys = Set(normalized(completedNodeIDs))
        let proofKeys = Set(normalized(proofBearingNodeIDs))
        let activeKeys = Set(normalized(activeNodeIDs))
        let statePreserved = graph.nodes.filter { $0.state == .completed || $0.state == .preserved }

        let preserved = graph.nodes.filter { node in
            node.planningKeySet.contains(where: completedKeys.contains) ||
                node.planningKeySet.contains(where: proofKeys.contains) ||
                statePreserved.contains(where: { $0.id == node.id })
        }
        let active = graph.nodes.filter { node in
            node.planningKeySet.contains(where: activeKeys.contains)
        }
        let proof = graph.nodes.filter { node in
            node.proofRequired && node.planningKeySet.contains(where: proofKeys.contains)
        }
        let preservedIDs = preserved.map(\.id).removingDuplicates().sorted()
        let activeIDs = active.map(\.id).removingDuplicates().sorted()
        let proofIDs = proof.map(\.id).removingDuplicates().sorted()
        let protectedIDs = Set(preservedIDs + activeIDs + proofIDs)
        let dependencyIDs = graph.dependencies
            .filter { protectedIDs.contains($0.blockedNodeID) || protectedIDs.contains($0.requiredNodeID) }
            .map(\.id)
            .removingDuplicates()
            .sorted()
        let summary = Self.summary(
            preservedCount: preservedIDs.count,
            proofCount: proofIDs.count,
            activeCount: activeIDs.count,
            dependencyCount: dependencyIDs.count
        )
        let trace = PlanningEngineRuntimeTrace.make(
            owner: "ProgressPreservationEngine",
            generatedAt: graph.generatedAt,
            components: [
                graph.id,
                preservedIDs.joined(separator: ","),
                proofIDs.joined(separator: ","),
                activeIDs.joined(separator: ","),
                dependencyIDs.joined(separator: ",")
            ],
            localOnly: graph.localOnly
        )

        return ProgressPreservationReport(
            graphID: graph.id,
            preservedNodeIDs: preservedIDs,
            proofBearingNodeIDs: proofIDs,
            activeNodeIDs: activeIDs,
            preservedDependencyIDs: dependencyIDs,
            summary: summary,
            runtimeTrace: trace
        )
    }

    private func normalized(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    private static func summary(
        preservedCount: Int,
        proofCount: Int,
        activeCount: Int,
        dependencyCount: Int
    ) -> String {
        if preservedCount == 0 && proofCount == 0 && activeCount == 0 {
            return "No existing progress needs preservation."
        }
        return "Preserved \(preservedCount) completed, \(proofCount) proof-bearing, and \(activeCount) active planning nodes across \(dependencyCount) dependencies."
    }
}
