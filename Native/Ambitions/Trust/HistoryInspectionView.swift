import AmbitionsDesignSystem
import SwiftUI

struct HistoryInspectionView: View {
    var body: some View {
        YouReflectionRouteSurface(accessibilityIdentifier: "insights.history.screen") { dashboard, actions in
            AnyView(VStack(alignment: .leading, spacing: actions.theme.spacing.lg) {
                InsightsRouteHeroSurface(
                    eyebrow: "History",
                    title: "Deep history",
                    subtitle: "The summary layer stays fast. This route makes the recent evidence and corrections feel alive and trustworthy.",
                    dominantTruth: dashboard.historyLayer.summaryTitle,
                    trustWhisper: dashboard.historyLayer.summaryDetail,
                    state: dashboard.hero.visualState
                )

                InsightsTimelineSurface(
                    title: dashboard.historyLayer.title,
                    subtitle: dashboard.historyLayer.subtitle,
                    items: dashboard.historyLayer.timelineItems,
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