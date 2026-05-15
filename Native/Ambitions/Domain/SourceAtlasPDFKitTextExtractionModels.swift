import Foundation
import PDFKit

let sourceAtlasPDFKitTextExtractionSchemaVersion = "source_atlas_pdfkit_text_extraction.native.v1"

enum SourceAtlasPDFKitTextExtractionQuality: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normalizedTextBlocks = "normalized_text_blocks"
    case partial
    case noText = "no_text"
    case failed
}

enum SourceAtlasPDFKitTextExtractionFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case emptyData = "empty_data"
    case lockedOrEncrypted = "locked_or_encrypted"
    case corruptPDF = "corrupt_pdf"
}

enum SourceAtlasPDFKitTextExtractionFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
}

struct SourceAtlasPDFKitTextExtractionRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let importCandidate: SourceAtlasPDFImportCandidate
    let originalLocator: String
    let canonicalLocator: String?
    let title: String?
    let pdfData: Data
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        importCandidate: SourceAtlasPDFImportCandidate,
        originalLocator: String,
        canonicalLocator: String? = nil,
        title: String? = nil,
        pdfData: Data,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = Self.trimmed(id)
        self.importCandidate = importCandidate
        self.originalLocator = Self.trimmed(originalLocator)
        self.canonicalLocator = Self.trimmedOptional(canonicalLocator)
        self.title = Self.trimmedOptional(title)
        self.pdfData = pdfData
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

struct SourceAtlasPDFKitTextExtractionPageLocator: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let pageIndex: Int
    let pageNumber: Int
    let locator: String
    let text: String?

    init(pageIndex: Int, text: String?) {
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

struct SourceAtlasPDFKitTextExtractionCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let sourceImportCandidateID: String
    let originalLocator: String
    let canonicalLocator: String?
    let pageLocators: [SourceAtlasPDFKitTextExtractionPageLocator]
    let normalizedTextBlocks: [String]
    let sourceHash: String
    let extractionQuality: SourceAtlasPDFKitTextExtractionQuality
    let failure: SourceAtlasPDFKitTextExtractionFailure
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

    var fallbackReason: SourceAtlasPDFKitTextExtractionFallbackReason {
        switch failure {
        case .none:
            switch extractionQuality {
            case .normalizedTextBlocks, .partial:
                return .reviewRequired
            case .noText, .failed:
                return .sourceNeeded
            }
        case .emptyData, .lockedOrEncrypted, .corruptPDF:
            return .sourceNeeded
        }
    }
}

struct SourceAtlasPDFKitTextExtractor: Sendable, Equatable, Hashable {
    func extractText(_ request: SourceAtlasPDFKitTextExtractionRequest) -> SourceAtlasPDFKitTextExtractionCandidate {
        let document = request.pdfData.isEmpty ? nil : PDFDocument(data: request.pdfData)
        let failure = Self.failure(for: request.pdfData, document: document)
        let pageLocators = Self.pageLocators(for: document)
        let normalizedTextBlocks = Self.normalizedTextBlocks(from: pageLocators)
        let extractionQuality = Self.extractionQuality(
            failure: failure,
            pageLocators: pageLocators,
            normalizedTextBlocks: normalizedTextBlocks
        )
        let sourceHash = Self.stableSourceHash(pdfData: request.pdfData)
        let sourceState = Self.conservativeSourceState(
            original: request.importCandidate.sourceState,
            extractionQuality: extractionQuality,
            failure: failure
        )
        let freshnessState = Self.conservativeFreshnessState(
            original: request.importCandidate.freshnessState,
            extractionQuality: extractionQuality,
            failure: failure
        )
        let provenanceState = request.importCandidate.provenanceState
        let reviewState = HumanProgressReviewState.needsPrivacyReview
        let privacyClass = request.importCandidate.privacyClass
        let sourceKind = request.importCandidate.sourceKind
        let title = request.title ?? request.importCandidate.title ?? "PDF text needs review"
        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: title,
            kind: .pdf,
            sourceKind: sourceKind,
            locator: request.canonicalLocator ?? request.originalLocator,
            provenanceState: provenanceState,
            extractionState: Self.containerExtractionState(
                extractionQuality: extractionQuality,
                failure: failure
            ),
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            failureState: Self.containerFailureState(
                extractionQuality: extractionQuality,
                failure: failure,
                sourceState: sourceState
            ),
            sourceRecordIDs: request.importCandidate.container.sourceRecordIDs,
            claimIDs: request.importCandidate.container.claimIDs,
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasPDFKitTextExtractionCandidate(
            id: request.id,
            title: title,
            sourceImportCandidateID: request.importCandidate.id,
            originalLocator: request.originalLocator,
            canonicalLocator: request.canonicalLocator,
            pageLocators: pageLocators,
            normalizedTextBlocks: normalizedTextBlocks,
            sourceHash: sourceHash,
            extractionQuality: extractionQuality,
            failure: failure,
            sourceKind: sourceKind,
            provenanceState: provenanceState,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            container: container,
            schemaVersion: sourceAtlasPDFKitTextExtractionSchemaVersion
        )
    }

