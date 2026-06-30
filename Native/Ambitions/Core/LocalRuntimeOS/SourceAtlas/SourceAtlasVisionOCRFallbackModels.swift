import Foundation

let sourceAtlasVisionOCRFallbackSchemaVersion = "source_atlas_vision_ocr_fallback.native.v1"

enum SourceAtlasVisionOCRInputKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case image
    case scannedPDF = "scanned_pdf"
    case unknown
    case unsupported
}

enum SourceAtlasVisionOCRQualityLabel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case highConfidence = "high_confidence"
    case mediumConfidence = "medium_confidence"
    case lowConfidence = "low_confidence"
    case noText = "no_text"
    case failed
    case unknown

    var isReviewWorthy: Bool {
        switch self {
        case .lowConfidence, .noText, .failed, .unknown:
            return true
        case .highConfidence, .mediumConfidence:
            return false
        }
    }
}

enum SourceAtlasVisionOCRFallbackExtractionQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normalizedTextBlocks = "normalized_text_blocks"
    case partial
    case noText = "no_text"
    case failed
}

enum SourceAtlasVisionOCRFallbackFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case noText = "no_text"
    case unsupportedInputKind = "unsupported_input_kind"
}

enum SourceAtlasVisionOCRFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
}

struct SourceAtlasVisionOCRPageLocator: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let pageIndex: Int
    let pageNumber: Int
    let locator: String
    let text: String?

    init(pageIndex: Int, text: String? = nil) {
        self.pageIndex = pageIndex
        self.pageNumber = pageIndex + 1
        self.locator = "page:\(self.pageNumber)"
        self.text = Self.trimmedOptional(text)
        self.id = Self.deterministicID(pageIndex: pageIndex, locator: self.locator)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private static func deterministicID(pageIndex: Int, locator: String) -> String {
        let hashInput = "\(pageIndex)\u{1f}\(locator)"
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}

struct SourceAtlasVisionOCRImageLocator: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let imageIndex: Int
    let locator: String
    let text: String?

    init(imageIndex: Int, text: String? = nil) {
        self.imageIndex = imageIndex
        self.locator = "image:\(imageIndex + 1)"
        self.text = Self.trimmedOptional(text)
        self.id = Self.deterministicID(imageIndex: imageIndex, locator: self.locator)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private static func deterministicID(imageIndex: Int, locator: String) -> String {
        let hashInput = "\(imageIndex)\u{1f}\(locator)"
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}

struct SourceAtlasVisionOCRTextBlock: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let locator: String?
    let text: String
    let qualityLabel: SourceAtlasVisionOCRQualityLabel

    init(locator: String? = nil, text: String, qualityLabel: SourceAtlasVisionOCRQualityLabel) {
        self.locator = Self.trimmedOptional(locator)
        self.text = Self.normalizedText(text)
        self.qualityLabel = qualityLabel
        self.id = Self.deterministicID(
            locator: self.locator,
            text: self.text,
            qualityLabel: qualityLabel
        )
    }

    private static func normalizedText(_ value: String) -> String {
        value
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private static func deterministicID(
        locator: String?,
        text: String,
        qualityLabel: SourceAtlasVisionOCRQualityLabel
    ) -> String {
        let hashInput = [
            locator ?? "locator:nil",
            text,
            qualityLabel.rawValue
        ].joined(separator: "\u{1f}")

        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}

struct SourceAtlasVisionOCRFallbackRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let title: String?
    let originalLocator: String
    let canonicalLocator: String?
    let inputKind: SourceAtlasVisionOCRInputKind
    let pageLocators: [SourceAtlasVisionOCRPageLocator]
    let imageLocators: [SourceAtlasVisionOCRImageLocator]
    let textBlocks: [SourceAtlasVisionOCRTextBlock]
    let suppliedSourceHash: String?
    let declaredSourceState: SourceAtlasRequirementSourceState
    let declaredFreshnessState: SourceAtlasFreshnessState
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        title: String? = nil,
        originalLocator: String,
        canonicalLocator: String? = nil,
        inputKind: SourceAtlasVisionOCRInputKind = .unknown,
        pageLocators: [SourceAtlasVisionOCRPageLocator] = [],
        imageLocators: [SourceAtlasVisionOCRImageLocator] = [],
        textBlocks: [SourceAtlasVisionOCRTextBlock] = [],
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = Self.trimmed(id)
        self.title = Self.trimmedOptional(title)
        self.originalLocator = Self.trimmed(originalLocator)
        self.canonicalLocator = Self.trimmedOptional(canonicalLocator)
        self.inputKind = inputKind
        self.pageLocators = pageLocators
        self.imageLocators = imageLocators
        self.textBlocks = Self.normalizedTextBlocks(textBlocks)
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

    private static func normalizedTextBlocks(_ blocks: [SourceAtlasVisionOCRTextBlock]) -> [SourceAtlasVisionOCRTextBlock] {
        var seen: Set<String> = []
        return blocks.compactMap { block in
            guard block.text.isEmpty == false else {
                return nil
            }
            guard seen.insert(block.text).inserted else {
                return nil
            }
            return block
        }
    }
}

struct SourceAtlasVisionOCRFallbackCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let originalLocator: String
    let canonicalLocator: String?
    let inputKind: SourceAtlasVisionOCRInputKind
    let pageLocators: [SourceAtlasVisionOCRPageLocator]
    let imageLocators: [SourceAtlasVisionOCRImageLocator]
    let normalizedTextBlocks: [String]
    let ocrQualityLabels: [SourceAtlasVisionOCRQualityLabel]
    let sourceHash: String
    let extractionQuality: SourceAtlasVisionOCRFallbackExtractionQuality
    let failure: SourceAtlasVisionOCRFallbackFailure
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
            extractionQuality != .normalizedTextBlocks ||
            failure != .none
    }

    var canMutateWithoutReview: Bool {
        false
    }

    var canSupportOfficialCurrentClaim: Bool {
        false
    }

    var fallbackReason: SourceAtlasVisionOCRFallbackReason {
        switch failure {
        case .none:
            return requiresReview ? .reviewRequired : .none
        case .sourceNeeded, .noText, .unsupportedInputKind:
            return .sourceNeeded
        }
    }
}

