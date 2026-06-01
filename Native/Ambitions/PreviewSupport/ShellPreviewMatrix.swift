import Foundation

struct ShellPreviewMatrix: Sendable {
    static let canonicalTabs: [AppTab] = AppTab.allCases
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
        failures.append(contentsOf: visualDiffLab.validationFailures())
        failures.append(contentsOf: accessibilityCertificationProgram.validationFailures())
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

struct AFEP020VisualDiffLab: Sendable, Equatable {
    static let `default` = AFEP020VisualDiffLab(
        surfaceFixtures: [
            AFEP020VisualDiffSurfaceFixture(
                tab: .today,
                surfaceTitle: "Today",
                primaryObjectTitle: "Reality Meridian",
                fixtureKey: "today-reality-meridian",
                deterministicSeed: "afep020-surface-today",
                projectionInputName: "today_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "today-reality-meridian"
            ),
            AFEP020VisualDiffSurfaceFixture(
                tab: .goals,
                surfaceTitle: "Goals",
                primaryObjectTitle: "Constellation Atlas",
                fixtureKey: "goals-constellation-atlas",
                deterministicSeed: "afep020-surface-goals",
                projectionInputName: "goals_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "goals-constellation-atlas"
            ),
            AFEP020VisualDiffSurfaceFixture(
                tab: .capture,
                surfaceTitle: "Capture",
                primaryObjectTitle: "Atmosphere Composer",
                fixtureKey: "capture-atmosphere-composer",
                deterministicSeed: "afep020-surface-capture",
                projectionInputName: "capture_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "capture-atmosphere-composer"
            ),
            AFEP020VisualDiffSurfaceFixture(
                tab: .time,
                surfaceTitle: "Time",
                primaryObjectTitle: "LifeShape Field",
                fixtureKey: "time-lifeshape-field",
                deterministicSeed: "afep020-surface-time",
                projectionInputName: "time_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "time-lifeshape-field"
            ),
            AFEP020VisualDiffSurfaceFixture(
                tab: .you,
                surfaceTitle: "You",
                primaryObjectTitle: "User System Profile",
                fixtureKey: "you-user-system-profile",
                deterministicSeed: "afep020-surface-you",
                projectionInputName: "you_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "you-user-system-profile"
            )
        ],
        variantDimensions: [
            AFEP020VisualDiffVariantDimension(
                id: "baseline",
                title: "Baseline",
                scenario: .baseline,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-baseline",
                projectionInputName: "baseline_projection_input",
                artifactStem: "baseline"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "loading",
                title: "Loading",
                scenario: .loading,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-loading",
                projectionInputName: "loading_projection_input",
                artifactStem: "loading"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "empty",
                title: "Empty",
                scenario: .empty,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-empty",
                projectionInputName: "empty_projection_input",
                artifactStem: "empty"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "private-source-review",
                title: "Private Source Review",
                scenario: .privateSourceReview,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-private-source-review",
                projectionInputName: "private_source_review_projection_input",
                artifactStem: "private-source-review"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "blocked-recovery",
                title: "Blocked Recovery",
                scenario: .blockedRecovery,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-blocked-recovery",
                projectionInputName: "blocked_recovery_projection_input",
                artifactStem: "blocked-recovery"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "overloaded",
                title: "Overloaded",
                scenario: .overloaded,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-overloaded",
                projectionInputName: "overloaded_projection_input",
                artifactStem: "overloaded"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "reduce-motion",
                title: "Reduce Motion",
                scenario: .reduceMotion,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: true,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-reduce-motion",
                projectionInputName: "reduce_motion_projection_input",
                artifactStem: "reduce-motion"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "increase-contrast",
                title: "Increase Contrast",
                scenario: .increaseContrast,
                dynamicTypeCategory: "UICTContentSizeCategoryM",
                reduceMotion: false,
                increaseContrast: true,
                deterministicSeed: "afep020-variant-increase-contrast",
                projectionInputName: "increase_contrast_projection_input",
                artifactStem: "increase-contrast"
            ),
            AFEP020VisualDiffVariantDimension(
                id: "dynamic-type",
                title: "Dynamic Type",
                scenario: .dynamicType,
                dynamicTypeCategory: "UICTContentSizeCategoryAccessibilityXXXL",
                reduceMotion: false,
                increaseContrast: false,
                deterministicSeed: "afep020-variant-dynamic-type",
                projectionInputName: "dynamic_type_projection_input",
                artifactStem: "dynamic-type"
            )
        ],
        artifactBundle: AFEP020VisualDiffArtifactBundleMetadata(
            bundleName: "AFEP-020 Visual Diff Lab",
            bundleDirectory: "afep-020-visual-diff-lab",
            artifactPrefix: "afep020-visual-diff",
            reportFilename: "afep020-visual-diff-lab-report.md",
            fixtureMatrixFilename: "afep020-visual-diff-fixture-matrix.md",
            proofBoundaryFilename: "afep020-visual-proof-claim-boundary.md"
        ),
        proofBoundary: AFEP020VisualDiffProofBoundaryMetadata(
            renderedScreenshotProofClaim: false,
            accessibilityCertificationClaim: false,
            releaseReadinessClaim: false,
            deviceProofClaim: false,
            ciProofClaim: false,
            fallbackProofPath: ShellPreviewMatrix.visualDiffArtifactFallbackProofPath,
            rollbackNote: "Use the AFRI-005 shell screenshot proof path when a rendered screenshot baseline is needed."
        ),
        provenanceReferences: AFEP020VisualDiffProvenanceReferences(
            sourceRecordID: "SourceRecord.afep020.visual-diff-lab",
            receiptID: "Receipt.afep020.visual-diff-lab",
            replayTraceID: "ReplayTrace.afep020.visual-diff-lab",
            youInspectionLabel: "You / What Ambitions knows",
            inspectionSurfaceTitle: "What Ambitions knows",
            inspectionSummary: "You / What Ambitions knows can inspect the AFEP-020 visual diff lab scaffold without implying rendered proof."
        ),
        claimFlags: AFEP020VisualDiffLocalClaimFlags(
            renderedScreenshotProofClaimed: false,
            accessibilityClaimed: false,
            releaseClaimed: false,
            deviceClaimed: false,
            ciClaimed: false,
            productionReadyClaimed: false
        )
    )

