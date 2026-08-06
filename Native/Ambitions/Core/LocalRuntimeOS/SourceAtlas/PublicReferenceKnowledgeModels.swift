import Foundation

let publicReferenceKnowledgeSchemaVersion = "public_reference_knowledge.native.v1"

struct PublicReferenceClaimID: Codable, Sendable, Equatable, Hashable, Identifiable {
    let rawValue: String

    var id: String { rawValue }

    init(_ rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum PublicReferenceAuthorityLane: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case classification
    case description
    case typicalPreparation = "typical_preparation"
    case hardGate = "hard_gate"
    case providerOffering = "provider_offering"
    case accreditationOrRecognition = "accreditation_or_recognition"
    case transfer
    case safetyOrLegalRule = "safety_or_legal_rule"
    case marketOrOutcomeDescription = "market_or_outcome_description"
}

struct PublicReferenceAuthority: Codable, Sendable, Equatable, Hashable {
    let publisherID: String
    let lane: PublicReferenceAuthorityLane
    let statement: String

    init(publisherID: String, lane: PublicReferenceAuthorityLane, statement: String) {
        self.publisherID = publisherID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lane = lane
        self.statement = statement.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PublicReferenceJurisdiction: Codable, Sendable, Equatable, Hashable {
    let code: String
    let label: String

    init(code: String, label: String) {
        self.code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PublicReferenceRelease: Codable, Sendable, Equatable, Hashable {
    let id: String
    let effectiveFrom: String?
    let effectiveUntil: String?

    init(id: String, effectiveFrom: String? = nil, effectiveUntil: String? = nil) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.effectiveFrom = effectiveFrom?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.effectiveUntil = effectiveUntil?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum PublicReferenceDeliveryState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case bundled
    case cachedVerified = "cached_verified"
    case lastKnownGood = "last_known_good"
    case staged
    case invalid
    case quarantined
    case unavailable
}

enum PublicReferenceSemanticReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case complete
    case incomplete
    case mappingNeeded = "mapping_needed"
    case disputed
}

enum PublicReferenceFreshnessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case aging
    case staleAllowed = "stale_allowed"
    case staleBlocked = "stale_blocked"
    case sourceChanged = "source_changed"
    case revoked
    case superseded
    case unknown
}

enum PublicReferenceRightsState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case approvedWithAttribution = "approved_with_attribution"
    case citationOnly = "citation_only"
    case transformationBlocked = "transformation_blocked"
    case reviewRequired = "review_required"
    case withdrawn
}

enum PublicReferenceClaimAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case authoritative
    case contextual
    case lastKnownGood = "last_known_good"
    case conflicting
    case unavailable
}

struct PublicReferenceClaimValue: Codable, Sendable, Equatable, Hashable {
    let text: String
    let unit: String?
    let languageCode: String?

    init(text: String, unit: String? = nil, languageCode: String? = nil) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.unit = unit?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.languageCode = languageCode?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PublicReferenceClaimEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: PublicReferenceClaimID
    let schemaVersion: String
    let sourceNativeSubjectID: String
    let predicateID: String
    let value: PublicReferenceClaimValue
    let sourceRecordID: String
    let authority: PublicReferenceAuthority
    let jurisdiction: PublicReferenceJurisdiction
    let release: PublicReferenceRelease
    let retrievedAt: String
    let checkedAt: String
    let deliveryState: PublicReferenceDeliveryState
    let semanticReviewState: PublicReferenceSemanticReviewState
    let freshnessState: PublicReferenceFreshnessState
    let rightsState: PublicReferenceRightsState
    let requiredAttribution: String
    let riskState: String
    let conflictIDs: [PublicReferenceClaimID]
    let supersedesIDs: [PublicReferenceClaimID]
    let supersededByIDs: [PublicReferenceClaimID]
    let contentHash: String

