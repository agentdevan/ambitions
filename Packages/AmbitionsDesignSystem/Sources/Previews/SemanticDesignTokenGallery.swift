#if canImport(SwiftUI)
import Foundation
import SwiftUI

public struct SemanticDesignTokenGallery: View {
    private let tokens = AmbitionSemanticDesignTokenCatalog.allTokens

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(
                    eyebrow: "UI-004",
                    title: "Semantic Design Tokens",
                    subtitle: "Color, surface, stroke, symbol, and accessibility fallbacks for the shared Ambitions component language."
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
                    ForEach(tokens) { token in
                        SemanticDesignTokenSwatch(token: token, appearance: .dark)
                    }
                }

                SectionHeader(
                    eyebrow: "Accessibility",
                    title: "Contrast and transparency fallbacks",
                    subtitle: "Every semantic token declares increased-contrast and reduced-transparency behavior without custom theming that bypasses accessibility."
                )

                ForEach(tokens) { token in
                    SemanticDesignTokenSwatch(token: token, appearance: .increasedContrastDark)
                }
            }
            .padding(24)
        }
        .background(Color(ambitionSemanticHex: AmbitionTokens.Foundation.graphiteInk.hex).ignoresSafeArea())
        .ambitionTheme(.dark)
    }
}

private struct SemanticDesignTokenSwatch: View {
    let token: AmbitionSemanticDesignToken
    let appearance: AmbitionDesignAppearance

    var body: some View {
        let colors = token.colors(for: appearance)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: token.symbolName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(ambitionSemanticHex: colors.foregroundHex))
                    .frame(width: 44, height: 44)
                    .background(Color(ambitionSemanticHex: colors.backgroundHex))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(ambitionSemanticHex: colors.strokeHex), lineWidth: 1.2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(token.surface)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(ambitionSemanticHex: colors.foregroundHex))
                    Text(token.primaryObject)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(token.role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider().overlay(Color(ambitionSemanticHex: colors.strokeHex).opacity(0.5))

            VStack(alignment: .leading, spacing: 6) {
                Text("Foreground \(colors.foregroundHex) - Background \(colors.backgroundHex)")
                Text("Increase Contrast: \(token.increasedContrastFallback)")
                Text("Reduce Transparency: \(token.reducedTransparencyFallback)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(ambitionSemanticHex: colors.backgroundHex).opacity(colors.materialOpacity))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(ambitionSemanticHex: colors.strokeHex), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(token.accessibilityLabel)
    }
}

private extension Color {
    init(ambitionSemanticHex hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = Int(clean, radix: 16) ?? 0
        self.init(red: Double((value >> 16) & 0xFF) / 255, green: Double((value >> 8) & 0xFF) / 255, blue: Double(value & 0xFF) / 255)
    }
}

#Preview("Semantic Design Token Gallery") {
    SemanticDesignTokenGallery()
}

#Preview("Semantic Design Tokens - Increase Contrast") {
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(AmbitionSemanticDesignTokenCatalog.allTokens) { token in
                SemanticDesignTokenSwatch(token: token, appearance: .increasedContrastDark)
            }
        }
        .padding(24)
    }
    .background(Color(ambitionSemanticHex: AmbitionTokens.Foundation.graphiteInk.hex).ignoresSafeArea())
    .ambitionTheme(.dark)
}
#endif
