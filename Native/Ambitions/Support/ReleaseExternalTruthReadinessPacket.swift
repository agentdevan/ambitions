import Foundation

enum ReleaseExternalTruthArea: String, CaseIterable, Sendable, Equatable {
    case appStoreCopy = "App Store copy"
    case screenshots = "Screenshots"
    case privacyLabels = "Privacy labels"
    case reviewerNotes = "Reviewer notes"
    case supportContact = "Support contact"
    case releaseNotes = "Release notes"
    case investorDemo = "Investor demo"
    case marketingOnePager = "Marketing one-pager"
    case accessibilityClaims = "Accessibility claims"
    case platformClaims = "Platform claims"
}

enum ReleaseExternalTruthState: String, Sendable, Equatable {
    case draftedFromCurrentEvidence = "Drafted from current evidence"
    case needsHumanAsset = "Needs human asset"
    case blockedUntilDeviceProof = "Blocked until device proof"
    case blockedUntilManualProof = "Blocked until manual proof"
}

enum AppStoreSubmissionPosture: String, Sendable, Equatable {
    case notReady = "Not App Store submission-ready"
    case candidateAfterHumanReleaseGates = "Candidate after human release gates"
}

enum InvestorDemoPosture: String, Sendable, Equatable {
    case preparedWithLimitations = "Prepared with limitations"
    case notPrepared = "Not prepared"
}

struct ReleaseExternalTruthItem: Identifiable, Sendable, Equatable {
    let id: String
    let area: ReleaseExternalTruthArea
    let preparedStatement: String
    let evidence: String
    let state: ReleaseExternalTruthState
    let limitation: String
}

