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
                    state: DegradedStateOrchestrator.unavailable(surface: "Capture"),
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
                title: "What needs a place?",
                subtitle: "Capture first. Smart Attachment suggests a place, saves a receipt, and keeps the route easy to change.",
                icon: "tray.and.arrow.down",
                explanationTitle: viewState.captures.isEmpty ? "Empty state" : "Open routing",
                explanation: viewState.captures.isEmpty ? "Not everything needs to become a goal." : "\(viewState.captures.filter { $0.status != .archived }.count) item\(viewState.captures.filter { $0.status != .archived }.count == 1 ? "" : "s") still have a visible destination.",
                accessibilityLabel: "Capture intake"
            )
        ) {
            EmptyView()
        } contentSlot: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { viewModel.draftText },
                        set: { viewModel.updateDraftText($0) }
                    ))
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
                        .accessibilityLabel("What needs a place?")

                    if viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("What needs a place?")
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textTertiary)
                            .padding(.horizontal, theme.spacing.md)
                            .padding(.vertical, theme.spacing.md)
                            .allowsHitTesting(false)
                    }
                }

                if let draftError = viewModel.draftError {
                    Text(draftError)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.warning)
                }

                if let routePreview = viewModel.draftRoutePreview {
                    draftRoutePreviewCard(routePreview)
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
                        Label("Save", systemImage: "plus.circle.fill")
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

    private func draftRoutePreviewCard(_ preview: CaptureDraftRoutePreview) -> some View {
        CaptureDraftRoutePreviewCard(preview: preview) { routeType in
            viewModel.selectDraftRoute(routeType)
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
            CaptureGroup(title: "Needs a Place", subtitle: "Raw thoughts and assumptions that should stay correctable.", captures: active),
            CaptureGroup(title: "Placed", subtitle: "Items with a visible destination but no Plan scheduling here.", captures: routed),
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
                    Label("Task", systemImage: "checkmark.circle")
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
                        await viewModel.saveToNeedsPlace(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Keep here", systemImage: "tray.full")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .needsTriage) == false)

                Menu("Attach proof") {
                    if activeGoalOptions.isEmpty {
                        Text("No active goals")
                    } else {
                        ForEach(activeGoalOptions) { option in
                            Button(option.title) {
                                Task {
                                    if let target = await viewModel.attachToGoal(
                                        captureID: capture.id,
                                        goalID: option.id,
                                        goalTitle: option.title,
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
                    Label("Idea", systemImage: "lightbulb")
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
                    Label("Review later", systemImage: "moon")
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

private struct CaptureDraftRoutePreviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: CaptureDraftRoutePreview
    let onSelect: (SmartAttachmentRouteType) -> Void

    private var visualState: AmbitionVisualState {
        preview.semanticState == SmartAttachmentResultState.needsClarification.rawValue ? .warning : .selected
    }

    var body: some View {
        AppCard(state: visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                routeSummary
                clarificationQuestion
                routeChoices
            }
            .padding(theme.spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.accessibilityLabel)
        .accessibilityValue(preview.accessibilityValue)
        .accessibilityHint(preview.accessibilityHint ?? "Choose a different route if this is not right.")
        .accessibilityIdentifier("captures.smart-attachment-preview")
    }

    private var routeSummary: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(preview.receiptTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(preview.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(preview.destinationLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var clarificationQuestion: some View {
        if let question = preview.clarificationQuestion {
            Text(question)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }

    private var routeChoices: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(preview.choices) { choice in
                Button {
                    onSelect(choice.routeType)
                } label: {
                    Text(choice.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: choice.isSelected ? .selected : .default))
                .accessibilityIdentifier("captures.route-choice.\(choice.routeType.rawValue)")
            }
        }
    }
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
        case .planSupport: "Capture"
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
