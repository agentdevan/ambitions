import Foundation

enum YouLens: SurfaceLens {
    static let contract = SurfaceLensContract(
        surface: .you,
        surfaceTitle: "You",
        primaryObjectTitle: "User System Profile",
        primaryActionTitle: "Review",
        runtimeInputs: [
            "local profile defaults",
            "permission status",
            "privacy posture",
            "receipt history",
            "appearance preferences",
            "account and reference-pack status"
        ],
        firstViewportContract: "User System Profile owns settings, trust, memory, permissions, appearance, account state, and local history as inspectable controls.",
        accessibilityContract: [
            "VoiceOver names User System Profile before trust, memory, permission, and appearance controls.",
            "Dynamic Type preserves settings and trust groups without hiding local status.",
            "Reduce Transparency keeps status labels readable without glass reliance."
        ],
        trustInspectionRequirements: ["source", "proof", "receipt", "privacy", "history"],
        failureStateRequirements: ["local-only state", "permission denied", "offline", "source unavailable", "recovery review"]
    )

    static func project(_ dashboard: YouDashboard) -> SurfaceLensReport {
        let scene = makeStageScene(for: dashboard)
        return SurfaceLensReport(
            contract: contract,
            primaryObjectSummary: scene.profileSummary,
            primaryActionSummary: dashboard.controlRoom.entries.first?.title ?? contract.primaryActionTitle,
            visibleStateSummary: scene.trustSummary,
            accessibilitySummary: scene.accessibilityFallbacks.joined(separator: " "),
            trustSummary: scene.historySummary,
            failureStateSummary: dashboard.notificationAuthorization.canRequestAuthorization
                ? "Permission review is available without changing the root surface."
                : "Permission and local-only status remain visible without silent mutation."
        )
    }

    static func makeStageScene(for dashboard: YouDashboard) -> YouStageScene {
        YouStageScene(dashboard: dashboard)
    }
}
