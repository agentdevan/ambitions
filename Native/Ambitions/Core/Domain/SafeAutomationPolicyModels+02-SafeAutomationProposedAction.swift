import Foundation

struct SafeAutomationProposedAction: Codable, Sendable, Equatable, Hashable {
    let kind: SafeAutomationActionKind
    let sourceDomain: ActionReceiptSourceDomain
    let targetObjects: [LifeGraphObjectReference]
    let sourceAllowsLocalMutation: Bool
    let schemaVersion: String

    init(
        kind: SafeAutomationActionKind,
        sourceDomain: ActionReceiptSourceDomain,
        targetObjects: [LifeGraphObjectReference] = [],
        sourceAllowsLocalMutation: Bool = true,
        schemaVersion: String = safeAutomationPolicySchemaVersion
    ) {
        self.kind = kind
        self.sourceDomain = sourceDomain
        self.targetObjects = targetObjects
        self.sourceAllowsLocalMutation = sourceAllowsLocalMutation
        self.schemaVersion = schemaVersion
    }
}

struct SafeAutomationPolicyEvaluator: Sendable {
    func evaluate(_ action: SafeAutomationProposedAction) -> SafeAutomationPolicyDecision {
        let hasTarget = action.targetObjects.contains(where: \.isWellFormed)

        if action.sourceAllowsLocalMutation == false {
            return decision(
                action,
                permission: .requiresConfirmation,
                confirmation: .requiredForExternalEffect,
                undo: .externalUndoUnavailable,
                safety: .externalEffect,
                reasons: [.unsupportedSource, .externalSideEffect],
                blockedFacts: ["The source may not silently change local data."],
                nextAction: ActionReceiptNextAction(kind: .dismiss, title: "Review in Ambitions"),
                receiptState: .needsConfirmation,
                receiptSafety: .confirmationRequired
            )
        }

        switch action.kind {
        case .noOp:
            return decision(
                action,
                permission: .suggestOnly,
                confirmation: .notRequired,
                undo: .notUndoable,
                safety: .safeLocal,
                reasons: [.noChangeNeeded],
                receiptState: .noOp
            )
        case .dismissSuggestion:
            return decision(
                action,
                permission: .executeLocalOnly,
                confirmation: .notRequired,
                undo: .notUndoable,
                safety: .safeLocal,
                reasons: [.localReversibleChange],
                receiptState: .noOp
            )
        case .createCapture, .routeCapture, .attachToGoal, .detachFromGoal, .archiveItem, .unarchiveItem, .markWaiting, .changePriority, .changeDeadline, .moveActionLater, .correctRecommendation, .editLocalNote:
            return localDecision(action, hasTarget: hasTarget)
        case .markDone:
            return localDecision(action, hasTarget: hasTarget, undo: .confirmationRequiredUndo)
        case .shrinkAction, .splitAction, .dropAction, .deferAction, .changeTimeWindow:
            return decision(
                action,
                permission: .requiresConfirmation,
                confirmation: .requiredForBroadReflow,
                undo: .confirmationRequiredUndo,
                safety: .broadPlanMutation,
                reasons: [.broadReflowMustBeConfirmed],
                degradedFacts: ["Plan changes are represented by policy only until a confirmed execution path exists."],
                nextAction: ActionReceiptNextAction(kind: .openTime, title: "Open Time", destination: .time),
                receiptState: .needsConfirmation,
                receiptSafety: .confirmationRequired
            )
        case .prepareCalendarBlock:
            return decision(
                action,
                permission: .prepareDraft,
                confirmation: .notRequired,
                undo: .notUndoable,
                safety: .confirmationGated,
                reasons: [.calendarIsPlanOwned, .localDraftOnly],
                degradedFacts: ["No calendar block is written by this policy."],
                nextAction: ActionReceiptNextAction(kind: .openTime, title: "Open Time", destination: .time),
                receiptState: .draftedPrepared,
                receiptSafety: .degraded
            )
        case .writeCalendarBlock:
            return decision(
                action,
                permission: .requiresConfirmation,
                confirmation: .requiredForExternalEffect,
                undo: .confirmationRequiredUndo,
                safety: .externalEffect,
                reasons: [.calendarIsPlanOwned, .externalSideEffect, .confirmationRequired],
                blockedFacts: ["No calendar data was changed."],
                nextAction: ActionReceiptNextAction(kind: .openTime, title: "Open Time", destination: .time),
                receiptState: .needsConfirmation,
                receiptSafety: .confirmationRequired
            )
        case .prepareExport:
            return decision(
                action,
                permission: .prepareDraft,
                confirmation: .notRequired,
                undo: .notUndoable,
                safety: .privacySensitive,
                reasons: [.privacySensitive, .localDraftOnly],
                degradedFacts: ["No export file is written by this policy."],
                receiptState: .exportedPrepared,
                receiptSafety: .degraded
            )
        case .performExport:
            return decision(
                action,
                permission: .requiresConfirmation,
                confirmation: .requiredForExternalEffect,
                undo: .externalUndoUnavailable,
                safety: .privacySensitive,
                reasons: [.privacySensitive, .externalSideEffect, .confirmationRequired],
                blockedFacts: ["No export was performed."],
                receiptState: .needsConfirmation,
                receiptSafety: .confirmationRequired
            )
        case .prepareSyncResolution:
            return decision(
                action,
                permission: .prepareDraft,
                confirmation: .required,
                undo: .notSupportedYet,
                safety: .unsupported,
                reasons: [.syncConflictRequiresReview, .notSupportedYet],
                blockedFacts: ["Sync resolution is not supported in this build."],
                receiptState: .failedSafely,
                receiptSafety: .safeFailure
            )
        case .applySyncResolution:
            return decision(
                action,
                permission: .notSupportedYet,
                confirmation: .notAllowed,
                undo: .notSupportedYet,
                safety: .unsupported,
                reasons: [.syncConflictRequiresReview, .notSupportedYet],
                blockedFacts: ["No sync conflict resolution was applied."],
                receiptState: .failedSafely,
                receiptSafety: .safeFailure
            )
        case .deleteObject:
            return decision(
                action,
                permission: .neverAutomate,
                confirmation: .requiredForDestructiveChange,
                undo: .destructiveUndoUnsafe,
                safety: .destructive,
                reasons: [.destructiveAction],
                blockedFacts: ["No object was deleted."],
                receiptState: .failedSafely,
                receiptSafety: .safeFailure
            )
        case .forgetMemory:
            return decision(
                action,
                permission: .neverAutomate,
                confirmation: .requiredForDestructiveChange,
                undo: .destructiveUndoUnsafe,
                safety: .privacySensitive,
                reasons: [.privacySensitive, .destructiveAction],
                blockedFacts: ["No memory was forgotten."],
                receiptState: .failedSafely,
                receiptSafety: .safeFailure
            )
        case .externalCommand:
            return decision(
                action,
                permission: .requiresConfirmation,
                confirmation: .requiredForExternalEffect,
                undo: .externalUndoUnavailable,
                safety: .externalEffect,
                reasons: [.externalSideEffect, .confirmationRequired],
                blockedFacts: ["No external command was executed."],
                receiptState: .needsConfirmation,
                receiptSafety: .confirmationRequired
            )
        }
    }

