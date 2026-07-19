import XCTest
@testable import Ambitions

final class SourceAtlasPackFactoryModelsTests: XCTestCase {
    private let factory = SourceAtlasPackFactoryLite()

    func testJSONFixtureBuildsValidatedComposablePack() throws {
        let pack = Self.composablePack()
        let data = try Self.jsonData(for: pack)

        let decoded = try factory.makePack(from: data, format: .json)

        XCTAssertEqual(decoded, pack)
        XCTAssertTrue(decoded.runtimeBoundary.isValueModelOnly)
        XCTAssertTrue(decoded.validationIssues.isEmpty)
        XCTAssertTrue(decoded.isValidForRuntimeUse)
        XCTAssertNoThrow(try decoded.validatedForUse())
        XCTAssertTrue(decoded.projections.first?.canDriveCurrentProjection ?? false)
        XCTAssertTrue(decoded.claims.contains(where: { $0.state == .sourceNeeded }))
        XCTAssertTrue(decoded.claims.contains(where: { $0.state == .stale }))
        XCTAssertTrue(decoded.claims.contains(where: { $0.state == .unknown }))
        XCTAssertTrue(decoded.claims.contains(where: { $0.state == .contradicted }))
        XCTAssertTrue(decoded.claims.contains(where: { $0.state == .revoked }))
        XCTAssertTrue(decoded.claims.contains(where: { $0.state == .verifiedByLocalProof }))
    }

    func testYAMLCompatibleFixtureBuildsTheSameValidatedPack() throws {
        let pack = Self.yamlComposablePack()
        let yamlCompatibleFixture = Self.yamlData(for: pack)

        let decoded = try factory.makePack(
            from: yamlCompatibleFixture,
            format: .yaml
        )

        XCTAssertEqual(decoded, pack)
        XCTAssertEqual(decoded.claims.map(\.state), pack.claims.map(\.state))
        XCTAssertEqual(decoded.requirements.first?.sourceState, .officialCurrent)
        XCTAssertEqual(decoded.domainPacks.first?.state, .official)
        XCTAssertEqual(decoded.capabilityGraphs.first?.ladders.first?.pathOverlays.first?.state, .official)
    }

    func testBlockedRequirementStatesRemainExplicitAndBlockCurrentProjection() throws {
        let pack = Self.composablePack(
            requirementSourceState: .sourceNeeded,
            requirementFreshnessState: .unknown,
            requirementReviewState: .required,
            requirementRiskState: .unknown
        )
        let decoded = try factory.decodePack(from: Self.jsonData(for: pack), format: .json)

        XCTAssertEqual(decoded.requirements.first?.sourceState, .sourceNeeded)
        XCTAssertEqual(decoded.requirements.first?.freshnessState, .unknown)
        XCTAssertEqual(decoded.requirements.first?.reviewState, .required)
        XCTAssertEqual(decoded.requirements.first?.riskState, .unknown)
        XCTAssertFalse(decoded.requirements.first?.canDriveCurrentRecommendation ?? true)
        XCTAssertTrue(factory.validate(decoded).contains(.invalidRequirementOverlay))
    }

    func testOfficialCurrentClaimsRequireApprovedOfficialSourceProvenance() throws {
        let pack = Self.composablePack(
            officialSourceKind: .candidate,
            officialSourceApprovedForOfficialClaims: false
        )

        XCTAssertThrowsError(try factory.makePack(from: Self.jsonData(for: pack), format: .json)) { error in
            guard case let SourceAtlasPackFactoryLiteError.validationFailed(issues) = error else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertEqual(issues, [.officialClaimWithoutApprovedSource])
        }
    }

    func testPackFactoryRemainsValueModelOnlyAndDoesNotEmitConfidenceReleaseOrModelReadyLanguage() throws {
        let pack = Self.composablePack()
        let decoded = try factory.makePack(from: Self.jsonData(for: pack), format: .json)
        let encoded = String(decoding: try JSONEncoder().encode(decoded), as: UTF8.self).lowercased()

        XCTAssertTrue(decoded.runtimeBoundary.isValueModelOnly)
        XCTAssertFalse(encoded.contains("confidence"))
        XCTAssertFalse(encoded.contains("release"))
        XCTAssertFalse(encoded.contains("model-ready"))
    }

