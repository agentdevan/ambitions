import Foundation

enum LifeShapeTodayCouplingAudit {
    static let owner = "Quality/LifeShapeTodayCouplingAudit"
    static let rule = "Time mutations must prove affected Today projection changes."

    static func auditMutationCouplingSource(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        let combined = files.map(\.contents).joined(separator: "\n")
        let path = files.map(\.path).joined(separator: ", ")
        let hasTimeMutationAction = combined.contains("TimeReflowDecisionActionKind") ||
            combined.contains("RuntimeMutation") ||
            combined.contains("StageMutation")

        guard hasTimeMutationAction else { return LifeShapeAuditReport(findings: []) }

        let provesTodayCoupling = combined.contains("StageMutationTargetSurface.today") ||
            combined.contains("affectedToday") ||
            combined.contains("Today projection")

        guard provesTodayCoupling == false else { return LifeShapeAuditReport(findings: []) }

        return LifeShapeAuditReport(findings: [
            LifeShapeAuditFinding(
                id: "today-coupling.missing-affected-today-proof",
                path: path,
                detail: "Time mutation source must prove affected Today projection changes."
            )
        ])
    }

    static func auditFocusedTests(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        let combined = files.map(\.contents).joined(separator: "\n")
        let hasTimeMutationTest = combined.contains("Time") && combined.contains("Mutation")
        let hasTodayProjectionAssertion = combined.contains("Today projection") ||
            combined.contains("affectedToday") ||
            combined.contains("StageMutationTargetSurface.today")

        guard hasTimeMutationTest && hasTodayProjectionAssertion == false else {
            return LifeShapeAuditReport(findings: [])
        }

        return LifeShapeAuditReport(findings: [
            LifeShapeAuditFinding(
                id: "today-coupling.missing-focused-test",
                path: files.map(\.path).joined(separator: ", "),
                detail: "Focused Time mutation tests must assert affected Today projection changes."
            )
        ])
    }
}
