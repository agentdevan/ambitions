@testable import Ambitions
import XCTest

final class SourceAtlasPublicPackRemoteTransportTests: XCTestCase {
    func testAnonymousTransportFetchesPointerManifestAndPackThenUsesVerifiedPipeline() async throws {
        let fixture = try Self.remoteFixture()
        let transport = SourceAtlasStaticPublicPackRemoteTransport(
            objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
                fixture.manifestKey: fixture.manifestData,
                fixture.packObjectKey: fixture.packData,
            ]
        )
        let access = Self.access(
            networkReachability: .online,
            bundledPublicArtifactAvailable: true
        )

        let resolution = try await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.civicManifestRequest,
                targetPackID: fixture.packID,
                bundledPayload: Self.payload(for: Self.sportsPack(), source: .bundled),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "public_civic_requirements"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [fixture.currentPointerKey, fixture.manifestKey, fixture.packObjectKey]
        )
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.manifestVersionID, fixture.manifestKey)
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, fixture.packSHA256)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(resolution.selectedPack?.id, fixture.packID)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testOfflineNoAccountSkipsRemoteTransportAndUsesLastKnownGood() async throws {
        let currentPack = Self.sportsPack(manifestID: "pack.current")
        let lastKnownGood = Self.sportsPack(manifestID: "pack.last-known-good")
        let currentEntry = try Self.entry(for: currentPack)
        let lastKnownGoodEntry = try Self.entry(for: lastKnownGood)
        let manifestEntry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: ["previous": lastKnownGoodEntry.currentSHA256]
        )
        let access = Self.access(
            networkReachability: .offline,
            lastKnownGoodAvailable: true,
            bundledPublicArtifactAvailable: false
        )

        let resolution = try await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.sportsManifestRequest,
                targetPackID: currentPack.id,
                cachedManifest: Self.manifest(entry: manifestEntry),
                lastKnownGoodPayload: Self.payload(for: lastKnownGood, source: .lastKnownGood),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:])
        )

        XCTAssertEqual(resolution.transportIssues, [.remoteFetchSkipped])
        XCTAssertEqual(resolution.objectRequests, [])
        XCTAssertEqual(resolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .lastKnownGood)
        XCTAssertEqual(resolution.selectedPack?.id, lastKnownGood.id)
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateDomainRequestRejectsBeforeTransport() async {
        let unsafeRequest = SourceAtlasPublicManifestRequest(
            domainID: "goal_text",
            channel: "stable",
            schemaVersion: "1.0.0",
            appVersion: "1.0"
        )
        let access = Self.access(networkReachability: .online)

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: unsafeRequest,
                targetPackID: "public-pack",
                accessDecision: access,
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:])
        )

        XCTAssertEqual(resolution.transportIssues, [.unsafeManifestRequest, .privateEgressFinding])
        XCTAssertEqual(resolution.objectRequests, [])
        XCTAssertEqual(resolution.pipelineResolution.status, .quarantined)
        XCTAssertEqual(resolution.pipelineResolution.manifestRequestIssues, [.privateEgressMarker])
        XCTAssertTrue(resolution.pipelineResolution.fetchIssues.contains(.unsafeManifestRequest))
        XCTAssertNil(resolution.pipelineResolution.packRequest)
    }

    func testPrivateManifestObjectKeyFromPointerStopsBeforeManifestFetch() async throws {
        let fixture = try Self.remoteFixture(
            manifestKey: "source-atlas/v1/staging/candidate/user_id/private.json"
        )
        let access = Self.access(networkReachability: .online)

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.civicManifestRequest,
                targetPackID: fixture.packID,
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "public_civic_requirements"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
            ])
        )

        XCTAssertEqual(resolution.objectRequests.map(\.objectKey), [fixture.currentPointerKey])
        XCTAssertEqual(resolution.transportIssues, [.currentPointerInvalid])
        XCTAssertEqual(resolution.pipelineResolution.status, .quarantined)
        XCTAssertTrue(resolution.pipelineResolution.fetchIssues.contains(.unsafeCurrentPointer))
        XCTAssertNil(resolution.pipelineResolution.packRequest)
    }

    func testURLSessionEndpointBuildsHTTPSObjectURLWithoutPrivateContext() {
        let request = SourceAtlasPublicPackRemoteObjectRequest(
            kind: .currentPointer,
            objectKey: "/source-atlas/v1/staging/candidate/public_civic_requirements/current.json"
        )
        let endpoint = SourceAtlasPublicPackRemoteEndpoint(
            baseURLString: "https://r2.example.test/source/"
        )

        XCTAssertEqual(endpoint.validationIssues, [])
        XCTAssertEqual(
            endpoint.url(for: request)?.absoluteString,
            "https://r2.example.test/source/source-atlas/v1/staging/candidate/public_civic_requirements/current.json"
        )
        XCTAssertEqual(
            SourceAtlasPublicPackRemoteEndpoint(baseURLString: "https://user@r2.example.test/source").validationIssues,
            [.invalidEndpoint]
        )
    }

    func testLiveProductionWorkerGatewayFetchesPublishedPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionOccupationManifestRequest,
                targetPackID: Self.productionOccupationPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "occupation_foundation"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/occupation_foundation/current.json",
                "source-atlas/v1/production/stable/occupation_foundation/revocations.json",
                "source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/occupation_foundation/lkg.json",
                "source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionOccupationPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionOccupationPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "occupation_foundation")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedCivicPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionCivicManifestRequest,
                targetPackID: Self.productionCivicPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "public_civic_requirements"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/public_civic_requirements/current.json",
                "source-atlas/v1/production/stable/public_civic_requirements/revocations.json",
                "source-atlas/v1/production/stable/public_civic_requirements/20260628T041500Z/manifest.json",
                "source-atlas/v1/production/stable/public_civic_requirements/lkg.json",
                "source-atlas/v1/production/stable/public_civic_requirements/20260628T041500Z/manifest.json",
                "source-atlas/v1/production/stable/public_civic_requirements/20260628T041500Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.queryResponse.fallbackReason, .reviewRequired)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.queryResponse.selectedResult.reviewState, .required)
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionCivicPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionCivicPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "public_civic_requirements")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedEducationPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionEducationManifestRequest,
                targetPackID: Self.productionEducationPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "education_credentialing"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/education_credentialing/current.json",
                "source-atlas/v1/production/stable/education_credentialing/revocations.json",
                "source-atlas/v1/production/stable/education_credentialing/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/education_credentialing/lkg.json",
                "source-atlas/v1/production/stable/education_credentialing/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/education_credentialing/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.queryResponse.fallbackReason, .reviewRequired)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.queryResponse.selectedResult.reviewState, .required)
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionEducationPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionEducationPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "education_credentialing")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedBusinessPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionBusinessManifestRequest,
                targetPackID: Self.productionBusinessPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "business_entrepreneurship"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/business_entrepreneurship/current.json",
                "source-atlas/v1/production/stable/business_entrepreneurship/revocations.json",
                "source-atlas/v1/production/stable/business_entrepreneurship/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/business_entrepreneurship/lkg.json",
                "source-atlas/v1/production/stable/business_entrepreneurship/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/business_entrepreneurship/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionBusinessPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionBusinessPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "business_entrepreneurship")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedCreativeProjectPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionCreativeProjectManifestRequest,
                targetPackID: Self.productionCreativeProjectPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "creative_project_reference"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/creative_project_reference/current.json",
                "source-atlas/v1/production/stable/creative_project_reference/revocations.json",
                "source-atlas/v1/production/stable/creative_project_reference/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/creative_project_reference/lkg.json",
                "source-atlas/v1/production/stable/creative_project_reference/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/creative_project_reference/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionCreativeProjectPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionCreativeProjectPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "creative_project_reference")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedPersonalGrowthPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionPersonalGrowthManifestRequest,
                targetPackID: Self.productionPersonalGrowthPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "personal_growth"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/personal_growth/current.json",
                "source-atlas/v1/production/stable/personal_growth/revocations.json",
                "source-atlas/v1/production/stable/personal_growth/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/personal_growth/lkg.json",
                "source-atlas/v1/production/stable/personal_growth/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/personal_growth/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionPersonalGrowthPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionPersonalGrowthPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "personal_growth")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedRelationshipsFamilyPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionRelationshipsFamilyManifestRequest,
                targetPackID: Self.productionRelationshipsFamilyPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "relationships_family"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/relationships_family/current.json",
                "source-atlas/v1/production/stable/relationships_family/revocations.json",
                "source-atlas/v1/production/stable/relationships_family/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/relationships_family/lkg.json",
                "source-atlas/v1/production/stable/relationships_family/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/relationships_family/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionRelationshipsFamilyPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionRelationshipsFamilyPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "relationships_family")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedHobbiesRecreationPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionHobbiesManifestRequest,
                targetPackID: Self.productionHobbiesPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "hobbies_recreation"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/hobbies_recreation/current.json",
                "source-atlas/v1/production/stable/hobbies_recreation/revocations.json",
                "source-atlas/v1/production/stable/hobbies_recreation/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/hobbies_recreation/lkg.json",
                "source-atlas/v1/production/stable/hobbies_recreation/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/hobbies_recreation/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionHobbiesPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionHobbiesPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "hobbies_recreation")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedHealthWellnessPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionHealthManifestRequest,
                targetPackID: Self.productionHealthPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "health_wellness_reference"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/health_wellness_reference/current.json",
                "source-atlas/v1/production/stable/health_wellness_reference/revocations.json",
                "source-atlas/v1/production/stable/health_wellness_reference/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/health_wellness_reference/lkg.json",
                "source-atlas/v1/production/stable/health_wellness_reference/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/health_wellness_reference/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionHealthPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionHealthPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "health_wellness_reference")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedStatCanHealthStatisticsPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionStatCanHealthStatisticsManifestRequest,
                targetPackID: Self.productionStatCanHealthStatisticsPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "health_wellness_reference_ca_statistics"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/health_wellness_reference_ca_statistics/current.json",
                "source-atlas/v1/production/stable/health_wellness_reference_ca_statistics/revocations.json",
                "source-atlas/v1/production/stable/health_wellness_reference_ca_statistics/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/health_wellness_reference_ca_statistics/lkg.json",
                "source-atlas/v1/production/stable/health_wellness_reference_ca_statistics/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/health_wellness_reference_ca_statistics/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionStatCanHealthStatisticsPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionStatCanHealthStatisticsPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "health_wellness_reference_ca_statistics")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedTravelRelocationPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionTravelManifestRequest,
                targetPackID: Self.productionTravelPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "travel_relocation"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/travel_relocation/current.json",
                "source-atlas/v1/production/stable/travel_relocation/revocations.json",
                "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/travel_relocation/lkg.json",
                "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionTravelPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionTravelPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "travel_relocation")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedFinancePublicReferencePackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionFinanceManifestRequest,
                targetPackID: Self.productionFinancePackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "finance_public_reference"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/finance_public_reference/current.json",
                "source-atlas/v1/production/stable/finance_public_reference/revocations.json",
                "source-atlas/v1/production/stable/finance_public_reference/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/finance_public_reference/lkg.json",
                "source-atlas/v1/production/stable/finance_public_reference/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/finance_public_reference/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.queryResponse.fallbackReason, .reviewRequired)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.queryResponse.selectedResult.reviewState, .required)
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionFinancePackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionFinancePackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "finance_public_reference")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedHomeLifeAdminPackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionHomeLifeAdminManifestRequest,
                targetPackID: Self.productionHomeLifeAdminPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "home_life_admin"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/home_life_admin/current.json",
                "source-atlas/v1/production/stable/home_life_admin/revocations.json",
                "source-atlas/v1/production/stable/home_life_admin/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/home_life_admin/lkg.json",
                "source-atlas/v1/production/stable/home_life_admin/20260628T000000Z/manifest.json",
                "source-atlas/v1/production/stable/home_life_admin/20260628T000000Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionHomeLifeAdminPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionHomeLifeAdminPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "home_life_admin")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayFetchesPublishedVolunteeringPublicReferencePackWithURLSessionWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 URLSession proof.")
        }

        let transport = SourceAtlasURLSessionPublicPackRemoteTransport(
            endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
        )
        XCTAssertEqual(transport.endpoint.validationIssues, [])

        let resolution = await SourceAtlasPublicPackRemoteFetchCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionVolunteeringManifestRequest,
                targetPackID: Self.productionVolunteeringPackID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "volunteering_public_reference"),
                checkedAt: Self.checkedAt
            ),
            transport: transport
        )

        XCTAssertEqual(resolution.transportIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                "source-atlas/v1/production/stable/volunteering_public_reference/current.json",
                "source-atlas/v1/production/stable/volunteering_public_reference/revocations.json",
                "source-atlas/v1/production/stable/volunteering_public_reference/20260628T180600Z/manifest.json",
                "source-atlas/v1/production/stable/volunteering_public_reference/lkg.json",
                "source-atlas/v1/production/stable/volunteering_public_reference/20260628T180600Z/manifest.json",
                "source-atlas/v1/production/stable/volunteering_public_reference/20260628T180600Z/pack.json",
            ]
        )
        XCTAssertEqual(resolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(resolution.pipelineResolution.packRequest?.declaredSHA256, Self.productionVolunteeringPackSHA256)
        XCTAssertEqual(resolution.selectedPack?.id, Self.productionVolunteeringPackID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "volunteering_public_reference")
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }
}

