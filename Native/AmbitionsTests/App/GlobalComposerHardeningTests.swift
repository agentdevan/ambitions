import XCTest
@testable import Ambitions

@MainActor
final class GlobalComposerHardeningTests: XCTestCase {
    func testAMB1674ComposerEntryContractCoversRequiredSources() {
        let contracts = CaptureComposerEntryContract.current

        XCTAssertEqual(Set(contracts.map(\.entryPoint)), [
            .globalButton,
            .shareExtension,
            .appIntent,
            .notificationAction,
            .deepLink
        ])
        XCTAssertTrue(contracts.allSatisfy(\.requiresSharedCommandExecutor))
        XCTAssertTrue(contracts.allSatisfy(\.mutatesOnlyAfterLocalCommand))
        XCTAssertTrue(contracts.allSatisfy(\.storesRawInputLocalOnly))
        XCTAssertTrue(contracts.allSatisfy(\.opensGlobalComposer))
        XCTAssertTrue(contracts.allSatisfy(\.requiresAccessibleReview))
        XCTAssertEqual(contracts.first { $0.entryPoint == .appIntent }?.commandSource, .appIntent)
        XCTAssertEqual(contracts.first { $0.entryPoint == .shareExtension }?.commandSource, .deepLink)
        XCTAssertEqual(contracts.first { $0.entryPoint == .notificationAction }?.captureSourceType, .notification)
    }

