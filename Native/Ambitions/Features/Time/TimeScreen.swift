import AmbitionsDesignSystem
import SwiftUI

struct TimeScreen: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TimeViewModel
    @State private var selectedDayID: String?
    @State private var selectedActionKind: TimeShapingActionKind = .patch
    @State private var isShapeTimeDepthExpanded = false
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: TimeViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TimeViewModel())
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ZStack {
            LivingSurfaceBackground(context: .plan, state: timeLivingState, intensity: 0.64)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    TopLevelSurfaceCompositionBar(surface: .time)

                    switch viewModel.state {
                    case .loading:
                        DegradedStateCard(state: DegradedStateOrchestrator.objectLoading(.lifeShapeContourMap))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.objectUnavailable(.lifeShapeContourMap),
                            primaryAccessibilityIdentifier: "time.retry-button",
                            onPrimaryAction: {
                                Task { await viewModel.refresh(using: featureFactory.timeService) }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(dashboard):
                        TimeHeroCard(hero: dashboard.hero, action: dashboard.primaryAction, onPrimaryAction: handlePrimaryAction)

                        TimeScopeChipStrip(timeframeLabel: dashboard.timeframeLabel)

                        TimeCapacityEnvelopeCard(envelope: dashboard.capacityEnvelope)

                        if let emptyTitle = dashboard.emptyTitle, let emptyMessage = dashboard.emptyMessage {
                            DegradedStateCard(
                                state: DegradedStateOrchestrator.timeEmpty(),
                                primaryAccessibilityIdentifier: "time.empty.create-goal",
                                secondaryAccessibilityIdentifier: "time.empty.open-captures",
                                onPrimaryAction: {
                                    _ = emptyTitle
                                    _ = emptyMessage
                                    shell.commandRouter.presentCreateGoal(source: .shellCompose)
                                },
                                onSecondaryAction: {
                                    shell.navigation.openTimeRoute(.captureInbox)
                                }
                            )
                        }

                        TimeShapeDepthDisclosure(
                            dashboard: dashboard,
                            selectedDayID: bindingForSelectedDay(defaultID: dashboard.pressureScrubber.defaultDayID),
                            selectedActionKind: $selectedActionKind,
                            isExpanded: $isShapeTimeDepthExpanded,
                            selectedDay: selectedDay(in: dashboard),
                            onOpenGoal: openGoal,
                            onOpenWindow: handleOpenWindow,
                            onOpenTimeRoute: openTimeRoute,
                            onCalendarAwarenessAction: handleCalendarAwarenessAction,
                            onDecisionItem: handleDecisionItem,
                            onShapingAction: handleShapingAction,
                            onReflowSuggestion: handleReflowSuggestion,
                            onReflowDecision: handleReflowDecision
                        )
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .accessibilityIdentifier("time.content-scroll")
            .scrollIndicators(.hidden)
        }
        .navigationTitle(showsNavigationChrome ? "Time" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shell.navigation.openHabits()
                    } label: {
                        Label("Rituals", systemImage: "repeat")
                    }
                    .accessibilityIdentifier("time.open-time-rituals-button")
                }
            }
        }
        .refreshable {
            await viewModel.refresh(using: featureFactory.timeService)
        }
        .accessibilityIdentifier("time.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .onChange(of: viewModel.stateKey) { _, _ in
            syncSelection()
        }
        .task {
            await viewModel.load(using: featureFactory.timeService)
            syncSelection()
        }
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    private var timeLivingState: LivingVisualState {
        guard case let .loaded(dashboard) = viewModel.state else {
            return .calm
        }

        let label = dashboard.capacityEnvelope.label.lowercased()
        if label.contains("overloaded") || label.contains("tight") {
            return .pressured
        }
        if dashboard.calendarAwareness.status == .denied {
            return .recovery
        }
        return .active
    }

    private func bindingForSelectedDay(defaultID: String) -> Binding<String> {
        Binding(
            get: { selectedDayID ?? defaultID },
            set: { selectedDayID = $0 }
        )
    }

    private func selectedDay(in dashboard: TimeDashboard) -> TimeElasticWeekDayState? {
        let activeID = selectedDayID ?? dashboard.pressureScrubber.defaultDayID
        return dashboard.weekDays.first(where: { $0.id == activeID }) ?? dashboard.weekDays.first
    }

    private func syncSelection() {
        guard case let .loaded(dashboard) = viewModel.state else { return }
        if dashboard.weekDays.contains(where: { $0.id == selectedDayID }) == false {
            selectedDayID = dashboard.pressureScrubber.defaultDayID
        }
        if dashboard.shapingActions.contains(where: { $0.kind == selectedActionKind }) == false {
            selectedActionKind = .patch
        }
    }

    private func handlePrimaryAction(_ action: TimeWeekPrimaryAction) {
        if let goalTarget = action.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let timeRoute = action.timeRoute {
            shell.navigation.openTimeRoute(timeRoute)
        }
    }

    private func handleShapingAction(_ action: TimeShapingActionState) {
        if let goalTarget = action.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let timeRoute = action.timeRoute {
            shell.navigation.openTimeRoute(timeRoute)
        }
    }

    private func handleOpenWindow(_ window: TimeOpenWindowState) {
        guard let target = window.target else { return }
        openGoal(target)
    }

    private func handleCalendarAwarenessAction(_ state: TimeCalendarAwarenessState) {
        guard state.canRequestCalendarRead else { return }
        Task {
            await viewModel.makeCalendarAware(using: featureFactory.timeService)
        }
    }

    private func handleDecisionItem(_ item: TimeDecisionItemState) {
        if let target = item.target {
            openGoal(target)
            return
        }
        if let route = item.timeRoute {
            openTimeRoute(route)
        }
    }

    private func handleReflowSuggestion(_ suggestion: TimeReflowSuggestionState) {
        if let target = suggestion.target {
            openGoal(target)
            return
        }
        if let route = suggestion.timeRoute {
            openTimeRoute(route)
        }
    }

    private func handleReflowDecision(
        _ option: TimeReflowDecisionOptionState,
        action: TimeReflowDecisionActionKind
    ) {
        guard action != .decline else { return }
        if let target = option.target {
            openGoal(target)
            return
        }
        if let route = option.timeRoute {
            openTimeRoute(route)
        }
    }

    private func openTimeRoute(_ route: TimeRouteTarget) {
        shell.navigation.openTimeRoute(route)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        shell.navigation.openGoalDetail(target)
    }
}

