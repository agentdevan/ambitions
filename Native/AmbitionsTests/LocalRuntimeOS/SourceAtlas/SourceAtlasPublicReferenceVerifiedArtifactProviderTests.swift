import CryptoKit
import XCTest
@testable import Ambitions

final class SourceAtlasPublicReferenceVerifiedArtifactProviderTests: XCTestCase {
    func testVerifiedBytesReturnTypedEvidenceForExactApprovedONETSlice() throws {
        let fixture = try Self.fixture()

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertEqual(result.failures, [])
        XCTAssertEqual(result.artifact?.pack.manifest.id, "onet-30.3")
        XCTAssertEqual(result.artifact?.evidence.manifestVersionID, "30.3")
        XCTAssertEqual(result.artifact?.evidence.manifestSHA256, fixture.manifestSHA256)
        XCTAssertEqual(result.artifact?.evidence.packSHA256, fixture.packSHA256)
        XCTAssertEqual(result.artifact?.evidence.sourceNativeSubjectID, "15-1252.00")
        XCTAssertEqual(result.artifact?.evidence.predicateIDs, ["occupation.task"])
        XCTAssertEqual(result.artifact?.evidence.sourceIDs, ["onet.database"])
        XCTAssertTrue(result.artifact?.evidence.signatureResult.isVerified == true)
        let publicArtifact = result.artifact?.publicReferencePackArtifact()
        XCTAssertEqual(publicArtifact?.id, "onet-30.3")
        XCTAssertEqual(publicArtifact?.claims.map(\.predicateID), ["occupation.task"])
        XCTAssertEqual(publicArtifact?.claims.map(\.sourceNativeFieldID), ["task-1"])
        XCTAssertEqual(publicArtifact?.claims.map(\.sourceLocator), ["https://www.onetcenter.org/database.html"])
        XCTAssertTrue(publicArtifact?.verificationEvidence.signatureResult.isVerified == true)
    }

    func testEveryExplicitPredicateFieldBindingIsAcceptedAndNoPrefixWildcardIsUsed() throws {
        for predicateID in SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedSourceFieldsByPredicate.keys.sorted() {
            let sourceNativeFieldID = try XCTUnwrap(
                SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedSourceFieldsByPredicate[predicateID]?.first
            )
            let fixture = try Self.fixture(
                predicateID: predicateID,
                sourceNativeFieldID: sourceNativeFieldID
            )

            let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

            XCTAssertEqual(result.failures, [], "Expected explicit binding for \(predicateID) / \(sourceNativeFieldID)")
        }
    }

