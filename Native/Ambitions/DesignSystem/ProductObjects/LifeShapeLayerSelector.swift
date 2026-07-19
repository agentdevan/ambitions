import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeLayerSelector: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Binding var selection: LifeShapeLayer

    private let layers: [LifeShapeLayer] = [.open, .protected, .pressure, .buffer]
    private var accessibilityCompact: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        HStack(spacing: theme.spacing.xxxs) {
            ForEach(layers) { layer in
                Button {
                    selection = layer
                } label: {
                    layerContent(for: layer)
                        .foregroundStyle(selection == layer ? theme.colors.textPrimary : theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: accessibilityCompact ? 56 : 42)
                        .padding(.horizontal, accessibilityCompact ? theme.spacing.xs : theme.spacing.xxs)
                        .background(layerFill(for: layer, selected: selection == layer))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(
                                    selection == layer
                                        ? selectorTint(for: layer).opacity(colorSchemeContrast == .increased ? 0.92 : 0.68)
                                        : theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.82 : 0.42),
                                    lineWidth: selection == layer ? 1.4 : 1
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("time.life-shape-field.layer.\(layer.rawValue)")
                .accessibilityLabel("\(layer.title) layer")
                .accessibilityValue(selection == layer ? "Selected" : "Not selected")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field.layer-selector")
    }

    private func layerFill(for layer: LifeShapeLayer, selected: Bool) -> some ShapeStyle {
        LinearGradient(
            colors: selected
                ? [
                    selectorTint(for: layer).opacity(colorSchemeContrast == .increased ? 0.42 : 0.30),
                    theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.92 : 0.62)
                ]
                : [
                    theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.88 : 0.54),
                    theme.colors.canvas.opacity(reduceTransparency ? 0.72 : 0.32)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func selectorTint(for layer: LifeShapeLayer) -> Color {
        theme.stateStyle(for: layer.selectorVisualState).accent
    }

    @ViewBuilder
    private func layerContent(for layer: LifeShapeLayer) -> some View {
        if accessibilityCompact {
            Image(systemName: layer.selectorSymbolName)
                .font(.system(size: 27, weight: .semibold))
                .symbolVariant(selection == layer ? .fill : .none)
                .accessibilityHidden(true)
        } else {
            Text(layer.title)
                .font(theme.typography.micro.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
    }
}

private extension LifeShapeLayer {
    var selectorVisualState: AmbitionVisualState {
        switch self {
        case .open:
            .success
        case .protected:
            .selected
        case .pressure:
            .warning
        case .buffer:
            .default
        }
    }

    var selectorSymbolName: String {
        switch self {
        case .open:
            "circle.dotted"
        case .protected:
            "lock.shield"
        case .pressure:
            "waveform.path.ecg"
        case .buffer:
            "rectangle.inset.filled.and.person.filled"
        }
    }
}
