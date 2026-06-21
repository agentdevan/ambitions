import Foundation

enum RenderDiagnostics {
    static let requiredRoles = CanvasPrimitiveObjectRole.allCases

    static var defaultChecks: [DiagnosticCheckResult] {
        var checks = requiredRoles.map { role in
            let budget = RenderPerformanceProbe.budget(for: role)
            return DiagnosticCheckResult(
                id: "render-\(role.rawValue)",
                owner: "Rendering/CanvasPrimitives",
                severity: budget.requiresSemanticMirror && budget.permitsTimelineLoop == false ? .pass : .blocker,
                summary: "\(role.rawValue) render budget requires semantic mirror and no timeline loop.",
                proofRequirement: "Canvas primitive tests must prove budget, semantic mirror, and nonblank render plan behavior."
            )
        }

        checks.append(
            DiagnosticCheckResult(
                id: "render-real-device-proof",
                owner: "Quality/RealDeviceRenderChecklist",
                severity: RealDeviceRenderChecklist.validationFailures().isEmpty ? .notice : .blocker,
                summary: "Real-device render proof is tracked separately from simulator compile proof.",
                proofRequirement: "Do not claim device render proof until the real-device checklist artifacts are reviewed."
            )
        )
        return checks
    }
}
