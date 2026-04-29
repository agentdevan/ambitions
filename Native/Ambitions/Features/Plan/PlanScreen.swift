import AmbitionsDesignSystem
import SwiftUI

struct PlanScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: PlanViewModel
    @State private var selectedDayID: String?
    @State private var selectedActionKind: PlanShapingActionKind = .patch
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: PlanViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? PlanViewModel())
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 9))
                        .transition(.ambitionPanel)
                case .failed:
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.unavailable(surface: "Plan"),
                        primaryAccessibilityIdentifier: "plan.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: container.planService) }
                        }
                    )
                    .transition(.ambitionPanel)
                case let .loaded(dashboard):
                    PlanHeroCard(hero: dashboard.hero, action: dashboard.primaryAction, onPrimaryAction: handlePrimaryAction)

                    PlanTreatyCard(treaty: dashboard.treaty)

                    PlanCapacityEnvelopeCard(envelope: dashboard.capacityEnvelope)

                    PlanGoalLifecycleRailCard(rail: dashboard.lifecycleRail)

                    PlanTimelineStripCard(strip: dashboard.timelineStrip, onOpenGoal: openGoal)

                    if let emptyTitle = dashboard.emptyTitle, let emptyMessage = dashboard.emptyMessage {
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.planEmpty(),
                            primaryAccessibilityIdentifier: "plan.empty.create-goal",
                            secondaryAccessibilityIdentifier: "plan.empty.open-captures",
                            onPrimaryAction: {
                                _ = emptyTitle
                                _ = emptyMessage
                                container.commandRouter.presentCreateGoal(source: .shellCompose)
                            },
                            onSecondaryAction: {
                                container.navigation.openPlanRoute(.capturesInbox)
                            }
                        )
                    }

                    PlanPressureScrubberCard(
                        scrubber: dashboard.pressureScrubber,
                        selectedDayID: bindingForSelectedDay(defaultID: dashboard.pressureScrubber.defaultDayID)
                    )

                    PlanGoalRelationshipCard(items: dashboard.goalShapingItems) { target in
                        openGoal(target)
                    }

                    PlanSecondaryDestinationsCard(destinations: dashboard.secondaryDestinations) { destination in
                        if let planRoute = destination.planRoute {
                            openPlanRoute(planRoute)
                        }
                    }

                    PlanElasticWeekCard(
                        days: dashboard.weekDays,
                        selectedDayID: bindingForSelectedDay(defaultID: dashboard.pressureScrubber.defaultDayID)
                    )

                    if let selectedDay = selectedDay(in: dashboard) {
                        PlanBelievabilityCard(
                            believability: dashboard.believability,
                            selectedDay: selectedDay,
                            onOpenGoal: openGoal,
                            onOpenWindow: handleOpenWindow
                        )
                    }

                    PlanCalendarAwarenessCard(
                        state: dashboard.calendarAwareness,
                        onPrimaryAction: handleCalendarAwarenessAction
                    )

                    PlanOpportunityWindowsCard(windows: dashboard.opportunityWindows, onOpenGoal: openGoal)

                    PlanDecisionListCard(
                        title: dashboard.decisionDebt.title,
                        subtitle: dashboard.decisionDebt.subtitle,
                        emptyTitle: "No decision needed",
                        emptyDetail: "The current plan is not asking for another decision right now.",
                        items: dashboard.decisionDebt.items,
                        accessibilityIdentifier: "plan.decision-debt",
                        onActivate: handleDecisionItem
                    )

                    PlanDecisionListCard(
                        title: dashboard.conflictCourt.title,
                        subtitle: dashboard.conflictCourt.subtitle,
                        emptyTitle: "No conflict to negotiate",
                        emptyDetail: "Nothing visible is competing hard enough to need attention.",
                        items: dashboard.conflictCourt.conflicts,
                        accessibilityIdentifier: "plan.conflict-court",
                        onActivate: handleDecisionItem
                    )

                    PlanCalendarBoundaryContractCard(
                        boundary: dashboard.calendarBoundary,
                        onPrimaryAction: {
                            handleCalendarAwarenessAction(dashboard.calendarAwareness)
                        }
                    )

                    PlanRecoveryEntryCard(recovery: dashboard.recoveryEntry, onActivate: handleDecisionItem)

                    PlanRealityReflowCard(reflow: dashboard.realityReflow, onActivate: handleReflowSuggestion)

                    PlanRecoveryGradientCard(gradient: dashboard.recoveryGradient)

                    PlanSaveTheDayCard(saveTheDay: dashboard.saveTheDay)

                    PlanReflowReceiptPreviewCard(preview: dashboard.reflowReceiptPreview)

                    PlanRecoveryMaturityCard(maturity: dashboard.recoveryMaturity)

                    PlanExecutionResilienceCard(
                        resilience: dashboard.resilience,
                        onOpenGoal: openGoal,
                        onOpenPlanRoute: openPlanRoute
                    )

                    PlanShapingActionsCard(
                        actions: dashboard.shapingActions,
                        selectedKind: $selectedActionKind,
                        selectedDay: selectedDay(in: dashboard),
                        onActivate: handleShapingAction
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(showsNavigationChrome ? "Plan" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        container.navigation.openHabits()
                    } label: {
                        Label("Rituals", systemImage: AppTab.habits.systemImage)
                    }
                    .accessibilityIdentifier("plan.open-habits-button")
                }
            }
        }
        .refreshable {
            await viewModel.refresh(using: container.planService)
        }
        .accessibilityIdentifier("plan.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .onChange(of: viewModel.stateKey) { _, _ in
            syncSelection()
        }
        .task {
            await viewModel.load(using: container.planService)
            syncSelection()
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }

    private func bindingForSelectedDay(defaultID: String) -> Binding<String> {
        Binding(
            get: { selectedDayID ?? defaultID },
            set: { selectedDayID = $0 }
        )
    }

    private func selectedDay(in dashboard: PlanDashboard) -> PlanElasticWeekDayState? {
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

    private func handlePrimaryAction(_ action: PlanWeekPrimaryAction) {
        if let goalTarget = action.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let planRoute = action.planRoute {
            container.navigation.openPlanRoute(planRoute)
        }
    }

    private func handleShapingAction(_ action: PlanShapingActionState) {
        if let goalTarget = action.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let planRoute = action.planRoute {
            container.navigation.openPlanRoute(planRoute)
        }
    }

    private func handleOpenWindow(_ window: PlanOpenWindowState) {
        guard let target = window.target else { return }
        openGoal(target)
    }

    private func handleCalendarAwarenessAction(_ state: PlanCalendarAwarenessState) {
        guard state.canRequestCalendarRead else { return }
        Task {
            await viewModel.makeCalendarAware(using: container.planService)
        }
    }

    private func handleDecisionItem(_ item: PlanDecisionItemState) {
        if let target = item.target {
            openGoal(target)
            return
        }
        if let route = item.planRoute {
            openPlanRoute(route)
        }
    }

    private func handleReflowSuggestion(_ suggestion: PlanReflowSuggestionState) {
        if let target = suggestion.target {
            openGoal(target)
            return
        }
        if let route = suggestion.planRoute {
            openPlanRoute(route)
        }
    }

    private func openPlanRoute(_ route: PlanRouteTarget) {
        container.navigation.openPlanRoute(route)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        container.navigation.openGoalDetail(target)
    }
}

