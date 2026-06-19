import Foundation

extension StepGraphCompiler {

    func edgeKind(
        for dependency: GoalCompiledPathDependency,
        stage: GoalCompiledPathStage
    ) -> StepGraphEdgeKind {
        switch (dependency.kind, stage.kind) {
        case (.stageOrdering, _):
            return .stageOrdering
        case (_, .firstProof):
            return .proofContinuity
        case (_, .reviewFinish):
            return .reviewClosure
        default:
            return .dependencyRequirement
        }
    }


    func graphShapeIssues(
        nodes: [StepGraphCompilerNode],
        edges: [StepGraphCompilerEdge]
    ) -> Set<StepGraphCompilerIssue> {
        var issues: Set<StepGraphCompilerIssue> = []
        if nodes.contains(where: { $0.kind == .installedStep }) == false {
            issues.insert(.missingInstalledStep)
        }
        if nodes.contains(where: { $0.kind == .proof }) == false {
            issues.insert(.missingProofNode)
        }
        if nodes.contains(where: { $0.kind == .review }) == false {
            issues.insert(.missingReviewNode)
        }
        if nodes.isEmpty || edges.isEmpty || nodes.contains(where: { $0.isInspectable == false }) {
            issues.insert(.opaqueGraph)
        }
        return issues
    }


    func makeSnapshot(
        input: StepGraphCompilerInput,
        selectedPathID: String,
        selectedCompiledCandidateID: String,
        nodes: [StepGraphCompilerNode],
        edges: [StepGraphCompilerEdge]
    ) -> StepGraphCompilerSnapshot {
        let nodeIDs = nodes.map(\.id).sorted()
        let edgeIDs = edges.map(\.id).sorted()
        let fingerprint = stableIdentifier(
            prefix: "step-graph.fingerprint",
            components: nodeIDs + edgeIDs + nodes.map(\.kind.rawValue)
        )
        return StepGraphCompilerSnapshot(
            id: stableIdentifier(
                prefix: "step-graph.snapshot",
                components: [input.goalReferenceID, selectedPathID, selectedCompiledCandidateID, fingerprint]
            ),
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            nodeIDs: nodeIDs,
            edgeIDs: edgeIDs,
            dependencyNodeIDs: nodes.filter { $0.kind == .dependency }.map(\.id).sorted(),
            proofNodeIDs: nodes.filter { $0.kind == .proof }.map(\.id).sorted(),
            reviewNodeIDs: nodes.filter { $0.kind == .review }.map(\.id).sorted(),
            fingerprint: fingerprint,
            localOnly: true
        )
    }


    func makeReceipt(
        input: StepGraphCompilerInput,
        selectedPathID: String,
        selectedCompiledCandidateID: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        inspectionRoute: String?,
        snapshot: StepGraphCompilerSnapshot?,
        issues: [StepGraphCompilerIssue]
    ) -> StepGraphCompilerReceipt? {
        guard
            issues.isEmpty,
            let graphReceiptID = input.graphReceiptID,
            let compiledAt = input.compiledAt,
            let replayTraceID,
            let inspectionRoute,
            let snapshot
        else {
            return nil
        }
        return StepGraphCompilerReceipt(
            id: graphReceiptID,
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            snapshotID: snapshot.id,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: normalizedIDs(receiptIDs + [graphReceiptID]),
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: inspectionRoute,
            compiledAt: compiledAt,
            localOnly: true
        )
    }


