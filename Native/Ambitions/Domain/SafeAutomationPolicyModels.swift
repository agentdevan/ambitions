import Foundation

let safeAutomationPolicySchemaVersion = "safe_automation_policy.native.v1"

enum SafeAutomationActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case createCapture = "create_capture"
    case routeCapture = "route_capture"
    case attachToGoal = "attach_to_goal"
    case detachFromGoal = "detach_from_goal"
    case archiveItem = "archive_item"
    case unarchiveItem = "unarchive_item"
    case markWaiting = "mark_waiting"
    case markDone = "mark_done"
    case moveActionLater = "move_action_later"
    case changePriority = "change_priority"
    case changeDeadline = "change_deadline"
    case changePlanWindow = "change_plan_window"
    case shrinkAction = "shrink_action"
    case splitAction = "split_action"
    case dropAction = "drop_action"
    case deferAction = "defer_action"
    case prepareCalendarBlock = "prepare_calendar_block"
    case writeCalendarBlock = "write_calendar_block"
    case prepareExport = "prepare_export"
    case performExport = "perform_export"
    case prepareSyncResolution = "prepare_sync_resolution"
    case applySyncResolution = "apply_sync_resolution"
    case deleteObject = "delete_object"
    case forgetMemory = "forget_memory"
    case externalCommand = "external_command"
    case correctRecommendation = "correct_recommendation"
    case editLocalNote = "edit_local_note"
    case dismissSuggestion = "dismiss_suggestion"
    case noOp = "no_op"
}

enum SafeAutomationPermissionLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case suggestOnly = "suggest_only"
    case prepareDraft = "prepare_draft"
    case requiresConfirmation = "requires_confirmation"
    case executeLocalOnly = "execute_local_only"
    case neverAutomate = "never_automate"
    case notSupportedYet = "not_supported_yet"
}

enum SafeAutomationConfirmationRequirement: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notRequired = "not_required"
    case required
    case requiredForExternalEffect = "required_for_external_effect"
    case requiredForDestructiveChange = "required_for_destructive_change"
    case requiredForBroadReflow = "required_for_broad_reflow"
    case notAllowed = "not_allowed"
}

enum SafeAutomationSafetyClassification: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safeLocal = "safe_local"
    case reversibleLocal = "reversible_local"
    case confirmationGated = "confirmation_gated"
    case externalEffect = "external_effect"
    case destructive
    case privacySensitive = "privacy_sensitive"
    case broadPlanMutation = "broad_plan_mutation"
    case unsupported
    case unsafe
}

enum SafeAutomationUndoRule: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safeLocalUndo = "safe_local_undo"
    case confirmationRequiredUndo = "confirmation_required_undo"
    case externalUndoUnavailable = "external_undo_unavailable"
    case destructiveUndoUnsafe = "destructive_undo_unsafe"
    case notUndoable = "not_undoable"
    case notSupportedYet = "not_supported_yet"

    var actionReceiptUndoAvailability: ActionReceiptUndoAvailability {
        switch self {
        case .safeLocalUndo:
            return .availableLocal
        case .confirmationRequiredUndo:
            return .requiresConfirmation
        case .externalUndoUnavailable, .notUndoable:
            return .unavailable
        case .destructiveUndoUnsafe:
            return .unsafe
        case .notSupportedYet:
            return .notSupportedYet
        }
    }
}

enum SafeAutomationPolicyReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localReversibleChange = "local_reversible_change"
    case localDraftOnly = "local_draft_only"
    case externalSideEffect = "external_side_effect"
    case calendarIsPlanOwned = "calendar_is_plan_owned"
    case destructiveAction = "destructive_action"
    case privacySensitive = "privacy_sensitive"
    case syncConflictRequiresReview = "sync_conflict_requires_review"
    case broadReflowMustBeConfirmed = "broad_reflow_must_be_confirmed"
    case notSupportedYet = "not_supported_yet"
    case noTargetObject = "no_target_object"
    case unsupportedSource = "unsupported_source"
    case noChangeNeeded = "no_change_needed"
    case confirmationRequired = "confirmation_required"

    var userFacingSummary: String {
        switch self {
        case .localReversibleChange:
            return "This is a local change that can be undone safely."
        case .localDraftOnly:
            return "This can be prepared as a draft without changing anything."
        case .externalSideEffect:
            return "This would affect something outside Ambitions."
        case .calendarIsPlanOwned:
            return "Calendar changes must be confirmed from Plan."
        case .destructiveAction:
            return "This could permanently remove or damage information."
        case .privacySensitive:
            return "This touches private information and needs review."
        case .syncConflictRequiresReview:
            return "This conflict needs review before anything changes."
        case .broadReflowMustBeConfirmed:
            return "This would change more than one part of the plan."
        case .notSupportedYet:
            return "This is not supported in this build."
        case .noTargetObject:
            return "Ambitions needs a specific item before changing anything."
        case .unsupportedSource:
            return "This source is not allowed to make that change."
        case .noChangeNeeded:
            return "Nothing needs to change."
        case .confirmationRequired:
            return "This needs confirmation before anything changes."
        }
    }
}

