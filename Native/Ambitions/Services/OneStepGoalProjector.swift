import Foundation

struct OneStepGoalProjector: Sendable {
    struct Input: Sendable {
        let oneStepGoals: [OneStepGoal]
        let goals: [Goal]
        let hiddenOneStepGoalIDs: Set<OneStepGoalID>
        let hiddenAreaIDs: Set<LifeAreaID>
        let privacyLevel: OneStepGoalPrivacyLevel
        let includeArchived: Bool
        let maxOneStepGoalsPerArea: Int

        init(
            oneStepGoals: [OneStepGoal],
            goals: [Goal] = [],
            hiddenOneStepGoalIDs: Set<OneStepGoalID> = [],
            hiddenAreaIDs: Set<LifeAreaID> = [],
            privacyLevel: OneStepGoalPrivacyLevel = .full,
            includeArchived: Bool = false,
            maxOneStepGoalsPerArea: Int = 5
        ) {
            self.oneStepGoals = oneStepGoals
            self.goals = goals
            self.hiddenOneStepGoalIDs = hiddenOneStepGoalIDs
            self.hiddenAreaIDs = hiddenAreaIDs
            self.privacyLevel = privacyLevel
            self.includeArchived = includeArchived
            self.maxOneStepGoalsPerArea = max(0, maxOneStepGoalsPerArea)
        }
    }

    func projection(from input: Input) -> OneStepGoalsProjection {
        let visibleOneStepGoals = input.oneStepGoals.filter { input.includeArchived || $0.status.isArchived == false }
        let activeGoalIDs = Set(input.goals.filter { $0.state == .active }.map(\.id))
        let groupedByArea = Dictionary(grouping: visibleOneStepGoals.compactMap { oneStepGoal -> (LifeAreaID, OneStepGoal)? in
            guard let lifeAreaID = oneStepGoal.lifeAreaID else { return nil }
            return (lifeAreaID, oneStepGoal)
        }, by: \.0).mapValues { pairs in pairs.map(\.1) }
        let standalone = visibleOneStepGoals.filter { $0.lifeAreaID == nil }

        let canonicalAreas = LifeAreaDefinition.canonical.map { definition in
            areaSummary(
                id: definition.id.rawValue,
                lifeAreaID: definition.id,
                definition: definition,
                displayName: definition.displayName,
                oneStepGoals: groupedByArea[definition.id] ?? [],
                activeGoalIDs: activeGoalIDs,
                input: input
            )
        }

        let knownAreaIDs = Set(LifeAreaDefinition.canonical.map(\.id))
        let unknownAreas = groupedByArea.keys
            .filter { knownAreaIDs.contains($0) == false }
            .sorted()
            .map { areaID in
                areaSummary(
                    id: areaID.rawValue,
                    lifeAreaID: areaID,
                    definition: nil,
                    displayName: "Area unavailable",
                    oneStepGoals: groupedByArea[areaID] ?? [],
                    activeGoalIDs: activeGoalIDs,
                    input: input
                )
            }

        let standaloneArea = standalone.isEmpty ? [] : [
            areaSummary(
                id: "standalone",
                lifeAreaID: nil,
                definition: nil,
                displayName: "No Life Area",
                oneStepGoals: standalone,
                activeGoalIDs: activeGoalIDs,
                input: input
            )
        ]

        let areas = (canonicalAreas + unknownAreas + standaloneArea).sorted(by: areaOrdering)
        return OneStepGoalsProjection(
            areas: areas,
            counts: statusCounts(for: visibleOneStepGoals),
            privacyLevel: input.privacyLevel
        )
    }

