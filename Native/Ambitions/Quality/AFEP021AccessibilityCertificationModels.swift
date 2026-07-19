import Foundation

struct AFEP021AccessibilityCertificationRow: Identifiable, Sendable, Equatable {
    let surface: AFEP021AccessibilitySurfaceFixture
    let gate: AFEP021AccessibilityGate
    let evidencePacket: AFEP021AccessibilityEvidencePacket?

    var id: String {
        "\(surface.tab.rawValue)-\(gate.kind.rawValue)"
    }
}

struct AFEP021AccessibilitySurfaceFixture: Identifiable, Sendable, Equatable {
    let tab: AmbitionsSurface
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
