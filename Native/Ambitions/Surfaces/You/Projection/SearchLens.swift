import Foundation

enum SearchLens {
    static let contract = OverlayLensContract(
        kind: .search,
        ownerLayer: "Surfaces/You/Projection",
        primaryObject: "Local Search results",
        projectionInputs: ["query prompt", "filters", "matched local candidates", "performance budget"],
        actionBoundary: "Search opens local results and expansion only through source-tied rows.",
        accessibilityBoundary: "VoiceOver reads result title, source, freshness, matched terms, and available actions.",
        trustBoundary: "Search stays local, inspectable, and source-tied with no external service.",
        failureStates: ["empty results", "budget hit", "broken source", "privacy-redacted result"]
    )

    static func project(_ state: YouEverythingSearchState) -> OverlayLensReport {
        OverlayLensReport(
            contract: contract,
            title: state.title,
            primarySummary: "\(state.returnedItemCount) of \(state.matchedCandidateCount) matched local candidates returned.",
            actionSummary: state.items.first?.primaryActions.first?.title ?? "Refine local search",
            accessibilitySummary: state.items.first?.accessibilityValue ?? state.queryPrompt,
            trustSummary: state.footer,
            failureSummary: state.items.isEmpty ? state.performanceBudgetSummary : "Search results preserve source and freshness labels."
        )
    }
}
