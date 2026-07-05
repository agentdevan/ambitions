import Foundation

enum AppIntentCommandRoutingClassification: String, Codable, Sendable, Equatable {
    case projectionQuery = "projection_query"
    case captureCommand = "capture_command"
    case actionCommand = "action_command"
    case unsafe
    case unknown
}

enum AppIntentCommandRoutingBoundary: String, Codable, Sendable, Equatable {
    case none
    case queuesLocalCreation = "queues_local_creation"
    case opensAppForAction = "opens_app_for_action"
    case requiresInAppConfirmation = "requires_in_app_confirmation"
    case unsafeDirectMutation = "unsafe_direct_mutation"
    case unknown
}

struct AppIntentCommandRoutingRecord: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let intentTypeName: String
    let routeID: String
    let classification: AppIntentCommandRoutingClassification
    let boundary: AppIntentCommandRoutingBoundary
    let commandKind: AmbitionsCommandKind?
    let routeURLString: String?
    let producesReceipt: Bool
    let evidence: [String]

    var isUnsafeOrUnknownMutatingRoute: Bool {
        switch boundary {
        case .unsafeDirectMutation, .unknown:
            return true
        case .none, .queuesLocalCreation, .opensAppForAction, .requiresInAppConfirmation:
            return false
        }
    }
}

