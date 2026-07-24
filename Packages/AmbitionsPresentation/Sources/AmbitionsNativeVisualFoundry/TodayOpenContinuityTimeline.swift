import SwiftUI

enum TodayOpenContinuityTimelineMode {
    case overview
    case fullDay
}

func todayOverviewObjects(
    content: TodayFlagshipCalibrationContent,
    visibleStartHereID: String
) -> [TodayFlagshipTimelineObject] {
    let candidates = content.timeline.filter {
        $0.canonicalObjectID != visibleStartHereID
    }
    var selectedCanonicalObjectIDs = Set<String>()

    func selectFirst(
        matching predicate: (TodayFlagshipTimelineObject) -> Bool
    ) {
        guard
            selectedCanonicalObjectIDs.count < 4,
            let candidate = candidates.first(where: {
                selectedCanonicalObjectIDs.contains($0.canonicalObjectID) == false
                    && predicate($0)
            })
        else {
            return
        }
        selectedCanonicalObjectIDs.insert(candidate.canonicalObjectID)
    }

    selectFirst { $0.isFixed }
    selectFirst { $0.isProtected }
    selectFirst { $0.isOpenLane }
    selectFirst { $0.isFixed == false && $0.isProtected == false && $0.isOpenLane == false }

    var emittedCanonicalObjectIDs = Set<String>()
    return candidates.filter { candidate in
        guard selectedCanonicalObjectIDs.contains(candidate.canonicalObjectID) else {
            return false
        }
        return emittedCanonicalObjectIDs.insert(candidate.canonicalObjectID).inserted
    }
}

struct TodayOpenContinuityTimeline: View {
    let content: TodayFlagshipCalibrationContent
    let visibleStartHereID: String
    let mode: TodayOpenContinuityTimelineMode
    let palette: TodayFlagshipPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            timelineHeading

            VStack(spacing: 0) {
                ForEach(Array(objects.enumerated()), id: \.element.id) { index, item in
                    TodayOpenContinuityTimelineRow(
                        item: item,
                        anchorTitle: anchorTitle(for: item),
                        palette: palette,
                        showsContinuation: index < objects.count - 1,
                        isOverview: mode == .overview
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            mode == .overview ? "tfcs-today-overview" : "tfcs-full-day-timeline"
        )
    }

    private var timelineHeading: some View {
        HStack(alignment: .center, spacing: 9) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 28, height: 38)
            .padding(.leading, 5)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    timelineTitle

                    Spacer(minLength: 0)

                    if mode == .overview {
                        Text(content.interfaceCopy.timelineContextTitle)
                            .font(TodayOpenContinuityTypographyRole.metadata.font)
                            .foregroundStyle(palette.tertiaryInk)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }

                timelineTitle
            }
        }
    }

    private var timelineTitle: some View {
        Text(
            mode == .overview
                ? content.interfaceCopy.timelineTitle
                : content.interfaceCopy.fullDayTitle
        )
        .font(.headline.weight(.semibold))
        .foregroundStyle(palette.primaryInk)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("tfcs-timeline")
    }

    private var objects: [TodayFlagshipTimelineObject] {
        switch mode {
        case .overview:
            todayOverviewObjects(
                content: content,
                visibleStartHereID: visibleStartHereID
            )
        case .fullDay:
            content.timeline.filter { $0.canonicalObjectID != visibleStartHereID }
        }
    }

    private func anchorTitle(for item: TodayFlagshipTimelineObject) -> String {
        if item.isFixed {
            return content.interfaceCopy.nextFixedAnchorTitle
        }
        if item.isProtected {
            return content.interfaceCopy.protectedAnchorTitle
        }
        if item.isOpenLane {
            return content.interfaceCopy.openLaneAnchorTitle
        }
        return item.acceptedState
    }
}

private struct TodayOpenContinuityTimelineRow: View {
    let item: TodayFlagshipTimelineObject
    let anchorTitle: String
    let palette: TodayFlagshipPalette
    let showsContinuation: Bool
    let isOverview: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            TodayOpenContinuitySpine(
                kind: nodeKind,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: showsContinuation
            )
            .frame(width: 28)
            .frame(minHeight: isOverview ? 58 : 68)
            .padding(.leading, 5)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.objectTitle)
                        .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 4)

                    Text(item.timeLabel)
                        .font(TodayOpenContinuityTypographyRole.metadata.font.monospacedDigit())
                        .foregroundStyle(palette.tertiaryInk)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("\(anchorTitle) · \(item.relationship)")
                    .font(TodayOpenContinuityTypographyRole.metadata.font)
                    .foregroundStyle(stateColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isOverview ? 8 : 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            [item.objectTitle, item.timeLabel, item.relationship, anchorTitle]
                .joined(separator: ", ")
        )
        .accessibilityIdentifier(
            "\(isOverview ? "tfcs-overview-row" : "tfcs-full-day-row")-\(item.canonicalObjectID)"
        )
    }

    private var stateColor: Color {
        switch nodeKind {
        case .fixed, .proposed, .saving:
            palette.articulationAccent
        case .protected, .settled:
            palette.settledAccent
        default:
            palette.tertiaryInk
        }
    }

    private var nodeKind: TodayOpenContinuityNodeKind {
        if item.isProtected {
            return .protected
        }
        if item.isFixed {
            return .fixed
        }
        if item.isOpenLane {
            return .openLane
        }
        return .current
    }
}
