import SwiftUI
import AmbitionsDesignSystem
import XCTest

final class InteractionMotionHapticsDesignSystemTests: XCTestCase {
    func testAFEP007SemanticCompilerMapsMeaningToTypographyColorMaterialSymbolMotionAndHaptics() {
        let cases: [(AmbitionSemanticCompilerInput, AmbitionSemanticCompilerOutput)] = AmbitionSemanticCompilerInput.allCases.map {
            ($0, AmbitionSemanticCompiler.compile($0))
        }

        XCTAssertEqual(cases.count, AmbitionSemanticCompilerInput.allCases.count)

        let expectations: [AmbitionSemanticCompilerInput: (
            typography: AmbitionSemanticTypographyRole,
            visualState: AmbitionSemanticState,
            colorTokenName: String,
            materialRole: AmbitionSemanticMaterialRole,
            symbolName: String,
            motionToken: AmbitionInteractionToken,
            hapticIntent: AmbitionTheme.HapticIntent?
        )] = [
            .startHereRecommendation: (
                typography: .heroDisplay,
                visualState: .focus,
                colorTokenName: "semanticColors.focus",
                materialRole: .hero,
                symbolName: "sparkles",
                motionToken: .panelReveal,
                hapticIntent: nil
            ),
            .routeOrientation: (
                typography: .title,
                visualState: .focus,
                colorTokenName: "semanticColors.focus",
                materialRole: .band,
                symbolName: "arrow.triangle.branch",
                motionToken: .routeOrientation,
                hapticIntent: .routeChange
            ),
            .proofReceipt: (
                typography: .sectionTitle,
                visualState: .success,
                colorTokenName: "colors.success",
                materialRole: .elevated,
                symbolName: "checkmark.seal.fill",
                motionToken: .proofConfirm,
                hapticIntent: .completion
            ),
            .sourceFreshness: (
                typography: .bodySecondary,
                visualState: .review,
                colorTokenName: "semanticColors.review",
                materialRole: .overlay,
                symbolName: "doc.text.magnifyingglass",
                motionToken: .sourceCheck,
                hapticIntent: nil
            ),
            .captureDraft: (
                typography: .bodyPrimary,
                visualState: .capture,
                colorTokenName: "semanticColors.capture",
                materialRole: .widget,
                symbolName: "tray.and.arrow.down.fill",
                motionToken: .panelReveal,
                hapticIntent: nil
            ),
            .lifeShapeReview: (
                typography: .titleCompact,
                visualState: .calendarDerived,
                colorTokenName: "semanticColors.calendarDerived",
                materialRole: .quietGlass,
                symbolName: "calendar.badge.clock",
                motionToken: .reviewRequired,
                hapticIntent: nil
            ),
            .recoveryClosure: (
                typography: .bodyEmphasized,
                visualState: .recovery,
                colorTokenName: "semanticColors.recovery",
                materialRole: .success,
                symbolName: "arrow.uturn.backward.circle.fill",
                motionToken: .correctionNeeded,
                hapticIntent: .correction
            ),
            .privacyBoundary: (
                typography: .caption,
                visualState: .protected,
                colorTokenName: "semanticColors.protected",
                materialRole: .graphiteRecess,
                symbolName: "lock.shield.fill",
                motionToken: .privacyBoundary,
                hapticIntent: nil
            ),
            .unsafeRedirect: (
                typography: .caption,
                visualState: .risk,
                colorTokenName: "semanticColors.risk",
                materialRole: .warning,
                symbolName: "exclamationmark.triangle.fill",
                motionToken: .unsafeRedirect,
                hapticIntent: nil
            ),
            .localOnlySettle: (
                typography: .micro,
                visualState: .protected,
                colorTokenName: "semanticColors.protected",
                materialRole: .canvas,
                symbolName: "lock.fill",
                motionToken: .localOnlySettle,
                hapticIntent: nil
            )
        ]

        for (input, output) in cases {
            let expected = expectations[input]
            XCTAssertNotNil(expected, input.rawValue)
            guard let expected else { continue }

            XCTAssertEqual(output.input, input, input.rawValue)
            XCTAssertEqual(output.typographyRole, expected.typography, input.rawValue)
            XCTAssertEqual(output.visualState, expected.visualState, input.rawValue)
            XCTAssertEqual(output.colorTokenName, expected.colorTokenName, input.rawValue)
            XCTAssertEqual(output.materialRole, expected.materialRole, input.rawValue)
            XCTAssertEqual(output.symbolName, expected.symbolName, input.rawValue)
            XCTAssertEqual(output.motionToken, expected.motionToken, input.rawValue)
            XCTAssertEqual(output.hapticPolicy.intent, expected.hapticIntent, input.rawValue)
            XCTAssertFalse(output.reducedMotionEquivalent.isEmpty, input.rawValue)
            XCTAssertFalse(output.nonColorCues.isEmpty, input.rawValue)
            XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Typography:"), input.rawValue)
            XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Visual state:"), input.rawValue)
            XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Color token:"), input.rawValue)
            XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Material role:"), input.rawValue)
            XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Non-color cues:"), input.rawValue)
            XCTAssertFalse(output.accessibilitySummary.localizedCaseInsensitiveContains("color only"), input.rawValue)
        }
    }

