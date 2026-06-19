#if canImport(SwiftUI)
import SwiftUI

struct TrustReceiptStackRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TrustReceiptStackItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ProofPulse(isActive: item.state == .proofSaved || item.state == .correction || item.state == .undo, label: item.state.title)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.summary)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let nextActionLabel = item.nextActionLabel {
                        Text(nextActionLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.xs)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                EvidenceLabel(item.sourceLabel, detail: "Action source", state: item.state.livingState, context: .trust)
                EvidenceLabel(item.freshnessLabel, detail: "Source freshness", state: item.state.livingState, context: .memory)
            }

            QuietCommandSurface(
                placeholder: "Correction and undo",
                detail: "\(item.correctionLabel). \(item.undoLabel).",
                context: .trust
            ) {
                Image(systemName: item.state.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(theme.semanticColors.protected.opacity(0.22), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    var accessibilitySummary: String {
        [
            item.state.title,
            item.title,
            item.summary,
            item.sourceLabel,
            item.freshnessLabel,
            item.correctionLabel,
            item.undoLabel,
            item.nextActionLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

public struct GroupedNavigationSystemItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let symbolName: String
    public let state: LivingVisualState
    public let statusLabel: String?

    public init(
        id: String,
        title: String,
        subtitle: String,
        symbolName: String,
        state: LivingVisualState = .calm,
        statusLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
        self.state = state
        self.statusLabel = statusLabel
    }
}

public struct GroupedNavigationSystemSection: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let items: [GroupedNavigationSystemItem]

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        items: [GroupedNavigationSystemItem]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
}

public struct GroupedNavigationSystem: View {
    @Environment(\.ambitionTheme) private var theme

    let sections: [GroupedNavigationSystemSection]
    let context: LivingTabContext
    let accessibilityIdentifierPrefix: String?
    let onSelect: ((GroupedNavigationSystemItem) -> Void)?

    public init(
        sections: [GroupedNavigationSystemSection],
        context: LivingTabContext = .you,
        accessibilityIdentifierPrefix: String? = nil,
        onSelect: ((GroupedNavigationSystemItem) -> Void)? = nil
    ) {
        self.sections = sections
        self.context = context
        self.accessibilityIdentifierPrefix = accessibilityIdentifierPrefix
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(section.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let subtitle = section.subtitle {
                            Text(subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: theme.spacing.xxs) {
                        ForEach(section.items) { item in
                            row(for: item)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(section.title)
            }
        }
    }

    @ViewBuilder
    func row(for item: GroupedNavigationSystemItem) -> some View {
        let accent = item.state == .calm ? context.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        let rowContent = HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: item.symbolName)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(accent.opacity(0.12)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            if let statusLabel = item.statusLabel {
                Text(statusLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule(style: .continuous).fill(accent.opacity(0.10)))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(accent.opacity(0.18), lineWidth: 1)
                    }
                    .accessibilityHidden(true)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .strokeBorder(accent.opacity(0.18), lineWidth: 1)
        }
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary(for: item))
        .modifier(GroupedNavigationSystemIdentifier(identifier: accessibilityIdentifier(for: item)))

        if let onSelect {
            Button {
                onSelect(item)
            } label: {
                rowContent
            }
            .buttonStyle(GroupedNavigationSystemButtonStyle())
        } else {
            rowContent
        }
    }

    func accessibilitySummary(for item: GroupedNavigationSystemItem) -> String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    func accessibilityIdentifier(for item: GroupedNavigationSystemItem) -> String? {
        guard let accessibilityIdentifierPrefix else { return nil }
        return "\(accessibilityIdentifierPrefix).\(item.id)"
    }
}

struct GroupedNavigationSystemButtonStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && reduceMotion == false ? 0.992 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

struct GroupedNavigationSystemIdentifier: ViewModifier {
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