private struct PlanTreatyCard: View {
    @Environment(\.ambitionTheme) private var theme

    let treaty: PlanTreatyState

    var body: some View {
        AppCard(state: treaty.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: treaty.title, subtitle: treaty.summary)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: theme.spacing.sm), GridItem(.flexible(), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                    PlanTreatyTile(title: "Keep", detail: treaty.protectedWork, icon: "lock.shield", state: .selected)
                    PlanTreatyTile(title: "Flex", detail: treaty.flexibleWork, icon: "arrow.left.and.right", state: .default)
                    PlanTreatyTile(title: "Not today", detail: treaty.notTodayWork, icon: "tray", state: .warning)
                    PlanTreatyTile(title: "Recovery", detail: treaty.recoveryAllowance, icon: "sun.max", state: treaty.visualState)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(treaty.calendarBoundary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.stateStyle(for: treaty.visualState).accent)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(treaty.primaryActionTitle)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(treaty.primaryActionSubtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.treaty")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanTreatyTile: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String
    let icon: String
    let state: AmbitionVisualState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                Text(title)
                    .font(theme.typography.caption)
            }
            .foregroundStyle(theme.stateStyle(for: state).accent)

            Text(detail)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.stateStyle(for: state).stroke.opacity(0.5), lineWidth: 1)
        )
    }
}

