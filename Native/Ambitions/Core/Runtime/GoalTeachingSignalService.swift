import Foundation

enum GoalTeachingSignalError: Error, Equatable {
    case goalMismatch
    case unanchoredArtifact
    case ambiguousScope
    case artifactNotFound
    case invalidRequest
}

protocol GoalTeachingSignalCapturing: Sendable {
    func capture(_ request: GoalTeachingCaptureRequest, metadata: GoalOrchestrationMetadata) async throws -> GoalTeachingSignal
}

protocol GoalTeachingSignalReading: Sendable {
    func listSignals(goalID: String) async throws -> [GoalTeachingSignal]
    func applicableSignals(goalID: String, metadata: GoalOrchestrationMetadata?) async throws -> GoalTeachingApplicableSet
}

struct DefaultGoalTeachingSignalService: GoalTeachingSignalCapturing, GoalTeachingSignalReading {
    let repository: any GoalTeachingSignalRepository

    func capture(_ request: GoalTeachingCaptureRequest, metadata: GoalOrchestrationMetadata) async throws -> GoalTeachingSignal {
        if let contextGoalID = metadata.context.goalID, contextGoalID != request.goalID {
            throw GoalTeachingSignalError.goalMismatch
        }

        let anchor = try validate(request: request, metadata: metadata)
        let signal = GoalTeachingSignal(
            id: DomainIdentifier.prefixed("teaching"),
            goalID: request.goalID,
            createdAt: request.capturedAt,
            updatedAt: request.capturedAt,
            source: .explicitManualCorrection,
            kind: request.kind,
            disposition: .active,
            anchor: anchor,
            payload: request.payload,
            applicationKey: GoalTeachingSignal.makeApplicationKey(
                goalID: request.goalID,
                kind: request.kind,
                anchor: anchor,
                normalizedTargetValue: request.payload.normalizedTargetValue
            ),
            userNote: request.userNote
        )
        try await repository.saveSignals([signal])
        return signal
    }

    func listSignals(goalID: String) async throws -> [GoalTeachingSignal] {
        try await repository.listSignals(goalID: goalID)
    }

    func applicableSignals(goalID: String, metadata: GoalOrchestrationMetadata?) async throws -> GoalTeachingApplicableSet {
        let history = try await repository.listSignals(goalID: goalID)
        let applicableHistory = history.filter { signal in
            guard signal.goalID == goalID else { return false }
            guard let metadata else { return true }
            return matches(signal.anchor, metadata: metadata)
        }
        let sorted = applicableHistory.sorted(by: signalOrdering)
        var latestByKey: [String: GoalTeachingSignal] = [:]
        var superseded: [String] = []

        for signal in sorted {
            if latestByKey[signal.applicationKey] == nil {
                latestByKey[signal.applicationKey] = signal
            } else {
                superseded.append(signal.id)
            }
        }

        let activeSignals = latestByKey.values.sorted(by: signalOrdering)
        return GoalTeachingApplicableSet(
            goalID: goalID,
            signals: activeSignals,
            supersededSignalIDs: superseded.sorted()
        )
    }
}

private extension DefaultGoalTeachingSignalService {
    func validate(
        request: GoalTeachingCaptureRequest,
        metadata: GoalOrchestrationMetadata
    ) throws -> GoalTeachingStableAnchor {
        switch (request.kind, request.payload, request.target.artifactKind) {
        case let (.interpretationCorrection, .interpretation(payload), .understandingInterpretation):
            return try interpretationAnchor(target: request.target, payload: payload, metadata: metadata)
        case (.goalSubjectCorrection, .goalSubject(_), .goalSubjectField):
            return GoalTeachingStableAnchor(
                artifactKind: .goalSubjectField,
                canonicalField: .goalSubject,
                candidateID: nil,
                stageID: nil,
                stepID: nil,
                targetFingerprint: "goal_subject",
                contradictionCode: nil,
                contradictionArtifactRefs: []
            )
        case let (.classificationCorrection, .classification(payload), .classificationField):
            return try classificationAnchor(target: request.target, payload: payload, metadata: metadata)
        case let (.requirementRelevanceCorrection, .requirementRelevance(_), artifactKind)
            where [.requirementHint, .readinessCriterion, .resourceHook].contains(artifactKind):
            return try requirementAnchor(target: request.target, metadata: metadata)
        case (.contradictionDispositionCorrection, .contradictionDisposition(_), .contradictionShape):
            return try contradictionAnchor(target: request.target, metadata: metadata)
        case (.energyFitCorrection, .energyFit(_), .energyEvaluation):
            return try energyAnchor(target: request.target, metadata: metadata)
        default:
            throw GoalTeachingSignalError.invalidRequest
        }
    }

