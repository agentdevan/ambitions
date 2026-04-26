import XCTest
@testable import Ambitions

final class OnboardingAndDegradedStateTests: XCTestCase {
    func testOlderAppStateSnapshotMissingOnboardingFieldsLoadsAsCompletedForExistingInstall() throws {
        let oldSnapshot = """
        {
          "id": "app_state.default",
          "preferredTab": "today",
          "userDisplayName": "Existing User",
          "appearancePreference": "system",
          "accentFamily": "sage",
          "reviewCadenceDays": 7,
          "localOnlyModeEnabled": true,
          "hasCompletedBootstrap": true,
          "lastBootstrapSource": "live",
          "lastBootstrapAt": "2026-04-20T12:00:00Z",
          "lastOpenedGoalID": null,
          "goalPriorityOrder": []
        }
        """.data(using: .utf8)!

        let state = try PersistenceCoding.decode(AppStateSnapshot.self, from: oldSnapshot)

        XCTAssertTrue(state.hasCompletedBootstrap)
        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertNil(state.onboardingEntryChoice)
    }

    func testFreshDefaultAppStateStillNeedsOnboarding() {
        XCTAssertFalse(AppStateSnapshot.default.hasCompletedBootstrap)
        XCTAssertFalse(AppStateSnapshot.default.hasCompletedOnboarding)
    }

    func testStartupShowsOnboardingForFreshInstallButNotExistingInstall() async throws {
        let freshRepository = InMemoryAppStateRepository(state: .default)
        let freshService = DefaultStartupService(
            preferencesStore: InMemoryAppPreferencesStore(preferences: AppStateSnapshot.default.preferences),
            appStateRepository: freshRepository
        )

        let freshSession = try await freshService.prepareSession(source: .live)

        XCTAssertTrue(freshSession.shouldShowOnboarding)

        var existingState = AppStateSnapshot.default
        existingState.hasCompletedBootstrap = true
        existingState.hasCompletedOnboarding = true
        let existingRepository = InMemoryAppStateRepository(state: existingState)
        let existingService = DefaultStartupService(
            preferencesStore: InMemoryAppPreferencesStore(preferences: existingState.preferences),
            appStateRepository: existingRepository
        )

        let existingSession = try await existingService.prepareSession(source: .live)

        XCTAssertFalse(existingSession.shouldShowOnboarding)
    }

    func testOnboardingCompletionPersistsChoice() async throws {
        let repository = InMemoryAppStateRepository(state: .default)
        let service = RepositoryBackedOnboardingService(appStateRepository: repository)

        let decision = try await service.complete(choice: .captureFirst, now: Date(timeIntervalSince1970: 0))
        let state = try await repository.loadState()

        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertEqual(state.onboardingEntryChoice, .captureFirst)
        XCTAssertEqual(decision, RepositoryBackedOnboardingService.routeDecision(for: .captureFirst))
    }

    func testCreateFirstGoalRouteDecision() {
        let decision = RepositoryBackedOnboardingService.routeDecision(for: .createFirstGoal)

        XCTAssertEqual(decision.selectedTab, .goals)
        XCTAssertEqual(decision.overlayIntent, .newGoal)
        XCTAssertEqual(decision.presentationContext, .createGoal)
    }

    func testCaptureFirstRouteDecision() {
        let decision = RepositoryBackedOnboardingService.routeDecision(for: .captureFirst)

        XCTAssertEqual(decision.selectedTab, .captures)
        XCTAssertEqual(decision.overlayIntent, .quickCapture)
        XCTAssertEqual(decision.presentationContext, .quickCapture)
    }

    func testDeniedPermissionDegradedStatePresentation() {
        let state = DegradedStateOrchestrator.permissionDeniedNotifications()

        XCTAssertEqual(state.kind, .permissionDenied)
        XCTAssertEqual(state.tone, .warning)
        XCTAssertEqual(state.primaryAction.routingHint, .profileTrust)
        XCTAssertEqual(state.secondaryAction?.routingHint, .systemSettings)
    }

    func testLowHistoryInsightsStatePresentation() {
        let state = DegradedStateOrchestrator.insightsLowHistory()

        XCTAssertEqual(state.kind, .lowHistory)
        XCTAssertEqual(state.primaryAction.routingHint, .today)
        XCTAssertTrue(state.explanation.contains("will not pretend"))
    }

    func testRepresentativeEmptyStateProjectionsForTopSurfaces() {
        XCTAssertEqual(DegradedStateOrchestrator.todayEmpty().kind, .empty)
        XCTAssertEqual(DegradedStateOrchestrator.goalsEmpty().primaryAction.routingHint, .createGoal)
        XCTAssertEqual(DegradedStateOrchestrator.planEmpty().secondaryAction?.routingHint, .captures)
        XCTAssertEqual(DegradedStateOrchestrator.capturesEmpty().title, "Capture messy life here")
        XCTAssertEqual(DegradedStateOrchestrator.youEmpty().primaryAction.routingHint, .profileTrust)
    }
}

private actor InMemoryAppStateRepository: AppStateRepository {
    private var state: AppStateSnapshot

    init(state: AppStateSnapshot) {
        self.state = state
    }

    func loadState() async throws -> AppStateSnapshot {
        state
    }

    func saveState(_ state: AppStateSnapshot) async throws {
        self.state = state
    }
}
