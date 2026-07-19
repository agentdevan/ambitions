#if canImport(SwiftUI)
import SwiftUI

struct ReceiptDrawerRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TrustReceiptLayerItem
    let onReview: (@MainActor @Sendable () -> Void)?
    let onUndo: (@MainActor @Sendable () -> Void)?

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

    func receiptFact(_ title: String, _ value: String) -> some View {
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

    let item: TrustReceiptLayerItem
    let onReview: (@MainActor @Sendable () -> Void)?
    let onUndo: (@MainActor @Sendable () -> Void)?

    public init(
        item: TrustReceiptLayerItem,
        onReview: (@MainActor @Sendable () -> Void)? = nil,
        onUndo: (@MainActor @Sendable () -> Void)? = nil
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
    var actionRow: some View {
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
    var actionButtons: some View {
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

    let item: TrustReceiptLayerItem
    let isVisible: Bool
    let onDismiss: @MainActor @Sendable () -> Void
    let onReview: (@MainActor @Sendable () -> Void)?

    public init(
        item: TrustReceiptLayerItem,
        isVisible: Bool,
        onDismiss: @escaping @MainActor @Sendable () -> Void,
        onReview: (@MainActor @Sendable () -> Void)? = nil
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
                .accessibilityIdentifier("trust.receipt-toast.dismiss-button")
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

    let title: String
    let summary: String
    let evidence: String
    let onOpen: () -> Void

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

public extension TrustReceiptLayerKind {
    var fe04Role: FE04PrimitiveRole {
        switch self {
        case .proofSaved, .dreamHandling, .mutation, .sourceConflict:
            return .proofTrail
        case .moved, .undone, .blockedSafely, .unsafeRedirect:
            return .receiptDrawer
        case .privateItem, .offlineLocal, .professionalBoundary:
            return .userSystemProfile
        case .staleSource, .sourceChange:
            return .sourceFreshnessBadge
        case .needsReview:
            return .closurePrompt
        }
    }
}

public extension SourceFreshnessState {
    var fe04Role: FE04PrimitiveRole {
        .sourceFreshnessBadge
    }
}

public extension ProofBead {
    var fe04Role: FE04PrimitiveRole {
        .proofTrail
    }
}

public extension ReceiptDrawerSection {
    var fe04Role: FE04PrimitiveRole {
        .receiptDrawer
    }
}

public extension ReceiptDrawer {
    var fe04Role: FE04PrimitiveRole {
        .receiptDrawer
    }
}

public extension SourceFreshnessLabel {
    var fe04Role: FE04PrimitiveRole {
        .sourceFreshnessBadge
    }
}

public extension SourceTrustReceiptStrip {
    var fe04Role: FE04PrimitiveRole {
        .inspectableStrip
    }
}

public extension ProofSpine {
    var fe04Role: FE04PrimitiveRole {
        .proofTrail
    }
}
#endif
