import AmbitionsDesignSystem
import SwiftUI
import UIKit

struct YouReflectionRouteSurface: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = YouHistoryViewModel()
    let accessibilityIdentifier: String
    let content: (InsightsDashboard, RouteActions) -> AnyView

    init(
        accessibilityIdentifier: String,
        content: @escaping (InsightsDashboard, RouteActions) -> AnyView
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 8))
                case let .failed(message):
                    AsyncStateCard(
                        .error(title: "Reflection is unavailable", message: message, icon: "chart.line.uptrend.xyaxis", actionTitle: "Retry"),
                        actionAccessibilityIdentifier: "insights.route.retry-button"
                    ) {
                        Task { await viewModel.refresh(using: featureFactory.insightsService) }
                    }
                case let .loaded(dashboard):
                    content(dashboard, routeActions)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: featureFactory.insightsService)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(viewModel.accessibilitySummary)
        .accessibilityHint("Reflection routes use stage route mutation, visible navigation, accessibility announcement, and proof artifact identifiers.")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: featureFactory.insightsService)
        }
    }

    private var routeActions: RouteActions {
        RouteActions(
            theme: theme,
            openGoal: { target in
                UIAccessibility.post(notification: .announcement, argument: "Opening goal from reflection history.")
                shell.navigation.openGoalDetail(target)
            },
            openTimeRoute: { route in
                UIAccessibility.post(notification: .announcement, argument: "Opening Time from reflection history.")
                shell.navigation.openTimeRoute(route)
            },
            openTimelineItem: { item in
                if let goalTarget = item.goalTarget {
                    UIAccessibility.post(notification: .announcement, argument: "Opening timeline goal from history inspection.")
                    shell.navigation.openGoalDetail(goalTarget)
                } else if let timeRoute = item.timeRoute {
                    UIAccessibility.post(notification: .announcement, argument: "Opening timeline Time route from history inspection.")
                    shell.navigation.openTimeRoute(timeRoute)
                }
            }
        )
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    struct RouteActions {
        let theme: AmbitionTheme
        let openGoal: (GoalRouteTarget) -> Void
        let openTimeRoute: (TimeRouteTarget) -> Void
        let openTimelineItem: (InsightsTimelineItem) -> Void

        @MainActor
        func announce(_ message: String, proofArtifactID: String) {
            _ = proofArtifactID
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}
