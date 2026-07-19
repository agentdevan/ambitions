import Foundation

enum LifeShapeSemanticAudit {
    static let owner = "Quality/LifeShapeSemanticAudit"
    static let rule = "Every visible LifeShape mark must expose derivation and accessibility meaning."

    static let requiredSemanticTokens = [
        "semanticMeaning",
        "accessibilitySummary",
        "inputRefs",
        "ruleIDs"
    ]

    static func auditSemanticMarkContract(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        let combined = files.map(\.contents).joined(separator: "\n")
        let path = files.map(\.path).joined(separator: ", ")
        guard combined.contains("LifeShapeSemanticMark") else {
            return LifeShapeAuditReport(findings: [
                LifeShapeAuditFinding(
                    id: "semantic.missing-mark-contract",
                    path: path,
                    detail: "LifeShape semantic mark contract was not found."
                )
            ])
        }

        let findings = requiredSemanticTokens.compactMap { token -> LifeShapeAuditFinding? in
            guard combined.contains(token) == false else { return nil }
            return LifeShapeAuditFinding(
                id: "semantic.missing-\(token)",
                path: path,
                detail: "LifeShape semantic marks are missing \(token)."
            )
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