    func interpretationAnchor(
        target: GoalTeachingCaptureTarget,
        payload: GoalTeachingInterpretationCorrection,
        metadata: GoalOrchestrationMetadata
    ) throws -> GoalTeachingStableAnchor {
        let matches = ([metadata.understanding.primaryInterpretation] + metadata.understanding.alternateInterpretations).filter { interpretation in
            normalize(interpretation.summary) == normalize(target.interpretationSummary ?? "") &&
            interpretation.modeHint == target.interpretationModeHint &&
            interpretation.domainHints.sorted(by: domainOrdering) == target.interpretationDomainHints.sorted(by: domainOrdering)
        }
        guard matches.count == 1 else {
            throw matches.isEmpty ? GoalTeachingSignalError.artifactNotFound : GoalTeachingSignalError.ambiguousScope
        }

        return GoalTeachingStableAnchor(
            artifactKind: .understandingInterpretation,
            canonicalField: nil,
            candidateID: nil,
            stageID: nil,
            stepID: nil,
            targetFingerprint: [
                normalize(payload.preferredInterpretationSummary),
                payload.preferredModeHint?.rawValue ?? "",
                payload.preferredDomainHints.map(\.rawValue).sorted().joined(separator: "|")
            ].joined(separator: "::"),
            contradictionCode: nil,
            contradictionArtifactRefs: []
        )
    }

    func classificationAnchor(
        target: GoalTeachingCaptureTarget,
        payload: GoalTeachingClassificationCorrection,
        metadata: GoalOrchestrationMetadata
    ) throws -> GoalTeachingStableAnchor {
        guard target.canonicalField == payload.field else {
            throw GoalTeachingSignalError.invalidRequest
        }

        switch payload.field {
        case .mode:
            guard case .mode = payload.correctedValue else { throw GoalTeachingSignalError.invalidRequest }
            _ = metadata.understanding.mode.goalMode
        case .domain:
            guard case .domain = payload.correctedValue else { throw GoalTeachingSignalError.invalidRequest }
            _ = metadata.understanding.domains
        case .ownership:
            guard case .ownership = payload.correctedValue else { throw GoalTeachingSignalError.invalidRequest }
            _ = metadata.understanding.ownership.executionOwnership
        case .timeline:
            guard case .timelinePosture = payload.correctedValue else { throw GoalTeachingSignalError.invalidRequest }
            _ = metadata.understanding.timeline.posture
        case .goalSubject:
            throw GoalTeachingSignalError.invalidRequest
        }

        return GoalTeachingStableAnchor(
            artifactKind: .classificationField,
            canonicalField: payload.field,
            candidateID: nil,
            stageID: nil,
            stepID: nil,
            targetFingerprint: payload.normalizedTargetValue,
            contradictionCode: nil,
            contradictionArtifactRefs: []
        )
    }

