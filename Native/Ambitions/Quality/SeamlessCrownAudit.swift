import Foundation

enum SeamlessCrownAudit {
    static let owner = "Quality/SeamlessCrownAudit"
    static let rule = "Context Crown must be integrated, singular, and useful."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files {
            if file.contents.contains("var contextCrown") {
                findings.append(LifeShapeAuditFinding(id: "crown.surface-owned-root-crown", path: file.path, detail: "Surface-owned root crown requires shell opt-out proof."))
            }
            if file.path.contains("AppShellHeaderRail") && file.contents.contains("headerMaterial") {
                findings.append(LifeShapeAuditFinding(id: "crown.detached-rail", path: file.path, detail: "Header rail material must be reviewed for seamless integration."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
