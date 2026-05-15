import XCTest
@testable import Ambitions

final class SourceAtlasVisionOCRFallbackModelsTests: XCTestCase {
    func testOCRFallbackDefaultsToUserProvidedSourceNeededAndPrivacyReviewRequired() {
        let candidate = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/scanned-guide.pdf",
                title: " Scanned Guide ",
                inputKind: .scannedPDF,
                pageLocators: [
                    SourceAtlasVisionOCRPageLocator(pageIndex: 0, text: "Page 1")
                ],
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "page:1",
                        text: "  First page  OCR text. ",
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
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertEqual(candidate.container.kind, .pdf)
        XCTAssertEqual(candidate.container.provenanceState, .ocrDerived)
        XCTAssertEqual(candidate.container.extractionState, .ocrDerived)
        XCTAssertEqual(candidate.container.reviewState, .needsPrivacyReview)
        XCTAssertEqual(candidate.container.privacyClass, .sensitive)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
    }

    func testNormalizedTextBlocksPageAndImageLocatorsAndGeneratedHashAreDeterministic() {
        let request = Self.request(
            originalLocator: "https://example.com/scanned-image.png",
            canonicalLocator: "https://cdn.example.com/scanned-image.png",
            inputKind: .image,
            pageLocators: [
                SourceAtlasVisionOCRPageLocator(pageIndex: 0, text: "Ignored for images")
            ],
            imageLocators: [
                SourceAtlasVisionOCRImageLocator(imageIndex: 0, text: " Image 1 "),
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
            ]
        )

        let first = SourceAtlasVisionOCRFallback().fallbackOCR(request)
        let second = SourceAtlasVisionOCRFallback().fallbackOCR(request)

        XCTAssertEqual(first.normalizedTextBlocks, ["First OCR block.", "Second OCR block."])
        XCTAssertEqual(first.pageLocators.count, 1)
        XCTAssertEqual(first.imageLocators.count, 2)
        XCTAssertEqual(first.imageLocators.first?.locator, "image:1")
        XCTAssertEqual(first.imageLocators.last?.text, "Image 2")
        XCTAssertEqual(first.ocrQualityLabels, [.highConfidence, .lowConfidence])
        XCTAssertEqual(first.extractionQuality, .partial)
        XCTAssertEqual(first.sourceHash, second.sourceHash)
        XCTAssertTrue(first.sourceHash.hasPrefix("fnv1a64:"))
    }