private struct TimeShapeDepthDisclosure: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: TimeDashboard
    let selectedDayID: Binding<String>
    @Binding var selectedActionKind: TimeShapingActionKind
    @Binding var isExpanded: Bool
    let selectedDay: TimeElasticWeekDayState?
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenWindow: (TimeOpenWindowState) -> Void
    let onOpenTimeRoute: (TimeRouteTarget) -> Void
    let onCalendarAwarenessAction: (TimeCalendarAwarenessState) -> Void
    let onDecisionItem: (TimeDecisionItemState) -> Void
    let onShapingAction: (TimeShapingActionState) -> Void
    let onReflowSuggestion: (TimeReflowSuggestionState) -> Void
    let onReflowDecision: (TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void

    var body: some View {
        StateDrivenMaterialPanel(context: .plan, state: .calm) {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    TimeTreatyCard(treaty: dashboard.treaty)
                    TimePressureRecoveryReviewCard(review: dashboard.pressureRecoveryReview)
                    TimeTimelineStripCard(strip: dashboard.timelineStrip, onOpenGoal: onOpenGoal)
                    TimePressureScrubberCard(scrubber: dashboard.pressureScrubber, selectedDayID: selectedDayID)
                    TimeGoalRelationshipCard(items: dashboard.goalShapingItems, onOpenGoal: onOpenGoal)
                    TimeSecondaryDestinationsCard(destinations: dashboard.secondaryDestinations) { destination in
                        if let timeRoute = destination.timeRoute {
                            onOpenTimeRoute(timeRoute)
                        }
                    }
                    TimeElasticWeekCard(days: dashboard.weekDays, selectedDayID: selectedDayID)

                    if let selectedDay {
                        TimeBelievabilityCard(
                            believability: dashboard.believability,
                            selectedDay: selectedDay,
                            onOpenGoal: onOpenGoal,
                            onOpenWindow: onOpenWindow
                        )
                    }

                    TimeCalendarAwarenessCard(state: dashboard.calendarAwareness, onPrimaryAction: onCalendarAwarenessAction)
                    TimeOpportunityWindowsCard(windows: dashboard.opportunityWindows, onOpenGoal: onOpenGoal)
                    TimeDecisionQueueCard(
                        decisionDebt: dashboard.decisionDebt,
                        conflictCourt: dashboard.conflictCourt,
                        onActivate: onDecisionItem
                    )
                    TimeCalendarBoundaryContractCard(
                        boundary: dashboard.calendarBoundary,
                        onPrimaryAction: { onCalendarAwarenessAction(dashboard.calendarAwareness) }
                    )
                    TimeExecutionResilienceCard(
                        resilience: dashboard.resilience,
                        onOpenGoal: onOpenGoal,
                        onOpenTimeRoute: onOpenTimeRoute
                    )
                    TimeShapingActionsCard(
                        actions: dashboard.shapingActions,
                        selectedKind: $selectedActionKind,
                        selectedDay: selectedDay,
                        onActivate: onShapingAction
                    )
                    TimeRecoveryCompositeSection(
                        recoveryEntry: dashboard.recoveryEntry,
                        realityReflow: dashboard.realityReflow,
                        reflowDecision: dashboard.reflowDecision,
                        recoveryGradient: dashboard.recoveryGradient,
                        saveTheDay: dashboard.saveTheDay,
                        reflowReceiptPreview: dashboard.reflowReceiptPreview,
                        recoveryMaturity: dashboard.recoveryMaturity,
                        onActivateDecision: onDecisionItem,
                        onActivateReflow: onReflowSuggestion,
                        onActivateReflowDecision: onReflowDecision
                    )
                    TimeLifeSuiteCard(suite: dashboard.lifeSuite)
                    TimeGoalLifecycleRailCard(rail: dashboard.lifecycleRail)
                }
                .padding(.top, theme.spacing.md)
            } label: {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("LifeShape Field depth")
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Open pressure, calendar source, recovery, reflow, and goal-time detail after capacity is clear.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("time.lifeshape-depth")
    }
}

