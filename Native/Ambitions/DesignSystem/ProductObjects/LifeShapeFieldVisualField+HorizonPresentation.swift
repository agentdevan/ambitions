import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldVisualField {
    var horizonStrip: some View {
        VStack(spacing: 0) {
            ForEach(horizonRows) { row in
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: row.kind.systemImage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.stateStyle(for: row.visualState).accent)
                        .frame(width: 24)
                    Text(row.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer(minLength: theme.spacing.sm)
                    Text(row.value)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Image(systemName: "chevron.right")
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 44)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle.opacity(0.28))
                        .frame(height: 1)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(row.title). \(row.accessibilitySummary)")
                .accessibilityValue(row.isOperational ? "Available" : "Staged")
                .accessibilityHint(row.isOperational ? "Time foundation signal is available." : "Time foundation signal is staged until local context exists.")
                .accessibilityIdentifier(row.id)
            }
        }
        .padding(.horizontal, theme.spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.88 : 0.46))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.78 : 0.34), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time horizons")
        .accessibilityValue(horizonRows.map(\.accessibilitySummary).joined(separator: ". "))
        .accessibilityIdentifier("time.life-shape-field.horizon-strip")
    }

    var accessibilityValue: String {
        [
            reading.accessibilitySummary,
            selectedMark?.accessibilitySummary,
            "\(selectedLayer.title) layer selected.",
            selectedLayer == .open && field.canPlaceStep == false ? field.placementUnavailableReason : nil,
            field.sourceState.privacyLabel
        ]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    var instrumentSegments: [LifeShapeSegment] {
        let order: [LifeShapeSegmentKind] = [.openTime, .protectedTime, .pressure, .buffer, .recovery, .goalTime]
        var segments = order.compactMap { kind in
            field.segments.first { $0.kind == kind } ?? fallbackSegment(for: kind)
        }
        if let source = field.segments.first(where: { $0.kind == .source }) {
            segments.append(source)
        }
        return segments
    }

    func fallbackSegment(for kind: LifeShapeSegmentKind) -> LifeShapeSegment? {
        switch kind {
        case .buffer:
            return LifeShapeSegment(
                kind: .buffer,
                detail: "No buffer has been added yet.",
                valueLabel: "None yet",
                weight: 0,
                visualState: .default
            )
        default:
            return nil
        }
    }

    var horizonRows: [TimeCalendarRow] {
        let preferredIDs = [
            "time.calendar.now",
            "time.calendar.fixed-point",
            "time.calendar.open-window",
            "time.calendar.scheduled-step",
            "time.calendar.protected-window",
            "time.calendar.pressure",
            "time.calendar.buffer",
            "time.calendar.day",
            "time.calendar.week",
            "time.calendar.month",
            "time.calendar.year",
            "time.calendar.list"
        ]
        let byID = Dictionary(uniqueKeysWithValues: field.calendarRows.map { ($0.id, $0) })
        return preferredIDs.compactMap { byID[$0] }.prefix(isAccessibilitySize ? 11 : 6).map { $0 }
    }

    var visibleHorizonTitle: String {
        switch reading.horizon {
        case .day:
            "Today"
        case .week:
            "This week"
        case .month:
            "This month"
        case .year:
            "This year"
        }
    }

    var nextFixedPointLabel: String {
        let protected = field.segments.first { $0.kind == .protectedTime }
        if protected?.weight ?? 0 > 0 {
            return "Fixed point visible"
        }
        return "No fixed blocks yet"
    }

    var protectedBoundaryLabel: String {
        let protected = field.segments.first { $0.kind == .protectedTime }
        guard let protected, protected.weight > 0 else {
            return "None marked yet"
        }
        return protected.valueLabel.humanInstrumentValue
    }

    var selectedWindowLabel: String {
        switch selectedLayer {
        case .open:
            return field.placementCandidate?.title ?? "Choose a Step"
        case .protected:
            return protectedBoundaryLabel
        case .pressure:
            return "Review pressure"
        case .buffer:
            return "Add buffer"
        }
    }

    var selectedLayerDetail: String {
        if selectedLayer == .open, field.canPlaceStep == false {
            return field.placementUnavailableReason
        }
        return selectedLayer.cardDetail(reading: reading, mark: selectedMark).humanRootCopy
    }

    var visiblePrimaryActionTitle: String {
        if selectedLayer == .open, primaryActionEnabled == false {
            return "Choose Step"
        }
        return primaryActionTitle
    }

    var selectedLayerTint: Color {
        layerTint(selectedLayer)
    }

    func layerTint(_ layer: LifeShapeLayer) -> Color {
        switch layer {
        case .open:
            theme.stateStyle(for: .success).accent
        case .protected:
            theme.stateStyle(for: .selected).accent
        case .pressure:
            theme.stateStyle(for: .warning).accent
        case .buffer:
            theme.stateStyle(for: .default).accent
        }
    }
}
