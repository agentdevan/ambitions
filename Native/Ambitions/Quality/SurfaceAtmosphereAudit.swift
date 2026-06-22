import Foundation

enum SurfaceAtmosphereAudit {
    static let owner = "Quality/SurfaceAtmosphereAudit"
    static let rule = "Full-bleed atmosphere must be semantic stage depth."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.contents.lowercased().contains("wallpaper") {
            findings.append(LifeShapeAuditFinding(id: "atmosphere.wallpaper", path: file.path, detail: "Atmosphere must not be wallpaper."))
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
