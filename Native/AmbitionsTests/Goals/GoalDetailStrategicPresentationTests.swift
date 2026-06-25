import XCTest
@testable import Ambitions

final class GoalDetailStrategicPresentationTests: XCTestCase {
    func testRepositoryBackedDetailProjectsStrategicFirstLayerForActiveGoal() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)

        XCTAssertFalse(detail.strategicStatus.title.isEmpty)
        XCTAssertFalse(detail.strategicStatus.summary.isEmpty)
        XCTAssertNotNil(detail.nextMovement)
        XCTAssertFalse(detail.pathStages.isEmpty)
        XCTAssertTrue(detail.pathStages.contains(where: { $0.position == .current || $0.position == .blocked }))
        XCTAssertTrue(detail.pathStages.contains(where: { $0.lifecycleMarkerLabel == "Current position" || $0.lifecycleMarkerLabel == "Friction marker" }))
        XCTAssertTrue(detail.pathStages.allSatisfy { $0.accessibilitySummary.isEmpty == false })
        XCTAssertFalse(detail.trajectory.phaseTitle.isEmpty)
    }

    func testMissionControlLanesExistForNormalActiveGoal() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)

        XCTAssertEqual(missionControl.lanes.map(\.kind), [.proof, .overview, .risks, .steps, .path])
        XCTAssertEqual(missionControl.lanes.map(\.title), ["Completed", "Now", "Friction", "Next", "Horizon"])
        XCTAssertFalse(missionControl.currentTruth.isEmpty)
        XCTAssertEqual(missionControl.sourceLabel, "Based on this goal")
        XCTAssertEqual(missionControl.ownershipLabel, "You own the path")
        XCTAssertTrue(missionControl.proofBoundaryLabel.contains("Proof"))
        XCTAssertEqual(missionControl.lanes.first(where: { $0.kind == .steps })?.badgeTitle, "Next step")
        XCTAssertTrue(missionControl.lanes.first(where: { $0.kind == .proof })?.summary.contains("Needs evidence") == true)
        XCTAssertEqual(missionControl.decisions.emptyTitle, "No decisions yet")
        XCTAssertEqual(missionControl.risks.emptyTitle, "No major risk visible")
        XCTAssertFalse(missionControl.archive.title.isEmpty)
        XCTAssertFalse(missionControl.timeline.items.isEmpty)
        XCTAssertEqual(missionControl.reviewTrail.items.map(\.kind), [.proof, .decision, .assumption, .receipt])
        XCTAssertTrue(missionControl.reviewTrail.accessibilitySummary.contains("Receipt"))
    }

    func testMissionControlLanePrimitivePreservesGoalDetailLaneContract() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Ship the family emergency plan"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)
        let completedLane = try XCTUnwrap(missionControl.lanes.first(where: { $0.kind == .proof }))
        let laneItem = MissionControlLaneItem(detailLane: completedLane)

        XCTAssertEqual(laneItem.id, GoalDetailMissionLaneKind.proof.rawValue)
        XCTAssertEqual(laneItem.title, completedLane.title)
        XCTAssertEqual(laneItem.value, completedLane.headline)
        XCTAssertEqual(laneItem.badgeTitle, completedLane.badgeTitle)
        XCTAssertEqual(laneItem.accessibilityIdentifier, completedLane.kind.accessibilityIdentifier)
        XCTAssertTrue(laneItem.accessibilityHint.contains("this goal thread"))
        XCTAssertFalse(laneItem.accessibilityHint.contains("MissionControlTimeSpine"))
    }

    @MainActor
    func testFCP10MissionControlTimeSpinePreservesOrderAndInspection() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Ship a proof-backed mission spine"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)
        let items = missionControl.lanes.map(MissionControlLaneItem.init(detailLane:))
        _ = MissionControlTimeSpine(
            items: items,
            defaultSelectedID: GoalDetailMissionLaneKind.overview.rawValue
        )

        XCTAssertEqual(missionControl.lanes.map(\.title), ["Completed", "Now", "Friction", "Next", "Horizon"])
        XCTAssertEqual(items.map(\.id), ["proof", "overview", "risks", "steps", "path"])
        XCTAssertTrue(items.first(where: { $0.id == "proof" })?.accessibilityHint.contains("this goal thread") == true)
        XCTAssertFalse(items.first(where: { $0.id == "proof" })?.accessibilityHint.contains("MissionControlTimeSpine") == true)
        XCTAssertEqual(items.first(where: { $0.id == "risks" })?.title, "Friction")
        XCTAssertFalse(items.first(where: { $0.id == "risks" })?.detail.isEmpty == true)
        XCTAssertTrue(items.first(where: { $0.id == "steps" })?.detail.localizedCaseInsensitiveContains("Step") == true)
        XCTAssertTrue(items.first(where: { $0.id == "path" })?.detail.localizedCaseInsensitiveContains("Decisions") == true)

        let visibleCopy = items.flatMap { [$0.title, $0.value, $0.detail, $0.accessibilityHint] }.joined(separator: " ").lowercased()
        XCTAssertFalse(visibleCopy.contains("goal mission control"))
        XCTAssertFalse(visibleCopy.contains("dashboard metrics grid"))
        XCTAssertFalse(visibleCopy.contains("kanban"))
        XCTAssertFalse(visibleCopy.contains("enterprise pm"))
        XCTAssertFalse(visibleCopy.contains("sparkline-as-product"))
    }

    func testM07PathBuilderConnectsRoadmapForkProofAndTodayWithoutNewTab() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Build a family emergency fund by 2026-12-01"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let pathBuilder = try XCTUnwrap(detail.pathBuilder)
        let combinedCopy = (
            [pathBuilder.title, pathBuilder.subtitle, pathBuilder.todayConnectionTitle, pathBuilder.todayConnectionSummary, pathBuilder.decisionReceiptSummary]
                + pathBuilder.phases.flatMap { [$0.title, $0.summary, $0.dependencySummary, $0.proofSummary] }
                + pathBuilder.forks.flatMap { [$0.title, $0.summary, $0.basisSummary, $0.decisionPrompt] }
                + pathBuilder.tradeoffReview.lanes.flatMap { [$0.title, $0.summary, $0.effortLabel, $0.timeLabel, $0.energyLabel, $0.reviewRequirementLabel, $0.recoveryLabel] }
        ).joined(separator: " ")

        XCTAssertEqual(pathBuilder.title, "Path Builder")
        XCTAssertFalse(pathBuilder.phases.isEmpty)
        XCTAssertLessThanOrEqual(pathBuilder.phases.count, 6)
        XCTAssertFalse(pathBuilder.proofRequirements.isEmpty)
        XCTAssertFalse(pathBuilder.tradeoffReview.lanes.isEmpty)
        XCTAssertTrue(pathBuilder.tradeoffReview.lanes.allSatisfy {
            $0.reviewRequirementLabel.localizedCaseInsensitiveContains("user review required")
        })
        XCTAssertTrue(pathBuilder.tradeoffReview.lanes.allSatisfy {
            $0.recoveryLabel.localizedCaseInsensitiveContains("recovery")
        })
        XCTAssertTrue(pathBuilder.tradeoffReview.accessibilitySummary.localizedCaseInsensitiveContains("energy"))
        XCTAssertTrue(pathBuilder.forks.contains(where: { $0.decisionPrompt.localizedCaseInsensitiveContains("choose, edit, or park") }))
        XCTAssertTrue(pathBuilder.todayConnectionTitle.isEmpty == false)
        XCTAssertEqual(pathBuilder.roadmapListTitle, "Path list")
        XCTAssertTrue(pathBuilder.performanceBudgetSummary.contains("\(pathBuilder.phases.count) phases"))
        XCTAssertTrue(pathBuilder.performanceBudgetSummary.contains("route options"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("AI decided"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("fully automated"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("best path"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("highest score"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("Path tab"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("Roadmap"))
        XCTAssertEqual(detail.screenContractSnapshot().topLevelTabTitles, ScreenContractValidator.canonicalTopLevelTabs)
    }

    func testFCP13BDecisionSpineFoldsAlternatePathsAndHistoryWithoutAutomatedReroute() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Build a family emergency fund by 2026-12-01"),
            now: Self.fixedNow
        )
        let initialDetail = try await service.loadDetail(target: created.target)
        let primaryStepID = try XCTUnwrap(initialDetail.primaryStepID)

        _ = try await service.performAction(
            GoalDetailActionRequest(target: created.target, kind: .delay, stepID: primaryStepID),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)
        let pathBuilder = try XCTUnwrap(detail.pathBuilder)
        let decisionSpine = GoalAlternatePathDecisionSpineState(
            decisions: missionControl.decisions,
            pathBuilder: pathBuilder
        )
        let combinedCopy = (
            [decisionSpine.title, decisionSpine.subtitle, decisionSpine.boundaryLabel, decisionSpine.accessibilitySummary]
                + decisionSpine.branches.flatMap {
                    [
                        $0.kind.title,
                        $0.title,
                        $0.summary,
                        $0.basisLabel,
                        $0.reviewLabel,
                        $0.consequenceLabel,
                        $0.mutationBoundaryLabel,
                        $0.freshnessLabel,
                    ]
                }
        ).joined(separator: " ")

        XCTAssertEqual(decisionSpine.title, "Decision Spine")
        XCTAssertFalse(decisionSpine.branches.isEmpty)
        XCTAssertTrue(decisionSpine.branches.contains { $0.kind == .alternatePath })
        XCTAssertTrue(decisionSpine.branches.contains { $0.kind == .decisionHistory })
        XCTAssertTrue(decisionSpine.branches.allSatisfy {
            $0.reviewLabel.localizedCaseInsensitiveContains("review")
        })
        XCTAssertTrue(decisionSpine.branches.allSatisfy {
            $0.mutationBoundaryLabel.localizedCaseInsensitiveContains("no")
        })
        XCTAssertTrue(combinedCopy.localizedCaseInsensitiveContains("No automated reroute"))
        XCTAssertTrue(combinedCopy.localizedCaseInsensitiveContains("no hidden plan or path mutation"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("AI decided"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("fully automated"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("kanban"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("PM dashboard"))
    }

    func testFCP11LifePathThreadPreservesOrderPrimitivesAndPrivateRedaction() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Build a family emergency fund by 2026-12-01"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let pathBuilder = try XCTUnwrap(detail.pathBuilder)
        let thread = LifePathThreadState(stages: detail.pathStages, pathBuilder: pathBuilder)

        XCTAssertEqual(thread.title, "LifePath Thread")
        XCTAssertEqual(thread.nodes.map(\.order), Array(1...thread.nodes.count))
        XCTAssertTrue(thread.nodes.allSatisfy { $0.nonColorMeaning.isEmpty == false })
        XCTAssertFalse(thread.proofBeads.isEmpty)
        XCTAssertFalse(thread.alternateRouteFolds.isEmpty)
        XCTAssertEqual(thread.sourceFold.title, "GoalPathSourceFold")
        XCTAssertTrue(thread.accessibilityValue.contains("Order 1"))
        XCTAssertTrue(thread.accessibilityHint.contains("proof beads"))
        XCTAssertTrue(thread.accessibilityHint.contains("risk pinch"))
        XCTAssertTrue(thread.accessibilityHint.contains("alternate route fold"))
        XCTAssertTrue(thread.accessibilityHint.contains("source fold"))
        XCTAssertFalse(thread.nodes.map(\.title).joined(separator: " ").localizedCaseInsensitiveContains("roadmap board"))
        XCTAssertFalse(thread.nodes.map(\.title).joined(separator: " ").localizedCaseInsensitiveContains("timeline clone"))

        let privateThread = LifePathThreadState(stages: detail.pathStages, pathBuilder: pathBuilder, privacySensitive: true)
        XCTAssertTrue(privateThread.nodes.allSatisfy { $0.title == "Private path stage" })
        XCTAssertTrue(privateThread.proofBeads.allSatisfy { $0.summary == "Proof detail hidden." })
        XCTAssertTrue(privateThread.sourceFold.privacyLabel.localizedCaseInsensitiveContains("hides titles"))
    }

    func testFCP11BlockedPathCreatesRiskPinchWithoutColorOnlyMeaning() throws {
        let blockedStage = GoalPathStage(
            id: "blocked-stage",
            title: "Waiting on the permit",
            summary: "The path cannot move until the real blocker is resolved.",
            stepCountLabel: "1 step",
            position: .blocked,
            statusLabel: "Blocked",
            highlight: "Call the office",
            state: .warning
        )
        let thread = LifePathThreadState(stages: [blockedStage], pathBuilder: nil)

        XCTAssertFalse(thread.riskPinches.isEmpty)
        XCTAssertTrue(thread.riskPinches.contains { $0.title.localizedCaseInsensitiveContains("Risk") || $0.title.localizedCaseInsensitiveContains("review") })
        XCTAssertTrue(thread.riskPinches.allSatisfy { $0.summary.isEmpty == false })
        XCTAssertTrue(thread.nodes.contains { $0.nonColorMeaning.localizedCaseInsensitiveContains("Risk visible") })
    }

    func testD14GoalDetailScreenContractSnapshotSatisfiesImplementationGate() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Align the Goal Detail lanes"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let contract = ScreenContractRegistry.contract(for: .goalDetail)
        let issues = ScreenContractValidator.validate(
            snapshot: detail.screenContractSnapshot(),
            against: contract
        )

        XCTAssertTrue(issues.isEmpty, issues.map(\.message).joined(separator: "\n"))
    }

    func testProofRailShowsProofSummaryAndEmptyStateTruthfully() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Create a public demo"),
            now: Self.fixedNow
        )

        var emptyDetail = try await service.loadDetail(target: created.target)
        var missionControl = try XCTUnwrap(emptyDetail.missionControl)
        XCTAssertEqual(missionControl.proofRail.emptyTitle, "No evidence yet")
        XCTAssertTrue(missionControl.proofRail.items.isEmpty)
        XCTAssertEqual(missionControl.lanes.first(where: { $0.kind == .proof })?.headline, "No evidence yet")

        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "evidence-demo",
                goalID: try XCTUnwrap(created.target.goalID),
                stepID: emptyDetail.primaryStepID,
                evidenceKind: .milestoneReached,
                source: .manual,
                capturedAt: "2026-04-26T12:00:00Z",
                progressDelta: nil,
                confidenceDelta: nil,
                minutesInvested: 30,
                note: "Demo shipped"
            )
        ])

        emptyDetail = try await service.loadDetail(target: created.target)
        missionControl = try XCTUnwrap(emptyDetail.missionControl)
        XCTAssertEqual(missionControl.proofRail.items.first?.title, "Demo shipped")
        XCTAssertEqual(missionControl.lanes.first(where: { $0.kind == .proof })?.badgeTitle, "Evidence visible")
    }

    func testFCP12EvidenceRailCarriesContextFreshnessPrivacyCorrectionAndStaleBoundary() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Keep launch evidence honest"),
            now: Self.fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)

        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "evidence-stale",
                goalID: goalID,
                stepID: nil,
                evidenceKind: .observationLogged,
                source: .manual,
                capturedAt: "2026-03-01T12:00:00Z",
                progressDelta: nil,
                confidenceDelta: nil,
                minutesInvested: nil,
                note: "Old proof needs review"
            ),
            ProgressEvidence(
                id: "evidence-imported",
                goalID: goalID,
                stepID: nil,
                evidenceKind: .reflectionLogged,
                source: .imported,
                capturedAt: "2026-04-26T12:00:00Z",
                progressDelta: nil,
                confidenceDelta: nil,
                minutesInvested: nil,
                note: "Imported proof needs correction posture"
            )
        ])

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)
        let staleBead = try XCTUnwrap(missionControl.proofRail.spineBeads.first(where: { $0.id == "evidence-stale" }))
        let importedBead = try XCTUnwrap(missionControl.proofRail.spineBeads.first(where: { $0.id == "evidence-imported" }))

        XCTAssertEqual(staleBead.freshness, .stale)
        XCTAssertTrue(staleBead.requiresReviewBeforeRecommendation)
        XCTAssertTrue(staleBead.staleReviewLabel?.localizedCaseInsensitiveContains("Review before recommendations") == true)
        XCTAssertTrue(staleBead.privacyLabel.localizedCaseInsensitiveContains("Private to this goal"))
        XCTAssertTrue(staleBead.correctionLabel?.localizedCaseInsensitiveContains("Correction can be reviewed") == true)
        XCTAssertEqual(importedBead.freshness, .partial)
        XCTAssertTrue(importedBead.privacyLabel.localizedCaseInsensitiveContains("Imported proof stays local"))
        XCTAssertTrue(missionControl.proofRail.subtitle.localizedCaseInsensitiveContains("context"))
        XCTAssertTrue(missionControl.proofRail.subtitle.localizedCaseInsensitiveContains("privacy"))
        XCTAssertFalse(missionControl.proofRail.subtitle.localizedCaseInsensitiveContains("trophy"))
        XCTAssertFalse(missionControl.proofRail.subtitle.localizedCaseInsensitiveContains("activity feed"))
    }

    func testMissionControlDegradesWhenGoalHasNoNextStep() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Publish a tiny field guide"),
            now: Self.fixedNow
        )
        let goals = try await repositories.goals.listGoals()
        var goal = try XCTUnwrap(goals.first)
        let completedPlan = try XCTUnwrap(goal.plan)
        goal = Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: GoalPlan(
                id: completedPlan.id,
                goalID: completedPlan.goalID,
                version: completedPlan.version,
                generatedAt: completedPlan.generatedAt,
                summary: completedPlan.summary,
                strategy: completedPlan.strategy,
                sections: completedPlan.sections.map { section in
                    PlanSection(
                        id: section.id,
                        goalID: section.goalID,
                        title: section.title,
                        summary: section.summary,
                        kind: section.kind,
                        orderIndex: section.orderIndex,
                        steps: section.steps.map { step in
                            Step(
                                id: step.id,
                                sectionID: step.sectionID,
                                title: step.title,
                                summary: step.summary,
                                type: step.type,
                                state: .completed,
                                owner: step.owner,
                                timing: step.timing,
                                dependencyStepIDs: step.dependencyStepIDs,
                                isOptional: step.isOptional,
                                isRepeatable: step.isRepeatable,
                                evidenceRequired: step.evidenceRequired,
                                successSignals: step.successSignals,
                                actionability: step.actionability
                            )
                        }
                    )
                },
                assumptions: completedPlan.assumptions,
                lint: completedPlan.lint
            ),
            lifeGraph: goal.lifeGraph
        )
        try await repositories.goals.saveGoals([goal])

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)

        XCTAssertEqual(missionControl.primaryNextMove.title, "Needs a next step")
        XCTAssertEqual(missionControl.lanes.first(where: { $0.kind == .steps })?.badgeTitle, "Needs review")
        XCTAssertTrue(missionControl.assumptions.contains(where: { $0.id == "next-step" && $0.status == "Needs review" }))
    }

    func testBlockedGoalSurfacesRiskLaneAndDistinctState() throws {
        let detail = Self.tryUnwrapScenario(PreviewGoalsScenarios.blockedTarget.id)
        let missionControl = try XCTUnwrap(detail.missionControl)

        XCTAssertEqual(detail.headline.renderState, .blocked)
        XCTAssertEqual(missionControl.lanes.first(where: { $0.kind == .risks })?.headline, "Blocked")
        XCTAssertEqual(missionControl.risks.items.first?.title, "Blocked")
        XCTAssertTrue(missionControl.timeline.items.contains(where: { $0.kind == .waiting || $0.kind == .current }))
    }

    func testCompletedCancelledAndParkedTimelineStatesStayDistinct() throws {
        let completed = Self.tryUnwrapScenario(PreviewGoalsScenarios.completedTarget.id)
        let parked = Self.tryUnwrapScenario(PreviewGoalsScenarios.parkedTarget.id)
        let cancelled = Self.tryUnwrapScenario(PreviewGoalsScenarios.cancelledTarget.id)

        XCTAssertTrue(completed.missionControl?.timeline.items.contains(where: { $0.kind == .completed }) == true)
        XCTAssertTrue(parked.missionControl?.timeline.items.contains(where: { $0.kind == .parked }) == true)
        XCTAssertTrue(cancelled.missionControl?.timeline.items.contains(where: { $0.kind == .cancelled }) == true)
    }

    func testBreadcrumbTimelineAssumptionsAndReceiptsStayTruthful() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Build a calm portfolio sample"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)

        XCTAssertEqual(missionControl.breadcrumb.labels.last, "Build a calm portfolio sample")
        XCTAssertTrue(missionControl.breadcrumb.fallbackUsed)
        XCTAssertTrue(missionControl.timeline.items.contains(where: { $0.kind == .current }))
        XCTAssertTrue(missionControl.timeline.items.contains(where: { $0.kind == .next && $0.isFuture }))
        XCTAssertFalse(missionControl.assumptions.isEmpty)
        XCTAssertTrue(missionControl.assumptions.contains(where: { $0.correctionLabel != nil }))
        XCTAssertTrue(missionControl.receipts.items.isEmpty)
        XCTAssertEqual(missionControl.receipts.emptyMessage, "Receipts will appear here after goal changes are recorded.")
        XCTAssertEqual(missionControl.reviewTrail.items.last?.reversibilityLabel, "Reversibility only when available")
        XCTAssertTrue(missionControl.reviewTrail.items.contains(where: { $0.sourceLabel == "Assumption" && $0.reviewLabel.localizedCaseInsensitiveContains("review") }))
    }

    func testMissionControlCopyAvoidsTechnicalEngineNames() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Build a proof-backed launch note"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)
        let missionControl = try XCTUnwrap(detail.missionControl)
        let headerCopy = [
            missionControl.currentTruth,
            missionControl.receipts.subtitle,
            missionControl.proofRail.subtitle,
        ]
        let laneCopy = missionControl.lanes.flatMap { lane in
            [lane.title, lane.headline, lane.summary, lane.detail]
        }
        let assumptionCopy = missionControl.assumptions.flatMap { assumption in
            [assumption.title, assumption.status, assumption.whyItMatters, assumption.correctionLabel ?? ""]
        }
        let reviewCopy = missionControl.reviewTrail.items.flatMap { item in
            [item.title, item.summary, item.sourceLabel, item.reviewLabel, item.reversibilityLabel]
        }
        let copy = (headerCopy + laneCopy + assumptionCopy + reviewCopy).joined(separator: " ")

        for forbidden in ["Life Graph", "Believability Kernel", "Action Closure Layer", "Proof Graph", "Promise Ledger", "Safe Automation Boundary", "Assumption Watchtower", "RC maturity"] {
            XCTAssertFalse(copy.contains(forbidden), "Unexpected technical copy: \(forbidden)")
        }
        for forbidden in ["AI verified", "AI confidence", "notification feed", "activity feed", "classified as"] {
            XCTAssertFalse(copy.localizedCaseInsensitiveContains(forbidden), "Unexpected trust copy: \(forbidden)")
        }
    }

    func testStarterPreviewKeepsFirstLayerStrategicReadVisible() {
        let detail = Self.tryUnwrapScenario(PreviewGoalsScenarios.starterTarget.id)

        XCTAssertEqual(detail.strategicStatus.title, "Starter path is taking shape")
        XCTAssertEqual(detail.pathStages.first?.position, .current)
        XCTAssertEqual(detail.nextMovement?.title, "Record one rough pass")
        XCTAssertEqual(detail.recentMovement.items.count, 0)
    }

    func testMakePathStagesFallsBackToSectionDerivedFilmstrip() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let section = PlanSection(
            id: "section-1",
            goalID: "goal-1",
            title: "Now",
            summary: "The highest-leverage move still open.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: [
                Step(
                    id: "step-1",
                    sectionID: "section-1",
                    title: "Outline the talk pitch",
                    summary: "Turn the idea into one visible draft.",
                    type: .actionUnit,
                    state: .planned,
                    owner: .localOwner,
                    timing: GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: nil),
                    dependencyStepIDs: [],
                    isOptional: false,
                    isRepeatable: false,
                    evidenceRequired: false,
                    successSignals: ["A visible draft exists."],
                    actionability: StepActionability(
                        action: "Draft the opener",
                        completionDefinition: "The opener is written.",
                        evidenceOfCompletion: ["One visible draft."],
                        fallbackMicroStep: "Draft the opener",
                        contextRequirements: []
                    )
                )
            ]
        )

        let stages = service.makePathStagesForTesting(pathSummary: nil, sections: [section], renderState: .starter)

        XCTAssertEqual(stages.count, 1)
        XCTAssertEqual(stages.first?.position, .current)
        XCTAssertEqual(stages.first?.statusLabel, "Current")
        XCTAssertEqual(stages.first?.highlight, "Outline the talk pitch")
        XCTAssertEqual(stages.first?.lifecycleMarkerLabel, "Current position")
        XCTAssertEqual(stages.first?.progressShapeLabel, "In motion now")
    }

    func testMakePathStagesSynthesizesFilmstripWhenNoPathOrSectionsExist() async throws {
        let repositories = try await Self.makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let blockedStages = service.makePathStagesForTesting(pathSummary: nil, sections: [], renderState: .blocked)
        XCTAssertEqual(blockedStages.count, 1)
        XCTAssertEqual(blockedStages.first?.position, .blocked)
        XCTAssertEqual(blockedStages.first?.highlight, "Resolve the blocker")
        XCTAssertEqual(blockedStages.first?.riskMarkerLabel, "Risk visible")

        let starterStages = service.makePathStagesForTesting(pathSummary: nil, sections: [], renderState: .starter)
        XCTAssertEqual(starterStages.count, 1)
        XCTAssertEqual(starterStages.first?.position, .current)
        XCTAssertEqual(starterStages.first?.highlight, "Take the first visible step")
        XCTAssertEqual(starterStages.first?.proofMarkerLabel, "Proof can be added here")
    }

    func testClarificationAndBlockedScenariosKeepTruthFirstMovement() {
        let clarification = Self.tryUnwrapScenario(PreviewGoalsScenarios.clarificationTarget.id)
        XCTAssertEqual(clarification.strategicStatus.title, "Clarification is the real work right now")
        XCTAssertEqual(clarification.nextMovement?.state, .warning)
        XCTAssertEqual(clarification.nextMovement?.title, "Answer the missing question")

        let blocked = Self.tryUnwrapScenario(PreviewGoalsScenarios.blockedTarget.id)
        XCTAssertEqual(blocked.strategicStatus.title, "The path is waiting on a real blocker")
        XCTAssertEqual(blocked.nextMovement?.state, .warning)
        XCTAssertEqual(blocked.nextMovement?.title, "Resolve the blocker")
    }

    func testExplainabilityRemainsAvailableWithoutOwningFirstLayer() async throws {
        let repositories = try await Self.makeRepositories()
        let runtime = RepositoryBackedRuntimeGoalIntelligenceService(repositories: repositories)
        let service = RepositoryBackedGoalsService(
            repositories: repositories,
            goalIntelligenceService: runtime
        )
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Launch my business"),
            now: Self.fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)

        XCTAssertNotNil(detail.explainability)
        XCTAssertFalse(detail.strategicStatus.summary.isEmpty)
        XCTAssertNotNil(detail.nextMovement)
        XCTAssertFalse(detail.pathStages.isEmpty)
    }

    func testPreviewTrustHeavyScenarioKeepsTrustSecondAndMemoryAvailable() {
        let detail = Self.tryUnwrapScenario(PreviewGoalsScenarios.activeTarget.id)

        XCTAssertNotNil(detail.explainability)
        XCTAssertEqual(detail.strategicStatus.title, "Path is in motion")
        XCTAssertEqual(detail.nextMovement?.title, "Refresh release docs and trust copy")
        XCTAssertFalse(detail.recentMovement.items.isEmpty)
        XCTAssertFalse(detail.history.isEmpty)
    }
}

private extension GoalDetailStrategicPresentationTests {
    static var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    static func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    static func tryUnwrapScenario(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> GoalDetailPresentation {
        guard let detail = PreviewGoalsScenarios.detailScenarios[key] else {
            XCTFail("Missing preview scenario \(key)", file: file, line: line)
            return PreviewGoalsScenarios.detailScenarios.values.first!
        }
        return detail
    }
}
