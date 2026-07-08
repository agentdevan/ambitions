import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeFieldVisualField: View {
    @Environment(\.ambitionTheme) var theme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let reading: LifeShapeReading
    let field: LifeShapeFieldState
    @Binding var selectedLayer: LifeShapeLayer
    let selectedMarks: [LifeShapeSemanticMark]
    let selectedMark: LifeShapeSemanticMark?
    let primaryActionTitle: String
    let primaryActionEnabled: Bool
    let displayedRenderState: LifeShapeRenderState
    let onSelectMark: (LifeShapeSemanticMark) -> Void
    let onPrimaryAction: () -> Void

    var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }
    private var selectedStyle: AmbitionStateStyle { theme.stateStyle(for: selectedVisualState) }
    private var selectedVisualState: AmbitionVisualState {
        selectedMark?.visualState ?? field.capacityFit.visualState
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Life Calendar")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)
                    .accessibilityIdentifier("time.life-calendar.title")
                Text(visibleHorizonTitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)
                    .accessibilityIdentifier("time.life-calendar.horizon-title")
            }
            fieldStage
            horizonStrip
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Life Calendar")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("time.life-shape-field.primary-object")
    }

    private var fieldStage: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            LifeShapeLayerSelector(selection: $selectedLayer)
            if isAccessibilitySize {
                accessibilityMicroField
            } else {
                calendarField
            }
        }
        .padding(theme.spacing.sm)
        .frame(minHeight: isAccessibilitySize ? 0 : 420, alignment: .top)
        .background(fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    selectedStyle.stroke.opacity(colorSchemeContrast == .increased ? 0.82 : 0.42),
                    lineWidth: colorSchemeContrast == .increased ? 1.5 : 1
                )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time field")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("time.life-shape-field.visual-stage")
    }

    private var accessibilityMicroField: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            selectedLayerReading

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(Array(instrumentSegments.prefix(5))) { segment in
                    accessibilitySegmentRow(segment)
                }
            }

            if selectedMarks.isEmpty == false {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Signals")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                    ForEach(selectedMarks.prefix(3)) { mark in
                        Button {
                            onSelectMark(mark)
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Circle()
                                    .fill(theme.stateStyle(for: mark.visualState).fill)
                                    .frame(width: 14, height: 14)
                                    .overlay {
                                        Circle()
                                            .stroke(theme.stateStyle(for: mark.visualState).stroke, lineWidth: 1)
                                    }
                                    .padding(.top, theme.spacing.xxs)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(mark.kind.pointTitle)
                                        .font(theme.typography.caption.weight(.semibold))
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(mark.detail.humanRootCopy)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, theme.spacing.xxs)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(mark.accessibilitySummary)
                        .accessibilityIdentifier("time.life-shape-field.mark.\(mark.id)")
                    }
                }
            }

            selectedBucket
        }
        .padding(theme.spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.94 : 0.58))
        }
        .overlay(instrumentStroke)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Life Calendar readable field")
        .accessibilityIdentifier("time.life-shape-field.accessibility-stage")
    }

    private func accessibilitySegmentRow(_ segment: LifeShapeSegment) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: segment.kind.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(layerTint(segment.kind.instrumentLayer))
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(segment.kind.instrumentTitle)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(segment.valueLabel.humanInstrumentValue)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(segment.detail.humanRootCopy)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(segment.title), \(segment.valueLabel), \(segment.detail)")
        .accessibilityIdentifier("time.life-shape-field.accessibility-segment.\(segment.kind.rawValue)")
    }

    private var fieldBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.canvas.opacity(reduceTransparency ? 0.98 : 0.92))

            LinearGradient(
                colors: [
                    selectedLayerTint.opacity(reduceTransparency ? 0.24 : 0.14),
                    theme.colors.canvasElevated.opacity(reduceTransparency ? 0.48 : 0.30),
                    theme.colors.canvas.opacity(reduceTransparency ? 0.98 : 0.84)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(theme.colors.strokeSubtle.opacity(index == 2 ? 0.16 : 0.08))
                        .frame(height: 1)
                    Spacer(minLength: 0)
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    var selectedLayerReading: some View {
        if isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(selectedLayer.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(selectedLayerTint)

                Text(accessibilityLayerSentence)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Next fixed point: \(nextFixedPointLabel)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("time.life-shape-field.accessibility-selected-layer")
        } else {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(selectedLayer.title)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(selectedLayerTint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text(selectedLayer.realitySentence(for: field, mark: selectedMark))
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    Text("Next fixed point")
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                        .textCase(.uppercase)
                    Text(nextFixedPointLabel)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                        .minimumScaleFactor(0.74)
                }
            }
        }
    }

    private var microField: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .topLeading) {
                fieldAtmosphere(size: size)

                ForEach(Array(instrumentSegments.prefix(isAccessibilitySize ? 4 : 5).enumerated()), id: \.offset) { index, segment in
                    fieldBand(segment: segment, index: index, size: size)
                }

                nowLine(size: size)

                ForEach(Array(selectedMarks.prefix(isAccessibilitySize ? 3 : 5).enumerated()), id: \.offset) { index, mark in
                    semanticPoint(mark: mark, index: index, size: size)
                }

                selectedLayerReading
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.top, theme.spacing.md)

                selectedBucket
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.md)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(minHeight: isAccessibilitySize ? 430 : 350)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(instrumentStroke)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Life Calendar instrument")
        .accessibilityIdentifier("time.life-shape-field.micro-field")
    }

    private var accessibilityLayerSentence: String {
        if selectedLayer == .pressure, let selectedMark {
            return selectedMark.detail
        }
        return selectedLayer.realitySentence(for: field, mark: selectedMark)
    }

    private func fieldAtmosphere(size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.94 : 0.54))

            LinearGradient(
                colors: [
                    selectedLayerTint.opacity(reduceTransparency ? 0.20 : 0.10),
                    theme.colors.canvasElevated.opacity(0.22),
                    theme.colors.canvas.opacity(0.56)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ForEach(0..<7, id: \.self) { index in
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(index == 3 ? 0.24 : 0.11))
                    .frame(width: size.width, height: 1)
                    .position(x: size.width / 2, y: CGFloat(index + 1) * size.height / 8)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func fieldBand(segment: LifeShapeSegment, index: Int, size: CGSize) -> some View {
        let tint = layerTint(segment.kind.instrumentLayer)
        let bandHeight = max(size.height * 0.075, 22)
        let topOffset = size.height * 0.33
        let verticalStep = bandHeight * 1.34
        let y = topOffset + CGFloat(index) * verticalStep
        let left = size.width * 0.19
        let trackWidth = size.width * 0.66
        let weight = min(max(CGFloat(segment.weight), segment.weight > 0 ? 0.12 : 0.04), 1)
        let bandWidth = max(trackWidth * weight, segment.weight > 0 ? 34 : 12)

        ZStack(alignment: .leading) {
            Text(segment.kind.instrumentTitle)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .frame(width: max(left - theme.spacing.sm, 54), alignment: .leading)
                .position(x: left / 2, y: y)

            RoundedRectangle(cornerRadius: bandHeight / 2, style: .continuous)
                .fill(theme.colors.strokeSubtle.opacity(0.14))
                .frame(width: trackWidth, height: bandHeight)
                .position(x: left + trackWidth / 2, y: y)

            RoundedRectangle(cornerRadius: bandHeight / 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            tint.opacity(colorSchemeContrast == .increased ? 0.84 : 0.62),
                            tint.opacity(colorSchemeContrast == .increased ? 0.42 : 0.24)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: bandWidth, height: bandHeight)
                .shadow(color: tint.opacity(reduceTransparency ? 0 : 0.24), radius: 10, x: 0, y: 0)
                .position(x: left + bandWidth / 2, y: y)

            Text(segment.valueLabel.humanInstrumentValue)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .frame(width: size.width * 0.22, alignment: .trailing)
                .position(x: size.width * 0.88, y: y)
        }
        .accessibilityLabel("\(segment.title), \(segment.valueLabel), \(segment.detail)")
    }

    private func nowLine(size: CGSize) -> some View {
        let x = size.width * 0.58
        return ZStack {
            Rectangle()
                .fill(selectedLayerTint.opacity(colorSchemeContrast == .increased ? 0.82 : 0.48))
                .frame(width: colorSchemeContrast == .increased ? 2 : 1, height: size.height * 0.58)
                .position(x: x, y: size.height * 0.53)

            Circle()
                .fill(selectedLayerTint)
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .stroke(theme.colors.textPrimary.opacity(0.66), lineWidth: 1)
                }
                .shadow(color: selectedLayerTint.opacity(reduceTransparency ? 0 : 0.46), radius: 14, x: 0, y: 0)
                .position(x: x, y: size.height * 0.42)

            Text("Now")
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(selectedLayerTint)
                .textCase(.uppercase)
                .position(x: x, y: size.height * 0.19)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func semanticPoint(mark: LifeShapeSemanticMark, index: Int, size: CGSize) -> some View {
        let tint = theme.stateStyle(for: mark.visualState).fill
        let x = size.width * (0.28 + CGFloat(index % 5) * 0.13)
        let y = size.height * (0.42 + CGFloat(index % 2) * 0.17)
        Button {
            onSelectMark(mark)
        } label: {
            Circle()
                .fill(tint.opacity(0.74))
                .frame(width: 14, height: 14)
                .overlay {
                    Circle()
                        .stroke(theme.colors.textPrimary.opacity(0.66), lineWidth: 1)
                }
                .shadow(color: tint.opacity(reduceTransparency ? 0 : 0.34), radius: 9, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
        .accessibilityLabel(mark.accessibilitySummary)
        .accessibilityIdentifier("time.life-shape-field.mark.\(mark.id)")
    }

    var instrumentStroke: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(
                selectedLayerTint.opacity(colorSchemeContrast == .increased ? 0.74 : 0.36),
                lineWidth: colorSchemeContrast == .increased ? 1.5 : 1
            )
    }

    @ViewBuilder
    var selectedBucket: some View {
        if isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Circle()
                        .stroke(selectedLayerTint, lineWidth: 1.3)
                        .frame(width: 18, height: 18)
                        .overlay {
                            Circle()
                                .fill(selectedLayerTint.opacity(0.74))
                                .frame(width: 7, height: 7)
                        }
                        .padding(.top, theme.spacing.xxs)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(selectedWindowLabel)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(selectedLayerDetail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button(action: onPrimaryAction) {
                    Label(visiblePrimaryActionTitle, systemImage: selectedLayer.actionSymbol)
                        .font(theme.typography.caption.weight(.semibold))
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .center)
                }
                .buttonStyle(.plain)
                .foregroundStyle(primaryActionEnabled ? selectedLayerTint : theme.colors.textTertiary)
                .disabled(primaryActionEnabled == false)
                .accessibilityIdentifier("time.life-shape-field.primary-action")
                .accessibilityHint(primaryActionEnabled ? "Applies this local Time change." : field.placementUnavailableReason)
            }
            .padding(theme.spacing.sm)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(theme.colors.canvas.opacity(reduceTransparency ? 0.96 : 0.66))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(selectedLayerTint.opacity(colorSchemeContrast == .increased ? 0.72 : 0.34), lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("time.life-shape-field.accessibility-primary-row")
        } else {
            compactSelectedBucket
        }
    }

    private var compactSelectedBucket: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Circle()
                .stroke(selectedLayerTint, lineWidth: 1.3)
                .frame(width: 18, height: 18)
                .overlay {
                    Circle()
                        .fill(selectedLayerTint.opacity(0.74))
                        .frame(width: 7, height: 7)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(selectedWindowLabel)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(selectedLayerDetail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onPrimaryAction) {
                Label(visiblePrimaryActionTitle, systemImage: selectedLayer.actionSymbol)
                    .font(theme.typography.caption.weight(.semibold))
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .frame(minHeight: 44)
                    .padding(.horizontal, theme.spacing.sm)
            }
            .buttonStyle(.plain)
            .foregroundStyle(primaryActionEnabled ? selectedLayerTint : theme.colors.textTertiary)
            .disabled(primaryActionEnabled == false)
            .accessibilityIdentifier("time.life-shape-field.primary-action")
            .accessibilityHint(primaryActionEnabled ? "Applies this local Time change." : field.placementUnavailableReason)
        }
        .padding(theme.spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.canvas.opacity(reduceTransparency ? 0.96 : 0.66))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(selectedLayerTint.opacity(colorSchemeContrast == .increased ? 0.72 : 0.34), lineWidth: 1)
        }
    }

}
