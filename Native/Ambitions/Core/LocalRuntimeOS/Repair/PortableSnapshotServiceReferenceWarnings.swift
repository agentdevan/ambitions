import Foundation

extension PortableSnapshotService {

    func referenceWarnings(for snapshot: PortableAppSnapshot) -> [PortableImportWarning] {
        let goalIDs = Set(snapshot.goals.map(\.id))
        let stepIDs = Set(
            snapshot.goals.flatMap { goal in
                goal.plan?.sections.flatMap { section in
                    section.steps.map(\.id)
                } ?? []
            }
        )
        var warnings: [PortableImportWarning] = []

        warnings += snapshot.drafts
            .compactMap { draft -> PortableImportWarning? in
                guard let goalID = draft.plannedGoalID, goalIDs.contains(goalID) == false else {
                    return nil
                }
                return PortableImportWarning(
                    id: "reference.draft.\(draft.id).planned_goal",
                    message: "A draft in this package points to a goal that is not included. Review placement before trusting the restore."
                )
            }

        warnings += snapshot.evidence
            .filter { goalIDs.contains($0.goalID) == false }
            .map {
                PortableImportWarning(
                    id: "reference.evidence.\($0.id).goal",
                    message: "A proof item in this package points to a goal that is not included. It will not be silently discarded, but it needs review."
                )
            }

        warnings += snapshot.feedback
            .filter { stepIDs.contains($0.base.stepID) == false }
            .map {
                PortableImportWarning(
                    id: "reference.feedback.\($0.base.id).step",
                    message: "A receipt in this package points to a Step that is not included. It will not be silently discarded, but it needs review."
                )
            }

        warnings += snapshot.captures
            .compactMap { capture -> PortableImportWarning? in
                guard let goalID = capture.linkedGoalID, goalIDs.contains(goalID) == false else {
                    return nil
                }
                return PortableImportWarning(
                    id: "reference.capture.\(capture.id).goal",
                    message: "A capture in this package points to a goal that is not included. Review its destination after import."
                )
            }

        warnings += snapshot.teachingSignals
            .filter { goalIDs.contains($0.goalID) == false }
            .map {
                PortableImportWarning(
                    id: "reference.memory.\($0.id).goal",
                    message: "A memory correction in this package points to a goal that is not included. Review before applying it broadly."
                )
            }

        if let lastOpenedGoalID = snapshot.appState.lastOpenedGoalID, goalIDs.contains(lastOpenedGoalID) == false {
            warnings.append(
                PortableImportWarning(
                    id: "reference.app_state.last_opened_goal",
                    message: "The package remembers a last-opened goal that is not included. Navigation can fall back safely."
                )
            )
        }

        if snapshot.entityRevisionLineageViews.isEmpty == false &&
            snapshot.entityRevisionLineageViews.count != snapshot.entityRevisionTombstones.count {
            warnings.append(
                PortableImportWarning(
                    id: "reference.lineage.tombstone_view_count",
                    message: "A lineage view count does not match the revision tombstones. Review export redaction before import."
                )
            )
        }

        return warnings
    }


    func compareGoals(incoming: [Goal], local: [Goal]) -> (accepted: [Goal], conflicts: [PortableConflict]) {
        let localByID = Dictionary(uniqueKeysWithValues: local.map { ($0.id, $0) })
        var accepted: [Goal] = []
        var conflicts: [PortableConflict] = []

        for item in incoming {
            guard let localItem = localByID[item.id] else {
                accepted.append(item)
                continue
            }

            let decision = conflictPolicyEngine.decide(
                ConflictPolicyCandidate(
                    entityKind: PortableConflictEntityKind.goal.rawValue,
                    localRevision: localItem.revision,
                    incomingRevision: item.revision,
                    localUpdatedAt: localItem.updatedAt,
                    incomingUpdatedAt: item.updatedAt,
                    valuesAreEqual: item == localItem
                )
            )
            switch decision.signal {
            case .noConflict:
                continue
            case .acceptIncoming:
                accepted.append(item)
            case .keepLocal, .requiresUserDecision:
                conflicts.append(makeConflict(kind: .goal, entityID: item.id, decision: decision))
            }
        }

        return (accepted, conflicts)
    }


