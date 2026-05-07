import XCTest
@testable import Ambitions

final class AmbitionsOSAlternatePathModelsTests: XCTestCase {
    func testReviewReadyPortfolioRoundTripsWithActiveAndAlternatePath() throws {
        let portfolio = pathPortfolio(
            paths: [
                Self.path(id: "path.active", kind: .activePath),
                Self.path(
                    id: "path.alternate",
                    title: "Adjacent path",
                    kind: .alternatePath,
                    transferableProofReceiptIDs: ["proof.practice"],
                    requirementOverlapIDs: ["requirement.practice"],
                    sourceClaimIDs: ["claim.practice"]
                )
            ]
        )

        let data = try JSONEncoder().encode(portfolio)
        let decoded = try JSONDecoder().decode(AmbitionsOSPathPortfolio.self, from: data)

        XCTAssertEqual(decoded, portfolio)
        XCTAssertTrue(decoded.validationIssues.isEmpty)
        XCTAssertEqual(decoded.reviewState, .reviewReady)
    }

    func testInvalidSchemaAndMalformedPortfolioAreRejected() {
        let portfolio = pathPortfolio(
            id: "",
            title: "",
            startingPositionSnapshotID: "",
            compiledGoalCandidateID: "",
            paths: [
                Self.path(id: "", title: "", kind: .alternatePath, summary: "", schemaVersion: "future")
            ],
            schemaVersion: "future"
        )

        let issues = portfolio.validationIssues

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPortfolio))
        XCTAssertTrue(issues.contains(.malformedPath))
        XCTAssertTrue(issues.contains(.missingStartingPosition))
        XCTAssertTrue(issues.contains(.missingCompiledGoalCandidate))
    }

    func testPortfolioRequiresActiveAndAlternativePaths() {
        let onlyActive = pathPortfolio(paths: [Self.path(kind: .activePath)])
        let onlyAlternative = pathPortfolio(paths: [Self.path(kind: .backupPath)])

        XCTAssertTrue(onlyActive.validationIssues.contains(.missingAlternativePath))
        XCTAssertTrue(onlyAlternative.validationIssues.contains(.missingActivePath))
    }

    func testProofTransferRequiresRequirementAndSourceOverlap() {
        let portfolio = pathPortfolio(
            paths: [
                Self.path(kind: .activePath),
                Self.path(
                    id: "path.transfer",
                    kind: .alternatePath,
                    transferableProofReceiptIDs: ["proof.old"]
                )
            ]
        )

        XCTAssertTrue(portfolio.validationIssues.contains(.proofTransferWithoutOverlap))
    }

    func testSourceCheckAndProfessionalBoundaryRequireReviewedSourceBackedEvidence() {
        let portfolio = pathPortfolio(
            paths: [
                Self.path(kind: .activePath),
                Self.path(
                    id: "path.source-check",
                    kind: .sourceCheckFirstPath,
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    reviewState: .needsSourceReview,
                    professionalBoundaryApplies: true
                )
            ]
        )

        let issues = portfolio.validationIssues

        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.professionalBoundaryReviewRequired))
        XCTAssertEqual(portfolio.reviewState, .needsSourceReview)
    }

    func testShameLanguageAndGuaranteedOutcomeBlockPortfolio() {
        let portfolio = pathPortfolio(
            paths: [
                Self.path(kind: .activePath),
                Self.path(
                    id: "path.bad-copy",
                    title: "Quit and start over",
                    kind: .fallbackPath,
                    summary: "The old work failed and was wasted.",
                    claimsGuaranteedOutcome: true
                )
            ]
        )

        let issues = portfolio.validationIssues

        XCTAssertTrue(issues.contains(.shameLanguage))
        XCTAssertTrue(issues.contains(.guaranteedOutcomeOverclaim))
        XCTAssertEqual(portfolio.reviewState, .blocked)
    }

    func testPathChangeRequiresReceiptAndDoesNotMutateLifeGraph() {
        let missingReceipt = pathPortfolio(
            paths: [
                Self.path(kind: .activePath),
                Self.path(id: "path.paused", kind: .pausedPath)
            ]
        )
        let withReceipt = pathPortfolio(
            paths: [
                Self.path(kind: .activePath),
                Self.path(id: "path.paused", kind: .pausedPath)
            ],
            pathChangeReceipts: [
                AmbitionsOSPathChangeReceipt(
                    id: "receipt.path-change",
                    fromPathID: "path.active",
                    toPathID: "path.paused",
                    reason: "Pause without losing proof",
                    stillCountsProofReceiptIDs: ["proof.practice"]
                )
            ]
        )

        XCTAssertTrue(missingReceipt.validationIssues.contains(.missingPathChangeReceipt))
        XCTAssertFalse(withReceipt.validationIssues.contains(.missingPathChangeReceipt))
        XCTAssertFalse(withReceipt.mutatesLifeGraph)
    }

    func testHiddenMutationRuntimeStoreAndSensitiveProjectionAreBlocked() {
        let portfolio = pathPortfolio(
            paths: [
                Self.path(kind: .activePath),
                Self.path(
                    id: "path.sensitive",
                    kind: .alternatePath,
                    privacyClass: .sensitive,
                    externalProjectionRequested: true
                )
            ],
            mutatesLifeGraph: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = portfolio.validationIssues

        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.externalProjectionRisk))
    }

    private func pathPortfolio(
        id: String = "portfolio.goal",
        title: String = "Goal Path Portfolio",
        startingPositionSnapshotID: String? = "starting-position.current",
        compiledGoalCandidateID: String? = "compiled-goal.current",
        localGoalPackIDs: [String] = ["pack.local.training"],
        paths: [AmbitionsOSAlternatePathCandidate]? = nil,
        pathChangeReceipts: [AmbitionsOSPathChangeReceipt] = [],
        preservesNorthStar: Bool = true,
        mutatesLifeGraph: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSAlternatePathSchemaVersion
    ) -> AmbitionsOSPathPortfolio {
        AmbitionsOSPathPortfolio(
            id: id,
            title: title,
            startingPositionSnapshotID: startingPositionSnapshotID,
            compiledGoalCandidateID: compiledGoalCandidateID,
            localGoalPackIDs: localGoalPackIDs,
            paths: paths ?? [Self.path(kind: .activePath), Self.path(id: "path.alternate", kind: .alternatePath)],
            pathChangeReceipts: pathChangeReceipts,
            preservesNorthStar: preservesNorthStar,
            mutatesLifeGraph: mutatesLifeGraph,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    private static func path(
        id: String = "path.active",
        title: String = "Current path",
        kind: AmbitionsOSAlternatePathKind,
        summary: String = "Keep this path available for review.",
        requirementSlotIDs: [String] = ["requirement.practice"],
        transferableProofReceiptIDs: [String] = [],
        requirementOverlapIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        professionalBoundaryApplies: Bool = false,
        claimsGuaranteedOutcome: Bool = false,
        externalProjectionRequested: Bool = false,
        schemaVersion: String = ambitionsOSAlternatePathSchemaVersion
    ) -> AmbitionsOSAlternatePathCandidate {
        AmbitionsOSAlternatePathCandidate(
            id: id,
            title: title,
            kind: kind,
            summary: summary,
            requirementSlotIDs: requirementSlotIDs,
            transferableProofReceiptIDs: transferableProofReceiptIDs,
            requirementOverlapIDs: requirementOverlapIDs,
            sourceClaimIDs: sourceClaimIDs,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            professionalBoundaryApplies: professionalBoundaryApplies,
            claimsGuaranteedOutcome: claimsGuaranteedOutcome,
            externalProjectionRequested: externalProjectionRequested,
            schemaVersion: schemaVersion
        )
    }
}
