import AmbitionsDesignSystem
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalsViewModel

    init(viewModel: GoalsViewModel = GoalsViewModel()) {
        _viewModel = State(initialValue: viewModel)
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
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.goalsService)
        }
    }

    private func emptyMessage(for filter: GoalsFilter, fallback: String) -> String {
        switch filter {
        case .active:
            fallback
        case .onHold:
            return "Nothing is paused right now. Ambitions can stay focused on what is actually in motion."
        case .achieved:
            return "Completed goals will collect here once the current wave closes cleanly."
        }
    }
}

#Preview("Goals Overview") {
    NavigationStack {
        GoalsScreen(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
