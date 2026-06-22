import Foundation

enum ShellUtilityValueAudit {
    static let owner = "Quality/ShellUtilityValueAudit"
    static let rule = "Shell controls must be useful, contextual, and non-duplicated."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        let corpus = files.map(\.contents).joined(separator: "\n")
        for label in ["Search", "Capture"] {
            let count = corpus.components(separatedBy: label).count - 1
            if count > 40 {
                findings.append(LifeShapeAuditFinding(id: "shell-utility.excessive-\(label.lowercased())", path: "Shell", detail: "Shell utility \(label) appears excessively; verify single contextual ownership."))
            }
        }
        if corpus.contains("systemImage: \"plus\"") && corpus.contains("Capture") == false {
            findings.append(LifeShapeAuditFinding(id: "shell-utility.generic-plus", path: "Shell", detail: "Generic plus appears without Capture/product role."))
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