    func requirementAnchor(
        target: GoalTeachingCaptureTarget,
        metadata: GoalOrchestrationMetadata
    ) throws -> GoalTeachingStableAnchor {
        if metadata.compiledPath.candidates.count > 1 && target.candidateID == nil {
            throw GoalTeachingSignalError.ambiguousScope
        }

        switch target.artifactKind {
        case .requirementHint:
            let matches = metadata.compiledPath.candidates.flatMap { candidate in
                candidate.requirementHints.compactMap { requirement -> GoalTeachingStableAnchor? in
                    guard target.candidateID == nil || target.candidateID == candidate.id else { return nil }
                    guard normalize(requirement.summary) == normalize(target.requirementSummary ?? "") else { return nil }
                    return GoalTeachingStableAnchor(
                        artifactKind: .requirementHint,
                        canonicalField: nil,
                        candidateID: candidate.id,
                        stageID: requirement.relatedStageID,
                        stepID: nil,
                        targetFingerprint: [
                            requirement.kind.rawValue,
                            normalize(requirement.summary),
                            requirement.relatedField?.rawValue ?? "",
                            requirement.relatedStageID ?? "",
                            requirement.blocking.description
                        ].joined(separator: "::"),
                        contradictionCode: nil,
                        contradictionArtifactRefs: []
                    )
                }
            }
            return try exactAnchor(from: matches)
        case .readinessCriterion:
            let matches = metadata.compiledPath.candidates.flatMap { candidate in
                candidate.readinessCriteria.compactMap { criterion -> GoalTeachingStableAnchor? in
                    guard target.candidateID == nil || target.candidateID == candidate.id else { return nil }
                    guard criterion.token == target.readinessToken else { return nil }
                    return GoalTeachingStableAnchor(
                        artifactKind: .readinessCriterion,
                        canonicalField: nil,
                        candidateID: candidate.id,
                        stageID: criterion.targetStageID,
                        stepID: nil,
                        targetFingerprint: [
                            criterion.kind.rawValue,
                            normalize(criterion.summary),
                            criterion.targetStageID ?? "",
                            criterion.token,
                            criterion.blocking.description
                        ].joined(separator: "::"),
                        contradictionCode: nil,
                        contradictionArtifactRefs: []
                    )
                }
            }
            return try exactAnchor(from: matches)
        case .resourceHook:
            let matches = metadata.compiledPath.candidates.flatMap { candidate in
                candidate.resourceHooks.compactMap { hook -> GoalTeachingStableAnchor? in
                    guard target.candidateID == nil || target.candidateID == candidate.id else { return nil }
                    guard normalize(hook.summary) == normalize(target.requirementSummary ?? "") else { return nil }
                    return GoalTeachingStableAnchor(
                        artifactKind: .resourceHook,
                        canonicalField: nil,
                        candidateID: candidate.id,
                        stageID: hook.targetStageID,
                        stepID: nil,
                        targetFingerprint: [
                            hook.kind.rawValue,
                            normalize(hook.summary),
                            hook.targetStageID ?? "",
                            hook.relatedDomains.map(\.rawValue).sorted().joined(separator: "|"),
                            hook.sourceClaimIDs.sorted().joined(separator: "|"),
                            hook.sourceRecordIDs.sorted().joined(separator: "|"),
                            hook.optionality.rawValue,
                            hook.placeholderState.rawValue
                        ].joined(separator: "::"),
                        contradictionCode: nil,
                        contradictionArtifactRefs: []
                    )
                }
            }
            return try exactAnchor(from: matches)
        default:
            throw GoalTeachingSignalError.invalidRequest
        }
    }

    func contradictionAnchor(
        target: GoalTeachingCaptureTarget,
        metadata: GoalOrchestrationMetadata
    ) throws -> GoalTeachingStableAnchor {
        guard let code = target.contradictionCode else {
            throw GoalTeachingSignalError.unanchoredArtifact
        }
        guard target.contradictionArtifactRefs.isEmpty == false else {
            throw GoalTeachingSignalError.unanchoredArtifact
        }
        let normalizedTargetRefs = target.contradictionArtifactRefs.sorted { $0.normalizedIdentity < $1.normalizedIdentity }
        let matches = metadata.contradictionReport.records.filter { record in
            record.code == code &&
            record.candidateID == target.candidateID &&
            record.stageID == target.stageID &&
            record.normalizedArtifactRefs.map {
                GoalTeachingContradictionArtifactRef(
                    kind: $0.kind,
                    id: $0.id,
                    candidateID: $0.candidateID,
                    stageID: $0.stageID
                )
            } == normalizedTargetRefs
        }
        guard matches.count == 1 else {
            throw matches.isEmpty ? GoalTeachingSignalError.artifactNotFound : GoalTeachingSignalError.ambiguousScope
        }
        let match = try exactElement(from: matches)
        return .contradiction(
            code: code,
            candidateID: match.candidateID,
            stageID: match.stageID,
            artifactRefs: normalizedTargetRefs
        )
    }

    func energyAnchor(
        target: GoalTeachingCaptureTarget,
        metadata: GoalOrchestrationMetadata
    ) throws -> GoalTeachingStableAnchor {
        let matches = metadata.energyModel.evaluations.filter { evaluation in
            evaluation.targetKind == target.energyTargetKind &&
            evaluation.targetID == target.energyTargetID &&
            evaluation.candidateID == target.candidateID &&
            evaluation.stageID == target.stageID &&
            evaluation.stepID == target.stepID
        }
        guard matches.count == 1 else {
            throw matches.isEmpty ? GoalTeachingSignalError.artifactNotFound : GoalTeachingSignalError.ambiguousScope
        }
        let match = try exactElement(from: matches)
        return GoalTeachingStableAnchor(
            artifactKind: .energyEvaluation,
            canonicalField: nil,
            candidateID: match.candidateID,
            stageID: match.stageID,
            stepID: match.stepID,
            targetFingerprint: [
                match.targetKind.rawValue,
                match.targetID,
                match.candidateID ?? "",
                match.stageID ?? "",
                match.stepID ?? ""
            ].joined(separator: "::"),
            contradictionCode: nil,
            contradictionArtifactRefs: []
        )
    }

