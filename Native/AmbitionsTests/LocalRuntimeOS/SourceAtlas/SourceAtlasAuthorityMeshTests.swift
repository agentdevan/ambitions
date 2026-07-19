import XCTest
@testable import Ambitions

final class SourceAtlasAuthorityMeshTests: XCTestCase {
    func testAcceptedAuthoritySupportsVisibleStepScheduleAndShare() {
        let result = Self.result(sourceIDs: ["source.official"])
        let inspection = SourceAtlasAuthorityMesh().inspect(
            SourceAtlasAuthorityMeshInput(
                queryResponse: Self.response(results: [result]),
                authorityRecords: [
                    Self.authority(sourceID: "source.official", jurisdictionIDs: ["us.ca"], shareRight: .publicExport)
                ],
                context: SourceAtlasAuthorityMeshContext(
                    action: .userControlledShare,
                    jurisdictionID: "US.CA",
                    shareScope: .userControlled
                )
            )
        )

        XCTAssertTrue(inspection.canSupportCurrentUse)
        XCTAssertTrue(inspection.selectedRow.canSupportVisibleStep)
        XCTAssertTrue(inspection.selectedRow.canInstallSchedule)
        XCTAssertTrue(inspection.selectedRow.canShare)
        XCTAssertTrue(inspection.selectedRow.issueCodes.isEmpty)
        XCTAssertEqual(inspection.selectedRow.authorityRecordIDs, ["authority.source.official"])
    }

    func testSourceRevocationEvidenceBlocksCurrentUse() {
        let result = Self.result(sourceIDs: ["source.official"])
        let inspection = SourceAtlasAuthorityMesh().inspect(
            SourceAtlasAuthorityMeshInput(
                queryResponse: Self.response(results: [result]),
                authorityRecords: [
                    Self.authority(sourceID: "source.official", state: .accepted, jurisdictionIDs: ["global"], shareRight: .publicExport)
                ],
                revocationEvidence: [
                    SourceAtlasAuthorityRevocationEvidence(
                        id: "revoke.source",
                        target: .source,
                        targetID: "source.official",
                        reason: "Superseded public source",
                        recordedAt: Self.checkedAt,
                        evidenceSourceIDs: ["source.notice"]
                    )
                ],
                context: SourceAtlasAuthorityMeshContext(action: .visibleStep)
            )
        )

        XCTAssertFalse(inspection.canSupportCurrentUse)
        XCTAssertEqual(inspection.selectedRow.issueCodes, ["source_revoked"])
        XCTAssertEqual(inspection.selectedRow.revocationEvidenceIDs, ["revoke.source"])
        XCTAssertEqual(inspection.activeRevocationEvidenceIDs, ["revoke.source"])
        XCTAssertEqual(inspection.blockedStepExamples, ["pack.sports::requirement.current:source_revoked"])
    }

    func testJurisdictionMismatchBlocksScheduleInstall() {
        let result = Self.result(sourceIDs: ["source.official"])
        let inspection = SourceAtlasAuthorityMesh().inspect(
            SourceAtlasAuthorityMeshInput(
                queryResponse: Self.response(results: [result]),
                authorityRecords: [
                    Self.authority(sourceID: "source.official", jurisdictionIDs: ["us.ny"], shareRight: .publicExport)
                ],
                context: SourceAtlasAuthorityMeshContext(action: .scheduleInstall, jurisdictionID: "us.ca")
            )
        )

        XCTAssertFalse(inspection.canSupportCurrentUse)
        XCTAssertFalse(inspection.selectedRow.canInstallSchedule)
        XCTAssertTrue(inspection.selectedRow.issueCodes.contains("jurisdiction_incompatible"))
    }

    func testLocalOnlyShareRightsStillAllowVisibleStepButBlockShare() {
        let result = Self.result(sourceIDs: ["source.official"])
        let inspection = SourceAtlasAuthorityMesh().inspect(
            SourceAtlasAuthorityMeshInput(
                queryResponse: Self.response(results: [result]),
                authorityRecords: [
                    Self.authority(sourceID: "source.official", jurisdictionIDs: ["global"], shareRight: .localOnly)
                ],
                context: SourceAtlasAuthorityMeshContext(
                    action: .userControlledShare,
                    shareScope: .userControlled
                )
            )
        )

        XCTAssertFalse(inspection.canSupportCurrentUse)
        XCTAssertTrue(inspection.selectedRow.canSupportVisibleStep)
        XCTAssertTrue(inspection.selectedRow.canInstallSchedule)
        XCTAssertFalse(inspection.selectedRow.canShare)
        XCTAssertEqual(inspection.selectedRow.issueCodes, ["share_rights_blocked"])
    }

