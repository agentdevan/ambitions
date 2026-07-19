import XCTest
@testable import Ambitions

final class P1DTimeFoundationTests: XCTestCase {
    func testP1DTimeProjectsFixedPointsOpenWindowsAndScheduledLocalSteps() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let reloadedRepositories = makeRepositories(store: store)
        let lifecycle = SimpleStepLifecycleService(
            repositories: repositories,
            idProvider: { "p1d-simple" }
        )

        let created = try await lifecycle.createSimpleStep(
            title: "Mail the library card form",
            now: fixedNow
        )
        let windowStart = fixedNow.addingTimeInterval(2 * 60 * 60)
        let windowEnd = windowStart.addingTimeInterval(30 * 60)
        let placed = try await lifecycle.placeStepInTime(
            goalID: created.goalID,
            stepID: created.stepID,
            windowStart: windowStart,
            windowEnd: windowEnd,
            now: fixedNow.addingTimeInterval(60)
        )
        try await repositories.goals.saveGoals([
            makeFixedPointGoal(
                id: "p1d-fixed-school",
                title: "School conference",
                stepTitle: "Attend the school conference",
                dueAt: iso.string(from: fixedNow.addingTimeInterval(24 * 60 * 60))
            )
        ])

        let timeState = try await RepositoryBackedTimeService(repositories: reloadedRepositories)
            .loadTimeSurfaceState(now: fixedNow)
        let blocks = timeState.weekDays.flatMap(\.blocks)
        let fixedRow = try XCTUnwrap(timeState.lifeSuite.field.calendarRows.first { $0.kind == .fixedPoint })
        let openRow = try XCTUnwrap(timeState.lifeSuite.field.calendarRows.first { $0.kind == .openWindow })
        let placement = try XCTUnwrap(timeState.lifeSuite.field.placementCandidate)
        let events = try await reloadedRepositories.eventLedger.fetchRecent(limit: 20)

