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

    func testSI15AccessibilityRequirementResponsibilityCoverage() {
        let requirements = SI15AccessibilityAdaptiveInterfaceReview.requirements
        let expectedScopes: Set<AmbitionsAccessibilityResponsibilityScope> = [
            .globalHelper,
            .primitiveResponsibility,
            .surfaceSpecific
        ]

        XCTAssertEqual(Set(AmbitionsAccessibilityResponsibilityScope.allCases), expectedScopes)
        XCTAssertEqual(Set(requirements.map(\.responsibilityScope)), expectedScopes)

        for requirement in requirements {
            XCTAssertFalse(requirement.responsibilitySummary.isEmpty)
            XCTAssertFalse(requirement.staticMotionMeaning.isEmpty)
            XCTAssertFalse(requirement.hitAreaStrategy.isEmpty)
            XCTAssertFalse(requirement.contrastTransparencyStrategy.isEmpty)
        }
    }

    func testAMB570PrimitiveFallbackContractRecordsRequiredBehaviors() {
        let profile = AmbitionsPrimitiveAccessibilityFallbackProfile.sourceTrustStrip

        XCTAssertEqual(profile.primitiveID, "source-trust-strip")
        XCTAssertEqual(profile.owningSurface, .today)
        XCTAssertEqual(
            profile.recordedAxes,
            Set(AmbitionsPrimitiveAccessibilityFallbackAxis.allCases)
        )
        XCTAssertTrue(profile.recordsRequiredBehaviors)
        XCTAssertFalse(profile.publicClaimAllowed)
        XCTAssertFalse(profile.changesRuntimeBehavior)
        XCTAssertTrue(profile.runtimeInspectionBoundary.localizedCaseInsensitiveContains("source"))
        XCTAssertTrue(profile.runtimeInspectionBoundary.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(profile.runtimeInspectionBoundary.localizedCaseInsensitiveContains("reason"))
    }

    func testAMB570PrimitiveFallbackBehaviorsStaySpecificInsteadOfGenericWorkarounds() {
        let profile = AmbitionsPrimitiveAccessibilityFallbackProfile.sourceTrustStrip

        for axis in AmbitionsPrimitiveAccessibilityFallbackAxis.allCases {
            let behavior = profile.behavior(for: axis)

            XCTAssertEqual(behavior.axis, axis)
            XCTAssertFalse(behavior.visibleFallback.isEmpty)
            XCTAssertFalse(behavior.evidenceSummary.isEmpty)
            XCTAssertFalse(behavior.manualProofStillRequired.isEmpty)
            XCTAssertTrue(profile.accessibilitySummary.localizedCaseInsensitiveContains(axis.title))
            XCTAssertFalse(behavior.visibleFallback.localizedCaseInsensitiveContains("generic workaround"))
            XCTAssertFalse(behavior.evidenceSummary.localizedCaseInsensitiveContains("generic workaround"))
        }

        XCTAssertTrue(profile.behavior(for: .dynamicType).visibleFallback.localizedCaseInsensitiveContains("accessibility text sizes"))
        XCTAssertTrue(profile.behavior(for: .reduceMotion).visibleFallback.localizedCaseInsensitiveContains("static"))
        XCTAssertTrue(profile.behavior(for: .reduceTransparency).visibleFallback.localizedCaseInsensitiveContains("opaque"))
        XCTAssertTrue(profile.behavior(for: .increaseContrast).visibleFallback.localizedCaseInsensitiveContains("border"))
    }

    @MainActor
    func testAMB570PrimitiveFallbackModifierIsAvailableToNewPrimitives() {
        let view = Text("Source trust")
            .ambitionsPrimitiveAccessibilityFallback(.sourceTrustStrip)

        XCTAssertFalse(String(describing: type(of: view)).isEmpty)
    }

    func testSI15PrimarySurfaceAccessibilitySummariesCoverAllActiveObjectTargets() {
        let summaries = SI15AccessibilityAdaptiveInterfaceReview.primaryObjectAccessibilitySummaries

        XCTAssertEqual(
            Set(summaries.map(\.surface)),
            Set(AmbitionsPrimaryObjectSurface.allCases)
        )

        for surface in AmbitionsPrimaryObjectSurface.allCases {
            let summary = SI15AccessibilityAdaptiveInterfaceReview.requirement(for: surface)
            XCTAssertEqual(summary.surface, surface)
            XCTAssertFalse(summary.activeObjectSummary.isEmpty)
            XCTAssertFalse(summary.dynamicTypeStrategy.isEmpty)
            XCTAssertFalse(summary.staticMotionEquivalent.isEmpty)
            XCTAssertFalse(summary.expandedHitAreaStrategy.isEmpty)
            XCTAssertFalse(summary.contrastTransparencyStrategy.isEmpty)
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
                path.hasPrefix("Packages/AmbitionsDesignSystem/Sources/Components/") ||
                    path.hasPrefix("Packages/AmbitionsDesignSystem/Sources/Previews/") ||
                    path.hasPrefix("Native/AmbitionsTests/"),
                "Unexpected SI15 owner path: \(path)"
            )
        }
    }
}
