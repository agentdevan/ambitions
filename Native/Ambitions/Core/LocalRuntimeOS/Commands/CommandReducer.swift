import Foundation

let commandMutationPlanSchemaVersion = "command_mutation_plan.native.v1"

enum CommandMutationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readOnlyInspect = "read_only_inspect"
    case runtimeMutation = "runtime_mutation"
    case externalSideEffect = "external_side_effect"
    case export
    case destructive
    case unsupported
}

enum CommandSideEffectPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case localOnly = "local_only"
    case requiresUserConfirmation = "requires_user_confirmation"
    case outboxRequired = "outbox_required"
    case prohibited
}

enum CommandRequiredConfirmation: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notRequired = "not_required"
    case requiredBeforeMutation = "required_before_mutation"
    case alreadyConfirmed = "already_confirmed"
}

struct CommandFallback: Codable, Sendable, Equatable, Hashable {
    let kind: String
    let summary: String

    init(kind: String, summary: String) {
        self.kind = kind
        self.summary = summary
    }
}

struct CommandUndoShape: Codable, Sendable, Equatable, Hashable {
    let kind: String
    let summary: String
    let target: AmbitionsCommandTarget

    init(kind: String, summary: String, target: AmbitionsCommandTarget) {
        self.kind = kind
        self.summary = summary
        self.target = target
    }
}

struct CommandMutationPlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let mutationKind: CommandMutationKind
    let target: AmbitionsCommandTarget
    let expectedProjectionIDs: [String]
    let sideEffectPolicy: CommandSideEffectPolicy
    let requiredConfirmation: CommandRequiredConfirmation
    let fallback: CommandFallback
    let undoShape: CommandUndoShape
    let canMutate: Bool
    let reasonCodes: [String]
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        validation: AmbitionsCommandValidationState,
        mutationKind: CommandMutationKind,
        expectedProjectionIDs: [ProjectionID],
        sideEffectPolicy: CommandSideEffectPolicy,
        requiredConfirmation: CommandRequiredConfirmation,
        fallback: CommandFallback,
        undoShape: CommandUndoShape,
        reasonCodes: [String] = [],
        schemaVersion: String = commandMutationPlanSchemaVersion
    ) {
        self.id = "command.mutation-plan.\(command.id)"
        self.commandID = command.id
        self.mutationKind = mutationKind
        self.target = command.target
        self.expectedProjectionIDs = Array(Set(expectedProjectionIDs.map(\.rawValue))).sorted()
        self.sideEffectPolicy = sideEffectPolicy
        self.requiredConfirmation = requiredConfirmation
        self.fallback = fallback
        self.undoShape = undoShape
        self.canMutate = validation == .valid && mutationKind != .readOnlyInspect && mutationKind != .unsupported
        self.reasonCodes = Array(Set(reasonCodes.filter { $0.isEmpty == false })).sorted()
        self.schemaVersion = schemaVersion
    }
}

struct CommandReducer: Sendable {
    func reduce(
        command: AmbitionsCommand,
        validation: AmbitionsCommandValidationState
    ) -> CommandMutationPlan {
        let mutationKind = mutationKind(for: command)
        return CommandMutationPlan(
            command: command,
            validation: validation,
            mutationKind: mutationKind,
            expectedProjectionIDs: expectedProjectionIDs(for: command, mutationKind: mutationKind),
            sideEffectPolicy: sideEffectPolicy(for: command, mutationKind: mutationKind),
            requiredConfirmation: requiredConfirmation(for: command, mutationKind: mutationKind),
            fallback: fallback(for: command, validation: validation, mutationKind: mutationKind),
            undoShape: undoShape(for: command, mutationKind: mutationKind),
            reasonCodes: reasonCodes(for: command, validation: validation, mutationKind: mutationKind)
        )
    }

    private func mutationKind(for command: AmbitionsCommand) -> CommandMutationKind {
        switch command.typedPayload {
        case .capture, .goal, .step, .profile, .repair, .attachment:
            return .runtimeMutation
        case .compensation:
            return .unsupported
        case let .schedule(schedule):
            if case let .calendarWrite(intent) = schedule.action {
                return intent.operationIdentityProvenance == .currentRequired ? .externalSideEffect : .runtimeMutation
            }
            return .runtimeMutation
        case .reminder, .externalOperation:
            return .externalSideEffect
        case let .history(history):
            switch history.action {
            case .openDestination, .askWhy, .dismissRecommendation: return .readOnlyInspect
            case .todayReceipt: return .runtimeMutation
            }
        case let .importDeletion(value):
            switch value.action {
            case .prepareExport, .performExport: return .export
            case .deleteObject, .forgetMemory: return .destructive
            }
        }
    }

