import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: detail actions route through GoalDetailActionRequest, update visible stage state, announce the result, and retain proof receipt references.
struct GoalDetailScreen: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalDetailViewModel

    @MainActor
    init(target: GoalRouteTarget, viewModel: GoalDetailViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? GoalDetailViewModel(target: target))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.missionControlTimeSpine))
                case let .failed(message):
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine),
                        primaryAccessibilityIdentifier: "goal-detail.retry-button",
                        onPrimaryAction: {
                            _ = message
                            Task { await viewModel.refresh(using: featureFactory.goalsService) }
                        }
                    )
                case let .loaded(detail):
                    GoalDetailProfileSurface(detail: detail)

                    GoalDetailHandoffSurface(
                        detail: detail,
                        onOpenToday: { openTodayHandoff(for: detail) },
                        onOpenTime: { openTimeHandoff(for: detail) },
                        onCapture: { openCaptureHandoff(for: detail) }
                    )

                    if let missionControl = detail.missionControl {
                        GoalDetailLaneSpineSurface(state: missionControl)
                    }

                    if let inlineMessage = viewModel.inlineMessage {
                        AppCard(state: inlineMessage.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(inlineMessage.title)
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(inlineMessage.body)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }

                    GoalDetailLensSwitcher(selectedLens: $viewModel.lens)

                    if let nextMovement = detail.nextMovement {
                        GoalDetailNextMovementSurface(movement: nextMovement)
                    }

                    GoalDetailPathFieldSurface(detail: detail, isReviewingPath: viewModel.lens == .path) { action in
                        Task { await viewModel.perform(action, using: featureFactory.goalsService) }
                    }

                    if viewModel.lens == .path {
                        GoalDetailPathDepthSurface(detail: detail)
                    }

                    GoalDetailJournalSurface(detail: detail)

                    if let explainability = detail.explainability {
                        GoalTrustWhisperSurface(
                            state: explainability,
                            isExpanded: $viewModel.isTrustExpanded
                        )
                    }

                    if let missionControl = detail.missionControl {
                        GoalDetailReviewTrailSurface(state: missionControl.reviewTrail)
                    }

                    GoalMemoryNarrativeSurface(
                        detail: detail,
                        isExpanded: $viewModel.isMemoryExpanded
                    )

                    if let clarification = detail.clarification {
                        GoalDetailSectionSurface(title: clarification.title, subtitle: clarification.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(clarification.questions) { question in
                                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                        Text(question.prompt)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                        Text(question.rationale)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                        Text("Safe default: \(question.gentleDefault)")
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textTertiary)
                                        TextField(
                                            "Write the smallest real answer",
                                            text: Binding(
                                                get: { viewModel.clarificationAnswers[question.id, default: question.existingAnswer ?? ""] },
                                                set: { viewModel.clarificationAnswers[question.id] = $0 }
                                            ),
                                            axis: .vertical
                                        )
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.top, theme.spacing.xs)
                                        Button("Save answer") {
                                            Task { await viewModel.saveClarificationAnswer(question, using: featureFactory.goalsService) }
                                        }
                                        .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                                        .padding(.top, theme.spacing.xs)
                                    }
                                    .padding(theme.spacing.sm)
                                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                                }
                            }
                        }
                    }

                    if let blocked = detail.blocked {
                        GoalDetailSectionSurface(title: blocked.title, subtitle: blocked.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(blocked.blockers, id: \.self) { blocker in
                                    Label(blocker, systemImage: "exclamationmark.triangle.fill")
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    GoalDetailSectionSurface(title: "Operations", subtitle: "Only available actions are shown. Unsupported path edits stay out of the control surface.") {
                        GoalActionGrid(actions: detail.actions) { action in
                            Task { await viewModel.perform(action, using: featureFactory.goalsService) }
                        }
                    }

                    if detail.suggestions.isEmpty == false {
                        GoalDetailSectionSurface(title: "Suggested steps", subtitle: "The calmest contained steps that still create signal.") {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.suggestions) { step in
                                    GoalSuggestionSurface(step: step)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("goal-detail.screen")
        .scrollIndicators(.hidden)
        .background(theme.colors.canvas.stageOwnedIgnoresSafeArea())
        .refreshable {
            await viewModel.refresh(using: featureFactory.goalsService)
        }
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.colors.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.inlineMessage?.title)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.lens)
        .task {
            await viewModel.load(using: featureFactory.goalsService)
        }
    }

    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    func openTodayHandoff(for detail: GoalDetailPresentation) {
        shell.navigation.selectToday(entryContext: .standard)
        shell.navigation.recordRoute(
            title: "Open Today from goal",
            source: .goalsCreate,
            presentationContext: .recall,
            destination: .tab(.today),
            receiptBody: "Opened Today from \(detail.headline.title) with goal context preserved locally."
        )
    }

    func openTimeHandoff(for detail: GoalDetailPresentation) {
        shell.navigation.openTimeRoute(.weeklyReview)
        shell.navigation.recordRoute(
            title: "Open Time from goal",
            source: .goalsCreate,
            presentationContext: .time,
            destination: .timeRoute(.weeklyReview),
            receiptBody: "Opened Time review from \(detail.headline.title) so schedule fit can be inspected before placement."
        )
    }

    func openCaptureHandoff(for detail: GoalDetailPresentation) {
        shell.navigation.presentTypedCaptureComposer(
            kind: .stepSeed,
            source: .goalsCreate,
            goalID: detail.target.goalID,
            seedText: detail.nextMovement?.title ?? detail.headline.title
        )
    }
}

private struct GoalDetailHandoffSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation
    let onOpenToday: () -> Void
    let onOpenTime: () -> Void
    let onCapture: () -> Void

    var body: some View {
        GoalDetailSectionSurface(
            title: "Use this goal",
            subtitle: "Start, schedule, or add context without widening the app."
        ) {
            HStack(spacing: theme.spacing.sm) {
                handoffButton("Today", systemImage: "sun.max", identifier: "goal-detail.handoff.today", action: onOpenToday)
                handoffButton("Time", systemImage: "clock.badge", identifier: "goal-detail.handoff.time", action: onOpenTime)
                handoffButton("Capture", systemImage: "square.and.pencil", identifier: "goal-detail.handoff.capture", action: onCapture)
            }

            Text(handoffSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("goal-detail.handoff-strip")
    }

    private var handoffSummary: String {
        if let next = detail.nextMovement {
            return "Next step: \(next.title). The goal stays inspectable here while Today and Time receive only the needed context."
        }
        return "No next step is forced. Add context first, then decide what Today or Time should carry."
    }

    private func handoffButton(
        _ title: String,
        systemImage: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(theme.typography.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .accessibilityIdentifier(identifier)
    }
}

private struct GoalDetailLaneSpineSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailMissionControlState

    var body: some View {
        GoalDetailSectionSurface(
            title: "Goal read",
            subtitle: state.currentTruth
        ) {
            MissionControlTimeSpine(
                items: state.lanes.map(MissionControlLaneItem.init(detailLane:)),
                defaultSelectedID: GoalDetailMissionLaneKind.overview.rawValue
            )

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                TagPill(state.ownershipLabel, state: .selected)
                TagPill(state.proofBoundaryLabel, state: state.proofRail.items.isEmpty ? .default : .success)
            }
            .accessibilityElement(children: .combine)
        }
        .accessibilityIdentifier("goal-detail.lane-spine")
    }
}

private struct GoalDetailLensSwitcher: View {
    @Environment(\.ambitionTheme) private var theme

    @Binding var selectedLens: GoalDetailLens

    var body: some View {
        Picker("Goal detail mode", selection: $selectedLens) {
            ForEach(GoalDetailLens.allCases, id: \.self) { lens in
                Text(lens.title).tag(lens)
            }
        }
        .pickerStyle(.segmented)
        .padding(theme.spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfacePrimary.opacity(0.64))
        )
        .accessibilityIdentifier("goal-detail.depth-lens")
    }
}

private struct GoalDetailPathDepthSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            content
        }
        .padding(.top, theme.spacing.lg * 3)
    }

    @ViewBuilder
    private var content: some View {
        if let pathBuilder = detail.pathBuilder {
            GoalPathBuilderSurface(state: pathBuilder)
            LifePathThreadSurface(state: LifePathThreadState(stages: detail.pathStages, pathBuilder: pathBuilder))
            if let missionControl = detail.missionControl {
                GoalAlternatePathDecisionSpine(
                    state: GoalAlternatePathDecisionSpineState(
                        decisions: missionControl.decisions,
                        pathBuilder: pathBuilder
                    )
                )
                GoalDetailTimelineSurface(state: missionControl.timeline)
                GoalDetailProofRailSurface(state: missionControl.proofRail)
                GoalDetailAssumptionsSurface(assumptions: missionControl.assumptions)
                GoalDetailReceiptsSurface(state: missionControl.receipts)
            }
        } else if let missionControl = detail.missionControl {
            GoalDetailTimelineSurface(state: missionControl.timeline)
            GoalDetailProofRailSurface(state: missionControl.proofRail)
            GoalDetailAssumptionsSurface(assumptions: missionControl.assumptions)
        }
    }
}
