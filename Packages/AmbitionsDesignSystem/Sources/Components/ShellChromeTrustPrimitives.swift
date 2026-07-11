#if canImport(SwiftUI)
import SwiftUI

public struct SourceTrustChrome: View {
    @Environment(\.ambitionTheme) private var theme

    private let sourceLabel: String
    private let productLabel: String
    private let systemImage: String?
    private let showsIcon: Bool

    public init(
        sourceLabel: String,
        productLabel: String,
        systemImage: String? = "lock.shield.fill",
        showsIcon: Bool = true
    ) {
        self.sourceLabel = sourceLabel
        self.productLabel = productLabel
        self.systemImage = systemImage
        self.showsIcon = showsIcon
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xxxs) {
            if showsIcon, let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.semanticColors.trust)
                    .accessibilityHidden(true)
            }

            Text(sourceLabel)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)

            Text("·")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)

            Text(productLabel)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.82)
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(Capsule(style: .continuous).fill(theme.shell.trustBadgeSurface))
        .overlay(Capsule(style: .continuous).stroke(theme.semanticColors.trust.opacity(0.38), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(sourceLabel). \(productLabel).")
    }
}

public struct LocalAmbitionsLockup: View {
    private let showsIcon: Bool

    public init(showsIcon: Bool = true) {
        self.showsIcon = showsIcon
    }

    public var body: some View {
        SourceTrustChrome(
            sourceLabel: "Local",
            productLabel: "Ambitions",
            systemImage: "lock.shield.fill",
            showsIcon: showsIcon
        )
        .accessibilityIdentifier("local-ambitions-lockup")
    }
}
#endif
