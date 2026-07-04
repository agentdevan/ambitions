import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func missionControlState(
        context: DetailContext,
        title: String,
        renderState: GoalRenderState,
        timing: GoalTiming,
        pathSummary: LifePathStateSummary?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        suggestions: [GoalDetailStepItem],
        evidenceItems: [GoalEvidenceItem],
        proofBeads: [ProofBead],
        feedbackItems: [GoalFeedbackItem],
        nextMovement: GoalDetailNextMovement?,
        trajectory: GoalDetailTrajectoryState,
        progressLabel: String,
        evidenceLabel: String,
        currentTruth: String
    ) -> GoalDetailMissionControlState {
        let nextStep = nextMovement.map {
            GoalNextVisibleStep(title: $0.title, detail: $0.summary, isAvailable: true)
        } ?? GoalNextVisibleStep(
            title: renderState == .blocked ? "Resolve the blocker" : "Needs a next step",
            detail: renderState == .blocked ? "The path should not add more work until this clears." : "Clarify one real step before adding more steps.",
            isAvailable: false
        )
        let proofSummary = goalDetailProofSummary(evidenceItems: evidenceItems, evidenceLabel: evidenceLabel)
        let riskItems = goalDetailRisks(
            context: context,
            renderState: renderState,
            pathSummary: pathSummary,
            suggestions: suggestions,
            evidenceItems: evidenceItems,
            timing: timing
        )
        let decisions = goalDetailDecisions(context: context, feedbackItems: feedbackItems)
        let risks = GoalDetailRisksState(
            title: "Risks",
            subtitle: riskItems.isEmpty ? "No major risk is visible from this goal data." : "Risks stay explicit so recovery can stay calm.",
            items: riskItems,
            emptyTitle: "No major risk visible",
            emptyMessage: "Nothing in this goal is asking for rescue right now."
        )
        let archive = goalDetailArchive(context: context, renderState: renderState, evidenceItems: evidenceItems, feedbackItems: feedbackItems, progressLabel: progressLabel)
        let currentPhase = pathStages.first(where: { $0.position == .current || $0.position == .blocked }) ?? pathStages.first
        let nextMilestone = pathSummary.flatMap(nextMilestoneTitle(for:)) ?? suggestions.first?.title ?? nextMovement?.title
        let pathDetail = currentPhase?.summary ?? trajectory.phaseSummary
        let riskHeadline = riskItems.first?.title ?? risks.emptyTitle
        let riskDetail = riskItems.first?.summary ?? risks.emptyMessage
        let decisionHeadline = decisions.items.first?.title ?? decisions.emptyTitle
        return GoalDetailMissionControlState(
            currentTruth: currentTruth,
            primaryNextMove: nextStep,
            sourceLabel: "Based on this goal",
            proofBoundaryLabel: evidenceItems.isEmpty ? "Proof is visible when saved" : "Proof stays attached to this goal",
            ownershipLabel: "You own the path",
            breadcrumb: goalDetailBreadcrumb(context: context, title: title),
            lanes: [
                GoalDetailMissionLaneState(
                    kind: .proof,
                    title: "Completed",
                    headline: proofSummary.latestTitle ?? proofSummary.title,
                    summary: proofSummary.detail,
                    detail: archive.learning.isEmpty
                        ? "Completed work stays attached as evidence, not as celebration."
                        : archive.learning,
                    badgeTitle: proofSummary.count == 0 ? "No evidence yet" : "Evidence visible",
                    systemImage: "checkmark.seal",
                    state: proofSummary.visualState
                ),
                GoalDetailMissionLaneState(
                    kind: .overview,
                    title: "Now",
                    headline: renderState.title,
                    summary: currentTruth,
                    detail: "Current path: \(currentPhase?.title ?? trajectory.phaseTitle).",
                    badgeTitle: currentPhase?.statusLabel ?? "Current",
                    systemImage: "scope",
                    state: renderState.visualState
                ),
                GoalDetailMissionLaneState(
                    kind: .risks,
                    title: "Friction",
                    headline: riskHeadline,
                    summary: riskDetail,
                    detail: riskItems.dropFirst().map(\.title).joined(separator: " · "),
                    badgeTitle: riskItems.isEmpty ? "Calm" : "Needs review",
                    systemImage: "exclamationmark.triangle",
                    state: riskItems.isEmpty ? .success : .warning
                ),
                GoalDetailMissionLaneState(
                    kind: .steps,
                    title: "Next",
                    headline: nextStep.title,
                    summary: nextStep.detail,
                    detail: nextStep.isAvailable ? "Keep this as the primary contained Step." : "This goal needs one safe next Step before the tactical list grows.",
                    badgeTitle: nextStep.isAvailable ? "Next step" : "Needs review",
                    systemImage: "arrow.right.circle",
                    state: nextStep.isAvailable ? .selected : .warning
                ),
                GoalDetailMissionLaneState(
                    kind: .path,
                    title: "Horizon",
                    headline: nextMilestone ?? currentPhase?.title ?? trajectory.phaseTitle,
                    summary: nextMilestone.map { "Next milestone: \($0)" } ?? "The route is still forming.",
                    detail: [
                        pathDetail,
                        "Decisions: \(decisionHeadline).",
                        "Horizon stays directional, not a rigid planning chart."
                    ].joined(separator: " "),
                    badgeTitle: "Direction",
                    systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                    state: currentPhase?.state ?? decisions.items.first?.state ?? .default
                )
            ],
            timeline: goalDetailTimeline(
                context: context,
                renderState: renderState,
                pathStages: pathStages,
                evidenceItems: evidenceItems,
                feedbackItems: feedbackItems,
                nextMovement: nextMovement,
                progressLabel: progressLabel
            ),
            assumptions: goalDetailAssumptions(
                context: context,
                renderState: renderState,
                timing: timing,
                evidenceItems: evidenceItems,
                suggestions: suggestions,
                risks: riskItems
            ),
            proofRail: GoalDetailProofRailState(
                title: "Evidence",
                subtitle: proofSummary.count == 0 ? "Evidence will appear here when it is recorded." : "Evidence keeps context, freshness, privacy, correction, and review visible.",
                items: evidenceItems,
                spineBeads: proofBeads,
                emptyTitle: "No evidence yet",
                emptyMessage: "Add evidence later when there is something real to show."
            ),
            decisions: decisions,
            risks: risks,
            archive: archive,
            receipts: GoalDetailReceiptsState(
                title: "What changed",
                subtitle: "Goal-related receipts stay visible here when the current data source provides them.",
                items: [],
                emptyTitle: "No receipts yet",
                emptyMessage: "Receipts will appear here after goal changes are recorded."
            )
        )
    }


    func goalDetailProofSummary(evidenceItems: [GoalEvidenceItem], evidenceLabel: String) -> GoalProofSummary {
        guard let latest = evidenceItems.first else {
            return GoalProofSummary(title: "No evidence yet", detail: "Needs evidence", count: 0, latestTitle: nil, visualState: .default)
        }
        return GoalProofSummary(
            title: evidenceItems.count == 1 ? "1 evidence item" : "\(evidenceItems.count) evidence items",
            detail: evidenceLabel,
            count: evidenceItems.count,
            latestTitle: latest.title,
            visualState: .selected
        )
    }


    func goalDetailBreadcrumb(context: DetailContext, title: String) -> GoalDetailBreadcrumbState {
        let graph = context.goal?.lifeGraph ?? context.draft?.draft.lifeGraph
        var labels: [String] = []
        if let domain = graph?.domains.max(by: { lhs, rhs in lhs.priority < rhs.priority })?.domain {
            labels.append(domain.lifeAreaDisplayName)
        }
        if let pathTitle = graph?.path?.title, pathTitle.isEmpty == false {
            labels.append(pathTitle)
        }
        labels.append(title)
        let compact = Array(labels.prefix(4))
        return GoalDetailBreadcrumbState(
            title: "Path",
            labels: compact.isEmpty ? [title] : compact,
            fallbackUsed: compact.count <= 1
        )
    }


    func goalDetailRisks(
        context: DetailContext,
        renderState: GoalRenderState,
        pathSummary: LifePathStateSummary?,
        suggestions: [GoalDetailStepItem],
        evidenceItems: [GoalEvidenceItem],
        timing: GoalTiming
    ) -> [GoalDetailRiskState] {
        var risks: [GoalDetailRiskState] = []
        if renderState == .blocked || context.draft?.blockers.isEmpty == false || pathSummary?.blockedPrerequisites.isEmpty == false {
            risks.append(GoalDetailRiskState(id: "risk-blocked", title: "Blocked", summary: "A blocker is visible, so the goal should not pretend to be moving normally.", state: .warning))
        }
        if pathSummary?.readiness.gapCount ?? 0 > 0 {
            risks.append(GoalDetailRiskState(id: "risk-waiting", title: "Waiting", summary: "One readiness gap needs an answer before the path is fully believable.", state: .warning))
        }
        if suggestions.isEmpty {
            risks.append(GoalDetailRiskState(id: "risk-next-step", title: "Needs a next step", summary: "The goal has no clear next step in the current plan.", state: .warning))
        }
        if evidenceItems.isEmpty {
            risks.append(GoalDetailRiskState(id: "risk-proof", title: "Proof is thin", summary: "No proof has been recorded yet.", state: .default))
        }
        if timing.dueAt != nil || timing.targetBy != nil {
            risks.append(GoalDetailRiskState(id: "risk-timing", title: "Timing needs review", summary: "The date is visible; keep the next step believable before adding more pressure.", state: .default))
        }
        return Array(risks.prefix(4))
    }


    func goalDetailDecisions(
        context: DetailContext,
        feedbackItems: [GoalFeedbackItem]
    ) -> GoalDetailDecisionsState {
        let items = feedbackItems.prefix(5).map { item in
            GoalDetailDecisionItemState(
                id: item.id,
                title: item.title,
                summary: item.subtitle,
                timestamp: item.timestamp,
                state: item.state
            )
        }

        let title = "Decisions"
        if items.isEmpty {
            return GoalDetailDecisionsState(
                title: title,
                subtitle: "Decision trail stays here when this goal changes.",
                items: [],
                emptyTitle: "No decisions yet",
                emptyMessage: context.goal == nil ? "Starter decisions will appear after this becomes an active goal." : "When you change, park, or explain this goal, the reason will stay visible here."
            )
        }

        return GoalDetailDecisionsState(
            title: title,
            subtitle: "\(items.count) goal decision\(items.count == 1 ? "" : "s") recorded from real history.",
            items: Array(items),
            emptyTitle: "No decisions yet",
            emptyMessage: "When this goal changes, the reason will stay visible here."
        )
    }


    func goalDetailArchive(
        context: DetailContext,
        renderState: GoalRenderState,
        evidenceItems: [GoalEvidenceItem],
        feedbackItems: [GoalFeedbackItem],
        progressLabel: String
    ) -> GoalDetailArchiveState {
        if renderState == .achieved || context.goal?.state == .completed {
            return GoalDetailArchiveState(
                title: "Completed",
                statusLabel: "Completed",
                summary: progressLabel,
                learning: evidenceItems.first.map { "Latest proof: \($0.title)" } ?? "Completion can still carry proof and reflection later.",
                state: .success
            )
        }

        if context.goal?.state == .archived {
            return GoalDetailArchiveState(
                title: "Archived",
                statusLabel: "Closed",
                summary: "This goal is closed without being treated as failure.",
                learning: feedbackItems.first.map { "Last change: \($0.title)" } ?? "Archive keeps the history available for later review.",
                state: .default
            )
        }

        if renderState == .onHold {
            return GoalDetailArchiveState(
                title: "Parked",
                statusLabel: "Review later",
                summary: "This goal is intentionally quiet for now.",
                learning: "Parking keeps the direction without forcing action today.",
                state: .default
            )
        }

        return GoalDetailArchiveState(
            title: "Archive ready",
            statusLabel: "Active",
            summary: "Archive learning will appear when this goal is parked, completed, or closed.",
            learning: "Nothing needs to be archived right now.",
            state: .selected
        )
    }
}
