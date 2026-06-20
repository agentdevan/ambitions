import Foundation

struct AFEP021AccessibilityCertificationProgram: Sendable, Equatable {
    static let `default` = AFEP021AccessibilityCertificationProgram(
        surfaceFixtures: [
            AFEP021AccessibilitySurfaceFixture(
                tab: .today,
                surfaceTitle: "Today",
                primaryObjectTitle: AmbitionsSurface.today.primaryObjectTitle,
                fixtureState: "today-reality-meridian",
                deterministicSeed: "afep021-surface-today",
                projectionInputName: "today_accessibility_projection_input",
                inspectionLabel: "You / Search Ambitions",
                artifactStem: "today-reality-meridian"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .goals,
                surfaceTitle: "Goals",
                primaryObjectTitle: AmbitionsSurface.goals.primaryObjectTitle,
                fixtureState: "goals-direction-atlas",
                deterministicSeed: "afep021-surface-goals",
                projectionInputName: "goals_accessibility_projection_input",
                inspectionLabel: "You / Search Ambitions",
                artifactStem: "goals-direction-atlas"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .time,
                surfaceTitle: "Time",
                primaryObjectTitle: AmbitionsSurface.time.primaryObjectTitle,
                fixtureState: "time-lifeshape-field",
                deterministicSeed: "afep021-surface-time",
                projectionInputName: "time_accessibility_projection_input",
                inspectionLabel: "You / Search Ambitions",
                artifactStem: "time-lifeshape-field"
            ),
            AFEP021AccessibilitySurfaceFixture(
                tab: .you,
                surfaceTitle: "You",
                primaryObjectTitle: AmbitionsSurface.you.primaryObjectTitle,
                fixtureState: "you-personal-runtime",
                deterministicSeed: "afep021-surface-you",
                projectionInputName: "you_accessibility_projection_input",
                inspectionLabel: "You / Search Ambitions",
                artifactStem: "you-personal-runtime"
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
                id: "today-manual-voiceover-pending",
                command: "manual VoiceOver traversal",
                artifactPath: "docs/audits/afep021-accessibility-proof-claim-boundary.md",
                surface: "Today",
                fixtureState: "today-reality-meridian",
                result: .skipped,
                knownLimitation: "Manual VoiceOver evidence is not recorded in this batch.",
                owner: "Today",
                followUpProofRequirement: "Manual VoiceOver traversal, Dynamic Type screenshots, Reduce Motion, and device proof remain required before public claim approval.",
                proofKind: .manualVoiceOver
            ),
            AFEP021AccessibilityEvidencePacket(
                id: "goals-automated-test",
                command: "make xcode-focused-test BATCH=AFEP-021 TEST=AmbitionsTests/AccessibilityNutritionChecklistTests",
                artifactPath: "docs/audits/afep021-accessibility-gate-matrix.md",
                surface: "Goals",
                fixtureState: "goals-direction-atlas",
                result: .pass,
                knownLimitation: "Automated coverage does not prove a public accessibility certification claim.",
                owner: "Goals",
                followUpProofRequirement: "Manual semantic-grouping and device-band proof remain required.",
                proofKind: .automatedTest
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
                fixtureState: "you-personal-runtime",
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
            youInspectionLabel: "You / Search Ambitions",
            inspectionSurfaceTitle: "Search Ambitions",
            inspectionSummary: "You / Search Ambitions can inspect the AFEP-021 accessibility certification scaffold without implying public certification."
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

        if surfaceFixtures.map(\.tab) != AmbitionsSurface.allCases {
            failures.append("accessibility certification surfaces must cover all active top-level surfaces in order")
        }

        for tab in AmbitionsSurface.allCases {
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
        if provenanceReferences.youInspectionLabel != "You / Search Ambitions" || provenanceReferences.inspectionSurfaceTitle != "Search Ambitions" {
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