    func localDecision(
        _ action: SafeAutomationProposedAction,
        hasTarget: Bool,
        undo: SafeAutomationUndoRule = .safeLocalUndo
    ) -> SafeAutomationPolicyDecision {
        if action.kind != .createCapture && action.kind != .correctRecommendation && action.kind != .dismissSuggestion && hasTarget == false {
            return decision(
                action,
                permission: .notSupportedYet,
                confirmation: .notAllowed,
                undo: .notSupportedYet,
                safety: .unsupported,
                reasons: [.noTargetObject],
                blockedFacts: ["No target object was provided."],
                receiptState: .failedSafely,
                receiptSafety: .safeFailure
            )
        }
        return decision(
            action,
            permission: .executeLocalOnly,
            confirmation: .notRequired,
            undo: undo,
            safety: undo == .safeLocalUndo ? .reversibleLocal : .confirmationGated,
            reasons: [.localReversibleChange],
            receiptState: .changed
        )
    }

    func decision(
        _ action: SafeAutomationProposedAction,
        permission: SafeAutomationPermissionLevel,
        confirmation: SafeAutomationConfirmationRequirement,
        undo: SafeAutomationUndoRule,
        safety: SafeAutomationSafetyClassification,
        reasons: [SafeAutomationPolicyReason],
        blockedFacts: [String] = [],
        degradedFacts: [String] = [],
        nextAction: ActionReceiptNextAction? = nil,
        receiptState: ActionReceiptResultState,
        receiptSafety: ActionReceiptSafetyState = .normal
    ) -> SafeAutomationPolicyDecision {
        SafeAutomationPolicyDecision(
            actionKind: action.kind,
            sourceDomain: action.sourceDomain,
            targetObjects: action.targetObjects,
            permissionLevel: permission,
            confirmationRequirement: confirmation,
            undoRule: undo,
            safetyClassification: safety,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts,
            suggestedNextSafeAction: nextAction,
            receiptRecommendation: SafeAutomationReceiptRecommendation(
                resultState: receiptState,
                undoAvailability: undo.actionReceiptUndoAvailability,
                correctionAvailability: correctionAvailability(permission: permission, receiptState: receiptState),
                safetyState: receiptSafety
            )
        )
    }

