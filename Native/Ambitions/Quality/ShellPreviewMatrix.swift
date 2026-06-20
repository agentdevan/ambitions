import Foundation

struct ShellPreviewMatrix: Sendable {
    static let canonicalTabs: [AmbitionsSurface] = AmbitionsSurface.allCases
    static let visualDiffLab = AFEP020VisualDiffLab.default
    static let accessibilityCertificationProgram = AFEP021AccessibilityCertificationProgram.default

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

    static let visualDiffArtifactFallbackProofPath = "docs/proof/afri/afri-005-shell-preview-screenshot-proof.md"

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
        if tabs != Set(AmbitionsSurface.allCases) {
            failures.append("canonical tabs must match active top-level tabs")
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
        failures.append(contentsOf: visualDiffLab.validationFailures())
        failures.append(contentsOf: accessibilityCertificationProgram.validationFailures())
        return failures
    }
}

struct ShellPreviewMatrixRow: Identifiable, Sendable, Equatable {
    let tab: AmbitionsSurface
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
