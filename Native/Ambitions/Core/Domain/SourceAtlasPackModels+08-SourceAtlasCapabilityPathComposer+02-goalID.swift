import Foundation

extension SourceAtlasCapabilityPathComposer {
    func compose() -> PersonalPathComposition {
        let selectedPacks = self.selectedPacks
        let candidatePaths = selectedPacks.flatMap { pack in
            pack.capabilityGraphs.flatMap { graph in
                composePaths(in: graph, pack: pack)
            }
        }
        .sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.id < rhs.id
        }

        let fallbackPath = SourceAtlasCapabilityPath(
            id: "source-atlas-path.\(goalID.isEmpty ? "goal" : goalID).fallback",
            capabilityGraphID: "source-atlas.graph.fallback",
            selectedNodeIDs: [],
            selectedEdgeIDs: [],
            selectedPathOverlayIDs: [],
            selectedRoleOverlayIDs: [],
            traversalTrace: ["No selected capability graph was available for composition."],
            blockedNodes: selection.rejectedPackIDs,
            staleNodes: [],
            missingSourceNodes: [],
            requirementProjection: SourceAtlasRequirementProjection(requirements: [], sourceFreshnessSummary: lifeContextProjection.sourceFreshnessSummary),
            score: 0,
            pathSummary: "Fallback path with no selected graph.",
            planSkeleton: buildPlanSkeleton(
                pathID: "source-atlas-path.\(goalID.isEmpty ? "goal" : goalID).fallback",
                pathSummary: "Fallback path with no selected graph.",
                requirementProjection: SourceAtlasRequirementProjection(requirements: [], sourceFreshnessSummary: lifeContextProjection.sourceFreshnessSummary),
                selectedNodeIDs: [],
                blockedNodes: selection.rejectedPackIDs,
                staleNodes: [],
                missingSourceNodes: [],
                score: 0
            )
        )

        let selectedPath = candidatePaths.first ?? fallbackPath
        let rejectedPaths = candidatePaths.dropFirst().map { $0 }
        let pathTradeoffs = rejectedPaths.map { rejectedPath in
            tradeoff(from: rejectedPath, against: selectedPath)
        }

        let alternativePathSet = candidatePaths.count > 1
            ? SourceAtlasAlternativePathSet(
                id: "source-atlas-alternatives.\(sourceAtlasProjectionID.isEmpty ? goalID : sourceAtlasProjectionID)",
                personalPathInstanceIDs: candidatePaths.map(\.id),
                sourceState: selectedPath.requirementProjection.hasBlockedItems ? .sourceNeeded : .officialCurrent,
                freshnessState: selectedPath.staleNodes.isEmpty ? .current : .stale,
                reviewState: selectedPath.planSkeleton.reviewMoments.isEmpty ? .approved : .required,
                riskState: selectedPath.planSkeleton.riskFlags.isEmpty ? .low : .high
            )
            : nil

        let explanationProjection = SourceAtlasPathCompositionExplanationProjection(
            summary: explanationSummary(for: selectedPath, alternatives: pathTradeoffs),
            sourceLabels: selectedPacks.map { "\($0.manifest.title) / \($0.manifest.id)" }.sorted(),
            whyThisChangesPlans: explanationReasons(for: selectedPath, alternatives: pathTradeoffs),
            confidenceLabel: selectedPath.planSkeleton.feasibilityBand.accessibilityLabel
        )

