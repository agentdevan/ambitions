import SwiftUI

struct TodayOpenContinuityFullDayView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var isNowFocused: Bool

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let origin: TodayFlagshipFullDayOrigin
    let palette: TodayFlagshipPalette

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    presentContext
                    nowProjection

                    if origin == .todayReturned {
                        settledNurseryProjection
                    }

                    TodayOpenContinuityTimeline(
                        content: timelineContent,
                        visibleStartHereID: nowStep.id,
                        mode: .fullDay,
                        palette: palette
                    )
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(palette.semanticPlane)
            .navigationTitle(content.interfaceCopy.fullDayTitle)
            .todayFlagshipInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation(motionPolicy.stateAnimation) {
                            proxy.scrollTo(nowStep.id, anchor: .top)
                        }
                        isNowFocused = true
                    } label: {
                        Label(
                            content.interfaceCopy.scrollToNowTitle,
                            systemImage: "location.fill"
                        )
                    }
                    .accessibilityInputLabels([content.interfaceCopy.scrollToNowTitle])
                    .accessibilityIdentifier("tfcs-scroll-to-now")
                }
            }
            .onAppear {
                isNowFocused = true
            }
            .onChange(of: state.focusAnchor) { _, anchor in
                guard anchor == .fullDayStep else { return }
                isNowFocused = true
            }
        }
        .background {
            palette.semanticPlane
                .ignoresSafeArea()
        }
        .accessibilityIdentifier("tfcs-full-day-root")
    }

    private var presentContext: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(content.presentContext.relationship)
                .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)

            Text(content.interfaceCopy.timelineContextTitle)
                .font(TodayOpenContinuityTypographyRole.metadata.font)
                .foregroundStyle(palette.tertiaryInk)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var nowProjection: some View {
        if origin == .todayInitial {
            Button {
                _ = state.openStepFromFullDay(id: nowStep.id)
            } label: {
                nowProjectionContent
            }
            .buttonStyle(.plain)
            .accessibilityHint(content.interfaceCopy.openStartHereHint)
            .accessibilityInputLabels([nowStep.title])
            .accessibilityIdentifier("tfcs-full-day-now-\(nowStep.id)")
            .accessibilityFocused($isNowFocused)
        } else {
            nowProjectionContent
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("tfcs-full-day-now-\(nowStep.id)")
                .accessibilityFocused($isNowFocused)
        }
    }

    private var nowProjectionContent: some View {
        TodayFlagshipObjectField(role: .current, palette: palette) {
            VStack(alignment: .leading, spacing: 8) {
                TodayFlagshipLandmarkLabel(
                    title: content.interfaceCopy.nowAnchorTitle,
                    symbol: "location.fill",
                    tint: palette.articulationAccent
                )

                Text(nowStep.title)
                    .font(TodayOpenContinuityTypographyRole.objectIdentity.font)
                    .foregroundStyle(palette.primaryInk)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Label(nowStep.parentPursuitTitle, systemImage: "scope")
                    .font(TodayOpenContinuityTypographyRole.relationship.font)
                    .foregroundStyle(palette.secondaryInk)

                Text(nowStep.currentAcceptedTruth)
                    .font(TodayOpenContinuityTypographyRole.state.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Label {
                    Text(nowTimeLabel)
                } icon: {
                    Image(systemName: "clock")
                }
                .font(TodayOpenContinuityTypographyRole.metadata.font.monospacedDigit())
                .foregroundStyle(palette.tertiaryInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .id(nowStep.id)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            [
                content.interfaceCopy.nowAnchorTitle,
                nowStep.title,
                nowStep.parentPursuitTitle,
                nowStep.currentAcceptedTruth,
                nowTimeLabel
            ].joined(separator: ", ")
        )
    }

    private var settledNurseryProjection: some View {
        HStack(alignment: .top, spacing: 9) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 28)
            .frame(minHeight: 112)
            .padding(.leading, 5)

            VStack(alignment: .leading, spacing: 7) {
                TodayFlagshipLandmarkLabel(
                    title: content.returnContract.settledLocationTitle,
                    symbol: "checkmark.seal",
                    tint: palette.settledAccent
                )

                Text(content.primaryStep.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.acceptedTruth)
                    .font(TodayOpenContinuityTypographyRole.state.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.trailing, 12)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(
            "tfcs-full-day-settled-\(content.primaryStep.id)"
        )
    }

    private var nowStep: TodayFlagshipStepSnapshot {
        let objectID = content.nowAnchorObjectID(for: origin)
        return objectID == content.revealedStartHereStep.id
            ? content.revealedStartHereStep
            : content.primaryStep
    }

    private var nowTimeLabel: String {
        nowStep.temporalContext.fullDayTimeLabel ?? nowStep.temporalContext.exactTime
    }

    private var timelineContent: TodayFlagshipCalibrationContent {
        guard origin == .todayReturned else { return content }
        return content.replacingTimelineForFullDay(content.returnedTodayTimeline)
    }

    private var motionPolicy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
    }
}

private extension TodayFlagshipCalibrationContent {
    func replacingTimelineForFullDay(
        _ replacement: [TodayFlagshipTimelineObject]
    ) -> Self {
        Self(
            familyID: familyID,
            isSynthetic: isSynthetic,
            interfaceCopy: interfaceCopy,
            presentContext: presentContext,
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStartHereStep,
            timeline: replacement,
            receipt: receipt,
            returnContract: returnContract,
            recovery: recovery,
            contextSeam: contextSeam,
            supporting: supporting
        )
    }
}
