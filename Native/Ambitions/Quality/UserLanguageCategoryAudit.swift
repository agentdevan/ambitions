import Foundation

enum UserLanguageCategoryAudit {
    static let owner = "Quality/UserLanguageCategoryAudit"
    static let rule = "Root UI must not expose architecture or invented terrain jargon."

    static let forbiddenRootJargon = [
        "ridge",
        "contour",
        "basin",
        "bridge",
        "lane",
        "seam",
        "trace",
        "pocket"
    ]

    static func auditRootStrings(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files {
            let isRootTimeFile = file.path.contains("LifeShape") || file.path.contains("Surfaces/Time")
            guard isRootTimeFile else { continue }

            for literal in LifeShapeAuditSupport.swiftStringLiterals(in: file.contents) {
                let lowercased = literal.lowercased()
                for term in forbiddenRootJargon where lowercased.contains(term) {
                    findings.append(LifeShapeAuditFinding(
                        id: "user-language-category.\(term)",
                        path: file.path,
                        detail: "Root Time string exposes unapproved jargon '\(term)': \(literal)"
                    ))
                }
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
