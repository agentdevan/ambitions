import Foundation

struct LifeAreaAtlasProjector: Sendable {
    struct Input: Sendable {
        let goals: [Goal]
        let northStars: [NorthStar]
        let proofProjection: ProofResourceGraphProjection?
        let receiptProjection: ActionReceiptProjection?
        let hiddenAreaIDs: Set<LifeAreaID>
        let privacyLevel: LifeAreaPrivacyLevel
        let maxGoalReferencesPerArea: Int

        init(
            goals: [Goal],
            northStars: [NorthStar] = [],
            proofProjection: ProofResourceGraphProjection? = nil,
            receiptProjection: ActionReceiptProjection? = nil,
            hiddenAreaIDs: Set<LifeAreaID> = [],
            privacyLevel: LifeAreaPrivacyLevel = .full,
            maxGoalReferencesPerArea: Int = 3
        ) {
            self.goals = goals
            self.northStars = northStars
            self.proofProjection = proofProjection
            self.receiptProjection = receiptProjection
            self.hiddenAreaIDs = hiddenAreaIDs
            self.privacyLevel = privacyLevel
            self.maxGoalReferencesPerArea = max(0, maxGoalReferencesPerArea)
        }
    }

    func atlas(from input: Input) -> LifeAreasAtlasProjection {
        LifeAreasAtlasProjection(overview: overview(from: input))
    }

    func overview(from input: Input) -> LifeAreasOverviewProjection {
        let grouped = LifeGraphResolver.groupGoalsByPrimaryDomain(input.goals)
        let northStarsByArea = Dictionary(grouping: input.northStars.filter { $0.posture.isArchived == false }, by: \.primaryLifeAreaID)
        let summaries = LifeAreaDefinition.canonical.map { definition in
            areaSummary(
                definition: definition,
                goals: grouped[definition.domainKey] ?? [],
                northStars: northStarsByArea[definition.id] ?? [],
                input: input
            )
        }

        return LifeAreasOverviewProjection(
            areas: summaries.sorted(by: areaOrdering),
            privacyLevel: input.privacyLevel
        )
    }

    private func areaSummary(
        definition: LifeAreaDefinition,
        goals: [Goal],
        northStars: [NorthStar],
        input: Input
    ) -> LifeAreaSummary {
        let isRedacted = input.hiddenAreaIDs.contains(definition.id) || input.privacyLevel == .redacted
        let privacyLevel: LifeAreaPrivacyLevel = isRedacted ? .redacted : input.privacyLevel
        let orderedGoals = goals.sorted(by: goalOrdering)
        let activeGoals = orderedGoals.filter { $0.state == .active }
        let parkedGoals = orderedGoals.filter { $0.state == .paused }
        let waitingReferences = orderedGoals.flatMap(waitingReferences)
        let proofHooks = orderedGoals.flatMap { goal in proofReferences(for: goal, projection: input.proofProjection) }
        let receiptHooks = orderedGoals.flatMap { goal in receiptReferences(for: goal, projection: input.receiptProjection) }
        let counts = LifeAreaCounts(
            activeGoalCount: activeGoals.count,
            parkedGoalCount: parkedGoals.count,
            northStarCount: northStars.count,
            waitingCount: waitingReferences.count,
            proofCount: proofHooks.count,
            receiptCount: receiptHooks.count
        )
        let visibleActive = activeGoals.prefix(input.maxGoalReferencesPerArea).map { LifeAreaGoalReference(goal: $0, privacyLevel: privacyLevel) }
        let visibleParked = parkedGoals.prefix(input.maxGoalReferencesPerArea).map { LifeAreaGoalReference(goal: $0, privacyLevel: privacyLevel) }
        let mostRelevantGoal = (activeGoals.first ?? parkedGoals.first).map { LifeAreaGoalReference(goal: $0, privacyLevel: privacyLevel) }
        let hooks = LifeAreaRelationshipHooks(
            goalReferences: orderedGoals.map(goalReference),
            proofReferences: proofHooks,
            receiptReferences: receiptHooks,
            waitingReferences: waitingReferences,
            futureNorthStarCount: northStars.count,
            hasDormantDirection: northStars.contains { $0.posture.isDormantDirection },
            supportsNorthStarGrouping: true,
            supportsOneStepGoalGrouping: true
        )
        return LifeAreaSummary(
            definition: definition,
            posture: posture(for: counts, isRedacted: isRedacted),
            counts: counts,
            activeGoals: visibleActive,
            parkedGoals: visibleParked,
            mostRelevantGoal: mostRelevantGoal,
            nextFocus: nextFocus(activeGoals: activeGoals, parkedGoals: parkedGoals, counts: counts, privacyLevel: privacyLevel),
            privacyLevel: privacyLevel,
            relationshipHooks: hooks
        )
    }