private extension SourceAtlasPublicPackRemoteTransportTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
    static let productionOccupationPackID = "source-atlas/v1/domain/occupation_foundation/20260628T000000Z"
    static let productionOccupationPackSHA256 = "55f2ae4593e40e30fe9aa48d0dab4988f186bc889cf225b3db2676b77e1d1ea3"
    static let productionCivicPackID = "source-atlas/v1/domain/public_civic_requirements/20260628T041500Z"
    static let productionCivicPackSHA256 = "bd6cb0923a4d438ad0a146c83908abf4c9be6301a51af92ccc32e037848115a6"
    static let productionEducationPackID = "source-atlas/v1/domain/education_credentialing/20260628T000000Z"
    static let productionEducationPackSHA256 = "95e7809997ba010db59cee5925bf9f713d85b70bf7e9e84eae961bd615919b3e"
    static let productionBusinessPackID = "source-atlas/v1/domain/business_entrepreneurship/20260628T000000Z"
    static let productionBusinessPackSHA256 = "04d9eaf6f96b1271982a356664a570c74ed946e3145be96bcf636e7f1e561af6"
    static let productionCreativeProjectPackID = "source-atlas/v1/domain/creative_project_reference/20260628T000000Z"
    static let productionCreativeProjectPackSHA256 = "32d55d50f4a8e3f69055cbf4eceddc0f316020449f274b040c1d64b77faba3d4"
    static let productionPersonalGrowthPackID = "source-atlas/v1/domain/personal_growth/20260628T000000Z"
    static let productionPersonalGrowthPackSHA256 = "01e67a2f783214af26713fac95c1864e9c8050dc5436096f9ca4c49e4f65e7d9"
    static let productionRelationshipsFamilyPackID = "source-atlas/v1/domain/relationships_family/20260628T000000Z"
    static let productionRelationshipsFamilyPackSHA256 = "de4db9e6778d23d16725951c88d6254355203a544b70246ade18f373447539c1"
    static let productionHobbiesPackID = "source-atlas/v1/domain/hobbies_recreation/20260628T000000Z"
    static let productionHobbiesPackSHA256 = "7768a3f7867ddb9f184c16989ebd7444c31c7053bfbd4375198a0f6199eb7638"
    static let productionHealthPackID = "source-atlas/v1/domain/health_wellness_reference/20260628T000000Z"
    static let productionHealthPackSHA256 = "b84001256a9bbb06c26e1656bb04a04217078ce77d7790aaab41656dd67ea301"
    static let productionStatCanHealthStatisticsPackID = "source-atlas/v1/domain/health_wellness_reference_ca_statistics/20260628T000000Z"
    static let productionStatCanHealthStatisticsPackSHA256 = "30c129cc7cbd0ff1027cc57a6f611579a5c1562a91fe929440857e01bc6981ee"
    static let productionTravelPackID = "source-atlas/v1/domain/travel_relocation/20260628T000000Z"
    static let productionTravelPackSHA256 = "ab6f77b1c8ba9c4c7667334b01f16080c0412c621f2055d473468a6625a7483f"
    static let productionFinancePackID = "source-atlas/v1/domain/finance_public_reference/20260628T000000Z"
    static let productionFinancePackSHA256 = "ca23807f8cae55bf052600a90ca205ff3436f987e5d97f8518e96cd300bd0c19"
    static let productionHomeLifeAdminPackID = "source-atlas/v1/domain/home_life_admin/20260628T000000Z"
    static let productionHomeLifeAdminPackSHA256 = "e732019e96231678955e6a45665f245159f45fc57563b75bd1ddc4c2734212ee"
    static let productionVolunteeringPackID = "source-atlas/v1/domain/volunteering_public_reference/20260628T180600Z"
    static let productionVolunteeringPackSHA256 = "7483b6e19f2ae712bd0936c0855f8072ce3fd0e650baf6bee5f7fcf1a433dd45"
    static let civicManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "public_civic_requirements",
        channel: "candidate",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let sportsManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionOccupationManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "occupation_foundation",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionCivicManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "public_civic_requirements",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionEducationManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "education_credentialing",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionBusinessManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "business_entrepreneurship",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionCreativeProjectManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "creative_project_reference",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionPersonalGrowthManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "personal_growth",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionRelationshipsFamilyManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "relationships_family",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionHobbiesManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "hobbies_recreation",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionHealthManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "health_wellness_reference",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionStatCanHealthStatisticsManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "health_wellness_reference_ca_statistics",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionTravelManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "travel_relocation",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionFinanceManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "finance_public_reference",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionHomeLifeAdminManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "home_life_admin",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let productionVolunteeringManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "volunteering_public_reference",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    static var liveEndpoint: String? {
        let environment = ProcessInfo.processInfo.environment
        return environment["SOURCE_ATLAS_LIVE_R2_ENDPOINT"]
            ?? environment["TEST_RUNNER_SOURCE_ATLAS_LIVE_R2_ENDPOINT"]
    }

    struct RemoteFixture {
        let currentPointerKey: String
        let manifestKey: String
        let packObjectKey: String
        let packID: String
        let packSHA256: String
        let pointerData: Data
        let manifestData: Data
        let packData: Data
    }

    static func remoteFixture(
        manifestKey: String = "source-atlas/v1/staging/candidate/public_civic_requirements/20260627T000000Z/manifest.json"
    ) throws -> RemoteFixture {
        let currentPointerKey = "source-atlas/v1/staging/candidate/public_civic_requirements/current.json"
        let packObjectKey = "source-atlas/v1/staging/candidate/public_civic_requirements/20260627T000000Z/pack.json"
        let packID = "source-atlas/v1/domain/public_civic_requirements/20260627T000000Z"
        let packData = publishedDomainPackData(packID: packID)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let manifestData = publishedManifestData(
            packID: packID,
            packObjectKey: packObjectKey,
            packSHA256: packSHA256
        )
        let pointerData = publishedPointerData(
            packID: packID,
            manifestKey: manifestKey,
            manifestSHA256: SourceAtlasStore.sha256Hex(for: manifestData),
            packSHA256: packSHA256
        )
        return RemoteFixture(
            currentPointerKey: currentPointerKey,
            manifestKey: manifestKey,
            packObjectKey: packObjectKey,
            packID: packID,
            packSHA256: packSHA256,
            pointerData: pointerData,
            manifestData: manifestData,
            packData: packData
        )
    }

    static func publishedPointerData(
        packID: String,
        manifestKey: String,
        manifestSHA256: String,
        packSHA256: String
    ) -> Data {
        Data(
            """
            {
              "schemaVersion": 1,
              "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
              "createdAt": "2026-06-27T00:00:00Z",
              "environment": "staging",
              "channel": "candidate",
              "packID": "\(packID)",
              "packVersion": "20260627T000000Z",
              "manifestKey": "\(manifestKey)",
              "manifestSHA256": "\(manifestSHA256)",
              "packSHA256": "\(packSHA256)",
              "revocationManifestKey": null,
              "lastKnownGoodKey": null,
              "publicReferenceOnly": true,
              "dataClass": "public_freshness",
              "privacyBoundary": "public/reference/freshness only",
              "nonClaims": [
                "not a final user plan, schedule, or Step generator"
              ]
            }
            """.utf8
        )
    }

    static func publishedManifestData(
        packID: String,
        packObjectKey: String,
        packSHA256: String
    ) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.packManifest.v1",
              "schema_version": "1.0.0",
              "manifest_id": "source_atlas_pack_manifest.test",
              "pack_id": "\(packID)",
              "created_at": "2026-06-27T00:00:00Z",
              "object_keys": {
                "pack": "\(packObjectKey)"
              },
              "sha256": "\(packSHA256)",
              "freshness_status": "current",
              "publicReferenceOnly": true
            }
            """.utf8
        )
    }

    static func publishedDomainPackData(packID: String) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.domainPack.v1",
              "schema_version": "1.0.0",
              "pack_id": "\(packID)",
              "frontier_id": "public_civic_requirements",
              "created_at": "2026-06-27T00:00:00Z",
              "publicReferenceOnly": true,
              "manifest": {
                "pack_version": "20260627T000000Z",
                "channel": "candidate",
                "environment": "staging"
              },
              "sources": [
                {
                  "source_id": "nara.constitution.presidency",
                  "source_name": "U.S. Constitution presidential eligibility",
                  "authority_class": "official_government",
                  "review_status": "reviewed",
                  "r2_pack_policy": "pack_allowed_with_attribution"
                }
              ],
              "claims": [
                {
                  "claim_id": "canonical_claim.age",
                  "claim_type": "eligibility_requirement",
                  "predicate": "eligibility_requirement",
                  "object_value": "U.S. presidential eligibility includes a minimum age requirement as a public constitutional reference.",
                  "domain": "public_civic_requirements",
                  "source_id": "nara.constitution.presidency",
                  "authority_class": "official_government",
                  "freshness_status": "current",
                  "review_required": false,
                  "locator": "https://www.archives.gov/founding-docs/constitution-transcript"
                }
              ],
              "non_claims": [
                "not a final user plan, schedule, or Step generator",
                "not legal advice"
              ]
            }
            """.utf8
        )
    }

    static func access(
        networkReachability: SourceAtlasNetworkReachability,
        lastKnownGoodAvailable: Bool = false,
        bundledPublicArtifactAvailable: Bool = true
    ) -> SourceAtlasAccessDecision {
        SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: networkReachability,
                lastKnownGoodAvailable: lastKnownGoodAvailable,
                bundledPublicArtifactAvailable: bundledPublicArtifactAvailable
            )
        )
    }

    static func manifest(
        entry: SourceAtlasFreshnessPackEntry,
        publishedAt: Date = Date(timeIntervalSince1970: 1_780_000_000)
    ) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "manifest.v1",
            publishedAt: publishedAt,
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

    static func sportsPack(manifestID: String = "pack.current") -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: manifestID,
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
                    retrievedAt: "2026-06-01T12:00:00Z",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                ),
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
                ),
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
                    reviewState: .approved
                ),
            ],
            starterItems: [],
            proofMap: [],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "starter_goal",
                    requiredPackIDs: [manifestID],
                    projectionProfiles: []
                ),
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
