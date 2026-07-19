@testable import Ambitions
import XCTest

final class AppContainerFactoryTests: XCTestCase {
    func testLiveBootstrapDoesNotSeedFreshRepositories() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        let repositories = try await AppContainerFactory.prepareRepositories(for: .live, store: store)

        let goals = try await repositories.goals.listGoals()
        let drafts = try await repositories.drafts.listDrafts()
        let evidence = try await repositories.evidence.listEvidence(goalID: nil)
        let feedback = try await repositories.feedback.listEvents(goalID: nil)
        let reminders = try await XCTUnwrap(repositories.reminders).listReminders()
        let actionReceipts = try await XCTUnwrap(repositories.actionReceiptHistory).listRecords()
        let runtimeSnapshots = try await XCTUnwrap(repositories.runtimeSnapshotLedger).fetchRecent(limit: 10)
        let commandRecords = try await XCTUnwrap(repositories.commandExecutionRecords).fetchRecent(limit: 10)
        let commandJournalEntries = try await repositories.commandJournal.fetchEntries(matching: .all, limit: 10)
        let graphOperationalRecords = try await XCTUnwrap(repositories.graphOperationalRecords).fetchRecords(surface: nil, snapshotID: nil, limit: 10)
        let graphProofRecords = try await XCTUnwrap(repositories.graphProofRecords).fetchRecords(proofID: nil, limit: 10)
        let graphProjectionRecords = try await XCTUnwrap(repositories.graphProjectionRecords).fetchRecords(surface: nil, snapshotID: nil, limit: 10)
        let state = try await repositories.appState.loadState()

        XCTAssertTrue(goals.isEmpty)
        XCTAssertTrue(drafts.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(reminders.isEmpty)
        XCTAssertTrue(actionReceipts.isEmpty)
        XCTAssertTrue(runtimeSnapshots.isEmpty)
        XCTAssertTrue(commandRecords.isEmpty)
        XCTAssertTrue(commandJournalEntries.isEmpty)
        XCTAssertTrue(graphOperationalRecords.isEmpty)
        XCTAssertTrue(graphProofRecords.isEmpty)
        XCTAssertTrue(graphProjectionRecords.isEmpty)
        XCTAssertEqual(state.userDisplayName, "")
        XCTAssertEqual(state.appearancePreference, .dark)
        XCTAssertNil(state.lastSeedVersion)
        XCTAssertNil(state.lastSeededAt)
    }

    func testLiveBootstrapUsesSQLiteRuntimeEventAuthority() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        let repositories = try await AppContainerFactory.prepareRepositories(for: .live, store: store)
        let runtimeEvents = try XCTUnwrap(repositories.runtimeEvents)
        let factorySource = try source("Native/Ambitions/App/AppContainerFactory.swift")
        let persistenceBootstrapSource = try source("Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift")

