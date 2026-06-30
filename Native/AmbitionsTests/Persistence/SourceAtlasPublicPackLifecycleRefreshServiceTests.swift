@testable import Ambitions
import XCTest

final class SourceAtlasPublicPackLifecycleRefreshServiceTests: XCTestCase {
    func testEmptyLifecycleConfigurationIsNoopAndDoesNotBlockLocalPlanning() async throws {
        let transport = SourceAtlasLifecycleCountingTransport(objectsByKey: [:])
        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            targets: [],
            transport: transport,
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.mode, .activeLifecycle)
        XCTAssertEqual(resolution.configuredTargetCount, 0)
        XCTAssertEqual(resolution.attemptedTargetIDs, [])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions, [])
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testConfiguredPublicLifecycleRefreshUsesLatestCachedPackOfflineWithoutTransport() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.seededRepository(fixture: fixture)
        let transport = SourceAtlasLifecycleCountingTransport(objectsByKey: [:])
        let service = SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    Self.approvedEntry(
                        id: "sports-stable",
                        targetPackID: fixture.pack.id,
                        allowedModes: [.activeLifecycle]
                    ),
                ]
            ),
            transport: transport,
            repository: repository
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .offline,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.attemptedTargetIDs, ["sports-stable"])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)
        XCTAssertEqual(resolution.targetResolutions.first?.selectedPack?.id, fixture.pack.id)
        XCTAssertEqual(resolution.targetResolutions.first?.appRefreshResolution?.accessDecision.route, .cachedPublic)
        XCTAssertEqual(
            resolution.targetResolutions.first?.appRefreshResolution?.refreshResolution.remoteResolution.transportIssues,
            [.remoteFetchSkipped]
        )
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testDirectTargetInitializerLeavesTargetsReviewRequiredBeforeTransport() async throws {
        let transport = SourceAtlasLifecycleCountingTransport(objectsByKey: [:])
        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            targets: [
                SourceAtlasPublicPackLifecycleRefreshTarget(
                    id: "sports-stable",
                    domainID: "sports",
                    channel: "stable",
                    schemaVersion: "1.0.0",
                    appVersion: "1.0",
                    publicLocale: "en-US",
                    targetPackID: "source-atlas/v1/domain/sports/20260627T000000Z"
                ),
            ],
            transport: transport,
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, ["sports-stable"])
        XCTAssertTrue(
            resolution.registryResolution.findings.contains(
                SourceAtlasPublicPackRefreshTargetRegistryFinding(
                    targetID: "sports-stable",
                    issue: .inactiveTarget
                )
            )
        )
        XCTAssertEqual(resolution.attemptedTargetIDs, [])
        XCTAssertEqual(resolution.targetResolutions, [])
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateLifecycleTargetIsRejectedBeforeTransport() async throws {
        let fixture = try Self.remoteNativeFixture()
        let transport = SourceAtlasLifecycleCountingTransport(
            objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
                fixture.manifestKey: fixture.manifestData,
                fixture.packObjectKey: fixture.packData,
            ]
        )
        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: "goal_text-refresh",
                            domainID: "goal_text",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            targetPackID: "source-atlas/v1/user_id/private-goal"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.approvalArtifactID
                    ),
                ]
            ),
            transport: transport,
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.attemptedTargetIDs, [])
        XCTAssertEqual(resolution.issues, [.privateTargetMetadata, .unsafeManifestRequest])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["goal_text", "user_id"])
        XCTAssertEqual(resolution.targetResolutions, [])
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testRegistryBackedLifecycleRefreshSelectsOnlyActiveModeTargets() async throws {
        let transport = SourceAtlasLifecycleCountingTransport(objectsByKey: [:])
        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: "review-required",
                            domainID: "sports",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            targetPackID: "source-atlas/v1/domain/sports/review"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .reviewRequired
                    ),
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: "sports-stable",
                            domainID: "sports",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: "source-atlas/v1/domain/sports/20260627T000000Z"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.approvalArtifactID
                    ),
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: "startup-only",
                            domainID: "sports",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            targetPackID: "source-atlas/v1/domain/sports/startup"
                        ),
                        allowedModes: [.startup],
                        status: .active,
                        reviewArtifactID: Self.approvalArtifactID
                    ),
                ]
            ),
            transport: transport,
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .offline,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 3)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, ["sports-stable"])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, ["review-required", "startup-only"])
        XCTAssertEqual(resolution.attemptedTargetIDs, ["sports-stable"])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)
        XCTAssertEqual(
            resolution.targetResolutions.first?.appRefreshResolution?.refreshResolution.remoteResolution.transportIssues,
            [.remoteFetchSkipped]
        )
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testRegistryBackedLifecycleRefreshRejectsActiveTargetWithoutApprovalBeforeTransport() async throws {
        let transport = SourceAtlasLifecycleCountingTransport(objectsByKey: [:])
        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: "sports-stable",
                            domainID: "sports",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: "source-atlas/v1/domain/sports/20260627T000000Z"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active
                    ),
                ]
            ),
            transport: transport,
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, ["sports-stable"])
        XCTAssertTrue(
            resolution.registryResolution.findings.contains(
                SourceAtlasPublicPackRefreshTargetRegistryFinding(
                    targetID: "sports-stable",
                    issue: .missingApprovalArtifact
                )
            )
        )
        XCTAssertEqual(resolution.issues, [.missingApprovalArtifact])
        XCTAssertEqual(resolution.attemptedTargetIDs, [])
        XCTAssertEqual(resolution.targetResolutions, [])
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesOccupationTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionOccupationTargetID,
                            domainID: "occupation_foundation",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionOccupationPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionGatewayApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionOccupationTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionOccupationTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionOccupationPackSHA256
        )
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionOccupationPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "occupation_foundation")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesCivicTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionCivicTargetID,
                            domainID: "public_civic_requirements",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionCivicPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionCivicGatewayApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not legal advice",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionCivicTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionCivicTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource,
            .cached
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.queryResponse.fallbackReason,
            .reviewRequired
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.queryResponse.selectedResult.reviewState,
            .required
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionCivicPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .verifiedReference)
        XCTAssertTrue(appResolution.refreshResolution.cacheJournalRecord.fallbackTriggered)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionCivicPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "public_civic_requirements")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesEducationTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionEducationTargetID,
                            domainID: "education_credentialing",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionEducationPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionQuadDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not an admissions decision",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionEducationTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionEducationTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource,
            .cached
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.queryResponse.fallbackReason,
            .reviewRequired
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.queryResponse.selectedResult.reviewState,
            .required
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionEducationPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .verifiedReference)
        XCTAssertTrue(appResolution.refreshResolution.cacheJournalRecord.fallbackTriggered)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionEducationPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "education_credentialing")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesBusinessTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionBusinessTargetID,
                            domainID: "business_entrepreneurship",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionBusinessPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionQuadDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not legal advice",
                            "not tax advice",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionBusinessTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionBusinessTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionBusinessPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionBusinessPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "business_entrepreneurship")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesCreativeProjectTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionCreativeProjectTargetID,
                            domainID: "creative_project_reference",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionCreativeProjectPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionDecaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not copyright permission",
                            "not license selection advice",
                            "not implementation advice",
                            "not source-use permission",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionCreativeProjectTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionCreativeProjectTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionCreativeProjectPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionCreativeProjectPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "creative_project_reference")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesPersonalGrowthTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionPersonalGrowthTargetID,
                            domainID: "personal_growth",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionPersonalGrowthPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionUndecaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not mental health treatment",
                            "not diagnosis",
                            "not therapy replacement",
                            "not emergency advice",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionPersonalGrowthTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionPersonalGrowthTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionPersonalGrowthPackSHA256
        )
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionPersonalGrowthPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "personal_growth")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesRelationshipsFamilyTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionRelationshipsFamilyTargetID,
                            domainID: "relationships_family",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionRelationshipsFamilyPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionDuodecaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not therapy",
                            "not diagnosis",
                            "not legal custody advice",
                            "not child protection advice",
                            "not emergency advice",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionRelationshipsFamilyTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionRelationshipsFamilyTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionRelationshipsFamilyPackSHA256
        )
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionRelationshipsFamilyPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "relationships_family")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesHobbiesRecreationTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionHobbiesTargetID,
                            domainID: "hobbies_recreation",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionHobbiesPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionPentaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not emergency advice",
                            "not unsafe instructions",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionHobbiesTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionHobbiesTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionHobbiesPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionHobbiesPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "hobbies_recreation")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesHealthWellnessTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionHealthTargetID,
                            domainID: "health_wellness_reference",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionHealthPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionHexaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not medical advice",
                            "not diagnosis",
                            "not treatment advice",
                            "not emergency advice",
                            "not a custom fitness or health plan",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionHealthTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionHealthTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionHealthPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .verifiedReference)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionHealthPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "health_wellness_reference")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesStatCanHealthStatisticsTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionStatCanHealthStatisticsTargetID,
                            domainID: "health_wellness_reference_ca_statistics",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionStatCanHealthStatisticsPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionTridecaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not medical advice",
                            "not diagnosis",
                            "not treatment advice",
                            "not emergency advice",
                            "not a custom fitness or health plan",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionStatCanHealthStatisticsTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionStatCanHealthStatisticsTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionStatCanHealthStatisticsPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .verifiedReference)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionStatCanHealthStatisticsPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "health_wellness_reference_ca_statistics")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesTravelRelocationTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionTravelTargetID,
                            domainID: "travel_relocation",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionTravelPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionHeptaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not visa advice",
                            "not legal advice",
                            "not emergency advice",
                            "not a safety guarantee",
                            "not a custom itinerary",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionTravelTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionTravelTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionTravelPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionTravelPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "travel_relocation")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesFinancePublicReferenceTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionFinanceTargetID,
                            domainID: "finance_public_reference",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionFinancePackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionOctaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not investment advice",
                            "not tax advice",
                            "not legal advice",
                            "not debt advice",
                            "not an individual financial plan",
                            "not benefit eligibility or approval",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionFinanceTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionFinanceTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource,
            .cached
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.queryResponse.fallbackReason,
            .reviewRequired
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.cacheResolution?.queryResponse.selectedResult.reviewState,
            .required
        )
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionFinancePackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .verifiedReference)
        XCTAssertTrue(appResolution.refreshResolution.cacheJournalRecord.fallbackTriggered)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionFinancePackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "finance_public_reference")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesHomeLifeAdminTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionHomeLifeAdminTargetID,
                            domainID: "home_life_admin",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionHomeLifeAdminPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionNonaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not emergency response advice",
                            "not unsafe repair guidance",
                            "not eligibility or loan approval",
                            "not contractor advice",
                            "not an individual household plan",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionHomeLifeAdminTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionHomeLifeAdminTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionHomeLifeAdminPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertFalse(appResolution.refreshResolution.cacheJournalRecord.fallbackTriggered)
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionHomeLifeAdminPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "home_life_admin")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLiveProductionWorkerGatewayRefreshesVolunteeringPublicReferenceTargetWhenEndpointIsProvided() async throws {
        guard let endpoint = Self.liveEndpoint else {
            throw XCTSkip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
        }

        let service = try SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistry(
                entries: [
                    SourceAtlasPublicPackRefreshTargetRegistryEntry(
                        target: SourceAtlasPublicPackLifecycleRefreshTarget(
                            id: Self.productionVolunteeringTargetID,
                            domainID: "volunteering_public_reference",
                            channel: "stable",
                            schemaVersion: "1.0.0",
                            appVersion: "1.0",
                            publicLocale: "en-US",
                            targetPackID: Self.productionVolunteeringPackID,
                            environment: "production"
                        ),
                        allowedModes: [.activeLifecycle],
                        status: .active,
                        reviewArtifactID: Self.productionTetradecaDomainNativeRegistryApprovalArtifactID,
                        nonClaims: [
                            "not a final user plan",
                            "not a Step generator",
                            "not current opportunity availability",
                            "not eligibility advice",
                            "not individualized placement",
                            "not release readiness",
                        ]
                    ),
                ]
            ),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: SourceAtlasPublicPackRemoteEndpoint(baseURLString: endpoint)
            ),
            repository: Self.repository()
        )

        let resolution = await service.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .activeLifecycle,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.configuredTargetCount, 1)
        XCTAssertEqual(resolution.registryResolution.selectedTargetIDs, [Self.productionVolunteeringTargetID])
        XCTAssertEqual(resolution.registryResolution.excludedTargetIDs, [])
        XCTAssertEqual(resolution.attemptedTargetIDs, [Self.productionVolunteeringTargetID])
        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.targetResolutions.count, 1)

        let targetResolution = try XCTUnwrap(resolution.targetResolutions.first)
        XCTAssertEqual(targetResolution.taskIssues, [])
        XCTAssertEqual(targetResolution.egressFindings, [])
        XCTAssertFalse(targetResolution.sentPrivateRuntimeContext)
        XCTAssertFalse(targetResolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(targetResolution.generatedFinalPlan)
        XCTAssertFalse(targetResolution.generatedFinalSchedule)
        XCTAssertFalse(targetResolution.generatedStepList)

        let appResolution = try XCTUnwrap(targetResolution.appRefreshResolution)
        XCTAssertEqual(appResolution.accessDecision.route, .remotePublicReference)
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.egressFindings, [])
        XCTAssertEqual(appResolution.refreshResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(
            appResolution.refreshResolution.remoteResolution.pipelineResolution.packRequest?.declaredSHA256,
            Self.productionVolunteeringPackSHA256
        )
        XCTAssertEqual(appResolution.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertEqual(appResolution.selectedPack?.id, Self.productionVolunteeringPackID)
        XCTAssertEqual(appResolution.selectedPack?.manifest.domainID, "volunteering_public_reference")
        XCTAssertTrue(appResolution.persistedPackPayload)
        XCTAssertFalse(appResolution.coreLocalPlanningBlocked)

        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }
}

