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
        XCTAssertTrue(unverifiedSummary.allSatisfy { $0.detail.localizedCaseInsensitiveContains("claims locked") })

        let verifiedSummaryItem = AccessibilityNutritionSummaryItem(
            category: .dynamicType,
            status: .verified,
            detail: "Verified on a specific build and device band."
        )
        XCTAssertTrue(verifiedSummaryItem.canPublishAsUserFacingClaim)
    }

    func testR01ClaimLockKeepsPublicAccessibilityClaimsUnavailableWithoutManualEvidence() {
        let entries = AccessibilityClaimsLock.r01Entries

        XCTAssertEqual(Set(entries.map(\.scope)), Set(AccessibilityClaimScope.allCases))
        XCTAssertTrue(AccessibilityClaimsLock.publishableClaims.isEmpty)
        XCTAssertEqual(entries.first { $0.scope == .appStoreSummary }?.state, .locked)
        XCTAssertTrue(entries.allSatisfy { $0.ownerBatch == "R01" })
        XCTAssertTrue(entries.allSatisfy { !$0.evidence.isEmpty && !$0.limitation.isEmpty })
        XCTAssertTrue(entries.contains { $0.limitation.localizedCaseInsensitiveContains("VoiceOver") })
        XCTAssertTrue(entries.contains { $0.scope == .dynamicType && $0.limitation.localizedCaseInsensitiveContains("screenshots") })
        XCTAssertTrue(entries.contains { $0.limitation.localizedCaseInsensitiveContains("Reduce Motion") })
        XCTAssertTrue(entries.contains { $0.limitation.localizedCaseInsensitiveContains("contrast") })
        XCTAssertTrue(entries.contains { $0.scope == .externalSurfaces && $0.limitation.localizedCaseInsensitiveContains("external-surface") })
        XCTAssertTrue(AccessibilityClaimsLock.summary.contains("claims locked until manual proof exists"))
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

    func testEB27AdjustmentEvidenceCoversDynamicTypeVoiceOverAndReduceMotion() {
        let requirements = EB27AccessibilityAdjustmentEvidence.requirements

        XCTAssertEqual(Set(requirements.map(\.axis)), Set(AccessibilityAdjustmentAxis.allCases))
        XCTAssertEqual(EB27AccessibilityAdjustmentEvidence.ownerBatch, "EB27")
        XCTAssertFalse(EB27AccessibilityAdjustmentEvidence.userFacingClaimsAllowed)

        for requirement in requirements {
            XCTAssertFalse(requirement.ownerFile.isEmpty)
            XCTAssertFalse(requirement.automatedProofTarget.isEmpty)
            XCTAssertFalse(requirement.requiredFallback.isEmpty)
            XCTAssertFalse(requirement.manualProofStillRequired.isEmpty)
            XCTAssertTrue(requirement.nonColorMeaningRequired)
            XCTAssertFalse(requirement.userFacingClaimAllowed)
        }
    }

    func testEB27AdjustmentEvidenceNamesExistingOwnerFilesAndManualLimits() {
        let requirements = EB27AccessibilityAdjustmentEvidence.requirements

        XCTAssertTrue(requirements.contains {
            $0.axis == .dynamicTypeLayout &&
                $0.ownerFile == "Sources/Theme/PanelDensitySize.swift" &&
                $0.requiredFallback.localizedCaseInsensitiveContains("lower density")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .voiceOverOrder &&
                $0.ownerFile == "Sources/Accessibility/AccessibilityNutrition.swift" &&
                $0.manualProofStillRequired.localizedCaseInsensitiveContains("Manual VoiceOver")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .reduceMotionEquivalent &&
                $0.ownerFile == "Sources/Components/DynamicAdaptiveVisualPrimitives.swift" &&
                $0.requiredFallback.localizedCaseInsensitiveContains("static state")
        })
    }

    func testEB28PlainLanguageEvidenceCoversCopyRecoveryAndScreenExplanation() {
        let requirements = EB28PlainLanguageExplanationEvidence.requirements

        XCTAssertEqual(Set(requirements.map(\.axis)), Set(AccessibilityPlainLanguageAxis.allCases))
        XCTAssertEqual(EB28PlainLanguageExplanationEvidence.ownerBatch, "EB28")
        XCTAssertFalse(EB28PlainLanguageExplanationEvidence.changesUserFacingBehavior)
        XCTAssertFalse(EB28PlainLanguageExplanationEvidence.releaseClaimsAllowed)

        for requirement in requirements {
            XCTAssertFalse(requirement.ownerFile.isEmpty)
            XCTAssertFalse(requirement.automatedProofTarget.isEmpty)
            XCTAssertFalse(requirement.requiredPattern.isEmpty)
            XCTAssertFalse(requirement.forbiddenPattern.isEmpty)
            XCTAssertFalse(requirement.userFacingBehaviorChanged)
            XCTAssertFalse(requirement.releaseClaimAllowed)
        }
    }

    func testEB28PlainLanguageEvidenceBlocksAnxietyAndAITheaterDrift() {
        let requirements = EB28PlainLanguageExplanationEvidence.requirements

        XCTAssertTrue(requirements.contains {
            $0.axis == .plainLanguageCopy &&
                $0.requiredPattern.localizedCaseInsensitiveContains("Recommended step") &&
                $0.forbiddenPattern.localizedCaseInsensitiveContains("confidence scores")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .anxietySafeRecovery &&
                $0.requiredPattern.localizedCaseInsensitiveContains("recoverable") &&
                $0.forbiddenPattern.localizedCaseInsensitiveContains("shame")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .screenExplanation &&
                $0.ownerFile == "Native/Ambitions/Domain/ScreenContractModels.swift" &&
                $0.forbiddenPattern.localizedCaseInsensitiveContains("unsupported implementation claim")
        })
    }

    func testEB29InputAlternativeEvidenceCoversVoiceMotorAndGesturePaths() {
        let requirements = EB29InputAlternativeEvidence.requirements

        XCTAssertEqual(Set(requirements.map(\.axis)), Set(AccessibilityInputAlternativeAxis.allCases))
        XCTAssertEqual(EB29InputAlternativeEvidence.ownerBatch, "EB29")
        XCTAssertFalse(EB29InputAlternativeEvidence.changesCaptureBehavior)
        XCTAssertFalse(EB29InputAlternativeEvidence.releaseClaimsAllowed)

        for requirement in requirements {
            XCTAssertFalse(requirement.ownerFile.isEmpty)
            XCTAssertFalse(requirement.automatedProofTarget.isEmpty)
            XCTAssertFalse(requirement.requiredAlternative.isEmpty)
            XCTAssertFalse(requirement.privacyBoundary.isEmpty)
            XCTAssertTrue(requirement.requiresVisibleControl)
            XCTAssertFalse(requirement.changesCaptureBehavior)
            XCTAssertFalse(requirement.releaseClaimAllowed)
        }
    }

    func testEB29InputAlternativeEvidenceKeepsVoiceCaptureReviewVisible() {
        let requirements = EB29InputAlternativeEvidence.requirements

        XCTAssertTrue(requirements.contains {
            $0.axis == .voiceFirstCapture &&
                $0.ownerFile == "Native/Ambitions/Features/Captures/CapturesScreen.swift" &&
                $0.requiredAlternative.localizedCaseInsensitiveContains("review") &&
                $0.privacyBoundary.localizedCaseInsensitiveContains("without user-visible review")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .motorAlternative &&
                $0.requiredAlternative.localizedCaseInsensitiveContains("button")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .gestureAlternative &&
                $0.ownerFile == "Sources/Components/GroupedNavigationList.swift" &&
                $0.requiredAlternative.localizedCaseInsensitiveContains("non-gesture activation")
        })
    }

    func testEB30OverloadAdaptationEvidenceCoversTodayPlanAndRecovery() {
        let requirements = EB30OverloadAdaptationEvidence.requirements

        XCTAssertEqual(Set(requirements.map(\.axis)), Set(AccessibilityOverloadAdaptationAxis.allCases))
        XCTAssertEqual(EB30OverloadAdaptationEvidence.ownerBatch, "EB30")
        XCTAssertFalse(EB30OverloadAdaptationEvidence.changesTodayOrPlanBehavior)
        XCTAssertFalse(EB30OverloadAdaptationEvidence.releaseClaimsAllowed)

        for requirement in requirements {
            XCTAssertFalse(requirement.ownerFile.isEmpty)
            XCTAssertFalse(requirement.automatedProofTarget.isEmpty)
            XCTAssertFalse(requirement.requiredAdaptation.isEmpty)
            XCTAssertFalse(requirement.forbiddenAdaptation.isEmpty)
            XCTAssertTrue(requirement.requiresUserControl)
            XCTAssertFalse(requirement.changesTodayOrPlanBehavior)
            XCTAssertFalse(requirement.releaseClaimAllowed)
        }
    }

    func testEB30OverloadAdaptationEvidenceRejectsShameAndHiddenAutomation() {
        let requirements = EB30OverloadAdaptationEvidence.requirements

        XCTAssertTrue(requirements.contains {
            $0.axis == .overloadedToday &&
                $0.ownerFile == "Native/Ambitions/Features/Today/TodayScreen.swift" &&
                $0.requiredAdaptation.localizedCaseInsensitiveContains("one clear next action") &&
                $0.forbiddenAdaptation.localizedCaseInsensitiveContains("shame")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .overloadedPlan &&
                $0.ownerFile == "Native/Ambitions/Features/Plan/PlanScreen.swift" &&
                $0.requiredAdaptation.localizedCaseInsensitiveContains("plain language") &&
                $0.forbiddenAdaptation.localizedCaseInsensitiveContains("automatic calendar mutation")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .lowLoadRecovery &&
                $0.ownerFile == "Sources/Theme/PanelDensitySize.swift" &&
                $0.requiredAdaptation.localizedCaseInsensitiveContains("larger panels") &&
                $0.forbiddenAdaptation.localizedCaseInsensitiveContains("motion-only state")
        })
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