private struct TimeScopeChipStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let timeframeLabel: String

    var body: some View {
        StateDrivenMaterialPanel(context: .plan, state: .active) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    AmbitionChip("Day", role: .time, semanticState: .calendarDerived)
                    AmbitionChip("Week", role: .time, semanticState: .focus)
                    AmbitionChip("Month", role: .time, semanticState: .neutral)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Time scope")
                .accessibilityValue("Day, Week, Month")

                EvidenceLabel(
                    "Shape Time",
                    detail: timeframeLabel,
                    source: "Time",
                    state: .active,
                    context: .plan
                )
            }
        }
        .accessibilityIdentifier("time.scope-chip-strip")
    }
}

private struct TimeCalendarAwarenessCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TimeCalendarAwarenessState
    let onPrimaryAction: (TimeCalendarAwarenessState) -> Void

    var body: some View {
        SchedulePanel(
            AmbitionRichPanelConfiguration(
                kind: .schedule,
                eyebrow: "Calendar",
                title: state.title,
                subtitle: state.detail,
                icon: state.primaryActionSystemImage,
                semanticState: semanticState,
                accessibilityLabel: "\(state.title). \(state.detail)"
            ),
            visualSlot: {
                EmptyView()
            },
            contentSlot: {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    HStack(spacing: theme.spacing.sm) {
                        TagPill(state.valueLabel, icon: "lock.shield", state: state.visualState)
                        TagPill(state.sourceLabel, icon: state.status == .calendarAware ? "calendar" : "iphone", state: .default)
                        TagPill("Time action", icon: "hand.tap", state: .default)
                    }
                    .accessibilityIdentifier("time.calendar-awareness")

                    Button {
                        onPrimaryAction(state)
                    } label: {
                        Label(state.primaryActionTitle, systemImage: state.primaryActionSystemImage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(state.canRequestCalendarRead == false)
                    .accessibilityIdentifier("time.calendar-aware.primary")
                }
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.title). \(state.detail)")
        .accessibilityIdentifier("time.calendar-awareness")
    }

    private var semanticState: AmbitionSemanticState {
        switch state.status {
        case .calendarAware:
            return .calendarDerived
        case .denied, .writeOnly:
            return .caution
        case .baseline, .unavailable:
            return .neutral
        }
    }
}

private struct TimeOpportunityWindowsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let windows: TimeOpportunityWindowsState
    let onOpenGoal: (GoalRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: windows.title, subtitle: windows.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(windows.windows) { window in
                        Button {
                            guard let target = window.target else { return }
                            onOpenGoal(target)
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Image(systemName: window.modeLabel == "Recovery" ? "sun.max" : "sparkles")
                                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(theme.stateStyle(for: window.visualState).accent)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    HStack(spacing: theme.spacing.xs) {
                                        TagPill(window.modeLabel, state: window.visualState)
                                        TagPill(window.timingLabel, state: .default)
                                    }
                                    Text(window.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(window.detail)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                if window.target != nil {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                            .padding(theme.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .fill(theme.colors.surfaceOverlay)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(window.target == nil)
                    }
                }
            }
        }
        .accessibilityIdentifier("time.opportunity-windows")
        .ambitionPanelAccessibility()
    }
}

private struct TimeDecisionListCard: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let emptyTitle: String
    let emptyDetail: String
    let items: [TimeDecisionItemState]
    let accessibilityIdentifier: String
    let onActivate: (TimeDecisionItemState) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: title, subtitle: subtitle)

                if items.isEmpty {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(emptyTitle)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(emptyDetail)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .padding(theme.spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                            .fill(theme.colors.surfaceOverlay)
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(items) { item in
                            Button {
                                onActivate(item)
                            } label: {
                                TimeDecisionItemRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .disabled(item.target == nil && item.timeRoute == nil)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .ambitionPanelAccessibility()
    }
}

private struct TimeDecisionItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TimeDecisionItemState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.visualState == .warning ? "exclamationmark.circle" : "circle.dotted")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: item.visualState).accent)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(item.detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.suggestion)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
            if item.target != nil || item.timeRoute != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}

private struct TimeCalendarBoundaryContractCard: View {
    @Environment(\.ambitionTheme) private var theme

    let boundary: TimeCalendarBoundaryContractState
    let onPrimaryAction: () -> Void

    var body: some View {
        AppCard(state: boundary.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: boundary.title, subtitle: boundary.detail)
                    .accessibilityIdentifier("time.calendar-boundary")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(boundary.permissionLabel, icon: "calendar", state: boundary.visualState)
                        TagPill(boundary.sourceLabel, icon: boundary.sourceLabel == "From your calendar" ? "calendar.badge.clock" : "iphone", state: .default)
                        TagPill("Manual fallback", icon: "hand.draw", state: .default)
                    }
                    Text(boundary.manualFallback)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(boundary.writeBoundary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                Button {
                    onPrimaryAction()
                } label: {
                    Label("Find real open windows", systemImage: "calendar.badge.clock")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: boundary.visualState))
                .disabled(boundary.canRequestCalendarRead == false)
                .accessibilityIdentifier("time.calendar-boundary.primary")
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.calendar-boundary")
    }
}

private struct TimeRecoveryEntryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let recovery: TimeRecoveryEntryState
    let onActivate: (TimeDecisionItemState) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: recovery.title, subtitle: recovery.detail)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(recovery.suggestions) { suggestion in
                        Button {
                            onActivate(suggestion)
                        } label: {
                            TimeDecisionItemRow(item: suggestion)
                        }
                        .buttonStyle(.plain)
                        .disabled(suggestion.target == nil && suggestion.timeRoute == nil)
                    }
                }

                Text(recovery.boundary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("time.recovery-entry")
        .ambitionPanelAccessibility()
    }
}

