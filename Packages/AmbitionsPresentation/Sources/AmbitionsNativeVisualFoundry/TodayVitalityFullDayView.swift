import SwiftUI

func todayVitalityFullDayObjects(
    content: TodayFlagshipCalibrationContent,
    origin: TodayFlagshipFullDayOrigin,
    acceptedTruth: String
) -> [TodayFlagshipTimelineObject] {
    guard origin == .todayReturned else {
        return content.supporting.fullDay.entries
    }

    return content.supporting.fullDay.entries.map { item in
        guard item.canonicalObjectID == content.primaryStep.id else { return item }
        return TodayFlagshipTimelineObject(
            id: item.id,
            canonicalObjectID: item.canonicalObjectID,
            objectTitle: item.objectTitle,
            timeLabel: item.timeLabel.replacingOccurrences(of: "Now · ", with: ""),
            relationship: acceptedTruth,
            acceptedState: acceptedTruth,
            role: .ordinary
        )
    }
}

struct TodayVitalityFullDayView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var focusedObjectID: String?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let origin: TodayFlagshipFullDayOrigin

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    contentTitle

                    ForEach(Array(objects.enumerated()), id: \.element.id) { index, item in
                        row(
                            item,
                            extendsAfter: index < objects.count
                        )
                        .id(item.canonicalObjectID)
                        .accessibilityFocused(
                            $focusedObjectID,
                            equals: item.canonicalObjectID
                        )
                    }

                    Spacer(minLength: 0)
                        .overlay(alignment: .leading) {
                            HStack(spacing: 0) {
                                TodayVitalityOpenRailContinuation()
                                    .stroke(
                                        palette.nodeColor(for: .open),
                                        style: StrokeStyle(
                                            lineWidth: palette.separatorStrokeWidth,
                                            lineCap: .round,
                                            dash: [3, 4]
                                        )
                                    )
                                    .frame(width: 44)

                                Spacer(minLength: 0)
                            }
                        }
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tfcs-full-day-timeline")
                .frame(maxWidth: 560, alignment: .leading)
                .containerRelativeFrame(.vertical, alignment: .top)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
            .background(palette.canvas)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomChrome(proxy: proxy)
            }
            .navigationTitle("")
            .onAppear {
                focusNow(proxy: proxy, shouldScroll: false)
            }
            .onChange(of: state.focusAnchor) { _, anchor in
                guard anchor == .fullDayStep else { return }
                focusNow(proxy: proxy, shouldScroll: true)
            }
        }
        .background {
            palette.canvas.ignoresSafeArea()
        }
        .accessibilityIdentifier("tfcs-full-day-root")
    }

    private var contentTitle: some View {
        Text(content.interfaceCopy.fullDayTitle)
            .font(TodayVitalityTypographyRole.objectIdentity.font)
            .foregroundStyle(palette.labelPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            .padding(.bottom, 18)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("r13-full-day-title")
    }

    @ViewBuilder
    private func row(
        _ item: TodayFlagshipTimelineObject,
        extendsAfter: Bool
    ) -> some View {
        if isInspectable(item) {
            Button {
                _ = state.openStepFromFullDay(id: item.canonicalObjectID)
            } label: {
                rowContent(
                    item,
                    extendsAfter: extendsAfter,
                    showsDisclosure: true
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens this Step without changing it.")
            .accessibilityInputLabels([item.objectTitle])
            .accessibilityIdentifier("tfcs-full-day-now-\(item.canonicalObjectID)")
        } else {
            rowContent(
                item,
                extendsAfter: extendsAfter,
                showsDisclosure: false
            )
            .accessibilityIdentifier(identifier(for: item))
        }
    }

    private func rowContent(
        _ item: TodayFlagshipTimelineObject,
        extendsAfter: Bool,
        showsDisclosure: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            TodayVitalityRailNode(
                kind: nodeKind(for: item),
                palette: palette,
                extendsAfter: extendsAfter
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(displayTime(for: item))
                        .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit().weight(.semibold))
                        .foregroundStyle(palette.nodeColor(for: nodeKind(for: item)))
                        .fixedSize(horizontal: false, vertical: true)

                    if isNow(item) && differentiateWithoutColor {
                        Text("Now")
                            .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                            .foregroundStyle(palette.labelPrimary)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(item.objectTitle)
                        .font(TodayVitalityTypographyRole.relationship.font.weight(.semibold))
                        .foregroundStyle(palette.labelPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 4)

                    if showsDisclosure {
                        Image(systemName: "chevron.forward")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.labelSecondary)
                            .accessibilityHidden(true)
                    }
                }

                Text(item.relationship)
                    .font(TodayVitalityTypographyRole.metadata.font)
                    .foregroundStyle(palette.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 7)
            .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 24 : 18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(for: item))
    }

    private func bottomChrome(proxy: ScrollViewProxy) -> some View {
        TodayVitalityFunctionalChrome(palette: palette, isInteractive: true) {
            VStack(alignment: .leading, spacing: 8) {
                Label(nowCue, systemImage: "location.fill")
                    .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit())
                    .foregroundStyle(palette.labelSecondary)

                Button {
                    focusNow(proxy: proxy, shouldScroll: true)
                } label: {
                    Text(content.interfaceCopy.scrollToNowTitle)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("tfcs-scroll-to-now")
                }
                .buttonStyle(
                    TodayVitalityActionStyle(
                        role: .continuation,
                        palette: palette
                    )
                )
                .accessibilityInputLabels([content.interfaceCopy.scrollToNowTitle])
            }
            .padding(12)
        }
        .accessibilityElement(children: .contain)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(palette.canvas.opacity(0.97))
    }

    private var objects: [TodayFlagshipTimelineObject] {
        todayVitalityFullDayObjects(
            content: content,
            origin: origin,
            acceptedTruth: state.acceptedTruth
        )
    }

    private var nowObjectID: String {
        content.nowAnchorObjectID(for: origin)
    }

    private var nowCue: String {
        guard let item = objects.first(where: { $0.canonicalObjectID == nowObjectID }) else {
            return content.interfaceCopy.nowAnchorTitle
        }
        let time = item.timeLabel.replacingOccurrences(of: "Now · ", with: "")
        return "\(content.interfaceCopy.nowAnchorTitle) · \(time)"
    }

    private func isNow(_ item: TodayFlagshipTimelineObject) -> Bool {
        item.canonicalObjectID == nowObjectID
    }

    private func isInspectable(_ item: TodayFlagshipTimelineObject) -> Bool {
        origin == .todayInitial && item.canonicalObjectID == content.primaryStep.id
    }

    private func displayTime(for item: TodayFlagshipTimelineObject) -> String {
        if isNow(item) && item.timeLabel.hasPrefix("Now") == false {
            return "Now · \(item.timeLabel)"
        }
        return item.timeLabel
    }

    private func nodeKind(for item: TodayFlagshipTimelineObject) -> TodayVitalityNodeKind {
        if isNow(item) { return .current }
        if isElapsed(item) { return .elapsed }
        if origin == .todayReturned && item.canonicalObjectID == content.primaryStep.id {
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

    private func isElapsed(_ item: TodayFlagshipTimelineObject) -> Bool {
        item.canonicalObjectID == "event.deep-work"
    }

    private func identifier(for item: TodayFlagshipTimelineObject) -> String {
        if origin == .todayReturned && item.canonicalObjectID == content.primaryStep.id {
            return "tfcs-full-day-settled-\(item.canonicalObjectID)"
        }
        if isNow(item) {
            return "tfcs-full-day-now-\(item.canonicalObjectID)"
        }
        return "tfcs-full-day-row-\(item.canonicalObjectID)"
    }

    private func accessibilityLabel(for item: TodayFlagshipTimelineObject) -> String {
        [displayTime(for: item), item.objectTitle, item.relationship, item.acceptedState]
            .joined(separator: ", ")
    }

    private func focusNow(proxy: ScrollViewProxy, shouldScroll: Bool) {
        if shouldScroll {
            if reduceMotion {
                proxy.scrollTo(nowObjectID, anchor: .center)
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(nowObjectID, anchor: .center)
                }
            }
        }
        focusedObjectID = nowObjectID
    }

    private var palette: TodayVitalityPalette {
        TodayVitalityPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast,
            differentiateWithoutColor: differentiateWithoutColor,
            reduceTransparency: reduceTransparency
        )
    }
}

private struct TodayVitalityOpenRailContinuation: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
