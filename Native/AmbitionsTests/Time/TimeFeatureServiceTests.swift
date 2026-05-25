import XCTest
@testable import Ambitions

final class TimeFeatureServiceTests: XCTestCase {
    func testEmptyRepositoriesReturnOpenRealityModelWeek() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.mode, .empty)
        XCTAssertEqual(dashboard.emptyTitle, "No weekly pressure yet")
        XCTAssertEqual(dashboard.believability.label, "Open")
        XCTAssertEqual(dashboard.primaryAction.kind, .useRoom)
        XCTAssertEqual(dashboard.weekDays.count, 7)
        XCTAssertEqual(dashboard.pressureScrubber.points.count, 7)
        XCTAssertEqual(dashboard.secondaryDestinations.map(\.id), ["plan-habits", "plan-captures", "plan-weekly-review"])
        XCTAssertTrue(dashboard.goalShapingItems.isEmpty)
        XCTAssertEqual(dashboard.hero.title, "Shape Time")
        XCTAssertEqual(dashboard.lifeSuite.title, "Shape Time")
        XCTAssertEqual(dashboard.lifeSuite.shapes.map(\.title), ["Day Shape", "Week Shape", "Life Shape"])
        XCTAssertTrue(dashboard.lifeSuite.shapes.allSatisfy { $0.facts.isEmpty == false })
        XCTAssertEqual(dashboard.lifeSuite.manualFallbackLabel, "Manual fallback available")
        XCTAssertEqual(dashboard.lifeSuite.trustLabel, "No silent calendar changes")
        XCTAssertEqual(dashboard.treaty.title, "This week's agreement")
        XCTAssertEqual(dashboard.capacityEnvelope.label, "Light")
        XCTAssertEqual(dashboard.timelineStrip.title, "Rich Timeline")
        XCTAssertFalse(dashboard.calendarBoundary.writeBoundary.lowercased().contains("sync"))
        XCTAssertFalse(dashboard.recoveryEntry.detail.contains("Reality Reflow"))
    }

    func testActiveGoalsProduceElasticWeekAndGoalRelationshipSignals() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.mode, .active)
        XCTAssertEqual(dashboard.weekDays.count, 7)
        XCTAssertEqual(dashboard.pressureScrubber.points.count, 7)
        XCTAssertFalse(dashboard.goalShapingItems.isEmpty)
        XCTAssertEqual(dashboard.shapingActions.map(\.kind), [.edit, .patch, .protect, .lighten])
        XCTAssertTrue(dashboard.hero.contextPills.contains(where: { $0.title.contains("goals visible") }))
        XCTAssertFalse(dashboard.resilience.lanes.isEmpty)
        XCTAssertNotNil(dashboard.primaryAction.goalTarget)
        XCTAssertEqual(dashboard.hero.title, "Shape Time")
        XCTAssertEqual(dashboard.treaty.title, "This week's agreement")
        XCTAssertFalse(dashboard.treaty.summary.contains("Kernel"))
        XCTAssertTrue(["Light", "Steady", "Tight", "Overloaded", "Fragile"].contains(dashboard.capacityEnvelope.label))
        XCTAssertFalse(dashboard.opportunityWindows.windows.isEmpty)
        XCTAssertLessThanOrEqual(dashboard.opportunityWindows.windows.count, 4)
        XCTAssertFalse(dashboard.timelineStrip.items.isEmpty)
    }

    func testF10TimeLifeSuiteProjectsDayWeekAndLifeShapeWithoutCalendarClone() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Place workshop idea", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let shapes = Dictionary(uniqueKeysWithValues: dashboard.lifeSuite.shapes.map { ($0.kind, $0) })

        XCTAssertEqual(dashboard.lifeSuite.subtitle, "LifeShape Field shows what the week can hold.")
        XCTAssertEqual(dashboard.lifeSuite.calendarBoundaryLabel, "Manual planning still works")
        XCTAssertEqual(shapes[.day]?.boundaryLabel, "No silent replanning")
        XCTAssertTrue(shapes[.day]?.facts.contains(where: { $0.contains("planned block") }) == true)
        XCTAssertEqual(shapes[.week]?.boundaryLabel, "Suggestions require confirmation")
        XCTAssertTrue(shapes[.week]?.summary.contains("capture") == true)
        XCTAssertTrue(shapes[.week]?.facts.contains("1 capture needs a place.") == true)
        XCTAssertEqual(shapes[.life]?.sourceLabel, "Based on active goals")
        XCTAssertFalse(dashboard.lifeSuite.trustLabel.localizedCaseInsensitiveContains("sync"))
    }

    func testCalendarAwareAvailabilityUsesExplicitAvailabilityLanguage() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .readWrite)
        )

        let timeState = service.makeCalendarAwarenessState(permission: .readWrite, openWindowCount: 1)

        XCTAssertEqual(timeState.title, "Calendar-aware availability")
        XCTAssertTrue(timeState.detail.localizedCaseInsensitiveContains("open window"))
        XCTAssertEqual(timeState.sourceLabel, "From your calendar")
        XCTAssertTrue(timeState.canRequestCalendarRead)
    }

    func testCalendarAwareActionSupportsDayWeekMonthAndYearHorizonRequests() async throws {
        let repositories = try await makeRepositories()
        let recordingService = RecordingTimeCalendarRealityService()
        let dayService = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: recordingService,
            calendarAvailabilityHorizon: "day"
        )
        let weekService = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: recordingService,
            calendarAvailabilityHorizon: "week"
        )
        let monthService = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: recordingService,
            calendarAvailabilityHorizon: "month"
        )
        let yearService = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: recordingService,
            calendarAvailabilityHorizon: "year"
        )

        let dayHorizon = dayService.dayHorizon(now: fixedDate)
        let weekHorizon = weekService.weekHorizon(now: fixedDate)
        let monthHorizon = monthService.monthHorizon(now: fixedDate)
        let yearHorizon = yearService.yearHorizon(now: fixedDate)

        _ = try await dayService.makeTimeCalendarAware(now: fixedDate)
        _ = try await weekService.makeTimeCalendarAware(now: fixedDate)
        _ = try await monthService.makeTimeCalendarAware(now: fixedDate)
        _ = try await yearService.makeTimeCalendarAware(now: fixedDate)

        let observedHorizon = await recordingService.currentRequestedHorizon()
        XCTAssertEqual(observedHorizon.count, 4)
        XCTAssertEqual(observedHorizon[0], dayHorizon)
        XCTAssertEqual(observedHorizon[1], weekHorizon)
        XCTAssertEqual(observedHorizon[2], monthHorizon)
        XCTAssertEqual(observedHorizon[3], yearHorizon)
    }

    func testSI08LifeShapeFieldItemsExposeCapacityPressureAndNoMutationBoundary() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "shape-tight-1", title: "Tight one"),
            makeWeekVisibleGoal(id: "shape-tight-2", title: "Tight two"),
            makeWeekVisibleGoal(id: "shape-tight-3", title: "Tight three")
        ])
        let dashboard = try await RepositoryBackedTimeService(repositories: repositories).loadTimeDashboard(now: fixedDate)

        let items = dashboard.lifeSuite.shapes.map(TimeLifeShapeFieldItem.init(shape:))
        let weekItem = try XCTUnwrap(items.first { $0.id == TimeLifeSuiteShapeKind.week.rawValue })

        XCTAssertEqual(items.map(\.accessibilityIdentifier), [
            "time.life-shape-field.day_shape",
            "time.life-shape-field.week_shape",
            "time.life-shape-field.life_shape"
        ])
        XCTAssertGreaterThan(weekItem.pressureLevel, 0.45)
        XCTAssertTrue(weekItem.capacityLabel.localizedCaseInsensitiveContains("pressure"))
        XCTAssertTrue(weekItem.recoveryLabel.localizedCaseInsensitiveContains("lighten"))
        XCTAssertTrue(weekItem.accessibilityHint.localizedCaseInsensitiveContains("LifeShape Field contour"))
        XCTAssertTrue(weekItem.accessibilityHint.localizedCaseInsensitiveContains("without changing"))
        XCTAssertFalse(items.map(\.summary).joined(separator: " ").localizedCaseInsensitiveContains("calendar grid"))
    }

    func testFCP14LifeShapeFieldItemsExposeContourPocketFieldAndRidgePrimitives() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "contour-tight-1", title: "Contour one"),
            makeWeekVisibleGoal(id: "contour-tight-2", title: "Contour two"),
            makeWeekVisibleGoal(id: "contour-tight-3", title: "Contour three")
        ])
        let dashboard = try await RepositoryBackedTimeService(repositories: repositories).loadTimeDashboard(now: fixedDate)
        let items = dashboard.lifeSuite.shapes.map(TimeLifeShapeFieldItem.init(shape:))
        let combined = items.map(\.accessibilityLabel).joined(separator: " ")

        XCTAssertEqual(items.count, 3)
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Capacity contour"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Protected pocket"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Pressure field"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Recovery pocket"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Milestone ridge"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Commitment load contour"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("bar chart"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("calendar grid"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("event grid"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("fake precision"))
    }

    func testLifeShapeDrillDownExplainsLongRangeShapeWithoutCalendarClone() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "life-shape-1", title: "Life shape one"),
            makeWeekVisibleGoal(id: "life-shape-2", title: "Life shape two"),
            makeWeekVisibleGoal(id: "life-shape-3", title: "Life shape three")
        ])
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let dashboard = try await RepositoryBackedTimeService(repositories: repositories).loadTimeDashboard(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let drillDown = dashboard.lifeSuite.drillDown

        XCTAssertEqual(drillDown.title, "LifeShape Field detail")
        XCTAssertTrue(drillDown.subtitle.contains("rhythm"))
        XCTAssertTrue(drillDown.rhythmLabel.contains("Rhythm"))
        XCTAssertTrue(drillDown.pressureWeeksLabel.contains("Pressure weeks"))
        XCTAssertTrue(drillDown.milestoneLabel.contains("Milestones"))
        XCTAssertTrue(drillDown.protectedTimeLabel.contains("Protected time"))
        XCTAssertTrue(drillDown.freeTimeLabel.contains("Free-time bands"))
        XCTAssertTrue(drillDown.recoverySpaceLabel.contains("Recovery space"))
        XCTAssertTrue(drillDown.commitmentLoadLabel.contains("Commitment load"))
        XCTAssertEqual(drillDown.items.map(\.id), [
            "life-areas",
            "pressure-weeks",
            "milestones",
            "protected-time",
            "free-time",
            "commitment-load"
        ])
        XCTAssertTrue(drillDown.items.contains(where: { $0.title == "Life areas" }))
        XCTAssertTrue(drillDown.accessibilityValue.contains("LifeShape Field detail"))

        let copy = [
            drillDown.subtitle,
            drillDown.rhythmLabel,
            drillDown.pressureWeeksLabel,
            drillDown.milestoneLabel,
            drillDown.protectedTimeLabel,
            drillDown.freeTimeLabel,
            drillDown.recoverySpaceLabel,
            drillDown.commitmentLoadLabel
        ].joined(separator: " ").lowercased()

        XCTAssertFalse(copy.contains("calendar grid"))
        XCTAssertFalse(copy.contains("schedule grid"))
        XCTAssertFalse(copy.contains("overdue"))
        XCTAssertFalse(copy.contains("failed"))
        XCTAssertFalse(copy.contains("score"))
        XCTAssertFalse(copy.contains("confidence"))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testF11DayAndWeekShapeExposeVisibleFactsWithoutReplanning() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Place dentist follow-up", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let shapes = Dictionary(uniqueKeysWithValues: dashboard.lifeSuite.shapes.map { ($0.kind, $0) })

        XCTAssertEqual(shapes[.day]?.title, "Day Shape")
        XCTAssertEqual(shapes[.day]?.boundaryLabel, "No silent replanning")
        XCTAssertTrue(shapes[.day]?.facts.contains(where: { $0.localizedCaseInsensitiveContains("planned block") }) == true)
        XCTAssertEqual(shapes[.week]?.title, "Week Shape")
        XCTAssertEqual(shapes[.week]?.boundaryLabel, "Suggestions require confirmation")
        XCTAssertTrue(shapes[.week]?.facts.contains(where: { $0.contains("pressured day") }) == true)
        XCTAssertTrue(shapes[.week]?.facts.contains("1 capture needs a place.") == true)
        XCTAssertFalse(dashboard.lifeSuite.shapes.flatMap(\.facts).joined(separator: " ").localizedCaseInsensitiveContains("automatically"))
    }

    func testBlockedDraftsAndOpenCapturesSurfaceRealityPressureTruthfully() async throws {
        let repositories = try await makeRepositories()
        let intake = GoalEngineIntakeService()
        let draftBuild = intake.buildGoalDraft(from: "I want to do something", referenceNow: GoalEngineFixtures.fixedNow)
        let persistedDraft = PersistedGoalDraft(
            id: "draft-plan-pressure",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            draft: draftBuild.draft,
            classification: nil,
            clarification: nil,
            stagedPlan: nil,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: nil,
            latestResultKind: .clarificationRequired
        )
        try await repositories.drafts.saveDrafts([persistedDraft])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Clarify the weekly commitment", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.believability.label, "Needs clarity")
        XCTAssertEqual(dashboard.believability.visualState, .warning)
        XCTAssertTrue(dashboard.hero.pressureSummary.contains("captures"))
        XCTAssertTrue(dashboard.hero.trustWhisper.contains("Clarify"))
        XCTAssertEqual(dashboard.primaryAction.kind, .shapeWeek)
    }

    func testHabitLikeGoalsRemainRepresentedUnderTimeSupportLoops() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.secondaryDestinations.map(\.id), ["plan-habits", "plan-captures", "plan-weekly-review"])
        XCTAssertTrue(dashboard.secondaryDestinations.contains(where: { $0.id == "plan-habits" && $0.valueLabel != "0" }))
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testD16RitualRouteIsTimeOwnedAndDoesNotRestoreStandaloneHabitsCopy() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let ritualDestination = try XCTUnwrap(dashboard.secondaryDestinations.first(where: { $0.timeRoute == .habits }))
        let ritualLane = try XCTUnwrap(dashboard.resilience.lanes.first(where: { $0.timeRoute == .habits }))
        let timeCopy = [
            ritualDestination.title,
            ritualDestination.detail,
            ritualLane.title,
            ritualLane.detail,
            ritualLane.recommendation,
            dashboard.resilience.focusProtection
        ].joined(separator: " ")

        XCTAssertEqual(ritualDestination.title, "Rituals")
        XCTAssertEqual(ritualLane.title, "Rituals")
        XCTAssertTrue(timeCopy.localizedCaseInsensitiveContains("ritual"))
        XCTAssertFalse(timeCopy.localizedCaseInsensitiveContains("habit"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Habits"))
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testWeeklyReviewDashboardBridgesCarryForwardAndSupportRoutes() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Review the carry-forward tradeoff", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadWeeklyReviewDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.hero.eyebrow, "Weekly Review")
        XCTAssertFalse(dashboard.carryForwardItems.isEmpty)
        XCTAssertTrue(dashboard.captureSummary.contains("capture"))
        XCTAssertEqual(dashboard.returnActionTitle, "Return to Time")
    }

    func testPK21TimeFeatureServiceMirrorsTimeLifeShapeDashboardSemantics() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "pk21-life-1", title: "Life one"),
            makeWeekVisibleGoal(id: "pk21-life-2", title: "Life two"),
            makeWeekVisibleGoal(id: "pk21-life-3", title: "Life three")
        ])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Prepare review packet", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()

        let baseline = try await service.loadTimeDashboard(now: fixedDate)
        let extracted = try await TimeFeatureService().makeDashboard(
            from: service,
            now: fixedDate,
            permission: .unavailable,
            snapshot: snapshot
        )

        XCTAssertEqual(baseline.hero.title, extracted.hero.title)
        XCTAssertEqual(baseline.hero.subtitle, extracted.hero.subtitle)
        XCTAssertEqual(baseline.lifeSuite.title, extracted.lifeSuite.title)
        XCTAssertEqual(baseline.lifeSuite.subtitle, extracted.lifeSuite.subtitle)
        XCTAssertEqual(baseline.lifeSuite.shapes.map(\.title), extracted.lifeSuite.shapes.map(\.title))
        XCTAssertEqual(
            baseline.lifeSuite.shapes.map(\.boundaryLabel),
            extracted.lifeSuite.shapes.map(\.boundaryLabel)
        )
        XCTAssertEqual(baseline.treaty.title, extracted.treaty.title)
        XCTAssertEqual(baseline.capacityEnvelope.label, extracted.capacityEnvelope.label)
    }

    func testPK21TimeFeatureServiceMirrorsRecoveryReflowSemanticsWithoutMutation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "pk21-reflow-\($0)", title: "PK21 overloaded \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()

        let baseline = try await service.loadTimeDashboard(now: fixedDate)
        let extracted = try await TimeFeatureService().makeDashboard(
            from: service,
            now: fixedDate,
            permission: .denied,
            snapshot: snapshot
        )
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()

        XCTAssertEqual(baseline.realityReflow.reasonKind, extracted.realityReflow.reasonKind)
        XCTAssertEqual(baseline.realityReflow.suggestions.map(\.kind), extracted.realityReflow.suggestions.map(\.kind))
        XCTAssertEqual(baseline.realityReflow.title, extracted.realityReflow.title)
        XCTAssertEqual(extracted.calendarAwareness.status, .denied)
        XCTAssertTrue(extracted.recoveryMaturity.calendarBoundary.contains("Manual planning works") || extracted.recoveryMaturity.calendarBoundary.contains("does not write calendar changes silently"))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testPK21TimeFeatureServicePreservesWeeklyReviewOutputAndNoCalendarCloneLanguage() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "pk21-weekly", title: "Weekly review pressure")
        ])
        let service = RepositoryBackedTimeService(repositories: repositories)
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()

        let baseline = try await service.loadWeeklyReviewDashboard(now: fixedDate)
        let extracted = try await TimeFeatureService().makeWeeklyReviewDashboard(from: service, now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()

        XCTAssertEqual(baseline.hero.eyebrow, extracted.hero.eyebrow)
        XCTAssertEqual(baseline.hero.title, extracted.hero.title)
        XCTAssertEqual(baseline.carryForwardItems.map(\.title), extracted.carryForwardItems.map(\.title))
        XCTAssertEqual(baseline.returnActionTitle, extracted.returnActionTitle)

        let snapshotCopy = [
            baseline.hero.subtitle,
            baseline.summaryDetail,
            baseline.summaryTitle,
            baseline.hero.continuityLabel
        ]
        let copiedText = snapshotCopy.joined(separator: " ").lowercased()
        XCTAssertFalse(copiedText.contains("calendar grid"))
        XCTAssertFalse(copiedText.contains("calendar clone"))
        XCTAssertFalse(copiedText.contains("score"))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testPK21TimeFeatureServiceMakesCalendarAwareDashboardFromInjectedPermission() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal(id: "pk21-calendar", title: "Calendar-boundary check")])
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()
        let extracted = try await TimeFeatureService().makeDashboard(
            from: service,
            now: fixedDate,
            permission: .notDetermined,
            openWindowCount: 2,
            snapshot: snapshot
        )

        XCTAssertEqual(extracted.calendarAwareness.status, .baseline)
        XCTAssertEqual(extracted.calendarBoundary.permissionLabel, "Optional")
        XCTAssertTrue(extracted.calendarBoundary.detail.lowercased().contains("open window"))
        XCTAssertEqual(extracted.calendarBoundary.canRequestCalendarRead, true)
        XCTAssertFalse(extracted.calendarBoundary.writeBoundary.contains("sync"))
        XCTAssertTrue(extracted.calendarBoundary.writeBoundary.contains("silently writes") == false)
    }

    func testPK21TimeFeatureServiceCanReuseInjectedSnapshotWithoutReloadingSource() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal(id: "pk21-snapshot", title: "Snapshot reuse")])
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()
        let source = PK21TrackingTimeFeatureProjectionSource(service: service)
        let timeService = TimeFeatureService()

        _ = try await timeService.makeDashboard(
            from: source,
            now: fixedDate,
            permission: .unavailable,
            snapshot: snapshot
        )

        XCTAssertEqual(source.loadSnapshotCount, 0)

        _ = try await timeService.makeDashboard(
            from: source,
            now: fixedDate,
            permission: .unavailable
        )

        XCTAssertEqual(source.loadSnapshotCount, 1)
    }

    func testDemoTimeProtectActionRemainsActionable() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let protectAction = try XCTUnwrap(dashboard.shapingActions.first(where: { $0.kind == .protect }))

        XCTAssertTrue(protectAction.goalTarget != nil || protectAction.timeRoute != nil)
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testTimeCalendarAwareActionIsTimeOwnedAndWritesPrivacyLedger() async throws {
        let ledger = InMemoryEventLedgerRepository()
        let repositories = try await makeRepositories(eventLedger: ledger)
        let calendar = RecordingTimeCalendarRealityService()
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: calendar
        )

        let dashboard = try await service.makeTimeCalendarAware(now: fixedDate)
        let events = try await ledger.fetchRecent(limit: 5)

        let requestedActionNames = await calendar.currentRequestedActionNames()
        XCTAssertEqual(requestedActionNames, ["Make Time calendar-aware"])
        XCTAssertEqual(dashboard.calendarAwareness.status, .calendarAware)
        XCTAssertEqual(dashboard.calendarAwareness.sourceLabel, "From your calendar")
        XCTAssertEqual(dashboard.calendarBoundary.sourceLabel, "From your calendar")
        XCTAssertTrue(dashboard.calendarAwareness.detail.contains("open window"))
        XCTAssertEqual(events.first?.kind, .calendarContextObserved)
        XCTAssertEqual(events.first?.privacy, .calendarDerived)
        XCTAssertEqual(events.first?.source, .plan)
    }

    func testCalendarDeniedProducesManualFallbackWithoutFakeClaims() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .denied)
        )

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.calendarAwareness.status, .denied)
        XCTAssertFalse(dashboard.calendarBoundary.canRequestCalendarRead)
        XCTAssertEqual(dashboard.calendarAwareness.sourceLabel, "Created in Ambitions")
        XCTAssertTrue(dashboard.calendarBoundary.manualFallback.contains("Manual planning still works"))
        XCTAssertTrue(dashboard.calendarBoundary.writeBoundary.contains("never silently writes"))
        XCTAssertFalse(dashboard.calendarBoundary.detail.lowercased().contains("sync"))
        XCTAssertFalse(dashboard.calendarBoundary.detail.lowercased().contains("export"))
    }

    func testTimeLifecycleRailDistinguishesCarriedAndOutsideGoalStates() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-active", title: "Active carried goal"),
            makeWeekVisibleGoal(id: "goal-future", title: "Future goal", state: .draft),
            makeWeekVisibleGoal(id: "goal-completed", title: "Completed goal", state: .completed),
            makeWeekVisibleGoal(id: "goal-cancelled", title: "Cancelled goal", state: .archived, stepState: .cancelled),
            makeWeekVisibleGoal(id: "goal-parked", title: "Parked goal", state: .paused),
            makeWeekVisibleGoal(id: "goal-blocked", title: "Blocked goal", stepState: .blocked),
            makeWeekVisibleGoal(id: "goal-waiting", title: "Waiting goal", mode: .delegatedSupport, relationshipKind: .delegated)
        ])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let counts = Dictionary(uniqueKeysWithValues: dashboard.lifecycleRail.segments.map { ($0.lifecycleState, $0.count) })

        XCTAssertGreaterThanOrEqual(counts[.active, default: 0], 1)
        XCTAssertGreaterThanOrEqual(counts[.future, default: 0], 1)
        XCTAssertEqual(counts[.completed], 1)
        XCTAssertEqual(counts[.cancelledDropped], 1)
        XCTAssertEqual(counts[.parked], 1)
        XCTAssertEqual(counts[.blocked], 1)
        XCTAssertEqual(counts[.waiting], 1)
        XCTAssertEqual(dashboard.lifecycleRail.segments.map(\.lifecycleState), [.previous, .active, .future, .waiting, .blocked, .parked, .protected, .completed, .cancelledDropped])
    }

    func testTimeTimelineIncludesActiveFutureAndPreviousWithoutFakeCertainty() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-active", title: "Active carried goal"),
            makeWeekVisibleGoal(id: "goal-future", title: "Future goal", state: .draft),
            makeWeekVisibleGoal(id: "goal-previous", title: "Previous goal", state: .archived, stepState: .completed)
        ])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertTrue(dashboard.timelineStrip.items.contains(where: { $0.kind == .active }))
        XCTAssertTrue(dashboard.timelineStrip.items.contains(where: { $0.kind == .future }))
        XCTAssertTrue(dashboard.timelineStrip.items.contains(where: { $0.kind == .previous }))
        XCTAssertEqual(dashboard.timelineStrip.title, "Rich Timeline")
        XCTAssertTrue(dashboard.timelineStrip.items.map(\.sourceLabel).contains("Based on your plan"))
        XCTAssertTrue(dashboard.timelineStrip.items.map(\.sourceLabel).contains("Created in Ambitions"))
        XCTAssertFalse(dashboard.timelineStrip.items.map(\.detail).joined(separator: " ").contains("%"))
    }

    func testCapacityEnvelopeUsesQualitativeStates() async throws {
        let lightRepositories = try await makeRepositories()
        let lightDashboard = try await RepositoryBackedTimeService(repositories: lightRepositories).loadTimeDashboard(now: fixedDate)
        XCTAssertEqual(lightDashboard.capacityEnvelope.label, "Light")

        let steadyRepositories = try await makeRepositories()
        try await steadyRepositories.goals.saveGoals([makeWeekVisibleGoal()])
        let steadyDashboard = try await RepositoryBackedTimeService(repositories: steadyRepositories).loadTimeDashboard(now: fixedDate)
        XCTAssertTrue(["Steady", "Tight"].contains(steadyDashboard.capacityEnvelope.label))

        let tightRepositories = try await makeRepositories()
        try await tightRepositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "tight-1", title: "Tight one"),
            makeWeekVisibleGoal(id: "tight-2", title: "Tight two"),
            makeWeekVisibleGoal(id: "tight-3", title: "Tight three")
        ])
        let tightDashboard = try await RepositoryBackedTimeService(repositories: tightRepositories).loadTimeDashboard(now: fixedDate)
        XCTAssertTrue(["Tight", "Overloaded"].contains(tightDashboard.capacityEnvelope.label))

        let overloadedRepositories = try await makeRepositories()
        try await overloadedRepositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "overloaded-\($0)", title: "Overloaded \($0)") })
        let overloadedDashboard = try await RepositoryBackedTimeService(repositories: overloadedRepositories).loadTimeDashboard(now: fixedDate)
        XCTAssertEqual(overloadedDashboard.capacityEnvelope.label, "Overloaded")
    }

    func testPressureRecoveryReviewExplainsOverloadWithoutShameOrMutation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "pressure-\($0)", title: "Pressure \($0)") })
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let review = dashboard.pressureRecoveryReview

        XCTAssertEqual(review.title, "Pressure and recovery review")
        XCTAssertTrue(review.pressureFieldLabel.contains("Pressure field"))
        XCTAssertTrue(review.recoveryLoopLabel.contains("Recovery loop"))
        XCTAssertTrue(review.weekPressureLabel.contains("need relief"))
        XCTAssertTrue(review.overloadedDayLabel.contains("reduce one ask"))
        XCTAssertTrue(review.recoverySpaceLabel.contains("Recovery space"))
        XCTAssertTrue(review.smallerStepAnchorLabel.contains("Smaller step anchor"))
        XCTAssertTrue(review.protectedTimeConflictLabel.contains("Protected time conflict"))
        XCTAssertTrue(review.lateStartAdjustmentLabel.contains("Late-start adjustment"))
        XCTAssertTrue(review.recoveryDayReviewLabel.contains("Still counts"))
        XCTAssertTrue(review.recoveryReceiptPreviewLabel.contains("Recovery receipt preview"))
        XCTAssertTrue(review.capacityReviewLabel.contains("qualitative"))
        XCTAssertTrue(review.signals.contains(where: { $0.id == "week-pressure" && $0.boundaryLabel == "Explain before changing" }))
        XCTAssertTrue(review.signals.contains(where: { $0.id == "protected-time" && $0.boundaryLabel == "No silent rescheduling" }))
        XCTAssertTrue(review.accessibilityValue.contains("Capacity review"))

        let riskyCopy = [
            review.title,
            review.detail,
            review.pressureFieldLabel,
            review.recoveryLoopLabel,
            review.weekPressureLabel,
            review.overloadedDayLabel,
            review.recoverySpaceLabel,
            review.smallerStepAnchorLabel,
            review.protectedTimeConflictLabel,
            review.lateStartAdjustmentLabel,
            review.recoveryDayReviewLabel,
            review.recoveryReceiptPreviewLabel,
            review.capacityReviewLabel
        ].joined(separator: " ").lowercased()

        XCTAssertFalse(riskyCopy.contains("overdue"))
        XCTAssertFalse(riskyCopy.contains("failed"))
        XCTAssertFalse(riskyCopy.contains("punishment"))
        XCTAssertFalse(riskyCopy.contains("productivity loss"))
        XCTAssertFalse(riskyCopy.contains("score"))
        XCTAssertFalse(riskyCopy.contains("confidence"))
        XCTAssertFalse(riskyCopy.contains("%"))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testDecisionDebtConflictCourtAndRecoveryAreSuggestionOnly() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-proof-thin", title: "Proof thin goal"),
            makeWeekVisibleGoal(id: "goal-blocked", title: "Blocked goal", stepState: .blocked)
        ])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Waiting on partner response", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertFalse(dashboard.decisionDebt.items.isEmpty)
        XCTAssertFalse(dashboard.conflictCourt.conflicts.isEmpty)
        XCTAssertFalse(dashboard.recoveryEntry.suggestions.isEmpty)
        XCTAssertTrue(dashboard.recoveryEntry.boundary.contains("No schedule changes"))
        XCTAssertTrue(dashboard.conflictCourt.subtitle.contains("not alarms") || dashboard.conflictCourt.conflicts.isEmpty)
    }

    func testProtectedTimeConflictDetectionAvoidsRankingLanguage() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(
                id: "goal-protected-alert-1",
                title: "Protected deep work",
                stepState: .blocked,
                targetBy: "2026-04-18T18:00:00Z",
                dueAt: nil
            ),
            makeWeekVisibleGoal(
                id: "goal-protected-alert-2",
                title: "Protected planning",
                targetBy: "2026-04-19T10:00:00Z",
                dueAt: nil
            ),
            makeWeekVisibleGoal()
        ])

        let dashboard = try await RepositoryBackedTimeService(repositories: repositories).loadTimeDashboard(now: fixedDate)
        let protectedConflict = try XCTUnwrap(dashboard.conflictCourt.conflicts.first(where: { $0.id == "conflict-protected-goals" }))
        let copy = [
            protectedConflict.title,
            protectedConflict.detail,
            dashboard.pressureRecoveryReview.protectedTimeConflictLabel,
            dashboard.pressureRecoveryReview.overloadedDayLabel
        ].joined(separator: " ").lowercased()

        XCTAssertTrue(protectedConflict.title == "Important goals are competing")
        XCTAssertTrue(protectedConflict.detail.contains("important goals are asking"))
        XCTAssertFalse(copy.contains("most important"))
        XCTAssertFalse(copy.contains("ranking"))
        XCTAssertTrue(dashboard.conflictCourt.subtitle.contains("negotiation") || dashboard.conflictCourt.subtitle.contains("not alarms"))
        XCTAssertTrue(dashboard.pressureRecoveryReview.signals.contains(where: { $0.id == "protected-time" && $0.statusLabel == "Review" }))
        XCTAssertTrue(dashboard.pressureRecoveryReview.signals.first(where: { $0.id == "protected-time" })?.detail.isEmpty == false)
    }

    func testRealityReflowNoReflowNeededProducesCalmStillBelievableState() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.realityReflow.reasonKind, .stillBelievable)
        XCTAssertEqual(dashboard.realityReflow.title, "Plan is still believable")
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .keepPlanUnchanged }))
        XCTAssertTrue(dashboard.realityReflow.noChangeCopy.contains("Nothing changed"))
    }

    func testOverloadedTimeProducesRealityReflowRecommendationWithoutMutation() async throws {
        let repositories = try await makeRepositories()
        let goals = (0..<6).map { makeWeekVisibleGoal(id: "reflow-overload-\($0)", title: "Reflow overload \($0)") }
        try await repositories.goals.saveGoals(goals)
        let before = try await repositories.goals.listGoals()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let after = try await repositories.goals.listGoals()

        XCTAssertEqual(dashboard.realityReflow.reasonKind, .overloadedPlan)
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .protectOneItem }))
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .shrinkAction }))
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .moveLocalActionLater }))
        XCTAssertEqual(before, after)
    }

    func testNoRecoveryMarginSuggestsSmallAdjustmentsBeforeBroadChanges() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "margin-\($0)", title: "Margin \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let orderedKinds = dashboard.recoveryGradient.options.map(\.kind)

        XCTAssertEqual(Array(orderedKinds.prefix(4)), [.protectOneItem, .shrinkAction, .splitAction, .moveLocalActionLater])
        XCTAssertTrue(dashboard.realityReflow.suggestions.first?.boundary.confirmationRequirement == .notRequired)
        XCTAssertFalse(dashboard.realityReflow.suggestions.first?.detail.lowercased().contains("reschedule") ?? true)
    }

    func testBlockedAndWaitingTimeSurfacesAppropriateRealityReasons() async throws {
        let blockedRepositories = try await makeRepositories()
        try await blockedRepositories.goals.saveGoals([makeWeekVisibleGoal(id: "blocked-reflow", title: "Blocked reflow", stepState: .blocked)])
        let blockedDashboard = try await RepositoryBackedTimeService(repositories: blockedRepositories).loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(blockedDashboard.realityReflow.reasonKind, .blockedGoal)
        XCTAssertTrue(blockedDashboard.realityReflow.suggestions.contains(where: { $0.kind == .markWaiting }))

        let waitingRepositories = try await makeRepositories()
        try await waitingRepositories.captures.saveCaptures([makeWaitingCapture()])
        let waitingDashboard = try await RepositoryBackedTimeService(repositories: waitingRepositories).loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(waitingDashboard.realityReflow.reasonKind, .waitingOnPersonOrResource)
        XCTAssertTrue(waitingDashboard.realityReflow.suggestions.contains(where: { $0.kind == .markWaiting }))
    }

    func testCalendarDeniedStillProducesManualRecoveryOptions() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .denied)
        )

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.calendarAwareness.status, .denied)
        XCTAssertTrue(dashboard.calendarBoundary.manualFallback.contains("Manual planning still works"))
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .protectOneItem || $0.kind == .keepPlanUnchanged }))
        XCTAssertTrue(dashboard.reflowReceiptPreview.whatWouldNotChange.contains(where: { $0.contains("Calendar blocks are not written") }))
    }

    func testBroadReflowAndCalendarImpactingChangesRequireConfirmation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "confirm-\($0)", title: "Confirm \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        let moveLater = try XCTUnwrap(dashboard.realityReflow.suggestions.first(where: { $0.kind == .moveLocalActionLater }))
        let drop = try XCTUnwrap(dashboard.realityReflow.suggestions.first(where: { $0.kind == .dropOptionalWork }))
        let confirm = try XCTUnwrap(dashboard.realityReflow.suggestions.first(where: { $0.kind == .askForConfirmation }))

        XCTAssertEqual(moveLater.boundary.confirmationRequirement, .requiredForBroadReflow)
        XCTAssertEqual(drop.boundary.confirmationRequirement, .requiredForDestructiveChange)
        XCTAssertNotEqual(confirm.boundary.confirmationRequirement, .notRequired)
        XCTAssertTrue(dashboard.calendarBoundary.writeBoundary.contains("never silently writes"))
    }

    func testReceiptPreviewIncludesWouldChangeAndWouldNotChange() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "receipt-\($0)", title: "Receipt \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertFalse(dashboard.reflowReceiptPreview.whatChanged.isEmpty)
        XCTAssertFalse(dashboard.reflowReceiptPreview.whatWouldNotChange.isEmpty)
        XCTAssertTrue(dashboard.reflowReceiptPreview.whatWouldNotChange.contains(where: { $0.contains("not silently rescheduled") }))
        XCTAssertTrue(dashboard.reflowReceiptPreview.confirmationRequired.contains("Safe local") || dashboard.reflowReceiptPreview.confirmationRequired.contains("confirmation"))
        XCTAssertFalse(dashboard.reflowReceiptPreview.safeFailureFallback.isEmpty)
    }

    func testReflowReceiptShowsMomentumReflowContract() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "momentum-\($0)", title: "Momentum \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let contract = dashboard.reflowReceiptPreview.momentumReflowContract

        XCTAssertFalse(contract.isEmpty)
        XCTAssertEqual(contract.count, 5)
        XCTAssertTrue(contract[0].contains("Original block link"))
        XCTAssertTrue(contract[1].contains("Approved duration"))
        XCTAssertTrue(contract[2].contains("Displaced step pressure"))
        XCTAssertTrue(contract[3].contains("Destination step"))
        XCTAssertTrue(contract[4].contains("LifeShape impact"))
    }

    func testSaveTheDayReturnsProtectedAdjustmentAndExplanation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "save-\($0)", title: "Save \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)

        XCTAssertFalse(dashboard.saveTheDay.protectedItem.isEmpty)
        XCTAssertFalse(dashboard.saveTheDay.adjustment.isEmpty)
        XCTAssertFalse(dashboard.saveTheDay.recoveryExplanation.isEmpty)
        XCTAssertTrue(dashboard.saveTheDay.boundary.contains("No silent rescheduling"))
    }

    func testM11RecoveryMaturityKeepsOverloadedDaysConfirmedPrivateAndReceipted() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "m11-\($0)", title: "M11 \($0)") })
        try await repositories.captures.saveCaptures([
            makeWaitingCapture(),
            makeCommitmentCapture()
        ])
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()

        XCTAssertEqual(dashboard.recoveryMaturity.title, "Recovery maturity")
        XCTAssertEqual(dashboard.recoveryMaturity.planFitLabel, "Needs relief")
        XCTAssertTrue(dashboard.recoveryMaturity.confirmationBoundary.contains("require confirmation"))
        XCTAssertTrue(dashboard.recoveryMaturity.calendarBoundary.contains("Manual planning works") || dashboard.recoveryMaturity.calendarBoundary.contains("does not write calendar changes silently"))
        XCTAssertTrue(dashboard.recoveryMaturity.socialBoundary.contains("private"))
        XCTAssertTrue(dashboard.recoveryMaturity.receiptBoundary.contains("receipt preview"))
        XCTAssertTrue(dashboard.recoveryMaturity.signals.contains(where: { $0.id == "waiting-commitments" && $0.statusLabel == "Visible" && $0.boundaryLabel == "No silent routing" }))
        XCTAssertTrue(dashboard.recoveryMaturity.signals.contains(where: { $0.id == "social-load" && $0.boundaryLabel == "No inference without you" }))
        XCTAssertTrue(dashboard.recoveryMaturity.signals.contains(where: { $0.id == "receipt" && $0.boundaryLabel.contains("Undo") }))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testF12ReflowDecisionProjectsUserOwnedOptionsWithoutSilentAutomation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "f12-\($0)", title: "F12 \($0)") })
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()

        XCTAssertEqual(dashboard.reflowDecision.title, "Reflow decisions")
        XCTAssertEqual(dashboard.reflowDecision.sourceLabel, "Based on Time")
        XCTAssertEqual(dashboard.reflowDecision.trustLabel, "No silent changes")
        XCTAssertTrue(dashboard.reflowDecision.options.contains(where: { $0.kind == .protectTime }))
        XCTAssertTrue(dashboard.reflowDecision.options.contains(where: { $0.kind == .makeSmaller }))
        XCTAssertTrue(dashboard.reflowDecision.options.contains(where: { $0.kind == .moveLater }))
        XCTAssertTrue(dashboard.reflowDecision.options.contains(where: { $0.kind == .reviewPlan }))
        XCTAssertTrue(dashboard.reflowDecision.options.allSatisfy { $0.trustLabel == "No silent changes" })
        XCTAssertTrue(dashboard.reflowDecision.receiptLabel.contains("No silent rescheduling"))
        XCTAssertTrue(dashboard.reflowDecision.options.allSatisfy { option in
            option.whatChangedLabel.hasPrefix("What changed:")
                && option.whyChangedLabel.hasPrefix("Why:")
                && option.impactedStepsLabel.hasPrefix("Impacted steps:")
                && option.capacityImpactLabel.hasPrefix("Capacity impact:")
                && option.protectedTimeImpactLabel.hasPrefix("Protected time impact:")
        })
        XCTAssertTrue(dashboard.reflowDecision.options.allSatisfy { option in
            option.actions.map(\.kind) == [.accept, .edit, .decline]
        })
        XCTAssertTrue(dashboard.reflowDecision.options.allSatisfy { option in
            option.accessibilityValue.contains("What changed:")
                && option.accessibilityValue.contains("Capacity impact:")
                && option.accessibilityValue.contains("Protected time impact:")
                && option.accessibilityValue.contains("Accept, Edit, Decline")
        })
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testFCP15ReflowDecisionFoldShowsBeforeAfterReceiptAndUserChoice() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "fcp15-\($0)", title: "FCP15 \($0)") })
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()

        let dashboard = try await RepositoryBackedTimeService(repositories: repositories).loadTimeDashboard(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let decision = dashboard.reflowDecision
        let protectedOption = try XCTUnwrap(decision.options.first { $0.kind == .protectTime })
        let preview = protectedOption.beforeAfterPreview

        XCTAssertEqual(preview.title, "Before / after")
        XCTAssertTrue(preview.beforeLabel.hasPrefix("Before:"))
        XCTAssertTrue(preview.afterLabel.hasPrefix("After:"))
        XCTAssertTrue(preview.shapeChangeLabel.hasPrefix("Shape change:"))
        XCTAssertTrue(preview.receiptPreviewLabel.hasPrefix("Receipt preview:"))
        XCTAssertTrue(preview.accessibilityValue.contains("Before / after"))
        XCTAssertTrue(protectedOption.accessibilityValue.contains("Before / after"))
        XCTAssertEqual(protectedOption.actions.map(\.kind), [.accept, .edit, .decline])
        XCTAssertTrue(protectedOption.protectedTimeImpactLabel.contains("Protected time impact:"))
        XCTAssertFalse(protectedOption.accessibilityValue.localizedCaseInsensitiveContains("optimized for you"))
        XCTAssertFalse(protectedOption.accessibilityValue.localizedCaseInsensitiveContains("hidden mutation"))
        XCTAssertFalse(protectedOption.accessibilityValue.localizedCaseInsensitiveContains("silent reflow"))
        XCTAssertFalse(protectedOption.accessibilityValue.localizedCaseInsensitiveContains("calendar write"))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testReflowCopyAvoidsFakeFutureSystemClaims() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "copy-\($0)", title: "Copy \($0)") })
        let dashboard = try await RepositoryBackedTimeService(repositories: repositories).loadTimeDashboard(now: fixedDate)

        let copy = [
            dashboard.realityReflow.title,
            dashboard.realityReflow.detail,
            dashboard.reflowDecision.title,
            dashboard.reflowDecision.subtitle,
            dashboard.reflowDecision.sourceLabel,
            dashboard.reflowDecision.trustLabel,
            dashboard.reflowDecision.receiptLabel,
            dashboard.saveTheDay.boundary,
            dashboard.recoveryMaturity.confirmationBoundary,
            dashboard.recoveryMaturity.calendarBoundary,
            dashboard.reflowReceiptPreview.detail,
            dashboard.reflowReceiptPreview.safeFailureFallback
        ].joined(separator: " ").lowercased()

        XCTAssertFalse(copy.contains("automatically"))
        XCTAssertFalse(copy.contains("will sync"))
        XCTAssertFalse(copy.contains("exported"))
        XCTAssertFalse(copy.contains("calendar written"))
    }

    func testTopLevelIARemainsCanonicalFiveTabShell() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Captures"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
    }

    func testD15TimeScreenContractSnapshotSatisfiesImplementationGate() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let dashboard = try await service.loadTimeDashboard(now: fixedDate)
        let contract = ScreenContractRegistry.contract(for: .plan)
        let snapshot = dashboard.screenContractSnapshot()

        XCTAssertEqual(snapshot.screenID, .plan)
        XCTAssertEqual(snapshot.topLevelTabTitles, ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertTrue(snapshot.firstScreenContent.contains("LifeShape Field"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("Open time"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("Protected time"))
        XCTAssertTrue(snapshot.copySamples.contains("LifeShape Field shows what the week can hold."))
        XCTAssertTrue(snapshot.copySamples.contains("Based on Time"))
        let issues = ScreenContractValidator.validate(snapshot: snapshot, against: contract)
        XCTAssertTrue(issues.isEmpty, "\(issues)")
    }
}

private extension TimeFeatureServiceTests {
    var fixedDate: Date {
        ISO8601DateFormatter().date(from: GoalEngineFixtures.fixedNow) ?? Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories(eventLedger: (any EventLedgerRepository)? = nil) async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: eventLedger ?? InMemoryEventLedgerRepository(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeWeekVisibleGoal(
        id: String = "goal-plan-visible",
        title: String = "Submit conference proposal",
        state: GoalLifecycleState = .active,
        mode: GoalMode = .achievement,
        relationshipKind: GoalRelationshipKind = .independent,
        stepState: StepLifecycleState = .planned,
        targetBy: String? = nil,
        dueAt: String? = "2026-04-17T12:00:00Z"
    ) -> Goal {
        let actor = GoalActor(
            actorID: "self",
            displayName: "You",
            ownership: .self,
            roleLabel: "Primary owner",
            isPrimary: true
        )
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: targetBy,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .adaptive,
            allowParallelSteps: true,
            maxActiveSteps: 3,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: true,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: nil,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let step = Step(
            id: "step-\(id)",
            sectionID: "section-\(id)",
            title: "Draft and submit the proposal",
            summary: "Finish the visible draft and send it before the deadline.",
            type: .actionUnit,
            state: stepState,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Proposal submitted"],
            actionability: StepActionability(
                action: "Draft and submit the proposal",
                completionDefinition: "The proposal is submitted.",
                evidenceOfCompletion: ["Submission confirmation"],
                fallbackMicroStep: "Open the draft and write the next paragraph.",
                contextRequirements: []
            )
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: GoalEngineFixtures.fixedNow,
            summary: "Conference proposal work is explicitly carried by this week.",
            strategy: strategy,
            sections: [
                PlanSection(
                    id: "section-\(id)",
                    goalID: id,
                    title: "Active",
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
            ),
            evaluation: PlanningEvaluation(
                feasibilityScore: 0.84,
                feasibilityLevel: .comfortable,
                recommendationConfidence: .high,
                pressureLevel: .low,
                fragilityLevel: .low,
                effortPosture: .steady,
                reasons: ["The visible step fits cleanly inside the current week."]
            )
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            state: state,
            title: title,
            summary: nil,
            mode: mode,
            relationshipKind: relationshipKind,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan
        )
    }

    func makeWaitingCapture() -> Capture {
        Capture(
            id: "capture-waiting-reflow",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            rawText: "Waiting on partner response",
            sourceType: .todayQuickCapture,
            status: .waiting,
            linkedGoalID: nil,
            kind: .waitingItem,
            route: .waiting,
            triageStatus: .waiting,
            waitingMetadata: CaptureWaitingMetadata(blockedBy: "Partner response", waitingOn: "Partner")
        )
    }

    func makeCommitmentCapture() -> Capture {
        Capture(
            id: "capture-commitment-reflow",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            rawText: "Send the school form by Friday",
            sourceType: .todayQuickCapture,
            status: .scheduled,
            linkedGoalID: nil,
            kind: .oneTimeCommitment,
            route: .timeSeed,
            triageStatus: .routed,
            commitmentKind: .oneTime
        )
    }
}

private final class PK21TrackingTimeFeatureProjectionSource: TimeFeatureProjectionSource {
    private let service: RepositoryBackedTimeService
    private(set) var loadSnapshotCount = 0

    init(service: RepositoryBackedTimeService) {
        self.service = service
    }

    func loadSnapshot() async throws -> RepositoryBackedTimeService.Snapshot {
        loadSnapshotCount += 1
        return try await service.loadSnapshot()
    }

    func makeDashboard(snapshot: RepositoryBackedTimeService.Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeDashboard {
        service.makeDashboard(snapshot: snapshot, now: now, calendarAwareness: calendarAwareness)
    }

    func makeWeeklyReviewDashboard(snapshot: RepositoryBackedTimeService.Snapshot, now: Date) -> WeeklyReviewDashboard {
        service.makeWeeklyReviewDashboard(snapshot: snapshot, now: now)
    }

    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> TimeCalendarAwarenessState {
        service.makeCalendarAwarenessState(permission: permission, openWindowCount: openWindowCount)
    }
}

private actor RecordingTimeCalendarRealityService: CalendarRealityServicing {
    private(set) var requestedActionNames: [String] = []
    private(set) var requestedHorizon: [DateInterval] = []

    func calendarPermissionState() async -> CalendarPermissionState {
        .notDetermined
    }

    func requestCalendarReadAccessFromPlan(actionName: String) async -> CalendarPermissionState {
        requestedActionNames.append(actionName)
        return .readWrite
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        _ = intent
        return .readWrite
    }

    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow] {
        [
            RealityWindow(
                id: "calendar-busy",
                kind: .calendarDerivedBusy,
                source: .calendarDerived,
                start: range.start.addingTimeInterval(3_600),
                end: range.start.addingTimeInterval(5_400),
                title: "Calendar busy time"
            )
        ]
    }

    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult {
        let permission = await requestCalendarReadAccessFromPlan(actionName: request.userInitiatedPlanAction)
        requestedHorizon.append(request.horizon)
        let busy = await fetchDerivedBusyWindows(for: request.horizon)
        let context = CalendarDerivedContext(
            permissionState: permission,
            observedRangeStart: request.horizon.start,
            observedRangeEnd: request.horizon.end,
            derivedBusyWindowCount: busy.count,
            userInitiatedPlanAction: request.userInitiatedPlanAction,
            explanation: "Plan used derived busy time locally."
        )
        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: request.horizon.start,
                horizon: request.horizon,
                calendarBusyWindows: busy,
                calendarContext: context
            )
        )
        return CalendarRealityReadResult(
            permissionState: permission,
            derivedBusyWindows: busy,
            calendarContext: context,
            openWindowCandidates: snapshot.openWindowCandidates
        )
    }

    func currentRequestedActionNames() -> [String] {
        requestedActionNames
    }

    func currentRequestedHorizon() -> [DateInterval] {
        requestedHorizon
    }
}

private struct FixedPermissionCalendarRealityService: CalendarRealityServicing {
    let permission: CalendarPermissionState

    func calendarPermissionState() async -> CalendarPermissionState {
        permission
    }

    func requestCalendarReadAccessFromPlan(actionName: String) async -> CalendarPermissionState {
        _ = actionName
        return permission
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        _ = intent
        return permission
    }

    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow] {
        _ = range
        return []
    }

    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult {
        CalendarRealityReadResult(
            permissionState: permission,
            derivedBusyWindows: [],
            calendarContext: CalendarDerivedContext(
                permissionState: permission,
                observedRangeStart: request.horizon.start,
                observedRangeEnd: request.horizon.end,
                derivedBusyWindowCount: 0,
                userInitiatedPlanAction: request.userInitiatedPlanAction,
                explanation: "Calendar permission unavailable."
            ),
            openWindowCandidates: []
        )
    }
}
