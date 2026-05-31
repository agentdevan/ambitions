import AmbitionsDesignSystem
import SwiftUI

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
                    DegradedStateCard(state: DegradedStateOrchestrator.objectLoading(.missionControlTimeSpine))
                case let .failed(message):
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine),
                        primaryAccessibilityIdentifier: "goal-detail.retry-button",
                        onPrimaryAction: {
                            _ = message
                            Task { await viewModel.refresh(using: featureFactory.goalsService) }
                        }
                    )
                case let .loaded(detail):
                    GoalDetailHeroCard(detail: detail)

                    if let missionControl = detail.missionControl {
                        GoalDetailMissionControlCard(state: missionControl)
                        GoalDetailBreadcrumbCard(state: missionControl.breadcrumb)
                        GoalDetailTimelineCard(state: missionControl.timeline)
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
                        LifePathThreadCard(
                            state: LifePathThreadState(
                                stages: detail.pathStages,
                                pathBuilder: detail.pathBuilder
                            )
                        )
                    }

                    if let movement = detail.nextMovement {
                        GoalDetailNextMovementCard(movement: movement)
                    }

                    GoalDetailTrajectoryCard(trajectory: detail.trajectory)

                    if let explainability = detail.explainability {
                        GoalTrustWhisperCard(
                            state: explainability,
                            isExpanded: $viewModel.isTrustExpanded
                        )
                    }

                    if detail.assumptions.isEmpty == false {
                        GoalDetailSectionCard(title: "Starter Assumptions", subtitle: "Visible assumptions keep provisional plans honest.") {
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
                        GoalDetailReviewTrailCard(state: missionControl.reviewTrail)
                        GoalDetailAssumptionsCard(assumptions: missionControl.assumptions)
                        GoalDetailProofRailCard(state: missionControl.proofRail)
                        GoalAlternatePathDecisionSpine(
                            state: GoalAlternatePathDecisionSpineState(
                                decisions: missionControl.decisions,
                                pathBuilder: detail.pathBuilder
                            )
                        )
                        GoalDetailRisksCard(state: missionControl.risks)
                        GoalDetailArchiveCard(state: missionControl.archive)
                        GoalDetailReceiptsCard(state: missionControl.receipts)
                    }

                    if let pathBuilder = detail.pathBuilder {
                        GoalPathBuilderCard(state: pathBuilder)
                    }

                    if let clarification = detail.clarification {
                        GoalDetailSectionCard(title: clarification.title, subtitle: clarification.subtitle) {
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
                        GoalDetailSectionCard(title: blocked.title, subtitle: blocked.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(blocked.blockers, id: \.self) { blocker in
                                    Label(blocker, systemImage: "exclamationmark.triangle.fill")
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    GoalDetailSectionCard(title: "Action rail", subtitle: "These controls write back to the real native plan and feedback history.") {
                        GoalActionGrid(actions: detail.actions) { action in
                            Task { await viewModel.perform(action, using: featureFactory.goalsService) }
                        }
                    }

                    GoalMemoryNarrativeCard(
                        detail: detail,
                        isExpanded: $viewModel.isMemoryExpanded
                    )

                    GoalDetailSectionCard(
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
                        GoalDetailSectionCard(title: "Suggested Steps", subtitle: "The calmest contained steps that still create signal.") {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.suggestions) { step in
                                    GoalSuggestionCard(step: step)
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

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }
}

private struct GoalDetailMissionControlCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailMissionControlState

    var body: some View {
        AppCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                MissionControlLaneHeader(
                    eyebrow: "Goal Mission Control",
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

    private static let compatibilityAnchors: [(identifier: String, label: String)] = [
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

private struct GoalDetailBreadcrumbCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailBreadcrumbState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    title: state.title,
                    subtitle: state.fallbackUsed ? "Relationship data is thin, so this falls back to the current goal." : "Where this goal sits in the larger system."
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(Array(state.labels.enumerated()), id: \.offset) { index, label in
                            HStack(spacing: theme.spacing.xs) {
                                Text(label)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(index == state.labels.count - 1 ? theme.colors.textPrimary : theme.colors.textSecondary)
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous).fill(theme.colors.surfaceOverlay))
                                if index < state.labels.count - 1 {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.labels.joined(separator: ", "))
        .accessibilityIdentifier("goal-detail.breadcrumb")
        .ambitionPanelAccessibility()
    }
}

private struct GoalDetailTimelineCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailTimelineState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(theme.stateStyle(for: item.state).accent)
                                    .frame(width: 10, height: 10)
                                Rectangle()
                                    .fill(theme.colors.strokeSubtle)
                                    .frame(width: 1, height: 34)
                            }
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Text(item.kind.title)
                                        .font(theme.typography.micro)
                                        .foregroundStyle(theme.colors.textTertiary)
                                    if item.isFuture {
                                        TagPill("Possible next", state: .default)
                                    }
                                }
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.summary)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goal-detail.timeline")
        .ambitionPanelAccessibility()
    }
}

private struct GoalPathBuilderCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalPathBuilderState

    var body: some View {
        GoalDetailSectionCard(title: state.title, subtitle: state.subtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                breadcrumb
                todayConnection
                phases

                if state.forks.isEmpty == false {
                    forks
                    tradeoffReview
                }

                if state.proofRequirements.isEmpty == false {
                    proofRequirements
                }

                roadmapList
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goal-detail.path-builder")
    }

    private var breadcrumb: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(Array(state.breadcrumbLabels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(theme.typography.micro)
                    .foregroundStyle(index == state.breadcrumbLabels.count - 1 ? theme.colors.textPrimary : theme.colors.textTertiary)
                if index < state.breadcrumbLabels.count - 1 {
                    Image(systemName: "chevron.right")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private var todayConnection: some View {
        AppCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Label("Today connection", systemImage: "scope")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.todayConnectionTitle)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(state.todayConnectionSummary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(state.planConnectionSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
    }

    private var phases: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: "Path shape", subtitle: "Phases stay connected to proof and the next step.")
            ForEach(state.phases) { phase in
                WidgetCard(state: phase.state) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(phase.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill(phase.statusLabel, state: phase.state)
                        }
                        Text(phase.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                        Label(phase.dependencySummary, systemImage: "point.3.connected.trianglepath.dotted")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Label(phase.proofSummary, systemImage: "checkmark.seal")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
            }
        }
    }

    private var forks: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: "Route options", subtitle: "Indicators only; compare before changing the path.")
            ForEach(state.forks) { fork in
                WidgetCard(state: fork.state) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(fork.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill(fork.freshnessLabel, state: fork.state)
                        }
                        Text(fork.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(fork.basisSummary)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(fork.decisionPrompt)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
    }

    private var tradeoffReview: some View {
        let review = state.tradeoffReview

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: review.title, subtitle: review.subtitle)
            ForEach(review.lanes) { lane in
                WidgetCard(state: lane.state) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Label(lane.title, systemImage: "arrow.triangle.branch")
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill("Review first", state: lane.state)
                        }
                        Text(lane.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                        Label(lane.effortLabel, systemImage: "wrench.and.screwdriver")
                        Label(lane.timeLabel, systemImage: "clock")
                        Label(lane.energyLabel, systemImage: "battery.75percent")
                        Label(lane.recoveryLabel, systemImage: "arrow.uturn.backward")
                        Label(lane.reviewRequirementLabel, systemImage: "hand.raised")
                    }
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(review.title)
        .accessibilityValue(review.accessibilitySummary)
        .accessibilityHint("Review route tradeoffs before choosing, editing, or parking a path.")
        .accessibilityIdentifier("goal-detail.tradeoff-review")
    }

    private var proofRequirements: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: "Proof checks", subtitle: "Evidence keeps the path shape honest.")
            ForEach(state.proofRequirements) { proof in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(theme.colors.accentPrimary)
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        HStack {
                            Text(proof.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill(proof.handoffLabel, state: proof.state)
                        }
                        Text(proof.summary)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .padding(theme.spacing.sm)
                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
            }
        }
    }

    private var roadmapList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: state.roadmapListTitle, subtitle: state.roadmapListSummary)
            ForEach(state.phases) { phase in
                Label("\(phase.title): \(phase.statusLabel)", systemImage: "list.bullet")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            Text(state.decisionReceiptSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
    }
}