private struct TimeRealityReflowCard: View {
    @Environment(\.ambitionTheme) private var theme

    let reflow: TimeRealityReflowState
    let onActivate: (TimeReflowSuggestionState) -> Void

    var body: some View {
        AppCard(state: reflow.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: reflow.title, subtitle: reflow.detail)
                    .accessibilityIdentifier("time.reality-reflow")

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    TagPill(reflow.reasonKind.title, icon: reflow.reasonKind == .stillBelievable ? "checkmark.seal" : "waveform.path.ecg", state: reflow.visualState)
                    Text(reflow.reasonDetail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(reflow.recommendedAdjustment)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(reflow.suggestions.prefix(3)) { suggestion in
                        Button {
                            onActivate(suggestion)
                        } label: {
                            TimeReflowSuggestionRow(suggestion: suggestion)
                        }
                        .buttonStyle(.plain)
                        .disabled(suggestion.target == nil && suggestion.timeRoute == nil)
                    }
                }

                Text(reflow.noChangeCopy)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("time.reality-reflow")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct TimeReflowSuggestionRow: View {
    @Environment(\.ambitionTheme) private var theme

    let suggestion: TimeReflowSuggestionState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: suggestion.kind.icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: suggestion.visualState).accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    Text(suggestion.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    TagPill(suggestion.boundary.safetyLabel, state: suggestion.visualState)
                }
                Text(suggestion.detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(suggestion.impactLabel). \(suggestion.boundary.confirmationLabel). \(suggestion.boundary.undoLabel).")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            if suggestion.target != nil || suggestion.timeRoute != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suggestion.title). \(suggestion.detail). \(suggestion.boundary.confirmationLabel). \(suggestion.boundary.undoLabel).")
    }
}

private struct TimeRecoveryGradientCard: View {
    @Environment(\.ambitionTheme) private var theme

    let gradient: TimeRecoveryGradientState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: gradient.title, subtitle: gradient.detail)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(gradient.options) { option in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Text("\(option.order + 1)")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.stateStyle(for: option.visualState).accent)
                                .frame(width: 22, height: 22)
                                .background(
                                    Circle()
                                        .fill(theme.colors.surfaceOverlay)
                                )
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Image(systemName: option.kind.icon)
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    Text(option.title)
                                        .font(theme.typography.bodyEmphasized)
                                }
                                .foregroundStyle(theme.colors.textPrimary)
                                Text(option.detail)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text("\(option.boundary.confirmationLabel). \(option.boundary.undoLabel).")
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                        .padding(.vertical, theme.spacing.xs)
                    }
                }
            }
        }
        .accessibilityIdentifier("time.recovery-gradient")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct TimePressureRecoveryReviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let review: TimePressureRecoveryReviewState

    var body: some View {
        AppCard(state: review.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: review.title, subtitle: review.detail)

                HStack(spacing: theme.spacing.xs) {
                    TagPill("Explain first", icon: "text.magnifyingglass", state: review.visualState)
                    TagPill("No silent changes", icon: "hand.tap", state: .warning)
                    TagPill("Still counts", icon: "checkmark.seal", state: .success)
                }
                .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    TimeKeyValueRow(label: "Pressure field", value: review.pressureFieldLabel, state: review.visualState)
                    TimeKeyValueRow(label: "Recovery loop", value: review.recoveryLoopLabel, state: .selected)
                    TimeKeyValueRow(label: "Week", value: review.weekPressureLabel, state: review.visualState)
                    TimeKeyValueRow(label: "Overload", value: review.overloadedDayLabel, state: review.visualState)
                    TimeKeyValueRow(label: "Recovery", value: review.recoverySpaceLabel, state: .success)
                    TimeKeyValueRow(label: "Smaller step", value: review.smallerStepAnchorLabel, state: .selected)
                    TimeKeyValueRow(label: "Protected", value: review.protectedTimeConflictLabel, state: .selected)
                    TimeKeyValueRow(label: "Late start", value: review.lateStartAdjustmentLabel, state: .default)
                    TimeKeyValueRow(label: "Review", value: review.recoveryDayReviewLabel, state: .success)
                    TimeKeyValueRow(label: "Receipt", value: review.recoveryReceiptPreviewLabel, state: .default)
                    TimeKeyValueRow(label: "Capacity", value: review.capacityReviewLabel, state: .default)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(review.signals) { signal in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: iconName(for: signal.id))
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: signal.visualState).accent)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Text(signal.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    TagPill(signal.statusLabel, state: signal.visualState)
                                }
                                Text(signal.detail)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(signal.boundaryLabel)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .fill(theme.colors.surfaceOverlay)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .accessibilityIdentifier("time.pressure-recovery-review")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(review.accessibilityValue)
        .ambitionPanelAccessibility()
    }

    private func iconName(for id: String) -> String {
        switch id {
        case "week-pressure": "gauge.with.dots.needle.bottom.50percent"
        case "recovery-space": "sun.max"
        case "protected-time": "clock.badge.checkmark"
        case "recovery-boundary": "hand.tap"
        default: "checkmark.circle"
        }
    }
}