        XCTAssertEqual(runtimeEvents.storeKind, .sqlite)
        XCTAssertTrue(runtimeEvents is EventStoreSQLite)
        XCTAssertNotNil(repositories.projectionStore)
        XCTAssertNotNil(repositories.searchIndex)
        XCTAssertTrue(factorySource.contains("PersistenceBootstrap.prepareRepositories"))
        XCTAssertTrue(persistenceBootstrapSource.contains("EventStoreSQLite.defaultLiveStore()"))
        XCTAssertTrue(persistenceBootstrapSource.contains("ProjectionStoreSQLite.defaultLiveStore()"))
        XCTAssertTrue(persistenceBootstrapSource.contains("SearchStoreFTS.defaultLiveStore()"))
        XCTAssertFalse(
            persistenceBootstrapSource.contains("return FileRuntimeEventStore.defaultLiveStore()"),
            "Persistent bootstrap runtime events must not use JSONL as live authority."
        )
    }

    func testAppBootstrapResponsibilitySlicesOwnNamedWiring() throws {
        let factorySource = try source("Native/Ambitions/App/AppContainerFactory.swift")
        let persistenceSource = try source("Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift")
        let runtimeSource = try source("Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift")
        let systemSurfaceSource = try source("Native/Ambitions/App/Bootstrap/SystemSurfaceBootstrap.swift")

        XCTAssertTrue(factorySource.contains("PersistenceBootstrap.prepareRepositories"))
        XCTAssertTrue(factorySource.contains("RuntimeBootstrap.makeRuntime"))
        XCTAssertTrue(factorySource.contains("SystemSurfaceBootstrap.makePlatformServices"))
        XCTAssertTrue(factorySource.contains("SystemSurfaceBootstrap.makeServices"))
        XCTAssertTrue(factorySource.contains("SystemSurfaceBootstrap.prepareLaunchEffects"))

        XCTAssertTrue(persistenceSource.contains("SwiftDataGoalRepository(store:"))
        XCTAssertTrue(persistenceSource.contains("EventStoreSQLite.defaultLiveStore()"))
        XCTAssertTrue(persistenceSource.contains("FileCommandJournal.defaultLiveStore()"))
        XCTAssertTrue(runtimeSource.contains("AmbitionsRuntimeFactory.make("))
        XCTAssertTrue(systemSurfaceSource.contains("LocalNotificationFoundation("))
        XCTAssertTrue(systemSurfaceSource.contains("EventKitIntegrationService("))
        XCTAssertFalse(systemSurfaceSource.contains("AmbitionsCommandExecutor("))
        XCTAssertTrue(systemSurfaceSource.contains("SourceAtlasPublicPackLifecycleRefreshService("))

        XCTAssertFalse(factorySource.contains("SwiftDataGoalRepository(store:"))
        XCTAssertFalse(factorySource.contains("AmbitionsRuntimeFactory.make("))
        XCTAssertFalse(factorySource.contains("LocalNotificationFoundation("))
        XCTAssertFalse(factorySource.contains("EventKitIntegrationService("))
        XCTAssertTrue(factorySource.contains("AmbitionsCommandExecutor("))
        XCTAssertTrue(factorySource.contains("RuntimeCommandClient("))
        XCTAssertTrue(factorySource.contains("scheduleStoreFileURL: scheduleStoreFileURL"))
        XCTAssertTrue(factorySource.contains("let lifeCalendarURL = lifeCalendarStoreURL(for: configuration)"))
        XCTAssertTrue(factorySource.contains(".applicationSupportDirectory"))
        XCTAssertTrue(factorySource.contains("URL.temporaryDirectory"))
        XCTAssertFalse(factorySource.contains("scheduleStoreFileURL: nil"))
        let capabilitySource = try source("Native/Ambitions/App/AppCapabilities.swift")
        let timeSurfaceSource = try source("Native/Ambitions/Surfaces/Time/TimeSurface.swift")
        XCTAssertTrue(capabilitySource.contains("let runtimeCommandClient: RuntimeCommandClient"))
        XCTAssertTrue(timeSurfaceSource.contains("featureFactory.runtimeCommandClient"))
    }

    func testPreviewAndDemoLifeCalendarStoresCannotResolveToLiveApplicationSupport() {
        let isolationID = UUID(uuidString: "B323E7AD-4E2C-4C42-A820-99E1D6B0CACE")!
        let secondIsolationID = UUID(uuidString: "A671B919-2DBD-4B24-B8FC-2EF29DF29C97")!
        let live = AppContainerFactory.lifeCalendarStoreURL(for: .live, isolatedStoreID: isolationID)
        let preview = AppContainerFactory.lifeCalendarStoreURL(for: .preview, isolatedStoreID: isolationID)
        let secondPreview = AppContainerFactory.lifeCalendarStoreURL(for: .preview, isolatedStoreID: secondIsolationID)
        #if DEBUG
        let demo = AppContainerFactory.lifeCalendarStoreURL(for: .demo, isolatedStoreID: isolationID)
        #endif

        XCTAssertTrue(live.path.hasPrefix(URL.applicationSupportDirectory.path))
        XCTAssertFalse(live.path.hasPrefix(URL.temporaryDirectory.path))
        XCTAssertTrue(preview.path.hasPrefix(URL.temporaryDirectory.path))
        XCTAssertNotEqual(preview, live)
        XCTAssertNotEqual(secondPreview, preview)
        #if DEBUG
        XCTAssertTrue(demo.path.hasPrefix(URL.temporaryDirectory.path))
        XCTAssertNotEqual(demo, live)
        XCTAssertNotEqual(demo, preview)
        #endif
        XCTAssertEqual(live.lastPathComponent, "LifeCalendar.json")
        XCTAssertEqual(preview.lastPathComponent, "LifeCalendar.json")
    }

    func testAppBootstrapDependencyGraphArtifactNamesCurrentOwners() throws {
        let artifact = try source("docs/audits/app-bootstrap-dependency-graph.md")

        XCTAssertTrue(artifact.contains("Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift"))
        XCTAssertTrue(artifact.contains("Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift"))
        XCTAssertTrue(artifact.contains("Native/Ambitions/App/Bootstrap/SystemSurfaceBootstrap.swift"))
        XCTAssertTrue(artifact.contains("Native/Ambitions/App/AppContainerFactory.swift"))
        XCTAssertTrue(artifact.contains("Proof ceiling: Source/architecture evidence"))
        XCTAssertTrue(artifact.contains("This artifact does not prove:"))
    }

    func testDemoBootstrapSeedsRepositoriesOnlyWhenExplicitlyRequested() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        #if DEBUG
            let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
            let goals = try await repositories.goals.listGoals()
            let drafts = try await repositories.drafts.listDrafts()
            let evidence = try await repositories.evidence.listEvidence(goalID: nil)
            let feedback = try await repositories.feedback.listEvents(goalID: nil)
            let state = try await repositories.appState.loadState()

            XCTAssertFalse(goals.isEmpty)
            XCTAssertFalse(drafts.isEmpty)
            XCTAssertFalse(evidence.isEmpty)
            XCTAssertFalse(feedback.isEmpty)
            XCTAssertEqual(state.lastSeedVersion, DemoSeedPipeline.seedVersion)
        #else
            _ = store
            throw XCTSkip("Demo bootstrap is only available in DEBUG builds.")
        #endif
    }

    func testLiveBootstrapPreservesExistingPersistedDataWithoutInjectingSeeds() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))

        try await repositories.goals.saveGoals([goal])
        try await repositories.appState.saveState(
            AppStateSnapshot(
                id: AppStateSnapshot.default.id,
                preferredTab: .goals,
                userDisplayName: "Existing User",
                appearancePreference: .dark,
                accentFamily: .blueGray,
                reviewCadenceDays: 3,
                localOnlyModeEnabled: true,
                hasCompletedBootstrap: true,
                hasCompletedOnboarding: true,
                onboardingVersion: 1,
                onboardingCompletedAt: GoalEngineFixtures.fixedNow,
                onboardingEntryChoice: .enterToday,
                lastBootstrapSource: .live,
                lastBootstrapAt: GoalEngineFixtures.fixedNow,
                lastSeedVersion: nil,
                lastSeededAt: nil,
                lastImportSummary: nil,
                lastOpenedGoalID: goal.id,
                goalPriorityOrder: [goal.id]
            )
        )

        let preparedRepositories = try await AppContainerFactory.prepareRepositories(for: .live, store: store)
        let loadedGoals = try await preparedRepositories.goals.listGoals()
        let loadedState = try await preparedRepositories.appState.loadState()

        XCTAssertEqual(loadedGoals.map(\.id), [goal.id])
        XCTAssertEqual(loadedGoals.first?.title, goal.title)
        XCTAssertEqual(loadedState.userDisplayName, "Existing User")
        XCTAssertEqual(loadedState.appearancePreference, .dark)
        XCTAssertEqual(loadedState.accentFamily, .blueGray)
        XCTAssertEqual(loadedState.goalPriorityOrder, [goal.id])
        XCTAssertNil(loadedState.lastSeedVersion)
    }

    @MainActor
    func testAppContainerExposesRuntimeWhilePreservingIPhoneServiceFacade() async throws {
        let container = try await AppContainerFactory.make(configuration: .preview)

        XCTAssertEqual(container.runtime.clientContext.kind, .iphoneApp)
        XCTAssertEqual(container.runtime.capabilities.syncBackendKind, .localOnly)
        XCTAssertNotNil(container.runtime.repositories.reminders as? SwiftDataReminderRepository)
        XCTAssertNotNil(container.runtime.repositories.actionReceiptHistory as? SwiftDataActionReceiptHistoryRepository)
        XCTAssertNotNil(container.runtime.repositories.commandExecutionRecords as? SwiftDataAmbitionsCommandExecutionRecordRepository)
        XCTAssertNotNil(container.runtime.repositories.commandJournal as? InMemoryCommandJournal)
        XCTAssertNotNil(container.runtime.repositories.runtimeSnapshotLedger as? SwiftDataRuntimeSnapshotLedgerRepository)
        XCTAssertNotNil(container.runtime.repositories.executionLedgerReplayInspection as? SwiftDataExecutionLedgerReplayInspectionRepository)
        XCTAssertNotNil(container.runtime.repositories.graphOperationalRecords as? SwiftDataAmbitionGraphOperationalRecordRepository)
        XCTAssertNotNil(container.runtime.repositories.graphProofRecords as? SwiftDataAmbitionGraphProofRecordRepository)
        XCTAssertNotNil(container.runtime.repositories.graphProjectionRecords as? SwiftDataAmbitionGraphProjectionRecordRepository)
        XCTAssertNotNil(container.runtime.goalIntelligenceService as? RepositoryBackedRuntimeGoalIntelligenceService)
        XCTAssertNotNil(container.todayService as? NotificationSchedulingTodayService)
        XCTAssertNotNil(container.goalsService as? NotificationSchedulingGoalsService)
        XCTAssertTrue(container.captureService is DefaultCaptureService)
        XCTAssertTrue(container.youService is RepositoryBackedYouService)
        XCTAssertEqual(container.shell.navigation.selectedTab, container.navigation.selectedTab)
        XCTAssertEqual(container.runtimeCapability.runtime.clientContext.kind, .iphoneApp)
        XCTAssertNotNil(container.runtimeCapability.todayService as? NotificationSchedulingTodayService)
        XCTAssertTrue(container.featureFactory.captureService is DefaultCaptureService)
        XCTAssertTrue(container.featureFactory.youService is RepositoryBackedYouService)
        XCTAssertEqual(container.persistence.bootstrapConfiguration, .preview)
        XCTAssertTrue(container.persistence.usesInMemoryStore)
        XCTAssertTrue(container.platform.externalActionService is AppExternalActionRoutingAdapter)
        XCTAssertTrue(container.sourceAtlasLifecycleRefreshService is SourceAtlasPublicPackLifecycleRefreshService)
        XCTAssertTrue(container.platform.sourceAtlasLifecycleRefreshService is SourceAtlasPublicPackLifecycleRefreshService)
        let sourceAtlasRefresh = await container.sourceAtlasLifecycleRefreshService.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .startup,
                networkReachability: .offline,
                checkedAt: Date(timeIntervalSince1970: 1_780_100_000)
            )
        )
        XCTAssertEqual(sourceAtlasRefresh.configuredTargetCount, 14)
        XCTAssertEqual(sourceAtlasRefresh.registryResolution.configuredEntryCount, 14)
        XCTAssertEqual(
            sourceAtlasRefresh.registryResolution.selectedTargetIDs,
            [
                "source-atlas-refresh-target.business_entrepreneurship.stable.20260628T000000Z",
                "source-atlas-refresh-target.creative_project_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.education_credentialing.stable.20260628T000000Z",
                "source-atlas-refresh-target.finance_public_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.health_wellness_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.health_wellness_reference_ca_statistics.stable.20260628T000000Z",
                "source-atlas-refresh-target.hobbies_recreation.stable.20260628T000000Z",
                "source-atlas-refresh-target.home_life_admin.stable.20260628T000000Z",
                "source-atlas-refresh-target.occupation_foundation.stable.20260628T000000Z",
                "source-atlas-refresh-target.personal_growth.stable.20260628T000000Z",
                "source-atlas-refresh-target.public_civic_requirements.stable.20260628T041500Z",
                "source-atlas-refresh-target.relationships_family.stable.20260628T000000Z",
                "source-atlas-refresh-target.travel_relocation.stable.20260628T000000Z",
                "source-atlas-refresh-target.volunteering_public_reference.stable.20260628T180600Z",
            ]
        )
        XCTAssertEqual(
            sourceAtlasRefresh.registryResolution.excludedTargetIDs,
            []
        )
        XCTAssertEqual(sourceAtlasRefresh.registryResolution.findings, [])
        XCTAssertEqual(sourceAtlasRefresh.registryResolution.egressFindings, [])
        let registryLoad = SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadDefaultAppArtifact()
        XCTAssertEqual(registryLoad.issues, [])
        XCTAssertEqual(registryLoad.artifactID, "source_atlas_public_refresh_targets.4d61a41e5350290c")
        XCTAssertFalse(registryLoad.usedFallbackEmptyRegistry)
        XCTAssertEqual(registryLoad.registry.entries.count, 14)
        XCTAssertEqual(Set(registryLoad.registry.entries.map(\.status)), [.active])
        XCTAssertEqual(
            sourceAtlasRefresh.attemptedTargetIDs,
            [
                "source-atlas-refresh-target.business_entrepreneurship.stable.20260628T000000Z",
                "source-atlas-refresh-target.creative_project_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.education_credentialing.stable.20260628T000000Z",
                "source-atlas-refresh-target.finance_public_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.health_wellness_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.health_wellness_reference_ca_statistics.stable.20260628T000000Z",
                "source-atlas-refresh-target.hobbies_recreation.stable.20260628T000000Z",
                "source-atlas-refresh-target.home_life_admin.stable.20260628T000000Z",
                "source-atlas-refresh-target.occupation_foundation.stable.20260628T000000Z",
                "source-atlas-refresh-target.personal_growth.stable.20260628T000000Z",
                "source-atlas-refresh-target.public_civic_requirements.stable.20260628T041500Z",
                "source-atlas-refresh-target.relationships_family.stable.20260628T000000Z",
                "source-atlas-refresh-target.travel_relocation.stable.20260628T000000Z",
                "source-atlas-refresh-target.volunteering_public_reference.stable.20260628T180600Z",
            ]
        )
        XCTAssertEqual(sourceAtlasRefresh.targetResolutions.count, 14)
        XCTAssertEqual(
            sourceAtlasRefresh.targetResolutions.compactMap {
                $0.appRefreshResolution?.refreshResolution.remoteResolution.transportIssues
            },
            [
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
                [.remoteFetchSkipped],
            ]
        )
        XCTAssertFalse(sourceAtlasRefresh.coreLocalPlanningBlocked)
        container.userSystem.applyAppearancePreference(.dark, .sage)
        XCTAssertEqual(container.appearancePreference, .dark)
        XCTAssertEqual(container.accentFamily, .sage)
    }
}

private extension AppContainerFactoryTests {
    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func goalFromFixture(id: String) -> Goal? {
        guard let fixture = GoalEngineFixtures.fixture(id: id) else {
            return nil
        }

        switch fixture.result {
        case let .planned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan
            )
        case let .starterPlanned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan
            )
        case .clarificationRequired, .blocked:
            return nil
        }
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "AppContainerFactoryTests", code: 1)
    }

    func source(_ relativePath: String) throws -> String {
        try String(
            contentsOf: repoRoot().appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }
}