    func testUnsupportedYAMLFeaturesAreRejected() {
        let yaml = """
        manifest:
          id: sports.pickleball.domain
          title: Pickleball Domain
          kind: domain_pack
          version: 1.0.0
          domainID: sports
          schemaVersion: source_atlas_pack.native.v1
        sources: []
        """

        XCTAssertThrowsError(try factory.decodePack(from: Data(yaml.utf8), format: .yaml)) { error in
            guard case let SourceAtlasPackFactoryLiteError.unsupportedYAMLFeature(feature) = error else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertEqual(feature, "flow-style")
        }
    }
}

private extension SourceAtlasPackFactoryModelsTests {
    static func jsonData(for pack: SourceAtlasPack) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(pack)
    }

    static func yamlData(for pack: SourceAtlasPack) -> Data {
        let yaml = """
        manifest:
          id: \(pack.manifest.id)
          title: \(pack.manifest.title)
          kind: \(pack.manifest.kind.rawValue)
          version: \(pack.manifest.version)
          domainID: \(pack.manifest.domainID)
          specificDomainID: null
          schemaVersion: \(pack.manifest.schemaVersion)
          classification: \(pack.manifest.classification)
          productionUse: \(pack.manifest.productionUse)
          canonDocumentIDs:
            - docs/canon/Ambitions_Source_Atlas.md
            - docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md
            - docs/codex/SOURCE_ATLAS_GATE_MATRIX.md
        sources:
          - id: source-official-rules
            title: Official pickleball rules
            kind: official
            locator: https://example.test/pickleball/rules
            retrievedAt: 2026-05-15T04:00:00Z
            contentHash: sha256:official-rules
            approvedForOfficialClaims: true
        claims:
          - id: claim-serve
            text: Serve rules are source-backed and current.
            state: official
            freshness: current
            riskClass: hobby
            sourceIDs:
              - source-official-rules
            reviewRequired: false
          - id: claim-source-needed
            text: This claim still needs a source.
            state: source_needed
            freshness: unknown
            riskClass: hobby
            sourceIDs:
            reviewRequired: true
          - id: claim-stale
            text: This claim is stale.
            state: stale
            freshness: stale
            riskClass: hobby
            sourceIDs:
              - source-official-rules
            reviewRequired: true
          - id: claim-unknown
            text: This claim is unknown.
            state: unknown
            freshness: unknown
            riskClass: hobby
            sourceIDs:
            reviewRequired: true
          - id: claim-contradicted
            text: This claim is contradicted.
            state: contradicted
            freshness: disputed
            riskClass: hobby
            sourceIDs:
              - source-official-rules
            reviewRequired: true
          - id: claim-revoked
            text: This claim is revoked.
            state: revoked
            freshness: revoked
            riskClass: hobby
            sourceIDs:
              - source-official-rules
            reviewRequired: true
          - id: claim-local-proof
            text: This claim is verified by local proof.
            state: verified_by_local_proof
            freshness: current
            riskClass: hobby
            sourceIDs:
              - source-official-rules
            reviewRequired: true
        requirements:
          - id: requirement-serve
            claimID: claim-serve
            title: Serve rules must stay current.
            kind: hard
            required: true
            sourceState: official_current
            freshnessState: current
            riskState: low
            reviewState: approved
        starterItems:
          - id: starter-pickleball
            title: Serve starter
            stepCandidateSeed: Practice serve mechanics.
            storesFinalSchedule: false
        proofMap:
          - id: proof-serve
            requirementID: requirement-serve
            capabilityNodeID: null
            proofDescription: Official pickleball rules prove the serve requirement.
            privacyClass: private
            proofCandidate: source_evidence
            proofStrength: official_certified
            sourceRecordIDs:
              - source-official-rules
            sourceClaimIDs:
              - claim-serve
            correctionHookIDs:
            revocationHookIDs:
            evidenceLedgerBridgeIDs:
        projections:
          - id: projection-pickleball-serve
            goalIntent: improve-pickleball-serve
            requiredPackIDs:
              - sports.pickleball.domain
            projectionProfiles:
              - id: profile-pickleball-serve
                profileTitle: Serve profile
                sourceState: official_current
                freshnessState: current
                riskState: low
                reviewState: approved
                producesPersonalPathInstance: true
                producesProjectionReceipt: true
                optionValueMap:
                  id: option-map-pickleball-serve
                  values:
                    stillCounts: practice serve
                  sourceState: official_current
                  freshnessState: current
                  reviewState: approved
                  riskState: low
                personalPathInstances:
                  - id: path-instance-pickleball-serve
                    personalPathTemplateID: path-pickleball-serve
                    stepCandidateSeeds:
                      - id: seed-pickleball-serve
                        stepCandidate: Practice serve mechanics for ten minutes.
                        storesFinalSchedule: false
                    sourceState: official_current
                    freshnessState: current
                    reviewState: approved
                    riskState: low
                    sourceRecordIDs:
                      - source-official-rules
                alternativePathSet: null
        freshnessPolicy:
          reviewIntervalDays: 180
          staleBlocksHighRiskUse: true
        riskPolicy:
          strictReviewRiskClasses:
            - education_eligibility
            - certification_eligibility
            - legal_civic
            - financial
            - health_medical
            - crisis_safety
            - minor_student_data
            - professional_boundary
            - deadline_sensitive
            - sensitive_private
        disclosureCopy:
          sourceNeeded: Needs a source before it can be reused.
          reviewRequired: Needs review before it can be reused.
          notProfessionalAdvice: Local-only guidance.
        runtimeBoundary:
          storesUserData: false
          performsNetworkFetches: false
          mutatesPlans: false
          writesPersistence: false
        composition:
          dependencyPackIDs:
          reusableNodeIDs:
            - pickleball.serve
            - pickleball.return
          overlayDependencyIDs:
            - sports.pickleball.domain
          projectionRecipeIDs:
            - recipe-pickleball-serve
          ownsIndividualGoalPhrase: false
          requirementOverlays:
            - id: overlay-pickleball-serve
              sourceAtlasRequirementID: requirement-serve
              requirementIDs:
                - requirement-serve
              summary: Serve requirement stays source-backed.
              sourceState: official_current
              freshnessState: current
              riskState: low
              reviewState: approved
        domainPacks:
          - id: sports.pickleball.domain
            title: Pickleball domain pack
            domainID: sports
            capabilityGraphIDs:
              - graph-pickleball
            specificDomainPackIDs:
              - sports.pickleball.specific
            reusableNodeIDs:
              - pickleball.return
              - pickleball.serve
            sourceSliceIDs:
              - source-official-rules
            state: official
            freshness: current
            riskClass: hobby
            reviewRequired: false
        specificDomainPacks:
          - id: sports.pickleball.specific
            title: Pickleball specific pack
            domainPackID: sports.pickleball.domain
            capabilityGraphID: graph-pickleball
            skillSliceIDs:
              - sports.pickleball.serve
            roleOverlayIDs:
              - role-athlete
            pathOverlayIDs:
              - path-pickleball-serve
            state: official
            freshness: current
            riskClass: hobby
            reviewRequired: false
            sourceSliceIDs:
              - source-official-rules
        capabilityGraphs:
          - id: graph-pickleball
            title: Pickleball capability graph
            domainPackID: sports.pickleball.domain
            capabilityNodeIDs:
              - pickleball.return
              - pickleball.serve
            capabilityEdgeIDs:
              - serve-to-return
            levelLadderIDs:
              - ladder-pickleball
            roleOverlayIDs:
              - role-athlete
            nodes:
              - id: pickleball.serve
                capabilityGraphID: graph-pickleball
                title: Serve
                summary: Serve mechanics and timing.
                sourceRecordIDs:
                  - source-official-rules
                state: official
                freshness: current
                riskClass: hobby
                reviewRequired: false
                linkedClaimIDs:
                  - claim-serve
              - id: pickleball.return
                capabilityGraphID: graph-pickleball
                title: Return
                summary: Return mechanics and positioning.
                sourceRecordIDs:
                  - source-official-rules
                state: official
                freshness: current
                riskClass: hobby
                reviewRequired: false
                linkedClaimIDs:
            edges:
              - id: serve-to-return
                capabilityGraphID: graph-pickleball
                sourceNodeID: pickleball.serve
                targetNodeID: pickleball.return
                kind: prerequisite
                state: official
                freshness: current
                riskClass: hobby
                reviewRequired: false
                roleOverlayIDs:
                  - role-athlete
                pathOverlayIDs:
                  - path-pickleball-serve
                sourceRecordIDs:
                  - source-official-rules
            ladders:
              - id: ladder-pickleball
                title: Pickleball ladder
                capabilityGraphID: graph-pickleball
                pathOverlays:
                  - id: path-pickleball-serve
                    title: Pickleball serve path
                    skillSliceID: sports.pickleball.serve
                    capabilityNodeIDs:
                      - pickleball.serve
                    pathPriority: 10
                    claimIDs:
                      - claim-serve
                    sourceRecordIDs:
                      - source-official-rules
                    state: official
                    freshness: current
                    riskClass: hobby
                    reviewRequired: false
                levelLabels:
                  - beginner
                  - recreational
            roleOverlays:
              - id: role-athlete
                roleID: athlete
                skillSliceID: sports.pickleball.serve
                reusableNodeIDs:
                  - pickleball.serve
                state: official
                freshness: current
                riskClass: hobby
                sourceIDs:
                  - source-official-rules
                reviewRequired: false
            state: official
            freshness: current
            riskClass: hobby
            reviewRequired: false
        """
        return Data(yaml.utf8)
    }

    static func yamlComposablePack() -> SourceAtlasPack {
        composablePack()
    }

    static func composablePack(
        officialSourceKind: SourceAtlasSourceKind = .official,
        officialSourceApprovedForOfficialClaims: Bool = true,
        requirementSourceState: SourceAtlasRequirementSourceState = .officialCurrent,
        requirementFreshnessState: SourceAtlasRequirementFreshnessState = .current,
        requirementReviewState: SourceAtlasRequirementReviewState = .approved,
        requirementRiskState: SourceAtlasRequirementRiskState = .low
    ) -> SourceAtlasPack {
        let officialSource = SourceAtlasSourceRecord(
            id: "source-official-rules",
            title: "Official pickleball rules",
            kind: officialSourceKind,
            locator: "https://example.test/pickleball/rules",
            retrievedAt: "2026-05-15T04:00:00Z",
            contentHash: "sha256:official-rules",
            approvedForOfficialClaims: officialSourceApprovedForOfficialClaims
        )

        let serveClaim = SourceAtlasClaim(
            id: "claim-serve",
            text: "Serve rules are source-backed and current.",
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: [officialSource.id],
            reviewRequired: false
        )
        let sourceNeededClaim = SourceAtlasClaim(
            id: "claim-source-needed",
            text: "This claim still needs a source.",
            state: .sourceNeeded,
            freshness: .unknown,
            riskClass: .hobby,
            sourceIDs: [],
            reviewRequired: true
        )
        let staleClaim = SourceAtlasClaim(
            id: "claim-stale",
            text: "This claim is stale.",
            state: .stale,
            freshness: .stale,
            riskClass: .hobby,
            sourceIDs: [officialSource.id],
            reviewRequired: true
        )
        let unknownClaim = SourceAtlasClaim(
            id: "claim-unknown",
            text: "This claim is unknown.",
            state: .unknown,
            freshness: .unknown,
            riskClass: .hobby,
            sourceIDs: [],
            reviewRequired: true
        )
        let contradictedClaim = SourceAtlasClaim(
            id: "claim-contradicted",
            text: "This claim is contradicted.",
            state: .contradicted,
            freshness: .disputed,
            riskClass: .hobby,
            sourceIDs: [officialSource.id],
            reviewRequired: true
        )
        let revokedClaim = SourceAtlasClaim(
            id: "claim-revoked",
            text: "This claim is revoked.",
            state: .revoked,
            freshness: .revoked,
            riskClass: .hobby,
            sourceIDs: [officialSource.id],
            reviewRequired: true
        )
        let localProofClaim = SourceAtlasClaim(
            id: "claim-local-proof",
            text: "This claim is verified by local proof.",
            state: .verifiedByLocalProof,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: [officialSource.id],
            reviewRequired: true
        )

        let requirement = SourceAtlasRequirement(
            id: "requirement-serve",
            claimID: serveClaim.id,
            title: "Serve rules must stay current.",
            kind: .hard,
            required: true,
            sourceState: requirementSourceState,
            freshnessState: requirementFreshnessState,
            riskState: requirementRiskState,
            reviewState: requirementReviewState
        )

        let proof = SourceAtlasProofMapEntry(
            id: "proof-serve",
            requirementID: requirement.id,
            proofDescription: "Official pickleball rules prove the serve requirement.",
            privacyClass: .privateLife,
            proofCandidate: .sourceEvidence,
            proofStrength: .officialCertified,
            sourceRecordIDs: [officialSource.id],
            sourceClaimIDs: [serveClaim.id]
        )

        let pathOverlay = SourceAtlasPathOverlay(
            id: "path-pickleball-serve",
            title: "Pickleball serve path",
            skillSliceID: "sports.pickleball.serve",
            capabilityNodeIDs: ["pickleball.serve"],
            pathPriority: 10,
            claimIDs: [serveClaim.id],
            sourceRecordIDs: [officialSource.id],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false
        )

        let roleOverlay = SourceAtlasRoleOverlay(
            id: "role-athlete",
            roleID: "athlete",
            skillSliceID: "sports.pickleball.serve",
            reusableNodeIDs: ["pickleball.serve"],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: [officialSource.id],
            reviewRequired: false
        )

        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-pickleball",
            title: "Pickleball ladder",
            capabilityGraphID: "graph-pickleball",
            pathOverlays: [pathOverlay],
            levelLabels: ["beginner", "recreational"]
        )

        let serveNode = SourceAtlasCapabilityNode(
            id: "pickleball.serve",
            capabilityGraphID: "graph-pickleball",
            title: "Serve",
            summary: "Serve mechanics and timing.",
            sourceRecordIDs: [officialSource.id],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false,
            linkedClaimIDs: [serveClaim.id]
        )
        let returnNode = SourceAtlasCapabilityNode(
            id: "pickleball.return",
            capabilityGraphID: "graph-pickleball",
            title: "Return",
            summary: "Return mechanics and positioning.",
            sourceRecordIDs: [officialSource.id],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false,
            linkedClaimIDs: []
        )
        let edge = SourceAtlasCapabilityEdge(
            id: "serve-to-return",
            capabilityGraphID: "graph-pickleball",
            sourceNodeID: serveNode.id,
            targetNodeID: returnNode.id,
            kind: .prerequisite,
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false,
            roleOverlayIDs: [roleOverlay.id],
            pathOverlayIDs: [pathOverlay.id],
            sourceRecordIDs: [officialSource.id]
        )

        let capabilityGraph = SourceAtlasCapabilityGraph(
            id: "graph-pickleball",
            title: "Pickleball capability graph",
            domainPackID: "sports.pickleball.domain",
            capabilityNodeIDs: [serveNode.id, returnNode.id],
            capabilityEdgeIDs: [edge.id],
            levelLadderIDs: [levelLadder.id],
            roleOverlayIDs: [roleOverlay.id],
            nodes: [serveNode, returnNode],
            edges: [edge],
            ladders: [levelLadder],
            roleOverlays: [roleOverlay],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false
        )

        let domainPack = SourceAtlasDomainPack(
            id: "sports.pickleball.domain",
            title: "Pickleball domain pack",
            domainID: "sports",
            capabilityGraphIDs: [capabilityGraph.id],
            specificDomainPackIDs: ["sports.pickleball.specific"],
            reusableNodeIDs: [serveNode.id, returnNode.id],
            sourceSliceIDs: [officialSource.id],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false
        )

        let specificDomainPack = SourceAtlasSpecificDomainPack(
            id: "sports.pickleball.specific",
            title: "Pickleball specific pack",
            domainPackID: domainPack.id,
            capabilityGraphID: capabilityGraph.id,
            skillSliceIDs: ["sports.pickleball.serve"],
            roleOverlayIDs: [roleOverlay.id],
            pathOverlayIDs: [pathOverlay.id],
            state: .official,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false,
            sourceSliceIDs: [officialSource.id]
        )

        let optionValueMap = SourceAtlasOptionValueMap(
            id: "option-map-pickleball-serve",
            values: ["stillCounts": "practice serve"],
            sourceState: .officialCurrent,
            freshnessState: .current,
            reviewState: .approved,
            riskState: .low
        )
        let personalPathInstance = SourceAtlasPersonalPathInstance(
            id: "path-instance-pickleball-serve",
            personalPathTemplateID: pathOverlay.id,
            stepCandidateSeeds: [
                SourceAtlasStepCandidateSeed(
                    id: "seed-pickleball-serve",
                    stepCandidate: "Practice serve mechanics for ten minutes."
                )
            ],
            sourceState: .officialCurrent,
            freshnessState: .current,
            reviewState: .approved,
            riskState: .low,
            sourceRecordIDs: [officialSource.id]
        )
        let profile = SourceAtlasProjectionProfile(
            id: "profile-pickleball-serve",
            profileTitle: "Serve profile",
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            producesPersonalPathInstance: true,
            producesProjectionReceipt: true,
            optionValueMap: optionValueMap,
            personalPathInstances: [personalPathInstance]
        )
        let projection = SourceAtlasGoalProjection(
            id: "projection-pickleball-serve",
            goalIntent: "improve-pickleball-serve",
            requiredPackIDs: [domainPack.id],
            projectionProfiles: [profile]
        )

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: domainPack.id,
                title: domainPack.title,
                kind: .domainPack,
                version: "1.0.0",
                domainID: domainPack.domainID
            ),
            sources: [officialSource],
            claims: [
                serveClaim,
                sourceNeededClaim,
                staleClaim,
                unknownClaim,
                contradictedClaim,
                revokedClaim,
                localProofClaim
            ],
            requirements: [requirement],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter-pickleball",
                    title: "Serve starter",
                    stepCandidateSeed: "Practice serve mechanics.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [proof],
            projections: [projection],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Needs a source before it can be reused.",
                reviewRequired: "Needs review before it can be reused.",
                notProfessionalAdvice: "Local-only guidance."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [serveNode.id, returnNode.id],
                overlayDependencyIDs: [domainPack.id],
                projectionRecipeIDs: ["recipe-pickleball-serve"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: [
                    SourceAtlasRequirementOverlay(
                        id: "overlay-pickleball-serve",
                        sourceAtlasRequirementID: requirement.id,
                        requirementIDs: [requirement.id],
                        summary: "Serve requirement stays source-backed.",
                        sourceState: .officialCurrent,
                        freshnessState: .current,
                        riskState: .low,
                        reviewState: .approved
                    )
                ]
            ),
            domainPacks: [domainPack],
            specificDomainPacks: [specificDomainPack],
            capabilityGraphs: [capabilityGraph]
        )
    }
}