    func compareDrafts(incoming: [PersistedGoalDraft], local: [PersistedGoalDraft]) -> (accepted: [PersistedGoalDraft], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .draft,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.updatedAt
        )
    }


    func compareEvidence(incoming: [ProgressEvidence], local: [ProgressEvidence]) -> (accepted: [ProgressEvidence], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .evidence,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.capturedAt
        )
    }


    func compareFeedback(incoming: [GoalFeedbackEvent], local: [GoalFeedbackEvent]) -> (accepted: [GoalFeedbackEvent], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .feedback,
            incoming: incoming,
            local: local,
            id: \.base.id,
            updatedAt: \.base.occurredAt
        )
    }


    func compareCaptures(incoming: [Capture], local: [Capture]) -> (accepted: [Capture], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .capture,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.updatedAt
        )
    }


    func compareTeachingSignals(incoming: [GoalTeachingSignal], local: [GoalTeachingSignal]) -> (accepted: [GoalTeachingSignal], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .teachingSignal,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.updatedAt
        )
    }


    func compareAppState(incoming: AppStateSnapshot, local: AppStateSnapshot) -> (accepted: Bool, conflicts: [PortableConflict]) {
        if local == .default {
            return (true, [])
        }
        let decision = conflictPolicyEngine.decide(
            ConflictPolicyCandidate(
                entityKind: PortableConflictEntityKind.appState.rawValue,
                localUpdatedAt: appStateMarker(local),
                incomingUpdatedAt: appStateMarker(incoming),
                valuesAreEqual: incoming == local,
                safeAutomaticMergeAllowed: false
            )
        )
        guard decision.signal != .noConflict else {
            return (false, [])
        }
        return (false, [makeConflict(kind: .appState, entityID: local.id, decision: decision)])
    }


    func compareByUpdatedAt<Item: Equatable>(
        kind: PortableConflictEntityKind,
        incoming: [Item],
        local: [Item],
        id: KeyPath<Item, String>,
        updatedAt: KeyPath<Item, String>
    ) -> (accepted: [Item], conflicts: [PortableConflict]) {
        let localByID = Dictionary(uniqueKeysWithValues: local.map { ($0[keyPath: id], $0) })
        var accepted: [Item] = []
        var conflicts: [PortableConflict] = []

        for item in incoming {
            let itemID = item[keyPath: id]
            guard let localItem = localByID[itemID] else {
                accepted.append(item)
                continue
            }

            let decision = conflictPolicyEngine.decide(
                ConflictPolicyCandidate(
                    entityKind: kind.rawValue,
                    localUpdatedAt: localItem[keyPath: updatedAt],
                    incomingUpdatedAt: item[keyPath: updatedAt],
                    valuesAreEqual: item == localItem
                )
            )
            switch decision.signal {
            case .noConflict:
                continue
            case .acceptIncoming:
                accepted.append(item)
            case .keepLocal, .requiresUserDecision:
                conflicts.append(makeConflict(kind: kind, entityID: itemID, decision: decision))
            }
        }

        return (accepted, conflicts)
    }


    func makeConflict(
        kind: PortableConflictEntityKind,
        entityID: String,
        decision: ConflictPolicyDecision
    ) -> PortableConflict {
        let recommendation: PortableConflictResolutionRecommendation
        switch decision.signal {
        case .acceptIncoming:
            recommendation = .acceptIncoming
        case .keepLocal:
            recommendation = .keepLocal
        case .requiresUserDecision, .noConflict:
            recommendation = .requiresUserDecision
        }
        return makeConflict(
            kind: kind,
            entityID: entityID,
            localMarker: decision.localMarker,
            incomingMarker: decision.incomingMarker,
            recommendation: recommendation,
            reason: decision.reason
        )
    }


    func makeConflict(
        kind: PortableConflictEntityKind,
        entityID: String,
        localMarker: String?,
        incomingMarker: String?,
        recommendation: PortableConflictResolutionRecommendation,
        reason: String
    ) -> PortableConflict {
        PortableConflict(
            id: "\(kind.rawValue):\(entityID)",
            entityKind: kind,
            entityID: entityID,
            localRevisionMarker: localMarker,
            incomingRevisionMarker: incomingMarker,
            recommendation: recommendation,
            reason: reason
        )
    }


    func appStateMarker(_ state: AppStateSnapshot) -> String {
        [
            state.lastBootstrapAt,
            state.lastSeededAt,
            state.lastOpenedGoalID,
            state.userDisplayName,
            state.preferredTab.rawValue
        ]
        .compactMap { $0 }
        .joined(separator: "|")
    }
}
