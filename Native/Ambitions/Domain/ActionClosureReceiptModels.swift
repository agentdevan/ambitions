import Foundation

let actionClosureReceiptSchemaVersion = "action_closure_receipt.native.v1"

enum ActionReceiptResultState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case created
    case changed
    case scheduled
    case moved
    case attached
    case detached
    case exportedPrepared = "exported_prepared"
    case draftedPrepared = "drafted_prepared"
    case completed
    case failedSafely = "failed_safely"
    case needsConfirmation = "needs_confirmation"
    case noOp = "no_op"
    case undoAvailable = "undo_available"
    case undoUnavailable = "undo_unavailable"
    case correctionAvailable = "correction_available"
}

enum ActionReceiptUndoAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case availableLocal = "available_local"
    case requiresConfirmation = "requires_confirmation"
    case unsafe
    case notSupportedYet = "not_supported_yet"

    var isAvailable: Bool {
        switch self {
        case .availableLocal, .requiresConfirmation:
            return true
        case .unavailable, .unsafe, .notSupportedYet:
            return false
        }
    }
}

enum ActionReceiptCorrectionAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case available
    case availableWithReason = "available_with_reason"
    case notSupportedYet = "not_supported_yet"

    var isAvailable: Bool {
        switch self {
        case .available, .availableWithReason:
            return true
        case .unavailable, .notSupportedYet:
            return false
        }
    }
}

enum ActionReceiptSafetyState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normal
    case degraded
    case safeFailure = "safe_failure"
    case externalUnavailable = "external_unavailable"
    case confirmationRequired = "confirmation_required"
}

enum ActionReceiptSourceDomain: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case reviews
    case goalDetail = "goal_detail"
    case commandPipeline = "command_pipeline"
    case eventLedger = "event_ledger"
    case proof
    case resource
    case commitment
    case calendar
    case exportImport = "export_import"
    case externalSurface = "external_surface"
    case system

    var lifeGraphSourceDomain: LifeGraphSourceDomain {
        switch self {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .plan:
            return .plan
        case .you, .reviews:
            return .you
        case .commandPipeline:
            return .commandPipeline
        case .eventLedger:
            return .eventLedger
        case .proof:
            return .proof
        case .resource:
            return .resource
        case .commitment:
            return .commitment
        case .calendar, .exportImport, .externalSurface, .system:
            return .system
        }
    }
}

enum ActionReceiptChangedFactKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case createdCapture = "created_capture"
    case attachedCaptureToGoal = "attached_capture_to_goal"
    case movedActionToLater = "moved_action_to_later"
    case completedAction = "completed_action"
    case markedWaiting = "marked_waiting"
    case preparedExport = "prepared_export"
    case preparedDraft = "prepared_draft"
    case failedSafely = "failed_safely"
    case needsConfirmation = "needs_confirmation"
    case changedField = "changed_field"
    case noChange = "no_change"
}

struct ActionReceiptChangedFact: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: ActionReceiptChangedFactKind
    let object: LifeGraphObjectReference?
    let fieldName: String?
    let previousValueSummary: String?
    let newValueSummary: String?
    let summary: String

    init(
        id: String,
        kind: ActionReceiptChangedFactKind,
        object: LifeGraphObjectReference? = nil,
        fieldName: String? = nil,
        previousValueSummary: String? = nil,
        newValueSummary: String? = nil,
        summary: String
    ) {
        self.id = Self.normalizedRequired(id)
        self.kind = kind
        self.object = object
        self.fieldName = Self.normalizedOptional(fieldName)
        self.previousValueSummary = Self.normalizedOptional(previousValueSummary)
        self.newValueSummary = Self.normalizedOptional(newValueSummary)
        self.summary = Self.normalizedRequired(summary)
    }

    var isWellFormed: Bool {
        id.isEmpty == false && summary.isEmpty == false && (object?.isWellFormed ?? true)
    }

    fileprivate var orderingKey: String {
        [
            object?.stableKey ?? "",
            kind.rawValue,
            fieldName ?? "",
            summary.lowercased(),
            id
        ].joined(separator: ":")
    }

    fileprivate static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

