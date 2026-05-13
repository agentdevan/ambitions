import XCTest
@testable import Ambitions

final class SourceAtlasPlainTextImporterModelsTests: XCTestCase {
    func testCopiedTextDefaultsToUserProvidedSourceNeededAndReviewRequired() {
        let candidate = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                title: " Program page excerpt ",
                originalText: "Applicants must submit proof by the published deadline."
            )
        )

        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.provenanceState, .copiedContent)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertEqual(candidate.freshnessState, .unknown)
        XCTAssertEqual(candidate.reviewState, .needsSourceReview)
        XCTAssertEqual(candidate.privacyClass, .privateLife)
        XCTAssertEqual(candidate.sourceCategory, .possibleRequirement)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertEqual(candidate.container.kind, .plainText)
        XCTAssertEqual(candidate.container.sourceKind, .userProvided)
        XCTAssertEqual(candidate.container.provenanceState, .copiedContent)
        XCTAssertEqual(candidate.container.extractionState, .copiedText)
        XCTAssertEqual(candidate.container.reviewState, .needsSourceReview)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
    }

    func testNormalizationDedupingAndGeneratedHashAreDeterministic() {
        let request = Self.request(
            originalText: """
             First   copied
             block.

             First copied block.

             Second block has   spacing.
            """
        )

        let first = SourceAtlasPlainTextImporter().importPlainText(request)
        let second = SourceAtlasPlainTextImporter().importPlainText(request)

        XCTAssertEqual(first.normalizedTextBlocks, ["First copied block.", "Second block has spacing."])
        XCTAssertEqual(first.extractionQuality, .normalizedTextBlocks)
        XCTAssertEqual(first.sourceHash, second.sourceHash)
        XCTAssertTrue(first.sourceHash.hasPrefix("fnv1a64:"))
    }

    func testManualEntryClassifiesAsPersonalNoteWithoutBecomingMutationReady() {
        let candidate = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "I may want to compare two certification paths later.",
                channel: .manualEntry
            )
        )

        XCTAssertEqual(candidate.sourceCategory, .personalNote)
        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
    }

    func testSuppliedSourceHashIsUsedWithoutTreatingTextAsOfficial() {
        let candidate = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "Copied text that still needs a source review.",
                suppliedSourceHash: "sha256:owner-supplied"
            )
        )

        XCTAssertEqual(candidate.sourceHash, "sha256:owner-supplied")
        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertTrue(candidate.requiresReview)
    }

    func testEmptyTooShortAndUnsupportedInputsFallBackToSourceNeeded() {
        let empty = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(originalText: "   \n\n ")
        )
        let tooShort = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(originalText: "short")
        )
        let unsupported = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "This content is long enough but the kind is unsupported.",
                inputKind: .unsupported
            )
        )

        XCTAssertEqual(empty.failure, .emptyText)
        XCTAssertEqual(empty.extractionQuality, .failed)
        XCTAssertEqual(tooShort.failure, .tooShort)
        XCTAssertEqual(tooShort.extractionQuality, .tooShort)
        XCTAssertEqual(unsupported.failure, .unsupportedInputKind)
        XCTAssertEqual(unsupported.sourceCategory, .unsupported)
        XCTAssertEqual(empty.container.failureState, .sourceMissing)
        XCTAssertEqual(tooShort.container.failureState, .sourceMissing)
        XCTAssertEqual(unsupported.container.failureState, .unsupportedFormat)
        XCTAssertTrue([empty, tooShort, unsupported].allSatisfy { $0.sourceState == .sourceNeeded })
        XCTAssertTrue([empty, tooShort, unsupported].allSatisfy { $0.fallbackReason == .sourceNeeded })
        XCTAssertTrue([empty, tooShort, unsupported].allSatisfy(\.requiresReview))
    }

    func testOfficialOrCurrentDeclaredStatesAreDowngradedToSourceNeeded() {
        let officialStates: [SourceAtlasRequirementSourceState] = [
            .official,
            .officialCurrent,
            .current
        ]

        for state in officialStates {
            let candidate = SourceAtlasPlainTextImporter().importPlainText(
                Self.request(
                    originalText: "Copied requirement text cannot certify official current state.",
                    declaredSourceState: state,
                    declaredFreshnessState: .current
                )
            )

            XCTAssertEqual(candidate.sourceState, .sourceNeeded)
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
            let candidate = SourceAtlasPlainTextImporter().importPlainText(
                Self.request(
                    originalText: "Copied source text preserves explicit state boundaries.",
                    declaredSourceState: state
                )
            )

            XCTAssertEqual(candidate.sourceState, state)
            XCTAssertTrue(candidate.requiresReview)
            XCTAssertFalse(candidate.canMutateWithoutReview)
        }
    }

    func testStaleContradictedAndRevokedStatesBlockCurrentUse() {
        let stale = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "Copied source text may be stale and must be reviewed.",
                declaredSourceState: .stale
            )
        )
        let contradicted = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "Copied source text may be contradicted and must be reviewed.",
                declaredSourceState: .contradicted
            )
        )
        let revoked = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "Copied source text may be revoked and must be reviewed.",
                declaredSourceState: .revoked
            )
        )

        XCTAssertEqual(stale.container.failureState, .stale)
        XCTAssertEqual(contradicted.container.failureState, .contradicted)
        XCTAssertEqual(revoked.container.failureState, .revoked)
        XCTAssertTrue([stale, contradicted, revoked].allSatisfy { $0.container.blocksCurrentUse })
    }

    func testPlainTextDowngradesCurrentFreshnessAndNeverSupportsOfficialCurrentClaim() {
        let candidate = SourceAtlasPlainTextImporter().importPlainText(
            Self.request(
                originalText: "Copied text has local proof only and still needs source review.",
                declaredSourceState: .locallyProven,
                declaredFreshnessState: .current
            )
        )

        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertEqual(candidate.fallbackReason, .reviewRequired)
        XCTAssertEqual(candidate.freshnessState, .needsReview)
        XCTAssertEqual(candidate.container.freshnessState, .needsReview)
    }

    func testDistinctStaleContradictedRevokedUnknownAndUserProvidedFreshnessStatesArePreserved() {
        let states: [SourceAtlasFreshnessState] = [
            .unknown,
            .userProvided,
            .needsReview,
            .aging,
            .stale,
            .staleCritical,
            .sourceChanged,
            .disputed,
            .revoked
        ]

        for state in states {
            let candidate = SourceAtlasPlainTextImporter().importPlainText(
                Self.request(
                    originalText: "Copied text preserves conservative freshness boundaries.",
                    declaredFreshnessState: state
                )
            )

            XCTAssertEqual(candidate.freshnessState, state)
            XCTAssertEqual(candidate.container.freshnessState, state)
            XCTAssertTrue(candidate.requiresReview)
        }
    }
}

private extension SourceAtlasPlainTextImporterModelsTests {
    static func request(
        id: String = "plain-text-import",
        title: String? = nil,
        originalText: String,
        channel: SourceAtlasPlainTextImportChannel = .pasteboard,
        inputKind: SourceAtlasPlainTextInputKind = .plainText,
        declaredSourceCategory: SourceAtlasPlainTextSourceCategory? = nil,
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) -> SourceAtlasPlainTextImportRequest {
        SourceAtlasPlainTextImportRequest(
            id: id,
            title: title,
            originalText: originalText,
            channel: channel,
            inputKind: inputKind,
            declaredSourceCategory: declaredSourceCategory,
            suppliedSourceHash: suppliedSourceHash,
            declaredSourceState: declaredSourceState,
            declaredFreshnessState: declaredFreshnessState,
            createdAt: "2026-05-13T15:22:39Z",
            updatedAt: "2026-05-13T15:22:39Z"
        )
    }
}
