import XCTest
@testable import Ambitions

final class AmbitionsOSLocalGoalPackModelsTests: XCTestCase {
    func testReviewedLocalPackRoundTripsAndProjectsCompilerSlots() throws {
        let pack = localPack(
            qualityState: .reviewed,
            requirementSlots: [
                Self.slot(
                    id: "requirement.training",
                    title: "Keep a reviewed training requirement available",
                    kind: .hardRequirement,
                    origin: .sourceBacked,
                    sourceState: .sourceBacked,
                    freshnessState: .current,
                    reviewState: .ready,
                    sourceClaimIDs: ["claim.training"]
                )
            ],
            starterSeeds: [
                AmbitionsOSLocalGoalPackStarterSeed(
                    id: "seed.training",
                    title: "Review training fit",
                    stepCandidateSeed: "Compare the requirement to your current week"
                )
            ],
            projectionRecipeIDs: ["recipe.training-fit"]
        )

        let data = try JSONEncoder().encode(pack)
        let decoded = try JSONDecoder().decode(AmbitionsOSLocalGoalPack.self, from: data)

        XCTAssertEqual(decoded, pack)
        XCTAssertTrue(decoded.validationIssues.isEmpty)
        XCTAssertEqual(decoded.compilerRequirementSlots.count, 1)
        XCTAssertEqual(decoded.compilerRequirementSlots.first?.sourceState, .sourceBacked)
        XCTAssertEqual(decoded.compilerRequirementSlots.first?.schemaVersion, ambitionsOSGoalPathCompilerSchemaVersion)
    }

    func testInvalidSchemaAndMalformedSlotsAreRejected() {
        let pack = localPack(
            manifest: Self.manifest(schemaVersion: "future"),
            requirementSlots: [
                Self.slot(id: "", title: "", schemaVersion: "future")
            ],
            schemaVersion: "future"
        )

        let issues = pack.validationIssues

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.missingManifestIdentity))
        XCTAssertTrue(issues.contains(.malformedRequirementSlot))
    }

    func testCompositionNoSprawlAndSourceAtlasAnchorAreRequired() {
        let pack = localPack(
            manifest: Self.manifest(
                sourceAtlasPackID: "",
                dependencyPackIDs: ["domain.health", "domain.health"],
                ownsIndividualGoalPhrase: true
            )
        )

        let issues = pack.validationIssues

        XCTAssertEqual(pack.manifest.dependencyPackIDs, ["domain.health"])
        XCTAssertTrue(issues.contains(.missingSourceAtlasPack))
        XCTAssertTrue(issues.contains(.onePackPerGoalRisk))
    }

    func testSourceFreeOfficialRequirementClaimsAreBlocked() {
        let pack = localPack(
            requirementSlots: [
                Self.slot(
                    kind: .hardRequirement,
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    reviewState: .needsSourceReview,
                    sourceClaimIDs: [],
                    claimsOfficialRequirement: true
                )
            ]
        )

        let issues = pack.validationIssues

        XCTAssertTrue(issues.contains(.officialRequirementOverclaim))
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
    }

    func testGeneratedPackAndGeneratedSlotCannotAppearReviewed() {
        let pack = localPack(
            qualityState: .generated,
            requirementSlots: [
                Self.slot(
                    origin: .generated,
                    sourceState: .userConfirmed,
                    freshnessState: .current,
                    reviewState: .ready
                )
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.generatedBoundaryRequired))
    }

    func testStarterSeedsStayCandidateOnlyAndNoExecutableRuntimeIsAllowed() {
        let pack = localPack(
            starterSeeds: [
                AmbitionsOSLocalGoalPackStarterSeed(
                    id: "seed.final-schedule",
                    title: "Universal daily schedule",
                    stepCandidateSeed: "Every user does this at 8 AM daily",
                    storesFinalSchedule: true
                )
            ],
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: false
            ),
            containsExecutableLogic: true
        )

        let issues = pack.validationIssues

        XCTAssertTrue(issues.contains(.universalScheduledStep))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.executableLogicBehavior))
    }

    func testDuplicateSlotsAreRejectedWithoutPersistenceStoreBehavior() {
        let pack = localPack(
            requirementSlots: [
                Self.slot(id: "requirement.shared"),
                Self.slot(id: "requirement.shared")
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.duplicateRequirementSlotID))
        XCTAssertFalse(pack.validationIssues.contains(.runtimeStoreBehavior))
    }

    private func localPack(
        manifest: AmbitionsOSLocalGoalPackManifest? = nil,
        qualityState: AmbitionsOSLocalGoalPackQualityState = .needsSourceReview,
        requirementSlots: [AmbitionsOSLocalGoalPackRequirementSlotDefinition]? = nil,
        starterSeeds: [AmbitionsOSLocalGoalPackStarterSeed] = [],
        projectionRecipeIDs: [String] = [],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        containsExecutableLogic: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) -> AmbitionsOSLocalGoalPack {
        AmbitionsOSLocalGoalPack(
            manifest: manifest ?? Self.manifest(),
            qualityState: qualityState,
            requirementSlots: requirementSlots ?? [Self.slot()],
            starterSeeds: starterSeeds,
            projectionRecipeIDs: projectionRecipeIDs,
            runtimeBoundary: runtimeBoundary,
            containsExecutableLogic: containsExecutableLogic,
            schemaVersion: schemaVersion
        )
    }

    private static func manifest(
        id: String = "pack.local.training",
        title: String = "Training Local Pack",
        sourceAtlasPackID: String = "source-atlas.training",
        kind: SourceAtlasPackKind = .starterKit,
        domainID: String = "training",
        dependencyPackIDs: [String] = ["domain.training"],
        ownsIndividualGoalPhrase: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) -> AmbitionsOSLocalGoalPackManifest {
        AmbitionsOSLocalGoalPackManifest(
            id: id,
            title: title,
            sourceAtlasPackID: sourceAtlasPackID,
            kind: kind,
            domainID: domainID,
            dependencyPackIDs: dependencyPackIDs,
            ownsIndividualGoalPhrase: ownsIndividualGoalPhrase,
            schemaVersion: schemaVersion
        )
    }

    private static func slot(
        id: String = "requirement.source-needed",
        title: String = "Confirm the current requirement",
        kind: AmbitionsOSGoalPathRequirementKind = .sourceNeeded,
        origin: AmbitionsOSLocalGoalPackSlotOrigin = .authored,
        blocking: Bool = true,
        sourceState: HumanProgressSourceState = .sourceNeeded,
        freshnessState: HumanProgressFreshnessState = .unknown,
        reviewState: HumanProgressReviewState = .needsSourceReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceClaimIDs: [String] = [],
        proofReceiptIDs: [String] = [],
        claimsOfficialRequirement: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) -> AmbitionsOSLocalGoalPackRequirementSlotDefinition {
        AmbitionsOSLocalGoalPackRequirementSlotDefinition(
            id: id,
            title: title,
            kind: kind,
            origin: origin,
            blocking: blocking,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sourceClaimIDs: sourceClaimIDs,
            proofReceiptIDs: proofReceiptIDs,
            claimsOfficialRequirement: claimsOfficialRequirement,
            schemaVersion: schemaVersion
        )
    }
}
