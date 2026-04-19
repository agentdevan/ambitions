import XCTest
@testable import Ambitions

final class LifeGraphModelsTests: XCTestCase {
    func testPrimaryDomainPrefersHighestPriorityAssignment() {
        let goal = sampleGoal(
            lifeGraph: LifeGraphContext(
                domains: [
                    LifeDomainAssignment(domain: .health, priority: 0.4),
                    LifeDomainAssignment(domain: .career, priority: 0.9)
                ],
                roles: [],
                path: nil,
                milestones: []
            )
        )

        XCTAssertEqual(LifeGraphResolver.primaryDomain(for: goal), .career)
    }

    func testGroupsGoalsByPrimaryDomain() {
        let careerGoal = sampleGoal(
            id: "career-goal",
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                roles: [],
                path: nil,
                milestones: []
            )
        )
        let healthGoal = sampleGoal(
            id: "health-goal",
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .health)],
                roles: [],
                path: nil,
                milestones: []
            )
        )
        let unassignedGoal = sampleGoal(id: "unassigned-goal", lifeGraph: nil)

        let grouped = LifeGraphResolver.groupGoalsByPrimaryDomain([careerGoal, healthGoal, unassignedGoal])

        XCTAssertEqual(grouped[.career]?.map(\.id), ["career-goal"])
        XCTAssertEqual(grouped[.health]?.map(\.id), ["health-goal"])
        XCTAssertEqual(grouped[nil]?.map(\.id), ["unassigned-goal"])
    }

    func testResolvesParentChildAndSupportRelationshipsStructurally() {
        let parent = sampleGoal(id: "parent", childGoalIDs: ["child"], supportGoalIDs: ["support"])
        let child = sampleGoal(id: "child", parentGoalID: "parent")
        let support = sampleGoal(id: "support", parentGoalID: "parent", relationshipKind: .support)

        let graph = LifeGraphResolver.relationshipGraph(for: parent, within: [parent, child, support])

        XCTAssertEqual(graph.parent?.id, nil)
        XCTAssertEqual(graph.children.map { $0.id }, ["child"])
        XCTAssertEqual(graph.supportGoals.map { $0.id }, ["support"])
    }

    func testResolvesMilestoneDependenciesInsideLifeGraphContext() {
        let context = LifeGraphContext(
            domains: [LifeDomainAssignment(domain: .career)],
            roles: [],
            path: LifePathDescriptor(kind: .careerTrack, title: "Astronaut path"),
            milestones: [
                LifeGraphMilestone(id: "education", title: "Finish degree", summary: nil, targetDate: "2027-05-15", stageID: "foundation", dependencyIDs: []),
                LifeGraphMilestone(id: "flight", title: "Flight hours", summary: nil, targetDate: "2028-09-01", stageID: "qualification", dependencyIDs: ["education"])
            ]
        )

        XCTAssertEqual(LifeGraphResolver.dependencies(forMilestoneID: "flight", in: context).map(\.id), ["education"])
        XCTAssertEqual(LifeGraphResolver.dependents(forMilestoneID: "education", in: context).map(\.id), ["flight"])
    }

    func testOrdersStagesAndResolvesBlockedPrerequisites() {
        let context = LifeGraphContext(
            domains: [LifeDomainAssignment(domain: .career)],
            roles: [],
            path: LifePathDescriptor(kind: .careerTrack, title: "Astronaut path"),
            stages: [
                LifePathStage(id: "application", title: "Application", orderIndex: 2),
                LifePathStage(id: "foundation", title: "Foundation", orderIndex: 0),
                LifePathStage(id: "qualification", title: "Qualification", orderIndex: 1)
            ],
            prerequisites: [
                LifePathPrerequisite(id: "application-needs-qualification", title: "Application needs qualification", kind: .stage, stageID: "application", requiredStageID: "qualification")
            ],
            milestones: []
        )

        XCTAssertEqual(LifeGraphResolver.orderedStages(in: context).map(\.id), ["foundation", "qualification", "application"])
        XCTAssertEqual(
            LifeGraphResolver.blockedPrerequisites(forStageID: "application", in: context, completedMilestoneIDs: [], completedStageIDs: []).map(\.id),
            ["application-needs-qualification"]
        )
        XCTAssertTrue(
            LifeGraphResolver.blockedPrerequisites(forStageID: "application", in: context, completedMilestoneIDs: [], completedStageIDs: ["qualification"]).isEmpty
        )
    }

    func testBuildsConservativePathStateSummaryFromGoalPlan() throws {
        let context = LifeGraphContext(
            domains: [LifeDomainAssignment(domain: .career)],
            roles: [],
            path: LifePathDescriptor(kind: .careerTrack, title: "Astronaut path"),
            stages: [
                LifePathStage(id: "foundation", title: "Foundation", orderIndex: 0, readinessSignals: [
                    LifePathSignal(id: "foundation-gap", title: "Baseline still forming", kind: .readiness, isGap: true)
                ]),
                LifePathStage(id: "qualification", title: "Qualification", orderIndex: 1)
            ],
            prerequisites: [
                LifePathPrerequisite(id: "qualification-needs-degree", title: "Qualification needs degree", kind: .milestone, stageID: "qualification", requiredMilestoneID: "degree")
            ],
            milestones: [
                LifeGraphMilestone(id: "degree", title: "Finish degree", stageID: "foundation"),
                LifeGraphMilestone(id: "experience", title: "Build experience", stageID: "qualification", dependencyIDs: ["degree"])
            ]
        )
        let goal = sampleGoal(
            lifeGraph: context,
            plan: GoalPlan(
                id: "plan-1",
                goalID: "goal-1",
                version: 1,
                generatedAt: "2026-04-20T12:00:00Z",
                summary: "Plan",
                strategy: sampleStrategy(),
                sections: [
                    PlanSection(id: "section-1", goalID: "goal-1", title: "Milestones", summary: nil, kind: .overview, orderIndex: 0, steps: [
                        completedStep(id: "step-1", title: "Finish degree")
                    ])
                ],
                assumptions: [],
                lint: PlanLintResult(goalID: "goal-1", planVersion: 1, isValid: true, issueCount: 0, issues: []),
                evaluation: nil
            )
        )

        let summary = try XCTUnwrap(LifeGraphResolver.pathStateSummary(for: goal))

        XCTAssertEqual(summary.progression.completedMilestoneIDs, ["degree"])
        XCTAssertEqual(summary.progression.nextMilestoneID, "experience")
        XCTAssertEqual(summary.activeStageID, "qualification")
        XCTAssertEqual(summary.blockedPrerequisites.map(\.id), [])
        XCTAssertEqual(summary.readiness.gapCount, 0)
    }
}

