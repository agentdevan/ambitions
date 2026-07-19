import XCTest
@testable import Ambitions

final class SourceAtlasFoundryM02ContractModelsTests: XCTestCase {
    func testM02FoundryPackDecodesAndPreservesPublicProvenanceFreshnessAndBoundaryFlags() throws {
        let data = try JSONSerialization.data(withJSONObject: Self.validFoundryPack())
        let pack = try JSONDecoder().decode(SourceAtlasFoundryM02Pack.self, from: data)

        XCTAssertEqual(pack.kind, "ambitions.sourceAtlas.foundryPack")
        XCTAssertTrue(pack.isPublicReferenceOnly)
        XCTAssertTrue(pack.preservesFoundryClaimStates)
        XCTAssertEqual(pack.metadata.freshnessState, "candidate")
        XCTAssertEqual(pack.sources.first?.publisher, "National Archives")
        XCTAssertEqual(pack.sources.first?.freshnessCadence, "stable law watch")
        XCTAssertEqual(pack.claims.first?.state, "source_backed")
        XCTAssertEqual(pack.claims.first?.freshness, "stable_law_watch")
        XCTAssertTrue(pack.claims.first?.requiresExplicitNativePromotion == true)
        XCTAssertTrue(pack.pathways.first?.runtimeBehavior.mustJoinWithPrivateRuntimeLocally == true)
        XCTAssertTrue(pack.pathways.first?.runtimeBehavior.mustNotUploadPrivateContext == true)
        XCTAssertEqual(pack.inspectionContract.defaultVisibility, "hidden")
        XCTAssertTrue(pack.nonClaims.contains("not a private user-data backend"))
    }

    func testSourceBackedFoundryClaimDoesNotBecomeNativeOfficialCurrentWithoutPromotion() throws {
        let data = try JSONSerialization.data(withJSONObject: Self.validFoundryPack())
        let pack = try JSONDecoder().decode(SourceAtlasFoundryM02Pack.self, from: data)
        let claim = try XCTUnwrap(pack.claims.first)

        XCTAssertEqual(claim.state, "source_backed")
        XCTAssertNotEqual(claim.state, SourceAtlasClaimState.official.rawValue)
        XCTAssertNotEqual(claim.freshness, SourceAtlasFreshnessState.current.rawValue)
        XCTAssertTrue(claim.requiresExplicitNativePromotion)
    }

    func testNativeM02BoundaryValidatorRejectsPrivateFieldsAndText() {
        let invalid: [String: Any] = [
            "goalText": "Become an astronaut",
            "captureText": "I captured a private thought.",
            "calendarData": ["Tuesday"],
            "capacity": "two hours",
            "lifeCapital": ["credential": "private"],
            "proofPayload": ["note": "private proof"],
            "receiptPayload": ["note": "private receipt"],
            "accountSecret": "pk-syntheticnotreal12345",
            "userID": "user-1234",
            "privateLifeGraph": ["nodes": []],
            "contact": "person@example.test",
            "kind": "ambitions.sourceAtlas.userMiniPack",
            "privacyClass": "privateLife",
            "sourceKind": "userProvided"
        ]

        let issues = Set(SourceAtlasFoundryM02BoundaryValidator().validate(jsonObject: invalid))

        XCTAssertTrue(issues.contains(.goalText))
        XCTAssertTrue(issues.contains(.captureText))
        XCTAssertTrue(issues.contains(.scheduleOrCapacity))
        XCTAssertTrue(issues.contains(.lifeCapital))
        XCTAssertTrue(issues.contains(.proofPayload))
        XCTAssertTrue(issues.contains(.receiptPayload))
        XCTAssertTrue(issues.contains(.accountSecret))
        XCTAssertTrue(issues.contains(.userIdentifier))
        XCTAssertTrue(issues.contains(.privateLifeGraph))
        XCTAssertTrue(issues.contains(.privateText))
        XCTAssertTrue(issues.contains(.userMiniPack))
        XCTAssertTrue(issues.contains(.privatePrivacyClass))
        XCTAssertTrue(issues.contains(.userProvidedSource))
    }

    func testNativeM02BoundaryValidatorAllowsPublicBoundaryMetadata() {
        let valid: [String: Any] = [
            "metadata": [
                "localPersonalizationRequired": true,
                "sourceAtlasInvisibleByDefault": true,
                "privacyBoundary": "public/reference/freshness only; no private life graph or private user context"
            ],
            "nonClaims": [
                "not a private user-data backend"
            ]
        ]

        XCTAssertEqual(SourceAtlasFoundryM02BoundaryValidator().validate(jsonObject: valid), [])
    }
}

private extension SourceAtlasFoundryM02ContractModelsTests {
    static func validFoundryPack() -> [String: Any] {
        [
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.foundryPack",
            "id": "pack.civic.us_president",
            "versionID": "m02-fixture-v1",
            "dataClass": "public_reference_claim",
            "metadata": [
                "freshnessState": "candidate",
                "privacyBoundary": "public/reference/freshness only; no private life graph, goals, captures, calendar data, proof, receipts, personalization, behavior history, or private user context",
                "runtimeRole": "reference_enrichment_only",
                "localPersonalizationRequired": true,
                "sourceAtlasInvisibleByDefault": true
            ],
            "sources": [
                [
                    "id": "nara.constitution.presidency",
                    "title": "U.S. Constitution presidential eligibility",
                    "publisher": "National Archives",
                    "url": "https://www.archives.gov/founding-docs/constitution-transcript",
                    "authorityTier": "constitutional_primary",
                    "freshnessCadence": "stable law watch",
                    "license": "U.S. federal public source; cite source URL"
                ]
            ],
            "claims": [
                [
                    "id": "claim.president.age_35",
                    "text": "The presidency has a minimum age eligibility gate of 35 years.",
                    "claimType": "eligibility_rule",
                    "state": "source_backed",
                    "freshness": "stable_law_watch",
                    "sourceIDs": ["nara.constitution.presidency"]
                ]
            ],
            "requirements": [
                [
                    "id": "requirement.president.minimum_age",
                    "claimID": "claim.president.age_35",
                    "gateType": "eligibility",
                    "structuredRule": [
                        "type": "minimum_age",
                        "years": 35
                    ]
                ]
            ],
            "pathways": [
                [
                    "id": "pathway.civic.us_president",
                    "title": "Become eligible to serve as President of the United States",
                    "domain": "civic",
                    "runtimeBehavior": [
                        "canEnrichLocalPath": true,
                        "mustJoinWithPrivateRuntimeLocally": true,
                        "mustNotUploadPrivateContext": true,
                        "inspectionVisibleOnlyWhenUseful": true,
                        "freshnessChangeMayTriggerReview": true
                    ]
                ]
            ],
            "inspectionContract": [
                "defaultVisibility": "hidden",
                "showWhen": ["user_asks_why", "source_freshness_changes_path_behavior"],
                "mustInclude": ["source", "claim", "freshness", "uncertainty", "user_control"]
            ],
            "nonClaims": [
                "not a private user-data backend",
                "not runtime recommendation proof by itself"
            ]
        ]
    }
}
