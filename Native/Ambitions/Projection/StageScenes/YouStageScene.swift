import Foundation

struct YouStageScene: Equatable, Sendable {
    let surface: StageMutationTargetSurface
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let profileSummary: String
    let trustSummary: String
    let permissionSummary: String
    let historySummary: String
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]

    init(dashboard: YouDashboard) {
        self.surface = .you
        self.productObject = YouLens.contract.primaryObjectTitle
        self.stageName = YouLens.contract.primaryObjectTitle
        self.firstViewportStructure = YouLens.contract.firstViewportContract
        self.profileSummary = dashboard.userSystemProfile.displayName
        self.trustSummary = dashboard.hero.dominantTruth
        self.permissionSummary = dashboard.notificationAuthorization.statusLabel
        self.historySummary = dashboard.userSystemProfileInspectionSummary
        self.sourceTrustLineOrder = ["profile", "permissions", "privacy", "history", "receipt"]
        self.accessibilityFallbacks = YouLens.contract.accessibilityContract
    }

    var satisfiesArchitectureTree: Bool {
        surface == .you &&
            productObject == "User System Profile" &&
            firstViewportStructure.localizedCaseInsensitiveContains("User System Profile") &&
            sourceTrustLineOrder == ["profile", "permissions", "privacy", "history", "receipt"] &&
            profileSummary.isEmpty == false &&
            trustSummary.isEmpty == false &&
            permissionSummary.isEmpty == false &&
            historySummary.isEmpty == false &&
            accessibilityFallbacks.isEmpty == false
    }
}
