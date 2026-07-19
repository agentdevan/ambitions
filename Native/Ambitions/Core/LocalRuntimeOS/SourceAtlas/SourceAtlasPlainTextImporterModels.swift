import Foundation

let sourceAtlasPlainTextImporterSchemaVersion = "source_atlas_plain_text_importer.native.v1"

enum SourceAtlasPlainTextImportChannel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pasteboard
    case shareExtension = "share_extension"
    case manualEntry = "manual_entry"
}

enum SourceAtlasPlainTextInputKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case plainText = "plain_text"
    case markdown
    case richText = "rich_text"
    case unknown
    case unsupported
}

enum SourceAtlasPlainTextSourceCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case copiedExcerpt = "copied_excerpt"
    case personalNote = "personal_note"
    case possibleRequirement = "possible_requirement"
    case unknown
    case unsupported
}

enum SourceAtlasPlainTextExtractionQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normalizedTextBlocks = "normalized_text_blocks"
    case tooShort = "too_short"
    case failed
}

enum SourceAtlasPlainTextImportFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case emptyText = "empty_text"
    case tooShort = "too_short"
    case unsupportedInputKind = "unsupported_input_kind"
}

enum SourceAtlasPlainTextImportFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
}

struct SourceAtlasPlainTextImportRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let title: String?
    let originalText: String
    let channel: SourceAtlasPlainTextImportChannel
    let inputKind: SourceAtlasPlainTextInputKind
    let declaredSourceCategory: SourceAtlasPlainTextSourceCategory?
    let suppliedSourceHash: String?
    let declaredSourceState: SourceAtlasRequirementSourceState
    let declaredFreshnessState: SourceAtlasFreshnessState
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        title: String? = nil,
        originalText: String,
        channel: SourceAtlasPlainTextImportChannel = .pasteboard,
        inputKind: SourceAtlasPlainTextInputKind = .plainText,
        declaredSourceCategory: SourceAtlasPlainTextSourceCategory? = nil,
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = Self.trimmed(id)
        self.title = Self.trimmedOptional(title)
        self.originalText = originalText
        self.channel = channel
        self.inputKind = inputKind
        self.declaredSourceCategory = declaredSourceCategory
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
}

struct SourceAtlasPlainTextImportCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let channel: SourceAtlasPlainTextImportChannel
    let inputKind: SourceAtlasPlainTextInputKind
    let sourceCategory: SourceAtlasPlainTextSourceCategory
    let normalizedTextBlocks: [String]
    let sourceHash: String
    let extractionQuality: SourceAtlasPlainTextExtractionQuality
    let failure: SourceAtlasPlainTextImportFailure
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

    var fallbackReason: SourceAtlasPlainTextImportFallbackReason {
        switch failure {
        case .none:
            return requiresReview ? .reviewRequired : .none
        case .emptyText, .tooShort, .unsupportedInputKind:
            return .sourceNeeded
        }
    }
}

struct SourceAtlasPlainTextImporter: Sendable, Equatable, Hashable {
    func importPlainText(_ request: SourceAtlasPlainTextImportRequest) -> SourceAtlasPlainTextImportCandidate {
        let normalizedTextBlocks = Self.normalizedTextBlocks(request.originalText)
        let validationFailure = Self.validationFailure(
            inputKind: request.inputKind,
            normalizedTextBlocks: normalizedTextBlocks
        )
        let sourceState = Self.conservativeSourceState(
            request.declaredSourceState,
            failure: validationFailure
        )
        let freshnessState = Self.conservativeFreshnessState(
            request.declaredFreshnessState,
            failure: validationFailure
        )
        let sourceCategory = Self.sourceCategory(
            declared: request.declaredSourceCategory,
            channel: request.channel,
            inputKind: request.inputKind,
            normalizedTextBlocks: normalizedTextBlocks,
            failure: validationFailure
        )
        let extractionQuality = Self.extractionQuality(
            failure: validationFailure,
            normalizedTextBlocks: normalizedTextBlocks
        )
        let sourceHash = request.suppliedSourceHash ?? Self.stableSourceHash(
            inputKind: request.inputKind,
            sourceCategory: sourceCategory,
            textBlocks: normalizedTextBlocks
        )
        let title = request.title ?? "Copied text needs review"

        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: title,
            kind: .plainText,
            sourceKind: .userProvided,
            locator: nil,
            provenanceState: .copiedContent,
            extractionState: .copiedText,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsSourceReview,
            privacyClass: .privateLife,
            failureState: Self.containerFailureState(
                failure: validationFailure,
                sourceState: sourceState
            ),
            sourceRecordIDs: [],
            claimIDs: [],
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasPlainTextImportCandidate(
            id: request.id,
            title: request.title,
            channel: request.channel,
            inputKind: request.inputKind,
            sourceCategory: sourceCategory,
            normalizedTextBlocks: normalizedTextBlocks,
            sourceHash: sourceHash,
            extractionQuality: extractionQuality,
            failure: validationFailure,
            sourceKind: .userProvided,
            provenanceState: .copiedContent,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: .needsSourceReview,
            privacyClass: .privateLife,
            container: container,
            schemaVersion: sourceAtlasPlainTextImporterSchemaVersion
        )
    }

