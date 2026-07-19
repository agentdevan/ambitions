import Foundation

enum ShellContentSafetyAudit {
    static let owner = "Quality/ShellContentSafetyAudit"
    static let rule = "Full-bleed atmosphere may extend under chrome; interactive content must stay safe."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        for file in files where file.path.contains("Stage") || file.path.contains("Surfaces") || file.path.contains("Composer") {
            let text = file.contents
            if text.contains("ignoresSafeArea") && text.contains("allowsHitTesting") == false && text.contains("accessibilityHidden") == false {
                findings.append(LifeShapeAuditFinding(id: "shell-content-safety.unsafe-ignores-safe-area", path: file.path, detail: "Full-bleed source uses ignoresSafeArea without clear noninteractive/background semantics."))
            }
            if text.contains("keyboard") && text.contains("dock") && text.contains("clearance") == false {
                findings.append(LifeShapeAuditFinding(id: "shell-content-safety.keyboard-dock-clearance", path: file.path, detail: "Keyboard/dock source must explicitly model clearance."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
