import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.appContainer) private var container
    @State private var state: AsyncViewState<GoalsDashboard> = .loading

    var body: some View {
        FeatureScaffoldView(
            title: "Goals",
            subtitle: "Ambition planning is now framed as a native module, with the TypeScript engine kept only as behavioral reference."
        ) {
            switch state {
            case .loading:
                ProgressView("Loading goals")
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let .failed(message):
                Text(message)
                    .foregroundStyle(.secondary)
            case let .loaded(dashboard):
                WidgetFeed(items: [
                    WidgetFeedItem(id: "goals-list", priority: .hero, variant: .expanded) {
                        GoalsListWidget(viewModel: goalsViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "goals-milestone", priority: .high, variant: .expanded) {
                        MilestonePromptWidget(viewModel: milestoneViewModel(dashboard), onAction: handleAction)
                    }
                ])
            }
        }
        .navigationTitle("Goals")
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await container.goalsService.loadGoalsDashboard())
        } catch {
            state = .failed("Unable to load Goals: \(error.localizedDescription)")
        }
    }

    private func handleAction(_ action: WidgetAction) {
        Task {
            await container.actionRouter.handle(action)
        }
    }

    private func goalsViewModel(_ dashboard: GoalsDashboard) -> GoalsListWidgetViewModel {
        GoalsListWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .goalsList, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.openDetail, .refinePlan]
                ),
                state: .ready(
                    GoalsListContent(
                        title: dashboard.title,
                        subtitle: dashboard.subtitle,
                        goals: dashboard.goals.map {
                            GoalsListItem(
                                id: $0.id,
                                title: $0.title,
                                subtitle: $0.subtitle,
                                progressLabel: $0.progressLabel,
                                statusLabel: $0.statusLabel
                            )
                        },
                        actions: [
                            WidgetInlineActionDescriptor(kind: .refinePlan, title: "Refine", icon: "slider.horizontal.3"),
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Review", icon: "arrow.right.circle")
                        ]
                    )
                )
            )
        )
    }

    private func milestoneViewModel(_ dashboard: GoalsDashboard) -> MilestonePromptWidgetViewModel {
        MilestonePromptWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .milestonePrompt, instanceID: "primary"),
                    priority: .high,
                    variant: .expanded,
                    chrome: .heroCard,
                    supportedActions: [.openDetail]
                ),
                state: .ready(
                    MilestonePromptContent(
                        title: dashboard.milestone.title,
                        subtitle: dashboard.milestone.subtitle,
                        prompt: dashboard.milestone.prompt,
                        confidenceLabel: dashboard.milestone.confidenceLabel,
                        actions: [
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Promote milestone", icon: "flag.checkered")
                        ]
                    )
                )
            )
        )
    }
}

#Preview("Goals") {
    NavigationStack {
        GoalsScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
