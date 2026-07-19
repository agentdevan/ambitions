import XCTest
@testable import Ambitions

final class SourceAtlasSeedFoundryTests: XCTestCase {
    // Guard note: this Persistence fixture boundary does not introduce SourceRecord, Receipt, or ReplayTrace owners.

    func testReusableSourceBoundSeedBuildsCurrentPackStateMatrixRow() {
        let checkedAt = Self.date(2026, 6, 1)
        let descriptor = Self.validDescriptor(checkedAt: checkedAt)
        let record = SourceAtlasSeedFoundry().evaluate(
            descriptor: descriptor,
            pack: Self.validPack(),
            checkedAt: checkedAt
        )

        XCTAssertTrue(record.canSupportCurrentUse)
        XCTAssertEqual(record.packState, .current)
        XCTAssertTrue(record.issues.isEmpty)
        XCTAssertEqual(record.matrixRow.packID, "sports.pickleball.domain")
        XCTAssertEqual(record.matrixRow.seedID, "seed-serve-reusable")
        XCTAssertEqual(record.matrixRow.releaseRecordID, "release-seed-serve")
        XCTAssertEqual(record.matrixRow.daysUntilReleaseRecordExpiry, 30)
        XCTAssertTrue(record.matrixRow.canSupportCurrentUse)
    }

    func testFreshnessWindowExpiryBlocksCurrentUse() {
        let checkedAt = Self.date(2026, 7, 1)
        let descriptor = Self.validDescriptor(
            checkedAt: checkedAt,
            releaseRecord: Self.releaseRecord(
                releasedAt: Self.date(2026, 5, 1),
                expiresAt: Self.date(2026, 5, 15)
            )
        )

        let record = SourceAtlasSeedFoundry().evaluate(
            descriptor: descriptor,
            pack: Self.validPack(),
            checkedAt: checkedAt,
            policy: SourceAtlasSeedReusePolicy(maximumFreshnessWindowDays: 20)
        )

        XCTAssertFalse(record.canSupportCurrentUse)
        XCTAssertEqual(record.packState, .stale)
        XCTAssertTrue(record.issues.contains(.freshnessWindowExpired))
        XCTAssertEqual(record.matrixRow.issueCodes, ["freshness_window_expired"])
    }

    func testContradictedClaimBlocksSeedReuseEvenWhenReleaseRecordExists() {
        let checkedAt = Self.date(2026, 6, 1)
        let pack = Self.validPack(
            claims: [
                SourceAtlasClaim(
                    id: "claim-serve",
                    text: "A later source contradicted this serve rule.",
                    state: .contradicted,
                    freshness: .disputed,
                    riskClass: .sportRules,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                )
            ]
        )

        let record = SourceAtlasSeedFoundry().evaluate(
            descriptor: Self.validDescriptor(checkedAt: checkedAt),
            pack: pack,
            checkedAt: checkedAt
        )

        XCTAssertFalse(record.canSupportCurrentUse)
        XCTAssertEqual(record.packState, .contradicted)
        XCTAssertTrue(record.issues.contains(.claimContradicted))
        XCTAssertTrue(record.issues.contains(.claimCannotSupportCurrentUse))
    }

    func testRejectedReleaseRecordBlocksSeedReuse() {
        let checkedAt = Self.date(2026, 6, 1)
        let descriptor = Self.validDescriptor(
            checkedAt: checkedAt,
            releaseRecord: Self.releaseRecord(
                releaseState: .rejected,
                accepted: false,
                releasedAt: checkedAt,
                expiresAt: Self.date(2026, 7, 1)
            )
        )

        let record = SourceAtlasSeedFoundry().evaluate(
            descriptor: descriptor,
            pack: Self.validPack(),
            checkedAt: checkedAt
        )

        XCTAssertFalse(record.canSupportCurrentUse)
        XCTAssertEqual(record.packState, .releaseBlocked)
        XCTAssertEqual(record.issues, [.releaseRecordRejected])
    }

    func testOneGoalOnlySeedAndFinalScheduleStorageAreBlocked() {
        let checkedAt = Self.date(2026, 6, 1)
        let descriptor = Self.validDescriptor(
            checkedAt: checkedAt,
            reuseScope: .oneGoalOnly,
            storesFinalSchedule: true
        )

        let record = SourceAtlasSeedFoundry().evaluate(
            descriptor: descriptor,
            pack: Self.validPack(),
            checkedAt: checkedAt
        )

        XCTAssertFalse(record.canSupportCurrentUse)
        XCTAssertEqual(record.packState, .seedBlocked)
        XCTAssertTrue(record.issues.contains(.reuseScopeNotReusable))
        XCTAssertTrue(record.issues.contains(.storesFinalSchedule))
    }

    func testMatrixSortsSeedRowsDeterministically() {
        let checkedAt = Self.date(2026, 6, 1)
        let pack = Self.validPack()
        let later = Self.validDescriptor(
            id: "seed-z",
            checkedAt: checkedAt,
            releaseRecord: Self.releaseRecord(id: "release-z", seedID: "seed-z", releasedAt: checkedAt, expiresAt: Self.date(2026, 7, 1))
        )
        let earlier = Self.validDescriptor(
            id: "seed-a",
            checkedAt: checkedAt,
            releaseRecord: Self.releaseRecord(id: "release-a", seedID: "seed-a", releasedAt: checkedAt, expiresAt: Self.date(2026, 7, 1))
        )

        let rows = SourceAtlasSeedFoundry().matrix(
            descriptors: [later, earlier],
            pack: pack,
            checkedAt: checkedAt
        )

        XCTAssertEqual(rows.map(\.seedID), ["seed-a", "seed-z"])
    }
}

