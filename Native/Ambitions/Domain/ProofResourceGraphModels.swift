import Foundation

let proofResourceGraphSchemaVersion = "proof_resource_graph.native.v1"

enum ProofReferenceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case completedAction = "completed_action"
    case stillCounts = "still_counts"
    case note
    case link
    case fileReference = "file_reference"
    case photoReference = "photo_reference"
    case calendarBlockReference = "calendar_block_reference"
    case reflection
    case externalArtifactReference = "external_artifact_reference"
    case decision
    case milestoneEvidence = "milestone_evidence"
    case feedbackReceived = "feedback_received"
    case blockerResolved = "blocker_resolved"
}

enum ProofStrength: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case weak
    case supporting
    case strong
    case decisive
}

enum ResourceReferenceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case note
    case link
    case fileReference = "file_reference"
    case documentReference = "document_reference"
    case externalReference = "external_reference"
    case projectArtifact = "project_artifact"
    case checklistTemplate = "checklist_template"
    case personReference = "person_reference"
    case calendarReference = "calendar_reference"
}

struct ProofReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: ProofReferenceKind
    let title: String
    let summary: String?
    let sourceObject: LifeGraphObjectReference?
    let attachedObject: LifeGraphObjectReference
    let occurredAt: String?
    let createdAt: String?
    let strength: ProofStrength?
    let sourceDomain: LifeGraphSourceDomain?
    let schemaVersion: String

    init(
        id: String,
        kind: ProofReferenceKind,
        title: String,
        summary: String? = nil,
        sourceObject: LifeGraphObjectReference? = nil,
        attachedObject: LifeGraphObjectReference,
        occurredAt: String? = nil,
        createdAt: String? = nil,
        strength: ProofStrength? = nil,
        sourceDomain: LifeGraphSourceDomain? = nil,
        schemaVersion: String = proofResourceGraphSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.kind = kind
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedOptional(summary)
        self.sourceObject = sourceObject
        self.attachedObject = attachedObject
        self.occurredAt = Self.normalizedOptional(occurredAt)
        self.createdAt = Self.normalizedOptional(createdAt)
        self.strength = strength
        self.sourceDomain = sourceDomain
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && title.isEmpty == false && attachedObject.isWellFormed && (sourceObject?.isWellFormed ?? true)
    }

    var lifeGraphObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .proof,
            id: id,
            parentContextID: attachedObject.id,
            label: title,
            sourceDomain: sourceDomain ?? .proof
        )
    }

    fileprivate var orderingKey: String {
        [
            attachedObject.stableKey,
            occurredAt ?? createdAt ?? "",
            kind.rawValue,
            title.lowercased(),
            id
        ].joined(separator: ":")
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct ResourceReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: ResourceReferenceKind
    let title: String
    let locator: String?
    let summary: String?
    let attachedObject: LifeGraphObjectReference
    let sourceDomain: LifeGraphSourceDomain?
    let schemaVersion: String

    init(
        id: String,
        kind: ResourceReferenceKind,
        title: String,
        locator: String? = nil,
        summary: String? = nil,
        attachedObject: LifeGraphObjectReference,
        sourceDomain: LifeGraphSourceDomain? = nil,
        schemaVersion: String = proofResourceGraphSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.locator = ProofReference.normalizedOptional(locator)
        self.summary = ProofReference.normalizedOptional(summary)
        self.attachedObject = attachedObject
        self.sourceDomain = sourceDomain
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && title.isEmpty == false && attachedObject.isWellFormed
    }

    var lifeGraphObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .resource,
            id: id,
            parentContextID: attachedObject.id,
            label: title,
            sourceDomain: sourceDomain ?? .resource
        )
    }

    fileprivate var orderingKey: String {
        [
            attachedObject.stableKey,
            kind.rawValue,
            title.lowercased(),
            locator ?? "",
            id
        ].joined(separator: ":")
    }
}

struct ProofResourceGraphProjection: Sendable, Equatable {
    let proofReferences: [ProofReference]
    let resourceReferences: [ResourceReference]
    let lifeGraphProjection: LifeGraphRelationshipProjection

    init(
        proofReferences: [ProofReference] = [],
        resourceReferences: [ResourceReference] = []
    ) {
        self.proofReferences = Self.validOrderedUniqueProof(proofReferences)
        self.resourceReferences = Self.validOrderedUniqueResources(resourceReferences)
        self.lifeGraphProjection = LifeGraphRelationshipProjection(
            relationships: Self.projectRelationships(
                proofReferences: self.proofReferences,
                resourceReferences: self.resourceReferences
            )
        )
    }

