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

    func testSharedLifeResponsibilitySummaryStaysAdditiveAndDerived() {
        let goal = sampleGoal(
            id: "household-goal",
            relationshipKind: .support,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .home)],
                roles: [LifeRole(kind: .responsibility, title: "Household support")],
                path: nil,
                stages: [],
                prerequisites: [],
                milestones: [],
                sharedLife: SharedLifeContext(
                    participants: [
                        SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner")
                    ],
                    responsibilities: [
                        SharedResponsibility(id: "pickup", title: "School pickup", kind: .care, participantID: "partner"),
                        SharedResponsibility(id: "groceries", title: "Groceries", kind: .household, participantID: "partner"),
                        SharedResponsibility(id: "dentist", title: "Dentist appointment", kind: .appointment, participantID: "partner", coordination: SharedCoordinationContext(kind: .appointment, title: "Dentist", summary: "Needs prep", preparationNote: "Bring forms"))
                    ]
                )
            )
        )

        let summary = LifeGraphResolver.sharedLifeSummary(for: goal, within: [goal], now: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(summary.responsibilitySummary.totalCount, 3)
        XCTAssertEqual(summary.responsibilitySummary.careCount, 1)
        XCTAssertEqual(summary.responsibilitySummary.householdCount, 1)
        XCTAssertEqual(summary.responsibilitySummary.appointmentCount, 1)
        XCTAssertEqual(summary.participantNames, ["Alex"])
        XCTAssertEqual(summary.coordinationSignals.first?.title, "Dentist")
    }

    func testSharedLifeSummaryUsesStructuralSupportLinksWhenMetadataIsAbsent() {
        let parent = sampleGoal(id: "parent", supportGoalIDs: ["support"], relationshipKind: .independent)
        let support = sampleGoal(id: "support", parentGoalID: "parent", relationshipKind: .support)

        let summary = LifeGraphResolver.sharedLifeSummary(
            for: parent,
            within: [parent, support],
            now: Date(timeIntervalSince1970: 0)
        )

        XCTAssertTrue(summary.delegatedSupportActive)
        XCTAssertEqual(summary.structuralSupportGoalCount, 1)
        XCTAssertTrue(summary.reasons.contains(where: { $0.localizedCaseInsensitiveContains("support") }))
    }

    func testLifeGraphObjectKindsCoverBatch77RelationshipReferences() {
        let supportedKinds = Set(LifeGraphObjectKind.allCases)

        XCTAssertTrue(supportedKinds.isSuperset(of: [
            .lifeArea,
            .northStar,
            .goal,
            .action,
            .step,
            .oneStepGoal,
            .capture,
            .commitment,
            .waitingItem,
            .proof,
            .evidence,
            .resource,
            .decision,
            .correction,
            .receipt
        ]))
        XCTAssertTrue(LifeGraphObjectKind.ambition.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.path.isPlaceholderOnlyInV1)
        XCTAssertFalse(LifeGraphObjectKind.oneStepGoal.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.commitment.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.waitingItem.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.proof.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.resource.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.receipt.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.review.isPlaceholderOnlyInV1)
        XCTAssertFalse(LifeGraphObjectKind.northStar.isPlaceholderOnlyInV1)
        XCTAssertFalse(LifeGraphObjectKind.goal.isPlaceholderOnlyInV1)
        XCTAssertFalse(LifeGraphObjectKind.capture.isPlaceholderOnlyInV1)
    }

    func testRelationshipRejectsMalformedEndpointsAndSelfRelationships() {
        let goal = LifeGraphObjectReference(kind: .goal, id: "goal-1", label: "Launch app", sourceDomain: .goals)
        let malformed = LifeGraphObjectReference(kind: .capture, id: "   ", label: "Capture")
        let sourceInvalid = LifeGraphRelationship(kind: .contains, source: malformed, target: goal)
        let targetInvalid = LifeGraphRelationship(kind: .supports, source: goal, target: malformed)
        let selfRelationship = LifeGraphRelationship(kind: .relatesTo, source: goal, target: goal)

        XCTAssertEqual(sourceInvalid.integrity, .invalidSource)
        XCTAssertEqual(targetInvalid.integrity, .invalidTarget)
        XCTAssertEqual(selfRelationship.integrity, .selfRelationship)

        let projection = LifeGraphRelationshipProjection(relationships: [sourceInvalid, targetInvalid, selfRelationship])
        XCTAssertTrue(projection.relationships.isEmpty)
    }

    func testRelationshipProjectionDeduplicatesAndOrdersDeterministically() {
        let goal = LifeGraphObjectReference(kind: .goal, id: "goal-1", label: "Launch app", sourceDomain: .goals)
        let stepA = LifeGraphObjectReference(kind: .step, id: "step-a", parentContextID: goal.id, label: "Build importer", sourceDomain: .goalEngine)
        let stepB = LifeGraphObjectReference(kind: .step, id: "step-b", parentContextID: goal.id, label: "Audit launch copy", sourceDomain: .goalEngine)
        let containsB = LifeGraphRelationship(kind: .contains, source: goal, target: stepB)
        let containsA = LifeGraphRelationship(kind: .contains, source: goal, target: stepA)

        let projection = LifeGraphRelationshipProjection(relationships: [containsB, containsA, containsA])

        XCTAssertEqual(projection.relationships.map(\.id), [containsA.id, containsB.id])
        XCTAssertEqual(projection.outgoing(from: goal).map(\.target.id), ["step-a", "step-b"])
        XCTAssertEqual(projection.incoming(to: stepA).map(\.source.id), ["goal-1"])
        XCTAssertEqual(projection.relatedObjects(from: goal, kind: .contains).map(\.id), ["step-b", "step-a"])
    }

    func testProjectionCreatesRelationshipsAndQueriesIncomingOutgoingObjects() {
        let goal = LifeGraphObjectReference(kind: .goal, id: "goal-1", label: "Launch app", sourceDomain: .goals)
        let action = LifeGraphObjectReference(kind: .action, id: "action-1", parentContextID: goal.id, label: "Ship build", sourceDomain: .goalEngine)
        let capture = LifeGraphObjectReference(kind: .capture, id: "capture-1", label: "Release checklist", sourceDomain: .capture)
        let proof = LifeGraphObjectReference(kind: .proof, id: "proof-placeholder-1", parentContextID: action.id, label: "Build artifact")

        var projection = LifeGraphRelationshipProjection()

        XCTAssertTrue(projection.add(LifeGraphRelationship(kind: .contains, source: goal, target: action)))
        XCTAssertFalse(projection.add(LifeGraphRelationship(kind: .contains, source: goal, target: action)))
        XCTAssertTrue(projection.add(LifeGraphRelationship(kind: .createdFrom, source: action, target: capture)))
        XCTAssertTrue(projection.add(LifeGraphRelationship(kind: .proves, source: proof, target: action)))

        XCTAssertEqual(projection.outgoing(from: goal, kind: .contains).map(\.target.id), ["action-1"])
        XCTAssertEqual(projection.relatedObjects(from: action, kind: .createdFrom).map(\.id), ["capture-1"])
        XCTAssertEqual(projection.sourceObjects(to: action, kind: .proves).map(\.id), ["proof-placeholder-1"])
        XCTAssertEqual(projection.relationships(involving: action, inMissionControlLane: .proof).map(\.source.id), ["proof-placeholder-1"])
    }

    func testBreadcrumbBuildsOrderedPathWithCycleProtection() {
        let goal = LifeGraphObjectReference(kind: .goal, id: "goal-1", label: "Launch app")
        let milestone = LifeGraphObjectReference(kind: .milestone, id: "milestone-1", parentContextID: goal.id, label: "Beta")
        let action = LifeGraphObjectReference(kind: .action, id: "action-1", parentContextID: milestone.id, label: "Invite testers")
        let orphan = LifeGraphObjectReference(kind: .decision, id: "decision-1", label: "Pause scope")

        let projection = LifeGraphRelationshipProjection(relationships: [
            LifeGraphRelationship(kind: .contains, source: goal, target: milestone),
            LifeGraphRelationship(kind: .contains, source: milestone, target: action),
            LifeGraphRelationship(kind: .belongsTo, source: goal, target: action)
        ])

        XCTAssertEqual(projection.breadcrumb(to: action).labels, ["Launch app", "Beta", "Invite testers"])
        XCTAssertEqual(projection.breadcrumb(to: orphan).labels, ["Pause scope"])
    }

    func testMissionControlLaneHelpersRemainStructuralOnly() {
        let goal = LifeGraphObjectReference(kind: .goal, id: "goal-1", label: "Launch app")
        let action = LifeGraphObjectReference(kind: .action, id: "action-1", label: "Ship build")
        let blocker = LifeGraphObjectReference(kind: .blocker, id: "blocker-1", label: "Missing certificate")
        let resource = LifeGraphObjectReference(kind: .resource, id: "resource-placeholder-1", label: "Release guide")
        let decision = LifeGraphObjectReference(kind: .decision, id: "decision-placeholder-1", label: "Use phased release")
        let receipt = LifeGraphObjectReference(kind: .receipt, id: "receipt-placeholder-1", label: "Build uploaded")

        let projection = LifeGraphRelationshipProjection(relationships: [
            LifeGraphRelationship(kind: .contains, source: goal, target: action),
            LifeGraphRelationship(kind: .blocks, source: blocker, target: action),
            LifeGraphRelationship(kind: .attachedTo, source: resource, target: action),
            LifeGraphRelationship(kind: .explains, source: decision, target: action),
            LifeGraphRelationship(kind: .produces, source: action, target: receipt)
        ])

        XCTAssertEqual(projection.relationships(involving: action, inMissionControlLane: .path).count, 1)
        XCTAssertEqual(projection.relationships(involving: action, inMissionControlLane: .risk).map(\.source.id), ["blocker-1"])
        XCTAssertEqual(projection.relationships(involving: action, inMissionControlLane: .resources).map(\.source.id), ["resource-placeholder-1"])
        XCTAssertEqual(projection.relationships(involving: action, inMissionControlLane: .decisions).map(\.source.id), ["decision-placeholder-1"])
        XCTAssertEqual(projection.relationships(involving: action, inMissionControlLane: .receipts).map(\.target.id), ["receipt-placeholder-1"])
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
