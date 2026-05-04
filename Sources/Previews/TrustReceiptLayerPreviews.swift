#if canImport(SwiftUI)
import SwiftUI

private struct TrustReceiptLayerPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [TrustReceiptLayerItem] = [
        TrustReceiptLayerItem(
            id: "saved",
            kind: .proofSaved,
            title: "Proof saved",
            summary: "A Still Counts closure was recorded with correction still available.",
            sourceLabel: "Today closure",
            freshness: .fresh,
            privacyLabel: "Private proof",
            undoLabel: "Undo",
            reviewLabel: "Review"
        ),
        TrustReceiptLayerItem(
            id: "moved",
            kind: .moved,
            title: "Moved to Goal",
            summary: "The capture changed place only after confirmation.",
            sourceLabel: "Capture route",
            freshness: .fresh,
            privacyLabel: "Private item",
            undoLabel: "Move back",
            reviewLabel: "Why this?"
        ),
        TrustReceiptLayerItem(
            id: "private",
            kind: .privateItem,
            title: "Sensitive detail hidden",
            summary: "The receipt shows state and source without exposing the private text.",
            sourceLabel: "Local receipt",
            freshness: .localOnly,
            privacyLabel: "Local only",
            reviewLabel: "Review privacy",
            redactedDetail: "Private detail redacted"
        ),
        TrustReceiptLayerItem(
            id: "stale",
            kind: .staleSource,
            title: "Source may need review",
            summary: "Older evidence is useful only after the user checks it.",
            sourceLabel: "Saved source",
            freshness: .stale,
            privacyLabel: "Private source",
            reviewLabel: "Review source"
        ),
        TrustReceiptLayerItem(
            id: "offline",
            kind: .offlineLocal,
            title: "Saved locally",
            summary: "The receipt stays on this device while source access is unavailable.",
            sourceLabel: "Device receipt",
            freshness: .offline,
            privacyLabel: "On device",
            undoLabel: "Undo"
        ),
        TrustReceiptLayerItem(
            id: "boundary",
            kind: .professionalBoundary,
            title: "Professional boundary",
            summary: "Ambitions can organize questions, not replace a professional source.",
            sourceLabel: "Boundary scaffold",
            freshness: .partial,
            privacyLabel: "Sensitive",
            reviewLabel: "Review boundary"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                TrustReceiptToast(
                    item: items[0],
                    isVisible: true,
                    onDismiss: {},
                    onReview: {}
                )

                InlineTrustReceipt(item: items[1], onReview: {}, onUndo: {})

                ProofPreview(item: items[2])

                SourceFreshnessLabel(.stale)

                WhyThisAffordance(
                    summary: "Based on local receipt state, source age, and user confirmation.",
                    evidence: "No hosted AI, account, or server source is claimed.",
                    onOpen: {}
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        InlineTrustReceipt(item: item, onReview: {}, onUndo: {})
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .trust, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }
}

struct TrustReceiptLayerPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            TrustReceiptLayerPreviewGallery()
                .previewDisplayName("SI10 Trust Receipt Layer")

            TrustReceiptLayerPreviewGallery()
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .previewDisplayName("SI10 Trust Receipt Layer Reduce Motion")

            TrustReceiptLayerPreviewGallery()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("SI10 Trust Receipt Layer Dynamic Type")
        }
    }
}
#endif
