import XCTest
@testable import Ambitions

final class AmbitionsOSProofTrustModelsTests: XCTestCase {
    private let validator = AmbitionsOSProofTrustValidator()

    func testClosureReceiptCanCloseProofTrustGateWhenEvidenceIsReviewReady() {
        let receipt = validReceipt(
            kind: .closure,
            actionReceiptIDs: ["action-receipt-1"],
            closureOutcome: .stillCounts
        )

        XCTAssertEqual(receipt.schemaVersion, ambitionsOSProofTrustSchemaVersion)
        XCTAssertTrue(receipt.hasTrustEvidence)
        XCTAssertTrue(receipt.canCloseProofTrustGate)
        XCTAssertEqual(validator.validate(receipt: receipt), [])
    }

    func testSourceNeededAndStaleHighRiskReceiptsRequireReviewBeforeTrustClosure() {
        let receipt = validReceipt(
            kind: .proof,
            proofReferenceIDs: ["proof-1"],
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            reviewState: .needsSourceReview
        )

        let issues = validator.validate(receipt: receipt)

        XCTAssertFalse(receipt.canCloseProofTrustGate)
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleHighRiskSource))
    }

    func testProfessionalBoundaryReceiptBlocksTrustClosureUntilReviewed() {
        let receipt = validReceipt(
            kind: .professionalBoundary,
            actionReceiptIDs: ["action-receipt-1"],
            sourceState: .sourceBacked,
            freshnessState: .current,
            professionalBoundaryReviewRequired: true
        )

        XCTAssertFalse(receipt.canCloseProofTrustGate)
        XCTAssertEqual(validator.validate(receipt: receipt), [.professionalBoundaryReviewRequired])
    }

    func testClosurePromptRejectsPunitiveUnresolvedLanguage() {
        let receipt = validReceipt(
            kind: .closure,
            actionReceiptIDs: ["action-receipt-1"],
            closureOutcome: .needsReview
        )
        let safePrompt = AmbitionsOSClosurePromptContract(promptID: "prompt-safe")
        let punitivePrompt = AmbitionsOSClosurePromptContract(
            promptID: "prompt-bad",
            unresolvedStateLabel: "Missed and overdue"
        )

        XCTAssertTrue(safePrompt.usesNonPunitiveLanguage)
        XCTAssertFalse(punitivePrompt.usesNonPunitiveLanguage)
        XCTAssertFalse(validator.validate(receipt: receipt, closurePrompt: safePrompt).contains(.punitiveClosureLanguage))
        XCTAssertTrue(validator.validate(receipt: receipt, closurePrompt: punitivePrompt).contains(.punitiveClosureLanguage))
    }

    func testMutationReceiptRequiresReviewableEvidenceAndNoSilentMutationRisk() {
        let missingEvidence = validReceipt(
            kind: .mutation,
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            reviewState: .needsUserReview,
            reversible: false
        )
        let reviewed = validReceipt(
            kind: .mutation,
            actionReceiptIDs: ["action-receipt-1"],
            changedFactSummaries: ["No user plan changed without review."],
            reviewState: .ready,
            reversible: true
        )

        let missingIssues = validator.validate(receipt: missingEvidence)

        XCTAssertFalse(missingEvidence.canCloseProofTrustGate)
        XCTAssertTrue(missingIssues.contains(.missingProofOrActionReceipt))
        XCTAssertTrue(missingIssues.contains(.silentMutationRisk))
        XCTAssertTrue(reviewed.canCloseProofTrustGate)
        XCTAssertEqual(validator.validate(receipt: reviewed), [])
    }

    func testSensitiveReceiptIsNotExternalProjectionSafeWithoutRedaction() {
        let sensitive = validReceipt(
            kind: .trustReview,
            actionReceiptIDs: ["action-receipt-1"],
            privacyClass: .sensitive
        )
        let redacted = validReceipt(
            kind: .trustReview,
            actionReceiptIDs: ["action-receipt-1"],
            privacyClass: .externalRedacted
        )

        XCTAssertFalse(sensitive.isExternalProjectionSafe)
        XCTAssertTrue(validator.validate(receipt: sensitive).contains(.privateExternalProjectionRisk))
        XCTAssertTrue(redacted.isExternalProjectionSafe)
        XCTAssertEqual(validator.validate(receipt: redacted), [])
    }
}

private extension AmbitionsOSProofTrustModelsTests {
    func validReceipt(
        kind: AmbitionsOSProofTrustReceiptKind,
        actionReceiptIDs: [String] = [],
        proofReferenceIDs: [String] = [],
        changedFactSummaries: [String] = [],
        closureOutcome: AmbitionsOSClosureOutcome? = nil,
        sourceState: HumanProgressSourceState = .sourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reversible: Bool = true,
        professionalBoundaryReviewRequired: Bool = false
    ) -> AmbitionsOSProofTrustReceipt {
        AmbitionsOSProofTrustReceipt(
            id: "proof-trust-\(kind.rawValue)",
            kind: kind,
            surface: .today,
            occurredAt: "2026-05-06T22:45:00Z",
            affectedObjectIDs: ["step-1"],
            actionReceiptIDs: actionReceiptIDs,
            proofReferenceIDs: proofReferenceIDs,
            sourceClaimIDs: ["source-claim-1"],
            sourcePackIDs: ["source-pack-1"],
            changedFactSummaries: changedFactSummaries,
            closureOutcome: closureOutcome,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            reversible: reversible,
            professionalBoundaryReviewRequired: professionalBoundaryReviewRequired
        )
    }
}