    func matches(_ anchor: GoalTeachingStableAnchor, metadata: GoalOrchestrationMetadata) -> Bool {
        switch anchor.artifactKind {
        case .goalSubjectField:
            return true
        case .classificationField:
            return true
        case .understandingInterpretation:
            let available = ([metadata.understanding.primaryInterpretation] + metadata.understanding.alternateInterpretations).map { interpretation in
                [
                    normalize(interpretation.summary),
                    interpretation.modeHint?.rawValue ?? "",
                    interpretation.domainHints.map(\.rawValue).sorted().joined(separator: "|")
                ].joined(separator: "::")
            }
            return available.contains(anchor.targetFingerprint)
        case .requirementHint:
            return metadata.compiledPath.candidates.contains { candidate in
                candidate.id == anchor.candidateID &&
                candidate.requirementHints.contains { requirement in
                    [
                        requirement.kind.rawValue,
                        normalize(requirement.summary),
                        requirement.relatedField?.rawValue ?? "",
                        requirement.relatedStageID ?? "",
                        requirement.blocking.description
                    ].joined(separator: "::") == anchor.targetFingerprint
                }
            }
        case .readinessCriterion:
            return metadata.compiledPath.candidates.contains { candidate in
                candidate.id == anchor.candidateID &&
                candidate.readinessCriteria.contains { criterion in
                    [
                        criterion.kind.rawValue,
                        normalize(criterion.summary),
                        criterion.targetStageID ?? "",
                        criterion.token,
                        criterion.blocking.description
                    ].joined(separator: "::") == anchor.targetFingerprint
                }
            }
        case .resourceHook:
            return metadata.compiledPath.candidates.contains { candidate in
                candidate.id == anchor.candidateID &&
                candidate.resourceHooks.contains { hook in
                    [
                        hook.kind.rawValue,
                        normalize(hook.summary),
                        hook.targetStageID ?? "",
                        hook.relatedDomains.map(\.rawValue).sorted().joined(separator: "|"),
                        hook.sourceClaimIDs.sorted().joined(separator: "|"),
                        hook.sourceRecordIDs.sorted().joined(separator: "|"),
                        hook.optionality.rawValue,
                        hook.placeholderState.rawValue
                    ].joined(separator: "::") == anchor.targetFingerprint
                }
            }
        case .contradictionShape:
            return metadata.contradictionReport.records.contains { record in
                record.code == anchor.contradictionCode &&
                record.candidateID == anchor.candidateID &&
                record.stageID == anchor.stageID &&
                GoalTeachingStableAnchor.normalizedContradictionFingerprint(
                    code: record.code,
                    artifactRefs: record.normalizedArtifactRefs.map {
                        GoalTeachingContradictionArtifactRef(
                            kind: $0.kind,
                            id: $0.id,
                            candidateID: $0.candidateID,
                            stageID: $0.stageID
                        )
                    }
                ) == anchor.targetFingerprint
            }
        case .energyEvaluation:
            return metadata.energyModel.evaluations.contains { evaluation in
                [
                    evaluation.targetKind.rawValue,
                    evaluation.targetID,
                    evaluation.candidateID ?? "",
                    evaluation.stageID ?? "",
                    evaluation.stepID ?? ""
                ].joined(separator: "::") == anchor.targetFingerprint
            }
        }
    }

    func exactAnchor(from anchors: [GoalTeachingStableAnchor]) throws -> GoalTeachingStableAnchor {
        try exactElement(from: anchors)
    }

    func exactElement<Element>(from elements: [Element]) throws -> Element {
        guard elements.count == 1, let match = elements.first else {
            throw elements.isEmpty ? GoalTeachingSignalError.artifactNotFound : GoalTeachingSignalError.ambiguousScope
        }
        return match
    }

    func signalOrdering(lhs: GoalTeachingSignal, rhs: GoalTeachingSignal) -> Bool {
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        return lhs.id > rhs.id
    }

    func domainOrdering(lhs: LifeDomainKey, rhs: LifeDomainKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
