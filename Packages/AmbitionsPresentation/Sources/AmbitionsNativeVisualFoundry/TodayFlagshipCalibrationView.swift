import SwiftUI

public struct TodayFlagshipCalibrationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var crownSpacing = 14.0

    @Binding private var state: TodayFlagshipJourneyState
    @State private var isDockExpanded: Bool
    @State private var crownScrollProgress: CGFloat = 0

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
        NavigationStack(path: navigationPath) {
            todayRoot
                .navigationDestination(for: TodayFlagshipRoute.self) { route in
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
                            TodayFlagshipFocusedStepView(
                                content: content,
                                state: $state
                            )
                        } else {
                            truthfulFallback
                        }
                    }
                }
        }
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
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: state.navigationPath) { oldPath, newPath in
            guard oldPath.isEmpty == false, newPath.isEmpty else { return }
            _ = state.returnByNativeBackNavigation()
        }
        .tint(palette.actionAccent)
        .accessibilityIdentifier("tfcs-journey-root")
    }

    private var todayRoot: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                crown
                    .frame(maxWidth: 560, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 24)
                    .padding(.trailing, rootTrailingPadding)
                    .padding(.top, 12 - (4 * crownScrollProgress))
                    .padding(.bottom, crownSpacing - (8 * crownScrollProgress))
                    .background(palette.semanticPlane)

                TodayOpenContinuityRoot(
                    content: content,
                    state: $state,
                    palette: palette,
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
                    reduceMotion ? nil : .easeOut(duration: 0.22),
                    value: isDockExpanded
                )
            }
        }
        .background {
            palette.semanticPlane
                .ignoresSafeArea()
        }
        .foregroundStyle(palette.primaryInk)
        .todayFlagshipHideRootNavigationBar()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-today-root")
    }

    private var crown: some View {
        Group {
            if usesAdaptiveNavigation {
                VStack(alignment: .leading, spacing: 4) {
                    crownTitle
                    crownRelationship
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    crownTitle
                    crownRelationship
                }
            }
        }
        .frame(
            height: (usesAdaptiveNavigation ? 46 : 26) - (6 * crownScrollProgress),
            alignment: .leading
        )
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.todayAccessibilityHeading)
        .accessibilityValue(crownAccessibilityValue)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("tfcs-today-heading")
    }

    private var crownTitle: some View {
        Text(content.interfaceCopy.ambitionsWordmark)
            .font(.subheadline.weight(.semibold))
    }

    private var crownRelationship: some View {
        Text(content.presentContext.relationship)
            .font(.caption)
            .foregroundStyle(palette.secondaryInk)
            .opacity(1 - crownScrollProgress)
            .offset(y: -3 * crownScrollProgress)
    }

    private var crownAccessibilityValue: String {
        [
            content.interfaceCopy.ambitionsWordmark,
            content.presentContext.relationship
        ].joined(separator: ", ")
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

}
