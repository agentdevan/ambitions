import Foundation

enum ProjectionTruthAudit {
    static let owner = "Quality/ProjectionTruthAudit"
    static let rule = "Projection code must not fabricate minimum-count intelligence."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files where file.path.contains("Projection") || file.path.contains("TimeLifeShape") {
            let lines = file.contents.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() where line.contains("max(") && line.contains(", 1") {
                findings.append(LifeShapeAuditFinding(
                    id: "projection-truth.fabricated-minimum-count",
                    path: file.path,
                    detail: "line \(index + 1): \(line.trimmingCharacters(in: .whitespaces))"
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
