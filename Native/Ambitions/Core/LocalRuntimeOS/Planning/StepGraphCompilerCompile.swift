import Foundation

extension StepGraphCompiler {
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


    func makeGraph(
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


    func nodeKind(for stage: GoalCompiledPathStage) -> StepGraphNodeKind {
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
}
