import XCTest
@testable import Ambitions

final class SourceAtlasImageScreenshotImporterModelsTests: XCTestCase {
    func testScreenshotDefaultsToUserProvidedOcrDerivedSensitiveAndReviewRequired() {
        let candidate = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                title: " Screenshot capture ",
                originalLocator: "/Users/devan/Documents/screenshot.png",
                imageLocators: [
                    SourceAtlasVisionOCRImageLocator(imageIndex: 0, text: "screen 1")
                ],
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "  Screenshot text block. ",
                        qualityLabel: .highConfidence
                    )
                ]
            )
        )

        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.provenanceState, .ocrDerived)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertEqual(candidate.freshnessState, .unknown)
        XCTAssertEqual(candidate.reviewState, .needsPrivacyReview)
        XCTAssertEqual(candidate.privacyClass, .sensitive)
        XCTAssertEqual(candidate.manualCorrectionState, .none)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertEqual(candidate.container.kind, .image)
        XCTAssertEqual(candidate.container.sourceKind, .userProvided)
        XCTAssertEqual(candidate.container.provenanceState, .ocrDerived)
        XCTAssertEqual(candidate.container.extractionState, .ocrDerived)
        XCTAssertEqual(candidate.container.reviewState, .needsPrivacyReview)
        XCTAssertEqual(candidate.container.privacyClass, .sensitive)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
    }

    func testNormalizedTextBlocksImageLocatorsManualCorrectionAndGeneratedHashAreDeterministic() {
        let request = Self.request(
            title: "Screenshot metadata",
            originalLocator: "https://example.com/screenshot.png",
            canonicalLocator: "https://cdn.example.com/screenshot-final.png",
            inputKind: .image,
            imageLocators: [
                SourceAtlasVisionOCRImageLocator(imageIndex: 0, text: "Image 1"),
                SourceAtlasVisionOCRImageLocator(imageIndex: 1, text: "Image 2")
            ],
            textBlocks: [
                SourceAtlasVisionOCRTextBlock(
                    locator: "image:1",
                    text: "  First   OCR\nblock. ",
                    qualityLabel: .highConfidence
                ),
                SourceAtlasVisionOCRTextBlock(
                    locator: "image:2",
                    text: "First OCR block.",
                    qualityLabel: .mediumConfidence
                ),
                SourceAtlasVisionOCRTextBlock(
                    locator: "image:3",
                    text: "Second OCR block.",
                    qualityLabel: .lowConfidence
                )
            ],
            manualCorrectionState: .provided,
            manualCorrectionNote: " Updated crop and text order. "
        )

        let first = SourceAtlasImageScreenshotImporter().importImageScreenshot(request)
        let second = SourceAtlasImageScreenshotImporter().importImageScreenshot(request)

        XCTAssertEqual(first.normalizedTextBlocks, ["First OCR block.", "Second OCR block."])
        XCTAssertEqual(first.imageLocators.count, 2)
        XCTAssertEqual(first.imageLocators.first?.locator, "image:1")
        XCTAssertEqual(first.imageLocators.last?.text, "Image 2")
        XCTAssertEqual(first.manualCorrectionState, .provided)
        XCTAssertEqual(first.manualCorrectionNote, "Updated crop and text order.")
        XCTAssertEqual(first.extractionQuality, .partial)
        XCTAssertEqual(first.sourceHash, second.sourceHash)
        XCTAssertTrue(first.sourceHash.hasPrefix("fnv1a64:"))
    }

    func testSuppliedSourceHashIsUsedWithoutTreatingImageAsOfficial() {
        let candidate = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "https://example.com/screenshot-source.png",
                suppliedSourceHash: "sha256:owner-supplied"
            )
        )

        XCTAssertEqual(candidate.sourceHash, "sha256:owner-supplied")
        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertTrue(candidate.requiresReview)
    }

    func testUnsupportedAndNoTextInputsFallBackToSourceNeeded() {
        let unsupported = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "/Users/devan/Documents/unsupported.png",
                inputKind: .unsupported,
                imageLocators: [
                    SourceAtlasVisionOCRImageLocator(imageIndex: 0, text: "Unsupported")
                ]
            )
        )
        let noText = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "/Users/devan/Documents/no-text.png",
                inputKind: .screenshot,
                imageLocators: [
                    SourceAtlasVisionOCRImageLocator(imageIndex: 0, text: "Screenshot locator")
                ]
            )
        )
        let empty = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "   ",
                inputKind: .unknown
            )
        )

        XCTAssertEqual(unsupported.failure, .unsupportedInputKind)
        XCTAssertEqual(unsupported.extractionQuality, .failed)
        XCTAssertEqual(unsupported.fallbackReason, .sourceNeeded)
        XCTAssertEqual(unsupported.container.failureState, .unsupportedFormat)
        XCTAssertEqual(noText.failure, .noText)
        XCTAssertEqual(noText.extractionQuality, .noText)
        XCTAssertEqual(noText.fallbackReason, .sourceNeeded)
        XCTAssertEqual(noText.container.failureState, .sourceMissing)
        XCTAssertEqual(empty.failure, .sourceNeeded)
        XCTAssertEqual(empty.extractionQuality, .failed)
        XCTAssertEqual(empty.container.failureState, .sourceMissing)
        XCTAssertTrue([unsupported, noText, empty].allSatisfy(\.requiresReview))
    }

    func testOfficialOrCurrentDeclaredStatesAreDowngradedToSourceNeeded() {
        let officialStates: [SourceAtlasRequirementSourceState] = [
            .official,
            .officialCurrent,
            .current
        ]

        for state in officialStates {
            let candidate = SourceAtlasImageScreenshotImporter().importImageScreenshot(
                Self.request(
                    originalLocator: "https://example.com/\(state.rawValue).png",
                    declaredSourceState: state,
                    declaredFreshnessState: .current
                )
            )

            XCTAssertEqual(candidate.sourceState, .sourceNeeded)
            XCTAssertEqual(candidate.freshnessState, .needsReview)
            XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
            XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
        }
    }

    func testDistinctUnknownSourceNeededStaleContradictedRevokedAndLocalProofStatesArePreserved() {
        let states: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked,
            .locallyProven
        ]

        for state in states {
            let candidate = SourceAtlasImageScreenshotImporter().importImageScreenshot(
                Self.request(
                    originalLocator: "https://example.com/\(state.rawValue).png",
                    declaredSourceState: state
                )
            )

            XCTAssertEqual(candidate.sourceState, state)
            XCTAssertTrue(candidate.requiresReview)
            XCTAssertFalse(candidate.canMutateWithoutReview)
        }
    }

    func testCurrentFreshnessIsDowngradedWhileNonCurrentStatesStayDistinct() {
        let current = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "/Users/devan/Documents/current.png",
                declaredFreshnessState: .current
            )
        )
        let stale = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "/Users/devan/Documents/stale.png",
                declaredFreshnessState: .stale
            )
        )
        let unknown = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "/Users/devan/Documents/unknown.png",
                declaredFreshnessState: .unknown
            )
        )
        let revoked = SourceAtlasImageScreenshotImporter().importImageScreenshot(
            Self.request(
                originalLocator: "/Users/devan/Documents/revoked.png",
                declaredFreshnessState: .revoked
            )
        )

        XCTAssertEqual(current.freshnessState, .needsReview)
        XCTAssertEqual(stale.freshnessState, .stale)
        XCTAssertEqual(unknown.freshnessState, .unknown)
        XCTAssertEqual(revoked.freshnessState, .revoked)
        XCTAssertTrue([current, stale, unknown, revoked].allSatisfy { $0.canSupportOfficialCurrentClaim == false })
    }
}

private extension SourceAtlasImageScreenshotImporterModelsTests {
    static func request(
        id: String = "image-screenshot-import",
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
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) -> SourceAtlasImageScreenshotImportRequest {
        SourceAtlasImageScreenshotImportRequest(
            id: id,
            title: title,
            originalLocator: originalLocator,
            canonicalLocator: canonicalLocator,
            inputKind: inputKind,
            imageLocators: imageLocators,
            textBlocks: textBlocks,
            manualCorrectionState: manualCorrectionState,
            manualCorrectionNote: manualCorrectionNote,
            suppliedSourceHash: suppliedSourceHash,
            declaredSourceState: declaredSourceState,
            declaredFreshnessState: declaredFreshnessState,
            createdAt: "2026-05-15T03:22:16Z",
            updatedAt: "2026-05-15T03:22:16Z"
        )
    }
}