    func testAMB1674ShellCaptureExecutesSharedCommandWithSourceAndRouteMetadata() async throws {
        let navigation = StageStore(selectedSurface: .today)
        let executor = RecordingCaptureCommandExecutor()
        let router = DefaultShellCommandRouter(
            navigation: navigation,
            intentSender: flagshipIntentSender(executor: executor)
        )

        let result = await router.execute(
            intent: .quickCapture,
            text: "Turn this into a goal",
            goalID: nil,
            captureID: nil,
            source: .shareExtension,
            selectedCaptureRouteType: .goal,
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )

        let commands = await executor.capturedCommands()
        let command = try XCTUnwrap(commands.first)
        XCTAssertEqual(commands.count, 1)
        XCTAssertEqual(command.kind, .quickCapture)
        XCTAssertEqual(command.source, .deepLink)
        XCTAssertEqual(command.sourceSurface, "Share")
        XCTAssertEqual(command.payload.rawText, "Turn this into a goal")
        XCTAssertEqual(command.payload.destinationRoute, CaptureRoute.goalSeed.rawValue)
        XCTAssertEqual(command.payload.metadata[ExternalCreationCommandMetadataKey.sourceType], CaptureSourceType.shareExtensionText.rawValue)
        XCTAssertEqual(command.payload.metadata["captureRouteType"], SmartAttachmentRouteType.goal.rawValue)
        XCTAssertEqual(command.payload.metadata["captureCommandPath"], "shell_command_router")
        XCTAssertEqual(result.createdCaptureID, "capture-recorded")
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .unavailable)
        XCTAssertEqual(
            result.pipelineTrace?.proofReceipt.summary,
            "Runtime receipt and projection evidence remain pending catch-up."
        )
    }

    func testAMB1674CaptureViewModelAcceptedSaveUsesCommandRouter() async throws {
        let navigation = StageStore(selectedSurface: .today)
        let executor = RecordingCaptureCommandExecutor()
        let router = DefaultShellCommandRouter(
            navigation: navigation,
            intentSender: flagshipIntentSender(executor: executor)
        )
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))

        viewModel.updateDraftText("Book dentist")
        viewModel.selectDraftRoute(.task)
        await viewModel.createQuickCapture(
            commandRouter: router,
            captureService: StubCaptureService(captures: []),
            goalsService: EmptyAMB1674GoalsService(),
            source: .globalCaptureComposer,
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )

        let commands = await executor.capturedCommands()
        let command = try XCTUnwrap(commands.first)
        XCTAssertEqual(command.kind, .quickCapture)
        XCTAssertEqual(command.source, .capture)
        XCTAssertEqual(command.payload.destinationRoute, CaptureRoute.timeSeed.rawValue)
        XCTAssertEqual(command.payload.metadata[ExternalCreationCommandMetadataKey.sourceType], CaptureSourceType.shellComposer.rawValue)
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved through command")
        XCTAssertEqual(viewModel.draftText, "")
        XCTAssertNil(viewModel.draftError)
    }

    func testCaptureViewModelRotatesSaveAttemptForRouteChangeButKeepsRetryStable() async throws {
        let executor = FailingRecordingCaptureCommandExecutor()
        let router = DefaultShellCommandRouter(
            navigation: StageStore(selectedSurface: .today),
            intentSender: flagshipIntentSender(executor: executor)
        )
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))

        viewModel.updateDraftText("Book dentist")
        viewModel.selectDraftRoute(.task)
        await viewModel.createQuickCapture(
            commandRouter: router,
            captureService: StubCaptureService(captures: []),
            goalsService: EmptyAMB1674GoalsService(),
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )
        viewModel.selectDraftRoute(.goal)
        await viewModel.createQuickCapture(
            commandRouter: router,
            captureService: StubCaptureService(captures: []),
            goalsService: EmptyAMB1674GoalsService(),
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )
        await viewModel.createQuickCapture(
            commandRouter: router,
            captureService: StubCaptureService(captures: []),
            goalsService: EmptyAMB1674GoalsService(),
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )

        let commands = await executor.capturedCommands()
        XCTAssertEqual(commands.count, 3)
        XCTAssertNotEqual(commands[0].id, commands[1].id)
        XCTAssertEqual(commands[1].id, commands[2].id)
        XCTAssertEqual(commands[0].payload.metadata["captureRouteType"], SmartAttachmentRouteType.task.rawValue)
        XCTAssertEqual(commands[1].payload.metadata["captureRouteType"], SmartAttachmentRouteType.goal.rawValue)
    }

    func testActivatedCaptureSeamRotatesSaveAttemptOnlyWhenSelectedRouteChanges() throws {
        let seam = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: repoRoot())

        XCTAssertGreaterThanOrEqual(seam.components(separatedBy: "updateSelectedDraftRoute(routeType)").count - 1, 2)
        XCTAssertTrue(seam.contains("guard routeType != selectedDraftRouteType else { return }"))
        XCTAssertTrue(seam.contains("draftID = DomainIdentifier.prefixed(\"shell.capture.draft\")"))
    }

    func testAMB1674RealShellCapturePersistsLocalOnlyRawCaptureThroughCommandPath() async throws {
        let navigation = StageStore(selectedSurface: .today)
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-raw-local" })
        let records = InMemoryAmbitionsCommandExecutionRecordRepository()
        let journal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: records,
            commandJournal: journal
        )
        let router = DefaultShellCommandRouter(
            navigation: navigation,
            intentSender: flagshipIntentSender(executor: executor)
        )

        let result = await router.execute(
            intent: .quickCapture,
            text: "NASA",
            goalID: nil,
            captureID: nil,
            source: .globalCaptureComposer,
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )

        let captures = try await repository.listCaptures()
        let capture = try XCTUnwrap(captures.first)
        let commandEntries = try await journal.fetchEntries(matching: .all, limit: nil)
        let commandRecords = try await records.fetchRecent(limit: 10)
        let commandRecord = try XCTUnwrap(commandRecords.first)

        XCTAssertEqual(result.createdCaptureID, capture.id)
        XCTAssertTrue(capture.id.hasPrefix("capture.shell.capture.command-"))
        XCTAssertEqual(capture.rawText, "NASA")
        XCTAssertEqual(capture.sourceType, .shellComposer)
        XCTAssertEqual(capture.route, .captureInbox)
        XCTAssertEqual(capture.maturityState, .raw)
        XCTAssertTrue(capture.localOnly)
        XCTAssertEqual(commandEntries.count, 1)
        XCTAssertEqual(commandEntries.first?.envelope.command.kind, .quickCapture)
        XCTAssertEqual(commandEntries.first?.envelope.source, .capture)
        XCTAssertEqual(commandRecord.command.privacy, .privateUserText)
        XCTAssertEqual(commandRecord.localOnly, true)
        XCTAssertEqual(commandRecord.result.metadata["captureSourceType"], CaptureSourceType.shellComposer.rawValue)
        XCTAssertEqual(commandRecord.result.metadata["captureLocalOnly"], "true")
        XCTAssertEqual(commandRecord.result.metadata["captureMaturityState"], CaptureMaturityState.raw.rawValue)
        XCTAssertNotNil(commandRecord.result.metadata["commandReceiptID"])
    }

    func testAMB1674CaptureMaturityStatesMapRawClarifiedAttachedScheduledAndParked() {
        let base = makeCapture(route: .captureInbox, kind: .raw, triageStatus: .needsTriage)

        XCTAssertEqual(base.maturityState, .raw)
        XCTAssertEqual(makeCapture(route: .goalSeed, kind: .goalSeed, triageStatus: .assumedRoute).maturityState, .clarified)
        XCTAssertEqual(makeCapture(route: .goalAttachment, kind: .goalSupportingTask, linkedGoalID: "goal-1").maturityState, .attached)
        XCTAssertEqual(makeCapture(route: .timeSeed, kind: .oneTimeCommitment, status: .scheduled).maturityState, .scheduled)
        XCTAssertEqual(makeCapture(route: .waiting, kind: .waitingItem, status: .waiting).maturityState, .parked)
        XCTAssertEqual(makeCapture(route: .optionalSomeday, kind: .optionalSomeday, status: .optionalSomeday).maturityState, .parked)
    }

    func testAMB1674ComposerCopyPolicyRejectsTicketWorkflowAIAndGuiltFraming() {
        let copySamples = CaptureViewState(captures: [], activeGoalOptions: [])
            .screenContractSnapshot()
            .copySamples
            .joined(separator: " ")
        let composerModeCopy = [
            CaptureComposerPresentationMode.globalComposer.subtitle,
            CaptureInteractions.routeReceiptMessage(for: .goal),
            CaptureObjectStagePrimitiveContract.current.accessibilityFallbacks.joined(separator: " ")
        ].joined(separator: " ")

        XCTAssertTrue(CaptureCopyPolicy.violations(in: copySamples).isEmpty)
        XCTAssertTrue(CaptureCopyPolicy.violations(in: composerModeCopy).isEmpty)
        XCTAssertEqual(CaptureCopyPolicy.violations(in: "AI ticket workflow guilt score").sorted(), ["AI", "guilt", "score", "ticket", "workflow"])
    }

    func testAMB1674ActivatedComposerKeepsAccessibilityFocusAndReduceMotionFallbacks() throws {
        let root = repoRoot()
        let seam = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: root)
        let router = try source("Native/Ambitions/App/ShellCommandRouter.swift", root: root)
        let composer = try source("Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift", root: root)

        XCTAssertTrue(seam.contains("await command.execute("))
        XCTAssertFalse(seam.contains("@Environment(\\.appContainer)"))
        XCTAssertFalse(seam.contains("appContainer.captureService.createCapture("))
        XCTAssertTrue(seam.contains("selectedCaptureRouteType: selectedDraftRouteType ?? decision.routeType"))
        XCTAssertTrue(composer.contains("viewModel.createQuickCapture("))
        XCTAssertTrue(composer.contains("commandRouter: shell.commandRouter"))
        XCTAssertTrue(seam.contains("shouldAutoFocus: true"))
        XCTAssertTrue(seam.contains(".scrollDismissesKeyboard(.interactively)"))
        XCTAssertTrue(seam.contains("@Environment(\\.accessibilityReduceMotion)"))
        XCTAssertTrue(seam.contains(".accessibilityLabel(AppShellCaptureAccessModel.activatedSeamAccessibilityLabel)"))
        XCTAssertTrue(seam.contains("selectedCaptureRouteType: selectedDraftRouteType ?? decision.routeType"))
        XCTAssertTrue(router.contains("intentSender.send("))
        XCTAssertFalse(router.contains("commandExecutor.execute("))
        XCTAssertFalse(router.contains("captureService.createCapture("))
        XCTAssertFalse(router.contains("Capture source is unavailable."))
        XCTAssertFalse(router.contains("Capture proof is still unavailable."))
        XCTAssertTrue(router.contains("Capture could not be saved."))
        XCTAssertTrue(CaptureObjectStagePrimitiveContract.current.accessibilityFallbacks.contains { $0.contains("VoiceOver") })
        XCTAssertTrue(CaptureObjectStagePrimitiveContract.current.accessibilityFallbacks.contains { $0.contains("Reduce Motion") })
    }

    private func makeCapture(
        route: CaptureRoute,
        kind: CaptureKind,
        status: CaptureStatus = .actionable,
        triageStatus: CaptureTriageStatus = .assumedRoute,
        linkedGoalID: String? = nil
    ) -> Capture {
        Capture(
            id: "capture-\(route.rawValue)-\(kind.rawValue)",
            createdAt: "2026-07-05T00:00:00Z",
            updatedAt: "2026-07-05T00:00:00Z",
            rawText: "Capture",
            sourceType: .shellComposer,
            status: status,
            linkedGoalID: linkedGoalID,
            kind: kind,
            route: route,
            triageStatus: triageStatus
        )
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/App/ShellCommandRouter.swift")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    private func flagshipIntentSender(
        executor: any CommandExecuting
    ) -> FlagshipRuntimeIntentAdapter {
        FlagshipRuntimeIntentAdapter(
            runtimeCommandClient: RuntimeCommandClient(
                execute: { command, context in
                    await executor.execute(command, context: context)
                },
                projection: { request in
                    throw RuntimeProjectionClientError.projectionUnavailable(request)
                }
            )
        )
    }
}

