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

enum SharedLifeRelationshipKind: String, Codable, Sendable, Equatable, Hashable {
    case partner
    case child
    case dependent
    case householdMember = "household_member"
    case careRecipient = "care_recipient"
    case supportNetwork = "support_network"
}

struct SharedLifeParticipant: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let displayName: String
    let relationshipKind: SharedLifeRelationshipKind
    let roleLabel: String?
    let note: String?

    init(
        id: String,
        displayName: String,
        relationshipKind: SharedLifeRelationshipKind,
        roleLabel: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.relationshipKind = relationshipKind
        self.roleLabel = roleLabel
        self.note = note
    }
}

enum SharedResponsibilityKind: String, Codable, Sendable, Equatable, Hashable {
    case care
    case household
    case appointment
    case logistics
    case support
}

enum SharedCoordinationKind: String, Codable, Sendable, Equatable, Hashable {
    case appointment
    case logistics
    case preparation
    case checkIn = "check_in"
}

struct SharedCoordinationContext: Codable, Sendable, Equatable, Hashable {
    let kind: SharedCoordinationKind
    let title: String?
    let summary: String?
    let locationHint: String?
    let preparationNote: String?

    init(
        kind: SharedCoordinationKind,
        title: String? = nil,
        summary: String? = nil,
        locationHint: String? = nil,
        preparationNote: String? = nil
    ) {
        self.kind = kind
        self.title = title
        self.summary = summary
        self.locationHint = locationHint
        self.preparationNote = preparationNote
    }
}

struct SharedResponsibility: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String?
    let kind: SharedResponsibilityKind
    let participantID: String?
    let coordination: SharedCoordinationContext?

    init(
        id: String,
        title: String,
        summary: String? = nil,
        kind: SharedResponsibilityKind,
        participantID: String? = nil,
        coordination: SharedCoordinationContext? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.kind = kind
        self.participantID = participantID
        self.coordination = coordination
    }
}

struct SharedLifeContext: Codable, Sendable, Equatable, Hashable {
    let participants: [SharedLifeParticipant]
    let responsibilities: [SharedResponsibility]
    let householdName: String?
    let careSummary: String?

    init(
        participants: [SharedLifeParticipant] = [],
        responsibilities: [SharedResponsibility] = [],
        householdName: String? = nil,
        careSummary: String? = nil
    ) {
        self.participants = participants
        self.responsibilities = responsibilities
        self.householdName = householdName
        self.careSummary = careSummary
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
    let sharedLife: SharedLifeContext?

    init(
        domains: [LifeDomainAssignment] = [],
        roles: [LifeRole] = [],
        path: LifePathDescriptor? = nil,
        stages: [LifePathStage] = [],
        prerequisites: [LifePathPrerequisite] = [],
        milestones: [LifeGraphMilestone] = [],
        sharedLife: SharedLifeContext? = nil
    ) {
        self.domains = domains
        self.roles = roles
        self.path = path
        self.stages = stages
        self.prerequisites = prerequisites
        self.milestones = milestones
        self.sharedLife = sharedLife
    }
}

let lifeGraphRelationshipSchemaVersion = "life_graph_relationship.native.v1"

enum LifeGraphObjectKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case lifeArea = "life_area"
    case ambition
    case northStar = "north_star"
    case goal
    case path
    case milestone
    case action
    case step
    case oneStepGoal = "one_step_goal"
    case capture
    case commitment
    case waitingItem = "waiting_item"
    case proof
    case evidence
    case resource
    case decision
    case correction
    case receipt
    case review
    case blocker
    case person

    var isPlaceholderOnlyInV1: Bool {
        switch self {
        case .ambition, .path, .commitment, .waitingItem, .proof, .resource, .decision, .correction, .receipt, .review, .blocker, .person:
            return true
        case .lifeArea, .northStar, .goal, .milestone, .action, .step, .oneStepGoal, .capture, .evidence:
            return false
        }
    }
}

enum LifeGraphSourceDomain: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goals
    case goalEngine = "goal_engine"
    case capture
    case time
    case today
    case you
    case eventLedger = "event_ledger"
    case commandPipeline = "command_pipeline"
    case proof
    case resource
    case commitment
    case receipt
    case system
}

struct LifeGraphObjectReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let kind: LifeGraphObjectKind
    let id: String
    let parentContextID: String?
    let label: String?
    let sourceDomain: LifeGraphSourceDomain?

    init(
        kind: LifeGraphObjectKind,
        id: String,
        parentContextID: String? = nil,
        label: String? = nil,
        sourceDomain: LifeGraphSourceDomain? = nil
    ) {
        self.kind = kind
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.parentContextID = Self.normalizedOptional(parentContextID)
        self.label = Self.normalizedOptional(label)
        self.sourceDomain = sourceDomain
    }

    var isWellFormed: Bool {
        id.isEmpty == false
    }

    var displayLabel: String {
        label ?? id
    }

    var stableKey: String {
        [
            kind.rawValue,
            id,
            parentContextID ?? "",
            sourceDomain?.rawValue ?? ""
        ].joined(separator: ":")
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

enum LifeGraphRelationshipKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case contains
    case belongsTo = "belongs_to"
    case supports
    case blocks
    case dependsOn = "depends_on"
    case relatesTo = "relates_to"
    case produces
    case proves
    case waitsOn = "waits_on"
    case corrects
    case explains
    case createdFrom = "created_from"
    case attachedTo = "attached_to"
}

