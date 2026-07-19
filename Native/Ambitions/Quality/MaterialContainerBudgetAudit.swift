import Foundation

enum MaterialContainerBudgetAudit {
    static let owner = "Quality/MaterialContainerBudgetAudit"
    static let rule = "First viewport may not regress into nested cards or boxed dashboard composition."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.path.contains("Surfaces/") || file.path.contains("ProductObjects/") {
            let text = file.contents
            let roundedCount = text.components(separatedBy: "RoundedRectangle").count - 1
            let materialCount = text.components(separatedBy: "Material").count - 1
            if roundedCount >= 6 && text.contains("VStack") {
                findings.append(LifeShapeAuditFinding(id: "material-budget.nested-rounded-containers", path: file.path, detail: "High rounded-container count suggests card-stack/dashboard composition."))
            }
            if materialCount >= 4 && text.contains("firstViewport") {
                findings.append(LifeShapeAuditFinding(id: "material-budget.first-viewport-material-excess", path: file.path, detail: "First viewport appears to exceed material budget."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
