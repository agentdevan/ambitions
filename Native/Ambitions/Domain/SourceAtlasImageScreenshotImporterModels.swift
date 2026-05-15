import Foundation

let sourceAtlasImageScreenshotImporterSchemaVersion = "source_atlas_image_screenshot_importer.native.v1"

enum SourceAtlasImageScreenshotInputKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case image
    case screenshot
    case unknown
    case unsupported
}

enum SourceAtlasImageScreenshotManualCorrectionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case provided

    var isPresent: Bool {
        self != .none
    }
}

enum SourceAtlasImageScreenshotImportExtractionQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normalizedTextBlocks = "normalized_text_blocks"
    case partial
    case noText = "no_text"
    case failed
}

enum SourceAtlasImageScreenshotImportFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case noText = "no_text"
    case unsupportedInputKind = "unsupported_input_kind"
}

enum SourceAtlasImageScreenshotImportFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
}

struct SourceAtlasImageScreenshotImportRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let title: String?
    let originalLocator: String
    let canonicalLocator: String?
    let inputKind: SourceAtlasImageScreenshotInputKind
    let imageLocators: [SourceAtlasVisionOCRImageLocator]
    let textBlocks: [SourceAtlasVisionOCRTextBlock]
    let manualCorrectionState: SourceAtlasImageScreenshotManualCorrectionState
    let manualCorrectionNote: String?
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
        inputKind: SourceAtlasImageScreenshotInputKind = .screenshot,
        imageLocators: [SourceAtlasVisionOCRImageLocator] = [],
        textBlocks: [SourceAtlasVisionOCRTextBlock] = [],
        manualCorrectionState: SourceAtlasImageScreenshotManualCorrectionState = .none,
        manualCorrectionNote: String? = nil,
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
        self.imageLocators = imageLocators
        self.textBlocks = Self.normalizedTextBlocks(textBlocks)
        self.manualCorrectionState = manualCorrectionState
        self.manualCorrectionNote = Self.trimmedOptional(manualCorrectionNote)
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

struct SourceAtlasImageScreenshotImportCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let originalLocator: String
    let canonicalLocator: String?
    let inputKind: SourceAtlasImageScreenshotInputKind
    let imageLocators: [SourceAtlasVisionOCRImageLocator]
    let normalizedTextBlocks: [String]
    let ocrQualityLabels: [SourceAtlasVisionOCRQualityLabel]
    let manualCorrectionState: SourceAtlasImageScreenshotManualCorrectionState
    let manualCorrectionNote: String?
    let sourceHash: String
    let extractionQuality: SourceAtlasImageScreenshotImportExtractionQuality
    let failure: SourceAtlasImageScreenshotImportFailure
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
            manualCorrectionState.isPresent ||
            failure != .none
    }

    var canMutateWithoutReview: Bool {
        false
    }

    var canSupportOfficialCurrentClaim: Bool {
        false
    }

    var fallbackReason: SourceAtlasImageScreenshotImportFallbackReason {
        switch failure {
        case .none:
            return requiresReview ? .reviewRequired : .none
        case .sourceNeeded, .noText, .unsupportedInputKind:
            return .sourceNeeded
        }
    }
}

