import Foundation

extension SourceAtlasCapabilityPathComposer {

    func buildPlanSkeleton(
        pathID: String,
        pathSummary: String,
        requirementProjection: SourceAtlasRequirementProjection,
        selectedNodeIDs: [String],
        blockedNodes: [String],
        staleNodes: [String],
        missingSourceNodes: [String],
        score: Double
    ) -> PlanSkeleton {
        let opportunityTokens = Self.tokens(
            lifeContextProjection.availableOpportunityAnchors
                .map { "\($0.title) \($0.detail)" }
                .joined(separator: " ")
        )
        let equipmentNeedsSetup = requirementProjection.equipment.contains { requirement in
            let requirementTokens = Self.tokens(requirement.title)
            return requirementTokens.isEmpty == false && requirementTokens.isSubset(of: opportunityTokens) == false
        }
        let setupNeeded = equipmentNeedsSetup || blockedNodes.isEmpty == false || missingSourceNodes.isEmpty == false
        let proofNeeded = requirementProjection.proofNeeds.isEmpty == false
        let reviewNeeded = staleNodes.isEmpty == false || requirementProjection.blockers.isEmpty == false
        let recoveryConstraintSummaries = lifeContextProjection.hardConstraints.filter {
            $0.title.localizedCaseInsensitiveContains("recovery") || $0.detail.localizedCaseInsensitiveContains("recovery")
        }
        let recoveryNeeded = recoveryConstraintSummaries.isEmpty == false || requirementProjection.blockers.isEmpty == false

        var milestones: [PlanSkeletonMilestone] = []
        var phases: [PlanSkeletonPhase] = []
        var proofMoments: [PlanSkeletonProofMoment] = []
        var reviewMoments: [PlanSkeletonReviewMoment] = []
        var recoveryWindows: [PlanSkeletonRecoveryWindow] = []
        var riskFlags: [PlanSkeletonRiskFlag] = []

        if setupNeeded {
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.setup",
                title: "Set up access and equipment",
                detail: requirementProjection.equipment.isEmpty ? "Make the path usable before execution." : requirementProjection.equipment.map(\.title).joined(separator: ", "),
                orderIndex: milestones.count,
                kind: .setup,
                requirementIDs: requirementProjection.equipment.map(\.id),
                nodeIDs: blockedNodes + missingSourceNodes,
                proofRequired: false,
                reviewRequired: false
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.setup",
                title: "Setup",
                detail: "Resolve setup work before the main path starts.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: blockedNodes + missingSourceNodes,
                riskFlagIDs: []
            ))
            riskFlags.append(PlanSkeletonRiskFlag(
                id: "\(pathID).risk.setup",
                title: "Setup risk",
                detail: "The current context does not fully support the path without setup work.",
                severity: 2,
                relatedNodeIDs: blockedNodes + missingSourceNodes,
                relatedRequirementIDs: requirementProjection.equipment.map(\.id)
            ))
        }

        milestones.append(PlanSkeletonMilestone(
            id: "\(pathID).milestone.execution",
            title: "Execute the selected path",
            detail: pathSummary,
            orderIndex: milestones.count,
            kind: .execution,
            requirementIDs: requirementProjection.skills.map(\.id) + requirementProjection.prerequisites.map(\.id) + requirementProjection.accelerators.map(\.id),
            nodeIDs: selectedNodeIDs,
            proofRequired: proofNeeded,
            reviewRequired: reviewNeeded
        ))
        phases.append(PlanSkeletonPhase(
            id: "\(pathID).phase.execution",
            title: "Execution",
            detail: "Follow the selected capability path.",
            orderIndex: phases.count,
            milestoneIDs: [milestones.last!.id],
            pathNodeIDs: selectedNodeIDs,
            riskFlagIDs: []
        ))

        if proofNeeded {
            let proofMoment = PlanSkeletonProofMoment(
                id: "\(pathID).proof",
                title: "Collect proof",
                detail: requirementProjection.proofNeeds.map(\.title).joined(separator: ", "),
                orderIndex: proofMoments.count,
                requirementIDs: requirementProjection.proofNeeds.map(\.id),
                nodeIDs: selectedNodeIDs
            )
            proofMoments.append(proofMoment)
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.proof",
                title: "Capture proof",
                detail: proofMoment.detail,
                orderIndex: milestones.count,
                kind: .proof,
                requirementIDs: proofMoment.requirementIDs,
                nodeIDs: proofMoment.nodeIDs,
                proofRequired: true,
                reviewRequired: reviewNeeded
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.proof",
                title: "Proof",
                detail: "Collect and preserve proof for the composed path.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: selectedNodeIDs,
                riskFlagIDs: []
            ))
        }

        if reviewNeeded {
            let reviewReason = staleNodes.isEmpty == false ? "Stale source needs review." : "A blocker or freshness issue needs review."
            let reviewMoment = PlanSkeletonReviewMoment(
                id: "\(pathID).review",
                title: "Review path freshness",
                detail: reviewReason,
                orderIndex: reviewMoments.count,
                requirementIDs: requirementProjection.blockers.map(\.id) + requirementProjection.proofNeeds.map(\.id),
                reason: reviewReason
            )
            reviewMoments.append(reviewMoment)
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.review",
                title: "Review the plan",
                detail: reviewMoment.detail,
                orderIndex: milestones.count,
                kind: .review,
                requirementIDs: reviewMoment.requirementIDs,
                nodeIDs: staleNodes,
                proofRequired: proofNeeded,
                reviewRequired: true
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.review",
                title: "Review",
                detail: "Review the path after setup or execution.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: staleNodes,
                riskFlagIDs: []
            ))
            riskFlags.append(PlanSkeletonRiskFlag(
                id: "\(pathID).risk.review",
                title: "Review risk",
                detail: reviewReason,
                severity: 1,
                relatedNodeIDs: staleNodes,
                relatedRequirementIDs: requirementProjection.blockers.map(\.id)
            ))
        }

        if recoveryNeeded {
            let recoveryWindow = PlanSkeletonRecoveryWindow(
                id: "\(pathID).recovery",
                title: "Protect recovery",
                detail: recoveryConstraintSummaries.isEmpty ? "Leave room for recovery." : recoveryConstraintSummaries.map { $0.detail }.joined(separator: ", "),
                orderIndex: recoveryWindows.count,
                protectsRecovery: true,
                relatedNodeIDs: selectedNodeIDs
            )
            recoveryWindows.append(recoveryWindow)
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.recovery",
                title: "Protect recovery",
                detail: recoveryWindow.detail,
                orderIndex: milestones.count,
                kind: .recovery,
                requirementIDs: requirementProjection.blockers.map(\.id),
                nodeIDs: selectedNodeIDs,
                proofRequired: false,
                reviewRequired: reviewNeeded
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.recovery",
                title: "Recovery",
                detail: "Preserve recovery after path work.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: selectedNodeIDs,
                riskFlagIDs: []
            ))
        }

        let focusDayLabels = lifeContextProjection.availableOpportunityAnchors.isEmpty
            ? ["midweek"]
            : lifeContextProjection.availableOpportunityAnchors.prefix(2).map(\.title)
        let weeklyCadence = PlanSkeletonWeeklyCadence(
            summary: weeklyCadenceSummary(pathSummary: pathSummary, score: score, setupNeeded: setupNeeded, proofNeeded: proofNeeded, reviewNeeded: reviewNeeded),
            anchorDays: focusDayLabels,
            proofTouchpoints: proofMoments.map(\.title),
            reviewTouchpoints: reviewMoments.map(\.title)
        )

        let feasibilityBand = feasibilityBand(
            score: score,
            blockedNodes: blockedNodes,
            staleNodes: staleNodes,
            missingSourceNodes: missingSourceNodes,
            setupNeeded: setupNeeded
        )

        if riskFlags.isEmpty {
            riskFlags.append(PlanSkeletonRiskFlag(
                id: "\(pathID).risk.base",
                title: "Path risk",
                detail: feasibilityBand.accessibilityLabel,
                severity: feasibilityBand == .impossibleUnderCurrentConstraints ? 3 : (feasibilityBand == .atRisk ? 2 : 0),
                relatedNodeIDs: selectedNodeIDs,
                relatedRequirementIDs: requirementProjection.requirementIDs
            ))
        }

        return PlanSkeleton(
            milestones: milestones,
            phases: phases,
            weeklyCadence: weeklyCadence,
            proofMoments: proofMoments,
            reviewMoments: reviewMoments,
            recoveryWindows: recoveryWindows,
            riskFlags: riskFlags.sorted { lhs, rhs in
                if lhs.severity != rhs.severity {
                    return lhs.severity > rhs.severity
                }
                return lhs.id < rhs.id
            },
            feasibilityBand: feasibilityBand
        )
    }


    func weeklyCadenceSummary(
        pathSummary: String,
        score: Double,
        setupNeeded: Bool,
        proofNeeded: Bool,
        reviewNeeded: Bool
    ) -> String {
        var parts: [String] = []
        parts.append(score >= 0.75 ? "Weekly cadence can stay steady." : "Weekly cadence should stay compact.")
        if setupNeeded {
            parts.append("Start with access or equipment setup.")
        }
        if proofNeeded {
            parts.append("Keep one proof touchpoint each week.")
        }
        if reviewNeeded {
            parts.append("Add a freshness review before the next sprint.")
        }
        return parts.joined(separator: " ")
    }


    func feasibilityBand(
        score: Double,
        blockedNodes: [String],
        staleNodes: [String],
        missingSourceNodes: [String],
        setupNeeded: Bool
    ) -> PlanSkeletonFeasibilityBand {
        let hardProblems = blockedNodes.count + missingSourceNodes.count
        if hardProblems >= 4 {
            return .impossibleUnderCurrentConstraints
        }
        if hardProblems >= 2 {
            return .unrealisticWithoutChangingScopeTimeCapacity
        }
        if score >= 0.82 && setupNeeded == false && staleNodes.isEmpty {
            return .comfortablyOnTrack
        }
        if score >= 0.66 && setupNeeded == false && staleNodes.count <= 1 {
            return .onTrack
        }
        if score >= 0.48 {
            return .tightButPossible
        }
        if score >= 0.32 {
            return .atRisk
        }
        return .unrealisticWithoutChangingScopeTimeCapacity
    }
}
