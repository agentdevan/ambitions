import AmbitionsDesignSystem
import SwiftUI

struct YouMonthlyReviewSurface: View {
    var body: some View {
        YouReflectionRouteSurface(accessibilityIdentifier: "insights.monthly-review.screen") { dashboard, actions in
            AnyView(VStack(alignment: .leading, spacing: actions.theme.spacing.lg) {
                InsightsRouteHeroSurface(
                    eyebrow: "Review",
                    title: "Monthly reflection",
                    subtitle: "Carry the strongest pattern truth into a calmer review layer rather than a report.",
                    dominantTruth: dashboard.hero.editorialSummary,
                    trustWhisper: dashboard.hero.trustWhisper,
                    state: dashboard.hero.visualState
                )

                InsightsComparePeriodSurface(compare: dashboard.comparePeriod)

                InsightsReviewConstellationSurface(
                    state: dashboard.reviewConstellation,
                    onOpenGoal: actions.openGoal,
                    onOpenTimeRoute: actions.openTimeRoute
                )

                AppCard {
                    VStack(alignment: .leading, spacing: actions.theme.spacing.md) {
                        SectionHeader(
                            title: "Review shaping",
                            subtitle: "Reflection matters when it changes what the next review protects, lightens, or questions."
                        )
                        Text("Use Weekly Review when this pattern truth should reshape the week. Use Goal Detail when the learning belongs to one active path.")
                            .font(actions.theme.typography.body)
                            .foregroundStyle(actions.theme.colors.textSecondary)

                        VStack(alignment: .leading, spacing: actions.theme.spacing.sm) {
                            Button {
                                actions.announce("Opening weekly review from monthly reflection.", proofArtifactID: "you.monthly-review.weekly-review.route")
                                actions.openTimeRoute(.weeklyReview)
                            } label: {
                                InsightsRouteActionRow(
                                    title: "Open weekly review",
                                    subtitle: "Carry this reflection back into the week without losing context.",
                                    state: .selected
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("insights.monthly-review.open-weekly-review")

                            if let goalTarget = dashboard.reviewConstellation.items.first(where: { $0.goalTarget != nil })?.goalTarget {
                                Button {
                                    actions.announce("Opening the clearest active goal from monthly reflection.", proofArtifactID: "you.monthly-review.goal.route")
                                    actions.openGoal(goalTarget)
                                } label: {
                                    InsightsRouteActionRow(
                                        title: "Open the clearest active goal",
                                        subtitle: "Inspect the path where this reflection is most actionable.",
                                        state: .default
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("insights.monthly-review.open-goal")
                            }
                        }
                    }
                }
            })
        }
        .accessibilityHint("Monthly reflection routes use runtime mutation, visible stage mutation, accessibility announcement, and proof artifact identifiers.")
    }
}
