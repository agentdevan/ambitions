import XCTest
@testable import Ambitions

final class LifeAreaAtlasProjectorTests: XCTestCase {
    func testCanonicalDefinitionsPreserveLifeDomainCompatibilityAndUserFacingLabels() {
        let definitions = LifeAreaDefinition.canonical

        XCTAssertEqual(definitions.map(\.domainKey), LifeDomainKey.allCases)
        XCTAssertEqual(definitions.map(\.id.rawValue), LifeDomainKey.allCases.map(\.rawValue))
        XCTAssertEqual(definitions.first { $0.domainKey == .finance }?.displayName, "Money")
        XCTAssertEqual(definitions.first { $0.domainKey == .personalGrowth }?.displayName, "Personal growth")
        XCTAssertTrue(definitions.allSatisfy { $0.accessibilityLabel.hasPrefix("Life Area") })
    }

    func testOverviewOrdersActiveThenContextThenEmptyByCanonicalOrder() {
        let projector = LifeAreaAtlasProjector()
        let activeHealth = makeGoal(id: "health-active", title: "Rebuild sleep", domain: .health, state: .active)
        let parkedCareer = makeGoal(id: "career-parked", title: "Explore a pivot", domain: .career, state: .paused)

        let overview = projector.overview(from: .init(goals: [parkedCareer, activeHealth]))

        XCTAssertEqual(overview.areas.prefix(3).map(\.definition.domainKey), [.health, .career, .education])
        XCTAssertEqual(overview.areas.first?.counts.activeGoalCount, 1)
        XCTAssertEqual(overview.areas.first { $0.definition.domainKey == .career }?.counts.parkedGoalCount, 1)
        XCTAssertEqual(overview.areas.first { $0.definition.domainKey == .education }?.posture, .empty)
        XCTAssertTrue(overview.accessibility.hint.contains("Map and list keep the same ordered meaning"))
        XCTAssertTrue(overview.accessibility.hint.contains("Reduce Motion"))
    }

    func testOverviewSummarizesProofReceiptsWaitingAndMostRelevantGoal() {
        let projector = LifeAreaAtlasProjector()
        let goal = makeGoal(
            id: "goal-money",
            title: "Build emergency fund",
            domain: .finance,
            state: .active,
            plan: makePlan(goalID: "goal-money", blockedStepID: "blocked-step")
        )
        let object = LifeGraphObjectReference(kind: .goal, id: goal.id, label: goal.title, sourceDomain: .goals)
        let proof = ProofReference(
            id: "proof-1",
            kind: .completedAction,
            title: "First transfer",
            attachedObject: object,
            strength: .supporting,
            sourceDomain: .proof
        )
        let receipt = ActionReceipt(
            id: "receipt-1",
            resultState: .completed,
            title: "Marked done",
            summary: "Completed one transfer",
            sourceDomain: .goals,
            occurredAt: "2026-04-28T12:00:00Z",
            affectedObjects: [object]
        )

        let overview = projector.overview(from: .init(
            goals: [goal],
            proofProjection: ProofResourceGraphProjection(proofReferences: [proof]),
            receiptProjection: ActionReceiptProjection(receipts: [receipt])
        ))
        let money = tryUnwrap(overview.areas.first { $0.definition.domainKey == .finance })

        XCTAssertEqual(money.definition.displayName, "Money")
        XCTAssertEqual(money.posture, .needsAttention)
        XCTAssertEqual(money.counts.activeGoalCount, 1)
        XCTAssertEqual(money.counts.waitingCount, 1)
        XCTAssertEqual(money.counts.proofCount, 1)
        XCTAssertEqual(money.counts.receiptCount, 1)
        XCTAssertEqual(money.mostRelevantGoal?.title, "Build emergency fund")
        XCTAssertEqual(money.nextFocus, "Review later")
    }

