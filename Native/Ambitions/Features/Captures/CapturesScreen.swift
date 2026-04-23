import AmbitionsDesignSystem
import SwiftUI

struct CapturesScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = CapturesViewModel()

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Inbox",
            title: "Captures",
            subtitle: "Review local captures collected from Ambitions and other on-device entry points."
        ) {
            switch viewModel.state {
            case .loading:
                LoadingSkeletonCard(lineCount: 6)
                    .transition(.ambitionPanel)
            case let .failed(message):
                EmptyStateCard(
                    title: "Captures are unavailable",
                    message: message,
                    icon: "tray.full",
                    actionTitle: "Retry",
                    actionAccessibilityIdentifier: "captures.retry-button"
                ) {
                    Task { await load() }
                }
                .transition(.ambitionPanel)
            case let .loaded(viewState):
                if viewState.captures.isEmpty {
                    EmptyStateCard(
                        title: "No captures yet",
                        message: "Local captures created in this build appear here once they are saved. Share Extension is not shipped in this build, and navigation shortcuts do not create captures in this batch.",
                        icon: "tray"
                    )
                    .transition(.ambitionPanel)
                } else {
                    LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                        if let message = viewModel.actionMessage {
                            AppCard {
                                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                    Text(message.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(message.body)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        ForEach(viewState.captures) { capture in
                            AppCard {
                                VStack(alignment: .leading, spacing: theme.spacing.md) {
                                    Text(capture.rawText)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(metadataText(for: capture))
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .accessibilityIdentifier("captures.metadata.\(capture.id)")

                                    captureActions(for: capture, activeGoalOptions: viewState.activeGoalOptions)
                                }
                            }
                            .accessibilityIdentifier("captures.card.\(capture.id)")
                        }
                    }
                    .transition(.ambitionPanel)
                }
            }
        }
        .navigationTitle("Captures")
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("captures.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            guard case .loading = viewModel.state else { return }
            await load()
        }
    }

    private func load() async {
        await viewModel.load(captureService: container.captureService, goalsService: container.goalsService)
    }

    private func metadataText(for capture: Capture) -> String {
        var parts = [capture.status.title]
        if let sourceType = capture.sourceType {
            parts.append(sourceLabel(for: sourceType))
        }
        if let destination = capture.triage?.destination {
            parts.append(destination.title)
        }
        if let revisitAfter = capture.revisitAfter {
            parts.append("Revisit after \(revisitAfter)")
        }
        parts.append(capture.updatedAt)
        return parts.joined(separator: " • ")
    }

    private func sourceLabel(for sourceType: CaptureSourceType) -> String {
        sourceType.title
    }

    @ViewBuilder
    private func captureActions(for capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Button("Save as seed") {
                Task {
                    await viewModel.saveAsSeed(
                        id: capture.id,
                        captureService: container.captureService,
                        goalsService: container.goalsService
                    )
                }
            }
            .buttonStyle(.bordered)
            .disabled(capture.status.canTransition(to: .seed) == false)

            Button("New goal") {
                container.commandRouter.presentCreateGoal(
                    source: .capturesScreen,
                    seedText: capture.rawText,
                    captureID: capture.id
                )
            }
            .buttonStyle(.borderedProminent)
            .disabled(canPromoteCaptureToGoal(capture) == false)
            .accessibilityIdentifier("captures.new-goal.\(capture.id)")

            Menu("Attach to goal") {
                if activeGoalOptions.isEmpty {
                    Text("No active goals")
                } else {
                    ForEach(activeGoalOptions) { option in
                        Button(option.title) {
                            Task {
                                if let target = await viewModel.attachToGoal(
                                    captureID: capture.id,
                                    goalID: option.id,
                                    captureService: container.captureService,
                                    goalsService: container.goalsService
                                ) {
                                    openGoal(target)
                                }
                            }
                        }
                    }
                }
            }
            .disabled(capture.status.canTransition(to: .goalBound) == false || activeGoalOptions.isEmpty)

            Button("Archive") {
                Task {
                    await viewModel.archive(
                        id: capture.id,
                        captureService: container.captureService,
                        goalsService: container.goalsService
                    )
                }
            }
            .buttonStyle(.bordered)
            .disabled(capture.status.canTransition(to: .archived) == false)
        }
        .font(theme.typography.caption)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        guard let goalID = target.goalID else { return }
        container.navigation.openGoalDetail(goalID: goalID, draftID: target.draftID)
    }

    private func canPromoteCaptureToGoal(_ capture: Capture) -> Bool {
        switch capture.status {
        case .seed, .actionable:
            return true
        case .goalBound, .scheduled, .delegated, .archived:
            return false
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

#if DEBUG
#Preview("Captures Light") {
    NavigationStack {
        CapturesScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Captures Dark") {
    NavigationStack {
        CapturesScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