        XCTAssertEqual(placed.windowStart, iso.string(from: windowStart))
        XCTAssertEqual(placed.windowEnd, iso.string(from: windowEnd))
        XCTAssertEqual(placed.updatedStep.timing.windowStart, placed.windowStart)
        XCTAssertEqual(placed.updatedStep.timing.windowEnd, placed.windowEnd)
        XCTAssertTrue(blocks.contains { $0.title == "Mail the library card form" && $0.kind == .flexible && $0.timingLabel.contains("Scheduled") })
        XCTAssertTrue(blocks.contains { $0.title == "Attend the school conference" && $0.kind == .fixed })
        XCTAssertTrue(fixedRow.isOperational)
        XCTAssertTrue(fixedRow.accessibilitySummary.localizedCaseInsensitiveContains("fixed"))
        XCTAssertTrue(openRow.isOperational)
        XCTAssertTrue(openRow.accessibilitySummary.localizedCaseInsensitiveContains("open"))
        XCTAssertEqual(placement.stepID, created.stepID)
        XCTAssertEqual(placement.goalID, created.goalID)
        XCTAssertEqual(placement.title, "Mail the library card form")
        XCTAssertTrue(events.contains { $0.kind == .itemScheduled && $0.goalID == created.goalID && $0.source == .time && $0.localOnly })
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
    }

    func testP1DCaptureCreatedStepAppearsInTimeOnlyAfterLocalStepScheduling() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let reloadedRepositories = makeRepositories(store: store)
        let lifecycle = SimpleStepLifecycleService(
            repositories: repositories,
            idProvider: { "p1d-capture-step" }
        )
        let captureService = DefaultCaptureService(
            repository: repositories.captures,
            eventLedger: repositories.eventLedger,
            simpleStepLifecycleService: lifecycle,
            idProvider: { "capture-p1d-time" }
        )

        let capture = try await captureService.createCapture(
            CreateCaptureRequest(
                rawText: "Prepare the renewal form",
                sourceType: .shellComposer,
                kind: .oneTimeCommitment,
                route: .timeSeed
            ),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(capture.linkedGoalID)
        let persistedSteps = try await reloadedRepositories.goals.listSteps(goalID: goalID)
        let step = try XCTUnwrap(persistedSteps.first)
        let windowStart = fixedNow.addingTimeInterval(3 * 60 * 60)
        _ = try await lifecycle.placeStepInTime(
            goalID: goalID,
            stepID: step.id,
            windowStart: windowStart,
            windowEnd: windowStart.addingTimeInterval(30 * 60),
            now: fixedNow.addingTimeInterval(90)
        )

        let timeState = try await RepositoryBackedTimeService(repositories: reloadedRepositories)
            .loadTimeSurfaceState(now: fixedNow)
        let placement = try XCTUnwrap(timeState.lifeSuite.field.placementCandidate)
        let blocks = timeState.weekDays.flatMap(\.blocks)
        let persistedCapture = try await reloadedRepositories.captures.capture(id: capture.id)

        XCTAssertEqual(persistedCapture?.route, .timeSeed)
        XCTAssertEqual(persistedCapture?.linkedGoalID, goalID)
        XCTAssertEqual(step.title, "Prepare the renewal form")
        XCTAssertEqual(placement.stepID, step.id)
        XCTAssertEqual(placement.goalID, goalID)
        XCTAssertEqual(placement.title, "Prepare the renewal form")
        XCTAssertTrue(blocks.contains { $0.title == "Prepare the renewal form" && $0.timingLabel.contains("Scheduled") })
        XCTAssertFalse(timeState.lifeSuite.field.calendarRows.map(\.detail).joined(separator: " ").contains("capture.capture-p1d-time"))
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.syncBackendKind, .localOnly)
    }

    func testP1DRecurringStepScaffoldingDoesNotBreakTimeProjection() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let reloadedRepositories = makeRepositories(store: store)
        let lifecycle = SimpleStepLifecycleService(
            repositories: repositories,
            idProvider: { "p1d-recurring" }
        )

        let created = try await lifecycle.createRecurringStep(
            title: "Review tomorrow's commitments",
            repeatEveryDays: 2,
            now: fixedNow
        )
        let occurrences = try await lifecycle.scheduledOccurrences(
            goalID: created.goalID,
            stepID: created.stepID,
            from: fixedNow,
            limit: 2
        )
        let firstOccurrence = try XCTUnwrap(occurrences.first)
        _ = try await lifecycle.completeRecurringOccurrence(
            goalID: created.goalID,
            stepID: created.stepID,
            occurrenceID: firstOccurrence.id,
            now: fixedNow.addingTimeInterval(60 * 60)
        )

        let timeState = try await RepositoryBackedTimeService(repositories: reloadedRepositories)
            .loadTimeSurfaceState(now: fixedNow)
        let blocks = timeState.weekDays.flatMap(\.blocks)
        let reloadedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let reloadedStep = try XCTUnwrap(reloadedSteps.first)

        XCTAssertEqual(reloadedStep.state, .planned)
        XCTAssertTrue(reloadedStep.isRepeatable)
        XCTAssertEqual(reloadedStep.timing.repeatEveryDays, 2)
        XCTAssertTrue(blocks.contains { block in
            block.title == "Review tomorrow's commitments" &&
                (
                    block.timingLabel.contains("Every 2d") ||
                    block.timingLabel.contains("Scheduled") ||
                    block.timingLabel.contains("Flex")
                )
        })
        XCTAssertNotNil(timeState.lifeSuite.field.placementCandidate)
        XCTAssertFalse(timeState.lifeSuite.field.calendarRows.map(\.accessibilitySummary).joined(separator: " ").localizedCaseInsensitiveContains("overdue"))
    }

    func testP1DLowContextTimeAvoidsFakeCapacityAndPlacementClaims() async throws {
        let repositories = makeRepositories(store: try AmbitionsPersistenceStore(inMemory: true))

        let timeState = try await RepositoryBackedTimeService(repositories: repositories)
            .loadTimeSurfaceState(now: fixedNow)
        let openSegment = try XCTUnwrap(timeState.lifeSuite.field.segments.first { $0.kind == .openTime })
        let openRow = try XCTUnwrap(timeState.lifeSuite.field.calendarRows.first { $0.kind == .openWindow })
        let copy = [
            timeState.emptyTitle ?? "",
            timeState.emptyMessage ?? "",
            openSegment.valueLabel,
            openSegment.detail,
            openRow.value,
            openRow.detail,
            timeState.lifeSuite.field.reading(for: .week).capacityStatement,
            timeState.lifeSuite.field.placementUnavailableReason
        ].joined(separator: " ").lowercased()

        XCTAssertEqual(timeState.mode, .empty)
        XCTAssertEqual(openSegment.valueLabel, "Low context")
        XCTAssertEqual(openRow.value, "Low context")
        XCTAssertFalse(openRow.isOperational)
        XCTAssertNil(timeState.lifeSuite.field.placementCandidate)
        XCTAssertFalse(timeState.lifeSuite.field.canPlaceStep)
        XCTAssertFalse(copy.contains("optimized"))
        XCTAssertFalse(copy.contains("ai recommends"))
        XCTAssertFalse(copy.contains("overdue"))
        XCTAssertFalse(copy.contains("score"))
        XCTAssertFalse(copy.contains("7 open days"))
        XCTAssertTrue(copy.contains("local schedule context"))
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
    }

    func testP1E1PersistedScheduledStepSurvivesRepositoryAndTimeServiceReload() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let firstRepositories = makeRepositories(store: store)
        let lifecycle = SimpleStepLifecycleService(
            repositories: firstRepositories,
            idProvider: { "p1e1-persisted-step" }
        )

        let created = try await lifecycle.createSimpleStep(
            title: "Mail the library card form",
            summary: "Persisted local Step scheduled before Time reload.",
            now: fixedNow
        )
        let windowStart = fixedNow.addingTimeInterval(90 * 60)
        _ = try await lifecycle.placeStepInTime(
            goalID: created.goalID,
            stepID: created.stepID,
            windowStart: windowStart,
            windowEnd: windowStart.addingTimeInterval(30 * 60),
            now: fixedNow.addingTimeInterval(30)
        )
        try await firstRepositories.goals.saveGoals([
            makeFixedPointGoal(
                id: "p1e1-fixed-school",
                title: "School conference",
                stepTitle: "Attend the school conference",
                dueAt: iso.string(from: fixedNow.addingTimeInterval(24 * 60 * 60))
            )
        ])

        let reloadedRepositories = makeRepositories(store: store)
        let reloadedTimeService = RepositoryBackedTimeService(repositories: reloadedRepositories)
        let timeState = try await reloadedTimeService.loadTimeSurfaceState(now: fixedNow)
        let fixedRow = try XCTUnwrap(timeState.lifeSuite.field.calendarRows.first { $0.kind == .fixedPoint })
        let openRow = try XCTUnwrap(timeState.lifeSuite.field.calendarRows.first { $0.kind == .openWindow })
        let scheduledRow = try XCTUnwrap(timeState.lifeSuite.field.calendarRows.first { $0.kind == .scheduledStep })
        let scheduledCopy = [
            scheduledRow.title,
            scheduledRow.value,
            scheduledRow.detail,
            scheduledRow.accessibilitySummary
        ].joined(separator: " ")
        let persistedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let events = try await reloadedRepositories.eventLedger.fetchRecent(limit: 20)

        XCTAssertTrue(persistedSteps.contains { $0.id == created.stepID && $0.timing.windowStart != nil && $0.timing.windowEnd != nil })
        XCTAssertTrue(fixedRow.isOperational)
        XCTAssertTrue(fixedRow.accessibilitySummary.localizedCaseInsensitiveContains("fixed"))
        XCTAssertTrue(openRow.accessibilitySummary.localizedCaseInsensitiveContains("open"))
        XCTAssertTrue(scheduledRow.isOperational)
        XCTAssertTrue(scheduledCopy.localizedCaseInsensitiveContains("Scheduled"), scheduledCopy)
        XCTAssertTrue(scheduledCopy.localizedCaseInsensitiveContains("Mail the library card form"), scheduledCopy)
        XCTAssertFalse(scheduledCopy.localizedCaseInsensitiveContains("capture."))
        XCTAssertTrue(events.contains { $0.kind == .itemScheduled && $0.goalID == created.goalID && $0.localOnly })
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.syncBackendKind, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)

        let emptyReloadedTimeState = try await RepositoryBackedTimeService(
            repositories: makeRepositories(store: try AmbitionsPersistenceStore(inMemory: true))
        )
        .loadTimeSurfaceState(now: fixedNow)
        let lowContextOpenRow = try XCTUnwrap(emptyReloadedTimeState.lifeSuite.field.calendarRows.first { $0.kind == .openWindow })
        let lowContextScheduledRow = try XCTUnwrap(emptyReloadedTimeState.lifeSuite.field.calendarRows.first { $0.kind == .scheduledStep })
        let lowContextCopy = [
            lowContextOpenRow.value,
            lowContextOpenRow.detail,
            lowContextScheduledRow.value,
            lowContextScheduledRow.detail,
            emptyReloadedTimeState.lifeSuite.field.placementUnavailableReason
        ].joined(separator: " ").lowercased()

        XCTAssertEqual(lowContextOpenRow.value, "Low context")
        XCTAssertFalse(lowContextOpenRow.isOperational)
        XCTAssertFalse(lowContextScheduledRow.isOperational)
        XCTAssertFalse(lowContextCopy.contains("7 open days"))
        XCTAssertFalse(lowContextCopy.contains("optimized"))
        XCTAssertFalse(lowContextCopy.contains("ai recommends"))
        XCTAssertNil(emptyReloadedTimeState.lifeSuite.field.placementCandidate)
    }
}

