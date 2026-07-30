import SwiftUI

struct TimeNativeCalibrationMeasuredTimeline: View {
    let fixture: TimeNativeCalibrationFixture
    let dayID: TimeNativeCalibrationDayID
    let focused: Bool
    let focusAnchor: TimeNativeCalibrationFocusAnchor
    let onOpenObject: (String) -> Void
    let onOpenReview: (String) -> Void

    private let labelWidth: CGFloat = 52
    @AccessibilityFocusState private var focusedObjectID: String?

    var body: some View {
        let scale = scale
        GeometryReader { proxy in
            let contentWidth = max(220, proxy.size.width - labelWidth - 4)
            ZStack(alignment: .topLeading) {
                hourRules(scale: scale, contentWidth: contentWidth)
                if dayID == .wednesday {
                    nowRule(scale: scale, contentWidth: contentWidth)
                }
                ForEach(fixture.objects(on: dayID)) { object in
                    if object.truth == .openCapacity {
                        openCapacityMarker(
                            object: object,
                            scale: scale,
                            contentWidth: contentWidth
                        )
                    } else {
                        objectBlock(
                            object: object,
                            scale: scale,
                            contentWidth: contentWidth
                        )
                    }
                }
            }
        }
        .frame(height: CGFloat(scale.height) + 12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tnc-d07-timeline-\(dayID.rawValue)")
        .onChange(of: focusAnchor, initial: true) { _, newAnchor in
            switch newAnchor {
            case let .temporalObject(objectID), let .conflictProposal(objectID):
                focusedObjectID = objectID
            default:
                break
            }
        }
    }

    private var scale: TimeNativeCalibrationScale {
        if dayID == .wednesday {
            if focused {
                return .init(startMinute: 13 * 60, endMinute: 20 * 60, pointsPerHour: 96)
            }
            return .init(startMinute: 13 * 60 + 30, endMinute: 19 * 60 + 15, pointsPerHour: 88)
        } else if dayID == .thursday {
            return .init(startMinute: 8 * 60 + 30, endMinute: 12 * 60, pointsPerHour: 96)
        } else {
            return .init(startMinute: 8 * 60, endMinute: 18 * 60, pointsPerHour: 72)
        }
    }

    @ViewBuilder
    private func hourRules(
        scale: TimeNativeCalibrationScale,
        contentWidth: CGFloat
    ) -> some View {
        let firstHour = (scale.startMinute + 59) / 60
        let finalHour = scale.endMinute / 60
        ForEach(firstHour...finalHour, id: \.self) { hour in
            let yOffset = CGFloat(scale.yOffset(for: hour * 60))
            Text(hourLabel(hour))
                .font(.caption.monospacedDigit())
                .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                .frame(width: labelWidth - 8, alignment: .trailing)
                .offset(y: yOffset - 8)
                .accessibilityHidden(true)

            Rectangle()
                .fill(TimeNativeCalibrationPalette.rule)
                .frame(width: contentWidth, height: 1)
                .offset(x: labelWidth, y: yOffset)
                .accessibilityHidden(true)
        }
    }

    private func nowRule(
        scale: TimeNativeCalibrationScale,
        contentWidth: CGFloat
    ) -> some View {
        let yOffset = CGFloat(scale.yOffset(for: fixture.nowMinute))
        return ZStack(alignment: .leading) {
            Circle()
                .fill(TimeNativeCalibrationPalette.now)
                .frame(width: 8, height: 8)
                .offset(x: labelWidth - 4)
            Rectangle()
                .fill(TimeNativeCalibrationPalette.now)
                .frame(width: contentWidth, height: 1)
                .offset(x: labelWidth)
            Text("3:12 PM")
                .font(.caption2.monospacedDigit().weight(.semibold))
                .foregroundStyle(TimeNativeCalibrationPalette.now)
                .padding(.horizontal, 4)
                .background(TimeNativeCalibrationPalette.background)
                .offset(x: labelWidth + 6, y: -16)
        }
        .offset(y: yOffset)
        .accessibilityElement()
        .accessibilityLabel("Now, Wednesday at 3:12 PM")
        .accessibilityIdentifier("tnc-d07-now")
    }

    private func objectBlock(
        object: TimeNativeCalibrationObject,
        scale: TimeNativeCalibrationScale,
        contentWidth: CGFloat
    ) -> some View {
        let yOffset = CGFloat(scale.yOffset(for: object.startMinute))
        let exactHeight = object.endMinute.map {
            CGFloat(scale.durationHeight(startMinute: object.startMinute, endMinute: $0))
        } ?? 1
        let placement = blockPlacement(for: object, contentWidth: contentWidth)

        return Button {
            if object.conflictParticipantIDs.isEmpty {
                onOpenObject(object.id)
            } else {
                onOpenReview(object.id)
            }
        } label: {
            TimeNativeCalibrationBlock(object: object, exactHeight: exactHeight)
        }
        .buttonStyle(.plain)
        .frame(width: placement.width, height: exactHeight)
        .contentShape(Rectangle())
        .offset(x: labelWidth + placement.x, y: yOffset)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(object.accessibilityLabel)
        .accessibilityHint(
            object.conflictParticipantIDs.isEmpty
                ? "Opens compact temporal object detail"
                : "Opens current and proposed conflict review"
        )
        .accessibilityInputLabels([object.title])
        .accessibilityIdentifier("tnc-d07-object-\(object.id)")
        .accessibilityFocused($focusedObjectID, equals: object.id)
    }

    private func openCapacityMarker(
        object: TimeNativeCalibrationObject,
        scale: TimeNativeCalibrationScale,
        contentWidth: CGFloat
    ) -> some View {
        let yOffset = CGFloat(scale.yOffset(for: object.startMinute))
        return VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .fill(TimeNativeCalibrationPalette.rule)
                .frame(width: contentWidth, height: 1)
            HStack(spacing: 6) {
                Image(systemName: "arrow.right")
                Text(object.timeLabel)
                    .fontWeight(.semibold)
                Text(object.title)
            }
            .font(.caption)
            Text(object.meaning ?? "")
                .font(.caption2)
                .foregroundStyle(TimeNativeCalibrationPalette.secondary)
        }
        .offset(x: labelWidth, y: yOffset)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(object.accessibilityLabel)
        .accessibilityIdentifier("tnc-d07-open-capacity")
    }

