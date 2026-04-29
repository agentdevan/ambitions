import AmbitionsDesignSystem
import XCTest

final class AccessibilityNutritionChecklistTests: XCTestCase {
    func testChecklistCoversBatch64RequiredCategories() {
        let requiredCategories: Set<AccessibilityNutritionCategory> = [
            .dynamicType,
            .voiceOver,
            .reduceMotion,
            .contrast,
            .colorNotOnlyMeaning,
            .tapTargetSize,
            .gestureAlternatives,
            .keyboardAndFocusSupport,
            .errorRecovery,
            .cognitiveLoad,
            .oneHandedUsability,
            .plainLanguageLabels,
            .noShameOrGuiltStates,
            .privacyTrustClarity,
            .verifiedUserFacingClaims
        ]

        XCTAssertEqual(Set(AccessibilityNutritionCategory.allCases), requiredCategories)
        XCTAssertEqual(Set(AccessibilityNutritionChecklist.items.map(\.category)), requiredCategories)
    }

    func testEveryCategoryHasReadableLabelAndVerificationGuidance() {
        for item in AccessibilityNutritionChecklist.items {
            XCTAssertFalse(item.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertFalse(item.verificationGuidance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertGreaterThan(item.verificationGuidance.count, item.label.count)
        }
    }

    func testUserFacingClaimsDefaultToUnverified() {
        let claimItem = AccessibilityNutritionChecklist.item(for: .verifiedUserFacingClaims)

        XCTAssertEqual(claimItem?.defaultStatus, .unverified)
        XCTAssertFalse(claimItem?.defaultStatus.isUserFacingClaimAllowed ?? true)
    }

    func testNoCategoryReliesOnColorOnlyState() {
        for item in AccessibilityNutritionChecklist.items {
            XCTAssertTrue(item.requiresNonColorSupport, "\(item.label) must require a non-color support path.")
        }
    }

    func testFutureYouSummaryDistinguishesVerifiedAndUnverifiedSupport() {
        let unverifiedSummary = AccessibilityNutritionChecklist.unverifiedUserSummary()
        XCTAssertEqual(unverifiedSummary.count, AccessibilityNutritionChecklist.items.count)
        XCTAssertTrue(unverifiedSummary.allSatisfy { $0.status == .unverified })
        XCTAssertTrue(unverifiedSummary.allSatisfy { $0.canPublishAsUserFacingClaim == false })

        let verifiedSummaryItem = AccessibilityNutritionSummaryItem(
            category: .dynamicType,
            status: .verified,
            detail: "Verified on a specific build and device band."
        )
        XCTAssertTrue(verifiedSummaryItem.canPublishAsUserFacingClaim)
    }

    func testScreenAuditDescriptorCarriesCompleteChecklist() {
        let descriptor = AccessibilityNutritionChecklist.screenAuditDescriptor(
            id: "today",
            screenName: "Today",
            route: "tab.today",
            owner: "Today"
        )

        XCTAssertEqual(descriptor.id, "today")
        XCTAssertEqual(descriptor.screenName, "Today")
        XCTAssertEqual(descriptor.route, "tab.today")
        XCTAssertEqual(descriptor.owner, "Today")
        XCTAssertEqual(descriptor.checklist, AccessibilityNutritionChecklist.items)
    }

    func testD21InternalEvidenceAuditsCoverActiveScreenMatrixRows() {
        let audits = AccessibilityNutritionChecklist.d21InternalEvidenceAudits()
        let expectedIDs: Set<String> = Set(Self.d21ExpectedAuditOrder)

        XCTAssertEqual(Set(audits.map(\.id)), expectedIDs)
        XCTAssertEqual(audits.map(\.id), Self.d21ExpectedAuditOrder)

        for audit in audits {
            XCTAssertFalse(audit.screenName.isEmpty)
            XCTAssertFalse(audit.route.isEmpty)
            XCTAssertFalse(audit.owner.isEmpty)
            XCTAssertEqual(Set(audit.summary.map(\.category)), Set(AccessibilityNutritionCategory.allCases))
            XCTAssertFalse(audit.limitations.isEmpty)
        }
    }

    func testD21InternalEvidenceDoesNotPublishUserFacingClaims() {
        for audit in AccessibilityNutritionChecklist.d21InternalEvidenceAudits() {
            XCTAssertFalse(audit.hasUserFacingClaim, "\(audit.screenName) must not publish a user-facing accessibility claim from D21 internal evidence.")

            let claimItem = audit.summary.first { $0.category == .verifiedUserFacingClaims }
            XCTAssertEqual(claimItem?.status, .unverified)
            XCTAssertEqual(audit.summary.filter { $0.status == .verified }.count, 0)
        }
    }

    func testD21InternalEvidenceKeepsManualVerificationExplicit() {
        for audit in AccessibilityNutritionChecklist.d21InternalEvidenceAudits() {
            let evidenceKinds = Set(audit.evidenceAnchors.map(\.kind))

            XCTAssertTrue(evidenceKinds.contains(.designCanon), "\(audit.screenName) must keep the design matrix as evidence.")
            XCTAssertTrue(evidenceKinds.contains(.sourceInspection), "\(audit.screenName) must name implementation source.")
            XCTAssertTrue(evidenceKinds.contains(.automatedTest), "\(audit.screenName) must name automated coverage.")
            XCTAssertTrue(evidenceKinds.contains(.manualVerificationRequired), "\(audit.screenName) must keep manual proof requirements explicit.")
            XCTAssertTrue(audit.evidenceAnchors.allSatisfy { !$0.path.isEmpty && !$0.note.isEmpty })
            XCTAssertTrue(audit.limitations.contains { $0.localizedCaseInsensitiveContains("manual") })
        }
    }

    private static let d21ExpectedAuditOrder = [
        "today",
        "goals",
        "goal-detail",
        "capture",
        "plan",
        "you",
        "life-areas-north-stars",
        "reviews-archive",
        "trust-center-what-ambitions-knows",
        "rich-panels",
        "grouped-navigation-list",
        "quiet-command-sheet-smart-attachment",
        "external-surfaces"
    ]
}
