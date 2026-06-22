import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeLayerSelector: View {
    @Environment(\.ambitionTheme) private var theme
    @Binding var selection: LifeShapeLayer

    private let layers: [LifeShapeLayer] = [.open, .protected, .pressure, .buffer]

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(layers) { layer in
                Button {
                    selection = layer
                } label: {
                    Text(layer.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(selection == layer ? theme.colors.canvas : theme.colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.horizontal, theme.spacing.sm)
                        .background(selection == layer ? theme.colors.textPrimary : theme.colors.surfaceOverlay.opacity(0.58))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
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
}
