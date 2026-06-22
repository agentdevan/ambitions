import Foundation

enum FullBleedSurfaceAudit {
    static let owner = "Quality/FullBleedSurfaceAudit"
    static let rule = "Root surfaces must render as full-bleed stages, not framed pages."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files {
            let contents = file.contents
            if contents.contains("AppShellHeaderRail") && contents.contains(".background(headerMaterial)") {
                findings.append(LifeShapeAuditFinding(id: "full-bleed.detached-header", path: file.path, detail: "Header rail material appears detached from the stage."))
            }
            if contents.contains("stageSurfaceHost") && contents.contains("shellRootDockLayer") && contents.contains("VStack(spacing: 0)") {
                findings.append(LifeShapeAuditFinding(id: "full-bleed.separated-stage", path: file.path, detail: "Stage layout appears separated into content and dock zones."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
