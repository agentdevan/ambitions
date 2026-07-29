public enum GoalsNativeCalibrationFixture {
    public static let preparingForBaby = makePreparingForBaby()

    private static func makePreparingForBaby() -> GoalsNativeCalibrationContent {
        let proofMoments = [
            GoalsNativeCalibrationProofMoment(
                id: "proof.crib-corner-cleared",
                title: "Crib corner cleared"
            ),
            GoalsNativeCalibrationProofMoment(
                id: "proof.paint-color-confirmed",
                title: "Paint color confirmed"
            ),
            GoalsNativeCalibrationProofMoment(
                id: "proof.wall-primed",
                title: "Wall primed"
            )
        ]

        let primaryGoal = GoalsNativeCalibrationGoal(
            id: "goal.welcome-baby-home",
            title: "Welcome our baby home",
            lifeAreaID: "life-area.home",
            lifeAreaTitle: "Home",
            currentDirection: "Make the home ready for the baby without consuming the time and energy the family needs now.",
            currentAcceptedTruth: "The wall is primed, the color is confirmed, and the crib corner is clear.",
            activeThread: "Finish the nursery.",
            nextMeaningfulMovement: "Paint the nursery wall.",
            followingMovement: "Assemble the crib.",
            materialConsequence: "Finishing the room now reduces last-minute setup while protecting family time.",
            scheduleFit: "The next movement currently fits before protected family time."
        )

        let lifeAreas = [
            GoalsNativeCalibrationLifeArea(
                id: "life-area.home",
                title: "Home",
                currentTruth: "Preparing a calm, workable home for the baby.",
                goals: [
                    GoalsNativeCalibrationGoalSummary(
                        id: primaryGoal.id,
                        title: primaryGoal.title,
                        acceptedPosture: "Nursery preparation is the active thread."
                    ),
                    GoalsNativeCalibrationGoalSummary(
                        id: "goal.make-home-easier-to-run",
                        title: "Make the house easier to run",
                        acceptedPosture: "Small systems are taking shape."
                    ),
                    GoalsNativeCalibrationGoalSummary(
                        id: "goal.finish-essential-move-in-work",
                        title: "Finish essential move-in work",
                        acceptedPosture: "Only essential work remains."
                    )
                ]
            ),
            GoalsNativeCalibrationLifeArea(
                id: "life-area.relationships",
                title: "Relationships",
                currentTruth: "Protecting time and ease for the first weeks together.",
                goals: [
                    GoalsNativeCalibrationGoalSummary(
                        id: "goal.protect-first-weeks-together",
                        title: "Protect our first weeks together",
                        acceptedPosture: "The family plan remains protected."
                    )
                ]
            ),
            GoalsNativeCalibrationLifeArea(
                id: "life-area.career",
                title: "Career",
                currentTruth: "Keeping meaningful work contained and dependable.",
                goals: [
                    GoalsNativeCalibrationGoalSummary(
                        id: "goal.ship-launch-well",
                        title: "Ship the launch well",
                        acceptedPosture: "The brief is ready for review."
                    )
                ]
            )
        ]

        let linkedLens = GoalsNativeCalibrationLinkedLens(
            goalID: primaryGoal.id,
            currentTruth: primaryGoal.currentAcceptedTruth,
            consequence: primaryGoal.materialConsequence,
            activeThread: primaryGoal.activeThread,
            nextMovement: primaryGoal.nextMeaningfulMovement,
            proofPosture: [
                "Crib corner cleared",
                "Paint color confirmed",
                "Wall primed"
            ],
            openActionTitle: "Open Goal"
        )

        let relationship = GoalsNativeCalibrationRelationship(
            id: "relationship.goal.welcome-baby-home.protect-first-weeks",
            primaryGoalID: primaryGoal.id,
            primaryGoalTitle: primaryGoal.title,
            ownerLifeAreaID: "life-area.home",
            ownerLifeAreaTitle: "Home",
            relatedGoalID: "goal.protect-first-weeks-together",
            relatedGoalTitle: "Protect our first weeks together",
            relatedLifeAreaID: "life-area.relationships",
            relatedLifeAreaTitle: "Relationships",
            meaning: "A ready nursery lowers pressure during the first days at home.",
            practicalConsequence: "Home setup should support the family’s first-week plan rather than consume it."
        )

        let goalPath = GoalsNativeCalibrationPath(
            id: "goalpath.welcome-baby-home.v1",
            nodes: [
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.define-ready",
                    title: "Define what ready means",
                    state: .completed,
                    detail: "The family agreed on the smallest useful definition of ready."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.clear-crib-corner",
                    title: "Clear the crib corner",
                    state: .completed,
                    proof: ["Crib corner cleared"],
                    proofIDs: ["proof.crib-corner-cleared"],
                    detail: "The crib corner is clear."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.prime-wall-color",
                    title: "Prime the wall and confirm the color",
                    state: .settled,
                    proof: ["Paint color confirmed", "Wall primed"],
                    proofIDs: ["proof.paint-color-confirmed", "proof.wall-primed"],
                    detail: "The wall is primed and the color is confirmed."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.paint-wall",
                    title: "Paint the nursery wall",
                    state: .current,
                    detail: "This is the current meaningful movement."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.assemble-crib",
                    title: "Assemble the crib",
                    state: .next,
                    detail: "This becomes available after the paint has settled."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.changing-station",
                    title: "Set up the changing station",
                    state: .planned,
                    detail: "This remains a planned movement."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.final-furniture",
                    title: "Arrange final furniture after delivery",
                    state: .conditional,
                    detail: "Future Step · available after delivery."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "pathnode.nursery-ready",
                    title: "Nursery ready for the crib",
                    state: .finish,
                    detail: "The room supports the family without taking over their time."
                )
            ],
            currentNodeID: "pathnode.paint-wall",
            nextNodeID: "pathnode.assemble-crib"
        )

        let recovery = GoalsNativeCalibrationRecovery(
            id: "recovery.goal.welcome-baby-home.paint-delay",
            goalID: primaryGoal.id,
            interruptionFact: "The nursery paint is unavailable until Friday.",
            retainedAcceptedTruth: primaryGoal.currentAcceptedTruth,
            retainedProofIDs: proofMoments.map(\.id),
            interruptedPathNodeID: "pathnode.paint-wall",
            possibleNextPathNodeID: "pathnode.assemble-crib",
            unchangedPathStatement: "The current path is still intact. Nothing has changed yet."
        )

        let closure = GoalsNativeCalibrationClosure(
            id: "closure.goal.welcome-baby-home.nursery-ready",
            goalID: primaryGoal.id,
            acceptedTruth: "The nursery is ready for the crib.",
            relationshipResult: "The first weeks together remain protected.",
            remainingOpenItem: "Arrange final furniture after delivery",
            proofIDs: proofMoments.map(\.id),
            history: [
                GoalsNativeCalibrationHistoryEntry(
                    id: "history.goal.welcome-baby-home.nursery-ready",
                    title: "Nursery outcome accepted",
                    detail: "The nursery is ready for the crib."
                ),
                GoalsNativeCalibrationHistoryEntry(
                    id: "history.goal.welcome-baby-home.protected-first-weeks",
                    title: "Protected relationship retained",
                    detail: "The first weeks together remain protected."
                )
            ],
            isOutcomeAchieved: true,
            isGoalClosed: true
        )

        return GoalsNativeCalibrationContent(
            familyID: "goals-flagship/home/welcome-baby-home/v1",
            isSynthetic: true,
            presentContext: "Living pursuits · Home is in focus",
            selectedLifeAreaID: "life-area.home",
            selectedGoalID: primaryGoal.id,
            lifeAreas: lifeAreas,
            primaryGoal: primaryGoal,
            linkedLens: linkedLens,
            relationship: relationship,
            goalPath: goalPath,
            proofMoments: proofMoments,
            recovery: recovery,
            closure: closure
        )
    }
}
