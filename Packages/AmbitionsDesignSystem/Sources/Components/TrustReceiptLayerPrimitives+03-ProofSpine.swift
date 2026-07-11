#if canImport(SwiftUI)
import SwiftUI

public struct ProofSpine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String
    let beads: [ProofBead]
    let emptyTitle: String
    let emptyMessage: String

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

    var proofEmptyState: some View {
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

    var visualSpine: some View {
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

    var accessibleStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(beads) { bead in
                beadBody(bead)
            }
        }
    }

    func beadBody(_ bead: ProofBead) -> some View {
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

    var accessibilitySummary: String {
        if beads.isEmpty {
            return "\(emptyTitle). \(emptyMessage)"
        }

        return beads.map(\.accessibilitySummary).joined(separator: " ")
    }
}

public struct SourceFold: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: TrustReceiptLayerItem

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
    var foldContent: some View {
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

    let item: TrustReceiptLayerItem

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

    let title: String
    let subtitle: String?
    let sections: [ReceiptDrawerSection]
    let onReview: (@MainActor @Sendable (TrustReceiptLayerItem) -> Void)?
    let onUndo: (@MainActor @Sendable (TrustReceiptLayerItem) -> Void)?

    public init(
        title: String = "Receipts",
        subtitle: String? = "What changed, why, and what you can review.",
        sections: [ReceiptDrawerSection],
        onReview: (@MainActor @Sendable (TrustReceiptLayerItem) -> Void)? = nil,
        onUndo: (@MainActor @Sendable (TrustReceiptLayerItem) -> Void)? = nil
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

    var emptyState: some View {
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

    func drawerSection(_ section: ReceiptDrawerSection) -> some View {
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
                    onReview: reviewAction(for: item),
                    onUndo: undoAction(for: item)
                )
            }
        }
        .accessibilityIdentifier("trust.receipt-drawer.section.\(section.id)")
    }

    func reviewAction(for item: TrustReceiptLayerItem) -> (@MainActor @Sendable () -> Void)? {
        guard let onReview else { return nil }
        return { onReview(item) }
    }

    func undoAction(for item: TrustReceiptLayerItem) -> (@MainActor @Sendable () -> Void)? {
        guard let onUndo else { return nil }
        return { onUndo(item) }
    }
}
#endif