struct SourceAtlasVisionOCRFallback {
    func fallbackOCR(_ request: SourceAtlasVisionOCRFallbackRequest) -> SourceAtlasVisionOCRFallbackCandidate {
        let normalizedTextBlocks = request.textBlocks.map(\.text)
        let failure = Self.validationFailure(
            inputKind: request.inputKind,
            pageLocators: request.pageLocators,
            imageLocators: request.imageLocators,
            normalizedTextBlocks: normalizedTextBlocks
        )
        let extractionQuality = Self.extractionQuality(
            failure: failure,
            textBlocks: normalizedTextBlocks,
            qualityLabels: request.textBlocks.map(\.qualityLabel)
        )
        let sourceState = Self.conservativeSourceState(request.declaredSourceState)
        let freshnessState = Self.conservativeFreshnessState(request.declaredFreshnessState)
        let sourceHash = request.suppliedSourceHash ?? Self.stableSourceHash(
            originalLocator: request.originalLocator,
            canonicalLocator: request.canonicalLocator,
            inputKind: request.inputKind,
            pageLocators: request.pageLocators,
            imageLocators: request.imageLocators,
            textBlocks: request.textBlocks,
            sourceState: sourceState,
            freshnessState: freshnessState,
            failure: failure
        )

        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: request.title ?? "OCR output needs review",
            kind: Self.containerKind(for: request.inputKind),
            sourceKind: .userProvided,
            locator: request.canonicalLocator ?? request.originalLocator,
            provenanceState: .ocrDerived,
            extractionState: Self.containerExtractionState(
                failure: failure,
                extractionQuality: extractionQuality
            ),
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            failureState: Self.containerFailureState(
                failure: failure,
                sourceState: sourceState
            ),
            sourceRecordIDs: [],
            claimIDs: [],
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasVisionOCRFallbackCandidate(
            id: request.id,
            title: request.title ?? "OCR output needs review",
            originalLocator: request.originalLocator,
            canonicalLocator: request.canonicalLocator,
            inputKind: request.inputKind,
            pageLocators: request.pageLocators,
            imageLocators: request.imageLocators,
            normalizedTextBlocks: normalizedTextBlocks,
            ocrQualityLabels: Self.orderedUnique(
                request.textBlocks.map(\.qualityLabel),
                fallbackLabel: Self.fallbackQualityLabel(
                    failure: failure,
                    extractionQuality: extractionQuality
                )
            ),
            sourceHash: sourceHash,
            extractionQuality: extractionQuality,
            failure: failure,
            sourceKind: .userProvided,
            provenanceState: .ocrDerived,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            container: container,
            schemaVersion: sourceAtlasVisionOCRFallbackSchemaVersion
        )
    }

