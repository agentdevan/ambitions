#if canImport(SwiftUI)
import SwiftUI

public struct CaptureRoutingPrimitiveFamilyContract: Equatable, Sendable {
    public let primitiveID: String
    public let ownerSurface: String
    public let productObjects: [String]
    public let stageName: String
    public let screenshotIdentifier: String
    public let replacesStructures: [String]
    public let routingOrder: [String]
    public let forbiddenPatterns: [String]
    public let accessibilityFallbacks: [String]

    public static let current = CaptureRoutingPrimitiveFamilyContract(
        primitiveID: "capture-routing-family",
        ownerSurface: "Global Capture",
        productObjects: ["Capture Routing", "Atmosphere Composer", "Receipt"],
        stageName: "Capture Routing Primitive Family",
        screenshotIdentifier: "CaptureRoutingPrimitiveFamily",
        replacesStructures: [
            "generic routing panels",
            "route category grids",
            "route proof pills",
            "rounded route option cards",
            "unsupported certainty labels",
            "chat transcript shells"
        ],
        routingOrder: [
            "input source",
            "deterministic route basis",
            "review state",
            "correction control",
            "receipt path",
            "no silent placement"
        ],
        forbiddenPatterns: [
            "fake confidence theater",
            "category grid",
            "chat transcript",
            "generic route card",
            "silent placement",
            "cloud classifier claim"
        ],
        accessibilityFallbacks: [
            "Dynamic Type stacks source, route basis, review state, correction, receipt, and no-silent-placement lines in the same order.",
            "Reduce Motion keeps route meaning in static labels instead of animation-only reveal.",
            "Differentiate Without Color pairs routing color with symbols and explicit review/correction text.",
            "VoiceOver reads deterministic route basis, selected route, correction options, receipt path, and no-silent-placement boundary before save actions."
        ]
    )
}

public enum CaptureRoutingPrimitiveRole: String, CaseIterable, Sendable, Identifiable {
    case routeReveal
    case placementReview
    case routeOption
    case correction
    case receipt
    case source
    case inputPolicy
    case noSilentPlacement

    public var id: String { rawValue }

    public var defaultEyebrow: String {
        switch self {
        case .routeReveal: "Route reveal"
        case .placementReview: "Placement review"
        case .routeOption: "Route option"
        case .correction: "Correction"
        case .receipt: "Receipt"
        case .source: "Source"
        case .inputPolicy: "Input policy"
        case .noSilentPlacement: "No silent placement"
        }
    }

    public var systemImage: String {
        switch self {
        case .routeReveal: "point.topleft.down.curvedto.point.bottomright.up"
        case .placementReview: "arrow.triangle.branch"
        case .routeOption: "location.circle"
        case .correction: "arrow.triangle.branch"
        case .receipt: "doc.text.magnifyingglass"
        case .source: "checkmark.shield"
        case .inputPolicy: "text.cursor"
        case .noSilentPlacement: "lock.shield"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .routeReveal: .review
        case .placementReview: .review
        case .routeOption: .focus
        case .correction: .review
        case .receipt: .trust
        case .source: .trust
        case .inputPolicy: .protected
        case .noSilentPlacement: .protected
        }
    }

    public var visualState: AmbitionVisualState {
        switch self {
        case .routeReveal: .selected
        case .placementReview: .selected
        case .routeOption: .default
        case .correction: .warning
        case .receipt: .success
        case .source: .default
        case .inputPolicy: .default
        case .noSilentPlacement: .default
        }
    }

    public var accessibilityRole: String {
        switch self {
        case .routeReveal: "capture route reveal"
        case .placementReview: "capture placement review"
        case .routeOption: "capture route option"
        case .correction: "capture route correction"
        case .receipt: "capture receipt"
        case .source: "capture source"
        case .inputPolicy: "capture entry rule"
        case .noSilentPlacement: "no silent placement"
        }
    }
}

public struct CaptureRoutingPrimitiveStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let role: CaptureRoutingPrimitiveRole
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let accessibilityIdentifier: String?
    private let content: Content

    public init(
        role: CaptureRoutingPrimitiveRole,
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        statusLabel: String? = nil,
        systemImage: String? = nil,
        visualState: AmbitionVisualState? = nil,
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
        .background(style.fill.opacity(0.20))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke.opacity(0.70))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.70))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .modifier(CaptureRoutingPrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
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

public struct CaptureRoutingPrimitiveLine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let role: CaptureRoutingPrimitiveRole
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let isSelected: Bool
    private let accessibilityIdentifier: String?

    public init(
        role: CaptureRoutingPrimitiveRole,
        title: String,
        subtitle: String? = nil,
        statusLabel: String? = nil,
        systemImage: String? = nil,
        visualState: AmbitionVisualState? = nil,
        isSelected: Bool = false,
        accessibilityIdentifier: String? = nil
    ) {
        self.role = role
        self.title = title
        self.subtitle = subtitle
        self.statusLabel = statusLabel
        self.systemImage = systemImage
        self.visualState = visualState
        self.isSelected = isSelected
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        let resolvedState = visualState ?? role.visualState
        let style = theme.stateStyle(for: resolvedState)

        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: systemImage ?? role.systemImage)
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(style.accent)
                .frame(width: 20, alignment: .leading)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(title)
                        .font(theme.typography.caption.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let statusLabel, dynamicTypeSize.isAccessibilitySize == false {
                        Text(statusLabel)
                            .font(theme.typography.micro.weight(.semibold))
                            .foregroundStyle(style.accent)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let statusLabel, dynamicTypeSize.isAccessibilitySize {
                    Text(statusLabel)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(style.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, theme.spacing.xs)
        .padding(.leading, theme.spacing.xs)
        .padding(.trailing, theme.spacing.sm)
        .background(style.fill.opacity(isSelected ? 0.24 : 0.08))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isSelected ? style.accent : style.stroke.opacity(0.52))
                .frame(width: isSelected ? 3 : 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel([role.accessibilityRole, title].joined(separator: ", "))
        .accessibilityValue([subtitle, statusLabel].compactMap { $0 }.joined(separator: ". "))
        .modifier(CaptureRoutingPrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

private struct CaptureRoutingPrimitiveIdentifierModifier: ViewModifier {
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
