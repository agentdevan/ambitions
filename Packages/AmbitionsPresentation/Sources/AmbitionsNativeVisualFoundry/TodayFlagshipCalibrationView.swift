import SwiftUI

public struct TodayFlagshipCalibrationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?
    @ScaledMetric(relativeTo: .body) private var sectionSpacing = 23.0

    @Binding private var state: TodayFlagshipJourneyState
    @State private var isDockExpanded: Bool

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
        .onChange(of: state.phase) { _, phase in
            routeAccessibilityFocus(for: phase)
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
                    .padding(.top, 12)
                    .padding(.bottom, sectionSpacing)
                    .background(palette.semanticPlane)
                    .accessibilityIdentifier("tfcs-today-crown")

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: sectionSpacing) {
                            if usesAdaptiveNavigation {
                                TodayFlagshipAdaptiveNavigationPassage(
                                    palette: palette,
                                    onCommand: onNavigationCommand
                                )
                            }

                            if state.phase == .todayReturned {
                                returnedContinuity
                                startHere(step: content.revealedStartHereStep)
                            } else {
                                startHere(step: content.primaryStep)
                            }

                            timeline
                        }
                        .frame(maxWidth: 560, alignment: .leading)
                        .padding(.leading, 24)
                        .padding(.trailing, rootTrailingPadding)
                        .padding(.bottom, 54)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: state.phase) { _, phase in
                        guard phase == .todayReturned else { return }
                        let anchor = content.returnContract.focusAnchorID
                        if reduceMotion {
                            proxy.scrollTo(anchor, anchor: .top)
                        } else {
                            withAnimation(.easeOut(duration: 0.28)) {
                                proxy.scrollTo(anchor, anchor: .top)
                            }
                        }
                    }
                }
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
                    isExpanded: $isDockExpanded,
                    palette: palette,
                    onCommand: onNavigationCommand
                )
                .padding(.trailing, isDockExpanded ? 12 : 2)
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
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-today-crown")
    }

    private var crownTitle: some View {
        Text(content.presentContext.crownTitle)
            .font(.title3.weight(.semibold))
            .accessibilityAddTraits(.isHeader)
    }

    private var crownRelationship: some View {
        Text(content.presentContext.relationship)
            .font(.caption)
            .foregroundStyle(palette.secondaryInk)
    }

    private func startHere(step: TodayFlagshipStepSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Start Here")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.articulationAccent)

            Text(step.title)
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            TodayFlagshipLocalSeam(palette: palette) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(step.currentAcceptedTruth)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(step.whyItFitsNow)
                        .font(.footnote)
                        .foregroundStyle(palette.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(step.materialConsequence)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(palette.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        _ = state.openStartHere()
                    } label: {
                        Text(step.primaryActionTitle)
                            .foregroundStyle(palette.actionInk)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 7))
                    .controlSize(.large)
                    .frame(minHeight: 44, alignment: .leading)
                    .accessibilityHint("Opens this Step without changing it")
                    .accessibilityIdentifier("tfcs-open-start-here")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityFocused($accessibilityFocus, equals: .startHere)
        .accessibilityIdentifier("tfcs-start-here")
    }

    private var returnedContinuity: some View {
        TodayFlagshipLocalSeam(palette: palette) {
            VStack(alignment: .leading, spacing: 7) {
                TodayFlagshipSectionLabel(
                    content.returnContract.settledLocationTitle,
                    symbol: "checkmark.seal",
                    palette: palette
                )

                Text(content.primaryStep.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.acceptedTruth)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .id(content.returnContract.focusAnchorID)
        .accessibilityElement(children: .combine)
        .accessibilityFocused($accessibilityFocus, equals: .returnedSettledStep)
        .accessibilityIdentifier("tfcs-returned-settled-step")
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Today’s Timeline")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            ForEach(content.timeline) { item in
                timelineItem(item)
            }
        }
        .padding(.top, 2)
        .accessibilityIdentifier("tfcs-timeline")
    }

    private func timelineItem(_ item: TodayFlagshipTimelineObject) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.objectTitle)
                .font(.body.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.timeLabel)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)

                Text(item.relationship)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if item.isProtected || item.isFixed {
                Text(item.acceptedState)
                    .font(.caption)
                    .foregroundStyle(palette.tertiaryInk)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(item.objectTitle), \(item.timeLabel), \(item.relationship), \(item.acceptedState)"
        )
    }

    private var truthfulFallback: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.title2.weight(.semibold))
            Text("That object is no longer here. Today remains available.")
                .foregroundStyle(palette.secondaryInk)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .background(palette.semanticPlane)
        .navigationTitle("Today")
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
            set: { state.updateNavigationPath($0) }
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

    private func routeAccessibilityFocus(for phase: TodayFlagshipJourneyPhase) {
        switch phase {
        case .todayInitial:
            accessibilityFocus = .startHere
        case .todayReturned:
            accessibilityFocus = .returnedSettledStep
        default:
            break
        }
    }
}
