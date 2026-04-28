import Foundation

let northStarSchemaVersion = "north_star.native.v1"

struct NorthStarID: RawRepresentable, Codable, Sendable, Equatable, Hashable, Comparable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func < (lhs: NorthStarID, rhs: NorthStarID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum NorthStarPosture: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case dormant
    case activeDirection = "active_direction"
    case parked
    case readyToShape = "ready_to_shape"
    case needsReview = "needs_review"
    case archived

    var displayName: String {
        switch self {
        case .dormant:
            return "Dormant for now"
        case .activeDirection:
            return "Active Direction"
        case .parked:
            return "Parked"
        case .readyToShape:
            return "Ready to shape"
        case .needsReview:
            return "Review later"
        case .archived:
            return "Archived"
        }
    }

    var isDormantDirection: Bool {
        switch self {
        case .dormant, .parked, .needsReview:
            return true
        case .activeDirection, .readyToShape, .archived:
            return false
        }
    }

    var isArchived: Bool {
        self == .archived
    }
}

enum NorthStarHorizon: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case someday
    case oneYear = "one_year"
    case threeYears = "three_years"
    case fiveYears = "five_years"
    case identityLevel = "identity_level"
    case openEnded = "open_ended"

    var displayName: String {
        switch self {
        case .someday:
            return "Someday"
        case .oneYear:
            return "About a year"
        case .threeYears:
            return "A few years"
        case .fiveYears:
            return "Long range"
        case .identityLevel:
            return "Identity-level"
        case .openEnded:
            return "Open-ended"
        }
    }
}

enum NorthStarActivationReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case heldWithoutPressure = "held_without_pressure"
    case needsClarity = "needs_clarity"
    case hasSupportingGoal = "has_supporting_goal"
    case readyToShape = "ready_to_shape"
    case notForNow = "not_for_now"

    var displayName: String {
        switch self {
        case .heldWithoutPressure:
            return "Held without pressure"
        case .needsClarity:
            return "Needs clarity"
        case .hasSupportingGoal:
            return "Has an active goal"
        case .readyToShape:
            return "Ready to shape"
        case .notForNow:
            return "Not for now"
        }
    }
}

enum NorthStarPrivacyLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case full
    case compact
    case redacted
}

struct NorthStarReferenceHooks: Codable, Sendable, Equatable, Hashable {
    let lifeAreaReference: LifeGraphObjectReference
    let linkedGoalReferences: [LifeGraphObjectReference]
    let pathReferences: [LifeGraphObjectReference]
    let milestoneReferences: [LifeGraphObjectReference]
    let stepReferences: [LifeGraphObjectReference]
    let proofReferences: [LifeGraphObjectReference]
    let decisionReferences: [LifeGraphObjectReference]
    let receiptReferences: [LifeGraphObjectReference]
    let reviewReferences: [LifeGraphObjectReference]
    let futureOneStepGoalReferences: [LifeGraphObjectReference]

    init(
        lifeAreaReference: LifeGraphObjectReference,
        linkedGoalReferences: [LifeGraphObjectReference] = [],
        pathReferences: [LifeGraphObjectReference] = [],
        milestoneReferences: [LifeGraphObjectReference] = [],
        stepReferences: [LifeGraphObjectReference] = [],
        proofReferences: [LifeGraphObjectReference] = [],
        decisionReferences: [LifeGraphObjectReference] = [],
        receiptReferences: [LifeGraphObjectReference] = [],
        reviewReferences: [LifeGraphObjectReference] = [],
        futureOneStepGoalReferences: [LifeGraphObjectReference] = []
    ) {
        self.lifeAreaReference = lifeAreaReference
        self.linkedGoalReferences = Self.orderedUnique(linkedGoalReferences)
        self.pathReferences = Self.orderedUnique(pathReferences)
        self.milestoneReferences = Self.orderedUnique(milestoneReferences)
        self.stepReferences = Self.orderedUnique(stepReferences)
        self.proofReferences = Self.orderedUnique(proofReferences)
        self.decisionReferences = Self.orderedUnique(decisionReferences)
        self.receiptReferences = Self.orderedUnique(receiptReferences)
        self.reviewReferences = Self.orderedUnique(reviewReferences)
        self.futureOneStepGoalReferences = Self.orderedUnique(futureOneStepGoalReferences)
    }

