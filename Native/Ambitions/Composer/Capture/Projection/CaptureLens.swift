import Foundation

enum CaptureLens {
    static let contract = OverlayLensContract(
        kind: .capture,
        ownerLayer: "Composer/Capture/Projection",
        primaryObject: "Atmosphere Composer routing review",
        projectionInputs: ["composer input", "placement review", "routing preview", "privacy boundary"],
        actionBoundary: "Capture can place, correct, archive, or promote only after visible review.",
        accessibilityBoundary: "VoiceOver reads placement, destination, consequence, privacy, and confirmation before actions.",
        trustBoundary: "Capture routing stays local and reviewable before it changes Goals, Today, or Time.",
        failureStates: ["empty input", "uncertain destination", "permission unavailable", "archive instead"]
    )

    static func project(_ review: CapturePlacementReviewState) -> OverlayLensReport {
        OverlayLensReport(
            contract: contract,
            title: review.title,
            primarySummary: "\(review.placementStateTitle): \(review.destinationLabel)",
            actionSummary: "\(review.confirmationLabel). \(review.archiveLabel)",
            accessibilitySummary: review.accessibilityValue,
            trustSummary: "\(review.privacyLabel). Capture review stays local.",
            failureSummary: review.destinationLabel.localizedCaseInsensitiveContains("Needs")
                ? "Placement waits for explicit review."
                : "Placement can proceed after confirmation."
        )
    }
}
