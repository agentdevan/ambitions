import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayFlagshipCalibrationFixtureTests: XCTestCase {
    func testFixtureFamilyKeepsDeterministicIdentityAndBootstrapNarrative() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(fixture.familyID, "today-flagship/preparing-for-baby/still-counts/v1")
        XCTAssertEqual(fixture.presentContext.dateISO8601, "2026-07-23")
        XCTAssertEqual(fixture.presentContext.relationship, "Thursday · Home before dinner")
        XCTAssertEqual(fixture.primaryStep.id, "step.nursery-ready-for-crib")
        XCTAssertEqual(fixture.primaryStep.parentPursuitID, "goal.welcome-baby-home")
        XCTAssertEqual(fixture.primaryStep.parentPursuitTitle, "Welcome our baby home")
        XCTAssertEqual(fixture.revealedStartHereStep.id, "step.send-launch-brief")
        XCTAssertNotEqual(fixture.primaryStep.id, fixture.revealedStartHereStep.id)
        XCTAssertTrue(fixture.isSynthetic)
    }

    func testFixtureSeparatesCurrentProposedAndSettledTruth() {
        let step = TodayFlagshipCalibrationFixture.preparingForBaby.primaryStep

        XCTAssertEqual(
            step.currentAcceptedTruth,
            "The corner is cleared and the paint sample is chosen."
        )
        XCTAssertEqual(
            step.stillCountsProposal.proposedTruth,
            "Record the cleared corner and paint sample as meaningful progress."
        )
        XCTAssertEqual(
            step.stillCountsProposal.settledTruth,
            "The cleared corner and paint sample now count toward the nursery."
        )
        XCTAssertNotEqual(step.currentAcceptedTruth, step.stillCountsProposal.proposedTruth)
        XCTAssertNotEqual(step.currentAcceptedTruth, step.stillCountsProposal.settledTruth)
        XCTAssertEqual(step.stillCountsProposal.outcomeTitle, "Still counts")
    }

    func testR02ProductLanguagePreservesMeaningWithoutInternalPhrases() throws {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let step = fixture.primaryStep

        XCTAssertEqual(step.title, "Make the nursery ready for the crib")
        XCTAssertEqual(
            step.whyItFitsNow,
            "This is the smallest useful step before protected family time."
        )
        XCTAssertEqual(
            step.materialConsequence,
            "It keeps the room moving without taking over the evening."
        )
        XCTAssertEqual(step.temporalContext.relationship, "Before family time")
        XCTAssertEqual(step.stillCountsProposal.commitActionTitle, "Record progress")
        XCTAssertEqual(
            fixture.recovery.availableChoices.map(\.title),
            ["Continue where you left off", "Leave this for later"]
        )

        let prohibited = [
            "Exact Step",
            "Current · Accepted",
            "Proposed · Not yet accepted",
            "Exact consequence",
            "Affected relationship",
            "Proof posture",
            "Time-owned",
            "authoritative until",
            "Receipt and History",
            "Added to Proof"
        ]
        let visibleFixtureCopy = [
            step.title,
            step.currentAcceptedTruth,
            step.whyItFitsNow,
            step.materialConsequence,
            step.temporalContext.relationship,
            step.primaryActionTitle,
            step.stillCountsProposal.proposedTruth,
            step.stillCountsProposal.settledTruth,
            step.stillCountsProposal.exactConsequence,
            step.stillCountsProposal.affectedLineage,
            step.stillCountsProposal.proofRequirement,
            step.stillCountsProposal.commitActionTitle,
            fixture.receipt.recordedLabel,
            fixture.receipt.receiptSummary,
            fixture.receipt.historySummary,
            fixture.receipt.proofLabel,
            fixture.recovery.interruptionTitle,
            fixture.recovery.interruptionDetail,
            fixture.recovery.lastSavedProgress
        ] + fixture.recovery.availableChoices.flatMap { [$0.title, $0.consequence] }

        let visibleViews = try primaryViewSource()
        for phrase in prohibited {
            XCTAssertFalse(
                visibleFixtureCopy.contains(where: { $0.localizedCaseInsensitiveContains(phrase) }),
                "Fixture product copy exposes prohibited phrase: \(phrase)"
            )
            XCTAssertFalse(
                visibleViews.localizedCaseInsensitiveContains(phrase),
                "Primary view source exposes prohibited phrase: \(phrase)"
            )
        }
    }

    func testR02FocusedStepDoesNotExposePassiveAlternativeOutcomeNames() throws {
        let visibleViews = try primaryViewSource()

        XCTAssertFalse(visibleViews.contains("Done · Move it · Waiting · Blocked · Not needed"))
        XCTAssertFalse(visibleViews.contains("Other outcomes"))
        XCTAssertFalse(visibleViews.contains("Choose another outcome"))
    }

    func testFixtureRetainsLineageConsequenceTimeProofAndReceiptHistoryCapability() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let step = fixture.primaryStep

        XCTAssertFalse(step.whyItFitsNow.isEmpty)
        XCTAssertFalse(step.materialConsequence.isEmpty)
        XCTAssertEqual(step.temporalContext.exactTime, "4:30 PM")
        XCTAssertEqual(step.temporalContext.owner, "Time")
        XCTAssertTrue(step.stillCountsProposal.createsProof)
        XCTAssertTrue(step.stillCountsProposal.createsReceipt)
        XCTAssertTrue(step.stillCountsProposal.appearsInHistory)
        XCTAssertFalse(step.stillCountsProposal.inverseAvailable)
        XCTAssertEqual(fixture.receipt.id, "receipt.step.nursery-ready-for-crib.still-counts")
        XCTAssertEqual(fixture.receipt.historyID, "history.step.nursery-ready-for-crib")
    }

    func testSupportingTimelineIsObjectLedAndPreservesProtectedReality() {
        let timeline = TodayFlagshipCalibrationFixture.preparingForBaby.timeline

        XCTAssertEqual(timeline.map(\.id), [
            "timeline.nursery-paint-sample",
            "timeline.work-launch-brief",
            "timeline.family-prenatal-walk"
        ])
        XCTAssertEqual(timeline.first?.objectTitle, "Paint the nursery sample")
        XCTAssertEqual(timeline.first?.timeLabel, "10:30 AM")
        XCTAssertTrue(timeline.contains(where: { $0.isProtected }))
        XCTAssertTrue(timeline.contains(where: { $0.isFixed }))
    }

    func testReturnedTodayProjectionShowsPromotedStepOnlyAsStartHere() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(
            fixture.timeline.filter {
                $0.canonicalObjectID == fixture.revealedStartHereStep.id
            }.count,
            1
        )
        XCTAssertFalse(
            fixture.returnedTodayTimeline.contains {
                $0.canonicalObjectID == fixture.revealedStartHereStep.id
            }
        )
        XCTAssertTrue(
            fixture.returnedTodayTimeline.contains {
                $0.canonicalObjectID == "step.nursery-paint-sample"
            }
        )
    }

    func testReturnAndRecoveryContractsUseStableObjectScopedAnchors() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(fixture.returnContract.settledStepID, fixture.primaryStep.id)
        XCTAssertEqual(fixture.returnContract.newStartHereStepID, fixture.revealedStartHereStep.id)
        XCTAssertEqual(
            fixture.returnContract.focusAnchorID,
            "today.settled.step.nursery-ready-for-crib"
        )
        XCTAssertEqual(fixture.recovery.stepID, fixture.primaryStep.id)
        XCTAssertEqual(
            fixture.recovery.lastSavedProgress,
            "Cleared the crib corner and kept the paint sample decision."
        )
        XCTAssertEqual(fixture.recovery.availableChoices.map(\.id), [
            "recovery.continue-saved-progress",
            "recovery.keep-step"
        ])
    }

    func testFixtureProvidesLongLocalizationAndDenseTodayStressWithoutNewPolicy() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(fixture.longContent.familyID, fixture.familyID)
        XCTAssertGreaterThan(
            fixture.longContent.primaryStep.title.count,
            fixture.primaryStep.title.count
        )
        XCTAssertEqual(fixture.denseToday.familyID, fixture.familyID)
        XCTAssertGreaterThan(fixture.denseToday.timeline.count, fixture.timeline.count)
        XCTAssertTrue(fixture.denseToday.timeline.filter(\.isProtected).count >= 2)
        XCTAssertTrue(fixture.denseToday.timeline.contains(where: \.isFixed))
    }

    func testArabicSaudiEvaluationFixtureUsesRealLocalizedRTLContent() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation
        let combined = [
            fixture.presentContext.crownTitle,
            fixture.presentContext.relationship,
            fixture.interfaceCopy.startHereTitle,
            fixture.interfaceCopy.rightNowTitle,
            fixture.interfaceCopy.reviewTitle,
            fixture.interfaceCopy.reviewChangeTitle,
            fixture.interfaceCopy.reviewRelationshipTitle,
            fixture.interfaceCopy.cancelTitle,
            fixture.primaryStep.title,
            fixture.primaryStep.currentAcceptedTruth,
            fixture.primaryStep.whyItFitsNow,
            fixture.primaryStep.materialConsequence,
            fixture.primaryStep.temporalContext.relationship,
            fixture.primaryStep.primaryActionTitle,
            fixture.primaryStep.stillCountsProposal.outcomeTitle,
            fixture.primaryStep.stillCountsProposal.commitActionTitle
        ].joined(separator: " ")

        XCTAssertEqual(fixture.familyID, "today-flagship/preparing-for-baby/still-counts/v1")
        XCTAssertEqual(fixture.interfaceCopy.localeIdentifier, "ar-SA")
        XCTAssertTrue(combined.unicodeScalars.contains(where: { (0x0600...0x06FF).contains($0.value) }))
        XCTAssertTrue(fixture.primaryStep.title.contains("Ambitions S10"))
        XCTAssertGreaterThan(fixture.primaryStep.materialConsequence.count, 80)
        XCTAssertNotEqual(fixture.primaryStep.temporalContext.exactTime, "4:30 PM")
        XCTAssertTrue(fixture.presentContext.relationship.contains("2026") == false)
    }

    func testNavigationOrderRemainsLockedAcrossOrdinaryAndAdaptiveChrome() {
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.roots.map(\.title),
            ["Today", "Goals", "Time", "You"]
        )
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.globalActions.map(\.title),
            ["Search", "Capture"]
        )
        XCTAssertTrue(TodayFlagshipNavigationCommand.today.isSelectedRoot)
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.roots.filter(\.isSelectedRoot),
            [.today]
        )
    }

    func testB01SourceDeclaresArticulatedSemanticAnatomyWithoutObsoleteShellControls() throws {
        let visibleViews = try primaryViewSource()

        let requiredSemanticIdentifiers = [
            "tfcs-start-here-object",
            "tfcs-timeline-row-",
            "tfcs-dock-shell-peek",
            "tfcs-focused-object-field",
            "tfcs-review-comparison",
            "tfcs-settlement-field",
            "tfcs-recovery-progress-field"
        ]
        for identifier in requiredSemanticIdentifiers {
            XCTAssertTrue(
                visibleViews.contains(identifier),
                "B01 semantic anatomy is missing \(identifier)"
            )
        }

        XCTAssertFalse(visibleViews.contains("TabView("))
        XCTAssertFalse(visibleViews.contains("case inbox"))
        XCTAssertFalse(visibleViews.contains("case calendar"))
        XCTAssertFalse(visibleViews.contains("Search in crown"))
        XCTAssertFalse(visibleViews.contains("Capture in crown"))
    }

    func testB02GrammarUsesSystemTypeMatteContentAndNonColorNodes() throws {
        let shapeLabels = TodayOpenContinuityNodeKind.allCases.map(\.nonColorShapeLabel)

        XCTAssertEqual(shapeLabels.count, 9)
        XCTAssertEqual(Set(shapeLabels).count, shapeLabels.count)
        XCTAssertFalse(shapeLabels.contains(where: \.isEmpty))

        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceRoot = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
        let grammarSources = try [
            "TodayOpenContinuityGrammar.swift",
            "TodayOpenContinuitySpine.swift",
            "TodayFlagshipCalibrationStyle.swift",
            "TodayFlagshipArticulatedAnatomy.swift"
        ].map { file in
            try String(
                contentsOf: sourceRoot.appendingPathComponent(file),
                encoding: .utf8
            )
        }.joined(separator: "\n")

        XCTAssertFalse(grammarSources.contains("Font.custom"))
        XCTAssertFalse(grammarSources.contains(".glassEffect("))
        XCTAssertFalse(grammarSources.contains("TabView("))
        XCTAssertFalse(grammarSources.contains("import AmbitionsFlagshipUI"))
        XCTAssertFalse(grammarSources.contains("import AmbitionsFlagshipFoundation"))
        XCTAssertTrue(
            grammarSources.contains("@Environment(\\.accessibilityDifferentiateWithoutColor)")
        )
        XCTAssertFalse(grammarSources.contains("let differentiateWithoutColor"))
    }

    private func primaryViewSource() throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceRoot = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
        let files = [
            "TodayFlagshipArticulatedAnatomy.swift",
            "TodayFlagshipCalibrationView.swift",
            "TodayFlagshipFocusedStepView.swift",
            "TodayFlagshipNavigationChrome.swift",
            "TodayFlagshipRecoveryReviewView.swift",
            "TodayFlagshipReviewView.swift"
        ]
        return try files.map { file in
            try String(
                contentsOf: sourceRoot.appendingPathComponent(file),
                encoding: .utf8
            )
        }.joined(separator: "\n")
    }
}
