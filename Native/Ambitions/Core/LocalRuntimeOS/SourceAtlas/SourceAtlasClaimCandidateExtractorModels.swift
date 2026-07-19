import Foundation

let sourceAtlasClaimCandidateExtractorSchemaVersion = "source_atlas_claim_candidate_extractor.native.v1"

enum SourceAtlasClaimCandidateKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case requirement
    case deadline
    case equipment
    case prerequisite
    case proof
    case unknown
    case warning
}

enum SourceAtlasClaimCandidateSignal: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case requirement
    case deadline
    case equipment
    case prerequisite
    case proof
    case unknown
    case warning
}

struct SourceAtlasClaimCandidateLocatorHint: Codable, Sendable, Equatable, Hashable {
    let sourceLocator: String?
    let pageNumber: Int?
    let lineNumber: Int?
    let pageLocator: String?
    let lineLocator: String?

    init(
        sourceLocator: String?,
        pageNumber: Int?,
        lineNumber: Int?,
        pageLocator: String?,
        lineLocator: String?
    ) {
        self.sourceLocator = Self.trimmedOptional(sourceLocator)
        self.pageNumber = pageNumber
        self.lineNumber = lineNumber
        self.pageLocator = Self.trimmedOptional(pageLocator)
        self.lineLocator = Self.trimmedOptional(lineLocator)
    }

    static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

struct SourceAtlasClaimCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasClaimCandidateKind
    let signal: SourceAtlasClaimCandidateSignal
    let text: String
    let normalizedText: String
    let title: String?
    let sourceLocator: String?
    let locatorHint: SourceAtlasClaimCandidateLocatorHint
    let documentType: SourceAtlasDocumentType?
    let riskClass: SourceAtlasRiskClass
    let sourceKind: SourceAtlasSourceKind
    let provenanceState: SourceAtlasSourceContainerProvenanceState
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let reviewState: HumanProgressReviewState
    let reviewRequired: Bool
    let isExplicitProofCandidate: Bool
    let schemaVersion: String
}

struct SourceAtlasClaimCandidateExtractionBehavior: Codable, Sendable, Equatable, Hashable {
    let performsNetworkAccess: Bool
    let persistsState: Bool
    let mutatesState: Bool
    let makesReleaseClaims: Bool

    static let valueModelOnly = SourceAtlasClaimCandidateExtractionBehavior(
        performsNetworkAccess: false,
        persistsState: false,
        mutatesState: false,
        makesReleaseClaims: false
    )
}

struct SourceAtlasClaimCandidateExtractionInput: Codable, Sendable, Equatable, Hashable {
    let title: String?
    let bodyText: String
    let sourceLocator: String?
    let documentClassifierDecision: SourceAtlasDocumentTypeClassifierDecision?

    init(
        title: String? = nil,
        bodyText: String,
        sourceLocator: String? = nil,
        documentClassifierDecision: SourceAtlasDocumentTypeClassifierDecision? = nil
    ) {
        self.title = Self.trimmedOptional(title)
        self.bodyText = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLocator = Self.trimmedOptional(sourceLocator)
        self.documentClassifierDecision = documentClassifierDecision
    }

    static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

struct SourceAtlasClaimCandidateExtraction: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let bodyText: String
    let sourceLocator: String?
    let documentType: SourceAtlasDocumentType?
    let riskClass: SourceAtlasRiskClass
    let sourceKind: SourceAtlasSourceKind
    let provenanceState: SourceAtlasSourceContainerProvenanceState
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let reviewState: HumanProgressReviewState
    let reviewRequired: Bool
    let candidates: [SourceAtlasClaimCandidate]
    let behavior: SourceAtlasClaimCandidateExtractionBehavior
    let schemaVersion: String

    var hasCandidatesRequiringReview: Bool {
        candidates.contains(where: \.reviewRequired)
    }
}
