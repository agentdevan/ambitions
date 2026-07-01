import XCTest
@testable import Ambitions

final class SourceAtlasOfflineNoAccountPlanningScaleTests: XCTestCase {
    func testLaunchFloorRequestEnvelopeKeepsFiftyThousandLawfulNoAccountShapesPublic() throws {
        var domainIDs: Set<String> = []
        var subdomainIDs: Set<String> = []
        var requestFingerprints: Set<String> = []
        var invalidSamples: [String] = []
        var privateFindingTokens: Set<String> = []
        var privateMarkerHits: [String] = []

        for index in 0..<50_000 {
            let domainID = "public_domain_\(index % 500)"
            let subdomainID = "public_subdomain_\(index % 5_000)"
            let request = SourceAtlasPublicPlanningContextRequest(
                domainID: domainID,
                targetPackID: "source-atlas/v1/domain/\(domainID)/\(subdomainID)/pack-\(index)",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                publicLocale: "en-US",
                publicJurisdiction: "US",
                requirementID: "requirement.public.\(subdomainID)",
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskClass: .lowRiskSkill
            )
            let inspected = request.egressRecord.inspectedValue

            if request.validationIssues.isEmpty == false {
                invalidSamples.append("\(index):\(request.validationIssues.map(\.rawValue).joined(separator: ","))")
            }
            if request.query.goalIntent != nil {
                invalidSamples.append("\(index):goal_intent_present")
            }
            privateFindingTokens.formUnion(
                SourceAtlasNoPrivateGraphEgressAudit
                    .validate([request.egressRecord])
                    .map(\.forbiddenToken)
            )
            for marker in Self.forbiddenRuntimeMarkers where inspected.localizedCaseInsensitiveContains(marker) {
                privateMarkerHits.append("\(index):\(marker)")
            }

            domainIDs.insert(domainID)
            subdomainIDs.insert(subdomainID)
            requestFingerprints.insert(inspected)
        }

        XCTAssertEqual(domainIDs.count, 500)
        XCTAssertEqual(subdomainIDs.count, 5_000)
        XCTAssertEqual(requestFingerprints.count, 50_000)
        XCTAssertEqual(invalidSamples, [])
        XCTAssertEqual(privateFindingTokens, [])
        XCTAssertEqual(privateMarkerHits, [])
    }

    func testOfflineNoAccountBundledAndLastKnownGoodBatchFeedsLocalPlanningWithoutPrivateEgress() throws {
        let bridge = SourceAtlasStepCandidateFieldBridge()
        var replayFingerprints: Set<String> = []
        var privateMarkerHits: [String] = []

        for index in 0..<64 {
            let useLastKnownGood = index.isMultiple(of: 2) == false
            let pack = Self.pack(index: index)
            let packData = try Self.encoded(pack)
            let entry = Self.entry(packID: pack.id, data: packData, includeRollback: useLastKnownGood)
            let access = Self.offlineNoAccountAccess(
                bundledAvailable: useLastKnownGood == false,
                lastKnownGoodAvailable: useLastKnownGood
            )
            let output = SourceAtlasVerifiedPublicPackProvider().publicPlanningContext(
                SourceAtlasVerifiedPublicPackProviderInput(
                    request: Self.request(for: pack, index: index),
                    cachedManifest: Self.manifest(entry: entry),
                    bundledPayload: useLastKnownGood ? nil : Self.payload(data: packData, source: .bundled),
                    lastKnownGoodPayload: useLastKnownGood ? Self.payload(data: packData, source: .lastKnownGood) : nil,
                    accessDecision: access,
                    checkedAt: Self.checkedAt
                )
            )

            XCTAssertEqual(output.requestIssues, [])
            XCTAssertEqual(output.egressFindings, [])
            XCTAssertEqual(output.fetchStatus, .usingLocalFallback)
            XCTAssertFalse(access.coreLocalPlanningBlocked)
            let context = try XCTUnwrap(output.context)
            XCTAssertEqual(context.useMode, .reviewOnlyReference)
            XCTAssertEqual(context.availability.selectedStoreSource, useLastKnownGood ? .lastKnownGood : .bundled)
            XCTAssertEqual(context.availability.isLastKnownGood, useLastKnownGood)
            XCTAssertTrue(context.availability.isLocalFallback)
            XCTAssertFalse(context.availability.canSupportCurrentPublicReferenceUse)
            XCTAssertFalse(context.availability.localPlanningBlocked)
            XCTAssertTrue(context.canInformLocalPlanning)

            let bridged = bridge.expandVerifiedPublicPlanningContext(
                providerOutput: output,
                composition: Self.composition(for: pack, index: index),
                pack: pack,
                generatedAt: Self.generatedAt,
                goalID: "local.goal.\(index)",
                candidateLimit: 8
            )

            XCTAssertEqual(bridged.issues, [])
            XCTAssertTrue(bridged.canUseSourceAtlasCandidates)
            XCTAssertEqual(bridged.shardInfluence?.selectedPackID, pack.id)
            XCTAssertTrue(bridged.field.sourceProvenance.contains(.sourceAtlasPack))
            XCTAssertEqual(bridged.receipts.map(\.kind), [.sourceAtlasPublicContextVerified, .sourceAtlasPublicContextApplied])
            XCTAssertTrue(bridged.receipts.flatMap(\.details).contains("source-atlas-final-step-owner=false"))
            XCTAssertTrue(bridged.receipts.flatMap(\.details).contains("source-atlas-final-schedule-owner=false"))
            replayFingerprints.insert(bridged.deterministicReplayFingerprint)

            privateMarkerHits.append(contentsOf: Self.privateMarkers(in: try Self.encodedString(output), index: index))
            privateMarkerHits.append(contentsOf: Self.privateMarkers(in: try Self.encodedString(bridged), index: index))
        }

        XCTAssertEqual(replayFingerprints.count, 64)
        XCTAssertEqual(privateMarkerHits, [])
    }

