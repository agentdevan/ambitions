import Foundation

enum OverlayLensKind: String, Sendable, Equatable {
    case capture = "Capture"
    case search = "Search"
    case closure = "Closure"
    case inspection = "Inspection"
}

struct OverlayLensContract: Sendable, Equatable {
    let kind: OverlayLensKind
    let ownerLayer: String
    let primaryObject: String
    let projectionInputs: [String]
    let actionBoundary: String
    let accessibilityBoundary: String
    let trustBoundary: String
    let failureStates: [String]

    var satisfiesFinalCanon: Bool {
        ownerLayer == "Projection/OverlayLenses" &&
            primaryObject.isEmpty == false &&
            projectionInputs.isEmpty == false &&
            actionBoundary.isEmpty == false &&
            accessibilityBoundary.isEmpty == false &&
            trustBoundary.localizedCaseInsensitiveContains("local") &&
            failureStates.isEmpty == false
    }
}

struct OverlayLensReport: Sendable, Equatable {
    let contract: OverlayLensContract
    let title: String
    let primarySummary: String
    let actionSummary: String
    let accessibilitySummary: String
    let trustSummary: String
    let failureSummary: String

    var isProductionReady: Bool {
        contract.satisfiesFinalCanon &&
            title.isEmpty == false &&
            primarySummary.isEmpty == false &&
            actionSummary.isEmpty == false &&
            accessibilitySummary.isEmpty == false &&
            trustSummary.isEmpty == false &&
            failureSummary.isEmpty == false
    }
}

enum CaptureLens {
    static let contract = OverlayLensContract(
        kind: .capture,
        ownerLayer: "Projection/OverlayLenses",
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