    private func blockPlacement(
        for object: TimeNativeCalibrationObject,
        contentWidth: CGFloat
    ) -> (x: CGFloat, width: CGFloat) {
        if object.id == "placement.family-time.wed-1730" {
            return (0, contentWidth * 0.68)
        }
        if object.id == "proposal.launch-review.wed-1745" {
            return (contentWidth * 0.62, contentWidth * 0.38)
        }
        return (0, contentWidth)
    }

    private func hourLabel(_ hour: Int) -> String {
        switch hour {
        case 0:
            "12 AM"
        case 1..<12:
            "\(hour) AM"
        case 12:
            "12 PM"
        default:
            "\(hour - 12) PM"
        }
    }
}

private struct TimeNativeCalibrationBlock: View {
    let object: TimeNativeCalibrationObject
    let exactHeight: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(background)
            border
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: symbolName)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(symbolColor)
                VStack(alignment: .leading, spacing: 1) {
                    Text(object.title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    if exactHeight >= 42 {
                        Text(compactStatus)
                            .font(.caption2)
                            .foregroundStyle(TimeNativeCalibrationPalette.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
        }
        .clipped()
    }

    @ViewBuilder
    private var border: some View {
        switch object.truth {
        case .acceptedFixed:
            HStack(spacing: 0) {
                Rectangle().fill(Color.white).frame(width: 4)
                Spacer()
            }
        case .acceptedProtected:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.86), lineWidth: 2)
        case .externalObservation:
            HStack(spacing: 3) {
                Rectangle().fill(Color.cyan.opacity(0.9)).frame(width: 2)
                Rectangle().fill(Color.cyan.opacity(0.45)).frame(width: 2)
                Spacer()
            }
        case .proposedPlacement:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    TimeNativeCalibrationPalette.proposal,
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
        case .openCapacity:
            EmptyView()
        }
    }

    private var background: Color {
        switch object.truth {
        case .acceptedFixed:
            TimeNativeCalibrationPalette.accepted
        case .acceptedProtected:
            TimeNativeCalibrationPalette.protected
        case .externalObservation:
            TimeNativeCalibrationPalette.external
        case .proposedPlacement, .openCapacity:
            TimeNativeCalibrationPalette.plane.opacity(0.92)
        }
    }

    private var symbolName: String {
        switch object.truth {
        case .acceptedFixed:
            "pin.fill"
        case .acceptedProtected:
            "lock.fill"
        case .externalObservation:
            "arrow.down.left.circle"
        case .proposedPlacement:
            "circle.dashed"
        case .openCapacity:
            "arrow.right"
        }
    }

    private var symbolColor: Color {
        object.truth == .proposedPlacement
            ? TimeNativeCalibrationPalette.proposal
            : .white
    }

    private var compactStatus: String {
        switch object.truth {
        case .acceptedFixed:
            "Fixed"
        case .acceptedProtected:
            object.meaning ?? "Protected"
        case .externalObservation:
            "Apple Calendar"
        case .proposedPlacement:
            "Proposed"
        case .openCapacity:
            "Open"
        }
    }
}