    func testCacheAndSeedFailuresFailClosed() {
        let result = Self.result(sourceIDs: ["source.official"])
        let inspection = SourceAtlasAuthorityMesh().inspect(
            SourceAtlasAuthorityMeshInput(
                queryResponse: Self.response(results: [result]),
                authorityRecords: [
                    Self.authority(sourceID: "source.official", jurisdictionIDs: ["global"], shareRight: .publicExport)
                ],
                context: SourceAtlasAuthorityMeshContext(action: .visibleStep),
                upstreamState: SourceAtlasAuthorityUpstreamState(
                    cacheCanSupportCurrentUse: false,
                    seedCanSupportCurrentUse: false,
                    cacheIssueCodes: ["revoked_by_manifest"],
                    seedIssueCodes: ["claim_revoked"]
                )
            )
        )

        XCTAssertFalse(inspection.canSupportCurrentUse)
        XCTAssertEqual(
            inspection.selectedRow.issueCodes,
            ["cache_cannot_support_current_use", "seed_cannot_support_current_use"]
        )
        XCTAssertEqual(inspection.selectedRow.cacheIssueCodes, ["revoked_by_manifest"])
        XCTAssertEqual(inspection.selectedRow.seedIssueCodes, ["claim_revoked"])
    }

    func testMatrixRowsSortDeterministically() {
        let later = Self.result(id: "pack.z::requirement.z", packID: "pack.z", requirementID: "requirement.z", sourceIDs: ["source.z"])
        let earlier = Self.result(id: "pack.a::requirement.a", packID: "pack.a", requirementID: "requirement.a", sourceIDs: ["source.a"])
        let rows = SourceAtlasAuthorityMesh().matrix(
            SourceAtlasAuthorityMeshInput(
                queryResponse: Self.response(results: [later, earlier], selected: later),
                authorityRecords: [
                    Self.authority(sourceID: "source.a", jurisdictionIDs: ["global"], shareRight: .publicExport),
                    Self.authority(sourceID: "source.z", jurisdictionIDs: ["global"], shareRight: .publicExport)
                ],
                context: SourceAtlasAuthorityMeshContext(action: .visibleStep)
            )
        )

        XCTAssertEqual(rows.map(\.resultID), ["pack.a::requirement.a", "pack.z::requirement.z"])
    }
}

private extension SourceAtlasAuthorityMeshTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)

    static func authority(
        sourceID: String,
        state: SourceAtlasAuthoritySourceState = .accepted,
        jurisdictionIDs: [String],
        shareRight: SourceAtlasAuthorityShareRight
    ) -> SourceAtlasAuthorityRecord {
        SourceAtlasAuthorityRecord(
            id: "authority.\(sourceID)",
            sourceID: sourceID,
            state: state,
            jurisdictionIDs: jurisdictionIDs,
            shareRight: shareRight,
            lastReviewedAt: checkedAt
        )
    }

    static func response(
        results: [SourceAtlasQueryResult],
        selected: SourceAtlasQueryResult? = nil
    ) -> SourceAtlasQueryResponse {
        SourceAtlasQueryResponse(
            query: SourceAtlasQuery(domainID: "sports"),
            results: results,
            selectedResult: selected ?? results[0]
        )
    }

    static func result(
        id: String = "pack.sports::requirement.current",
        packID: String = "pack.sports",
        requirementID: String = "requirement.current",
        sourceIDs: [String],
        sourceState: SourceAtlasRequirementSourceState = .officialCurrent,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        fallbackReason: SourceAtlasQueryFallbackReason? = nil
    ) -> SourceAtlasQueryResult {
        SourceAtlasQueryResult(
            id: id,
            packID: packID,
            domainID: "sports",
            goalIntent: "starter_goal",
            claimID: "claim.current",
            requirementID: requirementID,
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: .low,
            riskClass: .sportRules,
            reviewState: reviewState,
            provenanceSourceIDs: sourceIDs,
            proofEntryIDs: ["evidence.current"],
            fallbackReason: fallbackReason,
            sourceNeededDetail: nil
        )
    }
}