    func testPrivacySafeProjectionHidesDetailsWithoutDroppingStructure() {
        let projector = LifeAreaAtlasProjector()
        let goal = makeGoal(id: "goal-private", title: "Sensitive goal", domain: .relationships)

        let overview = projector.overview(from: .init(goals: [goal], hiddenAreaIDs: [.init(domain: .relationships)]))
        let relationships = tryUnwrap(overview.areas.first { $0.definition.domainKey == .relationships })
        let compact = overview.privacySafeCompact
        let redactedRelationships = tryUnwrap(compact.areas.first { $0.definition.domainKey == .relationships })

        XCTAssertEqual(relationships.posture, .unavailable)
        XCTAssertEqual(relationships.activeGoals.first?.title, "Private item")
        XCTAssertEqual(relationships.accessibility.value, "Private area. Detail hidden.")
        XCTAssertEqual(redactedRelationships.nextFocus, "Detail hidden")
        XCTAssertEqual(compact.areas.count, LifeDomainKey.allCases.count)
    }

    func testAtlasCarriesFutureGroupingHooksWithoutCreatingTaskSurfaces() {
        let projector = LifeAreaAtlasProjector()
        let goal = makeGoal(id: "goal-creative", title: "Finish song", domain: .creativity)

        let atlas = projector.atlas(from: .init(goals: [goal], maxGoalReferencesPerArea: 1))
        let creativityHooks = tryUnwrap(atlas.relationshipHooks[LifeAreaID(domain: .creativity)])

        XCTAssertEqual(atlas.title, "Life Areas Atlas")
        XCTAssertTrue(atlas.supportsGoalsPreview)
        XCTAssertTrue(atlas.supportsYouOrganization)
        XCTAssertTrue(atlas.supportsFutureNorthStarGrouping)
        XCTAssertTrue(atlas.supportsFutureSemanticZoom)
        XCTAssertEqual(atlas.futureNorthStarCount, 0)
        XCTAssertEqual(atlas.oneStepGoalCount, 0)
        XCTAssertFalse(atlas.hasDormantDirection)
        XCTAssertEqual(creativityHooks.goalReferences.map(\.id), ["goal-creative"])
        XCTAssertTrue(creativityHooks.supportsOneStepGoalGrouping)
    }

    func testAtlasCarriesNorthStarCountsWithoutRedesigningGoalsSurface() {
        let projector = LifeAreaAtlasProjector()
        let northStar = NorthStar(
            id: NorthStarID(rawValue: "astronaut"),
            title: "Become an Astronaut",
            primaryLifeAreaID: LifeAreaID(domain: .career),
            posture: .dormant
        )

        let atlas = projector.atlas(from: .init(goals: [], northStars: [northStar]))
        let career = tryUnwrap(atlas.overview.areas.first { $0.definition.domainKey == .career })

        XCTAssertEqual(career.counts.northStarCount, 1)
        XCTAssertEqual(career.nextFocus, "Held without pressure")
        XCTAssertEqual(career.relationshipHooks.futureNorthStarCount, 1)
        XCTAssertTrue(career.relationshipHooks.hasDormantDirection)
        XCTAssertEqual(atlas.futureNorthStarCount, 1)
        XCTAssertTrue(atlas.hasDormantDirection)
    }

    func testAtlasCarriesOneStepGoalCountsAndReferencesWithoutRedesigningGoalsSurface() {
        let projector = LifeAreaAtlasProjector()
        let task = OneStepGoal(
            id: OneStepGoalID(rawValue: "email-portfolio"),
            title: "Email portfolio",
            lifeAreaID: LifeAreaID(domain: .career),
            status: .today
        )

        let atlas = projector.atlas(from: .init(goals: [], oneStepGoals: [task]))
        let career = tryUnwrap(atlas.overview.areas.first { $0.definition.domainKey == .career })

        XCTAssertEqual(career.counts.oneStepGoalCount, 1)
        XCTAssertEqual(career.nextFocus, "One-Step Goals available")
        XCTAssertEqual(career.relationshipHooks.oneStepGoalCount, 1)
        XCTAssertEqual(career.relationshipHooks.oneStepGoalReferences.map(\.kind), [.oneStepGoal])
        XCTAssertEqual(atlas.oneStepGoalCount, 1)
    }

