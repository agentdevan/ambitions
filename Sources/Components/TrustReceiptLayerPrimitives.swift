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
    public let whyLabel: String?
    public let changeLabel: String?
    public let undoLabel: String?
    public let correctionLabel: String?
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
        whyLabel: String? = nil,
        changeLabel: String? = nil,
        undoLabel: String? = nil,
        correctionLabel: String? = nil,
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
        self.whyLabel = whyLabel
        self.changeLabel = changeLabel
        self.undoLabel = undoLabel
        self.correctionLabel = correctionLabel
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
            whyLabel,
            changeLabel,
            correctionLabel,
            reviewLabel,
            undoLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

public struct ReceiptDrawerSection: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let items: [TrustReceiptLayerItem]

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        items: [TrustReceiptLayerItem]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
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

public struct ProofBead: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let sourceLabel: String
    public let freshness: SourceFreshnessState
    public let privacyLabel: String
    public let timestampLabel: String?
    public let correctionLabel: String?
    public let staleReviewLabel: String?
    public let redactedDetail: String?

    public init(
        id: String,
        title: String,
        summary: String,
        sourceLabel: String,
        freshness: SourceFreshnessState,
        privacyLabel: String,
        timestampLabel: String? = nil,
        correctionLabel: String? = nil,
        staleReviewLabel: String? = nil,
        redactedDetail: String? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.freshness = freshness
        self.privacyLabel = privacyLabel
        self.timestampLabel = timestampLabel
        self.correctionLabel = correctionLabel
        self.staleReviewLabel = staleReviewLabel
        self.redactedDetail = redactedDetail
    }

    public var visibleSummary: String {
        redactedDetail ?? summary
    }

    public var isRedacted: Bool {
        redactedDetail != nil
    }

    public var requiresReviewBeforeRecommendation: Bool {
        switch freshness {
        case .stale, .partial, .denied, .blocked, .unavailable:
            return true
        case .fresh, .offline, .localOnly:
            return false
        }
    }

    public var accessibilitySummary: String {
        [
            title,
            visibleSummary,
            sourceLabel,
            freshness.label,
            privacyLabel,
            correctionLabel,
            staleReviewLabel,
            timestampLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

public struct ProofFreshnessLabel: View {
    private let freshness: SourceFreshnessState

    public init(_ freshness: SourceFreshnessState) {
        self.freshness = freshness
    }

    public var body: some View {
        SourceFreshnessLabel(freshness)
            .accessibilityIdentifier("proof-spine.freshness.\(freshness.rawValue)")
    }
}

public struct ProofCorrectionMark: View {
    private let label: String

    public init(_ label: String) {
        self.label = label
    }

    public var body: some View {
        EvidenceLabel(
            label,
            detail: "Correction remains visible",
            source: "User review",
            state: .stale,
            context: .trust
        )
        .accessibilityIdentifier("proof-spine.correction-mark")
    }
}

public struct ProofPrivacyRedaction: View {
    private let label: String

    public init(_ label: String = "Private details hidden") {
        self.label = label
    }

    public var body: some View {
        EvidenceLabel(
            label,
            detail: "Proof role remains visible",
            source: "Privacy boundary",
            state: .sensitive,
            context: .trust
        )
        .accessibilityIdentifier("proof-spine.privacy-redaction")
    }
}

public struct ProofSpine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let title: String
    private let subtitle: String
    private let beads: [ProofBead]
    private let emptyTitle: String
    private let emptyMessage: String

    public init(
        title: String = "Proof Spine",
        subtitle: String = "Source, freshness, privacy, correction, and review stay attached to proof.",
        beads: [ProofBead],
        emptyTitle: String = "No proof yet",
        emptyMessage: String = "Proof will appear here after something real is saved."
    ) {
        self.title = title
        self.subtitle = subtitle
        self.beads = beads
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.sectionTitle)
                    .foregroundStyle(theme.colors.textPrimary)

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if beads.isEmpty {
                proofEmptyState
            } else if dynamicTypeSize.isAccessibilitySize {
                accessibleStack
            } else {
                visualSpine
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilitySummary)
        .accessibilityIdentifier("proof-spine")
    }

    private var proofEmptyState: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            ProofPulse(isActive: false, label: emptyTitle)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(emptyTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Text(emptyMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .strokeBorder(theme.colors.strokeSubtle, lineWidth: 1)
        }
    }

    private var visualSpine: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(beads.enumerated()), id: \.element.id) { index, bead in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(spacing: theme.spacing.xxs) {
                        ProofPulse(isActive: true, label: "Proof bead \(index + 1)")

                        if index < beads.count - 1 {
                            Capsule(style: .continuous)
                                .fill(theme.semanticColors.protected.opacity(0.36))
                                .frame(width: 3, height: 34)
                                .accessibilityHidden(true)
                        }
                    }

                    beadBody(bead)
                        .padding(.bottom, index < beads.count - 1 ? theme.spacing.sm : 0)
                }
            }
        }
    }

    private var accessibleStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(beads) { bead in
                beadBody(bead)
            }
        }
    }

    private func beadBody(_ bead: ProofBead) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text(bead.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: theme.spacing.xs)

                if let timestamp = bead.timestampLabel {
                    Text(timestamp)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Text(bead.visibleSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                EvidenceLabel(bead.sourceLabel, detail: "Proof source", state: bead.freshness.visualState, context: .trust)
                ProofFreshnessLabel(bead.freshness)
                EvidenceLabel(bead.privacyLabel, detail: "Privacy boundary", state: bead.isRedacted ? .sensitive : .calm, context: .trust)

                if let correction = bead.correctionLabel {
                    ProofCorrectionMark(correction)
                }

                if let staleReview = bead.staleReviewLabel ?? (bead.requiresReviewBeforeRecommendation ? "Review before recommendations use this proof." : nil) {
                    EvidenceLabel(staleReview, detail: "Recommendation boundary", state: .stale, context: .trust)
                        .accessibilityIdentifier("proof-spine.stale-review")
                }

                if bead.isRedacted {
                    ProofPrivacyRedaction()
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .strokeBorder(bead.freshness.visualState == .stale ? theme.semanticColors.risk.opacity(0.42) : theme.semanticColors.protected.opacity(0.26), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bead.accessibilitySummary)
    }

    private var accessibilitySummary: String {
        if beads.isEmpty {
            return "\(emptyTitle). \(emptyMessage)"
        }

        return beads.map(\.accessibilitySummary).joined(separator: " ")
    }
}

public struct SourceFold: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let item: TrustReceiptLayerItem

    public init(item: TrustReceiptLayerItem) {
        self.item = item
    }

    public var body: some View {
        let stacksVertically = dynamicTypeSize.isAccessibilitySize

        Group {
            if stacksVertically {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    foldContent
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    foldContent
                }
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("trust.source-fold.\(item.id)")
        .accessibilityLabel("Source fold")
        .accessibilityValue(item.accessibilitySummary)
    }

    @ViewBuilder
    private var foldContent: some View {
        EvidenceLabel(
            item.sourceLabel,
            detail: item.freshness.detail,
            source: "Source",
            state: item.freshness.visualState,
            context: .trust
        )
        AmbitionChip(item.privacyLabel, icon: "lock", role: .protected, semanticState: .trust)
        SourceFreshnessLabel(item.freshness)
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

                    SourceFold(item: item)
                }
            }
        }
        .accessibilityIdentifier("trust.proof-preview.\(item.id)")
        .accessibilityLabel(item.accessibilitySummary)
    }
}