private extension LifeGraphModelsTests {
    func sampleGoal(
        id: String = "goal-1",
        parentGoalID: String? = nil,
        childGoalIDs: [String] = [],
        supportGoalIDs: [String] = [],
        relationshipKind: GoalRelationshipKind = .independent,
        lifeGraph: LifeGraphContext? = nil,
        plan: GoalPlan? = nil
    ) -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-20T12:00:00Z",
            updatedAt: "2026-04-20T12:00:00Z",
            state: .active,
            title: id,
            summary: nil,
            mode: .project,
            relationshipKind: relationshipKind,
            actor: .localOwner,
            parentGoalID: parentGoalID,
            childGoalIDs: childGoalIDs,
            supportGoalIDs: supportGoalIDs,
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
            lifeGraph: lifeGraph
        )
    }

    func sampleStrategy() -> PlanningStrategy {
        PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 3,
            preferredSectionOrder: [.overview, .activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
    }

    func completedStep(id: String, title: String) -> Step {
        Step(
            id: id,
            sectionID: "section-1",
            title: title,
            summary: nil,
            type: .actionUnit,
            state: .completed,
            owner: .localOwner,
            timing: GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: [title],
            actionability: StepActionability(action: title, completionDefinition: title, evidenceOfCompletion: [title], fallbackMicroStep: title, contextRequirements: [])
        )
    }
}
