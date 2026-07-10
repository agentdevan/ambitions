import XCTest
@testable import Ambitions

final class DedicatedDevicePrototypeRuntimeTests: XCTestCase {
    func testBedsideCompanionIsTheOnlyConstrainedPrototypeContext() {
        XCTAssertEqual(AmbitionsRuntimeClientContext.iphoneApp.kind, .iphoneApp)
        XCTAssertEqual(AmbitionsRuntimeClientContext.iphoneApp.displayName, "iPhone app")
        XCTAssertEqual(AmbitionsRuntimeClientContext.bedsideRitualCompanion.kind, .bedsideRitualCompanion)
        XCTAssertEqual(AmbitionsRuntimeClientContext.bedsideRitualCompanion.displayName, "Bedside ritual companion")
        XCTAssertFalse(AmbitionsRuntimeClientContext.iphoneApp.isConstrainedPrototype)
        XCTAssertTrue(AmbitionsRuntimeClientContext.bedsideRitualCompanion.isConstrainedPrototype)
        XCTAssertEqual(AmbitionsRuntimeClientKind.allCases, [.iphoneApp, .bedsideRitualCompanion])
    }

    func testProjectionDerivesFromRuntimeContextAndExternalSnapshotTruth() throws {
        let projection = DedicatedDevicePrototypeRuntime.makeProjection(from: makeContext(snapshot: makeSnapshot()))

        XCTAssertEqual(projection.clientContext, .bedsideRitualCompanion)
        XCTAssertEqual(projection.thesisName, "bedside_ritual_companion")
        XCTAssertEqual(projection.titleTemplateKey, "ritual_midday_reset")
        XCTAssertEqual(projection.primaryReference, ExternalSurfaceActionReference(goalID: "goal-1", stepID: "step-1"))
        XCTAssertEqual(projection.todayPosture, .recovery)
        XCTAssertEqual(projection.pressureLevel, .elevated)
        XCTAssertEqual(projection.openCaptureUrgency, .low)
        XCTAssertEqual(projection.blockerSummary, ExternalSurfaceBlockerSummary(waitingCount: 1, blockedCount: 2))
        XCTAssertEqual(projection.ritualCue?.kind, .middayReset)
        XCTAssertEqual(projection.commandOptions.map(\.descriptor.kind), [.complete, .snooze, .openGoal, .openToday, .openCaptureComposer, .openMemoryLens])
        XCTAssertEqual(projection.commandOptions.map(\.disposition), [.deviceSafeQuickAction, .deviceSafeQuickAction, .fallbackToPhone, .fallbackToPhone, .fallbackToPhone, .fallbackToPhone])
        XCTAssertEqual(projection.defaultFallbackRouteIntent, .returnToToday)
    }

    func testMissingSnapshotProducesSafeFallbackProjection() {
        let projection = DedicatedDevicePrototypeRuntime.makeProjection(from: makeContext(snapshot: nil))

        XCTAssertNil(projection.primaryReference)
        XCTAssertEqual(projection.titleTemplateKey, "device_bedside_open_phone")
        XCTAssertEqual(projection.todayPosture, .empty)
        XCTAssertEqual(projection.pressureLevel, .open)
        XCTAssertEqual(projection.openCaptureUrgency, .none)
        XCTAssertEqual(projection.commandOptions.map(\.descriptor.kind), [.openToday, .openMemoryLens])
        XCTAssertEqual(projection.commandOptions.map(\.disposition), [.fallbackToPhone, .fallbackToPhone])
        XCTAssertEqual(projection.defaultFallbackRouteIntent, .returnToToday)
    }

    func testProjectionRemainsPrivacySafeAndDoesNotExposeUserEnteredText() throws {
        let projection = DedicatedDevicePrototypeRuntime.makeProjection(from: makeContext(snapshot: makeSnapshot()))
        let data = try JSONEncoder().encode(projection)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(json.contains("Private Therapy Goal"))
        XCTAssertFalse(json.contains("Call my therapist"))
        XCTAssertFalse(json.contains("capture text"))
        XCTAssertTrue(json.contains("ritual_midday_reset"))
    }

    @MainActor
    func testDeviceSafeActionsExecuteOnlyWhenDescriptorSupportsTheCommand() async {
        let executor = RecordingDeviceActionExecutor()
        let runtime = DedicatedDevicePrototypeRuntime(
            contextService: StaticDeviceContextService(snapshot: makeSnapshot()),
            actionExecutor: executor
        )
        let projection = DedicatedDevicePrototypeRuntime.makeProjection(from: makeContext(snapshot: makeSnapshot()))

        let result = await runtime.perform(
            ExternalActionCommand(
                kind: .complete,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .futureExternalPayload
            ),
            projection: projection,
            now: .now
        )

        XCTAssertEqual(result.disposition, .deviceSafeQuickAction)
        XCTAssertEqual(result.runtimeResult?.outcome, .performed)
        XCTAssertEqual(executor.executedCommands.map(\.kind), [.complete])

        let unsupported = await runtime.perform(
            ExternalActionCommand(
                kind: .askForSmallerStep,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .futureExternalPayload
            ),
            projection: projection,
            now: .now
        )

        XCTAssertEqual(unsupported.disposition, .unsupported)
        XCTAssertEqual(executor.executedCommands.map(\.kind), [.complete])
    }