enum ActionReceiptNextActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case openToday = "open_today"
    case openPlan = "open_plan"
    case reviewGoal = "review_goal"
    case correctAssumption = "correct_assumption"
    case undoIfAvailable = "undo_if_available"
    case dismiss
}

struct ActionReceiptNextAction: Codable, Sendable, Equatable, Hashable {
    let kind: ActionReceiptNextActionKind
    let title: String
    let destination: AmbitionsCommandDestination?
    let target: LifeGraphObjectReference?

    init(
        kind: ActionReceiptNextActionKind,
        title: String,
        destination: AmbitionsCommandDestination? = nil,
        target: LifeGraphObjectReference? = nil
    ) {
        self.kind = kind
        self.title = ActionReceiptChangedFact.normalizedRequired(title)
        self.destination = destination
        self.target = target
    }

    var isWellFormed: Bool {
        title.isEmpty == false && (target?.isWellFormed ?? true)
    }
}

struct ActionReceiptWhyExplanation: Codable, Sendable, Equatable, Hashable {
    let body: String?
    let recommendationExplanationIDs: [String]
    let eventLedgerEntryIDs: [String]

    init(
        body: String? = nil,
        recommendationExplanationIDs: [String] = [],
        eventLedgerEntryIDs: [String] = []
    ) {
        self.body = ActionReceiptChangedFact.normalizedOptional(body)
        self.recommendationExplanationIDs = Self.normalizedUnique(recommendationExplanationIDs)
        self.eventLedgerEntryIDs = Self.normalizedUnique(eventLedgerEntryIDs)
    }

    var isEmpty: Bool {
        body == nil && recommendationExplanationIDs.isEmpty && eventLedgerEntryIDs.isEmpty
    }

    private static func normalizedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map(ActionReceiptChangedFact.normalizedRequired).filter { $0.isEmpty == false })).sorted()
    }
}

struct ActionReceiptSafeFailure: Codable, Sendable, Equatable, Hashable {
    let whatFailed: String
    let whyFailed: String?
    let unchangedFacts: [String]
    let nextSafeAction: ActionReceiptNextAction?

    init(
        whatFailed: String,
        whyFailed: String? = nil,
        unchangedFacts: [String],
        nextSafeAction: ActionReceiptNextAction? = nil
    ) {
        self.whatFailed = ActionReceiptChangedFact.normalizedRequired(whatFailed)
        self.whyFailed = ActionReceiptChangedFact.normalizedOptional(whyFailed)
        self.unchangedFacts = Array(Set(unchangedFacts.map(ActionReceiptChangedFact.normalizedRequired).filter { $0.isEmpty == false })).sorted()
        self.nextSafeAction = nextSafeAction
    }

    var isWellFormed: Bool {
        whatFailed.isEmpty == false &&
            unchangedFacts.isEmpty == false &&
            (nextSafeAction?.isWellFormed ?? true)
    }
}

struct ActionReceiptDisplaySummary: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let resultState: ActionReceiptResultState
    let occurredAt: String
    let sourceDomain: ActionReceiptSourceDomain
    let undoAvailability: ActionReceiptUndoAvailability
    let correctionAvailability: ActionReceiptCorrectionAvailability
    let nextActionTitle: String?
    let safetyState: ActionReceiptSafetyState
}

