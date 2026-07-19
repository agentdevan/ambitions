import Foundation

enum LifeShapeMutationAudit {
    static let owner = "Quality/LifeShapeMutationAudit"
    static let rule = "Primary Time actions must produce runtime mutation, stage mutation, proof, announcement, and undo policy."

    static let requiredMutationTokens = [
        "RuntimeMutation",
        "StageMutation",
        "MutationProof",
        "MutationAccessibilityAnnouncement",
        "MutationUndo"
    ]

    static func auditPrimaryActionSource(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        let combined = files.map(\.contents).joined(separator: "\n")
        let path = files.map(\.path).joined(separator: ", ")
        let hasPrimaryTimeAction = combined.contains("handleReflowDecision") ||
            combined.contains("TimeReflowDecisionActionKind") ||
            combined.contains("interactionIntent")

        guard hasPrimaryTimeAction else { return LifeShapeAuditReport(findings: []) }

        let findings = requiredMutationTokens.compactMap { token -> LifeShapeAuditFinding? in
            guard combined.contains(token) == false else { return nil }
            return LifeShapeAuditFinding(
                id: "mutation.missing-\(token)",
                path: path,
                detail: "Primary Time action source is missing \(token)."
            )
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