    var rows: [AFEP020VisualDiffLabRow] {
        surfaceFixtures.flatMap { surface in
            variantDimensions.map { variant in
                AFEP020VisualDiffLabRow(
                    surface: surface,
                    variant: variant,
                    artifactName: artifactBundle.artifactStem(for: surface, variant: variant),
                    artifactPath: artifactBundle.artifactPath(for: surface, variant: variant)
                )
            }
        }
    }

    let surfaceFixtures: [AFEP020VisualDiffSurfaceFixture]
    let variantDimensions: [AFEP020VisualDiffVariantDimension]
    let artifactBundle: AFEP020VisualDiffArtifactBundleMetadata
    let proofBoundary: AFEP020VisualDiffProofBoundaryMetadata
    let provenanceReferences: AFEP020VisualDiffProvenanceReferences
    let claimFlags: AFEP020VisualDiffLocalClaimFlags

    func validationFailures() -> [String] {
        var failures: [String] = []

        if surfaceFixtures.map(\.tab) != AppTab.allCases {
            failures.append("visual diff lab surface fixtures must cover Today, Goals, Capture, Time, and You in order")
        }

        for tab in AppTab.allCases {
            guard let surface = surfaceFixtures.first(where: { $0.tab == tab }) else {
                failures.append("visual diff lab is missing a surface fixture for \(tab.title)")
                continue
            }
            if surface.primaryObjectTitle != tab.primaryObjectTitle {
                failures.append("\(tab.title) must own \(tab.primaryObjectTitle), not \(surface.primaryObjectTitle)")
            }
            if surface.inspectionLabel != provenanceReferences.youInspectionLabel {
                failures.append("\(tab.title) must preserve the You inspection label")
            }
            if surface.deterministicSeed.isPathSafeComponent == false || surface.projectionInputName.isPathSafeComponent == false || surface.artifactStem.isPathSafeComponent == false {
                failures.append("\(tab.title) fixture metadata must stay path-safe")
            }
        }

        let requiredScenarios: Set<AFEP020VisualDiffScenario> = [
            .baseline,
            .loading,
            .empty,
            .privateSourceReview,
            .blockedRecovery,
            .overloaded,
            .reduceMotion,
            .increaseContrast,
            .dynamicType
        ]
        let coveredScenarios = Set(variantDimensions.map(\.scenario))
        if coveredScenarios != requiredScenarios {
            failures.append("visual diff lab must cover baseline, loading, empty, private/source-review, blocked/recovery, overloaded, Reduce Motion, Increase Contrast, and Dynamic Type")
        }

        if !variantDimensions.contains(where: { $0.reduceMotion }) {
            failures.append("visual diff lab must include Reduce Motion")
        }
        if !variantDimensions.contains(where: { $0.increaseContrast }) {
            failures.append("visual diff lab must include Increase Contrast")
        }
        if !variantDimensions.contains(where: { $0.dynamicTypeCategory.contains("Accessibility") }) {
            failures.append("visual diff lab must include Dynamic Type")
        }
        if variantDimensions.contains(where: { $0.deterministicSeed.isPathSafeComponent == false || $0.projectionInputName.isPathSafeComponent == false || $0.artifactStem.isPathSafeComponent == false }) {
            failures.append("visual diff lab variant metadata must stay path-safe")
        }

        if rows.count != surfaceFixtures.count * variantDimensions.count {
            failures.append("visual diff lab row count must be deterministic across every surface and variant")
        }
        if Set(rows.map(\.artifactName)).count != rows.count {
            failures.append("visual diff lab artifact names must be deterministic and unique")
        }
        if rows.contains(where: { $0.artifactPath.isPathSafeComponent == false }) {
            failures.append("visual diff lab artifact paths must stay path-safe")
        }

        if artifactBundle.bundleDirectory.isPathSafeComponent == false || artifactBundle.artifactPrefix.isPathSafeComponent == false {
            failures.append("visual diff lab artifact bundle metadata must stay path-safe")
        }
        if artifactBundle.reportFilename != "afep020-visual-diff-lab-report.md" || artifactBundle.fixtureMatrixFilename != "afep020-visual-diff-fixture-matrix.md" || artifactBundle.proofBoundaryFilename != "afep020-visual-proof-claim-boundary.md" {
            failures.append("visual diff lab report filenames must stay deterministic")
        }
        if proofBoundary.renderedScreenshotProofClaim || proofBoundary.accessibilityCertificationClaim || proofBoundary.releaseReadinessClaim || proofBoundary.deviceProofClaim || proofBoundary.ciProofClaim {
            failures.append("visual diff lab must not claim rendered screenshot, accessibility, release, device, or CI proof")
        }
        if proofBoundary.fallbackProofPath != ShellPreviewMatrix.visualDiffArtifactFallbackProofPath {
            failures.append("visual diff lab must keep the AFRI-005 fallback proof path explicit")
        }
        if claimFlags.renderedScreenshotProofClaimed || claimFlags.accessibilityClaimed || claimFlags.releaseClaimed || claimFlags.deviceClaimed || claimFlags.ciClaimed || claimFlags.productionReadyClaimed {
            failures.append("visual diff lab claim flags must remain local-only and false")
        }
        if provenanceReferences.sourceRecordID.isPathSafeComponent == false || provenanceReferences.receiptID.isPathSafeComponent == false || provenanceReferences.replayTraceID.isPathSafeComponent == false {
            failures.append("visual diff lab provenance identifiers must stay path-safe")
        }
        if provenanceReferences.sourceRecordID.contains("SourceRecord") == false || provenanceReferences.receiptID.contains("Receipt") == false || provenanceReferences.replayTraceID.contains("ReplayTrace") == false {
            failures.append("visual diff lab provenance identifiers must preserve SourceRecord, Receipt, and ReplayTrace references")
        }
        if provenanceReferences.youInspectionLabel != "You / What Ambitions knows" || provenanceReferences.inspectionSurfaceTitle != "What Ambitions knows" {
            failures.append("visual diff lab must preserve the You inspection surface labels")
        }
        if provenanceReferences.inspectionSummary.contains("rendered proof") == false {
            failures.append("visual diff lab inspection summary must state that rendered proof is not implied")
        }

        return failures
    }
}

struct AFEP020VisualDiffLabRow: Identifiable, Sendable, Equatable {
    let surface: AFEP020VisualDiffSurfaceFixture
    let variant: AFEP020VisualDiffVariantDimension
    let artifactName: String
    let artifactPath: String

