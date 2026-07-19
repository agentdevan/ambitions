import Foundation

enum DedicatedDevicePrototypeCommandDisposition: String, Codable, Sendable, Equatable {
    case deviceSafeQuickAction = "device_safe_quick_action"
    case fallbackToPhone = "fallback_to_phone"
}

enum DedicatedDevicePrototypeActionDisposition: String, Sendable, Equatable {
    case deviceSafeQuickAction = "device_safe_quick_action"
    case fallbackToPhone = "fallback_to_phone"
    case missingTarget = "missing_target"
    case unsupported
}

struct DedicatedDevicePrototypeCommandOption: Codable, Sendable, Equatable {
    let descriptor: ExternalSurfaceCommandDescriptor
    let disposition: DedicatedDevicePrototypeCommandDisposition
}

struct DedicatedDevicePrototypeProjection: Codable, Sendable, Equatable {
    let clientContext: AmbitionsRuntimeClientContext
    let thesisName: String
    let titleTemplateKey: String
    let primaryReference: ExternalSurfaceActionReference?
    let todayPosture: ExternalSurfaceTodayPosture
    let pressureLevel: ExternalSurfacePressureLevel
    let openCaptureUrgency: ExternalSurfaceCaptureUrgency
    let blockerSummary: ExternalSurfaceBlockerSummary
    let ritualCue: ExternalSurfaceRitualCue?
    let commandOptions: [DedicatedDevicePrototypeCommandOption]
    let defaultFallbackRouteIntent: RuntimeRouteIntent
}

struct DedicatedDevicePrototypeActionResult: Sendable, Equatable {
    let disposition: DedicatedDevicePrototypeActionDisposition
    let runtimeResult: RuntimeActionResult?
    let fallbackRouteIntent: RuntimeRouteIntent?

    init(
        disposition: DedicatedDevicePrototypeActionDisposition,
        runtimeResult: RuntimeActionResult? = nil,
        fallbackRouteIntent: RuntimeRouteIntent? = nil
    ) {
        self.disposition = disposition
        self.runtimeResult = runtimeResult
        self.fallbackRouteIntent = fallbackRouteIntent
    }
}

struct DedicatedDevicePrototypeRuntime {
    private static let thesisName = "bedside_ritual_companion"

    private let contextService: any RuntimeContextServicing
    private let actionExecutor: any RuntimeActionCommandExecuting

    init(
        contextService: any RuntimeContextServicing,
        actionExecutor: any RuntimeActionCommandExecuting
    ) {
        self.contextService = contextService
        self.actionExecutor = actionExecutor
    }

    func loadProjection(now: Date) async throws -> DedicatedDevicePrototypeProjection {
        let context = try await contextService.loadContext(now: now)
        return Self.makeProjection(from: context)
    }

    static func makeProjection(from context: RuntimeContextSnapshot) -> DedicatedDevicePrototypeProjection {
        let glance = ExternalSurfaceGlanceState(snapshot: context.externalSurfaceSnapshot)
        return DedicatedDevicePrototypeProjection(
            clientContext: .bedsideRitualCompanion,
            thesisName: thesisName,
            titleTemplateKey: titleTemplateKey(for: glance),
            primaryReference: glance.primaryReference,
            todayPosture: glance.todayPosture,
            pressureLevel: glance.pressureLevel,
            openCaptureUrgency: glance.openCaptureUrgency,
            blockerSummary: glance.blockerSummary,
            ritualCue: glance.ritualCue,
            commandOptions: commandOptions(from: glance.supportedCommands),
            defaultFallbackRouteIntent: .returnToToday
        )
    }

    @MainActor
    func perform(
        _ command: ExternalActionCommand,
        projection: DedicatedDevicePrototypeProjection,
        now: Date
    ) async -> DedicatedDevicePrototypeActionResult {
        guard let option = projection.commandOption(for: command.kind) else {
            return DedicatedDevicePrototypeActionResult(disposition: .unsupported)
        }

        switch option.disposition {
        case .deviceSafeQuickAction:
            guard command.hasRequiredTarget(for: option.descriptor) else {
                return DedicatedDevicePrototypeActionResult(
                    disposition: .missingTarget,
                    runtimeResult: RuntimeActionResult(outcome: .missingTarget)
                )
            }
            let result = await actionExecutor.execute(command, now: now)
            return DedicatedDevicePrototypeActionResult(
                disposition: .deviceSafeQuickAction,
                runtimeResult: result
            )
        case .fallbackToPhone:
            guard let route = fallbackRouteIntent(for: command) else {
                return DedicatedDevicePrototypeActionResult(disposition: .missingTarget)
            }
            return DedicatedDevicePrototypeActionResult(
                disposition: .fallbackToPhone,
                fallbackRouteIntent: route
            )
        }
    }

    private static func titleTemplateKey(for glance: ExternalSurfaceGlanceState) -> String {
        if let ritualCue = glance.ritualCue {
            return ritualCue.templateKey
        }
        if glance.primaryReference != nil {
            return "device_bedside_next_step"
        }
        return "device_bedside_open_phone"
    }

    private static func commandOptions(
        from descriptors: [ExternalSurfaceCommandDescriptor]
    ) -> [DedicatedDevicePrototypeCommandOption] {
        descriptors.compactMap { descriptor in
            switch descriptor.kind {
            case .complete, .snooze:
                return DedicatedDevicePrototypeCommandOption(
                    descriptor: descriptor,
                    disposition: .deviceSafeQuickAction
                )
            case .openGoal, .openToday, .openCaptureComposer, .openMemoryLens:
                return DedicatedDevicePrototypeCommandOption(
                    descriptor: descriptor,
                    disposition: .fallbackToPhone
                )
            }
        }
    }

    private func fallbackRouteIntent(for command: ExternalActionCommand) -> RuntimeRouteIntent? {
        switch command.kind {
        case .openGoal:
            guard let goalID = command.target.goalID, goalID.isEmpty == false else {
                return nil
            }
            return .openGoal(id: goalID)
        case .openToday:
            return .returnToToday
        case .openCaptureComposer:
            return .composeCapture
        case .openMemoryLens:
            return .openMemoryLens
        case .complete, .delay, .snooze, .askForSmallerStep, .unsupported(_):
            return nil
        }
    }
}

private extension DedicatedDevicePrototypeProjection {
    func commandOption(for kind: ExternalActionKind) -> DedicatedDevicePrototypeCommandOption? {
        commandOptions.first { option in
            switch (kind, option.descriptor.kind) {
            case (.complete, .complete),
                 (.snooze, .snooze),
                 (.openGoal, .openGoal),
                 (.openToday, .openToday),
                 (.openCaptureComposer, .openCaptureComposer),
                 (.openMemoryLens, .openMemoryLens):
                return true
            case (.delay, _),
                 (.askForSmallerStep, _),
                 (.unsupported(_), _),
                 (.complete, _),
                 (.snooze, _),
                 (.openGoal, _),
                 (.openToday, _),
                 (.openCaptureComposer, _),
                 (.openMemoryLens, _):
                return false
            }
        }
    }
}

private extension ExternalActionCommand {
    func hasRequiredTarget(for descriptor: ExternalSurfaceCommandDescriptor) -> Bool {
        if descriptor.requiresGoalID {
            guard let goalID = target.goalID, goalID.isEmpty == false else {
                return false
            }
        }
        if descriptor.requiresStepID {
            guard let stepID = target.stepID, stepID.isEmpty == false else {
                return false
            }
        }
        return true
    }
}
