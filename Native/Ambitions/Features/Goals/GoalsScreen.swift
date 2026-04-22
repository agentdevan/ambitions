import AmbitionsDesignSystem
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalsViewModel
    @State private var isCreateGoalPresented = false
    @State private var localCreationMessage: GoalDetailInlineMessage?
    private let externalCreationMessage: GoalDetailInlineMessage?
    private let externalRefreshID: Int
    private let showsNavigationChrome: Bool
    private let onCreateGoal: (() -> Void)?

    @MainActor
    init(
        viewModel: GoalsViewModel? = nil,
        creationMessage: GoalDetailInlineMessage? = nil,
        externalCreationMessage: GoalDetailInlineMessage? = nil,
        externalRefreshID: Int = 0,
        showsNavigationChrome: Bool = true,
        onCreateGoal: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel ?? GoalsViewModel())
        _localCreationMessage = State(initialValue: creationMessage)
        self.externalCreationMessage = externalCreationMessage
        self.externalRefreshID = externalRefreshID
        self.showsNavigationChrome = showsNavigationChrome
        self.onCreateGoal = onCreateGoal
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
                    AsyncStateCard(.loading(lines: 8))
                case let .failed(message):
                    AsyncStateCard(.error(title: "Goals are unavailable", message: message, actionTitle: "Retry")) {
                        Task { await viewModel.refresh(using: container.goalsService) }
                    }
                case let .loaded(overview):
                    GoalsHeroCard(overview: overview)

                    if let activeCreationMessage {
                        AppCard(state: activeCreationMessage.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(activeCreationMessage.title)
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(activeCreationMessage.body)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                        .accessibilityIdentifier("goals.creation-message")
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
                                        .accessibilityIdentifier("goals.open.\(item.target.goalID ?? item.target.draftID ?? item.id)")
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
        .accessibilityIdentifier("goals.screen")
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: container.goalsService)
        }
        .navigationTitle(showsNavigationChrome ? "Goals" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        localCreationMessage = nil
                        if let onCreateGoal {
                            onCreateGoal()
                        } else {
                            isCreateGoalPresented = true
                        }
                    } label: {
                        Label("Create Goal", systemImage: "plus")
                    }
                    .accessibilityIdentifier("goals.create-button")
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { showsNavigationChrome && isCreateGoalPresented },
            set: { isCreateGoalPresented = $0 }
        )) {
            NavigationStack {
                createGoalScreen
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: activeCreationMessage?.title)
        .onChange(of: externalRefreshID) { _, _ in
            guard externalRefreshID > 0 else { return }
            Task {
                await viewModel.refresh(using: container.goalsService)
            }
        }
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

    private var createGoalScreen: some View {
        CreateGoalScreen { response in
            let body: String = {
                switch response.resultKind {
                case .planned:
                    return "\(response.blueprint.title) is now in the portfolio with a canonical plan."
                case .starterPlanned:
                    return "\(response.blueprint.title) is now in the portfolio with a starter plan."
                case .clarificationRequired:
                    return "\(response.blueprint.title) needs one clarification before Ambitions treats it as a live goal."
                case .blocked:
                    return "\(response.blueprint.title) was saved as a blocked draft with the missing constraint visible."
                }
            }()
            localCreationMessage = GoalDetailInlineMessage(
                title: "Goal created",
                body: body,
                state: .success
            )
            Task {
                await viewModel.refresh(using: container.goalsService)
            }
        }
    }

    private var activeCreationMessage: GoalDetailInlineMessage? {
        externalCreationMessage ?? localCreationMessage
    }
}

#if DEBUG
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
#endif
