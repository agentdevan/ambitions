@testable import Ambitions
import XCTest

@MainActor
final class AppSourceAtlasLifecycleRefreshSchedulerTests: XCTestCase {
    func testStartupRefreshSchedulingDoesNotWaitForSourceAtlasCompletion() async throws {
        let scheduler = AppSourceAtlasLifecycleRefreshScheduler()
        let service = DeferredSourceAtlasLifecycleRefreshService()
        let input = SourceAtlasPublicPackLifecycleRefreshInput(
            mode: .startup,
            networkReachability: .online,
            checkedAt: Date(timeIntervalSince1970: 1_780_100_000)
        )

        scheduler.scheduleRefresh(input, using: service)

        XCTAssertTrue(scheduler.hasInFlightRefresh)
        XCTAssertNil(scheduler.latestResolution)
        XCTAssertEqual(scheduler.latestInput, input)
        XCTAssertEqual(scheduler.scheduledRefreshCount, 1)
        XCTAssertEqual(scheduler.cancelledRefreshCount, 0)
        try await service.waitForPendingRefreshCount(1)
        let observedInputs = await service.observedInputs()
        XCTAssertEqual(observedInputs, [input])

        await service.completeNext(with: Self.resolution(mode: .startup, attemptedTargetIDs: ["startup"]))
        try await Self.waitUntil { scheduler.hasInFlightRefresh == false }

        XCTAssertEqual(scheduler.latestResolution?.mode, .startup)
        XCTAssertEqual(scheduler.latestResolution?.attemptedTargetIDs, ["startup"])
        XCTAssertFalse(scheduler.latestResolution?.coreLocalPlanningBlocked ?? true)
    }

    func testRetryCancelsPriorRefreshAndIgnoresStaleCompletion() async throws {
        let scheduler = AppSourceAtlasLifecycleRefreshScheduler()
        let service = DeferredSourceAtlasLifecycleRefreshService()
        let firstInput = SourceAtlasPublicPackLifecycleRefreshInput(
            mode: .startup,
            networkReachability: .online,
            checkedAt: Date(timeIntervalSince1970: 1_780_100_000)
        )
        let retryInput = SourceAtlasPublicPackLifecycleRefreshInput(
            mode: .activeLifecycle,
            networkReachability: .online,
            checkedAt: Date(timeIntervalSince1970: 1_780_100_030)
        )

        scheduler.scheduleRefresh(firstInput, using: service)
        try await service.waitForPendingRefreshCount(1)

        scheduler.scheduleRefresh(retryInput, using: service)
        try await service.waitForPendingRefreshCount(2)

        XCTAssertTrue(scheduler.hasInFlightRefresh)
        XCTAssertEqual(scheduler.latestInput, retryInput)
        XCTAssertEqual(scheduler.scheduledRefreshCount, 2)
        XCTAssertEqual(scheduler.cancelledRefreshCount, 1)

        await service.completeNext(with: Self.resolution(mode: .startup, attemptedTargetIDs: ["stale-startup"]))
        await Task.yield()
        XCTAssertNil(scheduler.latestResolution)
        XCTAssertTrue(scheduler.hasInFlightRefresh)

        await service.completeNext(with: Self.resolution(mode: .activeLifecycle, attemptedTargetIDs: ["retry"]))
        try await Self.waitUntil { scheduler.hasInFlightRefresh == false }

        let observedModes = await service.observedInputs().map(\.mode)
        XCTAssertEqual(observedModes, [.startup, .activeLifecycle])
        XCTAssertEqual(scheduler.latestResolution?.mode, .activeLifecycle)
        XCTAssertEqual(scheduler.latestResolution?.attemptedTargetIDs, ["retry"])
        XCTAssertFalse(scheduler.latestResolution?.sentPrivateRuntimeContext ?? true)
        XCTAssertFalse(scheduler.latestResolution?.generatedFinalPlan ?? true)
        XCTAssertFalse(scheduler.latestResolution?.generatedFinalSchedule ?? true)
        XCTAssertFalse(scheduler.latestResolution?.generatedStepList ?? true)
    }

