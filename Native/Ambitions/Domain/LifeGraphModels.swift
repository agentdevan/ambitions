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

struct LifeGraphMilestone: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let targetDate: String?
    let dependencyIDs: [String]

    init(id: String, title: String, summary: String? = nil, targetDate: String? = nil, dependencyIDs: [String] = []) {
        self.id = id
        self.title = title
        self.summary = summary
        self.targetDate = targetDate
        self.dependencyIDs = dependencyIDs
    }
}

struct LifeGraphContext: Codable, Sendable, Equatable, Hashable {
    let domains: [LifeDomainAssignment]
    let roles: [LifeRole]
    let path: LifePathDescriptor?
    let milestones: [LifeGraphMilestone]

    init(
        domains: [LifeDomainAssignment] = [],
        roles: [LifeRole] = [],
        path: LifePathDescriptor? = nil,
        milestones: [LifeGraphMilestone] = []
    ) {
        self.domains = domains
        self.roles = roles
        self.path = path
        self.milestones = milestones
    }
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
}