    private static func failure(
        for pdfData: Data,
        document: PDFDocument?
    ) -> SourceAtlasPDFKitTextExtractionFailure {
        guard pdfData.isEmpty == false else {
            return .emptyData
        }
        guard let document else {
            return .corruptPDF
        }
        if document.isLocked || document.isEncrypted {
            return .lockedOrEncrypted
        }
        return .none
    }

    private static func pageLocators(for document: PDFDocument?) -> [SourceAtlasPDFKitTextExtractionPageLocator] {
        guard let document else {
            return []
        }

        return (0..<document.pageCount).compactMap { pageIndex in
            guard let page = document.page(at: pageIndex) else {
                return SourceAtlasPDFKitTextExtractionPageLocator(pageIndex: pageIndex, text: nil)
            }
            let normalizedText = Self.normalizedPageText(page.string)
            return SourceAtlasPDFKitTextExtractionPageLocator(pageIndex: pageIndex, text: normalizedText)
        }
    }

    private static func normalizedPageText(_ text: String?) -> String? {
        guard let text else {
            return nil
        }
        let normalizedBlocks = normalizedTextBlocks(from: text)
        guard normalizedBlocks.isEmpty == false else {
            return nil
        }
        return normalizedBlocks.joined(separator: "\n")
    }

    private static func normalizedTextBlocks(from pageLocators: [SourceAtlasPDFKitTextExtractionPageLocator]) -> [String] {
        var seen: Set<String> = []
        return pageLocators.flatMap { locator in
            normalizedTextBlocks(from: locator.text ?? "").filter { seen.insert($0).inserted }
        }
    }

    private static func normalizedTextBlocks(from text: String) -> [String] {
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

        return blocks
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

    private static func extractionQuality(
        failure: SourceAtlasPDFKitTextExtractionFailure,
        pageLocators: [SourceAtlasPDFKitTextExtractionPageLocator],
        normalizedTextBlocks: [String]
    ) -> SourceAtlasPDFKitTextExtractionQuality {
        guard failure == .none else {
            return .failed
        }
        guard pageLocators.isEmpty == false else {
            return .noText
        }
        let pagesWithText = pageLocators.filter { $0.text != nil }.count
        guard pagesWithText > 0 else {
            return .noText
        }
        guard pagesWithText == pageLocators.count else {
            return .partial
        }
        return normalizedTextBlocks.isEmpty ? .noText : .normalizedTextBlocks
    }

    private static func conservativeSourceState(
        original: SourceAtlasRequirementSourceState,
        extractionQuality: SourceAtlasPDFKitTextExtractionQuality,
        failure: SourceAtlasPDFKitTextExtractionFailure
    ) -> SourceAtlasRequirementSourceState {
        switch original {
        case .official, .officialCurrent, .current:
            return .sourceNeeded
        case .unknown, .sourceNeeded, .stale, .contradicted, .revoked, .locallyProven:
            return original
        }
    }

    private static func conservativeFreshnessState(
        original: SourceAtlasFreshnessState,
        extractionQuality: SourceAtlasPDFKitTextExtractionQuality,
        failure: SourceAtlasPDFKitTextExtractionFailure
    ) -> SourceAtlasFreshnessState {
        switch original {
        case .current:
            return .needsReview
        case .aging, .stale, .staleCritical, .sourceChanged, .disputed, .revoked, .unknown, .userProvided, .needsReview:
            return original
        }
    }

    private static func containerExtractionState(
        extractionQuality: SourceAtlasPDFKitTextExtractionQuality,
        failure: SourceAtlasPDFKitTextExtractionFailure
    ) -> SourceAtlasSourceContainerExtractionState {
        switch (failure, extractionQuality) {
        case (.none, .normalizedTextBlocks):
            return .textExtracted
        case (.none, .partial):
            return .textExtracted
        case (.none, .noText):
            return .extractionFailed
        case (.none, .failed):
            return .sourceLinked
        case (.emptyData, _), (.corruptPDF, _), (.lockedOrEncrypted, _):
            return .extractionFailed
        }
    }

    private static func containerFailureState(
        extractionQuality: SourceAtlasPDFKitTextExtractionQuality,
        failure: SourceAtlasPDFKitTextExtractionFailure,
        sourceState: SourceAtlasRequirementSourceState
    ) -> SourceAtlasSourceContainerFailureState {
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
            break
        }

        switch failure {
        case .emptyData:
            return .sourceMissing
        case .lockedOrEncrypted:
            return .inaccessible
        case .corruptPDF:
            return .extractionFailed
        case .none:
            switch extractionQuality {
            case .normalizedTextBlocks:
                return .none
            case .partial, .noText:
                return .extractionFailed
            case .failed:
                return .extractionFailed
            }
        }
    }

    private static func stableSourceHash(pdfData: Data) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in pdfData {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}