private struct PlanCapacityEnvelopeCard: View {
    @Environment(\.ambitionTheme) private var theme

    let envelope: PlanCapacityEnvelopeState

    var body: some View {
        AppCard(state: envelope.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: envelope.title, subtitle: envelope.detail)

                HStack(spacing: theme.spacing.xs) {
                    TagPill(envelope.label, icon: "gauge.with.dots.needle.bottom.50percent", state: envelope.visualState)
                    TagPill(envelope.availableCapacity, icon: "calendar", state: envelope.visualState)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    PlanKeyValueRow(label: "Pressure", value: envelope.pressure, state: envelope.visualState)
                    PlanKeyValueRow(label: "Focus time", value: envelope.protectedFocus, state: .selected)
                    PlanKeyValueRow(label: "Recovery margin", value: envelope.recoveryMargin, state: envelope.visualState)
                }
            }
        }
        .accessibilityIdentifier("plan.capacity-envelope")
        .ambitionPanelAccessibility()
    }
}

private struct PlanKeyValueRow: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String
    let state: AmbitionVisualState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Circle()
                .fill(theme.stateStyle(for: state).accent)
                .frame(width: 7, height: 7)
                .padding(.top, 7)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(value)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            Spacer()
        }
    }
}

private struct PlanGoalLifecycleRailCard: View {
    @Environment(\.ambitionTheme) private var theme

    let rail: PlanGoalLifecycleRailState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: rail.title, subtitle: rail.subtitle)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ForEach(rail.segments) { segment in
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Image(systemName: segment.lifecycleState.icon)
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    Text(segment.lifecycleState.title)
                                        .font(theme.typography.caption)
                                }
                                .foregroundStyle(theme.stateStyle(for: segment.lifecycleState.visualState).accent)

                                Text("\(segment.count)")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(segment.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .lineLimit(2)
                            }
                            .padding(theme.spacing.md)
                            .frame(width: 128, alignment: .leading)
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
        }
        .accessibilityIdentifier("plan.goal-lifecycle-rail")
        .ambitionPanelAccessibility()
    }
}

private struct PlanTimelineStripCard: View {
    @Environment(\.ambitionTheme) private var theme

    let strip: PlanTimelineStripState
    let onOpenGoal: (GoalRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: strip.title, subtitle: strip.subtitle)

                if strip.items.isEmpty {
                    Text("Goal movement will appear here when this plan has real pressure to carry.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            ForEach(strip.items) { item in
                                Button {
                                    guard let target = item.target else { return }
                                    onOpenGoal(target)
                                } label: {
                                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                        TagPill(item.kind.title, state: item.visualState)
                                        Text(item.title)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                            .lineLimit(2)
                                        Text(item.detail)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                            .lineLimit(3)
                                        Text(item.timingLabel)
                                            .font(theme.typography.micro)
                                            .foregroundStyle(theme.colors.textTertiary)
                                        TagPill(item.sourceLabel, state: .default)
                                    }
                                    .padding(theme.spacing.md)
                                    .frame(width: 176, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                            .fill(theme.colors.surfaceOverlay)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                            .stroke(theme.stateStyle(for: item.visualState).stroke.opacity(0.6), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(item.target == nil)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(item.title). \(item.detail). \(item.timingLabel). \(item.sourceLabel).")
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.timeline-strip")
        .ambitionPanelAccessibility()
    }
}

private struct PlanCalendarAwarenessCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: PlanCalendarAwarenessState
    let onPrimaryAction: (PlanCalendarAwarenessState) -> Void

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
                        TagPill("Plan action", icon: "hand.tap", state: .default)
                    }

                    Button {
                        onPrimaryAction(state)
                    } label: {
                        Label(state.primaryActionTitle, systemImage: state.primaryActionSystemImage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(state.canRequestCalendarRead == false)
                    .accessibilityIdentifier("plan.calendar-aware.primary")
                }
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.title). \(state.detail)")
        .accessibilityIdentifier("plan.calendar-awareness")
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

private struct PlanOpportunityWindowsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let windows: PlanOpportunityWindowsState
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
        .accessibilityIdentifier("plan.opportunity-windows")
        .ambitionPanelAccessibility()
    }
}

