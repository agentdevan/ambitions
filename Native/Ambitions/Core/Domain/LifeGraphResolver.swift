import Foundation

enum LifeGraphResolver {
    static func primaryDomain(for goal: Goal) -> LifeDomainKey? {
        primaryDomain(for: goal.lifeGraph)
    }

    static func primaryDomain(for draft: GoalDraft) -> LifeDomainKey? {
        primaryDomain(for: draft.lifeGraph)
    }

    static func groupGoalsByPrimaryDomain(_ goals: [Goal]) -> [LifeDomainKey?: [Goal]] {
        Dictionary(grouping: goals, by: { primaryDomain(for: $0) })
    }

    static func relationshipGraph(for goal: Goal, within goals: [Goal]) -> GoalRelationshipGraph {
        let goalIDs = Set(goals.map(\.id))
        let parent = goal.parentGoalID.flatMap { parentID in
            goals.first(where: { $0.id == parentID && goalIDs.contains(parentID) })
        }
        let children = goals.filter { candidate in
            (candidate.parentGoalID == goal.id && candidate.relationshipKind != .support) ||
                goal.childGoalIDs.contains(candidate.id)
        }
        let supportGoals = goals.filter { candidate in
            goal.supportGoalIDs.contains(candidate.id) ||
                (candidate.parentGoalID == goal.id && candidate.relationshipKind == .support)
        }

        return GoalRelationshipGraph(
            focus: goal,
            parent: parent,
            children: orderedUniqueGoals(children),
            supportGoals: orderedUniqueGoals(supportGoals)
        )
    }

    static func sharedLifeSummary(
        for goal: Goal,
        within goals: [Goal],
        now: Date
    ) -> SharedLifeGoalSummary {
        let graph = relationshipGraph(for: goal, within: goals)
        let participants = goal.lifeGraph?.sharedLife?.participants ?? []
        let responsibilities = goal.lifeGraph?.sharedLife?.responsibilities ?? []
        let participantLookup = Dictionary(uniqueKeysWithValues: participants.map { ($0.id, $0) })
        let participantNames = participants.map(\.displayName).sorted()
        let labels = participants.map {
            $0.roleLabel ?? $0.relationshipKind.rawValue.replacingOccurrences(of: "_", with: " ")
        }.sorted()
        let responsibilitySummary = SharedResponsibilitySummary(
            totalCount: responsibilities.count,
            careCount: responsibilities.filter { $0.kind == .care }.count,
            householdCount: responsibilities.filter { $0.kind == .household }.count,
            appointmentCount: responsibilities.filter { $0.kind == .appointment }.count,
            logisticsCount: responsibilities.filter { $0.kind == .logistics }.count,
            supportCount: responsibilities.filter { $0.kind == .support }.count,
            participantNames: Array(Set(responsibilities.compactMap { responsibility in
                responsibility.participantID.flatMap { participantLookup[$0]?.displayName }
            })).sorted()
        )
        let coordinationSignals = coordinationSignals(for: goal, now: now)

        var reasons: [String] = []
        if responsibilitySummary.careCount > 0 {
            reasons.append("Care responsibilities are active around this goal.")
        }
        if responsibilitySummary.appointmentCount > 0 || coordinationSignals.isEmpty == false {
            reasons.append("Shared coordination timing is part of this goal's context.")
        }
        if graph.supportGoals.isEmpty == false || goal.relationshipKind == .support || goal.mode == .delegatedSupport {
            reasons.append("Support work is part of the current structure, so progress should stay humane.")
        }

        var pressure = 0.18
        if responsibilitySummary.totalCount > 0 {
            pressure += min(0.16, Double(responsibilitySummary.totalCount) * 0.05)
        }
        if responsibilitySummary.careCount > 0 {
            pressure += 0.14
        }
        if coordinationSignals.contains(where: \.isTimed) {
            pressure += 0.08
        }
        if graph.supportGoals.isEmpty == false {
            pressure += min(0.08, Double(graph.supportGoals.count) * 0.04)
        }
        if goal.timing.tempo == .deadlineBased,
           coordinationSignals.isEmpty == false,
           let due = parseDate(goal.timing.dueAt ?? goal.timing.targetBy ?? goal.timing.windowEnd) {
            let days = Calendar(identifier: .gregorian).dateComponents([.day], from: now, to: due).day ?? 0
            if days <= 3 {
                pressure += 0.1
            } else if days <= 7 {
                pressure += 0.06
            }
        }

        let boundedPressure = roundToTwoDecimals(min(max(pressure, 0.05), 0.95))
        let relationshipLabels = labels.isEmpty
            ? fallbackRelationshipLabels(goal: goal, graph: graph)
            : labels

        if reasons.isEmpty {
            reasons.append("Shared-life context is present but still light.")
        }

        return SharedLifeGoalSummary(
            goalID: goal.id,
            participantNames: participantNames,
            relationshipLabels: relationshipLabels,
            delegatedSupportActive: goal.mode == .delegatedSupport || goal.relationshipKind == .support || graph.supportGoals.isEmpty == false,
            careContextActive: responsibilitySummary.careCount > 0,
            structuralSupportGoalCount: graph.supportGoals.count,
            responsibilitySummary: responsibilitySummary,
            coordinationSignals: coordinationSignals,
            pressureScore: boundedPressure,
            reasons: Array(reasons.prefix(3))
        )
    }

