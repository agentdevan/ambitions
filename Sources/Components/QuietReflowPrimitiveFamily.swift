#if canImport(SwiftUI)
import SwiftUI

public struct QuietReflowPrimitiveFamilyContract: Equatable, Sendable {
    public let primitiveID: String
    public let ownerSurface: String
    public let productObjects: [String]
    public let stageName: String
    public let screenshotIdentifier: String
    public let replacesStructures: [String]
    public let previewOrder: [String]
    public let forbiddenPatterns: [String]
    public let accessibilityFallbacks: [String]

    public static let current = QuietReflowPrimitiveFamilyContract(
        primitiveID: "quiet-reflow-family",
        ownerSurface: "Global action-state",
        productObjects: ["Quiet Reflow", "Preview-before-commit", "Receipt"],
        stageName: "Quiet Reflow Primitive Family",
        screenshotIdentifier: "QuietReflowPrimitiveFamily",
        replacesStructures: [
            "generic reflow panels",
            "rounded reflow option cards",
            "before-after preview cards",
            "impact preview cards",
            "receipt preview cards"
        ],
        previewOrder: [
            "current state",
            "proposed state",
            "reason",
            "user control",
            "receipt preview",
            "user choice"
        ],
        forbiddenPatterns: [
            "silent schedule mutation",
            "automatic calendar write",
            "generic reflow card",
            "optimization theatre",
            "urgency pressure"
        ],
        accessibilityFallbacks: [
            "Dynamic Type stacks current state, proposed state, source, control, and receipt in the same order.",
            "Reduce Motion keeps reflow meaning in static before and after labels.",
            "Differentiate Without Color pairs state color with symbols and explicit source/control/receipt copy.",
            "VoiceOver reads preview, option, impact, receipt, and no-silent-change state before actions."
        ]
    )
}

public enum QuietReflowPrimitiveRole: String, CaseIterable, Sendable, Identifiable {
    case preview
    case option
    case impact
    case receipt
    case source
    case noSilentChange
    case manualFallback

    public var id: String { rawValue }

    public var defaultEyebrow: String {
        switch self {
        case .preview: "Reflow preview"
        case .option: "Reflow option"
        case .impact: "Impact before approval"
        case .receipt: "Receipt preview"
        case .source: "Current state"
        case .noSilentChange: "No silent change"
        case .manualFallback: "User choice"
        }
    }

    public var systemImage: String {
        switch self {
        case .preview: "arrow.triangle.2.circlepath"
        case .option: "point.3.connected.trianglepath.dotted"
        case .impact: "timeline.selection"
        case .receipt: "doc.text.magnifyingglass"
        case .source: "scope"
        case .noSilentChange: "lock.shield"
        case .manualFallback: "hand.draw"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .preview: .review
        case .option: .focus
        case .impact: .review
        case .receipt: .trust
        case .source: .trust
        case .noSilentChange: .protected
        case .manualFallback: .protected
        }
    }

    public var visualState: AmbitionVisualState {
        switch self {
        case .preview: .selected
        case .option: .default
        case .impact: .warning
        case .receipt: .success
        case .source: .default
        case .noSilentChange: .default
        case .manualFallback: .default
        }
    }

    public var accessibilityRole: String {
        switch self {
        case .preview: "reflow preview"
        case .option: "reflow option"
        case .impact: "impact preview"
        case .receipt: "receipt preview"
        case .source: "current source state"
        case .noSilentChange: "no silent change"
        case .manualFallback: "user choice"
        }
    }
}

public struct QuietReflowPrimitiveStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let role: QuietReflowPrimitiveRole
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let isSelected: Bool
    private let accessibilityIdentifier: String?
    private let content: Content

    public init(
        role: QuietReflowPrimitiveRole,
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        statusLabel: String? = nil,
        systemImage: String? = nil,
        visualState: AmbitionVisualState? = nil,
        isSelected: Bool = false,
        accessibilityIdentifier: String? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.role = role
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.statusLabel = statusLabel
        self.systemImage = systemImage
        self.visualState = visualState
        self.isSelected = isSelected
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    public var body: some View {
        let resolvedState = visualState ?? role.visualState
        let style = theme.stateStyle(for: resolvedState)
        let strokeWidth: CGFloat = colorSchemeContrast == .increased ? 2 : 1

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
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(isSelected ? style.accent : theme.colors.textSecondary)
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
        .background(style.fill.opacity(isSelected ? 0.36 : 0.20))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isSelected ? style.accent : style.stroke)
                .frame(width: isSelected ? 4 : 2)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke.opacity(isSelected ? 0.86 : 0.54))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(isSelected ? 0.86 : 0.54))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .modifier(QuietReflowPrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
    }

    private var accessibilityLabel: String {
        [role.accessibilityRole, title].joined(separator: ", ")
    }

    private var accessibilityValue: String {
        [eyebrow ?? role.defaultEyebrow, subtitle, statusLabel]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}

public struct QuietReflowPrimitiveLine<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let role: QuietReflowPrimitiveRole
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let content: Content

    public init(
        role: QuietReflowPrimitiveRole,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        visualState: AmbitionVisualState? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.role = role
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.visualState = visualState
        self.content = content()
    }

    public var body: some View {
        let style = theme.stateStyle(for: visualState ?? role.visualState)

        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: systemImage ?? role.systemImage)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(style.accent)
                .frame(width: 22, alignment: .leading)
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
        }
        .padding(.vertical, theme.spacing.xxs)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.36))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle ?? role.defaultEyebrow)
    }
}

public struct QuietReflowBeforeAfterPrimitive: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let title: String
    private let beforeLabel: String
    private let afterLabel: String
    private let changeLabel: String
    private let receiptLabel: String
    private let visualState: AmbitionVisualState

    public init(
        title: String,
        beforeLabel: String,
        afterLabel: String,
        changeLabel: String,
        receiptLabel: String,
        visualState: AmbitionVisualState = .selected
    ) {
        self.title = title
        self.beforeLabel = beforeLabel
        self.afterLabel = afterLabel
        self.changeLabel = changeLabel
        self.receiptLabel = receiptLabel
        self.visualState = visualState
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            QuietReflowPrimitiveLine(
                role: .preview,
                title: title,
                subtitle: "Preview before approval.",
                systemImage: "rectangle.split.2x1",
                visualState: visualState
            )

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    previewDatum(beforeLabel, icon: "arrow.left.circle")
                    previewDatum(afterLabel, icon: "arrow.right.circle")
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    previewDatum(beforeLabel, icon: "arrow.left.circle")
                    previewDatum(afterLabel, icon: "arrow.right.circle")
                }
            }

            QuietReflowPrimitiveLine(
                role: .impact,
                title: changeLabel,
                systemImage: "point.3.connected.trianglepath.dotted",
                visualState: visualState
            )
            QuietReflowPrimitiveLine(
                role: .receipt,
                title: receiptLabel,
                systemImage: "doc.text.magnifyingglass"
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue([beforeLabel, afterLabel, changeLabel, receiptLabel].joined(separator: ". "))
    }

    private func previewDatum(_ text: String, icon: String) -> some View {
        QuietReflowPrimitiveLine(
            role: .preview,
            title: text,
            systemImage: icon,
            visualState: visualState
        )
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct QuietReflowPrimitiveIdentifierModifier: ViewModifier {
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
