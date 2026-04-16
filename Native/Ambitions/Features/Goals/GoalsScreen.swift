import AmbitionsDesignSystem
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalsViewModel
    @State private var isCreateGoalPresented = false
    @State private var creationMessage: GoalDetailInlineMessage?

    @MainActor
    init(
        viewModel: GoalsViewModel? = nil,
        creationMessage: GoalDetailInlineMessage? = nil
    ) {
        _viewModel = State(initialValue: viewModel ?? GoalsViewModel())
        _creationMessage = State(initialValue: creationMessage)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    HeroCard {
                        SectionHeader(
                            eyebrow: "Roadmap",
                            title: "Goals",
                            subtitle: "Loading the current portfolio, draft states, and next-step signals."
                        )
                    }
                    LoadingSkeletonCard(lineCount: 8)
                case let .failed(message):
                    EmptyStateCard(
                        title: "Goals are unavailable",
                        message: message,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Retry"
                    ) {
                        Task { await viewModel.refresh(using: container.goalsService) }
                    }
                case let .loaded(overview):
                    GoalsHeroCard(overview: overview)

                    if let creationMessage {
                        AppCard(state: creationMessage.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(creationMessage.title)
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(creationMessage.body)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            SectionHeader(
                                title: "Portfolio",
                                subtitle: viewModel.selectedSort == .manualPriority
                                    ? "Priority now reads from the persisted manual ordering you can adjust in Goal Detail."
                                    : "Sort by the lens that best matches the kind of decision you need to make."
                            ) {
                                Menu {
                                    ForEach(GoalsSortOption.allCases, id: \.self) { sort in
                                        Button(sort.title) {
                                            viewModel.selectedSort = sort
                                        }
                                    }
                                } label: {
                                    Label(viewModel.selectedSort.title, systemImage: "arrow.up.arrow.down")
                                }
                                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                            }

                            SegmentedFilterBar(items: GoalsFilter.allCases, selection: $viewModel.selectedFilter) { filter in
                                let count = viewModel.filterCounts[filter] ?? 0
                                return "\(filter.title) (\(count))"
                            }

                            if viewModel.visibleItems.isEmpty {
                                EmptyStateCard(
                                    title: overview.emptyTitle,
                                    message: emptyMessage(for: viewModel.selectedFilter, fallback: overview.emptyMessage),
                                    icon: viewModel.selectedFilter == .achieved ? "sparkles" : "scope"
                                )
                            } else {
                                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                    ForEach(viewModel.visibleItems) { item in
                                        NavigationLink(value: item.target) {
                                            GoalRowCard(item: item)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: container.goalsService)
        }
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    creationMessage = nil
                    isCreateGoalPresented = true
                } label: {
                    Label("Create Goal", systemImage: "plus")
                }
                .accessibilityIdentifier("goals.create-button")
            }
        }
        .sheet(isPresented: $isCreateGoalPresented) {
            NavigationStack {
                CreateGoalScreen { response in
                    creationMessage = GoalDetailInlineMessage(
                        title: "Goal created",
                        body: "\(response.blueprint.title) is now in the portfolio with its first 3 steps.",
                        state: .success
                    )
                    Task {
                        await viewModel.refresh(using: container.goalsService)
                    }
                }
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: creationMessage?.title)
        .task {
            await viewModel.load(using: container.goalsService)
        }
    }

    private func emptyMessage(for filter: GoalsFilter, fallback: String) -> String {
        switch filter {
        case .active:
            return fallback
        case .onHold:
            return "Nothing is paused right now. Ambitions can stay focused on what is actually in motion."
        case .achieved:
            return "Completed goals will collect here once the current wave closes cleanly."
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

#Preview("Goals Overview") {
    NavigationStack {
        GoalsScreen(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goals After Create") {
    NavigationStack {
        GoalsScreen(
            viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.createdOverview)),
            creationMessage: GoalDetailInlineMessage(
                title: "Goal created",
                body: "Ship the native create goal flow is now in the portfolio with its first 3 steps.",
                state: .success
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
