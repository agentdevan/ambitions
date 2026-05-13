import Foundation

let sourceAtlasURLSourceImporterSchemaVersion = "source_atlas_url_source_importer.native.v1"

enum SourceAtlasURLImportChannel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pasted
    case shareExtension = "share_extension"
    case manualEntry = "manual_entry"
}

enum SourceAtlasURLImportContentType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case html
    case pdf
    case plainText = "plain_text"
    case json
    case unknown
    case unsupported
}

enum SourceAtlasURLExtractionQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case linkOnly = "link_only"
    case metadataOnly = "metadata_only"
    case normalizedTextBlocks = "normalized_text_blocks"
    case failed
}

enum SourceAtlasURLImportFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case emptyURL = "empty_url"
    case invalidURL = "invalid_url"
    case unsupportedScheme = "unsupported_scheme"
    case unsupportedContentType = "unsupported_content_type"
    case extractionFailed = "extraction_failed"
}

enum SourceAtlasURLImportFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
}

struct SourceAtlasURLImportRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let originalURL: String
    let canonicalURL: String?
    let channel: SourceAtlasURLImportChannel
    let suppliedContentType: SourceAtlasURLImportContentType?
    let mimeType: String?
    let pageTitle: String?
    let extractedTextBlocks: [String]
    let suppliedSourceHash: String?
    let declaredSourceState: SourceAtlasRequirementSourceState
    let declaredFreshnessState: SourceAtlasFreshnessState
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        originalURL: String,
        canonicalURL: String? = nil,
        channel: SourceAtlasURLImportChannel = .pasted,
        suppliedContentType: SourceAtlasURLImportContentType? = nil,
        mimeType: String? = nil,
        pageTitle: String? = nil,
        extractedTextBlocks: [String] = [],
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = Self.trimmed(id)
        self.originalURL = Self.trimmed(originalURL)
        self.canonicalURL = Self.trimmedOptional(canonicalURL)
        self.channel = channel
        self.suppliedContentType = suppliedContentType
        self.mimeType = Self.trimmedOptional(mimeType)
        self.pageTitle = Self.trimmedOptional(pageTitle)
        self.extractedTextBlocks = Self.normalizedTextBlocks(extractedTextBlocks)
        self.suppliedSourceHash = Self.trimmedOptional(suppliedSourceHash)
        self.declaredSourceState = declaredSourceState
        self.declaredFreshnessState = declaredFreshnessState
        self.createdAt = Self.trimmed(createdAt)
        self.updatedAt = Self.trimmed(updatedAt)
    }

    private static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = trimmed(value)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private static func normalizedTextBlocks(_ blocks: [String]) -> [String] {
        var seen: Set<String> = []
        return blocks.compactMap { block in
            let normalized = block
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.isEmpty == false }
                .joined(separator: " ")
            guard normalized.isEmpty == false, seen.insert(normalized).inserted else {
                return nil
            }
            return normalized
        }
    }
}

struct SourceAtlasURLImportCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let originalURL: String
    let canonicalURL: String?
    let channel: SourceAtlasURLImportChannel
    let contentType: SourceAtlasURLImportContentType
    let pageTitle: String?
    let normalizedTextBlocks: [String]
    let sourceHash: String
    let extractionQuality: SourceAtlasURLExtractionQuality
    let failure: SourceAtlasURLImportFailure
    let sourceKind: SourceAtlasSourceKind
    let provenanceState: SourceAtlasSourceContainerProvenanceState
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let container: SourceAtlasSourceContainer
    let schemaVersion: String

    var requiresReview: Bool {
        reviewState.blocksAutomaticMutation ||
            provenanceState.requiresReview ||
            sourceKind != .official ||
            sourceState != .officialCurrent ||
            freshnessState != .current ||
            failure != .none
    }

    var canMutateWithoutReview: Bool {
        false
    }

    var canSupportOfficialCurrentClaim: Bool {
        false
    }

    var fallbackReason: SourceAtlasURLImportFallbackReason {
        switch failure {
        case .none:
            return requiresReview ? .reviewRequired : .none
        case .emptyURL, .invalidURL, .unsupportedScheme, .unsupportedContentType, .extractionFailed:
            return .sourceNeeded
        }
    }
}