struct SourceAtlasImageScreenshotImporter: Sendable, Equatable, Hashable {
    func importImageScreenshot(_ request: SourceAtlasImageScreenshotImportRequest) -> SourceAtlasImageScreenshotImportCandidate {
        let normalizedTextBlocks = request.textBlocks.map(\.text)
        let validationFailure = Self.validationFailure(
            inputKind: request.inputKind,
            imageLocators: request.imageLocators,
            normalizedTextBlocks: normalizedTextBlocks
        )
        let extractionQuality = Self.extractionQuality(
            failure: validationFailure,
            manualCorrectionState: request.manualCorrectionState,
            textBlocks: normalizedTextBlocks,
            qualityLabels: request.textBlocks.map(\.qualityLabel)
        )
        let sourceState = Self.conservativeSourceState(request.declaredSourceState)
        let freshnessState = Self.conservativeFreshnessState(request.declaredFreshnessState)
        let sourceHash = request.suppliedSourceHash ?? Self.stableSourceHash(
            originalLocator: request.originalLocator,
            canonicalLocator: request.canonicalLocator,
            inputKind: request.inputKind,
            imageLocators: request.imageLocators,
            textBlocks: request.textBlocks,
            manualCorrectionState: request.manualCorrectionState,
            manualCorrectionNote: request.manualCorrectionNote,
            sourceState: sourceState,
            freshnessState: freshnessState,
            failure: validationFailure
        )

        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: request.title ?? Self.defaultTitle(inputKind: request.inputKind),
            kind: .image,
            sourceKind: .userProvided,
            locator: request.canonicalLocator ?? request.originalLocator,
            provenanceState: .ocrDerived,
            extractionState: Self.containerExtractionState(
                failure: validationFailure,
                extractionQuality: extractionQuality
            ),
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            failureState: Self.containerFailureState(
                failure: validationFailure,
                sourceState: sourceState
            ),
            sourceRecordIDs: [],
            claimIDs: [],
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasImageScreenshotImportCandidate(
            id: request.id,
            title: request.title,
            originalLocator: request.originalLocator,
            canonicalLocator: request.canonicalLocator,
            inputKind: request.inputKind,
            imageLocators: request.imageLocators,
            normalizedTextBlocks: normalizedTextBlocks,
            ocrQualityLabels: Self.orderedUnique(
                request.textBlocks.map(\.qualityLabel),
                fallbackLabel: Self.fallbackQualityLabel(
                    failure: validationFailure,
                    extractionQuality: extractionQuality
                )
            ),
            manualCorrectionState: request.manualCorrectionState,
            manualCorrectionNote: request.manualCorrectionNote,
            sourceHash: sourceHash,
            extractionQuality: extractionQuality,
            failure: validationFailure,
            sourceKind: .userProvided,
            provenanceState: .ocrDerived,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            container: container,
            schemaVersion: sourceAtlasImageScreenshotImporterSchemaVersion
        )
    }

    private static func validationFailure(
        inputKind: SourceAtlasImageScreenshotInputKind,
        imageLocators: [SourceAtlasVisionOCRImageLocator],
        normalizedTextBlocks: [String]
    ) -> SourceAtlasImageScreenshotImportFailure {
        if inputKind == .unsupported {
            return .unsupportedInputKind
        }
        if imageLocators.isEmpty && normalizedTextBlocks.isEmpty {
            return .sourceNeeded
        }
        if normalizedTextBlocks.isEmpty {
            return .noText
        }
        return .none
    }

    private static func extractionQuality(
        failure: SourceAtlasImageScreenshotImportFailure,
        manualCorrectionState: SourceAtlasImageScreenshotManualCorrectionState,
        textBlocks: [String],
        qualityLabels: [SourceAtlasVisionOCRQualityLabel]
    ) -> SourceAtlasImageScreenshotImportExtractionQuality {
        switch failure {
        case .unsupportedInputKind, .sourceNeeded:
            return .failed
        case .noText:
            return .noText
        case .none:
            guard textBlocks.isEmpty == false else {
                return .noText
            }
            if manualCorrectionState.isPresent {
                return .partial
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

    private static func defaultTitle(inputKind: SourceAtlasImageScreenshotInputKind) -> String {
        switch inputKind {
        case .screenshot:
            return "Screenshot output needs review"
        case .image, .unknown, .unsupported:
            return "Image output needs review"
        }
    }

    private static func containerExtractionState(
        failure: SourceAtlasImageScreenshotImportFailure,
        extractionQuality: SourceAtlasImageScreenshotImportExtractionQuality
    ) -> SourceAtlasSourceContainerExtractionState {
        switch failure {
        case .none:
            switch extractionQuality {
            case .normalizedTextBlocks, .partial:
                return .ocrDerived
            case .noText, .failed:
                return .extractionFailed
            }
        case .sourceNeeded, .noText, .unsupportedInputKind:
            return .extractionFailed
        }
    }

    private static func containerFailureState(
        failure: SourceAtlasImageScreenshotImportFailure,
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
        failure: SourceAtlasImageScreenshotImportFailure,
        extractionQuality: SourceAtlasImageScreenshotImportExtractionQuality
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
        inputKind: SourceAtlasImageScreenshotInputKind,
        imageLocators: [SourceAtlasVisionOCRImageLocator],
        textBlocks: [SourceAtlasVisionOCRTextBlock],
        manualCorrectionState: SourceAtlasImageScreenshotManualCorrectionState,
        manualCorrectionNote: String?,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState,
        failure: SourceAtlasImageScreenshotImportFailure
    ) -> String {
        let hashInput = [
            originalLocator,
            canonicalLocator ?? "canonical:nil",
            inputKind.rawValue,
            imageLocators.map(\.locator).joined(separator: ","),
            textBlocks.map { "\($0.qualityLabel.rawValue):\($0.text)" }.joined(separator: "\u{1f}"),
            manualCorrectionState.rawValue,
            manualCorrectionNote ?? "manual_correction_note:nil",
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
