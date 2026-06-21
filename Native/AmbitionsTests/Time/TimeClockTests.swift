@testable import Ambitions
import Foundation
import XCTest

final class TimeClockTests: XCTestCase {
    func testCanonicalCoreTimeClockOwnersExistAndSharePolicy() throws {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/Time/AmbitionsClock.swift",
            "Native/Ambitions/Core/Time/SystemClock.swift",
            "Native/Ambitions/Core/Time/PreviewClock.swift",
            "Native/Ambitions/Core/Time/TimeZoneProvider.swift",
            "Native/Ambitions/Core/Time/DayBoundaryScheduler.swift",
            "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Core/Time owner: \(requiredPath)"
            )
        }

        let fixedSystem = SystemClock(timeZoneProvider: .utc)
        XCTAssertTrue(fixedSystem.advancesAutomatically)
        XCTAssertEqual(fixedSystem.timeZone.secondsFromGMT(), 0)
        XCTAssertEqual(fixedSystem.calendar.timeZone.secondsFromGMT(), 0)
    }

    func testProductionClockFactoryProvidesLiveSystemClock() {
        let before = Date()
        let clock = AmbitionsClockFactory.clock(for: .live, environment: [:])
        let observedNow = clock.now
        let after = Date()

        XCTAssertTrue(clock is SystemClock)
        XCTAssertTrue(clock.advancesAutomatically)
        XCTAssertGreaterThanOrEqual(observedNow, before)
        XCTAssertLessThanOrEqual(observedNow, after.addingTimeInterval(0.1))
    }

    func testRuntimeTickPolicyOwnsCalendarAndFormattingBehavior() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T22:30:00Z"))
        let policy = RuntimeTickPolicy.utc
        let dayStart = policy.startOfDay(for: now)
        let shifted = try XCTUnwrap(policy.date(byAdding: .day, value: 2, to: dayStart))

        XCTAssertEqual(DomainTimestamp.string(from: dayStart), "2026-04-15T00:00:00.000Z")
        XCTAssertEqual(policy.dayDistance(from: dayStart, to: shifted), 2)
        XCTAssertTrue(policy.isSameDay(now, dayStart))
        XCTAssertEqual(policy.shortMonthDayLabel(for: now), "Apr 15")
        XCTAssertEqual(policy.shortWeekdayLabel(for: now), "Wed")
        XCTAssertEqual(policy.dayOfMonthLabel(for: now), "15")
        XCTAssertEqual(policy.parseDateOnly("2026-04-15"), dayStart)
    }

    @MainActor
    func testTimeViewModelRecordsLoadedDayFromInjectedClock() async throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T09:30:00Z"))
        let clock = TestClock(now: now)
        let service = ClockRecordingTimeService(timeState: PreviewTimeScenarios.seeded)
        let viewModel = TimeViewModel()

        await viewModel.load(using: service, now: clock.now, calendar: clock.calendar)

        let loadedNows = await service.loadedNows()
        XCTAssertEqual(loadedNows, [now])
        XCTAssertEqual(viewModel.lastLoadedDayStart, clock.calendar.startOfDay(for: now))
        XCTAssertFalse(viewModel.shouldRefreshForDayBoundary(now: now.addingTimeInterval(60 * 30), calendar: clock.calendar))
        XCTAssertTrue(viewModel.shouldRefreshForDayBoundary(now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T00:01:00Z")), calendar: clock.calendar))
    }

    func testDayBoundarySchedulerOnlyRefreshesAcrossClockDay() throws {
        let calendar = PreviewClock.utcCalendar
        let scheduler = DayBoundaryScheduler()
        let loaded = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T08:00:00Z"))
        let sameDay = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T23:59:00Z"))
        let nextDay = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T00:00:01Z"))
        let dayStart = scheduler.loadedDayStart(for: loaded, calendar: calendar)

        XCTAssertFalse(scheduler.shouldRefresh(lastLoadedDayStart: dayStart, now: sameDay, calendar: calendar))
        XCTAssertTrue(scheduler.shouldRefresh(lastLoadedDayStart: dayStart, now: nextDay, calendar: calendar))
    }

    func testClockRefreshContextRefreshesForTimeZoneChangeWithoutRelaunch() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T03:30:00Z"))
        let scheduler = DayBoundaryScheduler()
        let utcClock = TestClock(now: now)
        let newYorkZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        let newYorkClock = TestClock(now: now, timeZone: newYorkZone)
        let loadedContext = scheduler.loadedClockContext(
            for: utcClock.now,
            calendar: utcClock.calendar,
            timeZone: utcClock.timeZone
        )

        XCTAssertTrue(
            scheduler.shouldRefresh(
                lastLoadedClockContext: loadedContext,
                now: newYorkClock.now,
                calendar: newYorkClock.calendar,
                timeZone: newYorkClock.timeZone
            )
        )
    }

    func testTimeSourcesDoNotUseNowDefaultsForViewModelLoads() throws {
        let root = repoRoot()
        let sourceRoots = [
            "Native/Ambitions/Core/Time",
            "Native/Ambitions/Projection/SurfaceLenses",
            "Native/Ambitions/Surfaces/Time"
        ].map { root.appendingPathComponent($0) }
        let fileURLs = try sourceRoots.flatMap { try swiftFiles(under: $0) }
        let disallowedPatterns = [
            #"now:\s*Date\s*=\s*\.now"#,
            #"Date\s*=\s*\.now"#,
            #"Date\.now"#,
            #"load\(using:\s*service:\s*any TimeServicing,\s*now:\s*Date\s*="#
        ]

        var findings: [String] = []
        for fileURL in fileURLs {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            for pattern in disallowedPatterns where contents.range(of: pattern, options: .regularExpression) != nil {
                findings.append(fileURL.lastPathComponent + " :: " + pattern)
            }
        }

        XCTAssertTrue(findings.isEmpty, "Time source still reads live time directly: \(findings.joined(separator: ", "))")
    }

    @MainActor
    func testTimeViewModelRefreshesWhenInjectedClockTimeZoneChanges() async throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T03:30:00Z"))
        let utcClock = TestClock(now: now)
        let newYorkClock = TestClock(now: now, timeZone: try XCTUnwrap(TimeZone(identifier: "America/New_York")))
        let service = ClockRecordingTimeService(timeState: PreviewTimeScenarios.seeded)
        let viewModel = TimeViewModel()

        await viewModel.load(
            using: service,
            now: utcClock.now,
            calendar: utcClock.calendar,
            timeZone: utcClock.timeZone
        )

        XCTAssertTrue(
            viewModel.shouldRefreshForClockChange(
                now: newYorkClock.now,
                calendar: newYorkClock.calendar,
                timeZone: newYorkClock.timeZone
            )
        )
    }

    func testRepositoryBackedTimeServiceUsesInjectedClockCalendarForProjectionLabels() async throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T03:30:00Z"))
        let repositories = try await makeRepositories()
        let utcService = RepositoryBackedTimeService(
            repositories: repositories,
            clock: TestClock(now: now)
        )
        let newYorkService = RepositoryBackedTimeService(
            repositories: repositories,
            clock: TestClock(now: now, timeZone: try XCTUnwrap(TimeZone(identifier: "America/New_York")))
        )

        XCTAssertEqual(utcService.timeframeLabel(now: now), "Apr 16-Apr 22")
        XCTAssertEqual(newYorkService.timeframeLabel(now: now), "Apr 15-Apr 21")
    }

    func testTimeLensUsesInjectedClockForCurrentDateSummary() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T03:30:00Z"))
        let scene = TimeLens.makeStageScene(
            for: PreviewTimeScenarios.seeded,
            clock: TestClock(now: now, timeZone: try XCTUnwrap(TimeZone(identifier: "America/New_York")))
        )

        XCTAssertEqual(scene.currentDateSummary, "Apr 15")
    }

    func testPreviewClockIsDebugOnlyInReleaseScopedTimeSource() throws {
        let root = repoRoot()
        let sourceRoots = [
            "Native/Ambitions/Core/Time",
            "Native/Ambitions/Surfaces/Time",
            "Native/Ambitions/Surfaces/Today",
            "Native/Ambitions/Projection/SurfaceLenses"
        ].map { root.appendingPathComponent($0) }
        let fileURLs = try sourceRoots.flatMap { try swiftFiles(under: $0) }
        var findings: [String] = []

        for fileURL in fileURLs {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            let releaseContents = LifeShapeAuditSupport.releaseScopedContents(contents)
            guard releaseContents.contains("PreviewClock") else { continue }
            findings.append(fileURL.path.replacingOccurrences(of: root.path + "/", with: ""))
        }

        XCTAssertTrue(findings.isEmpty, "PreviewClock leaks into release-scoped Time/Today source: \(findings.joined(separator: ", "))")
    }

    func testTodayAndTimeProjectionSourcesUseCoreTimePolicyForRendering() throws {
        let root = repoRoot()
        let surfaceLensRoot = root.appendingPathComponent("Native/Ambitions/Projection/SurfaceLenses")
        let sourceURLs = try swiftFiles(under: surfaceLensRoot).filter {
            $0.lastPathComponent.hasPrefix("Today") || $0.lastPathComponent.hasPrefix("Time")
        }
        let disallowedPatterns = [
            #"\bDateFormatter\s*\("#,
            #"\bCalendar\.current\b"#,
        ]

        var findings: [String] = []
        for fileURL in sourceURLs {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            for pattern in disallowedPatterns where contents.range(of: pattern, options: .regularExpression) != nil {
                findings.append(fileURL.lastPathComponent + " :: " + pattern)
            }
        }

        XCTAssertTrue(findings.isEmpty, "Today/Time projection sources still render time directly: \(findings.joined(separator: ", "))")
    }

    private func swiftFiles(under root: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return try enumerator.compactMap { item in
            guard let url = item as? URL,
                  url.pathExtension == "swift",
                  try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else {
                return nil
            }
            return url
        }
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/Time")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    private func makeRepositories() async throws -> AppRepositories {
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

private actor ClockRecordingTimeService: TimeServicing {
    let timeState: TimeSurfaceState
    private var nows: [Date] = []

    init(timeState: TimeSurfaceState) {
        self.timeState = timeState
    }

    func loadTimeSurfaceState(now: Date) async throws -> TimeSurfaceState {
        nows.append(now)
        return timeState
    }

    func loadTimeWeeklyReviewState(now: Date) async throws -> TimeWeeklyReviewState {
        _ = now
        return PreviewTimeScenarios.weeklyReview
    }

    func makeTimeCalendarAware(now: Date) async throws -> TimeSurfaceState {
        nows.append(now)
        return timeState
    }

    func loadedNows() -> [Date] {
        nows
    }
}