public struct ReceiptDrawer: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let sections: [ReceiptDrawerSection]
    private let onReview: ((TrustReceiptLayerItem) -> Void)?
    private let onUndo: ((TrustReceiptLayerItem) -> Void)?

    public init(
        title: String = "Receipts",
        subtitle: String? = "What changed, why, and what you can review.",
        sections: [ReceiptDrawerSection],
        onReview: ((TrustReceiptLayerItem) -> Void)? = nil,
        onUndo: ((TrustReceiptLayerItem) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.sections = sections
        self.onReview = onReview
        self.onUndo = onUndo
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: .trust, state: .calm) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.sectionTitle)
                        .foregroundStyle(theme.colors.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.bodySecondary)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if sections.isEmpty || sections.allSatisfy({ $0.items.isEmpty }) {
                    emptyState
                } else {
                    ForEach(sections) { section in
                        drawerSection(section)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("trust.receipt-drawer")
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("No receipt yet")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text("When Ambitions changes something, the receipt will show the consequence and review path.")
                .font(theme.typography.bodySecondary)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("trust.receipt-drawer.empty")
    }

    private func drawerSection(_ section: ReceiptDrawerSection) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(section.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle = section.subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            ForEach(section.items) { item in
                ReceiptDrawerRow(
                    item: item,
                    onReview: onReview.map { action in { action(item) } },
                    onUndo: onUndo.map { action in { action(item) } }
                )
            }
        }
        .accessibilityIdentifier("trust.receipt-drawer.section.\(section.id)")
    }
}

private struct ReceiptDrawerRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TrustReceiptLayerItem
    let onReview: (() -> Void)?
    let onUndo: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ProofPreview(item: item)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                receiptFact("What happened", item.summary)
                receiptFact("Why", item.whyLabel ?? "User review controls the next change.")
                receiptFact("Change", item.changeLabel ?? "No hidden change is implied.")
                if let correctionLabel = item.correctionLabel {
                    receiptFact("Correction", correctionLabel)
                }
            }

            HStack(spacing: theme.spacing.xs) {
                if let reviewLabel = item.reviewLabel, let onReview {
                    QuietActionButton(reviewLabel, icon: "doc.text.magnifyingglass", action: onReview)
                }
                if let undoLabel = item.undoLabel, let onUndo {
                    QuietActionButton(undoLabel, icon: "arrow.uturn.backward", action: onUndo)
                }
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("trust.receipt-drawer.row.\(item.id)")
        .accessibilityLabel(item.title)
        .accessibilityValue(item.accessibilitySummary)
    }

    private func receiptFact(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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
