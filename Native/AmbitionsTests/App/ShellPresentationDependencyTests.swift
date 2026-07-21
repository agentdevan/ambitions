@testable import Ambitions
import AmbitionsTimeFoundation
import XCTest

@MainActor
final class ShellPresentationDependencyTests: XCTestCase {
    func testActivatedCaptureCommandForwardsExactRequestClockAndResult() async throws {
        let now = Date(timeIntervalSince1970: 1_789_123_456)
        let expectedResult = ShellCommandExecutionResult(
            title: "Saved through authority",
            destination: .tab(.today),
            createdCaptureID: "capture.created"
        )
        let router = ShellPresentationCommandRouterSpy(executionResult: expectedResult)
        let command = ActivatedCaptureCommand(
            commandRouter: router,
            clock: TestClock(now: now)
        )
        let request = ActivatedCaptureCommandRequest(
            text: "Book dentist",
            goalID: "goal.health",
            captureID: "capture.draft",
            source: .shellCompose,
            selectedCaptureRouteType: .reminder
        )

        let result = await command.execute(request)

        XCTAssertEqual(result, expectedResult)
        let invocation = try XCTUnwrap(router.executionInvocation)
        XCTAssertEqual(invocation.intent, .quickCapture)
        XCTAssertEqual(invocation.text, request.text)
        XCTAssertEqual(invocation.goalID, request.goalID)
        XCTAssertEqual(invocation.captureID, request.captureID)
        XCTAssertEqual(invocation.source, request.source)
        XCTAssertEqual(invocation.selectedCaptureRouteType, request.selectedCaptureRouteType)
        XCTAssertEqual(invocation.now, now)
    }

    func testShellOverlayActionsForwardRouterAndSearchDependencies() async throws {
        let result = MemoryLensResult(
            id: "memory.goal",
            title: "Open health goal",
            subtitle: "Current local goal",
            explanation: "Matched locally",
            queryText: "health",
            timestamp: "2026-07-21T12:00:00Z",
            kind: .goal,
            facet: .open,
            actionTitle: "Open",
            destination: .goal("goal.health")
        )
        let router = ShellPresentationCommandRouterSpy()
        let search = ShellPresentationMemoryLensSpy(results: [result])
        let actions = ShellOverlayActions(
            navigation: StageStore(selectedSurface: .today),
            commandRouter: router,
            searchService: search
        )

        actions.presentCreateGoal(
            source: .shellUtility,
            seedText: "Train consistently",
            captureID: "capture.seed"
        )
        actions.route(to: .tab(.time), source: .shellUtility)
        let handoff = actions.route(searchResult: result, source: .shellUtility)
        let searchResults = await actions.search(
            query: "health",
            seedIntent: .memoryLens,
            origin: .you
        )
        let searchRequests = await search.recordedRequests()

        XCTAssertEqual(router.createGoalInvocation?.source, .shellUtility)
        XCTAssertEqual(router.createGoalInvocation?.seedText, "Train consistently")
        XCTAssertEqual(router.createGoalInvocation?.captureID, "capture.seed")
        XCTAssertEqual(router.routeInvocation?.destination, .tab(.time))
        XCTAssertEqual(router.routeInvocation?.source, .shellUtility)
        XCTAssertEqual(router.searchRouteInvocation?.result, result)
        XCTAssertEqual(router.searchRouteInvocation?.source, .shellUtility)
        XCTAssertEqual(handoff, result.trustedSearchHandoff(source: .shellUtility))
        XCTAssertEqual(searchResults, [result])
        XCTAssertEqual(searchRequests, [.init(query: "health", seedIntent: .memoryLens, origin: .you)])
    }