struct ActionReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let resultState: ActionReceiptResultState
    let title: String
    let summary: String
    let sourceDomain: ActionReceiptSourceDomain
    let occurredAt: String
    let createdAt: String
    let affectedObjects: [LifeGraphObjectReference]
    let changedFacts: [ActionReceiptChangedFact]
    let why: ActionReceiptWhyExplanation?
    let nextAction: ActionReceiptNextAction?
    let correctionAvailability: ActionReceiptCorrectionAvailability
    let undoAvailability: ActionReceiptUndoAvailability
    let safetyState: ActionReceiptSafetyState
    let safeFailure: ActionReceiptSafeFailure?
    let sourceObject: LifeGraphObjectReference?
    let schemaVersion: String

    init(
        id: String,
        resultState: ActionReceiptResultState,
        title: String,
        summary: String,
        sourceDomain: ActionReceiptSourceDomain,
        occurredAt: String,
        createdAt: String? = nil,
        affectedObjects: [LifeGraphObjectReference],
        changedFacts: [ActionReceiptChangedFact] = [],
        why: ActionReceiptWhyExplanation? = nil,
        nextAction: ActionReceiptNextAction? = nil,
        correctionAvailability: ActionReceiptCorrectionAvailability = .unavailable,
        undoAvailability: ActionReceiptUndoAvailability = .unavailable,
        safetyState: ActionReceiptSafetyState = .normal,
        safeFailure: ActionReceiptSafeFailure? = nil,
        sourceObject: LifeGraphObjectReference? = nil,
        schemaVersion: String = actionClosureReceiptSchemaVersion
    ) {
        self.id = ActionReceiptChangedFact.normalizedRequired(id)
        self.resultState = resultState
        self.title = ActionReceiptChangedFact.normalizedRequired(title)
        self.summary = ActionReceiptChangedFact.normalizedRequired(summary)
        self.sourceDomain = sourceDomain
        self.occurredAt = ActionReceiptChangedFact.normalizedRequired(occurredAt)
        self.createdAt = ActionReceiptChangedFact.normalizedRequired(createdAt ?? occurredAt)
        self.affectedObjects = Self.validOrderedUniqueObjects(affectedObjects)
        self.changedFacts = Self.validOrderedUniqueFacts(changedFacts)
        self.why = (why?.isEmpty ?? true) ? nil : why
        self.nextAction = nextAction
        self.correctionAvailability = correctionAvailability
        self.undoAvailability = undoAvailability
        self.safetyState = safetyState
        self.safeFailure = safeFailure
        self.sourceObject = sourceObject
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            occurredAt.isEmpty == false &&
            createdAt.isEmpty == false &&
            affectedObjects.isEmpty == false &&
            affectedObjects.allSatisfy(\.isWellFormed) &&
            changedFacts.allSatisfy(\.isWellFormed) &&
            (nextAction?.isWellFormed ?? true) &&
            (sourceObject?.isWellFormed ?? true) &&
            safeFailureIsValid
    }

    var lifeGraphObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .receipt,
            id: id,
            label: title,
            sourceDomain: .receipt
        )
    }

    var displaySummary: ActionReceiptDisplaySummary {
        ActionReceiptDisplaySummary(
            id: id,
            title: title,
            summary: summary,
            resultState: resultState,
            occurredAt: occurredAt,
            sourceDomain: sourceDomain,
            undoAvailability: undoAvailability,
            correctionAvailability: correctionAvailability,
            nextActionTitle: nextAction?.title,
            safetyState: safetyState
        )
    }

    fileprivate var dedupeKey: String {
        id.lowercased()
    }

    fileprivate var orderingKey: String {
        [
            occurredAt,
            createdAt,
            resultState.rawValue,
            title.lowercased(),
            id
        ].joined(separator: ":")
    }

    private var safeFailureIsValid: Bool {
        if resultState == .failedSafely || safetyState == .safeFailure {
            return safeFailure?.isWellFormed == true
        }
        return safeFailure?.isWellFormed ?? true
    }

    private static func validOrderedUniqueObjects(_ objects: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return objects
            .filter(\.isWellFormed)
            .filter { seen.insert($0.stableKey).inserted }
            .sorted { lhs, rhs in lhs.stableKey < rhs.stableKey }
    }

    private static func validOrderedUniqueFacts(_ facts: [ActionReceiptChangedFact]) -> [ActionReceiptChangedFact] {
        var seen = Set<String>()
        return facts
            .filter(\.isWellFormed)
            .filter { seen.insert($0.id.lowercased()).inserted }
            .sorted { lhs, rhs in lhs.orderingKey < rhs.orderingKey }
    }
}

