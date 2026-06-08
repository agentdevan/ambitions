#if canImport(SwiftUI)
import SwiftUI

public struct ClosureRecoveryPrimitiveFamilyContract: Equatable, Sendable {
    public let primitiveID: String
    public let ownerSurface: String
    public let productObjects: [String]
    public let stageName: String
    public let screenshotIdentifier: String
    public let replacesStructures: [String]
    public let actionStateOrder: [String]
    public let forbiddenPatterns: [String]
    public let accessibilityFallbacks: [String]

    public static let current = ClosureRecoveryPrimitiveFamilyContract(
        primitiveID: "closure-recovery-family",
        ownerSurface: "Global action-state",
        productObjects: ["Closure", "Recovery"],
        stageName: "Closure / Recovery Primitive Family",
        screenshotIdentifier: "ClosureRecoveryPrimitiveFamily",
        replacesStructures: [
            "generic closure panels",
            "generic recovery panels",
            "rounded recovery cards",
            "closure outcome cards",
            "receipt preview cards"
        ],
        actionStateOrder: [
            "context",
            "outcome meaning",
            "recovery consequence",
            "receipt preview",
            "no silent mutation"
        ],
        forbiddenPatterns: [
            "punitive closure language",
            "celebration noise",
            "generic panel shell",
            "metric pressure",
            "chain pressure"
        ],
        accessibilityFallbacks: [
            "Dynamic Type uses vertical line stages instead of fixed card grids.",
            "Reduce Motion preserves meaning through labels instead of animated-only state.",
            "Differentiate Without Color pairs role color with symbols and explicit text.",
            "VoiceOver reads closure, recovery, receipt, and no-silent-change state in order."
        ]
    )
}

public enum ClosureRecoveryPrimitiveRole: String, CaseIterable, Sendable, Identifiable {
    case closure
    case recovery
    case receipt
    case noSilentChange

    public var id: String { rawValue }

    public var defaultEyebrow: String {
        switch self {
        case .closure: "Closure"
        case .recovery: "Recovery"
        case .receipt: "Receipt"
        case .noSilentChange: "No silent change"
        }
    }

    public var systemImage: String {
        switch self {
        case .closure: "checkmark.seal"
        case .recovery: "arrow.triangle.2.circlepath"
        case .receipt: "doc.text"
        case .noSilentChange: "lock.shield"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .closure: .review
        case .recovery: .recovery
        case .receipt: .trust
        case .noSilentChange: .protected
        }
    }

    public var visualState: AmbitionVisualState {
        switch self {
        case .closure: .selected
        case .recovery: .warning
        case .receipt: .success
        case .noSilentChange: .default
        }
    }

    public var accessibilityRole: String {
        switch self {
        case .closure: "closure"
        case .recovery: "recovery"
        case .receipt: "receipt"
        case .noSilentChange: "no silent change"
        }
    }
}

public struct ClosureRecoveryPrimitiveStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let role: ClosureRecoveryPrimitiveRole
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let accessibilityIdentifier: String?
    private let content: Content

    public init(
        role: ClosureRecoveryPrimitiveRole,
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        statusLabel: String? = nil,
        systemImage: String? = nil,
        accessibilityIdentifier: String? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.role = role
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.statusLabel = statusLabel
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    public var body: some View {
        let style = theme.stateStyle(for: role.visualState)

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: systemImage ?? role.systemImage)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 22 : 18, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .frame(width: 28, alignment: .leading)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(eyebrow ?? role.defaultEyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(style.accent)
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.sm)

                if let statusLabel {
                    Text(statusLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content
        }
        .padding(.leading, theme.spacing.md)
        .padding(.trailing, theme.spacing.sm)
        .padding(.vertical, theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.fill.opacity(theme.mode == .dark ? 0.38 : 0.22))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.72))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .modifier(PrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
    }

    private var accessibilityLabel: String {
        [role.accessibilityRole, title]
            .joined(separator: ", ")
    }

    private var accessibilityValue: String {
        [eyebrow ?? role.defaultEyebrow, subtitle, statusLabel]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}

public struct ClosureRecoveryPrimitiveLine<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let role: ClosureRecoveryPrimitiveRole
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let isEmphasized: Bool
    private let accessibilityIdentifier: String?
    private let content: Content

    public init(
        role: ClosureRecoveryPrimitiveRole,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isEmphasized: Bool = false,
        accessibilityIdentifier: String? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.role = role
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isEmphasized = isEmphasized
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    public var body: some View {
        let style = theme.stateStyle(for: role.visualState)

        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: systemImage ?? role.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(style.accent)
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                content
            }

            Spacer(minLength: theme.spacing.xs)
        }
        .padding(.leading, theme.spacing.sm)
        .padding(.trailing, theme.spacing.xs)
        .padding(.vertical, theme.spacing.sm)
        .background(style.fill.opacity(isEmphasized ? 0.42 : 0.20))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent.opacity(isEmphasized ? 0.95 : 0.58))
                .frame(width: isEmphasized ? 3 : 2)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(isEmphasized ? 0.92 : 0.56))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(role.accessibilityRole), \(title)")
        .accessibilityValue(subtitle ?? "")
        .modifier(PrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

private struct PrimitiveIdentifierModifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}
#endif
