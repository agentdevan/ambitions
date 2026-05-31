import Foundation

struct ShellPreviewMatrix: Sendable {
    static let canonicalTabs: [AppTab] = AppTab.allCases

    static let variants: [ShellPreviewVariant] = [
        ShellPreviewVariant(
            id: "standard-light",
            title: "Standard Light",
            colorAppearance: .light,
            dynamicTypeCategory: "UICTContentSizeCategoryM",
            reduceMotion: false,
            shellState: .steady
        ),
        ShellPreviewVariant(
            id: "standard-dark",
            title: "Standard Dark",
            colorAppearance: .dark,
            dynamicTypeCategory: "UICTContentSizeCategoryM",
            reduceMotion: false,
            shellState: .steady
        ),
        ShellPreviewVariant(
            id: "oled-dark",
            title: "OLED Dark",
            colorAppearance: .oled,
            dynamicTypeCategory: "UICTContentSizeCategoryM",
            reduceMotion: false,
            shellState: .continuityReceipt
        ),
        ShellPreviewVariant(
            id: "dynamic-type-accessibility",
            title: "Dynamic Type Accessibility",
            colorAppearance: .dark,
            dynamicTypeCategory: "UICTContentSizeCategoryAccessibilityXXXL",
            reduceMotion: false,
            shellState: .globalEntryOpen
        ),
        ShellPreviewVariant(
            id: "reduce-motion",
            title: "Reduce Motion",
            colorAppearance: .dark,
            dynamicTypeCategory: "UICTContentSizeCategoryM",
            reduceMotion: true,
            shellState: .externalRoute
        )
    ]

    static let screenshotHook = ShellScreenshotHook(
        uiTestName: "AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs",
        attachmentPrefix: "afri-005-shell",
        proofDirectory: "docs/proof/afri",
        resultBundleExpectation: "XCTest attachments in the focused UI test xcresult"
    )

    static var rows: [ShellPreviewMatrixRow] {
        canonicalTabs.flatMap { tab in
            variants.map { variant in
                ShellPreviewMatrixRow(tab: tab, variant: variant)
            }
        }
    }

    static func validationFailures() -> [String] {
        var failures: [String] = []
        let tabs = Set(canonicalTabs)
        if tabs != Set([.today, .goals, .capture, .time, .you]) {
            failures.append("canonical tabs must be exactly Today, Goals, Capture, Time, and You")
        }
        if !variants.contains(where: { $0.colorAppearance == .dark }) {
            failures.append("matrix must include dark appearance")
        }
        if !variants.contains(where: { $0.colorAppearance == .oled }) {
            failures.append("matrix must include OLED dark appearance")
        }
        if !variants.contains(where: { $0.dynamicTypeCategory.contains("Accessibility") }) {
            failures.append("matrix must include accessibility Dynamic Type")
        }
        if !variants.contains(where: \.reduceMotion) {
            failures.append("matrix must include Reduce Motion")
        }
        for state in ShellPreviewState.allCases where !variants.contains(where: { $0.shellState == state }) {
            failures.append("matrix must include shell state \(state.rawValue)")
        }
        if screenshotHook.uiTestName.isEmpty || screenshotHook.attachmentPrefix.isEmpty {
            failures.append("screenshot hook must name a UI test and attachment prefix")
        }
        return failures
    }
}

struct ShellPreviewMatrixRow: Identifiable, Sendable, Equatable {
    let tab: AppTab
    let variant: ShellPreviewVariant

    var id: String {
        "\(tab.rawValue)-\(variant.id)"
    }
}

struct ShellPreviewVariant: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let colorAppearance: ShellPreviewColorAppearance
    let dynamicTypeCategory: String
    let reduceMotion: Bool
    let shellState: ShellPreviewState
}

enum ShellPreviewColorAppearance: String, CaseIterable, Sendable {
    case light
    case dark
    case oled
}

enum ShellPreviewState: String, CaseIterable, Sendable {
    case steady
    case globalEntryOpen
    case continuityReceipt
    case externalRoute
}

struct ShellScreenshotHook: Sendable, Equatable {
    let uiTestName: String
    let attachmentPrefix: String
    let proofDirectory: String
    let resultBundleExpectation: String
}