private extension P1DTimeFoundationTests {
    var fixedNow: Date {
        ISO8601DateFormatter().date(from: GoalEngineFixtures.fixedNow) ?? Date(timeIntervalSince1970: 1_712_692_800)
    }

    var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: SwiftDataEventLedgerRepository(store: store),
            commandExecutionRecords: SwiftDataAmbitionsCommandExecutionRecordRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeFixedPointGoal(
        id: String,
        title: String,
        stepTitle: String,
        dueAt: String
    ) -> Goal {
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let step = Step(
            id: "step-\(id)",
            sectionID: "section-\(id)",
            title: stepTitle,
            summary: "A fixed local point Time must keep distinct from open room.",
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: false,
            successSignals: ["Fixed point represented locally"],
            actionability: StepActionability(
                action: stepTitle,
                completionDefinition: "The fixed point happened or was reviewed.",
                evidenceOfCompletion: ["Local receipt"],
                fallbackMicroStep: "Confirm the fixed point still belongs on Time.",
                contextRequirements: ["fixed point"]
            )
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: GoalEngineFixtures.fixedNow,
            summary: "Fixed point foundation proof.",
            strategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            sections: [
                PlanSection(
                    id: "section-\(id)",
                    goalID: id,
                    title: "Fixed point",
                    summary: nil,
                    kind: .activeSteps,
                    orderIndex: 0,
                    steps: [step]
                )
            ],
            assumptions: [],
            lint: PlanLintResult(
                goalID: id,
                planVersion: goalEnginePlanVersion,
                isValid: true,
                issueCount: 0,
                issues: []
            )
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            state: .active,
            title: title,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: ["fixed-point"],
            timing: timing,
            planningStrategy: plan.strategy,
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: 1,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: plan
        )
    }
}