    private func expectedProjectionIDs(
        for command: AmbitionsCommand,
        mutationKind: CommandMutationKind
    ) -> [ProjectionID] {
        var projections: Set<ProjectionID> = [.receipt, .privacy]
        if mutationKind != .readOnlyInspect {
            projections.insert(.search)
            projections.insert(.widget)
            projections.insert(.appIntent)
        }
        switch command.target.destination {
        case .today:
            projections.insert(.today)
        case .goals, .goalDetail:
            projections.insert(.goals)
        case .time:
            projections.insert(.time)
        case .you:
            projections.insert(.you)
        case .capture, .captureInbox, .reviews, .memoryLens, .commandSheet, .weeklyReview, .none:
            break
        }
        switch command.source {
        case .today, .capture, .widget, .liveActivity, .appIntent, .notification, .deepLink, .system:
            projections.insert(.today)
        case .goals, .goalDetail:
            projections.insert(.goals)
        case .time:
            projections.insert(.time)
        case .you:
            projections.insert(.you)
        case .reviews:
            break
        }
        if command.target.goalID != nil || command.target.stepID != nil ||
            command.target.deliverableID != nil || command.target.scopeItemID != nil {
            projections.insert(.goals)
        }
        if command.target.timeID != nil {
            projections.insert(.time)
        }
        return projections.sorted()
    }

    private func sideEffectPolicy(
        for command: AmbitionsCommand,
        mutationKind: CommandMutationKind
    ) -> CommandSideEffectPolicy {
        switch mutationKind {
        case .readOnlyInspect:
            return .none
        case .externalSideEffect:
            return .requiresUserConfirmation
        case .export, .destructive:
            return .requiresUserConfirmation
        case .runtimeMutation:
            return .localOnly
        case .unsupported:
            return .prohibited
        }
    }

    private func requiredConfirmation(
        for command: AmbitionsCommand,
        mutationKind: CommandMutationKind
    ) -> CommandRequiredConfirmation {
        switch mutationKind {
        case .externalSideEffect, .export, .destructive:
            return .requiredBeforeMutation
        case .readOnlyInspect, .runtimeMutation, .unsupported:
            return .notRequired
        }
    }

    private func fallback(
        for command: AmbitionsCommand,
        validation: AmbitionsCommandValidationState,
        mutationKind: CommandMutationKind
    ) -> CommandFallback {
        if validation != .valid {
            return CommandFallback(
                kind: "blocked_without_mutation",
                summary: "Preserve local state and return validation status \(validation.rawValue)."
            )
        }
        switch mutationKind {
        case .readOnlyInspect:
            return CommandFallback(kind: "route_only", summary: "Open or inspect without changing runtime state.")
        case .externalSideEffect:
            return CommandFallback(kind: "local_receipt_only", summary: "Keep the local receipt and skip external effect when policy blocks it.")
        case .export:
            return CommandFallback(kind: "export_review", summary: "Require explicit review before export work proceeds.")
        case .destructive:
            return CommandFallback(kind: "destructive_review", summary: "Require explicit review before destructive work proceeds.")
        case .runtimeMutation:
            return CommandFallback(kind: "no_apply", summary: "Skip mutation and keep the command receipt inspectable.")
        case .unsupported:
            return CommandFallback(kind: "unsupported", summary: "Keep source state unchanged because the owner is not executable.")
        }
    }

    private func undoShape(
        for command: AmbitionsCommand,
        mutationKind: CommandMutationKind
    ) -> CommandUndoShape {
        switch mutationKind {
        case .readOnlyInspect:
            return CommandUndoShape(kind: "not_required", summary: "No runtime state changed.", target: command.target)
        case .externalSideEffect:
            return CommandUndoShape(kind: "outbox_cancel", summary: "Cancel queued side effect before delivery when available.", target: command.target)
        case .export:
            return CommandUndoShape(kind: "discard_export", summary: "Discard generated export package before sharing.", target: command.target)
        case .destructive:
            return CommandUndoShape(kind: "restore_from_receipt", summary: "Restore from the local receipt and tombstone lineage.", target: command.target)
        case .runtimeMutation:
            return CommandUndoShape(kind: "receipt_backed_undo", summary: "Use the command receipt and runtime event to reverse the local mutation.", target: command.target)
        case .unsupported:
            return CommandUndoShape(kind: "not_available", summary: "No undo is available because no mutation was applied.", target: command.target)
        }
    }

    private func reasonCodes(
        for command: AmbitionsCommand,
        validation: AmbitionsCommandValidationState,
        mutationKind: CommandMutationKind
    ) -> [String] {
        var reasons: [String] = []
        if validation != .valid {
            reasons.append(validation.rawValue)
        }
        if mutationKind == .externalSideEffect, command.calendarWriteCommandIntent?.userConfirmed != true {
            reasons.append("confirmation_required")
        }
        if mutationKind == .export || mutationKind == .destructive {
            reasons.append("review_required")
        }
        return reasons
    }
}
