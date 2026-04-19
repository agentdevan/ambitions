import Foundation

enum LifeDomainKey: String, Codable, Sendable, CaseIterable {
    case career
    case education
    case health
    case finance
    case home
    case relationships
    case creativity
    case personalGrowth = "personal_growth"
}

struct LifeDomainAssignment: Codable, Sendable, Equatable, Hashable {
    let domain: LifeDomainKey
    let priority: Double
    let note: String?

    init(domain: LifeDomainKey, priority: Double = 1, note: String? = nil) {
        self.domain = domain
        self.priority = priority
        self.note = note
    }
}

enum LifeRoleKind: String, Codable, Sendable {
    case primary
    case supporting
    case aspirational
    case responsibility
}

struct LifeRole: Codable, Sendable, Equatable, Hashable {
    let kind: LifeRoleKind
    let title: String
    let summary: String?

    init(kind: LifeRoleKind, title: String, summary: String? = nil) {
        self.kind = kind
        self.title = title
        self.summary = summary
    }
}

enum LifePathKind: String, Codable, Sendable {
    case careerTrack = "career_track"
    case educationTrack = "education_track"
    case healthJourney = "health_journey"
    case financialJourney = "financial_journey"
    case personalPath = "personal_path"
}

struct LifePathDescriptor: Codable, Sendable, Equatable, Hashable {
    let kind: LifePathKind
    let title: String
    let summary: String?

    init(kind: LifePathKind, title: String, summary: String? = nil) {
        self.kind = kind
        self.title = title
        self.summary = summary
    }
}

enum LifePathSignalKind: String, Codable, Sendable {
    case credential
    case experience
    case evidence
    case readiness
    case applicationWindow = "application_window"
    case portfolio
    case support
}

struct LifePathSignal: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let kind: LifePathSignalKind
    let isGap: Bool

    init(id: String, title: String, summary: String? = nil, kind: LifePathSignalKind, isGap: Bool = false) {
        self.id = id
        self.title = title
        self.summary = summary
        self.kind = kind
        self.isGap = isGap
    }
}

struct LifePathStage: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let orderIndex: Int
    let readinessSignals: [LifePathSignal]

    init(
        id: String,
        title: String,
        summary: String? = nil,
        orderIndex: Int,
        readinessSignals: [LifePathSignal] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.orderIndex = orderIndex
        self.readinessSignals = readinessSignals
    }
}

enum LifePathPrerequisiteKind: String, Codable, Sendable {
    case stage
    case milestone
    case readiness
    case credential
    case experience
}

struct LifePathPrerequisite: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let kind: LifePathPrerequisiteKind
    let stageID: String
    let requiredStageID: String?
    let requiredMilestoneID: String?

    init(
        id: String,
        title: String,
        summary: String? = nil,
        kind: LifePathPrerequisiteKind,
        stageID: String,
        requiredStageID: String? = nil,
        requiredMilestoneID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.kind = kind
        self.stageID = stageID
        self.requiredStageID = requiredStageID
        self.requiredMilestoneID = requiredMilestoneID
    }
}

struct LifeGraphMilestone: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let targetDate: String?
    let stageID: String?
    let dependencyIDs: [String]

    init(
        id: String,
        title: String,
        summary: String? = nil,
        targetDate: String? = nil,
        stageID: String? = nil,
        dependencyIDs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.targetDate = targetDate
        self.stageID = stageID
        self.dependencyIDs = dependencyIDs
    }
}

struct LifeGraphContext: Codable, Sendable, Equatable, Hashable {
    let domains: [LifeDomainAssignment]
    let roles: [LifeRole]
    let path: LifePathDescriptor?
    let stages: [LifePathStage]
    let prerequisites: [LifePathPrerequisite]
    let milestones: [LifeGraphMilestone]

    init(
        domains: [LifeDomainAssignment] = [],
        roles: [LifeRole] = [],
        path: LifePathDescriptor? = nil,
        stages: [LifePathStage] = [],
        prerequisites: [LifePathPrerequisite] = [],
        milestones: [LifeGraphMilestone] = []
    ) {
        self.domains = domains
        self.roles = roles
        self.path = path
        self.stages = stages
        self.prerequisites = prerequisites
        self.milestones = milestones
    }
}

struct LifePathReadinessSummary: Sendable, Equatable {
    let stageID: String?
    let gapSignals: [LifePathSignal]
    let supportiveSignals: [LifePathSignal]
    let isReady: Bool

    var gapCount: Int { gapSignals.count }
}

struct LifePathProgressionSummary: Sendable, Equatable {
    let activeStageID: String?
    let completedStageIDs: [String]
    let completedMilestoneIDs: [String]
    let nextMilestoneID: String?
    let totalStageCount: Int
    let totalMilestoneCount: Int
    let completedMilestoneCount: Int
}

struct LifePathStateSummary: Sendable, Equatable {
    let orderedStages: [LifePathStage]
    let activeStageID: String?
    let stageMilestones: [String: [LifeGraphMilestone]]
    let blockedPrerequisites: [LifePathPrerequisite]
    let readiness: LifePathReadinessSummary
    let progression: LifePathProgressionSummary
}

struct GoalRelationshipGraph: Sendable, Equatable {
    let focus: Goal
    let parent: Goal?
    let children: [Goal]
    let supportGoals: [Goal]
}

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

    private static func primaryDomain(for context: LifeGraphContext?) -> LifeDomainKey? {
        context?.domains.max { lhs, rhs in
            if lhs.priority == rhs.priority {
                return lhs.domain.rawValue > rhs.domain.rawValue
            }
            return lhs.priority < rhs.priority
        }?.domain
    }

    private static func orderedUniqueGoals(_ goals: [Goal]) -> [Goal] {
        var seen = Set<String>()
        return goals.filter { seen.insert($0.id).inserted }
    }

    private static func pathStateSummary(context: LifeGraphContext?, plan: GoalPlan?) -> LifePathStateSummary? {
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

    private static func completedMilestoneIDs(in context: LifeGraphContext, plan: GoalPlan?) -> Set<String> {
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

    private static func nextMilestone(
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

    private static func normalizedKey(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
