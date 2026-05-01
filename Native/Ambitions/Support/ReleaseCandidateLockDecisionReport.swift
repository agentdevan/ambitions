import Foundation

enum ReleaseCandidatePosture: String, Sendable, Equatable {
    case notReady = "Not ready"
    case internalQAReady = "Internal QA ready"
    case testFlightCandidateAfterDeviceSmoke = "TestFlight candidate after device smoke"
    case investorDemoPreparedWithLimitations = "Investor demo prepared with limitations"
    case appStoreSubmissionNotReady = "App Store submission not ready"
}

enum ReleaseCandidateLockStatus: String, Sendable, Equatable {
    case candidatePreparedHumanApprovalRequired = "Candidate prepared; human approval required"
}

enum ReleaseDecisionItemState: String, Sendable, Equatable {
    case satisfiedByRepoEvidence = "Satisfied by repo evidence"
    case blockedByMissingHumanOrDeviceProof = "Blocked by missing human or device proof"
    case deferredByRoadmapDecision = "Deferred by roadmap decision"
}

struct ReleaseCandidateDecisionItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let evidence: String
    let state: ReleaseDecisionItemState
    let nextAction: String
}

enum ReleaseCandidateLockDecisionReport {
    static let lockStatus: ReleaseCandidateLockStatus = .candidatePreparedHumanApprovalRequired

    static let releasePosture: ReleaseCandidatePosture = .investorDemoPreparedWithLimitations

    static let postureSummary = "R05 prepares the release-candidate truth for human review. The current build has strong simulator/unit evidence and an investor/demo story, but it is not TestFlight-ready, App Store submission-ready, or locked without human approval."

    static let satisfiedEvidence: [ReleaseCandidateDecisionItem] = [
        ReleaseCandidateDecisionItem(
            id: "d01-d26-design-layer",
            title: "Design Constitution alignment layer",
            evidence: "D01-D26 are complete for planning purposes with D26 validation over the Golden Launch Loop, Human Language Review, screen contracts, trust/privacy/receipt posture, accessibility evidence, and external-surface constraints.",
            state: .satisfiedByRepoEvidence,
            nextAction: "Preserve the five-tab shell and D-series history."
        ),
        ReleaseCandidateDecisionItem(
            id: "m01-m12-maturity-layer",
            title: "Maturity evidence layer",
            evidence: "M01-M12 are complete for planning purposes, including scenario catalog, export/import proof, no-lost-data hardening, external-surface verification checklist, path/memory/review/portfolio/recovery maturity, and continuity/performance evidence.",
            state: .satisfiedByRepoEvidence,
            nextAction: "Use the M-series evidence as release review context, not as App Store proof."
        ),
        ReleaseCandidateDecisionItem(
            id: "r01-r04-release-gates",
            title: "Release-readiness evidence gates",
            evidence: "R01-R04 are complete for planning purposes with accessibility claims locked, performance evidence recorded, device-readiness scenarios classified, and external truth materials drafted.",
            state: .satisfiedByRepoEvidence,
            nextAction: "Keep public claims bounded to the evidence packet."
        )
    ]

    static let blockers: [ReleaseCandidateDecisionItem] = [
        ReleaseCandidateDecisionItem(
            id: "human-approval",
            title: "Human approval is required before RC lock.",
            evidence: "Codex cannot capture final human approval inside repo evidence.",
            state: .blockedByMissingHumanOrDeviceProof,
            nextAction: "Record explicit human approval before changing the RC status from candidate prepared."
        ),
        ReleaseCandidateDecisionItem(
            id: "physical-device-smoke",
            title: "Physical-device smoke is not complete.",
            evidence: "R03 records simulator/source readiness and keeps real-device smoke, high-volume device scrolling, and installed-device app-group behavior unclaimed.",
            state: .blockedByMissingHumanOrDeviceProof,
            nextAction: "Run the R03 fresh install, returning user, denied permissions, lots-of-data, disrupted-week, export/import, and external-surface journeys on a supported iPhone."
        ),
        ReleaseCandidateDecisionItem(
            id: "manual-accessibility",
            title: "Manual accessibility proof is missing.",
            evidence: "R01 keeps AccessibilityClaimsLock.publishableClaims empty until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, motor/tap-target, and external-surface proof exists.",
            state: .blockedByMissingHumanOrDeviceProof,
            nextAction: "Complete manual accessibility verification before publishing Accessibility Nutrition or App Store accessibility claims."
        ),
        ReleaseCandidateDecisionItem(
            id: "signed-archive-store-validation",
            title: "Signed archive and App Store Connect validation are not complete.",
            evidence: "The repo can run simulator builds and unsigned archive workflows, but signing identities, provisioning profiles, App Store Connect credentials, and Validate App proof are outside repo evidence.",
            state: .blockedByMissingHumanOrDeviceProof,
            nextAction: "Run the signed archive and App Store Connect validation workflow on the release Mac."
        ),
        ReleaseCandidateDecisionItem(
            id: "external-platform-proof",
            title: "Rendered external-surface platform proof is missing.",
            evidence: "D22-D25/M04/R03/R04 cover contracts, snapshots, metadata, and limitations, but not rendered widgets, Live Activities, notification delivery, Shortcuts/Siri invocation, or device shared-container I/O.",
            state: .blockedByMissingHumanOrDeviceProof,
            nextAction: "Verify each enabled external surface on device or remove the claim from release materials."
        ),
        ReleaseCandidateDecisionItem(
            id: "store-material-assets",
            title: "Store assets and live URLs are not complete.",
            evidence: "R04 prepares a screenshot plan and support/privacy URL requirements without providing curated screenshots or live support/privacy pages.",
            state: .blockedByMissingHumanOrDeviceProof,
            nextAction: "Generate current screenshots from final build data and provide live support/privacy URLs before submission."
        )
    ]

    static let deferrals: [ReleaseCandidateDecisionItem] = [
        ReleaseCandidateDecisionItem(
            id: "apple-first-sync",
            title: "Apple-first sync remains a future human decision.",
            evidence: "Current repo evidence is local-first with portable export/import proof, not cloud/account sync.",
            state: .deferredByRoadmapDecision,
            nextAction: "Choose defer sync, policy-only, Apple-first sync implementation, or later account-backed sync in the next roadmap layer."
        ),
        ReleaseCandidateDecisionItem(
            id: "app-store-submission",
            title: "App Store submission candidate status is deferred.",
            evidence: "R04 drafts submission materials, but physical-device proof, signed validation, screenshots, live URLs, privacy-label review, and human approval remain open.",
            state: .deferredByRoadmapDecision,
            nextAction: "Treat the current posture as investor/demo prepared with limitations, not App Store submission candidate."
        )
    ]

    static var allItems: [ReleaseCandidateDecisionItem] {
        satisfiedEvidence + blockers + deferrals
    }
}
