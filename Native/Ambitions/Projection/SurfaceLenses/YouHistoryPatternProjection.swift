import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    func patternClusters(
        current: PeriodMetrics,
        previous: PeriodMetrics,
        trendPoints: [TrendPoint],
        momentumPoints: [TrendPoint],
        driftPoints: [TrendPoint],
        adaptationPoints: [TrendPoint],
        goalStatuses: [InsightsGoalStatusItem]
    ) -> [InsightsPatternCluster] {
        let topGoalTarget = goalStatuses.first?.target
        return [
            InsightsPatternCluster(
                id: "pattern-momentum",
                title: "Momentum",
                summary: current.visibleFollowThrough == 0
                    ? "Momentum is still waiting on a visible completion or minimum version."
                    : "Momentum is strongest when the next step stays small enough to be seen clearly.",
                emphasisLabel: current.visibleFollowThrough > 0 ? "Building" : "Quiet",
                deltaLabel: compareLabel(current.visibleFollowThrough - previous.visibleFollowThrough, positive: "more visible than last week", negative: "less visible than last week"),
                visualState: current.visibleFollowThrough > 0 ? .success : .default,
                points: momentumPoints.isEmpty ? trendPoints : momentumPoints,
                goalTarget: current.visibleFollowThrough > 0 ? topGoalTarget : nil,
                timeRoute: nil
            ),
            InsightsPatternCluster(
                id: "pattern-drift",
                title: "Drift",
                summary: current.frictionCount == 0
                    ? "No major drift signal is crowding out the current week."
                    : "Drift is showing up as confusion, oversizing, or skips. The right response is less pressure and more clarity.",
                emphasisLabel: current.frictionCount == 0 ? "Contained" : "Needs room",
                deltaLabel: compareLabel(previous.frictionCount - current.frictionCount, positive: "lighter than last week", negative: "heavier than last week"),
                visualState: current.frictionCount == 0 ? .selected : .warning,
                points: driftPoints,
                goalTarget: current.frictionCount > 0 ? topGoalTarget : nil,
                timeRoute: .weeklyReview
            ),
            InsightsPatternCluster(
                id: "pattern-adaptation",
                title: "Adaptation",
                summary: current.adaptationCount == 0
                    ? "No recent correction has materially changed the plan shape."
                    : "The plan is learning through smaller versions, timing changes, and clarification rather than pretending the first draft was perfect.",
                emphasisLabel: current.adaptationCount == 0 ? "Steady" : "Adapting",
                deltaLabel: compareLabel(current.adaptationCount - previous.adaptationCount, positive: "more active than last week", negative: "quieter than last week"),
                visualState: current.adaptationCount == 0 ? .default : .selected,
                points: adaptationPoints,
                goalTarget: nil,
                timeRoute: .weeklyReview
            )
        ]
    }

    func reviewConstellationState(
        goalStatuses: [InsightsGoalStatusItem],
        blockedCount: Int,
        current: PeriodMetrics,
        topGoalTarget: GoalRouteTarget?
    ) -> InsightsReviewConstellationState {
        var items = goalStatuses.prefix(3).map {
            InsightsReviewConstellationItem(
                id: "constellation-\($0.id)",
                title: $0.title,
                summary: $0.summary,
                signalLabel: $0.statusLabel,
                visualState: $0.visualState,
                goalTarget: $0.target,
                timeRoute: nil
            )
        }

        let planItem = InsightsReviewConstellationItem(
            id: "constellation-plan",
            title: blockedCount > 0 || current.frictionCount > current.visibleFollowThrough ? "The week needs a calmer shape" : "Weekly review can carry this learning forward",
            summary: blockedCount > 0 || current.frictionCount > current.visibleFollowThrough
                ? "Open Time to remove pressure, protect what still fits, and keep reflection attached to the real week."
                : "Open Time when you want this reflection to shape the next week instead of staying retrospective.",
            signalLabel: blockedCount > 0 || current.frictionCount > current.visibleFollowThrough ? "Shape next" : "Carry forward",
            visualState: blockedCount > 0 || current.frictionCount > current.visibleFollowThrough ? .warning : .selected,
            goalTarget: nil,
            timeRoute: .weeklyReview
        )
        items.append(planItem)

        if items.isEmpty, let topGoalTarget {
            items.append(
                InsightsReviewConstellationItem(
                    id: "constellation-fallback",
                    title: "Open the clearest active goal",
                    summary: "Reflection is still thin, so the most truthful next read lives with the goal doing the work.",
                    signalLabel: "Open goal",
                    visualState: .default,
                    goalTarget: topGoalTarget,
                    timeRoute: nil
                )
            )
        }

        return InsightsReviewConstellationState(
            title: "Review constellation",
            subtitle: "A small set of signals worth carrying across review, goal detail, and plan. It should improve comprehension, not add visual theater.",
            items: items
        )
    }

    func historyLayerState(
        timeline: [InsightsTimelineItem],
        current: PeriodMetrics,
        compare: InsightsComparePeriodState
    ) -> InsightsHistoryLayerState {
        let summaryTitle: String
        let summaryDetail: String

        if current.visibleFollowThrough == 0 {
            summaryTitle = "History is still warming up"
            summaryDetail = "Deep history stays available, but the current layer should remain conservative until newer evidence lands."
        } else if current.frictionCount > current.visibleFollowThrough {
            summaryTitle = "Recent history explains the pressure"
            summaryDetail = "The timeline matters now because it shows where skips, confusion, and rescoping started to crowd out proof."
        } else {
            summaryTitle = "Recent history is carrying the current read"
            summaryDetail = compare.summary
        }

        return InsightsHistoryLayerState(
            title: "History and reflection",
            subtitle: "The summary layer stays quick. The deeper timeline is here when you need proof of what changed.",
            summaryTitle: summaryTitle,
            summaryDetail: summaryDetail,
            previewItems: Array(timeline.prefix(3)),
            timelineItems: timeline
        )
    }

    func postureSummary(
        activeGoalCount: Int,
        blockedCount: Int,
        completionCount: Int,
        minimumCount: Int,
        frictionCount: Int,
        adaptationCount: Int
    ) -> InsightsPostureSummary {
        if activeGoalCount == 0 {
            return InsightsPostureSummary(
                title: "Reflection is waiting for live evidence",
                detail: "This layer becomes useful once active goals, progress signals, and feedback start accumulating.",
                label: "Quiet",
                visualState: .default
            )
        }
        if blockedCount > 0 {
            return InsightsPostureSummary(
                title: "Some goals need clarification before the reflection can sharpen",
                detail: "Open blockers are still the strongest source of uncertainty in the current read.",
                label: "Needs care",
                visualState: .warning
            )
        }
        if frictionCount > completionCount + minimumCount {
            return InsightsPostureSummary(
                title: "Friction is leading the current story",
                detail: "The healthiest response is to reduce pressure and make the next step smaller, not to add more commitments.",
                label: "Heavy week",
                visualState: .warning
            )
        }
        if adaptationCount > 0 && completionCount + minimumCount > 0 {
            return InsightsPostureSummary(
                title: "Adaptation is helping the plan stay believable",
                detail: "Corrections and smaller versions are turning into visible follow-through instead of churn.",
                label: "Adapting",
                visualState: .selected
            )
        }
        if completionCount + minimumCount == 0 {
            return InsightsPostureSummary(
                title: "The portfolio is active, but the week is still light on proof",
                detail: "Active goals exist, but this week still needs more visible evidence before a stronger claim would be trustworthy.",
                label: "Waiting on signal",
                visualState: .default
            )
        }
        return InsightsPostureSummary(
            title: "The week is producing usable evidence",
            detail: "Momentum is coming from visible work and a calmer scope, which makes the current portfolio easier to trust.",
            label: "Believable",
            visualState: .success
        )
    }

    func changeSummaries(
        blockedCount: Int,
        frictionCount: Int,
        adaptationCount: Int,
        completionCount: Int,
        minimumCount: Int
    ) -> [InsightsChangeSummary] {
        [
            InsightsChangeSummary(
                id: "insights-change-adaptation",
                title: "Time changes",
                detail: adaptationCount == 0
                    ? "No recent adaptation signal is changing the plan right now."
                    : "Feedback is actively changing how the plan is being carried this week.",
                valueLabel: "\(adaptationCount)",
                icon: "arrow.triangle.branch",
                visualState: adaptationCount == 0 ? .default : .selected
            ),
            InsightsChangeSummary(
                id: "insights-change-friction",
                title: "Drift and friction",
                detail: frictionCount == 0
                    ? "No major drift signal is overpowering the current week."
                    : "Recent friction is the clearest reason some work needs gentler scope.",
                valueLabel: "\(frictionCount)",
                icon: "waveform.path.ecg",
                visualState: frictionCount == 0 ? .success : .warning
            ),
            InsightsChangeSummary(
                id: "insights-change-care",
                title: "Goals needing care",
                detail: blockedCount == 0
                    ? "No active goal is currently blocked on clarification."
                    : "Some active work still needs clarification before it can be trusted fully.",
                valueLabel: "\(blockedCount)",
                icon: "lifepreserver",
                visualState: blockedCount == 0 ? .default : .warning
            ),
            InsightsChangeSummary(
                id: "insights-change-followthrough",
                title: "Visible follow-through",
                detail: completionCount + minimumCount == 0
                    ? "The week still needs a visible completion or minimum version to read clearly."
                    : "Completions and minimum versions are carrying the most useful signal right now.",
                valueLabel: "\(completionCount + minimumCount)",
                icon: "checkmark.circle",
                visualState: completionCount + minimumCount == 0 ? .default : .success
            )
        ]
    }

    func goalStatuses(
        goals: [Goal],
        feedback: [GoalFeedbackEvent],
        evidence: [ProgressEvidence]
    ) -> [InsightsGoalStatusItem] {
        goals.compactMap { goal in
            let evaluation = goal.plan?.evaluation
            let goalSteps = goal.plan?.sections.flatMap(\.steps) ?? []
            let goalStepIDs = Set(goalSteps.map(\.id))
            let goalFeedback = feedback.filter { event in goalStepIDs.contains(event.stepID) }
            let goalEvidence = evidence.filter { $0.goalID == goal.id }
            let frictionCount = goalFeedback.filter(isFriction).count
            let completionCount = goalEvidence.filter { $0.evidenceKind == .stepCompleted || $0.evidenceKind == .ritualCompletion }.count
            let minimumCount = goalEvidence.filter { $0.evidenceKind == .ritualMinimumVersion }.count
            let statusLabel: String
            let summary: String
            let state: AmbitionVisualState

            if evaluation?.feasibilityLevel == .notBelievable || evaluation?.feasibilityLevel == .fragile {
                statusLabel = "Needs care"
                summary = "Current planning signals are warning that this goal is fragile under the week's scope."
                state = .warning
            } else if frictionCount > 0 {
                statusLabel = "Adjusting"
                summary = "Recent friction suggests the current version of the work needs a smaller or clearer next step."
                state = .selected
            } else if completionCount + minimumCount > 0 {
                statusLabel = "Believable"
                summary = "This goal has visible evidence this week, which keeps its current path grounded in real follow-through."
                state = .success
            } else {
                statusLabel = "Quiet"
                summary = "The goal is active, but this week has not yet produced enough evidence to say much more than that."
                state = .default
            }

            return InsightsGoalStatusItem(
                id: "insights-goal-\(goal.id)",
                target: GoalRouteTarget(goalID: goal.id),
                title: goal.title,
                summary: summary,
                statusLabel: statusLabel,
                visualState: state
            )
        }
        .sorted { lhs, rhs in
            let leftRank = goalStatusRank(lhs.visualState)
            let rightRank = goalStatusRank(rhs.visualState)
            if leftRank == rightRank {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return leftRank < rightRank
        }
        .prefix(4)
        .map { $0 }
    }
}