    static func coordinationSignals(for goal: Goal, now: Date) -> [SharedLifeCoordinationSignal] {
        let responsibilities = goal.lifeGraph?.sharedLife?.responsibilities ?? []
        let dueDate = parseDate(goal.timing.dueAt ?? goal.timing.targetBy ?? goal.timing.windowEnd)

        return responsibilities.compactMap { responsibility in
            guard let coordination = responsibility.coordination else { return nil }
            let title = coordination.title ?? responsibility.title
            var fragments: [String] = []
            if let summary = coordination.summary, summary.isEmpty == false {
                fragments.append(summary)
            }
            if let note = coordination.preparationNote, note.isEmpty == false {
                fragments.append(note)
            }
            if let location = coordination.locationHint, location.isEmpty == false {
                fragments.append(location)
            }
            let isTimed = dueDate != nil
            let needsPreparation = coordination.preparationNote?.isEmpty == false
            let baseSummary = fragments.isEmpty ? "Shared coordination should stay visible." : fragments.joined(separator: " ")
            let summary: String
            if isTimed, let dueDate {
                let days = Calendar(identifier: .gregorian).dateComponents([.day], from: now, to: dueDate).day ?? 0
                summary = days <= 3 ? "\(baseSummary) Timing is close." : baseSummary
            } else {
                summary = baseSummary
            }
            return SharedLifeCoordinationSignal(
                id: responsibility.id,
                title: title,
                summary: summary,
                needsPreparation: needsPreparation,
                isTimed: isTimed
            )
        }
    }

    static func dependencies(forMilestoneID milestoneID: String, in context: LifeGraphContext?) -> [LifeGraphMilestone] {
        guard let context,
              let milestone = context.milestones.first(where: { $0.id == milestoneID }) else {
            return []
        }
        let dependencies = Set(milestone.dependencyIDs)
        return context.milestones.filter { dependencies.contains($0.id) }
    }

    static func dependents(forMilestoneID milestoneID: String, in context: LifeGraphContext?) -> [LifeGraphMilestone] {
        guard let context else { return [] }
        return context.milestones.filter { $0.dependencyIDs.contains(milestoneID) }
    }

