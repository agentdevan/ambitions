import Foundation

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

    static func normalizedOptional(_ value: String?) -> String? {
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

    static func deterministicID(
        kind: LifeGraphRelationshipKind,
        source: LifeGraphObjectReference,
        target: LifeGraphObjectReference
    ) -> String {
        "lifegraph:\(source.stableKey):\(kind.rawValue):\(target.stableKey)"
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9:_-]+"#, with: "-", options: .regularExpression)
    }

    static func normalizedOptional(_ value: String?) -> String? {
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

    func filtered(
        kind: LifeGraphRelationshipKind?,
        where predicate: (LifeGraphRelationship) -> Bool
    ) -> [LifeGraphRelationship] {
        relationships.filter { relationship in
            predicate(relationship) && (kind == nil || relationship.kind == kind)
        }
    }

    func parentCandidate(
        for object: LifeGraphObjectReference,
        excluding visited: Set<String>
    ) -> LifeGraphObjectReference? {
        let containerParents = incoming(to: object, kind: .contains).map(\.source)
        let belongsToParents = outgoing(from: object, kind: .belongsTo).map(\.target)
        return orderedUniqueReferences(containerParents + belongsToParents)
            .first { visited.contains($0.stableKey) == false }
    }

    func orderedUniqueReferences(_ references: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
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

    static func validOrderedUnique(_ relationships: [LifeGraphRelationship]) -> [LifeGraphRelationship] {
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
