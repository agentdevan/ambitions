import Foundation

enum ProductObjectDominanceAudit {
    static let owner = "Quality/ProductObjectDominanceAudit"
    static let rule = "Root surfaces must render one dominant product object in the first viewport."

    static func auditTimeRootComposition(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files where file.path.contains("LifeShapeFieldView") {
            let body = file.contents
            if ordered(body, "contextCrown", before: "objectCanvas") {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.crown-before-primary-object",
                    path: file.path,
                    detail: "LifeShapeFieldView renders a root crown before the primary field object."
                ))
            }
            if ordered(body, "LifeShapeLayerSelector", before: "objectCanvas") {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.selector-sibling-before-object",
                    path: file.path,
                    detail: "Layer selector is a sibling before the primary field instead of internal object anatomy."
                ))
            }
            if body.contains("LifeShapeNowInstrument") {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.now-instrument-sibling",
                    path: file.path,
                    detail: "LifeShapeNowInstrument is reachable as root sibling anatomy."
                ))
            }
            if ordered(body, "lifeShapeHorizonRows", before: "LifeShapeBucketDetail") == false,
               body.contains("LifeShapeBucketDetail") {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.detail-root-sibling",
                    path: file.path,
                    detail: "Bucket detail is reachable as root sibling anatomy before user selection proof."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func ordered(_ contents: String, _ first: String, before second: String) -> Bool {
        guard let firstRange = contents.range(of: first),
              let secondRange = contents.range(of: second) else {
            return false
        }
        return firstRange.lowerBound < secondRange.lowerBound
    }
}
