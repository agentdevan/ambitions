import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModelsTests: XCTestCase {
    private let validator = AmbitionsOSLivingDreamStartingPositionPrivacyIntakeValidator()

    func testAnsweredMinimalIntakeCanProceedWithoutStorageOrMutation() throws {
        let packet = intakePacket(
            questions: [
                question(
                    id: "availability-question",
                    dimension: .availability,
                    answerState: .answered,
                    linkedStartingSignalIDs: ["unknown-availability"]
                )
            ],
            privacyPolicies: []
        )

        let data = try JSONEncoder().encode(packet)
        let decoded = try JSONDecoder().decode(
            AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket.self,
            from: data
        )
        let evaluation = validator.evaluate(packet: decoded)

        XCTAssertEqual(evaluation.issues, [])
        XCTAssertEqual(evaluation.readiness, .readyForPathPortfolio)
        XCTAssertEqual(evaluation.requiredQuestionIDs, ["availability-question"])
        XCTAssertEqual(evaluation.answeredQuestionIDs, ["availability-question"])
        XCTAssertFalse(evaluation.storesUserData)
        XCTAssertFalse(evaluation.mutatesCommitments)
        XCTAssertFalse(evaluation.projectsExternally)
    }

    func testRequiredUnansweredIntakeStopsAtUserAnswer() {
        let packet = intakePacket(
            questions: [
                question(
                    id: "jurisdiction-question",
                    dimension: .locationJurisdiction,
                    answerState: .unanswered,
                    linkedStartingSignalIDs: ["unknown-availability"]
                )
            ]
        )

        let evaluation = validator.evaluate(packet: packet)

        XCTAssertEqual(evaluation.readiness, .needsUserAnswer)
        XCTAssertEqual(evaluation.requiredQuestionIDs, ["jurisdiction-question"])
        XCTAssertEqual(evaluation.answeredQuestionIDs, [])
    }

    func testAskOnlyNeededBlocksUnlinkedAndUnnecessarySensitiveQuestions() {
        let packet = intakePacket(
            questions: [
                question(
                    id: "extra-health-question",
                    dimension: .healthPhysicalConstraint,
                    answerState: .unanswered,
                    requiredForPathFit: false,
                    privacyClass: .sensitive,
                    sensitiveAreas: [.medical],
                    linkedStartingSignalIDs: [],
                    retentionPolicy: .localOnlySensitive
                )
            ]
        )

        let issues = validator.validate(packet: packet)

        XCTAssertTrue(issues.contains(.unnecessaryQuestion))
        XCTAssertTrue(issues.contains(.unnecessarySensitiveIntake))
        XCTAssertEqual(validator.evaluate(packet: packet).readiness, .needsPrivacyReview)
    }

    func testSensitiveIntakeRequiresPrivacyPolicyAndLocalOnlyRetention() {
        let sensitiveQuestion = question(
            id: "medical-question",
            dimension: .healthPhysicalConstraint,
            answerState: .answered,
            privacyClass: .sensitive,
            sensitiveAreas: [.medical],
            linkedStartingSignalIDs: ["unknown-availability"],
            retentionPolicy: .localPrivate
        )
        let packet = intakePacket(questions: [sensitiveQuestion])

        let issues = validator.validate(packet: packet)

        XCTAssertTrue(issues.contains(.missingPrivacyPolicy))
        XCTAssertTrue(issues.contains(.localStorageBoundaryBroken))
        XCTAssertEqual(validator.evaluate(packet: packet).readiness, .blocked)
    }

    func testSensitiveIntakeWithReviewedPolicyStaysLocalAndReady() {
        let sensitiveQuestion = question(
            id: "medical-question",
            dimension: .healthPhysicalConstraint,
            answerState: .answered,
            privacyClass: .sensitive,
            sensitiveAreas: [.medical],
            linkedStartingSignalIDs: ["unknown-availability"],
            retentionPolicy: .localOnlySensitive
        )
        let packet = intakePacket(
            questions: [sensitiveQuestion],
            privacyPolicies: [
                privacyPolicy(objectID: "medical-question", privacyClass: .sensitive, sensitiveAreas: [.medical])
            ]
        )

        let evaluation = validator.evaluate(packet: packet)

        XCTAssertEqual(evaluation.issues, [])
        XCTAssertEqual(evaluation.readiness, .readyForPathPortfolio)
    }

    func testEligibilityRuntimeStorageAndMutationBoundariesBlockProceeding() {
        let packet = intakePacket(
            eligibilityEvaluation: eligibilityEvaluation(issues: [.deadlinePassed], blockedConditionIDs: ["deadline"]),
            questions: [
                question(
                    id: "availability-question",
                    dimension: .availability,
                    answerState: .answered,
                    linkedStartingSignalIDs: ["unknown-availability"]
                )
            ],
            writesPersistence: true,
            mutatesCommitments: true,
            usesUserDataServer: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(packet: packet)

        XCTAssertTrue(issues.contains(.eligibilityNotReady))
        XCTAssertTrue(issues.contains(.localStorageBoundaryBroken))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(issues.contains(.runtimeBoundaryBroken))
        XCTAssertEqual(validator.evaluate(packet: packet).readiness, .blocked)
    }

    func testMalformedDuplicateAndUnsupportedSchemaAreReported() {
        let packet = intakePacket(
            id: "",
            questions: [
                question(id: "", prompt: "", reason: "", dimension: .availability, linkedStartingSignalIDs: ["missing"]),
                question(id: "", prompt: "Duplicate", reason: "Duplicate", dimension: .availability, linkedStartingSignalIDs: ["missing"])
            ],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(packet: packet)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPacket))
        XCTAssertTrue(issues.contains(.malformedQuestion))
        XCTAssertTrue(issues.contains(.duplicateQuestionID))
        XCTAssertTrue(issues.contains(.missingStartingPositionUnknown))
    }
}