    private static func validationFailure(
        inputKind: SourceAtlasVisionOCRInputKind,
        pageLocators: [SourceAtlasVisionOCRPageLocator],
        imageLocators: [SourceAtlasVisionOCRImageLocator],
        normalizedTextBlocks: [String]
    ) -> SourceAtlasVisionOCRFallbackFailure {
        if inputKind == .unsupported {
            return .unsupportedInputKind
        }
        if pageLocators.isEmpty && imageLocators.isEmpty && normalizedTextBlocks.isEmpty {
            return .sourceNeeded
        }
        if normalizedTextBlocks.isEmpty {
            return .noText
        }
        return .none
    }

    private static func extractionQuality(
        failure: SourceAtlasVisionOCRFallbackFailure,
        textBlocks: [String],
        qualityLabels: [SourceAtlasVisionOCRQualityLabel]
    ) -> SourceAtlasVisionOCRFallbackExtractionQuality {
        switch failure {
        case .unsupportedInputKind, .sourceNeeded:
            return .failed
        case .noText:
            return .noText
        case .none:
            guard textBlocks.isEmpty == false else {
                return .noText
            }
            guard qualityLabels.contains(where: { $0.isReviewWorthy }) == false else {
                return .partial
            }
            return .normalizedTextBlocks
        }
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

    private static func containerKind(for inputKind: SourceAtlasVisionOCRInputKind) -> SourceAtlasSourceContainerKind {
        switch inputKind {
        case .image:
            return .image
        case .scannedPDF, .unknown, .unsupported:
            return .pdf
        }
    }

    private static func containerExtractionState(
        failure: SourceAtlasVisionOCRFallbackFailure,
        extractionQuality: SourceAtlasVisionOCRFallbackExtractionQuality
    ) -> SourceAtlasSourceContainerExtractionState {
        switch failure {
        case .none:
            switch extractionQuality {
            case .normalizedTextBlocks:
                return .ocrDerived
            case .partial:
                return .ocrDerived
            case .noText:
                return .extractionFailed
            case .failed:
                return .extractionFailed
            }
        case .sourceNeeded, .noText:
            return .extractionFailed
        case .unsupportedInputKind:
            return .extractionFailed
        }
    }

    private static func containerFailureState(
        failure: SourceAtlasVisionOCRFallbackFailure,
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
        case .sourceNeeded, .noText:
            return .sourceMissing
        case .unsupportedInputKind:
            return .unsupportedFormat
        }
    }

    private static func fallbackQualityLabel(
        failure: SourceAtlasVisionOCRFallbackFailure,
        extractionQuality: SourceAtlasVisionOCRFallbackExtractionQuality
    ) -> SourceAtlasVisionOCRQualityLabel {
        switch (failure, extractionQuality) {
        case (.none, .normalizedTextBlocks):
            return .highConfidence
        case (.none, .partial):
            return .mediumConfidence
        case (.none, .noText), (.sourceNeeded, _):
            return .noText
        case (.unsupportedInputKind, _), (.none, .failed), (.noText, _):
            return .failed
        }
    }

    private static func stableSourceHash(
        originalLocator: String,
        canonicalLocator: String?,
        inputKind: SourceAtlasVisionOCRInputKind,
        pageLocators: [SourceAtlasVisionOCRPageLocator],
        imageLocators: [SourceAtlasVisionOCRImageLocator],
        textBlocks: [SourceAtlasVisionOCRTextBlock],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState,
        failure: SourceAtlasVisionOCRFallbackFailure
    ) -> String {
        let hashInput = [
            originalLocator,
            canonicalLocator ?? "canonical:nil",
            inputKind.rawValue,
            pageLocators.map(\.locator).joined(separator: ","),
            imageLocators.map(\.locator).joined(separator: ","),
            textBlocks.map { "\($0.qualityLabel.rawValue):\($0.text)" }.joined(separator: "\u{1f}"),
            sourceState.rawValue,
            freshnessState.rawValue,
            failure.rawValue
        ].joined(separator: "\u{1f}")

        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }

    private static func orderedUnique<T: Hashable>(
        _ values: [T],
        fallbackLabel: T? = nil
    ) -> [T] {
        var seen: Set<T> = []
        var result: [T] = []
        for value in values {
            if seen.insert(value).inserted {
                result.append(value)
            }
        }
        if result.isEmpty, let fallbackLabel, seen.insert(fallbackLabel).inserted {
            result.append(fallbackLabel)
        }
        return result
    }
}