    func proof(attachedTo object: LifeGraphObjectReference) -> [ProofReference] {
        proofReferences.filter { $0.attachedObject.stableKey == object.stableKey }
    }

    func resources(attachedTo object: LifeGraphObjectReference) -> [ResourceReference] {
        resourceReferences.filter { $0.attachedObject.stableKey == object.stableKey }
    }

    func relationshipProjection(for object: LifeGraphObjectReference) -> LifeGraphRelationshipProjection {
        LifeGraphRelationshipProjection(
            relationships: lifeGraphProjection.relationships.filter {
                $0.source.stableKey == object.stableKey || $0.target.stableKey == object.stableKey
            }
        )
    }

    static func attachProof(
        _ proof: ProofReference,
        to relationships: LifeGraphRelationshipProjection = LifeGraphRelationshipProjection()
    ) -> LifeGraphRelationshipProjection {
        var projection = relationships
        projectedRelationships(for: proof).forEach { _ = projection.add($0) }
        return projection
    }

    static func attachResource(
        _ resource: ResourceReference,
        to relationships: LifeGraphRelationshipProjection = LifeGraphRelationshipProjection()
    ) -> LifeGraphRelationshipProjection {
        var projection = relationships
        projectedRelationships(for: resource).forEach { _ = projection.add($0) }
        return projection
    }

    private static func projectRelationships(
        proofReferences: [ProofReference],
        resourceReferences: [ResourceReference]
    ) -> [LifeGraphRelationship] {
        proofReferences.flatMap(projectedRelationships) + resourceReferences.flatMap(projectedRelationships)
    }

    private static func projectedRelationships(for proof: ProofReference) -> [LifeGraphRelationship] {
        guard proof.isWellFormed else { return [] }

        let proofObject = proof.lifeGraphObjectReference
        var relationships = [
            LifeGraphRelationship(
                kind: proof.relationshipKindToAttachedObject,
                source: proofObject,
                target: proof.attachedObject,
                note: proof.summary
            )
        ]

        if let sourceObject = proof.sourceObject {
            relationships.append(
                LifeGraphRelationship(
                    kind: .produces,
                    source: sourceObject,
                    target: proofObject,
                    note: proof.summary
                )
            )
        }

        return relationships
    }

    private static func projectedRelationships(for resource: ResourceReference) -> [LifeGraphRelationship] {
        guard resource.isWellFormed else { return [] }

        return [
            LifeGraphRelationship(
                kind: resource.relationshipKindToAttachedObject,
                source: resource.lifeGraphObjectReference,
                target: resource.attachedObject,
                note: resource.summary
            )
        ]
    }

    private static func validOrderedUniqueProof(_ references: [ProofReference]) -> [ProofReference] {
        var seen = Set<String>()
        return references
            .filter(\.isWellFormed)
            .filter { seen.insert($0.dedupeKey).inserted }
            .sorted { lhs, rhs in lhs.orderingKey < rhs.orderingKey }
    }

    private static func validOrderedUniqueResources(_ references: [ResourceReference]) -> [ResourceReference] {
        var seen = Set<String>()
        return references
            .filter(\.isWellFormed)
            .filter { seen.insert($0.dedupeKey).inserted }
            .sorted { lhs, rhs in lhs.orderingKey < rhs.orderingKey }
    }
}

private extension ProofReference {
    var dedupeKey: String {
        [
            id,
            kind.rawValue,
            attachedObject.stableKey,
            sourceObject?.stableKey ?? ""
        ].joined(separator: ":")
    }

    var relationshipKindToAttachedObject: LifeGraphRelationshipKind {
        switch kind {
        case .decision:
            return .explains
        case .note, .reflection:
            return .relatesTo
        default:
            return .proves
        }
    }
}

private extension ResourceReference {
    var dedupeKey: String {
        [
            id,
            kind.rawValue,
            attachedObject.stableKey,
            locator ?? ""
        ].joined(separator: ":")
    }

    var relationshipKindToAttachedObject: LifeGraphRelationshipKind {
        switch kind {
        case .note:
            return .relatesTo
        default:
            return .attachedTo
        }
    }
}