    func makeTrace(
        input: StepGraphCompilerInput,
        selectedPathID: String?,
        selectedCompiledCandidateID: String?,
        snapshot: StepGraphCompilerSnapshot?,
        edges: [StepGraphCompilerEdge],
        issues: [StepGraphCompilerIssue],
        replayTraceID: String?
    ) -> StepGraphCompilerTrace {
        StepGraphCompilerTrace(
            id: stableIdentifier(
                prefix: "step-graph.trace",
                components: [
                    input.goalReferenceID,
                    selectedPathID ?? "unselected",
                    selectedCompiledCandidateID ?? "missing-candidate",
                    snapshot?.id ?? "blocked",
                    issues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            graphSnapshotID: snapshot?.id,
            transitionIDs: edges.map(\.id).sorted(),
            issueIDs: issues.map(\.rawValue),
            replayTraceID: replayTraceID,
            localOnly: true
        )
    }


    func blockedRecord(
        input: StepGraphCompilerInput,
        selectedPathID: String?,
        selectedCompiledCandidateID: String?,
        issues: Set<StepGraphCompilerIssue>
    ) -> StepGraphCompilerRecord {
        let sortedIssues = sortedIssues(issues)
        let trace = makeTrace(
            input: input,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            snapshot: nil,
            edges: [],
            issues: sortedIssues,
            replayTraceID: nil
        )
        return StepGraphCompilerRecord(
            id: stableIdentifier(
                prefix: "step-graph.record",
                components: [
                    input.goalReferenceID,
                    selectedPathID ?? "unselected",
                    selectedCompiledCandidateID ?? "missing-candidate",
                    sortedIssues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            nodes: [],
            edges: [],
            snapshot: nil,
            receipt: nil,
            trace: trace,
            issues: sortedIssues
        )
    }


    func dependencyTitle(for dependency: GoalCompiledPathDependency) -> String {
        switch dependency.kind {
        case .stageOrdering:
            return "Stage order"
        case .readiness:
            return "Readiness dependency"
        case .support:
            return "Support dependency"
        case .timeline:
            return "Timeline dependency"
        case .knowledge:
            return "Knowledge dependency"
        }
    }


    func dependencyOrderIndex(
        for dependency: GoalCompiledPathDependency,
        stages: [GoalCompiledPathStage]
    ) -> Int {
        guard let relatedStageID = dependency.relatedStageID,
              let stage = stages.first(where: { $0.id == relatedStageID }) else {
            return Int.max
        }
        return stage.orderIndex
    }


    func nodeID(candidateID: String, token: String) -> String {
        stableIdentifier(prefix: "step-graph.node", components: [candidateID, token])
    }


    func dependencyNodeID(candidateID: String, token: String) -> String {
        stableIdentifier(prefix: "step-graph.dependency", components: [candidateID, token])
    }


    func dedupeEdges(_ edges: [StepGraphCompilerEdge]) -> [StepGraphCompilerEdge] {
        Array(Dictionary(uniqueKeysWithValues: edges.map { ($0.id, $0) }).values)
    }


    func hasCycle(edges: [StepGraphCompilerEdge], nodeIDs: [String]) -> Bool {
        var adjacency: [String: [String]] = [:]
        for edge in edges {
            adjacency[edge.fromNodeID, default: []].append(edge.toNodeID)
        }
        var visiting: Set<String> = []
        var visited: Set<String> = []

        func visit(_ nodeID: String) -> Bool {
            if visiting.contains(nodeID) {
                return true
            }
            if visited.contains(nodeID) {
                return false
            }
            visiting.insert(nodeID)
            for nextNodeID in adjacency[nodeID, default: []] {
                if visit(nextNodeID) {
                    return true
                }
            }
            visiting.remove(nodeID)
            visited.insert(nodeID)
            return false
        }

        for nodeID in nodeIDs.sorted() {
            if visit(nodeID) {
                return true
            }
        }
        return false
    }


    func sortedIssues(_ issues: Set<StepGraphCompilerIssue>) -> [StepGraphCompilerIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }


    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }


    func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }


    func stableIdentifier(prefix: String, components: [String]) -> String {
        let tokens = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0.isEmpty == false }
            .map { value in
                value.map { character -> Character in
                    character.isLetter || character.isNumber ? character : "-"
                }
            }
            .map { String($0).replacingOccurrences(of: "--+", with: "-", options: .regularExpression) }
        return ([prefix] + tokens).joined(separator: ".")
    }
}
