import Foundation

enum FullBleedSurfaceAudit {
    static let owner = "Quality/FullBleedSurfaceAudit"
    static let rule = "Root surfaces must render as full-bleed stages, not header/content/footer boxes."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.path.contains("/App/") || file.path.contains("/Stage/") || file.path.contains("/Surfaces/") {
            let text = file.contents
            if text.contains("Rectangle().fill") && text.localizedCaseInsensitiveContains("divider") && text.localizedCaseInsensitiveContains("header") {
                findings.append(LifeShapeAuditFinding(id: "full-bleed.header-divider", path: file.path, detail: "Header divider/slab pattern appears in shell or surface source."))
            }
            if text.contains(".background(headerMaterial)") && text.contains("onBack == nil") {
                findings.append(LifeShapeAuditFinding(id: "full-bleed.root-header-material", path: file.path, detail: "Root header material must be integrated, not a separate slab."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