enum AppIntentCommandRoutingInventory {
    static let records: [AppIntentCommandRoutingRecord] = [
        AppIntentCommandRoutingRecord(
            id: "create-capture",
            intentTypeName: "CreateAmbitionsCaptureIntent",
            routeID: "capture",
            classification: .captureCommand,
            boundary: .queuesLocalCreation,
            commandKind: .quickCapture,
            routeURLString: "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent",
            producesReceipt: true,
            evidence: [
                "CreateAmbitionsCaptureIntent.makeCaptureRequest trims and rejects empty text.",
                "AppIntentBridge.enqueueExternalCreation stores local review input and records a local-only receipt.",
                "DefaultExternalCreationImportService imports later through AmbitionsCommand quickCapture.",
            ]
        ),
        AppIntentCommandRoutingRecord(
            id: "create-goal-draft",
            intentTypeName: "CreateAmbitionsGoalDraftIntent",
            routeID: "goal-draft",
            classification: .captureCommand,
            boundary: .queuesLocalCreation,
            commandKind: .createGoal,
            routeURLString: "ambitions://overlay/quiet-command-sheet?origin=app_intent",
            producesReceipt: true,
            evidence: [
                "CreateAmbitionsGoalDraftIntent.makeGoalDraftRequest trims and rejects empty text.",
                "Goal draft intent uses AppIntentBridge local-only intake before command-backed import.",
            ]
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.today",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "today",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/today?origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.goals",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "goals",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/goals?origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.time",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "time",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/time?origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.capture",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "capture",
            classification: .captureCommand,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.you",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "you",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/you?origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.command",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "command",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://overlay/quiet-command-sheet?origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.memory_lens",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "memory_lens",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://overlay/memory-lens?intent=memory_lens&origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.quick_capture",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "quick_capture",
            classification: .captureCommand,
            boundary: .queuesLocalCreation,
            commandKind: .quickCapture,
            routeURLString: "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent",
            producesReceipt: true,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.start_next_step",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "start_next_step",
            classification: .actionCommand,
            boundary: .opensAppForAction,
            commandKind: .startStepSession,
            routeURLString: "ambitions://tab/today?context=focus&origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.mark_done",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "mark_done",
            classification: .actionCommand,
            boundary: .requiresInAppConfirmation,
            commandKind: .completeAction,
            routeURLString: "ambitions://tab/today?context=focus&origin=app_intent",
            producesReceipt: true,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.save_the_day",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "save_the_day",
            classification: .actionCommand,
            boundary: .requiresInAppConfirmation,
            commandKind: .recoverAction,
            routeURLString: "ambitions://tab/today?context=recovery&origin=app_intent",
            producesReceipt: true,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.quick_recovery",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "quick_recovery",
            classification: .actionCommand,
            boundary: .requiresInAppConfirmation,
            commandKind: .recoverAction,
            routeURLString: "ambitions://tab/today?context=recovery&origin=app_intent",
            producesReceipt: true,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.quick_focus",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "quick_focus",
            classification: .actionCommand,
            boundary: .opensAppForAction,
            commandKind: .startStepSession,
            routeURLString: "ambitions://tab/today?context=focus&origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "destination.quick_time_patch",
            intentTypeName: "OpenAmbitionsDestinationIntent",
            routeID: "quick_time_patch",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/time?origin=app_intent",
            producesReceipt: false,
            evidence: destinationEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "system-control.start_now",
            intentTypeName: "OpenAmbitionsSystemControlIntent",
            routeID: "start_now",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/today?origin=app_intent",
            producesReceipt: false,
            evidence: systemControlEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "system-control.capture",
            intentTypeName: "OpenAmbitionsSystemControlIntent",
            routeID: "capture",
            classification: .captureCommand,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent",
            producesReceipt: false,
            evidence: systemControlEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "system-control.still_counts",
            intentTypeName: "OpenAmbitionsSystemControlIntent",
            routeID: "still_counts",
            classification: .actionCommand,
            boundary: .requiresInAppConfirmation,
            commandKind: .completeAction,
            routeURLString: "ambitions://tab/today?origin=app_intent",
            producesReceipt: true,
            evidence: systemControlEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "system-control.add_proof",
            intentTypeName: "OpenAmbitionsSystemControlIntent",
            routeID: "add_proof",
            classification: .actionCommand,
            boundary: .requiresInAppConfirmation,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/today?origin=app_intent",
            producesReceipt: true,
            evidence: systemControlEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "system-control.open_current_step",
            intentTypeName: "OpenAmbitionsSystemControlIntent",
            routeID: "open_current_step",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://tab/today?origin=app_intent",
            producesReceipt: false,
            evidence: systemControlEvidence
        ),
        AppIntentCommandRoutingRecord(
            id: "deep-action.open-current-step",
            intentTypeName: "OpenAmbitionsCurrentStepIntent",
            routeID: "open-current-step",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://goal/goal-placeholder?origin=app_intent&stepID=step-placeholder",
            producesReceipt: false,
            evidence: deepActionEvidence("OpenAmbitionsCurrentStepIntent")
        ),
        AppIntentCommandRoutingRecord(
            id: "deep-action.start-current-step",
            intentTypeName: "StartAmbitionsCurrentStepIntent",
            routeID: "start-current-step",
            classification: .actionCommand,
            boundary: .opensAppForAction,
            commandKind: .startStepSession,
            routeURLString: "ambitions://tab/today?context=focus&origin=app_intent",
            producesReceipt: false,
            evidence: deepActionEvidence("StartAmbitionsCurrentStepIntent")
        ),
        AppIntentCommandRoutingRecord(
            id: "deep-action.guarded-close-step",
            intentTypeName: "GuardedCloseAmbitionsStepIntent",
            routeID: "guarded-close-step",
            classification: .actionCommand,
            boundary: .requiresInAppConfirmation,
            commandKind: .completeAction,
            routeURLString: "ambitions://goal/goal-placeholder?origin=app_intent&stepID=step-placeholder",
            producesReceipt: true,
            evidence: deepActionEvidence("GuardedCloseAmbitionsStepIntent")
        ),
        AppIntentCommandRoutingRecord(
            id: "deep-action.show-receipt",
            intentTypeName: "ShowAmbitionsReceiptIntent",
            routeID: "show-receipt",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://overlay/memory-lens?intent=memory_lens&q=receipt:receipt-placeholder&origin=app_intent",
            producesReceipt: false,
            evidence: deepActionEvidence("ShowAmbitionsReceiptIntent")
        ),
        AppIntentCommandRoutingRecord(
            id: "deep-action.inspect-local-knowledge",
            intentTypeName: "InspectAmbitionsLocalKnowledgeIntent",
            routeID: "inspect-local-knowledge",
            classification: .projectionQuery,
            boundary: .opensAppForAction,
            commandKind: .openDestination,
            routeURLString: "ambitions://overlay/memory-lens?intent=memory_lens&q=topic-placeholder&origin=app_intent",
            producesReceipt: false,
            evidence: deepActionEvidence("InspectAmbitionsLocalKnowledgeIntent")
        ),
    ]

    static var unsafeOrUnknownMutatingRecords: [AppIntentCommandRoutingRecord] {
        records.filter(\.isUnsafeOrUnknownMutatingRoute)
    }

    static var currentIntentTypeNames: Set<String> {
        Set(records.map(\.intentTypeName))
    }

    private static let destinationEvidence = [
        "AmbitionsAppShortcutDestination.d25CommandDescriptor defines command kind, privacy summary, receipt posture, and route URL.",
        "OpenAmbitionsDestinationIntent queues only an app route URL; it does not write private graph state.",
    ]

    private static let systemControlEvidence = [
        "ExternalSurfaceControlContract defines execution mode, receipt posture, required object IDs, and redacted privacy summary.",
        "OpenAmbitionsSystemControlIntent queues the contract deep link; mutating controls require in-app confirmation.",
    ]

    private static func deepActionEvidence(_ intentTypeName: String) -> [String] {
        [
            "AmbitionsDeepActionShortcut.descriptor defines command kind, route URL, receipt posture, and privacy summary.",
            "\(intentTypeName) queues a safe app route and does not directly mutate private graph state.",
        ]
    }
}
