#if canImport(SwiftUI)
import SwiftUI

public enum FlagshipRuntimeStageKind: String, Sendable {
    case realityMeridian
    case atmosphereComposer
    case shellChrome
    case objectStage
    case proof

    public var label: String {
        switch self {
        case .realityMeridian: "Reality Meridian"
        case .atmosphereComposer: "Atmosphere Composer"
        case .shellChrome: "Shell Chrome"
        case .objectStage: "Object Stage"
        case .proof: "Proof"
        }
    }
}

public struct FlagshipRuntimeMetric: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let value: String
    public let systemImage: String

    public init(id: String, title: String, value: String, systemImage: String) {
        self.id = id
        self.title = title
        self.value = value
        self.systemImage = systemImage
    }
}

public struct FlagshipRuntimeProofHook: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let accessibilityHint: String

    public init(id: String, title: String, summary: String, accessibilityHint: String) {
        self.id = id
        self.title = title
        self.summary = summary
        self.accessibilityHint = accessibilityHint
    }
}

public struct FlagshipRuntimeStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let kind: FlagshipRuntimeStageKind
    private let title: String
    private let summary: String
    private let metrics: [FlagshipRuntimeMetric]
    private let proofHooks: [FlagshipRuntimeProofHook]
    private let screenshotIdentifier: String
    private let content: Content

    public init(
        kind: FlagshipRuntimeStageKind,
        title: String,
        summary: String,
        metrics: [FlagshipRuntimeMetric] = [],
        proofHooks: [FlagshipRuntimeProofHook] = [],
        screenshotIdentifier: String,
        @ViewBuilder content: () -> Content
    ) {
        self.kind = kind
        self.title = title
        self.summary = summary
        self.metrics = metrics
        self.proofHooks = proofHooks
        self.screenshotIdentifier = screenshotIdentifier
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.md) {
            stageHeader
            content
            if proofHooks.isEmpty == false {
                proofHookStack
            }
        }
        .padding(dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.md)
        .background(stageBackground)
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(theme.colors.accentPrimary.opacity(reduceMotion ? 0.42 : 0.68))
                .frame(width: 2)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title), \(kind.label)")
        .accessibilityValue(summary)
        .accessibilityIdentifier(screenshotIdentifier)
    }

    private var stageHeader: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(kind.label)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.8)
            Text(title)
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if metrics.isEmpty == false { metricRow }
        }
        .accessibilityIdentifier("\(screenshotIdentifier).header")
    }

    private var metricRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                ForEach(metrics) { metric in
                    metricChip(metric)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(metrics) { metric in
                    metricChip(metric)
                }
            }
        }
    }

    private func metricChip(_ metric: FlagshipRuntimeMetric) -> some View {
        Label("\(metric.title): \(metric.value)", systemImage: metric.systemImage)
            .font(theme.typography.caption.weight(.medium))
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.vertical, theme.spacing.xxxs)
            .padding(.horizontal, theme.spacing.xs)
            .background(Capsule().fill(theme.colors.canvas.opacity(0.24)))
            .accessibilityIdentifier("\(screenshotIdentifier).metric.\(metric.id)")
    }

    private var proofHookStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(proofHooks) { hook in
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(hook.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hook.summary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint(hook.accessibilityHint)
                .accessibilityIdentifier("\(screenshotIdentifier).proof.\(hook.id)")
            }
        }
    }

    private var stageBackground: some View {
        RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
            .fill(theme.colors.canvas.opacity(0.20))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                    .strokeBorder(theme.colors.strokeSubtle.opacity(0.55), lineWidth: 1)
            }
    }
}
#endif