    private func areaSummary(
        id: String,
        lifeAreaID: LifeAreaID?,
        definition: LifeAreaDefinition?,
        displayName: String,
        oneStepGoals: [OneStepGoal],
        activeGoalIDs: Set<String>,
        input: Input
    ) -> OneStepGoalAreaSummary {
        let isAreaHidden = lifeAreaID.map { input.hiddenAreaIDs.contains($0) } ?? false
        let ordered = oneStepGoals.sorted(by: oneStepGoalOrdering)
        let summaries = ordered
            .prefix(input.maxOneStepGoalsPerArea)
            .map { oneStepGoal in
                let privacyLevel: OneStepGoalPrivacyLevel = isAreaHidden ||
                    input.hiddenOneStepGoalIDs.contains(oneStepGoal.id) ||
                    oneStepGoal.isSensitive ||
                    input.privacyLevel == .redacted
                    ? .redacted
                    : input.privacyLevel
                return OneStepGoalSummary(
                    oneStepGoal: oneStepGoal,
                    linkedActiveGoalCount: oneStepGoal.linkedGoalIDs.filter { activeGoalIDs.contains($0) }.count,
                    privacyLevel: privacyLevel
                )
            }
        let counts = statusCounts(for: oneStepGoals)
        let areaPrivacy: OneStepGoalPrivacyLevel = isAreaHidden || input.privacyLevel == .redacted ? .redacted : input.privacyLevel
        return OneStepGoalAreaSummary(
            id: id,
            lifeAreaID: lifeAreaID,
            definition: definition,
            displayName: displayName,
            oneStepGoals: Array(summaries),
            counts: counts,
            emptyTitle: "No One-Step Goals here yet",
            emptyMessage: lifeAreaID == nil
                ? "Standalone tasks can wait here without becoming a full goal."
                : "Small standalone tasks can live under this Life Area.",
            privacyLevel: areaPrivacy,
            accessibility: OneStepGoalAccessibilityProjection(
                label: "One-Step Goals, \(displayName)",
                value: areaPrivacy == .redacted
                    ? "\(counts.total) One-Step Goals. Detail hidden."
                    : "\(counts.total) One-Step Goals. \(counts.openCount) open. \(counts.parked) parked.",
                hint: "Tasks are standalone One-Step Goals. They do not create Goals automatically."
            )
        )
    }

    private func areaOrdering(_ lhs: OneStepGoalAreaSummary, _ rhs: OneStepGoalAreaSummary) -> Bool {
        let leftRank = lhs.counts.total > 0 ? 0 : 1
        let rightRank = rhs.counts.total > 0 ? 0 : 1
        if leftRank != rightRank {
            return leftRank < rightRank
        }

        let leftOrder = lhs.definition?.canonicalOrder ?? (lhs.lifeAreaID == nil ? Int.max - 1 : Int.max)
        let rightOrder = rhs.definition?.canonicalOrder ?? (rhs.lifeAreaID == nil ? Int.max - 1 : Int.max)
        if leftOrder != rightOrder {
            return leftOrder < rightOrder
        }

        if lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) != .orderedSame {
            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    private func oneStepGoalOrdering(_ lhs: OneStepGoal, _ rhs: OneStepGoal) -> Bool {
        if statusRank(lhs.status) != statusRank(rhs.status) {
            return statusRank(lhs.status) < statusRank(rhs.status)
        }
        if lhs.timing?.dueAt != rhs.timing?.dueAt {
            return (lhs.timing?.dueAt ?? "9999-12-31T23:59:59Z") < (rhs.timing?.dueAt ?? "9999-12-31T23:59:59Z")
        }
        if lhs.lastReferencedAt != rhs.lastReferencedAt {
            return (lhs.lastReferencedAt ?? "") > (rhs.lastReferencedAt ?? "")
        }
        if lhs.updatedAt != rhs.updatedAt {
            return (lhs.updatedAt ?? "") > (rhs.updatedAt ?? "")
        }
        let leftArea = lhs.lifeAreaID?.rawValue ?? "zzzz-standalone"
        let rightArea = rhs.lifeAreaID?.rawValue ?? "zzzz-standalone"
        if leftArea != rightArea {
            return leftArea < rightArea
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    private func statusRank(_ status: OneStepGoalStatus) -> Int {
        switch status {
        case .today, .ready, .scheduled:
            return 0
        case .waiting, .reviewLater:
            return 1
        case .parked:
            return 2
        case .completed:
            return 3
        case .archived:
            return 4
        }
    }

    private func statusCounts(for oneStepGoals: [OneStepGoal]) -> OneStepGoalStatusCounts {
        OneStepGoalStatusCounts(
            ready: oneStepGoals.filter { $0.status == .ready }.count,
            today: oneStepGoals.filter { $0.status == .today }.count,
            scheduled: oneStepGoals.filter { $0.status == .scheduled }.count,
            waiting: oneStepGoals.filter { $0.status == .waiting }.count,
            reviewLater: oneStepGoals.filter { $0.status == .reviewLater }.count,
            parked: oneStepGoals.filter { $0.status == .parked }.count,
            completed: oneStepGoals.filter { $0.status == .completed }.count,
            archived: oneStepGoals.filter { $0.status == .archived }.count
        )
    }
}
