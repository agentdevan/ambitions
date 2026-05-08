import AmbitionsDesignSystem
import XCTest

final class InteractionMotionHapticsDesignSystemTests: XCTestCase {
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
            XCTAssertFalse(token.accessibilitySummary.isEmpty)
            XCTAssertTrue(token.accessibilitySummary.localizedCaseInsensitiveContains("Reduce Motion"))
        }
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
    }

    func testFCP09ObjectMotionPoliciesCoverFlagshipObjects() {
        XCTAssertEqual(Set(AmbitionFlagshipMotionObject.allCases), [
            .startHere,
            .realityRail,
            .receiptDrawer,
            .sourceFold,
            .missionControlTimeSpine,
            .actionClosureDiamond,
            .lifeShapeMap,
            .captureComposer
        ])

        let titles = Set(AmbitionFlagshipMotionObject.allCases.map { $0.motionPolicy.objectTitle })
        XCTAssertEqual(titles, [
            "Start Here",
            "Reality Meridian",
            "Receipt Drawer",
            "Source Fold",
            "MissionControlTimeSpine",
            "Action Closure Diamond",
            "LifeShape Map",
            "Capture Atmosphere Composer"
        ])
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
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Completed, Now, Friction, Next, Horizon"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("capacity"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("calendar clone"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("habit"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("streak"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("score"))
    }
}
