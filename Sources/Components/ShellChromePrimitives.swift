#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionModeLens: String, CaseIterable, Sendable, Identifiable {
    case focus
    case triage
    case plan
    case recover
    case review

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .focus: "Focus"
        case .triage: "Sort"
        case .plan: "Plan"
        case .recover: "Recover"
        case .review: "Review"
        }
    }

    public var systemImage: String {
        switch self {
        case .focus: "scope"
        case .triage: "tray.full"
        case .plan: "calendar.badge.clock"
        case .recover: "arrow.uturn.backward.circle"
        case .review: "doc.text.magnifyingglass"
        }
    }
}

public enum AmbitionAmbientStatus: String, CaseIterable, Sendable, Identifiable {
    case clear
    case steady
    case tight
    case fragile
    case atRisk
    case recovered
    case protected

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .clear: "Clear"
        case .steady: "Steady"
        case .tight: "Tight"
        case .fragile: "Too much planned"
        case .atRisk: "Needs attention"
        case .recovered: "Recovered"
        case .protected: "Private"
        }
    }

    public var systemImage: String {
        switch self {
        case .clear: "checkmark.circle.fill"
        case .steady: "circle.dashed"
        case .tight: "exclamationmark.circle.fill"
        case .fragile: "circle.lefthalf.filled"
        case .atRisk: "exclamationmark.triangle.fill"
        case .recovered: "arrow.uturn.backward.circle.fill"
        case .protected: "lock.shield.fill"
        }
    }
}

public enum AmbitionTrustBadgeState: String, CaseIterable, Sendable, Identifiable {
    case localOnly
    case synced
    case exportReady
    case calendarLocal
    case needsBackup
    case staleWidget

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .localOnly: "Local only"
        case .synced: "Synced"
        case .exportReady: "Export ready"
        case .calendarLocal: "From calendar"
        case .needsBackup: "Needs backup"
        case .staleWidget: "Needs refresh"
        }
    }

    public var systemImage: String {
        switch self {
        case .localOnly: "iphone"
        case .synced: "checkmark.icloud.fill"
        case .exportReady: "square.and.arrow.up"
        case .calendarLocal: "calendar.badge.clock"
        case .needsBackup: "externaldrive.badge.exclamationmark"
        case .staleWidget: "arrow.clockwise"
        }
    }
}

public enum AmbitionMissionLane: String, CaseIterable, Sendable, Identifiable {
    case overview
    case path
    case steps
    case proof
    case decisions
    case risks
    case archive

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .overview: "Overview"
        case .path: "Path"
        case .steps: "Steps"
        case .proof: "Proof"
        case .decisions: "Decisions"
        case .risks: "Risks"
        case .archive: "Archive"
        }
    }

    public var systemImage: String {
        switch self {
        case .overview: "rectangle.and.text.magnifyingglass"
        case .path: "point.topleft.down.curvedto.point.bottomright.up"
        case .steps: "scope"
        case .proof: "checkmark.seal"
        case .decisions: "arrow.triangle.branch"
        case .risks: "exclamationmark.triangle"
        case .archive: "archivebox"
        }
    }
}

public struct AmbitionProofRailItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String

    public init(id: String, title: String, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

public struct AmbitionModeLensPill: View {
    @Environment(\.ambitionTheme) private var theme

    private let lens: AmbitionModeLens

    public init(_ lens: AmbitionModeLens) {
        self.lens = lens
    }

    public var body: some View {
        Label(lens.title, systemImage: lens.systemImage)
            .font(theme.typography.caption)
            .foregroundStyle(theme.shell.activeTabForeground)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxs)
            .background(Capsule().fill(theme.shell.activeTabBackground))
            .overlay(Capsule().stroke(theme.shell.activeTabForeground.opacity(0.34), lineWidth: 1))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(lens.title) view")
            .accessibilityValue("Changes what this screen emphasizes")
    }
}

public struct AmbitionAmbientStatusOrb: View {
    @Environment(\.ambitionTheme) private var theme

    private let status: AmbitionAmbientStatus
    private let showsLabel: Bool

