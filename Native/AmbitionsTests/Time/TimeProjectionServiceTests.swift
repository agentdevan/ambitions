import XCTest
@testable import Ambitions

final class TimeProjectionServiceTests: XCTestCase {
    func testAMB573TimeObjectStagePrimitiveContractReplacesFirstViewportGenericGeometry() throws {
        let contract = TimeObjectStagePrimitiveContract.current
        let fieldSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift"),
            encoding: .utf8
        )
        let canvasSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCanvas.swift"),
            encoding: .utf8
        )
        let lensSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Projection/SurfaceLenses/TimeLens.swift"),
            encoding: .utf8
        )
        let timeScreenSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/Time/TimeSurface.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(contract.primitiveID, "time-object-stage")
        XCTAssertEqual(contract.ownerSurface, "Time")
        XCTAssertEqual(contract.productObject, "LifeShape Field")
        XCTAssertEqual(contract.screenshotIdentifier, "TimeObjectStage")
        XCTAssertTrue(contract.firstViewportAvoidsCalendarCardStackGeometry)
        XCTAssertEqual(contract.sourceTrustLineOrder, ["current date", "now marker", "fixed points", "capacity", "protected windows", "pressure", "horizon", "Capture"])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("rounded LifeShape canvas panel"))
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("change preview panel"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertFalse(fieldSource.contains("LazyVGrid("))
        XCTAssertTrue(canvasSource.contains("semanticMarkRow(mark, compact: dynamicTypeSize.isAccessibilitySize == false)"))
        XCTAssertTrue(canvasSource.contains("dynamicTypeSize.isAccessibilitySize"))
        XCTAssertTrue(lensSource.contains("Capture routes through the global composer"))
        XCTAssertTrue(timeScreenSource.contains(".stageOwnedSafeAreaInset(edge: .bottom"))
        XCTAssertTrue(timeScreenSource.contains("Color.clear"))
        XCTAssertFalse(timeScreenSource.contains("theme.colors.canvasElevated.opacity(0.92)"))
        XCTAssertFalse(timeScreenSource.contains("theme.colors.canvas.opacity(0.96)"))
    }

    func testAMB573PrimitiveRegistryIncludesTimeObjectStageEntry() throws {
        let registryURL = repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md")
        guard FileManager.default.fileExists(atPath: registryURL.path) else {
            throw XCTSkip("Historical primitive registry is not retained in current repo truth.")
        }
        let registry = try String(contentsOf: registryURL, encoding: .utf8)

        XCTAssertTrue(registry.contains("| time-object-stage | Promoted | Time | LifeShape Field | AMB-573 |"))
        XCTAssertTrue(registry.contains("### time-object-stage"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md"))
    }

    func testEmptyRepositoriesReturnOpenRealityModelWeek() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.mode, .empty)
        XCTAssertEqual(timeState.emptyTitle, "No weekly pressure yet")
        XCTAssertEqual(timeState.believability.label, "Open")
        XCTAssertEqual(timeState.primaryAction.kind, .useRoom)
        XCTAssertEqual(timeState.weekDays.count, 7)
        XCTAssertEqual(timeState.pressureScrubber.points.count, 7)
        XCTAssertEqual(timeState.secondaryDestinations.map(\.id), ["time-rituals", "time-held-input", "time-weekly-review"])
        XCTAssertTrue(timeState.goalShapingItems.isEmpty)
        XCTAssertEqual(timeState.hero.title, "Shape Time")
        XCTAssertEqual(timeState.lifeSuite.title, "Shape Time")
        XCTAssertEqual(timeState.lifeSuite.shapes.map(\.title), ["Day Shape", "Week Shape", "Life Shape"])
        XCTAssertTrue(timeState.lifeSuite.shapes.allSatisfy { $0.facts.isEmpty == false })
        XCTAssertEqual(timeState.lifeSuite.manualFallbackLabel, "User choice available")
        XCTAssertEqual(timeState.lifeSuite.trustLabel, "No silent calendar changes")
        XCTAssertEqual(timeState.treaty.title, "This week's agreement")
        XCTAssertEqual(timeState.capacityEnvelope.label, "Light")
        XCTAssertEqual(timeState.timelineStrip.title, "Rich Timeline")
        XCTAssertFalse(timeState.calendarBoundary.writeBoundary.lowercased().contains("sync"))
        XCTAssertFalse(timeState.recoveryEntry.detail.contains("Reality Reflow"))
    }

    func testActiveGoalsProduceElasticWeekAndGoalRelationshipSignals() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.mode, .active)
        XCTAssertEqual(timeState.weekDays.count, 7)
        XCTAssertEqual(timeState.pressureScrubber.points.count, 7)
        XCTAssertFalse(timeState.goalShapingItems.isEmpty)
        XCTAssertEqual(timeState.shapingActions.map(\.kind), [.edit, .patch, .protect, .lighten])
        XCTAssertTrue(timeState.hero.contextPills.contains(where: { $0.title.contains("goals visible") }))
        XCTAssertFalse(timeState.resilience.lanes.isEmpty)
        XCTAssertNotNil(timeState.primaryAction.goalTarget)
        XCTAssertEqual(timeState.hero.title, "Shape Time")
        XCTAssertEqual(timeState.treaty.title, "This week's agreement")
        XCTAssertFalse(timeState.treaty.summary.contains("Kernel"))
        XCTAssertTrue(["Light", "Steady", "Tight", "Overloaded", "Fragile"].contains(timeState.capacityEnvelope.label))
        XCTAssertFalse(timeState.opportunityWindows.windows.isEmpty)
        XCTAssertLessThanOrEqual(timeState.opportunityWindows.windows.count, 4)
        XCTAssertFalse(timeState.timelineStrip.items.isEmpty)
    }

    func testF10TimeLifeSuiteProjectsDayWeekAndLifeShapeWithoutCalendarClone() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Place workshop idea", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let shapes = Dictionary(uniqueKeysWithValues: timeState.lifeSuite.shapes.map { ($0.kind, $0) })

        XCTAssertEqual(timeState.lifeSuite.subtitle, "Open time, goal time, protected time, pressure, source state, and user choice stay inspectable.")
        XCTAssertEqual(timeState.lifeSuite.calendarBoundaryLabel, "Manual shaping still works")
        XCTAssertEqual(shapes[.day]?.boundaryLabel, "No silent Time change")
        XCTAssertTrue(shapes[.day]?.facts.contains(where: { $0.contains("fixed point") }) == true)
        XCTAssertFalse(shapes[.day]?.facts.joined(separator: " ").localizedCaseInsensitiveContains("moves") ?? true)
        XCTAssertEqual(shapes[.week]?.boundaryLabel, "Suggestions require confirmation")
        XCTAssertTrue(shapes[.week]?.summary.contains("capture") == true)
        XCTAssertTrue(shapes[.week]?.facts.contains("1 capture needs a place.") == true)
        XCTAssertEqual(shapes[.life]?.sourceLabel, "Based on active goals")
        XCTAssertFalse(timeState.lifeSuite.trustLabel.localizedCaseInsensitiveContains("sync"))
    }

    func testAESP015LifeShapeFieldWeekDefaultCopyHighlightsOpenTimeProtectedTimeAndManualFallback() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Place a quieter step", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)
        let weekShape = try XCTUnwrap(timeState.lifeSuite.shapes.first(where: { $0.kind == .week }))
        let weekItem = LifeShapeFieldItem(shape: weekShape)

        XCTAssertEqual(
            timeState.lifeSuite.subtitle,
            "Open time, goal time, protected time, pressure, source state, and user choice stay inspectable."
        )
        XCTAssertEqual(timeState.lifeSuite.manualFallbackLabel, "User choice available")
        XCTAssertEqual(timeState.lifeSuite.trustLabel, "No silent calendar changes")
        XCTAssertEqual(timeState.lifeSuite.calendarBoundaryLabel, "Manual shaping still works")
        XCTAssertTrue(weekShape.facts.first?.localizedCaseInsensitiveContains("Open time:") == true)
        XCTAssertTrue(weekShape.schedulePressureLabel.localizedCaseInsensitiveContains("pressure"))
        XCTAssertTrue(weekShape.protectedTimeLabel.localizedCaseInsensitiveContains("protected"))
        XCTAssertTrue(weekShape.proofOpportunityLabel.localizedCaseInsensitiveContains("proof opportunity"))
        XCTAssertTrue(weekShape.privacyLabel.localizedCaseInsensitiveContains("user choice"))
        XCTAssertEqual(
            weekItem.accessibilityHint,
            "Selects this LifeShape Field contour without changing Time or calendar."
        )
        XCTAssertTrue(weekItem.accessibilityLabel.contains(weekItem.capacityContourLabel))
        XCTAssertTrue(weekItem.accessibilityLabel.contains(weekItem.protectedPocketLabel))
        XCTAssertTrue(weekItem.accessibilityLabel.contains(weekItem.pressureFieldLabel))
        XCTAssertTrue(weekItem.accessibilityLabel.contains(weekItem.recoveryPocketLabel))
    }

    func testAMB964LifeShapeFieldUsesRequiredWeekCapacityLanguageAndActions() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Place a quieter step", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)
        let weekReading = timeState.lifeSuite.field.reading(for: .week)
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift"),
            encoding: .utf8
        )
        let capacitySource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCapacity.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(timeState.lifeSuite.field.defaultHorizon, .week)
        XCTAssertTrue(weekReading.capacityStatement.contains("This week can hold"))
        XCTAssertTrue(weekReading.capacityStatement.localizedCaseInsensitiveContains("focused block"))
        XCTAssertTrue(weekReading.capacityStatement.localizedCaseInsensitiveContains("light step"))
        XCTAssertTrue(weekReading.capacityStatement.localizedCaseInsensitiveContains("protected recovery window"))
        XCTAssertTrue(source.contains("capacityStatement"))
        XCTAssertTrue(capacitySource.contains("var capacityStatement"))
        XCTAssertTrue(capacitySource.contains("time.life-shape-field.action.shape-week"))
        XCTAssertTrue(capacitySource.contains("time.life-shape-field.action.review-pressure"))
        XCTAssertTrue(capacitySource.contains("time.life-shape-field.action.protect-block"))
        XCTAssertTrue(capacitySource.contains("time.life-shape-field.action.adjust-shape"))
        XCTAssertTrue(TimeObjectStagePrimitiveContract.current.replacesFirstViewportStructures.contains("metric-row stack"))
    }

    func testAESP015ReflowReceiptPreviewAndDecisionCopyStayInspectableWithoutSilentMutation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "aesp-015-change-\($0)", title: "AESP 015 \($0)") })
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)

        XCTAssertTrue(timeState.reflowReceiptPreview.whatWouldNotChange.contains("Calendar blocks are not written."))
        XCTAssertTrue(timeState.reflowReceiptPreview.whatWouldNotChange.contains("Time is not silently rescheduled."))
        XCTAssertTrue(timeState.reflowReceiptPreview.momentumReflowContract.contains(where: { $0.localizedCaseInsensitiveContains("pressure") }))
        XCTAssertTrue(timeState.reflowReceiptPreview.safeFailureFallback.localizedCaseInsensitiveContains("keeps Time as-is"))
        XCTAssertTrue(timeState.reflowDecision.options.contains(where: { $0.kind == .moveLater && $0.title == "Move it" }))
        XCTAssertTrue(timeState.reflowDecision.options.contains(where: { $0.accessibilityValue.localizedCaseInsensitiveContains("step") }))
        XCTAssertFalse(timeState.reflowDecision.options.contains(where: { $0.accessibilityValue.localizedCaseInsensitiveContains("move later") }))
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
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)

        let items = timeState.lifeSuite.shapes.map(LifeShapeFieldItem.init(shape:))
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
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)
        let items = timeState.lifeSuite.shapes.map(LifeShapeFieldItem.init(shape:))
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

    func testAFRI026LifeShapeFieldExposesInspectableCapacityPressureProtectedAndMilestoneMeaning() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "afri-026-tight-1", title: "AFRI 026 one"),
            makeWeekVisibleGoal(id: "afri-026-tight-2", title: "AFRI 026 two"),
            makeWeekVisibleGoal(id: "afri-026-tight-3", title: "AFRI 026 three")
        ])
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)

        let items = timeState.lifeSuite.shapes.map(LifeShapeFieldItem.init(shape:))
        let combinedInspection = items.map(\.lifeShapeInspectionSummary).joined(separator: " ")
        let compactCopy = items.map(\.compactInspectionSummary).joined(separator: " ")

        XCTAssertTrue(combinedInspection.localizedCaseInsensitiveContains("Schedule reality"))
        XCTAssertTrue(combinedInspection.localizedCaseInsensitiveContains("Free capacity"))
        XCTAssertTrue(combinedInspection.localizedCaseInsensitiveContains("Protected time"))
        XCTAssertTrue(combinedInspection.localizedCaseInsensitiveContains("Pressure"))
        XCTAssertTrue(combinedInspection.localizedCaseInsensitiveContains("Milestones"))
        XCTAssertTrue(combinedInspection.localizedCaseInsensitiveContains("Life-area shape"))
        XCTAssertTrue(compactCopy.localizedCaseInsensitiveContains("without becoming a calendar grid"))
        XCTAssertFalse(combinedInspection.localizedCaseInsensitiveContains("calendar clone"))
        XCTAssertFalse(combinedInspection.localizedCaseInsensitiveContains("score"))
    }

    func testTimeLifeShapeProjectionExposesProofOpportunityAndPrivacyLabelsDeterministically() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "life-projection-1", title: "Life projection one"),
            makeWeekVisibleGoal(id: "life-projection-2", title: "Life projection two"),
            makeWeekVisibleGoal(id: "life-projection-3", title: "Life projection three")
        ])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Protect a quiet proof opportunity", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let firstSurfaceState = try await service.loadTimeSurfaceState(now: fixedDate)
        let secondSurfaceState = try await service.loadTimeSurfaceState(now: fixedDate)
        let firstShapes = firstSurfaceState.lifeSuite.shapes
        let secondShapes = secondSurfaceState.lifeSuite.shapes

        let firstProjection = firstShapes.map {
            [
                $0.kind.rawValue,
                $0.schedulePressureLabel,
                $0.protectedTimeLabel,
                $0.capacityLabel,
                $0.proofOpportunityLabel,
                $0.provenanceLabel,
                $0.privacyLabel
            ].joined(separator: "|")
        }
        let secondProjection = secondShapes.map {
            [
                $0.kind.rawValue,
                $0.schedulePressureLabel,
                $0.protectedTimeLabel,
                $0.capacityLabel,
                $0.proofOpportunityLabel,
                $0.provenanceLabel,
                $0.privacyLabel
            ].joined(separator: "|")
        }

        XCTAssertEqual(firstProjection, secondProjection)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)

        let weekShape = try XCTUnwrap(firstShapes.first { $0.kind == .week })
        let weekItem = LifeShapeFieldItem(shape: weekShape)
        let inspectionSummary = weekItem.lifeShapeInspectionSummary
        let accessibilityLabel = weekItem.accessibilityLabel

        XCTAssertTrue(weekShape.schedulePressureLabel.localizedCaseInsensitiveContains("pressure"))
        XCTAssertTrue(weekShape.proofOpportunityLabel.localizedCaseInsensitiveContains("proof opportunity"))
        XCTAssertTrue(weekShape.provenanceLabel.localizedCaseInsensitiveContains("provenance"))
        XCTAssertTrue(weekShape.privacyLabel.localizedCaseInsensitiveContains("privacy"))
        XCTAssertTrue(inspectionSummary.localizedCaseInsensitiveContains("Proof opportunity"))
        XCTAssertTrue(inspectionSummary.localizedCaseInsensitiveContains("Provenance"))
        XCTAssertTrue(inspectionSummary.localizedCaseInsensitiveContains("Privacy"))
        XCTAssertTrue(accessibilityLabel.localizedCaseInsensitiveContains("Proof opportunity"))
        XCTAssertTrue(accessibilityLabel.localizedCaseInsensitiveContains("Provenance"))
        XCTAssertTrue(accessibilityLabel.localizedCaseInsensitiveContains("Privacy"))
        XCTAssertFalse(inspectionSummary.localizedCaseInsensitiveContains("calendar grid"))
        XCTAssertFalse(accessibilityLabel.localizedCaseInsensitiveContains("calendar grid"))
        XCTAssertFalse(accessibilityLabel.localizedCaseInsensitiveContains("%"))
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
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let drillDown = timeState.lifeSuite.drillDown

        XCTAssertEqual(drillDown.title, "LifeShape Field detail")
        XCTAssertTrue(drillDown.subtitle.contains("rhythm"))
        XCTAssertTrue(drillDown.rhythmLabel.contains("Rhythm"))
        XCTAssertTrue(drillDown.pressureWeeksLabel.contains("Pressure weeks"))
        XCTAssertTrue(drillDown.milestoneLabel.contains("Milestones"))
        XCTAssertTrue(drillDown.protectedTimeLabel.contains("Protected time"))
        XCTAssertTrue(drillDown.freeTimeLabel.contains("Free-time bands"))
        XCTAssertTrue(drillDown.recoverySpaceLabel.contains("Recovery space"))
        XCTAssertTrue(drillDown.commitmentLoadLabel.contains("Commitment load"))
        XCTAssertTrue(drillDown.monthRangeLabel.contains("Month horizon"))
        XCTAssertTrue(drillDown.yearRangeLabel.contains("Year horizon"))
        XCTAssertTrue(drillDown.lifeRangeLabel.contains("Life range"))
        XCTAssertTrue(drillDown.cognitiveLoadLabel.contains("Cognitive load"))
        XCTAssertTrue(drillDown.physicalEnergyLabel.contains("Physical energy"))
        XCTAssertTrue(drillDown.transitionFrictionLabel.contains("Transition friction"))
        XCTAssertTrue(drillDown.freeTimeQualityLabel.contains("Free-time quality"))
        XCTAssertTrue(drillDown.executionLanesLabel.contains("Execution lanes"))
        XCTAssertTrue(drillDown.goalLoadLabel.contains("Goal load"))
        XCTAssertEqual(drillDown.items.map(\.id), [
            "life-areas",
            "pressure-weeks",
            "milestones",
            "protected-time",
            "free-time",
            "commitment-load",
            "month-horizon",
            "year-horizon",
            "life-range",
            "cognitive-load",
            "physical-energy",
            "transition-friction",
            "free-time-quality",
            "execution-lanes",
            "goal-load"
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
            drillDown.commitmentLoadLabel,
            drillDown.monthRangeLabel,
            drillDown.yearRangeLabel,
            drillDown.lifeRangeLabel,
            drillDown.cognitiveLoadLabel,
            drillDown.physicalEnergyLabel,
            drillDown.transitionFrictionLabel,
            drillDown.freeTimeQualityLabel,
            drillDown.executionLanesLabel,
            drillDown.goalLoadLabel
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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let shapes = Dictionary(uniqueKeysWithValues: timeState.lifeSuite.shapes.map { ($0.kind, $0) })

        XCTAssertEqual(shapes[.day]?.title, "Day Shape")
        XCTAssertEqual(shapes[.day]?.boundaryLabel, "No silent Time change")
        XCTAssertTrue(shapes[.day]?.facts.contains(where: { $0.localizedCaseInsensitiveContains("fixed point") }) == true)
        XCTAssertEqual(shapes[.week]?.title, "Week Shape")
        XCTAssertEqual(shapes[.week]?.boundaryLabel, "Suggestions require confirmation")
        XCTAssertTrue(shapes[.week]?.facts.contains(where: { $0.contains("pressured day") }) == true)
        XCTAssertTrue(shapes[.week]?.facts.contains("1 capture needs a place.") == true)
        XCTAssertFalse(timeState.lifeSuite.shapes.flatMap(\.facts).joined(separator: " ").localizedCaseInsensitiveContains("automatically"))
    }

    func testBlockedDraftsAndOpenCapturesSurfaceRealityPressureTruthfully() async throws {
        let repositories = try await makeRepositories()
        let intake = GoalEngineIntakeService()
        let draftBuild = intake.buildGoalDraft(from: "I want to do something", referenceNow: GoalEngineFixtures.fixedNow)
        let persistedDraft = PersistedGoalDraft(
            id: "draft-time-pressure",
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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.believability.label, "Needs clarity")
        XCTAssertEqual(timeState.believability.visualState, .warning)
        XCTAssertTrue(timeState.hero.pressureSummary.contains("captures"))
        XCTAssertTrue(timeState.hero.trustWhisper.contains("Clarify"))
        XCTAssertEqual(timeState.primaryAction.kind, .shapeWeek)
    }

    func testHabitLikeGoalsRemainRepresentedUnderTimeSupportLoops() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.secondaryDestinations.map(\.id), ["time-rituals", "time-held-input", "time-weekly-review"])
        XCTAssertTrue(timeState.secondaryDestinations.contains(where: { $0.id == "time-rituals" && $0.valueLabel != "0" }))
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testD16RitualRouteIsTimeOwnedAndDoesNotRestoreStandaloneHabitsCopy() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let ritualDestination = try XCTUnwrap(timeState.secondaryDestinations.first(where: { $0.timeRoute == .rituals }))
        let ritualLane = try XCTUnwrap(timeState.resilience.lanes.first(where: { $0.timeRoute == .rituals }))
        let timeCopy = [
            ritualDestination.title,
            ritualDestination.detail,
            ritualLane.title,
            ritualLane.detail,
            ritualLane.recommendation,
            timeState.resilience.focusProtection
        ].joined(separator: " ")

        XCTAssertEqual(ritualDestination.title, "Rituals")
        XCTAssertEqual(ritualLane.title, "Rituals")
        XCTAssertTrue(timeCopy.localizedCaseInsensitiveContains("ritual"))
        XCTAssertFalse(timeCopy.localizedCaseInsensitiveContains("habit"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("TimeRituals"))
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testTimeWeeklyReviewStateBridgesCarryForwardAndSupportRoutes() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Review the carry-forward tradeoff", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeWeeklyReviewState(now: fixedDate)

        XCTAssertEqual(timeState.hero.eyebrow, "Weekly Review")
        XCTAssertFalse(timeState.carryForwardItems.isEmpty)
        XCTAssertTrue(timeState.captureSummary.contains("capture"))
        XCTAssertEqual(timeState.returnActionTitle, "Return to Time")
    }

    func testPK21TimeProjectionServiceMirrorsTimeLifeShapeSurfaceSemantics() async throws {
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

        let baseline = try await service.loadTimeSurfaceState(now: fixedDate)
        let extracted = try await TimeProjectionService().makeTimeSurfaceState(
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

    func testPK21TimeProjectionServiceMirrorsRecoveryReflowSemanticsWithoutMutation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "pk21-change-\($0)", title: "PK21 overloaded \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()

        let baseline = try await service.loadTimeSurfaceState(now: fixedDate)
        let extracted = try await TimeProjectionService().makeTimeSurfaceState(
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
        XCTAssertTrue(extracted.recoveryMaturity.calendarBoundary.contains("Manual shaping works") || extracted.recoveryMaturity.calendarBoundary.contains("does not write calendar changes silently"))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testPK21TimeProjectionServicePreservesWeeklyReviewOutputAndNoCalendarCloneLanguage() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "pk21-weekly", title: "Weekly review pressure")
        ])
        let service = RepositoryBackedTimeService(repositories: repositories)
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()

        let baseline = try await service.loadTimeWeeklyReviewState(now: fixedDate)
        let extracted = try await TimeProjectionService().makeTimeWeeklyReviewState(from: service, now: fixedDate)
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

    func testPK21TimeProjectionServiceMakesCalendarAwareSurfaceStateFromInjectedPermission() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal(id: "pk21-calendar", title: "Calendar-boundary check")])
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()
        let extracted = try await TimeProjectionService().makeTimeSurfaceState(
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

    func testPK21TimeProjectionServiceCanReuseInjectedSnapshotWithoutReloadingSource() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal(id: "pk21-snapshot", title: "Snapshot reuse")])
        let service = RepositoryBackedTimeService(repositories: repositories)
        let snapshot = try await service.loadSnapshot()
        let source = PK21TrackingTimeProjectionSource(service: service)
        let timeService = TimeProjectionService()

        _ = try await timeService.makeTimeSurfaceState(
            from: source,
            now: fixedDate,
            permission: .unavailable,
            snapshot: snapshot
        )

        XCTAssertEqual(source.loadSnapshotCount, 0)

        _ = try await timeService.makeTimeSurfaceState(
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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let protectAction = try XCTUnwrap(timeState.shapingActions.first(where: { $0.kind == .protect }))

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

        let timeState = try await service.makeTimeCalendarAware(now: fixedDate)
        let events = try await ledger.fetchRecent(limit: 5)

        let requestedActionNames = await calendar.currentRequestedActionNames()
        XCTAssertEqual(requestedActionNames, ["Make Time calendar-aware"])
        XCTAssertEqual(timeState.calendarAwareness.status, .calendarAware)
        XCTAssertEqual(timeState.calendarAwareness.sourceLabel, "From your calendar")
        XCTAssertEqual(timeState.calendarBoundary.sourceLabel, "From your calendar")
        XCTAssertTrue(timeState.calendarAwareness.detail.contains("open window"))
        XCTAssertEqual(events.first?.kind, .calendarContextObserved)
        XCTAssertEqual(events.first?.privacy, .calendarDerived)
        XCTAssertEqual(events.first?.source, .time)
    }

    func testCalendarDeniedProducesManualFallbackWithoutFakeClaims() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .denied)
        )

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.calendarAwareness.status, .denied)
        XCTAssertFalse(timeState.calendarBoundary.canRequestCalendarRead)
        XCTAssertEqual(timeState.calendarAwareness.sourceLabel, "Created in Ambitions")
        XCTAssertTrue(timeState.calendarBoundary.manualFallback.contains("Manual shaping still works"))
        XCTAssertTrue(timeState.calendarBoundary.writeBoundary.contains("never silently writes"))
        XCTAssertFalse(timeState.calendarBoundary.detail.lowercased().contains("sync"))
        XCTAssertFalse(timeState.calendarBoundary.detail.lowercased().contains("export"))
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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let counts = Dictionary(uniqueKeysWithValues: timeState.lifecycleRail.segments.map { ($0.lifecycleState, $0.count) })

        XCTAssertGreaterThanOrEqual(counts[.active, default: 0], 1)
        XCTAssertGreaterThanOrEqual(counts[.future, default: 0], 1)
        XCTAssertEqual(counts[.completed], 1)
        XCTAssertEqual(counts[.cancelledDropped], 1)
        XCTAssertEqual(counts[.parked], 1)
        XCTAssertEqual(counts[.blocked], 1)
        XCTAssertEqual(counts[.waiting], 1)
        XCTAssertEqual(timeState.lifecycleRail.segments.map(\.lifecycleState), [.previous, .active, .future, .waiting, .blocked, .parked, .protected, .completed, .cancelledDropped])
    }

    func testTimeTimelineIncludesActiveFutureAndPreviousWithoutFakeCertainty() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-active", title: "Active carried goal"),
            makeWeekVisibleGoal(id: "goal-future", title: "Future goal", state: .draft),
            makeWeekVisibleGoal(id: "goal-previous", title: "Previous goal", state: .archived, stepState: .completed)
        ])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertTrue(timeState.timelineStrip.items.contains(where: { $0.kind == .active }))
        XCTAssertTrue(timeState.timelineStrip.items.contains(where: { $0.kind == .future }))
        XCTAssertTrue(timeState.timelineStrip.items.contains(where: { $0.kind == .previous }))
        XCTAssertEqual(timeState.timelineStrip.title, "Rich Timeline")
        XCTAssertTrue(timeState.timelineStrip.items.map(\.sourceLabel).contains("Based on Time"))
        XCTAssertTrue(timeState.timelineStrip.items.map(\.sourceLabel).contains("Created in Ambitions"))
        XCTAssertFalse(timeState.timelineStrip.items.map(\.detail).joined(separator: " ").contains("%"))
    }

    func testCapacityEnvelopeUsesQualitativeStates() async throws {
        let lightRepositories = try await makeRepositories()
        let lightSurfaceState = try await RepositoryBackedTimeService(repositories: lightRepositories).loadTimeSurfaceState(now: fixedDate)
        XCTAssertEqual(lightSurfaceState.capacityEnvelope.label, "Light")

        let steadyRepositories = try await makeRepositories()
        try await steadyRepositories.goals.saveGoals([makeWeekVisibleGoal()])
        let steadySurfaceState = try await RepositoryBackedTimeService(repositories: steadyRepositories).loadTimeSurfaceState(now: fixedDate)
        XCTAssertTrue(["Steady", "Tight"].contains(steadySurfaceState.capacityEnvelope.label))

        let tightRepositories = try await makeRepositories()
        try await tightRepositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "tight-1", title: "Tight one"),
            makeWeekVisibleGoal(id: "tight-2", title: "Tight two"),
            makeWeekVisibleGoal(id: "tight-3", title: "Tight three")
        ])
        let tightSurfaceState = try await RepositoryBackedTimeService(repositories: tightRepositories).loadTimeSurfaceState(now: fixedDate)
        XCTAssertTrue(["Tight", "Overloaded"].contains(tightSurfaceState.capacityEnvelope.label))

        let overloadedRepositories = try await makeRepositories()
        try await overloadedRepositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "overloaded-\($0)", title: "Overloaded \($0)") })
        let overloadedSurfaceState = try await RepositoryBackedTimeService(repositories: overloadedRepositories).loadTimeSurfaceState(now: fixedDate)
        XCTAssertEqual(overloadedSurfaceState.capacityEnvelope.label, "Overloaded")
    }

    func testPressureRecoveryReviewExplainsOverloadWithoutShameOrMutation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "pressure-\($0)", title: "Pressure \($0)") })
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let review = timeState.pressureRecoveryReview

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
        XCTAssertTrue(review.recoveryReceiptPreviewLabel.contains("Recovery review preview"))
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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertFalse(timeState.decisionDebt.items.isEmpty)
        XCTAssertFalse(timeState.conflictCourt.conflicts.isEmpty)
        XCTAssertFalse(timeState.recoveryEntry.suggestions.isEmpty)
        XCTAssertTrue(timeState.recoveryEntry.boundary.contains("No schedule changes"))
        XCTAssertTrue(timeState.conflictCourt.subtitle.contains("not alarms") || timeState.conflictCourt.conflicts.isEmpty)
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
                title: "Protected shaping",
                targetBy: "2026-04-19T10:00:00Z",
                dueAt: nil
            ),
            makeWeekVisibleGoal()
        ])

        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)
        let protectedConflict = try XCTUnwrap(timeState.conflictCourt.conflicts.first(where: { $0.id == "conflict-protected-goals" }))
        let copy = [
            protectedConflict.title,
            protectedConflict.detail,
            timeState.pressureRecoveryReview.protectedTimeConflictLabel,
            timeState.pressureRecoveryReview.overloadedDayLabel
        ].joined(separator: " ").lowercased()

        XCTAssertTrue(protectedConflict.title == "Important goals are competing")
        XCTAssertTrue(protectedConflict.detail.contains("important goals are asking"))
        XCTAssertFalse(copy.contains("most important"))
        XCTAssertFalse(copy.contains("ranking"))
        XCTAssertTrue(timeState.conflictCourt.subtitle.contains("negotiation") || timeState.conflictCourt.subtitle.contains("not alarms"))
        XCTAssertTrue(timeState.pressureRecoveryReview.signals.contains(where: { $0.id == "protected-time" && $0.statusLabel == "Review" }))
        XCTAssertTrue(timeState.pressureRecoveryReview.signals.first(where: { $0.id == "protected-time" })?.detail.isEmpty == false)
    }

    func testRealityReflowNoReflowNeededProducesCalmStillBelievableState() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.realityReflow.reasonKind, .stillBelievable)
        XCTAssertEqual(timeState.realityReflow.title, "Time is still believable")
        XCTAssertTrue(timeState.realityReflow.suggestions.contains(where: { $0.kind == .keepTimeUnchanged }))
        XCTAssertTrue(timeState.realityReflow.noChangeCopy.contains("Nothing changed"))
    }

    func testOverloadedTimeProducesRealityReflowRecommendationWithoutMutation() async throws {
        let repositories = try await makeRepositories()
        let goals = (0..<6).map { makeWeekVisibleGoal(id: "time-change-overload-\($0)", title: "Time overload \($0)") }
        try await repositories.goals.saveGoals(goals)
        let before = try await repositories.goals.listGoals()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let after = try await repositories.goals.listGoals()

        XCTAssertEqual(timeState.realityReflow.reasonKind, .overloadedTimeShape)
        XCTAssertTrue(timeState.realityReflow.suggestions.contains(where: { $0.kind == .protectOneItem }))
        XCTAssertTrue(timeState.realityReflow.suggestions.contains(where: { $0.kind == .shrinkAction }))
        XCTAssertTrue(timeState.realityReflow.suggestions.contains(where: { $0.kind == .moveLocalActionLater }))
        XCTAssertEqual(before, after)
    }

    func testNoRecoveryMarginSuggestsSmallAdjustmentsBeforeBroadChanges() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "margin-\($0)", title: "Margin \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let orderedKinds = timeState.recoveryGradient.options.map(\.kind)

        XCTAssertEqual(Array(orderedKinds.prefix(4)), [.protectOneItem, .shrinkAction, .splitAction, .moveLocalActionLater])
        XCTAssertTrue(timeState.realityReflow.suggestions.first?.boundary.confirmationRequirement == .notRequired)
        XCTAssertFalse(timeState.realityReflow.suggestions.first?.detail.lowercased().contains("reschedule") ?? true)
    }

    func testBlockedAndWaitingTimeSurfacesAppropriateRealityReasons() async throws {
        let blockedRepositories = try await makeRepositories()
        try await blockedRepositories.goals.saveGoals([makeWeekVisibleGoal(id: "blocked-time-change", title: "Blocked Time change", stepState: .blocked)])
        let blockedSurfaceState = try await RepositoryBackedTimeService(repositories: blockedRepositories).loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(blockedSurfaceState.realityReflow.reasonKind, .blockedGoal)
        XCTAssertTrue(blockedSurfaceState.realityReflow.suggestions.contains(where: { $0.kind == .markWaiting }))

        let waitingRepositories = try await makeRepositories()
        try await waitingRepositories.captures.saveCaptures([makeWaitingCapture()])
        let waitingSurfaceState = try await RepositoryBackedTimeService(repositories: waitingRepositories).loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(waitingSurfaceState.realityReflow.reasonKind, .waitingOnPersonOrResource)
        XCTAssertTrue(waitingSurfaceState.realityReflow.suggestions.contains(where: { $0.kind == .markWaiting }))
    }

    func testCalendarDeniedStillProducesManualRecoveryOptions() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .denied)
        )

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertEqual(timeState.calendarAwareness.status, .denied)
        XCTAssertTrue(timeState.calendarBoundary.manualFallback.contains("Manual shaping still works"))
        XCTAssertTrue(timeState.realityReflow.suggestions.contains(where: { $0.kind == .protectOneItem || $0.kind == .keepTimeUnchanged }))
        XCTAssertTrue(timeState.reflowReceiptPreview.whatWouldNotChange.contains(where: { $0.contains("Calendar blocks are not written") }))
    }

    func testBroadReflowAndCalendarImpactingChangesRequireConfirmation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "confirm-\($0)", title: "Confirm \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        let moveLater = try XCTUnwrap(timeState.realityReflow.suggestions.first(where: { $0.kind == .moveLocalActionLater }))
        let drop = try XCTUnwrap(timeState.realityReflow.suggestions.first(where: { $0.kind == .dropOptionalWork }))
        let confirm = try XCTUnwrap(timeState.realityReflow.suggestions.first(where: { $0.kind == .askForConfirmation }))

        XCTAssertEqual(moveLater.boundary.confirmationRequirement, .requiredForBroadReflow)
        XCTAssertEqual(drop.boundary.confirmationRequirement, .requiredForDestructiveChange)
        XCTAssertNotEqual(confirm.boundary.confirmationRequirement, .notRequired)
        XCTAssertTrue(timeState.calendarBoundary.writeBoundary.contains("never silently writes"))
    }

    func testReceiptPreviewIncludesWouldChangeAndWouldNotChange() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "receipt-\($0)", title: "Receipt \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertFalse(timeState.reflowReceiptPreview.whatChanged.isEmpty)
        XCTAssertFalse(timeState.reflowReceiptPreview.whatWouldNotChange.isEmpty)
        XCTAssertTrue(timeState.reflowReceiptPreview.whatWouldNotChange.contains(where: { $0.contains("not silently rescheduled") }))
        XCTAssertTrue(timeState.reflowReceiptPreview.confirmationRequired.contains("Safe local") || timeState.reflowReceiptPreview.confirmationRequired.contains("confirmation"))
        XCTAssertFalse(timeState.reflowReceiptPreview.safeFailureFallback.isEmpty)
    }

    func testReflowReceiptShowsMomentumReflowContract() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "momentum-\($0)", title: "Momentum \($0)") })
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let contract = timeState.reflowReceiptPreview.momentumReflowContract

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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)

        XCTAssertFalse(timeState.saveTheDay.protectedItem.isEmpty)
        XCTAssertFalse(timeState.saveTheDay.adjustment.isEmpty)
        XCTAssertFalse(timeState.saveTheDay.recoveryExplanation.isEmpty)
        XCTAssertTrue(timeState.saveTheDay.boundary.contains("No silent rescheduling"))
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

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()

        XCTAssertEqual(timeState.recoveryMaturity.title, "Recovery maturity")
        XCTAssertEqual(timeState.recoveryMaturity.timeFitLabel, "Needs relief")
        XCTAssertTrue(timeState.recoveryMaturity.confirmationBoundary.contains("require confirmation"))
        XCTAssertTrue(timeState.recoveryMaturity.calendarBoundary.contains("Manual shaping works") || timeState.recoveryMaturity.calendarBoundary.contains("does not write calendar changes silently"))
        XCTAssertTrue(timeState.recoveryMaturity.socialBoundary.contains("private"))
        XCTAssertTrue(timeState.recoveryMaturity.receiptBoundary.contains("review preview"))
        XCTAssertTrue(timeState.recoveryMaturity.signals.contains(where: { $0.id == "waiting-commitments" && $0.statusLabel == "Visible" && $0.boundaryLabel == "No silent routing" }))
        XCTAssertTrue(timeState.recoveryMaturity.signals.contains(where: { $0.id == "social-load" && $0.boundaryLabel == "No inference without you" }))
        XCTAssertTrue(timeState.recoveryMaturity.signals.contains(where: { $0.id == "receipt" && $0.boundaryLabel.contains("Undo") }))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testF12ReflowDecisionProjectsUserOwnedOptionsWithoutSilentAutomation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "f12-\($0)", title: "F12 \($0)") })
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()

        XCTAssertEqual(timeState.reflowDecision.title, "Review Time changes")
        XCTAssertEqual(timeState.reflowDecision.sourceLabel, "Based on Time")
        XCTAssertEqual(timeState.reflowDecision.trustLabel, "Changes stay reviewable")
        XCTAssertTrue(timeState.reflowDecision.options.contains(where: { $0.kind == .protectTime }))
        XCTAssertTrue(timeState.reflowDecision.options.contains(where: { $0.kind == .makeSmaller }))
        XCTAssertTrue(timeState.reflowDecision.options.contains(where: { $0.kind == .moveLater }))
        XCTAssertTrue(timeState.reflowDecision.options.contains(where: { $0.kind == .reviewShape }))
        XCTAssertTrue(timeState.reflowDecision.options.allSatisfy { $0.trustLabel == "Changes stay reviewable" })
        XCTAssertTrue(timeState.reflowDecision.receiptLabel.contains("No silent rescheduling"))
        XCTAssertTrue(timeState.reflowDecision.options.allSatisfy { option in
            option.whatChangedLabel.hasPrefix("What changed:")
                && option.whyChangedLabel.hasPrefix("Why:")
                && option.impactedStepsLabel.hasPrefix("Impacted steps:")
                && option.capacityImpactLabel.hasPrefix("Capacity impact:")
                && option.protectedTimeImpactLabel.hasPrefix("Protected time impact:")
        })
        XCTAssertTrue(timeState.reflowDecision.options.allSatisfy { option in
            option.actions.map(\.kind) == [.accept, .edit, .decline]
        })
        XCTAssertTrue(timeState.reflowDecision.options.allSatisfy { option in
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

        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let decision = timeState.reflowDecision
        let protectedOption = try XCTUnwrap(decision.options.first { $0.kind == .protectTime })
        let preview = protectedOption.beforeAfterPreview

        XCTAssertEqual(preview.title, "Before / after")
        XCTAssertFalse(preview.beforeLabel.isEmpty)
        XCTAssertFalse(preview.afterLabel.isEmpty)
        XCTAssertFalse(preview.shapeChangeLabel.isEmpty)
        XCTAssertFalse(preview.receiptPreviewLabel.isEmpty)
        XCTAssertFalse(preview.accessibilityValue.isEmpty)
        XCTAssertFalse(protectedOption.accessibilityValue.isEmpty)
        XCTAssertEqual(protectedOption.actions.map(\.kind), [.accept, .edit, .decline])
        XCTAssertFalse(protectedOption.protectedTimeImpactLabel.isEmpty)
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
        let timeState = try await RepositoryBackedTimeService(repositories: repositories).loadTimeSurfaceState(now: fixedDate)

        let copy = [
            timeState.realityReflow.title,
            timeState.realityReflow.detail,
            timeState.reflowDecision.title,
            timeState.reflowDecision.subtitle,
            timeState.reflowDecision.sourceLabel,
            timeState.reflowDecision.trustLabel,
            timeState.reflowDecision.receiptLabel,
            timeState.saveTheDay.boundary,
            timeState.recoveryMaturity.confirmationBoundary,
            timeState.recoveryMaturity.calendarBoundary,
            timeState.reflowReceiptPreview.detail,
            timeState.reflowReceiptPreview.safeFailureFallback
        ].joined(separator: " ").lowercased()

        XCTAssertFalse(copy.contains("automatically"))
        XCTAssertFalse(copy.contains("will sync"))
        XCTAssertFalse(copy.contains("exported"))
        XCTAssertFalse(copy.contains("calendar written"))
    }

    func testTopLevelIARemainsCanonicalFourTabShell() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Capture"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Captures"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
    }

    func testD15TimeSurfaceContractSnapshotSatisfiesImplementationGate() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedTimeService(repositories: repositories)

        let timeState = try await service.loadTimeSurfaceState(now: fixedDate)
        let contract = ScreenContractRegistry.contract(for: .time)
        let snapshot = timeState.screenContractSnapshot()

        XCTAssertEqual(snapshot.screenID, .time)
        XCTAssertEqual(snapshot.topLevelTabTitles, ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(snapshot.topLevelTabTitles.contains("Capture"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("LifeShape Field"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("Open time"))
        XCTAssertTrue(snapshot.firstScreenContent.contains("Protected time"))
        XCTAssertTrue(snapshot.copySamples.contains("Open time, goal time, protected time, pressure, source state, and user choice stay inspectable."))
        XCTAssertTrue(snapshot.copySamples.contains("Based on Time"))
        let issues = ScreenContractValidator.validate(snapshot: snapshot, against: contract)
        XCTAssertTrue(issues.isEmpty, "\(issues)")
    }
}

private extension TimeProjectionServiceTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("project.yml")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

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
        id: String = "goal-time-visible",
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
            id: "capture-waiting-time-change",
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
            id: "capture-commitment-time-change",
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

private final class PK21TrackingTimeProjectionSource: TimeProjectionSource {
    private let service: RepositoryBackedTimeService
    private(set) var loadSnapshotCount = 0

    init(service: RepositoryBackedTimeService) {
        self.service = service
    }

    func loadSnapshot() async throws -> RepositoryBackedTimeService.Snapshot {
        loadSnapshotCount += 1
        return try await service.loadSnapshot()
    }

    func makeTimeSurfaceState(snapshot: RepositoryBackedTimeService.Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeSurfaceState {
        service.makeTimeSurfaceState(snapshot: snapshot, now: now, calendarAwareness: calendarAwareness)
    }

    func makeTimeWeeklyReviewState(snapshot: RepositoryBackedTimeService.Snapshot, now: Date) -> TimeWeeklyReviewState {
        service.makeTimeWeeklyReviewState(snapshot: snapshot, now: now)
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

    func requestCalendarReadAccessFromTime(actionName: String) async -> CalendarPermissionState {
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
        let permission = await requestCalendarReadAccessFromTime(actionName: request.userInitiatedTimeAction)
        requestedHorizon.append(request.horizon)
        let busy = await fetchDerivedBusyWindows(for: request.horizon)
        let context = CalendarDerivedContext(
            permissionState: permission,
            observedRangeStart: request.horizon.start,
            observedRangeEnd: request.horizon.end,
            derivedBusyWindowCount: busy.count,
            userInitiatedTimeAction: request.userInitiatedTimeAction,
            explanation: "Time used derived busy time locally."
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

    func requestCalendarReadAccessFromTime(actionName: String) async -> CalendarPermissionState {
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
                userInitiatedTimeAction: request.userInitiatedTimeAction,
                explanation: "Calendar permission unavailable."
            ),
            openWindowCandidates: []
        )
    }
}
