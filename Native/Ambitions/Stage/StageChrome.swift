import AmbitionsDesignSystem
import CoreGraphics
import Foundation

enum StageRouteDepth: String, Equatable {
    case root
    case drilldown
}

struct StageChromePolicy: Equatable {
    let routeDepth: StageRouteDepth
    let overlayPresentation: StageOverlayPresentation
    let dynamicTypeIsAccessibilitySize: Bool
    let showsRootDock: Bool
    let showsDockBackdrop: Bool
    let dockClearance: CGFloat
    let dockBackdropHeight: CGFloat
    let stageContentBottomClearance: CGFloat
    let captureComposerClearance: CGFloat
    let continuityReceiptBottomClearance: CGFloat
}

struct StageDockDestination: Equatable, Identifiable {
    let surface: AmbitionsSurface
    let title: String
    let glyphRole: AmbitionSemanticGlyphRole
    let accessibilityIdentifier: String

    var id: AmbitionsSurface { surface }

    var systemImage: String {
        glyphRole.symbolName
    }

    static var all: [StageDockDestination] {
        AmbitionsSurface.allCases.map { surface in
            StageDockDestination(
                surface: surface,
                title: surface.title,
                glyphRole: surface.stageDockGlyphRole,
                accessibilityIdentifier: "shell.meridian.destination.\(surface.rawValue)"
            )
        }
    }
}

extension AmbitionsSurface {
    var stageDockGlyphRole: AmbitionSemanticGlyphRole {
        switch self {
        case .today:
            .startHere
        case .goals:
            .goalsAtlas
        case .time:
            .timeCapacity
        case .you:
            .userProfile
        }
    }
}

struct StageChromeContract: Equatable {
    let title: String
    let destinationRailLabel: String
    let receiptOverlayZoneLabel: String
    let globalActionLabel: String
    let safeAreaLabel: String
    let rollbackLabel: String
    let destinations: [StageDockDestination]

    var accessibilitySummary: String {
        [
            title,
            destinationRailLabel,
            receiptOverlayZoneLabel,
            globalActionLabel,
            safeAreaLabel
        ].joined(separator: ". ")
    }

    static let launchDefault = StageChromeContract(
        title: "Ambition Meridian",
        destinationRailLabel: "Four destinations: Today, Goals, Time, You.",
        receiptOverlayZoneLabel: "Receipt overlay zone stays bounded and dismissible.",
        globalActionLabel: "Global add opens capture or command choices without changing tabs.",
        safeAreaLabel: "Shell chrome stays inside safe areas and keeps native navigation available.",
        rollbackLabel: "Rollback by reverting the Stage shell migration commit; no alternate root shell is exposed.",
        destinations: StageDockDestination.all
    )
}
