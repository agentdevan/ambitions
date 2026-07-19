#if canImport(SwiftUI)
import SwiftUI

public struct SourceTrustReceiptStrip: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Inspection-only: owner surfaces supply SourceRecord, Receipt, and ReplayTrace labels.
    // This primitive renders those labels without adding recommendation or routing logic.
    let items: [SourceTrustReceiptStripItem]

    public init(items: [SourceTrustReceiptStripItem]) {
        self.items = items
    }

    public init(
        sourceLabel: String,
        freshness: SourceFreshnessState,
        receiptLabel: String,
        privacyLabel: String = "Private by default"
    ) {
        self.items = [
            SourceTrustReceiptStripItem(
                id: "source",
                role: .source,
                value: sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Local source" : sourceLabel,
                detail: "Source remains attached to this recommendation.",
                visualState: freshness.visualState
            ),
            SourceTrustReceiptStripItem(
                id: "freshness",
                role: .freshness,
                value: freshness.label,
                detail: freshness.detail,
                visualState: freshness.visualState
            ),
            SourceTrustReceiptStripItem(
                id: "privacy",
                role: .privacy,
                value: privacyLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Private by default" : privacyLabel,
                detail: "Trust boundary stays visible.",
                visualState: .sensitive
            ),
            SourceTrustReceiptStripItem(
                id: "receipt",
                role: .receipt,
                value: receiptLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Receipt ready" : receiptLabel,
                detail: "Receipt path remains inspectable.",
                visualState: .proof
            )
        ]
    }

    public var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    stripItems
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    stripItems
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Source, trust, and receipt")
        .accessibilityValue(accessibilitySummary)
        .accessibilityIdentifier("trust.source-trust-receipt-strip")
    }

    @ViewBuilder
    var stripItems: some View {
        ForEach(items) { item in
            stripItem(item)
        }
    }

    func stripItem(_ item: SourceTrustReceiptStripItem) -> some View {
        let accent = accentColor(for: item)

        return HStack(alignment: .center, spacing: theme.spacing.xs) {
            Image(systemName: item.role.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.role.title)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .textCase(.uppercase)

                Text(item.value)
                    .font((dynamicTypeSize.isAccessibilitySize ? theme.typography.caption : theme.typography.micro).weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xxs)
        .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(accent.opacity(item.visualState == .sensitive ? 0.14 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .stroke(accent.opacity(item.visualState == .stale ? 0.42 : 0.26), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilitySummary)
    }

    func accentColor(for item: SourceTrustReceiptStripItem) -> Color {
        item.primitiveSemanticToken.color(in: theme)
    }

    var accessibilitySummary: String {
        items.map(\.accessibilitySummary).joined(separator: ". ")
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
    let freshness: SourceFreshnessState

    public init(_ freshness: SourceFreshnessState) {
        self.freshness = freshness
    }

    public var body: some View {
        SourceFreshnessLabel(freshness)
            .accessibilityIdentifier("proof-spine.freshness.\(freshness.rawValue)")
    }
}

public struct ProofCorrectionMark: View {
    let label: String

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
    let label: String

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
#endif
