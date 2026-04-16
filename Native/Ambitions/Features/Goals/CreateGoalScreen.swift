import AmbitionsDesignSystem
import SwiftUI

struct CreateGoalScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateGoalViewModel

    private let onCreated: (CreateGoalResponse) -> Void

    @MainActor
    init(
        viewModel: CreateGoalViewModel? = nil,
        onCreated: @escaping (CreateGoalResponse) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel ?? CreateGoalViewModel())
        self.onCreated = onCreated
    }

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Goals",
            title: "Create Goal",
            subtitle: "Start with a clear title. Ambitions will generate a small deterministic first plan."
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                if case let .failed(message) = viewModel.submissionState {
                    EmptyStateCard(
                        title: "Goal could not be created",
                        message: message,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Try again"
                    ) {
                        viewModel.submissionState = .idle
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        SectionHeader(
                            title: "Goal title",
                            subtitle: "Keep it specific enough to plan, but small enough to act on."
                        )

                        TextField("What do you want to do?", text: $viewModel.title, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isSubmitting)
                            .accessibilityIdentifier("create-goal.title-field")

                        Picker("Goal type", selection: Binding<GoalMode?>(
                            get: { viewModel.selectedMode },
                            set: { viewModel.selectedMode = $0 }
                        )) {
                            Text("Auto-detect").tag(Optional<GoalMode>.none)
                            ForEach(goalTypeOptions, id: \.self) { mode in
                                Text(mode.displayTitle).tag(Optional(mode))
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(viewModel.isSubmitting)
                    }
                }

                AppCard(state: .default) {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            title: "What happens next",
                            subtitle: "The first pass stays local, deterministic, and conservative."
                        )
                        Text("Ambitions will create one goal, one initial micro-plan, and exactly three short first steps.")
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }

                Button {
                    Task {
                        if let response = await viewModel.submit(using: container.goalsService) {
                            onCreated(response)
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(theme.colors.textPrimary)
                        }
                        Text(viewModel.isSubmitting ? "Creating Goal..." : "Create Goal")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                .disabled(viewModel.canSubmit == false)
                .accessibilityIdentifier("create-goal.submit-button")
            }
        }
        .navigationTitle("Create Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(viewModel.isSubmitting)
            }
        }
    }

    private var goalTypeOptions: [GoalMode] {
        [.project, .achievement, .learning, .exploration, .maintenance]
    }
}

#Preview("Create Goal Empty") {
    NavigationStack {
        CreateGoalScreen(viewModel: CreateGoalViewModel())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Create Goal Input") {
    NavigationStack {
        CreateGoalScreen(
            viewModel: CreateGoalViewModel(
                title: "Ship the native create-goal flow",
                selectedMode: .project
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Create Goal Loading") {
    NavigationStack {
        CreateGoalScreen(
            viewModel: CreateGoalViewModel(
                title: "Learn SwiftUI layout",
                selectedMode: .learning,
                submissionState: .loading
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Create Goal Failure") {
    NavigationStack {
        CreateGoalScreen(
            viewModel: CreateGoalViewModel(
                title: "Plan a freelance pivot",
                submissionState: .failed("Unable to create Goal: A goal title is required before a native plan can be created.")
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
