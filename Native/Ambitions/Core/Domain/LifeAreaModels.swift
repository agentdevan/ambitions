import Foundation

let lifeAreaAtlasSchemaVersion = "life_area_atlas.native.v1"

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
    let goalThreadCount: Int
    let northStarCount: Int
    let oneStepGoalCount: Int
    let waitingCount: Int
    let proofCount: Int
    let receiptCount: Int

    private enum CodingKeys: String, CodingKey {
        case activeGoalCount
        case parkedGoalCount
        case goalThreadCount
        case northStarCount
        case oneStepGoalCount
        case waitingCount
        case proofCount
        case receiptCount
    }

    init(
        activeGoalCount: Int,
        parkedGoalCount: Int,
        goalThreadCount: Int = 0,
        northStarCount: Int = 0,
        oneStepGoalCount: Int = 0,
        waitingCount: Int,
        proofCount: Int,
        receiptCount: Int
    ) {
        self.activeGoalCount = activeGoalCount
        self.parkedGoalCount = parkedGoalCount
        self.goalThreadCount = goalThreadCount
        self.northStarCount = northStarCount
        self.oneStepGoalCount = oneStepGoalCount
        self.waitingCount = waitingCount
        self.proofCount = proofCount
        self.receiptCount = receiptCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.activeGoalCount = try container.decode(Int.self, forKey: .activeGoalCount)
        self.parkedGoalCount = try container.decode(Int.self, forKey: .parkedGoalCount)
        self.goalThreadCount = try container.decodeIfPresent(Int.self, forKey: .goalThreadCount) ?? 0
        self.northStarCount = try container.decodeIfPresent(Int.self, forKey: .northStarCount) ?? 0
        self.oneStepGoalCount = try container.decodeIfPresent(Int.self, forKey: .oneStepGoalCount) ?? 0
        self.waitingCount = try container.decode(Int.self, forKey: .waitingCount)
        self.proofCount = try container.decode(Int.self, forKey: .proofCount)
        self.receiptCount = try container.decode(Int.self, forKey: .receiptCount)
    }

    var hasContent: Bool {
        activeGoalCount > 0 || parkedGoalCount > 0 || goalThreadCount > 0 || northStarCount > 0 || oneStepGoalCount > 0 || waitingCount > 0 || proofCount > 0 || receiptCount > 0
    }
}

struct LifeAreaRelationshipHooks: Codable, Sendable, Equatable, Hashable {
    let goalThreadReferences: [LifeGraphObjectReference]
    let goalThreadPathReferences: [LifeGraphObjectReference]
    let stepReferences: [LifeGraphObjectReference]
    let commitmentReferences: [LifeGraphObjectReference]
    let goalReferences: [LifeGraphObjectReference]
    let oneStepGoalReferences: [LifeGraphObjectReference]
    let proofReferences: [LifeGraphObjectReference]
    let receiptReferences: [LifeGraphObjectReference]
    let waitingReferences: [LifeGraphObjectReference]
    let futureNorthStarCount: Int
    let oneStepGoalCount: Int
    let hasDormantDirection: Bool
    let supportsNorthStarGrouping: Bool
    let supportsOneStepGoalGrouping: Bool

    private enum CodingKeys: String, CodingKey {
        case goalThreadReferences
        case goalThreadPathReferences
        case stepReferences
        case commitmentReferences
        case goalReferences
        case oneStepGoalReferences
        case proofReferences
        case receiptReferences
        case waitingReferences
        case futureNorthStarCount
        case oneStepGoalCount
        case hasDormantDirection
        case supportsNorthStarGrouping
        case supportsOneStepGoalGrouping
    }

    init(
        goalThreadReferences: [LifeGraphObjectReference] = [],
        goalThreadPathReferences: [LifeGraphObjectReference] = [],
        stepReferences: [LifeGraphObjectReference] = [],
        commitmentReferences: [LifeGraphObjectReference] = [],
        goalReferences: [LifeGraphObjectReference] = [],
        oneStepGoalReferences: [LifeGraphObjectReference] = [],
        proofReferences: [LifeGraphObjectReference] = [],
        receiptReferences: [LifeGraphObjectReference] = [],
        waitingReferences: [LifeGraphObjectReference] = [],
        futureNorthStarCount: Int = 0,
        oneStepGoalCount: Int = 0,
        hasDormantDirection: Bool = false,
        supportsNorthStarGrouping: Bool = true,
        supportsOneStepGoalGrouping: Bool = true
    ) {
        self.goalThreadReferences = Self.orderedUnique(goalThreadReferences)
        self.goalThreadPathReferences = Self.orderedUnique(goalThreadPathReferences)
        self.stepReferences = Self.orderedUnique(stepReferences)
        self.commitmentReferences = Self.orderedUnique(commitmentReferences)
        self.goalReferences = Self.orderedUnique(goalReferences)
        self.oneStepGoalReferences = Self.orderedUnique(oneStepGoalReferences)
        self.proofReferences = Self.orderedUnique(proofReferences)
        self.receiptReferences = Self.orderedUnique(receiptReferences)
        self.waitingReferences = Self.orderedUnique(waitingReferences)
        self.futureNorthStarCount = futureNorthStarCount
        self.oneStepGoalCount = oneStepGoalCount
        self.hasDormantDirection = hasDormantDirection
        self.supportsNorthStarGrouping = supportsNorthStarGrouping
        self.supportsOneStepGoalGrouping = supportsOneStepGoalGrouping
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.goalThreadReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .goalThreadReferences) ?? [])
        self.goalThreadPathReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .goalThreadPathReferences) ?? [])
        self.stepReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .stepReferences) ?? [])
        self.commitmentReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .commitmentReferences) ?? [])
        self.goalReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .goalReferences) ?? [])
        self.oneStepGoalReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .oneStepGoalReferences) ?? [])
        self.proofReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .proofReferences) ?? [])
        self.receiptReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .receiptReferences) ?? [])
        self.waitingReferences = Self.orderedUnique(try container.decodeIfPresent([LifeGraphObjectReference].self, forKey: .waitingReferences) ?? [])
        self.futureNorthStarCount = try container.decodeIfPresent(Int.self, forKey: .futureNorthStarCount) ?? 0
        self.oneStepGoalCount = try container.decodeIfPresent(Int.self, forKey: .oneStepGoalCount) ?? 0
        self.hasDormantDirection = try container.decodeIfPresent(Bool.self, forKey: .hasDormantDirection) ?? false
        self.supportsNorthStarGrouping = try container.decodeIfPresent(Bool.self, forKey: .supportsNorthStarGrouping) ?? true
        self.supportsOneStepGoalGrouping = try container.decodeIfPresent(Bool.self, forKey: .supportsOneStepGoalGrouping) ?? true
    }

    private static func orderedUnique(_ references: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return references
            .filter(\.isWellFormed)
            .filter { seen.insert($0.stableKey).inserted }
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
            hint: "Life Areas organize goals without adding a new top-level tab. Map and list keep the same ordered meaning, and Reduce Motion preserves the same object meaning."
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
    let oneStepGoalCount: Int
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
        self.oneStepGoalCount = overview.areas.map(\.relationshipHooks.oneStepGoalCount).reduce(0, +)
        self.hasDormantDirection = overview.areas.contains { $0.relationshipHooks.hasDormantDirection }
    }
}