    init(
        id: PublicReferenceClaimID,
        sourceNativeSubjectID: String,
        predicateID: String,
        value: PublicReferenceClaimValue,
        sourceRecordID: String,
        authority: PublicReferenceAuthority,
        jurisdiction: PublicReferenceJurisdiction,
        release: PublicReferenceRelease,
        retrievedAt: String,
        checkedAt: String,
        deliveryState: PublicReferenceDeliveryState,
        semanticReviewState: PublicReferenceSemanticReviewState,
        freshnessState: PublicReferenceFreshnessState,
        rightsState: PublicReferenceRightsState,
        requiredAttribution: String,
        riskState: String,
        conflictIDs: [PublicReferenceClaimID] = [],
        supersedesIDs: [PublicReferenceClaimID] = [],
        supersededByIDs: [PublicReferenceClaimID] = [],
        contentHash: String,
        schemaVersion: String = publicReferenceKnowledgeSchemaVersion
    ) {
        self.id = id
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceNativeSubjectID = sourceNativeSubjectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.predicateID = predicateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.value = value
        self.sourceRecordID = sourceRecordID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.authority = authority
        self.jurisdiction = jurisdiction
        self.release = release
        self.retrievedAt = retrievedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.checkedAt = checkedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.deliveryState = deliveryState
        self.semanticReviewState = semanticReviewState
        self.freshnessState = freshnessState
        self.rightsState = rightsState
        self.requiredAttribution = requiredAttribution.trimmingCharacters(in: .whitespacesAndNewlines)
        self.riskState = riskState.trimmingCharacters(in: .whitespacesAndNewlines)
        self.conflictIDs = Self.orderedUnique(conflictIDs)
        self.supersedesIDs = Self.orderedUnique(supersedesIDs)
        self.supersededByIDs = Self.orderedUnique(supersededByIDs)
        self.contentHash = contentHash.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var availability: PublicReferenceClaimAvailability {
        if deliveryState == .unavailable || deliveryState == .invalid || deliveryState == .quarantined ||
            semanticReviewState != .complete || rightsState == .withdrawn || rightsState == .reviewRequired ||
            freshnessState == .staleBlocked || freshnessState == .revoked || freshnessState == .unknown {
            return .unavailable
        }
        if conflictIDs.isEmpty == false || semanticReviewState == .disputed {
            return .conflicting
        }
        if deliveryState == .lastKnownGood || freshnessState == .staleAllowed || freshnessState == .superseded {
            return .lastKnownGood
        }
        if freshnessState == .aging || rightsState == .citationOnly || rightsState == .transformationBlocked {
            return .contextual
        }
        return .authoritative
    }

    var isWellFormed: Bool {
        id.rawValue.isEmpty == false &&
            schemaVersion == publicReferenceKnowledgeSchemaVersion &&
            sourceNativeSubjectID.isEmpty == false &&
            predicateID.isEmpty == false &&
            value.text.isEmpty == false &&
            sourceRecordID.isEmpty == false &&
            authority.publisherID.isEmpty == false &&
            authority.statement.isEmpty == false &&
            jurisdiction.code.isEmpty == false &&
            release.id.isEmpty == false &&
            retrievedAt.isEmpty == false &&
            checkedAt.isEmpty == false &&
            requiredAttribution.isEmpty == false &&
            contentHash.isEmpty == false
    }

    private static func orderedUnique(_ values: [PublicReferenceClaimID]) -> [PublicReferenceClaimID] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

struct PublicReferenceCrosswalkClaim: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let publisherID: String
    let relationshipKind: String
    let sourceNativeID: String
    let sourceReleaseID: String
    let targetNativeID: String
    let targetReleaseID: String
    let reviewState: PublicReferenceSemanticReviewState
    let limitations: String
    let rightsState: PublicReferenceRightsState
    let freshnessState: PublicReferenceFreshnessState

    init(
        id: String,
        publisherID: String,
        relationshipKind: String,
        sourceNativeID: String,
        sourceReleaseID: String,
        targetNativeID: String,
        targetReleaseID: String,
        reviewState: PublicReferenceSemanticReviewState,
        limitations: String,
        rightsState: PublicReferenceRightsState,
        freshnessState: PublicReferenceFreshnessState
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.publisherID = publisherID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.relationshipKind = relationshipKind.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceNativeID = sourceNativeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceReleaseID = sourceReleaseID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.targetNativeID = targetNativeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.targetReleaseID = targetReleaseID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reviewState = reviewState
        self.limitations = limitations.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rightsState = rightsState
        self.freshnessState = freshnessState
    }
}
