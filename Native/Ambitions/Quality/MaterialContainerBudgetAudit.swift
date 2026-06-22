import Foundation

enum MaterialContainerBudgetAudit {
    static let owner = "Quality/MaterialContainerBudgetAudit"
    static let rule = "First viewport must avoid nested strong material containers."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files {
            let roundedCount = file.contents.components(separatedBy: "RoundedRectangle").count - 1
            let materialCount = file.contents.components(separatedBy: ".background").count - 1
            if file.path.contains("Surface") && roundedCount >= 4 && materialCount >= 4 {
                findings.append(LifeShapeAuditFinding(id: "material.container-over-budget", path: file.path, detail: "Surface appears to exceed first-viewport material container budget."))
            }
            if file.contents.contains("card inside") || file.contents.contains("nested panel") {
                findings.append(LifeShapeAuditFinding(id: "material.nested-panel-language", path: file.path, detail: "Nested material panel language requires review."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
