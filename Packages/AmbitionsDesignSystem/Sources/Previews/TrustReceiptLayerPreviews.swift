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
            whyLabel: "The user chose Still Counts instead of silent rescheduling.",
            changeLabel: "Closure was recorded; the day was not rearranged.",
            undoLabel: "Undo",
            correctionLabel: "Correction stays available from the receipt.",
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
            whyLabel: "The user confirmed the destination.",
            changeLabel: "Capture placement changed with a receipt.",
            undoLabel: "Move back",
            correctionLabel: "Route can be corrected without losing the capture.",
            reviewLabel: "Why this?"
        ),
        TrustReceiptLayerItem(
            id: "undone",
            kind: .undone,
            title: "Undo recorded",
            summary: "The prior receipt was reversed and the reversal stayed visible.",
            sourceLabel: "Recovery receipt",
            freshness: .fresh,
            privacyLabel: "Private undo",
            whyLabel: "The user reversed the earlier change.",
            changeLabel: "The reversal was recorded locally.",
            undoLabel: "Undo unavailable",
            correctionLabel: "Correction stays available.",
            reviewLabel: "Review undo"
        ),
        TrustReceiptLayerItem(
            id: "private",
            kind: .privateItem,
            title: "Sensitive detail hidden",
            summary: "The receipt shows state and source without exposing the private text.",
            sourceLabel: "Local receipt",
            freshness: .localOnly,
            privacyLabel: "Local only",
            whyLabel: "Sensitive detail is hidden outside the review surface.",
            changeLabel: "Only the safe summary is visible here.",
            correctionLabel: "Privacy can be reviewed from You.",
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
            whyLabel: "The source is useful but older than the review window.",
            changeLabel: "No action changes until the user reviews the source.",
            correctionLabel: "Source may be replaced or corrected.",
            reviewLabel: "Review context"
        ),
        TrustReceiptLayerItem(
            id: "offline",
            kind: .offlineLocal,
            title: "Saved locally",
            summary: "The receipt stays on this device while source access is unavailable.",
            sourceLabel: "Device receipt",
            freshness: .offline,
            privacyLabel: "On device",
            whyLabel: "Source access is unavailable.",
            changeLabel: "Receipt remains local.",
            undoLabel: "Undo"
        ),
        TrustReceiptLayerItem(
            id: "recovery",
            kind: .blockedSafely,
            title: "Recovery path blocked safely",
            summary: "The surface stayed honest about a blocked recovery state instead of implying a hidden change.",
            sourceLabel: "Recovery path",
            freshness: .blocked,
            privacyLabel: "Protected state",
            whyLabel: "The blocked path keeps the user in control.",
            changeLabel: "No hidden change was applied.",
            undoLabel: "Undo unavailable",
            correctionLabel: "Correction unavailable",
            reviewLabel: "Review recovery"
        ),
        TrustReceiptLayerItem(
            id: "boundary",
            kind: .professionalBoundary,
            title: "Professional boundary",
            summary: "Ambitions can organize questions, not replace a professional source.",
            sourceLabel: "Boundary scaffold",
            freshness: .partial,
            privacyLabel: "Sensitive",
            whyLabel: "Professional topics need outside sources.",
            changeLabel: "Ambitions keeps this as review, not advice.",
            correctionLabel: "Boundary can be reviewed before acting.",
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

                WhyThisAffordance(
                    summary: "Receipts show what changed, why it changed, and what remains reviewable.",
                    evidence: "No hosted backend, account, or AI confidence language is implied.",
                    onOpen: {}
                )

                ReceiptDrawer(
                    title: "Receipt drawer",
                    subtitle: "The drawer keeps source freshness, privacy, correction, undo, and review visible.",
                    sections: [
                        ReceiptDrawerSection(
                            id: "recent",
                            title: "Recent receipts",
                            subtitle: "Normal, undo, and moved states stay separate from review-only states.",
                            items: Array(items.prefix(4))
                        ),
                        ReceiptDrawerSection(
                            id: "recovery",
                            title: "Recovery states",
                            subtitle: "Private, stale, offline, and blocked states stay visible without hidden claims.",
                            items: Array(items.suffix(4))
                        )
                    ],
                    onReview: { _ in },
                    onUndo: { _ in }
                )

                ProofSpine(
                    title: "Proof trail",
                    subtitle: "Proof keeps source freshness and privacy attached to the visible trail.",
                    beads: [
                        ProofBead(
                            id: "bead-saved",
                            title: items[0].title,
                            summary: items[0].summary,
                            sourceLabel: items[0].sourceLabel,
                            freshness: items[0].freshness,
                            privacyLabel: items[0].privacyLabel,
                            timestampLabel: "2026-05-18T12:00:00Z",
                            correctionLabel: items[0].correctionLabel,
                            staleReviewLabel: items[0].reviewLabel
                        ),
                        ProofBead(
                            id: "bead-private",
                            title: items[3].title,
                            summary: items[3].summary,
                            sourceLabel: items[3].sourceLabel,
                            freshness: items[3].freshness,
                            privacyLabel: items[3].privacyLabel,
                            timestampLabel: "2026-05-18T12:05:00Z",
                            correctionLabel: items[3].correctionLabel,
                            staleReviewLabel: items[3].reviewLabel,
                            redactedDetail: items[3].redactedDetail
                        ),
                        ProofBead(
                            id: "bead-recovery",
                            title: items[6].title,
                            summary: items[6].summary,
                            sourceLabel: items[6].sourceLabel,
                            freshness: items[6].freshness,
                            privacyLabel: items[6].privacyLabel,
                            timestampLabel: "2026-05-18T12:10:00Z",
                            correctionLabel: items[6].correctionLabel,
                            staleReviewLabel: "Blocked safely until review"
                        )
                    ]
                )

                SourceFreshnessLabel(.fresh)
                SourceFreshnessLabel(.localOnly)

                InlineTrustReceipt(item: items[1], onReview: {}, onUndo: {})

                ReceiptDrawer(
                    title: "Receipt Drawer",
                    sections: [
                        ReceiptDrawerSection(
                            id: "recent",
                            title: "Recent receipts",
                            subtitle: "Consequences and review paths stay visible.",
                            items: Array(items.prefix(3))
                        ),
                        ReceiptDrawerSection(
                            id: "source-review",
                            title: "Source review",
                            subtitle: "Older, local, and boundary states stay separate.",
                            items: Array(items.suffix(3))
                        )
                    ],
                    onReview: { _ in },
                    onUndo: { _ in }
                )

                ProofPreview(item: items[3])

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
