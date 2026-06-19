import Foundation

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
