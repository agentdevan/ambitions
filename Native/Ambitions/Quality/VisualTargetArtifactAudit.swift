import Foundation

enum VisualTargetArtifactAudit {
    static let owner = "Quality/VisualTargetArtifactAudit"
    static let rule = "Visual work requires positive target artifacts."

    static func audit(paths: [String]) -> LifeShapeAuditReport {
        let required = [
            "docs/design/targets/time/lifeshape_field_visual_target.md",
            "docs/design/targets/time/lifeshape_field_acceptance_rubric.md",
            "docs/design/red_fixtures/time/current_failed_lifeshape_field.png",
            "docs/design/red_fixtures/time/current_failed_lifeshape_field.md"
        ]
        let existing = Set(paths)
        let findings = required
            .filter { existing.contains($0) == false }
            .map {
                LifeShapeAuditFinding(
                    id: "visual-target.missing-artifact",
                    path: $0,
                    detail: "Required visual target/red-fixture artifact is missing."
                )
            }
        return LifeShapeAuditReport(findings: findings)
    }
}
