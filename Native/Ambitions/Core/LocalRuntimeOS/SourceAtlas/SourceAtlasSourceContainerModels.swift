import Foundation

let sourceAtlasSourceContainerSchemaVersion = "source_atlas_source_container.native.v1"

enum SourceAtlasSourceContainerKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case url
    case pdf
    case image
    case plainText = "plain_text"
    case localFile = "local_file"
    case officialPack = "official_pack"
    case userMiniPack = "user_mini_pack"
}

enum SourceAtlasSourceContainerProvenanceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case approvedOfficial = "approved_official"
    case sourceAttached = "source_attached"
    case userProvided = "user_provided"
    case copiedContent = "copied_content"
    case ocrDerived = "ocr_derived"
    case localFile = "local_file"
    case userMiniPack = "user_mini_pack"
    case unknown

    var requiresReview: Bool {
        switch self {
        case .approvedOfficial, .sourceAttached:
            return false
        case .userProvided, .copiedContent, .ocrDerived, .localFile, .userMiniPack, .unknown:
            return true
        }
    }

    var hasApprovedOfficialProvenance: Bool {
        self == .approvedOfficial
    }
}

enum SourceAtlasSourceContainerExtractionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notStarted = "not_started"
    case sourceLinked = "source_linked"
    case textExtracted = "text_extracted"
    case copiedText = "copied_text"
    case ocrDerived = "ocr_derived"
    case extractionFailed = "extraction_failed"
    case notApplicable = "not_applicable"

    var requiresReview: Bool {
        switch self {
        case .copiedText, .ocrDerived, .extractionFailed:
            return true
        case .notStarted, .sourceLinked, .textExtracted, .notApplicable:
            return false
        }
    }
}

enum SourceAtlasSourceContainerFailureState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceMissing = "source_missing"
    case inaccessible
    case unsupportedFormat = "unsupported_format"
    case extractionFailed = "extraction_failed"
    case stale
    case contradicted
    case revoked
    case privacyReviewRequired = "privacy_review_required"

    var blocksCurrentUse: Bool {
        self != .none
    }
}

struct SourceAtlasSourceContainer: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: SourceAtlasSourceContainerKind
    let sourceKind: SourceAtlasSourceKind
    let locator: String?
    let provenanceState: SourceAtlasSourceContainerProvenanceState
    let extractionState: SourceAtlasSourceContainerExtractionState
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let failureState: SourceAtlasSourceContainerFailureState
    let sourceRecordIDs: [String]
    let claimIDs: [String]
    let createdAt: String
    let updatedAt: String
    let lastReviewedAt: String?
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: SourceAtlasSourceContainerKind,
        sourceKind: SourceAtlasSourceKind = .unknown,
        locator: String? = nil,
        provenanceState: SourceAtlasSourceContainerProvenanceState = .unknown,
        extractionState: SourceAtlasSourceContainerExtractionState = .notStarted,
        sourceState: SourceAtlasRequirementSourceState = .unknown,
        freshnessState: SourceAtlasFreshnessState = .unknown,
        reviewState: HumanProgressReviewState = .needsSourceReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        failureState: SourceAtlasSourceContainerFailureState = .none,
        sourceRecordIDs: [String] = [],
        claimIDs: [String] = [],
        createdAt: String,
        updatedAt: String,
        lastReviewedAt: String? = nil,
        schemaVersion: String = sourceAtlasSourceContainerSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.sourceKind = sourceKind
        self.locator = locator?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.provenanceState = provenanceState
        self.extractionState = extractionState
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = Self.normalizedReviewState(
            kind: kind,
            provenanceState: provenanceState,
            extractionState: extractionState,
            reviewState: reviewState
        )
        self.privacyClass = privacyClass
        self.failureState = Self.normalizedFailureState(
            sourceState: sourceState,
            failureState: failureState
        )
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.claimIDs = Self.orderedUnique(claimIDs)
        self.createdAt = createdAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updatedAt = updatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastReviewedAt = lastReviewedAt?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            createdAt.isEmpty == false &&
            updatedAt.isEmpty == false &&
            schemaVersion == sourceAtlasSourceContainerSchemaVersion
    }

    var requiresReview: Bool {
        provenanceState.requiresReview ||
            extractionState.requiresReview ||
            reviewState.blocksAutomaticMutation ||
            kind == .userMiniPack
    }

    var hasApprovedProvenance: Bool {
        provenanceState.hasApprovedOfficialProvenance &&
            sourceKind == .official &&
            sourceRecordIDs.isEmpty == false
    }

    var canSupportOfficialCurrentClaim: Bool {
        hasApprovedProvenance &&
            sourceState == .officialCurrent &&
            freshnessState == .current &&
            reviewState == .ready &&
            failureState == .none
    }

    var canSupportLocalProofClaim: Bool {
        sourceState == .locallyProven &&
            failureState == .none &&
            reviewState == .ready
    }

    var blocksCurrentUse: Bool {
        failureState.blocksCurrentUse ||
            sourceState.blocksCurrentProjection ||
            freshnessState == .stale ||
            freshnessState == .staleCritical ||
            freshnessState == .sourceChanged ||
            freshnessState == .disputed ||
            freshnessState == .revoked ||
            freshnessState == .unknown ||
            requiresReview
    }

    var conservativeRequirementSourceState: SourceAtlasRequirementSourceState {
        if failureState == .revoked || sourceState == .revoked || freshnessState == .revoked {
            return .revoked
        }
        if failureState == .contradicted || sourceState == .contradicted || freshnessState == .disputed {
            return .contradicted
        }
        if failureState == .stale ||
            sourceState == .stale ||
            freshnessState == .stale ||
            freshnessState == .staleCritical ||
            freshnessState == .sourceChanged {
            return .stale
        }
        if canSupportOfficialCurrentClaim {
            return .officialCurrent
        }
        if canSupportLocalProofClaim {
            return .locallyProven
        }
        if sourceRecordIDs.isEmpty || provenanceState == .unknown {
            return .sourceNeeded
        }
        return sourceState
    }

    private static func normalizedReviewState(
        kind: SourceAtlasSourceContainerKind,
        provenanceState: SourceAtlasSourceContainerProvenanceState,
        extractionState: SourceAtlasSourceContainerExtractionState,
        reviewState: HumanProgressReviewState
    ) -> HumanProgressReviewState {
        if reviewState != .ready {
            return reviewState
        }
        if kind == .userMiniPack || provenanceState.requiresReview || extractionState.requiresReview {
            return .needsSourceReview
        }
        return .ready
    }

    private static func normalizedFailureState(
        sourceState: SourceAtlasRequirementSourceState,
        failureState: SourceAtlasSourceContainerFailureState
    ) -> SourceAtlasSourceContainerFailureState {
        if failureState != .none {
            return failureState
        }
        switch sourceState {
        case .sourceNeeded:
            return .sourceMissing
        case .stale:
            return .stale
        case .contradicted:
            return .contradicted
        case .revoked:
            return .revoked
        case .unknown, .locallyProven, .official, .officialCurrent, .current:
            return .none
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}
