import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {
    func makeAtlasCard(
        from item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsAtlasSurfaceState {
        let posture = classifyPosture(for: item, snapshot: snapshot, learningSummary: learningSummary)
        let pathSummary = pathSummary(for: item, snapshot: snapshot)
        let phaseSummary = activeStageTitle(for: pathSummary)
            ?? item.shellSummary?.pathSummary
            ?? item.progressLabel
        let milestoneSummary = milestoneSummary(for: item, pathSummary: pathSummary)
        let sourceGoal = item.target.goalID.flatMap { goalID in snapshot.goals.first(where: { $0.id == goalID }) }
        let sourceDraft = item.target.draftID.flatMap { draftID in snapshot.drafts.first(where: { $0.id == draftID }) }
        let goalEvidence = item.target.goalID.map { goalID in snapshot.evidence.filter { $0.goalID == goalID } } ?? []
        let lifecycleState = portfolioLifecycleState(
            item: item,
            goal: sourceGoal,
            draft: sourceDraft,
            pathSummary: pathSummary,
            learningSummary: learningSummary,
            evidence: goalEvidence
        )
        let proofSummary = proofSummary(for: item, evidence: goalEvidence)
        let nextVisibleStep = nextVisibleStep(for: item, goal: sourceGoal, draft: sourceDraft)
        let weather = weatherState(
            lifecycleState: lifecycleState,
            posture: posture,
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            pathSummary: pathSummary
        )
        let momentumIntegrity = momentumIntegrity(
            lifecycleState: lifecycleState,
            posture: posture,
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            evidence: goalEvidence
        )

        return GoalsAtlasSurfaceState(
            id: item.id,
            target: item.target,
            title: item.title,
            subtitle: item.subtitle,
            modeLabel: item.modeLabel,
            posture: posture,
            renderState: item.renderState,
            progressValue: item.progressValue,
            progressLabel: item.progressLabel,
            timingLabel: item.timingLabel,
            weekRelationship: weekRelationship(for: item, learningSummary: learningSummary),
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            pressureSummary: pressureSummary(for: item, lifecycleState: lifecycleState, posture: posture, proofSummary: proofSummary, learningSummary: learningSummary),
            nextStepHint: item.nextStepHint,
            lifecycleState: lifecycleState,
            weather: weather,
            weatherSummary: weatherSummary(for: weather, lifecycleState: lifecycleState, posture: posture, proofSummary: proofSummary, nextVisibleStep: nextVisibleStep),
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            momentumIntegrity: momentumIntegrity,
            supportLabel: item.supportLabel,
            priorityLabel: directionLabel(for: item, lifecycleState: lifecycleState, posture: posture),
            manualPriorityRank: item.manualPriorityRank,
            shellSummary: item.shellSummary
        )
    }


    func makeBoardCard(
        from item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsBoardCardState {
        makeAtlasCard(from: item, snapshot: snapshot, learningSummary: learningSummary)
    }


    func classifyPosture(
        for item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsAtlasPosture {
        switch item.renderState {
        case .clarification, .blocked:
            return .atRisk
        case .onHold:
            return .lowerPriority
        case .achieved:
            return .achieved
        case .starter, .active:
            break
        }

        let freshnessWarning = item.shellSummary?.indicators.contains(where: { $0.kind == .freshness && $0.state == .warning }) == true
        let contradictionFlag = item.shellSummary?.indicators.contains(where: { $0.kind == .contradiction }) == true
        let pathSummary = pathSummary(for: item, snapshot: snapshot)
        let blockedPath = pathSummary?.blockedPrerequisites.isEmpty == false
            || (pathSummary?.readiness.gapCount ?? 0) > 0
        let timelineRisk = learningSummary?.timelineRisk.riskScore ?? 0
        let driftCount = learningSummary?.driftTriggers.count ?? 0

        if freshnessWarning || contradictionFlag || blockedPath {
            return .atRisk
        }

        if item.manualPriorityRank >= 2 && item.urgencyScore >= 0.48 && item.momentumScore <= 0.56 {
            return .crowded
        }

        if timelineRisk >= 0.85 {
            return .atRisk
        }

        if item.manualPriorityRank == 0 && driftCount == 0 && item.urgencyScore >= 0.55 {
            return .active
        }

        if item.momentumScore < 0.24 {
            return .stalled
        }

        if item.momentumScore < 0.42 && item.manualPriorityRank > 0 {
            return .stalled
        }

        if driftCount > 0 && item.progressValue < 0.35 {
            return .stalled
        }

        return .active
    }


    func pathSummary(for item: GoalListItem, snapshot: Snapshot) -> LifePathStateSummary? {
        pathSummary(for: item.target, snapshot: snapshot)
    }


    func pathSummary(for target: GoalRouteTarget, snapshot: Snapshot) -> LifePathStateSummary? {
        if let goalID = target.goalID,
           let goal = snapshot.goals.first(where: { $0.id == goalID }) {
            return LifeGraphResolver.pathStateSummary(for: goal)
        }

        if let draftID = target.draftID,
           let draft = snapshot.drafts.first(where: { $0.id == draftID }) {
            return LifeGraphResolver.pathStateSummary(for: draft.draft, plan: draft.stagedPlan)
        }

        return nil
    }


    func milestoneSummary(for item: GoalListItem, pathSummary: LifePathStateSummary?) -> String {
        if let pathSummary {
            let completed = pathSummary.progression.completedMilestoneIDs.count
            let total = pathSummary.progression.totalMilestoneCount
            if total > 0 {
                return "\(completed)/\(total) milestones visible"
            }
        }

        return item.progressLabel
    }


    func weekRelationship(for item: GoalListItem, learningSummary: GoalLearningSummary?) -> String {
        if item.renderState == .clarification || item.renderState == .blocked {
            return "This week needs a clarifying step before more planning."
        }

        if let risk = learningSummary?.timelineRisk.riskScore, risk >= 0.7 {
            return "This week is carrying real deadline pressure."
        }

        if item.manualPriorityRank == 0 {
            return "This week this goal is carrying the strongest directional weight."
        }

        if item.momentumScore >= 0.6 {
            return "This week momentum is visible and worth protecting."
        }

        if item.momentumScore < 0.4 {
            return "This week needs a small visible signal to stay alive."
        }

        return "This week can stay steady without opening more planning."
    }


    func pressureSummary(
        for item: GoalListItem,
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsAtlasPosture,
        proofSummary: GoalProofSummary,
        learningSummary: GoalLearningSummary?
    ) -> String {
        switch posture {
        case .atRisk:
            if lifecycleState == .blocked {
                return [learningSummary?.timelineRisk.reasons.first, item.shellSummary?.explanationSummary, "This goal is blocked and needs direct attention before progress can continue."]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            if lifecycleState == .waiting {
                return [learningSummary?.timelineRisk.reasons.first, item.shellSummary?.explanationSummary, "This goal is waiting on a readiness answer before the path is believable again."]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            return learningSummary?.timelineRisk.reasons.first
                ?? item.shellSummary?.explanationSummary
                ?? "Risk is high enough that this goal needs direct attention."
        case .crowded:
            return "This goal is still alive, but nearby priorities are compressing the attention it can hold."
        case .stalled:
            return learningSummary?.driftTriggers.first?.summary
                ?? "Recent movement is thin, so this goal is drifting and needs one visible signal."
        case .active:
            if proofSummary.count == 0 {
                return item.shellSummary?.explanationSummary
                    ?? "The path is live, but proof is still thin enough to deserve attention."
            }
            return item.shellSummary?.explanationSummary
                ?? "The path still has believable momentum."
        case .lowerPriority:
            return lifecycleState == .completed
                ? "This goal is completed and preserved in history."
                : "This goal is intentionally quieter right now."
        case .achieved:
            return "This loop is closed and no longer competing for attention."
        }
    }
}