    func testAFEP007SemanticCompilerAttachesInspectionSeamsWhenProvenanceIsReferenced() {
        let provenance = AmbitionSemanticCausalityContext.runtimeProvenanceInspection
        let output = AmbitionSemanticCompiler.compile(.proofReceipt, causalityContext: provenance)

        XCTAssertEqual(output.causalityContext, provenance)
        XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("SourceRecord"))
        XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("ReplayTrace"))
        XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("Search Ambitions"))
        XCTAssertTrue(output.accessibilitySummary.localizedCaseInsensitiveContains("You / Search Ambitions"))
    }

    func testSI12InteractionTokensCoverMeaningfulMotionPurposes() {
        XCTAssertEqual(Set(AmbitionInteractionPurpose.allCases), [
            .orientation,
            .confirmation,
            .uncertaintyReduction
        ])

        let purposes = Set(AmbitionInteractionToken.allCases.map(\.purpose))
        XCTAssertEqual(purposes, Set(AmbitionInteractionPurpose.allCases))
    }

    func testSI12InteractionTokensExposeReduceMotionEquivalents() {
        for token in AmbitionInteractionToken.allCases {
            XCTAssertFalse(token.title.isEmpty)
            XCTAssertFalse(token.reduceMotionEquivalent.isEmpty)
            XCTAssertFalse(token.hapticBoundary.isEmpty)
            XCTAssertFalse(token.accessibilitySummary.isEmpty)
            XCTAssertTrue(token.accessibilitySummary.localizedCaseInsensitiveContains("Reduce Motion"))
            XCTAssertTrue(token.accessibilitySummary.localizedCaseInsensitiveContains("Haptics"))
            XCTAssertTrue(token.accessibilitySummary.localizedCaseInsensitiveContains(token.hapticBoundary))
        }
    }

    func testAMB510LuminousTraceRolesExposeStaticOriginAndRelationshipMeaning() {
        XCTAssertEqual(Set(LuminousTraceModifier.Role.allCases), [
            .relationship,
            .proof,
            .reflow,
            .route,
            .receiptResolve,
            .activeNodeTether,
            .staticOrigin
        ])

        for role in LuminousTraceModifier.Role.allCases {
            XCTAssertFalse(role.summary.isEmpty, role.rawValue)
            XCTAssertFalse(role.originLabel.isEmpty, role.rawValue)
            XCTAssertFalse(role.summary.localizedCaseInsensitiveContains("ambient brand"), role.rawValue)
            XCTAssertFalse(role.summary.localizedCaseInsensitiveContains("decorative"), role.rawValue)
        }

        XCTAssertEqual(Set(LuminousTraceModifier.Intensity.allCases), [
            .quiet,
            .standard,
            .emphasized
        ])
    }

    func testSI12HapticsRemainOptionalAndUserInitiated() {
        let hapticTokens = AmbitionInteractionToken.allCases.filter(\.allowsAutomaticHaptics)

        XCTAssertEqual(Set(hapticTokens), [
            .routeOrientation,
            .selectionConfirm,
            .proofConfirm,
            .correctionNeeded
        ])

        for token in AmbitionInteractionToken.allCases where token.purpose != .confirmation {
            if token.allowsAutomaticHaptics {
                XCTAssertTrue(
                    token.hapticPolicy.intent == .routeChange ||
                    token.hapticPolicy.intent == .correction
                )
            }
        }
    }

    func testSI12LDIHookStatesStayVisualWithoutRuntimeClaims() {
        let ldiVisualTokens: Set<AmbitionInteractionToken> = [
            .correctionNeeded,
            .sourceCheck,
            .reviewRequired,
            .privacyBoundary,
            .unsafeRedirect,
            .recompilePending,
            .localOnlySettle
        ]

        XCTAssertTrue(ldiVisualTokens.isSubset(of: Set(AmbitionInteractionToken.allCases)))

        let combined = ldiVisualTokens
            .map { "\($0.title) \($0.reduceMotionEquivalent)" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("cloud synced"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("server"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("automatic commitment"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("color only"))
    }

    func testFCP09ObjectMotionPoliciesCoverFlagshipObjects() {
        XCTAssertEqual(Set(AmbitionFlagshipMotionObject.allCases), [
            .startHere,
            .realityMeridian,
            .receiptDrawer,
            .sourceFold,
            .missionControlTimeSpine,
            .actionClosureDiamond,
            .lifeShapeField,
            .captureComposer
        ])

        let titles = Set(AmbitionFlagshipMotionObject.allCases.map { $0.motionPolicy.objectTitle })
        XCTAssertEqual(titles, [
            "Start Here",
            "Reality Meridian",
            "Receipt Drawer",
            "Source Fold",
            "Constellation Atlas",
            "Action Closure Diamond",
            "LifeShape Field",
            "Capture Atmosphere Composer"
        ])

        XCTAssertEqual(AmbitionFlagshipMotionObject.realityRail, .realityMeridian)
        XCTAssertEqual(AmbitionFlagshipMotionObject.lifeShapeMap, .lifeShapeField)
    }

    func testFCP09ObjectMotionPoliciesPreserveMeaningWithoutMotion() {
        for object in AmbitionFlagshipMotionObject.allCases {
            let policy = object.motionPolicy

            XCTAssertTrue(policy.preservesMeaningWithoutMotion, policy.objectTitle)
            XCTAssertFalse(policy.stateMeaning.isEmpty, policy.objectTitle)
            XCTAssertFalse(policy.hapticBoundary.isEmpty, policy.objectTitle)
            XCTAssertFalse(policy.accessibilitySummary.isEmpty, policy.objectTitle)
            XCTAssertTrue(policy.accessibilitySummary.localizedCaseInsensitiveContains("Reduce Motion"), policy.objectTitle)
        }
    }

    func testFCP09ObjectMotionPoliciesKeepHapticsUserInitiatedAndBounded() {
        for object in AmbitionFlagshipMotionObject.allCases {
            let policy = object.motionPolicy

            if policy.hapticPolicy.intent != nil {
                XCTAssertTrue(
                    policy.hapticBoundary.localizedCaseInsensitiveContains("user"),
                    "\(policy.objectTitle) haptics must stay user initiated."
                )
            }

            XCTAssertFalse(policy.hapticBoundary.localizedCaseInsensitiveContains("automatic"), policy.objectTitle)
            XCTAssertFalse(policy.accessibilitySummary.localizedCaseInsensitiveContains("confetti"), policy.objectTitle)
            XCTAssertFalse(policy.accessibilitySummary.localizedCaseInsensitiveContains("reward"), policy.objectTitle)
            XCTAssertFalse(policy.accessibilitySummary.localizedCaseInsensitiveContains("AI confidence"), policy.objectTitle)
        }
    }

    func testFCP09ObjectMotionPoliciesRespectProductBoundaries() {
        let combined = AmbitionFlagshipMotionObject.allCases
            .map {
                let policy = $0.motionPolicy
                return [
                    policy.objectTitle,
                    policy.owner,
                    policy.stateMeaning,
                    policy.reduceMotionEquivalent,
                    policy.hapticBoundary
                ].joined(separator: " ")
            }
            .joined(separator: " ")

        XCTAssertTrue(combined.localizedCaseInsensitiveContains("placement appears after content"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("life areas, proof, pressure, and next steps"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("capacity"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("calendar clone"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("habit"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("streak"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("score"))
    }

    @MainActor
    func testSI12TactilePrimitivesExposeAccessibilityAndReduceMotionContracts() {
        let afi = AfiFlowIndicator()
        XCTAssertTrue(afi.accessibilityValue.localizedCaseInsensitiveContains("Reduce Motion"))
        XCTAssertTrue(afi.accessibilityValue.localizedCaseInsensitiveContains("Non-color cue"))

        let quiet = QuietBreatheIndicator()
        XCTAssertTrue(quiet.accessibilityValue.localizedCaseInsensitiveContains("LOCAL ONLY"))
        XCTAssertTrue(quiet.accessibilityValue.localizedCaseInsensitiveContains("static dot"))

        let proof = ProofPulseBadge()
        XCTAssertTrue(proof.accessibilityValue.localizedCaseInsensitiveContains("Verified"))
        XCTAssertTrue(proof.accessibilityValue.localizedCaseInsensitiveContains("static badge"))

        let anchorMeter = AnchorDotMeter()
        XCTAssertTrue(anchorMeter.accessibilityValue.localizedCaseInsensitiveContains("filled dots"))
        XCTAssertTrue(anchorMeter.accessibilityValue.localizedCaseInsensitiveContains("outlined dots"))

        let tension = CapacitiveTensionBar(stressScore: 0.88)
        XCTAssertTrue(tension.accessibilityValue.localizedCaseInsensitiveContains("Overcommitted"))
        XCTAssertTrue(tension.accessibilityValue.localizedCaseInsensitiveContains("Non-color cue"))

        let foldOut = AuditFoldOut(title: "On-device audit logs", logs: ["One", "Two"])
        XCTAssertTrue(foldOut.accessibilityValue.localizedCaseInsensitiveContains("Closed"))
        XCTAssertTrue(foldOut.accessibilityValue.contains("2 log entries"))

        let dial = TactileDialControl(threshold: .constant(0.72))
        XCTAssertTrue(dial.accessibilityValue.localizedCaseInsensitiveContains("72 percent"))
        XCTAssertTrue(dial.accessibilityValue.localizedCaseInsensitiveContains("Non-color cue"))

        let toggle = TactileToggleSeam(title: "Optional cadence", isOn: .constant(true))
        XCTAssertEqual(toggle.accessibilityValue, "On")
    }
}
