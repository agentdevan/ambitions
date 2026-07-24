import SwiftUI

struct TodayOpenContinuityRoot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let palette: TodayFlagshipPalette
    let usesAdaptiveNavigation: Bool
    let trailingPadding: CGFloat
    let onNavigationCommand: (TodayFlagshipNavigationCommand) -> Void
    let onCrownScrollProgress: (CGFloat) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if usesAdaptiveNavigation {
                        TodayFlagshipAdaptiveNavigationPassage(
                            copy: content.interfaceCopy,
                            commands: TodayFlagshipNavigationCommand.allCases,
                            palette: palette,
                            onCommand: onNavigationCommand
                        )
                    }

                    TodayOpenContinuityStartHere(
                        copy: content.interfaceCopy,
                        step: visibleStartHere,
                        palette: palette,
                        showsAction: state.phase != .todayReturned,
                        onOpen: {
                            _ = state.openStartHere()
                        }
                    )
                    .accessibilityFocused($accessibilityFocus, equals: .startHere)

                    if let contextSeam = content.contextSeam,
                       contextSeam.affectedObjectID == visibleStartHere.id {
                        TodayOpenContinuityContextSeam(
                            seam: contextSeam,
                            palette: palette
                        )
                    }

                    if state.phase == .todayReturned {
                        returnedContinuity
                    }

                    TodayOpenContinuityTimeline(
                        content: timelineContent,
                        visibleStartHereID: visibleStartHere.id,
                        mode: .overview,
                        palette: palette,
                        shouldFocusFullDayAction: state.focusAnchor == .fullDayAction,
                        onOpenFullDay: {
                            _ = state.openFullDay()
                        }
                    )
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.leading, 24)
                .padding(.trailing, trailingPadding)
                .padding(.bottom, 54)
            }
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                onCrownScrollProgress(min(offset / 56, 1))
            }
            .onChange(of: state.phase) { _, phase in
                routeFocus(for: phase)
                guard phase == .todayReturned else { return }
                let anchor = content.returnContract.focusAnchorID
                if reduceMotion {
                    proxy.scrollTo(anchor, anchor: .bottom)
                } else {
                    withAnimation(.easeOut(duration: 0.28)) {
                        proxy.scrollTo(anchor, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var visibleStartHere: TodayFlagshipStepSnapshot {
        state.phase == .todayReturned ? content.revealedStartHereStep : content.primaryStep
    }

    private var timelineContent: TodayFlagshipCalibrationContent {
        guard state.phase == .todayReturned else { return content }
        return content.withTimeline(content.returnedTodayTimeline)
    }

    private var returnedContinuity: some View {
        HStack(alignment: .top, spacing: 9) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 28)
            .frame(minHeight: 84)
            .padding(.leading, 5)

            VStack(alignment: .leading, spacing: 5) {
                Text(content.returnContract.settledLocationTitle)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.settledAccent)

                Text(content.primaryStep.title)
                    .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.acceptedTruth)
                    .font(TodayOpenContinuityTypographyRole.metadata.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(palette.divider)
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
        }
        .id(content.returnContract.focusAnchorID)
        .accessibilityElement(children: .combine)
        .accessibilityFocused($accessibilityFocus, equals: .returnedSettledStep)
        .accessibilityIdentifier("tfcs-returned-settled-step")
    }

    private func routeFocus(for phase: TodayFlagshipJourneyPhase) {
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

struct TodayOpenContinuityStartHere: View {
    let copy: TodayFlagshipInterfaceCopy
    let step: TodayFlagshipStepSnapshot
    let palette: TodayFlagshipPalette
    let showsAction: Bool
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            startHereHeader

            Text(step.title)
                .font(TodayOpenContinuityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.primaryInk)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            currentTruth
            fitAndProtection
            actionRelationship
        }
        .padding(.leading, 38)
        .padding(.trailing, 15)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 4,
                bottomTrailingRadius: 20,
                topTrailingRadius: 4,
                style: .continuous
            )
            .fill(palette.primaryObjectPlane)
        }
        .overlay(alignment: .leading) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: true
            )
            .padding(.leading, 5)
            .padding(.vertical, 7)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            [copy.startHereTitle, step.title, step.parentPursuitTitle]
                .joined(separator: ", ")
        )
        .accessibilityValue(copy.nowAnchorTitle)
        .accessibilityIdentifier("tfcs-start-here-object")
    }

    private var startHereHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(copy.startHereTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.articulationAccent)

                Spacer(minLength: 0)

                Label(step.parentPursuitTitle, systemImage: "scope")
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(copy.startHereTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.articulationAccent)

                Label(step.parentPursuitTitle, systemImage: "scope")
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
            }
        }
    }

    private var currentTruth: some View {
        HStack(alignment: .top, spacing: 10) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: false
            )
            .frame(width: 18, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(copy.rightNowTitle)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)

                Text(step.currentAcceptedTruth)
                    .font(TodayOpenContinuityTypographyRole.state.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 10,
                bottomLeadingRadius: 3,
                bottomTrailingRadius: 10,
                topTrailingRadius: 3,
                style: .continuous
            )
            .fill(palette.currentTruthPlane)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-root-current-truth")
    }

    private var fitAndProtection: some View {
        Label {
            Text(step.startHereSummary)
                .font(TodayOpenContinuityTypographyRole.relationship.font)
                .foregroundStyle(palette.primaryInk)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "shield")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.settledAccent)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-root-fit-protection")
    }

    @ViewBuilder
    private var actionRelationship: some View {
        if showsAction {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    timeRelationship
                    Spacer(minLength: 0)
                    continuationButton
                        .frame(maxWidth: 188)
                }

                VStack(alignment: .leading, spacing: 9) {
                    timeRelationship
                    continuationButton
                }
            }
        } else {
            timeRelationship
                .accessibilityIdentifier("tfcs-returned-start-here-time")
        }
    }

    private var timeRelationship: some View {
        Label {
            VStack(alignment: .leading, spacing: 1) {
                Text(step.temporalContext.relationship)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                Text(step.temporalContext.exactTime)
                    .font(TodayOpenContinuityTypographyRole.relationship.font.monospacedDigit())
            }
        } icon: {
            Image(systemName: "clock")
                .foregroundStyle(palette.tertiaryInk)
        }
        .foregroundStyle(palette.secondaryInk)
        .accessibilityElement(children: .combine)
    }

    private var continuationButton: some View {
        Button(action: onOpen) {
            Text(step.primaryActionTitle)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 46)
        }
        .buttonStyle(TodayOpenContinuityPrimaryActionStyle(palette: palette.openContinuity))
        .accessibilityHint(copy.openStartHereHint)
        .accessibilityIdentifier("tfcs-open-start-here")
    }
}

private extension TodayFlagshipCalibrationContent {
    func withTimeline(_ timeline: [TodayFlagshipTimelineObject]) -> Self {
        Self(
            familyID: familyID,
            isSynthetic: isSynthetic,
            interfaceCopy: interfaceCopy,
            presentContext: presentContext,
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStartHereStep,
            timeline: timeline,
            receipt: receipt,
            returnContract: returnContract,
            recovery: recovery,
            contextSeam: contextSeam
        )
    }
}
