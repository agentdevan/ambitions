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
            "I primed the wall and tested the new color."
        )
        XCTAssertEqual(
            step.stillCountsProposal.settledTruth,
            "I primed the wall and tested the new color."
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
        XCTAssertEqual(
            "\(step.temporalContext.exactTime) · \(step.temporalContext.relationship)",
            "Available now · before 2:00 PM handoff"
        )
        XCTAssertEqual(step.stillCountsProposal.commitActionTitle, "Record progress")
        XCTAssertEqual(
            fixture.recovery.availableChoices.map(\.title),
            ["Continue Where You Left Off", "Leave for Later"]
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
        XCTAssertEqual(step.temporalContext.exactTime, "Available now")
        XCTAssertEqual(
            step.temporalContext.relationship,
            "before 2:00 PM handoff"
        )
        XCTAssertEqual(fixture.revealedStartHereStep.temporalContext.exactTime, "2:00 PM")
        XCTAssertEqual(step.temporalContext.fullDayTimeLabel, "10:30 AM")
        XCTAssertEqual(
            fixture.timeline.first(where: { $0.canonicalObjectID == "step.send-launch-brief" })?.timeLabel,
            "2:00 PM"
        )
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
            "timeline.work-launch-brief",
            "timeline.family-time",
            "timeline.open-after-family"
        ])
        XCTAssertEqual(timeline.first?.objectTitle, "Send the launch brief")
        XCTAssertEqual(timeline.first?.timeLabel, "2:00 PM")
        XCTAssertTrue(timeline.contains(where: { $0.isProtected }))
        XCTAssertTrue(timeline.contains(where: { $0.isFixed }))
        XCTAssertTrue(timeline.contains(where: { $0.isOpenLane }))
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
                $0.canonicalObjectID == "event.family-time"
            }
        )
        XCTAssertFalse(
            fixture.returnedTodayTimeline.contains {
                $0.canonicalObjectID == fixture.primaryStep.id
            },
            "The settled primary Step is projected by its dedicated return-anchor row"
        )
        XCTAssertEqual(
            Set(fixture.returnedTodayTimeline.map(\.canonicalObjectID)).count,
            fixture.returnedTodayTimeline.count
        )
        XCTAssertEqual(
            fixture.returnedTodayVisibleObjectIDs.filter {
                $0 == fixture.revealedStartHereStep.id
            }.count,
            1
        )
        XCTAssertEqual(
            fixture.returnedTodayVisibleObjectIDs.filter {
                $0 == fixture.returnContract.settledStepID
            }.count,
            1
        )
    }

    func testReturnedProjectionDeduplicatesSettledAndRevealedIDsIntrinsically() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let adversarialTimeline = fixture.timeline + [
            TodayFlagshipTimelineObject(
                id: "timeline.duplicate-settled",
                canonicalObjectID: fixture.primaryStep.id,
                objectTitle: fixture.primaryStep.title,
                timeLabel: "10:30 AM",
                relationship: "Settled",
                acceptedState: fixture.primaryStep.stillCountsProposal.settledTruth
            ),
            TodayFlagshipTimelineObject(
                id: "timeline.duplicate-revealed",
                canonicalObjectID: fixture.revealedStartHereStep.id,
                objectTitle: fixture.revealedStartHereStep.title,
                timeLabel: "2:00 PM",
                relationship: "Fixed",
                acceptedState: fixture.revealedStartHereStep.currentAcceptedTruth
            )
        ]
        let projected = fixture.replacingTimeline(adversarialTimeline)

        XCTAssertEqual(
            Set(projected.returnedTodayVisibleObjectIDs).count,
            projected.returnedTodayVisibleObjectIDs.count
        )
        XCTAssertEqual(
            projected.returnedTodayVisibleObjectIDs.filter { $0 == fixture.primaryStep.id }.count,
            1
        )
        XCTAssertEqual(
            projected.returnedTodayVisibleObjectIDs.filter {
                $0 == fixture.revealedStartHereStep.id
            }.count,
            1
        )
    }

    func testR13SupportingSnapshotsRemainFixtureDrivenAndReadOnly() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let supporting = fixture.supporting

        XCTAssertEqual(supporting.goal.id, fixture.primaryStep.parentPursuitID)
        XCTAssertEqual(supporting.goal.nextStepID, fixture.primaryStep.id)
        XCTAssertEqual(supporting.history.id, fixture.receipt.historyID)
        XCTAssertEqual(supporting.history.stepID, fixture.primaryStep.id)
        XCTAssertEqual(supporting.history.goalID, fixture.primaryStep.parentPursuitID)
        XCTAssertTrue(supporting.history.isLocalOnly)

        XCTAssertTrue(supporting.timeTransfer.isReadOnly)
        XCTAssertTrue(supporting.timeTransfer.isHostEvaluationOnly)
        XCTAssertFalse(supporting.timeTransfer.isProductRouteAvailable)
        XCTAssertEqual(supporting.timeTransfer.sourceOwner, "Today")
        XCTAssertEqual(supporting.timeTransfer.destinationOwner, "Time")

        XCTAssertEqual(supporting.commitFailure.affectedStepID, fixture.primaryStep.id)
        XCTAssertTrue(supporting.commitFailure.preservesAcceptedTruth)
    }

    func testUndoRequiresExactCurrentReceiptRevisionAndDependencies() {
        let standard = TodayFlagshipCalibrationFixture.preparingForBaby
        XCTAssertFalse(standard.supporting.inverse.isAvailable)
        XCTAssertNil(standard.supporting.inverse.currentReceiptID)

        let eligible = standard.undoAvailableEvaluation.supporting.inverse
        XCTAssertTrue(eligible.isAvailable)
        XCTAssertTrue(
            standard.undoAvailableEvaluation.primaryStep.stillCountsProposal.inverseAvailable
        )
        XCTAssertEqual(
            eligible.commandID,
            "CMD-TODAY-DETAIL-CLOSURE-REVIEW-001-INVERSE"
        )
        XCTAssertEqual(
            eligible.triggerReceiptID,
            "receipt.step.nursery-ready-for-crib.still-counts"
        )
        XCTAssertEqual(eligible.currentReceiptID, eligible.triggerReceiptID)
        XCTAssertTrue(eligible.stepRevisionIsCurrent)
        XCTAssertTrue(eligible.dependenciesAreCurrent)
        XCTAssertFalse(eligible.hasNewerDependentCommand)
        XCTAssertTrue(eligible.preservesHistory)
    }

    func testEveryUndoEligibilityGateIsIndependentlyRequired() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby.undoAvailableEvaluation
        let eligible = fixture.supporting.inverse
        let invalidSnapshots = [
            inverse(from: eligible, currentReceiptID: "receipt.other"),
            inverse(from: eligible, stepRevisionIsCurrent: false),
            inverse(from: eligible, dependenciesAreCurrent: false),
            inverse(from: eligible, hasNewerDependentCommand: true),
            inverse(from: eligible, preservesHistory: false)
        ]

        for invalid in invalidSnapshots {
            XCTAssertFalse(invalid.isAvailable)
            let content = fixture.replacingInverse(invalid)
            var state = TodayFlagshipJourneyState.preview(content: content, phase: .settled)
            XCTAssertFalse(state.openSupportingRoute(.undoReview))
            XCTAssertNil(state.supportingRoute)
        }
    }

    func testSupportingSnapshotsAreExplicit() throws {
        let contentSource = try foundrySource(named: "TodayFlagshipCalibrationContent.swift")
        XCTAssertTrue(contentSource.contains("supporting: TodayFlagshipSupportingSnapshots"))
        XCTAssertFalse(contentSource.contains("supporting: TodayFlagshipSupportingSnapshots?"))
        XCTAssertFalse(contentSource.contains("defaultSupportingSnapshots"))
    }

    func testB02ReturnedTodayKeepsOneRevealedStartHereAndExactSettledAnchor() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let allReturnedIdentities = [fixture.revealedStartHereStep.id]
            + fixture.returnedTodayTimeline.map(\.canonicalObjectID)

        XCTAssertEqual(
            allReturnedIdentities.filter { $0 == fixture.revealedStartHereStep.id }.count,
            1
        )
        XCTAssertEqual(fixture.returnContract.settledStepID, fixture.primaryStep.id)
        XCTAssertEqual(
            fixture.returnContract.focusAnchorID,
            "today.settled.step.nursery-ready-for-crib"
        )
        XCTAssertEqual(
            fixture.receipt.historySummary,
            fixture.primaryStep.stillCountsProposal.settledTruth
        )
        XCTAssertFalse(fixture.receipt.recordedLabel.localizedCaseInsensitiveContains("will"))
        XCTAssertFalse(fixture.receipt.receiptSummary.localizedCaseInsensitiveContains("will"))
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
            "I primed the wall and tested the new color."
        )
        XCTAssertEqual(fixture.recovery.availableChoices.map(\.id), [
            "recovery.continue-saved-progress",
            "recovery.keep-step"
        ])
    }

    func testB02ResilienceSnapshotsAreExplicitAndNonMutating() throws {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(
            fixture.timeline.map(\.role),
            [.fixed, .protected, .openLane]
        )
        XCTAssertNil(fixture.contextSeam)

        let quiet = fixture.quietToday
        XCTAssertEqual(quiet.timeline.map(\.role), [.protected, .openLane])
        XCTAssertEqual(
            quiet.timeline.map(\.timeLabel),
            ["5:30 PM", "Open after 6:30 PM"]
        )

        let dense = fixture.denseToday
        XCTAssertGreaterThan(dense.timeline.count, fixture.timeline.count)
        XCTAssertTrue(dense.timeline.contains { $0.role == .fixed })
        XCTAssertTrue(dense.timeline.contains { $0.role == .protected })

        let veryDense = fixture.veryDenseToday
        XCTAssertEqual(veryDense.timeline.count, 10)
        XCTAssertEqual(veryDense.timeline.map(\.timeLabel), [
            "11:40 AM", "12:20 PM", "1:10 PM", "2:00 PM", "3:20 PM",
            "4:45 PM", "5:30 PM", "6:30 PM", "Open after 6:30 PM", "7:15 PM"
        ])
        XCTAssertTrue(veryDense.timeline.contains { $0.role == .external })
        XCTAssertTrue(veryDense.timeline.contains { $0.role == .openLane })

        let offline = try XCTUnwrap(fixture.offlineLocalTruth.contextSeam)
        XCTAssertEqual(offline.condition, .offlineLocalTruth)
        XCTAssertEqual(offline.affectedObjectID, fixture.primaryStep.id)
        XCTAssertEqual(offline.ownerTitle, fixture.interfaceCopy.todayNavigationTitle)
        XCTAssertEqual(fixture.offlineLocalTruth.timeline, fixture.timeline)

        let stale = try XCTUnwrap(fixture.staleExternalContext.contextSeam)
        XCTAssertEqual(stale.condition, .staleExternalContext)
        XCTAssertEqual(stale.affectedObjectID, fixture.revealedStartHereStep.id)
        XCTAssertTrue(
            fixture.staleExternalContext.timeline.contains {
                $0.canonicalObjectID == stale.affectedObjectID && $0.role == .external
            }
        )

        let conflict = try XCTUnwrap(fixture.conflictTransfer.contextSeam)
        XCTAssertEqual(conflict.condition, .conflictTransfer)
        XCTAssertEqual(conflict.affectedObjectID, fixture.primaryStep.id)
        XCTAssertEqual(conflict.ownerTitle, fixture.interfaceCopy.timeNavigationTitle)
        XCTAssertTrue(conflict.body.contains("nursery Step"))
        XCTAssertTrue(conflict.body.contains("before family time"))
        XCTAssertTrue(conflict.body.contains("placement in Time"))
        XCTAssertTrue(conflict.accessibilityLabel.contains("placement review belongs in Time"))
        XCTAssertEqual(fixture.conflictTransfer.timeline, fixture.timeline)
    }

    func testB02RecoveryAndResilienceSourceExposeNoUnsupportedCommands() throws {
        let source = try primaryViewSource()
        let journeySource = try foundrySource(named: "TodayFlagshipJourneyState.swift")

        XCTAssertFalse(source.contains("Other outcomes"))
        XCTAssertTrue(journeySource.contains("applyEligibleInverse"))
        XCTAssertTrue(journeySource.contains("inverseIsAvailable"))
        XCTAssertFalse(source.contains("genericUndo"))
        XCTAssertFalse(source.contains("tfcs-open-in-time"))
        XCTAssertFalse(source.contains("tfcs-refresh-external-context"))
    }

    func testB02RecoveryUsesInterruptedContinuityGrammarAndAcceptedTruth() throws {
        let recoverySource = try foundrySource(named: "TodayFlagshipRecoveryReviewView.swift")
        let vitalityRecoverySource = try foundrySource(named: "TodayVitalityRecoveryView.swift")
        let focusedSource = try foundrySource(named: "TodayFlagshipFocusedStepView.swift")
        let resilienceSource = try foundrySource(named: "TodayOpenContinuityResilience.swift")
        let recoveryComposition = recoverySource + vitalityRecoverySource + resilienceSource

        XCTAssertTrue(recoveryComposition.contains("TodayOpenContinuitySpine"))
        XCTAssertTrue(recoveryComposition.contains("kind: .interrupted"))
        XCTAssertTrue(focusedSource.contains("state.acceptedTruth"))
        XCTAssertTrue(recoveryComposition.contains("content.primaryStep.parentPursuitTitle"))
        XCTAssertTrue(recoveryComposition.contains("content.interfaceCopy.lastSavedProgressTitle"))
        XCTAssertTrue(vitalityRecoverySource.contains("state.leaveForLater()"))
        XCTAssertTrue(recoveryComposition.contains("tfcs-recovery-step-identity"))
        XCTAssertTrue(recoveryComposition.contains("tfcs-recovery-current-truth"))
        XCTAssertFalse(recoverySource.contains("Interrupted Step"))
        XCTAssertFalse(recoverySource.contains("Last saved progress"))
        XCTAssertTrue(focusedSource.contains("TodayVitalityInterruptedStepView"))
        XCTAssertTrue(focusedSource.contains("state.phase == .recoveredContinuation"))
        XCTAssertTrue(focusedSource.contains("recoveredProgress"))
        XCTAssertTrue(focusedSource.contains("TodayVitalityFocusedStepView"))
        XCTAssertFalse(focusedSource.contains("private var recoveredSeam"))
    }

    func testB02RootRendersExplicitReadOnlyContextSeamAndTimelineUsesRole() throws {
        let rootSource = try foundrySource(named: "TodayOpenContinuityRoot.swift")
        let timelineSource = try foundrySource(named: "TodayOpenContinuityTimeline.swift")
        let resilienceSource = try foundrySource(named: "TodayOpenContinuityResilience.swift")
        let contextSeamSource = try XCTUnwrap(
            resilienceSource.components(
                separatedBy: "struct TodayOpenContinuityContextSeam"
            ).last
        )

        XCTAssertTrue(rootSource.contains("content.contextSeam"))
        XCTAssertTrue(rootSource.contains("TodayOpenContinuityContextSeam"))
        XCTAssertTrue(rootSource.contains("contextSeam.affectedObjectID == visibleStartHere.id"))
        XCTAssertTrue(timelineSource.contains("contextSeam.affectedObjectID == item.canonicalObjectID"))
        XCTAssertTrue(resilienceSource.contains("seam.condition"))
        XCTAssertTrue(resilienceSource.contains("seam.accessibilityLabel"))
        XCTAssertTrue(resilienceSource.contains("tfcs-context-seam-"))
        XCTAssertFalse(contextSeamSource.contains("Button"))
        XCTAssertTrue(timelineSource.contains("switch item.role"))
        XCTAssertFalse(timelineSource.contains("if item.isProtected"))
        XCTAssertFalse(timelineSource.contains("if item.isFixed"))
        XCTAssertFalse(timelineSource.contains("if item.isOpenLane"))
    }

    func testB02ReduceMotionKeepsStaticStateMeaning() throws {
        let standardPolicy = TodayOpenContinuityMotionPolicy(reduceMotion: false)
        let reducedPolicy = TodayOpenContinuityMotionPolicy(reduceMotion: true)

        XCTAssertNotNil(standardPolicy.stateAnimation)
        XCTAssertNil(reducedPolicy.stateAnimation)
        XCTAssertEqual(
            Set(TodayOpenContinuityNodeKind.allCases.map(\.nonColorShapeLabel)).count,
            TodayOpenContinuityNodeKind.allCases.count,
            "Every state keeps a unique static shape when motion is reduced"
        )

        let grammarSource = try foundrySource(named: "TodayOpenContinuityGrammar.swift")
        let spineSource = try foundrySource(named: "TodayOpenContinuitySpine.swift")
        let rootSource = try foundrySource(named: "TodayOpenContinuityRoot.swift")
        let timelineSource = try foundrySource(named: "TodayOpenContinuityTimeline.swift")
        let fullDaySource = try foundrySource(named: "TodayOpenContinuityFullDayView.swift")
        let focusedSource = try foundrySource(named: "TodayOpenContinuityFocusedObject.swift")
        let truthSource = try foundrySource(named: "TodayOpenContinuityTruthFlow.swift")
        let journeySource = try foundrySource(named: "TodayFlagshipCalibrationView.swift")
        let reviewSource = try foundrySource(named: "TodayFlagshipReviewView.swift")
        let navigationSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")
        let motionSources = [
            grammarSource,
            spineSource,
            rootSource,
            timelineSource,
            fullDaySource,
            focusedSource,
            truthSource,
            journeySource,
            navigationSource
        ].joined(separator: "\n")

        XCTAssertTrue(grammarSource.contains("struct TodayOpenContinuityMotionPolicy"))
        XCTAssertTrue(
            grammarSource.contains(
                "@Environment(\\.accessibilityReduceMotion) private var reduceMotion"
            )
        )
        XCTAssertTrue(grammarSource.contains(".scaleEffect(reduceMotion ? 1 :"))
        XCTAssertTrue(spineSource.contains("policy.stateAnimation"))
        XCTAssertTrue(fullDaySource.contains("withAnimation(motionPolicy.stateAnimation)"))
        XCTAssertTrue(
            fullDaySource.contains(
                "@Environment(\\.accessibilityReduceMotion) private var reduceMotion"
            )
        )
        XCTAssertFalse(motionSources.contains(".spring("))
        XCTAssertFalse(motionSources.contains(".blur("))
        XCTAssertTrue(reviewSource.contains(".sensoryFeedback(.selection"))
        XCTAssertTrue(reviewSource.contains(".sensoryFeedback("))
        XCTAssertTrue(reviewSource.contains(".impact(weight: .light"))
        XCTAssertTrue(
            navigationSource.contains(
                ".sensoryFeedback(.selection, trigger: commandSelectionFeedback)"
            )
        )
        XCTAssertTrue(navigationSource.contains("commandSelectionFeedback += 1"))
        XCTAssertTrue(
            navigationSource.contains(".scaleEffect(reduceMotion ? 1 :")
        )
        XCTAssertTrue(journeySource.contains(".sensoryFeedback(.success"))
        XCTAssertTrue(journeySource.contains("state.phase"))
    }

    func testB02MotionScopeKeepsScrollAndTimelineObservationBounded() throws {
        let rootSource = try foundrySource(named: "TodayOpenContinuityRoot.swift")
        let timelineSource = try foundrySource(named: "TodayOpenContinuityTimeline.swift")

        XCTAssertTrue(
            rootSource.contains(
                "min(max(0, geometry.contentOffset.y + geometry.contentInsets.top) / 56, 1)"
            )
        )
        XCTAssertTrue(rootSource.contains("onCrownScrollProgress(progress)"))
        XCTAssertTrue(timelineSource.contains("let renderedObjects = objects"))
        XCTAssertTrue(timelineSource.contains("Array(renderedObjects.enumerated())"))
        XCTAssertTrue(timelineSource.contains("renderedObjects.count - 1"))
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

    func testB02FoundryKeepsSystemTypographyAndItsPackageLocalBoundary() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceRoot = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
        let sourceFiles = try FileManager.default.contentsOfDirectory(
            at: sourceRoot,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "swift" }
        let foundrySource = try sourceFiles.map {
            try String(contentsOf: $0, encoding: .utf8)
        }.joined(separator: "\n")

        XCTAssertFalse(foundrySource.contains("Font.custom"))
        XCTAssertFalse(foundrySource.contains(".custom("))
        XCTAssertFalse(foundrySource.contains("import AmbitionsFlagshipUI"))
        XCTAssertFalse(foundrySource.contains("import AmbitionsFlagshipFoundation"))
        XCTAssertFalse(foundrySource.contains("import AmbitionsPresentationContracts"))

        let manifest = try String(
            contentsOf: packageRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        XCTAssertNotNil(
            manifest.range(
                of: #"\.target\(name:\s*"AmbitionsNativeVisualFoundry"\)"#,
                options: .regularExpression
            ),
            "The Foundry target must remain package-local and dependency-free"
        )
    }

    func testB02OverviewSelectionIsDeterministicAndBounded() throws {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let overview = todayOverviewObjects(
            content: fixture,
            visibleStartHereID: fixture.primaryStep.id
        )

        XCTAssertLessThanOrEqual(overview.count, 3)
        XCTAssertEqual(overview.count, 3)
        XCTAssertFalse(
            overview.contains { $0.canonicalObjectID == fixture.primaryStep.id }
        )
        XCTAssertEqual(
            Set(overview.map(\.id)),
            Set([
                "timeline.work-launch-brief",
                "timeline.family-time",
                "timeline.open-after-family"
            ])
        )
        XCTAssertEqual(
            overview.map(\.id),
            fixture.timeline.filter {
                Set([
                    "timeline.work-launch-brief",
                    "timeline.family-time",
                    "timeline.open-after-family"
                ]).contains($0.id)
            }.map(\.id),
            "Selected anchors preserve fixture chronology after deterministic priority selection"
        )
        XCTAssertEqual(overview.filter(\.isFixed).count, 1)
        XCTAssertEqual(overview.filter(\.isProtected).count, 1)

        let denseOverview = todayOverviewObjects(
            content: fixture.denseToday,
            visibleStartHereID: fixture.primaryStep.id
        )
        XCTAssertLessThanOrEqual(denseOverview.count, 3)
        XCTAssertEqual(denseOverview.filter(\.isFixed).count, 1)
        XCTAssertEqual(denseOverview.filter(\.isProtected).count, 1)

        let duplicateCanonicalObject = TodayFlagshipTimelineObject(
            id: "timeline.work-launch-brief-projection",
            canonicalObjectID: "step.send-launch-brief",
            objectTitle: "Launch brief continuity projection",
            timeLabel: "2:05 PM",
            relationship: "Same canonical work commitment",
            acceptedState: "Fixed",
            isFixed: true
        )
        let duplicateContent = fixture.replacingTimeline(
            fixture.timeline + [duplicateCanonicalObject]
        )
        let deDuplicatedOverview = todayOverviewObjects(
            content: duplicateContent,
            visibleStartHereID: fixture.primaryStep.id
        )
        XCTAssertEqual(
            deDuplicatedOverview.filter {
                $0.canonicalObjectID == duplicateCanonicalObject.canonicalObjectID
            }.count,
            1,
            "Overview selection de-duplicates multiple projections of one canonical object"
        )

        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceRoot = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
        let rootSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("TodayVitalityRootView.swift"),
            encoding: .utf8
        )
        let timelineSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("TodayVitalityTimelineView.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(rootSource.components(separatedBy: "ScrollView {").count - 1, 1)
        XCTAssertFalse(timelineSource.contains("ScrollView"))
        XCTAssertFalse(rootSource.contains("content.timeline"))
        XCTAssertFalse(rootSource.contains("TodayFlagshipNavigationCommand.search"))
        XCTAssertFalse(rootSource.contains("TodayFlagshipNavigationCommand.capture"))
        XCTAssertTrue(rootSource.contains(".onScrollGeometryChange"))
        XCTAssertTrue(rootSource.contains("onCrownScrollProgress"))
        XCTAssertTrue(timelineSource.contains("TodayVitalityNode("))
        XCTAssertTrue(timelineSource.contains("TodayVitalityActionStyle("))
        XCTAssertTrue(timelineSource.contains("tfcs-view-full-day"))
    }

    func testB02TallOverviewFillsAvailablePlaneWithoutNewTruth() throws {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let rootSource = try foundrySource(named: "TodayVitalityRootView.swift")
        let timelineSource = try foundrySource(named: "TodayVitalityTimelineView.swift")

        XCTAssertEqual(fixture.timeline.count, 3)
        XCTAssertTrue(fixture.timeline.contains { $0.canonicalObjectID.hasPrefix("lane.") })
        XCTAssertFalse(rootSource.contains("GeometryReader { viewport in"))
        XCTAssertFalse(rootSource.contains("frame(maxHeight: .infinity"))
        XCTAssertFalse(timelineSource.contains("mode == .overview ? .infinity : nil"))
    }

    func testB02FullDayUsesExplicitOriginNowIdentity() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(
            fixture.nowAnchorObjectID(for: .todayInitial),
            fixture.primaryStep.id
        )
        XCTAssertEqual(
            fixture.nowAnchorObjectID(for: .todayReturned),
            fixture.revealedStartHereStep.id
        )
    }

    func testB02FocusedStepUsesOneNaturalDepthAndOneOutcome() throws {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let step = fixture.primaryStep

        XCTAssertEqual(step.id, "step.nursery-ready-for-crib")
        XCTAssertEqual(step.parentPursuitID, "goal.welcome-baby-home")
        XCTAssertFalse(step.currentAcceptedTruth.isEmpty)
        XCTAssertFalse(step.whyItFitsNow.isEmpty)
        XCTAssertFalse(step.materialConsequence.isEmpty)
        XCTAssertFalse(step.temporalContext.relationship.isEmpty)
        XCTAssertEqual(step.stillCountsProposal.outcomeTitle, "Still counts")

        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: packageRoot
                .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
                .appendingPathComponent("TodayOpenContinuityFocusedObject.swift"),
            encoding: .utf8
        )
        let focusedWrapperSource = try String(
            contentsOf: packageRoot
                .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
                .appendingPathComponent("TodayFlagshipFocusedStepView.swift"),
            encoding: .utf8
        )

        let orderedMarkers = [
            "tfcs-focused-identity",
            "tfcs-focused-parent-pursuit",
            "tfcs-focused-current-truth",
            "tfcs-focused-why-now",
            "tfcs-focused-protected-consequence",
            "tfcs-focused-temporal-anchor",
            "tfcs-select-still-counts"
        ]
        let markerOffsets = try orderedMarkers.map { marker in
            try XCTUnwrap(source.range(of: marker)?.lowerBound)
        }
        for pair in zip(markerOffsets, markerOffsets.dropFirst()) {
            XCTAssertLessThan(pair.0, pair.1)
        }

        XCTAssertFalse(source.contains("Form"))
        XCTAssertFalse(source.contains("Settings"))
        XCTAssertFalse(source.contains("Other outcomes"))
        XCTAssertFalse(source.contains("Done · Move it · Waiting · Blocked · Not needed"))
        XCTAssertTrue(source.contains("dynamicTypeSize.isAccessibilitySize"))
        XCTAssertTrue(source.contains("accessibilityParentPursuit"))
        XCTAssertEqual(
            source.components(separatedBy: "tfcs-select-still-counts").count - 1,
            1
        )
        XCTAssertFalse(
            focusedWrapperSource.contains(
                ".navigationTitle(content.interfaceCopy.startHereTitle)"
            )
        )
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
            "TodayOpenContinuityRoot.swift",
            "TodayOpenContinuityTimeline.swift",
            "TodayOpenContinuityFocusedObject.swift",
            "TodayOpenContinuityResilience.swift",
            "TodayOpenContinuityTruthFlow.swift",
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

    private func foundrySource(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: packageRoot
                .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
                .appendingPathComponent(filename),
            encoding: .utf8
        )
    }

    private func inverse(
        from source: TodayFlagshipInverseSnapshot,
        currentReceiptID: String? = nil,
        stepRevisionIsCurrent: Bool? = nil,
        dependenciesAreCurrent: Bool? = nil,
        hasNewerDependentCommand: Bool? = nil,
        preservesHistory: Bool? = nil
    ) -> TodayFlagshipInverseSnapshot {
        TodayFlagshipInverseSnapshot(
            commandID: source.commandID,
            title: source.title,
            triggerReceiptID: source.triggerReceiptID,
            currentReceiptID: currentReceiptID ?? source.currentReceiptID,
            stepRevisionIsCurrent: stepRevisionIsCurrent ?? source.stepRevisionIsCurrent,
            dependenciesAreCurrent: dependenciesAreCurrent ?? source.dependenciesAreCurrent,
            hasNewerDependentCommand: hasNewerDependentCommand
                ?? source.hasNewerDependentCommand,
            preservesHistory: preservesHistory ?? source.preservesHistory
        )
    }
}

private extension TodayFlagshipCalibrationContent {
    func replacingTimeline(_ timeline: [TodayFlagshipTimelineObject]) -> Self {
        Self(
            familyID: familyID,
            isSynthetic: isSynthetic,
            interfaceCopy: interfaceCopy,
            presentContext: presentContext,
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStartHereStep,
            timeline: timeline,
            receipt: receipt,
            returnContract: returnContract,
            recovery: recovery,
            contextSeam: contextSeam,
            supporting: supporting
        )
    }

    func replacingInverse(_ inverse: TodayFlagshipInverseSnapshot) -> Self {
        Self(
            familyID: familyID,
            isSynthetic: isSynthetic,
            interfaceCopy: interfaceCopy,
            presentContext: presentContext,
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStartHereStep,
            timeline: timeline,
            receipt: receipt,
            returnContract: returnContract,
            recovery: recovery,
            contextSeam: contextSeam,
            supporting: TodayFlagshipSupportingSnapshots(
                goal: supporting.goal,
                timeTransfer: supporting.timeTransfer,
                history: supporting.history,
                inverse: inverse,
                commitFailure: supporting.commitFailure,
                fullDay: supporting.fullDay
            )
        )
    }
}
