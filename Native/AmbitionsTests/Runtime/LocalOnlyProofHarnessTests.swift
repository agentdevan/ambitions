import Foundation
import XCTest
@testable import Ambitions

final class LocalOnlyProofHarnessTests: XCTestCase {
    func testPrivateLifeRuntimeBoundaryLocalOnlyIsLocalOnlyAndNonHosted() {
        let boundary = PrivateLifeRuntimeBoundary.localOnly

        XCTAssertTrue(boundary.usesSwiftDataPersistence)
        XCTAssertTrue(boundary.usesRepositoryBackedMemory)
        XCTAssertEqual(boundary.syncBackendKind, .localOnly)
        XCTAssertFalse(boundary.hasHostedBackend)
        XCTAssertFalse(boundary.hasRemoteIntelligenceBackend)
        XCTAssertFalse(boundary.hasExternalCloudLLMDependency)
        XCTAssertFalse(boundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries)
        XCTAssertTrue(boundary.isLocalOnly)
    }

    func testCurrentLocalRuntimeCapabilitiesStayLocalOnlyAndUseLocalTrustPosture() {
        let capabilities = AmbitionsRuntimeCapabilities.currentLocalRuntime

        XCTAssertEqual(capabilities.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertEqual(capabilities.syncBackendKind, .localOnly)
        XCTAssertEqual(capabilities.trustPosture, .localOnly)
        XCTAssertTrue(capabilities.usesRepositoryBackedMemory)
        XCTAssertTrue(capabilities.supportsExternalSurfaceSnapshots)
        XCTAssertTrue(capabilities.supportsExternalActionCommands)
        XCTAssertTrue(capabilities.supportsCalendarReminderIntegration)
        XCTAssertTrue(capabilities.supportsNotificationScheduling)
        XCTAssertFalse(capabilities.hasRemoteIntelligenceBackend)
    }

    func testRuntimePackageBoundaryManifestCurrentExcludesRemoteIntelligenceAndForbiddenFrameworks() {
        let manifest = RuntimePackageBoundaryManifest.current

        XCTAssertFalse(manifest.remoteIntelligenceBackendDeclared)
        XCTAssertTrue(manifest.localRuntimeOwnerDeclared)
        XCTAssertFalse(manifest.packageWiringDeclared)
        XCTAssertTrue(manifest.forbiddenImports.contains("CloudKit"))
        XCTAssertTrue(manifest.forbiddenImports.contains("EventKit"))
        XCTAssertTrue(manifest.forbiddenImports.contains("UserNotifications"))
        XCTAssertTrue(manifest.forbiddenImports.contains("SwiftUI"))
        XCTAssertTrue(manifest.forbiddenImports.contains("UIKit"))
        XCTAssertTrue(manifest.forbiddenImports.contains("AppKit"))
    }

    @MainActor
    func testLocalRepositoryRuntimeCompositionUsesInMemorySwiftDataAndLocalOnlySyncCapability() async throws {
        let repositories = try makeRepositories()
        let goal = Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: "local-only-proof-goal",
            revision: 1,
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            state: .active,
            title: "Keep the runtime local-only",
            summary: "Boundary proof fixture.",
            mode: .project,
            relationshipKind: .independent,
            actor: GoalActor(
                actorID: "self",
                displayName: "Devan",
                ownership: .self,
                roleLabel: nil,
                isPrimary: true
            ),
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
                progressReviewCadenceDays: nil
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
            lifeGraph: nil
        )
        let capture = Capture(
            id: "local-only-proof-capture",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            rawText: "Local-only proof fixture.",
            sourceType: .todayQuickCapture,
            status: .seed,
            linkedGoalID: goal.id
        )

        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([capture])

        let runtime = AmbitionsRuntimeFactory.make(
            repositories: repositories,
            clientContext: .iphoneApp,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService(),
            syncCapability: LocalOnlySyncCapability(),
            externalSnapshotReader: StaticRuntimeSnapshotReader(snapshot: nil),
            knowledgeProvider: LocalOnlyKnowledgeProvider()
        )

        let context = try await runtime.contextService.loadContext(now: Date(timeIntervalSince1970: 1_776_600_000))
        let syncStatus = await runtime.syncCapability.status()

        XCTAssertEqual(context.capabilities.privateLifeRuntimeBoundary, PrivateLifeRuntimeBoundary.localOnly)
        XCTAssertTrue(context.capabilities.privateLifeRuntimeBoundary.isLocalOnly)
        XCTAssertEqual(context.capabilities.syncBackendKind, SyncBackendKind.localOnly)
        XCTAssertFalse(context.capabilities.hasRemoteIntelligenceBackend)
        XCTAssertEqual(context.syncStatus.backendKind, SyncBackendKind.localOnly)
        XCTAssertEqual(context.syncStatus.trustPosture, PortableTrustPosture.localOnly)
        XCTAssertEqual(context.syncStatus.availability, SyncCapabilityAvailability.unavailable)
        XCTAssertEqual(context.memorySummary.goalCount, 1)
        XCTAssertEqual(context.memorySummary.captureCount, 1)
        XCTAssertEqual(syncStatus.backendKind, SyncBackendKind.localOnly)
        XCTAssertEqual(syncStatus.trustPosture, PortableTrustPosture.localOnly)
        XCTAssertEqual(syncStatus.availability, SyncCapabilityAvailability.unavailable)
    }