    public init(_ status: AmbitionAmbientStatus, showsLabel: Bool = true) {
        self.status = status
        self.showsLabel = showsLabel
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            Image(systemName: status.systemImage)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .frame(width: 24, height: 24)
                .background(Circle().fill(accent.opacity(theme.mode == .dark ? 0.20 : 0.12)))
                .overlay(Circle().stroke(accent.opacity(0.42), lineWidth: 1))
                .accessibilityHidden(true)

            if showsLabel {
                Text(status.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Status \(status.title)")
    }

    private var accent: Color {
        switch status {
        case .clear: theme.shell.statusClear
        case .steady: theme.shell.statusSteady
        case .tight: theme.shell.statusTight
        case .fragile: theme.shell.statusFragile
        case .atRisk: theme.shell.statusAtRisk
        case .recovered: theme.shell.statusRecovered
        case .protected: theme.shell.statusProtected
        }
    }
}

public struct AmbitionContinuityRibbon: View {
    @Environment(\.ambitionTheme) private var theme

    private let message: String
    private let status: AmbitionAmbientStatus
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        message: String,
        status: AmbitionAmbientStatus = .steady,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.status = status
        self.actionTitle = actionTitle
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.xs) {
            AmbitionAmbientStatusOrb(status, showsLabel: false)

            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: theme.spacing.xs)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.shell.activeTabForeground)
                    .buttonStyle(.plain)
                    .ambitionMinimumTapTarget(theme.panel.minimumTapTarget)
            }

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xxs)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.shell.ribbonMaterial))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.shell.divider, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .accessibilityValue(status.title)
    }
}

public struct AmbitionActionClosureTray: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let message: String
    private let status: AmbitionAmbientStatus
    private let onDismiss: (() -> Void)?

    public init(
        title: String,
        message: String,
        status: AmbitionAmbientStatus = .steady,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.status = status
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack(alignment: .center, spacing: theme.spacing.xs) {
                AmbitionAmbientStatusOrb(status, showsLabel: false)

                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: theme.spacing.xs)

                if let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityIdentifier("action-closure-tray.dismiss-button")
                    .accessibilityLabel("Dismiss result")
                }
            }

            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.shell.receiptMaterial))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.shell.divider, lineWidth: 1))
        .shadow(color: theme.depth.overlay.color, radius: theme.depth.overlay.radius, x: theme.depth.overlay.x, y: theme.depth.overlay.y)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityValue(status.title)
    }
}

public struct AmbitionLifeGraphBreadcrumb: View {
    @Environment(\.ambitionTheme) private var theme

    private let items: [String]

    public init(_ items: [String]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            ForEach(Array(items.enumerated()), id: \.offset) { entry in
                Text(entry.element)
                    .font(theme.typography.caption)
                    .foregroundStyle(entry.offset == items.indices.last ? theme.colors.textPrimary : theme.colors.textSecondary)
                    .lineLimit(1)

                if entry.offset != items.indices.last {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(items.joined(separator: ", "))
    }
}

public struct AmbitionMissionControlLanes: View {
    @Environment(\.ambitionTheme) private var theme

    private let selected: AmbitionMissionLane?

    public init(selected: AmbitionMissionLane? = nil) {
        self.selected = selected
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(AmbitionMissionLane.allCases) { lane in
                Label(lane.title, systemImage: lane.systemImage)
                    .font(theme.typography.caption)
                    .foregroundStyle(lane == selected ? theme.shell.activeTabForeground : theme.shell.inactiveTabForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxs)
                    .background(Capsule().fill(lane == selected ? theme.shell.activeTabBackground : theme.shell.controlBackground))
                    .overlay(Capsule().stroke(lane == selected ? theme.shell.activeTabForeground.opacity(0.34) : theme.shell.divider, lineWidth: 1))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Path, Now, Proof, Watch")
    }
}

public struct AmbitionNotTodayStrip: View {
    @Environment(\.ambitionTheme) private var theme

    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: "moon.zzz")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.shell.statusProtected)
                .accessibilityHidden(true)

            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xxs)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.shell.controlBackground))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.shell.divider, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

public struct AmbitionProofRail: View {
    @Environment(\.ambitionTheme) private var theme

    private let items: [AmbitionProofRailItem]

    public init(items: [AmbitionProofRailItem]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(items) { item in
                Label(item.title, systemImage: item.systemImage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxs)
                    .background(Capsule().fill(theme.shell.controlBackground))
                    .overlay(Capsule().stroke(theme.shell.divider, lineWidth: 1))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(items.map(\.title).joined(separator: ", "))
    }
}

public struct AmbitionTrustBadge: View {
    @Environment(\.ambitionTheme) private var theme

    private let state: AmbitionTrustBadgeState

    public init(_ state: AmbitionTrustBadgeState) {
        self.state = state
    }

    public var body: some View {
        Label(state.title, systemImage: state.systemImage)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxs)
            .background(Capsule().fill(theme.shell.trustBadgeSurface))
            .overlay(Capsule().stroke(theme.semanticColors.trust.opacity(0.38), lineWidth: 1))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(state.title)
    }
}
#endif
