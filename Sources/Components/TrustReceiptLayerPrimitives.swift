#if canImport(SwiftUI)
import SwiftUI

public enum TrustReceiptLayerKind: String, CaseIterable, Identifiable, Sendable {
    case proofSaved
    case moved
    case undone
    case privateItem
    case staleSource
    case offlineLocal
    case blockedSafely
    case needsReview
    case dreamHandling
    case sourceChange
    case mutation
    case unsafeRedirect
    case sourceConflict
    case professionalBoundary
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .proofSaved: "Proof saved"
        case .moved: "Moved with receipt"
        case .undone: "Undo recorded"
        case .privateItem: "Private receipt"
        case .staleSource: "Source may need review"
        case .offlineLocal: "Local only"
        case .blockedSafely: "Blocked safely"
        case .needsReview: "Needs review"
        case .dreamHandling: "Handling receipt"
        case .sourceChange: "Source change"
        case .mutation: "Mutation receipt"
        case .unsafeRedirect: "Unsafe redirect"
        case .sourceConflict: "Source conflict"
        case .professionalBoundary: "Professional boundary"
        }
    }
    public var symbolName: String {
        switch self {
        case .proofSaved: "checkmark.seal.fill"
        case .moved: "arrow.triangle.branch"
        case .undone: "arrow.uturn.backward.circle"
        case .privateItem: "lock.shield"
        case .staleSource: "clock.badge.exclamationmark"
        case .offlineLocal: "iphone"
        case .blockedSafely: "exclamationmark.shield"
        case .needsReview: "questionmark.folder"
        case .dreamHandling: "sparkles.rectangle.stack"
        case .sourceChange: "doc.badge.clock"
        case .mutation: "arrow.left.arrow.right.circle"
        case .unsafeRedirect: "hand.raised.circle"
        case .sourceConflict: "exclamationmark.arrow.triangle.2.circlepath"
        case .professionalBoundary: "person.crop.circle.badge.exclamationmark"
        }
    }
    public var visualState: LivingVisualState {
        switch self {
        case .proofSaved, .moved, .undone:
            return .proof
        case .privateItem, .offlineLocal:
            return .sensitive
        case .staleSource, .needsReview, .sourceChange, .sourceConflict, .professionalBoundary:
            return .stale
        case .blockedSafely, .unsafeRedirect:
            return .pressured
        case .dreamHandling, .mutation:
            return .active
        }
    }
}

public enum SourceFreshnessState: String, CaseIterable, Identifiable, Sendable {
    case fresh
    case partial
    case stale
    case denied
    case offline
    case localOnly
    case blocked
    case unavailable
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .fresh: "Fresh source"
        case .partial: "Partial source"
        case .stale: "Review source"
        case .denied: "Source denied"
        case .offline: "Offline"
        case .localOnly: "Local only"
        case .blocked: "Blocked"
        case .unavailable: "No source"
        }
    }
    public var detail: String {
        switch self {
        case .fresh: "Recently checked local evidence."
        case .partial: "Some evidence is visible; review before relying on it."
        case .stale: "Older evidence should be checked before reuse."
        case .denied: "Permission is not available."
        case .offline: "Stored on this device until source access returns."
        case .localOnly: "Private to this device unless the user changes it."
        case .blocked: "Ambitions will not act on this source."
        case .unavailable: "No source evidence is attached."
        }
    }
    var visualState: LivingVisualState {
        switch self {
        case .fresh: .proof
        case .partial: .active
        case .stale, .denied, .unavailable: .stale
        case .offline, .localOnly: .sensitive
        case .blocked: .pressured
        }
    }
}