struct SafeAutomationReceiptRecommendation: Codable, Sendable, Equatable, Hashable {
    let resultState: ActionReceiptResultState
    let undoAvailability: ActionReceiptUndoAvailability
    let correctionAvailability: ActionReceiptCorrectionAvailability
    let safetyState: ActionReceiptSafetyState

    init(
        resultState: ActionReceiptResultState,
        undoAvailability: ActionReceiptUndoAvailability,
        correctionAvailability: ActionReceiptCorrectionAvailability,
        safetyState: ActionReceiptSafetyState
    ) {
        self.resultState = resultState
        self.undoAvailability = undoAvailability
        self.correctionAvailability = correctionAvailability
        self.safetyState = safetyState
    }
}

struct SafeAutomationPolicyDecision: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let actionKind: SafeAutomationActionKind
    let sourceDomain: ActionReceiptSourceDomain
    let targetObjects: [LifeGraphObjectReference]
    let permissionLevel: SafeAutomationPermissionLevel
    let confirmationRequirement: SafeAutomationConfirmationRequirement
    let undoRule: SafeAutomationUndoRule
    let safetyClassification: SafeAutomationSafetyClassification
    let reasons: [SafeAutomationPolicyReason]
    let blockedFacts: [String]
    let degradedFacts: [String]
    let suggestedNextSafeAction: ActionReceiptNextAction?
    let receiptRecommendation: SafeAutomationReceiptRecommendation
    let schemaVersion: String

    init(
        actionKind: SafeAutomationActionKind,
        sourceDomain: ActionReceiptSourceDomain,
        targetObjects: [LifeGraphObjectReference] = [],
        permissionLevel: SafeAutomationPermissionLevel,
        confirmationRequirement: SafeAutomationConfirmationRequirement,
        undoRule: SafeAutomationUndoRule,
        safetyClassification: SafeAutomationSafetyClassification,
        reasons: [SafeAutomationPolicyReason],
        blockedFacts: [String] = [],
        degradedFacts: [String] = [],
        suggestedNextSafeAction: ActionReceiptNextAction? = nil,
        receiptRecommendation: SafeAutomationReceiptRecommendation,
        schemaVersion: String = safeAutomationPolicySchemaVersion
    ) {
        let validTargets = Self.validOrderedUniqueTargets(targetObjects)
        self.actionKind = actionKind
        self.sourceDomain = sourceDomain
        self.targetObjects = validTargets
        self.permissionLevel = permissionLevel
        self.confirmationRequirement = confirmationRequirement
        self.undoRule = undoRule
        self.safetyClassification = safetyClassification
        self.reasons = Self.orderedUniqueReasons(reasons)
        self.blockedFacts = Self.normalizedUnique(blockedFacts)
        self.degradedFacts = Self.normalizedUnique(degradedFacts)
        self.suggestedNextSafeAction = suggestedNextSafeAction
        self.receiptRecommendation = receiptRecommendation
        self.schemaVersion = schemaVersion
        self.id = Self.decisionID(actionKind: actionKind, sourceDomain: sourceDomain, targetObjects: validTargets)
    }

    var requiresExplicitUserConfirmation: Bool {
        confirmationRequirement != .notRequired
    }

    var mustNeverBeSilent: Bool {
        switch permissionLevel {
        case .suggestOnly, .prepareDraft, .executeLocalOnly:
            return requiresExplicitUserConfirmation || safetyClassification != .safeLocal && safetyClassification != .reversibleLocal
        case .requiresConfirmation, .neverAutomate, .notSupportedYet:
            return true
        }
    }

    var isAllowedForFutureLocalExecution: Bool {
        permissionLevel == .executeLocalOnly && confirmationRequirement == .notRequired
    }

    func recommendedReceipt(occurredAt: String) -> ActionReceipt {
        let affectedObjects = targetObjects.isEmpty ? [policyObjectReference] : targetObjects
        let failure = safeFailureIfNeeded(affectedObjects: affectedObjects)
        return ActionReceipt(
            id: "receipt.policy.\(id)",
            resultState: receiptRecommendation.resultState,
            title: receiptTitle,
            summary: receiptSummary,
            sourceDomain: sourceDomain,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects,
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact.policy.\(id)",
                    kind: changedFactKind,
                    object: affectedObjects.first,
                    summary: receiptSummary
                )
            ],
            why: ActionReceiptWhyExplanation(body: reasons.map(\.userFacingSummary).joined(separator: " ")),
            nextAction: suggestedNextSafeAction,
            correctionAvailability: receiptRecommendation.correctionAvailability,
            undoAvailability: receiptRecommendation.undoAvailability,
            safetyState: receiptRecommendation.safetyState,
            safeFailure: failure,
            sourceObject: policyObjectReference
        )
    }

    private var policyObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .action,
            id: id,
            label: actionKind.rawValue,
            sourceDomain: .system
        )
    }

    private var receiptTitle: String {
        switch receiptRecommendation.resultState {
        case .needsConfirmation:
            return "Confirmation needed"
        case .failedSafely:
            return "Action did not change anything"
        case .draftedPrepared, .exportedPrepared:
            return "Draft prepared"
        case .noOp:
            return "Nothing changed"
        default:
            return "Action checked"
        }
    }

    private var receiptSummary: String {
        if receiptRecommendation.resultState == .failedSafely {
            return "No automation ran and no data changed."
        }
        if receiptRecommendation.resultState == .needsConfirmation {
            return "Ambitions needs confirmation before anything changes."
        }
        if receiptRecommendation.resultState == .draftedPrepared || receiptRecommendation.resultState == .exportedPrepared {
            return "A draft can be prepared without changing anything."
        }
        if receiptRecommendation.resultState == .noOp {
            return "No change was needed."
        }
        return "This action is allowed by local policy, but the current runtime keeps it as a receipt-only outcome."
    }

    private var changedFactKind: ActionReceiptChangedFactKind {
        switch receiptRecommendation.resultState {
        case .failedSafely:
            return .failedSafely
        case .needsConfirmation:
            return .needsConfirmation
        case .draftedPrepared, .exportedPrepared:
            return .preparedDraft
        case .noOp:
            return .noChange
        default:
            return .changedField
        }
    }

    private func safeFailureIfNeeded(affectedObjects: [LifeGraphObjectReference]) -> ActionReceiptSafeFailure? {
        guard receiptRecommendation.resultState == .failedSafely || receiptRecommendation.safetyState == .safeFailure else {
            return nil
        }
        let unchanged = ["No automation ran.", "No undo ran.", "No calendar, export, sync, external, or destructive data changed."]
        return ActionReceiptSafeFailure(
            whatFailed: receiptTitle,
            whyFailed: reasons.first?.userFacingSummary,
            unchangedFacts: unchanged,
            nextSafeAction: suggestedNextSafeAction ?? ActionReceiptNextAction(kind: .dismiss, title: "Dismiss")
        )
    }

    private static func decisionID(
        actionKind: SafeAutomationActionKind,
        sourceDomain: ActionReceiptSourceDomain,
        targetObjects: [LifeGraphObjectReference]
    ) -> String {
        let targetKey = targetObjects.map(\.stableKey).joined(separator: ".")
        let raw = [actionKind.rawValue, sourceDomain.rawValue, targetKey.isEmpty ? "no_target" : targetKey]
            .joined(separator: ".")
        return raw
            .replacingOccurrences(of: ":", with: ".")
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }

    private static func validOrderedUniqueTargets(_ targets: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return targets
            .filter(\.isWellFormed)
            .filter { seen.insert($0.stableKey).inserted }
            .sorted { lhs, rhs in lhs.stableKey < rhs.stableKey }
    }

    private static func orderedUniqueReasons(_ reasons: [SafeAutomationPolicyReason]) -> [SafeAutomationPolicyReason] {
        var seen = Set<SafeAutomationPolicyReason>()
        return reasons.filter { seen.insert($0).inserted }
    }

    private static func normalizedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

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
        case .shrinkAction, .splitAction, .dropAction, .deferAction, .changePlanWindow:
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

    private func localDecision(
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

    private func decision(
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

    private func correctionAvailability(
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

private extension ActionReceiptSourceDomain {
    init(commandSource: AmbitionsCommandSource) {
        switch commandSource {
        case .today:
            self = .today
        case .goals:
            self = .goals
        case .capture:
            self = .capture
        case .time:
            self = .time
        case .you:
            self = .you
        case .reviews:
            self = .reviews
        case .goalDetail:
            self = .goalDetail
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            self = .externalSurface
        case .system:
            self = .system
        }
    }
}

private extension AmbitionsCommandSource {
    var allowsSilentLocalPolicyConsideration: Bool {
        switch self {
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            return false
        case .today, .goals, .capture, .time, .you, .reviews, .goalDetail, .system:
            return true
        }
    }
}

private extension LifeGraphObjectReference {
    static func commandTargets(_ command: AmbitionsCommand) -> [LifeGraphObjectReference] {
        var targets: [LifeGraphObjectReference] = []
        if let goalID = command.target.goalID {
            targets.append(LifeGraphObjectReference(kind: .goal, id: goalID, sourceDomain: .goals))
        }
        if let captureID = command.target.captureID {
            targets.append(LifeGraphObjectReference(kind: .capture, id: captureID, sourceDomain: .capture))
        }
        if let timeID = command.target.timeID {
            targets.append(LifeGraphObjectReference(kind: .action, id: timeID, sourceDomain: .time))
        }
        if let stepID = command.target.stepID {
            targets.append(LifeGraphObjectReference(kind: .step, id: stepID, parentContextID: command.target.goalID, sourceDomain: .goalEngine))
        }
        if let reviewID = command.target.reviewID {
            targets.append(LifeGraphObjectReference(kind: .decision, id: reviewID, sourceDomain: .you))
        }
        if let recommendationID = command.target.recommendationID {
            targets.append(LifeGraphObjectReference(kind: .correction, id: recommendationID, sourceDomain: .system))
        }
        if let explanationID = command.target.explanationID {
            targets.append(LifeGraphObjectReference(kind: .decision, id: explanationID, sourceDomain: .system))
        }
        return targets
    }
}
