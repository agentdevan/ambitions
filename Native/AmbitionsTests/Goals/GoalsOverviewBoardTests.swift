import XCTest
@testable import Ambitions

final class GoalsOverviewAtlasTests: XCTestCase {
    func testOverviewUsesRecoverPrimaryActionWhenAtRiskAtlasItemExists() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let liveGoal = makeGoal(
            id: "goal-live-direction",
            title: "Ship the native create goal flow",
            dueInDays: 18
        )
        let blocked = makeClarificationDraft(
            id: "draft-clarify-start",
            title: "I don't know where to start",
            resultKind: .blocked
        )

        try await repositories.goals.saveGoals([liveGoal])
        try await repositories.drafts.saveDrafts([blocked])
        try await savePriorityOrder([liveGoal.id, blocked.id], repositories: repositories)

        let overview = try await service.loadOverview()

        XCTAssertEqual(overview.heroPrimaryAction.kind, .recoverGoal)
        XCTAssertEqual(overview.heroPrimaryAction.target, GoalRouteTarget(draftID: blocked.id))
        XCTAssertTrue(overview.bands.contains(where: { $0.kind == .activeDirection && $0.cards.isEmpty == false }))
        XCTAssertTrue(
            overview.bands
                .first(where: { $0.kind == .pressure })?
                .cards
                .contains(where: { $0.target == GoalRouteTarget(draftID: blocked.id) && $0.posture == .atRisk }) == true
        )
    }

    func testOverviewGroupsCrowdedAndStalledGoalsUsingExistingSignals() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let active = makeGoal(
            id: "goal-live-proposal",
            title: "Submit my conference talk proposal",
            dueInDays: 12
        )
        let stalled = makeGoal(
            id: "goal-stalled-learning",
            title: "Learn how to mix vocals",
            dueInDays: 45
        )
        let crowded = makeGoal(
            id: "goal-crowded-certification",
            title: "Finish my certification",
            dueInDays: 12
        )

        try await repositories.goals.saveGoals([active, stalled, crowded])
        try await savePriorityOrder([active.id, stalled.id, crowded.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let atlasCards = overview.bands.flatMap(\.cards)

        XCTAssertTrue(atlasCards.contains(where: { $0.posture == .stalled }))
        XCTAssertTrue(atlasCards.contains(where: { $0.target == GoalRouteTarget(goalID: crowded.id, draftID: nil) && $0.posture == .crowded }))
        XCTAssertEqual(
            overview.bands.first(where: { $0.kind == .pressure })?.cards.first(where: { $0.target == GoalRouteTarget(goalID: crowded.id, draftID: nil) })?.posture,
            .crowded
        )
    }

    func testOverviewBuildsHorizonLadderFallbackFromPlanSectionsWhenPathGraphIsThin() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goal = makeGoal(
            id: "goal-horizon-ladder",
            title: "Ship the native create goal flow",
            dueInDays: 20
        )

        try await repositories.goals.saveGoals([goal])
        try await savePriorityOrder([goal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let rung = try XCTUnwrap(overview.horizonLadder.rungs.first)

        XCTAssertFalse(rung.summary.isEmpty)
        XCTAssertFalse(rung.highlight.isEmpty)
        XCTAssertFalse(rung.milestoneLabel.isEmpty)
        XCTAssertTrue(rung.milestoneLabel.contains("steps") || rung.milestoneLabel.contains("milestones"))
    }

    func testOverviewProjectsPortfolioWeatherProofAndNextVisibleStep() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let protectedGoal = makeGoal(
            id: "goal-protected-proof",
            title: "Ship the Goals portfolio",
            dueInDays: 10
        )
        let waitingGoal = makeGoal(
            id: "goal-waiting-readiness",
            title: "Submit the application packet",
            dueInDays: 24,
            lifeDomain: .career,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                stages: [
                    LifePathStage(
                        id: "stage-readiness-gap",
                        title: "Readiness",
                        summary: "The path needs one answer before it is ready.",
                        orderIndex: 0,
                        readinessSignals: [
                            LifePathSignal(id: "signal-readiness-gap", title: "Requirements still need clarifying", kind: .readiness, isGap: true)
                        ]
                    )
                ],
                milestones: [
                    LifeGraphMilestone(
                        id: "milestone-readiness",
                        title: "Readiness checkpoint",
                        summary: "Move only after the gap closes.",
                        stageID: "stage-readiness-gap"
                    )
                ]
            )
        )
        let blockedDraft = makeClarificationDraft(
            id: "draft-blocked-portfolio",
            title: "Plan the blocked move",
            resultKind: .blocked
        )

        try await repositories.goals.saveGoals([protectedGoal, waitingGoal])
        try await repositories.drafts.saveDrafts([blockedDraft])
        try await repositories.evidence.saveEvidence([
            evidence(goalID: protectedGoal.id, stepID: "step-\(protectedGoal.id)", note: "Drafted portfolio proof")
        ])
        try await savePriorityOrder([protectedGoal.id, waitingGoal.id, blockedDraft.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let cards = overview.bands.flatMap(\.cards) + overview.lowerPriority.cards
        let protectedCard = try XCTUnwrap(cards.first(where: { $0.target == GoalRouteTarget(goalID: protectedGoal.id, draftID: nil) }))
        let waitingCard = try XCTUnwrap(cards.first(where: { $0.target == GoalRouteTarget(goalID: waitingGoal.id, draftID: nil) }))
        let blockedCard = try XCTUnwrap(cards.first(where: { $0.target == GoalRouteTarget(draftID: blockedDraft.id) }))

        XCTAssertEqual(protectedCard.lifecycleState, .protected)
        XCTAssertEqual(protectedCard.weather, .protected)
        XCTAssertEqual(protectedCard.proofSummary.count, 1)
        XCTAssertEqual(protectedCard.proofSummary.latestTitle, "Drafted portfolio proof")
        XCTAssertTrue(protectedCard.nextVisibleStep.isAvailable)
        XCTAssertEqual(protectedCard.momentumIntegrity.title, "Kept in view")
        XCTAssertEqual(protectedCard.priorityLabel, "Protected direction")

        XCTAssertEqual(waitingCard.lifecycleState, .waiting)
        XCTAssertEqual(waitingCard.weather, .stormy)
        XCTAssertTrue(waitingCard.pressureSummary.localizedCaseInsensitiveContains("waiting on a readiness answer"))
        XCTAssertTrue(waitingCard.weatherSummary.localizedCaseInsensitiveContains("waiting on a readiness answer"))

        XCTAssertEqual(blockedCard.lifecycleState, .blocked)
        XCTAssertEqual(blockedCard.weather, .stormy)
        XCTAssertEqual(blockedCard.proofSummary.title, "No proof yet")
        XCTAssertTrue(overview.stateChips.contains(where: { $0.lifecycleState == .blocked && $0.count == 1 }))
        XCTAssertEqual(overview.lifecycleRail.first(where: { $0.id == "active" })?.count, 3)
    }

    func testOverviewKeepsCompletedAndCancelledArchiveStatesDistinct() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let completed = makeGoal(
            id: "goal-completed-portfolio",
            title: "Finish launch checklist",
            dueInDays: -1,
            state: .completed
        )
        let cancelled = makeGoal(
            id: "goal-cancelled-portfolio",
            title: "Retire stale experiment",
            dueInDays: -1,
            state: .archived
        )

        try await repositories.goals.saveGoals([completed, cancelled])
        try await savePriorityOrder([completed.id, cancelled.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let archiveCards = overview.lowerPriority.cards

        XCTAssertTrue(archiveCards.contains(where: { $0.target.goalID == completed.id && $0.lifecycleState == .completed }))
        XCTAssertTrue(archiveCards.contains(where: { $0.target.goalID == cancelled.id && $0.lifecycleState == .cancelledDropped }))
        XCTAssertTrue(overview.archiveSummary.chips.contains(where: { $0.lifecycleState == .completed && $0.count == 1 }))
        XCTAssertTrue(overview.archiveSummary.chips.contains(where: { $0.lifecycleState == .cancelledDropped && $0.count == 1 }))
        XCTAssertTrue(overview.archiveSummary.learningLines.contains(where: { $0.contains("completed") }))
        XCTAssertTrue(overview.archiveSummary.learningLines.contains(where: { $0.contains("closed without being treated as failure") }))
    }

    func testOverviewKeepsEmptyCopyReadableWhenNoGoalsExist() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let overview = try await service.loadOverview()

        XCTAssertEqual(overview.emptyTitle, "No goals yet")
        XCTAssertTrue(overview.emptyMessage.localizedCaseInsensitiveContains("explain the path"))
        XCTAssertTrue(overview.bands.allSatisfy(\.cards.isEmpty))
        XCTAssertFalse(overview.hero.dominantTruth.localizedCaseInsensitiveContains("score"))
    }

    func testOverviewUsesManualFallbackLanguageWhenGoalHasNoPlan() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goal = makeGoal(
            id: "goal-manual-fallback",
            title: "Shape the next direction",
            dueInDays: 21,
            includePlan: false
        )

        try await repositories.goals.saveGoals([goal])
        try await savePriorityOrder([goal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let card = try XCTUnwrap(overview.bands.flatMap(\.cards).first(where: { $0.target.goalID == goal.id }))

        XCTAssertEqual(card.nextVisibleStep.title, "Needs a next step")
        XCTAssertFalse(card.nextVisibleStep.isAvailable)
        XCTAssertEqual(card.phaseSummary, "Plan forming")
        XCTAssertEqual(card.priorityLabel, "Protected direction")
        XCTAssertFalse(card.priorityLabel.localizedCaseInsensitiveContains("rank"))
        XCTAssertFalse(card.priorityLabel.localizedCaseInsensitiveContains("priority position"))
    }

    func testM10PortfolioMaturitySummarizesScopeStuckWorkProofAndArchiveLearning() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goals = [
            makeGoal(id: "goal-m10-primary", title: "Ship the portfolio maturity pass", dueInDays: 7),
            makeGoal(id: "goal-m10-second", title: "Prepare the launch story", dueInDays: 10),
            makeGoal(id: "goal-m10-third", title: "Tighten investor demo", dueInDays: 12),
            makeGoal(id: "goal-m10-fourth", title: "Clean up support docs", dueInDays: 14),
            makeGoal(id: "goal-m10-closed", title: "Retire stale portfolio idea", dueInDays: -2, state: .archived),
        ]
        let blocked = makeClarificationDraft(
            id: "draft-m10-blocked",
            title: "Figure out the blocked portfolio move",
            resultKind: .blocked
        )
        let captures = (0..<4).map { index in
            makeOneStepCapture(
                id: "capture-m10-task-\(index)",
                title: "Handle loose standalone task \(index + 1)",
                status: .actionable,
                deadlineText: "Today",
                deadlineKind: .hard
            )
        }

        try await repositories.goals.saveGoals(goals)
        try await repositories.drafts.saveDrafts([blocked])
        try await repositories.captures.saveCaptures(captures)
        try await repositories.evidence.saveEvidence([
            evidence(goalID: "goal-m10-primary", stepID: "step-goal-m10-primary", note: "Direction maturity proof")
        ])
        try await savePriorityOrder(goals.map(\.id) + [blocked.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let maturity = overview.maturitySummary

        XCTAssertEqual(maturity.title, "Direction maturity")
        XCTAssertEqual(maturity.scopeSignal.title, "Scope needs review")
        XCTAssertEqual(maturity.stuckWorkSignal.title, "Stuck work is visible")
        XCTAssertTrue(maturity.stuckWorkSignal.detail.contains("waiting or blocked"))
        XCTAssertTrue(maturity.stuckWorkSignal.detail.contains("open One-Step Goals"))
        XCTAssertEqual(maturity.proofSignal.title, "Proof is thin")
        XCTAssertEqual(maturity.nextStepSignal.title, "Some next steps need shape")
        XCTAssertTrue(maturity.archiveLearning.contains(where: { $0.contains("closed without being treated as failure") }))
        XCTAssertFalse(maturity.accessibilityValue.localizedCaseInsensitiveContains("score"))
    }

    func testGoalAtlasPreviewConsumesLifeAreasProjectionWithoutRedesigningSurface() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let moneyGoal = makeGoal(
            id: "goal-money-area",
            title: "Build an emergency fund",
            dueInDays: 30,
            lifeDomain: .finance
        )
        let careerGoal = makeGoal(
            id: "goal-career-area",
            title: "Prepare portfolio review",
            dueInDays: 14,
            lifeDomain: .career
        )

        try await repositories.goals.saveGoals([moneyGoal, careerGoal])
        try await savePriorityOrder([moneyGoal.id, careerGoal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let atlasPreview = try XCTUnwrap(overview.atlasPreview)

        XCTAssertEqual(atlasPreview.title, "Constellation Atlas")
        XCTAssertEqual(atlasPreview.groups.map(\.title), ["Career", "Money"])
        XCTAssertTrue(atlasPreview.groups.contains(where: { $0.id == "finance" && $0.items.map(\.id) == [moneyGoal.id] }))
        XCTAssertEqual(overview.lifeAreas.title, "Constellation Atlas")
        XCTAssertEqual(overview.lifeAreas.items.map(\.title), ["Career", "Money"])
        XCTAssertTrue(overview.lifeAreas.supportsListFallback)
        XCTAssertEqual(overview.lifeAreas.availableZoomModes, [.map, .list])
        XCTAssertLessThanOrEqual(overview.lifeAreas.items.count, overview.lifeAreas.maxVisibleAreas)
    }

    func testGoalsLifeAreasSurfaceGoalThreadProofAndReceiptAlignedSummaries() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goal = makeGoal(
            id: "goal-thread-overview",
            title: "Ship the thread overview",
            dueInDays: 18,
            lifeDomain: .career,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                stages: [
                    LifePathStage(
                        id: "stage-discovery",
                        title: "Discovery",
                        summary: "Keep the path believable.",
                        orderIndex: 0,
                        readinessSignals: [
                            LifePathSignal(id: "signal-start", title: "Start here", kind: .readiness)
                        ]
                    )
                ],
                milestones: [
                    LifeGraphMilestone(
                        id: "milestone-start",
                        title: "Small first proof",
                        summary: "Record the first visible proof.",
                        stageID: "stage-discovery"
                    )
                ]
            )
        )

        try await repositories.goals.saveGoals([goal])
        try await repositories.evidence.saveEvidence([
            evidence(goalID: goal.id, stepID: "step-\(goal.id)", note: "First proof note")
        ])
        try await savePriorityOrder([goal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let careerArea = try XCTUnwrap(overview.lifeAreas.items.first { $0.id == "career" })

        XCTAssertEqual(careerArea.goalThreadCount, 1)
        XCTAssertEqual(careerArea.goalThreadSummary, "Discovery")
        XCTAssertEqual(careerArea.proofCount, 1)
        XCTAssertEqual(careerArea.receiptCount, 0)
        XCTAssertTrue(careerArea.goalReferences.contains(where: { $0.id == goal.id }))
    }

    func testAFI07GoalsConstellationAtlasKeepsThreadsConnectedToTodayWithoutTopLevelMissionControl() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let musicGoal = makeGoal(
            id: "goal-afi07-music",
            title: "Open Music",
            dueInDays: 14,
            lifeDomain: .creativity
        )
        let healthGoal = makeGoal(
            id: "goal-afi07-health",
            title: "Protect morning strength",
            dueInDays: 21,
            lifeDomain: .health
        )

        try await repositories.goals.saveGoals([musicGoal, healthGoal])
        try await savePriorityOrder([musicGoal.id, healthGoal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let atlasPreview = try XCTUnwrap(overview.atlasPreview)
        let orbitalLens = GoalLifePathState(overview: overview)
        let snapshot = overview.screenContractSnapshot()
        let firstScreenCopy = (snapshot.firstScreenContent + snapshot.copySamples).joined(separator: " ")

        XCTAssertEqual(overview.hero.eyebrow, "Your Direction")
        XCTAssertEqual(overview.hero.title, "Your Direction")
        XCTAssertEqual(overview.lifeAreas.title, "Constellation Atlas")
        XCTAssertEqual(atlasPreview.title, "Constellation Atlas")
        XCTAssertEqual(orbitalLens.accessibilityLabel, "Goals Orbital Lens")
        XCTAssertTrue(orbitalLens.accessibilityHint.contains("feed Today"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("Constellation Atlas"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("Orbital Lens"))
        XCTAssertEqual(snapshot.topLevelTabTitles, ["Today", "Goals", "Capture", "Time", "You"])

        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("Mission Control"))
        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("KPI"))
        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("rank"))
        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("Priority position"))
        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("astrology"))
        XCTAssertFalse(firstScreenCopy.localizedCaseInsensitiveContains("habit ring"))
        XCTAssertTrue(overview.bands.flatMap(\.cards).allSatisfy { $0.priorityLabel.localizedCaseInsensitiveContains("priority position") == false })
    }

    func testAFRI024GoalsConstellationAtlasExposesInspectableLocalSourceReceiptAndReplayBasis() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goal = makeGoal(
            id: "goal-afri024-atlas",
            title: "Prepare the launch narrative",
            dueInDays: 16,
            lifeDomain: .career,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                stages: [
                    LifePathStage(
                        id: "stage-launch-story",
                        title: "Launch story",
                        summary: "Keep proof and path visible.",
                        orderIndex: 0,
                        readinessSignals: [
                            LifePathSignal(id: "signal-current-step", title: "Draft outline", kind: .readiness)
                        ]
                    )
                ],
                milestones: [
                    LifeGraphMilestone(
                        id: "milestone-outline",
                        title: "Outline approved",
                        summary: "Narrative path is inspectable.",
                        stageID: "stage-launch-story"
                    )
                ]
            )
        )

        try await repositories.goals.saveGoals([goal])
        try await repositories.evidence.saveEvidence([
            evidence(goalID: goal.id, stepID: "step-\(goal.id)", note: "Reviewed launch proof")
        ])
        try await savePriorityOrder([goal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let summary = overview.constellationAtlasInspectionSummary
        let accessibilityValue = overview.constellationAtlasAccessibilityValue
        let primaryCard = try XCTUnwrap(overview.bands.flatMap(\.cards).first { $0.target.goalID == goal.id })

        XCTAssertTrue(summary.contains("SourceRecord:"))
        XCTAssertTrue(summary.contains("Receipt:"))
        XCTAssertTrue(summary.contains("ReplayTrace:"))
        XCTAssertTrue(summary.contains("You / What Ambitions knows:"))
        XCTAssertTrue(summary.contains("local Goals, drafts, evidence, and capture records"))
        XCTAssertTrue(summary.contains("closure receipts"))
        XCTAssertTrue(summary.contains("Active direction"))
        XCTAssertTrue(summary.contains("Orbital Lens keeps one thread connected to Today"))
        XCTAssertTrue(accessibilityValue.contains("Constellation Atlas"))
        XCTAssertEqual(
            overview.constellationAtlasCompactInspectionSummary,
            "Local source, proof receipts, and replay trace stay inspectable through You."
        )
        XCTAssertEqual(primaryCard.milestoneSummary, "0/1 milestones visible")
        XCTAssertEqual(primaryCard.proofSummary.latestTitle, "Reviewed launch proof")
        XCTAssertTrue(primaryCard.nextVisibleStep.isAvailable)
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("streak"))
    }

    func testD13GoalsProjectionSurfacesNorthStarsAndOneStepFoundationsWithoutNewTabs() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let careerGoal = makeGoal(
            id: "goal-career-d13",
            title: "Prepare portfolio review",
            dueInDays: 14,
            lifeDomain: .career
        )
        let taskCapture = makeOneStepCapture(
            id: "capture-one-step-d13",
            title: "Book dentist",
            status: .actionable,
            deadlineText: "Today",
            deadlineKind: .hard
        )

        try await repositories.goals.saveGoals([careerGoal])
        try await repositories.captures.saveCaptures([taskCapture])
        try await savePriorityOrder([careerGoal.id], repositories: repositories)

        let overview = try await service.loadOverview()

        XCTAssertEqual(overview.northStars.title, "North Stars")
        XCTAssertEqual(overview.northStars.emptyTitle, "No North Stars here yet")
        XCTAssertEqual(overview.northStars.totalCount, 0)

        XCTAssertEqual(overview.oneStepGoals.title, "One-Step Goals")
        XCTAssertEqual(overview.oneStepGoals.openCount, 1)
        let item = try XCTUnwrap(overview.oneStepGoals.items.first)
        XCTAssertEqual(item.id, "capture.\(taskCapture.id)")
        XCTAssertEqual(item.title, "Book dentist")
        XCTAssertEqual(item.statusLabel, "Today")
        XCTAssertEqual(item.timingLabel, "Today")
        XCTAssertTrue(item.canPromoteToGoal)
        XCTAssertTrue(item.accessibilityHint.contains("Standalone task"))

        XCTAssertEqual(ScreenContractValidator.canonicalTopLevelTabs, ["Today", "Goals", "Capture", "Time", "You"])
    }

    func testD13GoalsScreenContractSnapshotSatisfiesImplementationGate() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goal = makeGoal(
            id: "goal-contract-d13",
            title: "Ship the Goals Life Areas transformation",
            dueInDays: 18,
            lifeDomain: .career
        )
        try await repositories.goals.saveGoals([goal])
        try await savePriorityOrder([goal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let contract = ScreenContractRegistry.contract(for: .goals)
        let issues = ScreenContractValidator.validate(
            snapshot: overview.screenContractSnapshot(),
            against: contract
        )

        XCTAssertTrue(issues.isEmpty, issues.map(\.message).joined(separator: "\n"))
    }

    func testSI06LifePathStateUsesProofRiskNextAndPrivateFallbacks() {
        let state = GoalLifePathState(overview: PreviewGoalsScenarios.overview)

        XCTAssertEqual(state.badge, "Route attention")
        XCTAssertTrue(state.nodes.contains(where: { $0.kind == .start }))
        XCTAssertTrue(state.nodes.contains(where: { $0.kind == .current }))
        XCTAssertTrue(state.nodes.contains(where: { $0.kind == .proof }))
        XCTAssertTrue(state.nodes.contains(where: { $0.kind == .risk }))
        XCTAssertTrue(state.nodes.contains(where: { $0.kind == .next }))
        XCTAssertTrue(state.nodes.allSatisfy { $0.nonColorMeaning.isEmpty == false })
        XCTAssertFalse(state.alternateRoutes.isEmpty)
        XCTAssertFalse(state.accessibilityValue.localizedCaseInsensitiveContains("score"))

        let privateState = GoalLifePathState(overview: PreviewGoalsScenarios.overview, privacySensitive: true)
        XCTAssertEqual(privateState.title, "Private ambition path")
        XCTAssertTrue(privateState.nodes.contains(where: { $0.detail.localizedCaseInsensitiveContains("hidden") }))
        XCTAssertTrue(privateState.accessibilityHint.localizedCaseInsensitiveContains("private"))
    }
}

private extension GoalsOverviewAtlasTests {
    var now: Date {
        Date()
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func savePriorityOrder(_ ids: [String], repositories: AppRepositories) async throws {
        var state = try await repositories.appState.loadState()
        state.goalPriorityOrder = ids
        try await repositories.appState.saveState(state)
    }

    func makeGoal(
        id: String,
        title: String,
        dueInDays: Int,
        state: GoalLifecycleState = .active,
        includePlan: Bool = true,
        lifeDomain: LifeDomainKey? = nil,
        lifeGraph: LifeGraphContext? = nil
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: isoDate(daysFromNow: dueInDays),
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 3,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: nil,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let step = Step(
            id: "step-\(id)",
            sectionID: "section-\(id)",
            title: "Do the next visible step",
            summary: nil,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(
                action: "Do it",
                completionDefinition: "Done",
                evidenceOfCompletion: ["Done"],
                fallbackMicroStep: "Start",
                contextRequirements: []
            )
        )
        let plan = includePlan ? GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: isoDate(daysFromNow: -1),
            summary: nil,
            strategy: strategy,
            sections: [
                PlanSection(
                    id: "section-\(id)",
                    goalID: id,
                    title: "Active",
                    summary: nil,
                    kind: .activeSteps,
                    orderIndex: 0,
                    steps: [step]
                )
            ],
            assumptions: [],
            lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        ) : nil

        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: isoDate(daysFromNow: -2),
            updatedAt: isoDate(daysFromNow: -1),
            state: state,
            title: title,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: lifeGraph ?? lifeDomain.map { LifeGraphContext(domains: [LifeDomainAssignment(domain: $0)]) }
        )
    }

    func evidence(goalID: String, stepID: String, note: String) -> ProgressEvidence {
        ProgressEvidence(
            id: "evidence-\(goalID)",
            goalID: goalID,
            stepID: stepID,
            evidenceKind: .stepCompleted,
            source: .manual,
            capturedAt: isoDate(daysFromNow: 0),
            progressDelta: nil,
            confidenceDelta: nil,
            minutesInvested: nil,
            note: note
        )
    }

    func makeClarificationDraft(
        id: String,
        title: String,
        resultKind: GoalOrchestrationResultKind = .clarificationRequired
    ) -> PersistedGoalDraft {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let draft = GoalDraft(
            schemaVersion: goalEngineSchemaVersion,
            source: .manual,
            title: title,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
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
                strategyKind: .adaptive,
                allowParallelSteps: true,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
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
            )
        )

        return PersistedGoalDraft(
            id: id,
            createdAt: isoDate(daysFromNow: -1),
            updatedAt: isoDate(daysFromNow: -1),
            draft: draft,
            classification: nil,
            clarification: nil,
            stagedPlan: nil,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: nil,
            latestResultKind: resultKind
        )
    }

    func makeOneStepCapture(
        id: String,
        title: String,
        status: CaptureStatus,
        deadlineText: String?,
        deadlineKind: CaptureDeadlineKind
    ) -> Capture {
        Capture(
            id: id,
            createdAt: isoDate(daysFromNow: -1),
            updatedAt: isoDate(daysFromNow: 0),
            rawText: title,
            sourceType: .todayQuickCapture,
            status: status,
            linkedGoalID: nil,
            triage: CaptureTriageMetadata(destination: .timeSeed, hint: "Saved as Task · Today"),
            revisitAfter: nil,
            kind: .deadlineTask,
            route: .timeSeed,
            triageStatus: .routed,
            commitmentKind: .oneTime,
            deadlineText: deadlineText,
            deadlineKind: deadlineKind,
            contextLensHint: nil,
            priorityHints: CapturePriorityHints(deadline: .high),
            goalRelationship: nil,
            deliverableHint: nil,
            scopeItemHint: nil,
            waitingMetadata: nil,
            assumptionSummary: "Saved as a standalone Task because no existing local destination was reliable enough."
        )
    }

    func isoDate(daysFromNow: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysFromNow, to: now) ?? now
        return ISO8601DateFormatter().string(from: date)
    }
}
