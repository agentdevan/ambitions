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

        XCTAssertTrue(
            AccessibilityNutritionChecklist.item(for: .voiceOver)?.verificationGuidance.contains("labels, values, hints, grouping, and reading order") ?? false
        )
        XCTAssertTrue(
            AccessibilityNutritionChecklist.item(for: .reduceMotion)?.verificationGuidance.contains("state changes, route transitions, completion, and recovery") ?? false
        )
        XCTAssertTrue(
            AccessibilityNutritionChecklist.item(for: .keyboardAndFocusSupport)?.verificationGuidance.contains("logical focus order and visible focus") ?? false
        )
        XCTAssertTrue(
            AccessibilityNutritionChecklist.item(for: .tapTargetSize)?.verificationGuidance.contains("hit-area expectations") ?? false
        )
        XCTAssertTrue(
            AccessibilityNutritionChecklist.item(for: .contrast)?.verificationGuidance.contains("contrast expectations") ?? false
        )
        XCTAssertTrue(
            AccessibilityNutritionChecklist.item(for: .colorNotOnlyMeaning)?.verificationGuidance.contains("text, icon, shape, position, or pattern") ?? false
        )
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

    func testAMB1814AutomatedNutritionGateCoversVoiceOverDynamicTypeAndReduceMotionOnly() {
        let gate = AMB1814AutomatedNutritionGate.gate
        let requirements = AMB1814AutomatedNutritionGate.requirements

        XCTAssertEqual(gate.id, "amb-1814-automated-accessibility-nutrition-gate")
        XCTAssertEqual(gate.issueID, "AMB-1814")
        XCTAssertEqual(gate.owner, "Accessibility")
        XCTAssertEqual(Set(gate.coveredAxes), Set(AccessibilityAdjustmentAxis.allCases))
        XCTAssertEqual(Set(gate.coveredCategories), [.voiceOver, .dynamicType, .reduceMotion])
        XCTAssertEqual(requirements.count, 3)
        XCTAssertTrue(gate.sourceTruth.contains("Sources/Accessibility/AccessibilityAutomatedNutritionGate.swift"))
        XCTAssertTrue(gate.sourceTruth.contains("docs/qa/accessibility/amb-1814-automated-nutrition-gate.md"))
        XCTAssertFalse(AMB1814AutomatedNutritionGate.userFacingClaimsAllowed)
        XCTAssertFalse(AMB1814AutomatedNutritionGate.releaseClaimsAllowed)

        for requirement in requirements {
            XCTAssertFalse(requirement.ownerFile.isEmpty)
            XCTAssertEqual(
                requirement.automatedProofTarget,
                "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift"
            )
            XCTAssertFalse(requirement.automatedEvidenceScope.isEmpty)
            XCTAssertFalse(requirement.requiredFallback.isEmpty)
            XCTAssertEqual(requirement.verificationStatus, .partiallySupported)
            XCTAssertFalse(requirement.publicAccessibilityClaimAllowed)
        }
    }

    func testAMB1814AutomatedNutritionGateKeepsManualAndDeviceProofBoundariesExplicit() {
        let requirements = AMB1814AutomatedNutritionGate.requirements
        let gate = AMB1814AutomatedNutritionGate.gate

        XCTAssertTrue(gate.limitations.contains { $0.localizedCaseInsensitiveContains("No XCTest execution") })
        XCTAssertTrue(gate.limitations.contains { $0.localizedCaseInsensitiveContains("No public accessibility conformance") })

        XCTAssertTrue(requirements.contains {
            $0.axis == .voiceOverOrder &&
                $0.category == .voiceOver &&
                $0.automatedEvidenceScope.localizedCaseInsensitiveContains("manual traversal") &&
                $0.manualProofStillRequired.localizedCaseInsensitiveContains("Manual VoiceOver") &&
                $0.deviceProofStillRequired.localizedCaseInsensitiveContains("Physical-device VoiceOver")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .dynamicTypeLayout &&
                $0.category == .dynamicType &&
                $0.ownerFile == "Sources/Theme/PanelDensitySize.swift" &&
                $0.requiredFallback.localizedCaseInsensitiveContains("Large text") &&
                $0.manualProofStillRequired.localizedCaseInsensitiveContains("screenshot") &&
                $0.deviceProofStillRequired.localizedCaseInsensitiveContains("Physical-device Dynamic Type")
        })
        XCTAssertTrue(requirements.contains {
            $0.axis == .reduceMotionEquivalent &&
                $0.category == .reduceMotion &&
                $0.ownerFile == "Sources/Components/DynamicAdaptiveVisualPrimitives.swift" &&
                $0.requiredFallback.localizedCaseInsensitiveContains("without motion") &&
                $0.manualProofStillRequired.localizedCaseInsensitiveContains("Reduce Motion walkthrough") &&
                $0.deviceProofStillRequired.localizedCaseInsensitiveContains("Physical-device Reduce Motion")
        })
    }

    func testAFI12AccessibilityStateProofLocksActiveFlagshipSurfaces() {
        XCTAssertEqual(AFI12AccessibilityStateProof.ownerBatch, "AFI12")
        XCTAssertFalse(AFI12AccessibilityStateProof.userFacingClaimsAllowed)
        XCTAssertEqual(AFI12AccessibilityStateProof.activeTopLevelSurfaces, [
            "Today",
            "Goals",
            "Time",
            "You"
        ])
        XCTAssertEqual(Set(AFI12AccessibilityStateProof.supportObjects), [
            "Trust Seam",
            "Quiet Reflow",
            "Receipt Surface"
        ])
        XCTAssertTrue(AFI12AccessibilityStateProof.missingActiveSurfaceProofs.isEmpty)
        XCTAssertFalse(AFI12AccessibilityStateProof.containsRetiredPlanTopLevelProof)
        XCTAssertEqual(
            AFI12AccessibilityStateProof.surfaceProofs.map(\.surface),
            AFI12AccessibilityStateProof.activeTopLevelSurfaces
        )

        let captureProof = AFI12AccessibilityStateProof.captureSurfaceProof
        XCTAssertEqual(captureProof.surface, "Capture Composer")
        XCTAssertEqual(captureProof.primaryObject, "Atmosphere Composer")
        XCTAssertTrue(captureProof.publicAccessibilityClaimAllowed == false)
        XCTAssertTrue(captureProof.voiceOverSummary.contains("Atmosphere Composer"))
        XCTAssertTrue(captureProof.manualProofStillRequired.localizedCaseInsensitiveContains("keyboard"))

        let motionProof = AFI12AccessibilityStateProof.motionBehaviorProof
        XCTAssertEqual(motionProof.surface, "Stage Motion")
        XCTAssertFalse(AFI12AccessibilityStateProof.activeTopLevelSurfaces.contains("Motion"))
        XCTAssertTrue(motionProof.voiceOverSummary.contains("without becoming a destination"))
    }

    func testAFI12SurfaceProofsPreserveMeaningWithoutPublicClaims() {
        for proof in AFI12AccessibilityStateProof.surfaceProofs {
            XCTAssertFalse(proof.primaryObject.isEmpty)
            XCTAssertFalse(proof.voiceOverSummary.isEmpty)
            XCTAssertFalse(proof.dynamicTypeFallback.isEmpty)
            XCTAssertFalse(proof.reduceMotionFallback.isEmpty)
            XCTAssertFalse(proof.nonColorStateSupport.isEmpty)
            XCTAssertFalse(proof.trustReceiptPath.isEmpty)
            XCTAssertFalse(proof.publicAccessibilityClaimAllowed)
            XCTAssertTrue(proof.manualProofStillRequired.localizedCaseInsensitiveContains("Manual VoiceOver"))
            XCTAssertTrue(proof.manualProofStillRequired.localizedCaseInsensitiveContains("Dynamic Type"))
            XCTAssertTrue(proof.manualProofStillRequired.localizedCaseInsensitiveContains("Reduce Motion"))
            XCTAssertFalse(proof.voiceOverSummary.localizedCaseInsensitiveContains("AI confidence"))
            XCTAssertFalse(proof.voiceOverSummary.localizedCaseInsensitiveContains("verified accessible"))
        }
    }

    func testAFI12SurfaceProofsSpellOutFallbacksAndReceiptsForActiveSurfaces() {
        let proofsBySurface = Dictionary(uniqueKeysWithValues: AFI12AccessibilityStateProof.surfaceProofs.map { ($0.surface, $0) })

        XCTAssertEqual(Set(proofsBySurface.keys), Set(AFI12AccessibilityStateProof.activeTopLevelSurfaces))

        assertAFI12Proof(
            proofsBySurface["Today"],
            surface: "Today",
            primaryObject: "Reality Meridian",
            voiceOverSnippets: ["Reality Meridian", "Now", "Next", "Later", "receipt availability"],
            dynamicTypeSnippets: ["active decision", "source", "recovery path", "primary action"],
            reduceMotionSnippets: ["static", "Now", "Next", "Later"],
            nonColorSnippets: ["Now", "protected", "waiting", "blocked", "recovery"],
            receiptSnippets: ["Why This?", "closure receipts"]
        )

        assertAFI12Proof(
            proofsBySurface["Goals"],
            surface: "Goals",
            primaryObject: "Life Area Atlas",
            voiceOverSnippets: ["Life Area Atlas", "life areas", "goal threads", "Today connection", "source path"],
            dynamicTypeSnippets: ["decorative geometry", "selected area", "thread", "next meaningful action"],
            reduceMotionSnippets: ["static", "selected state", "native drill-down"],
            nonColorSnippets: ["Pinned", "selected", "stale", "blocked", "Today-linked"],
            receiptSnippets: ["Goal thread proof", "decision receipts"]
        )

        let captureProof = AFI12AccessibilityStateProof.captureSurfaceProof
        assertAFI12Proof(
            captureProof,
            surface: "Capture Composer",
            primaryObject: "Atmosphere Composer",
            voiceOverSnippets: ["Atmosphere Composer", "input purpose", "text or voice action", "route result", "correction path"],
            dynamicTypeSnippets: ["composer", "add action", "route result", "correction choices"],
            reduceMotionSnippets: ["static", "Needs a Place", "Ready to Place", "Grow into Goal"],
            nonColorSnippets: ["Route confidence", "private item", "needs-place", "correction"],
            receiptSnippets: ["placement", "correction receipts", "undo"]
        )

        assertAFI12Proof(
            AFI12AccessibilityStateProof.motionBehaviorProof,
            surface: "Stage Motion",
            primaryObject: "Stage Motion",
            voiceOverSnippets: ["activity path", "proof density", "trust links", "without becoming a destination"],
            dynamicTypeSnippets: ["path", "trace summary", "trust route", "primary action"],
            reduceMotionSnippets: ["static", "path", "proof summary", "next-action"],
            nonColorSnippets: ["Active", "blocked", "stalled", "recovery", "line-order"],
            receiptSnippets: ["Goal and Time proofs", "source", "receipt"]
        )

        assertAFI12Proof(
            proofsBySurface["Time"],
            surface: "Time",
            primaryObject: "Life Calendar",
            voiceOverSnippets: ["Life Calendar", "horizon", "open time", "goal time", "protected time", "pressure", "manual mode"],
            dynamicTypeSnippets: ["horizon", "pressure source", "protected time", "Shape week", "Review pressure"],
            reduceMotionSnippets: ["static", "before/after summary", "explicit confirmation"],
            nonColorSnippets: ["Pressure", "protected", "open", "unavailable", "source-review"],
            receiptSnippets: ["Quiet Reflow", "preview", "source", "confirmation", "receipt"]
        )

        assertAFI12Proof(
            proofsBySurface["You"],
            surface: "You",
            primaryObject: "User System Profile",
            voiceOverSnippets: ["User System Profile", "Planning Setup", "Privacy & automation", "Privacy", "Receipts & History", "Defaults"],
            dynamicTypeSnippets: ["grouped-navigation behavior", "large text sizes", "trust", "privacy", "receipts", "setup", "defaults"],
            reduceMotionSnippets: ["disclosure state"],
            nonColorSnippets: ["Trust", "private", "unavailable", "manual", "review", "future-owned"],
            receiptSnippets: ["Trust Center", "What Ambitions Knows", "Receipts & History"]
        )
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
                $0.ownerFile == "Native/Ambitions/Quality/ScreenContracts/ScreenContractModels.swift" &&
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
                $0.ownerFile == "Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift" &&
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

    func testEB30OverloadAdaptationEvidenceCoversTodayTimeAndRecovery() {
        let requirements = EB30OverloadAdaptationEvidence.requirements

        XCTAssertEqual(Set(requirements.map(\.axis)), Set(AccessibilityOverloadAdaptationAxis.allCases))
        XCTAssertEqual(EB30OverloadAdaptationEvidence.ownerBatch, "EB30")
        XCTAssertFalse(EB30OverloadAdaptationEvidence.changesTodayOrTimeBehavior)
        XCTAssertFalse(EB30OverloadAdaptationEvidence.releaseClaimsAllowed)

        for requirement in requirements {
            XCTAssertFalse(requirement.ownerFile.isEmpty)
            XCTAssertFalse(requirement.automatedProofTarget.isEmpty)
            XCTAssertFalse(requirement.requiredAdaptation.isEmpty)
            XCTAssertFalse(requirement.forbiddenAdaptation.isEmpty)
            XCTAssertTrue(requirement.requiresUserControl)
            XCTAssertFalse(requirement.changesTodayOrTimeBehavior)
            XCTAssertFalse(requirement.releaseClaimAllowed)
        }
    }

    func testEB30OverloadAdaptationEvidenceRejectsShameAndHiddenAutomation() {
        let requirements = EB30OverloadAdaptationEvidence.requirements

        XCTAssertTrue(requirements.contains {
            $0.axis == .overloadedToday &&
                $0.ownerFile == "Native/Ambitions/Surfaces/Today/TodaySurface.swift" &&
                $0.requiredAdaptation.localizedCaseInsensitiveContains("one clear next action") &&
                $0.forbiddenAdaptation.localizedCaseInsensitiveContains("shame")
        })
        let hasOverloadedTimeShapeRequirement = requirements.contains { requirement in
            requirement.axis == .overloadedTimeShape &&
                requirement.ownerFile == "Native/Ambitions/Surfaces/Time/TimeSurface.swift" &&
                requirement.requiredAdaptation.localizedCaseInsensitiveContains("plain language") &&
                requirement.forbiddenAdaptation.localizedCaseInsensitiveContains("automatic calendar mutation")
        }
        XCTAssertTrue(hasOverloadedTimeShapeRequirement)
        XCTAssertTrue(requirements.contains {
            $0.axis == .lowLoadRecovery &&
                $0.ownerFile == "Sources/Theme/PanelDensitySize.swift" &&
                $0.requiredAdaptation.localizedCaseInsensitiveContains("larger panels") &&
                $0.forbiddenAdaptation.localizedCaseInsensitiveContains("motion-only state")
        })
    }

    static let d21ExpectedAuditOrder = [
        "today",
        "reviews-archive",
        "rich-panels",
        "you",
        "grouped-navigation-list",
        "goal-detail",
        "capture",
        "time",
        "trust-center-what-ambitions-knows",
        "quiet-command-sheet-smart-attachment",
        "goals",
        "life-areas-north-stars",
        "external-surfaces"
    ]

    func assertAFI12Proof(
        _ proof: AFI12AccessibilitySurfaceProof?,
        surface: String,
        primaryObject: String,
        voiceOverSnippets: [String],
        dynamicTypeSnippets: [String],
        reduceMotionSnippets: [String],
        nonColorSnippets: [String],
        receiptSnippets: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNotNil(proof, "Missing AFI12 proof for \(surface).", file: file, line: line)

        guard let proof else { return }

        XCTAssertEqual(proof.surface, surface, file: file, line: line)
        XCTAssertEqual(proof.primaryObject, primaryObject, file: file, line: line)
        XCTAssertFalse(proof.publicAccessibilityClaimAllowed, file: file, line: line)

        assertContains(proof.voiceOverSummary, snippets: voiceOverSnippets, file: file, line: line)
        assertContains(proof.dynamicTypeFallback, snippets: dynamicTypeSnippets, file: file, line: line)
        assertContains(proof.reduceMotionFallback, snippets: reduceMotionSnippets, file: file, line: line)
        assertContains(proof.nonColorStateSupport, snippets: nonColorSnippets, file: file, line: line)
        assertContains(proof.trustReceiptPath, snippets: receiptSnippets, file: file, line: line)
        assertContains(proof.manualProofStillRequired, snippets: ["Manual VoiceOver", "Dynamic Type", "Reduce Motion"], file: file, line: line)
    }

    func assertContains(
        _ text: String,
        snippets: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for snippet in snippets {
            XCTAssertTrue(text.localizedCaseInsensitiveContains(snippet), "Expected '\(text)' to contain '\(snippet)'.", file: file, line: line)
        }
    }
}
