import Foundation

enum LifeShapeFakePrecisionAudit {
    static let owner = "Quality/LifeShapeFakePrecisionAudit"
    static let rule = "Root Time copy must not expose fake precision, score language, or runtime/trust jargon."

    static let forbiddenRootTerms = [
        "%",
        "score",
        "confidence",
        "risk",
        "optimized",
        "best next",
        "productivity",
        "runtime",
        "trust",
        "source",
        "receipt",
        "debug",
        "reflow",
        "preview changes",
        "week shape"
    ]

    static func auditRootTimeCopy(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files {
            let literals = LifeShapeAuditSupport.swiftStringLiterals(in: file.contents)
            for literal in literals {
                let lowercased = literal.lowercased()
                for term in forbiddenRootTerms where lowercased.contains(term) {
                    findings.append(LifeShapeAuditFinding(
                        id: "fake-precision.\(normalized(term))",
                        path: file.path,
                        detail: "Root Time string exposes forbidden term '\(term)': \(literal)"
                    ))
                }
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func normalized(_ term: String) -> String {
        term.lowercased()
            .replacingOccurrences(of: "%", with: "percent")
            .replacingOccurrences(of: " ", with: "-")
    }
}