    static func orderedStages(in context: LifeGraphContext?) -> [LifePathStage] {
        guard let context else { return [] }
        return context.stages.sorted { lhs, rhs in
            if lhs.orderIndex == rhs.orderIndex {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.orderIndex < rhs.orderIndex
        }
    }

    static func milestonesByStage(in context: LifeGraphContext?) -> [String: [LifeGraphMilestone]] {
        guard let context else { return [:] }
        let stageOrder = Dictionary(uniqueKeysWithValues: orderedStages(in: context).enumerated().map { ($1.id, $0) })
        return Dictionary(grouping: context.milestones.compactMap { milestone in
            guard milestone.stageID != nil else { return nil }
            return milestone
        }, by: { $0.stageID ?? "" }).mapValues { milestones in
            milestones.sorted { lhs, rhs in
                if lhs.targetDate == rhs.targetDate {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
                return (lhs.targetDate ?? "") < (rhs.targetDate ?? "")
            }
        }.sorted { lhs, rhs in
            let left = stageOrder[lhs.key] ?? Int.max
            let right = stageOrder[rhs.key] ?? Int.max
            return left < right
        }.reduce(into: [String: [LifeGraphMilestone]]()) { partial, entry in
            partial[entry.key] = entry.value
        }
    }

    static func prerequisites(forStageID stageID: String, in context: LifeGraphContext?) -> [LifePathPrerequisite] {
        guard let context else { return [] }
        return context.prerequisites.filter { $0.stageID == stageID }
    }

    static func blockedPrerequisites(
        forStageID stageID: String,
        in context: LifeGraphContext?,
        completedMilestoneIDs: Set<String> = [],
        completedStageIDs: Set<String> = []
    ) -> [LifePathPrerequisite] {
        prerequisites(forStageID: stageID, in: context).filter { prerequisite in
            if let requiredMilestoneID = prerequisite.requiredMilestoneID {
                return completedMilestoneIDs.contains(requiredMilestoneID) == false
            }
            if let requiredStageID = prerequisite.requiredStageID {
                return completedStageIDs.contains(requiredStageID) == false
            }
            return false
        }
    }

    static func readinessSummary(forStageID stageID: String?, in context: LifeGraphContext?) -> LifePathReadinessSummary {
        guard let stageID,
              let stage = context?.stages.first(where: { $0.id == stageID }) else {
            return LifePathReadinessSummary(stageID: nil, gapSignals: [], supportiveSignals: [], isReady: true)
        }
        let gaps = stage.readinessSignals.filter(\.isGap)
        let supportive = stage.readinessSignals.filter { !$0.isGap }
        return LifePathReadinessSummary(stageID: stage.id, gapSignals: gaps, supportiveSignals: supportive, isReady: gaps.isEmpty)
    }

    static func pathStateSummary(for goal: Goal) -> LifePathStateSummary? {
        pathStateSummary(context: goal.lifeGraph, plan: goal.plan)
    }

    static func pathStateSummary(for draft: GoalDraft, plan: GoalPlan? = nil) -> LifePathStateSummary? {
        pathStateSummary(context: draft.lifeGraph, plan: plan)
    }

    static func primaryDomain(for context: LifeGraphContext?) -> LifeDomainKey? {
        context?.domains.max { lhs, rhs in
            if lhs.priority == rhs.priority {
                return lhs.domain.rawValue > rhs.domain.rawValue
            }
            return lhs.priority < rhs.priority
        }?.domain
    }

    static func orderedUniqueGoals(_ goals: [Goal]) -> [Goal] {
        var seen = Set<String>()
        return goals.filter { seen.insert($0.id).inserted }
    }

    static func pathStateSummary(context: LifeGraphContext?, plan: GoalPlan?) -> LifePathStateSummary? {
        guard let context, context.stages.isEmpty == false || context.milestones.isEmpty == false || context.prerequisites.isEmpty == false else {
            return nil
        }

        let ordered = orderedStages(in: context)
        let stageMilestones = milestonesByStage(in: context)
        let completedMilestoneIDs = completedMilestoneIDs(in: context, plan: plan)
        let completedStages = Set(ordered.compactMap { stage -> String? in
            let milestones = stageMilestones[stage.id] ?? []
            guard milestones.isEmpty == false else { return nil }
            return milestones.allSatisfy { completedMilestoneIDs.contains($0.id) } ? stage.id : nil
        })
        let activeStageID = ordered.first(where: { completedStages.contains($0.id) == false })?.id
            ?? ordered.first?.id
        let blocked = activeStageID.map {
            blockedPrerequisites(
                forStageID: $0,
                in: context,
                completedMilestoneIDs: completedMilestoneIDs,
                completedStageIDs: completedStages
            )
        } ?? []
        let readiness = readinessSummary(forStageID: activeStageID, in: context)
        let nextMilestoneID = nextMilestone(in: context, orderedStages: ordered, stageMilestones: stageMilestones, completedMilestoneIDs: completedMilestoneIDs)?.id

        return LifePathStateSummary(
            orderedStages: ordered,
            activeStageID: activeStageID,
            stageMilestones: stageMilestones,
            blockedPrerequisites: blocked,
            readiness: readiness,
            progression: LifePathProgressionSummary(
                activeStageID: activeStageID,
                completedStageIDs: Array(completedStages).sorted(),
                completedMilestoneIDs: Array(completedMilestoneIDs).sorted(),
                nextMilestoneID: nextMilestoneID,
                totalStageCount: ordered.count,
                totalMilestoneCount: context.milestones.count,
                completedMilestoneCount: completedMilestoneIDs.count
            )
        )
    }

    static func completedMilestoneIDs(in context: LifeGraphContext, plan: GoalPlan?) -> Set<String> {
        guard let plan else { return [] }
        let completedTitles = Set(
            plan.sections
                .flatMap(\.steps)
                .filter { $0.state == .completed }
                .map { normalizedKey($0.title) }
        )
        return Set(context.milestones.compactMap { milestone in
            completedTitles.contains(normalizedKey(milestone.title)) ? milestone.id : nil
        })
    }

    static func nextMilestone(
        in context: LifeGraphContext,
        orderedStages: [LifePathStage],
        stageMilestones: [String: [LifeGraphMilestone]],
        completedMilestoneIDs: Set<String>
    ) -> LifeGraphMilestone? {
        for stage in orderedStages {
            let milestones = stageMilestones[stage.id] ?? []
            if let next = milestones.first(where: { completedMilestoneIDs.contains($0.id) == false }) {
                return next
            }
        }
        return context.milestones.first(where: { completedMilestoneIDs.contains($0.id) == false })
    }

    static func normalizedKey(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    static func fallbackRelationshipLabels(goal: Goal, graph: GoalRelationshipGraph) -> [String] {
        var labels: [String] = []
        if goal.relationshipKind == .support || goal.mode == .delegatedSupport {
            labels.append("support")
        }
        if graph.children.isEmpty == false {
            labels.append("child")
        }
        if graph.supportGoals.isEmpty == false {
            labels.append("support network")
        }
        return labels.isEmpty ? ["shared context"] : labels
    }

    static func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return DomainTimestamp.date(from: value)
    }

    static func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
