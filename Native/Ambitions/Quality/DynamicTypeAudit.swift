import Foundation

enum DynamicTypeAudit {
    static let requiredScenario = RuntimeScenarioAccessibilityMode.dynamicTypeXXXL
    static let rootSurfacePolicy = "Every root surface must keep its primary product object readable at Dynamic Type XXXL."

    static func auditLifeShapeAccessibilityMode(hasXXXLScenario: Bool, hasReadablePrimaryObjectProof: Bool) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        if hasXXXLScenario == false {
            findings.append(LifeShapeAuditFinding(
                id: "dynamic-type.missing-xxxl-scenario",
                path: owner,
                detail: "LifeShape Time must include a Dynamic Type XXXL scenario."
            ))
        }
        if hasReadablePrimaryObjectProof == false {
            findings.append(LifeShapeAuditFinding(
                id: "dynamic-type.missing-readable-primary-object-proof",
                path: owner,
                detail: "LifeShape Time must prove the primary object remains readable at accessibility sizes."
            ))
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static let owner = "Quality/DynamicTypeAudit"
}
