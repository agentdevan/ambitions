import Foundation

let sourceAtlasPDFImportBoundarySchemaVersion = "source_atlas_pdf_import_boundary.native.v1"

enum SourceAtlasPDFImportRoute: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localFile = "local_file"
    case pdfURL = "pdf_url"
}

enum SourceAtlasPDFImportExtractionQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case metadataOnly = "metadata_only"
    case blocked
    case failed
}

enum SourceAtlasPDFImportFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case lockedOrEncrypted = "locked_or_encrypted"
    case corrupt
    case huge
    case partial
    case noText = "no_text"
    case privateSensitive = "private_sensitive"
    case unsupported
}

enum SourceAtlasPDFImportFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
}

struct SourceAtlasPDFImportRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let originalLocator: String
    let canonicalLocator: String?
    let title: String?
    let suppliedSourceHash: String?
    let declaredSourceState: SourceAtlasRequirementSourceState
    let declaredFreshnessState: SourceAtlasFreshnessState
    let declaredFailure: SourceAtlasPDFImportFailure
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        originalLocator: String,
        canonicalLocator: String? = nil,
        title: String? = nil,
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown,
        declaredFailure: SourceAtlasPDFImportFailure = .none,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = Self.trimmed(id)
        self.originalLocator = Self.trimmed(originalLocator)
        self.canonicalLocator = Self.trimmedOptional(canonicalLocator)
        self.title = Self.trimmedOptional(title)
        self.suppliedSourceHash = Self.trimmedOptional(suppliedSourceHash)
        self.declaredSourceState = declaredSourceState
        self.declaredFreshnessState = declaredFreshnessState
        self.declaredFailure = declaredFailure
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
}

struct SourceAtlasPDFImportCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let originalLocator: String
    let canonicalLocator: String?
    let route: SourceAtlasPDFImportRoute?
    let sourceHash: String
    let extractionQuality: SourceAtlasPDFImportExtractionQuality
    let failure: SourceAtlasPDFImportFailure
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

    var fallbackReason: SourceAtlasPDFImportFallbackReason {
        switch failure {
        case .none:
            return requiresReview ? .reviewRequired : .none
        case .privateSensitive:
            return .reviewRequired
        case .sourceNeeded, .lockedOrEncrypted, .corrupt, .huge, .partial, .noText, .unsupported:
            return .sourceNeeded
        }
    }
}

struct SourceAtlasPDFImportBoundary: Sendable, Equatable, Hashable {
    func importPDF(_ request: SourceAtlasPDFImportRequest) -> SourceAtlasPDFImportCandidate {
        let route = Self.route(for: request.canonicalLocator ?? request.originalLocator)
        let failure = Self.validationFailure(
            declaredFailure: request.declaredFailure,
            effectiveLocator: request.canonicalLocator ?? request.originalLocator,
            route: route
        )
        let sourceState = Self.conservativeSourceState(request.declaredSourceState)
        let freshnessState = Self.conservativeFreshnessState(request.declaredFreshnessState)
        let provenanceState = Self.provenanceState(for: route)
        let extractionQuality = Self.extractionQuality(
            failure: failure,
            route: route
        )
        let title = request.title ?? Self.defaultTitle(route: route, failure: failure)
        let sourceHash = request.suppliedSourceHash ?? Self.stableSourceHash(
            locator: request.canonicalLocator ?? request.originalLocator,
            title: title,
            route: route,
            failure: failure,
            sourceState: sourceState,
            freshnessState: freshnessState
        )

        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: title,
            kind: .pdf,
            sourceKind: .userProvided,
            locator: request.canonicalLocator ?? request.originalLocator,
            provenanceState: provenanceState,
            extractionState: Self.extractionState(failure: failure),
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            failureState: Self.containerFailureState(
                failure: failure,
                sourceState: sourceState
            ),
            sourceRecordIDs: sourceState == .locallyProven ? [request.id] : [],
            claimIDs: [],
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasPDFImportCandidate(
            id: request.id,
            title: request.title,
            originalLocator: request.originalLocator,
            canonicalLocator: request.canonicalLocator,
            route: route,
            sourceHash: sourceHash,
            extractionQuality: extractionQuality,
            failure: failure,
            sourceKind: .userProvided,
            provenanceState: provenanceState,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            container: container,
            schemaVersion: sourceAtlasPDFImportBoundarySchemaVersion
        )
    }

    private static func route(for locator: String) -> SourceAtlasPDFImportRoute? {
        let trimmedLocator = locator.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedLocator.isEmpty == false else {
            return nil
        }

        if let components = URLComponents(string: trimmedLocator),
           let scheme = components.scheme?.lowercased() {
            guard Self.isPDFLocator(trimmedLocator) else {
                return nil
            }
            switch scheme {
            case "file":
                return .localFile
            case "http", "https":
                return .pdfURL
            default:
                return nil
            }
        }

        let lowercased = trimmedLocator.lowercased()
        if Self.isPDFLocator(trimmedLocator) &&
            (trimmedLocator.hasPrefix("/") ||
                trimmedLocator.hasPrefix("~") ||
                lowercased.hasSuffix(".pdf")) {
            return .localFile
        }

        return nil
    }

