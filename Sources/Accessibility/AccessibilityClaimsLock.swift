import Foundation

public enum AccessibilityClaimScope: String, CaseIterable, Identifiable, Sendable {
    case dynamicType
    case voiceOver
    case reduceMotion
    case contrast
    case motor
    case externalSurfaces
    case appStoreSummary

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dynamicType: "Dynamic Type"
        case .voiceOver: "VoiceOver"
        case .reduceMotion: "Reduce Motion"
        case .contrast: "Contrast"
        case .motor: "Motor and tap targets"
        case .externalSurfaces: "External surfaces"
        case .appStoreSummary: "App Store accessibility summary"
        }
    }
}

public enum AccessibilityClaimLockState: String, CaseIterable, Identifiable, Sendable {
    case locked
    case manualProofRequired
    case notInScope
    case verified

    public var id: String { rawValue }
    public var canPublish: Bool { self == .verified }

    public var label: String {
        switch self {
        case .locked: "Claims locked"
        case .manualProofRequired: "Manual proof required"
        case .notInScope: "Not in scope"
        case .verified: "Verified"
        }
    }
}

public struct AccessibilityClaimLockEntry: Identifiable, Hashable, Sendable {
    public let scope: AccessibilityClaimScope
    public let state: AccessibilityClaimLockState
    public let evidence: String
    public let limitation: String
    public let ownerBatch: String

    public var id: AccessibilityClaimScope { scope }
    public var canPublish: Bool { state.canPublish }

    public init(
        scope: AccessibilityClaimScope,
        state: AccessibilityClaimLockState,
        evidence: String,
        limitation: String,
        ownerBatch: String
    ) {
        self.scope = scope
        self.state = state
        self.evidence = evidence
        self.limitation = limitation
        self.ownerBatch = ownerBatch
    }
}

public enum AccessibilityClaimsLock {
    public static let r01Entries: [AccessibilityClaimLockEntry] = [
        AccessibilityClaimLockEntry(
            scope: .dynamicType,
            state: .manualProofRequired,
            evidence: "D21 records internal source, design, and automated-test anchors for active screens.",
            limitation: "Accessibility-size screenshots and no-clipping review are not recorded for the supported launch device band.",
            ownerBatch: "R01"
        ),
        AccessibilityClaimLockEntry(
            scope: .voiceOver,
            state: .manualProofRequired,
            evidence: "D21 records labels, values, hints, and reading-order requirements as internal evidence.",
            limitation: "Manual VoiceOver traversal evidence is not recorded for top-level and detail surfaces.",
            ownerBatch: "R01"
        ),
        AccessibilityClaimLockEntry(
            scope: .reduceMotion,
            state: .manualProofRequired,
            evidence: "Design-system motion variants and Reduce Motion requirements exist.",
            limitation: "A toggled Reduce Motion walkthrough is not recorded for launch journeys.",
            ownerBatch: "R01"
        ),
        AccessibilityClaimLockEntry(
            scope: .contrast,
            state: .manualProofRequired,
            evidence: "Design canon and semantic color requirements exist for light/dark mode contrast.",
            limitation: "Measured contrast evidence for active screens and states is not recorded.",
            ownerBatch: "R01"
        ),
        AccessibilityClaimLockEntry(
            scope: .motor,
            state: .manualProofRequired,
            evidence: "Shared tap-target helpers and gesture-alternative requirements exist.",
            limitation: "A launch-band motor/tap-target pass is not recorded across all primary flows.",
            ownerBatch: "R01"
        ),
        AccessibilityClaimLockEntry(
            scope: .externalSurfaces,
            state: .manualProofRequired,
            evidence: "D22-D25 and M04 record contract-level accessibility requirements for widgets, Live Activities, App Intents, and notifications.",
            limitation: "Rendered widget, Live Activity, Shortcuts, notification, and real-device external-surface accessibility proof is not recorded.",
            ownerBatch: "R01"
        ),
        AccessibilityClaimLockEntry(
            scope: .appStoreSummary,
            state: .locked,
            evidence: "Internal evidence exists, but no public accessibility claim has verified scope.",
            limitation: "App Store, release notes, marketing, and in-app accessibility summaries must not publish accessibility support claims yet.",
            ownerBatch: "R01"
        )
    ]

    public static var publishableClaims: [AccessibilityClaimLockEntry] {
        r01Entries.filter(\.canPublish)
    }

    public static var summary: String {
        "R01 keeps public accessibility claims locked until manual proof exists; R02 is next."
    }
}
