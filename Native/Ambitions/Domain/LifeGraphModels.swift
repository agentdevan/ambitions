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
