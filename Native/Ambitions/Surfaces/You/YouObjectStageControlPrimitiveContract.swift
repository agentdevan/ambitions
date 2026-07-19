import Foundation

struct YouObjectStageControlPrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let screenshotIdentifier: String
    let sourceControlOrder: [String]
    let replacesFirstViewportStructures: [String]
    let exemptedSemanticControls: [String]
    let accessibilityFallbacks: [String]
    let reservesTabBarClearance: Bool
    let avoidsGenericProfileSettingsWall: Bool

    static let current = YouObjectStageControlPrimitiveContract(
        primitiveID: "personal-runtime-group",
        ownerSurface: "You",
        productObject: "User System Profile",
        stageName: "You settings",
        screenshotIdentifier: "YouObjectStageControl",
        sourceControlOrder: [
            "appearance",
            "capture",
            "life areas",
            "privacy",
            "local data",
            "sources",
            "receipts and history",
            "accessibility",
            "about"
        ],
        replacesFirstViewportStructures: [
            "detached profile hero",
            "generic settings wall",
            "operator-style root overview",
            "rounded per-row card stack",
            "social profile",
            "admin panel",
            "AI settings wall",
            "verbose documentation UI",
            "internal runtime console"
        ],
        exemptedSemanticControls: [
            "native grouped navigation rows",
            "semantic detail control groups",
            "permission and receipt drill-down controls"
        ],
        accessibilityFallbacks: [
            "VoiceOver reads object, group purpose, control title, status, and available route in grouped order.",
            "Dynamic Type shifts rows into stacked symbol, title, status, and detail content without restoring card containers.",
            "Reduce Motion relies on native disclosure and haptic route change state rather than motion-only meaning.",
            "Increase Contrast and Differentiate Without Color use line, symbol, and status text in addition to accent color."
        ],
        reservesTabBarClearance: true,
        avoidsGenericProfileSettingsWall: true
    )
}
