import Foundation

enum SeamlessDockAudit {
    static let owner = "Quality/SeamlessDockAudit"
    static let rule = "Continuity Dock must be root-only, integrated, and subordinate."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files {
            if file.contents.contains("StageDockRail") && file.contents.contains("Capsule") && file.contents.contains("stroke") {
                findings.append(LifeShapeAuditFinding(id: "dock.heavy-capsule", path: file.path, detail: "Dock uses heavy capsule/stroke anatomy that must be proven seamless."))
            }
            if file.contents.contains("navigationDestination") && file.contents.contains("showsRootDock") {
                findings.append(LifeShapeAuditFinding(id: "dock.route-depth-risk", path: file.path, detail: "Route depth and dock visibility require proof."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
