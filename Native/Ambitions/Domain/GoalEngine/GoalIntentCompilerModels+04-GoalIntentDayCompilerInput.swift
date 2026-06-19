import Foundation

extension GoalIntentDayCompilerInput {
    func makeOutput(
        compiledSteps: [CompiledStep],
        compiledAt: String,
        receipts: [CompiledStepReceipt]? = nil
    ) -> GoalIntentDayCompilerOutput {
        let resolvedCompiledSteps = adjustedCompiledSteps(compiledSteps)
        let resolvedStatus = status == .blocked || resolvedCompiledSteps.isEmpty ? .blocked : status
        let resolvedReceipts = receipts ?? Self.defaultReceipts(
            intent: intent,
            compiledSteps: resolvedCompiledSteps,
            compiledAt: compiledAt,
            status: resolvedStatus,
            sourceSurface: intent.sourceSurface,
            assumptionIDs: assumptions.map(\.id),
            clarificationQuestionIDs: clarification.questions.map(\.id),
            blockedReasons: blockedReasons,
            capacityEnvelope: capacityEnvelope,
            localOnly: localOnly
        )

        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: compiledAt,
            status: resolvedStatus,
            assumptions: assumptions,
            clarification: clarification,
            blockedReasons: blockedReasons,
            capacityEnvelope: capacityEnvelope,
            compiledSteps: resolvedCompiledSteps,
            receipts: resolvedReceipts,
            localOnly: localOnly
        )
    }

    static func defaultReceipts(
        intent: GoalIntent,
        compiledSteps: [CompiledStep],
        compiledAt: String,
        status: GoalIntentDayCompilerStatus,
        sourceSurface: GoalIntentSourceSurface,
        assumptionIDs: [String],
        clarificationQuestionIDs: [String],
        blockedReasons: [GoalIntentBlockedReason],
        capacityEnvelope: GoalIntentCapacityEnvelope?,
        localOnly: Bool
    ) -> [CompiledStepReceipt] {
        if compiledSteps.isEmpty {
            let blockedSummary = blockedReasons.isEmpty
                ? "The compiler kept the output blocked to preserve local-only truth."
                : blockedReasons.map(\.summary).joined(separator: ", ")
            let capacitySummary = capacityEnvelope.map { " Capacity context: \($0.summary)" } ?? ""
            return [
                CompiledStepReceipt(
                    id: "receipt-\(intent.id)-blocked",
                    compiledStepID: "blocked",
                    intentID: intent.id,
                    generatedAt: compiledAt,
                    status: status,
                    summary: "No executable daily step was emitted.",
                    reason: "\(blockedSummary)\(capacitySummary)",
                    sourceSurface: sourceSurface,
                    assumptionIDs: assumptionIDs,
                    clarificationQuestionIDs: clarificationQuestionIDs,
                    blockedReasonIDs: blockedReasons.map(\.id),
                    localOnly: localOnly
                )
            ]
        }

        return compiledSteps.map { step in
            let capacityReason = capacityEnvelope.map { " Capacity context: \($0.summary)" } ?? ""
            return CompiledStepReceipt(
                id: "receipt-\(step.id)",
                compiledStepID: step.id,
                intentID: intent.id,
                generatedAt: compiledAt,
                status: status,
                summary: "Compiled daily step candidate \(step.title).",
                reason: step.isExecutable
                    ? "Deterministic local-first compilation.\(capacityReason)"
                    : "Step remains blocked by the compiled path.\(capacityReason)",
                sourceSurface: sourceSurface,
                assumptionIDs: step.assumptionIDs,
                clarificationQuestionIDs: step.clarificationQuestionIDs,
                blockedReasonIDs: step.blockingReasonIDs,
                localOnly: localOnly
            )
        }
    }

    func adjustedCompiledSteps(_ compiledSteps: [CompiledStep]) -> [CompiledStep] {
        guard let capacityEnvelope else {
            return compiledSteps
        }

        if capacityEnvelope.mode == .normal {
            return compiledSteps
        }

        guard let stepLimit = capacityEnvelope.stepLimit else {
            return compiledSteps
        }

        guard stepLimit > 0 else {
            return []
        }

        return compiledSteps.prefix(stepLimit).enumerated().map { index, step in
            adjustedCompiledStep(step, capacityEnvelope: capacityEnvelope, isPrimary: index == 0)
        }
    }

    func adjustedCompiledStep(
        _ step: CompiledStep,
        capacityEnvelope: GoalIntentCapacityEnvelope,
        isPrimary: Bool
    ) -> CompiledStep {
        let capacityReasonIDs = capacityEnvelope.localReasonIDs
        let adjustedPace: PlanningPace
        switch capacityEnvelope.mode {
        case .normal:
            adjustedPace = step.pace
        default:
            adjustedPace = .untimed
        }

        let adjustedContextRequirements = isPrimary && capacityEnvelope.mode != .normal
            ? step.contextRequirements + [capacityEnvelope.summary]
            : step.contextRequirements
        let adjustedEvidenceHint = isPrimary && capacityEnvelope.mode != .normal
            ? [step.evidenceHint, capacityEnvelope.summary].compactMap { $0 }.joined(separator: " ")
            : step.evidenceHint
        let adjustedBlockingReasonIDs = (step.blockingReasonIDs + capacityReasonIDs).removingDuplicates()
        let adjustedIsOptional = capacityEnvelope.mode == .recovery ? true : step.isOptional
        let adjustedIsExecutable = step.isExecutable && capacityEnvelope.mode != .protectedConflict

        return CompiledStep(
            schemaVersion: step.schemaVersion,
            id: step.id,
            intentID: step.intentID,
            sourceCandidateID: step.sourceCandidateID,
            sourceStageID: step.sourceStageID,
            title: step.title,
            summary: step.summary,
            orderIndex: step.orderIndex,
            stepType: step.stepType,
            pace: adjustedPace,
            targetDate: step.targetDate,
            repeatEveryDays: step.repeatEveryDays,
            evidenceHint: adjustedEvidenceHint,
            contextRequirements: adjustedContextRequirements,
            isOptional: adjustedIsOptional,
            isRepeatable: step.isRepeatable,
            isExecutable: adjustedIsExecutable,
            blockingReasonIDs: adjustedBlockingReasonIDs,
            assumptionIDs: step.assumptionIDs,
            clarificationQuestionIDs: step.clarificationQuestionIDs
        )
    }
}

extension MissingFieldKey {
    var displayName: String {
        switch self {
        case .goalSubject:
            return "goal subject"
        case .goalShape:
            return "goal shape"
        case .executorIdentity:
            return "executor identity"
        case .supportScope:
            return "support scope"
        case .successDefinition:
            return "success definition"
        case .timeHorizon:
            return "time horizon"
        }
    }
}

func normalizedRequired(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

func normalizedOptional(_ value: String?) -> String? {
    guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
          trimmed.isEmpty == false else {
        return nil
    }
    return trimmed
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
