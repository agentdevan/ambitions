import Foundation

enum SeamlessDockAudit {
    static let owner = "Quality/SeamlessDockAudit"
    static let rule = "Continuity Dock must be root-only, safe, and visually integrated into the stage."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.path.contains("Dock") || file.path.contains("Stage") || file.path.contains("Scaffold") {
            let text = file.contents
            if text.contains("stroke(") && text.contains("Capsule") && file.path.contains("Dock") {
                findings.append(LifeShapeAuditFinding(id: "seamless-dock.heavy-pill-stroke", path: file.path, detail: "Dock uses a bordered capsule pattern; root dock must be visually subordinate and integrated."))
            }
            if text.contains("showsRootDock") && text.contains("drilldown") == false && file.path.contains("Stage") {
                findings.append(LifeShapeAuditFinding(id: "seamless-dock.route-depth-proof", path: file.path, detail: "Dock visibility source must prove route-depth hiding for drilldowns."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
