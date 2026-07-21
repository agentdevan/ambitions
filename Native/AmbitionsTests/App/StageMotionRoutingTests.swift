import XCTest
@testable import Ambitions

@MainActor
final class StageMotionRoutingTests: XCTestCase {
    func testMotionRoutingUsesExplicitTypedDispatchWithoutGlobalNotifications() throws {
        let root = repoRoot()
        let eventSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Stage/Motion/StageMotionEvent.swift"),
            encoding: .utf8
        )
        let viewSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift"),
            encoding: .utf8
        )
        let stageSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Stage/AmbitionsStage.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(eventSource.contains("Notification"))
        XCTAssertFalse(viewSource.contains("NotificationCenter"))
        XCTAssertFalse(viewSource.contains("onAction: @escaping (MotionCurrentAction) -> Void ="))
        XCTAssertFalse(stageSource.contains("NotificationCenter"))
        XCTAssertFalse(stageSource.contains("motionCurrentActionObserver"))
    }

    func testEveryMotionActionDispatchesThroughTypedReducerOwnedStageRoutes() {
        let owner = StageOwner()

        let today = StageStore(selectedSurface: .time)
        today.handleMotionAction(.openToday, owner: owner, source: "test")
        XCTAssertEqual(today.selectedTab, .today)
        XCTAssertEqual(today.lastEffectRun.proofArtifactIDs, ["stage.surface.today"])

        let goals = StageStore(selectedSurface: .today)
        goals.handleMotionAction(.openGoals, owner: owner, source: "test")
        XCTAssertEqual(goals.selectedTab, .goals)
        XCTAssertEqual(goals.lastStageFocusPlan.target, .rootObject(.goals))

        let time = StageStore(selectedSurface: .today)
        time.handleMotionAction(.openTime, owner: owner, source: "test")
        XCTAssertEqual(time.selectedTab, .time)

        let trust = StageStore(selectedSurface: .today)
        trust.handleMotionAction(.openTrust, owner: owner, source: "test")
        XCTAssertEqual(trust.youPath, [.history])

        for action in [
            MotionCurrentAction.reviewHistory("review"),
            .openHistory("history"),
            .returnToThread("thread")
        ] {
            let navigation = StageStore(selectedSurface: .today)
            navigation.handleMotionAction(action, owner: owner, source: "test")
            XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
            XCTAssertEqual(navigation.lastStageFocusPlan.target, .overlay("memory-lens"))
        }
    }

    func testStageOwnerRoutesMotionActionsToCanonicalSurfaces() {
        let owner = StageOwner()

        switch owner.route(for: .openToday, source: "test") {
        case let .returnToToday(context):
            XCTAssertEqual(context, .standard)
        default:
            XCTFail("openToday should route to Today standard context")
        }

        switch owner.route(for: .openGoals, source: "test") {
        case .openGoals:
            break
        default:
            XCTFail("openGoals should route to Goals")
        }

        switch owner.route(for: .openTime, source: "test") {
        case .openTime:
            break
        default:
            XCTFail("openTime should route to Time")
        }
    }

    func testStageOwnerRoutesReviewHistoryAndThreadReturnThroughMemoryLensOverlay() {
        let owner = StageOwner()

        assertMemoryLensOverlay(
            owner.route(for: .reviewHistory("review"), source: "test"),
            expectedQuery: "review:review"
        )
        assertMemoryLensOverlay(
            owner.route(for: .openHistory("history"), source: "test"),
            expectedQuery: "history:history"
        )
        assertMemoryLensOverlay(
            owner.route(for: .returnToThread("thread"), source: "test"),
            expectedQuery: "thread:thread"
        )
    }

    func testStageOwnerRecordsProjectionAndReduceMotionState() {
        let owner = StageOwner(reduceMotionEnabled: true)
        _ = owner.route(for: .openTime, source: "stage-test")

        XCTAssertEqual(owner.lastMotionProjection?.action, .openTime)
        XCTAssertEqual(owner.lastMotionProjection?.sourceSurface, "stage-test")
        XCTAssertEqual(owner.lastMotionProjection?.reduceMotion, true)
        XCTAssertEqual(owner.lastMotionProjection?.displayStyle, .calm)
        XCTAssertEqual(owner.lastMotionCoordination?.projection.action, .openTime)
        XCTAssertEqual(owner.lastMotionCoordination?.reductionPolicy.displayStyle, .calm)
        XCTAssertFalse(owner.lastMotionCoordination?.reductionPolicy.allowsAmbientMovement ?? true)
    }

    func testStageMotionDefaultSourceIsBehaviorLayerNotRootSurface() {
        let owner = StageOwner()
        _ = owner.route(for: .openTime)

        XCTAssertEqual(owner.lastMotionProjection?.sourceSurface, "stage.motion")
        XCTAssertFalse(owner.lastMotionProjection?.sourceSurface.localizedCaseInsensitiveContains("motion.current") ?? true)

        let coordination = StageMotionCoordinator().coordinate(action: .reviewHistory(nil))
        XCTAssertEqual(coordination.projection.sourceSurface, "stage.motion")
        XCTAssertFalse(coordination.projection.sourceSurface.localizedCaseInsensitiveContains("screen"))
        XCTAssertFalse(coordination.projection.sourceSurface.localizedCaseInsensitiveContains("tab"))
    }

    func testStageMotionCoordinatorOwnsCanonicalRoutingAndPolicy() {
        let coordinator = StageMotionCoordinator(reduceMotionEnabled: false)
        let coordination = coordinator.coordinate(
            action: .reviewHistory(nil),
            source: "stage-motion-test"
        )

        XCTAssertEqual(coordination.projection.action, .reviewHistory(nil))
        XCTAssertEqual(coordination.projection.sourceSurface, "stage-motion-test")
        XCTAssertEqual(coordination.projection.reduceMotion, false)
        XCTAssertEqual(coordination.projection.displayStyle, .active)
        XCTAssertEqual(coordination.reductionPolicy.displayStyle, .active)
        XCTAssertTrue(coordination.reductionPolicy.allowsAmbientMovement)
        assertMemoryLensOverlay(coordination.route, expectedQuery: "review continuity")
    }

    func testStageMotionReductionPolicyKeepsReducedMotionSemanticQueriesStatic() {
        let policy = StageMotionReductionPolicy.current(reduceMotionEnabled: true)

        XCTAssertEqual(policy.displayStyle, .calm)
        XCTAssertFalse(policy.allowsAmbientMovement)
        XCTAssertEqual(policy.motionQuery(label: "review", action: .reviewHistory(nil)), "review")
        XCTAssertEqual(policy.motionQuery(label: "review", action: .reviewHistory("review-id")), "review:review-id")
        XCTAssertTrue(policy.movementTextureDescription.contains("Static movement marks"))
        XCTAssertTrue(policy.rhythmSpacingDescription.contains("static"))
    }

    private func assertMemoryLensOverlay(_ route: StageMotionRoute, expectedQuery: String) {
        switch route {
        case let .presentOverlay(overlay):
            XCTAssertEqual(overlay.kind, .memoryLens)
            XCTAssertEqual(overlay.query, expectedQuery)
        default:
            XCTFail("Expected presentOverlay memory lens route")
        }
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