private actor RecordingCaptureCommandExecutor: CommandExecuting {
    private var commands: [AmbitionsCommand] = []

    nonisolated func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        AmbitionsCommandValidator().validate(command)
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        commands.append(command)
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Saved through command",
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: "capture-recorded", destination: .captureInbox),
            metadata: [
                "captureID": "capture-recorded",
                "commandReceiptID": "command.receipt.recording",
                "captureLocalOnly": "true",
                "captureMaturityState": CaptureMaturityState.raw.rawValue
            ]
        )
    }

    func capturedCommands() -> [AmbitionsCommand] {
        commands
    }
}

private actor FailingRecordingCaptureCommandExecutor: CommandExecuting {
    private var commands: [AmbitionsCommand] = []

    nonisolated func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        AmbitionsCommandValidator().validate(command)
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        _ = context
        commands.append(command)
        return AmbitionsCommandExecutionResult(
            status: .failed,
            summary: "Capture could not be saved.",
            route: nil,
            target: nil,
            metadata: [:]
        )
    }

    func capturedCommands() -> [AmbitionsCommand] {
        commands
    }
}

private actor EmptyAMB1674GoalsService: GoalsServicing {
    func loadOverview() async throws -> GoalsOverview {
        GoalsOverview(
            hero: GoalsBoardHeroState(
                eyebrow: "Goals",
                title: "Goals",
                subtitle: "No goals",
                dominantTruth: "No goals",
                pressureSummary: "No goals",
                contextPills: [],
                attentionPills: []
            ),
            heroPrimaryAction: GoalsBoardPrimaryAction(
                kind: .createGoal,
                title: "Create goal",
                subtitle: "Create goal",
                systemImage: "plus.circle",
                target: nil,
                state: .selected
            ),
            bands: [],
            horizonLadder: GoalsHorizonLadderState(title: "Horizon ladder", subtitle: "No goals", rungs: []),
            weekPressureSummary: GoalsWeekPressureSummary(
                title: "Calm",
                subtitle: "Calm",
                leadingMetric: "0 active",
                trailingMetric: "0 stretching thin",
                pill: GoalsHeroPillState(title: "Calm", icon: "leaf", state: .success)
            ),
            lowerPriority: GoalsLowerPriorityState(title: "Lower priority", subtitle: "No goals", disclosureTitle: "Show quieter goals", cards: []),
            lifecycleRail: [
                GoalLifecycleRailSegment(id: "previous", title: "Previous", count: 0, subtitle: "None", state: .default),
                GoalLifecycleRailSegment(id: "active", title: "Active", count: 0, subtitle: "None", state: .selected),
                GoalLifecycleRailSegment(id: "future", title: "Future", count: 0, subtitle: "None", state: .default)
            ],
            stateChips: [],
            atlasPreview: nil,
            archiveSummary: GoalPortfolioArchiveSummary(title: "Archive is quiet", subtitle: "No archive goals", chips: [], learningLines: []),
            maturitySummary: .empty,
            items: [],
            isSeeded: false,
            emptyTitle: "No goals",
            emptyMessage: "No goals"
        )
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        fatalError("Not needed for AMB-1674 Capture hardening tests.")
    }

    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        _ = request
        _ = now
        fatalError("Not needed for AMB-1674 Capture hardening tests.")
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = request
        _ = now
        fatalError("Not needed for AMB-1674 Capture hardening tests.")
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for AMB-1674 Capture hardening tests.")
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for AMB-1674 Capture hardening tests.")
    }
}
