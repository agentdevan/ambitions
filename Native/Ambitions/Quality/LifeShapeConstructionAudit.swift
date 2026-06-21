import Foundation

enum LifeShapeConstructionAudit {
    static let owner = "Quality/LifeShapeConstructionAudit"
    static let rule = "UI must not construct production LifeShape buckets or projections."

    private static let blockedConstructors = [
        "LifeShapeBucket(",
        "LifeShapeProjection("
    ]

    private static let approvedPathFragments = [
        "Native/Ambitions/Projection/SurfaceLenses/",
        "Native/Ambitions/Core/"
    ]

    static func auditUIConstruction(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files {
            let approved = approvedPathFragments.contains { file.path.contains($0) }
            guard approved == false else { continue }
            guard isUIPath(file.path) else { continue }

            for constructor in blockedConstructors where file.contents.contains(constructor) {
                findings.append(LifeShapeAuditFinding(
                    id: "construction.\(constructor.replacingOccurrences(of: "(", with: "").lowercased())",
                    path: file.path,
                    detail: "UI source must not directly construct \(constructor)."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func isUIPath(_ path: String) -> Bool {
        path.contains("/Surfaces/Time/") ||
            path.contains("/DesignSystem/ProductObjects/") ||
            path.contains("/App/")
    }
}