    var id: String {
        "\(surface.tab.rawValue)-\(variant.id)"
    }
}

struct AFEP020VisualDiffSurfaceFixture: Identifiable, Sendable, Equatable {
    let tab: AppTab
    let surfaceTitle: String
    let primaryObjectTitle: String
    let fixtureKey: String
    let deterministicSeed: String
    let projectionInputName: String
    let inspectionLabel: String
    let artifactStem: String

    var id: String {
        fixtureKey
    }
}

struct AFEP020VisualDiffVariantDimension: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let scenario: AFEP020VisualDiffScenario
    let dynamicTypeCategory: String
    let reduceMotion: Bool
    let increaseContrast: Bool
    let deterministicSeed: String
    let projectionInputName: String
    let artifactStem: String
}

enum AFEP020VisualDiffScenario: String, CaseIterable, Sendable {
    case baseline
    case loading
    case empty
    case privateSourceReview = "private_source_review"
    case blockedRecovery = "blocked_recovery"
    case overloaded
    case reduceMotion = "reduce_motion"
    case increaseContrast = "increase_contrast"
    case dynamicType = "dynamic_type"

    var title: String {
        switch self {
        case .baseline:
            "Baseline"
        case .loading:
            "Loading"
        case .empty:
            "Empty"
        case .privateSourceReview:
            "Private Source Review"
        case .blockedRecovery:
            "Blocked Recovery"
        case .overloaded:
            "Overloaded"
        case .reduceMotion:
            "Reduce Motion"
        case .increaseContrast:
            "Increase Contrast"
        case .dynamicType:
            "Dynamic Type"
        }
    }
}