    func testAtlasConsumesCanonicalGoalThreadHierarchiesAndPreservesThreadStepCommitmentProofAndReceiptReferences() {
        let projector = LifeAreaAtlasProjector()
        let goal = makeGoal(id: "goal-thread-career", title: "Ship the thread merge", domain: .career)
        let ambition = Ambition(
            id: "ambition-thread-career",
            title: "Career ambition",
            identityStatement: "Keep one canonical thread for the same work.",
            lifeAreaID: "career",
            desiredOutcome: "A single path stays inspectable.",
            desiredProofDescription: "The path keeps its step, commitment, proof, and receipt references.",
            activeGoalThreadID: "thread-career",
            activeCommitmentID: "commitment-career",
            knownConstraintIDs: [],
            recoveryPolicy: "Keep the path small and resumable.",
            createdAt: "2026-04-28T12:00:00Z",
            updatedAt: "2026-04-28T12:00:00Z"
        )
        let thread = GoalThread(
            id: "thread-career",
            ambitionID: ambition.id,
            lifeAreaID: "career",
            name: "Career thread",
            goalIDs: [goal.id],
            isActive: true,
            createdAt: "2026-04-28T12:00:00Z",
            updatedAt: "2026-04-28T12:00:00Z"
        )
        let commitment = Commitment(
            id: "commitment-career",
            ambitionID: ambition.id,
            goalThreadID: thread.id,
            stepID: "step-career",
            promisedFor: "2026-04-29",
            expectedEffort: "15 min",
            minimumProofDescription: "Show the thread still exists.",
            fitReason: "Fits the canonical path.",
            recoveryPolicy: "Restart with the smallest useful step.",
            status: .promised,
            createdAt: "2026-04-28T12:10:00Z",
            updatedAt: "2026-04-28T12:10:00Z"
        )
        let step = AmbitionGraphStep(
            id: "step-career",
            ambitionID: ambition.id,
            goalThreadID: thread.id,
            outcomeID: nil,
            name: "Open the next step",
            description: "Keep the path inspectable.",
            targetOrder: 1,
            expectedEffortMinutes: 15,
            isMilestone: true,
            createdAt: "2026-04-28T12:15:00Z",
            updatedAt: "2026-04-28T12:15:00Z"
        )
        let proof = Proof(
            id: "proof-career",
            ambitionID: ambition.id,
            goalThreadID: thread.id,
            commitmentID: commitment.id,
            closureEventID: "closure-career",
            proofType: .text,
            artifactReference: nil,
            text: "Saved a proof note for the thread.",
            source: "Goals",
            createdAt: "2026-04-28T12:20:00Z"
        )
        let recovery = RecoveryThread(
            id: "recovery-career",
            ambitionID: ambition.id,
            trigger: "The thread needed a receipt.",
            priorProofRefs: [proof.id],
            preservedProofRefs: [proof.id],
            receiptBehavior: .createOnReentry,
            whatChanged: "Kept the thread aligned.",
            newSmallestCommitment: "commitment-career-mini",
            status: .active,
            receiptID: "receipt-career",
            createdAt: "2026-04-28T12:25:00Z",
            updatedAt: "2026-04-28T12:25:00Z"
        )

        let hierarchy = AmbitionGraphGoalThreadHierarchy(
            goalThread: thread,
            ambition: ambition,
            commitments: [commitment],
            proofs: [proof],
            steps: [step],
            recoveryThreads: [recovery]
        )
        let goalReference = LifeGraphObjectReference(kind: .goal, id: goal.id, label: goal.title, sourceDomain: .goals)
        let proofReference = ProofReference(
            id: "proof-reference-career",
            kind: .completedAction,
            title: "Saved proof note",
            summary: "Supports the thread path.",
            sourceObject: goalReference,
            attachedObject: goalReference,
            occurredAt: "2026-04-28T12:20:00Z",
            strength: .supporting,
            sourceDomain: .proof
        )
        let receipt = ActionReceipt(
            id: "receipt-career",
            resultState: .completed,
            title: "Recorded thread receipt",
            summary: "Kept the thread aligned.",
            sourceDomain: .goals,
            occurredAt: "2026-04-28T12:25:00Z",
            affectedObjects: [goalReference]
        )

        let atlas = projector.atlas(from: .init(
            goals: [goal],
            goalThreadHierarchies: [hierarchy],
            proofProjection: ProofResourceGraphProjection(proofReferences: [proofReference]),
            receiptProjection: ActionReceiptProjection(receipts: [receipt])
        ))
        let career = tryUnwrap(atlas.overview.areas.first { $0.definition.domainKey == .career })

        XCTAssertEqual(career.counts.goalThreadCount, 1)
        XCTAssertEqual(career.nextFocus, "Ship the thread merge")
        XCTAssertEqual(career.relationshipHooks.goalThreadReferences.map(\.id), [thread.id])
        XCTAssertEqual(career.relationshipHooks.goalThreadPathReferences.map(\.id), [ambition.id, thread.id, goal.id, commitment.id, step.id, proof.id])
        XCTAssertEqual(career.relationshipHooks.stepReferences.map(\.id), [step.id])
        XCTAssertEqual(career.relationshipHooks.commitmentReferences.map(\.id), [commitment.id])
        XCTAssertEqual(career.relationshipHooks.proofReferences.map(\.id), [proofReference.id])
        XCTAssertEqual(career.relationshipHooks.receiptReferences.map(\.id), ["receipt-career"])
        XCTAssertTrue(career.relationshipHooks.supportsOneStepGoalGrouping)
        XCTAssertTrue(atlas.hasDormantDirection == false)
    }

