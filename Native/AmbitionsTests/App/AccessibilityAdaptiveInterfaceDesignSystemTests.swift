import AmbitionsDesignSystem
import XCTest

final class AccessibilityAdaptiveInterfaceDesignSystemTests: XCTestCase {
    func testSI15AdaptiveAxesCoverPromptRequirements() {
        XCTAssertEqual(Set(AmbitionsAdaptiveAxis.allCases), [
            .dynamicType,
            .voiceOver,
            .reduceMotion,
            .nonColorMeaning,
            .tapTarget,
            .privacySafeExposure,
            .cognitiveLoad
        ])

        XCTAssertEqual(SI15AccessibilityAdaptiveInterfaceReview.ownerBatch, "SI15")
        XCTAssertFalse(SI15AccessibilityAdaptiveInterfaceReview.releaseClaimsAllowed)
        XCTAssertFalse(SI15AccessibilityAdaptiveInterfaceReview.runtimeBehaviorChanged)
    }

    func testSI15AdaptiveReviewLanesMapToExistingSIPrimitiveStates() {
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.sourceReview.loadingState, .sourceConflict)
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.privacySensitive.loadingState, .privacySensitive)
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.professionalBoundary.statusRole, .professionalBoundary)
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.crisisSupport.statusRole, .crisisSupport)
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.overloadedDay.loadingState, .overwhelmingDay)
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.recovery.statusRole, .recoveryAvailable)
        XCTAssertEqual(AmbitionsAdaptiveReviewLane.emptyOrNoData.statusRole, .noDataYet)
    }

    func testSI15RequirementsCoverEveryLaneAndAxisPair() {
        let requirements = SI15AccessibilityAdaptiveInterfaceReview.requirements
        let expectedCount = AmbitionsAdaptiveReviewLane.allCases.count * AmbitionsAdaptiveAxis.allCases.count

        XCTAssertEqual(requirements.count, expectedCount)
        XCTAssertEqual(Set(requirements.map(\.lane)), Set(AmbitionsAdaptiveReviewLane.allCases))
        XCTAssertEqual(Set(requirements.map(\.axis)), Set(AmbitionsAdaptiveAxis.allCases))

        for lane in AmbitionsAdaptiveReviewLane.allCases {
            XCTAssertEqual(
                Set(SI15AccessibilityAdaptiveInterfaceReview.requirements(for: lane).map(\.axis)),
                Set(AmbitionsAdaptiveAxis.allCases)
            )
        }
    }

    func testSI15RequirementsKeepAccessibilityEvidenceExplicitAndNonColor() {
        for requirement in SI15AccessibilityAdaptiveInterfaceReview.requirements {
            XCTAssertFalse(requirement.visibleFallback.isEmpty)
            XCTAssertFalse(requirement.voiceOverSummary.isEmpty)
            XCTAssertFalse(requirement.reduceMotionEquivalent.isEmpty)
            XCTAssertFalse(requirement.manualProofStillRequired.isEmpty)
            XCTAssertTrue(requirement.nonColorMeaningRequired)
            XCTAssertFalse(requirement.publicClaimAllowed)
            XCTAssertFalse(requirement.changesRuntimeBehavior)
            XCTAssertTrue(requirement.voiceOverSummary.contains(requirement.axis.title))
            XCTAssertTrue(requirement.voiceOverSummary.contains(requirement.statusRole.title))
        }
    }

    func testSI15LDIHookLanesStayVisualOnlyWithoutRuntimeClaims() {
        let hooks = Set(AmbitionsAdaptiveReviewLane.allCases.filter(\.isFutureLDIVisualHook))

        XCTAssertEqual(hooks, [
            .sourceReview,
            .privacySensitive,
            .professionalBoundary,
            .crisisSupport
        ])

        let combined = SI15AccessibilityAdaptiveInterfaceReview.requirements
            .filter(\.isFutureLDIVisualHook)
            .map {
                "\($0.visibleFallback) \($0.voiceOverSummary) \($0.reduceMotionEquivalent)"
            }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("hosted " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("backend " + "sync"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("automatic commitment"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release " + "ready"))
    }

    func testSI15SourceFilesStayWithinAllowedOwnerFamilies() {
        for path in SI15AccessibilityAdaptiveInterfaceReview.sourceFiles {
            XCTAssertTrue(
                path.hasPrefix("Sources/Components/") ||
                    path.hasPrefix("Sources/Previews/") ||
                    path.hasPrefix("Native/AmbitionsTests/"),
                "Unexpected SI15 owner path: \(path)"
            )
        }
    }
}