struct AFEP020VisualDiffArtifactBundleMetadata: Sendable, Equatable {
    let bundleName: String
    let bundleDirectory: String
    let artifactPrefix: String
    let reportFilename: String
    let fixtureMatrixFilename: String
    let proofBoundaryFilename: String

    func artifactStem(for surface: AFEP020VisualDiffSurfaceFixture, variant: AFEP020VisualDiffVariantDimension) -> String {
        "\(artifactPrefix)/\(surface.artifactStem)-\(variant.artifactStem)"
    }

    func artifactPath(for surface: AFEP020VisualDiffSurfaceFixture, variant: AFEP020VisualDiffVariantDimension) -> String {
        "\(bundleDirectory)/\(artifactStem(for: surface, variant: variant)).png"
    }
}

struct AFEP020VisualDiffProofBoundaryMetadata: Sendable, Equatable {
    let renderedScreenshotProofClaim: Bool
    let accessibilityCertificationClaim: Bool
    let releaseReadinessClaim: Bool
    let deviceProofClaim: Bool
    let ciProofClaim: Bool
    let fallbackProofPath: String
    let rollbackNote: String
}

struct AFEP020VisualDiffProvenanceReferences: Sendable, Equatable {
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let youInspectionLabel: String
    let inspectionSurfaceTitle: String
    let inspectionSummary: String
}

struct AFEP020VisualDiffLocalClaimFlags: Sendable, Equatable {
    let renderedScreenshotProofClaimed: Bool
    let accessibilityClaimed: Bool
    let releaseClaimed: Bool
    let deviceClaimed: Bool
    let ciClaimed: Bool
    let productionReadyClaimed: Bool
}

