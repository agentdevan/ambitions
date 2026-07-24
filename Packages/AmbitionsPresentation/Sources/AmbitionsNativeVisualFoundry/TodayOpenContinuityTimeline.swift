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

    if let affectedObjectID = content.contextSeam?.affectedObjectID,
       affectedObjectID != visibleStartHereID {
        selectFirst { $0.canonicalObjectID == affectedObjectID }
    }
    selectFirst { $0.role == .fixed }
    selectFirst { $0.role == .protected }
    selectFirst { $0.role == .openLane }
    selectFirst { $0.role == .ordinary || $0.role == .external }

    var emittedCanonicalObjectIDs = Set<String>()
    return candidates.filter { candidate in
        guard selectedCanonicalObjectIDs.contains(candidate.canonicalObjectID) else {
            return false
        }
        return emittedCanonicalObjectIDs.insert(candidate.canonicalObjectID).inserted
    }
}

struct TodayOpenContinuityTimeline: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var isFullDayActionFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let visibleStartHereID: String
    let mode: TodayOpenContinuityTimelineMode
    let palette: TodayFlagshipPalette
    let shouldFocusFullDayAction: Bool
    var onOpenFullDay: (() -> Void)?

    init(
        content: TodayFlagshipCalibrationContent,
        visibleStartHereID: String,
        mode: TodayOpenContinuityTimelineMode,
        palette: TodayFlagshipPalette,
        shouldFocusFullDayAction: Bool = false,
        onOpenFullDay: (() -> Void)? = nil
    ) {
        self.content = content
        self.visibleStartHereID = visibleStartHereID
        self.mode = mode
        self.palette = palette
        self.shouldFocusFullDayAction = shouldFocusFullDayAction
        self.onOpenFullDay = onOpenFullDay
    }

    var body: some View {
        let renderedObjects = objects

        VStack(alignment: .leading, spacing: 10) {
            timelineHeading

            VStack(spacing: 0) {
                ForEach(Array(renderedObjects.enumerated()), id: \.element.id) { index, item in
                    VStack(spacing: 0) {
                        TodayOpenContinuityTimelineRow(
                            item: item,
                            anchorTitle: anchorTitle(for: item),
                            palette: palette,
                            showsContinuation: index < renderedObjects.count - 1,
                            isOverview: mode == .overview
                        )

                        if let contextSeam = content.contextSeam,
                           contextSeam.affectedObjectID == item.canonicalObjectID {
                            TodayOpenContinuityContextSeam(
                                seam: contextSeam,
                                palette: palette
                            )
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            mode == .overview ? "tfcs-today-overview" : "tfcs-full-day-timeline"
        )
        .animation(motionPolicy.stateAnimation, value: renderedObjects.map(\.id))
    }

    private var motionPolicy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
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

                    overviewTrailingContent
                }

                VStack(alignment: .leading, spacing: 2) {
                    timelineTitle
                    overviewTrailingContent
                }
            }
        }
    }

    @ViewBuilder
    private var overviewTrailingContent: some View {
        if mode == .overview, let onOpenFullDay {
            Button(action: onOpenFullDay) {
                Label(
                    content.interfaceCopy.viewFullDayTitle,
                    systemImage: "chevron.forward"
                )
                .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                .padding(.vertical, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .foregroundStyle(palette.articulationAccent)
            .accessibilityFocused($isFullDayActionFocused)
            .accessibilityIdentifier("tfcs-view-full-day")
            .onAppear {
                isFullDayActionFocused = shouldFocusFullDayAction
            }
            .onChange(of: shouldFocusFullDayAction) { _, shouldFocus in
                guard shouldFocus else { return }
                isFullDayActionFocused = true
            }
        } else if mode == .overview {
            Text(content.interfaceCopy.timelineContextTitle)
                .font(TodayOpenContinuityTypographyRole.metadata.font)
                .foregroundStyle(palette.tertiaryInk)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    private var timelineTitle: some View {
        Text(
            mode == .overview
                ? content.interfaceCopy.timelineTitle
                : content.interfaceCopy.timelineTitle
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
        switch item.role {
        case .fixed:
            return content.interfaceCopy.nextFixedAnchorTitle
        case .protected:
            return content.interfaceCopy.protectedAnchorTitle
        case .openLane:
            return content.interfaceCopy.openLaneAnchorTitle
        case .now:
            return content.interfaceCopy.nowAnchorTitle
        case .ordinary, .external:
            return item.acceptedState
        }
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
        switch item.role {
        case .now, .ordinary:
            .current
        case .fixed:
            .fixed
        case .protected:
            .protected
        case .external:
            .external
        case .openLane:
            .openLane
        }
    }
}