    func testLifeAreaCountsDecodeOlderPayloadsWithoutNorthStarsOrOneStepGoals() throws {
        let data = """
        {
          "activeGoalCount": 1,
          "parkedGoalCount": 2,
          "waitingCount": 3,
          "proofCount": 4,
          "receiptCount": 5
        }
        """.data(using: .utf8)!

        let counts = try JSONDecoder().decode(LifeAreaCounts.self, from: data)

        XCTAssertEqual(counts.activeGoalCount, 1)
        XCTAssertEqual(counts.parkedGoalCount, 2)
        XCTAssertEqual(counts.goalThreadCount, 0)
        XCTAssertEqual(counts.northStarCount, 0)
        XCTAssertEqual(counts.oneStepGoalCount, 0)
        XCTAssertEqual(counts.waitingCount, 3)
        XCTAssertEqual(counts.proofCount, 4)
        XCTAssertEqual(counts.receiptCount, 5)
    }

    func testLifeAreaRelationshipHooksDecodeOlderPayloadsWithoutOneStepGoals() throws {
        let data = """
        {
          "goalReferences": [],
          "proofReferences": [],
          "receiptReferences": [],
          "waitingReferences": [],
          "futureNorthStarCount": 0,
          "hasDormantDirection": false,
          "supportsNorthStarGrouping": true,
          "supportsOneStepGoalGrouping": true
        }
        """.data(using: .utf8)!

        let hooks = try JSONDecoder().decode(LifeAreaRelationshipHooks.self, from: data)

        XCTAssertEqual(hooks.goalThreadReferences, [])
        XCTAssertEqual(hooks.goalThreadPathReferences, [])
        XCTAssertEqual(hooks.stepReferences, [])
        XCTAssertEqual(hooks.commitmentReferences, [])
        XCTAssertEqual(hooks.oneStepGoalReferences, [])
        XCTAssertEqual(hooks.oneStepGoalCount, 0)
        XCTAssertTrue(hooks.supportsOneStepGoalGrouping)
    }

