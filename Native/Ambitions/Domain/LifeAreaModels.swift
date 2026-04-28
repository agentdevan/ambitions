import Foundation

let lifeAreaAtlasSchemaVersion = "life_area_atlas.native.v1"

struct LifeAreaID: RawRepresentable, Codable, Sendable, Equatable, Hashable, Comparable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(domain: LifeDomainKey) {
        self.init(rawValue: domain.rawValue)
    }

    static func < (lhs: LifeAreaID, rhs: LifeAreaID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension LifeDomainKey {
    var lifeAreaID: LifeAreaID {
        LifeAreaID(domain: self)
    }

    var lifeAreaDisplayName: String {
        switch self {
        case .career:
            return "Career"
        case .education:
            return "Education"
        case .health:
            return "Health"
        case .finance:
            return "Money"
        case .home:
            return "Home"
        case .relationships:
            return "Relationships"
        case .creativity:
            return "Creativity"
        case .personalGrowth:
            return "Personal growth"
        }
    }

    var lifeAreaSummary: String {
        switch self {
        case .career:
            return "Work, calling, and visible contribution."
        case .education:
            return "Learning, credentials, and skill-building."
        case .health:
            return "Body, recovery, energy, and care."
        case .finance:
            return "Money decisions, security, and practical resources."
        case .home:
            return "Home, household, and the places life runs through."
        case .relationships:
            return "People, care, support, and shared responsibilities."
        case .creativity:
            return "Creative work, craft, and self-expression."
        case .personalGrowth:
            return "Identity, reflection, and becoming more yourself."
        }
    }
}

struct LifeAreaDefinition: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LifeAreaID
    let domainKey: LifeDomainKey
    let displayName: String
    let summary: String?
    let accessibilityLabel: String
    let accessibilityHint: String
    let canonicalOrder: Int

    init(domainKey: LifeDomainKey, canonicalOrder: Int) {
        self.id = domainKey.lifeAreaID
        self.domainKey = domainKey
        self.displayName = domainKey.lifeAreaDisplayName
        self.summary = domainKey.lifeAreaSummary
        self.accessibilityLabel = "Life Area, \(domainKey.lifeAreaDisplayName)"
        self.accessibilityHint = "Organizes related goals and progress without adding a new tab."
        self.canonicalOrder = canonicalOrder
    }

    static let canonical: [LifeAreaDefinition] = LifeDomainKey.allCases.enumerated().map { index, domain in
        LifeAreaDefinition(domainKey: domain, canonicalOrder: index)
    }
}

enum LifeAreaPosture: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case light
    case needsAttention = "needs_attention"
    case empty
    case unavailable

    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .light:
            return "Light"
        case .needsAttention:
            return "Area needs review"
        case .empty:
            return "Nothing active here yet"
        case .unavailable:
            return "Area unavailable"
        }
    }
}

enum LifeAreaPrivacyLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case full
    case compact
    case redacted
}

struct LifeAreaAccessibilityProjection: Codable, Sendable, Equatable, Hashable {
    let label: String
    let value: String
    let hint: String
}

struct LifeAreaGoalReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String?
    let state: GoalLifecycleState
    let relationshipKind: GoalRelationshipKind
    let objectReference: LifeGraphObjectReference

    init(goal: Goal, privacyLevel: LifeAreaPrivacyLevel = .full) {
        self.id = goal.id
        self.title = privacyLevel == .redacted ? "Private item" : goal.title
        self.summary = privacyLevel == .redacted ? "Detail hidden" : goal.summary
        self.state = goal.state
        self.relationshipKind = goal.relationshipKind
        self.objectReference = LifeGraphObjectReference(
            kind: .goal,
            id: goal.id,
            label: privacyLevel == .redacted ? "Private item" : goal.title,
            sourceDomain: .goals
        )
    }
}

struct LifeAreaCounts: Codable, Sendable, Equatable, Hashable {
    let activeGoalCount: Int
    let parkedGoalCount: Int
    let waitingCount: Int
    let proofCount: Int
    let receiptCount: Int

    var hasContent: Bool {
        activeGoalCount > 0 || parkedGoalCount > 0 || waitingCount > 0 || proofCount > 0 || receiptCount > 0
    }
}