struct AFEP021AccessibilityCertificationProgram: Sendable, Equatable {
    static let `default` = AFEP021AccessibilityCertificationProgram(
        surfaceFixtures: [
            AFEP021AccessibilitySurfaceFixture(
                tab: .today,
                surfaceTitle: "Today",
                primaryObjectTitle: "Reality Meridian",
                fixtureState: "today-reality-meridian",
                deterministicSeed: "afep021-surface-today",
                projectionInputName: "today_accessibility_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "today-reality-meridian"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .goals,
                surfaceTitle: "Goals",
                primaryObjectTitle: "Constellation Atlas",
                fixtureState: "goals-constellation-atlas",
                deterministicSeed: "afep021-surface-goals",
                projectionInputName: "goals_accessibility_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "goals-constellation-atlas"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .capture,
                surfaceTitle: "Capture",
                primaryObjectTitle: "Atmosphere Composer",
                fixtureState: "capture-atmosphere-composer",
                deterministicSeed: "afep021-surface-capture",
                projectionInputName: "capture_accessibility_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "capture-atmosphere-composer"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .time,
                surfaceTitle: "Time",
                primaryObjectTitle: "LifeShape Field",
                fixtureState: "time-lifeshape-field",
                deterministicSeed: "afep021-surface-time",
                projectionInputName: "time_accessibility_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "time-lifeshape-field"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .you,
                surfaceTitle: "You",
                primaryObjectTitle: "User System Profile",
                fixtureState: "you-user-system-profile",
                deterministicSeed: "afep021-surface-you",
                projectionInputName: "you_accessibility_projection_input",
                inspectionLabel: "You / What Ambitions knows",
                artifactStem: "you-user-system-profile"
            )
        ],
        gateMatrix: [
            AFEP021AccessibilityGate(
                kind: .voiceOver,
                title: "VoiceOver",
                requirement: "Object summaries, labels, hints, values, and reading order must support VoiceOver without implying public certification.",
                evidenceKind: .automatedTest,
                owner: "Accessibility",
                followUpProofRequirement: "Manual VoiceOver traversal remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .dynamicType,
                title: "Dynamic Type",
                requirement: "Primary object hierarchy and actions must remain readable at accessibility text sizes.",
                evidenceKind: .automatedTest,
                owner: "Accessibility",
                followUpProofRequirement: "Device-band Dynamic Type screenshot review remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .reduceMotion,
                title: "Reduce Motion",
                requirement: "State changes and route transitions must have a static equivalent when motion is reduced.",
                evidenceKind: .sourceBackedSupport,
                owner: "Accessibility",
                followUpProofRequirement: "A Reduce Motion walkthrough remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .increaseContrast,
                title: "Increase Contrast",
                requirement: "Boundaries and state must survive contrast increases without relying on ambient color or material.",
                evidenceKind: .sourceBackedSupport,
                owner: "Accessibility",
                followUpProofRequirement: "Measured contrast review remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .tapTargets,
                title: "Tap Targets",
                requirement: "Primary actions must remain comfortably hittable and never require precision taps.",
                evidenceKind: .automatedTest,
                owner: "Accessibility",
                followUpProofRequirement: "Motor and tap-target review on device remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .semanticGrouping,
                title: "Semantic Grouping",
                requirement: "Information groups must remain meaningful to VoiceOver, scanning, and reduced cognitive load.",
                evidenceKind: .automatedTest,
                owner: "Accessibility",
                followUpProofRequirement: "Manual semantic grouping review remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .nonColorMeaning,
                title: "Non-color Meaning",
                requirement: "State meaning must survive without tint by using text, shape, position, or iconography.",
                evidenceKind: .sourceBackedSupport,
                owner: "Accessibility",
                followUpProofRequirement: "Rendered state review remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .motionIndependentMeaning,
                title: "Motion-independent Meaning",
                requirement: "Motion must never be the only carrier of relationship, status, or hierarchy meaning.",
                evidenceKind: .sourceBackedSupport,
                owner: "Accessibility",
                followUpProofRequirement: "Reduce-motion visual review remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .privacyRedactionReadability,
                title: "Privacy / Redaction Readability",
                requirement: "Redacted or private content must remain legible as privacy-safe state, not blank ambiguity.",
                evidenceKind: .automatedTest,
                owner: "Privacy",
                followUpProofRequirement: "Device review of redaction and privacy states remains required for public accessibility claims.",
                publicClaimBlocked: true
            ),
            AFEP021AccessibilityGate(
                kind: .cognitiveLoad,
                title: "Cognitive Load",
                requirement: "Each primary surface must preserve one-primary-object discipline and avoid cluttering the decision path.",
                evidenceKind: .sourceBackedSupport,
                owner: "Product",
                followUpProofRequirement: "Manual readability review remains required for public accessibility claims.",
                publicClaimBlocked: true
            )
        ],
        evidencePackets: [
            AFEP021AccessibilityEvidencePacket(
                id: "today-source-backed",
                command: "make xcode-focused-test BATCH=AFEP-021 TEST=AmbitionsTests/ShellPreviewMatrixTests",
                artifactPath: "docs/audits/afep021-accessibility-certification-program-report.md",
                surface: "Today",
                fixtureState: "today-reality-meridian",
                result: .pass,
                knownLimitation: "Manual VoiceOver and device-band proof remain required before any public accessibility claim.",
                owner: "Today",
                followUpProofRequirement: "Manual VoiceOver traversal, Dynamic Type screenshots, Reduce Motion, and device proof remain required.",
                proofKind: .sourceBackedSupport
            ),
            AFEP021AccessibilityEvidencePacket(
                id: "goals-automated-test",
                command: "make xcode-focused-test BATCH=AFEP-021 TEST=AmbitionsTests/AccessibilityNutritionChecklistTests",
                artifactPath: "docs/audits/afep021-accessibility-gate-matrix.md",
                surface: "Goals",
                fixtureState: "goals-constellation-atlas",
                result: .pass,
                knownLimitation: "Automated coverage does not prove a public accessibility certification claim.",
                owner: "Goals",
                followUpProofRequirement: "Manual semantic-grouping and device-band proof remain required.",
                proofKind: .automatedTest
            ),
            AFEP021AccessibilityEvidencePacket(
                id: "capture-manual-voiceover-pending",
                command: "manual VoiceOver traversal",
                artifactPath: "docs/audits/afep021-accessibility-proof-claim-boundary.md",
                surface: "Capture",
                fixtureState: "capture-atmosphere-composer",
                result: .skipped,
                knownLimitation: "Manual VoiceOver evidence is not recorded in this batch.",
                owner: "Capture",
                followUpProofRequirement: "Manual VoiceOver traversal must be collected before public claim approval.",
                proofKind: .manualVoiceOver
            ),
            AFEP021AccessibilityEvidencePacket(
                id: "time-rendered-proof-pending",
                command: "xcode screenshot export review",
                artifactPath: "docs/audits/afep021-accessibility-rollback-plan.md",
                surface: "Time",
                fixtureState: "time-lifeshape-field",
                result: .skipped,
                knownLimitation: "Rendered screenshot review is not collected as proof in this batch.",
                owner: "Time",
                followUpProofRequirement: "Rendered and device-band proof remain required for public accessibility claims.",
                proofKind: .renderedScreenshot
            ),
            AFEP021AccessibilityEvidencePacket(
                id: "you-public-claim-approval-pending",
                command: "public accessibility claim review",
                artifactPath: "docs/proof/afri/afri-034-accessibility-proof-matrix.md",
                surface: "You",
                fixtureState: "you-user-system-profile",
                result: .skipped,
                knownLimitation: "Public accessibility claim approval is explicitly blocked in this scaffold.",
                owner: "You",
                followUpProofRequirement: "Public claim approval remains blocked until manual/device proof exists.",
                proofKind: .publicAccessibilityClaimApproval
            )
        ],
        proofBoundary: AFEP021AccessibilityProofBoundaryMetadata(
            sourceBackedSupportClaimAllowed: true,
            automatedTestClaimAllowed: true,
            renderedScreenshotClaimAllowed: false,
            manualVoiceOverClaimAllowed: false,
            dynamicTypeScreenshotClaimAllowed: false,
            reduceMotionWalkthroughClaimAllowed: false,
            increaseContrastMeasuredReviewClaimAllowed: false,
            tapTargetMotorReviewClaimAllowed: false,
            physicalDeviceProofClaimAllowed: false,
            publicAccessibilityCertificationClaimAllowed: false,
            afri034RollbackBaselinePath: "docs/proof/afri/afri-034-accessibility-proof-matrix.md",
            afri005ShellScreenshotProofPath: "docs/proof/afri/afri-005-shell-preview-screenshot-proof.md",
            blockedProofKinds: [
                .renderedScreenshot,
                .manualVoiceOver,
                .dynamicTypeScreenshotReview,
                .reduceMotionWalkthrough,
                .increaseContrastMeasuredReview,
                .tapTargetMotorReview,
                .physicalDeviceProof,
                .publicAccessibilityClaimApproval
            ],
            rollbackNote: "Use AFRI-034 for the accessibility proof baseline and AFRI-005 for the shell screenshot rollback path."
        ),
        provenanceReferences: AFEP021AccessibilityProvenanceReferences(
            sourceRecordID: "SourceRecord.afep021.accessibility-certification-program",
            receiptID: "Receipt.afep021.accessibility-certification-program",
            replayTraceID: "ReplayTrace.afep021.accessibility-certification-program",
            youInspectionLabel: "You / What Ambitions knows",
            inspectionSurfaceTitle: "What Ambitions knows",
            inspectionSummary: "You / What Ambitions knows can inspect the AFEP-021 accessibility certification scaffold without implying public certification."
        ),
        claimFlags: AFEP021AccessibilityLocalClaimFlags(
            sourceBackedSupportClaimed: false,
            automatedTestClaimed: false,
            renderedScreenshotClaimed: false,
            manualVoiceOverClaimed: false,
            dynamicTypeScreenshotClaimed: false,
            reduceMotionWalkthroughClaimed: false,
            increaseContrastClaimed: false,
            tapTargetMotorClaimed: false,
            physicalDeviceClaimed: false,
            publicAccessibilityCertificationClaimed: false,
            releaseClaimed: false
        )
    )