private extension AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModelsTests {
    func intakePacket(
        id: String = "intake-packet",
        startingPosition: AmbitionsOSStartingPositionSnapshot? = nil,
        eligibilityEvaluation: AmbitionsOSLivingDreamEligibilityDeadlineEvaluation? = nil,
        questions: [AmbitionsOSLivingDreamIntakeQuestion],
        privacyPolicies: [AmbitionsOSPrivacySafetyPolicy] = [],
        allowsExternalProjection: Bool = false,
        writesPersistence: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion
    ) -> AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket {
        AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket(
            id: id,
            startingPosition: startingPosition ?? startingPositionSnapshot(),
            eligibilityEvaluation: eligibilityEvaluation ?? self.eligibilityEvaluation(),
            questions: questions,
            privacyPolicies: privacyPolicies,
            allowsExternalProjection: allowsExternalProjection,
            writesPersistence: writesPersistence,
            mutatesCommitments: mutatesCommitments,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func startingPositionSnapshot() -> AmbitionsOSStartingPositionSnapshot {
        AmbitionsOSStartingPositionSnapshot(
            id: "starting-position",
            title: "Starting position",
            signals: [
                AmbitionsOSStartingPositionSignal(
                    id: "known-proof",
                    title: "Proof already exists",
                    dimension: .proof,
                    kind: .proof,
                    sourceState: .userConfirmed,
                    freshnessState: .current,
                    reviewState: .ready,
                    privacyClass: .privateLife,
                    sourceClaimIDs: ["claim-proof"],
                    receiptIDs: ["receipt-proof"]
                ),
                AmbitionsOSStartingPositionSignal(
                    id: "unknown-availability",
                    title: "Availability needs one answer",
                    dimension: .availability,
                    kind: .unknown,
                    sourceState: .userConfirmed,
                    freshnessState: .current,
                    reviewState: .ready,
                    privacyClass: .privateLife,
                    sourceClaimIDs: ["claim-availability"],
                    receiptIDs: ["receipt-availability"]
                )
            ]
        )
    }

    func eligibilityEvaluation(
        issues: [AmbitionsOSLivingDreamEligibilityDeadlineIssue] = [],
        blockedConditionIDs: [String] = []
    ) -> AmbitionsOSLivingDreamEligibilityDeadlineEvaluation {
        AmbitionsOSLivingDreamEligibilityDeadlineEvaluation(
            runtimeID: "eligibility-runtime",
            eligibleConditionIDs: blockedConditionIDs.isEmpty ? ["deadline"] : [],
            blockedConditionIDs: blockedConditionIDs,
            issues: issues,
            activatesPlans: false,
            mutatesCommitments: false
        )
    }

    func question(
        id: String,
        prompt: String = "What should Ambitions know before suggesting a path?",
        reason: String = "This keeps the first path honest.",
        dimension: AmbitionsOSStartingPositionDimension,
        answerState: AmbitionsOSLivingDreamIntakeAnswerState = .unanswered,
        requiredForPathFit: Bool = true,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        linkedStartingSignalIDs: [String],
        linkedEligibilityConditionIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        retentionPolicy: AmbitionsOSLivingDreamIntakeRetentionPolicy = .sessionOnly,
        reviewState: HumanProgressReviewState = .ready,
        schemaVersion: String = ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion
    ) -> AmbitionsOSLivingDreamIntakeQuestion {
        AmbitionsOSLivingDreamIntakeQuestion(
            id: id,
            prompt: prompt,
            reason: reason,
            dimension: dimension,
            answerState: answerState,
            requiredForPathFit: requiredForPathFit,
            privacyClass: privacyClass,
            sensitiveAreas: sensitiveAreas,
            linkedStartingSignalIDs: linkedStartingSignalIDs,
            linkedEligibilityConditionIDs: linkedEligibilityConditionIDs,
            sourceClaimIDs: sourceClaimIDs,
            retentionPolicy: retentionPolicy,
            reviewState: reviewState,
            schemaVersion: schemaVersion
        )
    }

    func privacyPolicy(
        objectID: String,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = []
    ) -> AmbitionsOSPrivacySafetyPolicy {
        AmbitionsOSPrivacySafetyPolicy(
            id: "privacy-\(objectID)",
            objectID: objectID,
            surface: .you,
            permissionState: .localOnly,
            privacyClass: privacyClass,
            sensitiveAreas: sensitiveAreas,
            reviewState: .ready,
            projectionPolicy: .redactedLocal,
            toolIntent: .readLocalSummary,
            toolApprovalState: .reviewOnly,
            deterministicFallbackAvailable: true,
            redactionSummary: "Local private intake only.",
            receipts: [
                AmbitionsOSPrivacyReceipt(
                    id: "receipt-\(objectID)",
                    action: "privacy reviewed",
                    occurredAt: "2026-05-07T14:15:00Z"
                )
            ],
            changesAppState: false,
            runtimeBoundary: .valueModelOnly
        )
    }
}
