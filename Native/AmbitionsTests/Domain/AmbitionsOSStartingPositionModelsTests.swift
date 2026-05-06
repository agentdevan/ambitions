import XCTest
@testable import Ambitions

final class AmbitionsOSStartingPositionModelsTests: XCTestCase {
    private let validator = AmbitionsOSStartingPositionValidator()

    func testReviewReadyBaselineKeepsDignityLanguageAndMapsSignals() throws {
        let snapshot = snapshot(
            signals: [
                signal(id: "advantage-proof", dimension: .proof, kind: .proof),
                signal(id: "constraint-time", dimension: .availability, kind: .constraint),
                signal(id: "unknown-source", dimension: .educationLevel, kind: .unknown)
            ],
            intakeQuestions: [
                question(id: "availability-question", dimension: .availability, isRequiredForPathFit: true)
            ]
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(AmbitionsOSStartingPositionSnapshot.self, from: data)

        XCTAssertEqual(validator.validate(decoded), [])
        XCTAssertEqual(decoded.pathFit, .reviewReady)
        XCTAssertEqual(decoded.advantages.map(\.id), ["advantage-proof"])
        XCTAssertEqual(decoded.constraints.map(\.id), ["constraint-time"])
        XCTAssertEqual(decoded.unknowns.map(\.id), ["unknown-source"])
        XCTAssertEqual(decoded.dignityLanguage, "This is where the path starts.")
    }

    func testInvalidSchemaAndMalformedSignalsAreRejected() {
        let snapshot = snapshot(
            id: "",
            title: "",
            signals: [
                signal(id: "", title: "", dimension: .skills, kind: .advantage, schemaVersion: "old.schema")
            ],
            intakeQuestions: [
                question(id: "", prompt: "", reason: "", dimension: .availability, isRequiredForPathFit: true)
            ],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(snapshot)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedSnapshot))
        XCTAssertTrue(issues.contains(.malformedSignal))
        XCTAssertTrue(issues.contains(.malformedIntakeQuestion))
    }

    func testSourceSensitiveStartingFactsRequireSourceReviewBeforePathFit() {
        let snapshot = snapshot(
            signals: [
                signal(
                    id: "jurisdiction",
                    dimension: .locationJurisdiction,
                    kind: .constraint,
                    sourceState: .sourceNeeded,
                    freshnessState: .staleCritical
                ),
                signal(id: "unknown-source", dimension: .educationLevel, kind: .unknown)
            ]
        )

        let issues = validator.validate(snapshot)

        XCTAssertEqual(snapshot.pathFit, .needsSourceReview)
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
    }

    func testEligibilityCertificationAndBehindLanguageAreBlocked() {
        let snapshot = snapshot(
            signals: [
                signal(id: "unknown-source", dimension: .educationLevel, kind: .unknown)
            ],
            surfaceLanguageSamples: ["You are behind and need to catch up."],
            claimsEligibilityAsCertified: true
        )

        let issues = validator.validate(snapshot)

        XCTAssertEqual(snapshot.pathFit, .blocked)
        XCTAssertTrue(issues.contains(.certificationOverclaim))
        XCTAssertTrue(issues.contains(.behindLanguage))
    }

    func testSensitiveIntakeMustBeRequiredAndReviewed() {
        let snapshot = snapshot(
            signals: [
                signal(id: "unknown-source", dimension: .privacyNeeds, kind: .unknown)
            ],
            intakeQuestions: [
                question(
                    id: "health-question",
                    dimension: .healthPhysicalConstraint,
                    isRequiredForPathFit: false,
                    privacyClass: .sensitive,
                    reviewState: .needsPrivacyReview
                )
            ]
        )

        let issues = validator.validate(snapshot)

        XCTAssertEqual(snapshot.pathFit, .needsUserReview)
        XCTAssertTrue(issues.contains(.unnecessarySensitiveIntake))
        XCTAssertTrue(issues.contains(.privacyReviewRequired))
    }

    func testExternalProjectionAndRuntimeStoreBehaviorAreRejected() {
        let snapshot = snapshot(
            signals: [
                signal(id: "sensitive-proof", dimension: .proof, kind: .proof, privacyClass: .sensitive),
                signal(id: "unknown-source", dimension: .privacyNeeds, kind: .unknown)
            ],
            externalProjectionRequested: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: false,
                writesPersistence: true
            )
        )

        let issues = validator.validate(snapshot)

        XCTAssertEqual(snapshot.pathFit, .blocked)
        XCTAssertTrue(issues.contains(.externalProjectionRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }

    func testMissingUnknownsAreHeldAsIncompleteNotCertified() {
        let snapshot = snapshot(
            signals: [
                signal(id: "advantage-proof", dimension: .proof, kind: .proof)
            ]
        )

        XCTAssertEqual(snapshot.pathFit, .missingUnknowns)
        XCTAssertTrue(validator.validate(snapshot).contains(.missingUnknowns))
    }
}

private extension AmbitionsOSStartingPositionModelsTests {
    func snapshot(
        id: String = "starting-position",
        title: String = "Starting position",
        signals: [AmbitionsOSStartingPositionSignal],
        intakeQuestions: [AmbitionsOSStartingPositionIntakeQuestion] = [],
        surfaceLanguageSamples: [String] = ["This is where the path starts."],
        claimsEligibilityAsCertified: Bool = false,
        externalProjectionRequested: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSStartingPositionSchemaVersion
    ) -> AmbitionsOSStartingPositionSnapshot {
        AmbitionsOSStartingPositionSnapshot(
            id: id,
            title: title,
            signals: signals,
            intakeQuestions: intakeQuestions,
            surfaceLanguageSamples: surfaceLanguageSamples,
            claimsEligibilityAsCertified: claimsEligibilityAsCertified,
            externalProjectionRequested: externalProjectionRequested,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func signal(
        id: String,
        title: String = "Starting signal",
        dimension: AmbitionsOSStartingPositionDimension,
        kind: AmbitionsOSStartingPositionSignalKind,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSStartingPositionSchemaVersion
    ) -> AmbitionsOSStartingPositionSignal {
        AmbitionsOSStartingPositionSignal(
            id: id,
            title: title,
            dimension: dimension,
            kind: kind,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sourceClaimIDs: ["claim-1"],
            receiptIDs: ["receipt-1"],
            schemaVersion: schemaVersion
        )
    }

    func question(
        id: String,
        prompt: String = "What should Ambitions know before suggesting a path?",
        reason: String = "This keeps the first path honest.",
        dimension: AmbitionsOSStartingPositionDimension,
        isRequiredForPathFit: Bool,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        schemaVersion: String = ambitionsOSStartingPositionSchemaVersion
    ) -> AmbitionsOSStartingPositionIntakeQuestion {
        AmbitionsOSStartingPositionIntakeQuestion(
            id: id,
            prompt: prompt,
            dimension: dimension,
            reason: reason,
            isRequiredForPathFit: isRequiredForPathFit,
            privacyClass: privacyClass,
            reviewState: reviewState,
            schemaVersion: schemaVersion
        )
    }
}
