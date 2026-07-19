import Foundation

enum RouteDepthChromeAudit {
    static let owner = "Quality/RouteDepthChromeAudit"
    static let rule = "Chrome must reduce by route depth."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.path.contains("Navigation") || file.path.contains("Stage") || file.path.contains("Scaffold") {
            let text = file.contents
            if text.contains("navigationDestination") && text.contains("showsRootDock") {
                findings.append(LifeShapeAuditFinding(id: "route-depth.navigation-dock-risk", path: file.path, detail: "Navigation destination source must prove root dock is hidden at detail depth."))
            }
            if text.contains("fullScreenCover") && text.contains("showsRootDock") {
                findings.append(LifeShapeAuditFinding(id: "route-depth.overlay-dock-risk", path: file.path, detail: "Overlay source must prove root dock is hidden when focus requires it."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
