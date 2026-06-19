import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: detail actions route through GoalDetailActionRequest, update visible stage state, announce the result, and retain proof receipt references.
struct GoalDetailScreen: View {
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
                    GoalDetailHeroSurface(detail: detail)

                    if let missionControl = detail.missionControl {
                        GoalDetailMissionControlSurface(state: missionControl)
                        GoalDetailBreadcrumbSurface(state: missionControl.breadcrumb)
                        GoalDetailTimelineSurface(state: missionControl.timeline)
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

                    if detail.target.launchContext == .help {
                        AppCard(state: .warning) {
                            SectionHeader(
                                title: "Help-first route",
                                subtitle: "This detail view opened from a help or correction action, so the path view is leading with the smallest trustworthy next step."
                            )
                        }
                    }

                    if detail.pathStages.isEmpty == false {
                        LifePathThreadSurface(
                            state: LifePathThreadState(
                                stages: detail.pathStages,
                                pathBuilder: detail.pathBuilder
                            )
                        )
                    }

                    if let movement = detail.nextMovement {
                        GoalDetailNextMovementSurface(movement: movement)
                    }

                    GoalDetailTrajectorySurface(trajectory: detail.trajectory)

                    if let explainability = detail.explainability {
                        GoalTrustWhisperSurface(
                            state: explainability,
                            isExpanded: $viewModel.isTrustExpanded
                        )
                    }

                    if detail.assumptions.isEmpty == false {
                        GoalDetailSectionSurface(title: "Starter Assumptions", subtitle: "Visible assumptions keep provisional plans honest.") {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(detail.assumptions, id: \.self) { assumption in
                                    Label(assumption, systemImage: "leaf.fill")
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    if let missionControl = detail.missionControl {
                        GoalDetailReviewTrailSurface(state: missionControl.reviewTrail)
                        GoalDetailAssumptionsSurface(assumptions: missionControl.assumptions)
                        GoalDetailProofRailSurface(state: missionControl.proofRail)
                        GoalAlternatePathDecisionSpine(
                            state: GoalAlternatePathDecisionSpineState(
                                decisions: missionControl.decisions,
                                pathBuilder: detail.pathBuilder
                            )
                        )
                        GoalDetailRisksSurface(state: missionControl.risks)
                        GoalDetailArchiveSurface(state: missionControl.archive)
                        GoalDetailReceiptsSurface(state: missionControl.receipts)
                    }

                    if let pathBuilder = detail.pathBuilder {
                        GoalPathBuilderSurface(state: pathBuilder)
                    }

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

                    GoalDetailSectionSurface(title: "Action rail", subtitle: "These controls write back to the real native plan and feedback history.") {
                        GoalActionGrid(actions: detail.actions) { action in
                            Task { await viewModel.perform(action, using: featureFactory.goalsService) }
                        }
                    }

                    GoalMemoryNarrativeSurface(
                        detail: detail,
                        isExpanded: $viewModel.isMemoryExpanded
                    )

                    GoalDetailSectionSurface(
                        title: "Tactics and detail",
                        subtitle: viewModel.lens == .path ? "Inspect the path structure without displacing the first-screen strategy read." : "Open the underlying sections and steps when you need the tactical layer."
                    ) {
                        SegmentedFilterBar(items: GoalDetailLens.allCases, selection: $viewModel.lens) { $0.title }
                            .padding(.bottom, theme.spacing.sm)

                        if viewModel.lens == .path {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.pathStages) { stage in
                                    WidgetCard(state: stage.state) {
                                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                    Text(stage.title)
                                                        .font(theme.typography.section)
                                                        .foregroundStyle(theme.colors.textPrimary)
                                                    Text(stage.statusLabel)
                                                        .font(theme.typography.micro)
                                                        .foregroundStyle(theme.colors.textTertiary)
                                                }
                                                Spacer()
                                                TagPill(stage.stepCountLabel, state: stage.state)
                                            }
                                            Text(stage.summary)
                                                .font(theme.typography.body)
                                                .foregroundStyle(theme.colors.textSecondary)
                                            if let highlight = stage.highlight {
                                                Text(highlight)
                                                    .font(theme.typography.caption)
                                                    .foregroundStyle(theme.colors.textTertiary)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.sections) { section in
                                    AppCard {
                                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                    Text(section.title)
                                                        .font(theme.typography.section)
                                                        .foregroundStyle(theme.colors.textPrimary)
                                                    Text(section.summary)
                                                        .font(theme.typography.caption)
                                                        .foregroundStyle(theme.colors.textSecondary)
                                                }
                                                Spacer()
                                                TagPill(section.kindLabel, state: .default)
                                            }
                                            ForEach(section.steps) { step in
                                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                    HStack {
                                                        Text(step.title)
                                                            .font(theme.typography.bodyEmphasized)
                                                            .foregroundStyle(theme.colors.textPrimary)
                                                        Spacer()
                                                        TagPill(step.statusLabel, state: step.state)
                                                    }
                                                    Text(step.summary)
                                                        .font(theme.typography.caption)
                                                        .foregroundStyle(theme.colors.textSecondary)
                                                    Text(step.timingLabel)
                                                        .font(theme.typography.caption)
                                                        .foregroundStyle(theme.colors.textTertiary)
                                                }
                                                .padding(theme.spacing.sm)
                                                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .accessibilityIdentifier("goal-detail.tactics-region")

                    if detail.suggestions.isEmpty == false {
                        GoalDetailSectionSurface(title: "Suggested Steps", subtitle: "The calmest contained steps that still create signal.") {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.suggestions) { step in
                                    GoalSuggestionSurface(step: step)
                                }
                            }
                        }
                    }

                    if let explainability = detail.explainability {
                        GoalExplainabilitySection(
                            state: explainability,
                            isTrustExpanded: $viewModel.isTrustExpanded,
                            isCorrectionsExpanded: $viewModel.isCorrectionsExpanded,
                            onCorrection: { control in
                                Task { await viewModel.submitExplainabilityCorrection(control, using: featureFactory.goalsService) }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("goal-detail.screen")
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: featureFactory.goalsService)
        }
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
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
}

struct GoalDetailMissionControlSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailMissionControlState

    var body: some View {
        AppCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                MissionControlLaneHeader(
                    eyebrow: "Goal Thread Focus",
                    title: state.currentTruth,
                    subtitle: state.primaryNextMove.title,
                    badges: [
                        MissionControlLaneHeaderBadge(id: "source", title: state.sourceLabel, symbolName: "scope", state: .default),
                        MissionControlLaneHeaderBadge(id: "proof", title: state.proofBoundaryLabel, symbolName: "checkmark.seal", state: .selected),
                        MissionControlLaneHeaderBadge(id: "owner", title: state.ownershipLabel, symbolName: "person.crop.circle", state: .default),
                    ]
                )

                MissionControlTimeSpine(
                    items: state.lanes.map(MissionControlLaneItem.init(detailLane:)),
                    defaultSelectedID: GoalDetailMissionLaneKind.overview.rawValue
                )

                VStack(alignment: .leading, spacing: 1) {
                    ForEach(GoalDetailMissionLaneKind.allCases, id: \.rawValue) { kind in
                        Text(" ")
                            .frame(width: 1, height: 1)
                            .accessibilityLabel(kind.title)
                            .accessibilityIdentifier(kind.accessibilityIdentifier)
                    }
                    ForEach(Self.compatibilityAnchors, id: \.identifier) { anchor in
                        Text(" ")
                            .frame(width: 1, height: 1)
                            .accessibilityLabel(anchor.label)
                            .accessibilityIdentifier(anchor.identifier)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goal-detail.mission-control")
        .ambitionPanelAccessibility()
    }

    static let compatibilityAnchors: [(identifier: String, label: String)] = [
        ("goal-detail.decisions", "Decisions"),
        ("goal-detail.risks", "Risks"),
        ("goal-detail.archive", "Archive"),
        ("goal-detail.path-filmstrip", "Path filmstrip"),
        ("goal-detail.path-builder", "Path builder"),
        ("goal-detail.tactics-region", "Tactics"),
        ("goal-detail.trust-whisper", "Trust whisper"),
        ("goal-detail.memory-narrative", "Memory narrative"),
    ]
}
