import AmbitionsDesignSystem
import SwiftUI

struct HistoryInspectionView: View {
    var body: some View {
        YouReflectionRouteSurface(accessibilityIdentifier: "insights.history.screen") { historyProjection, actions in
            AnyView(VStack(alignment: .leading, spacing: actions.theme.spacing.lg) {
                InspectionSurface(kind: .history)

                InsightsRouteHeroSurface(
                    eyebrow: "History",
                    title: "Review history",
                    subtitle: "Recent evidence and corrections stay inspectable from their owning routes.",
                    dominantTruth: historyProjection.historyLayer.summaryTitle,
                    trustWhisper: historyProjection.historyLayer.summaryDetail,
                    state: historyProjection.hero.visualState
                )

                InsightsTimelineSurface(
                    title: historyProjection.historyLayer.title,
                    subtitle: historyProjection.historyLayer.subtitle,
                    items: historyProjection.historyLayer.timelineItems,
                    onOpenItem: actions.openTimelineItem
                )

                AppCard {
                    VStack(alignment: .leading, spacing: actions.theme.spacing.md) {
                        SectionHeader(
                            title: "Return with continuity",
                            subtitle: "History should lead somewhere useful, not strand you in recall."
                        )
                        Button {
                            actions.announce("Opening weekly review from history inspection.", proofArtifactID: "trust.history.weekly-review.route")
                            actions.openTimeRoute(.weeklyReview)
                        } label: {
                            InsightsRouteActionRow(
                                title: "Open weekly review",
                                subtitle: "Use the recent timeline to decide what to protect, lighten, or leave behind.",
                                state: .selected
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("insights.history.open-weekly-review")
                    }
                }
            })
        }
    }
}
