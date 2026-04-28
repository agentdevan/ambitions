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

    func testAtlasIsFutureReadyWithoutCreatingNorthStarOrTaskObjects() {
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
        XCTAssertFalse(atlas.hasDormantDirection)
        XCTAssertEqual(creativityHooks.goalReferences.map(\.id), ["goal-creative"])
        XCTAssertTrue(creativityHooks.supportsOneStepGoalGrouping)
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
