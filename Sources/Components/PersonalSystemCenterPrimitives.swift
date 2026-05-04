#if canImport(SwiftUI)
import SwiftUI

public struct PersonalSystemCenterSignal: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let source: String
    public let state: LivingVisualState
    public let context: LivingTabContext

    public init(
        id: String,
        title: String,
        detail: String,
        source: String,
        state: LivingVisualState = .calm,
        context: LivingTabContext = .you
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.source = source
        self.state = state
        self.context = context
    }
}

public struct PersonalSystemCenterSetupItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let statusLabel: String
    public let state: LivingVisualState

    public init(
        id: String,
        title: String,
        statusLabel: String,
        state: LivingVisualState = .calm
    ) {
        self.id = id
        self.title = title
        self.statusLabel = statusLabel
        self.state = state
    }
}

public struct PersonalSystemCenterHeader: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let summary: String
    private let controlLabel: String
    private let trustLabel: String
    private let signals: [PersonalSystemCenterSignal]

    public init(
        title: String,
        summary: String,
        controlLabel: String = "You are in control",
        trustLabel: String = "Local-first",
        signals: [PersonalSystemCenterSignal]
    ) {
        self.title = title
        self.summary = summary
        self.controlLabel = controlLabel
        self.trustLabel = trustLabel
        self.signals = signals
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: .you, state: .proof) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: theme.icon.largeSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(LivingTabContext.you.accent(in: theme))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(LivingTabContext.you.accent(in: theme).opacity(0.14)))
                        .overlay {
                            Circle()
                                .strokeBorder(LivingTabContext.you.accent(in: theme).opacity(0.26), lineWidth: 1)
                        }
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text("You")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .accessibilityAddTraits(.isHeader)

                        Text(title)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(controlLabel)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: theme.spacing.xs)

                    EvidenceLabel(
                        trustLabel,
                        detail: "Trust visible",
                        source: "You owns controls",
                        state: .proof,
                        context: .trust
                    )
                }

                Text(summary)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150), spacing: theme.spacing.xs)],
                    alignment: .leading,
                    spacing: theme.spacing.xs
                ) {
                    ForEach(signals) { signal in
                        EvidenceLabel(
                            signal.title,
                            detail: signal.detail,
                            source: signal.source,
                            state: signal.state,
                            context: signal.context
                        )
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.system-profile-panel")
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(controlLabel). \(summary)")
    }
}

public struct PersonalSystemCenterSetupCompleteness: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let summary: String
    private let completedCount: Int
    private let totalCount: Int
    private let items: [PersonalSystemCenterSetupItem]

    public init(
        title: String,
        summary: String,
        completedCount: Int,
        totalCount: Int,
        items: [PersonalSystemCenterSetupItem]
    ) {
        self.title = title
        self.summary = summary
        self.completedCount = max(0, completedCount)
        self.totalCount = max(1, totalCount)
        self.items = items
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: .you, state: completenessState) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(summary)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: theme.spacing.sm)

                    Text("\(boundedCompleted)/\(totalCount)")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .accessibilityHidden(true)
                }

                ProgressView(value: Double(boundedCompleted), total: Double(totalCount))
                    .tint(theme.stateStyle(for: completenessState.ambitionState).accent)
                    .accessibilityLabel("Setup completeness")
                    .accessibilityValue("\(boundedCompleted) of \(totalCount)")

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(items) { item in
                        HStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(theme.stateStyle(for: item.state.ambitionState).accent)
                                .frame(width: 8, height: 8)
                                .accessibilityHidden(true)

                            Text(item.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textPrimary)

                            Spacer(minLength: theme.spacing.xs)

                            Text(item.statusLabel)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.title). \(item.statusLabel). \(item.state.title)")
                    }
                }
            }
        }
        .accessibilityIdentifier("you.setup-completeness")
    }

    private var boundedCompleted: Int {
        min(completedCount, totalCount)
    }

    private var completenessState: LivingVisualState {
        boundedCompleted >= totalCount ? .proof : .stale
    }
}

public struct PersonalSystemCenterNavigation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let sections: [GroupedNavigationSystemSection]
    private let onSelect: (GroupedNavigationSystemItem) -> Void

    public init(
        sections: [GroupedNavigationSystemSection],
        onSelect: @escaping (GroupedNavigationSystemItem) -> Void
    ) {
        self.sections = sections
        self.onSelect = onSelect
    }

    public var body: some View {
        GroupedNavigationSystem(
            sections: sections,
            context: .you,
            accessibilityIdentifierPrefix: "you.row",
            onSelect: onSelect
        )
        .transition(DAVMotionPreset.softReveal.transition(reduceMotion: reduceMotion))
        .accessibilityIdentifier("you.grouped-navigation-root")
    }
}
#endif
