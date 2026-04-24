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
}