    private static func orderedUnique(_ references: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return references
            .filter(\.isWellFormed)
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
}

struct NorthStarAccessibilityProjection: Codable, Sendable, Equatable, Hashable {
    let label: String
    let value: String
    let hint: String
}

struct NorthStar: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: NorthStarID
    let title: String
    let summary: String?
    let primaryLifeAreaID: LifeAreaID
    let secondaryLifeAreaIDs: [LifeAreaID]
    let posture: NorthStarPosture
    let horizon: NorthStarHorizon?
    let motivationNote: String?
    let linkedGoalIDs: [String]
    let proofReferenceIDs: [String]
    let receiptReferenceIDs: [String]
    let decisionReferenceIDs: [String]
    let reviewReferenceIDs: [String]
    let activationReadiness: NorthStarActivationReadiness
    let canBeShaped: Bool
    let shapeIntoGoalLabel: String
    let suggestedNextAction: String?
    let createdAt: String?
    let updatedAt: String?
    let lastReferencedAt: String?
    let isSensitive: Bool
    let relationshipHooks: NorthStarReferenceHooks

    init(
        schemaVersion: String = northStarSchemaVersion,
        id: NorthStarID,
        title: String,
        summary: String? = nil,
        primaryLifeAreaID: LifeAreaID,
        secondaryLifeAreaIDs: [LifeAreaID] = [],
        posture: NorthStarPosture = .dormant,
        horizon: NorthStarHorizon? = nil,
        motivationNote: String? = nil,
        linkedGoalIDs: [String] = [],
        proofReferenceIDs: [String] = [],
        receiptReferenceIDs: [String] = [],
        decisionReferenceIDs: [String] = [],
        reviewReferenceIDs: [String] = [],
        activationReadiness: NorthStarActivationReadiness = .heldWithoutPressure,
        canBeShaped: Bool = false,
        shapeIntoGoalLabel: String = "This can become a goal later",
        suggestedNextAction: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        lastReferencedAt: String? = nil,
        isSensitive: Bool = false,
        relationshipHooks: NorthStarReferenceHooks? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = Self.normalizedOptional(summary)
        self.primaryLifeAreaID = primaryLifeAreaID
        self.secondaryLifeAreaIDs = Self.orderedUniqueLifeAreaIDs(secondaryLifeAreaIDs.filter { $0 != primaryLifeAreaID })
        self.posture = posture
        self.horizon = horizon
        self.motivationNote = Self.normalizedOptional(motivationNote)
        self.linkedGoalIDs = Self.orderedUniqueStrings(linkedGoalIDs)
        self.proofReferenceIDs = Self.orderedUniqueStrings(proofReferenceIDs)
        self.receiptReferenceIDs = Self.orderedUniqueStrings(receiptReferenceIDs)
        self.decisionReferenceIDs = Self.orderedUniqueStrings(decisionReferenceIDs)
        self.reviewReferenceIDs = Self.orderedUniqueStrings(reviewReferenceIDs)
        self.activationReadiness = activationReadiness
        self.canBeShaped = canBeShaped
        self.shapeIntoGoalLabel = shapeIntoGoalLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "This can become a goal later"
            : shapeIntoGoalLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.suggestedNextAction = Self.normalizedOptional(suggestedNextAction)
        self.createdAt = Self.normalizedOptional(createdAt)
        self.updatedAt = Self.normalizedOptional(updatedAt)
        self.lastReferencedAt = Self.normalizedOptional(lastReferencedAt)
        self.isSensitive = isSensitive

        let areaReference = LifeGraphObjectReference(
            kind: .lifeArea,
            id: primaryLifeAreaID.rawValue,
            label: LifeAreaDefinition.canonical.first(where: { $0.id == primaryLifeAreaID })?.displayName,
            sourceDomain: .goals
        )
        self.relationshipHooks = relationshipHooks ?? NorthStarReferenceHooks(
            lifeAreaReference: areaReference,
            linkedGoalReferences: self.linkedGoalIDs.map {
                LifeGraphObjectReference(kind: .goal, id: $0, sourceDomain: .goals)
            },
            proofReferences: self.proofReferenceIDs.map {
                LifeGraphObjectReference(kind: .proof, id: $0, parentContextID: id.rawValue, sourceDomain: .proof)
            },
            decisionReferences: self.decisionReferenceIDs.map {
                LifeGraphObjectReference(kind: .decision, id: $0, parentContextID: id.rawValue, sourceDomain: .goals)
            },
            receiptReferences: self.receiptReferenceIDs.map {
                LifeGraphObjectReference(kind: .receipt, id: $0, parentContextID: id.rawValue, sourceDomain: .receipt)
            },
            reviewReferences: self.reviewReferenceIDs.map {
                LifeGraphObjectReference(kind: .review, id: $0, parentContextID: id.rawValue, sourceDomain: .you)
            }
        )
    }