private struct TimeDecisionQueueCard: View {
    @Environment(\.ambitionTheme) private var theme

    let decisionDebt: TimeDecisionDebtState
    let conflictCourt: TimeConflictCourtState
    let onActivate: (TimeDecisionItemState) -> Void

    var body: some View {
        if decisionDebt.items.isEmpty && conflictCourt.conflicts.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if !decisionDebt.items.isEmpty {
                    TimeDecisionListCard(
                        title: decisionDebt.title,
                        subtitle: decisionDebt.subtitle,
                        emptyTitle: "No decision needed",
                        emptyDetail: "The current plan is not asking for another decision right now.",
                        items: decisionDebt.items,
                        accessibilityIdentifier: "time.decision-debt",
                        onActivate: onActivate
                    )
                }

                if !conflictCourt.conflicts.isEmpty {
                    TimeDecisionListCard(
                        title: conflictCourt.title,
                        subtitle: conflictCourt.subtitle,
                        emptyTitle: "No conflict to negotiate",
                        emptyDetail: "Nothing visible is competing hard enough to need attention.",
                        items: conflictCourt.conflicts,
                        accessibilityIdentifier: "time.conflict-court",
                        onActivate: onActivate
                    )
                }
            }
        }
    }
}

private struct TimeRecoveryCompositeSection: View {
    let recoveryEntry: TimeRecoveryEntryState
    let realityReflow: TimeRealityReflowState
    let reflowDecision: TimeReflowDecisionState
    let recoveryGradient: TimeRecoveryGradientState
    let saveTheDay: TimeSaveTheDayState
    let reflowReceiptPreview: TimeReflowReceiptPreviewState
    let recoveryMaturity: TimeRecoveryMaturityState
    let onActivateDecision: (TimeDecisionItemState) -> Void
    let onActivateReflow: (TimeReflowSuggestionState) -> Void
    let onActivateReflowDecision: (TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void

    var body: some View {
        if realityReflow.reasonKind == .lowData || realityReflow.reasonKind == .stillBelievable {
            EmptyView()
        } else {
            VStack(spacing: 16) {
                TimeRecoveryEntryCard(recovery: recoveryEntry, onActivate: onActivateDecision)

                TimeRealityReflowCard(reflow: realityReflow, onActivate: onActivateReflow)

                TimeReflowDecisionCard(decision: reflowDecision, onActivate: onActivateReflowDecision)

                TimeRecoveryGradientCard(gradient: recoveryGradient)

                TimeSaveTheDayCard(saveTheDay: saveTheDay)

                TimeReflowReceiptPreviewCard(preview: reflowReceiptPreview)

                TimeRecoveryMaturityCard(maturity: recoveryMaturity)
            }
        }
    }
}

private struct TimeSaveTheDayCard: View {
    @Environment(\.ambitionTheme) private var theme

    let saveTheDay: TimeSaveTheDayState

    var body: some View {
        AppCard(state: saveTheDay.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: saveTheDay.title, subtitle: saveTheDay.detail)

                if let question = saveTheDay.oneQuestion {
                    Label(question, systemImage: "questionmark.circle")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    TimeKeyValueRow(label: "Keep", value: saveTheDay.protectedItem, state: .selected)
                    TimeKeyValueRow(label: "Adjust", value: saveTheDay.adjustment, state: saveTheDay.visualState)
                    TimeKeyValueRow(label: "Recover", value: saveTheDay.recoveryExplanation, state: .success)
                }

                Text(saveTheDay.boundary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("time.save-the-day")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct TimeReflowReceiptPreviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: TimeReflowReceiptPreviewState

    var body: some View {
        AppCard(state: preview.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: preview.title, subtitle: preview.detail)

                HStack(spacing: theme.spacing.xs) {
                    TagPill(preview.confirmationRequired, icon: "hand.tap", state: preview.visualState)
                    TagPill(preview.undoAvailability, icon: "arrow.uturn.backward", state: .default)
                }

                TimeReceiptFactGroup(title: "Would change", facts: preview.whatChanged, state: preview.visualState)
                TimeReceiptFactGroup(title: "Would not change", facts: preview.whatWouldNotChange, state: .default)
                if preview.momentumReflowContract.isEmpty == false {
                    TimeReceiptFactGroup(
                        title: "Momentum reflow contract",
                        facts: preview.momentumReflowContract,
                        state: .warning
                    )
                }

                Text(preview.safeFailureFallback)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("time.reflow-receipt-preview")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct TimeRecoveryMaturityCard: View {
    @Environment(\.ambitionTheme) private var theme

    let maturity: TimeRecoveryMaturityState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: maturity.title, subtitle: maturity.detail)
                    .accessibilityIdentifier("time.recovery-maturity")

                HStack(spacing: theme.spacing.xs) {
                    TagPill(maturity.planFitLabel, icon: "gauge", state: .selected)
                    TagPill("Confirm first", icon: "hand.tap", state: .warning)
                    TagPill("Private", icon: "lock", state: .default)
                }
                .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(maturity.signals) { signal in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: iconName(for: signal.id))
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: signal.visualState).accent)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Text(signal.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    TagPill(signal.statusLabel, state: signal.visualState)
                                }
                                Text(signal.detail)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(signal.boundaryLabel)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .fill(theme.colors.surfaceOverlay)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                        )
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(maturity.confirmationBoundary)
                    Text(maturity.calendarBoundary)
                    Text(maturity.socialBoundary)
                    Text(maturity.receiptBoundary)
                }
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(maturity.title). \(maturity.detail). \(maturity.confirmationBoundary). \(maturity.calendarBoundary). \(maturity.socialBoundary).")
        .accessibilityHint("Review Plan recovery boundaries before confirming any broad change.")
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.recovery-maturity")
    }

    private func iconName(for signalID: String) -> String {
        switch signalID {
        case "fit": "gauge"
        case "waiting-commitments": "hourglass"
        case "social-load": "person.2"
        case "receipt": "receipt"
        default: "checkmark.seal"
        }
    }
}