    func testRevokedStaleMissingAndUnsafeProviderOutputsFailClosedBeforeSourceAtlasCandidates() throws {
        let safePack = Self.pack(index: 900)
        let safeComposition = Self.composition(for: safePack, index: 900)
        let bridge = SourceAtlasStepCandidateFieldBridge()
        let cases: [FailClosedCase] = [.revoked, .staleCritical, .missing, .unsafeRequest]

        for failCase in cases {
            let output = try Self.providerOutput(for: failCase, pack: safePack)
            let bridged = bridge.expandVerifiedPublicPlanningContext(
                providerOutput: output,
                composition: safeComposition,
                pack: safePack,
                generatedAt: Self.generatedAt,
                goalID: "local.failclosed.\(failCase.rawValue)",
                candidateLimit: 4
            )

            XCTAssertNil(output.context)
            XCTAssertFalse(output.canProvidePublicPlanningContext)
            XCTAssertFalse(bridged.canUseSourceAtlasCandidates)
            XCTAssertNil(bridged.shardInfluence)
            XCTAssertNil(bridged.field.sourceAtlasExpansionTrace)
            XCTAssertFalse(bridged.field.sourceProvenance.contains(.sourceAtlasPack))
            XCTAssertEqual(bridged.field.selectedCandidate?.kind, .fallback)
            XCTAssertEqual(bridged.receipts.map(\.kind), [.sourceAtlasPublicContextRejected])

            switch failCase {
            case .revoked:
                XCTAssertEqual(output.fetchStatus, .quarantined)
                XCTAssertTrue(output.cacheIssues.contains(.revokedByManifest))
                XCTAssertEqual(output.egressFindings, [])
                XCTAssertEqual(Self.privateMarkers(in: try Self.encodedString(output), index: 0), [])
            case .staleCritical:
                XCTAssertEqual(output.fetchStatus, .quarantined)
                XCTAssertTrue(output.cacheIssues.contains(.staleCriticalByManifest))
                XCTAssertEqual(output.egressFindings, [])
                XCTAssertEqual(Self.privateMarkers(in: try Self.encodedString(output), index: 0), [])
            case .missing:
                XCTAssertEqual(output.fetchStatus, .unavailable)
                XCTAssertTrue(output.fetchIssues.contains(.manifestUnavailable))
                XCTAssertEqual(output.egressFindings, [])
                XCTAssertEqual(Self.privateMarkers(in: try Self.encodedString(output), index: 0), [])
            case .unsafeRequest:
                XCTAssertEqual(output.requestIssues, [.unsafePublicSelector])
                XCTAssertEqual(output.fetchStatus, .quarantined)
                XCTAssertEqual(output.fetchIssues, [.privateEgressFinding])
                XCTAssertEqual(Set(output.egressFindings.map(\.forbiddenToken)), ["goal_text"])
                XCTAssertFalse(try Self.encodedString(output).contains("account_id"))
                XCTAssertFalse(try Self.encodedString(output).contains("device_id"))
            }
        }
    }
}

private extension SourceAtlasOfflineNoAccountPlanningScaleTests {
    enum FailClosedCase: String, CaseIterable {
        case revoked
        case staleCritical
        case missing
        case unsafeRequest
    }

