public enum GoalsNativeCalibrationFixture {
    public static let preparingForBaby = makePreparingForBaby()

    private static func makePreparingForBaby() -> GoalsNativeCalibrationContent {
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
            id: "relationship.home-supports-first-weeks",
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
                    id: "goalpath-node.define-ready",
                    title: "Define what ready means",
                    state: .completed,
                    detail: "The family agreed on the smallest useful definition of ready."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.clear-crib-corner",
                    title: "Clear the crib corner",
                    state: .completed,
                    proof: ["Crib corner cleared"],
                    detail: "The crib corner is clear."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.prime-wall",
                    title: "Prime the wall and confirm the color",
                    state: .settled,
                    proof: ["Paint color confirmed", "Wall primed"],
                    detail: "The wall is primed and the color is confirmed."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.paint-wall",
                    title: "Paint the nursery wall",
                    state: .current,
                    detail: "This is the current meaningful movement."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.assemble-crib",
                    title: "Assemble the crib",
                    state: .next,
                    detail: "This becomes available after the paint has settled."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.changing-station",
                    title: "Set up the changing station",
                    state: .planned,
                    detail: "This remains a planned movement."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.final-furniture",
                    title: "Arrange final furniture after delivery",
                    state: .conditional,
                    detail: "Future Step · available after delivery."
                ),
                GoalsNativeCalibrationPathNode(
                    id: "goalpath-node.nursery-ready",
                    title: "Nursery ready for the crib",
                    state: .finish,
                    detail: "The room supports the family without taking over their time."
                )
            ],
            currentNodeID: "goalpath-node.paint-wall",
            nextNodeID: "goalpath-node.assemble-crib"
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
            goalPath: goalPath
        )
    }
}