    private func posture(for counts: LifeAreaCounts, isRedacted: Bool) -> LifeAreaPosture {
        if isRedacted {
            return .unavailable
        }
        if counts.waitingCount > 0 {
            return .needsAttention
        }
        if counts.activeGoalCount > 0 {
            return .active
        }
        if counts.parkedGoalCount > 0 || counts.northStarCount > 0 || counts.proofCount > 0 || counts.receiptCount > 0 {
            return .light
        }
        return .empty
    }

    private func nextFocus(
        activeGoals: [Goal],
        parkedGoals: [Goal],
        counts: LifeAreaCounts,
        privacyLevel: LifeAreaPrivacyLevel
    ) -> String? {
        guard privacyLevel != .redacted else { return "Detail hidden" }
        if counts.waitingCount > 0 {
            return "Review later"
        }
        if let active = activeGoals.first {
            return active.title
        }
        if counts.northStarCount > 0 {
            return "Held without pressure"
        }
        if parkedGoals.isEmpty == false {
            return "Organize this area"
        }
        return nil
    }

    private func areaOrdering(_ lhs: LifeAreaSummary, _ rhs: LifeAreaSummary) -> Bool {
        let leftRank = areaRank(lhs)
        let rightRank = areaRank(rhs)
        if leftRank != rightRank {
            return leftRank < rightRank
        }
        if lhs.definition.canonicalOrder != rhs.definition.canonicalOrder {
            return lhs.definition.canonicalOrder < rhs.definition.canonicalOrder
        }
        let nameCompare = lhs.definition.displayName.localizedCaseInsensitiveCompare(rhs.definition.displayName)
        if nameCompare != .orderedSame {
            return nameCompare == .orderedAscending
        }
        return lhs.id.rawValue < rhs.id.rawValue
    }

    private func areaRank(_ area: LifeAreaSummary) -> Int {
        if area.counts.activeGoalCount > 0 { return 0 }
        if area.counts.parkedGoalCount > 0 || area.counts.northStarCount > 0 || area.counts.waitingCount > 0 || area.counts.proofCount > 0 || area.counts.receiptCount > 0 { return 1 }
        return 2
    }

    private func goalOrdering(_ lhs: Goal, _ rhs: Goal) -> Bool {
        if lifecycleRank(lhs.state) != lifecycleRank(rhs.state) {
            return lifecycleRank(lhs.state) < lifecycleRank(rhs.state)
        }
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    private func lifecycleRank(_ state: GoalLifecycleState) -> Int {
        switch state {
        case .active:
            return 0
        case .paused:
            return 1
        case .draft:
            return 2
        case .completed:
            return 3
        case .archived:
            return 4
        }
    }

    private func goalReference(_ goal: Goal) -> LifeGraphObjectReference {
        LifeGraphObjectReference(kind: .goal, id: goal.id, label: goal.title, sourceDomain: .goals)
    }

    private func waitingReferences(for goal: Goal) -> [LifeGraphObjectReference] {
        let blockedSteps = goal.plan?.sections.flatMap(\.steps).filter { $0.state == .blocked } ?? []
        return blockedSteps.map { step in
            LifeGraphObjectReference(kind: .waitingItem, id: step.id, parentContextID: goal.id, label: step.title, sourceDomain: .goalEngine)
        }
    }

    private func proofReferences(for goal: Goal, projection: ProofResourceGraphProjection?) -> [LifeGraphObjectReference] {
        guard let projection else { return [] }
        return projection.proof(attachedTo: goalReference(goal)).map(\.lifeGraphObjectReference)
    }

    private func receiptReferences(for goal: Goal, projection: ActionReceiptProjection?) -> [LifeGraphObjectReference] {
        guard let projection else { return [] }
        return projection.receipts(for: goalReference(goal)).map(\.lifeGraphObjectReference)
    }
}