    static let checkedAt = Date(timeIntervalSince1970: 1_780_100_000)
    static let generatedAt = "2026-07-01T12:30:00Z"
    static let forbiddenRuntimeMarkers = [
        "account_id",
        "device_id",
        "user_id",
        "capture_text",
        "private_life_graph",
        "PRIVATE-GOAL-TEXT"
    ]

    static func offlineNoAccountAccess(
        bundledAvailable: Bool,
        lastKnownGoodAvailable: Bool
    ) -> SourceAtlasAccessDecision {
        SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: lastKnownGoodAvailable,
                bundledPublicArtifactAvailable: bundledAvailable
            )
        )
    }

    static func providerOutput(
        for failCase: FailClosedCase,
        pack: SourceAtlasPack
    ) throws -> SourceAtlasVerifiedPublicPackProviderOutput {
        let packData = try encoded(pack)
        let access = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: failCase == .missing ? .offline : .online,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: false,
                bundledPublicArtifactAvailable: false
            )
        )
        let request = failCase == .unsafeRequest
            ? SourceAtlasPublicPlanningContextRequest(
                domainID: "goal_text",
                targetPackID: pack.id,
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0"
            )
            : Self.request(for: pack, index: 900)
        let manifestEntry: SourceAtlasFreshnessPackEntry
        switch failCase {
        case .revoked:
            manifestEntry = entry(packID: pack.id, data: packData, claimState: .revoked)
        case .staleCritical:
            manifestEntry = entry(packID: pack.id, data: packData, claimState: .stale)
        case .missing, .unsafeRequest:
            manifestEntry = entry(packID: pack.id, data: packData)
        }

        return SourceAtlasVerifiedPublicPackProvider().publicPlanningContext(
            SourceAtlasVerifiedPublicPackProviderInput(
                request: request,
                fetchedManifestData: failCase == .missing ? nil : try encoded(manifest(entry: manifestEntry)),
                downloadedPackData: failCase == .missing ? nil : packData,
                accessDecision: access,
                checkedAt: checkedAt
            )
        )
    }

    static func request(for pack: SourceAtlasPack, index: Int) -> SourceAtlasPublicPlanningContextRequest {
        SourceAtlasPublicPlanningContextRequest(
            domainID: pack.manifest.domainID,
            targetPackID: pack.id,
            channel: "stable",
            schemaVersion: "1.0.0",
            appVersion: "1.0",
            publicLocale: "en-US",
            publicJurisdiction: "US",
            requirementID: "requirement.public.\(index)",
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskClass: .lowRiskSkill
        )
    }

    static func manifest(entry: SourceAtlasFreshnessPackEntry) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "source-atlas/v1/production/stable/\(entry.packID.replacingOccurrences(of: "/", with: "_"))/manifest.json",
            publishedAt: checkedAt,
            packIndex: [entry]
        )
    }

    static func entry(
        packID: String,
        data: Data,
        includeRollback: Bool = false,
        claimState: SourceAtlasFreshnessBrokerClaimState? = nil
    ) -> SourceAtlasFreshnessPackEntry {
        let hash = SourceAtlasStore.sha256Hex(for: data)
        return SourceAtlasFreshnessPackEntry(
            packID: packID,
            currentSHA256: hash,
            currentSignature: "signature",
            rollbackPointers: includeRollback ? ["previous": hash] : [:],
            claimStateBuckets: claimState.map {
                [
                    SourceAtlasFreshnessBrokerClaimStateBucket(
                        state: $0,
                        claimIDs: ["claim.public.blocked"]
                    )
                ]
            } ?? []
        )
    }

    static func payload(
        data: Data,
        source: SourceAtlasStorePayloadSource
    ) -> SourceAtlasStorePayload {
        SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func pack(index: Int) -> SourceAtlasPack {
        let domainID = "public_domain_\(index % 500)"
        let packID = "source-atlas/v1/domain/\(domainID)/pack-public-\(index)"
        let sourceID = "source.public.\(index)"
        let claimID = "claim.public.\(index)"
        let requirementID = "requirement.public.\(index)"
        let starterID = "starter.public.\(index)"
        let proofID = "proof.public.\(index)"
        let nodeID = "node.public.\(index)"
        let claim = SourceAtlasClaim(
            id: claimID,
            text: "Official public reference \(index) can inform local planning.",
            state: .official,
            freshness: .current,
            riskClass: .lowRiskSkill,
            sourceIDs: [sourceID],
            reviewRequired: false
        )
        let requirement = SourceAtlasRequirement(
            id: requirementID,
            claimID: claimID,
            title: "Review public reference \(index).",
            kind: .proof,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: packID,
                title: "Public No-Account Pack \(index)",
                kind: .domainPack,
                version: "1.0.0",
                domainID: domainID
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: sourceID,
                    title: "Official public source \(index)",
                    kind: .official,
                    locator: "https://example.test/public/\(index)",
                    retrievedAt: "2026-07-01T00:00:00Z",
                    contentHash: "hash-\(index)",
                    approvedForOfficialClaims: true
                )
            ],
            claims: [claim],
            requirements: [requirement],
            starterItems: [
                SourceAtlasStarterItem(
                    id: starterID,
                    title: "Review public source \(index)",
                    stepCandidateSeed: "Review public source \(index) before choosing a local action.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: proofID,
                    requirementID: requirementID,
                    proofDescription: "Public source \(index) should be reviewed as reference evidence.",
                    privacyClass: .externalRedacted,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: nodeID,
                    sourceRecordIDs: [sourceID],
                    sourceClaimIDs: [claimID]
                )
            ],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Public reference is needed.",
                reviewRequired: "Review the public reference before current use.",
                notProfessionalAdvice: "Public reference only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [nodeID],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["projection.public.\(index)"],
                ownsIndividualGoalPhrase: false
            )
        )
    }

    static func composition(for pack: SourceAtlasPack, index: Int) -> PersonalPathComposition {
        let requirementIDs = pack.requirements.map(\.id)
        let nodeID = "node.public.\(index)"
        let path = SourceAtlasCapabilityPath(
            id: "path.public.\(index)",
            capabilityGraphID: "graph.public.\(index)",
            selectedNodeIDs: [nodeID],
            selectedEdgeIDs: [],
            selectedPathOverlayIDs: [],
            selectedRoleOverlayIDs: [],
            traversalTrace: ["selected public reference node \(index)"],
            blockedNodes: [],
            staleNodes: [],
            missingSourceNodes: [],
            requirementProjection: SourceAtlasRequirementProjection(
                requirements: pack.requirements,
                sourceFreshnessSummary: []
            ),
            score: 0.9,
            pathSummary: "Use public reference \(index) as local planning context.",
            planSkeleton: PlanSkeleton(
                milestones: [
                    PlanSkeletonMilestone(
                        id: "milestone.public.\(index)",
                        title: "Review public reference",
                        detail: "Use the public reference before local execution.",
                        orderIndex: 0,
                        kind: .proof,
                        requirementIDs: requirementIDs,
                        nodeIDs: [nodeID],
                        proofRequired: true,
                        reviewRequired: false
                    )
                ],
                phases: [
                    PlanSkeletonPhase(
                        id: "phase.public.\(index)",
                        title: "Reference",
                        detail: "Confirm public context.",
                        orderIndex: 0,
                        milestoneIDs: ["milestone.public.\(index)"],
                        pathNodeIDs: [nodeID],
                        riskFlagIDs: []
                    )
                ],
                weeklyCadence: PlanSkeletonWeeklyCadence(
                    summary: "Review public context before local action.",
                    anchorDays: ["midweek"],
                    proofTouchpoints: ["Review public reference"],
                    reviewTouchpoints: []
                ),
                proofMoments: [
                    PlanSkeletonProofMoment(
                        id: "proof-moment.public.\(index)",
                        title: "Check public source",
                        detail: "Use the public source as reference evidence.",
                        orderIndex: 0,
                        requirementIDs: requirementIDs,
                        nodeIDs: [nodeID]
                    )
                ],
                reviewMoments: [],
                recoveryWindows: [],
                riskFlags: [],
                feasibilityBand: .comfortablyOnTrack
            )
        )

        return PersonalPathComposition(
            goalID: "local.goal.\(index)",
            userContextVersion: "local-context.v1",
            sourceAtlasProjectionID: "source-atlas.public.projection.\(index)",
            pathInstances: [path],
            alternativePathSet: nil,
            selectedPath: path,
            rejectedPaths: [],
            pathTradeoffs: [],
            explanationProjection: SourceAtlasPathCompositionExplanationProjection(
                summary: "Local runtime uses public reference context.",
                sourceLabels: ["Public Source Atlas Pack"],
                whyThisChangesPlans: ["Public source requirements inform candidate generation."],
                confidenceLabel: "Public reference available"
            )
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    static func encodedString<T: Encodable>(_ value: T) throws -> String {
        String(data: try encoded(value), encoding: .utf8) ?? ""
    }

    static func privateMarkers(in text: String, index: Int) -> [String] {
        forbiddenRuntimeMarkers.compactMap { marker in
            text.localizedCaseInsensitiveContains(marker) ? "\(index):\(marker)" : nil
        }
    }
}