enum LifeGraphRelationshipIntegrity: String, Codable, Sendable, Equatable, Hashable {
    case valid
    case invalidSource = "invalid_source"
    case invalidTarget = "invalid_target"
    case selfRelationship = "self_relationship"
}

enum LifeGraphRelationshipCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case structure
    case support
    case risk
    case proof
    case waiting
    case correction
    case explanation
    case creation
    case attachment
    case generic
}

enum LifeGraphMissionControlLane: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case path
    case now
    case proof
    case risk
    case people
    case resources
    case decisions
    case receipts
}

struct LifeGraphRelationship: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: LifeGraphRelationshipKind
    let source: LifeGraphObjectReference
    let target: LifeGraphObjectReference
    let note: String?
    let schemaVersion: String

    init(
        kind: LifeGraphRelationshipKind,
        source: LifeGraphObjectReference,
        target: LifeGraphObjectReference,
        note: String? = nil,
        id: String? = nil,
        schemaVersion: String = lifeGraphRelationshipSchemaVersion
    ) {
        self.kind = kind
        self.source = source
        self.target = target
        self.note = Self.normalizedOptional(note)
        self.schemaVersion = schemaVersion
        self.id = id ?? Self.deterministicID(kind: kind, source: source, target: target)
    }

    var integrity: LifeGraphRelationshipIntegrity {
        if source.isWellFormed == false {
            return .invalidSource
        }
        if target.isWellFormed == false {
            return .invalidTarget
        }
        if source.stableKey == target.stableKey {
            return .selfRelationship
        }
        return .valid
    }

    var category: LifeGraphRelationshipCategory {
        switch kind {
        case .contains, .belongsTo:
            return .structure
        case .supports:
            return .support
        case .blocks, .dependsOn:
            return .risk
        case .proves:
            return .proof
        case .waitsOn:
            return .waiting
        case .corrects:
            return .correction
        case .explains:
            return .explanation
        case .produces:
            return .creation
        case .attachedTo:
            return .attachment
        case .createdFrom:
            return .creation
        case .relatesTo:
            return .generic
        }
    }

    var missionControlLane: LifeGraphMissionControlLane {
        if source.kind == .person || target.kind == .person {
            return .people
        }
        if source.kind == .resource || target.kind == .resource {
            return .resources
        }
        if source.kind == .decision || target.kind == .decision {
            return .decisions
        }
        if source.kind == .receipt || target.kind == .receipt {
            return .receipts
        }

        switch category {
        case .structure, .creation:
            return .path
        case .support, .attachment, .generic:
            return .now
        case .proof:
            return .proof
        case .risk, .waiting, .correction, .explanation:
            return .risk
        }
    }

    private static func deterministicID(
        kind: LifeGraphRelationshipKind,
        source: LifeGraphObjectReference,
        target: LifeGraphObjectReference
    ) -> String {
        "lifegraph:\(source.stableKey):\(kind.rawValue):\(target.stableKey)"
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9:_-]+"#, with: "-", options: .regularExpression)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct LifeGraphBreadcrumb: Sendable, Equatable {
    let objects: [LifeGraphObjectReference]

    var labels: [String] {
        objects.map(\.displayLabel)
    }
}

struct LifeGraphRelationshipProjection: Sendable, Equatable {
    private(set) var relationships: [LifeGraphRelationship]

    init(relationships: [LifeGraphRelationship] = []) {
        self.relationships = Self.validOrderedUnique(relationships)
    }

    mutating func add(_ relationship: LifeGraphRelationship) -> Bool {
        guard relationship.integrity == .valid,
              relationships.contains(where: { $0.id == relationship.id }) == false else {
            return false
        }
        relationships.append(relationship)
        relationships = Self.validOrderedUnique(relationships)
        return true
    }

    func outgoing(from object: LifeGraphObjectReference, kind: LifeGraphRelationshipKind? = nil) -> [LifeGraphRelationship] {
        filtered(kind: kind) { $0.source.stableKey == object.stableKey }
    }

    func incoming(to object: LifeGraphObjectReference, kind: LifeGraphRelationshipKind? = nil) -> [LifeGraphRelationship] {
        filtered(kind: kind) { $0.target.stableKey == object.stableKey }
    }

