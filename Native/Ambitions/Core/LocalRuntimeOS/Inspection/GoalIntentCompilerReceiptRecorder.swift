import Foundation

struct GoalIntentCompilerReceiptRecorder: Sendable {
    let actionReceiptHistoryRepository: any ActionReceiptHistoryRepository

    init(actionReceiptHistoryRepository: any ActionReceiptHistoryRepository) {
        self.actionReceiptHistoryRepository = actionReceiptHistoryRepository
    }

    func save(_ output: GoalIntentDayCompilerOutput) async throws {
        let records = Self.records(from: output)
        guard records.isEmpty == false else {
            return
        }

        try await actionReceiptHistoryRepository.save(records)
    }

    private static func records(from output: GoalIntentDayCompilerOutput) -> [ActionReceiptHistoryRecord] {
        let intentReference = goalIntentReference(from: output.intent)
        let receipts = deduplicatedReceipts(from: output)

        return receipts.map { receipt in
            let stepReference = compiledStepReference(for: receipt, output: output)
            let affectedObjects = uniqueObjects([intentReference, stepReference].compactMap { $0 })
            let changedFacts = changedFacts(
                for: receipt,
                output: output,
                intentReference: intentReference,
                stepReference: stepReference
            )

            let actionReceipt = ActionReceipt(
                id: receipt.id,
                resultState: resultState(for: receipt.status),
                title: receipt.summary,
                summary: receipt.reason,
                sourceDomain: .goals,
                occurredAt: receipt.generatedAt,
                affectedObjects: affectedObjects,
                changedFacts: changedFacts,
                correctionAvailability: .unavailable,
                undoAvailability: .unavailable,
                safetyState: .normal,
                sourceObject: intentReference
            )

            return ActionReceiptHistoryRecord(
                receipt: actionReceipt,
                privacyLevel: .safeToShow,
                localOnly: true,
                proofRelevance: proofRelevance(for: receipt.status),
                requiresConfirmationBeforeBroaderUse: receipt.status != .clear
            )
        }
    }

    private static func resultState(for status: GoalIntentDayCompilerStatus) -> ActionReceiptResultState {
        switch status {
        case .clear:
            return .completed
        case .ambiguous, .blocked:
            return .needsConfirmation
        }
    }

    private static func proofRelevance(for status: GoalIntentDayCompilerStatus) -> ActionReceiptProofRelevance {
        switch status {
        case .clear:
            return .notProof
        case .ambiguous, .blocked:
            return .needsConfirmation
        }
    }

    private static func goalIntentReference(from intent: GoalIntent) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .goal,
            id: intent.id,
            label: intent.rawStatement,
            sourceDomain: .goals
        )
    }

    private static func compiledStepReference(
        for receipt: CompiledStepReceipt,
        output: GoalIntentDayCompilerOutput
    ) -> LifeGraphObjectReference? {
        guard receipt.compiledStepID != "blocked" else {
            return nil
        }

        guard let step = output.compiledSteps.first(where: { $0.id == receipt.compiledStepID }) else {
            return nil
        }

        return LifeGraphObjectReference(
            kind: .step,
            id: step.id,
            parentContextID: output.intent.id,
            label: step.title,
            sourceDomain: .goalEngine
        )
    }

    private static func changedFacts(
        for receipt: CompiledStepReceipt,
        output: GoalIntentDayCompilerOutput,
        intentReference: LifeGraphObjectReference,
        stepReference: LifeGraphObjectReference?
    ) -> [ActionReceiptChangedFact] {
        var facts: [ActionReceiptChangedFact] = [
            ActionReceiptChangedFact(
                id: "\(receipt.id).source-surface",
                kind: .changedField,
                object: intentReference,
                fieldName: "sourceSurface",
                newValueSummary: output.intent.sourceSurface.rawValue,
                summary: "Compiled from \(output.intent.sourceSurface.rawValue) input."
            )
        ]

        if let stepReference {
            facts.append(
                ActionReceiptChangedFact(
                    id: "\(receipt.id).step-status",
                    kind: receipt.status == .clear ? .changedField : .needsConfirmation,
                    object: stepReference,
                    fieldName: "compilerStatus",
                    previousValueSummary: "pending",
                    newValueSummary: receipt.status.rawValue,
                    summary: receipt.summary
                )
            )
        } else {
            let blockedSummary = blockedReasonSummary(for: receipt, output: output)

            facts.append(
                ActionReceiptChangedFact(
                    id: "\(receipt.id).blocked-reason",
                    kind: .needsConfirmation,
                    object: intentReference,
                    fieldName: "blockedReasons",
                    newValueSummary: blockedSummary,
                    summary: blockedSummary
                )
            )
        }

        return facts
    }

    private static func blockedReasonSummary(
        for receipt: CompiledStepReceipt,
        output: GoalIntentDayCompilerOutput
    ) -> String {
        let linkedReasonSummaries = output.blockedReasons
            .filter { receipt.blockedReasonIDs.contains($0.id) }
            .map(\.summary)

        if linkedReasonSummaries.isEmpty == false {
            return linkedReasonSummaries.joined(separator: ", ")
        }

        let fallbackSummary = receipt.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        return fallbackSummary.isEmpty ? receipt.summary : fallbackSummary
    }

    private static func deduplicatedReceipts(from output: GoalIntentDayCompilerOutput) -> [CompiledStepReceipt] {
        var seen = Set<String>()
        var uniqueReceipts: [CompiledStepReceipt] = []

        for receipt in output.receipts.reversed() {
            guard seen.insert(receipt.id).inserted else {
                continue
            }
            uniqueReceipts.append(receipt)
        }

        return Array(uniqueReceipts.reversed())
    }

    private static func uniqueObjects(_ objects: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return objects.filter { seen.insert($0.stableKey).inserted }
    }
}
