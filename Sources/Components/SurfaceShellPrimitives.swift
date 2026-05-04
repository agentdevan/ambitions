#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsSurfaceShellKind: String, CaseIterable, Sendable, Identifiable {
    case topLevelSurface
    case drillDown
    case utilityHub
    case overlayHost

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .topLevelSurface: "Top level surface"
        case .drillDown: "Drill-down"
        case .utilityHub: "Utility hub"
        case .overlayHost: "Overlay host"
        }
    }

    public var defaultLens: AmbitionModeLens {
        switch self {
        case .topLevelSurface: .focus
        case .drillDown: .review
        case .utilityHub: .triage
        case .overlayHost: .triage
        }
    }

    public var defaultStatus: AmbitionAmbientStatus {
        switch self {
        case .topLevelSurface: .steady
        case .drillDown: .clear
        case .utilityHub: .protected
        case .overlayHost: .tight
        }
    }

    public var accessibilityRole: String {
        switch self {
        case .topLevelSurface: "Top level Ambitions surface"
        case .drillDown: "Owned drill-down surface"
        case .utilityHub: "Grouped navigation hub"
        case .overlayHost: "Temporary overlay host"
        }
    }
}

public struct AmbitionsSurfaceHeaderAction {
    public let title: String
    public let systemImage: String
    public let accessibilityIdentifier: String?
    public let action: () -> Void

    public init(
        title: String,
        systemImage: String,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}

public struct AmbitionsSurfaceShell<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let kind: AmbitionsSurfaceShellKind
    private let title: String
    private let subtitle: String?
    private let statusMessage: String?
    private let primaryAction: AmbitionsSurfaceHeaderAction?
    private let secondaryAction: AmbitionsSurfaceHeaderAction?
    private let content: Content

    public init(
        kind: AmbitionsSurfaceShellKind = .topLevelSurface,
        title: String,
        subtitle: String? = nil,
        statusMessage: String? = nil,
        primaryAction: AmbitionsSurfaceHeaderAction? = nil,
        secondaryAction: AmbitionsSurfaceHeaderAction? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.statusMessage = statusMessage
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            header
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.lg)
        .background(theme.shell.canvasGradient)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: kind.rawValue)
        .ambitionPanelAccessibility(
            label: "\(title), \(kind.accessibilityRole)",
            value: statusMessage ?? kind.defaultStatus.title,
            hint: "Contains the current surface header and owned navigation or module content."
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack(spacing: theme.spacing.xs) {
                        AmbitionModeLensPill(kind.defaultLens)
                        AmbitionAmbientStatusOrb(kind.defaultStatus)
                    }

                    Text(title)
                        .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.titleCompact : theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .layoutPriority(2)

                Spacer(minLength: theme.spacing.xs)

                headerActions
            }

            if let statusMessage {
                AmbitionContinuityRibbon(
                    message: statusMessage,
                    status: kind.defaultStatus
                )
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.shell.headerMaterial))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.shell.divider, lineWidth: 1))
        .shadow(color: theme.depth.resting.color, radius: theme.depth.resting.radius, x: theme.depth.resting.x, y: theme.depth.resting.y)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("si.surface-shell.header")
    }

    @ViewBuilder
    private var headerActions: some View {
        let actions = [primaryAction, secondaryAction].compactMap { $0 }

        if actions.isEmpty == false {
            HStack(spacing: theme.spacing.xs) {
                ForEach(Array(actions.enumerated()), id: \.offset) { entry in
                    let action = entry.element
                    Button(action: action.action) {
                        Label(action.title, systemImage: action.systemImage)
                            .labelStyle(.iconOnly)
                            .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier(action.accessibilityIdentifier ?? "si.surface-shell.action.\(entry.offset)")
                    .accessibilityLabel(action.title)
                }
            }
            .accessibilityElement(children: .contain)
        }
    }
}

public struct ShellOverlayZone<Overlay: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let subtitle: String?
    private let isPresented: Bool
    private let onDismiss: () -> Void
    private let overlay: Overlay

    public init(
        title: String,
        subtitle: String? = nil,
        isPresented: Bool,
        onDismiss: @escaping () -> Void,
        @ViewBuilder overlay: () -> Overlay
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.overlay = overlay()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                                .lineLimit(2)

                            if let subtitle {
                                Text(subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: theme.spacing.xs)

                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(theme.colors.textSecondary)
                        .accessibilityLabel("Dismiss")
                    }

                    overlay
                }
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.shell.receiptMaterial))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.shell.divider, lineWidth: 1))
                .shadow(color: theme.depth.overlay.color, radius: theme.depth.overlay.radius, x: theme.depth.overlay.x, y: theme.depth.overlay.y)
                .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                .accessibilityElement(children: .contain)
                .accessibilityLabel(title)
                .accessibilityHint("Temporary surface. Dismiss to return to the previous screen.")
                .accessibilityIdentifier("si.shell-overlay-zone")
            }
        }
        .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: isPresented)
    }
}
#endif
