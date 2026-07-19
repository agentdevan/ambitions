import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    func evidence(in window: PeriodWindow, from evidence: [ProgressEvidence]) -> [ProgressEvidence] {
        evidence.filter { parseDate($0.capturedAt).map { $0 >= window.start && $0 < window.end } ?? false }
    }

    func feedback(in window: PeriodWindow, from feedback: [GoalFeedbackEvent]) -> [GoalFeedbackEvent] {
        feedback.filter { parseDate($0.base.occurredAt).map { $0 >= window.start && $0 < window.end } ?? false }
    }

    func metrics(evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent]) -> PeriodMetrics {
        PeriodMetrics(
            completionCount: evidence.filter { $0.evidenceKind == .stepCompleted || $0.evidenceKind == .ritualCompletion }.count,
            minimumCount: evidence.filter { $0.evidenceKind == .ritualMinimumVersion }.count,
            quickLogCount: evidence.filter { $0.evidenceKind == .ritualQuickLog || $0.evidenceKind == .sessionLogged }.count,
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
            editorialSummary = "Reflection stays useful here by being conservative. The next visible completion will sharpen the read more than another abstract number."
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
            subtitle: "Reflection stays calm, specific, and close to the work instead of drifting into detached reporting.",
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
                timeRoute: .weeklyReview,
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
                timeRoute: nil,
                insightsRoute: nil
            )
        }
        return InsightsHeroAction(
            title: "Open deeper history",
            subtitle: "Review the evidence and corrections carrying the current read.",
            systemImage: "clock.arrow.circlepath",
            visualState: .selected,
            goalTarget: nil,
            timeRoute: nil,
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
                timeRoute: nil,
                insightsRoute: nil
            )
        }
        if current.frictionCount > current.visibleFollowThrough {
            return InsightsContinuityRibbon(
                title: "This week is tightening around friction",
                detail: "Take that signal back into Goals before adding more load.",
                icon: "calendar.badge.exclamationmark",
                visualState: .warning,
                goalTarget: nil,
                timeRoute: .weeklyReview,
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
                timeRoute: .weeklyReview,
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
}