    var objectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .northStar,
            id: id.rawValue,
            label: title.isEmpty ? "North Star" : title,
            sourceDomain: .goals
        )
    }

    var redacted: NorthStar {
        NorthStar(
            schemaVersion: schemaVersion,
            id: id,
            title: "Private North Star",
            summary: "Detail hidden",
            primaryLifeAreaID: primaryLifeAreaID,
            secondaryLifeAreaIDs: secondaryLifeAreaIDs,
            posture: posture,
            horizon: horizon,
            motivationNote: "Detail hidden",
            linkedGoalIDs: linkedGoalIDs,
            proofReferenceIDs: proofReferenceIDs,
            receiptReferenceIDs: receiptReferenceIDs,
            decisionReferenceIDs: decisionReferenceIDs,
            reviewReferenceIDs: reviewReferenceIDs,
            activationReadiness: activationReadiness,
            canBeShaped: canBeShaped,
            shapeIntoGoalLabel: shapeIntoGoalLabel,
            suggestedNextAction: suggestedNextAction.map { _ in "Review later" },
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastReferencedAt: lastReferencedAt,
            isSensitive: true,
            relationshipHooks: relationshipHooks
        )
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func orderedUniqueStrings(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }

    private static func orderedUniqueLifeAreaIDs(_ values: [LifeAreaID]) -> [LifeAreaID] {
        var seen = Set<LifeAreaID>()
        return values
            .filter { seen.insert($0).inserted }
            .sorted()
    }
}

struct NorthStarSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: NorthStarID
    let title: String
    let summary: String?
    let lifeAreaID: LifeAreaID
    let posture: NorthStarPosture
    let horizonLabel: String?
    let activationReadiness: NorthStarActivationReadiness
    let linkedActiveGoalCount: Int
    let canBeShaped: Bool
    let shapeIntoGoalLabel: String
    let suggestedNextAction: String?
    let privacyLevel: NorthStarPrivacyLevel
    let objectReference: LifeGraphObjectReference
    let relationshipHooks: NorthStarReferenceHooks
    let accessibility: NorthStarAccessibilityProjection

    init(northStar: NorthStar, linkedActiveGoalCount: Int, privacyLevel: NorthStarPrivacyLevel) {
        let hidden = privacyLevel == .redacted
        let visibleNorthStar = hidden ? northStar.redacted : northStar
        self.id = visibleNorthStar.id
        self.title = hidden ? "Private North Star" : visibleNorthStar.title
        self.summary = hidden ? "Detail hidden" : visibleNorthStar.summary
        self.lifeAreaID = visibleNorthStar.primaryLifeAreaID
        self.posture = visibleNorthStar.posture
        self.horizonLabel = visibleNorthStar.horizon?.displayName
        self.activationReadiness = visibleNorthStar.activationReadiness
        self.linkedActiveGoalCount = linkedActiveGoalCount
        self.canBeShaped = visibleNorthStar.canBeShaped
        self.shapeIntoGoalLabel = visibleNorthStar.shapeIntoGoalLabel
        self.suggestedNextAction = hidden ? "Review later" : visibleNorthStar.suggestedNextAction
        self.privacyLevel = privacyLevel
        self.objectReference = hidden
            ? LifeGraphObjectReference(kind: .northStar, id: visibleNorthStar.id.rawValue, label: "Private North Star", sourceDomain: .goals)
            : visibleNorthStar.objectReference
        self.relationshipHooks = visibleNorthStar.relationshipHooks
        self.accessibility = NorthStarAccessibilityProjection(
            label: hidden ? "Private North Star" : "North Star, \(visibleNorthStar.title)",
            value: hidden
                ? "Detail hidden. \(visibleNorthStar.posture.displayName)."
                : "\(visibleNorthStar.posture.displayName). \(visibleNorthStar.activationReadiness.displayName). \(linkedActiveGoalCount) linked active goal\(linkedActiveGoalCount == 1 ? "" : "s").",
            hint: visibleNorthStar.canBeShaped
                ? "This can become a goal later. No goal is created automatically."
                : "Held without pressure under its Life Area."
        )
    }
}

