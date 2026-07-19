#if canImport(SwiftUI)
import SwiftUI

public struct ContextRecallSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let summary: String
    let sourceLabel: String
    let confidenceLabel: String
    let state: ContextRecallState
    let context: LivingTabContext
    let controls: [String]

    public init(
        title: String,
        summary: String,
        sourceLabel: String,
        confidenceLabel: String,
        state: ContextRecallState,
        context: LivingTabContext = .memory,
        controls: [String] = []
    ) {
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.confidenceLabel = confidenceLabel
        self.state = state
        self.context = context
        self.controls = controls
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: context, state: state.livingState) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: state.symbolName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(context.accent(in: theme))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(context.accent(in: theme).opacity(0.12)))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(state.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(context.accent(in: theme))
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(summary)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.xs)
            }

            FlowEvidenceLabels(
                labels: [
                    EvidenceLabel(sourceLabel, detail: "Source visible", state: state.livingState, context: context),
                    EvidenceLabel(confidenceLabel, detail: "No hidden certainty", state: state.livingState, context: .trust)
                ]
            )

            if controls.isEmpty == false {
                QuietCommandSurface(
                    placeholder: "Review controls",
                    detail: controls.joined(separator: " · "),
                    context: .trust
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    var accessibilitySummary: String {
        [state.title, title, summary, sourceLabel, confidenceLabel, controls.joined(separator: ", ")]
            .filter { $0.isEmpty == false }
            .joined(separator: ". ")
    }
}

@available(*, deprecated, renamed: "ContextRecallSurface")
public typealias ContextRecallCard = ContextRecallSurface

public struct MemoryConstellationNode: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let state: ContextRecallState

    public init(id: String, title: String, detail: String, state: ContextRecallState) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
    }
}

public struct MemoryConstellation: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String
    let nodes: [MemoryConstellationNode]

    public init(title: String, subtitle: String, nodes: [MemoryConstellationNode]) {
        self.title = title
        self.subtitle = subtitle
        self.nodes = nodes
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: .memory, state: .calm) {
            SectionHeader(eyebrow: "Memory map", title: title, subtitle: subtitle)

            VStack(spacing: theme.spacing.sm) {
                HStack(alignment: .center, spacing: theme.spacing.xs) {
                    ForEach(nodes) { node in
                        MemoryConstellationNodeView(node: node)
                    }
                }

                Capsule(style: .continuous)
                    .fill(theme.semanticColors.trust.opacity(0.28))
                    .frame(height: 1)
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(theme.semanticColors.protected.opacity(reduceMotion ? 0.28 : 0.42))
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(subtitle). \(nodes.count) visible memory states.")
    }
}

struct MemoryConstellationNodeView: View {
    @Environment(\.ambitionTheme) private var theme

    let node: MemoryConstellationNode

    var body: some View {
        VStack(spacing: theme.spacing.xxs) {
            Image(systemName: node.state.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(node.state == .sensitive ? theme.semanticColors.protected : theme.semanticColors.trust)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(theme.colors.surfaceOverlay)
                        .overlay(Circle().strokeBorder(theme.semanticColors.trust.opacity(0.24), lineWidth: 1))
                )
                .accessibilityHidden(true)

            Text(node.title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(node.detail)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, minHeight: 104)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(node.title). \(node.detail). \(node.state.title).")
    }
}

struct FlowEvidenceLabels: View {
    @Environment(\.ambitionTheme) private var theme

    let labels: [EvidenceLabel]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(labels.indices, id: \.self) { index in
                labels[index]
            }
        }
    }
}

public enum TrustReceiptVisualState: String, CaseIterable, Identifiable, Sendable {
    case proofSaved
    case correction
    case undo
    case staleSource
    case blocked
    case empty

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .proofSaved: "Proof saved"
        case .correction: "Correction visible"
        case .undo: "Undo available"
        case .staleSource: "Source may need review"
        case .blocked: "Blocked safely"
        case .empty: "No receipts"
        }
    }

    public var livingState: LivingVisualState {
        switch self {
        case .proofSaved, .correction, .undo:
            return .proof
        case .staleSource:
            return .stale
        case .blocked:
            return .pressured
        case .empty:
            return .empty
        }
    }

    public var symbolName: String {
        switch self {
        case .proofSaved: "checkmark.seal.fill"
        case .correction: "checkmark.bubble"
        case .undo: "arrow.uturn.backward.circle"
        case .staleSource: "clock.badge.exclamationmark"
        case .blocked: "exclamationmark.shield"
        case .empty: "tray"
        }
    }
}

public struct TrustReceiptStackItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let sourceLabel: String
    public let freshnessLabel: String
    public let undoLabel: String
    public let correctionLabel: String
    public let nextActionLabel: String?
    public let state: TrustReceiptVisualState

    public init(
        id: String,
        title: String,
        summary: String,
        sourceLabel: String,
        freshnessLabel: String,
        undoLabel: String,
        correctionLabel: String,
        nextActionLabel: String? = nil,
        state: TrustReceiptVisualState
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.freshnessLabel = freshnessLabel
        self.undoLabel = undoLabel
        self.correctionLabel = correctionLabel
        self.nextActionLabel = nextActionLabel
        self.state = state
    }
}

public struct TrustReceiptStack: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let items: [TrustReceiptStackItem]

    public init(
        title: String = "Trust receipts",
        subtitle: String = "Privacy-safe summaries of what changed, why, and what can be corrected or undone.",
        items: [TrustReceiptStackItem]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }

    public var body: some View {
        AdaptiveModuleChrome(
            title: title,
            subtitle: subtitle,
            context: .trust,
            state: items.isEmpty ? .empty : .proof,
            evidence: items.isEmpty ? "No receipt is shown without source evidence" : "\(items.count) source-bound receipts"
        ) {
            if items.isEmpty {
                TrustReceiptEmptyState()
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        TrustReceiptStackRow(item: item)
                    }
                }
            }
        }
        .accessibilityIdentifier("trust.receipt-stack")
    }
}

struct TrustReceiptEmptyState: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        QuietCommandSurface(
            placeholder: "No receipts to show",
            detail: "Ambitions should say when there is no audit trail instead of implying hidden proof.",
            context: .trust
        ) {
            ProofPulse(isActive: false, label: "No proof receipt visible")
        }
    }
}
#endif