    func testMissingTrustRootFailsClosed() throws {
        let fixture = try Self.fixture(includeTrustRoot: false)

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.missingTrustRoot])
    }

    func testTamperedPackBytesFailClosedBeforeReturningArtifact() throws {
        let fixture = try Self.fixture(packDataOverride: Data("tampered".utf8))

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertTrue(result.failures.contains(.packHashMismatch))
    }

    func testUnsupportedPredicateFailsClosedAfterCryptographicVerification() throws {
        let fixture = try Self.fixture(predicateID: "occupation.salary")

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.unsupportedPredicate])
        XCTAssertTrue(result.manifestVerification?.isVerified == true)
    }

    func testMissingApprovedArtifactInPublicCacheFailsClosed() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("public-reference-bridge-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let repository = SourceAtlasPublicPackCacheFileRepository(rootDirectory: root)

        let result = try SourceAtlasPublicReferenceVerifiedArtifactProvider().verifiedArtifact(
            in: repository,
            checkedAt: Self.checkedAt,
            ed25519PublicKey: Curve25519.Signing.PrivateKey().publicKey.rawRepresentation
        )

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.missingCachedArtifact])
    }

    func testArtifactReleaseSubjectAndSourceBindingsFailClosedIndependently() throws {
        let cases: [(Fixture, SourceAtlasPublicReferenceVerifiedArtifactFailure)] = [
            (try Self.fixture(packArtifactID: "occupation-foundation"), .unsupportedArtifact),
            (try Self.fixture(packReleaseID: "30.2"), .unsupportedRelease),
            (try Self.fixture(subjectID: "29-1141.00"), .unsupportedSubject),
            (try Self.fixture(sourceID: "bls.oes"), .unsupportedSource)
        ]

        for (fixture, expectedFailure) in cases {
            let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

            XCTAssertNil(result.artifact)
            XCTAssertEqual(result.failures, [expectedFailure])
        }
    }

    func testDuplicateSourceIDsFailClosedAsInvalidPack() throws {
        let fixture = try Self.fixture(duplicateSource: true)

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.invalidPack])
    }

    func testDuplicateClaimIDsFailClosedAsInvalidPack() throws {
        let fixture = try Self.fixture(duplicateClaim: true)

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.invalidPack])
    }

    func testDuplicateRequirementIDsFailClosedAsInvalidPack() throws {
        let fixture = try Self.fixture(duplicateRequirement: true)

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.invalidPack])
    }

    func testNonOfficialClaimFailsClosedBeforePublicElevation() throws {
        let fixture = try Self.fixture(claimState: .maintainerCurated)

        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.failures, [.unsupportedSource])
    }

    func testNonOfficialOrUnapprovedSourceFailsClosedBeforePublicElevation() throws {
        let fixtures = [
            try Self.fixture(sourceKind: .maintainerCurated),
            try Self.fixture(sourceApprovedForOfficialClaims: false)
        ]

        for fixture in fixtures {
            let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)

            XCTAssertNil(result.artifact)
            XCTAssertEqual(result.failures, [.unsupportedSource])
        }
    }

    func testUnapprovedRightsOrSourceNativeFieldFailsClosed() throws {
        let cases = [
            (try Self.fixture(sourceLicenseIdentifier: nil), SourceAtlasPublicReferenceVerifiedArtifactFailure.unsupportedSource),
            (try Self.fixture(sourceLocator: "https://example.com/onet"), .unsupportedSource),
            (try Self.fixture(sourceNativeFieldID: "skill-1"), .unsupportedPredicate),
            (try Self.fixture(sourceNativeFieldID: "task-arbitrary"), .unsupportedPredicate)
        ]

        for (fixture, expectedFailure) in cases {
            let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(fixture.input)
            XCTAssertNil(result.artifact)
            XCTAssertEqual(result.failures, [expectedFailure])
        }
    }

    func testBundleProviderRequiresACompleteSameLoaderResourceSet() async throws {
        let fixture = try Self.fixture()
        let complete = FixtureBundleResourceLoader(resources: fixture.bundleResources)
        let provider = SourceAtlasBundlePublicReferenceVerifiedPackProvider(
            resourceLoaders: [complete],
            now: { Self.checkedAt }
        )

        let artifact = await provider.verifiedSourceAtlasArtifact(matching: nil)

        XCTAssertEqual(artifact?.evidence.packSource, .bundled)
        XCTAssertEqual(artifact?.evidence.manifestSHA256, fixture.manifestSHA256)
        XCTAssertEqual(artifact?.evidence.packSHA256, fixture.packSHA256)
    }

    func testBundleProviderFailsClosedForEachMissingResource() async throws {
        let fixture = try Self.fixture()
        for missingName in fixture.bundleResources.keys {
            var resources = fixture.bundleResources
            resources.removeValue(forKey: missingName)
            let provider = SourceAtlasBundlePublicReferenceVerifiedPackProvider(
                resourceLoaders: [FixtureBundleResourceLoader(resources: resources)],
                now: { Self.checkedAt }
            )

            let artifact = await provider.verifiedSourceAtlasArtifact(matching: nil)

            XCTAssertNil(artifact, "Expected missing resource \(missingName) to fail closed")
        }
    }

    func testBundleProviderDoesNotCombineResourcesAcrossLoaders() async throws {
        let fixture = try Self.fixture()
        let manifestOnly = FixtureBundleResourceLoader(resources: [
            "onet-30.3-manifest.json": fixture.input.manifestData,
            "onet-30.3-ed25519-public-key.txt": fixture.publicKey.base64EncodedData()
        ])
        let packOnly = FixtureBundleResourceLoader(resources: [
            "onet-30.3-pack.json": fixture.packData
        ])
        let provider = SourceAtlasBundlePublicReferenceVerifiedPackProvider(
            resourceLoaders: [manifestOnly, packOnly],
            now: { Self.checkedAt }
        )

        let artifact = await provider.verifiedSourceAtlasArtifact(matching: nil)

        XCTAssertNil(artifact)
    }

    func testBundleProviderWithNoExplicitResourcesIsUnavailable() async {
        let provider = SourceAtlasBundlePublicReferenceVerifiedPackProvider(
            resourceLoaders: [],
            now: { Self.checkedAt }
        )

        let artifact = await provider.verifiedSourceAtlasArtifact(matching: nil)

        XCTAssertNil(artifact)
    }
}

private extension SourceAtlasPublicReferenceVerifiedArtifactProviderTests {
    struct Fixture {
        let input: SourceAtlasPublicReferenceArtifactVerificationInput
        let manifestSHA256: String
        let packSHA256: String
        let packData: Data
        let publicKey: Data

        var bundleResources: [String: Data] {
            [
                "onet-30.3-manifest.json": input.manifestData,
                "onet-30.3-pack.json": packData,
                "onet-30.3-ed25519-public-key.txt": publicKey.base64EncodedData()
            ]
        }
    }

    struct FixturePackConfiguration {
        let predicateID: String
        let artifactID: String
        let releaseID: String
        let subjectID: String
        let sourceID: String
        let sourceKind: SourceAtlasSourceKind
        let sourceApprovedForOfficialClaims: Bool
        let sourceLicenseIdentifier: String?
        let sourceLocator: String
        let sourceNativeFieldID: String
        let claimState: SourceAtlasClaimState
        let duplicateSource: Bool
        let duplicateClaim: Bool
        let duplicateRequirement: Bool
    }

    static let checkedAt = Date(timeIntervalSince1970: 1_780_100_000)

