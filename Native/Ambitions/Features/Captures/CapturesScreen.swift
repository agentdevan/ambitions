import AmbitionsDesignSystem
import SwiftUI

enum CapturesScreenShellMode: Equatable {
    case planSupport
    case topLevelCapture
}

struct CapturesScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = CapturesViewModel()
    private let shellMode: CapturesScreenShellMode

    init(shellMode: CapturesScreenShellMode = .planSupport) {
        self.shellMode = shellMode
    }

    var body: some View {
        FeatureScaffoldView(
            eyebrow: shellMode.eyebrow,
            title: shellMode.title,
            subtitle: shellMode.subtitle
        ) {
            switch viewModel.state {
            case .loading:
                LoadingSkeletonCard(lineCount: 6)
                    .transition(.ambitionPanel)
            case .failed:
                DegradedStateCard(
                    state: DegradedStateOrchestrator.unavailable(surface: "Captures"),
                    primaryAccessibilityIdentifier: "captures.retry-button",
                    onPrimaryAction: {
                        Task { await load() }
                    }
                )
                .transition(.ambitionPanel)
            case let .loaded(viewState):
                intakePanel(viewState: viewState)
                .transition(.ambitionPanel)

                if viewState.captures.isEmpty {
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.capturesEmpty(),
                        primaryAccessibilityIdentifier: "captures.empty.capture-now",
                        secondaryAccessibilityIdentifier: shellMode == .planSupport ? "captures.empty.return-to-plan" : nil,
                        onPrimaryAction: {
                            container.commandRouter.presentCommandSheet(
                                intent: .quickCapture,
                                source: .capturesScreen,
                                presentationContext: .quickCapture
                            )
                        },
                        onSecondaryAction: shellMode == .planSupport ? {
                            container.navigation.resetPlanPath()
                        } : nil
                    )
                    .accessibilityIdentifier("captures.empty")
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

                        ForEach(groupedCaptures(viewState.captures), id: \.title) { group in
                            VStack(alignment: .leading, spacing: theme.spacing.md) {
                                SectionHeader(title: group.title, subtitle: group.subtitle)
                                ForEach(group.captures) { capture in
                                    captureCard(capture, activeGoalOptions: viewState.activeGoalOptions)
                                }
                            }
                        }
                    }
                    .transition(.ambitionPanel)
                }
            }
        }
        .navigationTitle(shellMode.title)
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

    private func intakePanel(viewState: CapturesViewState) -> some View {
        CapturePanel(
            AmbitionRichPanelConfiguration(
                kind: .capture,
                eyebrow: "Fast intake",
                title: "What do you need to get out of your head?",
                subtitle: "Capture first. Then route it as a one-time commitment, seed, waiting item, goal-supporting task, deliverable, someday item, or archive.",
                icon: "tray.and.arrow.down",
                explanationTitle: viewState.captures.isEmpty ? "Empty state" : "Open routing",
                explanation: viewState.captures.isEmpty ? "Not everything needs to become a goal." : "\(viewState.captures.filter { $0.status != .archived }.count) item\(viewState.captures.filter { $0.status != .archived }.count == 1 ? "" : "s") still have a visible destination.",
                accessibilityLabel: "Capture intake"
            )
        ) {
            EmptyView()
        } contentSlot: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                TextEditor(text: $viewModel.draftText)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(minHeight: 92)
                    .scrollContentBackground(.hidden)
                    .padding(theme.spacing.sm)
                    .background(theme.colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .stroke(theme.colors.strokeSubtle)
                    )
                    .accessibilityIdentifier("captures.quick-input")

                if let draftError = viewModel.draftError {
                    Text(draftError)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.warning)
                }

                HStack(spacing: theme.spacing.sm) {
                    Button {
                        Task {
                            await viewModel.createQuickCapture(
                                captureService: container.captureService,
                                goalsService: container.goalsService
                            )
                        }
                    } label: {
                        Label("Capture", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("captures.quick-submit")

                    if shellMode == .planSupport {
                        Button {
                            container.navigation.resetPlanPath()
                        } label: {
                            Label("Plan", systemImage: "calendar")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("captures.return-to-plan")
                    }
                }
            }
        }
    }

    private func metadataText(for capture: Capture) -> String {
        var parts = [capture.kind.title, capture.route.title, capture.triageStatus.title]
        if let sourceType = capture.sourceType {
            parts.append(sourceLabel(for: sourceType))
        }
        if let deadlineText = capture.deadlineText { parts.append("Deadline \(deadlineText)") }
        if let contextLensHint = capture.contextLensHint { parts.append(contextLensHint.displayTitle) }
        if let revisitAfter = capture.revisitAfter {
            parts.append("Revisit after \(revisitAfter)")
        }
        parts.append(capture.updatedAt)
        return parts.joined(separator: " • ")
    }

    private func sourceLabel(for sourceType: CaptureSourceType) -> String {
        sourceType.title
    }

    private func groupedCaptures(_ captures: [Capture]) -> [CaptureGroup] {
        let active = captures.filter { [.needsTriage, .actionable].contains($0.status) }
        let routed = captures.filter { [.seed, .goalBound, .scheduled, .delegated].contains($0.status) }
        let parked = captures.filter { [.waiting, .optionalSomeday, .archived].contains($0.status) }
        return [
            CaptureGroup(title: "Needs a route", subtitle: "Raw thoughts and assumptions that should stay correctable.", captures: active),
            CaptureGroup(title: "Routed", subtitle: "Items with an obvious destination but no Plan 2.0 scheduling here.", captures: routed),
            CaptureGroup(title: "Parked", subtitle: "Waiting, someday, and archived items stay findable without crowding the day.", captures: parked)
        ].filter { $0.captures.isEmpty == false }
    }

    private func captureCard(_ capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        AppCard(state: state(for: capture)) {
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

                if let assumption = capture.assumptionSummary {
                    Text(assumption)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                captureActions(for: capture, activeGoalOptions: activeGoalOptions)
            }
        }
    }

    private func state(for capture: Capture) -> AmbitionVisualState {
        switch capture.status {
        case .waiting:
            return .warning
        case .archived, .optionalSomeday:
            return .disabled
        case .goalBound, .scheduled:
            return .success
        case .needsTriage:
            return .selected
        case .seed, .actionable, .delegated:
            return .default
        }
    }

    @ViewBuilder
    private func captureActions(for capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.routeToPlan(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Plan seed", systemImage: "calendar.badge.plus")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .scheduled) == false)

                Button {
                    container.commandRouter.presentCreateGoal(
                        source: .capturesScreen,
                        seedText: capture.rawText,
                        captureID: capture.id
                    )
                } label: {
                    Label("New goal", systemImage: "target")
                }
                .buttonStyle(.borderedProminent)
                .disabled(canPromoteCaptureToGoal(capture) == false)
                .accessibilityIdentifier("captures.new-goal.\(capture.id)")
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.saveAsSeed(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Seed", systemImage: "sparkles")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .seed) == false)

                Menu("Attach") {
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
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.markDeliverableSeed(
                            id: capture.id,
                            text: capture.rawText,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Deliverable", systemImage: "shippingbox")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .seed) == false)

                Button {
                    Task {
                        await viewModel.markWaiting(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Waiting", systemImage: "hourglass")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .waiting) == false)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.markOptionalSomeday(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Someday", systemImage: "moon")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .optionalSomeday) == false)

                Button {
                    Task {
                        await viewModel.archive(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .archived) == false)
            }
        }
        .font(theme.typography.caption)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        guard let goalID = target.goalID else { return }
        container.navigation.openGoalDetail(goalID: goalID, draftID: target.draftID)
    }

    private func canPromoteCaptureToGoal(_ capture: Capture) -> Bool {
        switch capture.status {
        case .needsTriage, .seed, .actionable:
            return true
        case .goalBound, .scheduled, .delegated, .archived:
            return false
        case .waiting, .optionalSomeday:
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

private struct CaptureGroup {
    let title: String
    let subtitle: String
    let captures: [Capture]
}

private extension NowContextLens {
    var displayTitle: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .freeTime: "Free Time"
        case .admin: "Admin"
        case .creative: "Creative"
        case .recovery: "Recovery"
        case .deepFocus: "Deep Focus"
        case .all: "All"
        }
    }
}

private extension CapturesScreenShellMode {
    var eyebrow: String {
        switch self {
        case .planSupport: "Plan support"
        case .topLevelCapture: "Top-level intake"
        }
    }

    var title: String {
        switch self {
        case .planSupport: "Captures"
        case .topLevelCapture: "Capture"
        }
    }

    var subtitle: String {
        switch self {
        case .planSupport:
            "Absorb raw inputs into the current week so captures feel like part of the operating system, not a separate inbox product."
        case .topLevelCapture:
            "Hold raw inputs in one calm place until they are ready to become a goal, plan adjustment, seed, or archive."
        }
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
