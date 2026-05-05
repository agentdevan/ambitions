import AmbitionsDesignSystem
import Foundation

struct ProfileCrossSurfaceProofReviewProjector {
    struct Input: Sendable, Equatable {
        let captureSeedCount: Int
        let goalProofCount: Int
        let todayCompletionProofCount: Int
        let planReceiptCount: Int
        let goalChangeCount: Int
        let reviewPromptCount: Int
    }

    func project(_ input: Input) -> ProfileCrossSurfaceProofReviewState {
        ProfileCrossSurfaceProofReviewState(
            title: "Proof and review connections",
            subtitle: "A compact map of where proof, receipts, and review prompts already belong across Ambitions.",
            items: [
                captureToGoalProof(input),
                todayToGoalProof(input),
                planReflowReceipt(input),
                goalChangeToYouHistory(input),
                receiptDetailNavigation,
                sparseReviewPrompts(input)
            ],
            footer: "This map does not create a dashboard, raw log, or new tab. It points review back to the owning surface."
        )
    }

    private func captureToGoalProof(_ input: Input) -> ProfileCrossSurfaceProofReviewItem {
        ProfileCrossSurfaceProofReviewItem(
            id: "cross-review-capture-goal-proof",
            title: "Capture to Goal proof",
            summary: input.captureSeedCount == 0
                ? "Capture can become goal context only after review."
                : "\(input.captureSeedCount) capture or goal-seed records can carry source notes into goal review.",
            sourceLabel: "Source: Capture",
            reviewLabel: "Confirm before saving",
            privacyLabel: "Private details summarized",
            routeLabel: "Review in Capture or Goal creation",
            state: input.captureSeedCount == 0 ? .default : .selected
        )
    }

    private func todayToGoalProof(_ input: Input) -> ProfileCrossSurfaceProofReviewItem {
        ProfileCrossSurfaceProofReviewItem(
            id: "cross-review-today-goal-proof",
            title: "Today completion to Goal proof",
            summary: input.todayCompletionProofCount == 0
                ? "Completed steps will appear as proof only when the owning flow saves evidence."
                : "\(input.todayCompletionProofCount) completed-step proof records can support \(input.goalProofCount) goal proof records.",
            sourceLabel: "Source: Today",
            reviewLabel: "Review in Goal proof",
            privacyLabel: "Evidence, not a prize",
            routeLabel: "Review in Today or Goal Detail",
            state: input.todayCompletionProofCount == 0 ? .default : .success
        )
    }

    private func planReflowReceipt(_ input: Input) -> ProfileCrossSurfaceProofReviewItem {
        ProfileCrossSurfaceProofReviewItem(
            id: "cross-review-plan-reflow-receipt",
            title: "Plan reflow to receipt",
            summary: input.planReceiptCount == 0
                ? "Plan changes stay quiet until an owning Plan action records review context."
                : "\(input.planReceiptCount) Plan ledger entries can explain what changed and why.",
            sourceLabel: "Source: Plan",
            reviewLabel: "Review source",
            privacyLabel: "Receipt, not notification",
            routeLabel: "Review in Plan or Receipts",
            state: input.planReceiptCount == 0 ? .default : .warning
        )
    }

    private func goalChangeToYouHistory(_ input: Input) -> ProfileCrossSurfaceProofReviewItem {
        ProfileCrossSurfaceProofReviewItem(
            id: "cross-review-goal-you-history",
            title: "Goal change to You history",
            summary: input.goalChangeCount == 0
                ? "Goal changes will appear in You only as local review summaries."
                : "\(input.goalChangeCount) goal changes can be summarized in Trust History.",
            sourceLabel: "Source: Goals",
            reviewLabel: "Local record",
            privacyLabel: "Summary first",
            routeLabel: "Review in Goal Detail or You",
            state: input.goalChangeCount == 0 ? .default : .selected
        )
    }

    private var receiptDetailNavigation: ProfileCrossSurfaceProofReviewItem {
        ProfileCrossSurfaceProofReviewItem(
            id: "cross-review-receipt-detail-navigation",
            title: "Receipt detail navigation",
            summary: "Receipt rows point back to their owning surface instead of opening a separate feed.",
            sourceLabel: "Source: Receipts",
            reviewLabel: "Owning surface",
            privacyLabel: "Raw logs hidden",
            routeLabel: "Review where shown",
            state: .default
        )
    }

    private func sparseReviewPrompts(_ input: Input) -> ProfileCrossSurfaceProofReviewItem {
        ProfileCrossSurfaceProofReviewItem(
            id: "cross-review-sparse-prompts",
            title: "Sparse review prompts",
            summary: input.reviewPromptCount == 0
                ? "No current review prompt needs attention."
                : "\(input.reviewPromptCount) local review boundaries can ask before consequential reuse.",
            sourceLabel: "Source: Review",
            reviewLabel: input.reviewPromptCount == 0 ? "No review needed" : "Review source",
            privacyLabel: "User-owned",
            routeLabel: "Review from owning surface",
            state: input.reviewPromptCount == 0 ? .default : .warning
        )
    }
}
