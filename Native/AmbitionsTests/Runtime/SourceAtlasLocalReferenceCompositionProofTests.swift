import XCTest
@testable import Ambitions

final class SourceAtlasLocalReferenceCompositionProofTests: XCTestCase {
    func testProductionR2PackBuildsLocalOnlySourceInspectionWithoutPlanningClaims() throws {
        let fetchResolution = try Self.productionFetchResolution()
        let cacheResolution = try XCTUnwrap(fetchResolution.cacheResolution)

        let proof = SourceAtlasLocalReferenceCompositionProofBuilder().make(
            SourceAtlasLocalReferenceCompositionInput(
                cacheResolution: cacheResolution,
                fetchResolution: fetchResolution,
                localMatchLabel: "Matched occupation foundation locally",
                publicEntityLabel: "Occupation foundation public reference"
            )
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)
        let encoded = try Self.encodedJSONString(proof) + Self.presentationText(presentation)

        XCTAssertEqual(fetchResolution.status, .accepted)
        XCTAssertEqual(fetchResolution.egressFindings, [])
        XCTAssertEqual(cacheResolution.loadResult.selectedSource, .cached)
        XCTAssertEqual(proof.state, .current)
        XCTAssertEqual(proof.packID, Self.productionPackID)
        XCTAssertEqual(proof.domainID, "occupation_foundation")
        XCTAssertEqual(proof.localOnlyMatchingStatement, "Matched locally on this device.")
        XCTAssertTrue(proof.runtimeOwnsFitTimingPriorityProof)
        XCTAssertFalse(proof.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(proof.createsFinalSchedule)
        XCTAssertFalse(proof.blocksCoreLocalPlanning)
        XCTAssertEqual(proof.issues, [])
        XCTAssertEqual(presentation.state, .current)
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
        XCTAssertEqual(Self.privateEgressFindings(in: proof), [])
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("final user plan"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("final schedule"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("Step generator"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("goal_text"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("private_graph"))
    }

    func testCurrentPublicReferenceBuildsLocalOnlyInspectionProof() throws {
        let resolution = try Self.cacheResolution(
            pack: Self.pack(),
            query: SourceAtlasQuery(domainID: "sports")
        )

        let proof = SourceAtlasLocalReferenceCompositionProofBuilder().make(
            SourceAtlasLocalReferenceCompositionInput(
                cacheResolution: resolution,
                localMatchLabel: "Matched a public sports rule",
                publicEntityLabel: "Public sports rule"
            )
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)

        XCTAssertEqual(proof.state, .current)
        XCTAssertEqual(proof.packID, "pack.current")
        XCTAssertEqual(proof.sourceName, "Official rules")
        XCTAssertEqual(proof.referenceTitle, "Use current public rule")
        XCTAssertEqual(proof.localOnlyMatchingStatement, "Matched locally on this device.")
        XCTAssertTrue(proof.runtimeOwnsFitTimingPriorityProof)
        XCTAssertFalse(proof.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(proof.createsFinalSchedule)
        XCTAssertFalse(proof.blocksCoreLocalPlanning)
        XCTAssertEqual(proof.issues, [])
        XCTAssertEqual(presentation.state, .current)
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
        XCTAssertEqual(Self.privateEgressFindings(in: proof), [])
    }

    func testPrivateLocalMatchTextIsRedactedBeforeProofOrInspection() throws {
        let resolution = try Self.cacheResolution(
            pack: Self.pack(),
            query: SourceAtlasQuery(domainID: "sports")
        )

        let proof = SourceAtlasLocalReferenceCompositionProofBuilder().make(
            SourceAtlasLocalReferenceCompositionInput(
                cacheResolution: resolution,
                localMatchLabel: "goal_text: make the team",
                publicEntityLabel: "personal_context: roster history"
            )
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)
        let encoded = try Self.encodedJSONString(proof) + Self.presentationText(presentation)

        XCTAssertEqual(proof.localMatchLabel, "Matched locally on this device")
        XCTAssertEqual(proof.publicEntityLabel, "Public reference")
        XCTAssertTrue(proof.issues.contains(.privateLocalMatchRedacted))
        XCTAssertTrue(proof.issues.contains(.privatePublicEntityRedacted))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("make the team"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("roster history"))
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
        XCTAssertEqual(Self.privateEgressFindings(in: proof), [])
    }

    func testLastKnownGoodMapsToStaleInspectionWithoutCurrentUseClaim() throws {
        let currentPack = Self.pack(id: "pack.current")
        let lastKnownGood = Self.pack(id: "pack.last-known-good")
        let currentEntry = try Self.entry(for: currentPack)
        let lastKnownGoodEntry = try Self.entry(for: lastKnownGood)
        let entry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: ["previous": lastKnownGoodEntry.currentSHA256]
        )
        let resolution = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.runtimeArtifact(
                    manifestVersionID: "manifest.v1",
                    entry: entry,
                    channel: "stable",
                    artifactVersionID: "public-reference",
                    sourceState: .officialCurrent,
                    freshnessState: .current
                ),
                lastKnownGoodPayload: try Self.payload(for: lastKnownGood, source: .lastKnownGood),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        let proof = SourceAtlasLocalReferenceCompositionProofBuilder().make(
            SourceAtlasLocalReferenceCompositionInput(
                cacheResolution: resolution,
                localMatchLabel: "Matched public sports rule"
            )
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)

        XCTAssertEqual(proof.state, .stale)
        XCTAssertTrue(proof.issues.contains(.localFallbackUsed))
        XCTAssertTrue(proof.caveats.contains("Using last verified public reference."))
        XCTAssertFalse(proof.blocksCoreLocalPlanning)
        XCTAssertEqual(presentation.state, .stale)
        XCTAssertFalse(presentation.state.blocksCurrentUse)
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
    }

    func testRevokedManifestMapsToBlockedSourceInspectionAndLocalPlanningContinues() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let revokedEntry = SourceAtlasFreshnessPackEntry(
            packID: entry.packID,
            currentSHA256: entry.currentSHA256,
            currentSignature: "signature",
            claimStateBuckets: [
                SourceAtlasFreshnessBrokerClaimStateBucket(
                    state: .revoked,
                    claimIDs: ["claim.current"]
                )
            ]
        )
        let resolution = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: revokedEntry),
                request: SourceAtlasPublicPackRequest.runtimeArtifact(
                    manifestVersionID: "manifest.v1",
                    entry: revokedEntry,
                    channel: "stable",
                    artifactVersionID: "public-reference",
                    sourceState: .officialCurrent,
                    freshnessState: .current
                ),
                cachedPayload: try Self.payload(for: pack, source: .cached),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        let proof = SourceAtlasLocalReferenceCompositionProofBuilder().make(
            SourceAtlasLocalReferenceCompositionInput(
                cacheResolution: resolution,
                localMatchLabel: "Matched public sports rule"
            )
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)

        XCTAssertEqual(proof.state, .revoked)
        XCTAssertTrue(proof.issues.contains(.sourceBlocked))
        XCTAssertTrue(proof.issues.contains(.noEligiblePublicReference))
        XCTAssertFalse(proof.blocksCoreLocalPlanning)
        XCTAssertEqual(presentation.state, .revoked)
        XCTAssertTrue(presentation.state.blocksCurrentUse)
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
    }

    func testReviewRequiredReferenceMapsToReviewInspection() throws {
        let reviewPack = Self.pack(reviewState: .required)
        let resolution = try Self.cacheResolution(
            pack: reviewPack,
            query: SourceAtlasQuery(domainID: "sports")
        )

        let proof = SourceAtlasLocalReferenceCompositionProofBuilder().make(
            SourceAtlasLocalReferenceCompositionInput(
                cacheResolution: resolution,
                localMatchLabel: "Matched public sports rule"
            )
        )
        let presentation = SourceInspectionPresentation.make(localReferenceProof: proof)

        XCTAssertEqual(proof.state, .reviewRequired)
        XCTAssertTrue(proof.issues.contains(.sourceReviewRequired))
        XCTAssertFalse(proof.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(proof.createsFinalSchedule)
        XCTAssertEqual(presentation.state, .reviewRequired)
        XCTAssertTrue(presentation.subtitle.localizedCaseInsensitiveContains("review"))
        XCTAssertEqual(SourceInspectionCopyAudit.validate(presentation), [])
    }
}

private extension SourceAtlasLocalReferenceCompositionProofTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
    static let productionPackID = "source-atlas/v1/domain/occupation_foundation/20260628T000000Z"

    static func productionFetchResolution() throws -> SourceAtlasPublicPackFetchResolution {
        let root = repoRoot()
        let packRoot = root.appendingPathComponent("tools/source-atlas/generated/pack-production/train-28-stable-approval-gate")
        let publisherRoot = root.appendingPathComponent("tools/source-atlas/generated/r2-publisher/train-29-production-remote-r2")
        let currentPointerData = try Data(contentsOf: publisherRoot.appendingPathComponent("current-pointer.json"))
        let manifestData = try Data(contentsOf: packRoot.appendingPathComponent("manifest.json"))
        let revocationData = try Data(contentsOf: packRoot.appendingPathComponent("revocations.json"))
        let lkgData = try Data(contentsOf: packRoot.appendingPathComponent("lkg.json"))
        let packData = try Data(contentsOf: packRoot.appendingPathComponent("pack.json"))

        return SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: SourceAtlasPublicManifestRequest(
                    domainID: "occupation_foundation",
                    channel: "stable",
                    schemaVersion: "1.0.0",
                    appVersion: "1.0",
                    publicLocale: "en-US"
                ),
                targetPackID: productionPackID,
                fetchedCurrentPointerData: currentPointerData,
                fetchedManifestData: manifestData,
                fetchedRevocationManifestData: revocationData,
                fetchedLastKnownGoodPointerData: lkgData,
                fetchedLastKnownGoodManifestData: manifestData,
                downloadedPackData: packData,
                accessDecision: SourceAtlasAccessBoundary().resolve(
                    SourceAtlasAccessRequest(
                        artifactTier: .publicFreshness,
                        accountSessionState: .noAccount,
                        entitlementState: .bundledOnly,
                        networkReachability: .online,
                        cachedPublicArtifactAvailable: false,
                        bundledPublicArtifactAvailable: false
                    )
                ),
                query: SourceAtlasQuery(domainID: "occupation_foundation"),
                checkedAt: checkedAt
            )
        )
    }

