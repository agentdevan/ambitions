import AmbitionsDesignSystem
import SwiftUI

// AMBITIONS-QUALITY-EXTRACTION: Visual support extensions live in LifeShapeFieldVisualFieldSupport.swift; this file keeps the root instrument anatomy together for review.
struct LifeShapeFieldVisualField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let reading: LifeShapeReading
    let field: LifeShapeFieldState
    let selectedLayer: LifeShapeLayer
    let selectedMarks: [LifeShapeSemanticMark]
    let selectedMark: LifeShapeSemanticMark?
    let primaryActionTitle: String
    let displayedRenderState: LifeShapeRenderState
    let onSelectMark: (LifeShapeSemanticMark) -> Void
    let onPrimaryAction: () -> Void

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }
    private var selectedStyle: AmbitionStateStyle { theme.stateStyle(for: selectedVisualState) }
    private var selectedVisualState: AmbitionVisualState {
        selectedMark?.visualState ?? field.capacityFit.visualState
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            fieldStage
            horizonStrip
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("LifeShape Field")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("time.life-shape-field.now-instrument")
    }

    private var fieldStage: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                fieldBackground
                starDust
                orbitalRings
                layerBands(in: size)
                nowSweep(in: size)
                fixedPoints(in: size)
                centerReadout
                bottomActionCard
            }
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        selectedStyle.stroke.opacity(colorSchemeContrast == .increased ? 0.82 : 0.42),
                        lineWidth: colorSchemeContrast == .increased ? 1.5 : 1
                    )
            }
        }
        .frame(height: isAccessibilitySize ? 480 : 430)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("LifeShape visual field")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("time.life-shape-field.primary-object")
    }

    private var fieldBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.canvas.opacity(reduceTransparency ? 0.98 : 0.92))

            RadialGradient(
                colors: [
                    selectedLayer.tint.opacity(reduceTransparency ? 0.26 : 0.18),
                    theme.colors.canvasElevated.opacity(reduceTransparency ? 0.44 : 0.24),
                    .clear
                ],
                center: .center,
                startRadius: 24,
                endRadius: isAccessibilitySize ? 280 : 260
            )
        }
        .accessibilityHidden(true)
    }

    private var starDust: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    Circle()
                        .fill(theme.colors.textTertiary.opacity(index % 3 == 0 ? 0.24 : 0.12))
                        .frame(width: CGFloat(1 + index % 3), height: CGFloat(1 + index % 3))
                        .position(starPosition(index: index, in: proxy.size))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private var orbitalRings: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height - 116)
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .stroke(
                            selectedLayer.tint.opacity(index == 1 ? 0.22 : 0.10),
                            style: StrokeStyle(
                                lineWidth: index == 1 ? 1.2 : 0.8,
                                lineCap: .round,
                                dash: index == 3 ? [2, 7] : []
                            )
                        )
                        .frame(
                            width: diameter * CGFloat(0.46 + Double(index) * 0.15),
                            height: diameter * CGFloat(0.46 + Double(index) * 0.15)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 76)
        }
        .accessibilityHidden(true)
    }

    private func layerBands(in size: CGSize) -> some View {
        let diameter = min(size.width, size.height - 116)
        return ZStack {
            ForEach(Array(layerBandSpecs.enumerated()), id: \.offset) { index, spec in
                LifeShapeArcShape(start: spec.start, end: spec.end)
                    .stroke(
                        spec.color.opacity(selectedLayer == spec.layer ? 0.90 : 0.42),
                        style: StrokeStyle(
                            lineWidth: selectedLayer == spec.layer ? 22 : 16,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .shadow(color: spec.color.opacity(selectedLayer == spec.layer ? 0.46 : 0.16), radius: selectedLayer == spec.layer ? 14 : 6)
                    .frame(
                        width: diameter * CGFloat(0.54 + Double(index % 2) * 0.13),
                        height: diameter * CGFloat(0.54 + Double(index % 2) * 0.13)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 76)
        .accessibilityHidden(true)
    }

    private func nowSweep(in size: CGSize) -> some View {
        let diameter = min(size.width, size.height - 116)
        return ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            selectedLayer.tint.opacity(0.82),
                            selectedLayer.tint.opacity(0.28),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: diameter * 0.30, height: colorSchemeContrast == .increased ? 2 : 1.2)
                .offset(x: -diameter * 0.31)
                .rotationEffect(.degrees(selectedLayer.sweepDegrees))

            Circle()
                .fill(selectedLayer.tint)
                .frame(width: 12, height: 12)
                .shadow(color: selectedLayer.tint.opacity(0.7), radius: 10)
                .offset(y: -diameter * 0.29)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 76)
        .accessibilityHidden(true)
    }

    private func fixedPoints(in size: CGSize) -> some View {
        let diameter = min(size.width, size.height - 116)
        return ZStack {
            ForEach(Array(visualPoints.enumerated()), id: \.element.id) { index, point in
                Button {
                    if let mark = point.mark {
                        onSelectMark(mark)
                    }
                } label: {
                    VStack(spacing: theme.spacing.xxxs) {
                        Circle()
                            .fill(point.color)
                            .frame(width: point.isSelected ? 13 : 9, height: point.isSelected ? 13 : 9)
                            .overlay(Circle().stroke(theme.colors.textPrimary.opacity(0.84), lineWidth: 1))
                            .shadow(color: point.color.opacity(point.isSelected ? 0.76 : 0.28), radius: point.isSelected ? 10 : 4)
                        if isAccessibilitySize == false {
                            Text(point.title)
                                .font(theme.typography.micro.weight(point.isSelected ? .semibold : .regular))
                                .foregroundStyle(point.isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 86)
                        }
                    }
                }
                .buttonStyle(.plain)
                .position(pointPosition(index: index, count: max(visualPoints.count, 1), radius: diameter * 0.39, size: size))
                .accessibilityLabel(point.accessibilityLabel)
                .accessibilityValue(point.accessibilityValue)
            }
        }
        .padding(.bottom, 76)
    }

    private var centerReadout: some View {
        let metric = selectedLayer.centerMetric(for: field, mark: selectedMark)
        return VStack(spacing: theme.spacing.xxxs) {
            Text("Now")
                .font(.system(size: isAccessibilitySize ? 15 : 12, weight: .semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .textCase(.uppercase)
            Text(metric.primary)
                .font(.system(size: isAccessibilitySize ? 42 : 40, weight: .semibold))
                .foregroundStyle(selectedLayer.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(metric.secondary)
                .font(.system(size: isAccessibilitySize ? 19 : 18, weight: .semibold))
                .foregroundStyle(theme.colors.textPrimary.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(metric.caption)
                .font(.system(size: isAccessibilitySize ? 14 : 13, weight: .medium))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.78)
        }
        .frame(width: isAccessibilitySize ? 220 : 200)
        .padding(.vertical, isAccessibilitySize ? 18 : 16)
        .background {
            Circle()
                .fill(theme.colors.canvas.opacity(reduceTransparency ? 0.96 : 0.72))
                .shadow(color: selectedLayer.tint.opacity(0.22), radius: 24)
        }
        .padding(.bottom, isAccessibilitySize ? 86 : 74)
        .accessibilityHidden(true)
    }

    private var bottomActionCard: some View {
        VStack {
            Spacer()
            HStack(spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    Circle()
                        .stroke(selectedLayer.tint, lineWidth: 1.2)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Circle()
                                .fill(selectedLayer.tint.opacity(0.72))
                                .frame(width: 6, height: 6)
                        }
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(selectedLayer.cardTitle(mark: selectedMark))
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text(selectedLayer.cardDetail(reading: reading, mark: selectedMark))
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: onPrimaryAction) {
                    Label(primaryActionTitle, systemImage: selectedLayer.actionSymbol)
                        .font(theme.typography.caption.weight(.semibold))
                        .labelStyle(.titleAndIcon)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .frame(minHeight: 44)
                        .padding(.horizontal, theme.spacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(selectedLayer.tint)
                .accessibilityIdentifier("time.life-shape-field.primary-action")
            }
            .padding(theme.spacing.sm)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.92 : 0.64))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.82 : 0.42), lineWidth: 1)
            }
            .padding(theme.spacing.sm)
        }
    }

    private var horizonStrip: some View {
        VStack(spacing: 0) {
            ForEach(horizonRows) { row in
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: row.symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(row.color)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time horizons")
        .accessibilityValue(horizonRows.map { "\($0.title), \($0.value)" }.joined(separator: ". "))
    }

    private var accessibilityValue: String {
        [
            reading.accessibilitySummary,
            selectedMark?.accessibilitySummary,
            "\(selectedLayer.title) layer selected.",
            field.sourceState.privacyLabel
        ]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    private var layerBandSpecs: [LifeShapeLayerBandSpec] {
        [
            LifeShapeLayerBandSpec(layer: .open, start: .degrees(180), end: .degrees(352), color: LifeShapeLayer.open.tint),
            LifeShapeLayerBandSpec(layer: .protected, start: .degrees(214), end: .degrees(264), color: LifeShapeLayer.protected.tint),
            LifeShapeLayerBandSpec(layer: .pressure, start: .degrees(8), end: .degrees(64), color: LifeShapeLayer.pressure.tint),
            LifeShapeLayerBandSpec(layer: .buffer, start: .degrees(70), end: .degrees(118), color: LifeShapeLayer.buffer.tint)
        ]
    }

    private var visualPoints: [LifeShapeVisualPoint] {
        let marks = selectedMarks.isEmpty ? Array(field.semanticMarks.prefix(3)) : selectedMarks
        return marks.prefix(4).map { mark in
            LifeShapeVisualPoint(
                id: mark.id,
                title: mark.kind.pointTitle,
                color: mark.kind.layer.tint,
                accessibilityLabel: mark.kind.title,
                accessibilityValue: mark.accessibilitySummary,
                isSelected: mark.id == selectedMark?.id,
                mark: mark
            )
        }
    }

    private var horizonRows: [LifeShapeVisualHorizonRow] {
        let day = field.reading(for: .day)
        let week = field.reading(for: .week)
        let month = field.reading(for: .month)
        return [
            LifeShapeVisualHorizonRow(title: "Today", value: day.capacityStatement.shortVisualLabel, symbol: "sun.max", color: LifeShapeLayer.open.tint),
            LifeShapeVisualHorizonRow(title: "This week", value: week.capacityStatement.shortVisualLabel, symbol: "calendar", color: LifeShapeLayer.protected.tint),
            LifeShapeVisualHorizonRow(title: "Rest of month", value: month.capacityStatement.shortVisualLabel, symbol: "circle.dotted", color: LifeShapeLayer.buffer.tint)
        ]
    }

    private func pointPosition(index: Int, count: Int, radius: CGFloat, size: CGSize) -> CGPoint {
        let angles = [-84.0, -8.0, 92.0, 188.0]
        let angle = Angle.degrees(angles[index % angles.count])
        let center = CGPoint(x: size.width * 0.5, y: (size.height - 76) * 0.48)
        return CGPoint(
            x: center.x + cos(angle.radians) * radius,
            y: center.y + sin(angle.radians) * radius
        )
    }

    private func starPosition(index: Int, in size: CGSize) -> CGPoint {
        let xSeed = CGFloat((index * 37) % 100) / 100
        let ySeed = CGFloat((index * 61) % 100) / 100
        return CGPoint(
            x: size.width * (0.08 + xSeed * 0.84),
            y: size.height * (0.08 + ySeed * 0.64)
        )
    }
}

private struct LifeShapeLayerBandSpec {
    let layer: LifeShapeLayer
    let start: Angle
    let end: Angle
    let color: Color
}

private struct LifeShapeVisualPoint: Identifiable {
    let id: String
    let title: String
    let color: Color
    let accessibilityLabel: String
    let accessibilityValue: String
    let isSelected: Bool
    let mark: LifeShapeSemanticMark?
}

private struct LifeShapeVisualHorizonRow: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let symbol: String
    let color: Color
}

private struct LifeShapeArcShape: Shape {
    let start: Angle
    let end: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        return path
    }
}
