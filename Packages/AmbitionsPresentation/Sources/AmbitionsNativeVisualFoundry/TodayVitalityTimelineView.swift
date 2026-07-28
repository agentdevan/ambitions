import SwiftUI

func todayReturnedOverviewObjects(
    content: TodayFlagshipCalibrationContent
) -> [TodayFlagshipTimelineObject] {
    let settled = TodayFlagshipTimelineObject(
        id: content.returnContract.focusAnchorID,
        canonicalObjectID: content.primaryStep.id,
        objectTitle: "Nursery progress recorded",
        timeLabel: content.primaryStep.temporalContext.fullDayTimeLabel ?? "10:30 AM",
        relationship: content.primaryStep.title,
        acceptedState: content.primaryStep.stillCountsProposal.settledTruth,
        role: .ordinary
    )
    let remaining = todayOverviewObjects(
        content: content,
        visibleStartHereID: content.revealedStartHereStep.id
    ).filter {
        $0.canonicalObjectID != content.primaryStep.id
            && $0.role != .fixed
    }
    return [settled] + Array(remaining.prefix(2))
}

struct TodayVitalityTimelineView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var isFullDayActionFocused: Bool
    @AccessibilityFocusState private var isReturnedSettledStepFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let phase: TodayFlagshipJourneyPhase
    let palette: TodayVitalityPalette
    let shouldFocusFullDayAction: Bool
    let onOpenFullDay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(content.interfaceCopy.timelineTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.labelSecondary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("tfcs-timeline")

            VStack(spacing: 0) {
                ForEach(Array(objects.enumerated()), id: \.element.id) { index, item in
                    timelineRow(item, at: index)

                    if let contextSeam = content.contextSeam,
                       contextSeam.affectedObjectID == item.canonicalObjectID {
                        TodayVitalityContextSeam(
                            seam: contextSeam,
                            palette: palette
                        )
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tfcs-today-overview")

            Button(action: onOpenFullDay) {
                HStack(spacing: 12) {
                    Text(content.interfaceCopy.viewFullDayTitle)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.forward")
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 48)
            }
            .buttonStyle(
                TodayVitalityActionStyle(
                    role: .navigationDisclosure,
                    palette: palette
                )
            )
            .accessibilityInputLabels([content.interfaceCopy.viewFullDayTitle])
            .accessibilityFocused($isFullDayActionFocused)
            .accessibilityIdentifier("tfcs-view-full-day")
            .onAppear {
                isFullDayActionFocused = shouldFocusFullDayAction
            }
            .onChange(of: shouldFocusFullDayAction) { _, shouldFocus in
                guard shouldFocus else { return }
                isFullDayActionFocused = true
            }
        }
        .animation(motionPolicy.stateAnimation, value: objects.map(\.id))
        .onAppear {
            isReturnedSettledStepFocused = phase == .todayReturned
        }
        .onChange(of: phase) { _, newPhase in
            isReturnedSettledStepFocused = newPhase == .todayReturned
        }
    }

    private var objects: [TodayFlagshipTimelineObject] {
        if phase == .todayReturned {
            return todayReturnedOverviewObjects(content: content)
        }
        return todayOverviewObjects(
            content: content,
            visibleStartHereID: content.primaryStep.id
        )
    }

    private var motionPolicy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
    }

    @ViewBuilder
    private func timelineRow(
        _ item: TodayFlagshipTimelineObject,
        at index: Int
    ) -> some View {
        let isSettledReturn = phase == .todayReturned
            && item.canonicalObjectID == content.primaryStep.id
        let row = TodayVitalityTimelineRow(
            item: item,
            palette: palette,
            isSettledReturn: isSettledReturn,
            extendsAfter: index < objects.count - 1
        )

        if isSettledReturn {
            row.accessibilityFocused($isReturnedSettledStepFocused)
        } else {
            row
        }
    }
}

struct TodayVitalityRailNode: View {
    let kind: TodayVitalityNodeKind
    let palette: TodayVitalityPalette
    let extendsAfter: Bool

    var body: some View {
        VStack(spacing: 0) {
            TodayVitalityNode(kind: kind, palette: palette)

            Rectangle()
                .fill(palette.separator)
                .frame(width: palette.separatorStrokeWidth)
                .frame(maxHeight: .infinity)
                .opacity(extendsAfter ? 1 : 0)
        }
        .frame(width: 44)
        .frame(minHeight: 54)
        .accessibilityHidden(true)
    }
}

private struct TodayVitalityTimelineRow: View {
    let item: TodayFlagshipTimelineObject
    let palette: TodayVitalityPalette
    let isSettledReturn: Bool
    let extendsAfter: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            TodayVitalityRailNode(
                kind: nodeKind,
                palette: palette,
                extendsAfter: extendsAfter
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.timeLabel)
                    .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit().weight(.semibold))
                    .foregroundStyle(nodeColor)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.objectTitle)
                    .font(TodayVitalityTypographyRole.relationship.font.weight(.semibold))
                    .foregroundStyle(palette.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.relationship)
                    .font(TodayVitalityTypographyRole.metadata.font)
                    .foregroundStyle(palette.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if isSettledReturn {
                    Text(item.acceptedState)
                        .font(TodayVitalityTypographyRole.metadata.font)
                        .foregroundStyle(palette.labelSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 7)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .id(isSettledReturn ? item.id : item.canonicalObjectID)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(
            isSettledReturn
                ? "tfcs-returned-settled-step"
                : "tfcs-overview-row-\(item.canonicalObjectID)"
        )
    }

    private var accessibilityLabel: String {
        [item.objectTitle, item.timeLabel, item.relationship, item.acceptedState]
            .joined(separator: ", ")
    }

    private var nodeKind: TodayVitalityNodeKind {
        if isSettledReturn {
            return .settled
        }
        switch item.role {
        case .fixed:
            return .fixed
        case .protected:
            return .protected
        case .openLane:
            return .open
        case .external:
            return .external
        case .now, .ordinary:
            return .current
        }
    }

    private var nodeColor: Color {
        palette.nodeColor(for: nodeKind)
    }
}