private struct TimeReceiptFactGroup: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let facts: [String]
    let state: AmbitionVisualState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            ForEach(facts, id: \.self) { fact in
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    Image(systemName: title == "Would change" ? "circle.dotted" : "lock")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.stateStyle(for: state).accent)
                    Text(fact)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct TimeHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let hero: TimeRealityHeroState
    let action: TimeWeekPrimaryAction
    let onPrimaryAction: (TimeWeekPrimaryAction) -> Void

    var body: some View {
        HeroCard(state: action.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(hero.dominantTruth)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hero.roomSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(hero.pressureSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "waveform.path.ecg.text")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(hero.trustWhisper)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    onPrimaryAction(action)
                } label: {
                    HStack(alignment: .center, spacing: theme.spacing.sm) {
                        Image(systemName: action.systemImage)
                            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(action.title)
                                .font(theme.typography.bodyEmphasized)
                            Text(action.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(AmbitionButtonStyle(tier: .hero, state: action.state))
                .accessibilityIdentifier("time.hero.primary-action")
            }
        }
        .accessibilityIdentifier("time.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct TimePressureScrubberCard: View {
    @Environment(\.ambitionTheme) private var theme

    let scrubber: TimePressureScrubberState
    @Binding var selectedDayID: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: scrubber.title, subtitle: scrubber.subtitle)
                    .accessibilityIdentifier("time.pressure-scrubber")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ForEach(scrubber.points) { point in
                            Button {
                                selectedDayID = point.id
                            } label: {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    HStack {
                                        Text(point.weekdayLabel)
                                            .font(theme.typography.caption)
                                        Spacer(minLength: theme.spacing.xs)
                                        Text(point.dateLabel)
                                            .font(theme.typography.caption)
                                    }
                                    .foregroundStyle(selectedDayID == point.id ? theme.colors.textPrimary : theme.colors.textSecondary)

                                    Capsule()
                                        .fill(theme.stateStyle(for: point.level.visualState).accent.opacity(selectedDayID == point.id ? 0.9 : 0.45))
                                        .frame(width: CGFloat(72 * point.pressureValue), height: 8)

                                    Text(point.roomLabel)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(point.summary)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textTertiary)
                                        .lineLimit(2)
                                }
                                .padding(theme.spacing.sm)
                                .frame(width: 120, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                        .fill(selectedDayID == point.id ? theme.colors.surfaceOverlay : theme.colors.surfacePrimary)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                        .stroke(selectedDayID == point.id ? theme.stateStyle(for: point.level.visualState).accent : theme.colors.strokeSubtle, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("time.scrubber.point.\(point.id)")
                            .accessibilityValue(selectedDayID == point.id ? "selected" : "not selected")
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.pressure-scrubber")
    }
}

private struct TimeElasticWeekCard: View {
    @Environment(\.ambitionTheme) private var theme

    let days: [TimeElasticWeekDayState]
    @Binding var selectedDayID: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Weekly Plan Strip",
                    subtitle: "Dense days expand, quiet days compress, and open room stays visible instead of disappearing into a calendar grid."
                )
                .accessibilityIdentifier("time.weekly-shaping-strip")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: theme.spacing.sm) {
                        ForEach(days) { day in
                            Button {
                                selectedDayID = day.id
                            } label: {
                                TimeElasticWeekDayColumn(day: day, isSelected: selectedDayID == day.id)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("time.day.\(day.id)")
                        }
                    }
                    .padding(.vertical, theme.spacing.xxs)
                }
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.weekly-shaping-strip")
    }
}

private struct TimeElasticWeekDayColumn: View {
    @Environment(\.ambitionTheme) private var theme

    let day: TimeElasticWeekDayState
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(day.weekdayLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(day.dateLabel)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                }
                Spacer(minLength: theme.spacing.xs)
                TagPill(day.level.title, icon: day.level.icon, state: day.level.visualState)
            }

            Text(day.highlight)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(day.blocks.prefix(2)) { block in
                    HStack(alignment: .top, spacing: theme.spacing.xs) {
                        Image(systemName: block.kind.icon)
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.stateStyle(for: block.visualState).accent)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(block.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textPrimary)
                                .lineLimit(2)
                            Text(block.kind.title)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                    }
                }
                if day.overflowCount > 0 {
                    Text("+\(day.overflowCount) more")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Spacer(minLength: theme.spacing.xs)

            if let openWindow = day.openWindow {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(openWindow.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(openWindow.suggestionLabel ?? day.roomLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                }
                .padding(theme.spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfacePrimary)
                )
            }
        }
        .padding(theme.spacing.md)
        .frame(width: 172)
        .frame(minHeight: 190 + (day.intensity * 86))
        .background(
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .fill(isSelected ? theme.colors.surfaceOverlay : theme.colors.surfacePrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .stroke(isSelected ? theme.stateStyle(for: day.level.visualState).accent : theme.colors.strokeSubtle, lineWidth: 1)
        )
        .shadow(color: isSelected ? theme.elevation.raised.color.opacity(0.22) : .clear, radius: 18, y: 10)
    }
}

