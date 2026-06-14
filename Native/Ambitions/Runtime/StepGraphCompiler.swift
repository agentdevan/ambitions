import Foundation

enum StepGraphNodeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case installedStep = "installed_step"
    case reserveStep = "reserve_step"
    case proof
    case review
    case dependency
}

enum StepGraphEdgeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case stageOrdering = "stage_ordering"
    case dependencyRequirement = "dependency_requirement"
    case proofContinuity = "proof_continuity"
    case reviewClosure = "review_closure"
}

enum StepGraphCompilerIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pathSelectionBlocked = "path_selection_blocked"
    case explicitSelectionRequired = "explicit_selection_required"
    case selectedPathMissing = "selected_path_missing"
    case selectedCompiledCandidateMissing = "selected_compiled_candidate_missing"
    case compiledCandidateBlocked = "compiled_candidate_blocked"
    case missingInstalledStep = "missing_installed_step"
    case missingProofNode = "missing_proof_node"
    case missingReviewNode = "missing_review_node"
    case unresolvedDependency = "unresolved_dependency"
    case dependencyCycle = "dependency_cycle"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case opaqueGraph = "opaque_graph"
    case hiddenMutationRisk = "hidden_mutation_risk"
}

struct StepGraphCompilerNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepGraphNodeKind
    let title: String
    let summary: String
    let pathID: String
    let candidateID: String
    let stageID: String?
    let dependencyID: String?
    let orderIndex: Int
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    var isInspectable: Bool {
        sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }
}

struct StepGraphCompilerEdge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepGraphEdgeKind
    let fromNodeID: String
    let toNodeID: String
    let summary: String
}

struct StepGraphCompilerSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String
    let selectedCompiledCandidateID: String
    let nodeIDs: [String]
    let edgeIDs: [String]
    let dependencyNodeIDs: [String]
    let proofNodeIDs: [String]
    let reviewNodeIDs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct StepGraphCompilerReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String
    let selectedCompiledCandidateID: String
    let snapshotID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let compiledAt: String
    let localOnly: Bool
}

struct StepGraphCompilerTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String?
    let selectedCompiledCandidateID: String?
    let graphSnapshotID: String?
    let transitionIDs: [String]
    let issueIDs: [String]
    let replayTraceID: String?
    let localOnly: Bool
}

struct StepGraphCompilerInput: Sendable, Equatable {
    let goalReferenceID: String
    let latticeRecord: MultiPathLatticeRecord
    let compiledPath: GoalCompiledPath
    let selectedCompiledCandidateID: String?
    let graphReceiptID: String?
    let compiledAt: String?

    init(
        goalReferenceID: String,
        latticeRecord: MultiPathLatticeRecord,
        compiledPath: GoalCompiledPath,
        selectedCompiledCandidateID: String? = nil,
        graphReceiptID: String?,
        compiledAt: String?
    ) {
        self.goalReferenceID = Self.normalizedID(goalReferenceID)
        self.latticeRecord = latticeRecord
        self.compiledPath = compiledPath
        self.selectedCompiledCandidateID = Self.normalizedOptional(selectedCompiledCandidateID)
        self.graphReceiptID = Self.normalizedOptional(graphReceiptID)
        self.compiledAt = Self.normalizedOptional(compiledAt)
    }

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct StepGraphCompilerRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String?
    let selectedCompiledCandidateID: String?
    let nodes: [StepGraphCompilerNode]
    let edges: [StepGraphCompilerEdge]
    let snapshot: StepGraphCompilerSnapshot?
    let receipt: StepGraphCompilerReceipt?
    let trace: StepGraphCompilerTrace
    let issues: [StepGraphCompilerIssue]

    var canDriveGraphCompilerSegment: Bool {
        issues.isEmpty && snapshot != nil && receipt != nil && nodes.allSatisfy(\.isInspectable)
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .graphCompiler,
            state: canDriveGraphCompilerSegment ? .ready : .blocked,
            sourceRecordIDs: receipt?.sourceRecordIDs ?? [],
            receiptIDs: receipt?.receiptIDs ?? [],
            replayTraceID: receipt?.replayTraceID,
            whatAmbitionsKnowsRoute: receipt?.whatAmbitionsKnowsRoute,
            isReversible: true,
            canDriveVisibleExecution: canDriveGraphCompilerSegment,
            blocksDownstream: canDriveGraphCompilerSegment == false
        )
    }
}

