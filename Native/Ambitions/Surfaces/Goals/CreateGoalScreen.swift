import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: submit routes through GoalsService.createGoal, updates the visible Goals stage on success, announces completion through the owning shell, and stores the local goal creation proof receipt.
struct CreateGoalScreen: View {
    @Environment(\.appFeatureFactoryCapability) var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) var theme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.dismiss) var dismiss
    @State var viewModel: CreateGoalViewModel
    let onCreated: (CreateGoalResponse) -> Void

    @MainActor
    init(
        viewModel: CreateGoalViewModel? = nil,
        onCreated: @escaping (CreateGoalResponse) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel ?? CreateGoalViewModel())
        self.onCreated = onCreated
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                createGoalObjectStage

                if case let .failed(message) = viewModel.submissionState {
                    EmptyStateCard(
                        title: "Goal setup paused",
                        message: message,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Try again"
                    ) {
                        viewModel.submissionState = .idle
                    }
                }

                if let handoff = viewModel.captureGoalHandoff {
                    captureGoalHandoffCard(handoff)
                }

                switch viewModel.previewState {
                case .idle:
                    if viewModel.trimmedTitle.isEmpty == false {
                        LoadingSkeletonCard(lineCount: 5)
                    }
                case .loading:
                    LoadingSkeletonCard(lineCount: 7)
                case let .failed(message):
                    AppCard(state: .warning) {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            SectionHeader(
                                title: "Goal preview paused",
                                subtitle: "Ambitions could not shape the path just yet."
                            )
                            Text(message)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .padding(theme.spacing.lg)
                    }
                case let .loaded(preview):
                    if let clarification = preview.clarification {
                        clarificationCard(clarification)
                    }

                    strategyCard(preview)

                    goalSeedReviewSection(preview.goalSeedReviewState)

                    if let feasibility = preview.feasibility {
                        feasibilityCard(feasibility, preview: preview)
                    }

                    if preview.pathStages.isEmpty == false || preview.milestonePreview.isEmpty == false {
                        milestoneCard(preview)
                    }

                    trustCard(preview.trust)
                }

                Button {
                    Task {
                        if let response = await viewModel.submit(
                            using: featureFactory.goalsService,
                            runtimeCommandClient: featureFactory.runtimeCommandClient
                        ) {
                            onCreated(response)
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(theme.colors.textPrimary)
                        }
                        Text(submitButtonTitle)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                .disabled(viewModel.canSubmit == false)
                .accessibilityIdentifier("create-goal.submit-button")
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.canvas.stageOwnedIgnoresSafeArea())
        .navigationTitle("Create goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.colors.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .presentationBackground(theme.colors.canvas)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(viewModel.isSubmitting)
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.previewKey)
        .task {
            guard viewModel.isSubmitting == false else { return }
            viewModel.schedulePreviewRefresh(using: featureFactory.goalsService)
        }
        .onChange(of: viewModel.previewInputKey, initial: false) { _, _ in
            guard viewModel.isSubmitting == false else { return }
            viewModel.schedulePreviewRefresh(using: featureFactory.goalsService)
        }
        .onDisappear {
            viewModel.cancelPreviewRefresh()
        }
    }

}
#if DEBUG
#Preview("Create Goal Empty") {
    NavigationStack {
        CreateGoalScreen(viewModel: CreateGoalViewModel())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Create Goal Capture Seed") {
    NavigationStack {
        CreateGoalScreen(
            viewModel: CreateGoalViewModel(
                title: "Review the notification handoff copy before the next hardening pass.",
                entrySource: .globalCaptureComposer,
                captureID: "preview-capture-2"
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
