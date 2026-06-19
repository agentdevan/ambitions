import Foundation

struct AmbitionGraphProjectionStore: Sendable, Equatable, Hashable {
    let snapshots: [AmbitionGraphSnapshot]

    init(snapshots: [AmbitionGraphSnapshot] = []) {
        self.snapshots = Self.orderedUnique(snapshots)
    }

    func snapshot(by id: String) -> AmbitionGraphSnapshot? {
        snapshots.first { $0.id == id }
    }

    func projection(
        for surface: AmbitionGraphProjectionSurface,
        snapshotID: String,
        generatedAt: String,
        id: String
    ) -> AmbitionGraphProjectionSnapshot? {
        guard let source = snapshot(by: snapshotID) else {
            return nil
        }
        return projection(for: surface, from: source, generatedAt: generatedAt, id: id)
    }

    func projection(
        for surface: AmbitionGraphProjectionSurface,
        from snapshot: AmbitionGraphSnapshot,
        generatedAt: String,
        id: String
    ) -> AmbitionGraphProjectionSnapshot {
        let ambitionID = snapshot.ambition.id
        let commitmentIDs = selectedCommitmentIDs(for: surface, in: snapshot)
        let commitmentSet = Set(commitmentIDs)
        let stepIDs = selectedStepIDs(for: surface, in: snapshot, activeCommitments: commitmentSet)
        let proofIDs = selectedProofIDs(for: surface, in: snapshot, activeCommitments: commitmentSet)
        let constraintIDs = selectedConstraintIDs(for: surface, in: snapshot)
        let outcomeIDs = selectedOutcomeIDs(for: surface, in: snapshot)
        let identityDirectionIDs = selectedIdentityDirectionIDs(for: surface, in: snapshot)
        let closureEventIDs = selectedClosureEventIDs(for: surface, in: snapshot, activeCommitments: commitmentSet)
        let recoveryThreadIDs = selectedRecoveryThreadIDs(for: surface, in: snapshot)
        let recommendationTraceIDs = selectedRecommendationTraceIDs(for: surface, in: snapshot, activeCommitments: commitmentSet)

        let sourceFields = selectedSourceFields(for: surface, in: snapshot, proofIDs: proofIDs)
        let selectedPrivacyClasses = snapshot.privacyClasses(for: commitmentIDs, proofIDs: proofIDs, constraintIDs: constraintIDs)
        let sourceObjectIDs = [snapshot.ambition.id] + commitmentIDs + proofIDs + stepIDs + constraintIDs

        return AmbitionGraphProjectionSnapshot(
            id: id,
            sourceSnapshotID: snapshot.id,
            surface: surface,
            generatedAt: generatedAt,
            ambitionID: ambitionID,
            sourceFields: sourceFields,
            sourceObjectIDs: sourceObjectIDs,
            privacyClasses: selectedPrivacyClasses,
            ambitionPrivacyClasses: [snapshot.ambition.privacyClass],
            commitmentIDs: commitmentIDs,
            proofIDs: proofIDs,
            constraintIDs: constraintIDs,
            outcomeIDs: outcomeIDs,
            identityDirectionIDs: identityDirectionIDs,
            stepIDs: stepIDs,
            closureEventIDs: closureEventIDs,
            recoveryThreadIDs: recoveryThreadIDs,
            recommendationTraceIDs: recommendationTraceIDs
        )
    }

    func projections(
        for snapshot: AmbitionGraphSnapshot,
        generatedAt: String,
        idPrefix: String
    ) -> [AmbitionGraphProjectionSnapshot] {
        AmbitionGraphProjectionSurface.allCases.map { surface in
            projection(
                for: surface,
                from: snapshot,
                generatedAt: generatedAt,
                id: "\(idPrefix)-\(surface.rawValue)"
            )
        }
    }

    func crossSurfaceLoop(
        for snapshot: AmbitionGraphSnapshot,
        generatedAt: String,
        id: String,
        projectionIDPrefix: String
    ) -> AmbitionGraphCrossSurfaceLoop {
        let surfaceProjections = projections(
            for: snapshot,
            generatedAt: generatedAt,
            idPrefix: projectionIDPrefix
        )

        return AmbitionGraphCrossSurfaceLoop(
            id: id,
            sourceSnapshotID: snapshot.id,
            generatedAt: generatedAt,
            ambitionID: snapshot.ambition.id,
            localProjectionOnly: surfaceProjections.allSatisfy(\.localProjectionOnly),
            coveredSurfaces: surfaceProjections.map(\.surface),
            surfaceProjectionIDs: surfaceProjections.map(\.id),
            sourceFields: surfaceProjections.flatMap(\.sourceFields),
            sourceObjectIDs: surfaceProjections.flatMap(\.sourceObjectIDs),
            privacyClasses: surfaceProjections.flatMap(\.privacyClasses),
            identityDirectionIDs: surfaceProjections.flatMap(\.identityDirectionIDs),
            outcomeIDs: surfaceProjections.flatMap(\.outcomeIDs),
            commitmentIDs: surfaceProjections.flatMap(\.commitmentIDs),
            stepIDs: snapshot.steps.map(\.id),
            closureEventIDs: surfaceProjections.flatMap(\.closureEventIDs),
            proofIDs: surfaceProjections.flatMap(\.proofIDs),
            recoveryThreadIDs: surfaceProjections.flatMap(\.recoveryThreadIDs),
            recommendationTraceIDs: surfaceProjections.flatMap(\.recommendationTraceIDs)
        )
    }

