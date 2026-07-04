import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func heroPrimaryAction(
        activeDirectionCards: [GoalsAtlasSurfaceState],
        pressuredCards: [GoalsAtlasSurfaceState],
        cards: [GoalsAtlasSurfaceState]
    ) -> GoalsAtlasPrimaryAction {
        if let atRisk = pressuredCards.first(where: { $0.posture == .atRisk }) {
            return GoalsAtlasPrimaryAction(
                kind: .recoverGoal,
                title: "Recover \(atRisk.title)",
                subtitle: atRisk.pressureSummary,
                systemImage: "lifepreserver",
                target: atRisk.target,
                state: .warning
            )
        }

        if let crowded = pressuredCards.first(where: { $0.posture == .crowded }) {
            return GoalsAtlasPrimaryAction(
                kind: .refineStrategy,
                title: "Refine \(crowded.title)",
                subtitle: crowded.weekRelationship,
                systemImage: "slider.horizontal.3",
                target: crowded.target,
                state: .selected
            )
        }

        if let primary = activeDirectionCards.first {
            return GoalsAtlasPrimaryAction(
                kind: .openGoal,
                title: "Open \(primary.title)",
                subtitle: primary.weekRelationship,
                systemImage: "arrow.up.right.circle",
                target: primary.target,
                state: .selected
            )
        }

        return GoalsAtlasPrimaryAction(
            kind: .createGoal,
            title: cards.isEmpty ? "Create your first goal" : "Create another goal",
            subtitle: "Start one live direction instead of growing a passive list.",
            systemImage: "plus.circle",
            target: nil,
            state: .selected
        )
    }


    func makeOrbitalLensState(
        lifeAreas: GoalsLifeAreasOverviewState,
        activeDirectionCards: [GoalsAtlasSurfaceState],
        pressuredCards: [GoalsAtlasSurfaceState],
        cards: [GoalsAtlasSurfaceState],
        heroPrimaryAction: GoalsAtlasPrimaryAction,
        seeded: Bool
    ) -> GoalsOrbitalLensState {
        let selectedArea = lifeAreas.items.first {
            $0.activeGoalCount > 0 || $0.parkedGoalCount > 0 || $0.goalThreadCount > 0 || $0.proofCount > 0 || $0.receiptCount > 0
        } ?? lifeAreas.items.first
        let selectedGoalIDs = Set(selectedArea?.goalReferences.map(\.id) ?? [])
        let areaCard = cards.first { card in
            guard let goalID = card.target.goalID else { return false }
            return selectedGoalIDs.contains(goalID)
        }
        let activeThread = areaCard ?? activeDirectionCards.first ?? pressuredCards.first ?? cards.first
        let recommendedStep = activeThread?.nextVisibleStep.title ?? heroPrimaryAction.title
        let proofCount = selectedArea?.proofCount ?? activeThread?.proofSummary.count ?? 0
        let receiptCount = selectedArea?.receiptCount ?? 0
        let proofSummary = proofCount > 0
            ? "Evidence visible: \(proofCount) saved item\(proofCount == 1 ? "" : "s") and \(receiptCount) change record\(receiptCount == 1 ? "" : "s") stay attached to this direction thread."
            : "Evidence light: the lens keeps context visible before asking for commitment."
        let sourceSummary = seeded
            ? "Context: preview Goals, drafts, evidence, and capture records."
            : "Context: local Goals, drafts, evidence, and capture records."
        let feedsToday = selectedArea?.todayTraceSummary ?? activeThread?.weekRelationship ?? "Feeds Today when this thread becomes the recommended step."
        let whyThis = activeThread?.pressureSummary ?? activeThread?.phaseSummary ?? "Thread Focus follows the clearest Life Area connection."
        let status = orbitalLensStatus(for: activeThread)
        let selectedLifeAreaTitle = selectedArea?.title ?? "No selected Life Area"
        let activeThreadTitle = activeThread?.title ?? "No active thread yet"

        return GoalsOrbitalLensState(
            title: "Thread Focus",
            collapsedSummary: "\(selectedLifeAreaTitle) / \(activeThreadTitle)",
            selectedLifeAreaTitle: selectedLifeAreaTitle,
            selectedLifeAreaSummary: selectedArea?.subtitle ?? "The lens will attach once a Life Area has source.",
            activeThreadTitle: activeThreadTitle,
            recommendedStepTitle: recommendedStep,
            feedsTodaySummary: feedsToday,
            proofSummary: proofSummary,
            sourceSummary: sourceSummary,
            whyThisSummary: whyThis,
            statusSummary: status,
            openThreadLabel: selectedArea?.openThreadLabel ?? (activeThread == nil ? "Open thread when ready" : "Open thread"),
            target: activeThread?.target,
            accessibilityLabel: "Thread Focus",
            accessibilityValue: "\(selectedLifeAreaTitle). \(activeThreadTitle). \(feedsToday). \(proofSummary). \(sourceSummary). \(whyThis). \(status).",
            accessibilityHint: "Expands proof, source, Today trace, and status while staying attached to Your Direction."
        )
    }


    func orbitalLensStatus(for card: GoalsAtlasSurfaceState?) -> String {
        guard let card else { return "Quiet" }

        switch card.lifecycleState {
        case .waiting:
            return "Waiting"
        case .blocked:
            return "Blocked"
        case .parked, .passive:
            return "Waiting"
        default:
            break
        }

        switch card.posture {
        case .atRisk, .stalled:
            return "Needs recovery"
        case .crowded:
            return "Needs recovery"
        default:
            return card.lifecycleState.title
        }
    }


    func makeHorizonLadder(
        activeDirectionCards: [GoalsAtlasSurfaceState],
        pressuredCards: [GoalsAtlasSurfaceState],
        snapshot: Snapshot
    ) -> GoalsHorizonLadderState {
        let sources = Array((activeDirectionCards + pressuredCards).prefix(4))
        let rungs = sources.compactMap { card -> GoalsHorizonLadderRung? in
            let pathSummary = pathSummary(for: card.target, snapshot: snapshot)
            let completedMilestones = pathSummary?.progression.completedMilestoneIDs.count ?? 0
            let totalMilestones = pathSummary?.progression.totalMilestoneCount ?? 0
            let activeStageTitle = activeStageTitle(for: pathSummary) ?? card.phaseSummary
            let highlight = nextMilestoneTitle(for: pathSummary) ?? card.nextStepHint
            let signalLabel: String
            let state: AmbitionVisualState

            if pathSummary?.blockedPrerequisites.isEmpty == false || (pathSummary?.readiness.gapCount ?? 0) > 0 {
                signalLabel = "Blocked signal visible"
                state = .warning
            } else if card.posture == .atRisk {
                signalLabel = "Pressure is high"
                state = .warning
            } else if card.posture == .active {
                signalLabel = "Path is moving"
                state = .selected
            } else {
                signalLabel = "Needs a smaller step"
                state = .default
            }

            return GoalsHorizonLadderRung(
                id: card.id,
                target: card.target,
                title: card.title,
                summary: activeStageTitle,
                milestoneLabel: totalMilestones > 0 ? "\(completedMilestones)/\(totalMilestones) milestones" : card.milestoneSummary,
                signalLabel: signalLabel,
                highlight: highlight,
                state: state
            )
        }

        return GoalsHorizonLadderState(
            title: "Horizon ladder",
            subtitle: "A shallow read on where the live goals sit in their current phase or path without opening Goal Detail.",
            rungs: rungs
        )
    }


    func makeLifecycleRail(cards: [GoalsAtlasSurfaceState]) -> [GoalLifecycleRailSegment] {
        let previousCount = cards.filter { [.completed, .cancelledDropped, .previous, .parked].contains($0.lifecycleState) }.count
        let activeCount = cards.filter(\.lifecycleState.isCurrentPortfolioState).count
        let futureCount = cards.filter { $0.lifecycleState == .future }.count

        return [
            GoalLifecycleRailSegment(
                id: "previous",
                title: "Previous",
                count: previousCount,
                subtitle: previousCount == 0 ? "History will stay visible here" : "Closed, parked, or transformed",
                state: .default
            ),
            GoalLifecycleRailSegment(
                id: "active",
                title: "Active",
                count: activeCount,
                subtitle: activeCount == 0 ? "No live pursuit right now" : "Currently shaping attention",
                state: activeCount == 0 ? .default : .selected
            ),
            GoalLifecycleRailSegment(
                id: "future",
                title: "Future",
                count: futureCount,
                subtitle: futureCount == 0 ? "No scheduled future goals" : "Planned, not active yet",
                state: .default
            )
        ]
    }


    func makeStateChips(cards: [GoalsAtlasSurfaceState]) -> [GoalStateChipState] {
        let chipStates: [GoalPortfolioLifecycleState] = [.protected, .waiting, .blocked, .parked, .completed, .cancelledDropped]
        return chipStates.map { state in
            GoalStateChipState(lifecycleState: state, count: cards.filter { $0.lifecycleState == state }.count)
        }
    }


    func makeArchiveSummary(cards: [GoalsAtlasSurfaceState]) -> GoalPortfolioArchiveSummary {
        let archiveChips = makeStateChips(cards: cards).filter {
            [.parked, .completed, .cancelledDropped].contains($0.lifecycleState)
        }
        let count = archiveChips.map(\.count).reduce(0, +)
        let learningLines = archiveLearningLines(cards: cards)
        return GoalPortfolioArchiveSummary(
            title: count == 0 ? "Archive is quiet" : "\(count) goals in archive states",
            subtitle: count == 0
                ? "Completed, parked, and cancelled goals will remain part of your progress history."
                : "Completed, parked, and cancelled goals are preserved without being treated as failure.",
            chips: archiveChips,
            learningLines: learningLines
        )
    }


    func makePortfolioMaturitySummary(
        cards: [GoalsAtlasSurfaceState],
        oneStepGoals: [OneStepGoal],
        archiveSummary: GoalPortfolioArchiveSummary
    ) -> GoalPortfolioMaturitySummary {
        let liveCards = cards.filter { $0.lifecycleState.isCurrentPortfolioState || $0.renderState == .starter }
        let prooflessLiveCount = liveCards.filter { $0.proofSummary.count == 0 }.count
        let blockedOrWaitingCount = liveCards.filter { [.blocked, .waiting].contains($0.lifecycleState) }.count
        let crowdedOrStalledCount = liveCards.filter { [.crowded, .stalled, .atRisk].contains($0.posture) }.count
        let missingNextStepCount = liveCards.filter { $0.nextVisibleStep.isAvailable == false }.count
        let openOneStepCount = oneStepGoals.filter(\.status.isOpen).count

        let scopeSignal = GoalPortfolioMaturitySignal(
            id: "scope",
            title: liveCards.count <= 3 ? "Scope is readable" : "Scope needs review",
            detail: liveCards.count <= 3
                ? "\(liveCards.count) live ambitions are competing for attention."
                : "\(liveCards.count) live ambitions are active; choose what should stay protected.",
            state: liveCards.count <= 3 ? .selected : .warning
        )
        let stuckWorkSignal = GoalPortfolioMaturitySignal(
            id: "stuck-work",
            title: blockedOrWaitingCount + crowdedOrStalledCount == 0 ? "No stuck work is loud" : "Stuck work is visible",
            detail: stuckWorkDetail(
                blockedOrWaitingCount: blockedOrWaitingCount,
                crowdedOrStalledCount: crowdedOrStalledCount,
                openOneStepCount: openOneStepCount
            ),
            state: blockedOrWaitingCount + crowdedOrStalledCount == 0 ? .selected : .warning
        )
        let proofSignal = GoalPortfolioMaturitySignal(
            id: "proof",
            title: prooflessLiveCount == 0 ? "Evidence is visible" : "Evidence is thin",
            detail: prooflessLiveCount == 0
                ? "Live ambitions have evidence or history attached."
                : "\(prooflessLiveCount) live ambitions need evidence before momentum is easy to trust.",
            state: prooflessLiveCount == 0 ? .selected : .default
        )
        let nextStepSignal = GoalPortfolioMaturitySignal(
            id: "next-step",
            title: missingNextStepCount == 0 ? "Next steps are clear" : "Some next steps need shape",
            detail: missingNextStepCount == 0
                ? "Every live ambition has a current next visible step."
                : "\(missingNextStepCount) live ambitions need one concrete next step before they can carry attention.",
            state: missingNextStepCount == 0 ? .selected : .warning
        )

        let accessibilityValue = [
            scopeSignal.title,
            stuckWorkSignal.title,
            proofSignal.title,
            nextStepSignal.title
        ].joined(separator: ". ")

        return GoalPortfolioMaturitySummary(
            title: "Direction maturity",
            subtitle: "A qualitative read on scope, proof, stuck work, and what should happen next.",
            scopeSignal: scopeSignal,
            stuckWorkSignal: stuckWorkSignal,
            proofSignal: proofSignal,
            nextStepSignal: nextStepSignal,
            archiveLearning: archiveSummary.learningLines,
            accessibilityLabel: "Direction maturity",
            accessibilityValue: accessibilityValue,
            accessibilityHint: "Review scope, stuck work, proof, and next-step clarity before adding more goals."
        )
    }


    func stuckWorkDetail(
        blockedOrWaitingCount: Int,
        crowdedOrStalledCount: Int,
        openOneStepCount: Int
    ) -> String {
        var parts: [String] = []
        if blockedOrWaitingCount > 0 {
            parts.append("\(blockedOrWaitingCount) waiting or blocked")
        }
        if crowdedOrStalledCount > 0 {
            parts.append("\(crowdedOrStalledCount) crowded or stalled")
        }
        if openOneStepCount > 3 {
            parts.append("\(openOneStepCount) open One-Step Goals")
        }
        return parts.isEmpty ? "No blockers, waiting states, or overloaded One-Step Goals are driving the atlas." : parts.joined(separator: " · ")
    }
}