        return PersonalPathComposition(
            goalID: goalID.isEmpty ? match.normalizedGoalIntent : goalID,
            userContextVersion: userContextVersion,
            sourceAtlasProjectionID: sourceAtlasProjectionID.isEmpty ? selectedPath.id : sourceAtlasProjectionID,
            pathInstances: candidatePaths,
            alternativePathSet: alternativePathSet,
            selectedPath: selectedPath,
            rejectedPaths: rejectedPaths,
            pathTradeoffs: pathTradeoffs,
            explanationProjection: explanationProjection
        )
    }


    var selectedPacks: [SourceAtlasPack] {
        let selectedIDs = Set(selection.selectedPackIDs)
        let selected = packs.filter { selectedIDs.isEmpty || selectedIDs.contains($0.id) }
        return selected.isEmpty ? packs.filter { match.sourceAtlasPackIDs.contains($0.id) } : selected
    }


    func composePaths(in graph: SourceAtlasCapabilityGraph, pack: SourceAtlasPack) -> [SourceAtlasCapabilityPath] {
        let overlays = graph.ladders.flatMap(\.pathOverlays)
        let matchingOverlays = overlays.filter { overlay in
            overlayMatches(overlay, graph: graph)
        }
        let effectiveOverlays = matchingOverlays.isEmpty ? overlays.sorted { lhs, rhs in
            if lhs.pathPriority != rhs.pathPriority {
                return lhs.pathPriority > rhs.pathPriority
            }
            return lhs.id < rhs.id
        } : matchingOverlays.sorted { lhs, rhs in
            if lhs.pathPriority != rhs.pathPriority {
                return lhs.pathPriority > rhs.pathPriority
            }
            return lhs.id < rhs.id
        }

        let roleOverlays = graph.roleOverlays.filter { roleOverlay in
            roleOverlayMatches(roleOverlay, graph: graph)
        }

        if effectiveOverlays.isEmpty {
            return [buildPath(
                graph: graph,
                pack: pack,
                overlay: nil,
                roleOverlays: roleOverlays
            )]
        }

        return effectiveOverlays.map { overlay in
            buildPath(graph: graph, pack: pack, overlay: overlay, roleOverlays: roleOverlays)
        }
    }


    func overlayMatches(_ overlay: SourceAtlasPathOverlay, graph: SourceAtlasCapabilityGraph) -> Bool {
        let skillSliceIDs = match.matchedSkillSliceIDs.isEmpty ? graph.nodes.map(\.id) : match.matchedSkillSliceIDs
        let roleIDs = match.matchedRoleIDs.isEmpty ? [overlay.roleID].compactMap { $0 } : match.matchedRoleIDs

        for skillSliceID in skillSliceIDs {
            for roleID in roleIDs {
                if overlay.matches(skillSliceID: skillSliceID, roleID: roleID) {
                    return true
                }
            }
        }

        if overlay.capabilityNodeIDs.isEmpty == false && overlay.skillSliceID.isEmpty == false {
            return true
        }

        return match.matchedSkillSliceIDs.isEmpty && match.matchedRoleIDs.isEmpty
    }


    func roleOverlayMatches(_ roleOverlay: SourceAtlasRoleOverlay, graph: SourceAtlasCapabilityGraph) -> Bool {
        let skillSliceIDs = match.matchedSkillSliceIDs.isEmpty ? graph.nodes.map(\.id) : match.matchedSkillSliceIDs
        let roleIDs = match.matchedRoleIDs.isEmpty ? [roleOverlay.roleID] : match.matchedRoleIDs

        for skillSliceID in skillSliceIDs {
            for roleID in roleIDs {
                if roleOverlay.supports(skillSliceID: skillSliceID) && roleOverlay.roleID == roleID {
                    return true
                }
            }
        }

        return match.matchedSkillSliceIDs.isEmpty && match.matchedRoleIDs.isEmpty
    }


    func buildPath(
        graph: SourceAtlasCapabilityGraph,
        pack: SourceAtlasPack,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay]
    ) -> SourceAtlasCapabilityPath {
        let nodesByID = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        let edgesBySourceID = Dictionary(grouping: graph.edges, by: \.sourceNodeID)
        let overlayNodeIDs = overlay?.capabilityNodeIDs ?? []
        let seedNodeIDs = overlayNodeIDs.isEmpty
            ? Self.normalized(graph.capabilityNodeIDs + roleOverlays.flatMap(\.reusableNodeIDs))
            : overlayNodeIDs
        let allowedNodeIDs = overlayNodeIDs.isEmpty ? nil : Set(overlayNodeIDs)
        let traversal = traverse(
            graphID: graph.id,
            nodesByID: nodesByID,
            edgesBySourceID: edgesBySourceID,
            seedNodeIDs: seedNodeIDs,
            allowedNodeIDs: allowedNodeIDs
        )
        let requirementProjection = SourceAtlasRequirementProjection(
            requirements: pack.requirements,
            sourceFreshnessSummary: lifeContextProjection.sourceFreshnessSummary
        )
        let pathText = candidateText(
            graph: graph,
            pack: pack,
            overlay: overlay,
            roleOverlays: roleOverlays,
            traversal: traversal,
            requirementProjection: requirementProjection
        )
        let score = scorePath(
            graph: graph,
            packID: pack.id,
            overlay: overlay,
            roleOverlays: roleOverlays,
            traversal: traversal,
            requirementProjection: requirementProjection,
            pathText: pathText
        )
        let planSkeleton = buildPlanSkeleton(
            pathID: pathID(for: graph, overlay: overlay, roleOverlays: roleOverlays),
            pathSummary: pathSummary(for: graph, overlay: overlay, traversal: traversal),
            requirementProjection: requirementProjection,
            selectedNodeIDs: traversal.selectedNodeIDs,
            blockedNodes: traversal.blockedNodes,
            staleNodes: traversal.staleNodes,
            missingSourceNodes: traversal.missingSourceNodes,
            score: score
        )

        return SourceAtlasCapabilityPath(
            id: pathID(for: graph, overlay: overlay, roleOverlays: roleOverlays),
            capabilityGraphID: graph.id,
            selectedNodeIDs: traversal.selectedNodeIDs,
            selectedEdgeIDs: traversal.selectedEdgeIDs,
            selectedPathOverlayIDs: overlay.map { [$0.id] } ?? [],
            selectedRoleOverlayIDs: roleOverlays.map(\.id),
            traversalTrace: traversal.traversalTrace,
            blockedNodes: traversal.blockedNodes,
            staleNodes: traversal.staleNodes,
            missingSourceNodes: traversal.missingSourceNodes,
            requirementProjection: requirementProjection,
            score: score,
            pathSummary: pathSummary(for: graph, overlay: overlay, traversal: traversal),
            planSkeleton: planSkeleton
        )
    }


    func traverse(
        graphID: String,
        nodesByID: [String: SourceAtlasCapabilityNode],
        edgesBySourceID: [String: [SourceAtlasCapabilityEdge]],
        seedNodeIDs: [String],
        allowedNodeIDs: Set<String>?
    ) -> TraversalSnapshot {
        var selectedNodeIDs: [String] = []
        var selectedEdgeIDs: [String] = []
        var traversalTrace: [String] = []
        var blockedNodes: Set<String> = []
        var staleNodes: Set<String> = []
        var missingSourceNodes: Set<String> = []
        var visited: Set<String> = []
        var queue = seedNodeIDs

        if queue.isEmpty {
            queue = roots(in: nodesByID, edgesBySourceID: edgesBySourceID)
        }

        while queue.isEmpty == false {
            let currentNodeID = queue.removeFirst()
            guard visited.insert(currentNodeID).inserted else {
                continue
            }

            guard let node = nodesByID[currentNodeID] else {
                missingSourceNodes.insert(currentNodeID)
                traversalTrace.append("\(graphID): missing node \(currentNodeID)")
                continue
            }

            selectedNodeIDs.append(node.id)
            traversalTrace.append("\(graphID): node \(node.id) \(node.title)")
            if node.freshness != .current {
                staleNodes.insert(node.id)
            }
            if node.state.isBlockingState || node.reviewRequired {
                blockedNodes.insert(node.id)
            }

            for edge in edgesBySourceID[currentNodeID] ?? [] {
                if let allowedNodeIDs, allowedNodeIDs.contains(edge.targetNodeID) == false {
                    traversalTrace.append("\(graphID): skipped edge \(edge.id) \(edge.sourceNodeID)->\(edge.targetNodeID) outside selected path overlay")
                    continue
                }

                if nodesByID[edge.targetNodeID] == nil {
                    missingSourceNodes.insert(edge.targetNodeID)
                }
                if edge.freshness != .current {
                    staleNodes.insert(edge.id)
                }

                if edge.canTraverse(using: .conservativeFreshness, riskPolicy: .conservative) == false {
                    blockedNodes.insert(edge.targetNodeID)
                    traversalTrace.append("\(graphID): blocked edge \(edge.id) \(edge.sourceNodeID)->\(edge.targetNodeID)")
                    continue
                }

                selectedEdgeIDs.append(edge.id)
                traversalTrace.append("\(graphID): edge \(edge.id) \(edge.sourceNodeID)->\(edge.targetNodeID)")
                queue.append(edge.targetNodeID)
            }
        }

        let orderedNodeIDs = Self.orderedUniquePreservingOrder(selectedNodeIDs)
        let orderedEdgeIDs = Self.orderedUniquePreservingOrder(selectedEdgeIDs)
        let orderedTrace = Self.orderedUniquePreservingOrder(traversalTrace)
        return TraversalSnapshot(
            selectedNodeIDs: orderedNodeIDs,
            selectedEdgeIDs: orderedEdgeIDs,
            traversalTrace: orderedTrace,
            blockedNodes: Self.orderedUniquePreservingOrder(Array(blockedNodes)),
            staleNodes: Self.orderedUniquePreservingOrder(Array(staleNodes)),
            missingSourceNodes: Self.orderedUniquePreservingOrder(Array(missingSourceNodes))
        )
    }


    func roots(
        in nodesByID: [String: SourceAtlasCapabilityNode],
        edgesBySourceID: [String: [SourceAtlasCapabilityEdge]]
    ) -> [String] {
        let allTargetIDs = Set(edgesBySourceID.values.flatMap { $0.map(\.targetNodeID) })
        return nodesByID.values
            .filter { allTargetIDs.contains($0.id) == false }
            .sorted { lhs, rhs in
                if lhs.id != rhs.id {
                    return lhs.id < rhs.id
                }
                return lhs.title < rhs.title
            }
            .map(\.id)
    }
}