    func correctionAvailability(
        permission: SafeAutomationPermissionLevel,
        receiptState: ActionReceiptResultState
    ) -> ActionReceiptCorrectionAvailability {
        switch permission {
        case .executeLocalOnly, .requiresConfirmation, .neverAutomate, .notSupportedYet:
            return .availableWithReason
        case .suggestOnly, .prepareDraft:
            return receiptState == .noOp ? .unavailable : .availableWithReason
        }
    }
}

extension SafeAutomationProposedAction {
    static func fromCommand(_ command: AmbitionsCommand) -> SafeAutomationProposedAction {
        SafeAutomationProposedAction(
            kind: SafeAutomationActionKind(command: command),
            sourceDomain: ActionReceiptSourceDomain(commandSource: command.source),
            targetObjects: LifeGraphObjectReference.commandTargets(command),
            sourceAllowsLocalMutation: command.source.allowsSilentLocalPolicyConsideration
        )
    }
}

extension SafeAutomationActionKind {
    init(command: AmbitionsCommand) {
        switch command.kind {
        case .openDestination, .askWhy:
            self = .noOp
        case .quickCapture:
            self = .createCapture
        case .createGoal:
            self = .attachToGoal
        case .updateGoal:
            self = .editLocalNote
        case .attachToGoal:
            self = .attachToGoal
        case .createTimeItem:
            self = .routeCapture
        case .scheduleItem:
            self = command.payload.metadata["calendarWriteIntent"] == "true" ? .writeCalendarBlock : .prepareCalendarBlock
        case .prepareExport:
            self = .prepareExport
        case .performExport:
            self = .performExport
        case .deleteObject:
            self = .deleteObject
        case .forgetMemory:
            self = .forgetMemory
        case .startStepSession:
            self = .noOp
        case .completeAction:
            self = .markDone
        case .delayAction:
            self = .moveActionLater
        case .splitAction:
            self = .splitAction
        case .recoverAction:
            self = .deferAction
        case .markWaiting:
            self = .markWaiting
        case .archiveItem:
            self = .archiveItem
        case .setPriority, .setUrgency:
            self = .changePriority
        case .setDeadline:
            self = .changeDeadline
        case .setContextLens, .clearContextLensOverride:
            self = .correctRecommendation
        case .routeCommitment:
            self = .routeCapture
        case .addDeliverable, .addGoalScopeItem:
            self = .attachToGoal
        case .removeDeliverable, .removeGoalScopeItem:
            self = .dropAction
        case .dismissRecommendation:
            self = .dismissSuggestion
        }
    }
}