private struct GoalDetailAssumptionsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let assumptions: [GoalDetailAssumptionState]

    var body: some View {
        GoalDetailSectionCard(title: "Assumptions", subtitle: "Correctable reads Ambitions is using for this goal.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(assumptions) { assumption in
                    AppCard(state: assumption.state) {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Text(assumption.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer()
                                TagPill(assumption.status, state: assumption.state)
                            }
                            Text(assumption.whyItMatters)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            if let correctionLabel = assumption.correctionLabel {
                                Text(correctionLabel)
                                    .font(theme.typography.micro)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.assumptions")
    }
}

private struct GoalDetailReviewTrailCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailReviewTrailState

    var body: some View {
        GoalDetailSectionCard(title: state.title, subtitle: state.subtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(state.items) { item in
                    WidgetCard(state: item.state) {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                                Label(item.kind.title, systemImage: item.kind.symbolName)
                                    .font(theme.typography.micro)
                                    .foregroundStyle(theme.colors.textTertiary)
                                Spacer()
                                TagPill(item.sourceLabel, state: item.state)
                            }

                            Text(item.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(item.summary)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)

                            HStack(spacing: theme.spacing.xs) {
                                Label(item.reviewLabel, systemImage: "eye")
                                Text(item.reversibilityLabel)
                            }
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilitySummary)
        .accessibilityIdentifier("goal-detail.review-trail")
    }
}

private struct GoalDetailProofRailCard: View {
    let state: GoalDetailProofRailState

    var body: some View {
        ProofSpine(
            title: state.title,
            subtitle: state.subtitle,
            beads: state.spineBeads,
            emptyTitle: state.emptyTitle,
            emptyMessage: state.emptyMessage
        )
        .accessibilityIdentifier("goal-detail.proof-rail")
    }
}

private struct GoalDetailReceiptsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailReceiptsState

    var body: some View {
        GoalDetailSectionCard(title: state.title, subtitle: state.subtitle) {
            if state.items.isEmpty {
                EmptyStateCard(title: state.emptyTitle, message: state.emptyMessage, icon: "doc.text.magnifyingglass")
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.items) { item in
                        AppCard(state: item.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.summary)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.timestamp)
                                    .font(theme.typography.micro)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.receipts")
    }
}

private struct GoalAlternatePathDecisionSpine: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalAlternatePathDecisionSpineState

    var body: some View {
        GoalDetailSectionCard(title: state.title, subtitle: state.subtitle) {
            if state.branches.isEmpty {
                EmptyStateCard(title: state.emptyTitle, message: state.emptyMessage, icon: "arrow.triangle.branch")
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    decisionBoundary
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(Array(state.branches.enumerated()), id: \.element.id) { index, branch in
                            branchFold(branch, isLast: index == state.branches.count - 1)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilitySummary)
        .accessibilityHint("Review alternate paths and decisions before changing this goal.")
        .accessibilityIdentifier("goal-detail.decisions")
    }

    private var decisionBoundary: some View {
        Label(state.boundaryLabel, systemImage: "hand.raised")
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.sm)
            .background(
                Capsule()
                    .fill(theme.colors.surfaceSecondary.opacity(0.72))
            )
    }

    private func branchFold(
        _ branch: GoalAlternatePathDecisionBranchState,
        isLast: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: branch.kind.symbolName)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.stateStyle(for: branch.state).accent)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(theme.stateStyle(for: branch.state).fill.opacity(0.72))
                    )
                if isLast == false {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle)
                        .frame(width: 1)
                        .frame(minHeight: 44)
                }
            }
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(branch.kind.title)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                    Spacer(minLength: theme.spacing.sm)
                    TagPill(branch.freshnessLabel, state: branch.state)
                }
                Text(branch.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(branch.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Label(branch.basisLabel, systemImage: "point.3.connected.trianglepath.dotted")
                    Label(branch.reviewLabel, systemImage: "eye")
                    Label(branch.consequenceLabel, systemImage: "arrow.left.and.right")
                    Label(branch.mutationBoundaryLabel, systemImage: "lock")
                }
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(.bottom, isLast ? 0 : theme.spacing.xs)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct GoalDetailRisksCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailRisksState

    var body: some View {
        GoalDetailSectionCard(title: state.title, subtitle: state.subtitle) {
            if state.items.isEmpty {
                EmptyStateCard(title: state.emptyTitle, message: state.emptyMessage, icon: "checkmark.shield")
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(theme.stateStyle(for: item.state).accent)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.summary)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goal-detail.risks")
    }
}

private struct GoalDetailArchiveCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailArchiveState

    var body: some View {
        GoalDetailSectionCard(title: "Archive", subtitle: "What this goal should remember when its active work changes.") {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text(state.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer()
                    TagPill(state.statusLabel, state: state.state)
                }
                Text(state.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(state.learning)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Archive. \(state.title). \(state.summary)")
        .accessibilityIdentifier("goal-detail.archive")
    }
}

private struct GoalExplainabilitySection: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalExplainabilityState
    @Binding var isTrustExpanded: Bool
    @Binding var isCorrectionsExpanded: Bool
    let onCorrection: (GoalCorrectionControlState) -> Void

    var body: some View {
        if isTrustExpanded {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                GoalDetailSectionCard(title: "Why this is on deck", subtitle: "Calm reasoning that stays attached to the strategic read instead of taking over the screen.") {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text(state.whyThis.compactSummary)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        ForEach(Array(state.whyThis.lines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }
                .accessibilityIdentifier("goal-detail.trust-panel")

                GoalDetailSectionCard(title: "Trust posture", subtitle: "Confidence, freshness, and contradictions stay legible before the deeper audit.") {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ExplainabilityLabelList(
                            title: humanizedConfidence(state.confidence.understandingConfidence),
                            subtitle: state.confidence.pathConfidence.map(humanizedConfidence),
                            labels: state.confidence.detailLabels
                        )
                        ExplainabilityLabelList(
                            title: state.freshness.postureLabel,
                            subtitle: state.freshness.severityLabel,
                            labels: state.freshness.detailLabels
                        )

                        if state.contradictions.isEmpty == false {
                            Divider()
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                Text("What needs reconciling")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                ForEach(state.contradictions) { contradiction in
                                    AppCard(state: contradiction.state) {
                                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                            HStack {
                                                Text(contradiction.title)
                                                    .font(theme.typography.bodyEmphasized)
                                                    .foregroundStyle(theme.colors.textPrimary)
                                                Spacer()
                                                TagPill(contradiction.severityLabel, state: contradiction.state)
                                            }
                                            Text(contradiction.summary)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                GoalDetailSectionCard(title: "Source context", subtitle: "Audit stays available here without dominating the first layer.") {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.sourceAudit.rows) { row in
                            AppCard(state: row.state) {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    Text(row.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(row.subtitle)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                    ForEach(row.detailLabels, id: \.self) { label in
                                        Text(label)
                                            .font(theme.typography.micro)
                                            .foregroundStyle(theme.colors.textTertiary)
                                    }
                                }
                            }
                        }
                    }
                }
                .accessibilityIdentifier("goal-detail.audit-panel")

                if state.correctionControls.isEmpty == false || state.appliedTeachingBadges.isEmpty == false {
                    GoalDetailSectionCard(title: "Corrections and teaching", subtitle: "Use these when the app needs clearer truth, not more admin.") {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Button(isCorrectionsExpanded ? "Hide correction actions" : "Open correction actions") {
                                isCorrectionsExpanded.toggle()
                            }
                            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                            .accessibilityIdentifier("goal-detail.corrections-toggle")

                            if state.appliedTeachingBadges.isEmpty == false {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    Text("Already learned")
                                        .font(theme.typography.section)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    ForEach(state.appliedTeachingBadges) { badge in
                                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                                            TagPill(badge.title, state: badge.state)
                                            Text(badge.subtitle)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                        }
                                    }
                                }
                            }

                            if isCorrectionsExpanded {
                                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                    ForEach(state.correctionControls) { control in
                                        AppCard(state: control.state) {
                                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                                Text(control.title)
                                                    .font(theme.typography.bodyEmphasized)
                                                    .foregroundStyle(theme.colors.textPrimary)
                                                Text(control.subtitle)
                                                    .font(theme.typography.caption)
                                                    .foregroundStyle(theme.colors.textSecondary)
                                                Button(control.title) {
                                                    onCorrection(control)
                                                }
                                                .buttonStyle(AmbitionPressableButtonStyle(state: control.state))
                                                .padding(.top, theme.spacing.xs)
                                            }
                                        }
                                    }
                                }
                                .accessibilityIdentifier("goal-detail.corrections-panel")
                            }
                        }
                    }
                }
            }
        }
    }

    private func humanizedConfidence(_ confidence: RecommendationConfidence) -> String {
        confidence.rawValue
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

private struct GoalTrustWhisperCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalExplainabilityState
    @Binding var isExpanded: Bool

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(state.whisper.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(state.whisper.subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(state.whisper.pillLine)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                    Spacer()
                    Button(isExpanded ? "Hide trust detail" : "Open trust detail") {
                        isExpanded.toggle()
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier("goal-detail.trust-toggle")
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(state.whisper.pills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.trust-whisper")
        .ambitionPanelAccessibility()
    }
}

private struct GoalMemoryNarrativeCard: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation
    @Binding var isExpanded: Bool

    var body: some View {
        GoalDetailSectionCard(title: "What changed and why", subtitle: memorySubtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if detail.recentMovement.items.isEmpty {
                    Text("No visible changes have landed yet.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(detail.recentMovement.items.prefix(2)) { item in
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                TagPill(item.categoryLabel, state: item.state)
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(item.subtitle)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                    Text(item.timestamp)
                                        .font(theme.typography.micro)
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                        }
                    }
                }

                if detail.evidence.isEmpty == false || detail.history.isEmpty == false {
                    Button(isExpanded ? "Hide deeper memory" : "Open deeper memory") {
                        isExpanded.toggle()
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier("goal-detail.memory-toggle")
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        if detail.evidence.isEmpty == false {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                Text("Evidence")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                ForEach(detail.evidence) { item in
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(theme.colors.accentPrimary)
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(item.title)
                                                .font(theme.typography.bodyEmphasized)
                                                .foregroundStyle(theme.colors.textPrimary)
                                            Text(item.subtitle)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                            Text(item.timestamp)
                                                .font(theme.typography.micro)
                                                .foregroundStyle(theme.colors.textTertiary)
                                        }
                                    }
                                }
                            }
                        }

                        if detail.history.isEmpty == false {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                Text("Adjustments")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                ForEach(detail.history) { item in
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        TagPill(item.title, state: item.state)
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(item.subtitle)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                            Text(item.timestamp)
                                                .font(theme.typography.micro)
                                                .foregroundStyle(theme.colors.textTertiary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .accessibilityIdentifier("goal-detail.memory-panel")
                }
            }
        }
        .accessibilityIdentifier("goal-detail.memory-narrative")
    }

    private var memorySubtitle: String {
        if detail.recentMovement.items.isEmpty == false {
            return detail.recentMovement.summary
        }
        if detail.evidence.isEmpty == false || detail.history.isEmpty == false {
            return "The recent story stays readable before the deeper log details."
        }
        return "Memory stays available here without turning the screen into a raw log."
    }
}

private struct ExplainabilityLabelList: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let labels: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
    }
}

#if DEBUG
#Preview("Goal Detail Active") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.activeTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.activeTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.activeTarget.id]!)
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Starter") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.starterTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.starterTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.starterTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Clarification") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.clarificationTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.clarificationTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.clarificationTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Blocked") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.blockedTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.blockedTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.blockedTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Support") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.supportTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.supportTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.supportTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Trust Heavy") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.activeTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.activeTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.activeTarget.id]!),
                isTrustExpanded: true,
                isCorrectionsExpanded: true,
                isMemoryExpanded: true
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
