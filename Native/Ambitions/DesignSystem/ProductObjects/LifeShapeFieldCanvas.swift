import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    func horizonTextButton(_ horizon: TimeHorizon) -> some View {
        let selected = selectedHorizon == horizon
        let horizonReading = suite.field.reading(for: horizon)
        let accessibilityReduceMotion = reduceMotion
        return Button {
            withAnimation(accessibilityReduceMotion ? nil : .easeOut(duration: 0.18)) {
                selectedHorizon = horizon
            }
        } label: {
            HorizonCapacityPrimitiveLine(
                role: selected ? .selectedHorizon : .horizon,
                title: horizon.title,
                subtitle: horizonReading.capacityStatement,
                statusLabel: selected ? "Selected" : "Review",
                visualState: selected ? .selected : .default,
                isSelected: selected,
                accessibilityIdentifier: "time.life-shape-field.horizon.\(horizon.rawValue)"
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("time.life-shape-field.horizon.\(horizon.rawValue)")
    }

    var objectCanvas: some View {
        ZStack(alignment: .topLeading) {
            objectStageTextureBackdrop

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                if displayedRenderState == .pressureCluster {
                    Text("Pressure")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.stateStyle(for: .warning).accent)
                        .lineLimit(1)
                        .accessibilityIdentifier("time.life-shape-field.pressure-label")
                }
                Text(reading.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(reading.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
                segmentTexture
                if revealsPressure {
                    Text(suite.field.reflowProposal.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.lg)
        }
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 300 : 380)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("LifeShape Field")
        .accessibilityValue("\(reading.title). \(reading.summary). \(reading.capacityStatement)")
    }

    var objectStageTextureBackdrop: some View {
        ProductMeaningCanvasEngine(
            role: .timePressure,
            marks: suite.field.semanticMarks.map { mark in
                ProductMeaningCanvasMark(id: mark.id, intensity: mark.intensity)
            },
            visualState: suite.field.capacityFit.visualState,
            accessibilityIdentifier: "time.life-shape-field.pressure-canvas-engine"
        )
        .opacity(colorSchemeContrast == .increased ? 0.58 : 0.36)
        .mask {
            RadialGradient(
                colors: [
                    .white,
                    .white.opacity(0.68),
                    .clear
                ],
                center: .center,
                startRadius: dynamicTypeSize.isAccessibilitySize ? 80 : 118,
                endRadius: dynamicTypeSize.isAccessibilitySize ? 260 : 320
            )
        }
        .accessibilityHidden(true)
    }

    var segmentTexture: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(semanticMarksForFirstViewport) { mark in
                semanticMarkRow(mark, compact: dynamicTypeSize.isAccessibilitySize == false)
            }
        }
        .accessibilityHidden(true)
    }

    var semanticMarksForFirstViewport: ArraySlice<LifeShapeSemanticMark> {
        if dynamicTypeSize.isAccessibilitySize {
            return suite.field.semanticMarks.prefix(suite.field.semanticMarks.count)
        }
        return suite.field.semanticMarks.prefix(6)
    }

    func semanticMarkRow(_ mark: LifeShapeSemanticMark, compact: Bool) -> some View {
        let style = theme.stateStyle(for: mark.visualState)
        let lineWidth = colorSchemeContrast == .increased ? 1.6 : 1
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: mark.kind.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 16)
            Text("\(mark.kind.semanticMeaning): \(mark.valueLabel)")
                .font(theme.typography.micro)
                .lineLimit(compact ? 2 : 1)
                .minimumScaleFactor(compact ? 0.64 : 0.68)
                .layoutPriority(1)
            Spacer(minLength: theme.spacing.xs)
            if reduceMotion {
                Text(mark.kind.title)
                    .font(theme.typography.micro)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            } else {
                Rectangle()
                    .fill(style.accent.opacity(colorSchemeContrast == .increased ? 0.72 : 0.34))
                    .frame(
                        width: max(CGFloat(compact ? 18 : 30), CGFloat((compact ? 34 : 58) * mark.intensity)),
                        height: colorSchemeContrast == .increased ? 9 : 7
                    )
            }
        }
        .foregroundStyle(style.foreground)
        .padding(.vertical, theme.spacing.xxxs)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(colorSchemeContrast == .increased ? 0.78 : 0.32))
                .frame(height: lineWidth)
        }
    }
}