    func testLifeAreaRelationshipHooksUseOrderedUniqueStableReferences() {
        let hooks = LifeAreaRelationshipHooks(
            goalReferences: [
                LifeGraphObjectReference(kind: .goal, id: "goal-b", label: "Beta", sourceDomain: .goals),
                LifeGraphObjectReference(kind: .goal, id: "goal-a", label: "Alpha", sourceDomain: .goals),
                LifeGraphObjectReference(kind: .goal, id: "goal-a", label: "Alpha", sourceDomain: .goals)
            ],
            proofReferences: [
                LifeGraphObjectReference(kind: .proof, id: "proof-b", label: "Beta proof", sourceDomain: .proof),
                LifeGraphObjectReference(kind: .proof, id: "proof-a", label: "Alpha proof", sourceDomain: .proof)
            ],
            receiptReferences: [
                LifeGraphObjectReference(kind: .receipt, id: "receipt-b", label: "Beta receipt", sourceDomain: .receipt),
                LifeGraphObjectReference(kind: .receipt, id: "receipt-a", label: "Alpha receipt", sourceDomain: .receipt)
            ]
        )

        XCTAssertEqual(hooks.goalReferences.map(\.id), ["goal-b", "goal-a"])
        XCTAssertEqual(hooks.proofReferences.map(\.id), ["proof-b", "proof-a"])
        XCTAssertEqual(hooks.receiptReferences.map(\.id), ["receipt-b", "receipt-a"])
    }
}

private extension LifeAreaAtlasProjectorTests {
    func tryUnwrap<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) -> T {
        guard let value else {
            XCTFail("Expected value", file: file, line: line)
            fatalError("Expected value")
        }
        return value
    }

    func makeGoal(
        id: String,
        title: String,
        domain: LifeDomainKey,
        state: GoalLifecycleState = .active,
        plan: GoalPlan? = nil
    ) -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-28T12:00:00Z",
            updatedAt: "2026-04-28T12:00:00Z",
            state: state,
            title: title,
            summary: "A grounded goal",
            mode: .project,
            relationshipKind: .independent,
            actor: .localOwner,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: GoalTiming(
                tempo: .untimed,
                timingType: .logWhenDone,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: 7
            ),
            planningStrategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: nil,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: plan,
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: domain)])
        )
    }

    func makePlan(goalID: String, blockedStepID: String) -> GoalPlan {
        GoalPlan(
            id: "plan-\(goalID)",
            goalID: goalID,
            version: 1,
            generatedAt: "2026-04-28T12:00:00Z",
            summary: "Plan",
            strategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            sections: [
                PlanSection(
                    id: "section-1",
                    goalID: goalID,
                    title: "Next",
                    summary: nil,
                    kind: .activeSteps,
                    orderIndex: 0,
                    steps: [
                        Step(
                            id: blockedStepID,
                            sectionID: "section-1",
                            title: "Waiting on bank reply",
                            summary: nil,
                            type: .actionUnit,
                            state: .blocked,
                            owner: .localOwner,
                            timing: GoalTiming(
                                tempo: .untimed,
                                timingType: .suggestedNext,
                                startsOn: nil,
                                dueAt: nil,
                                targetBy: nil,
                                windowStart: nil,
                                windowEnd: nil,
                                suggestedNextAt: nil,
                                repeatEveryDays: nil,
                                progressReviewCadenceDays: 7
                            ),
                            dependencyStepIDs: [],
                            isOptional: false,
                            isRepeatable: false,
                            evidenceRequired: false,
                            successSignals: ["Reply received"],
                            actionability: StepActionability(
                                action: "Check whether the bank replied",
                                completionDefinition: "The reply is known.",
                                evidenceOfCompletion: ["Reply is logged"],
                                fallbackMicroStep: "Open the latest message.",
                                contextRequirements: []
                            )
                        )
                    ]
                )
            ],
            assumptions: [],
            lint: PlanLintResult(goalID: goalID, planVersion: 1, isValid: true, issueCount: 0, issues: []),
            evaluation: nil
        )
    }
}