struct SourceAtlasURLSourceImporter: Sendable, Equatable, Hashable {
    func importURL(_ request: SourceAtlasURLImportRequest) -> SourceAtlasURLImportCandidate {
        let validationFailure = Self.validationFailure(for: request.originalURL)
        let contentType = request.suppliedContentType ?? Self.detectedContentType(
            canonicalURL: request.canonicalURL ?? request.originalURL,
            mimeType: request.mimeType
        )
        let failure = validationFailure ?? Self.contentFailure(contentType: contentType)
        let extractionQuality = Self.extractionQuality(
            failure: failure,
            title: request.pageTitle,
            textBlocks: request.extractedTextBlocks
        )
        let canonicalURL = failure == .none ? Self.normalizedURLString(request.canonicalURL ?? request.originalURL) : request.canonicalURL
        let sourceState = Self.conservativeSourceState(request.declaredSourceState, failure: failure)
        let containerFailureState = Self.containerFailureState(failure: failure)
        let hash = request.suppliedSourceHash ?? Self.stableSourceHash(
            canonicalURL: canonicalURL ?? request.originalURL,
            contentType: contentType,
            title: request.pageTitle,
            textBlocks: request.extractedTextBlocks
        )
        let title = request.pageTitle ?? "URL source needs review"

        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: title,
            kind: .url,
            sourceKind: .userProvided,
            locator: canonicalURL ?? request.originalURL,
            provenanceState: .userProvided,
            extractionState: Self.containerExtractionState(
                failure: failure,
                extractionQuality: extractionQuality
            ),
            sourceState: sourceState,
            freshnessState: request.declaredFreshnessState,
            reviewState: .needsSourceReview,
            privacyClass: .privateLife,
            failureState: containerFailureState,
            sourceRecordIDs: [],
            claimIDs: [],
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasURLImportCandidate(
            id: request.id,
            originalURL: request.originalURL,
            canonicalURL: canonicalURL,
            channel: request.channel,
            contentType: contentType,
            pageTitle: request.pageTitle,
            normalizedTextBlocks: request.extractedTextBlocks,
            sourceHash: hash,
            extractionQuality: extractionQuality,
            failure: failure,
            sourceKind: .userProvided,
            provenanceState: .userProvided,
            sourceState: sourceState,
            freshnessState: request.declaredFreshnessState,
            reviewState: .needsSourceReview,
            privacyClass: .privateLife,
            container: container,
            schemaVersion: sourceAtlasURLSourceImporterSchemaVersion
        )
    }

    private static func validationFailure(for urlString: String) -> SourceAtlasURLImportFailure? {
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedURL.isEmpty == false else {
            return .emptyURL
        }
        guard let components = URLComponents(string: trimmedURL),
              let scheme = components.scheme?.lowercased(),
              components.host?.isEmpty == false else {
            return .invalidURL
        }
        guard scheme == "https" || scheme == "http" else {
            return .unsupportedScheme
        }
        return nil
    }

    private static func normalizedURLString(_ urlString: String) -> String? {
        guard validationFailure(for: urlString) == nil else {
            return nil
        }
        return URLComponents(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines))?.string
    }

    private static func detectedContentType(
        canonicalURL: String,
        mimeType: String?
    ) -> SourceAtlasURLImportContentType {
        if let mimeType = mimeType?.lowercased() {
            if mimeType.contains("html") { return .html }
            if mimeType.contains("pdf") { return .pdf }
            if mimeType.contains("plain") { return .plainText }
            if mimeType.contains("json") { return .json }
        }

        let pathExtension = URLComponents(string: canonicalURL)?
            .path
            .split(separator: ".")
            .last?
            .lowercased()

        switch pathExtension {
        case "html", "htm":
            return .html
        case "pdf":
            return .pdf
        case "txt", "md":
            return .plainText
        case "json":
            return .json
        case .some:
            return .unknown
        case .none:
            return .unknown
        }
    }

    private static func contentFailure(contentType: SourceAtlasURLImportContentType) -> SourceAtlasURLImportFailure {
        contentType == .unsupported ? .unsupportedContentType : .none
    }

    private static func extractionQuality(
        failure: SourceAtlasURLImportFailure,
        title: String?,
        textBlocks: [String]
    ) -> SourceAtlasURLExtractionQuality {
        if failure != .none {
            return .failed
        }
        if textBlocks.isEmpty == false {
            return .normalizedTextBlocks
        }
        if title?.isEmpty == false {
            return .metadataOnly
        }
        return .linkOnly
    }

    private static func conservativeSourceState(
        _ sourceState: SourceAtlasRequirementSourceState,
        failure: SourceAtlasURLImportFailure
    ) -> SourceAtlasRequirementSourceState {
        guard failure == .none else {
            return .sourceNeeded
        }
        switch sourceState {
        case .official, .officialCurrent, .current:
            return .sourceNeeded
        case .unknown, .sourceNeeded, .stale, .contradicted, .revoked, .locallyProven:
            return sourceState
        }
    }

    private static func containerFailureState(failure: SourceAtlasURLImportFailure) -> SourceAtlasSourceContainerFailureState {
        switch failure {
        case .none:
            return .none
        case .emptyURL, .invalidURL, .unsupportedScheme:
            return .sourceMissing
        case .unsupportedContentType:
            return .unsupportedFormat
        case .extractionFailed:
            return .extractionFailed
        }
    }

    private static func containerExtractionState(
        failure: SourceAtlasURLImportFailure,
        extractionQuality: SourceAtlasURLExtractionQuality
    ) -> SourceAtlasSourceContainerExtractionState {
        switch failure {
        case .none:
            switch extractionQuality {
            case .normalizedTextBlocks:
                return .textExtracted
            case .metadataOnly, .linkOnly:
                return .sourceLinked
            case .failed:
                return .extractionFailed
            }
        case .emptyURL, .invalidURL, .unsupportedScheme, .unsupportedContentType, .extractionFailed:
            return .extractionFailed
        }
    }

    private static func stableSourceHash(
        canonicalURL: String,
        contentType: SourceAtlasURLImportContentType,
        title: String?,
        textBlocks: [String]
    ) -> String {
        let hashInput = ([canonicalURL, contentType.rawValue, title ?? ""] + textBlocks)
            .joined(separator: "\u{1f}")
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}
