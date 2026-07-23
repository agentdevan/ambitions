public enum TodayFlagshipCalibrationFixture {
    /// Synthetic evaluation content. This fixture is not canon, runtime truth,
    /// persistence proof, or a production screenshot baseline.
    public static let preparingForBaby = makePreparingForBaby()

    private static func makePreparingForBaby(
        longContent: Bool = false,
        denseToday: Bool = false
    ) -> TodayFlagshipCalibrationContent {
        let proposal = TodayFlagshipStillCountsProposal(
            outcomeTitle: "Still counts",
            proposedTruth: "Record the cleared corner and paint sample as meaningful progress.",
            settledTruth: "The cleared corner and paint sample count as progress toward the nursery.",
            exactConsequence: (
                "This Step leaves Start Here, remains visible as settled progress, "
                    + "and protects family dinner and the evening health walk."
            ),
            affectedLineage: "Welcome our baby home → Nursery ready for the crib",
            proofRequirement: "The saved progress note becomes local Proof for this Step.",
            createsProof: true,
            createsReceipt: true,
            appearsInHistory: true,
            inverseAvailable: false,
            commitActionTitle: "Record Still counts"
        )
        let primaryTitle = longContent
            ? "Make the baby’s room ready for the crib before protected family time begins"
            : "Make the baby’s room ready for the crib"
        let primaryStep = TodayFlagshipStepSnapshot(
            id: "step.nursery-ready-for-crib",
            title: primaryTitle,
            parentPursuitID: "goal.welcome-baby-home",
            parentPursuitTitle: "Welcome our baby home",
            currentAcceptedTruth: "The home corner is clear and the paint sample is ready.",
            whyItFitsNow: (
                "The room is open now, before the fixed work handoff and protected family evening."
            ),
            materialConsequence: (
                "A small pass now keeps family dinner and the prenatal walk protected."
            ),
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: "4:30 PM",
                relationship: "Finish this pass before protected family time",
                owner: "Time"
            ),
            primaryActionTitle: "Continue nursery setup",
            stillCountsProposal: proposal
        )
        let revealedStep = TodayFlagshipStepSnapshot(
            id: "step.send-launch-brief",
            title: longContent
                ? "Send the launch brief that keeps the meaningful work commitment on track"
                : "Send the launch brief",
            parentPursuitID: "goal.meaningful-work-commitment",
            parentPursuitTitle: "Keep the launch promise",
            currentAcceptedTruth: "The brief is drafted and waiting for one final read.",
            whyItFitsNow: "The nursery progress is recorded and the 2:00 PM handoff is next.",
            materialConsequence: "Sending it protects the work promise without entering family time.",
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: "2:00 PM",
                relationship: "Fixed work handoff",
                owner: "Time"
            ),
            primaryActionTitle: "Review launch brief",
            stillCountsProposal: proposal
        )
        var timeline = baseTimeline
        if denseToday {
            timeline.insert(
                TodayFlagshipTimelineObject(
                    id: "timeline.prenatal-appointment-notes",
                    objectTitle: "Bring appointment notes",
                    timeLabel: "1:10 PM",
                    relationship: "Baby preparation · Health",
                    acceptedState: "Protected health context",
                    isProtected: true
                ),
                at: 1
            )
            timeline.append(
                TodayFlagshipTimelineObject(
                    id: "timeline.family-dinner",
                    objectTitle: "Family dinner",
                    timeLabel: "6:30 PM",
                    relationship: "Protected family time",
                    acceptedState: "Protected",
                    isProtected: true,
                    isFixed: true
                )
            )
        }

        return TodayFlagshipCalibrationContent(
            familyID: "today-flagship/preparing-for-baby/still-counts/v1",
            isSynthetic: true,
            presentContext: TodayFlagshipPresentContext(
                dateISO8601: "2026-07-23",
                relationship: "Thursday · Home before dinner",
                crownTitle: "Today"
            ),
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStep,
            timeline: timeline,
            receipt: TodayFlagshipReceiptSnapshot(
                id: "receipt.step.nursery-ready-for-crib.still-counts",
                historyID: "history.step.nursery-ready-for-crib",
                recordedLabel: "Recorded on this device",
                receiptSummary: "Still counts · meaningful progress recorded locally",
                historySummary: "Accepted truth changed from ready to begin to meaningful progress recorded.",
                proofLabel: "Added to Proof for Welcome our baby home"
            ),
            returnContract: TodayFlagshipReturnContract(
                settledStepID: "step.nursery-ready-for-crib",
                newStartHereStepID: "step.send-launch-brief",
                focusAnchorID: "today.settled.step.nursery-ready-for-crib",
                settledLocationTitle: "Progress recorded today"
            ),
            recovery: TodayFlagshipRecoverySnapshot(
                stepID: "step.nursery-ready-for-crib",
                interruptionTitle: "This pass was interrupted",
                interruptionDetail: "The last saved nursery progress is still here.",
                lastSavedProgress: "Cleared the crib corner and kept the paint sample decision.",
                availableChoices: [
                    TodayFlagshipRecoveryChoice(
                        id: "recovery.continue-saved-progress",
                        title: "Continue from saved progress",
                        consequence: "Return to the same Step without changing accepted truth."
                    ),
                    TodayFlagshipRecoveryChoice(
                        id: "recovery.keep-step",
                        title: "Keep this Step as it is",
                        consequence: "Dismiss recovery and preserve the Step for later."
                    )
                ]
            )
        )
    }

    private static let baseTimeline: [TodayFlagshipTimelineObject] = [
        TodayFlagshipTimelineObject(
            id: "timeline.nursery-paint-sample",
            objectTitle: "Paint the nursery sample",
            timeLabel: "10:30 AM",
            relationship: "Baby preparation · Home",
            acceptedState: "Ready now"
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.work-launch-brief",
            objectTitle: "Send the launch brief",
            timeLabel: "2:00 PM",
            relationship: "One meaningful work commitment",
            acceptedState: "Fixed",
            isFixed: true
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.family-prenatal-walk",
            objectTitle: "Take the prenatal walk together",
            timeLabel: "5:30 PM",
            relationship: "Family time · Health",
            acceptedState: "Protected",
            isProtected: true
        )
    ]
}

public extension TodayFlagshipCalibrationContent {
    var longContent: Self {
        TodayFlagshipCalibrationFixture.makeLongContent()
    }

    var denseToday: Self {
        TodayFlagshipCalibrationFixture.makeDenseToday()
    }
}

private extension TodayFlagshipCalibrationFixture {
    static func makeLongContent() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(longContent: true)
    }

    static func makeDenseToday() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(denseToday: true)
    }
}