    let surfaceFixtures: [AFEP021AccessibilitySurfaceFixture]
    let gateMatrix: [AFEP021AccessibilityGate]
    let evidencePackets: [AFEP021AccessibilityEvidencePacket]
    let proofBoundary: AFEP021AccessibilityProofBoundaryMetadata
    let provenanceReferences: AFEP021AccessibilityProvenanceReferences
    let claimFlags: AFEP021AccessibilityLocalClaimFlags

    var rows: [AFEP021AccessibilityCertificationRow] {
        surfaceFixtures.flatMap { surface in
            gateMatrix.map { gate in
                AFEP021AccessibilityCertificationRow(
                    surface: surface,
                    gate: gate,
                    evidencePacket: evidencePackets.first { $0.surface == surface.surfaceTitle }
                )
            }
        }
    }

    func validationFailures() -> [String] {
        var failures: [String] = []

        if surfaceFixtures.map(\.tab) != AppTab.allCases {
            failures.append("accessibility certification surfaces must cover Today, Goals, Capture, Time, and You in order")
        }

        for tab in AppTab.allCases {
            guard let surface = surfaceFixtures.first(where: { $0.tab == tab }) else {
                failures.append("accessibility certification program is missing a surface fixture for \(tab.title)")
                continue
            }
            if surface.surfaceTitle != tab.title {
                failures.append("\(tab.title) must preserve its surface title")
            }
            if surface.primaryObjectTitle != tab.primaryObjectTitle {
                failures.append("\(tab.title) must own \(tab.primaryObjectTitle), not \(surface.primaryObjectTitle)")
            }
            if surface.inspectionLabel != provenanceReferences.youInspectionLabel {
                failures.append("\(tab.title) must preserve the You inspection label")
            }
            if surface.deterministicSeed.isPathSafeComponent == false || surface.projectionInputName.isPathSafeComponent == false || surface.artifactStem.isPathSafeComponent == false || surface.fixtureState.isPathSafeComponent == false {
                failures.append("\(tab.title) accessibility certification fixture metadata must stay path-safe")
            }
        }

        let expectedGateKinds: Set<AFEP021AccessibilityGateKind> = Set(AFEP021AccessibilityGateKind.allCases)
        if Set(gateMatrix.map(\.kind)) != expectedGateKinds {
            failures.append("accessibility certification gate matrix must cover VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, tap targets, semantic grouping, non-color meaning, motion-independent meaning, privacy/redaction readability, and cognitive load")
        }

        if gateMatrix.contains(where: { $0.publicClaimBlocked == false }) {
            failures.append("accessibility certification gates must keep public claims blocked")
        }

        if evidencePackets.count != surfaceFixtures.count {
            failures.append("accessibility certification evidence packets must cover every canonical surface")
        }
        for packet in evidencePackets {
            if packet.command.isEmpty || packet.artifactPath.isEmpty || packet.surface.isEmpty || packet.fixtureState.isEmpty || packet.knownLimitation.isEmpty || packet.owner.isEmpty || packet.followUpProofRequirement.isEmpty {
                failures.append("accessibility certification evidence packets must keep command, artifact path, surface, fixture state, limitation, owner, and follow-up fields populated")
            }
            if packet.artifactPath.isPathSafeComponent == false {
                failures.append("accessibility certification evidence packet artifact paths must stay path-safe")
            }
            if packet.result == .fail {
                failures.append("accessibility certification evidence packets must not claim a failure result for the scaffold")
            }
        }

        if proofBoundary.sourceBackedSupportClaimAllowed == false || proofBoundary.automatedTestClaimAllowed == false {
            failures.append("accessibility certification proof boundary must allow source-backed support and automated-test evidence")
        }
        if proofBoundary.renderedScreenshotClaimAllowed || proofBoundary.manualVoiceOverClaimAllowed || proofBoundary.dynamicTypeScreenshotClaimAllowed || proofBoundary.reduceMotionWalkthroughClaimAllowed || proofBoundary.increaseContrastMeasuredReviewClaimAllowed || proofBoundary.tapTargetMotorReviewClaimAllowed || proofBoundary.physicalDeviceProofClaimAllowed || proofBoundary.publicAccessibilityCertificationClaimAllowed {
            failures.append("accessibility certification proof boundary must block rendered, manual, device, and public certification claims")
        }
        if Set(proofBoundary.blockedProofKinds) != Set([
            .renderedScreenshot,
            .manualVoiceOver,
            .dynamicTypeScreenshotReview,
            .reduceMotionWalkthrough,
            .increaseContrastMeasuredReview,
            .tapTargetMotorReview,
            .physicalDeviceProof,
            .publicAccessibilityClaimApproval
        ]) {
            failures.append("accessibility certification proof boundary must enumerate the blocked rendered, manual, device, and public claim proof kinds")
        }
        if proofBoundary.afri034RollbackBaselinePath != "docs/proof/afri/afri-034-accessibility-proof-matrix.md" || proofBoundary.afri005ShellScreenshotProofPath != "docs/proof/afri/afri-005-shell-preview-screenshot-proof.md" {
            failures.append("accessibility certification proof boundary must keep the AFRI-034 and AFRI-005 rollback paths explicit")
        }
        if proofBoundary.rollbackNote.contains("AFRI-034") == false || proofBoundary.rollbackNote.contains("AFRI-005") == false {
            failures.append("accessibility certification rollback note must mention AFRI-034 and AFRI-005")
        }

        if provenanceReferences.sourceRecordID.isPathSafeComponent == false || provenanceReferences.receiptID.isPathSafeComponent == false || provenanceReferences.replayTraceID.isPathSafeComponent == false {
            failures.append("accessibility certification provenance identifiers must stay path-safe")
        }
        if provenanceReferences.sourceRecordID.contains("SourceRecord") == false || provenanceReferences.receiptID.contains("Receipt") == false || provenanceReferences.replayTraceID.contains("ReplayTrace") == false {
            failures.append("accessibility certification provenance identifiers must preserve SourceRecord, Receipt, and ReplayTrace references")
        }
        if provenanceReferences.youInspectionLabel != "You / What Ambitions knows" || provenanceReferences.inspectionSurfaceTitle != "What Ambitions knows" {
            failures.append("accessibility certification must preserve the You inspection surface labels")
        }
        if provenanceReferences.inspectionSummary.contains("public certification") == false {
            failures.append("accessibility certification inspection summary must state that public certification is not implied")
        }

        if claimFlags.sourceBackedSupportClaimed || claimFlags.automatedTestClaimed || claimFlags.renderedScreenshotClaimed || claimFlags.manualVoiceOverClaimed || claimFlags.dynamicTypeScreenshotClaimed || claimFlags.reduceMotionWalkthroughClaimed || claimFlags.increaseContrastClaimed || claimFlags.tapTargetMotorClaimed || claimFlags.physicalDeviceClaimed || claimFlags.publicAccessibilityCertificationClaimed || claimFlags.releaseClaimed {
            failures.append("accessibility certification local claim flags must remain false")
        }

        return failures
    }
}