    @MainActor
    func testDeepEditingActionsFallbackToPhoneInsteadOfLocalDeviceHandling() async {
        let executor = RecordingDeviceActionExecutor()
        let runtime = DedicatedDevicePrototypeRuntime(
            contextService: StaticDeviceContextService(snapshot: makeSnapshot()),
            actionExecutor: executor
        )
        let projection = DedicatedDevicePrototypeRuntime.makeProjection(from: makeContext(snapshot: makeSnapshot()))

        let openGoal = await runtime.perform(
            ExternalActionCommand(
                kind: .openGoal,
                target: ExternalActionTarget(goalID: "goal-1"),
                source: .futureExternalPayload
            ),
            projection: projection,
            now: .now
        )
        let openToday = await runtime.perform(
            ExternalActionCommand(kind: .openToday, source: .futureExternalPayload),
            projection: projection,
            now: .now
        )

        XCTAssertEqual(openGoal.disposition, .fallbackToPhone)
        XCTAssertEqual(openGoal.fallbackRouteIntent, .openGoal(id: "goal-1"))
        XCTAssertEqual(openToday.disposition, .fallbackToPhone)
        XCTAssertEqual(openToday.fallbackRouteIntent, .returnToToday)
        XCTAssertTrue(executor.executedCommands.isEmpty)
    }
}

private extension DedicatedDevicePrototypeRuntimeTests {
    func makeContext(snapshot: ExternalSurfaceSnapshot?) -> RuntimeContextSnapshot {
        RuntimeContextSnapshot(
            clientContext: .bedsideRitualCompanion,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Ambitions is running in explicit local-only mode.",
            ),
            knowledgeProviderStatuses: [],
            memorySummary: emptyMemorySummary(),
            externalSurfaceSnapshot: snapshot
        )
    }

    func emptyMemorySummary() -> RuntimeMemorySummary {
        RuntimeMemorySummary(
            memory: RuntimeMemorySnapshot(
                goals: [],
                drafts: [],
                evidence: [],
                feedback: [],
                captures: [],
                appState: .default
            )
        )
    }

    func makeSnapshot() -> ExternalSurfaceSnapshot {
        ExternalSurfaceSnapshot(
            generatedAt: "2026-04-19T12:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-legacy",
                stepID: "step-legacy",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .soon,
                    timing: .deadline
                )
            ),
            nowState: ExternalSurfaceNowState(
                todayPosture: .recovery,
                pressureLevel: .elevated,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-1", stepID: "step-1"),
                activeFocus: nil,
                openCaptureUrgency: .low,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 1, blockedCount: 2),
                ritualCue: ExternalSurfaceRitualCue(
                    kind: .middayReset,
                    templateKey: "ritual_midday_reset",
                    progressState: .needsReset,
                    primaryReference: ExternalSurfaceActionReference(goalID: "goal-1", stepID: "step-1")
                ),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .complete, requiresGoalID: true, requiresStepID: true),
                    ExternalSurfaceCommandDescriptor(kind: .snooze, requiresGoalID: true, requiresStepID: true),
                    ExternalSurfaceCommandDescriptor(kind: .openGoal, requiresGoalID: true, requiresStepID: false),
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                    ExternalSurfaceCommandDescriptor(kind: .openCaptureComposer, requiresGoalID: false, requiresStepID: false),
                    ExternalSurfaceCommandDescriptor(kind: .openMemoryLens, requiresGoalID: false, requiresStepID: false),
                ]
            )
        )
    }
}

private struct StaticDeviceContextService: RuntimeContextServicing {
    let snapshot: ExternalSurfaceSnapshot?

    func loadContext(now: Date) async throws -> RuntimeContextSnapshot {
        _ = now
        return RuntimeContextSnapshot(
            clientContext: .bedsideRitualCompanion,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Ambitions is running in explicit local-only mode.",
            ),
            knowledgeProviderStatuses: [],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: [],
                    drafts: [],
                    evidence: [],
                    feedback: [],
                    captures: [],
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: snapshot
        )
    }
}

@MainActor
private final class RecordingDeviceActionExecutor: RuntimeActionCommandExecuting {
    private(set) var executedCommands: [ExternalActionCommand] = []

    func execute(_ command: ExternalActionCommand, now: Date) async -> RuntimeActionResult {
        _ = now
        executedCommands.append(command)
        return RuntimeActionResult(outcome: .performed, messageTitle: "Recorded")
    }
}