struct NorthStarAreaSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LifeAreaID
    let definition: LifeAreaDefinition?
    let northStars: [NorthStarSummary]
    let counts: NorthStarPostureCounts
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: NorthStarPrivacyLevel
    let accessibility: NorthStarAccessibilityProjection
}

struct NorthStarPostureCounts: Codable, Sendable, Equatable, Hashable {
    let dormant: Int
    let activeDirection: Int
    let parked: Int
    let readyToShape: Int
    let needsReview: Int
    let archived: Int

    var total: Int {
        dormant + activeDirection + parked + readyToShape + needsReview + archived
    }

    var hasDormantDirection: Bool {
        dormant > 0 || parked > 0 || needsReview > 0
    }
}

struct NorthStarsProjection: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let title: String
    let subtitle: String
    let areas: [NorthStarAreaSummary]
    let counts: NorthStarPostureCounts
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: NorthStarPrivacyLevel
    let accessibility: NorthStarAccessibilityProjection

    var privacySafeCompact: NorthStarsProjection {
        NorthStarsProjection(
            schemaVersion: schemaVersion,
            title: title,
            subtitle: "North Stars are available with sensitive details hidden.",
            areas: areas.map { area in
                NorthStarAreaSummary(
                    id: area.id,
                    definition: area.definition,
                    northStars: area.northStars.map { summary in
                        NorthStarSummary(
                            northStar: NorthStar(
                                id: summary.id,
                                title: "Private North Star",
                                summary: "Detail hidden",
                                primaryLifeAreaID: summary.lifeAreaID,
                                posture: summary.posture,
                                horizon: nil,
                                activationReadiness: summary.activationReadiness,
                                canBeShaped: summary.canBeShaped,
                                shapeIntoGoalLabel: summary.shapeIntoGoalLabel,
                                suggestedNextAction: "Review later",
                                isSensitive: true,
                                relationshipHooks: summary.relationshipHooks
                            ),
                            linkedActiveGoalCount: summary.linkedActiveGoalCount,
                            privacyLevel: .redacted
                        )
                    },
                    counts: area.counts,
                    emptyTitle: "No North Stars here yet",
                    emptyMessage: "Held directions will appear here without becoming pressure.",
                    privacyLevel: .redacted,
                    accessibility: NorthStarAccessibilityProjection(
                        label: area.definition.map { "Life Area North Stars, \($0.displayName)" } ?? "Life Area North Stars",
                        value: "\(area.counts.total) North Stars. Detail hidden.",
                        hint: "Sensitive long-range direction is hidden."
                    )
                )
            },
            counts: counts,
            emptyTitle: "No North Stars here yet",
            emptyMessage: "Long-range directions can be saved without becoming active goals.",
            privacyLevel: .redacted
        )
    }

    init(
        schemaVersion: String = northStarSchemaVersion,
        title: String = "North Stars",
        subtitle: String = "Long-range direction held without pressure.",
        areas: [NorthStarAreaSummary],
        counts: NorthStarPostureCounts,
        emptyTitle: String = "No North Stars here yet",
        emptyMessage: String = "Long-range directions can be saved without becoming active goals.",
        privacyLevel: NorthStarPrivacyLevel
    ) {
        self.schemaVersion = schemaVersion
        self.title = title
        self.subtitle = subtitle
        self.areas = areas
        self.counts = counts
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.privacyLevel = privacyLevel
        self.accessibility = NorthStarAccessibilityProjection(
            label: title,
            value: "\(counts.total) North Stars. \(counts.readyToShape) ready to shape. \(counts.dormant) dormant for now.",
            hint: "North Stars live under Life Areas and do not become goals automatically."
        )
    }
}
