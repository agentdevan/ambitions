import XCTest
@testable import Ambitions

final class SourceAtlasURLSourceImporterModelsTests: XCTestCase {
    func testPastedURLDefaultsToUserProvidedSourceNeededAndReviewRequired() {
        let candidate = SourceAtlasURLSourceImporter().importURL(
            Self.request(
                originalURL: " https://example.com/path ",
                pageTitle: " Example Requirement ",
                extractedTextBlocks: [" First block. ", "Second\nblock."]
            )
        )

        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.provenanceState, .userProvided)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertEqual(candidate.freshnessState, .unknown)
        XCTAssertEqual(candidate.reviewState, .needsSourceReview)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertEqual(candidate.container.kind, .url)
        XCTAssertEqual(candidate.container.sourceKind, .userProvided)
        XCTAssertEqual(candidate.container.reviewState, .needsSourceReview)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
    }

    func testCanonicalURLAndContentTypeArePreservedWhenSuppliedAfterRedirect() {
        let candidate = SourceAtlasURLSourceImporter().importURL(
            Self.request(
                originalURL: "https://example.com/redirect",
                canonicalURL: "https://example.org/final.pdf",
                channel: .shareExtension,
                suppliedContentType: .pdf,
                pageTitle: "Final PDF"
            )
        )

        XCTAssertEqual(candidate.originalURL, "https://example.com/redirect")
        XCTAssertEqual(candidate.canonicalURL, "https://example.org/final.pdf")
        XCTAssertEqual(candidate.channel, .shareExtension)
        XCTAssertEqual(candidate.contentType, .pdf)
        XCTAssertEqual(candidate.extractionQuality, .metadataOnly)
        XCTAssertEqual(candidate.failure, .none)
        XCTAssertEqual(candidate.container.locator, "https://example.org/final.pdf")
    }

    func testNormalizedTextBlocksAndGeneratedHashAreDeterministic() {
        let request = Self.request(
            originalURL: "https://example.com/source.html",
            pageTitle: "Source",
            extractedTextBlocks: [
                " First   block\nwith spacing. ",
                "First block with spacing.",
                "Second block."
            ]
        )

        let first = SourceAtlasURLSourceImporter().importURL(request)
        let second = SourceAtlasURLSourceImporter().importURL(request)

        XCTAssertEqual(first.normalizedTextBlocks, ["First block with spacing.", "Second block."])
        XCTAssertEqual(first.extractionQuality, .normalizedTextBlocks)
        XCTAssertEqual(first.sourceHash, second.sourceHash)
        XCTAssertTrue(first.sourceHash.hasPrefix("fnv1a64:"))
    }

    func testSuppliedSourceHashIsUsedWithoutTreatingURLAsOfficial() {
        let candidate = SourceAtlasURLSourceImporter().importURL(
            Self.request(
                originalURL: "https://example.com/source",
                suppliedSourceHash: "sha256:owner-supplied"
            )
        )

        XCTAssertEqual(candidate.sourceHash, "sha256:owner-supplied")
        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertTrue(candidate.requiresReview)
    }

    func testInvalidURLFallsBackToSourceNeededFailureState() {
        let candidate = SourceAtlasURLSourceImporter().importURL(
            Self.request(originalURL: "not a url")
        )

        XCTAssertEqual(candidate.failure, .invalidURL)
        XCTAssertEqual(candidate.extractionQuality, .failed)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertEqual(candidate.fallbackReason, .sourceNeeded)
        XCTAssertEqual(candidate.container.failureState, .sourceMissing)
        XCTAssertTrue(candidate.requiresReview)
    }

    func testUnsupportedSchemeAndUnsupportedContentTypeRemainReviewBlocked() {
        let unsupportedScheme = SourceAtlasURLSourceImporter().importURL(
            Self.request(originalURL: "file:///private/source.html")
        )
        let unsupportedContent = SourceAtlasURLSourceImporter().importURL(
            Self.request(
                originalURL: "https://example.com/source.bin",
                suppliedContentType: .unsupported
            )
        )

        XCTAssertEqual(unsupportedScheme.failure, .unsupportedScheme)
        XCTAssertEqual(unsupportedScheme.container.failureState, .sourceMissing)
        XCTAssertEqual(unsupportedContent.failure, .unsupportedContentType)
        XCTAssertEqual(unsupportedContent.container.failureState, .unsupportedFormat)
        XCTAssertTrue([unsupportedScheme, unsupportedContent].allSatisfy(\.requiresReview))
        XCTAssertTrue([unsupportedScheme, unsupportedContent].allSatisfy { $0.canMutateWithoutReview == false })
    }

    func testOfficialOrCurrentDeclaredStatesAreDowngradedToSourceNeeded() {
        let officialStates: [SourceAtlasRequirementSourceState] = [
            .official,
            .officialCurrent,
            .current
        ]

        for state in officialStates {
            let candidate = SourceAtlasURLSourceImporter().importURL(
                Self.request(
                    originalURL: "https://example.com/\(state.rawValue)",
                    declaredSourceState: state,
                    declaredFreshnessState: .current
                )
            )

            XCTAssertEqual(candidate.sourceState, .sourceNeeded)
            XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
            XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
        }
    }

    func testDistinctUnknownStaleContradictedRevokedAndLocalProofStatesArePreserved() {
        let states: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked,
            .locallyProven
        ]

        for state in states {
            let candidate = SourceAtlasURLSourceImporter().importURL(
                Self.request(
                    originalURL: "https://example.com/\(state.rawValue)",
                    declaredSourceState: state
                )
            )

            XCTAssertEqual(candidate.sourceState, state)
            XCTAssertTrue(candidate.requiresReview)
            XCTAssertFalse(candidate.canMutateWithoutReview)
        }
    }
}

private extension SourceAtlasURLSourceImporterModelsTests {
    static func request(
        originalURL: String,
        canonicalURL: String? = nil,
        channel: SourceAtlasURLImportChannel = .pasted,
        suppliedContentType: SourceAtlasURLImportContentType? = nil,
        pageTitle: String? = nil,
        extractedTextBlocks: [String] = [],
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) -> SourceAtlasURLImportRequest {
        SourceAtlasURLImportRequest(
            id: "url-import-\(originalURL.hashValue)",
            originalURL: originalURL,
            canonicalURL: canonicalURL,
            channel: channel,
            suppliedContentType: suppliedContentType,
            pageTitle: pageTitle,
            extractedTextBlocks: extractedTextBlocks,
            suppliedSourceHash: suppliedSourceHash,
            declaredSourceState: declaredSourceState,
            declaredFreshnessState: declaredFreshnessState,
            createdAt: "2026-05-13T12:05:57Z",
            updatedAt: "2026-05-13T12:05:57Z"
        )
    }
}