enum ReleaseExternalTruthReadinessPacket {
    static let items: [ReleaseExternalTruthItem] = [
        ReleaseExternalTruthItem(
            id: "app-store-copy",
            area: .appStoreCopy,
            preparedStatement: "Ambitions helps you capture what is on your mind, shape goals into believable next steps, plan a week that can survive real life, recover when plans change, and review proof of what moved.",
            evidence: "The active native shell is Today, Goals, Capture, Time, and You; D11-D26, M01-M12, and R01-R03 evidence cover the Golden Launch Loop, local-first trust posture, recovery, reviews, memory visibility, and release gates.",
            state: .draftedFromCurrentEvidence,
            limitation: "Final App Store metadata still needs human review, current screenshots, support and privacy URLs, signed archive validation, and approval."
        ),
        ReleaseExternalTruthItem(
            id: "screenshots",
            area: .screenshots,
            preparedStatement: "Screenshot plan: capture Today, Goals or Goal Detail, Capture, Time, You, What Ambitions Knows, and one recovery/review moment after the final release build is installed.",
            evidence: "R03 completed simulator/source scenario coverage; no curated App Store screenshot set has been generated or human-approved in this environment.",
            state: .needsHumanAsset,
            limitation: "Do not submit screenshots until the signed build, device class, privacy-safe demo data, and human visual review are complete."
        ),
        ReleaseExternalTruthItem(
            id: "privacy-labels",
            area: .privacyLabels,
            preparedStatement: "Privacy posture: the current native app is local-first, requires no Ambitions account, has no tracking flag, and declares no collected data types in the privacy manifest currently checked into the repo.",
            evidence: "Native/Ambitions/Resources/PrivacyInfo.xcprivacy sets NSPrivacyTracking to false and NSPrivacyCollectedDataTypes to an empty array; D05, D18, D19, M02, M03, R01, and R03 keep privacy, correction, export/import, and platform limits evidence-bound.",
            state: .draftedFromCurrentEvidence,
            limitation: "App Store Connect labels must be reconciled against the final signed build, any Apple permission prompts, support URLs, and human legal/privacy review before submission."
        ),
        ReleaseExternalTruthItem(
            id: "reviewer-notes",
            area: .reviewerNotes,
            preparedStatement: "Reviewer notes draft: no login is required; Calendar-style permissions are optional and manual planning remains available; external surfaces should be evaluated only where the submitted build enables them.",
            evidence: "R03 records no-account fresh-install proof paths, denied-permission fallbacks, and external-surface device gates without claiming TestFlight or App Store readiness.",
            state: .draftedFromCurrentEvidence,
            limitation: "Final reviewer notes still need exact build number, device coverage, enabled capabilities, and any App Store Connect-specific instructions."
        ),
        ReleaseExternalTruthItem(
            id: "support-contact",
            area: .supportContact,
            preparedStatement: "Support/contact requirement: provide live support and privacy URLs before App Store submission; do not imply account, cloud, or sync support that is not in the current native app.",
            evidence: "Release-compliance docs require support/privacy URLs; current native evidence does not prove hosted support or privacy pages.",
            state: .needsHumanAsset,
            limitation: "Submission remains blocked until live URLs and support handling are supplied and reviewed."
        ),
        ReleaseExternalTruthItem(
            id: "release-notes",
            area: .releaseNotes,
            preparedStatement: "Release notes draft: Ambitions organizes life around Today, Goals, Capture, Time, and You, with calmer capture, believable planning, recovery, proof, local trust controls, and clearer release-readiness limits.",
            evidence: "D01-D26, M01-M12, and R01-R04 are complete for planning purposes, while R05 still gates RC lock.",
            state: .draftedFromCurrentEvidence,
            limitation: "Final release notes must be reviewed against the exact submitted build and must not claim accessibility, sync, TestFlight, App Store, or RC readiness beyond evidence."
        ),
        ReleaseExternalTruthItem(
            id: "investor-demo",
            area: .investorDemo,
            preparedStatement: "Demo story: start with a loose thought in Capture, place it into a meaningful Goal, use Time to make the week believable, land in Today for one protected next Step, recover when life changes, then inspect receipts, reviews, and What Ambitions Knows in You.",
            evidence: "M01 scenario coverage and R03 representative fixtures prove the Golden Launch Loop as a QA/demo path over existing surfaces without productizing personal assumptions.",
            state: .draftedFromCurrentEvidence,
            limitation: "Demo remains investor/internal-ready with stated limits; it is not proof of App Store submission readiness or physical-device platform coverage."
        ),
        ReleaseExternalTruthItem(
            id: "marketing-one-pager",
            area: .marketingOnePager,
            preparedStatement: "One-page promise: Ambitions makes life feel organized and gives concrete steps to accomplish what the user sets their mind to, without adding another dashboard or requiring an account.",
            evidence: "The top-level IA stays Today, Goals, Capture, Time, and You; docs and tests guard against Tasks, Insights, Habits, Calendar, account, sync, cloud, and AI-wrapper drift.",
            state: .draftedFromCurrentEvidence,
            limitation: "Marketing must stay tied to shipped native behavior and avoid unverified platform, accessibility, sync, account, or advice claims."
        ),
        ReleaseExternalTruthItem(
            id: "accessibility-claims",
            area: .accessibilityClaims,
            preparedStatement: "Accessibility public claims remain locked; current copy may say the team is still verifying accessibility evidence, not that support is fully verified.",
            evidence: "R01 keeps AccessibilityClaimsLock.publishableClaims empty until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, motor, external-surface, and App Store-summary proof exists.",
            state: .blockedUntilManualProof,
            limitation: "Do not publish Accessibility Nutrition facts or App Store accessibility claims from the current evidence alone."
        ),
        ReleaseExternalTruthItem(
            id: "platform-claims",
            area: .platformClaims,
            preparedStatement: "Platform claims remain gated; widgets, Live Activities, Shortcuts, notifications, real-device behavior, TestFlight, App Store submission, and RC lock are not public-ready claims yet.",
            evidence: "D22-D25/M04/R02/R03 cover shared contracts, source budgets, metadata, and simulator/source paths while keeping rendered/device/platform proof unclaimed.",
            state: .blockedUntilDeviceProof,
            limitation: "Do not claim physical-device, TestFlight, App Store, external-surface, or RC readiness until R05 and human/device evidence close the gates."
        )
    ]

    static var appStoreSubmissionPosture: AppStoreSubmissionPosture {
        .notReady
    }

    static var investorDemoPosture: InvestorDemoPosture {
        .preparedWithLimitations
    }

    static var blockedItems: [ReleaseExternalTruthItem] {
        items.filter { item in
            item.state == .blockedUntilDeviceProof ||
            item.state == .blockedUntilManualProof ||
            item.state == .needsHumanAsset
        }
    }

    static var readinessSummary: String {
        "R04 prepares \(items.count) external-truth areas for App Store, privacy, marketing, and demo review while keeping App Store submission and RC lock blocked until R05/human gates."
    }
}
