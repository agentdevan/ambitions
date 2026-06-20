import Foundation

enum StageSurfaceLayer: String, Equatable {
    case persistentSurface
    case globalComposer
    case motionBehavior
    case trustInspection
}

struct StageSurfaceOwnership: Equatable, Identifiable {
    let id: String
    let title: String
    let layer: StageSurfaceLayer
    let canonicalTab: AmbitionsSurface?
    let primaryObjectTitle: String
    let routePolicy: String
}

enum SurfaceOwnershipRegistry {
    static let persistentSurfaceTabs: [AmbitionsSurface] = [.today, .goals, .time, .you]

    static let persistentSurfaces: [StageSurfaceOwnership] = persistentSurfaceTabs.map { tab in
        StageSurfaceOwnership(
            id: tab.rawValue,
            title: tab.title,
            layer: .persistentSurface,
            canonicalTab: tab,
            primaryObjectTitle: tab.primaryObjectTitle,
            routePolicy: "Root Stage surface"
        )
    }

    static let globalComposer = StageSurfaceOwnership(
        id: "capture",
        title: "Capture",
        layer: .globalComposer,
        canonicalTab: nil,
        primaryObjectTitle: "Atmosphere Composer",
        routePolicy: "Overlay/global composer only"
    )

    static let motionBehavior = StageSurfaceOwnership(
        id: "motion",
        title: "Motion",
        layer: .motionBehavior,
        canonicalTab: nil,
        primaryObjectTitle: "Stage/Motion behavior",
        routePolicy: "Behavior layer only"
    )

    static let trustInspection = StageSurfaceOwnership(
        id: "trust-inspection",
        title: "Proof / Source / Privacy / History / Receipts",
        layer: .trustInspection,
        canonicalTab: nil,
        primaryObjectTitle: "Inspectable trust layer",
        routePolicy: "Contextual inspection inside owning surfaces"
    )

    static var rootSurfaceTitles: [String] {
        persistentSurfaces.map(\.title)
    }

    static var rootSurfaceRawValues: [String] {
        persistentSurfaces.map(\.id)
    }

    static func ownership(for tab: AmbitionsSurface) -> StageSurfaceOwnership {
        guard let surface = persistentSurfaces.first(where: { $0.canonicalTab == tab }) else {
            preconditionFailure("Missing Stage surface ownership for \(tab.rawValue).")
        }
        return surface
    }

    static func isPersistentRoot(rawValue: String) -> Bool {
        rootSurfaceRawValues.contains(rawValue.lowercased())
    }

    static func validationIssues(
        persistentSurfaces surfaces: [StageSurfaceOwnership] = persistentSurfaces
    ) -> [String] {
        var issues: [String] = []

        if surfaces.map(\.canonicalTab) != persistentSurfaceTabs.map(Optional.some) {
            issues.append("Stage root surfaces must be exactly Today, Goals, Time, You.")
        }

        let rootIDs = surfaces.map(\.id)
        if rootIDs.contains("capture") {
            issues.append("Capture must remain overlay/global composer only.")
        }
        if rootIDs.contains("motion") {
            issues.append("Motion must remain Stage/Motion behavior only.")
        }

        let duplicateIDs = Dictionary(grouping: rootIDs, by: { $0 })
            .filter { $0.value.count > 1 }
            .keys
        for duplicate in duplicateIDs.sorted() {
            issues.append("Duplicate Stage root surface id: \(duplicate).")
        }

        for surface in surfaces {
            guard surface.layer == .persistentSurface else {
                issues.append("\(surface.title) is not a persistent Stage surface.")
                continue
            }
            guard let tab = surface.canonicalTab else {
                issues.append("\(surface.title) must be backed by a canonical tab.")
                continue
            }
            let expectedObject = tab.primaryObjectTitle
            if surface.primaryObjectTitle != expectedObject {
                issues.append("\(surface.title) must own \(expectedObject), not \(surface.primaryObjectTitle).")
            }
        }

        return issues
    }
}
