import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        guard let draft = snapshot.drafts.first(where: { $0.id == request.target.draftID || ($0.plannedGoalID != nil && $0.plannedGoalID == request.target.goalID) }) else {
            throw GoalsFeatureError.notFound
        }

        let trimmed = request.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Answer still needed",
                    body: "Write the smallest real answer you have. Ambitions will keep the plan provisional rather than inventing one.",
                    state: .warning
                )
            )
        }

        let updatedDraft = materializeDraft(
            from: draft,
            answeredField: request.field,
            answer: trimmed,
            now: now
        )
        let receipt = try await saveClarificationMaterialization(
            goal: updatedDraft.goal,
            draft: updatedDraft.draft,
            now: now
        )

        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: updatedDraft.draft.latestResultKind == .clarificationRequired ? "Clarification saved" : "Goal refreshed",
                body: updatedDraft.message,
                state: updatedDraft.draft.latestResultKind == .clarificationRequired ? .selected : .success
            ),
            unitOfWorkReceipt: receipt
        )
    }


    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        let detail = try resolveDetailContext(target: request.target, snapshot: snapshot)
        guard let metadata = detail.draft?.metadata else {
            throw GoalsFeatureError.notActionable
        }

        let goalID = detail.goal?.id ?? detail.draft?.plannedGoalID ?? metadata.context.goalID
        guard let goalID else {
            throw GoalsFeatureError.notActionable
        }

        let signal: GoalTeachingSignal
        if let goalIntelligenceService {
            do {
                signal = try await goalIntelligenceService.captureCorrection(
                    target: request.target,
                    control: request.control,
                    now: now
                )
            } catch RuntimeGoalIntelligenceError.notFound {
                throw GoalsFeatureError.notFound
            } catch RuntimeGoalIntelligenceError.notActionable {
                throw GoalsFeatureError.notActionable
            }
        } else {
            signal = try await teachingService.capture(
                GoalTeachingCaptureRequest(
                    goalID: goalID,
                    capturedAt: DomainTimestamp.string(from: now),
                    kind: request.control.teachingSignalKind,
                    payload: request.control.payload,
                    target: request.control.target,
                    userNote: request.control.subtitle
                ),
                metadata: metadata
            )
        }

        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: "Correction captured",
                body: correctionMessage(for: signal),
                state: .selected
            )
        )
    }
}