struct ActionReceiptProjection: Sendable, Equatable {
    let receipts: [ActionReceipt]
    let rejectedReceiptIDs: [String]
    let lifeGraphProjection: LifeGraphRelationshipProjection

    init(receipts: [ActionReceipt] = []) {
        var seen = Set<String>()
        var accepted: [ActionReceipt] = []
        var rejected: [String] = []

        for receipt in receipts {
            guard receipt.isWellFormed, seen.insert(receipt.dedupeKey).inserted else {
                rejected.append(receipt.id.isEmpty ? "malformed-receipt" : receipt.id)
                continue
            }
            accepted.append(receipt)
        }

        self.receipts = accepted.sorted { lhs, rhs in
            if lhs.occurredAt != rhs.occurredAt {
                return lhs.occurredAt > rhs.occurredAt
            }
            return lhs.orderingKey < rhs.orderingKey
        }
        self.rejectedReceiptIDs = rejected.sorted()
        self.lifeGraphProjection = LifeGraphRelationshipProjection(
            relationships: self.receipts.flatMap(Self.projectedRelationships)
        )
    }

    func receipts(for object: LifeGraphObjectReference) -> [ActionReceipt] {
        receipts.filter { receipt in
            receipt.affectedObjects.contains { $0.stableKey == object.stableKey }
        }
    }

    func receipts(resultState: ActionReceiptResultState) -> [ActionReceipt] {
        receipts.filter { $0.resultState == resultState }
    }

    func correctionAvailableReceipts() -> [ActionReceipt] {
        receipts.filter { $0.correctionAvailability.isAvailable || $0.resultState == .correctionAvailable }
    }

    func undoAvailableReceipts() -> [ActionReceipt] {
        receipts.filter { $0.undoAvailability.isAvailable || $0.resultState == .undoAvailable }
    }

    func displaySummaries(limit: Int? = nil) -> [ActionReceiptDisplaySummary] {
        let summaries = receipts.map(\.displaySummary)
        guard let limit else { return summaries }
        return Array(summaries.prefix(max(0, limit)))
    }

    func relationshipProjection(for object: LifeGraphObjectReference) -> LifeGraphRelationshipProjection {
        LifeGraphRelationshipProjection(
            relationships: lifeGraphProjection.relationships.filter {
                $0.source.stableKey == object.stableKey || $0.target.stableKey == object.stableKey
            }
        )
    }

    static func projectedRelationships(for receipt: ActionReceipt) -> [LifeGraphRelationship] {
        guard receipt.isWellFormed else { return [] }

        let receiptObject = receipt.lifeGraphObjectReference
        var relationships = receipt.affectedObjects.map { affectedObject in
            LifeGraphRelationship(
                kind: .explains,
                source: receiptObject,
                target: affectedObject,
                note: receipt.summary
            )
        }

        if let sourceObject = receipt.sourceObject {
            relationships.append(
                LifeGraphRelationship(
                    kind: .createdFrom,
                    source: receiptObject,
                    target: sourceObject,
                    note: receipt.why?.body
                )
            )
        }

        if receipt.correctionAvailability.isAvailable {
            relationships.append(contentsOf: receipt.affectedObjects.map { affectedObject in
                LifeGraphRelationship(
                    kind: .corrects,
                    source: receiptObject,
                    target: affectedObject,
                    note: receipt.why?.body
                )
            })
        }

        return relationships
    }
}