public struct TrustReceiptLayerItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let kind: TrustReceiptLayerKind
    public let title: String
    public let summary: String
    public let sourceLabel: String
    public let freshness: SourceFreshnessState
    public let privacyLabel: String
    public let undoLabel: String?
    public let reviewLabel: String?
    public let redactedDetail: String?

    public init(
        id: String,
        kind: TrustReceiptLayerKind,
        title: String,
        summary: String,
        sourceLabel: String,
        freshness: SourceFreshnessState,
        privacyLabel: String = "Private by default",
        undoLabel: String? = nil,
        reviewLabel: String? = nil,
        redactedDetail: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.freshness = freshness
        self.privacyLabel = privacyLabel
        self.undoLabel = undoLabel
        self.reviewLabel = reviewLabel
        self.redactedDetail = redactedDetail
    }

    public var accessibilitySummary: String {
        [
            kind.title,
            title,
            summary,
            sourceLabel,
            freshness.label,
            privacyLabel,
            reviewLabel,
            undoLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

public struct SourceFreshnessLabel: View {
    @Environment(\.ambitionTheme) private var theme

    private let state: SourceFreshnessState
    private let label: String?

    public init(_ state: SourceFreshnessState, label: String? = nil) {
        self.state = state
        self.label = label
    }

    public var body: some View {
        EvidenceLabel(
            label ?? state.label,
            detail: state.detail,
            source: "Source freshness",
            state: state.visualState,
            context: .trust
        )
        .accessibilityIdentifier("trust.source-freshness.\(state.rawValue)")
    }
}

public struct ProofPreview: View {
    @Environment(\.ambitionTheme) private var theme

    private let item: TrustReceiptLayerItem

    public init(item: TrustReceiptLayerItem) {
        self.item = item
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: .trust, state: item.kind.visualState) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: item.kind.symbolName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.summary)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: theme.spacing.xs) {
                        AmbitionChip(item.privacyLabel, icon: "lock", role: .protected, semanticState: .trust)
                        SourceFreshnessLabel(item.freshness)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("trust.proof-preview.\(item.id)")
        .accessibilityLabel(item.accessibilitySummary)
    }
}

public struct InlineTrustReceipt: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let item: TrustReceiptLayerItem
    private let onReview: (() -> Void)?
    private let onUndo: (() -> Void)?

    public init(
        item: TrustReceiptLayerItem,
        onReview: (() -> Void)? = nil,
        onUndo: (() -> Void)? = nil
    ) {
        self.item = item
        self.onReview = onReview
        self.onUndo = onUndo
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ProofPreview(item: item)
            actionRow
        }
        .accessibilityIdentifier("trust.inline-receipt.\(item.id)")
    }

    @ViewBuilder
    private var actionRow: some View {
        let stackVertically = dynamicTypeSize.isAccessibilitySize

        if stackVertically {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                actionButtons
            }
        } else {
            HStack(spacing: theme.spacing.xs) {
                actionButtons
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if let reviewLabel = item.reviewLabel, let onReview {
            QuietActionButton(reviewLabel, icon: "doc.text.magnifyingglass", action: onReview)
        }
        if let undoLabel = item.undoLabel, let onUndo {
            QuietActionButton(undoLabel, icon: "arrow.uturn.backward", action: onUndo)
        }
    }
}

public struct TrustReceiptToast: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let item: TrustReceiptLayerItem
    private let isVisible: Bool
    private let onDismiss: () -> Void
    private let onReview: (() -> Void)?

    public init(
        item: TrustReceiptLayerItem,
        isVisible: Bool,
        onDismiss: @escaping () -> Void,
        onReview: (() -> Void)? = nil
    ) {
        self.item = item
        self.isVisible = isVisible
        self.onDismiss = onDismiss
        self.onReview = onReview
    }

    public var body: some View {
        if isVisible {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: item.kind.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.kind.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.xs)

                if let onReview, item.reviewLabel != nil {
                    Button(action: onReview) {
                        Image(systemName: "doc.text.magnifyingglass")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.reviewLabel ?? "Review receipt")
                }

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss receipt")
            }
            .padding(theme.spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    .strokeBorder(theme.semanticColors.protected.opacity(0.28), lineWidth: 1)
            }
            .transition(DAVMotionPreset.receiptConfirmation.transition(reduceMotion: reduceMotion))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("trust.receipt-toast.\(item.id)")
            .accessibilityValue(item.accessibilitySummary)
        }
    }
}

public struct WhyThisAffordance: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let summary: String
    private let evidence: String
    private let onOpen: () -> Void

    public init(title: String = "Why this?", summary: String, evidence: String, onOpen: @escaping () -> Void) {
        self.title = title
        self.summary = summary
        self.evidence = evidence
        self.onOpen = onOpen
    }

    public var body: some View {
        Button(action: onOpen) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "questionmark.circle")
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(summary)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("trust.why-this")
        .accessibilityLabel(title)
        .accessibilityValue("\(summary). \(evidence)")
        .accessibilityHint("Opens source and receipt detail.")
    }
}
#endif