private actor SourceAtlasLifecycleCountingTransport: SourceAtlasPublicPackRemoteTransport {
    private let objectsByKey: [String: Data]
    private var requests: [SourceAtlasPublicPackRemoteObjectRequest] = []

    init(objectsByKey: [String: Data]) {
        self.objectsByKey = objectsByKey
    }

    func fetch(_ request: SourceAtlasPublicPackRemoteObjectRequest) async throws -> Data {
        requests.append(request)
        guard let data = objectsByKey[request.objectKey] else {
            throw SourceAtlasPublicPackRemoteTransportError.missingObject(request.objectKey)
        }
        return data
    }

    func requestCount() -> Int {
        requests.count
    }
}

private extension SourceAtlasPublicPackLifecycleRefreshServiceTests {
    struct RemoteNativeFixture {
        let currentPointerKey: String
        let manifestKey: String
        let packObjectKey: String
        let pack: SourceAtlasPack
        let packSHA256: String
        let pointerData: Data
        let manifestData: Data
        let packData: Data
    }

    static let checkedAt = Date(timeIntervalSince1970: 1_780_100_000)
    static let approvalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-active-target-approval-gate-train-26.md"
    static let productionGatewayApprovalArtifactID = "docs/qa/source-atlas/r2/source-atlas-public-r2-worker-gateway-owner-approval-train-34.md"
    static let productionCivicGatewayApprovalArtifactID = "docs/qa/source-atlas/r2/source-atlas-public-r2-worker-gateway-civic-approval-train-37.md"
    static let productionQuadDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-quad-domain-approval-train-43.json"
    static let productionPentaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-penta-domain-approval-train-44.json"
    static let productionHexaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-hexa-domain-approval-train-45.json"
    static let productionHeptaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-hepta-domain-approval-train-46.json"
    static let productionOctaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-octa-domain-approval-train-47.json"
    static let productionNonaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-nona-domain-approval-train-48.json"
    static let productionDecaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-deca-domain-approval-train-49.json"
    static let productionUndecaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-undeca-domain-approval-train-50.json"
    static let productionDuodecaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-duodeca-domain-approval-train-51.json"
    static let productionTridecaDomainNativeRegistryApprovalArtifactID = "docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-trideca-domain-approval-train-81.json"
    static let productionTetradecaDomainNativeRegistryApprovalArtifactID = "tools/source-atlas/generated/r2-owner-approval/train-131-tetradeca-ledger-gated/r2-owner-approval.json"
    static let productionOccupationTargetID = "source-atlas-refresh-target.occupation_foundation.stable.20260628T000000Z"
    static let productionOccupationPackID = "source-atlas/v1/domain/occupation_foundation/20260628T000000Z"
    static let productionOccupationPackSHA256 = "55f2ae4593e40e30fe9aa48d0dab4988f186bc889cf225b3db2676b77e1d1ea3"
    static let productionCivicTargetID = "source-atlas-refresh-target.public_civic_requirements.stable.20260628T041500Z"
    static let productionCivicPackID = "source-atlas/v1/domain/public_civic_requirements/20260628T041500Z"
    static let productionCivicPackSHA256 = "bd6cb0923a4d438ad0a146c83908abf4c9be6301a51af92ccc32e037848115a6"
    static let productionEducationTargetID = "source-atlas-refresh-target.education_credentialing.stable.20260628T000000Z"
    static let productionEducationPackID = "source-atlas/v1/domain/education_credentialing/20260628T000000Z"
    static let productionEducationPackSHA256 = "95e7809997ba010db59cee5925bf9f713d85b70bf7e9e84eae961bd615919b3e"
    static let productionBusinessTargetID = "source-atlas-refresh-target.business_entrepreneurship.stable.20260628T000000Z"
    static let productionBusinessPackID = "source-atlas/v1/domain/business_entrepreneurship/20260628T000000Z"
    static let productionBusinessPackSHA256 = "04d9eaf6f96b1271982a356664a570c74ed946e3145be96bcf636e7f1e561af6"
    static let productionCreativeProjectTargetID = "source-atlas-refresh-target.creative_project_reference.stable.20260628T000000Z"
    static let productionCreativeProjectPackID = "source-atlas/v1/domain/creative_project_reference/20260628T000000Z"
    static let productionCreativeProjectPackSHA256 = "32d55d50f4a8e3f69055cbf4eceddc0f316020449f274b040c1d64b77faba3d4"
    static let productionPersonalGrowthTargetID = "source-atlas-refresh-target.personal_growth.stable.20260628T000000Z"
    static let productionPersonalGrowthPackID = "source-atlas/v1/domain/personal_growth/20260628T000000Z"
    static let productionPersonalGrowthPackSHA256 = "01e67a2f783214af26713fac95c1864e9c8050dc5436096f9ca4c49e4f65e7d9"
    static let productionRelationshipsFamilyTargetID = "source-atlas-refresh-target.relationships_family.stable.20260628T000000Z"
    static let productionRelationshipsFamilyPackID = "source-atlas/v1/domain/relationships_family/20260628T000000Z"
    static let productionRelationshipsFamilyPackSHA256 = "de4db9e6778d23d16725951c88d6254355203a544b70246ade18f373447539c1"
    static let productionHobbiesTargetID = "source-atlas-refresh-target.hobbies_recreation.stable.20260628T000000Z"
    static let productionHobbiesPackID = "source-atlas/v1/domain/hobbies_recreation/20260628T000000Z"
    static let productionHobbiesPackSHA256 = "7768a3f7867ddb9f184c16989ebd7444c31c7053bfbd4375198a0f6199eb7638"
    static let productionHealthTargetID = "source-atlas-refresh-target.health_wellness_reference.stable.20260628T000000Z"
    static let productionHealthPackID = "source-atlas/v1/domain/health_wellness_reference/20260628T000000Z"
    static let productionHealthPackSHA256 = "b84001256a9bbb06c26e1656bb04a04217078ce77d7790aaab41656dd67ea301"
    static let productionStatCanHealthStatisticsTargetID = "source-atlas-refresh-target.health_wellness_reference_ca_statistics.stable.20260628T000000Z"
    static let productionStatCanHealthStatisticsPackID = "source-atlas/v1/domain/health_wellness_reference_ca_statistics/20260628T000000Z"
    static let productionStatCanHealthStatisticsPackSHA256 = "30c129cc7cbd0ff1027cc57a6f611579a5c1562a91fe929440857e01bc6981ee"
    static let productionTravelTargetID = "source-atlas-refresh-target.travel_relocation.stable.20260628T000000Z"
    static let productionTravelPackID = "source-atlas/v1/domain/travel_relocation/20260628T000000Z"
    static let productionTravelPackSHA256 = "ab6f77b1c8ba9c4c7667334b01f16080c0412c621f2055d473468a6625a7483f"
    static let productionFinanceTargetID = "source-atlas-refresh-target.finance_public_reference.stable.20260628T000000Z"
    static let productionFinancePackID = "source-atlas/v1/domain/finance_public_reference/20260628T000000Z"
    static let productionFinancePackSHA256 = "ca23807f8cae55bf052600a90ca205ff3436f987e5d97f8518e96cd300bd0c19"
    static let productionHomeLifeAdminTargetID = "source-atlas-refresh-target.home_life_admin.stable.20260628T000000Z"
    static let productionHomeLifeAdminPackID = "source-atlas/v1/domain/home_life_admin/20260628T000000Z"
    static let productionHomeLifeAdminPackSHA256 = "e732019e96231678955e6a45665f245159f45fc57563b75bd1ddc4c2734212ee"
    static let productionVolunteeringTargetID = "source-atlas-refresh-target.volunteering_public_reference.stable.20260628T180600Z"
    static let productionVolunteeringPackID = "source-atlas/v1/domain/volunteering_public_reference/20260628T180600Z"
    static let productionVolunteeringPackSHA256 = "7483b6e19f2ae712bd0936c0855f8072ce3fd0e650baf6bee5f7fcf1a433dd45"
    static let sportsManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
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

