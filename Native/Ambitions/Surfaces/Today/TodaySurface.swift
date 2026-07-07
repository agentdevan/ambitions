import AmbitionsDesignSystem
import Foundation
import SwiftUI

// Mutation/accessibility/proof contract: Today actions route through TodayViewModel runtime mutations, visibly update the Meridian stage, announce closure/recovery results, and save proof artifacts.
struct TodaySurface: View {
    let autoLoad: Bool
    let showsNavigationChrome: Bool

    // Canon marker for frontend recovery gates: TodayExecutionDepthDisclosure.
    @Environment(\.appShellCapability) var appShellCapability
    @Environment(\.appFeatureFactoryCapability) var appFeatureFactoryCapability
    @Environment(\.appUserSystemCapability) var appUserSystemCapability
    @Environment(\.ambitionTheme) var theme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State var viewModel: TodayViewModel
    @State var selectedStepDetail: DayRailStepDetailState?
    @State var selectedActionClosure: TodayActionClosureSheetState?
    @State var selectedRejectionReasonSheet: TodayRejectionReasonSheetState?
    @State var selectedStepReplacementSheet: TodayStepReplacementSheetState?
    @State var selectedWindowProtection: TodayWindowProtectionFlowState?
    @State var selectedTimeShape: TodayTimeShapeFlowState?
    @State var approvedReplacementRail: AmbitionsDayRailViewState?
    #if DEBUG
    @State var debugScreenshotSheetApplied = false
    #endif

    @MainActor
    init(viewModel: TodayViewModel? = nil, autoLoad: Bool = true, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TodayViewModel())
        self.autoLoad = autoLoad
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ZStack(alignment: .top) {
            TodayBackgroundView(clock: clock)

            todayContent
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, bottomChromeClearance)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .refreshable {
                    await refresh()
                }
        }
        .accessibilityIdentifier("today.screen")
        .navigationTitle(showsNavigationChrome ? "Today" : "")
        .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .inline : .large)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .overlay(alignment: .topLeading) {
            if let message = viewModel.transientMessage {
                TodayInlineReceiptState(message: message)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(item: $selectedStepDetail) { detail in
            TodayStepDetailSheet(detail: detail) { action in
                selectedStepDetail = nil
                handleAction(action)
            }
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedActionClosure) { closure in
            TodayActionClosureSheet(state: closure) { outcome in
                selectedActionClosure = nil
                Task {
                    await viewModel.confirmActionClosure(
                        closure,
                        outcome: outcome,
                        using: featureFactory.todayReceiptCommands,
                        refreshService: featureFactory.todayService,
                        userDisplayName: userSystem.session.userDisplayName,
                        now: clock.now,
                        calendar: clock.calendar,
                        entryContext: shell.navigation.takeTodayEntryContext(),
                        timeZone: clock.timeZone
                    )
                }
            }
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedRejectionReasonSheet) { sheetState in
            TodayRejectionReasonSheet(state: sheetState) { submission in
                selectedRejectionReasonSheet = nil
                Task {
                    await submitRejection(submission, from: sheetState)
                }
            }
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedStepReplacementSheet) { sheetState in
            TodayStepReplacementSheet(
                state: sheetState,
                onWhyNotThis: {
                    selectedStepReplacementSheet = nil
                    selectedRejectionReasonSheet = rejectionReasonSheetState(for: sheetState.originalHero)
                },
                onApprove: { option in
                    selectedStepReplacementSheet = nil
                    if let currentRail = currentDisplayRail() {
                        approvedReplacementRail = sheetState.approvedRail(
                            from: currentRail,
                            selectedOption: option
                        )
                    }
                    viewModel.transientMessage = sheetState.approvalReceiptMessage(for: option)
                }
            )
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedWindowProtection) { flowState in
            TodayWindowProtectionFlow(state: flowState) {
                selectedWindowProtection = nil
            }
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedTimeShape) { flowState in
            TodayTimeShapeFlow(state: flowState) {
                selectedTimeShape = nil
            }
            .ambitionTheme(theme)
        }
        .onChange(of: shell.navigation.selectedTab) { _, selectedTab in
            guard autoLoad, selectedTab == .today else { return }
            Task { await activate() }
        }
        .onChange(of: shell.navigation.todayEntryContext) { _, entryContext in
            guard autoLoad, shell.navigation.selectedTab == .today, entryContext != .standard else { return }
            Task { await activate() }
        }
        .task {
            guard autoLoad else { return }
            await activate()
        }
        .task {
            guard autoLoad, clock.advancesAutomatically else { return }
            await observeDayBoundary()
        }
        #if DEBUG
        .task(id: viewModel.stateKey) {
            applyDebugScreenshotSheetIfNeeded()
        }
        #endif
    }

    #if DEBUG
    #endif
}

struct TodayInlineFallbackState: View {
    @Environment(\.ambitionTheme) var theme

    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Image(systemName: systemImage)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.accentWarm)
            Text(title)
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Text(message)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.top, theme.spacing.xxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TodayInlineReceiptState: View {
    @Environment(\.ambitionTheme) var theme

    let message: TodayInlineMessage

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(message.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(message.body)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .shadow(color: theme.depth.overlay.color, radius: theme.depth.overlay.radius, x: theme.depth.overlay.x, y: theme.depth.overlay.y)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(message.title)
        .accessibilityValue(message.body)
        .accessibilityIdentifier("today.inline-message")
    }
}

#if DEBUG
#Preview("Today MFP") {
    NavigationStack {
        TodaySurface(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.stable)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.stable))
    .ambitionTheme(.dark)
}

#Preview("Today MFP Dynamic Type") {
    NavigationStack {
        TodaySurface(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.overloaded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.overloaded))
    .ambitionTheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
