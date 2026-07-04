import Foundation

enum FrontendReleaseQualityStatus: String, Sendable, Equatable {
    case green = "Green"
    case yellow = "Yellow"
    case red = "Red"
}

enum FrontendReleaseProofState: String, Sendable, Equatable {
    case requiredMissing = "Required missing"
    case indexedNotRun = "Indexed, not run"
    case blockedUntilDeviceEvidence = "Blocked until device evidence"
    case blockedUntilHumanReview = "Blocked until human review"
}

enum FrontendReleaseProofKind: String, CaseIterable, Sendable, Equatable {
    case screenshot = "Screenshot"
    case journey = "Journey"
    case accessibility = "Accessibility"
    case dynamicType = "Dynamic Type"
    case reduceMotion = "Reduce Motion"
    case device = "Device"
    case siblingDependency = "Sibling frontend dependency"
    case acceptedYellowSeparation = "Accepted Yellow separation"
}

struct FrontendReleaseProofRequirement: Identifiable, Sendable, Equatable {
    let id: String
    let kind: FrontendReleaseProofKind
    let requiredScope: String
    let evidence: String
    let state: FrontendReleaseProofState
    let releaseBlocker: String
}

enum ReleaseFrontendProofGate {
    static let currentStatus: FrontendReleaseQualityStatus = .yellow

    static let acceptedYellowCountsAsGreen = false

    static let visualGreenClaimAllowed = false

    static let appStoreFrontendClaimAllowed = false

    static let deviceSensitiveClaimsRequireDeviceEvidence = true

    static let releaseDependencyIssues = [
        "AMB-1749",
        "AMB-1744",
        "AMB-1743",
        "AMB-1733",
        "AMB-1734",
        "AMB-1735",
        "AMB-1736",
        "AMB-1737",
        "AMB-1738",
        "AMB-1739",
        "AMB-1740",
        "AMB-1741",
        "AMB-1742",
        "AMB-1751"
    ]

    static let requiredScreenshotScopes = [
        "root_shell",
        "capture",
        "today",
        "goals",
        "time",
        "you",
        "inspection_details",
        "empty_error_offline_states"
    ]

    static let requirements: [FrontendReleaseProofRequirement] = [
        FrontendReleaseProofRequirement(
            id: "frontend-screenshot-current",
            kind: .screenshot,
            requiredScope: "Root shell, Capture, Today, Goals, Time, You, inspection details, and key empty/error/offline states.",
            evidence: "AMB-1749 defines stable screenshot artifact roots, but the slow screenshot lane was not run for this release gate.",
            state: .indexedNotRun,
            releaseBlocker: "Do not report frontend Green or App Store screenshot readiness until current screenshots exist for every required scope."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-journey-current",
            kind: .journey,
            requiredScope: "Root/Capture/Today/Goals/Time/You journeys plus inspection details.",
            evidence: "AMB-1749 indexes source UI journey tests; current rendered journey proof remains separate from unit/source-route proof.",
            state: .indexedNotRun,
            releaseBlocker: "Do not infer frontend quality from unit tests or source-route tests alone."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-accessibility-manual",
            kind: .accessibility,
            requiredScope: "Manual VoiceOver, focus order, semantic grouping, contrast, tap-target, and non-color meaning checks on release-critical paths.",
            evidence: "Automated requirement tests exist; manual accessibility conformance proof is missing.",
            state: .requiredMissing,
            releaseBlocker: "Do not publish accessibility conformance or accessibility-ready frontend claims."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-dynamic-type",
            kind: .dynamicType,
            requiredScope: "Accessibility-size screenshots and clipping/overlap review for root shell, Capture, Today, Goals, Time, You, and inspection details.",
            evidence: "Design-system contract tests exist; current rendered Dynamic Type screenshot review is missing.",
            state: .requiredMissing,
            releaseBlocker: "Do not claim release-critical frontend readability at accessibility sizes."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-reduce-motion",
            kind: .reduceMotion,
            requiredScope: "Reduced-motion static equivalents for shell transitions, Capture, Time layers, recovery, and inspection paths.",
            evidence: "Reduce Motion contract coverage exists; rendered release walkthrough is missing.",
            state: .requiredMissing,
            releaseBlocker: "Do not claim motion/accessibility readiness for frontend release paths."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-device-proof",
            kind: .device,
            requiredScope: "Physical iPhone proof for visual fit, safe areas, keyboard behavior, device performance, and App Store screenshot/device-sensitive claims.",
            evidence: "No current physical-device frontend proof is attached to AMB-1750.",
            state: .blockedUntilDeviceEvidence,
            releaseBlocker: "Do not make device-sensitive frontend, TestFlight, or App Store claims."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-sibling-dependency",
            kind: .siblingDependency,
            requiredScope: "Ambitions Flagship Frontend Recovery and linked frontend parent features.",
            evidence: "AMB-1749 links the sibling frontend project and AMB-1733 through AMB-1744 plus AMB-1751 as frontend recovery dependencies.",
            state: .blockedUntilHumanReview,
            releaseBlocker: "Do not treat architecture remediation status as sibling frontend recovery completion."
        ),
        FrontendReleaseProofRequirement(
            id: "frontend-yellow-separation",
            kind: .acceptedYellowSeparation,
            requiredScope: "Accepted Yellow, Ready for Review, source-only, and harness-only evidence must remain separate from Green release claims.",
            evidence: "This gate keeps frontend status Yellow while required screenshot, accessibility, visual review, and device proof are missing.",
            state: .requiredMissing,
            releaseBlocker: "Do not count Accepted Yellow or Ready for Review frontend work as Green."
        )
    ]

    static var releaseSummary: String {
        "Frontend release quality is Yellow: AMB-1749 provides harness/index proof, while screenshots, rendered journeys, manual accessibility, Dynamic Type, Reduce Motion, visual review, and device proof remain required before Green."
    }

    static var blockingRequirements: [FrontendReleaseProofRequirement] {
        requirements.filter { requirement in
            requirement.state != .blockedUntilHumanReview || acceptedYellowCountsAsGreen == false
        }
    }

    static func validationFailures() -> [String] {
        var failures: [String] = []

        if currentStatus == .green {
            failures.append("Frontend release quality cannot be Green without current visual, accessibility, journey, and device evidence.")
        }
        if acceptedYellowCountsAsGreen {
            failures.append("Accepted Yellow must not count as frontend Green.")
        }
        if visualGreenClaimAllowed {
            failures.append("Visual Green requires independent visual review and current screenshot evidence.")
        }
        if appStoreFrontendClaimAllowed {
            failures.append("App Store frontend claims require current release/device evidence.")
        }
        if deviceSensitiveClaimsRequireDeviceEvidence == false {
            failures.append("Device-sensitive claims must require device evidence.")
        }
        if Set(requiredScreenshotScopes) != Set([
            "root_shell",
            "capture",
            "today",
            "goals",
            "time",
            "you",
            "inspection_details",
            "empty_error_offline_states"
        ]) {
            failures.append("Required screenshot scopes are incomplete.")
        }
        if Set(requirements.map(\.kind)) != Set(FrontendReleaseProofKind.allCases) {
            failures.append("Frontend release proof requirements do not cover every proof kind.")
        }
        for dependency in ["AMB-1749", "AMB-1744", "AMB-1743", "AMB-1733", "AMB-1751"] where releaseDependencyIssues.contains(dependency) == false {
            failures.append("Missing frontend release dependency \(dependency).")
        }

        return failures
    }
}