    static func repository() throws -> SourceAtlasPublicPackCacheFileRepository {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("source-atlas-lifecycle-refresh-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return SourceAtlasPublicPackCacheFileRepository(rootDirectory: root)
    }

    static func seededRepository(fixture: RemoteNativeFixture) throws -> SourceAtlasPublicPackCacheFileRepository {
        let repository = try repository()
        let onlineResolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: sportsManifestRequest,
                targetPackID: fixture.pack.id,
                fetchedCurrentPointerData: fixture.pointerData,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                accessDecision: access(networkReachability: .online),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: checkedAt
            )
        )
        let journalRecord = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: sportsManifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: [
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .manifest,
                        objectKey: fixture.manifestKey
                    ),
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .pack,
                        objectKey: fixture.packObjectKey
                    ),
                ],
                fetchResolution: onlineResolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                committedAt: checkedAt
            )
        )
        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: fixture.packData
            )
        )
        XCTAssertEqual(result.status, .persistedCurrent)
        return repository
    }

    static func approvedEntry(
        id: String,
        targetPackID: String,
        allowedModes: Set<SourceAtlasPublicPackLifecycleRefreshMode>
    ) -> SourceAtlasPublicPackRefreshTargetRegistryEntry {
        SourceAtlasPublicPackRefreshTargetRegistryEntry(
            target: SourceAtlasPublicPackLifecycleRefreshTarget(
                id: id,
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                publicLocale: "en-US",
                targetPackID: targetPackID
            ),
            allowedModes: allowedModes,
            status: .active,
            reviewArtifactID: approvalArtifactID,
            nonClaims: [
                "not a final user plan",
                "not a Step generator",
                "not legal approval",
            ]
        )
    }

    static func remoteNativeFixture() throws -> RemoteNativeFixture {
        let currentPointerKey = "source-atlas/v1/staging/stable/sports/current.json"
        let manifestKey = "source-atlas/v1/staging/stable/sports/20260627T000000Z/manifest.json"
        let packObjectKey = "source-atlas/v1/staging/stable/sports/20260627T000000Z/pack.json"
        let pack = pack(id: "source-atlas/v1/domain/sports/20260627T000000Z")
        let packData = try encoded(pack)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let manifestData = publishedManifestData(
            packID: pack.id,
            packObjectKey: packObjectKey,
            packSHA256: packSHA256
        )
        let pointerData = publishedPointerData(
            packID: pack.id,
            manifestKey: manifestKey,
            manifestSHA256: SourceAtlasStore.sha256Hex(for: manifestData),
            packSHA256: packSHA256
        )
        return RemoteNativeFixture(
            currentPointerKey: currentPointerKey,
            manifestKey: manifestKey,
            packObjectKey: packObjectKey,
            pack: pack,
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
              "channel": "stable",
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
              "manifest_id": "source_atlas_pack_manifest.lifecycle_refresh_test",
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

    static func access(networkReachability: SourceAtlasNetworkReachability) -> SourceAtlasAccessDecision {
        SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: networkReachability,
                cachedPublicArtifactAvailable: false,
                bundledPublicArtifactAvailable: false
            )
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    static func pack(id: String) -> SourceAtlasPack {
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
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.current",
                    title: "Review public rule",
                    stepCandidateSeed: "Review the public rule.",
                    storesFinalSchedule: false
                ),
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof.requirement.current",
                    requirementID: "requirement.current",
                    proofDescription: "Public source proof.",
                    privacyClass: .externalRedacted,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: "sports.public.rules",
                    sourceRecordIDs: ["source.official"],
                    sourceClaimIDs: ["claim.current"]
                ),
            ],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "sports",
                    requiredPackIDs: [id],
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
