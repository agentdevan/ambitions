import Foundation

extension SourceAtlasCapabilityPathComposer {

    func scorePath(
        graph: SourceAtlasCapabilityGraph,
        packID: String,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay],
        traversal: TraversalSnapshot,
        requirementProjection: SourceAtlasRequirementProjection,
        pathText: String
    ) -> Double {
        var score = 0.12
        score += min(0.18, Double(traversal.selectedNodeIDs.count) * 0.03)
        score += min(0.08, Double(traversal.selectedEdgeIDs.count) * 0.02)
        score += overlay.map { min(0.18, Double(max(0, $0.pathPriority)) * 0.03) } ?? 0.03
        score += match.matchedRoleIDs.isEmpty == false ? 0.04 : 0.0
        score += match.matchedSkillSliceIDs.isEmpty == false ? 0.04 : 0.0
        score += contextAlignmentScore(pathText: pathText, overlay: overlay, roleOverlays: roleOverlays)
        score += factorLedgerScore(pathText: pathText)
        score += requirementScore(requirementProjection: requirementProjection)
        score -= min(0.30, Double(traversal.blockedNodes.count) * 0.07)
        score -= min(0.12, Double(traversal.staleNodes.count) * 0.03)
        score -= min(0.18, Double(traversal.missingSourceNodes.count) * 0.06)
        score -= selection.rejectedPackIDs.contains(packID) ? 0.03 : 0.0
        return Self.clamp(score)
    }


    func candidateText(
        graph: SourceAtlasCapabilityGraph,
        pack: SourceAtlasPack,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay],
        traversal: TraversalSnapshot,
        requirementProjection: SourceAtlasRequirementProjection
    ) -> String {
        let nodesByID = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        let nodeText = traversal.selectedNodeIDs.compactMap { nodeID -> String? in
            guard let node = nodesByID[nodeID] else { return nil }
            return [node.title, node.summary].joined(separator: " ")
        }
        let overlayText = [
            graph.title,
            pack.manifest.title,
            overlay?.title ?? "",
            overlay?.skillSliceID ?? ""
        ]
        .filter { $0.isEmpty == false }

        return [
            overlayText.joined(separator: " "),
            roleOverlays.map { "\($0.roleID) \($0.skillSliceID)" }.joined(separator: " "),
            nodeText.joined(separator: " "),
            traversal.traversalTrace.joined(separator: " ")
        ]
        .joined(separator: " ")
    }


    func contextAlignmentScore(
        pathText: String,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay]
    ) -> Double {
        let candidateTokens = Self.tokens(pathText)
        let opportunityTokens = Self.tokens(lifeContextProjection.availableOpportunityAnchors.map(\.detail).joined(separator: " "))
        let hardConstraintTokens = Self.tokens(lifeContextProjection.hardConstraints.map(\.detail).joined(separator: " "))
        let softConstraintTokens = Self.tokens(lifeContextProjection.softConstraints.map(\.detail).joined(separator: " "))
        let eligibilityTokens = Self.tokens(
            lifeContextProjection.eligibilityModel.map { pathway in
                [
                    pathway.pathwayType.rawValue,
                    pathway.eligibilityRulesSummary,
                    pathway.gradeWindow ?? "",
                    pathway.sexLeaguePathway ?? "",
                    pathway.locationDependent ? "location dependent" : ""
                ].joined(separator: " ")
            }
            .joined(separator: " ")
        )

        let opportunityOverlap = Double(candidateTokens.intersection(opportunityTokens).count) * 0.025
        let constraintOverlap = Double(candidateTokens.intersection(hardConstraintTokens.union(softConstraintTokens)).count) * 0.02
        let eligibilityOverlap = Double(candidateTokens.intersection(eligibilityTokens).count) * 0.035
        let roleOverlap = Double(candidateTokens.intersection(Self.tokens(roleOverlays.map(\.roleID).joined(separator: " "))).count) * 0.02
        let overlayBonus = overlay.map { Self.tokens($0.title + " " + $0.skillSliceID).isDisjoint(with: candidateTokens) ? 0.0 : 0.05 } ?? 0.0

        var score = opportunityOverlap + constraintOverlap + eligibilityOverlap + roleOverlap + overlayBonus
        let opportunityText = lifeContextProjection.availableOpportunityAnchors
            .map { "\($0.title) \($0.detail)" }
            .joined(separator: " ")
            .lowercased()
        if opportunityText.contains("field") &&
            candidateTokens.contains("field") {
            score += 0.08
        }
        if opportunityText.contains("home") &&
            candidateTokens.contains("home") {
            score += 0.80
        }
        if lifeContextProjection.eligibilityModel.isEmpty == false && candidateTokens.contains("eligibility") {
            score += 0.1
        }
        if lifeContextProjection.eligibilityModel.isEmpty && candidateTokens.contains("eligibility") {
            score -= 0.35
        }
        if opportunityText.contains("field") == false &&
            (candidateTokens.contains("field") || candidateTokens.contains("travel")) {
            score -= 1.0
        }
        if lifeContextProjection.travelModel.transportationAccess == .car && candidateTokens.contains("travel") {
            score += 0.04
        }
        if lifeContextProjection.travelModel.transportationAccess == .parentGuardian || lifeContextProjection.travelModel.transportationAccess == .limited {
            if candidateTokens.contains("setup") || candidateTokens.contains("home") {
                score += 0.30
            }
            if candidateTokens.contains("field") || candidateTokens.contains("travel") {
                score -= 0.06
            }
        }
        if lifeContextProjection.hardConstraints.isEmpty == false && candidateTokens.contains("recovery") {
            score += 0.03
        }
        return score
    }


    func factorLedgerScore(pathText: String) -> Double {
        guard let factorLedger else {
            return 0.0
        }

        let candidateTokens = Self.tokens(pathText)
        var score = 0.0
        for factor in factorLedger.factors where factor.active && factor.allowedForRuntimeUse {
            let factorTokens = Self.tokens([
                factor.humanReadableReason,
                factor.affectedRecommendationArea,
                factor.freshness.lastAffectedLabel,
                factor.fallbackBehaviorIfRemoved,
                factor.source.sourceLabel
            ].joined(separator: " "))

            let overlap = Double(candidateTokens.intersection(factorTokens).count)
            if overlap > 0 {
                score += min(0.08, overlap * (0.015 + factor.runtimeWeight * 0.03))
            }
            switch factor.factorType {
            case .facilityAccess, .equipmentAccess:
                if candidateTokens.contains("facility") || candidateTokens.contains("equipment") || candidateTokens.contains("access") {
                    score += min(0.08, factor.runtimeWeight * 0.04)
                }
            case .eligibilityPathway:
                if candidateTokens.contains("eligibility") {
                    score += min(0.08, factor.runtimeWeight * 0.05)
                }
            case .recoveryConstraint:
                if candidateTokens.contains("recovery") {
                    score += min(0.06, factor.runtimeWeight * 0.04)
                }
            case .travelFit, .transportationConstraint:
                if candidateTokens.contains("travel") || candidateTokens.contains("field") {
                    score += min(0.06, factor.runtimeWeight * 0.035)
                }
            case .recentProof:
                if candidateTokens.contains("proof") || candidateTokens.contains("review") {
                    score += min(0.05, factor.runtimeWeight * 0.03)
                }
            default:
                break
            }
        }

        return score
    }


    func requirementScore(requirementProjection: SourceAtlasRequirementProjection) -> Double {
        var score = 0.0
        score += requirementProjection.hardRequirements.isEmpty == false ? 0.03 : 0.0
        score += requirementProjection.prerequisites.isEmpty == false ? 0.03 : 0.0
        score += requirementProjection.proofNeeds.isEmpty == false ? 0.03 : 0.0
        score -= requirementProjection.blockers.isEmpty == false ? 0.15 : 0.0
        score += requirementProjection.accelerators.isEmpty == false ? 0.02 : 0.0
        score += requirementProjection.deadlineSensitiveItems.isEmpty == false ? 0.02 : 0.0
        return score
    }


    func pathSummary(
        for graph: SourceAtlasCapabilityGraph,
        overlay: SourceAtlasPathOverlay?,
        traversal: TraversalSnapshot
    ) -> String {
        let overlayTitle = overlay?.title ?? graph.title
        let nodeCount = traversal.selectedNodeIDs.count
        let blockerCount = traversal.blockedNodes.count
        let staleCount = traversal.staleNodes.count
        let missingCount = traversal.missingSourceNodes.count
        return "\(overlayTitle) with \(nodeCount) nodes, \(blockerCount) blockers, \(staleCount) stale nodes, and \(missingCount) missing sources."
    }


    func pathID(
        for graph: SourceAtlasCapabilityGraph,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay]
    ) -> String {
        let overlayPart = overlay?.id ?? "graph-root"
        let rolePart = roleOverlays.map(\.id).joined(separator: ".")
        return Self.normalized(
            ["source-atlas-path", goalID.isEmpty ? match.normalizedGoalIntent : goalID, graph.id, overlayPart, rolePart]
        )
        .joined(separator: ".")
    }
}
