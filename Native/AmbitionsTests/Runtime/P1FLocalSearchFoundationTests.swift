import XCTest
@testable import Ambitions

final class P1FLocalSearchFoundationTests: XCTestCase {
    func testP1FLocalSearchFindsFoundationObjectsWithoutAccountOrNetwork() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let captureService = DefaultCaptureService(
            repository: repositories.captures,
            eventLedger: repositories.eventLedger,
            simpleStepLifecycleService: SimpleStepLifecycleService(
                repositories: repositories,
                idProvider: { "p1f-capture-step" }
            ),
            idProvider: { "capture-p1f-local-search" }
        )

        let capture = try await captureService.createCapture(
            CreateCaptureRequest(
                rawText: "File the passport renewal form",
                sourceType: .shellComposer,
                kind: .oneTimeCommitment,
                route: .timeSeed
            ),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(capture.linkedGoalID)
        let steps = try await repositories.goals.listSteps(goalID: goalID)
        let step = try XCTUnwrap(steps.first)

        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "proof-p1f-passport",
                goalID: goalID,
                stepID: step.id,
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: iso.string(from: fixedNow.addingTimeInterval(60)),
                progressDelta: 0.2,
                confidenceDelta: nil,
                minutesInvested: 10,
                note: "Proof for the passport renewal search path."
            )
        ])
        try await repositories.feedback.saveEvents([
            .delayed(
                base: GoalFeedbackEventBase(
                    id: "feedback-p1f-passport",
                    stepID: step.id,
                    occurredAt: iso.string(from: fixedNow.addingTimeInterval(120)),
                    note: "Move it after checking the mailbox."
                ),
                timingAdjustment: .laterToday,
                date: nil
            )
        ], goalID: goalID)

        let reloadedRepositories = makeRepositories(store: store)
        let search = DefaultMemoryLensService(repositories: reloadedRepositories)

        let stepResults = await search.search(query: "passport renewal", seedIntent: .memoryLens, origin: .today)
        let captureResults = await search.search(query: "File the passport renewal form", seedIntent: .memoryLens, origin: .today)
        let proofResults = await search.search(query: "passport renewal search path", seedIntent: .memoryLens, origin: .you)
        let recentChangeResults = await search.search(query: "checking the mailbox", seedIntent: .memoryLens, origin: .today)
        let timeResults = await search.search(query: "Open Time", seedIntent: .openWeek, origin: .time)
        let settingResults = await search.search(query: "Privacy", seedIntent: .memoryLens, origin: .you)

        XCTAssertTrue(stepResults.contains {
            $0.kind == .step &&
                $0.title == "File the passport renewal form" &&
                $0.destination == .goal(goalID) &&
                $0.actionTitle == "Open step" &&
                $0.userFacingContext.localizedCaseInsensitiveContains("Planned")
        })
        XCTAssertTrue(captureResults.contains {
            ($0.kind == .capture || $0.kind == .thought) &&
                $0.title == "File the passport renewal form"
        })
        XCTAssertTrue(proofResults.contains {
            $0.kind == .proof &&
                $0.destination == .goal(goalID) &&
                $0.inspectActionTitle == "Inspect"
        })
        XCTAssertTrue(recentChangeResults.contains {
            $0.kind == .recentChange &&
                $0.facet == .whatChanged &&
                $0.destination == .goal(goalID)
        })
        XCTAssertTrue(timeResults.contains {
            $0.kind == .timeWindow &&
                $0.destination == .tab(.time) &&
                $0.actionTitle == "Open Time"
        })
        XCTAssertTrue(settingResults.contains {
            $0.kind == .setting &&
                $0.destination == .youRoute(.privacy)
        })
        XCTAssertTrue(
            [stepResults, captureResults, proofResults, recentChangeResults, timeResults, settingResults]
                .flatMap { $0 }
                .allSatisfy { $0.trustedSearchHandoff(source: .shellUtility).isTrusted }
        )
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.syncBackendKind, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
    }

    func testP1FYouEverythingSearchKeepsLifeContextAsLocalPlaceholderOnly() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        try await repositories.lifeContext?.saveBundles([makeLifeContextBundle()])

        let dashboard = try await RepositoryBackedYouService(repositories: makeRepositories(store: store))
            .loadYouDashboard()
        let search = dashboard.everythingSearch
        let lifeContextResults = search.items.filter { $0.kind == .lifeContext }

        XCTAssertTrue(search.footer.contains("No external service"))
        XCTAssertTrue(search.filters.contains { $0.title == "Life Context" && $0.valueLabel == "1" })
        XCTAssertTrue(lifeContextResults.contains {
            $0.title == "Local context profile" &&
                $0.summary.localizedCaseInsensitiveContains("Transit")
        })
        XCTAssertFalse(search.filters.contains { $0.title == "Life Capital" })
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
    }
}

private extension P1FLocalSearchFoundationTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
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
            reminders: SwiftDataReminderRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            eventLedger: SwiftDataEventLedgerRepository(store: store),
            sideEffectLedger: SwiftDataSideEffectLedgerRepository(store: store),
            actionReceiptHistory: SwiftDataActionReceiptHistoryRepository(store: store),
            lifeContext: SwiftDataLifeContextRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeLifeContextBundle() -> LifeContextBundle {
        LifeContextBundle(
            id: "life-context-p1f",
            profile: LifeContextProfile(
                id: "life-profile-p1f",
                birthdate: nil,
                exactAgeYears: nil,
                ageSource: nil,
                ageLastConfirmedAt: nil,
                timezone: "America/New_York",
                locale: "en-US",
                generalLocationLabel: "Local context profile",
                locationPrecision: .cityRegion,
                sexOrEligibilityContext: nil,
                lifeStage: .adult,
                schoolOrWorkContext: nil,
                travelRadiusMinutes: 30,
                travelRadiusMiles: nil,
                transportationAccess: .transit,
                scheduleAnchors: [],
                dependencyConstraints: [],
                budgetConstraintBand: .moderate,
                energyPattern: .variable,
                recoveryConstraints: [],
                accessibilityNeeds: [],
                userNotes: "Transportation local context used only as a searchable placeholder."
            ),
            createdAt: "2026-05-25T16:08:00Z",
            updatedAt: "2026-05-25T16:09:00Z"
        )
    }
}