struct LifeAreaRelationshipHooks: Codable, Sendable, Equatable, Hashable {
    let goalReferences: [LifeGraphObjectReference]
    let proofReferences: [LifeGraphObjectReference]
    let receiptReferences: [LifeGraphObjectReference]
    let waitingReferences: [LifeGraphObjectReference]
    let futureNorthStarCount: Int
    let hasDormantDirection: Bool
    let supportsNorthStarGrouping: Bool
    let supportsOneStepGoalGrouping: Bool

    init(
        goalReferences: [LifeGraphObjectReference] = [],
        proofReferences: [LifeGraphObjectReference] = [],
        receiptReferences: [LifeGraphObjectReference] = [],
        waitingReferences: [LifeGraphObjectReference] = [],
        futureNorthStarCount: Int = 0,
        hasDormantDirection: Bool = false,
        supportsNorthStarGrouping: Bool = true,
        supportsOneStepGoalGrouping: Bool = true
    ) {
        self.goalReferences = goalReferences
        self.proofReferences = proofReferences
        self.receiptReferences = receiptReferences
        self.waitingReferences = waitingReferences
        self.futureNorthStarCount = futureNorthStarCount
        self.hasDormantDirection = hasDormantDirection
        self.supportsNorthStarGrouping = supportsNorthStarGrouping
        self.supportsOneStepGoalGrouping = supportsOneStepGoalGrouping
    }
}

struct LifeAreaSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LifeAreaID
    let definition: LifeAreaDefinition
    let posture: LifeAreaPosture
    let counts: LifeAreaCounts
    let activeGoals: [LifeAreaGoalReference]
    let parkedGoals: [LifeAreaGoalReference]
    let mostRelevantGoal: LifeAreaGoalReference?
    let nextFocus: String?
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: LifeAreaPrivacyLevel
    let relationshipHooks: LifeAreaRelationshipHooks
    let accessibility: LifeAreaAccessibilityProjection

    var compactSummary: String {
        if privacyLevel == .redacted {
            return "Detail hidden"
        }
        if counts.activeGoalCount > 0 {
            return "\(counts.activeGoalCount) active goal\(counts.activeGoalCount == 1 ? "" : "s")"
        }
        if counts.parkedGoalCount > 0 {
            return "\(counts.parkedGoalCount) parked goal\(counts.parkedGoalCount == 1 ? "" : "s")"
        }
        return emptyTitle
    }

    var redacted: LifeAreaSummary {
        LifeAreaSummary(
            definition: definition,
            posture: .unavailable,
            counts: counts,
            activeGoals: activeGoals.map { _ in LifeAreaGoalReference.redactedPlaceholder },
            parkedGoals: parkedGoals.map { _ in LifeAreaGoalReference.redactedPlaceholder },
            mostRelevantGoal: mostRelevantGoal.map { _ in LifeAreaGoalReference.redactedPlaceholder },
            nextFocus: "Detail hidden",
            privacyLevel: .redacted,
            relationshipHooks: relationshipHooks
        )
    }

    init(
        definition: LifeAreaDefinition,
        posture: LifeAreaPosture,
        counts: LifeAreaCounts,
        activeGoals: [LifeAreaGoalReference],
        parkedGoals: [LifeAreaGoalReference],
        mostRelevantGoal: LifeAreaGoalReference?,
        nextFocus: String?,
        emptyTitle: String = "No goals here yet",
        emptyMessage: String = "Organize this area when something belongs here.",
        privacyLevel: LifeAreaPrivacyLevel,
        relationshipHooks: LifeAreaRelationshipHooks
    ) {
        self.id = definition.id
        self.definition = definition
        self.posture = posture
        self.counts = counts
        self.activeGoals = activeGoals
        self.parkedGoals = parkedGoals
        self.mostRelevantGoal = mostRelevantGoal
        self.nextFocus = nextFocus
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.privacyLevel = privacyLevel
        self.relationshipHooks = relationshipHooks
        self.accessibility = Self.accessibilityProjection(
            definition: definition,
            posture: posture,
            counts: counts,
            privacyLevel: privacyLevel
        )
    }

    private static func accessibilityProjection(
        definition: LifeAreaDefinition,
        posture: LifeAreaPosture,
        counts: LifeAreaCounts,
        privacyLevel: LifeAreaPrivacyLevel
    ) -> LifeAreaAccessibilityProjection {
        let value: String
        if privacyLevel == .redacted {
            value = "Private area. Detail hidden."
        } else {
            value = [
                posture.displayName,
                "\(counts.activeGoalCount) active",
                "\(counts.parkedGoalCount) parked",
                "\(counts.waitingCount) waiting",
                "\(counts.proofCount) proof",
                "\(counts.receiptCount) receipts"
            ].joined(separator: ", ")
        }
        return LifeAreaAccessibilityProjection(
            label: "Life Area, \(definition.displayName)",
            value: value,
            hint: "Opens later Life Areas detail when that surface exists."
        )
    }
}

