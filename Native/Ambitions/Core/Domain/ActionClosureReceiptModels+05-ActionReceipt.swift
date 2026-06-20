import Foundation

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

    var dedupeKey: String {
        id.lowercased()
    }

    var orderingKey: String {
        [
            occurredAt,
            createdAt,
            resultState.rawValue,
            title.lowercased(),
            id
        ].joined(separator: ":")
    }

    var safeFailureIsValid: Bool {
        if resultState == .failedSafely || safetyState == .safeFailure {
            return safeFailure?.isWellFormed == true
        }
        return safeFailure?.isWellFormed ?? true
    }

    static func validOrderedUniqueObjects(_ objects: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return objects
            .filter(\.isWellFormed)
            .filter { seen.insert($0.stableKey).inserted }
            .sorted { lhs, rhs in lhs.stableKey < rhs.stableKey }
    }

    static func validOrderedUniqueFacts(_ facts: [ActionReceiptChangedFact]) -> [ActionReceiptChangedFact] {
        var seen = Set<String>()
        return facts
            .filter(\.isWellFormed)
            .filter { seen.insert($0.id.lowercased()).inserted }
    }
}
