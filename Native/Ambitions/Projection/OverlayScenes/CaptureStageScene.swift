import Foundation

enum OverlayStageSceneKind: String, Sendable, Equatable {
    case capture = "Capture"
    case search = "Search"
    case closure = "Closure"
    case inspection = "Inspection"
}

struct OverlayStageSceneContract: Sendable, Equatable {
    let kind: OverlayStageSceneKind
    let ownerLayer: String
    let routeBoundary: String
    let dockBehavior: String
    let focusRestoration: String
    let semanticMirror: String
    let motionBehavior: String
    let proofBoundary: String

    var satisfiesFinalCanon: Bool {
        ownerLayer == "Projection/OverlayScenes" &&
            routeBoundary.localizedCaseInsensitiveContains("overlay") &&
            dockBehavior.localizedCaseInsensitiveContains("root dock") &&
            focusRestoration.isEmpty == false &&
            semanticMirror.localizedCaseInsensitiveContains("accessibility") &&
            motionBehavior.localizedCaseInsensitiveContains("Stage/Motion") &&
            proofBoundary.localizedCaseInsensitiveContains("local")
    }
}

struct OverlayStageScene: Sendable, Equatable {
    let contract: OverlayStageSceneContract
    let title: String
    let primaryObject: String
    let visibleAction: String
    let stateSummary: String
    let accessibilitySummary: String
    let trustSummary: String
    let failureSummary: String

    var isProductionReady: Bool {
        contract.satisfiesFinalCanon &&
            title.isEmpty == false &&
            primaryObject.isEmpty == false &&
            visibleAction.isEmpty == false &&
            stateSummary.isEmpty == false &&
            accessibilitySummary.isEmpty == false &&
            trustSummary.localizedCaseInsensitiveContains("local") &&
            failureSummary.isEmpty == false
    }
}

enum CaptureStageScene {
    static let contract = OverlayStageSceneContract(
        kind: .capture,
        ownerLayer: "Projection/OverlayScenes",
        routeBoundary: "Capture appears as a composer overlay, never a root route.",
        dockBehavior: "Root dock remains owned by persistent surfaces under the overlay.",
        focusRestoration: "Dismissal restores focus to the invoking surface action.",
        semanticMirror: "Capture overlay exposes accessibility summaries before mutation.",
        motionBehavior: "Stage/Motion coordinates composer reveal, reduction, and return.",
        proofBoundary: "Capture placement proof remains local and inspectable."
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