struct StepGraphCompiler: Sendable, Equatable {
    func compile(_ input: StepGraphCompilerInput) -> StepGraphCompilerRecord {
        let selectedPathID = input.latticeRecord.selectedPathID
        let selectedCompiledCandidateID = input.selectedCompiledCandidateID ?? selectedPathID
        let selectedLatticeCandidate = input.latticeRecord.candidates.first { $0.id == selectedPathID }
        let selectedCompiledCandidate = input.compiledPath.candidates.first { $0.id == selectedCompiledCandidateID }

        var issues: Set<StepGraphCompilerIssue> = []
        if input.latticeRecord.canDrivePathSelectionSegment == false {
            issues.insert(.pathSelectionBlocked)
        }
        if input.latticeRecord.issues.contains(.explicitSelectionRequired) || selectedPathID == nil {
            issues.insert(.explicitSelectionRequired)
        }
        if input.latticeRecord.issues.contains(.selectedPathMissing) || selectedLatticeCandidate == nil {
            issues.insert(.selectedPathMissing)
        }
        if selectedCompiledCandidate == nil {
            issues.insert(.selectedCompiledCandidateMissing)
        }
        if input.latticeRecord.issues.contains(.hiddenMutationRisk) {
            issues.insert(.hiddenMutationRisk)
        }

        guard
            let selectedPathID,
            let selectedCompiledCandidateID,
            let selectedLatticeCandidate,
            let selectedCompiledCandidate
        else {
            return blockedRecord(
                input: input,
                selectedPathID: selectedPathID,
                selectedCompiledCandidateID: selectedCompiledCandidateID,
                issues: issues
            )
        }

        if selectedCompiledCandidate.posture == .blocked ||
            selectedCompiledCandidate.safeForStarterPlanning == false ||
            input.compiledPath.overallPosture == .blocked ||
            input.compiledPath.safeForStarterPlanning == false {
            issues.insert(.compiledCandidateBlocked)
        }

        let sourceRecordIDs = normalizedIDs(
            selectedLatticeCandidate.sourceRecordIDs +
                selectedCompiledCandidate.dependencies.flatMap(\.sourceRecordIDs)
        )
        let receiptIDs = normalizedIDs(
            selectedLatticeCandidate.receiptIDs +
                [input.latticeRecord.selectionReceipt?.id, input.graphReceiptID].compactMap { $0 }
        )
        let replayTraceID = normalizedOptional(selectedLatticeCandidate.replayTraceID)
        let inspectionRoute = normalizedOptional(selectedLatticeCandidate.whatAmbitionsKnowsRoute)

        if selectedLatticeCandidate.sourceRecordIDs.isEmpty || sourceRecordIDs.isEmpty {
            issues.insert(.missingSourceRecord)
        }
        if selectedLatticeCandidate.receiptIDs.isEmpty || receiptIDs.isEmpty || input.graphReceiptID == nil {
            issues.insert(.missingReceipt)
        }
        if replayTraceID == nil {
            issues.insert(.missingReplayTrace)
        }
        if inspectionRoute == nil {
            issues.insert(.missingInspectionRoute)
        }

        let graph = makeGraph(
            selectedPathID: selectedPathID,
            candidate: selectedCompiledCandidate,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            inspectionRoute: inspectionRoute
        )
        issues.formUnion(graph.issues)

        let sortedIssues = sortedIssues(issues)
        let snapshot = sortedIssues.isEmpty ? makeSnapshot(
            input: input,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            nodes: graph.nodes,
            edges: graph.edges
        ) : nil
        let receipt = makeReceipt(
            input: input,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            inspectionRoute: inspectionRoute,
            snapshot: snapshot,
            issues: sortedIssues
        )
        let trace = makeTrace(
            input: input,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            snapshot: snapshot,
            edges: graph.edges,
            issues: sortedIssues,
            replayTraceID: replayTraceID
        )

        return StepGraphCompilerRecord(
            id: stableIdentifier(
                prefix: "step-graph.record",
                components: [
                    input.goalReferenceID,
                    selectedPathID,
                    selectedCompiledCandidateID,
                    snapshot?.id ?? "blocked",
                    sortedIssues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            selectedPathID: selectedPathID,
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            nodes: graph.nodes,
            edges: graph.edges,
            snapshot: snapshot,
            receipt: receipt,
            trace: trace,
            issues: sortedIssues
        )
    }

    private func makeGraph(
        selectedPathID: String,
        candidate: GoalCompiledPathCandidate,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        inspectionRoute: String?
    ) -> (
        nodes: [StepGraphCompilerNode],
        edges: [StepGraphCompilerEdge],
        issues: Set<StepGraphCompilerIssue>
    ) {
        let stages = candidate.stages.sorted { lhs, rhs in
            if lhs.orderIndex == rhs.orderIndex {
                return lhs.id < rhs.id
            }
            return lhs.orderIndex < rhs.orderIndex
        }
        let dependencies = Dictionary(uniqueKeysWithValues: candidate.dependencies.map { ($0.id, $0) })
        let stageIDs = Set(stages.map(\.id))
        let stageNodeIDs = Dictionary(uniqueKeysWithValues: stages.map {
            ($0.id, nodeID(candidateID: candidate.id, token: $0.id))
        })
        let dependencyNodeIDs = Dictionary(uniqueKeysWithValues: candidate.dependencies.map {
            ($0.id, dependencyNodeID(candidateID: candidate.id, token: $0.id))
        })

        var issues: Set<StepGraphCompilerIssue> = []
        var nodes: [StepGraphCompilerNode] = stages.map { stage in
            StepGraphCompilerNode(
                id: nodeID(candidateID: candidate.id, token: stage.id),
                kind: nodeKind(for: stage),
                title: stage.title,
                summary: stage.summary,
                pathID: selectedPathID,
                candidateID: candidate.id,
                stageID: stage.id,
                dependencyID: nil,
                orderIndex: stage.orderIndex,
                sourceRecordIDs: sourceRecordIDs,
                receiptIDs: receiptIDs,
                replayTraceID: replayTraceID,
                whatAmbitionsKnowsRoute: inspectionRoute
            )
        }

        nodes.append(contentsOf: candidate.dependencies.sorted { $0.id < $1.id }.map { dependency in
            StepGraphCompilerNode(
                id: dependencyNodeID(candidateID: candidate.id, token: dependency.id),
                kind: .dependency,
                title: dependencyTitle(for: dependency),
                summary: dependency.summary,
                pathID: selectedPathID,
                candidateID: candidate.id,
                stageID: dependency.relatedStageID,
                dependencyID: dependency.id,
                orderIndex: dependencyOrderIndex(for: dependency, stages: stages),
                sourceRecordIDs: normalizedIDs(sourceRecordIDs + dependency.sourceRecordIDs),
                receiptIDs: receiptIDs,
                replayTraceID: replayTraceID,
                whatAmbitionsKnowsRoute: inspectionRoute
            )
        })

        var edges: [StepGraphCompilerEdge] = []
        for pair in zip(stages, stages.dropFirst()) {
            guard let fromNodeID = stageNodeIDs[pair.0.id], let toNodeID = stageNodeIDs[pair.1.id] else {
                issues.insert(.unresolvedDependency)
                continue
            }
            edges.append(
                StepGraphCompilerEdge(
                    id: stableIdentifier(prefix: "step-graph.edge.stage", components: [candidate.id, pair.0.id, pair.1.id]),
                    kind: .stageOrdering,
                    fromNodeID: fromNodeID,
                    toNodeID: toNodeID,
                    summary: "\(pair.0.title) precedes \(pair.1.title)."
                )
            )
        }

        for stage in stages {
            guard let stageNodeID = stageNodeIDs[stage.id] else {
                issues.insert(.unresolvedDependency)
                continue
            }
            for dependencyID in normalizedIDs(stage.dependencyIDs) {
                guard let dependency = dependencies[dependencyID],
                      let dependencyNodeID = dependencyNodeIDs[dependencyID] else {
                    issues.insert(.unresolvedDependency)
                    continue
                }
                edges.append(
                    StepGraphCompilerEdge(
                        id: stableIdentifier(prefix: "step-graph.edge.dependency", components: [candidate.id, dependencyID, stage.id]),
                        kind: edgeKind(for: dependency, stage: stage),
                        fromNodeID: dependencyNodeID,
                        toNodeID: stageNodeID,
                        summary: dependency.summary
                    )
                )
                if let relatedStageID = dependency.relatedStageID,
                   relatedStageID != stage.id,
                   let relatedStageNodeID = stageNodeIDs[relatedStageID] {
                    edges.append(
                        StepGraphCompilerEdge(
                            id: stableIdentifier(prefix: "step-graph.edge.related-stage", components: [candidate.id, relatedStageID, stage.id, dependencyID]),
                            kind: .dependencyRequirement,
                            fromNodeID: relatedStageNodeID,
                            toNodeID: stageNodeID,
                            summary: "\(relatedStageID) must be inspectable before \(stage.id)."
                        )
                    )
                } else if let relatedStageID = dependency.relatedStageID, stageIDs.contains(relatedStageID) == false {
                    issues.insert(.unresolvedDependency)
                }
            }
        }

        let sortedNodes = nodes.sorted { lhs, rhs in
            if lhs.orderIndex == rhs.orderIndex {
                if lhs.kind.rawValue == rhs.kind.rawValue {
                    return lhs.id < rhs.id
                }
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.orderIndex < rhs.orderIndex
        }
        let sortedEdges = dedupeEdges(edges).sorted { $0.id < $1.id }
        issues.formUnion(graphShapeIssues(nodes: sortedNodes, edges: sortedEdges))
        if hasCycle(edges: sortedEdges, nodeIDs: sortedNodes.map(\.id)) {
            issues.insert(.dependencyCycle)
        }

        return (sortedNodes, sortedEdges, issues)
    }

    private func nodeKind(for stage: GoalCompiledPathStage) -> StepGraphNodeKind {
        switch stage.kind {
        case .setup:
            return .installedStep
        case .readiness, .advancement:
            return .reserveStep
        case .firstProof:
            return .proof
        case .reviewFinish:
            return .review
        }
    }

    private func edgeKind(
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

    private func graphShapeIssues(
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

    private func makeSnapshot(
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

    private func makeReceipt(
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

    private func makeTrace(
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

    private func blockedRecord(
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

    private func dependencyTitle(for dependency: GoalCompiledPathDependency) -> String {
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

    private func dependencyOrderIndex(
        for dependency: GoalCompiledPathDependency,
        stages: [GoalCompiledPathStage]
    ) -> Int {
        guard let relatedStageID = dependency.relatedStageID,
              let stage = stages.first(where: { $0.id == relatedStageID }) else {
            return Int.max
        }
        return stage.orderIndex
    }

    private func nodeID(candidateID: String, token: String) -> String {
        stableIdentifier(prefix: "step-graph.node", components: [candidateID, token])
    }

    private func dependencyNodeID(candidateID: String, token: String) -> String {
        stableIdentifier(prefix: "step-graph.dependency", components: [candidateID, token])
    }

    private func dedupeEdges(_ edges: [StepGraphCompilerEdge]) -> [StepGraphCompilerEdge] {
        Array(Dictionary(uniqueKeysWithValues: edges.map { ($0.id, $0) }).values)
    }

    private func hasCycle(edges: [StepGraphCompilerEdge], nodeIDs: [String]) -> Bool {
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

    private func sortedIssues(_ issues: Set<StepGraphCompilerIssue>) -> [StepGraphCompilerIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }

    private func stableIdentifier(prefix: String, components: [String]) -> String {
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
