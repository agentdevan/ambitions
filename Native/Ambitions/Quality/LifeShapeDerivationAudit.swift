import Foundation

enum LifeShapeDerivationAudit {
    static let owner = "Quality/LifeShapeDerivationAudit"
    static let rule = "LifeShape buckets must carry derivation inputs, rules, clock source, fallback, and accessibility summary."

    static let requiredContractTokens = [
        "LifeShapeProjection",
        "LifeShapeBucket",
        "LifeShapeBucketBuilder",
        "LifeShapeReadingKind",
        "LifeShapeLayer",
        "LifeShapeHorizon",
        "inputRefs",
        "ruleIDs",
        "clockDerivation",
        "fallbackState",
        "LifeShapeConfidence",
        "accessibilitySummary"
    ]

    static func auditModelContract(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        let combined = files.map(\.contents).joined(separator: "\n")
        let path = files.map(\.path).joined(separator: ", ")
        let findings = requiredContractTokens.compactMap { token -> LifeShapeAuditFinding? in
            guard combined.contains(token) == false else { return nil }
            return LifeShapeAuditFinding(
                id: "derivation.missing-\(token)",
                path: path,
                detail: "LifeShape derivation contract is missing \(token)."
            )
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