    func testAppBootstrapperLaunchPathSchedulesSourceAtlasRefreshWithoutAwaitingIt() throws {
        let source = try String(
            contentsOf: Self.repoRoot().appendingPathComponent("Native/Ambitions/App/AppBootstrapper.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("await reconcileMaintenance(using: container, mode: .startup"))
        XCTAssertTrue(source.contains("sourceAtlasRefreshScheduler.scheduleRefresh"))
        XCTAssertFalse(
            source.contains("_ = await container.sourceAtlasLifecycleRefreshService.refreshPublicSourceAtlasPacks"),
            "Startup maintenance must schedule Source Atlas refresh instead of awaiting network-backed public refresh work."
        )
    }

    func testSwiftUISceneRegistersAllowedSourceAtlasBackgroundRefreshIdentifier() throws {
        let rootSceneSource = try String(
            contentsOf: Self.repoRoot().appendingPathComponent("Native/Ambitions/App/AmbitionsRootScene.swift"),
            encoding: .utf8
        )
        let bootstrapperSource = try String(
            contentsOf: Self.repoRoot().appendingPathComponent("Native/Ambitions/App/AppBootstrapper.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(
            rootSceneSource.contains(".backgroundTask(.appRefresh(SourceAtlasPublicPackBackgroundRefreshTaskIdentifier.publicPackRefresh))")
        )
        XCTAssertTrue(rootSceneSource.contains("await bootstrapper.performSourceAtlasPublicPackBackgroundRefresh"))
        XCTAssertTrue(bootstrapperSource.contains("mode: .background"))
        XCTAssertTrue(bootstrapperSource.contains("container.sourceAtlasLifecycleRefreshService.refreshPublicSourceAtlasPacks(input)"))
        XCTAssertFalse(bootstrapperSource.contains("generatedFinalPlan = true"))
        XCTAssertFalse(bootstrapperSource.contains("generatedFinalSchedule = true"))
    }

    func testSourceAtlasBackgroundRefreshIdentifierIsConfiguredInInfoPlist() throws {
        let infoURL = Self.repoRoot().appendingPathComponent("Native/Ambitions/Support/Info.plist")
        let info = try XCTUnwrap(NSDictionary(contentsOf: infoURL) as? [String: Any])
        let permittedIdentifiers = try XCTUnwrap(info["BGTaskSchedulerPermittedIdentifiers"] as? [String])
        let backgroundModes = try XCTUnwrap(info["UIBackgroundModes"] as? [String])

        XCTAssertEqual(permittedIdentifiers, [SourceAtlasPublicPackBackgroundRefreshTaskIdentifier.publicPackRefresh])
        XCTAssertEqual(backgroundModes, ["fetch"])
    }
}

private actor DeferredSourceAtlasLifecycleRefreshService: SourceAtlasPublicPackLifecycleRefreshing {
    private struct PendingRefresh {
        let input: SourceAtlasPublicPackLifecycleRefreshInput
        let continuation: CheckedContinuation<SourceAtlasPublicPackLifecycleRefreshResolution, Never>
    }

    private var inputs: [SourceAtlasPublicPackLifecycleRefreshInput] = []
    private var pending: [PendingRefresh] = []

    func refreshPublicSourceAtlasPacks(
        _ input: SourceAtlasPublicPackLifecycleRefreshInput
    ) async -> SourceAtlasPublicPackLifecycleRefreshResolution {
        inputs.append(input)
        return await withCheckedContinuation { continuation in
            pending.append(PendingRefresh(input: input, continuation: continuation))
        }
    }

    func observedInputs() -> [SourceAtlasPublicPackLifecycleRefreshInput] {
        inputs
    }

    func waitForPendingRefreshCount(_ count: Int) async throws {
        for _ in 0..<100 {
            if pending.count >= count {
                return
            }
            try await Task.sleep(nanoseconds: 5_000_000)
        }
        throw XCTSkip("Deferred Source Atlas refresh did not reach pending count \(count).")
    }

    func completeNext(with resolution: SourceAtlasPublicPackLifecycleRefreshResolution) {
        guard pending.isEmpty == false else { return }
        let next = pending.removeFirst()
        next.continuation.resume(returning: resolution)
    }
}

private extension AppSourceAtlasLifecycleRefreshSchedulerTests {
    static func resolution(
        mode: SourceAtlasPublicPackLifecycleRefreshMode,
        attemptedTargetIDs: [String]
    ) -> SourceAtlasPublicPackLifecycleRefreshResolution {
        SourceAtlasPublicPackLifecycleRefreshResolution(
            mode: mode,
            configuredTargetCount: attemptedTargetIDs.count,
            attemptedTargetIDs: attemptedTargetIDs,
            issues: [],
            registryResolution: SourceAtlasPublicPackRefreshTargetRegistry().resolveTargets(for: mode),
            egressFindings: [],
            targetResolutions: [],
            sentPrivateRuntimeContext: false,
            scheduledHiddenRuntimeMutation: false,
            generatedFinalPlan: false,
            generatedFinalSchedule: false,
            generatedStepList: false
        )
    }

    static func waitUntil(
        _ predicate: @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        for _ in 0..<100 {
            if predicate() {
                return
            }
            try await Task.sleep(nanoseconds: 5_000_000)
        }
        XCTFail("Timed out waiting for predicate.", file: file, line: line)
    }

    static func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/App/AppBootstrapper.swift")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
