import Foundation

enum SurfaceAtmosphereAudit {
    static let owner = "Quality/SurfaceAtmosphereAudit"
    static let rule = "Full-bleed atmosphere must be semantic stage depth, not wallpaper or decoration."

    private static let forbiddenTerms = [
        "wallpaper",
        "decorative stars",
        "space art",
        "neon HUD",
        "particle background"
    ]

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.path.contains("Stage") || file.path.contains("DesignSystem") || file.path.contains("Surfaces") {
            let lower = file.contents.lowercased()
            for term in forbiddenTerms where lower.contains(term.lowercased()) {
                findings.append(LifeShapeAuditFinding(id: "surface-atmosphere.\(term.replacingOccurrences(of: " ", with: "-"))", path: file.path, detail: "Atmosphere must not become \(term)."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