private extension SourceAtlasSeedFoundryTests {
    static func validDescriptor(
        id: String = "seed-serve-reusable",
        checkedAt: Date,
        reuseScope: SourceAtlasSeedReuseScope = .domain,
        storesFinalSchedule: Bool = false,
        releaseRecord: SourceAtlasSeedReleaseRecord? = nil
    ) -> SourceAtlasReusableSeedDescriptor {
        SourceAtlasReusableSeedDescriptor(
            id: id,
            packID: "sports.pickleball.domain",
            sourceSeedID: "seed-profile-pickleball-starter",
            title: "Reusable serve practice seed",
            reuseScope: reuseScope,
            sourceRecordIDs: ["source-official"],
            claimIDs: ["claim-serve"],
            requirementIDs: ["requirement-serve"],
            storesFinalSchedule: storesFinalSchedule,
            releaseRecord: releaseRecord ?? self.releaseRecord(
                seedID: id,
                releasedAt: checkedAt,
                expiresAt: Self.date(2026, 7, 1)
            )
        )
    }

    static func releaseRecord(
        id: String = "release-seed-serve",
        seedID: String = "seed-serve-reusable",
        releaseState: SourceAtlasSeedReleaseState = .accepted,
        accepted: Bool = true,
        releasedAt: Date,
        expiresAt: Date
    ) -> SourceAtlasSeedReleaseRecord {
        SourceAtlasSeedReleaseRecord(
            id: id,
            packID: "sports.pickleball.domain",
            seedID: seedID,
            packVersion: "1.0.0",
            manifestVersionID: "manifest.2026-06-01",
            releaseState: releaseState,
            accepted: accepted,
            releasedAt: releasedAt,
            expiresAt: expiresAt,
            checksum: "sha256:seed",
            sourceRecordIDs: ["source-official"],
            claimIDs: ["claim-serve"]
        )
    }

    static func validPack(
        claims: [SourceAtlasClaim]? = nil
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "sports.pickleball.domain",
                title: "Pickleball Domain",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: "source-official",
                    title: "Official pickleball rules",
                    kind: .official,
                    locator: "https://example.test/rules",
                    retrievedAt: "2026-05-06T20:00:00Z",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                )
            ],
            claims: claims ?? [
                SourceAtlasClaim(
                    id: "claim-serve",
                    text: "Serve rules require a source-backed rules overlay.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                )
            ],
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement-serve",
                    claimID: "claim-serve",
                    title: "Understand serve rule",
                    kind: .hard,
                    required: true,
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: .approved
                )
            ],
            starterItems: [],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "evidence-serve",
                    requirementID: "requirement-serve",
                    proofDescription: "Reviewed rule source.",
                    privacyClass: .privateLife,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: "capability-serve",
                    sourceRecordIDs: ["source-official"],
                    sourceClaimIDs: ["claim-serve"],
                    correctionHookIDs: ["hook-correct-serve"],
                    revocationHookIDs: ["hook-revoke-serve"],
                    evidenceLedgerBridgeIDs: ["ledger-serve"]
                )
            ],
            projections: [
                SourceAtlasGoalProjection(
                    id: "recipe-pickleball-starter",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
                    projectionProfiles: [
                        SourceAtlasProjectionProfile(
                            id: "profile-pickleball-starter",
                            profileTitle: "Starter",
                            sourceState: .officialCurrent,
                            freshnessState: .current,
                            riskState: .low,
                            reviewState: .approved,
                            producesPersonalPathInstance: true,
                            producesProjectionReceipt: true,
                            optionValueMap: SourceAtlasOptionValueMap(
                                id: "map-profile-pickleball-starter",
                                values: ["cadence": "steady"],
                                sourceState: .officialCurrent,
                                freshnessState: .current,
                                reviewState: .approved,
                                riskState: .low
                            ),
                            personalPathInstances: [
                                SourceAtlasPersonalPathInstance(
                                    id: "path-profile-pickleball-starter",
                                    personalPathTemplateID: "template-profile-pickleball-starter",
                                    stepCandidateSeeds: [
                                        SourceAtlasStepCandidateSeed(
                                            id: "seed-profile-pickleball-starter",
                                            stepCandidate: "Practice a goal-aligned serve path."
                                        )
                                    ],
                                    sourceState: .officialCurrent,
                                    freshnessState: .current,
                                    reviewState: .approved,
                                    riskState: .low,
                                    sourceRecordIDs: ["source-official"]
                                )
                            ]
                        )
                    ]
                )
            ],
            freshnessPolicy: SourceAtlasFreshnessPolicy(
                reviewIntervalDays: 180,
                staleBlocksHighRiskUse: true
            ),
            riskPolicy: SourceAtlasRiskPolicy(
                strictReviewRiskClasses: SourceAtlasRiskClass.allCases.filter(\.requiresStrictReview)
            ),
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Official requirements need a source.",
                reviewRequired: "Review before using this for current use.",
                notProfessionalAdvice: "This is planning support, not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["pickleball.serve", "pickleball.rules"],
                overlayDependencyIDs: ["sports.pickleball.rules"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: []
            )
        )
    }

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: year,
            month: month,
            day: day
        ).date!
    }
}
