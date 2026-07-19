import AmbitionsDesignSystem
import Foundation

extension PreviewFixtures {
    static let defaultInsightsDashboard = InsightsDashboard(
        title: "Reflection OS",
        subtitle: "A calm narrative read on what your behavior is teaching the system right now.",
        posture: InsightsPostureSummary(
            title: "Adaptation is helping the plan stay believable",
            detail: "Corrections and smaller versions are turning into visible follow-through instead of churn.",
            label: "Adapting",
            visualState: .selected
        ),
        hero: InsightsHeroState(
            eyebrow: "What you are learning",
            title: "Adaptation is helping the plan stay believable",
            subtitle: "Reflection stays calm, specific, and close to the work instead of drifting into metric theater.",
            dominantTruth: "Smaller versions are carrying momentum more reliably than bigger plans.",
            editorialSummary: "What changed recently is not just activity volume. The system is learning which lighter asks still create proof.",
            trustWhisper: "This changed after recent feedback and still has visible proof.",
            postureLabel: "Adapting",
            visualState: .selected,
            contextPills: [
                InsightsHeroPill(id: "preview-hero-1", title: "2 more than last week", icon: "calendar", visualState: .default),
                InsightsHeroPill(id: "preview-hero-2", title: "4 visible wins", icon: "checkmark.circle.fill", visualState: .success),
                InsightsHeroPill(id: "preview-hero-3", title: "1 friction signal", icon: "waveform.path.ecg", visualState: .warning),
                InsightsHeroPill(id: "preview-hero-4", title: "More proof than last week", icon: "arrow.up.right", visualState: .selected)
            ],
            primaryAction: InsightsHeroAction(
                title: "Open deeper history",
                subtitle: "Review the evidence and corrections carrying the current read.",
                systemImage: "clock.arrow.circlepath",
                visualState: .selected,
                goalTarget: nil,
                timeRoute: nil,
                insightsRoute: .history
            )
        ),
        continuityRibbon: InsightsContinuityRibbon(
            title: "Smaller versions are keeping the plan believable",
            detail: "That learning should stay visible when you move back into shaping.",
            icon: "leaf.fill",
            visualState: .selected,
            goalTarget: nil,
            timeRoute: .weeklyReview,
            insightsRoute: nil
        ),
        stats: [
            MetricSummary(id: "insight-1", title: "Follow-through", value: "4", detail: "Completions and minimum versions this week", icon: "checkmark.circle"),
            MetricSummary(id: "insight-2", title: "Consistency", value: "63%", detail: "Ritual rhythm this week", icon: "repeat"),
            MetricSummary(id: "insight-3", title: "Adaptation", value: "Building", detail: "How quickly corrections turned back into movement", icon: "arrow.triangle.branch"),
            MetricSummary(id: "insight-4", title: "Needs care", value: "1", detail: "Open clarification or blocked drafts", icon: "lifepreserver")
        ],
        summary: "Recent adaptation works best when the next step stays small, explicit, and grounded in visible evidence.",
        changeSummaries: [
            InsightsChangeSummary(id: "insight-change-1", title: "Plan changes", detail: "Feedback is actively changing how the plan is being carried this week.", valueLabel: "2", icon: "arrow.triangle.branch", visualState: .selected),
            InsightsChangeSummary(id: "insight-change-2", title: "Drift and friction", detail: "Recent friction is the clearest reason some work needs gentler scope.", valueLabel: "1", icon: "waveform.path.ecg", visualState: .warning),
            InsightsChangeSummary(id: "insight-change-3", title: "Goals needing care", detail: "One active area still needs clarification before it can be trusted fully.", valueLabel: "1", icon: "lifepreserver", visualState: .warning),
            InsightsChangeSummary(id: "insight-change-4", title: "Visible follow-through", detail: "Completions and minimum versions are carrying the most useful signal right now.", valueLabel: "4", icon: "checkmark.circle", visualState: .success)
        ],
        goalStatuses: [
            InsightsGoalStatusItem(id: "insight-goal-1", target: GoalRouteTarget(goalID: "goal-native"), title: "Close the hardening pass", summary: "This goal has visible evidence this week, which keeps its current path grounded in real follow-through.", statusLabel: "Believable", visualState: .success),
            InsightsGoalStatusItem(id: "insight-goal-2", target: GoalRouteTarget(goalID: "goal-growth"), title: "Retention loop", summary: "Recent friction suggests the current version of the work needs a smaller or clearer next step.", statusLabel: "Adjusting", visualState: .selected)
        ],
        comparePeriod: InsightsComparePeriodState(
            title: "Compare periods",
            subtitle: "Compact contrast keeps the reflection layer grounded without turning the screen into a BI panel.",
            summary: "The system is seeing steadier proof than last week without a matching rise in friction.",
            metrics: [
                InsightsCompareMetric(id: "preview-compare-1", title: "Visible follow-through", currentLabel: "4", previousLabel: "2", deltaLabel: "2 more than last week", visualState: .success),
                InsightsCompareMetric(id: "preview-compare-2", title: "Friction", currentLabel: "1", previousLabel: "2", deltaLabel: "1 softer than last week", visualState: .selected),
                InsightsCompareMetric(id: "preview-compare-3", title: "Adaptation", currentLabel: "2", previousLabel: "1", deltaLabel: "1 more visible adaptation", visualState: .selected)
            ]
        ),
        patternClusters: [
            InsightsPatternCluster(id: "preview-pattern-1", title: "Momentum", summary: "Momentum is strongest when the next step stays small enough to be seen clearly.", emphasisLabel: "Building", deltaLabel: "2 more visible than last week", visualState: .success, points: [
                TrendPoint(id: "pm1", label: "M", value: 0.32),
                TrendPoint(id: "pm2", label: "T", value: 0.44),
                TrendPoint(id: "pm3", label: "W", value: 0.58),
                TrendPoint(id: "pm4", label: "T", value: 0.61),
                TrendPoint(id: "pm5", label: "F", value: 0.79),
                TrendPoint(id: "pm6", label: "S", value: 0.48),
                TrendPoint(id: "pm7", label: "S", value: 0.73)
            ], goalTarget: GoalRouteTarget(goalID: "goal-native"), timeRoute: nil),
            InsightsPatternCluster(id: "preview-pattern-2", title: "Drift", summary: "Drift is showing up as friction around one active area, not as a full portfolio collapse.", emphasisLabel: "Needs room", deltaLabel: "1 lighter than last week", visualState: .warning, points: [
                TrendPoint(id: "pd1", label: "M", value: 0.62),
                TrendPoint(id: "pd2", label: "T", value: 0.44),
                TrendPoint(id: "pd3", label: "W", value: 0.52),
                TrendPoint(id: "pd4", label: "T", value: 0.35),
                TrendPoint(id: "pd5", label: "F", value: 0.41),
                TrendPoint(id: "pd6", label: "S", value: 0.26),
                TrendPoint(id: "pd7", label: "S", value: 0.29)
            ], goalTarget: GoalRouteTarget(goalID: "goal-growth"), timeRoute: .weeklyReview),
            InsightsPatternCluster(id: "preview-pattern-3", title: "Adaptation", summary: "The plan is learning through lighter versions rather than pretending the first draft was perfect.", emphasisLabel: "Adapting", deltaLabel: "1 more active than last week", visualState: .selected, points: [
                TrendPoint(id: "pa1", label: "M", value: 0.18),
                TrendPoint(id: "pa2", label: "T", value: 0.24),
                TrendPoint(id: "pa3", label: "W", value: 0.46),
                TrendPoint(id: "pa4", label: "T", value: 0.58),
                TrendPoint(id: "pa5", label: "F", value: 0.66),
                TrendPoint(id: "pa6", label: "S", value: 0.49),
                TrendPoint(id: "pa7", label: "S", value: 0.62)
            ], goalTarget: nil, timeRoute: .weeklyReview)
        ],
        reviewConstellation: InsightsReviewConstellationState(
            title: "Review constellation",
            subtitle: "A small set of signals worth carrying across review, goal detail, and plan.",
            items: [
                InsightsReviewConstellationItem(id: "preview-constellation-1", title: "Close the hardening pass", summary: "This goal has visible evidence this week, which keeps its current path grounded in real follow-through.", signalLabel: "Believable", visualState: .success, goalTarget: GoalRouteTarget(goalID: "goal-native"), timeRoute: nil),
                InsightsReviewConstellationItem(id: "preview-constellation-2", title: "Retention loop", summary: "Recent friction suggests the current version of the work needs a smaller or clearer next step.", signalLabel: "Adjusting", visualState: .selected, goalTarget: GoalRouteTarget(goalID: "goal-growth"), timeRoute: nil),
                InsightsReviewConstellationItem(id: "preview-constellation-3", title: "The week needs a calmer shape", summary: "Open Time to remove pressure, protect what still fits, and keep reflection attached to the real week.", signalLabel: "Shape next", visualState: .warning, goalTarget: nil, timeRoute: .weeklyReview)
            ]
        ),
        historyLayer: InsightsHistoryLayerState(
            title: "History and reflection",
            subtitle: "The summary layer stays quick. The deeper timeline is here when you need proof of what changed.",
            summaryTitle: "Recent history is carrying the current read",
            summaryDetail: "The system is seeing steadier proof than last week without a matching rise in friction.",
            previewItems: [
                InsightsTimelineItem(id: "preview-timeline-1", title: "Completed deep work block", subtitle: "Close the hardening pass", timestamp: "40 min ago", icon: "checkmark.circle.fill", badge: "Win", visualState: .success, goalTarget: GoalRouteTarget(goalID: "goal-native"), timeRoute: nil),
                InsightsTimelineItem(id: "preview-timeline-2", title: "Step was shrunk", subtitle: "Retention loop", timestamp: "Yesterday", icon: "arrow.triangle.branch", badge: "Adapted", visualState: .selected, goalTarget: GoalRouteTarget(goalID: "goal-growth"), timeRoute: .weeklyReview),
                InsightsTimelineItem(id: "preview-timeline-3", title: "Help requested", subtitle: "Retention loop", timestamp: "2 days ago", icon: "lifepreserver", badge: "Help", visualState: .warning, goalTarget: GoalRouteTarget(goalID: "goal-growth"), timeRoute: .weeklyReview)
            ],
            timelineItems: [
                InsightsTimelineItem(id: "preview-timeline-1", title: "Completed deep work block", subtitle: "Close the hardening pass", timestamp: "40 min ago", icon: "checkmark.circle.fill", badge: "Win", visualState: .success, goalTarget: GoalRouteTarget(goalID: "goal-native"), timeRoute: nil),
                InsightsTimelineItem(id: "preview-timeline-2", title: "Step was shrunk", subtitle: "Retention loop", timestamp: "Yesterday", icon: "arrow.triangle.branch", badge: "Adapted", visualState: .selected, goalTarget: GoalRouteTarget(goalID: "goal-growth"), timeRoute: .weeklyReview),
                InsightsTimelineItem(id: "preview-timeline-3", title: "Help requested", subtitle: "Retention loop", timestamp: "2 days ago", icon: "lifepreserver", badge: "Help", visualState: .warning, goalTarget: GoalRouteTarget(goalID: "goal-growth"), timeRoute: .weeklyReview),
                InsightsTimelineItem(id: "preview-timeline-4", title: "Updated release validation notes", subtitle: "Close the hardening pass", timestamp: "3 days ago", icon: "sparkles", badge: nil, visualState: .default, goalTarget: GoalRouteTarget(goalID: "goal-native"), timeRoute: nil)
            ]
        ),
        trendTitle: "Pattern truth",
        trendSubtitle: "Microcharts support the read. They do not replace it.",
        timeframeLabel: "This week",
        trendPoints: [
            TrendPoint(id: "mon", label: "M", value: 0.48),
            TrendPoint(id: "tue", label: "T", value: 0.56),
            TrendPoint(id: "wed", label: "W", value: 0.68),
            TrendPoint(id: "thu", label: "T", value: 0.61),
            TrendPoint(id: "fri", label: "F", value: 0.79),
            TrendPoint(id: "sat", label: "S", value: 0.52),
            TrendPoint(id: "sun", label: "S", value: 0.73)
        ],
        trendSummary: "Execution improved once the week narrowed to one clear hardening pass.",
        activitiesTitle: "Recent signals",
        activitiesSubtitle: "Recent evidence, decisions, and changes that explain the current readout.",
        activities: [
            ActivitySummary(id: "activity-1", title: "Completed deep work block", subtitle: "Close the hardening pass", timestamp: "40 min ago", icon: "checkmark.circle.fill", badge: "Win"),
            ActivitySummary(id: "activity-2", title: "Step was shrunk", subtitle: "Retention loop", timestamp: "Yesterday", icon: "arrow.triangle.branch", badge: "Adapted"),
            ActivitySummary(id: "activity-3", title: "Updated release validation notes", subtitle: "Close the hardening pass", timestamp: "3 days ago", icon: "sparkles", badge: nil)
        ]
    )
}
