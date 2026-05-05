import AmbitionsDesignSystem
import Foundation

struct ProfileCrossSurfaceProofReviewItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let sourceLabel: String
    let reviewLabel: String
    let privacyLabel: String
    let routeLabel: String
    let state: AmbitionVisualState
}

struct ProfileCrossSurfaceProofReviewState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [ProfileCrossSurfaceProofReviewItem]
    let footer: String

    static let empty = ProfileCrossSurfaceProofReviewState(
        title: "Proof and Review",
        subtitle: "Cross-surface proof and review stay behind owning surfaces.",
        items: [],
        footer: "This is a summary, not a new destination."
    )
}
