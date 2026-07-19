#if canImport(SwiftUI)
import SwiftUI

public struct ProofRelationshipTracePrimitiveFamilyContract: Equatable, Sendable {
    public let primitiveID: String
    public let ownerSurface: String
    public let productObjects: [String]
    public let stageName: String
    public let screenshotIdentifier: String
    public let replacesStructures: [String]
    public let inspectionOrder: [String]
    public let forbiddenPatterns: [String]
    public let accessibilityFallbacks: [String]

    public static let current = ProofRelationshipTracePrimitiveFamilyContract(
        primitiveID: "proof-relationship-trace-family",
        ownerSurface: "Today / Goals / Motion",
        productObjects: ["Proof", "Relationship", "Trace", "Receipt"],
        stageName: "Proof / Relationship / Trace Primitive Family",
        screenshotIdentifier: "ProofRelationshipTracePrimitiveFamily",
        replacesStructures: [
            "generic trace chips",
            "decorative proof pills",
            "source proof receipt panels",
            "review trail cards",
            "receipt cards"
        ],
        inspectionOrder: [
            "source",
            "relationship",
            "proof",
            "receipt",
            "review path",
            "user inspection"
        ],
        forbiddenPatterns: [
            "decorative proof",
            "detached proof card",
            "generic trace chip",
            "proof without receipt path",
            "relationship without source"
        ],
        accessibilityFallbacks: [
            "Dynamic Type stacks source, relationship, proof, receipt, review path, and inspection rows without changing order.",
            "Reduce Motion keeps trace state in static symbols and labels rather than animated-only marks.",
            "Differentiate Without Color pairs every proof or relationship state with explicit source, proof, receipt, or replay text.",
            "VoiceOver reads source, relationship, proof, receipt, review path, and user inspection before any action can mutate state."
        ]
    )
}

public enum ProofRelationshipTracePrimitiveRole: String, CaseIterable, Sendable, Identifiable {
    case source
    case relationship
    case proof
    case receipt
    case replayTrace
    case inspection

    public var id: String { rawValue }

    public var defaultEyebrow: String {
        switch self {
        case .source: "Source"
        case .relationship: "Relationship"
        case .proof: "Proof"
        case .receipt: "Receipt"
        case .replayTrace: "Review path"
        case .inspection: "Inspection"
        }
    }

    public var systemImage: String {
        switch self {
        case .source: "link"
        case .relationship: "point.topleft.down.curvedto.point.bottomright.up"
        case .proof: "seal"
        case .receipt: "doc.text.magnifyingglass"
        case .replayTrace: "arrow.triangle.branch"
        case .inspection: "eye"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .source: .trust
        case .relationship: .focus
        case .proof: .success
        case .receipt: .trust
        case .replayTrace: .review
        case .inspection: .protected
        }
    }

    public var visualState: AmbitionVisualState {
        switch self {
        case .source, .receipt, .replayTrace: .default
        case .relationship, .inspection: .selected
        case .proof: .success
        }
    }

    public var accessibilityRole: String {
        switch self {
        case .source: "source"
        case .relationship: "relationship"
        case .proof: "proof"
        case .receipt: "receipt"
        case .replayTrace: "review path"
        case .inspection: "inspection"
        }
    }
}

public struct ProofRelationshipTracePrimitiveStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let role: ProofRelationshipTracePrimitiveRole
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let visualState: AmbitionVisualState?
    private let accessibilityIdentifier: String?
    private let content: Content

    public init(
        role: ProofRelationshipTracePrimitiveRole,
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
        let style = theme.stateStyle(for: visualState ?? role.visualState)
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
        .background(style.fill.opacity(0.14))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: colorSchemeContrast == .increased ? 4 : 3)
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
                .fill(style.stroke.opacity(0.56))
                .frame(height: strokeWidth)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel([role.accessibilityRole, title].joined(separator: ", "))
        .accessibilityValue([eyebrow ?? role.defaultEyebrow, subtitle, statusLabel].compactMap { $0 }.joined(separator: ". "))
        .modifier(ProofRelationshipTraceIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

public struct ProofRelationshipTracePrimitiveLine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let role: ProofRelationshipTracePrimitiveRole
    private let title: String
    private let subtitle: String?
    private let statusLabel: String?
    private let systemImage: String?
    private let semanticState: AmbitionSemanticState?
    private let visualState: AmbitionVisualState?
    private let accessibilityIdentifier: String?

    public init(
        role: ProofRelationshipTracePrimitiveRole,
        title: String,
        subtitle: String? = nil,
        statusLabel: String? = nil,
        systemImage: String? = nil,
        semanticState: AmbitionSemanticState? = nil,
        visualState: AmbitionVisualState? = nil,
        accessibilityIdentifier: String? = nil
    ) {
        self.role = role
        self.title = title
        self.subtitle = subtitle
        self.statusLabel = statusLabel
        self.systemImage = systemImage
        self.semanticState = semanticState
        self.visualState = visualState
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        let resolvedState = visualState ?? semanticState?.proofRelationshipTraceVisualState ?? role.visualState
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
                        .font(theme.typography.caption.weight(.semibold))
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
        .background(style.fill.opacity(0.10))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.stroke.opacity(0.62))
                .frame(width: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel([role.accessibilityRole, title].joined(separator: ", "))
        .accessibilityValue([subtitle, statusLabel].compactMap { $0 }.joined(separator: ". "))
        .modifier(ProofRelationshipTraceIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

public struct ProofRelationshipTracePrimitiveToken: View {
    @Environment(\.ambitionTheme) private var theme

    private let role: ProofRelationshipTracePrimitiveRole
    private let title: String
    private let systemImage: String?
    private let semanticState: AmbitionSemanticState?
    private let accessibilityIdentifier: String?

    public init(
        role: ProofRelationshipTracePrimitiveRole,
        title: String,
        systemImage: String? = nil,
        semanticState: AmbitionSemanticState? = nil,
        accessibilityIdentifier: String? = nil
    ) {
        self.role = role
        self.title = title
        self.systemImage = systemImage
        self.semanticState = semanticState
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        let resolvedState = semanticState?.proofRelationshipTraceVisualState ?? role.visualState
        let style = theme.stateStyle(for: resolvedState)

        HStack(spacing: theme.spacing.xxs) {
            Image(systemName: systemImage ?? role.systemImage)
                .font(.system(size: 11, weight: .semibold))
                .accessibilityHidden(true)
            Text(title)
                .font(theme.typography.micro.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(style.accent)
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xs)
        .background(style.fill.opacity(0.12))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.64))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel([role.accessibilityRole, title].joined(separator: ", "))
        .modifier(ProofRelationshipTraceIdentifierModifier(identifier: accessibilityIdentifier))
    }
}

private extension AmbitionSemanticState {
    var proofRelationshipTraceVisualState: AmbitionVisualState {
        switch self {
        case .success, .accessibilityVerified:
            .success
        case .caution, .risk, .confidenceLow, .accessibilityUnverified:
            .warning
        case .focus, .protected, .trust, .recovery:
            .selected
        default:
            .default
        }
    }
}

private struct ProofRelationshipTraceIdentifierModifier: ViewModifier {
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
