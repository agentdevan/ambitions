@testable import Ambitions
import Foundation
import XCTest

final class TodayClockTests: XCTestCase {
    @MainActor
    func testPreviewClockFreezesFromEnvironmentOverride() throws {
        let clock = try XCTUnwrap(PreviewClock.environmentOverride([
            PreviewClock.environmentKey: "2026-04-15T12:00:00Z"
        ]))

        XCTAssertEqual(DomainTimestamp.string(from: clock.now), "2026-04-15T12:00:00.000Z")
        XCTAssertEqual(clock.timeZone.secondsFromGMT(), 0)
        XCTAssertFalse(clock.advancesAutomatically)
        XCTAssertEqual(clock.calendar.component(.hour, from: clock.now), 12)
    }

    @MainActor
    func testClockFactoryUsesPreviewOverrideForDeterministicScreenshots() throws {
        let clock = AmbitionsClockFactory.clock(for: .preview, environment: [
            PreviewClock.environmentKey: "2026-04-15T22:30:00Z"
        ])

        XCTAssertEqual(DomainTimestamp.string(from: clock.now), "2026-04-15T22:30:00.000Z")
        XCTAssertFalse(clock.advancesAutomatically)
    }

    func testTestClockAdvancesWithoutReadingSystemTime() throws {
        let start = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T23:59:00Z"))
        let clock = TestClock(now: start)
        let advanced = clock.advanced(by: 120)

        XCTAssertEqual(DomainTimestamp.string(from: clock.now), "2026-04-15T23:59:00.000Z")
        XCTAssertEqual(DomainTimestamp.string(from: advanced.now), "2026-04-16T00:01:00.000Z")
        XCTAssertFalse(advanced.advancesAutomatically)
    }

    @MainActor
    func testTodayViewModelRecordsLoadedDayFromInjectedClock() async throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T09:30:00Z"))
        let clock = TestClock(now: now)
        let service = ClockRecordingTodayService(experience: PreviewTodayScenarios.stable)
        let viewModel = TodayViewModel()

        await viewModel.activate(
            using: service,
            userDisplayName: "Devan",
            now: clock.now,
            calendar: clock.calendar
        )

        let loadedNows = await service.loadedNows()
        XCTAssertEqual(loadedNows, [now])
        XCTAssertEqual(viewModel.lastLoadedDayStart, clock.calendar.startOfDay(for: now))
        XCTAssertFalse(viewModel.shouldRefreshForDayBoundary(now: now.addingTimeInterval(60 * 30), calendar: clock.calendar))
        XCTAssertTrue(viewModel.shouldRefreshForDayBoundary(now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T00:01:00Z")), calendar: clock.calendar))
    }

    func testTodayDayBoundaryRefreshPolicyOnlyRefreshesAcrossClockDay() throws {
        let calendar = PreviewClock.utcCalendar
        let policy = TodayDayBoundaryRefreshPolicy()
        let loaded = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T08:00:00Z"))
        let sameDay = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T23:59:00Z"))
        let nextDay = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T00:00:01Z"))
        let dayStart = policy.loadedDayStart(for: loaded, calendar: calendar)

        XCTAssertFalse(policy.shouldRefresh(lastLoadedDayStart: dayStart, now: sameDay, calendar: calendar))
        XCTAssertTrue(policy.shouldRefresh(lastLoadedDayStart: dayStart, now: nextDay, calendar: calendar))
    }

    @MainActor
    func testTodayViewModelRefreshesWhenInjectedClockTimeZoneChanges() async throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T03:30:00Z"))
        let utcClock = TestClock(now: now)
        let newYorkClock = TestClock(now: now, timeZone: try XCTUnwrap(TimeZone(identifier: "America/New_York")))
        let service = ClockRecordingTodayService(experience: PreviewTodayScenarios.stable)
        let viewModel = TodayViewModel()

        await viewModel.activate(
            using: service,
            userDisplayName: "Devan",
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

    func testTodayLensUsesInjectedClockForGeneratedAt() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let lens = TodayLens(experience: PreviewTodayScenarios.stable, clock: TestClock(now: now))

        XCTAssertEqual(lens.generatedAt, now)
        XCTAssertEqual(lens.stageScene.generatedAt, now)
    }

    func testStepReplacementRecordedAtIsDeterministicWhenClockIsInjected() throws {
        let clock = PreviewClock(now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z")))
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let recordedAt = DomainTimestamp.string(from: clock.now)

        let state = TodayStepReplacementSheetState.make(
            from: hero,
            privacy: rail.privacyProjection,
            contextLabel: rail.contextSummary,
            recordedAt: recordedAt
        )

        XCTAssertEqual(state.recordedAt, "2026-04-15T12:00:00.000Z")
        XCTAssertTrue(state.alternatives.allSatisfy { $0.receiptPreviewLabel.isEmpty == false })
    }

    func testTodaySourcesDoNotReadSystemTimeDirectlyOutsideSystemClock() throws {
        let sourceRoot = repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/Today")
        let fileURLs = try swiftFiles(under: sourceRoot)
        let disallowedPatterns = [
            #"Date\(\)"#,
            #"Calendar\.current"#,
            #"TimelineView\(\.periodic\(from:\s*\.now"#,
            #"DomainTimestamp\.string\(from:\s*\.now\)"#,
            #"Date\s*=\s*\.now"#,
            #"occurredAt:\s*Date\s*=\s*\.now"#,
        ]

        var findings: [String] = []
        for fileURL in fileURLs {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            for pattern in disallowedPatterns where contents.range(of: pattern, options: .regularExpression) != nil {
                findings.append(fileURL.lastPathComponent + " :: " + pattern)
            }
        }

        XCTAssertTrue(findings.isEmpty, "Today source still reads live time directly: \(findings.joined(separator: ", "))")
    }

    func swiftFiles(under root: URL) throws -> [URL] {
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

    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Surfaces/Today")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private actor ClockRecordingTodayService: TodayServicing {
    let experience: TodayExperience
    var nows: [Date] = []

    init(experience: TodayExperience) {
        self.experience = experience
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = entryContext
        nows.append(now)
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        return TodayActionResponse(message: nil)
    }

    func loadedNows() -> [Date] {
        nows
    }
}
