import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedInsightsService: InsightsServicing {
    let repositories: AppRepositories

    func loadInsightsDashboard() async throws -> InsightsDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot)
    }
}

private extension RepositoryBackedInsightsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
    }

    struct PeriodWindow {
        let start: Date
        let end: Date
    }

    struct PeriodMetrics {
        let completionCount: Int
        let minimumCount: Int
        let quickLogCount: Int
        let frictionCount: Int
        let adaptationCount: Int

        var visibleFollowThrough: Int { completionCount + minimumCount }
        var momentumScore: Double { Double((completionCount * 2) + minimumCount + quickLogCount) - Double(frictionCount * 2) }
    }

    struct DatedActivity {
        let date: Date
        let summary: InsightsTimelineItem
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback
        )
    }

    func makeDashboard(snapshot: Snapshot) -> InsightsDashboard {
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let currentWindow = PeriodWindow(
            start: calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart,
            end: calendar.date(byAdding: .day, value: 1, to: todayStart) ?? now
        )
        let previousWindow = PeriodWindow(
            start: calendar.date(byAdding: .day, value: -7, to: currentWindow.start) ?? currentWindow.start,
            end: currentWindow.start
        )

        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let habitGoals = snapshot.goals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }

        let currentEvidence = evidence(in: currentWindow, from: snapshot.evidence)
        let previousEvidence = evidence(in: previousWindow, from: snapshot.evidence)
        let currentFeedback = feedback(in: currentWindow, from: snapshot.feedback)
        let previousFeedback = feedback(in: previousWindow, from: snapshot.feedback)

        let currentMetrics = metrics(evidence: currentEvidence, feedback: currentFeedback)
        let previousMetrics = metrics(evidence: previousEvidence, feedback: previousFeedback)
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked || $0.latestResultKind == .clarificationRequired }.count

        let trendPoints = dailyTrendPoints(from: snapshot.evidence, feedback: snapshot.feedback, start: currentWindow.start)
        let momentumPoints = weightedPoints(from: currentEvidence, feedback: currentFeedback, start: currentWindow.start, positiveKinds: [.stepCompleted, .habitCompletion, .habitMinimumVersion], frictionWeight: 0.45)
        let driftPoints = weightedPoints(from: currentEvidence, feedback: currentFeedback, start: currentWindow.start, positiveKinds: [.askedWhyThisMattersProxy], frictionWeight: 0.9, mode: .drift)
        let adaptationPoints = weightedPoints(from: currentEvidence, feedback: currentFeedback, start: currentWindow.start, positiveKinds: [.habitMinimumVersion], frictionWeight: 0.2, mode: .adaptation)

        let goalStatuses = goalStatuses(goals: activeGoals, feedback: currentFeedback, evidence: currentEvidence)
        let timelineItems = timelineItems(snapshot: snapshot, now: now)
        let posture = postureSummary(
            activeGoalCount: activeGoals.count,
            blockedCount: blockedCount,
            completionCount: currentMetrics.completionCount,
            minimumCount: currentMetrics.minimumCount,
            frictionCount: currentMetrics.frictionCount,
            adaptationCount: currentMetrics.adaptationCount
        )
        let summary = summaryText(
            activeGoalCount: activeGoals.count,
            blockedCount: blockedCount,
            completionCount: currentMetrics.completionCount,
            minimumCount: currentMetrics.minimumCount,
            frictionCount: currentMetrics.frictionCount
        )
        let compare = comparePeriodState(current: currentMetrics, previous: previousMetrics)
        let reviewConstellation = reviewConstellationState(
            goalStatuses: goalStatuses,
            blockedCount: blockedCount,
            current: currentMetrics,
            topGoalTarget: goalStatuses.first?.target
        )
        let continuityRibbon = continuityRibbonState(
            blockedCount: blockedCount,
            current: currentMetrics,
            goalStatuses: goalStatuses
        )

        return InsightsDashboard(
            title: "Reflection OS",
            subtitle: "A calm narrative read on what your behavior is teaching the system right now.",
            posture: posture,
            hero: heroState(
                posture: posture,
                summary: summary,
                current: currentMetrics,
                previous: previousMetrics,
                goalStatuses: goalStatuses,
                compare: compare
            ),
            continuityRibbon: continuityRibbon,
            stats: [
                MetricSummary(id: "insights-focus", title: "Follow-through", value: "\(currentMetrics.visibleFollowThrough)", detail: "Completions and minimum versions this week", icon: "checkmark.circle"),
                MetricSummary(id: "insights-consistency", title: "Consistency", value: "\(consistency(for: habitGoals, metrics: currentMetrics))%", detail: habitGoals.isEmpty ? "No recurring loops yet" : "Ritual rhythm this week", icon: "repeat"),
                MetricSummary(id: "insights-recovery", title: "Adaptation", value: adaptationLabel(currentMetrics, previous: previousMetrics), detail: "How quickly corrections turned back into movement", icon: "arrow.triangle.branch"),
                MetricSummary(id: "insights-care", title: "Needs care", value: "\(blockedCount)", detail: "Open clarification or blocked drafts", icon: "lifepreserver")
            ],
            summary: summary,
            changeSummaries: changeSummaries(
                blockedCount: blockedCount,
                frictionCount: currentMetrics.frictionCount,
                adaptationCount: currentMetrics.adaptationCount,
                completionCount: currentMetrics.completionCount,
                minimumCount: currentMetrics.minimumCount
            ),
            goalStatuses: goalStatuses,
            comparePeriod: compare,
            patternClusters: patternClusters(
                current: currentMetrics,
                previous: previousMetrics,
                trendPoints: trendPoints,
                momentumPoints: momentumPoints,
                driftPoints: driftPoints,
                adaptationPoints: adaptationPoints,
                goalStatuses: goalStatuses
            ),
            reviewConstellation: reviewConstellation,
            historyLayer: historyLayerState(
                timeline: timelineItems,
                current: currentMetrics,
                compare: compare
            ),
            trendTitle: "Pattern truth",
            trendSubtitle: "Microcharts support the read. They do not replace it.",
            timeframeLabel: "This week",
            trendPoints: trendPoints,
            trendSummary: trendSummary(points: trendPoints),
            activitiesTitle: "Recent history",
            activitiesSubtitle: "Recent evidence and corrections that explain why this read matters now.",
            activities: timelineItems.map {
                ActivitySummary(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    timestamp: $0.timestamp,
                    icon: $0.icon,
                    badge: $0.badge
                )
            }
        )
    }

    func evidence(in window: PeriodWindow, from evidence: [ProgressEvidence]) -> [ProgressEvidence] {
        evidence.filter { parseDate($0.capturedAt).map { $0 >= window.start && $0 < window.end } ?? false }
    }

    func feedback(in window: PeriodWindow, from feedback: [GoalFeedbackEvent]) -> [GoalFeedbackEvent] {
        feedback.filter { parseDate($0.base.occurredAt).map { $0 >= window.start && $0 < window.end } ?? false }
    }

    func metrics(evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent]) -> PeriodMetrics {
        PeriodMetrics(
            completionCount: evidence.filter { $0.evidenceKind == .stepCompleted || $0.evidenceKind == .habitCompletion }.count,
            minimumCount: evidence.filter { $0.evidenceKind == .habitMinimumVersion }.count,
            quickLogCount: evidence.filter { $0.evidenceKind == .habitQuickLog || $0.evidenceKind == .sessionLogged }.count,
            frictionCount: feedback.filter(isFriction).count,
            adaptationCount: feedback.filter(isAdaptationSignal).count
        )
    }

    func heroState(
        posture: InsightsPostureSummary,
        summary: String,
        current: PeriodMetrics,
        previous: PeriodMetrics,
        goalStatuses: [InsightsGoalStatusItem],
        compare: InsightsComparePeriodState
    ) -> InsightsHeroState {
        let delta = current.visibleFollowThrough - previous.visibleFollowThrough
        let dominantTruth: String
        let editorialSummary: String
        let trustWhisper: String

        if current.frictionCount > current.visibleFollowThrough {
            dominantTruth = "Recent friction is teaching the system to lower scope before it asks for more."
            editorialSummary = "The reflective read matters now because pressure is outpacing proof. A smaller next step will teach more than pushing harder."
            trustWhisper = "Based on this week, the calmer path is more believable right now."
        } else if current.adaptationCount > 0 && current.visibleFollowThrough > 0 {
            dominantTruth = "Adaptation is turning corrections into usable momentum."
            editorialSummary = "What changed recently is not just the volume of activity. The plan is learning which lighter versions still create real evidence."
            trustWhisper = "This changed after recent feedback and still has visible proof."
        } else if current.visibleFollowThrough == 0 {
            dominantTruth = "The system has an active portfolio, but not enough current proof to say more than that."
            editorialSummary = "Reflection stays useful here by being conservative. The next visible completion will sharpen the read more than another dashboard number."
            trustWhisper = "This looks based on older context and limited recent evidence."
        } else {
            dominantTruth = "Momentum is building from repeatable scope, not volume theater."
            editorialSummary = "The first screenful should answer what you are learning: smaller, visible work is making the current plan easier to trust."
            trustWhisper = "Based on your current week, this still fits."
        }

        let primaryAction = heroAction(current: current, goalStatuses: goalStatuses)
        let pills = [
            InsightsHeroPill(id: "hero-period", title: compare.metrics.first?.deltaLabel ?? "This week", icon: "calendar", visualState: .default),
            InsightsHeroPill(id: "hero-proof", title: "\(current.visibleFollowThrough) visible wins", icon: "checkmark.circle.fill", visualState: current.visibleFollowThrough > 0 ? .success : .default),
            InsightsHeroPill(id: "hero-friction", title: "\(current.frictionCount) friction signals", icon: "waveform.path.ecg", visualState: current.frictionCount > 0 ? .warning : .default),
            InsightsHeroPill(id: "hero-change", title: delta >= 0 ? "More proof than last week" : "Softer than last week", icon: delta >= 0 ? "arrow.up.right" : "arrow.down.right", visualState: delta >= 0 ? .selected : .warning)
        ]

        return InsightsHeroState(
            eyebrow: "What you are learning",
            title: posture.title,
            subtitle: "Reflection stays calm, specific, and close to the work instead of drifting into dashboard theater.",
            dominantTruth: dominantTruth,
            editorialSummary: editorialSummary,
            trustWhisper: trustWhisper,
            postureLabel: posture.label,
            visualState: posture.visualState,
            contextPills: pills,
            primaryAction: primaryAction
        )
    }

    func heroAction(current: PeriodMetrics, goalStatuses: [InsightsGoalStatusItem]) -> InsightsHeroAction {
        if current.frictionCount > current.visibleFollowThrough {
            return InsightsHeroAction(
                title: "Open weekly review",
                subtitle: "Reduce pressure before the drift hardens into plan debt.",
                systemImage: "arrow.triangle.branch",
                visualState: .warning,
                goalTarget: nil,
                planRoute: .weeklyReview,
                insightsRoute: nil
            )
        }
        if let firstAdjustingGoal = goalStatuses.first(where: { $0.visualState != .success }), let target = firstAdjustingGoal.target {
            return InsightsHeroAction(
                title: "Open the goal asking for care",
                subtitle: "Inspect the clearest place where the plan wants a smaller or clearer next step.",
                systemImage: "target",
                visualState: firstAdjustingGoal.visualState,
                goalTarget: target,
                planRoute: nil,
                insightsRoute: nil
            )
        }
        return InsightsHeroAction(
            title: "Open deeper history",
            subtitle: "Review the evidence and corrections carrying the current read.",
            systemImage: "clock.arrow.circlepath",
            visualState: .selected,
            goalTarget: nil,
            planRoute: nil,
            insightsRoute: .history
        )
    }

    func continuityRibbonState(
        blockedCount: Int,
        current: PeriodMetrics,
        goalStatuses: [InsightsGoalStatusItem]
    ) -> InsightsContinuityRibbon? {
        if blockedCount > 0, let target = goalStatuses.first(where: { $0.visualState == .warning })?.target {
            return InsightsContinuityRibbon(
                title: "One active goal still needs clarification",
                detail: "Reflection is carrying that uncertainty forward so the next fix can be intentional.",
                icon: "lifepreserver",
                visualState: .warning,
                goalTarget: target,
                planRoute: nil,
                insightsRoute: nil
            )
        }
        if current.frictionCount > current.visibleFollowThrough {
            return InsightsContinuityRibbon(
                title: "This week is tightening around friction",
                detail: "Take that signal back into Plan before adding more load.",
                icon: "calendar.badge.exclamationmark",
                visualState: .warning,
                goalTarget: nil,
                planRoute: .weeklyReview,
                insightsRoute: nil
            )
        }
        if current.adaptationCount > 0 {
            return InsightsContinuityRibbon(
                title: "Smaller versions are keeping the plan believable",
                detail: "That learning should stay visible when you move back into shaping.",
                icon: "leaf.fill",
                visualState: .selected,
                goalTarget: nil,
                planRoute: .weeklyReview,
                insightsRoute: nil
            )
        }
        return nil
    }

    func comparePeriodState(current: PeriodMetrics, previous: PeriodMetrics) -> InsightsComparePeriodState {
        let metrics = [
            InsightsCompareMetric(
                id: "compare-followthrough",
                title: "Visible follow-through",
                currentLabel: "\(current.visibleFollowThrough)",
                previousLabel: "\(previous.visibleFollowThrough)",
                deltaLabel: compareLabel(current.visibleFollowThrough - previous.visibleFollowThrough, positive: "more than last week", negative: "fewer than last week"),
                visualState: current.visibleFollowThrough >= previous.visibleFollowThrough ? .success : .warning
            ),
            InsightsCompareMetric(
                id: "compare-friction",
                title: "Friction",
                currentLabel: "\(current.frictionCount)",
                previousLabel: "\(previous.frictionCount)",
                deltaLabel: compareLabel(previous.frictionCount - current.frictionCount, positive: "softer than last week", negative: "heavier than last week"),
                visualState: current.frictionCount <= previous.frictionCount ? .selected : .warning
            ),
            InsightsCompareMetric(
                id: "compare-adaptation",
                title: "Adaptation",
                currentLabel: "\(current.adaptationCount)",
                previousLabel: "\(previous.adaptationCount)",
                deltaLabel: compareLabel(current.adaptationCount - previous.adaptationCount, positive: "more visible adaptation", negative: "less visible adaptation"),
                visualState: current.adaptationCount >= previous.adaptationCount ? .selected : .default
            )
        ]

        let summary: String
        if current.visibleFollowThrough > previous.visibleFollowThrough && current.frictionCount <= previous.frictionCount {
            summary = "The system is seeing steadier proof than last week without a matching rise in friction."
        } else if current.frictionCount > previous.frictionCount {
            summary = "Recent change matters because friction is rising faster than visible proof."
        } else if current.adaptationCount > previous.adaptationCount {
            summary = "Recent change is showing up mostly as adaptation, not raw volume. That is a useful sign."
        } else {
            summary = "The period comparison is relatively steady. The plan quality is changing more through nuance than through dramatic swings."
        }

        return InsightsComparePeriodState(
            title: "Compare periods",
            subtitle: "Compact contrast keeps the reflection layer grounded without turning the screen into a BI panel.",
            summary: summary,
            metrics: metrics
        )
    }

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
                planRoute: nil
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
                planRoute: .weeklyReview
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
                planRoute: .weeklyReview
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
                planRoute: nil
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
            planRoute: .weeklyReview
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
                    planRoute: nil
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
            let completionCount = goalEvidence.filter { $0.evidenceKind == .stepCompleted || $0.evidenceKind == .habitCompletion }.count
            let minimumCount = goalEvidence.filter { $0.evidenceKind == .habitMinimumVersion }.count
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

    func dailyTrendPoints(from evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent], start: Date) -> [TrendPoint] {
        weightedPoints(from: evidence, feedback: feedback, start: start, positiveKinds: [.stepCompleted, .habitCompletion, .habitMinimumVersion], frictionWeight: 0.55)
    }

    enum PointMode {
        case standard
        case drift
        case adaptation
    }

    enum PositiveKind: Hashable {
        case stepCompleted
        case habitCompletion
        case habitMinimumVersion
        case askedWhyThisMattersProxy
    }

    func weightedPoints(
        from evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        start: Date,
        positiveKinds: [PositiveKind],
        frictionWeight: Double,
        mode: PointMode = .standard
    ) -> [TrendPoint] {
        (0..<7).compactMap { offset -> TrendPoint? in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: start) else { return nil }
            let dayEvidence = evidence.filter { parseDate($0.capturedAt).map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false }
            let dayFeedback = feedback.filter { parseDate($0.base.occurredAt).map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false }

            let positive = dayEvidence.reduce(0.0) { partial, item in
                partial + evidenceWeight(item.evidenceKind, matching: positiveKinds, mode: mode)
            } + dayFeedback.reduce(0.0) { partial, event in
                partial + feedbackPositiveWeight(event, mode: mode)
            }

            let friction = dayFeedback.reduce(0.0) { partial, event in
                partial + (isFriction(event) ? frictionWeight : 0.0)
            }

            let normalized: Double
            switch mode {
            case .drift:
                normalized = max(0.08, min(1, (1.2 + friction - positive) / 2.4))
            case .adaptation:
                normalized = max(0.08, min(1, (0.9 + positive - (friction * 0.35)) / 1.8))
            case .standard:
                normalized = max(0.08, min(1, (1.2 + positive - friction) / 2.4))
            }

            return TrendPoint(
                id: "\(mode)-trend-\(offset)",
                label: dayLabel(for: day),
                value: normalized
            )
        }
    }

    func evidenceWeight(_ kind: ProgressEvidenceKind, matching positiveKinds: [PositiveKind], mode: PointMode) -> Double {
        let requested = Set(positiveKinds)
        switch kind {
        case .stepCompleted:
            return requested.contains(.stepCompleted) ? 1.0 : 0
        case .habitCompletion:
            return requested.contains(.habitCompletion) ? 0.95 : 0
        case .habitMinimumVersion:
            return requested.contains(.habitMinimumVersion) ? (mode == .adaptation ? 1.0 : 0.7) : 0
        case .habitQuickLog, .sessionLogged:
            return mode == .standard ? 0.35 : 0.15
        case .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
            return mode == .adaptation ? 0.35 : 0.2
        }
    }

    func feedbackPositiveWeight(_ event: GoalFeedbackEvent, mode: PointMode) -> Double {
        switch mode {
        case .adaptation:
            switch event {
            case .delayed, .askedForSmallerVersion, .tooBig, .askedWhyThisMatters:
                return 0.55
            case .edited, .notRelevant:
                return 0.35
            default:
                return 0
            }
        case .drift:
            switch event {
            case .completed:
                return 0.2
            default:
                return 0
            }
        case .standard:
            switch event {
            case .completed:
                return 0.25
            default:
                return 0
            }
        }
    }

    func timelineItems(snapshot: Snapshot, now: Date) -> [InsightsTimelineItem] {
        let goalsByStep = Dictionary(uniqueKeysWithValues: snapshot.goals.flatMap { goal in
            (goal.plan?.sections.flatMap(\.steps) ?? []).map { ($0.id, goal) }
        })

        let evidenceActivities = snapshot.evidence.compactMap { evidence -> DatedActivity? in
            guard let date = parseDate(evidence.capturedAt) else { return nil }
            let target = GoalRouteTarget(goalID: evidence.goalID)
            return DatedActivity(
                date: date,
                summary: InsightsTimelineItem(
                    id: evidence.id,
                    title: evidenceTitle(for: evidence),
                    subtitle: goalTitle(for: evidence.goalID, goals: snapshot.goals),
                    timestamp: relativeTimestamp(for: evidence.capturedAt, now: now),
                    icon: evidenceIcon(for: evidence),
                    badge: evidenceBadge(for: evidence),
                    visualState: evidenceState(for: evidence),
                    goalTarget: target.goalID == nil ? nil : target,
                    planRoute: nil
                )
            )
        }

        let feedbackActivities = snapshot.feedback.compactMap { event -> DatedActivity? in
            guard let date = parseDate(event.base.occurredAt) else { return nil }
            let goal = goalsByStep[event.stepID]
            let target = goal.map { GoalRouteTarget(goalID: $0.id) }
            return DatedActivity(
                date: date,
                summary: InsightsTimelineItem(
                    id: event.base.id,
                    title: feedbackTitle(for: event),
                    subtitle: stepTitle(for: event.stepID, goals: snapshot.goals),
                    timestamp: relativeTimestamp(for: event.base.occurredAt, now: now),
                    icon: feedbackIcon(for: event),
                    badge: feedbackBadge(for: event),
                    visualState: feedbackState(for: event),
                    goalTarget: target,
                    planRoute: isFriction(event) ? .weeklyReview : nil
                )
            )
        }

        return (evidenceActivities + feedbackActivities)
            .sorted { lhs, rhs in
                if lhs.date == rhs.date {
                    return lhs.summary.id > rhs.summary.id
                }
                return lhs.date > rhs.date
            }
            .prefix(8)
            .map(\.summary)
    }

    func summaryText(activeGoalCount: Int, blockedCount: Int, completionCount: Int, minimumCount: Int, frictionCount: Int) -> String {
        if blockedCount > 0 {
            return "Some goals are asking for clarification before this reflection can claim much more. The strongest signal is still coming from small visible wins, not volume."
        }
        if frictionCount > completionCount {
            return "Friction outweighed completions this week, so the healthiest response is to shrink the next step and remove pressure rather than add more commitments."
        }
        if minimumCount > 0 {
            return "Minimum-version follow-through is carrying momentum. The pattern suggests smaller asks are helping the plan stay honest."
        }
        return activeGoalCount == 0
            ? "Reflection will become richer as live goals, evidence, and history accumulate."
            : "Real evidence is accumulating against the current portfolio, and the plan quality looks strongest when the next step stays specific and visible."
    }

    func trendSummary(points: [TrendPoint]) -> String {
        guard let first = points.first?.value, let last = points.last?.value else {
            return "The trend will become more meaningful as more evidence lands."
        }
        if last > first + 0.1 {
            return "The week improved as visible evidence accumulated and friction stayed manageable."
        }
        if first > last + 0.1 {
            return "Signal softened later in the week, which usually means the next step needs less pressure and more clarity."
        }
        return "The week stayed relatively steady. Consistency is coming more from repeatable scope than from bursts."
    }

    func consistency(for habits: [Goal], metrics: PeriodMetrics) -> Int {
        guard habits.isEmpty == false else { return 0 }
        return min(100, Int((Double(metrics.visibleFollowThrough + metrics.quickLogCount) / Double(max(habits.count * 3, 1))) * 100))
    }

    func adaptationLabel(_ current: PeriodMetrics, previous: PeriodMetrics) -> String {
        let delta = current.adaptationCount - previous.adaptationCount
        if current.adaptationCount == 0 { return "Quiet" }
        if delta > 0 { return "Building" }
        if delta < 0 { return "Slower" }
        return "Steady"
    }

    func compareLabel(_ delta: Int, positive: String, negative: String) -> String {
        if delta > 0 { return "\(abs(delta)) \(positive)" }
        if delta < 0 { return "\(abs(delta)) \(negative)" }
        return "Same as last week"
    }

    func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    func relativeTimestamp(for value: String, now: Date) -> String {
        guard let date = parseDate(value) else { return value }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: now)
    }

    func goalTitle(for goalID: String, goals: [Goal]) -> String {
        goals.first(where: { $0.id == goalID })?.title ?? "Goal context"
    }

    func stepTitle(for stepID: String, goals: [Goal]) -> String {
        goals
            .flatMap { $0.plan?.sections.flatMap(\.steps) ?? [] }
            .first(where: { $0.id == stepID })?.title ?? "Goal correction"
    }

    func evidenceTitle(for evidence: ProgressEvidence) -> String {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return "Completed work"
        case .habitMinimumVersion:
            return "Minimum version logged"
        case .habitQuickLog:
            return "Ritual signal captured"
        case .sessionLogged:
            return "Session logged"
        case .reflectionLogged:
            return "Reflection captured"
        case .delegatedUpdate:
            return "Support update captured"
        case .observationLogged:
            return "Observation recorded"
        case .milestoneReached:
            return "Milestone reached"
        }
    }

    func evidenceIcon(for evidence: ProgressEvidence) -> String {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return "checkmark.circle.fill"
        case .habitMinimumVersion:
            return "leaf.fill"
        case .habitQuickLog:
            return "plus.bubble.fill"
        default:
            return "sparkles"
        }
    }

    func evidenceBadge(for evidence: ProgressEvidence) -> String? {
        switch evidence.evidenceKind {
        case .habitMinimumVersion:
            return "Minimum"
        case .habitQuickLog:
            return "Quick log"
        case .stepCompleted, .habitCompletion:
            return "Win"
        default:
            return nil
        }
    }

    func evidenceState(for evidence: ProgressEvidence) -> AmbitionVisualState {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return .success
        case .habitMinimumVersion:
            return .selected
        case .habitQuickLog, .sessionLogged:
            return .default
        default:
            return .default
        }
    }

    func feedbackTitle(for event: GoalFeedbackEvent) -> String {
        switch event {
        case .skipped:
            return "Skipped without punishment"
        case .delayed:
            return "Timing softened"
        case .confused:
            return "Help requested"
        case .tooBig, .askedForSmallerVersion:
            return "Step was shrunk"
        case .notRelevant:
            return "Plan correction flagged"
        case .askedWhyThisMatters:
            return "Rationale requested"
        case .edited:
            return "Step language adjusted"
        case .tooEasy:
            return "Low-signal step noticed"
        case .completed:
            return "Completion feedback logged"
        }
    }

    func feedbackIcon(for event: GoalFeedbackEvent) -> String {
        switch event {
        case .completed:
            return "checkmark.circle"
        case .notRelevant:
            return "nosign"
        case .confused:
            return "lifepreserver"
        default:
            return "arrow.triangle.branch"
        }
    }

    func feedbackBadge(for event: GoalFeedbackEvent) -> String? {
        switch event {
        case .confused:
            return "Help"
        case .notRelevant:
            return "Correction"
        case .askedForSmallerVersion, .tooBig:
            return "Adapted"
        default:
            return nil
        }
    }

    func feedbackState(for event: GoalFeedbackEvent) -> AmbitionVisualState {
        switch event {
        case .completed:
            return .success
        case .askedForSmallerVersion, .delayed, .edited, .askedWhyThisMatters:
            return .selected
        case .skipped, .confused, .tooBig, .notRelevant:
            return .warning
        case .tooEasy:
            return .default
        }
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant:
            return true
        default:
            return false
        }
    }

    func isAdaptationSignal(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .delayed, .askedForSmallerVersion, .tooBig, .confused, .notRelevant, .askedWhyThisMatters:
            return true
        default:
            return false
        }
    }

    func goalStatusRank(_ state: AmbitionVisualState) -> Int {
        switch state {
        case .pressed:
            return 5
        case .disabled:
            return 6
        case .loading:
            return 7
        case .warning:
            return 0
        case .selected:
            return 1
        case .success:
            return 2
        case .celebration:
            return 3
        case .default:
            return 4
        }
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value, value.isEmpty == false else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
