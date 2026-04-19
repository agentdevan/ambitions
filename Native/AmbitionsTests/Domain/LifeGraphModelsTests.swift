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
                LifeGraphMilestone(id: "education", title: "Finish degree", summary: nil, targetDate: "2027-05-15", dependencyIDs: []),
                LifeGraphMilestone(id: "flight", title: "Flight hours", summary: nil, targetDate: "2028-09-01", dependencyIDs: ["education"])
            ]
        )

        XCTAssertEqual(LifeGraphResolver.dependencies(forMilestoneID: "flight", in: context).map(\.id), ["education"])
        XCTAssertEqual(LifeGraphResolver.dependents(forMilestoneID: "education", in: context).map(\.id), ["flight"])
    }
}

private extension LifeGraphModelsTests {
    func sampleGoal(
        id: String = "goal-1",
        parentGoalID: String? = nil,
        childGoalIDs: [String] = [],
        supportGoalIDs: [String] = [],
        relationshipKind: GoalRelationshipKind = .independent,
        lifeGraph: LifeGraphContext? = nil
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
            plan: nil,
            lifeGraph: lifeGraph
        )
    }
}