    static func cacheResolution(
        pack: SourceAtlasPack,
        query: SourceAtlasQuery
    ) throws -> SourceAtlasLocalPackCacheResolution {
        let entry = try entry(for: pack)
        return SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.runtimeArtifact(
                    manifestVersionID: "manifest.v1",
                    entry: entry,
                    channel: "stable",
                    artifactVersionID: "public-reference",
                    sourceState: .officialCurrent,
                    freshnessState: .current
                ),
                cachedPayload: try payload(for: pack, source: .cached),
                query: query,
                checkedAt: checkedAt
            )
        )
    }

    static func manifest(entry: SourceAtlasFreshnessPackEntry) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "manifest.v1",
            publishedAt: checkedAt,
            packIndex: [entry]
        )
    }

    static func entry(for pack: SourceAtlasPack) throws -> SourceAtlasFreshnessPackEntry {
        let data = try encoded(pack)
        return SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: SourceAtlasStore.sha256Hex(for: data),
            currentSignature: "signature"
        )
    }

    static func payload(
        for pack: SourceAtlasPack,
        source: SourceAtlasStorePayloadSource
    ) throws -> SourceAtlasStorePayload {
        let data = try encoded(pack)
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    static func encodedJSONString<T: Encodable>(_ value: T) throws -> String {
        String(data: try encoded(value), encoding: .utf8) ?? ""
    }

    static func privateEgressFindings(
        in proof: SourceAtlasLocalReferenceCompositionProof
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let values = [
            proof.sourceName,
            proof.sourceKind,
            proof.referenceTitle,
            proof.retrievedLabel,
            proof.freshnessLabel,
            proof.useLabel,
            proof.localMatchLabel,
            proof.publicEntityLabel,
            proof.localOnlyMatchingStatement,
            proof.nonClaim
        ] + proof.caveats
        return SourceAtlasNoPrivateGraphEgressAudit.validate([
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: proof.id,
                inspectedValue: values.joined(separator: " ")
            )
        ])
    }

    static func presentationText(_ presentation: SourceInspectionPresentation) -> String {
        ([
            presentation.title,
            presentation.subtitle,
            presentation.publicDetail.sourceName,
            presentation.publicDetail.sourceKind,
            presentation.publicDetail.referenceTitle,
            presentation.publicDetail.retrievedLabel,
            presentation.publicDetail.freshnessLabel,
            presentation.publicDetail.useLabel,
            presentation.privacySummary,
            presentation.hiddenByDefaultSummary,
            presentation.accessibilityLabel,
            presentation.accessibilityValue,
            presentation.accessibilityHint,
            presentation.semanticAnnouncement,
            presentation.redactionSummary,
            presentation.reduceMotionSummary
        ] + presentation.contextRows.flatMap { [$0.title, $0.detail] })
            .joined(separator: " ")
    }

    static func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("tools/source-atlas/generated/pack-production/train-28-stable-approval-gate/pack.json")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    static func pack(
        id: String = "pack.current",
        reviewState: SourceAtlasRequirementReviewState = .approved
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: id,
                title: "Public Sports Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: "source.official",
                    title: "Official rules",
                    kind: .official,
                    locator: "https://example.test/rules",
                    retrievedAt: "Checked 2026-06-01",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                )
            ],
            claims: [
                SourceAtlasClaim(
                    id: "claim.current",
                    text: "The public rule is current.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source.official"],
                    reviewRequired: false
                )
            ],
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement.current",
                    claimID: "claim.current",
                    title: "Use current public rule",
                    kind: .hard,
                    required: true,
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: reviewState
                )
            ],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.current",
                    title: "Review public rule",
                    stepCandidateSeed: "Review the public rule.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "starter_goal",
                    requiredPackIDs: [id],
                    projectionProfiles: []
                )
            ],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Planning support only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["node.current"],
                overlayDependencyIDs: ["overlay.current"],
                projectionRecipeIDs: ["projection.current"],
                ownsIndividualGoalPhrase: false
            )
        )
    }
}
