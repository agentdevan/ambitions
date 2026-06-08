#if canImport(SwiftUI)
import SwiftUI

public struct HorizonCapacityPrimitiveFamilyContract: Equatable, Sendable {
    public let primitiveID: String
    public let ownerSurface: String
    public let productObjects: [String]
    public let stageName: String
    public let screenshotIdentifier: String
    public let replacesStructures: [String]
    public let relationshipOrder: [String]
    public let forbiddenPatterns: [String]
    public let accessibilityFallbacks: [String]

    public static let current = HorizonCapacityPrimitiveFamilyContract(
        primitiveID: "horizon-capacity-family",
        ownerSurface: "Time",
        productObjects: ["Horizon", "Capacity", "LifeShape Field"],
        stageName: "Horizon / Capacity Primitive Family",
        screenshotIdentifier: "HorizonCapacityPrimitiveFamily",
        replacesStructures: [
            "generic horizon chips",
            "horizon tab strips",
            "capacity cards",
            "capacity panels",
            "continuity pills",
            "root-card horizon controls"
        ],
        relationshipOrder: [
            "selected horizon",
            "capacity fit",
            "protected/open time relationship",
            "source and receipt",
            "continuity",
            "no root navigation"
        ],
        forbiddenPatterns: [
            "root tab behavior",
            "generic horizon card",
            "numeric capacity ranking",
            "schedule optimization",
            "calendar-density ranking",
            "resource allocation"
        ],
        accessibilityFallbacks: [
            "Dynamic Type stacks horizon, capacity, source, receipt, and continuity lines without changing order.",
            "Reduce Motion keeps selected horizon and capacity fit in static labels instead of animated-only state.",
            "Differentiate Without Color pairs horizon/capacity state with symbols and selected/review text.",
            "VoiceOver reads selected horizon, capacity statement, source, receipt, continuity, and no-root-navigation boundary before reflow actions."
        ]
    )
}

public enum HorizonCapacityPrimitiveRole: String, CaseIterable, Sendable, Identifiable {
    case horizon
    case selectedHorizon
    case capacity
    case source
    case receipt
    case continuity
    case noRootNavigation

    public var id: String { rawValue }

    public var defaultEyebrow: String {
        switch self {
        case .horizon: "Horizon"
        case .selectedHorizon: "Selected horizon"
        case .capacity: "Capacity"
        case .source: "Source"
        case .receipt: "Receipt"
        case .continuity: "Continuity"
        case .noRootNavigation: "No root navigation"
        }
    }

    public var systemImage: String {
        switch self {
        case .horizon: "point.topleft.down.curvedto.point.bottomright.up"
        case .selectedHorizon: "checkmark.circle"
        case .capacity: "gauge.with.dots.needle.bottom.50percent"
        case .source: "checkmark.shield"
        case .receipt: "doc.text.magnifyingglass"
        case .continuity: "waveform.path"
        case .noRootNavigation: "lock.shield"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .horizon: .review
        case .selectedHorizon: .focus
        case .capacity: .review
        case .source: .trust
        case .receipt: .trust
        case .continuity: .protected
        case .noRootNavigation: .protected
        }
    }

    public var visualState: AmbitionVisualState {
        switch self {
        case .horizon: .default
        case .selectedHorizon: .selected
        case .capacity: .selected
        case .source: .default
        case .receipt: .success
        case .continuity: .default
        case .noRootNavigation: .default
        }
    }

    public var accessibilityRole: String {
        switch self {
        case .horizon: "time horizon"
        case .selectedHorizon: "selected time horizon"
        case .capacity: "time capacity"
        case .source: "time source"
        case .receipt: "time receipt"
        case .continuity: "time continuity"
        case .noRootNavigation: "no root navigation"
        }
    }
}

public struct HorizonCapacityPrimitiveStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let role: HorizonCapacityPrimitiveRole
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let accessibilityIdentifier: String?
    private let content: Content

    public init(
        role: HorizonCapacityPrimitiveRole,
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
        .background(style.fill.opacity(0.18))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke.opacity(0.66))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.66))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel([role.accessibilityRole, title].joined(separator: ", "))
        .accessibilityValue([eyebrow ?? role.defaultEyebrow, subtitle, statusLabel].compactMap { $0 }.joined(separator: ". "))
        .modifier(HorizonCapacityPrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

public struct HorizonCapacityPrimitiveLine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let role: HorizonCapacityPrimitiveRole
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let isSelected: Bool
    private let accessibilityIdentifier: String?

    public init(
        role: HorizonCapacityPrimitiveRole,
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
        .modifier(HorizonCapacityPrimitiveIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

private struct HorizonCapacityPrimitiveIdentifierModifier: ViewModifier {
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