private struct PlanDecisionListCard: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let emptyTitle: String
    let emptyDetail: String
    let items: [PlanDecisionItemState]
    let accessibilityIdentifier: String
    let onActivate: (PlanDecisionItemState) -> Void

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
                                PlanDecisionItemRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .disabled(item.target == nil && item.planRoute == nil)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .ambitionPanelAccessibility()
    }
}

private struct PlanDecisionItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: PlanDecisionItemState

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
            if item.target != nil || item.planRoute != nil {
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

private struct PlanCalendarBoundaryContractCard: View {
    @Environment(\.ambitionTheme) private var theme

    let boundary: PlanCalendarBoundaryContractState
    let onPrimaryAction: () -> Void

    var body: some View {
        AppCard(state: boundary.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: boundary.title, subtitle: boundary.detail)

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
                .accessibilityIdentifier("plan.calendar-boundary.primary")
            }
        }
        .accessibilityIdentifier("plan.calendar-boundary")
        .ambitionPanelAccessibility()
    }
}

private struct PlanRecoveryEntryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let recovery: PlanRecoveryEntryState
    let onActivate: (PlanDecisionItemState) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: recovery.title, subtitle: recovery.detail)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(recovery.suggestions) { suggestion in
                        Button {
                            onActivate(suggestion)
                        } label: {
                            PlanDecisionItemRow(item: suggestion)
                        }
                        .buttonStyle(.plain)
                        .disabled(suggestion.target == nil && suggestion.planRoute == nil)
                    }
                }

                Text(recovery.boundary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("plan.recovery-entry")
        .ambitionPanelAccessibility()
    }
}

private struct PlanRealityReflowCard: View {
    @Environment(\.ambitionTheme) private var theme

    let reflow: PlanRealityReflowState
    let onActivate: (PlanReflowSuggestionState) -> Void