    func crossSurfaceLoop(
        for snapshotID: String,
        generatedAt: String,
        id: String,
        projectionIDPrefix: String
    ) -> AmbitionGraphCrossSurfaceLoop? {
        guard let source = snapshot(by: snapshotID) else {
            return nil
        }

        return crossSurfaceLoop(
            for: source,
            generatedAt: generatedAt,
            id: id,
            projectionIDPrefix: projectionIDPrefix
        )
    }

    static func orderedUnique(_ snapshots: [AmbitionGraphSnapshot]) -> [AmbitionGraphSnapshot] {
        var seen = Set<String>()
        return snapshots
            .filter { seen.insert($0.id).inserted }
            .sorted { lhs, rhs in
                if lhs.id == rhs.id {
                    return lhs.ambition.id < rhs.ambition.id
                }
                return lhs.id < rhs.id
            }
    }

    func selectedCommitmentIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.commitments
                .filter { activeTodayCommitment($0) && ($0.stepID != nil || $0.promisedFor != nil || $0.expectedEffort != nil) }
                .map(\.id)
        case .goals:
            return snapshot.commitments
                .filter { $0.status != .completed && $0.goalThreadID != nil }
                .map(\.id)
        case .capture:
            return snapshot.commitments.filter {
                $0.minimumProofDescription != nil || $0.fitReason != nil
            }.map(\.id)
        case .time:
            return snapshot.commitments.filter {
                $0.promisedFor != nil || $0.expectedEffort != nil
            }.map(\.id)
        case .you:
            return snapshot.commitments.filter { $0.goalThreadID != "thread-goals" }.map(\.id)
        }
    }

    func activeTodayCommitment(_ commitment: Commitment) -> Bool {
        [.open, .promised, .inFlight, .waiting, .stillCounts, .held].contains(commitment.status)
    }

    func selectedStepIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot,
        activeCommitments: Set<String>
    ) -> [String] {
        let activeGoalThreads = Set(
            snapshot.commitments
                .filter { activeCommitments.contains($0.id) }
                .compactMap(\.goalThreadID)
        )

        switch surface {
        case .today:
            return snapshot.steps.filter { step in
                step.isCompleted == false &&
                    step.isMilestone == false &&
                    (activeGoalThreads.contains(step.goalThreadID ?? "") ||
                        step.goalThreadID == nil ||
                        step.expectedEffortMinutes != nil)
            }.map(\.id)
        case .goals:
            return snapshot.steps.filter { $0.isMilestone == false && $0.isCompleted == false }.map(\.id)
        case .capture:
            return []
        case .time:
            return snapshot.steps.filter { $0.expectedEffortMinutes != nil && $0.isMilestone == false }.map(\.id)
        case .you:
            return snapshot.steps.filter { $0.isCompleted == false && $0.isMilestone == false }.map(\.id)
        }
    }

    func selectedProofIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot,
        activeCommitments: Set<String>
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.proofs.filter { proof in
                guard let commitmentID = proof.commitmentID else { return false }
                return activeCommitments.contains(commitmentID) && proof.proofType == .text
            }.map(\.id)
        case .goals:
            return snapshot.proofs.map(\.id)
        case .you:
            return snapshot.proofs.filter { $0.proofType == .text && $0.userConfirmed }.map(\.id)
        case .capture:
            return snapshot.proofs.filter { proof in
                (proof.source?.isEmpty == false) || proof.artifactReference != nil || proof.text != nil
            }.map(\.id)
        case .time:
            return snapshot.proofs.filter { proof in
                let linkedToTimedCommitment = proof.commitmentID.flatMap { activeCommitments.contains($0) } ?? false
                let isTimeArtifact = proof.ambitionID == snapshot.ambition.id && proof.ambitionID.isEmpty == false
                return linkedToTimedCommitment || isTimeArtifact && proof.proofType == .photo
            }.map(\.id)
        }
    }

    func selectedConstraintIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.constraints.filter(\.userConfirmed).map(\.id)
        case .goals, .you:
            return snapshot.constraints.map(\.id)
        case .capture:
            return snapshot.constraints.filter { $0.mitigation != nil && $0.mitigation?.isEmpty == false }.map(\.id)
        case .time:
            return snapshot.constraints.filter { $0.patternType == .environment || $0.patternType == .externalRequirement }.map(\.id)
        }
    }

    func selectedOutcomeIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.outcomes.filter(\.isPrimary).map(\.id)
        case .goals:
            return snapshot.outcomes.filter { $0.goalThreadID != nil }.map(\.id)
        case .capture:
            return snapshot.outcomes.filter { $0.id.hasPrefix("capture-") }.map(\.id)
        case .time:
            return snapshot.outcomes.filter { $0.kind == .behavior || $0.kind == .state }.map(\.id)
        case .you:
            return snapshot.outcomes.map(\.id)
        }
    }

    func selectedIdentityDirectionIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot
    ) -> [String] {
        switch surface {
        case .today, .time:
            return []
        case .goals, .capture, .you:
            return snapshot.identityDirections.map(\.id)
        }
    }

    func selectedClosureEventIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot,
        activeCommitments: Set<String>
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.closureEvents.filter { event in
                event.commitmentID.flatMap { activeCommitments.contains($0) } ?? false
            }.map(\.id)
        case .goals, .you:
            return snapshot.closureEvents.filter { event in
                event.closureState.isClosureForRecovery == false
            }.map(\.id)
        case .capture:
            return snapshot.closureEvents.filter { $0.followUpPlan != nil }.map(\.id)
        case .time:
            return snapshot.closureEvents.filter { event in
                event.closureState == .stillCounts || event.closureState == .moved
            }.map(\.id)
        }
    }

    func selectedRecoveryThreadIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.recoveryThreads.filter(\.isRecoverable).map(\.id)
        case .time:
            return snapshot.recoveryThreads.filter { $0.status == .active || $0.status == .held }.map(\.id)
        case .goals, .capture, .you:
            return snapshot.recoveryThreads.map(\.id)
        }
    }

    func selectedRecommendationTraceIDs(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot,
        activeCommitments: Set<String>
    ) -> [String] {
        switch surface {
        case .today:
            return snapshot.recommendationTraces.filter {
                activeCommitments.contains($0.recommendedObjectID)
            }.map(\.id)
        case .goals:
            return snapshot.recommendationTraces.filter { $0.sourceLabels.isEmpty == false }.map(\.id)
        case .capture:
            return snapshot.recommendationTraces.filter { $0.sourceRefs.contains(where: { $0.isEmpty == false }) }.map(\.id)
        case .time:
            return snapshot.recommendationTraces.filter { $0.userAction != .none }.map(\.id)
        case .you:
            return snapshot.recommendationTraces.map(\.id)
        }
    }

    func selectedSourceFields(
        for surface: AmbitionGraphProjectionSurface,
        in snapshot: AmbitionGraphSnapshot,
        proofIDs: [String]
    ) -> [String] {
        switch surface {
        case .capture:
            return selectedCaptureSourceFields(in: snapshot)
        case .you:
            return selectedAllSourceFields(in: snapshot, proofIDs: proofIDs)
        default:
            return selectedSurfaceSourceFields(in: snapshot, proofIDs: proofIDs, surface: surface)
        }
    }

    func selectedSurfaceSourceFields(
        in snapshot: AmbitionGraphSnapshot,
        proofIDs: [String],
        surface: AmbitionGraphProjectionSurface
    ) -> [String] {
        let includedProofs = Set(proofIDs)
        return snapshot.proofs.filter { includedProofs.contains($0.id) }.compactMap(\.source) +
            snapshot.recommendationTraces.filter {
                switch surface {
                case .today:
                    return $0.sourceLabels.contains(where: { $0.isEmpty == false })
                case .goals:
                    return $0.sourceRefs.contains(where: { $0.isEmpty == false })
                case .time:
                    return $0.userAction != .none
                default:
                    return false
                }
            }.flatMap(\.sourceRefs) +
            snapshot.recommendationTraces.flatMap(\.sourceLabels)
    }

    func selectedCaptureSourceFields(in snapshot: AmbitionGraphSnapshot) -> [String] {
        snapshot.proofs.compactMap(\.source) +
            snapshot.recommendationTraces.flatMap(\.sourceLabels) +
            snapshot.recommendationTraces.flatMap(\.sourceRefs)
    }

    func selectedAllSourceFields(
        in snapshot: AmbitionGraphSnapshot,
        proofIDs: [String]
    ) -> [String] {
        snapshot.proofs.compactMap(\.source) +
            selectedSurfaceSourceFields(in: snapshot, proofIDs: proofIDs, surface: .goals) +
            snapshot.recommendationTraces.flatMap(\.sourceLabels) +
            snapshot.recommendationTraces.flatMap(\.sourceRefs)
    }
}