struct AFEP021AccessibilityCertificationRow: Identifiable, Sendable, Equatable {
    let surface: AFEP021AccessibilitySurfaceFixture
    let gate: AFEP021AccessibilityGate
    let evidencePacket: AFEP021AccessibilityEvidencePacket?

    var id: String {
        "\(surface.tab.rawValue)-\(gate.kind.rawValue)"
    }
}

struct AFEP021AccessibilitySurfaceFixture: Identifiable, Sendable, Equatable {
    let tab: AppTab
    let surfaceTitle: String
    let primaryObjectTitle: String
    let fixtureState: String
    let deterministicSeed: String
    let projectionInputName: String
    let inspectionLabel: String
    let artifactStem: String

    var id: String {
        fixtureState
    }
}

struct AFEP021AccessibilityGate: Identifiable, Sendable, Equatable {
    let kind: AFEP021AccessibilityGateKind
    let title: String
    let requirement: String
    let evidenceKind: AFEP021AccessibilityProofKind
    let owner: String
    let followUpProofRequirement: String
    let publicClaimBlocked: Bool

    var id: String {
        kind.rawValue
    }
}

enum AFEP021AccessibilityGateKind: String, CaseIterable, Sendable {
    case voiceOver
    case dynamicType
    case reduceMotion
    case increaseContrast
    case tapTargets
    case semanticGrouping
    case nonColorMeaning
    case motionIndependentMeaning
    case privacyRedactionReadability
    case cognitiveLoad
}