extension ActionReceipt {
    static func fromCommandResult(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        occurredAt: String
    ) -> ActionReceipt {
        let affectedObjects = ActionReceipt.affectedObjects(command: command, result: result)
        let resultState = ActionReceipt.resultState(command: command, result: result)
        let safeFailure = ActionReceipt.safeFailure(command: command, result: result, resultState: resultState)

        return ActionReceipt(
            id: "receipt.command.\(command.id)",
            resultState: resultState,
            title: ActionReceipt.title(command: command, resultState: resultState),
            summary: result.summary,
            sourceDomain: ActionReceipt.sourceDomain(for: command.source),
            occurredAt: occurredAt,
            affectedObjects: affectedObjects.isEmpty ? [ActionReceipt.commandSourceObject(command)] : affectedObjects,
            changedFacts: ActionReceipt.changedFacts(command: command, result: result, resultState: resultState),
            why: ActionReceiptWhyExplanation(
                recommendationExplanationIDs: result.recommendationExplanationIDs + command.relations.recommendationExplanationIDs,
                eventLedgerEntryIDs: result.eventLedgerEntryIDs + command.relations.eventLedgerEntryIDs
            ),
            nextAction: ActionReceipt.nextAction(for: result),
            correctionAvailability: ActionReceipt.correctionAvailability(command: command, result: result),
            undoAvailability: ActionReceipt.undoAvailability(command: command, result: result),
            safetyState: ActionReceipt.safetyState(result: result, resultState: resultState),
            safeFailure: safeFailure,
            sourceObject: ActionReceipt.commandSourceObject(command)
        )
    }

