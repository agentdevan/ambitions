import Foundation

extension ExecutionResilienceProjector {
    func nowRecoverySummary(from assessment: ExecutionResilienceAssessment) -> NowPressureSummary {
        NowPressureSummary(
            level: pressure(for: assessment.status),
            itemCount: assessment.disruptions.count,
            summary: assessment.recommendedRecoveryOption?.summary ?? "No recovery pressure is visible.",
            evidenceReferenceIDs: assessment.eventLedgerEntryIDs
        )
    }

    func nowRecoveryState(from assessment: ExecutionResilienceAssessment) -> NowRecoveryState {
        switch assessment.status {
        case .stable:
            return .stable
        case .watch:
            return .watch
        case .needsRecovery, .atRisk:
            return .needsRecovery
        case .blocked:
            return .blocked
        case .recovering:
            return .recovering
        }
    }

    func command(for option: ExecutionRecoveryOption, assessment: ExecutionResilienceAssessment, createdAt: String? = nil) -> AmbitionsCommand? {
        guard let kind = option.relatedCommandKind else { return nil }
        let destination: AmbitionsCommandDestination?
        switch option.strategy {
        case .openTime:
            destination = .time
        case .openGoal:
            destination = .goalDetail
        case .openCapture:
            destination = .capture
        default:
            destination = nil
        }
        let target = AmbitionsCommandTarget(
            goalID: option.relatedGoalID,
            captureID: option.relatedCaptureID,
            timeID: option.relatedTimeID,
            recommendationID: option.id,
            explanationID: option.relatedExplanationID,
            destination: destination
        )
        let content = AmbitionsCommandPayload(
            title: option.title,
            notes: option.summary,
            priorityHints: AmbitionsCommandPriorityHints(recoveryState: nowRecoveryState(from: assessment)),
            explanationID: option.relatedExplanationID
        )
        let command = AmbitionsCommand(
            id: "command.resilience.\(option.id)",
            source: .system,
            typedPayload: .repair(RepairCommand(
                action: kind == .openDestination ? .openDestination : .recover,
                recommendation: RecoveryRecommendationCommand(
                    goalID: option.relatedGoalID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                    captureID: option.relatedCaptureID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                    timeID: option.relatedTimeID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                    title: option.title,
                    explanationID: option.relatedExplanationID.flatMap(RuntimeCommandObjectID.init(rawValue:))
                ),
                target: target,
                content: RuntimeCommandContent(content)
            )),
            createdAt: createdAt ?? assessment.generatedAt,
            actor: .system,
            relations: AmbitionsCommandRelations(
                goalIDs: assessment.relatedGoalIDs,
                captureIDs: assessment.relatedCaptureIDs,
                timeIDs: assessment.relatedTimeIDs,
                reviewIDs: assessment.relatedReviewIDs,
                eventLedgerEntryIDs: option.eventLedgerEntryIDs,
                recommendationExplanationIDs: option.recommendationExplanationIDs
            ),
            privacy: assessment.privacy
        )
        return command.validated(as: AmbitionsCommandValidator().validate(command))
    }
}