    private static func isPDFLocator(_ locator: String) -> Bool {
        if let components = URLComponents(string: locator),
           components.scheme?.isEmpty == false {
            return components.path.lowercased().hasSuffix(".pdf")
        }
        return locator.lowercased().hasSuffix(".pdf")
    }

    private static func validationFailure(
        declaredFailure: SourceAtlasPDFImportFailure,
        effectiveLocator: String,
        route: SourceAtlasPDFImportRoute?
    ) -> SourceAtlasPDFImportFailure {
        if declaredFailure != .none {
            return declaredFailure
        }
        guard effectiveLocator.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return .sourceNeeded
        }
        return route == nil ? .unsupported : .none
    }

    private static func conservativeSourceState(
        _ declaredSourceState: SourceAtlasRequirementSourceState
    ) -> SourceAtlasRequirementSourceState {
        switch declaredSourceState {
        case .official, .officialCurrent, .current:
            return .sourceNeeded
        case .unknown, .sourceNeeded, .stale, .contradicted, .revoked, .locallyProven:
            return declaredSourceState
        }
    }

    private static func conservativeFreshnessState(
        _ declaredFreshnessState: SourceAtlasFreshnessState
    ) -> SourceAtlasFreshnessState {
        switch declaredFreshnessState {
        case .current:
            return .needsReview
        case .aging, .stale, .staleCritical, .sourceChanged, .disputed, .revoked, .unknown, .userProvided, .needsReview:
            return declaredFreshnessState
        }
    }

    private static func provenanceState(
        for route: SourceAtlasPDFImportRoute?
    ) -> SourceAtlasSourceContainerProvenanceState {
        switch route {
        case .localFile:
            return .localFile
        case .pdfURL:
            return .sourceAttached
        case .none:
            return .unknown
        }
    }

    private static func extractionQuality(
        failure: SourceAtlasPDFImportFailure,
        route: SourceAtlasPDFImportRoute?
    ) -> SourceAtlasPDFImportExtractionQuality {
        switch failure {
        case .none:
            return route == nil ? .failed : .metadataOnly
        case .lockedOrEncrypted, .huge, .privateSensitive:
            return .blocked
        case .sourceNeeded, .corrupt, .partial, .noText, .unsupported:
            return .failed
        }
    }

    private static func extractionState(
        failure: SourceAtlasPDFImportFailure
    ) -> SourceAtlasSourceContainerExtractionState {
        switch failure {
        case .none, .lockedOrEncrypted, .huge, .privateSensitive:
            return .sourceLinked
        case .sourceNeeded:
            return .notStarted
        case .corrupt, .partial, .noText, .unsupported:
            return .extractionFailed
        }
    }

    private static func containerFailureState(
        failure: SourceAtlasPDFImportFailure,
        sourceState: SourceAtlasRequirementSourceState
    ) -> SourceAtlasSourceContainerFailureState {
        switch failure {
        case .none:
            switch sourceState {
            case .stale:
                return .stale
            case .contradicted:
                return .contradicted
            case .revoked:
                return .revoked
            case .unknown, .sourceNeeded, .locallyProven, .official, .officialCurrent, .current:
                return sourceState == .sourceNeeded ? .sourceMissing : .none
            }
        case .sourceNeeded:
            return .sourceMissing
        case .lockedOrEncrypted, .huge:
            return .inaccessible
        case .corrupt, .partial, .noText:
            return .extractionFailed
        case .privateSensitive:
            return .privacyReviewRequired
        case .unsupported:
            return .unsupportedFormat
        }
    }

    private static func defaultTitle(
        route: SourceAtlasPDFImportRoute?,
        failure: SourceAtlasPDFImportFailure
    ) -> String {
        switch (route, failure) {
        case (_, .privateSensitive):
            return "Private PDF needs privacy review"
        case (.localFile, _):
            return "Local PDF needs privacy review"
        case (.pdfURL, _):
            return "PDF URL needs privacy review"
        case (nil, _):
            return "PDF source needs privacy review"
        }
    }

    private static func stableSourceHash(
        locator: String,
        title: String,
        route: SourceAtlasPDFImportRoute?,
        failure: SourceAtlasPDFImportFailure,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState
    ) -> String {
        let hashInput = [
            locator,
            title,
            route?.rawValue ?? "route:nil",
            failure.rawValue,
            sourceState.rawValue,
            freshnessState.rawValue
        ].joined(separator: "\u{1f}")

        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}