    func relatedObjects(
        from object: LifeGraphObjectReference,
        kind: LifeGraphRelationshipKind? = nil
    ) -> [LifeGraphObjectReference] {
        orderedUniqueReferences(outgoing(from: object, kind: kind).map(\.target))
    }

    func sourceObjects(
        to object: LifeGraphObjectReference,
        kind: LifeGraphRelationshipKind? = nil
    ) -> [LifeGraphObjectReference] {
        orderedUniqueReferences(incoming(to: object, kind: kind).map(\.source))
    }

    func relationships(
        involving object: LifeGraphObjectReference,
        inMissionControlLane lane: LifeGraphMissionControlLane
    ) -> [LifeGraphRelationship] {
        relationships.filter {
            $0.missionControlLane == lane &&
                ($0.source.stableKey == object.stableKey || $0.target.stableKey == object.stableKey)
        }
    }

    func breadcrumb(
        to object: LifeGraphObjectReference,
        maxDepth: Int = 8
    ) -> LifeGraphBreadcrumb {
        guard object.isWellFormed, maxDepth > 0 else {
            return LifeGraphBreadcrumb(objects: object.isWellFormed ? [object] : [])
        }

        var path = [object]
        var current = object
        var visited = Set([object.stableKey])

        while path.count < maxDepth {
            guard let parent = parentCandidate(for: current, excluding: visited) else {
                break
            }
            path.insert(parent, at: 0)
            visited.insert(parent.stableKey)
            current = parent
        }

        return LifeGraphBreadcrumb(objects: path)
    }

    private func filtered(
        kind: LifeGraphRelationshipKind?,
        where predicate: (LifeGraphRelationship) -> Bool
    ) -> [LifeGraphRelationship] {
        relationships.filter { relationship in
            predicate(relationship) && (kind == nil || relationship.kind == kind)
        }
    }

    private func parentCandidate(
        for object: LifeGraphObjectReference,
        excluding visited: Set<String>
    ) -> LifeGraphObjectReference? {
        let containerParents = incoming(to: object, kind: .contains).map(\.source)
        let belongsToParents = outgoing(from: object, kind: .belongsTo).map(\.target)
        return orderedUniqueReferences(containerParents + belongsToParents)
            .first { visited.contains($0.stableKey) == false }
    }

    private func orderedUniqueReferences(_ references: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return references
            .filter { seen.insert($0.stableKey).inserted }
            .sorted { lhs, rhs in
                if lhs.kind.rawValue != rhs.kind.rawValue {
                    return lhs.kind.rawValue < rhs.kind.rawValue
                }
                if lhs.displayLabel.localizedCaseInsensitiveCompare(rhs.displayLabel) != .orderedSame {
                    return lhs.displayLabel.localizedCaseInsensitiveCompare(rhs.displayLabel) == .orderedAscending
                }
                return lhs.stableKey < rhs.stableKey
            }
    }

    private static func validOrderedUnique(_ relationships: [LifeGraphRelationship]) -> [LifeGraphRelationship] {
        var seen = Set<String>()
        return relationships
            .filter { $0.integrity == .valid }
            .filter { seen.insert($0.id).inserted }
            .sorted { lhs, rhs in
                if lhs.source.stableKey != rhs.source.stableKey {
                    return lhs.source.stableKey < rhs.source.stableKey
                }
                if lhs.kind.rawValue != rhs.kind.rawValue {
                    return lhs.kind.rawValue < rhs.kind.rawValue
                }
                return lhs.target.stableKey < rhs.target.stableKey
            }
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

struct SharedResponsibilitySummary: Sendable, Equatable {
    let totalCount: Int
    let careCount: Int
    let householdCount: Int
    let appointmentCount: Int
    let logisticsCount: Int
    let supportCount: Int
    let participantNames: [String]
}

struct SharedLifeCoordinationSignal: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let needsPreparation: Bool
    let isTimed: Bool
}

struct SharedLifeGoalSummary: Sendable, Equatable {
    let goalID: String
    let participantNames: [String]
    let relationshipLabels: [String]
    let delegatedSupportActive: Bool
    let careContextActive: Bool
    let structuralSupportGoalCount: Int
    let responsibilitySummary: SharedResponsibilitySummary
    let coordinationSignals: [SharedLifeCoordinationSignal]
    let pressureScore: Double
    let reasons: [String]
}

struct SharedLifePortfolioSummary: Sendable, Equatable {
    let totalResponsibilityCount: Int
    let careGoalCount: Int
    let coordinationSignalCount: Int
    let headline: String
}

struct SharedLifeCoordinationSnapshot: Sendable, Equatable {
    let goalSummaries: [String: SharedLifeGoalSummary]
    let portfolioSummary: SharedLifePortfolioSummary
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

    private static func fallbackRelationshipLabels(goal: Goal, graph: GoalRelationshipGraph) -> [String] {
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

    private static func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return DomainTimestamp.date(from: value)
    }

    private static func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