    func testSCG009CNoAccountCoreFlowPersistsLocallyAndFeedsToday() async throws {
        let repositories = try makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let captureService = DefaultCaptureService(
            repository: repositories.captures,
            eventLedger: repositories.eventLedger,
            idProvider: { "local-only-capture-scg009c" }
        )
        let todayService = RepositoryBackedTodayService(
            repositories: repositories,
            captureService: captureService
        )
        let sync = LocalOnlySyncCapability()
        let syncStatus = await sync.status()
        let now = Date(timeIntervalSince1970: 1_712_692_800)

        let createdGoal = try await goalsService.createGoal(
            CreateGoalRequest(title: "Use Ambitions without an account"),
            now: now
        )
        let capture = try await captureService.createCapture(
            CreateCaptureRequest(rawText: "No account local capture", sourceType: .shellComposer),
            now: now
        )
        let today = try await todayService.loadTodayExperience(
            userDisplayName: "Local User",
            now: now
        )
        let goalID = try XCTUnwrap(createdGoal.target.goalID)
        let persistedGoal = try await repositories.goals.goal(id: goalID)
        let persistedCapture = try await repositories.captures.capture(id: capture.id)

        XCTAssertEqual(syncStatus.backendKind, .localOnly)
        XCTAssertEqual(syncStatus.availability, .unavailable)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
        XCTAssertNotNil(persistedGoal)
        XCTAssertEqual(persistedCapture?.rawText, "No account local capture")
        XCTAssertEqual(today.hero.primaryAction.action.target.goalID, createdGoal.target.goalID)
        XCTAssertEqual(today.hero.truth.nowSubtitle, "Use Ambitions without an account")
    }

    func testAppUnitOfWorkReceiptsExposeLocalSwiftDataSingleContextAndNoExternalSideEffects() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let unitOfWork = SwiftDataAppUnitOfWork(store: store)

        let result = try await unitOfWork.perform(id: "local-only-proof-unit-of-work") { _ in
            "saved"
        }

        XCTAssertEqual(result.value, "saved")
        XCTAssertEqual(result.receipt.writeScope, .localSwiftDataSingleContext)
        XCTAssertFalse(result.receipt.didCommitChanges)
        XCTAssertEqual(result.receipt.rollbackBehavior, AppUnitOfWorkReceipt.rollbackOnThrownError)
        XCTAssertEqual(result.receipt.sideEffectPolicy, AppUnitOfWorkReceipt.noExternalSideEffects)
    }

    func testPrivacyManifestDeclaresNoCollectedDataAndOnlyInventoriedAccessedAPIs() throws {
        let privacyManifest = try loadPrivacyManifest()
        let accessedAPITypes = privacyManifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]] ?? []
        let fileTimestampAPI = try XCTUnwrap(accessedAPITypes.first)

        XCTAssertEqual(privacyManifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertTrue((privacyManifest["NSPrivacyCollectedDataTypes"] as? [Any] ?? []).isEmpty)
        XCTAssertEqual(accessedAPITypes.count, 1)
        XCTAssertEqual(fileTimestampAPI["NSPrivacyAccessedAPIType"] as? String, "NSPrivacyAccessedAPICategoryFileTimestamp")
        XCTAssertEqual(fileTimestampAPI["NSPrivacyAccessedAPITypeReasons"] as? [String], ["C617.1"])
    }
}

private extension LocalOnlyProofHarnessTests {
    func loadPrivacyManifest() throws -> [String: Any] {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let url = repoRoot.appendingPathComponent("Native/Ambitions/Resources/PrivacyInfo.xcprivacy")
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return try XCTUnwrap(plist as? [String: Any])
    }

    struct StaticRuntimeSnapshotReader: RuntimeExternalSurfaceSnapshotReading {
        let snapshot: ExternalSurfaceSnapshot?

        func loadSnapshot() async throws -> ExternalSurfaceSnapshot? {
            snapshot
        }
    }

    func makeRepositories() throws -> AppRepositories {
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
}