enum AFEP021AccessibilityProofKind: String, CaseIterable, Sendable {
    case sourceBackedSupport
    case automatedTest
    case renderedScreenshot
    case manualVoiceOver
    case dynamicTypeScreenshotReview
    case reduceMotionWalkthrough
    case increaseContrastMeasuredReview
    case tapTargetMotorReview
    case physicalDeviceProof
    case publicAccessibilityClaimApproval
}

enum AFEP021AccessibilityEvidenceState: String, CaseIterable, Sendable {
    case pass
    case fail
    case skipped
}

struct AFEP021AccessibilityEvidencePacket: Identifiable, Sendable, Equatable {
    let id: String
    let command: String
    let artifactPath: String
    let surface: String
    let fixtureState: String
    let result: AFEP021AccessibilityEvidenceState
    let knownLimitation: String
    let owner: String
    let followUpProofRequirement: String
    let proofKind: AFEP021AccessibilityProofKind
}

struct AFEP021AccessibilityProofBoundaryMetadata: Sendable, Equatable {
    let sourceBackedSupportClaimAllowed: Bool
    let automatedTestClaimAllowed: Bool
    let renderedScreenshotClaimAllowed: Bool
    let manualVoiceOverClaimAllowed: Bool
    let dynamicTypeScreenshotClaimAllowed: Bool
    let reduceMotionWalkthroughClaimAllowed: Bool
    let increaseContrastMeasuredReviewClaimAllowed: Bool
    let tapTargetMotorReviewClaimAllowed: Bool
    let physicalDeviceProofClaimAllowed: Bool
    let publicAccessibilityCertificationClaimAllowed: Bool
    let afri034RollbackBaselinePath: String
    let afri005ShellScreenshotProofPath: String
    let blockedProofKinds: [AFEP021AccessibilityProofKind]
    let rollbackNote: String
}

struct AFEP021AccessibilityProvenanceReferences: Sendable, Equatable {
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let youInspectionLabel: String
    let inspectionSurfaceTitle: String
    let inspectionSummary: String
}

struct AFEP021AccessibilityLocalClaimFlags: Sendable, Equatable {
    let sourceBackedSupportClaimed: Bool
    let automatedTestClaimed: Bool
    let renderedScreenshotClaimed: Bool
    let manualVoiceOverClaimed: Bool
    let dynamicTypeScreenshotClaimed: Bool
    let reduceMotionWalkthroughClaimed: Bool
    let increaseContrastClaimed: Bool
    let tapTargetMotorClaimed: Bool
    let physicalDeviceClaimed: Bool
    let publicAccessibilityCertificationClaimed: Bool
    let releaseClaimed: Bool
}

private extension String {
    var isPathSafeComponent: Bool {
        guard isEmpty == false else {
            return false
        }
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._/")
        return unicodeScalars.allSatisfy { allowedCharacters.contains($0) } && contains("..") == false && contains("//") == false
    }
}
