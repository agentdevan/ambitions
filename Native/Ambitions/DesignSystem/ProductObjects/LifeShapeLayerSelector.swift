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
        HStack(spacing: theme.spacing.xs) {
            ForEach(layers) { layer in
                Button {
                    selection = layer
                } label: {
                    layerContent(for: layer)
                        .foregroundStyle(selection == layer ? theme.colors.canvas : theme.colors.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: accessibilityCompact ? 56 : 44)
                        .padding(.horizontal, accessibilityCompact ? theme.spacing.xs : theme.spacing.sm)
                        .background(layerFill(selected: selection == layer))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.82 : 0.42), lineWidth: 1)
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

    private func layerFill(selected: Bool) -> some ShapeStyle {
        LinearGradient(
            colors: selected
                ? [
                    theme.colors.textPrimary.opacity(0.98),
                    theme.colors.textPrimary.opacity(colorSchemeContrast == .increased ? 0.94 : 0.82)
                ]
                : [
                    theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.88 : 0.54),
                    theme.colors.canvas.opacity(reduceTransparency ? 0.72 : 0.32)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
                .font(theme.typography.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
    }
}

private extension LifeShapeLayer {
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
