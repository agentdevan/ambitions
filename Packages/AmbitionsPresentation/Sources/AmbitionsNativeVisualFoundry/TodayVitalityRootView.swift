import SwiftUI

struct TodayVitalityRootView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let shellPalette: TodayFlagshipPalette
    let usesAdaptiveNavigation: Bool
    let trailingPadding: CGFloat
    let onNavigationCommand: (TodayFlagshipNavigationCommand) -> Void
    let onCrownScrollProgress: (CGFloat) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if usesAdaptiveNavigation {
                        TodayFlagshipAdaptiveNavigationPassage(
                            copy: content.interfaceCopy,
                            commands: TodayFlagshipNavigationCommand.allCases,
                            palette: shellPalette,
                            onCommand: onNavigationCommand
                        )
                    }

                    TodayVitalityStartHere(
                        copy: content.interfaceCopy,
                        step: visibleStartHere,
                        palette: vitalityPalette,
                        showsAction: state.phase != .todayReturned,
                        onOpen: {
                            _ = state.openStartHere()
                        }
                    )
                    .accessibilityFocused($accessibilityFocus, equals: .startHere)

                    if let contextSeam = content.contextSeam,
                       contextSeam.affectedObjectID == visibleStartHere.id {
                        TodayVitalityContextSeam(
                            seam: contextSeam,
                            palette: vitalityPalette
                        )
                    }

                    TodayVitalityTimelineView(
                        content: content,
                        phase: state.phase,
                        palette: vitalityPalette,
                        shouldFocusFullDayAction: state.focusAnchor == .fullDayAction,
                        onOpenFullDay: {
                            _ = state.openFullDay()
                        }
                    )
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.leading, 24)
                .padding(.trailing, trailingPadding)
                .padding(.bottom, 72)
            }
            .contentMargins(
                .trailing,
                usesAdaptiveNavigation ? 0 : 54,
                for: .scrollIndicators
            )
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                min(max(0, geometry.contentOffset.y + geometry.contentInsets.top) / 56, 1)
            } action: { _, progress in
                onCrownScrollProgress(progress)
            }
            .onChange(of: state.phase) { _, phase in
                routeFocus(for: phase)
                guard phase == .todayReturned else { return }
                withAnimation(motionPolicy.stateAnimation) {
                    proxy.scrollTo(content.returnContract.focusAnchorID, anchor: .center)
                }
            }
        }
    }

    private var visibleStartHere: TodayFlagshipStepSnapshot {
        state.phase == .todayReturned ? content.revealedStartHereStep : content.primaryStep
    }

    private var vitalityPalette: TodayVitalityPalette {
        TodayVitalityPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast,
            differentiateWithoutColor: differentiateWithoutColor,
            reduceTransparency: reduceTransparency
        )
    }

    private var motionPolicy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
    }

    private func routeFocus(for phase: TodayFlagshipJourneyPhase) {
        switch phase {
        case .todayInitial:
            accessibilityFocus = .startHere
        case .todayReturned:
            break
        default:
            break
        }
    }
}

private struct TodayVitalityStartHere: View {
    let copy: TodayFlagshipInterfaceCopy
    let step: TodayFlagshipStepSnapshot
    let palette: TodayVitalityPalette
    let showsAction: Bool
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            Text(copy.startHereTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.ambitionsAccentMuted)
                .accessibilityAddTraits(.isHeader)

            Text(step.title)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Label(step.parentPursuitTitle, systemImage: "house")
                .font(TodayVitalityTypographyRole.relationship.font)
                .foregroundStyle(palette.ambitionsAccentMuted)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("tfcs-root-parent-pursuit")

            presentField

            temporalRelationship

            if showsAction {
                Button(action: onOpen) {
                    ZStack {
                        Text(step.primaryActionTitle)
                            .multilineTextAlignment(.center)

                        HStack {
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .accessibilityHidden(true)
                        }
                    }
                    .frame(minHeight: 48)
                }
                .buttonStyle(
                    TodayVitalityActionStyle(
                        role: .continuation,
                        palette: palette
                    )
                )
                .accessibilityHint(copy.openStartHereHint)
                .accessibilityInputLabels([step.primaryActionTitle, copy.startHereTitle])
                .accessibilityIdentifier("tfcs-open-start-here")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            [copy.startHereTitle, step.title, step.parentPursuitTitle]
                .joined(separator: ", ")
        )
        .accessibilityValue(copy.nowAnchorTitle)
        .accessibilityIdentifier("tfcs-start-here-object")
    }

    private var presentField: some View {
        HStack(alignment: .top, spacing: 8) {
            TodayVitalityRailNode(
                kind: .current,
                palette: palette,
                extendsAfter: true
            )

            VStack(alignment: .leading, spacing: 11) {
                Text(copy.rightNowTitle)
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.ambitionsAccentMuted)

                Text(step.currentAcceptedTruth)
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .foregroundStyle(palette.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(step.startHereSummary)
                    .font(TodayVitalityTypographyRole.relationship.font)
                    .foregroundStyle(palette.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 7)
            .padding(.bottom, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-root-current-truth")
    }

    private var temporalRelationship: some View {
        Label {
            Text("\(step.temporalContext.exactTime) · \(step.temporalContext.relationship)")
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "clock")
                .accessibilityHidden(true)
        }
        .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit())
        .foregroundStyle(palette.labelSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(
            showsAction ? "tfcs-root-time-relationship" : "tfcs-returned-start-here-time"
        )
    }
}