    func testShellOverlayActionsMutateOnlyTheirInjectedNavigationStore() {
        let firstNavigation = StageStore(selectedSurface: .time)
        let secondNavigation = StageStore(selectedSurface: .goals)
        let firstActions = ShellOverlayActions(
            navigation: firstNavigation,
            commandRouter: ShellPresentationCommandRouterSpy(),
            searchService: ShellPresentationMemoryLensSpy()
        )

        firstActions.selectToday(entryContext: .stepSession)
        firstActions.presentNoteCapture(source: .shellUtility, seedText: "Keep this thought")

        XCTAssertEqual(firstNavigation.selectedTab, .today)
        XCTAssertEqual(firstNavigation.todayEntryContext, .stepSession)
        XCTAssertEqual(firstNavigation.activeOverlay?.query, "Keep this thought")
        XCTAssertEqual(firstNavigation.activeOverlay?.typedCaptureRoute?.kind, .noteThought)
        XCTAssertEqual(secondNavigation.selectedTab, .goals)
        XCTAssertNil(secondNavigation.activeOverlay)
    }
}

@MainActor
private final class ShellPresentationCommandRouterSpy: ShellCommandRouting {
    struct ExecutionInvocation: Equatable {
        let intent: ShellCommandIntent
        let text: String
        let goalID: String?
        let captureID: String?
        let source: ShellCommandEntrySource
        let selectedCaptureRouteType: SmartAttachmentRouteType?
        let now: Date
    }

    struct CreateGoalInvocation: Equatable {
        let source: ShellCommandEntrySource
        let seedText: String
        let captureID: String?
    }

    struct RouteInvocation: Equatable {
        let destination: ShellCommandDestination
        let source: ShellCommandEntrySource
    }

    struct SearchRouteInvocation: Equatable {
        let result: MemoryLensResult
        let source: ShellCommandEntrySource
    }

    var executionInvocation: ExecutionInvocation?
    var createGoalInvocation: CreateGoalInvocation?
    var routeInvocation: RouteInvocation?
    var searchRouteInvocation: SearchRouteInvocation?
    private let executionResult: ShellCommandExecutionResult

    init(executionResult: ShellCommandExecutionResult = ShellCommandExecutionResult()) {
        self.executionResult = executionResult
    }

    func presentCommandSheet(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext
    ) {}

    // swiftlint:disable:next function_parameter_count
    func presentMemoryLens(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        query: String,
        goalID: String?,
        captureID: String?
    ) {}

    func presentCreateGoal(source: ShellCommandEntrySource, seedText: String, captureID: String?) {
        createGoalInvocation = CreateGoalInvocation(
            source: source,
            seedText: seedText,
            captureID: captureID
        )
    }

    func route(to destination: ShellCommandDestination, source: ShellCommandEntrySource) {
        routeInvocation = RouteInvocation(destination: destination, source: source)
    }

    func route(
        searchResult result: MemoryLensResult,
        source: ShellCommandEntrySource
    ) -> ShellTrustedSearchHandoff {
        searchRouteInvocation = SearchRouteInvocation(result: result, source: source)
        return result.trustedSearchHandoff(source: source)
    }

    // swiftlint:disable:next function_parameter_count
    func execute(
        intent: ShellCommandIntent,
        text: String,
        goalID: String?,
        captureID: String?,
        source: ShellCommandEntrySource,
        selectedCaptureRouteType: SmartAttachmentRouteType?,
        now: Date
    ) async -> ShellCommandExecutionResult {
        executionInvocation = ExecutionInvocation(
            intent: intent,
            text: text,
            goalID: goalID,
            captureID: captureID,
            source: source,
            selectedCaptureRouteType: selectedCaptureRouteType,
            now: now
        )
        return executionResult
    }
}

private actor ShellPresentationMemoryLensSpy: MemoryLensServicing {
    struct Request: Sendable, Equatable {
        let query: String
        let seedIntent: ShellCommandIntent?
        let origin: AmbitionsSurface?
    }

    private let results: [MemoryLensResult]
    private var requests: [Request] = []

    init(results: [MemoryLensResult] = []) {
        self.results = results
    }

    func search(
        query: String,
        seedIntent: ShellCommandIntent?,
        origin: AmbitionsSurface?
    ) async -> [MemoryLensResult] {
        requests.append(Request(query: query, seedIntent: seedIntent, origin: origin))
        return results
    }

    func recordedRequests() -> [Request] {
        requests
    }
}