    private static func validationFailure(
        inputKind: SourceAtlasPlainTextInputKind,
        normalizedTextBlocks: [String]
    ) -> SourceAtlasPlainTextImportFailure {
        guard inputKind != .unsupported else {
            return .unsupportedInputKind
        }
        guard normalizedTextBlocks.isEmpty == false else {
            return .emptyText
        }
        let normalizedCharacterCount = normalizedTextBlocks.joined(separator: " ").count
        guard normalizedCharacterCount >= 12 else {
            return .tooShort
        }
        return .none
    }

    private static func normalizedTextBlocks(_ text: String) -> [String] {
        var blocks: [String] = []
        var currentLines: [String] = []

        for line in text.components(separatedBy: .newlines) {
            let normalizedLine = normalizedWhitespace(line)
            if normalizedLine.isEmpty {
                appendBlock(lines: &currentLines, to: &blocks)
            } else {
                currentLines.append(normalizedLine)
            }
        }
        appendBlock(lines: &currentLines, to: &blocks)

        var seen: Set<String> = []
        return blocks.filter { block in
            seen.insert(block).inserted
        }
    }

    private static func appendBlock(lines: inout [String], to blocks: inout [String]) {
        let block = lines.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        if block.isEmpty == false {
            blocks.append(block)
        }
        lines.removeAll(keepingCapacity: true)
    }

    private static func normalizedWhitespace(_ value: String) -> String {
        value
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
    }

    private static func sourceCategory(
        declared: SourceAtlasPlainTextSourceCategory?,
        channel: SourceAtlasPlainTextImportChannel,
        inputKind: SourceAtlasPlainTextInputKind,
        normalizedTextBlocks: [String],
        failure: SourceAtlasPlainTextImportFailure
    ) -> SourceAtlasPlainTextSourceCategory {
        guard failure != .unsupportedInputKind else {
            return .unsupported
        }
        if let declared, declared != .unsupported {
            return declared
        }
        if inputKind == .unknown {
            return .unknown
        }
        if channel == .manualEntry {
            return .personalNote
        }
        let joined = normalizedTextBlocks.joined(separator: " ").lowercased()
        if joined.contains("required") ||
            joined.contains("requirement") ||
            joined.contains("must ") ||
            joined.contains("deadline") ||
            joined.contains("certification") {
            return .possibleRequirement
        }
        return .copiedExcerpt
    }

    private static func extractionQuality(
        failure: SourceAtlasPlainTextImportFailure,
        normalizedTextBlocks: [String]
    ) -> SourceAtlasPlainTextExtractionQuality {
        switch failure {
        case .none:
            return .normalizedTextBlocks
        case .tooShort:
            return .tooShort
        case .emptyText, .unsupportedInputKind:
            return normalizedTextBlocks.isEmpty ? .failed : .normalizedTextBlocks
        }
    }

    private static func conservativeSourceState(
        _ sourceState: SourceAtlasRequirementSourceState,
        failure: SourceAtlasPlainTextImportFailure
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

    private static func conservativeFreshnessState(
        _ freshnessState: SourceAtlasFreshnessState,
        failure: SourceAtlasPlainTextImportFailure
    ) -> SourceAtlasFreshnessState {
        guard failure == .none else {
            return .needsReview
        }
        switch freshnessState {
        case .current:
            return .needsReview
        case .aging, .stale, .staleCritical, .sourceChanged, .disputed, .revoked, .unknown, .userProvided, .needsReview:
            return freshnessState
        }
    }

    private static func containerFailureState(
        failure: SourceAtlasPlainTextImportFailure,
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
                return .none
            }
        case .emptyText, .tooShort:
            return .sourceMissing
        case .unsupportedInputKind:
            return .unsupportedFormat
        }
    }

    private static func stableSourceHash(
        inputKind: SourceAtlasPlainTextInputKind,
        sourceCategory: SourceAtlasPlainTextSourceCategory,
        textBlocks: [String]
    ) -> String {
        let hashInput = ([inputKind.rawValue, sourceCategory.rawValue] + textBlocks)
            .joined(separator: "\u{1f}")
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in hashInput.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}
