import Foundation

enum RootReportPanelAudit {
    static let owner = "Quality/RootReportPanelAudit"
    static let rule = "Root product objects cannot be explanatory report panels."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files {
            let contents = file.contents
            if file.path.contains("LifeShapeNowInstrument") ||
                contents.contains("struct LifeShapeNowInstrument") {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.lifeshape-now-instrument",
                    path: file.path,
                    detail: "LifeShapeNowInstrument is a report-panel risk and must not be root Time anatomy."
                ))
            }
            if contents.contains("Text(reading.capacityStatement)") &&
                contents.contains("primaryActionTitle") {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.capacity-copy-with-cta",
                    path: file.path,
                    detail: "Capacity paragraph and primary CTA appear in the same root report panel."
                ))
            }
            if contents.contains("mark.kind.semanticMeaning") &&
                contents.contains("mark.valueLabel") {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.semantic-meaning-row",
                    path: file.path,
                    detail: "Root field can fall back to semantic meaning rows instead of rendered meaning."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