    static func fixture(
        predicateID: String = "occupation.task",
        packArtifactID: String = "onet-30.3",
        packReleaseID: String = "30.3",
        subjectID: String = "15-1252.00",
        sourceID: String = "onet.database",
        sourceKind: SourceAtlasSourceKind = .official,
        sourceApprovedForOfficialClaims: Bool = true,
        sourceLicenseIdentifier: String? = SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedLicenseIdentifier,
        sourceLocator: String = SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedSourceLocator,
        sourceNativeFieldID: String = "task-1",
        claimState: SourceAtlasClaimState = .official,
        duplicateSource: Bool = false,
        duplicateClaim: Bool = false,
        duplicateRequirement: Bool = false,
        includeTrustRoot: Bool = true,
        packDataOverride: Data? = nil
    ) throws -> Fixture {
        let configuration = FixturePackConfiguration(
            predicateID: predicateID,
            artifactID: packArtifactID,
            releaseID: packReleaseID,
            subjectID: subjectID,
            sourceID: sourceID,
            sourceKind: sourceKind,
            sourceApprovedForOfficialClaims: sourceApprovedForOfficialClaims,
            sourceLicenseIdentifier: sourceLicenseIdentifier,
            sourceLocator: sourceLocator,
            sourceNativeFieldID: sourceNativeFieldID,
            claimState: claimState,
            duplicateSource: duplicateSource,
            duplicateClaim: duplicateClaim,
            duplicateRequirement: duplicateRequirement
        )
        let pack = Self.pack(configuration: configuration)
        let packData = try encoded(pack)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let privateKey = Curve25519.Signing.PrivateKey()
        let unsignedManifest = SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "30.3",
            publishedAt: checkedAt,
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: "onet-30.3",
                    currentSHA256: packSHA256,
                    currentSignature: ""
                )
            ]
        )
        let signedData = try ManifestVerifier.signingPayload(for: unsignedManifest)
        let signature = try privateKey.signature(for: signedData).base64EncodedString()
        let manifest = SourceAtlasFreshnessManifest(
            schemaVersion: unsignedManifest.schemaVersion,
            versionID: unsignedManifest.versionID,
            publishedAt: unsignedManifest.publishedAt,
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: "onet-30.3",
                    currentSHA256: packSHA256,
                    currentSignature: "ed25519:\(signature)"
                )
            ]
        )
        let manifestData = try encoded(manifest)
        let manifestSHA256 = SourceAtlasStore.sha256Hex(for: manifestData)
        let deliveredPackData = packDataOverride ?? packData

        return Fixture(
            input: SourceAtlasPublicReferenceArtifactVerificationInput(
                manifestData: manifestData,
                expectedManifestSHA256: manifestSHA256,
                packPayload: SourceAtlasStorePayload(
                    source: .cached,
                    data: deliveredPackData,
                    declaredSHA256: packSHA256
                ),
                checkedAt: checkedAt,
                ed25519PublicKey: includeTrustRoot ? privateKey.publicKey.rawRepresentation : nil
            ),
            manifestSHA256: manifestSHA256,
            packSHA256: packSHA256,
            packData: deliveredPackData,
            publicKey: privateKey.publicKey.rawRepresentation
        )
    }

    static func pack(configuration: FixturePackConfiguration) -> SourceAtlasPack {
        let claimID = "\(configuration.subjectID)::\(configuration.predicateID)::\(configuration.sourceNativeFieldID)"
        let source = SourceAtlasSourceRecord(
            id: configuration.sourceID,
            title: "O*NET Database 30.3",
            kind: configuration.sourceKind,
            locator: configuration.sourceLocator,
            retrievedAt: "2026-08-06T00:00:00Z",
            contentHash: "source-hash",
            approvedForOfficialClaims: configuration.sourceApprovedForOfficialClaims,
            licenseIdentifier: configuration.sourceLicenseIdentifier,
            requiredAttribution: SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedAttribution
        )
        let claim = SourceAtlasClaim(
            id: claimID,
            text: "Develop software systems.",
            state: configuration.claimState,
            freshness: .current,
            riskClass: .careerContext,
            sourceIDs: [configuration.sourceID],
            reviewRequired: false
        )
        let requirement = SourceAtlasRequirement(
            id: "requirement.task-1",
            claimID: claimID,
            title: "Inspect public occupation task",
            kind: .hard,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )
        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: configuration.artifactID,
                title: "O*NET 30.3 Software Developers",
                kind: .domainPack,
                version: configuration.releaseID,
                domainID: "career",
                specificDomainID: configuration.subjectID,
                productionUse: true
            ),
            sources: configuration.duplicateSource ? [source, source] : [source],
            claims: configuration.duplicateClaim ? [claim, claim] : [claim],
            requirements: configuration.duplicateRequirement ? [requirement, requirement] : [requirement],
            starterItems: [],
            proofMap: [],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Source needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Public descriptive reference only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["onet.\(configuration.subjectID)"],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["public-reference.onet.30.3"],
                ownsIndividualGoalPhrase: false
            )
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }
}

private struct FixtureBundleResourceLoader: SourceAtlasPublicReferenceBundleResourceLoading {
    let resources: [String: Data]

    func data(forResource name: String, withExtension resourceExtension: String) -> Data? {
        resources["\(name).\(resourceExtension)"]
    }
}