    var body: some View {
        AppCard(state: reflow.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: reflow.title, subtitle: reflow.detail)

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
                            PlanReflowSuggestionRow(suggestion: suggestion)
                        }
                        .buttonStyle(.plain)
                        .disabled(suggestion.target == nil && suggestion.planRoute == nil)
                    }
                }

                Text(reflow.noChangeCopy)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("plan.reality-reflow")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanReflowSuggestionRow: View {
    @Environment(\.ambitionTheme) private var theme

    let suggestion: PlanReflowSuggestionState

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

            if suggestion.target != nil || suggestion.planRoute != nil {
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

private struct PlanRecoveryGradientCard: View {
    @Environment(\.ambitionTheme) private var theme

    let gradient: PlanRecoveryGradientState

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
        .accessibilityIdentifier("plan.recovery-gradient")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanSaveTheDayCard: View {
    @Environment(\.ambitionTheme) private var theme

    let saveTheDay: PlanSaveTheDayState

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
                    PlanKeyValueRow(label: "Keep", value: saveTheDay.protectedItem, state: .selected)
                    PlanKeyValueRow(label: "Adjust", value: saveTheDay.adjustment, state: saveTheDay.visualState)
                    PlanKeyValueRow(label: "Recover", value: saveTheDay.recoveryExplanation, state: .success)
                }

                Text(saveTheDay.boundary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("plan.save-the-day")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanReflowReceiptPreviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: PlanReflowReceiptPreviewState

    var body: some View {
        AppCard(state: preview.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: preview.title, subtitle: preview.detail)

                HStack(spacing: theme.spacing.xs) {
                    TagPill(preview.confirmationRequired, icon: "hand.tap", state: preview.visualState)
                    TagPill(preview.undoAvailability, icon: "arrow.uturn.backward", state: .default)
                }

                PlanReceiptFactGroup(title: "Would change", facts: preview.whatChanged, state: preview.visualState)
                PlanReceiptFactGroup(title: "Would not change", facts: preview.whatWouldNotChange, state: .default)

                Text(preview.safeFailureFallback)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("plan.reflow-receipt-preview")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanRecoveryMaturityCard: View {
    @Environment(\.ambitionTheme) private var theme

    let maturity: PlanRecoveryMaturityState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: maturity.title, subtitle: maturity.detail)

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
        .accessibilityIdentifier("plan.recovery-maturity")
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(maturity.title). \(maturity.detail). \(maturity.confirmationBoundary). \(maturity.calendarBoundary). \(maturity.socialBoundary).")
        .accessibilityHint("Review Plan recovery boundaries before confirming any broad change.")
        .ambitionPanelAccessibility()
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

private struct PlanReceiptFactGroup: View {
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

private struct PlanHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let hero: PlanRealityHeroState
    let action: PlanWeekPrimaryAction
    let onPrimaryAction: (PlanWeekPrimaryAction) -> Void

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
                .accessibilityIdentifier("plan.hero.primary-action")
            }
        }
        .accessibilityIdentifier("plan.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct PlanPressureScrubberCard: View {
    @Environment(\.ambitionTheme) private var theme

    let scrubber: PlanPressureScrubberState
    @Binding var selectedDayID: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: scrubber.title, subtitle: scrubber.subtitle)

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
                            .accessibilityIdentifier("plan.scrubber.point.\(point.id)")
                            .accessibilityValue(selectedDayID == point.id ? "selected" : "not selected")
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.pressure-scrubber")
        .ambitionPanelAccessibility()
    }
}

private struct PlanElasticWeekCard: View {
    @Environment(\.ambitionTheme) private var theme

    let days: [PlanElasticWeekDayState]
    @Binding var selectedDayID: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Weekly Plan Strip",
                    subtitle: "Dense days expand, quiet days compress, and open room stays visible instead of disappearing into a calendar grid."
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: theme.spacing.sm) {
                        ForEach(days) { day in
                            Button {
                                selectedDayID = day.id
                            } label: {
                                PlanElasticWeekDayColumn(day: day, isSelected: selectedDayID == day.id)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("plan.day.\(day.id)")
                        }
                    }
                    .padding(.vertical, theme.spacing.xxs)
                }
            }
        }
        .accessibilityIdentifier("plan.weekly-plan-strip")
        .ambitionPanelAccessibility()
    }
}

private struct PlanElasticWeekDayColumn: View {
    @Environment(\.ambitionTheme) private var theme

    let day: PlanElasticWeekDayState
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

private struct PlanBelievabilityCard: View {
    @Environment(\.ambitionTheme) private var theme

    let believability: PlanBelievabilityState
    let selectedDay: PlanElasticWeekDayState
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenWindow: (PlanOpenWindowState) -> Void

    var body: some View {
        AppCard(state: believability.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Week believability",
                    subtitle: "Plan explains why the week looks doable, tight, or overloaded before it asks you to intervene."
                )

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
                                        PlanBelievabilityBlockRow(block: block)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    PlanBelievabilityBlockRow(block: block)
                                }
                            }
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("plan.selected-day.\(selectedDay.id)")

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
        .accessibilityIdentifier("plan.believability-card")
        .ambitionPanelAccessibility()
    }
}

private struct PlanBelievabilityBlockRow: View {
    @Environment(\.ambitionTheme) private var theme

    let block: PlanWeekBlockState

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

private struct PlanExecutionResilienceCard: View {
    @Environment(\.ambitionTheme) private var theme