    func testSuppliedSourceHashIsUsedWithoutTreatingOCRAsOfficial() {
        let candidate = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "https://example.com/scanned-source.png",
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Owner-supplied OCR text.",
                        qualityLabel: .highConfidence
                    )
                ],
                suppliedSourceHash: "sha256:owner-supplied"
            )
        )

        XCTAssertEqual(candidate.sourceHash, "sha256:owner-supplied")
        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertTrue(candidate.requiresReview)
    }

    func testUnsupportedInputAndNoTextFallbackToConservativeFailures() {
        let unsupported = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/unsupported.ocr",
                inputKind: .unsupported,
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Unsupported input kind.",
                        qualityLabel: .failed
                    )
                ]
            )
        )
        let noText = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/no-text.pdf",
                inputKind: .scannedPDF,
                pageLocators: [
                    SourceAtlasVisionOCRPageLocator(pageIndex: 0, text: nil)
                ]
            )
        )
        let empty = SourceAtlasVisionOCRFallback().fallbackOCR(
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
            let candidate = SourceAtlasVisionOCRFallback().fallbackOCR(
                Self.request(
                    originalLocator: "https://example.com/\(state.rawValue).png",
                    textBlocks: [
                        SourceAtlasVisionOCRTextBlock(
                            locator: "image:1",
                            text: "Official-looking OCR text still needs review.",
                            qualityLabel: .highConfidence
                        )
                    ],
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
            let candidate = SourceAtlasVisionOCRFallback().fallbackOCR(
                Self.request(
                    originalLocator: "https://example.com/\(state.rawValue).png",
                    textBlocks: [
                        SourceAtlasVisionOCRTextBlock(
                            locator: "image:1",
                            text: "OCR preserves explicit state boundaries.",
                            qualityLabel: .mediumConfidence
                        )
                    ],
                    declaredSourceState: state
                )
            )

            XCTAssertEqual(candidate.sourceState, state)
            XCTAssertTrue(candidate.requiresReview)
            XCTAssertFalse(candidate.canMutateWithoutReview)
        }
    }

    func testCurrentFreshnessIsDowngradedWhileNonCurrentStatesStayDistinct() {
        let current = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/current.png",
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Current freshness still needs privacy review.",
                        qualityLabel: .highConfidence
                    )
                ],
                declaredFreshnessState: .current
            )
        )
        let stale = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/stale.png",
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Stale OCR text stays stale.",
                        qualityLabel: .mediumConfidence
                    )
                ],
                declaredFreshnessState: .stale
            )
        )
        let unknown = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/unknown.png",
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Unknown freshness stays unknown.",
                        qualityLabel: .mediumConfidence
                    )
                ],
                declaredFreshnessState: .unknown
            )
        )
        let revoked = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/revoked.png",
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Revoked freshness stays revoked.",
                        qualityLabel: .mediumConfidence
                    )
                ],
                declaredFreshnessState: .revoked
            )
        )

        XCTAssertEqual(current.freshnessState, .needsReview)
        XCTAssertEqual(stale.freshnessState, .stale)
        XCTAssertEqual(unknown.freshnessState, .unknown)
        XCTAssertEqual(revoked.freshnessState, .revoked)
        XCTAssertTrue([current, stale, unknown, revoked].allSatisfy { $0.canSupportOfficialCurrentClaim == false })
    }

    func testLocallyProvenContainerKeepsLocalProofConservativeState() {
        let candidate = SourceAtlasVisionOCRFallback().fallbackOCR(
            Self.request(
                originalLocator: "/Users/devan/Documents/local-proof.png",
                inputKind: .image,
                textBlocks: [
                    SourceAtlasVisionOCRTextBlock(
                        locator: "image:1",
                        text: "Local proof OCR still needs review.",
                        qualityLabel: .highConfidence
                    )
                ],
                declaredSourceState: .locallyProven,
                declaredFreshnessState: .current
            )
        )

        XCTAssertEqual(candidate.sourceState, .locallyProven)
        XCTAssertEqual(candidate.container.sourceState, .locallyProven)
        XCTAssertEqual(candidate.container.conservativeRequirementSourceState, .sourceNeeded)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
        XCTAssertFalse(candidate.container.canSupportLocalProofClaim)
    }
}

private extension SourceAtlasVisionOCRFallbackModelsTests {
    static func request(
        originalLocator: String,
        title: String? = "OCR needs review",
        canonicalLocator: String? = nil,
        inputKind: SourceAtlasVisionOCRInputKind = .unknown,
        pageLocators: [SourceAtlasVisionOCRPageLocator] = [],
        imageLocators: [SourceAtlasVisionOCRImageLocator] = [],
        textBlocks: [SourceAtlasVisionOCRTextBlock] = [],
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) -> SourceAtlasVisionOCRFallbackRequest {
        SourceAtlasVisionOCRFallbackRequest(
            id: "ocr-fallback-\(originalLocator.hashValue)",
            title: title,
            originalLocator: originalLocator,
            canonicalLocator: canonicalLocator,
            inputKind: inputKind,
            pageLocators: pageLocators,
            imageLocators: imageLocators,
            textBlocks: textBlocks,
            suppliedSourceHash: suppliedSourceHash,
            declaredSourceState: declaredSourceState,
            declaredFreshnessState: declaredFreshnessState,
            createdAt: "2026-05-15T02:51:34Z",
            updatedAt: "2026-05-15T02:51:34Z"
        )
    }
}
