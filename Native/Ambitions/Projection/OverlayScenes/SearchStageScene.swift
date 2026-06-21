import Foundation

enum SearchStageScene {
    static let contract = OverlayStageSceneContract(
        kind: .search,
        ownerLayer: "Projection/OverlayScenes",
        routeBoundary: "Search appears as an overlay, not a persistent surface.",
        dockBehavior: "Root dock stays visible only for the owning root surface.",
        focusRestoration: "Dismissal restores focus to the search entry trigger.",
        semanticMirror: "Search overlay exposes accessibility result and recovery text.",
        motionBehavior: "Stage/Motion coordinates reduced reveal and result updates.",
        proofBoundary: "Search reads local memory and keeps hidden details local."
    )

    static func project(_ lens: OverlayLensReport) -> OverlayStageScene {
        OverlayStageScene(
            contract: contract,
            title: lens.title,
            primaryObject: lens.contract.primaryObject,
            visibleAction: lens.actionSummary,
            stateSummary: lens.primarySummary,
            accessibilitySummary: lens.accessibilitySummary,
            trustSummary: lens.trustSummary,
            failureSummary: lens.failureSummary
        )
    }
}
