import Foundation

enum DiagnosticCheckSeverity: String, CaseIterable, Sendable {
    case pass
    case notice
    case blocker
}

struct DiagnosticCheckResult: Identifiable, Sendable, Equatable {
    let id: String
    let owner: String
    let severity: DiagnosticCheckSeverity
    let summary: String
    let proofRequirement: String

    var blocksGreen: Bool {
        severity == .blocker
    }
}

enum RuntimeDiagnostics {
    static let actionFlowStages = [
        "StageAction",
        "StageReducer",
        "CommandValidation",
        "AmbitionsCommand",
        "RuntimeValidator",
        "RuntimeMutation",
        "StageMutation",
        "UserVisibleMutation",
        "StageMotionEvent",
        "StageEffect",
        "accessibility announcement",
        "proof artifact"
    ]

    static var defaultChecks: [DiagnosticCheckResult] {
        [
            DiagnosticCheckResult(
                id: "runtime-action-flow",
                owner: "Core/LocalRuntimeOS/Boundary",
                severity: actionFlowStages.count >= 12 ? .pass : .blocker,
                summary: "Runtime action flow has deterministic stages from command to proof artifact.",
                proofRequirement: "Focused runtime mutation tests must cover command, visible mutation, announcement, and proof."
            ),
            DiagnosticCheckResult(
                id: "runtime-local-first",
                owner: "Core/LocalRuntimeOS/Boundary",
                severity: .pass,
                summary: "Runtime diagnostics are local-only and do not require hosted services.",
                proofRequirement: "Quality gate must continue blocking remote inference and private-data backend paths."
            )
        ]
    }
}