struct LifeAreasOverviewProjection: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let title: String
    let subtitle: String
    let areas: [LifeAreaSummary]
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: LifeAreaPrivacyLevel
    let accessibility: LifeAreaAccessibilityProjection

    init(
        schemaVersion: String = lifeAreaAtlasSchemaVersion,
        title: String = "Life Areas Overview",
        subtitle: String = "Your goals organized by meaningful areas of life.",
        areas: [LifeAreaSummary],
        emptyTitle: String = "No goals here yet",
        emptyMessage: String = "Life Areas will take shape as goals are created.",
        privacyLevel: LifeAreaPrivacyLevel
    ) {
        self.schemaVersion = schemaVersion
        self.title = title
        self.subtitle = subtitle
        self.areas = areas
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.privacyLevel = privacyLevel
        self.accessibility = LifeAreaAccessibilityProjection(
            label: title,
            value: "\(areas.count) Life Areas. \(areas.filter { $0.counts.hasContent }.count) with activity.",
            hint: "Life Areas organize goals without adding a new top-level tab."
        )
    }

    var privacySafeCompact: LifeAreasOverviewProjection {
        LifeAreasOverviewProjection(
            schemaVersion: schemaVersion,
            title: title,
            subtitle: "Life Areas are available with sensitive details hidden.",
            areas: areas.map(\.redacted),
            emptyTitle: "Detail hidden",
            emptyMessage: "Private area details are hidden.",
            privacyLevel: .redacted
        )
    }
}

struct LifeAreasAtlasProjection: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let title: String
    let overview: LifeAreasOverviewProjection
    let areaCount: Int
    let relationshipHooks: [LifeAreaID: LifeAreaRelationshipHooks]
    let supportsGoalsPreview: Bool
    let supportsYouOrganization: Bool
    let supportsFutureLifeAreaDetail: Bool
    let supportsFutureNorthStarGrouping: Bool
    let supportsFutureSemanticZoom: Bool
    let supportsFutureArchiveReviewLearning: Bool
    let futureNorthStarCount: Int
    let hasDormantDirection: Bool

    init(
        schemaVersion: String = lifeAreaAtlasSchemaVersion,
        title: String = "Life Areas Atlas",
        overview: LifeAreasOverviewProjection
    ) {
        self.schemaVersion = schemaVersion
        self.title = title
        self.overview = overview
        self.areaCount = overview.areas.count
        self.relationshipHooks = Dictionary(uniqueKeysWithValues: overview.areas.map { ($0.id, $0.relationshipHooks) })
        self.supportsGoalsPreview = true
        self.supportsYouOrganization = true
        self.supportsFutureLifeAreaDetail = true
        self.supportsFutureNorthStarGrouping = true
        self.supportsFutureSemanticZoom = true
        self.supportsFutureArchiveReviewLearning = true
        self.futureNorthStarCount = overview.areas.map(\.relationshipHooks.futureNorthStarCount).reduce(0, +)
        self.hasDormantDirection = overview.areas.contains { $0.relationshipHooks.hasDormantDirection }
    }
}

private extension LifeAreaGoalReference {
    static var redactedPlaceholder: LifeAreaGoalReference {
        LifeAreaGoalReference(
            id: "private-item",
            title: "Private item",
            summary: "Detail hidden",
            state: .active,
            relationshipKind: .independent,
            objectReference: LifeGraphObjectReference(kind: .goal, id: "private-item", label: "Private item", sourceDomain: .goals)
        )
    }

    init(
        id: String,
        title: String,
        summary: String?,
        state: GoalLifecycleState,
        relationshipKind: GoalRelationshipKind,
        objectReference: LifeGraphObjectReference
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.state = state
        self.relationshipKind = relationshipKind
        self.objectReference = objectReference
    }
}