    private static func affectedObjects(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> [LifeGraphObjectReference] {
        let target = result.target ?? command.target
        var objects: [LifeGraphObjectReference] = []
        if let goalID = target.goalID {
            objects.append(LifeGraphObjectReference(kind: .goal, id: goalID, sourceDomain: .goals))
        }
        if let captureID = target.captureID {
            objects.append(LifeGraphObjectReference(kind: .capture, id: captureID, sourceDomain: .capture))
        }
        if let planID = target.planID {
            objects.append(LifeGraphObjectReference(kind: .action, id: planID, sourceDomain: .plan))
        }
        if let stepID = target.stepID {
            objects.append(LifeGraphObjectReference(kind: .step, id: stepID, parentContextID: target.goalID, sourceDomain: .goalEngine))
        }
        return objects
    }

    private static func resultState(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> ActionReceiptResultState {
        switch result.status {
        case .succeeded:
            switch command.kind {
            case .quickCapture:
                return .created
            case .attachToGoal:
                return .attached
            case .markWaiting:
                return .changed
            case .archiveItem, .setPriority, .setUrgency, .setDeadline, .routeCommitment, .createPlanItem:
                return .changed
            case .scheduleItem:
                return .draftedPrepared
            case .completeAction:
                return .completed
            default:
                return .changed
            }
        case .requiresConfirmation:
            return .needsConfirmation
        case .noOp:
            return .noOp
        case .failed, .unsupported, .blocked:
            return .failedSafely
        case .pending, .queued:
            return .draftedPrepared
        }
    }

    private static func changedFacts(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        resultState: ActionReceiptResultState
    ) -> [ActionReceiptChangedFact] {
        let object = affectedObjects(command: command, result: result).first
        let kind: ActionReceiptChangedFactKind
        switch resultState {
        case .created:
            kind = .createdCapture
        case .attached:
            kind = .attachedCaptureToGoal
        case .moved:
            kind = .movedActionToLater
        case .completed:
            kind = .completedAction
        case .exportedPrepared:
            kind = .preparedExport
        case .draftedPrepared:
            kind = .preparedDraft
        case .failedSafely:
            kind = .failedSafely
        case .needsConfirmation:
            kind = .needsConfirmation
        case .noOp:
            kind = .noChange
        case .changed, .scheduled, .detached, .undoAvailable, .undoUnavailable, .correctionAvailable:
            kind = command.kind == .markWaiting ? .markedWaiting : .changedField
        }

        return [
            ActionReceiptChangedFact(
                id: "fact.\(command.id).\(kind.rawValue)",
                kind: kind,
                object: object,
                summary: result.summary
            )
        ]
    }

    private static func safeFailure(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        resultState: ActionReceiptResultState
    ) -> ActionReceiptSafeFailure? {
        guard resultState == .failedSafely else { return nil }
        return ActionReceiptSafeFailure(
            whatFailed: title(command: command, resultState: resultState),
            whyFailed: result.metadata["blockedBy"] ?? result.metadata["validation"] ?? result.metadata["error"],
            unchangedFacts: ["No calendar, export, sync, external surface, or unsupported app data was changed."],
            nextSafeAction: ActionReceiptNextAction(kind: .dismiss, title: "Dismiss")
        )
    }

    private static func undoAvailability(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> ActionReceiptUndoAvailability {
        guard result.status == .succeeded else {
            return result.status == .requiresConfirmation ? .requiresConfirmation : .unavailable
        }

        switch command.kind {
        case .attachToGoal, .markWaiting, .archiveItem, .setPriority, .setUrgency, .setDeadline, .routeCommitment, .quickCapture:
            return .availableLocal
        case .scheduleItem where command.payload.metadata["calendarWriteIntent"] == "true":
            return .requiresConfirmation
        case .openDestination, .askWhy, .dismissRecommendation:
            return .unavailable
        default:
            return .notSupportedYet
        }
    }

    private static func correctionAvailability(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> ActionReceiptCorrectionAvailability {
        switch result.status {
        case .succeeded:
            return command.relations.recommendationExplanationIDs.isEmpty && result.recommendationExplanationIDs.isEmpty ? .available : .availableWithReason
        case .requiresConfirmation, .failed, .blocked, .unsupported:
            return .availableWithReason
        case .pending, .queued, .noOp:
            return .unavailable
        }
    }

    private static func safetyState(result: AmbitionsCommandExecutionResult, resultState: ActionReceiptResultState) -> ActionReceiptSafetyState {
        if resultState == .needsConfirmation {
            return .confirmationRequired
        }
        switch result.status {
        case .failed, .blocked, .unsupported:
            return .safeFailure
        case .queued, .pending:
            return .degraded
        case .succeeded, .noOp, .requiresConfirmation:
            return .normal
        }
    }

    private static func nextAction(for result: AmbitionsCommandExecutionResult) -> ActionReceiptNextAction? {
        switch result.route {
        case .today:
            return ActionReceiptNextAction(kind: .openToday, title: "Open Today", destination: .today)
        case .plan:
            return ActionReceiptNextAction(kind: .openPlan, title: "Open Plan", destination: .plan)
        case .goalDetail, .goals:
            return ActionReceiptNextAction(kind: .reviewGoal, title: "Review goal", destination: result.route)
        case .capture, .capturesInbox:
            return ActionReceiptNextAction(kind: .dismiss, title: "Dismiss", destination: result.route)
        case .you, .reviews, .memoryLens, .commandSheet, .weeklyReview, nil:
            return nil
        }
    }

    private static func title(command: AmbitionsCommand, resultState: ActionReceiptResultState) -> String {
        switch resultState {
        case .created:
            return "Capture created"
        case .attached:
            return "Item attached"
        case .draftedPrepared:
            return "Draft prepared"
        case .failedSafely:
            return "Action did not change anything"
        case .needsConfirmation:
            return "Confirmation needed"
        case .completed:
            return "Action completed"
        default:
            return command.payload.title ?? command.kind.rawValue.replacingOccurrences(of: "_", with: " ")
        }
    }

    private static func sourceDomain(for source: AmbitionsCommandSource) -> ActionReceiptSourceDomain {
        switch source {
        case .today:
            return .today
        case .goals:
            return .goals
        case .capture:
            return .capture
        case .plan:
            return .plan
        case .you:
            return .you
        case .reviews:
            return .reviews
        case .goalDetail:
            return .goalDetail
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            return .externalSurface
        case .system:
            return .system
        }
    }

    private static func commandSourceObject(_ command: AmbitionsCommand) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .action,
            id: command.id,
            label: command.kind.rawValue,
            sourceDomain: .commandPipeline
        )
    }
}
