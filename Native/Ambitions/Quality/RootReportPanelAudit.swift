import Foundation

enum RootReportPanelAudit {
    static let owner = "Quality/RootReportPanelAudit"
    static let rule = "Root product objects cannot be explanatory report panels."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files {
            let contents = file.contents
            if file.path.contains("LifeShapeNowInstrument") ||
                contents.contains("struct LifeShapeNowInstrument")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.lifeshape-now-instrument",
                    path: file.path,
                    detail: "LifeShapeNowInstrument is a report-panel risk and must not be root Time anatomy."
                ))
            }
            if contents.contains("Text(reading.capacityStatement)") &&
                contents.contains("primaryActionTitle")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.capacity-copy-with-cta",
                    path: file.path,
                    detail: "Capacity paragraph and primary CTA appear in the same root report panel."
                ))
            }
            if isRootLifeShapeRenderingFile(file.path) &&
                contents.contains("Text(") &&
                contents.contains("mark.kind.semanticMeaning") &&
                contents.contains("mark.valueLabel")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.semantic-meaning-row",
                    path: file.path,
                    detail: "Root field can fall back to semantic meaning rows instead of rendered meaning."
                ))
            }
            if file.path.contains("GoalsObjectView"),
               contents.contains("LazyVGrid(") || contents.contains("RoundedRectangle(cornerRadius: theme.radius.lg")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.goals-dashboard-grid",
                    path: file.path,
                    detail: "Goals root cannot present Constellation Atlas as a dashboard grid/card wrapper."
                ))
            }
            if file.path.contains("YouRootSurface"),
               contents.contains("PersonalSystemCenterRootView") || contents.contains("source-settings") || contents.contains("receipts-history")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.you-governance-manual-root",
                    path: file.path,
                    detail: "You root cannot expose governance/source/receipt controls as first-viewport settings grammar."
                ))
            }
            if file.path.contains("CaptureAtmosphereComposer"),
               contents.contains("isRouteRevealVisible") || contents.contains("Keyboard dictation only")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.capture-routing-taxonomy",
                    path: file.path,
                    detail: "Capture primary composer cannot expose route-reveal or fake dictation taxonomy."
                ))
            }
            if file.path.contains("StageMotionState"),
               contents.contains("objectConsequence(renderState:")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "report-panel.motion-default-fixture-page",
                    path: file.path,
                    detail: "Motion cannot render fixture object-current state as production page anatomy."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func isRootLifeShapeRenderingFile(_ path: String) -> Bool {
        path.contains("DesignSystem/ProductObjects/LifeShape") ||
            path.contains("Surfaces/Time")
    }
}
