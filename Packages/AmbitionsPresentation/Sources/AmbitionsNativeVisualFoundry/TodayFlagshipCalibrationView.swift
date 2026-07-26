import SwiftUI

#if os(iOS)
import UIKit
#endif

public struct TodayFlagshipCalibrationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding private var state: TodayFlagshipJourneyState
    @State private var isDockExpanded: Bool
    @State private var crownScrollProgress: CGFloat = 0
    @State private var recoveryDetent: PresentationDetent = .medium

    private let content: TodayFlagshipCalibrationContent
    private let onNavigationCommand: (TodayFlagshipNavigationCommand) -> Void
    private let onCommitProposal: @MainActor () async -> Bool

    public init(
        content: TodayFlagshipCalibrationContent,
        state: Binding<TodayFlagshipJourneyState>,
        initialDockExpanded: Bool = false,
        onNavigationCommand: @escaping (TodayFlagshipNavigationCommand) -> Void = { _ in },
        onCommitProposal: @escaping @MainActor () async -> Bool = { true }
    ) {
        self.content = content
        _state = state
        _isDockExpanded = State(initialValue: initialDockExpanded)
        self.onNavigationCommand = onNavigationCommand
        self.onCommitProposal = onCommitProposal
    }

    public var body: some View {
        presentedJourney
            .onChange(of: state.navigationPath, reconcileNativeBack)
            .sensoryFeedback(.success, trigger: state.phase) { oldPhase, newPhase in
                oldPhase == .savingAcceptedTruth && newPhase == .settled
            }
            .onChange(of: state.phase, announceTransition)
            .tint(palette.actionAccent)
            .accessibilityIdentifier("tfcs-journey-root")
    }

    private var navigationRoot: some View {
        NavigationStack(path: navigationPath) {
            todayRoot
                .navigationDestination(for: TodayFlagshipRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    private var presentedJourney: some View {
        navigationRoot
        .todayFlagshipConsequentialReview(isPresented: reviewPresentation) {
            TodayFlagshipReviewView(
                content: content,
                state: $state,
                onCommitProposal: onCommitProposal
            )
        }
        .sheet(isPresented: recoveryPresentation) {
            TodayFlagshipRecoveryReviewView(
                content: content,
                state: $state
            )
            .presentationDetents([.medium, .large], selection: $recoveryDetent)
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func destination(for route: TodayFlagshipRoute) -> some View {
        switch route {
        case let .fullDay(origin):
            TodayOpenContinuityFullDayView(
                content: content,
                state: $state,
                origin: origin,
                palette: palette
            )
        case let .step(id):
            if id == content.primaryStep.id {
                TodayFlagshipFocusedStepView(content: content, state: $state)
            } else {
                truthfulFallback
            }
        }
    }

    private var todayRoot: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                TodayVitalityRootCrown(
                    copy: content.interfaceCopy,
                    relationship: content.presentContext.relationship,
                    palette: palette,
                    scrollProgress: crownScrollProgress
                )
                    .frame(maxWidth: 560, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 24)
                    .padding(.trailing, rootTrailingPadding)
                    .padding(.top, 12 - (4 * crownScrollProgress))
                    .padding(.bottom, 14 - (8 * crownScrollProgress))
                    .background(palette.semanticPlane)

                TodayVitalityRootView(
                    content: content,
                    state: $state,
                    shellPalette: palette,
                    usesAdaptiveNavigation: usesAdaptiveNavigation,
                    trailingPadding: rootTrailingPadding,
                    onNavigationCommand: onNavigationCommand,
                    onCrownScrollProgress: { progress in
                        crownScrollProgress = progress
                    }
                )
            }
            .allowsHitTesting(isDockExpanded == false)
            .accessibilityHidden(isDockExpanded)

            if isDockExpanded && usesAdaptiveNavigation == false {
                palette.semanticPlane
                    .opacity(0.93)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isDockExpanded = false
                    }
                    .accessibilityHidden(true)
            }

            if usesAdaptiveNavigation == false {
                TodayFlagshipDock(
                    copy: content.interfaceCopy,
                    commands: TodayFlagshipNavigationCommand.allCases,
                    isExpanded: $isDockExpanded,
                    palette: palette,
                    onCommand: onNavigationCommand
                )
                .padding(.trailing, isDockExpanded ? 0 : 2)
                .animation(
                    motionPolicy.stateAnimation,
                    value: isDockExpanded
                )
            }
        }
        .background {
            palette.semanticPlane
                .ignoresSafeArea()
        }
        .foregroundStyle(palette.primaryInk)
        .navigationTitle(content.interfaceCopy.todayNavigationTitle)
        .todayFlagshipHideRootNavigationBar()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-today-root")
    }

    private var truthfulFallback: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(content.interfaceCopy.fallbackTodayTitle)
                .font(.title2.weight(.semibold))
            Text(content.interfaceCopy.fallbackTodayBody)
                .foregroundStyle(palette.secondaryInk)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .background(palette.semanticPlane)
        .navigationTitle(content.interfaceCopy.fallbackTodayTitle)
    }

    private var reviewPresentation: Binding<Bool> {
        Binding(
            get: { state.isReviewPresented },
            set: { isPresented in
                guard isPresented == false, state.phase == .reviewingProposal else {
                    return
                }
                _ = state.cancelReview()
            }
        )
    }

    private var navigationPath: Binding<[TodayFlagshipRoute]> {
        Binding(
            get: { state.navigationPath },
            set: { state.reconcileNavigationPath($0) }
        )
    }

    private var recoveryPresentation: Binding<Bool> {
        Binding(
            get: { state.isRecoveryPresented },
            set: { isPresented in
                guard isPresented == false, state.phase == .recoveryReview else {
                    return
                }
                _ = state.dismissRecovery()
            }
        )
    }

    private var usesAdaptiveNavigation: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var rootTrailingPadding: CGFloat {
        if usesAdaptiveNavigation {
            return 24
        }
        return 68
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }

    private var motionPolicy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
    }

    private func announceTransition(
        from oldPhase: TodayFlagshipJourneyPhase,
        to newPhase: TodayFlagshipJourneyPhase
    ) {
        let announcement: String?
        switch (oldPhase, newPhase) {
        case (_, .interrupted):
            announcement = content.interfaceCopy.interruptionAnnouncement
        case (_, .recoveryReview), (_, .recoveredContinuation):
            announcement = content.interfaceCopy.recoveryAnnouncement
        case (.savingAcceptedTruth, .settled):
            announcement = content.interfaceCopy.settlementAnnouncement
        case (.settled, .todayReturned):
            announcement = content.interfaceCopy.returnAnnouncement
        default:
            announcement = nil
        }

        #if os(iOS)
        if let announcement {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
        #endif
    }

    private func reconcileNativeBack(
        _ oldPath: [TodayFlagshipRoute],
        _ newPath: [TodayFlagshipRoute]
    ) {
        guard oldPath.isEmpty == false, newPath.isEmpty else { return }
        _ = state.returnByNativeBackNavigation()
    }

}
