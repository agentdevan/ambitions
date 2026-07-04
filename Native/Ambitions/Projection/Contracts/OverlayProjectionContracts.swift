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
        Self.allowedOwnerLayers.contains(ownerLayer) &&
            primaryObject.isEmpty == false &&
            projectionInputs.isEmpty == false &&
            actionBoundary.isEmpty == false &&
            accessibilityBoundary.isEmpty == false &&
            trustBoundary.localizedCaseInsensitiveContains("local") &&
            failureStates.isEmpty == false
    }

    private static let allowedOwnerLayers: Set<String> = [
        "Composer/Capture/Projection",
        "Stage/Overlays/Projection",
        "Trust/Projection"
    ]
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
        Self.allowedOwnerLayers.contains(ownerLayer) &&
            routeBoundary.localizedCaseInsensitiveContains("overlay") &&
            dockBehavior.localizedCaseInsensitiveContains("root dock") &&
            focusRestoration.isEmpty == false &&
            semanticMirror.localizedCaseInsensitiveContains("accessibility") &&
            motionBehavior.localizedCaseInsensitiveContains("Stage/Motion") &&
            proofBoundary.localizedCaseInsensitiveContains("local")
    }

    private static let allowedOwnerLayers: Set<String> = [
        "Composer/Capture/Projection",
        "Stage/Overlays/Projection",
        "Trust/Projection"
    ]
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
