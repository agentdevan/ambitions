import AmbitionsDesignSystem
import SwiftUI

struct CreateGoalScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFieldFocused: Bool
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
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                HeroCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text(viewModel.captureID == nil ? "Goals" : "Grow into Goal")
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.accentWarm)

                        Text("Set up this goal")
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)

                        Text(heroSubtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .ambitionPanelAccessibility()

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

                intakeCard
                if let handoff = viewModel.captureGoalHandoff {
                    captureGoalHandoffCard(handoff)
                }
                composerHeroCard

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
                        if let response = await viewModel.submit(using: container.goalsService) {
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
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.previewKey)
        .task {
            guard viewModel.isSubmitting == false else { return }
            isTitleFieldFocused = true
            viewModel.schedulePreviewRefresh(using: container.goalsService)
        }
        .onChange(of: viewModel.previewInputKey, initial: false) { _, _ in
            guard viewModel.isSubmitting == false else { return }
            viewModel.schedulePreviewRefresh(using: container.goalsService)
        }
        .onDisappear {
            viewModel.cancelPreviewRefresh()
        }
    }

    private var composerHeroCard: some View {
        AppCard(state: heroVisualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Goal setup",
                    title: heroTitle,
                    subtitle: heroBody
                ) {
                    TagPill(heroBadgeTitle, state: heroVisualState)
                }

                HStack(spacing: theme.spacing.xs) {
                    TagPill(viewModel.selectedPace.rawValue.capitalized, icon: "dial.medium", state: .selected)
                    if let selectedTargetDate = viewModel.selectedTargetDateLabel {
                        TagPill("Date \(selectedTargetDate)", icon: "calendar", state: .default)
                    }
                    if viewModel.captureID != nil {
                        TagPill("Grow into Goal", icon: "tray.full", state: .default)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.hero-card")
            .padding(theme.spacing.lg)
        }
    }

    private var intakeCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Describe the goal plainly",
                    subtitle: "Name the outcome in normal language. Ambitions will shape a first path before anything is saved."
                )

                TextField("What do you want to make real?", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isSubmitting)
                    .focused($isTitleFieldFocused)
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

                Text("The first read keeps the goal focused on clarity, timing, and what can happen next.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .padding(theme.spacing.lg)
        }
    }

    private func captureGoalHandoffCard(_ handoff: CaptureGoalHandoffState) -> some View {
        AppCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    title: handoff.title,
                    subtitle: handoff.sourceLabel
                )

                Text(handoff.consequenceLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                HStack(spacing: theme.spacing.xs) {
                    TagPill(handoff.confirmationLabel, icon: "checkmark.seal", state: .selected)
                    TagPill(handoff.privacyLabel, icon: "lock", state: .default)
                }
            }
            .padding(theme.spacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("create-goal.capture-handoff")
    }

    private func clarificationCard(_ clarification: GoalClarificationState) -> some View {
        AppCard(state: .warning) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: clarification.title,
                    subtitle: clarification.subtitle
                )

                ForEach(clarification.questions) { question in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(question.prompt)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        Text(question.rationale)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)

                        TextField(
                            question.gentleDefault,
                            text: Binding(
                                get: { viewModel.answer(for: question.field) },
                                set: { viewModel.setAnswer($0, for: question.field) }
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.clarification-card")
            .padding(theme.spacing.lg)
        }
    }

    private func strategyCard(_ preview: CreateGoalPreviewState) -> some View {
        AppCard(state: preview.renderState.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Goal to path",
                    title: preview.normalizedTitle,
                    subtitle: preview.summary
                ) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(preview.modeLabel, state: .default)
                        TagPill(preview.renderState.title, state: preview.renderState.visualState)
                    }
                }

                if preview.blocked == nil {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text("What the path looks like")
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        if preview.pathStages.isEmpty {
                            Text("Ambitions is holding off on a path until the goal is clearer.")
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                        } else {
                            ForEach(preview.pathStages.prefix(3)) { stage in
                                HStack(alignment: .top, spacing: theme.spacing.sm) {
                                    Circle()
                                        .fill(theme.stateStyle(for: stage.state).accent)
                                        .frame(width: 8, height: 8)
                                        .padding(.top, theme.spacing.xs)

                                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                        Text(stage.title)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                        Text(stage.highlight ?? stage.summary)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                    }
                                    Spacer(minLength: theme.spacing.sm)
                                    TagPill(stage.stepCountLabel, state: stage.state)
                                }
                            }
                        }
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.strategy-card")
            .padding(theme.spacing.lg)
        }
    }

    private func feasibilityCard(
        _ feasibility: StrategyComposerFeasibilityState,
        preview: CreateGoalPreviewState
    ) -> some View {
        AppCard(state: feasibility.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: feasibility.title,
                    subtitle: feasibility.summary
                ) {
                    TagPill(preview.selectedPace.rawValue.capitalized, state: .selected)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Pacing")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)

                    ForEach(preview.paceOptions) { option in
                        Button {
                            viewModel.selectPace(option.choice)
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.md) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                    Text(option.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(option.subtitle)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                }

                                Spacer(minLength: theme.spacing.sm)
                                TagPill(option.badgeTitle, state: option.state)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(theme.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .fill(theme.stateStyle(for: option.state).fill)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .stroke(theme.stateStyle(for: option.state).stroke, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if feasibility.details.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Why it looks this way")
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        ForEach(Array(feasibility.details.prefix(3).enumerated()), id: \.offset) { entry in
                            Text("• \(entry.element)")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }

                if let deadlineGuidance = preview.deadlineGuidance {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(deadlineGuidance.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(deadlineGuidance.body)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)

                        Button {
                            viewModel.applySuggestedDeadline(deadlineGuidance.suggestedDate)
                        } label: {
                            HStack {
                                Text("Use \(deadlineGuidance.suggestedDate)")
                                Spacer()
                                TagPill(deadlineGuidance.badgeTitle, state: deadlineGuidance.state)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(AmbitionPressableButtonStyle(state: .warning))
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.feasibility-card")
            .padding(theme.spacing.lg)
        }
    }

    private func milestoneCard(_ preview: CreateGoalPreviewState) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Phase and milestone preview",
                    subtitle: "The first pass stays small enough to act on while still showing the shape of the path."
                )

                ForEach(preview.milestonePreview) { item in
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Text(item.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(item.summary)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer(minLength: theme.spacing.sm)
                        TagPill(item.timingLabel, state: .default)
                    }
                    .padding(.vertical, theme.spacing.xxs)
                }
            }
            .padding(theme.spacing.lg)
        }
    }

    private func trustCard(_ trust: StrategyComposerTrustState) -> some View {
        AppCard(state: trust.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: trust.title,
                    subtitle: "A calm first read on what Ambitions is using and what it is not pretending to know."
                ) {
                    TagPill(trust.badgeTitle, state: trust.state)
                }

                ForEach(Array(trust.lines.enumerated()), id: \.offset) { entry in
                    Text("• \(entry.element)")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.trust-card")
            .padding(theme.spacing.lg)
        }
    }

    private var heroSubtitle: String {
        viewModel.captureID == nil
            ? "Shape a first path before you save the goal."
            : "Grow the capture into a goal only after you confirm the setup."
    }

    private var heroTitle: String {
        switch viewModel.previewState {
        case .idle:
            return "Name the outcome first"
        case .loading:
            return "Shaping the first path"
        case let .failed(message):
            return message
        case let .loaded(preview):
            switch preview.resultKind {
            case .planned, .starterPlanned:
                return "A first path is visible"
            case .clarificationRequired:
                return "One clarification keeps the path honest"
            case .blocked:
                return "A blocker is visible before the goal goes live"
            }
        }
    }

    private var heroBody: String {
        switch viewModel.previewState {
        case .idle:
            return "Start with the goal in plain language. Ambitions will keep the first read focused on clarity, timing, and what can happen next."
        case .loading:
            return "Ambitions is shaping the setup without saving anything yet."
        case let .failed(message):
            return message
        case let .loaded(preview):
            if let feasibility = preview.feasibility {
                return feasibility.summary
            }
            if let clarification = preview.clarification {
                return clarification.subtitle
            }
            if let blocked = preview.blocked {
                return blocked.subtitle
            }
            return preview.summary
        }
    }

    private var heroBadgeTitle: String {
        switch viewModel.previewState {
        case .idle:
            return "Intake"
        case .loading:
            return "Preview"
        case .failed:
            return "Paused"
        case let .loaded(preview):
            return preview.renderState.title
        }
    }

    private var heroVisualState: AmbitionVisualState {
        switch viewModel.previewState {
        case .idle, .loading:
            return .selected
        case .failed:
            return .warning
        case let .loaded(preview):
            return preview.renderState.visualState
        }
    }

    private var submitButtonTitle: String {
        guard case let .loaded(preview) = viewModel.previewState else {
            return viewModel.isSubmitting ? "Saving..." : "Create Goal"
        }

        if viewModel.isSubmitting {
            return preview.resultKind == .planned || preview.resultKind == .starterPlanned ? "Creating Goal..." : "Saving Draft..."
        }

        switch preview.resultKind {
        case .planned, .starterPlanned:
            return "Create Goal"
        case .clarificationRequired, .blocked:
            return "Save Draft"
        }
    }

    private var goalTypeOptions: [GoalMode] {
        [.project, .achievement, .learning, .exploration, .maintenance]
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
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
                entrySource: .capturesScreen,
                captureID: "preview-capture-2"
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
