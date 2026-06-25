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
            if body.contains("LifeShapeBucketDetail"),
               body.contains("if selectedMarkID != nil") == false
            {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.detail-root-sibling",
                    path: file.path,
                    detail: "Bucket detail is reachable as root sibling anatomy before user selection proof."
                ))
            }
        }

        for file in files where file.path.contains("LifeShapeFieldVisualField") {
            if file.contents.contains("LifeShapeArcShape") ||
                file.contents.contains("orbitalRings") ||
                file.contents.contains("layerBandSpecs")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.radial-gauge-primary-object",
                    path: file.path,
                    detail: "Root Time must not use a giant radial gauge as the LifeShape primary object."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    static func auditRootObjectComposition(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings = auditTimeRootComposition(files).findings

        for file in files {
            let contents = file.contents
            if file.path.contains("GoalsObjectView") {
                if contents.contains("LazyVGrid(") || contents.contains("LifeAreaRegionButton") {
                    findings.append(LifeShapeAuditFinding(
                        id: "dominance.goals-card-grid-root",
                        path: file.path,
                        detail: "Goals root renders life areas as a grid/card surface instead of one Constellation Atlas object."
                    ))
                }
                if contents.contains("LifeAreaAtlasField(") == false {
                    findings.append(LifeShapeAuditFinding(
                        id: "dominance.goals-missing-atlas-field",
                        path: file.path,
                        detail: "Goals root must render the connected LifeAreaAtlasField object."
                    ))
                }
            }

            if file.path.contains("YouRootSurface") {
                if contents.contains("PersonalSystemCenterRootView") || contents.contains("YouPersonalSystemNavigation(") {
                    findings.append(LifeShapeAuditFinding(
                        id: "dominance.you-governance-root",
                        path: file.path,
                        detail: "You root renders a governance/control-center surface instead of User System Profile rows."
                    ))
                }
            }

            if file.path.contains("StageMotionCurrentView"),
               contents.contains("projection ??")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.motion-production-fixture-fallback",
                    path: file.path,
                    detail: "Stage Motion current view must require a real projection in production."
                ))
            }

            if file.path.contains("QuietCommandCaptureOverlay"),
               contents.contains("CaptureObjectView(") || contents.contains("saveCapture()")
            {
                findings.append(LifeShapeAuditFinding(
                    id: "dominance.capture-quick-sheet-composer",
                    path: file.path,
                    detail: "Quick Capture overlay must route into the activated composer instead of rendering or saving a second composer."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func ordered(_ contents: String, _ first: String, before second: String) -> Bool {
        guard let firstRange = contents.range(of: first),
              let secondRange = contents.range(of: second)
        else {
            return false
        }
        return firstRange.lowerBound < secondRange.lowerBound
    }
}