    let resilience: PlanExecutionResilienceState
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenPlanRoute: (PlanRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: resilience.title,
                    subtitle: resilience.subtitle
                )

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
                            } else if let planRoute = lane.planRoute {
                                onOpenPlanRoute(planRoute)
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

                                if lane.goalTarget != nil || lane.planRoute != nil {
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
                        .disabled(lane.goalTarget == nil && lane.planRoute == nil)
                        .accessibilityIdentifier("plan.resilience.\(lane.id)")
                    }
                }

                if let windowMagnetism = resilience.windowMagnetism {
                    Button {
                        guard let target = windowMagnetism.target else { return }
                        onOpenGoal(target)
                    } label: {
                        PlanCompactSplitPane(
                            dominantTitle: windowMagnetism.title,
                            dominantBody: windowMagnetism.detail,
                            contextTitle: windowMagnetism.dayLabel,
                            contextBody: "\(windowMagnetism.suggestionTitle)\n\(windowMagnetism.suggestionDetail)",
                            state: windowMagnetism.visualState
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(windowMagnetism.target == nil)
                    .accessibilityIdentifier("plan.window-magnetism")
                }
            }
        }
        .accessibilityIdentifier("plan.execution-resilience")
        .ambitionPanelAccessibility()
    }
}

private struct PlanCompactSplitPane: View {
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

private struct PlanShapingActionsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [PlanShapingActionState]
    @Binding var selectedKind: PlanShapingActionKind
    let selectedDay: PlanElasticWeekDayState?
    let onActivate: (PlanShapingActionState) -> Void

    private var selectedAction: PlanShapingActionState? {
        actions.first(where: { $0.kind == selectedKind }) ?? actions.first
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Week-shaping actions",
                    subtitle: "Keep one shaping lane obvious: edit, patch, move later, or lighten."
                )

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
                        .accessibilityIdentifier("plan.action.select.\(action.kind.rawValue)")
                    }
                }

                if let selectedAction {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        PlanCompactSplitPane(
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
                            .accessibilityIdentifier("plan.action.cta")
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: selectedAction.state))
                        .disabled(selectedAction.goalTarget == nil && selectedAction.planRoute == nil)
                        .accessibilityLabel(callToActionTitle(for: selectedAction))
                        .accessibilityHint(selectedAction.recommendation)
                        .accessibilityIdentifier("plan.action.cta")
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.action-lane")
        .ambitionPanelAccessibility()
    }

    private func callToActionTitle(for action: PlanShapingActionState) -> String {
        if action.planRoute == .capturesInbox {
            return "Open Capture"
        }
        if action.goalTarget != nil {
            return "Open goal"
        }
        return action.title
    }
}

private struct PlanGoalRelationshipCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [PlanGoalShapingItem]
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

                if items.isEmpty {
                    Text("Once active goals carry real work, they will show up here with their week relationship and next doable move.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(items) { item in
                            Button {
                                guard let target = item.target else { return }
                                onOpenGoal(target)
                            } label: {
                                PlanGoalRelationshipRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .disabled(item.target == nil)
                            .accessibilityIdentifier("plan.goal.open.\(item.id)")
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.goal-relationship-card")
        .ambitionPanelAccessibility()
    }
}

private struct PlanGoalRelationshipRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: PlanGoalShapingItem

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
                Text("Next doable move: \(item.nextMoveLabel)")
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

private struct PlanSecondaryDestinationsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let destinations: [PlanSecondaryDestination]
    let onOpen: (PlanSecondaryDestination) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Plan-owned support routes", subtitle: "Rituals, Capture, and review stay subordinate so the week remains the dominant workspace.")

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
                        .accessibilityIdentifier("plan.open-\(destination.id)-button")
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview("Plan Seeded") {
    NavigationStack {
        PlanScreen(viewModel: PlanViewModel(state: .loaded(PreviewPlanScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Plan Empty") {
    NavigationStack {
        PlanScreen(viewModel: PlanViewModel(state: .loaded(PreviewPlanScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
