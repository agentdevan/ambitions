import Foundation

enum StageDiagnostics {
    static let rootSurfaces: [AmbitionsSurface] = [.today, .goals, .time, .you]

    static var defaultChecks: [DiagnosticCheckResult] {
        [
            DiagnosticCheckResult(
                id: "stage-root-surfaces",
                owner: "Stage",
                severity: Set(rootSurfaces) == Set(AmbitionsSurface.allCases) ? .pass : .blocker,
                summary: "Stage root surfaces are Today, Goals, Time, and You.",
                proofRequirement: "Architecture inventory and top-level surface tests must keep Capture and Motion out of root routes."
            ),
            DiagnosticCheckResult(
                id: "stage-chrome-discipline",
                owner: "Stage/Chrome",
                severity: .pass,
                summary: ShellChromeAudit.rule,
                proofRequirement: "Focused shell tests must prove dock, overlay, route restoration, and focus restoration behavior."
            )
        ]
    }
}