private struct TimeBelievabilityCard: View {
    @Environment(\.ambitionTheme) private var theme

    let believability: TimeBelievabilityState
    let selectedDay: TimeElasticWeekDayState
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenWindow: (TimeOpenWindowState) -> Void

    var body: some View {
        AppCard(state: believability.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Week believability",
                    subtitle: "Plan explains why the week looks doable, tight, or overloaded before it asks you to intervene."
                )
                .accessibilityIdentifier("time.believability-card")

                HStack(spacing: theme.spacing.xs) {
                    TagPill(believability.label, icon: "scope", state: believability.visualState)
                    TagPill("\(selectedDay.weekdayLabel) \(selectedDay.dateLabel)", icon: "calendar", state: selectedDay.level.visualState)
                    TagPill(selectedDay.roomLabel, state: selectedDay.level.visualState)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(believability.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(believability.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(believability.supportLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack {
                        Text("Selected day")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Spacer()
                        Text(selectedDay.capacityLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                    }

                    if selectedDay.blocks.isEmpty {
                        Text("No explicit block is attached to this day yet.")
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    } else {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            ForEach(selectedDay.blocks) { block in
                                if let target = block.target {
                                    Button {
                                        onOpenGoal(target)
                                    } label: {
                                        TimeBelievabilityBlockRow(block: block)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    TimeBelievabilityBlockRow(block: block)
                                }
                            }
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("time.selected-day.\(selectedDay.id)")

                if let openWindow = selectedDay.openWindow {
                    Button {
                        onOpenWindow(openWindow)
                    } label: {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: "sparkles")
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: openWindow.visualState).accent)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(openWindow.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(openWindow.detail)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                                if let suggestionLabel = openWindow.suggestionLabel {
                                    Text("Best fit: \(suggestionLabel)")
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                            Spacer()
                            if openWindow.target != nil {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                        .padding(theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .fill(theme.colors.surfaceOverlay)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(openWindow.target == nil)
                }
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.believability-card")
    }
}

private struct TimeBelievabilityBlockRow: View {
    @Environment(\.ambitionTheme) private var theme

    let block: TimeWeekBlockState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: block.kind.icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: block.visualState).accent)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(block.kind.title, state: block.visualState)
                    TagPill(block.timingLabel, state: .default)
                }
                Text(block.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(block.detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(block.goalLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}

private struct TimeExecutionResilienceCard: View {
    @Environment(\.ambitionTheme) private var theme

    let resilience: TimeExecutionResilienceState
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenTimeRoute: (TimeRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: resilience.title,
                    subtitle: resilience.subtitle
                )
                .accessibilityIdentifier("time.execution-resilience")

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(resilience.calmExplanation)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(resilience.focusProtection)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(resilience.tradeoffFraming)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(resilience.lanes) { lane in
                        Button {
                            if let goalTarget = lane.goalTarget {
                                onOpenGoal(goalTarget)
                            } else if let timeRoute = lane.timeRoute {
                                onOpenTimeRoute(timeRoute)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    HStack(spacing: theme.spacing.xs) {
                                        TagPill(lane.title, state: lane.state)
                                        Text(lane.recommendation)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textTertiary)
                                            .lineLimit(2)
                                    }
                                    Text(lane.detail)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer(minLength: theme.spacing.sm)

                                if lane.goalTarget != nil || lane.timeRoute != nil {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                            .padding(theme.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .fill(theme.colors.surfaceOverlay)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(lane.goalTarget == nil && lane.timeRoute == nil)
                        .accessibilityIdentifier("time.resilience.\(lane.id)")
                    }
                }

                if let windowMagnetism = resilience.windowMagnetism {
                    Button {
                        guard let target = windowMagnetism.target else { return }
                        onOpenGoal(target)
                    } label: {
                        TimeCompactSplitPane(
                            dominantTitle: windowMagnetism.title,
                            dominantBody: windowMagnetism.detail,
                            contextTitle: windowMagnetism.dayLabel,
                            contextBody: "\(windowMagnetism.suggestionTitle)\n\(windowMagnetism.suggestionDetail)",
                            state: windowMagnetism.visualState
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(windowMagnetism.target == nil)
                    .accessibilityIdentifier("time.window-magnetism")
                }
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.execution-resilience")
    }
}

private struct TimeCompactSplitPane: View {
    @Environment(\.ambitionTheme) private var theme

    let dominantTitle: String
    let dominantBody: String
    let contextTitle: String
    let contextBody: String
    let state: AmbitionVisualState

    var body: some View {
        let stateStyle = theme.stateStyle(for: state)

        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(dominantTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(dominantBody)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Capsule()
                    .fill(stateStyle.accent.opacity(0.85))
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(contextTitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(contextBody)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfacePrimary)
            )
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(stateStyle.stroke.opacity(0.6), lineWidth: 1)
        )
    }
}

private struct TimeShapingActionsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [TimeShapingActionState]
    @Binding var selectedKind: TimeShapingActionKind
    let selectedDay: TimeElasticWeekDayState?
    let onActivate: (TimeShapingActionState) -> Void

    private var selectedAction: TimeShapingActionState? {
        actions.first(where: { $0.kind == selectedKind }) ?? actions.first
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Week-shaping actions",
                    subtitle: "Keep one shaping lane obvious: edit, patch, adjust later, or lighten."
                )
                .accessibilityIdentifier("time.action-lane")

                LazyVGrid(columns: [GridItem(.flexible(), spacing: theme.spacing.sm), GridItem(.flexible(), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                    ForEach(actions) { action in
                        Button {
                            selectedKind = action.kind
                        } label: {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                HStack {
                                    Image(systemName: action.systemImage)
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    Spacer()
                                    TagPill(action.kind.title, state: action.state)
                                }
                                .foregroundStyle(theme.colors.textPrimary)

                                Text(action.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(action.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .lineLimit(3)
                            }
                            .padding(theme.spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .fill(selectedKind == action.kind ? theme.colors.surfaceOverlay : theme.colors.surfacePrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .stroke(selectedKind == action.kind ? theme.stateStyle(for: action.state).accent : theme.colors.strokeSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("time.action.select.\(action.kind.rawValue)")
                    }
                }

                if let selectedAction {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        TimeCompactSplitPane(
                            dominantTitle: selectedAction.title,
                            dominantBody: selectedAction.recommendation,
                            contextTitle: selectedDay.map { "Current pressure focus: \($0.weekdayLabel) \($0.dateLabel)" } ?? "Current pressure focus",
                            contextBody: selectedDay.map { "\($0.roomLabel)\n\($0.highlight)" } ?? "Pick one day and keep the contextual pane compact.",
                            state: selectedAction.state
                        )

                        Button {
                            onActivate(selectedAction)
                        } label: {
                            HStack {
                                Text(callToActionTitle(for: selectedAction))
                                    .font(theme.typography.bodyEmphasized)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityElement(children: .combine)
                            .accessibilityIdentifier("time.action.cta")
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: selectedAction.state))
                        .disabled(selectedAction.goalTarget == nil && selectedAction.timeRoute == nil)
                        .accessibilityLabel(callToActionTitle(for: selectedAction))
                        .accessibilityHint(selectedAction.recommendation)
                        .accessibilityIdentifier("time.action.cta")
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.action-lane")
    }

    private func callToActionTitle(for action: TimeShapingActionState) -> String {
        if action.timeRoute == .captureInbox {
            return "Open Capture"
        }
        if action.goalTarget != nil {
            return "Open goal"
        }
        return action.title
    }
}

private struct TimeGoalRelationshipCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [TimeGoalShapingItem]
    let onOpenGoal: (GoalRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Goals shaping the week",
                    subtitle: items.isEmpty
                        ? "No active goals are asking the week for structure yet."
                        : "Plan stays tied to active goals instead of turning into a disconnected scheduler."
                )
                .accessibilityIdentifier("time.goal-relationship-card")

                if items.isEmpty {
                    Text("Once active goals carry real work, they will show up here with their week relationship and next doable step.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(items) { item in
                            Button {
                                guard let target = item.target else { return }
                                onOpenGoal(target)
                            } label: {
                                TimeGoalRelationshipRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .disabled(item.target == nil)
                            .accessibilityIdentifier("time.goal.open.\(item.id)")
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("time.goal-relationship-card")
    }
}

private struct TimeGoalRelationshipRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TimeGoalShapingItem

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(item.pressureLabel, state: item.visualState)
                    Text(item.weekRelationship)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
                Text(item.goalTitle)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(item.attentionReason)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Next doable step: \(item.nextMoveLabel)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            Image(systemName: "chevron.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .ambitionPanelAccessibility()
    }
}

private struct TimeSecondaryDestinationsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let destinations: [TimeSecondaryDestination]
    let onOpen: (TimeSecondaryDestination) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Time-owned support routes", subtitle: "Rituals, Capture, and review stay subordinate so the week remains the dominant workspace.")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(destinations) { destination in
                        Button {
                            onOpen(destination)
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Image(systemName: destination.icon)
                                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(theme.stateStyle(for: destination.visualState).accent)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(destination.title)
                                        .font(theme.typography.section)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(destination.detail)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer(minLength: theme.spacing.sm)
                                TagPill(destination.valueLabel, state: destination.visualState)
                            }
                            .padding(theme.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .fill(theme.colors.surfaceOverlay)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(accessibilityIdentifier(for: destination))
                    }
                }
            }
        }
    }

    private func accessibilityIdentifier(for destination: TimeSecondaryDestination) -> String {
        if destination.timeRoute == .habits {
            return "time.open-time-rituals-button"
        }
        if destination.timeRoute == .weeklyReview {
            return "time.open-time-weekly-review-button"
        }
        return "time.open-\(destination.id)-button"
    }
}

#if DEBUG
#Preview("Time Seeded") {
    NavigationStack {
        TimeScreen(viewModel: TimeViewModel(state: .loaded(PreviewTimeScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Time Empty") {
    NavigationStack {
        TimeScreen(viewModel: TimeViewModel(state: .loaded(PreviewTimeScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
